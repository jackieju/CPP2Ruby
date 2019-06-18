load 'log.rb'
def method_signature(method_name, arg_number)
    return "#{method_name}\#\##{arg_number}"
end
def translate_varname(varname, uncapitalize=true)
    return "" if varname==nil or varname == ""
    if uncapitalize
        if varname.size ==1 
            varname = varname.downcase
        else
            varname = varname[0].downcase+varname[1..varname.size-1]
        end
    end
    keywords = ["begin", "end", "def", "rescue"]
    if keywords.include?(varname)
        return "_translated_#{varname}"
    end
    return varname
end
class Variable
    attr_accessor :name, :type, :newname
    def initialize(name, type, newname=name)
        @name = name
        @type = type
        @newname = translate_varname(newname)
    end
end
class VarType
    attr_accessor :name, :ref, :is_simpleType, :type # type can be:nil, "FunctionPointer"
    def initialize(name)
        @name = name
        @ref = 0
        @is_simpleType = false
        @type = nil
    end

end
class Scope
    # name is scope name in c/cpp, except "module"
    # name can "class", "struct", "module"(module means namespace)
    attr_accessor :name, :vars, :parentScope, :hasGoto, :labeled_blocks
    def initialize(name)
        @name = name 
        @vars = {}
        @hasGoto = false # only for functiondefinition
        @labeled_blocks =[]
    end
    
    def add_var(v)
        p "add_var:#{v.name}", 20
        if @name == "class"
            v.newname = "@#{v.newname}"
        end
        @vars[v.name] = v
        return v.newname
    end
    
    def get_var(k)
        return @vars[k]
    end

end
class ModuleDef < Scope
    attr_accessor :class_name, :modules, :classes, :methods, :src, :functions, :includings
  
    def initialize(class_name)
        super("module")
        @class_name = class_name
        @methods = {}
        @modules = {}
        @classes = {}
        # @functions record mapping from c name to ruby name, because c can overide function with same name, we will map them to "#{cmethod_name}_v#{arg_number}"
        # e.g.
        # functions=>{
        #    "fn1"=>{
        #        "fn1_v1"=>"fn1#1", #fn1 with 1 parameter
        #        "fn1_v2"=>"fn1#2"  #fn2 with 2 paratermers          
        #    }
        #}
        @functions = {} 
        @includings = [] 
    end
    def add_src(src)
        @src = "" if !@src
        @src += src
    end
    

    def add_method(method_name, args, src, acc="public")
        arg_number = args.size
        method_sig = method_signature(method_name, arg_number)
        
        # if overriden, modify name
        @functions[method_name] = {} if !@functions[method_name] 
        
        newname = "#{method_name}_v#{arg_number}"
        @functions[method_name][newname] = method_sig
        method_name = newname
            
        if @methods[method_sig]
            method_desc = @methods[method_sig]
            method_desc[:name] = method_name
            method_desc[:args] = args
            if src && src.strip != ""
                method_desc[:src] =src
            end
            if method_desc[:decoration] == nil
                method_desc[:decoration] = ""
            end
            ar = acc.split(" ")
            ar.each{|v|
                if method_desc[:decoration].index(v) == nil
                    method_desc[:decoration] += " #{v}"
                end
            }
            
        else
            @methods[method_sig]={
                :name=>method_name,
                :args=>args,
                :src=>src,
                :decoration=>acc
            }
        end
        p("method #{method_sig} added to #{self.class_name}@#{self}:#{@methods[method_sig].inspect} \n")
      #  p(@methods.inspect)
      #  if self.class != ModuleDef
      #      p ("parent:#{self.parent}")
      #      if  self.parent
      #          p("parent:#{self.parent.inspect}")
      #      else
      #          p("parent:#{self.parent}")
      #  
      #      end
      #  end
    end
    
    def add_module(module_name)
        if module_name.class == String
            moduleDef = ModuleDef.new(module_name)
            @modules[module_name] = moduleDef
            moduleDef.parentScope = self
        else
            moduleDef = module_name
            @modules[moduleDef.class_name] = moduleDef
            moduleDef.parentScope = self
            
            
        end
        return moduleDef
    end
    
    # class_name can be CladdDef Object
    def add_class(class_name)
        
        if class_name.class == String && @classes[class_name] == nil
            
            clsdef = ClassDef.new(class_name)
            @classes[class_name] = clsdef
            clsdef.parentScope = self
            p "===>add_class:#{clsdef.class_name}@#{clsdef} to #{self.class_name}@#{self}", 20
        else
            
            clsdef = class_name
            @classes[clsdef.class_name] = clsdef
            clsdef.parentScope = self
            p "===>add_class:#{clsdef.class_name}@#{clsdef} to #{self.class_name}@#{self}", 20
        end
        

        return clsdef
    end
