load 'log.rb'
def translate_varname(varname)
    return "" if varname==nil or varname == ""
    if varname.size ==1 
        varname = varname.downcase
    else
        varname = varname[0].downcase+varname[1..varname.size-1]
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
    attr_accessor :name, :ref
    def initialize(name)
        @name = name
        @ref = 0
    end
end
class Scope
    attr_accessor :name, :vars
    def initialize(name)
        @name = name
        @vars = {}
    end
    
    def add_var(v)
        @vars[v.name] = v
    end
    

end
class ClassDef < Scope
    attr_accessor :class_name, :parent, :modules, :methods, :src
    def initialize(class_name)
        super("class")
        @class_name = class_name
        @methods = {}
    end
    def add_src(src)
        @src = "" if !@src
        @src += src
    end
    def add_method(method_name, arg_number, src, acc="public")
        method_sig = "#{method_name}\#\##{arg_number}"
        if @methods[method_sig]
            @methods[method_sig][:name] = method_name
            if src && src.strip != ""
                @methods[method_sig][:src] =src
            end
            if @methods[method_sig][:decoration] == nil
                @methods[method_sig][:decoration] = ""
            end
            ar = acc.split(" ")
            ar.each{|v|
                if @methods[method_sig][:decoration].index(v) == nil
                    @methods[method_sig][:decoration] += " #{v}"
                end
            }
            
        else
            @methods[method_sig]={
                :name=>method_name,
                :src=>src,
                :decoration=>acc
            }
        end
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
        p "haha"
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
    def current_class_scope
         i = @sstack.size-1
         while (i>=0)
             if @sstack[i].name == "class"
                 return @sstack[i]
             end
             i -= 1
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


	

  protected

    def Get()
        p "get"
    end
    
    def In(symbolSet, i)
        return symbolSet[i / NSETBITS] & (1 << (i % NSETBITS))
        
    end
    
    def Expect(n)
        p "expect #{SYMS[n]}, sym = #{@sym}, line #{@scanner.nextSym.line} col #{@scanner.nextSym.col} pos #{@scanner.nextSym.pos} sym #{SYMS[@scanner.nextSym.sym]}"
        if @sym == n 
            Get()
        else 
            GenError(n)
        end
    end
    def prevline(pos, num=1)
        ret = ""
        # pos = @scanner.buffPos
        buffer = @scanner.buffer
        
        p "p1:#{pos}"
        while pos>0 && buffer[pos] && (buffer[pos].to_byte == 10 || buffer[pos].to_byte == 13)
            pos -= 1
        end
        p "p2:#{pos}"
        
        while  pos>0 && buffer[pos] && (buffer[pos].to_byte != 10 && buffer[pos].to_byte != 13)
            pos -= 1
        end
        
        p "p3:#{pos}"
        while (num>0)

            
            pos_end = pos
            while  pos>0 && buffer[pos] && (buffer[pos].to_byte == 10 || buffer[pos].to_byte == 13)
                pos -= 1
            end   
            p "p4:#{pos}"
            
            while  pos>0 && buffer[pos] && (buffer[pos].to_byte != 10 && buffer[pos].to_byte != 13)
                pos -= 1
            end
            p "p5:#{pos}"
            
            if pos == 0
                pos_start = 0
            else
                pos_start = pos+1 
            end
            ret = buffer[pos_start..pos_end]+ret if buffer[pos_start..pos_end]
            num -= 1
        end
        
        return ret
    end    
    def GenError(errorNo)
        p "generror #{errorNo}, line #{@scanner.nextSym.line} col #{@scanner.nextSym.col} sym #{@scanner.nextSym.sym} val #{@scanner.GetName()}"
        
        
        pos = @scanner.nextSym.pos
        
        p prevline(pos, 2)
        
        
        pos1 = pos
        while (pos1 > 0 && @scanner.buffer[pos1-1] != "\n" )
            pos1 -= 1
        end
        pos2 = pos 
        while (pos2 < @scanner.buffer.size-1 && @scanner.buffer[pos2+1] != "\n" )
            pos2 += 1
        end        
        p "......#{@scanner.buffer[pos1..pos2].gsub("\t",' ')}......"
        s1 = ""
        for a in 0..pos-pos1-1
            s1 += "~"
        end
        s2 = ""
        for a in 0..pos2-pos-1
            s2 += "~"
        end
        p "......#{s1}^#{s2}......"
        # # p "line:#{@scanner.cur_line()}"
        p("stack:", 1000)
        @error.StoreErr(errorNo, @scanner.nextSym.clone)
        raise "stopped because error"
    end
    # Scanner
    #    Error
    #    Sym

end