end
class ClassDef < ModuleDef
    attr_accessor :class_name, :parent, :methods, :src, :parentScope, :functions, :includings
    def initialize(class_name)
        super("class")
        @class_name = class_name
        @methods = {}
        @name="class"
        @includings = []
    end
    # for supporting multi-inheritanc
    # will generate new module containings class content, and current class will just include the module
    def to_module
        module_name = "#{@class_name}_module"
        r = ModuleDef.new(module_name)
        r.methods = @methods
        r.functions = @functions
        r.src = @src
        r.parentScope = parentScope
        r.includings = includings
        
        @methods = {}
        @classes = {}
        @functions = {} 
        @includings = [module_name]
        return r
    end

end
class CRParser 
# Abstract Parser
  public
    def initialize(s = nil, e = nil)
        if (!e || !s) 
          p "CRParser::CRParser: No Scanner or No Error Mgr\n"
          exit(1)
        end
        @scanner = s
        @error = e
        @sym = 0
        @sstack = [] # scope stack
        @classdefs = {}
        # p "haha"
    end
    
    def current_scope(name=nil)
        return @sstack.last if name == nil
         i = @sstack.size-1
         while (i>=0)
             if @sstack[i].name == name
                 return @sstack[i]
             end
             i -= 1
         end
         return nil
    end
    
    def list_scopes
        cs = current_scope
        s = ""
        while cs
            s+= "scope:#{cs.name}=>"
            cs = cs.parentScope
        end
        p s
    end
    def in_scope(name)
        cs = current_scope
      #  p "==>in_scope0:#{name}, #{name.inspect} ", 10
        
      #  p "==>cs1:#{cs.inspect}"
        if name.class == String
            @sstack.push(Scope.new(name))
        else
            if name == cs
                throw Exception.new("enter wrong scope")
            end
            @sstack.push(name)
        end
    
      #  p("rootmod3:#{$g_root_moddef.parentScope}")
     #   p "cs2:#{current_scope.inspect}, #{cs}"
        current_scope.parentScope = cs
       #    p("rootmod4:#{$g_root_moddef.parentScope}")
        if current_scope == cs
            throw Exception.new("hahahahaha")
        end
        # p "cs3:#{current_scope.inspect}, parent=#{current_scope.parent}", 30
     
    end
    def out_scope()
        @sstack.pop
    end    
    def current_ruby_scope
         i = @sstack.size-1
         while (i>=0)
             n = @sstack[i].name
             if n == "class" || n == "struct" || n == "module"
                 return @sstack[i]
             end
             i -= 1
         end
         return nil
    end
    
    def find_var(name, scope=nil)
         p "find_var:#{name}", 10
        scope= current_scope  if !scope
        i = 1
        while scope 
             #p "scope:#{scope.inspect}"
           # p "scope:#{scope}"
           # p "class:#{scope.class_name}" if scope.is_a?(ClassDef)
            
            i+=1
            if i>=20
                dump_pos
                #p "scope:#{scope.inspect}"
                throw Exception.new("===>error<====")
            end
            scope.vars.each{|k,v|
                p "===>var:#{k}"
            }
            ret = scope.get_var(name)
            return ret if ret
            scope = scope.parentScope
        end
        return nil
    end
    def canUseBreak?
        i = @sstack.size-1
        while (i>=0)
            if @sstack[i].name == "FunctionBody" 
                return false
            end
            
            if  @sstack[i].name == "ForStatement" || @sstack[i].name == "WhileStatement" || @sstack[i].name == "DoStatement"
                return true
            end
            i -= 1
        end
        return false
        
    end
    
    
    # Constructs abstract parser, and associates it with scanner S and
    # customized error reporter E

    def CRParser
        p("Abstract CRParser::Parse() called\n")
        exit(1)
        
    end

    def Parse()
        
    end
    # Abstract parser

    def SynError(errorNo)
        if (errorNo <= @error.MinUserError) 
            errorNo = @error.MinUserError
        end    
        @error.StoreErr(errorNo, @scanner.nextSym)
             
    end
    # Records syntax error ErrorNo

    def SemError(errorNo)
        if (errorNo <= @error.MinUserError)
             errorNo = @error.MinUserError
         end
        @error.StoreErr(errorNo, @scanner.CurrSym)
    end
    # Records semantic error ErrorNo

    def dump_pos(pos=@scanner.buffPos)
        p("start dump pos", 5)
        lino = get_lineno_by_pos(pos)+1
        
        p "---- dump position ----"
        i = 3
        ls =  prevline(pos, i)
        ls.each{|l|
            p "#{"%05d" % (lino-i)}#{l}"
            i-=1
        }
       
        pos1 = pos
        while (pos1 > 0 && @scanner.buffer[pos1-1] != "\n" )
            pos1 -= 1
        end
        pos2 = pos 
        while (pos2 < @scanner.buffer.size-1 && @scanner.buffer[pos2+1] != "\n" )
            pos2 += 1
        end        
        p "#{"%05d" % (lino)}......#{@scanner.buffer[pos1..pos2].gsub("\t",' ')}......"
        s1 = ""
        for a in 0..pos-pos1-1
            s1 += "~"
        end
        s2 = ""
        for a in 0..pos2-pos-1
            s2 += "~"
        end
        p "     ......#{s1}^#{s2}......"
        
        p "---- end of dump position ----"
        
    end    
	

  protected

    def Get()
        p "get"
    end
    
    def In(symbolSet, i)
        return symbolSet[i / NSETBITS] & (1 << (i % NSETBITS))
        
    end
    
    def Expect(n)
        p "expect #{n}(#{SYMS[n]}), sym = #{@sym}(#{SYMS[@sym]})('#{@scanner.GetSymValue(@scanner.nextSym)}'), line #{@scanner.nextSym.line} col #{@scanner.nextSym.col} pos #{@scanner.nextSym.pos} sym #{SYMS[@scanner.nextSym.sym]}"
        if @sym == n 
            Get()
        else 
            GenError(n)
        end
    end
    def prevline(pos, num=1, padding=0)
        ret = []
        # pos = @scanner.buffPos
        buffer = @scanner.buffer
        
     #   p "p1:#{pos}"
        while pos>0 && buffer[pos] && (buffer[pos].to_byte == 10 || buffer[pos].to_byte == 13)
            pos -= 1
        end
      #  p "p2:#{pos}"
        
        while  pos>0 && buffer[pos] && (buffer[pos].to_byte != 10 && buffer[pos].to_byte != 13)
            pos -= 1
        end
        
     #   p "p3:#{pos}"
        while (num>0)

            
            pos_end = pos
            while  pos>0 && buffer[pos] && (buffer[pos].to_byte == 10 || buffer[pos].to_byte == 13)
                pos -= 1
            end   
           # p "p4:#{pos}"
            
            while  pos>0 && buffer[pos] && (buffer[pos].to_byte != 10 && buffer[pos].to_byte != 13)
                pos -= 1
            end
         #   p "p5:#{pos}"
            
            if pos == 0
                pos_start = 0
            else
                pos_start = pos+1 
            end
            ret.insert(0,buffer[pos_start..pos_end]) if buffer[pos_start..pos_end]
            num -= 1
        end
        
        return ret
    end
    
    def get_lineno_by_pos(pos) # line number start from 0
        buf = @scanner.buffer[0..pos]
        return buf.count("\n")
    end

    
    def GenError(errorNo)
        p "generror #{errorNo}, line #{@scanner.nextSym.line} col #{@scanner.nextSym.col} sym #{@scanner.nextSym.sym} val #{@scanner.GetName()}"
        
        
        pos = @scanner.nextSym.pos
        
        dump_pos(pos)
        
        # # p "line:#{@scanner.cur_line()}"
        p("stack:", 1000)
        @error.StoreErr(errorNo, @scanner.nextSym.clone)
        raise "stopped because error #{errorNo}, file #{$g_cur_parse_file}"
    end
    # Scanner
    #    Error
    #    Sym

end