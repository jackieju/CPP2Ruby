load 'goto.rb'
load 'sym.rb'
load 'scanner.rb'
load 'cr_parser.rb'
load 'error.rb'
load 'log.rb'
load 'c_classdefs.rb'
load 'common.rb'

def pp(m, stack=0)

    m = format_msg(m, "", stack)
    # puts m
    begin
        put m
    rescue Exception=>e
         print "#{m}\n"
    end
end

def debug(s)
    p s
end

def pdebug(s, stack=0)
    depth = 0
    sp = ""
    begin
        raise Exception.new
    rescue Exception=>e
        e.backtrace.each{|b|
            if b =~ /in `C'/
                # p "====got botoom====total #{e.backtrace.size}"
                break
            else
                depth += 1
                sp += "-+"
            end
        }
        
    end
    
    m = "{#{sp}#{depth}}#{s}"
    if stack>0
        m = format_msg(m, "", stack)
    end
    
    debug(m)
    
end
=begin
$Sym = nil

def Get

end

def GenError(n)
    p "error #{n}"
end

def Expect(n)
  if (@sym == n) 
      Get()
      GenError(n)
  end
end
=end


# $g_classdefs = {}

def add_class(class_name, parent=nil, modules=nil)
    clsdef = ClassDef.new(class_name)
    $g_classdefs = {} if $g_classdefs == nil
    $g_classdefs[class_name] = clsdef
end

# when translate multiple file, will share one class tree
$g_classdefs = {} if $g_classdefs == nil
$g_root_moddef = ModuleDef.new("::")
$g_classdefs["::"] = $g_root_moddef

if $ar_classdefs
    $ar_classdefs.each{|cls|
        $g_root_moddef.add_class(cls)
    }
    p "===>$ar_classdefs:#{$ar_classdefs.inspect}"
end



def dump_one_as_ruby(v, module_name=nil)
    pp "dump ruby for #{v.class_name}@#{v}, #{module_name}", 20
   # pp "dump #{v.inspect}", 10
            s_methods =""
            v.methods.each{|k,v|
                p "#{k}, #{v[:decoration]}"
                # p "       methods signature:#{k}"
                # p "       methods name:#{v[:name]}"
                # p "       src:#{v[:src]}" 
                method_name = v[:name]
                # if method_name =~ /SetJournalDocumentNumber/
                #     p "--->src111:#{v[:src]}"
                # end
                if v[:decoration] =~ /static/
                    method_name = "self.#{v[:name]}"
                end
            
            
                if v[:src] && v[:src].strip != ""
                    method_template =<<HERE
                def #{method_name}#{v[:src]}
                
HERE
                else
                    next
                end
                s_methods += method_template

            }
            # p "==>methods:#{methods}"
            class_name = v.class_name
            includings = ""
            v.includings.each{|inc|
                includings += "include #{inc}\n"
            }
            if class_name == "::"
                    class_name ="_global_"
                    class_template = <<HERE
                    #{s_methods}
                    #{v.src}
HERE
            else
                if (module_name && module_name != "")
                    class_name = "#{module_name}::#{class_name}"
                end
                if v.class == ModuleDef
                    class_template =<<HERE
                module #{class_name}
                    #{includings}
                 #{s_methods}
                 #{v.src}
                end
HERE
                else
                    
                    if v.parent
                        class_template =<<HERE
                class #{class_name} < #{v.parent}
                    #{includings}
                #{s_methods}
                 #{v.src}
                end
HERE
                    else
                        class_template =<<HERE
                class #{class_name}
                    #{includings}
                 #{s_methods}
                 #{v.src}
                end
HERE
                    end
                end
            end
            
            wfname = ""
            wfname += "#{$output_dir}/" if $output_dir && $output_dir != ""
            
            #if module_name && module_name != ""
            #    p "module_name:#{module_name}"
            #    
            #    mds = module_name.split("::")
            #    p "mds:#{mds}"
            #    mpath = mds.join("/")
            #    wfname += "#{mpath}/"
            #end
           # wfname +=  "#{v.class_name.downcase}.rb"
           wfname +=  "#{class_name.gsub("::","/").downcase}.rb"
            #if $output_dir && $output_dir != ""
            #    wfname = "#{$output_dir}/#{class_name.downcase}.rb"
            #else
            #    wfname = "#{class_name.downcase}.rb"
            #end
            write_class(wfname, class_template)
end
#def dump_module_as_ruby(moduleDef, module_name=nil)
#    v =moduleDef
#    dump_classes_as_ruby(v.classes) if v.classes && v.classes.size > 0
#    dump_one_as_ruby(v, module_name)
#end
def dump_classes_as_ruby(classdefs, module_name=nil)
 #   p "dump222 #{classdefs.inspect}"
        classdefs.each{|k,v|
            p "class #{k}"
            p "       type: #{v.name} #{v.class}"
            p "       class name: #{v.class_name}"
#            p "       parent: #{v.parent}"
            p "       parentScope: #{v.parentScope}@#{v.parentScope}" if v.parentScope
            p "       modules: #{v.modules.keys}"
            p "       classes: #{v.classes.size}"
            p "       methods: #{v.methods.size}"
            p "       src: #{v.src}" if v.src
            m=""
            if v.is_a?(ModuleDef)
                p "--->333"
              # dump_module_as_ruby(v, module_name)
              
              if (module_name && module_name != "" && module_name != "::")
                  m = "#{module_name}::"
              else
                  m =""
              end
              
              m += v.class_name if v.class_name != "::"
              dump_classes_as_ruby(v.classes, m) if v.classes && v.classes.size > 0
              
              dump_classes_as_ruby(v.modules, m) if v.modules && v.modules.size > 0
              
            end
            dump_one_as_ruby(v, module_name)
            
        }
        
        
end

class Parser < CRParser
    attr_accessor :classdefs
    def curLine()
        @scanner.currLine
    end
    def curCol()
        @scanner.currCol
    end
    def curString() # current string means value of nextsym
        # ret = @scanner.GetName()
        ret = @scanner.GetSymValue(@scanner.nextSym)
        # p "------#{@scanner}"
        return ret
    end
    def prevString() # previous string means value of currsym
        # ret = @scanner.GetName()
        ret = @scanner.GetSymValue(@scanner.currSym)
        # p "------#{@scanner}"
        return ret
    end
    def nextString()
        ret = @scanner.GetNextName()
        p "------#{ret}"
        return ret
    end
    def getSymValue(sym)
        @scanner.GetSymString(sym)
    end
    def curSym()
        @scanner.nextSym
    end
    # def Parse()
    #     @scanner->Reset()
    #     Get()
    #     C()
    # end
    def pclass
        p "=====classdefs====="
          @classdefs.each{|k,v|
                                     p "classdef #{k}=#{v}"
            }
            p "=====classdefs end====="
            
    end
    def dump_buffer_to_file(fname)
        save_to_file(@scanner.buffer, fname)
    end
    def dump_classes_as_ruby
        Kernel.send(:dump_classes_as_ruby, @classdefs)
    end
    def dump_classes
        
        classdefs = @classdefs
        classdefs.each{|k,v|
            p "class #{k}:"
            p "       class name: #{v.class_name}"
            p "       parent: #{v.parent}"
            p "       modules: #{v.modules}"
            p "       methods:"
            v.methods.each{|k,v|
                p "       methods signature:#{k}"
                p "       methods decc:#{v[:decoration] }"
                
                p "       methods name:#{v[:name]}"
                p "       src:#{v[:src]}" 
            }      
        }
    end   
    #def find_class1(varname)
    #    p("@classdefs:#{@classdefs.inspect}")
    #    @classdefs.each{|k,v|
    #             p "find_class #{k}=#{v}"
    #    }
    #     if @classdefs[varname]
    #         return @classdefs[varname]
    #     end
    #     return nil
    #end
    
    def using_namespace_scope()
        return @using_namespace if @using_namespace
        c = @root_class
        ar = @using_namespace_str.split("::")
        for i in 0..ar.size-1
            r = c.modules[ar[i]]
            if !r
                p("namespace '#{ar[i]}' not found under #{c.class_name}")
                return nil 
            end
            c = r
        end
        @using_namespace = c
        return  @using_namespace
    end
    
    # find module from scope, if not found then find in parent scope
    def find_module_from(name, scope)
        ret = {
            :v=>nil,
            :prefix=>""
        }
        if scope == nil # find using namespace
            if @using_namespace
                ret[:v]= @using_namespace.modules[name]
                if ret[:v]
                    ret[:prefix]= @using_namespace_str
                end
            end
            return ret
        end
        if !scope.is_a?(ModuleDef) # skip class, functiondef
            return find_module_from(name, scope.parentScope)
        end
        ret[:v] = scope.modules[name]
        if ret[:v]
            return ret
        else
            return find_module_from(name, scope.parentScope)
        end
    end
    
    def find_class_from(name, sc)
         if sc
             #p("find_class_from:#{name}, #{sc.inspect}")
            # p sc.classes.inspect
         end
        ret = {
            :v=>nil,
            :prefix=>""
        }
        if !sc
            return ret if !@using_namespace
            ret[:v] = @using_namespace.classes[name]
            if ret[:v]
                ret[:prefix] = @using_namespace_str
            end 
            return ret
        end
        ret[:v] = sc.classes[name]
        return ret if ret[:v]
        return find_class_from(name, sc.parentScope)
    end
    def find_class(name)
        p "find_class:#{name}"
        ret = {
            :v=>nil,
            :prefix=>""
        }
      #  r = _find_class(name)
      #  return r if r
        
        ar = name.split("::")
        if ar.size == 1 # not "::", means only class no modules
             return find_class_from(name, current_ruby_scope)
        else
            na = ar[0]
            # find first module
            if na == "" # the case "::a"
                ret = {
                    :v=>@root_class,
                    :prefix=>""
                }
            else
                ret = find_module_from(na, current_ruby_scope) 
            end
            return ret if ret[:v] == nil
            sc = ret[:v]
            if ar.size >2 # more modules
                for i in 1..ar.size-2
                    sc = sc.modules[ar[i]]
                end
            end
            ret[:v] = sc.classes[ar[ar.size-1]]
            return ret
        end
        return ret
    end
=begin    
    def _find_class(name)
        ret = {
            :v=>nil,
            :prefix=>""
        }
        ar = name.split("::")
        ret = ""
        sc = current_ruby_scope
        for i in 0..ar.size-1
            na = ar[i]
            if i == ar.size-1 # class
                if sc.classes[na]
                    if ret && ret !=""
                        return "#{ret}::#{na}"
                    else
                        return na
                    end
                else 
                    return ret
                end
            elsif i == 0 # first module
                sc = find_module_from(na, sc)
                return nil if !sc
                ret += "#{sc.class_name}::" 
                
            else # module but not first
                sc = sc.modules[na]
                return nil if !sc
                ret += "#{sc.class_name}::" 
            end
        end
    end
=end    
    def find_function_from(name, sc)
        r = sc.methods[name]
        return if r
        return find_function_from(name, sc.parentScope)
    end
    def find_function(name)
        ret = {
            :v=>nil,
            :prefix=>""
        }
        ar = name.split(".")
        if ar.size > 1 # has function owner
            fn = ar[ar.size-1]
            ar_sc = ar[0].split("::")
            if ar_sc.size >1 # has module
                ret = find_module_from(ar_sc[0], current_scope)
                return ret if !ret[:v]
                sc = ret[:v]
                if ar_sc.size > 2 
                    for i in 1..ar_sc.size-2
                        sc = sc.modules[ar_sc[i]]
                    end
                end
                ret[:v] = sc.methods[fn]
                
            else # only class
                ret = find_class(ar_sc[0])
                cls = ret[:v]
                return ret if !cls
                ret[:v] = cls.methods[fn]
            end
        else # only function name
            ret[:v] = find_function_from(name, current_ruby_scope)
        end
        return ret
    end
    
    def add_class(class_name, parent=nil, modules=nil)
        
        clsdef = ClassDef.new(class_name)
        @classdefs[class_name] = clsdef
        return clsdef
    end
    def GetNextSym(step =1)
        _scanner = @scanner.clone()
      #  p "==>scanner clone =#{_scanner.inspect}"
        _sym = nil
        while step > 0
             begin 
                _sym = _scanner.Get()
              #  p "==>scanner clone2 =#{_scanner.inspect}"
            
                # if $sc_cur != $sc.currSym.sym
                #     pp("!!!===", 20)
                # end
                _scanner.nextSym.SetSym(_sym)
                if (_sym <= C_MAXT) 
                    # _error.errorDist +=1
            
                else 
                    if (_sym == C_PreProcessorSym) # /*86*/
                      # line 65 "cs.atg"
	    
                    else
                        #/* Empty Stmt */ ;
                        _scanner.nextSym = _scanner.currSym
                    end
                end
            
                # if $sc_cur != $sc.currSym.sym
                #     pp("!!!===", 20)
                # end
            
            end while (_sym > C_MAXT || ignoreSym?(_sym))
            step -= 1
        end
        return _scanner.nextSym
    end
    def GetNext(step =1)
        _scanner = @scanner.clone()
        # p "==>scanner clone =#{_scanner.inspect}"
        _sym = nil
        while step > 0
             begin 
                _sym = _scanner.Get()
            
                # if $sc_cur != $sc.currSym.sym
                #     pp("!!!===", 20)
                # end
            
                _scanner.nextSym.SetSym(_sym)
                if (_sym <= C_MAXT) 
                    # _error.errorDist +=1
            
                else 
                    if (_sym == C_PreProcessorSym) # /*86*/
                      # line 65 "cs.atg"
	    
                    else
                        #/* Empty Stmt */ ;
                        _scanner.nextSym = _scanner.currSym
                    end
                end
            
                # if $sc_cur != $sc.currSym.sym
                #     pp("!!!===", 20)
                # end
            
            end while (_sym > C_MAXT || ignoreSym?(_sym))
            step -= 1
        end
        return _sym
    end
    def GetNextSymFromSym(sym, step =1)
        _scanner = @scanner.clone()
        _scanner.currLine = sym.line
        _scanner.currCol = sym.col
        _scanner.buffPos = sym.pos+sym.len-1
        _scanner.Scan_NextCh
        # p "==>scanner clone =#{_scanner.inspect}"
        _sym = nil
        while step > 0
             begin 
                _sym = _scanner.Get()
            
                # if $sc_cur != $sc.currSym.sym
                #     pp("!!!===", 20)
                # end
            
                _scanner.nextSym.SetSym(_sym)
                p "==>8888:#{_sym}, #{_scanner.nextSym.sym}, #{getSymValue(_scanner.nextSym)}"
                if (_sym <= C_MAXT) 
                    # _error.errorDist +=1
            
                else 
                    if (_sym == C_PreProcessorSym) # /*86*/
                      # line 65 "cs.atg"
	    
                    else
                        #/* Empty Stmt */ ;
                        _scanner.nextSym = _scanner.currSym
                    end
                end
            
                # if $sc_cur != $sc.currSym.sym
                #     pp("!!!===", 20)
                # end
            
            end while (_sym > C_MAXT || ignoreSym?(_sym))
            step -= 1
        end
        return _scanner.nextSym
    end
    def GetNextFromSym(sym, step =1)
        _scanner = @scanner.clone()
        _scanner.currLine = sym.line
        _scanner.currCol = sym.col
        _scanner.buffPos = sym.pos+sym.len-1
        _scanner.Scan_NextCh
        
        # p "==>scanner clone =#{_scanner.inspect}"
        _sym = nil
        while step > 0
             begin 
                _sym = _scanner.Get()
            
                # if $sc_cur != $sc.currSym.sym
                #     pp("!!!===", 20)
                # end
            
                _scanner.nextSym.SetSym(_sym)
                if (_sym <= C_MAXT) 
                    # _error.errorDist +=1
            
                else 
                    if (_sym == C_PreProcessorSym) # /*86*/
                      # line 65 "cs.atg"
	    
                    else
                        #/* Empty Stmt */ ;
                        _scanner.nextSym = _scanner.currSym
                    end
                end
            
                # if $sc_cur != $sc.currSym.sym
                #     pp("!!!===", 20)
                # end
            
            end while (_sym > C_MAXT || ignoreSym?(_sym))
            step -= 1
        end
        return _sym
    end
    def include_file(finclude)
        $exclude_file.each{|f|
            f = f.downcase
            fi = finclude.downcase
            return false if f == fi
            if f.index("*")
                reg = Regexp.new(f)
                if (fi =~ reg) == 0
                    return false
                end
            end
    
        }
        # make sure include only once
        if (@included_files[finclude] == 1)
            @scanner.delete_curline
            return
        else
            if !@scanner.include_file(finclude)
                # GenError(114)
                pp "===>114",20
            else
                @included_files[finclude] = 1
            end
            # p "after include:pos #{@scanner.buffPos}, ch #{@scanner.cch}, sym #{@sym},#{@scanner.buffer}"
        end
    end
    def ignoreSym?(sym)
        ignored = [
            C_constSym
            ]
        if ignored.include?(sym)
            return true
        else
            return false
        end
    end
    def Get(ignore_crlf=true)        
        # p "sym1=#{@sym}"
         begin 
# p "Get0:@sym=#{@sym}, len=#{@scanner.nextSym.len}, nextSym=#{@scanner.nextSym.sym}, string=#{@scanner.GetSymString(@scanner.nextSym)}, pos=#{@scanner.buffPos}, @ch=#{@scanner.ch}"
            @prev_sym = @sym
            @sym = @scanner.Get(ignore_crlf)
 # p "Get1:@sym=#{@sym}, len=#{@scanner.nextSym.len}, nextSym=#{@scanner.nextSym.sym}, string=#{@scanner.GetSymString(@scanner.nextSym)}, pos=#{@scanner.buffPos}, @ch=#{@scanner.ch}"
            # p "Get(): sym = #{@sym}, line #{@scanner.nextSym.line} col #{@scanner.nextSym.col} pos #{@scanner.nextSym.pos} sym #{SYMS[@sym]}"
            # p "sym1=#{@sym}"
            # pp("hhhh", 30) if @sym==9
            @scanner.nextSym.SetSym(@sym)
            # p "==>#{@sym}, #{getSymValue(@scanner.nextSym)}"
            if (@sym <= C_MAXT) 
                @error.errorDist +=1
            
            else 
                if (@sym == C_PreProcessorSym) # /*86*/
                    if @in_preprocessing
                        break
                    end
                    @scanner.skip_curline
                    # p "ch #{@scanner.ch}"
                    # p "pos:#{@scanner.buffPos}, #{@scanner.ch}, #{@scanner.buffer[@scanner.buffPos]}, buffer:#{@scanner.buffer}"
=begin              
                 # line 65 "cs.atg"
                  _str1 = curString()
                  pp "preprocessor #{}", 20
                  @sym = @scanner.Get()
                  _str2 = curString()
                  directive = "#{_str1}#{_str2}"
                  p "directive=#{directive}"
                  if  directive == "\#include"
                      @sym = @scanner.Get()
                      finclude = curString()
                      if finclude[0]=="\"" || finclude[0] =="\'"
                            finclude = finclude[1..finclude.size-1]
                      end
                      if finclude[finclude.size-1]=="\"" || finclude[finclude.size-1] =="\'"
                            finclude = finclude[0..finclude.size-2]
                      end
                      p "include file #{finclude}"
                      include_file(finclude)
                         
                  end
                  
                  # skip current line
                  @scanner.NextLine
=end                  
                  
                  
                  
                  
                   # p "preprocessor2 #{curString()}"
=begin
                  	char str[256];
                  	str = @scanner.GetName(@scanner.nextSym)
              	
                  	p = strchr(str, ' ')
        
                  	if ( p != NULL )
                  	    *p=0; 
                  	    directive = str + sizeof(char)
                  	    #// proce include 
                  	    if (strcmp(str, "include") == 0){
                  	            // get content
                  	            p += sizeof(char)
                  	            while ( (*p == ' ' || *p == '\t' ) && *p != '\0' ){
                  	                    p += sizeof(char)              
                  	            }
                  	            if ( *p != '\0' )
                  	                    content = p;
                  	    end

                  	end
=end
              	    
                else
                    #/* Empty Stmt */ ;
                    @scanner.nextSym = @scanner.currSym
                end
            end
        end while (@sym > C_MAXT || (self.class.to_s!= "Preprocessor" &&ignoreSym?(@sym) ) )
        # p "get()2: #{@sym}"
        # p "Get()2 #{@scanner.nextSym.sym}, line #{@scanner.nextSym.line}, col #{@scanner.nextSym.col}, value #{curString()}"
        # p("Get()3:#{@sym}, #{curString()}, line #{curLine}", 20)
        return @scanner.nextSym.sym
    end
    
    def add_macro(n,v)
        ret = ""
        v = v.strip
        if v =~ /^(\d+)\w?$/                        # number literal
            n1 = n[0].upcase+n[1..n.size-1]        
            ret = "dummy_type #{n1} = #{$1};"
            @macros[n] = $1
        elsif v =~ /^\"(.*?)\"$/ || v =~ /^\'(.)\'$/ # string literal
             n1 = n[0].upcase+n[1..n.size-1]
             ret = "dummy_type #{n1} = #{v};"
             @macros[n] = $1
        else
            @macros[n] = v
        end
        return ret
    end

    def is_number?(s)
        s =~ /^\d+\w?$/
    end
    def delete_curline
        pos = @scanner.buffPos
        
        @scanner.delete_curline
       #  Get() if pos != @scanner.buffPos
       #  p "get:#{@sym}"
    end
    def delete_prevline
        # pos = @scanner.buffPos
        p "==>sym2220:#{@sym}, #{curString()}, #{@scanner.buffPos}"
        
        @scanner.delete_prevline
        if @scanner.buffPos <= 0
            @scanner.Reset
            # Get()
        end
        #Get()
        # Get() if pos != @scanner.buffPos
        p "==>sym2221:#{@sym}, #{curString()}, #{@scanner.buffPos}"
    end
    def delete_lines(p1,p2,inclue = true)
        pos = @scanner.buffPos
        p("---->dddd:#{pos}, #{p1}, #{p2}")
        pos1,pos2 = @scanner.delete_lines(p1, p2, inclue)
        #p "after delete_lines:#{pos1}, #{pos2}, pos #{pos}, buffer:#{@scanner.buffer}", 10
        # Get() if pos != @scanner.buffPos
        p "after delete_lines:#{@scanner.buffer[@scanner.buffPos..@scanner.buffPos+20]}"
        p("---->dddd:#{pos}, #{pos1}, #{pos2}")
        
      #  Get() if pos >pos1 && pos <= pos2
    #    Get() if pos >=pos1 && pos <= pos2
        p "after delete_lines2:#{@scanner.buffer[@scanner.buffPos..@scanner.buffPos+50]}"
        
    end
 


    def skip_curline
        ret = @scanner.skip_curline
#        Get()
        
        return ret
    end

=begin    
    def _preprocess(stop_on_unkown_directive = true)
        while (@sym!=C_EOF_Sym)
            
             # p "sym2:#{@sym}, #{curString()}"
            if @sym == C_PreProcessorSym
                @directive = preprocess_directive()
                return @directive if stop_on_unkown_directive && @directive
            end
            # if @sym == C_identifierSym
            #     cs = curString()
            #     if ifdefined?(cs)
            #         @macros[n]
            #     end
            # end
            Get()
        end
    end
    def Preprocess()
        @in_preprocessing = true
        Get()
        _preprocess(false)
        @in_preprocessing = false
        # p "after preprocess: #{@scanner.buffer}"
        return @scanner.buffer
    end
=end
    # line 98 "cs.atg"
    def C()
        pclass()
    	in_scope(@root_class)
        p "root:#{@root_class.inspect}"
    	
        ret = ""
        p "==>C:#{SYMS[@sym]}"
    # line 98 "cs.atg"
    
 
    # line 135 "cs.atg"
    #   if (Sym == packageSym) {
    # # line 135 "cs.atg"
    #       Package();
    #   }
    # line 135 "cs.atg"
    #   while (Sym == useSym ||
    #          Sym == loadSym) {
    # # line 135 "cs.atg"
    #       if (Sym == useSym) {
    # # line 135 "cs.atg"
    #           Import();
    #       } elsif (Sym == loadSym) {
    # # line 135 "cs.atg"
    #           LoadLib();
    #       } else GenError(87);
    #   }
    # # line 135 "cs.atg"
    #   if (Sym >= inheritSym && Sym <= LessSym) {
    # # line 135 "cs.atg"
    #       Inheritance();
    #   }
    # line 137 "cs.atg"
    	while (@sym >= C_identifierSym && @sym <= C_hexnumberSym ||
    	       @sym >= C_stringD1Sym && @sym <= C_charD1Sym ||
    	       @sym == C_SemicolonSym ||
    	       @sym >= C_classSym && @sym <= C_LbraceSym ||
    	       @sym >= C_staticSym && @sym <= C_voidSym ||
    	       @sym == C_LparenSym ||
    	       @sym >= C_StarSym && @sym <= C_caseSym ||
    	       @sym >= C_defaultSym && @sym <= C_ifSym ||
    	       @sym >= C_returnSym && @sym <= C_switchSym ||
    	       @sym == C_AndSym ||
    	       @sym >= C_PlusSym && @sym <= C_MinusSym ||
    	       @sym >= C_PlusPlusSym && @sym <= C_MinusMinusSym ||
    	       @sym >= C_newSym && @sym <= C_DollarSym ||
    	       @sym >= C_BangSym && @sym <= C_TildeSym ||
    	       @sym == C_EnumSym || 
    	       @sym == C_TypedefSym || 
    	       @sym == C_StructSym ||
               @sym == C_deleteSym || @sym == C_throwSym || @sym == C_sizeofSym  || @sym == C_namespaceSym || @sym== C_usingSym ||
               @sym == C_operatorSym || @sym == C_ColonColonSym
               ) 
    # line 137 "cs.atg"
    		ret += Definition()
    	end
    # line 137 "cs.atg"
    	Expect(C_EOF_Sym)
    # line 137 "cs.atg"
        
        out_scope()
       
        @root_class.add_src(ret)
        
    	return ret
    end
    
    # line 246 "cs.atg"
    def Inheritance(clsdef)
        # TODO
        pdebug("===>Inheritance:#{@sym}, #{curString()}");
    
    # # line 246 "cs.atg"
    #   if (@sym == C_inheritSym) 
    # # line 246 "cs.atg"
    #       Get()
    #   elsif (@sym == C_LessSym) 
    # # line 246 "cs.atg"
    #       Get()
    #   else 
    #       GenError(88)
    #     end
    # line 246 "cs.atg"
        Get()
        decorators = ["public", "protected", "privrate"]
        if (@sym == C_identifierSym && decorators.include?(curString()) )
            Get()  # Expect(C_identifierSym) # public/private
        end
        parent_class_name = ClassFullName()
    	#Expect(C_identifierSym) # parent class name
    	#parent_class_name = prevString()
    	p "parent class name = #{parent_class_name}"
    	clsdef.parent = parent_class_name
    	#if @sym == C_LessSym
        #        filterTemplate()
        #end
    # line 247 "cs.atg"
        
    # multi inheritance
    # for ruby doesn't have MI, we create module for other parent from the 2nd one
        while (@sym==C_CommaSym)
            Get()
            if (@sym == C_identifierSym && decorators.include?(curString()) )
                Get()  # Expect(C_identifierSym) # public/private
            end
            #Expect(C_identifierSym)
        	#parent_class_name = prevString()
            parent_class_name = ClassFullName()
            r = find_class(parent_class_name)
            #newmodule = ModuleDef.new(parent_class_name)
            #pmodule = @root_class
            #if r[:prefix]
            #    parent_class_name = r[:prefix]+"::"+parent_class_name 
            #    rr = find_module_from(r[:prefix], current_scope)
            #    if rr[:v]
            #        pmodule = rr[:v]
            #    end
            #end
            #pmodule.add_module(newmodule)
            clsdef.includings.push(parent_class_name)
            if r[:v]
                newmodule = r[:v].to_module() 
                r[:v].parentScope.add_module(newmodule)
            end
        end


    # line 264 "cs.atg"
        # Expect(C_SemicolonSym)
    end
    
    def NamespaceDef
        p("====>NamespaceDef0", 10)
        pdebug("===>NamespaceDef:#{@sym}, #{curString()}")
        	Expect(C_namespaceSym)
        
     
        	_class_name = curString()
        	Expect(C_identifierSym)
        clsdef = ModuleDef.new(_class_name)
            

        	if (@sym == C_LbraceSym)
        	   ClassBody(clsdef)
            
    	    else
    	        p "--->NamespaceDef33, #{@sym}, #{curString()}"
                Expect(C_SemicolonSym)
                p "--->cNamespaceDef34, #{@sym}, #{curString()}"
    	        
    	    end
    	   
    	  #  @classdefs[_class_name] = clsdef
          p "add module #{clsdef.class_name} to #{current_scope.inspect}"
          current_ruby_scope.add_module(clsdef)
          
          p("====>NamespaceDef1")
     
    end
    
    def ClassDef
        p("ClassDef0", 10)
        pdebug("===>ClassDef:#{@sym}, #{curString()}")
        # line 267 "cs.atg"
        	Expect(C_classSym)
        # line 267 "cs.atg"
        
        # filter out declaration between 'class' and class name
            p("ClassDef0:#{@sym}, #{curString()}")

            filterSymBefore([C_ColonSym, C_LbraceSym, C_LessSym, C_SemicolonSym], 1)
          #  Get()
            p("after filterSymBefore: #{@sym}, #{curString()}")
        	_class_name = curString()
        	Expect(C_identifierSym)
        	clsdef = ClassDef.new(_class_name)
            
            if @sym == C_LessSym
                filterTemplate()
            end
            # class_name = _class_name[0].upcase + _class_name[1.._class_name.size-1]
        # line 268 "cs.atg"

        # line 295 "cs.atg"
        	while (@sym == C_ColonSym) 
        # line 295 "cs.atg"
        		Inheritance(clsdef)
        	end
        # line 296 "cs.atg"
        	
        # has to add class before class body, in case class with same name already added in c_classdefs.rb
        #p "currentrubyscope:#{current_ruby_scope.inspect}"
        current_ruby_scope.add_class(clsdef)
        p "add class:#{clsdef.class_name}"
            
            if (@sym == C_LbraceSym)
        	    ClassBody(clsdef)
    	    else
    	        p "--->classdef33, #{@sym}, #{curString()}"
    	        # line 296 "cs.atg"
                Expect(C_SemicolonSym)
                p "--->classdef34, #{@sym}, #{curString()}"
    	        
    	    end
    	    
    	    #@classdefs[_class_name] = clsdef
            # @classdefs.each{|k,v|
            #               p "classdef #{k}=#{v}"
            #           }

    end
    
    def FriendClass()
        ClassDef
           #  Expect(C_classSym)
           #     Expect(C_identifierSym)
           #     Expect(C_SemicolonSym)
    end
    # line 297 "cs.atg"
    def ClassBody(clsdef) #not onlye used in class, also used in namespace
       
        in_scope(clsdef)
        pdebug("===>ClassBody:#{@sym}, #{curString()}");
        ret = ""
    # line 298 "cs.atg"

    # line 322 "cs.atg"
    	Expect(C_LbraceSym)
    	$class_current_mode = "public"
    # line 322 "cs.atg"
    	while (@sym >= C_identifierSym && @sym <= C_hexnumberSym ||
    	       @sym >= C_stringD1Sym && @sym <= C_charD1Sym ||
    	       @sym == C_SemicolonSym ||
    	       @sym >= C_classSym && @sym <= C_LbraceSym ||
    	       @sym >= C_staticSym && @sym <= C_voidSym ||
    	       @sym == C_LparenSym ||
    	       @sym >= C_StarSym && @sym <= C_caseSym ||
    	       @sym >= C_defaultSym && @sym <= C_ifSym ||
    	       @sym >= C_returnSym && @sym <= C_switchSym ||
    	       @sym == C_AndSym ||
    	       @sym >= C_PlusSym && @sym <= C_MinusSym ||
    	       @sym >= C_PlusPlusSym && @sym <= C_MinusMinusSym ||
    	       @sym >= C_newSym && @sym <= C_DollarSym ||
    	       @sym >= C_BangSym && @sym <= C_TildeSym ||
               @sym == C_deleteSym || @sym == C_throwSym || @sym == C_sizeofSym || @sym == C_TypedefSym || @sym==C_EnumSym || @sym==C_namespaceSym || @sym == C_StructSym || @sym == C_usingSym) 
    # line 322 "cs.atg"
                cs = curString()
                p "cs:#{cs}"
                # if (cs == "friend") #ignore
                #                    Get()
                #                    FriendClass()
                #                    next
                #                end
                # if cs == "public" || cs == "private" || cs == "protected"
                #           Get()
                #           Expect(C_ColonSym)
                #           if cs == "private" 
                #               $class_current_mode = "private"
                #           else
                #               $class_current_mode = "public"
                #           end
                #           next
                #       end 
    		ret += Definition()
		
    	end
    # line 322 "cs.atg"
    	Expect(C_RbraceSym)
    # line 324 "cs.atg"
   # p "#{current_scope().inspect}"
   # p @sstack.inspect
        current_scope.add_src(ret)

    	 out_scope()
    end
    
    # def EnumClass()
    #     Get()
    #     name = curString()
    #     Get()
    #     Expect(C_LbraceSym)
    #     base = 0
    #     while @sym == C_identifierSym
    #         a = curString()
    #         # to constant
    #         a = a[0].upcase+a[1..a.size-1]
    #
    #         Get()
    #         if (@sym == C_EqualSym)
    #             Get()
    #             v = curString()
    #             Expect(C_numberSym)
    #             p "v=#{v}, sym:#{@sym}"
    #             if v =~ /^([\d.]+)\w*$/
    #                 v = $1
    #                 end
    #             base = v.to_i
    #             # Get()
    #             end
    #             ret += "#{a} = #{base}\n"
    #             p "#{a} = #{base}\n"
    #             p "sym:#{@sym}"
    #             if @sym == C_CommaSym
    #                 Get()
    #                 base += 1
    #         end
    #         p "==>enum22:#{@sym}, #{SYMS[@sym]}, #{curString}", 10
    #
    #     end
    #
    #     Expect(C_RbraceSym)
    #     pdebug("===>Enum1:#{@sym}, #{ret}")
    #     return ret
    # end
    def Enum()
        ret = ""
        pdebug("===>Enum:#{@sym}, #{curString()}");
    	Get()
        isClass = false
        if @sym == C_classSym
            isClass = true
            Get()
            module_name = curString()
            module_name = module_name[0].upcase+module_name[1..module_name.size-1]
           
            Get()
        
        elsif @sym == C_identifierSym # enum type name before {}
    	    Get()
	    end
        
        if @sym == C_ColonSym # enum class F : char{}
            Get()
            Get()
        end
        
        if @sym == C_SemicolonSym # just "enum A;"
            
        else
            Expect(C_LbraceSym)
        	base = 0
            list = ""
        	while @sym == C_identifierSym
        	    a = curString()
        	    # to constant
        	    a = a[0].upcase+a[1..a.size-1]
    	    
        	    Get()
        	    if (@sym == C_EqualSym)
        	        Get()
                    v = Expression()
        	       # v = curString()
        	        #Expect(C_numberSym)
        	        p "v=#{v}, sym:#{@sym}"
        	        if v =~ /^((-|\+)[\d.]+)\w*$/
        	            v = $1
    	            end
        	        base = v.to_i
                    # Get()
    	        end
    	        list += "#{a} = #{base}\n"
    	        p "#{a} = #{base}\n"
    	        p "sym:#{@sym}"
    	        if @sym == C_CommaSym
    	            Get()
    	            base += 1
                end
                p "==>enum22:#{@sym}, #{SYMS[@sym]}, #{curString}", 10
            
    	    end
    	
        	Expect(C_RbraceSym)
            if isClass
                 ret += "module #{module_name}{\n#{list}\n}"
            else
                 ret += list
            end
         end # if @sym == C_SemicolonSym; else
    	pdebug("===>Enum1:#{@sym}, #{ret}")
    	return ret
    end

    def Union()
        pdebug("===>Union:#{@sym}, #{curString()}");
        	Expect(C_unionSym)
        
        if @sym == C_identifierSym
        	_class_name = curString()
        	clsdef = ClassDef.new(_class_name)
            Get()
        else
            clsdef = ClassDef.new("__union_dummy_name__")
        end
  
        if @sym == C_finalSym
            Get()
        end
  

        	if (@sym == C_LbraceSym)
        	    ClassBody(clsdef)
    	    else
                Expect(C_SemicolonSym)
     
    	        
    	    end

           return 
    end
    def StructDef()
        pdebug("===>StructDef:#{@sym}, #{curString()}");
        	Expect(C_StructSym)
        # line 267 "cs.atg"
        
        if @sym == C_identifierSym
        	_class_name = curString()
        	clsdef = ClassDef.new(_class_name)
            Get()
        else
            clsdef = ClassDef.new("__struct_dummy_name__")
        end
            # class_name = _class_name[0].upcase + _class_name[1.._class_name.size-1]
        # line 268 "cs.atg"
        if @sym == C_finalSym
            Get()
        end
        # line 295 "cs.atg"
        	while (@sym == C_ColonSym) 
        # line 295 "cs.atg"
        		Inheritance(clsdef)
        	end
        # line 296 "cs.atg"
        	if (@sym == C_LbraceSym)
        	    ClassBody(clsdef)
    	    else
    	        p "--->classdef33, #{@sym}, #{curString()}"
    	        # line 296 "cs.atg"
                Expect(C_SemicolonSym)
                p "--->classdef34, #{@sym}, #{curString()}"
    	        
    	    end
    	    
    	   # @classdefs[_class_name] = clsdef
           current_ruby_scope.add_class(clsdef) if clsdef.class_name != "__struct_dummy_name__"
           return clsdef
    end
    # line 218 "cs.atg"
    def Definition()
        ret = ""
    # line 218 "cs.atg"
    	pdebug("===>Definition:#{@sym}, #{curString()}");
        name = curString()
    # line 219 "cs.atg"
    	if (@sym == C_classSym) 
    # line 219 "cs.atg"
    		ClassDef()
            # p "--->classDef11, #{@sym}, #{curString()}"
        elsif @sym == C_namespaceSym
            NamespaceDef()
        elsif (@sym == C_EnumSym)
    	    ret += Enum()
    	elsif (@sym == C_StructSym)
    	    StructDef()
            
        elsif @sym == C_usingSym
           Get()
           Get() if @sym ==  C_namespaceSym
           
           ns = ClassFullName()
           p "using1 namespace #{ns}"
           @using_namespace_str = ns
           using_namespace_scope()
           Expect(C_SemicolonSym)
           ret += "\n"
	    # elsif
	    #          [ StorageClass ] Type { "*" } identifier
	    #                                    ( FunctionDefinition | VarList ";" ) 
	    #                                    | Inheritance .
    	elsif (@sym >= C_EOF_Sym && @sym <= C_hexnumberSym ||
    	           @sym >= C_stringD1Sym && @sym <= C_charD1Sym ||
    	           @sym == C_SemicolonSym ||
    	           @sym >= C_LbraceSym && @sym <= C_voidSym ||
    	           @sym == C_LparenSym ||
    	           @sym >= C_StarSym && @sym <= C_caseSym ||
    	           @sym >= C_defaultSym && @sym <= C_ifSym ||
    	           @sym >= C_returnSym && @sym <= C_switchSym ||
    	           @sym == C_AndSym ||
    	           @sym >= C_PlusSym && @sym <= C_MinusSym ||
    	           @sym >= C_PlusPlusSym && @sym <= C_MinusMinusSym ||
    	           @sym >= C_newSym && @sym <= C_DollarSym ||
    	           @sym >= C_BangSym && @sym <= C_TildeSym ||
    	           @sym == C_TypedefSym || @sym == C_deleteSym || @sym == C_throwSym ||
                   @sym == C_sizeofSym || @sym == C_operatorSym || @sym == C_ColonColonSym
                   ) 
    # line 219 "cs.atg"
    		ret += Statements()
    	else 
    	    GenError(89)
	    end
	    return ret
    end
    
    def initialize(scanner, error, classdefs={})
        
        # @scanner = scanner
        #         @error = MyError.new("whaterver", scanner)
        super(scanner, error)
        @included_files = {}
        @macros = {}
        # @classdefs=$g_classdefs if $g_classdefs
        @classdefs = $g_classdefs
        
        #moddef = ModuleDef.new("::")
        #$g_classdefs = {} if $g_classdefs == nil
        #$g_classdefs["::"] = moddef
        #@root_class = moddef
        @root_class = $g_root_moddef
       # @root_class = add_class("::")

        
        #p("classdefs:#{@classdefs.inspect}")
        p "init end"
        pclass
    end
    
    # line 561 "cs.atg"
    def FunctionBody()
        # in_scope("FunctionBody"))
    # line 561 "cs.atg"
    	ret = CompoundStatement()
    # line 562 "cs.atg"
        # out_scope()
	    return ret
    end
    # line 709 "cs.atg"
    def CompoundStatement()
        pdebug("===>CompoundStatement:#{@sym}, line #{curLine()}, col #{curCol()}")
    # line 709 "cs.atg"
    	Expect(C_LbraceSym)
    # line 709 "cs.atg"
    	ret = Statements()
    # line 709 "cs.atg"
    	Expect(C_RbraceSym)
    	pdebug("===>CompoundStatement1:#{@sym}, line #{curLine()}, col #{curCol()}")
        
    	return ret
    end
    
    # general statement, can be local definition or statement
    def gStatement()
        
        p("gStatement0", 10)
        pdebug("-->gStatement, line #{@scanner.currLine}, sym=#{@sym}, val=#{curString()}")
        rStatement = ""
        if @sym == C_SemicolonSym
            Get()
           return "" 
        elsif @sym == C_TildeSym  # deconstructor
            if ['class', 'struct', 'module'].include?(current_scope.name)
                Get()
                Expect(C_identifierSym)
                FunctionDefinition(current_scope.class_name, "uninitialize")
	        end
        elsif @sym == C_ColonColonSym
            p("--->3333121")
            rStatement += LocalDeclaration()
		elsif @sym == C_identifierSym 
		     # p "|||||||||||||@sym = #{@sym}, #{@scanner.currSym.inspect}, #{curString()}, @scanner=#{@scanner}"
        	    #                 $sc_cur = $sc.currSym.sym
                _next = GetNext()
        	    #                 if $sc_cur != $sc.currSym.sym
        	    #                     pp("!!!===", 20)
        	    #                 end
                p "GetNext=#{_next}"
        	    #                 p "|||||||||||||@sym = #{@sym}, #{@scanner.currSym.inspect}, #{curString()}, @scanner=#{@scanner}"
        	    #                 
        	    
        	    # TODO, theoritcally, user can write "a *b;", which is ambiguious (see where a is type)
        	    p "current scope:#{current_scope.name}"
        	    cs = curString()
        	    if current_scope.name == "class"
        	        p "class name #{current_scope.class_name}, curString1()=#{cs}"
    	        end
                if _next == C_ColonColonSym
                    #    A::~A
                    #_nn--->^
    	            _nn = GetNextSym(2) 
    	            _c_nn = getSymValue(_nn) 
    	            if _nn.sym == C_TildeSym # id::~
                        # LocalDeclaration() # deconstructor
                        class_name = curString()
                        Expect(C_identifierSym)
                        Expect(C_ColonColonSym)
                        Expect(C_TildeSym)
                        Expect(C_identifierSym)
                        
                        FunctionDefinition(class_name, "uninitialize")
                        
    	            elsif _nn.sym == C_identifierSym && _c_nn == cs # constructor # id::id
    	            #    A::A
                    #_nn--->^
                        # LocalDeclaration() 
                        class_name = curString()
                        Expect(C_identifierSym)
                        Expect(C_ColonColonSym)
                        Expect(C_identifierSym)
                        FunctionDefinition(class_name, "initialize")
                    elsif _nn.sym == C_operatorSym
                        rStatement += Statement()
	                else
	                    count = 3 # in c++, only A::B::C, A is namespace, B is class, so at most 3
	                    _nnn = GetNext(count)
	                    while ( _nnn== C_ColonColonSym)
	                        count +=1
	                        GetNext(count)
	                        count +=1
	                        _nnn = GetNext(count)
                        end
                        # id::id2::id3...
                        if _nnn == C_LessSym || # using template,e.g. A::B::C<D,F> t;
                            _nnn == C_identifierSym # A::B::C t;
                            p("using template2, sym=#{@sym}, curString=#{curString()}")
                            rStatement += LocalDeclaration()
                        elsif _nnn == C_PointSym || # functioncall A::B::C.method();
                             _nnn == C_LparenSym # functioncall A::B::C();
	                        rStatement += Statement() 
                        else
                    	    p "gStatement11:#{@sym}, #{curString()}"
                            
                            rStatement += LocalDeclaration()
                        end
    	            end 
    	            
    	         elsif cs == "virtual" && ['class', 'struct', 'module'].include?(current_scope.name)
    	            Get()
	                if curString() == "~"
	                    Get()
	                    Expect(C_identifierSym)
    	                FunctionDefinition(current_scope.class_name, "uninitialize") #skip it
	                else
	                    fn_name = ""
	                    while GetNext() != C_LparenSym
	                        Get()
                        end
                        fn_name = curString()
                        Get()
                        p "virtual function, #{fn_name}"
     	                FunctionDefinition(current_scope.class_name, fn_name) # skip it ???
    
                    end
 
    	        elsif _next == C_LparenSym  && ['class', 'struct'].include?(current_scope.name)# for constructor in class or struct, should not include module
    	            p "--> in class scope"
    	            if current_scope.class_name == cs # constructor
    	                Get()
                        FunctionDefinition(current_scope.class_name, "initialize")
	                elsif cs=="~" # deconstructor
                        Get()
                        Expect(C_identifierSym)
	                    FunctionDefinition(current_scope.class_name, "uninitialize") 
                    else # maybe functioncall
                        rStatement += Statement()
                                               
                    end
    	        elsif _next == C_LessSym # 
    	             p("before using template3:sym=#{@sym}, curString=#{curString()}")
                    if cs == "template" # define tempalte function or template class
                        # e.g. template <bool isDisassembly, bool isComponent> bool CWorkOrderATPSelectStrategy<isDisassembly, isComponent>::QtyOnOrdered (){}
                        Get()
                        #Expect(C_LessSym)
                        #FormalParamList()
                        filterTemplate()
                       # p("gStatement15:sym=#{@sym},curString=#{curString()}")
                        
                      #  Expect(C_GreaterSym)
                        p("gStatement16:sym=#{@sym},curString=#{curString()}")
                     #   Get()
                        p("gStatement17:sym=#{@sym},curString=#{curString()}")
                    
                        if (@sym == C_classSym) 
                            ClassDef()
                        else
                            rStatement +=   LocalDeclaration() 
                        end
                    else # using template, e.g. map<SBOString, False> currencyRoundingMap; parse from "map"
                        # or map<SBOString, False>().a()
    	               ## LocalDeclaration() # just pass it
                       #Get() 
                       #Expect(C_LessSym)
                       #FormalParamList()
                       #Expect(C_GreaterSym)
                       #if @sym == C_LparenSym   # map<SBOString, False>() 
                       #   rStatement += cs+FunctionCall()
                       #end
                       
                       if isTemplatedFnCall(1)
                            rStatement += Statement()
                       else
                            rStatement += LocalDeclaration()
                       end
                    end
                        p("after lol:#{@sym}")
        	    elsif  _next == C_identifierSym || _next == C_AndSym || _next == C_StarSym ||
        	        _next == C_TypedefSym || _next == C_staticSym  || _next == C_operatorSym #||
                    # _next == C_ColonColonSym # TODO this will unsupport A::B::C.callmethod()
        	        rStatement += LocalDeclaration()
                else #maybe functioncall
                    rStatement += Statement()
                    # p "statement return #{rStatement}"
                end
        elsif (@sym >= C_staticSym && @sym <= C_voidSym || @sym == C_TypedefSym || @sym == C_operatorSym)
        # line 711 "cs.atg"
        		rStatement += LocalDeclaration()
        else
                throw "error in gstatement"
       end
       pdebug("-->gStatement1, line #{@scanner.currLine}, sym=#{@sym}, val=#{curString()}")
       
        return rStatement
    end
    
    # ignore sym until meet one of stopper, after skip number of sym before the stopper
    def filterSymBefore(stopper, skip=0) 
        @curSym = curSym
        ar = [@curSym]
 
        count = 1 
        
        while (true)
            _s = GetNextSym(count)
           
            p("#{count}th=#{_s.sym},#{getSymValue(_s)}")
            if stopper == C_EOF_Sym || stopper.include?(_s.sym)
                ar.push(_s)
                __s = ar[ar.size() - 1 - skip]
                p("ar:#{ar.inspect}")
                p("will delete from sym #{curSym().sym}, #{curString()} to #{__s.sym},#{getSymValue(__s)}")
                @scanner.delete_in_line(curSym().pos, __s.pos)
                Get()
                return true
                
            end
            count +=1
            ar.push(_s)
        end
        return false
  
    end
    def filterTemplate(offset=0) # ignore <int, bool....>, offset is offset of < from current sym
        l_count = 0 # for ingore embbed <>
        p("filterTemplate0:offset=#{offset}, #{@sym},#{curString()}", 10)
        count = offset 
        while (true)
            _s = GetNextSym(count)
            p("#{count}th=#{_s.sym}, #{getSymValue(_s)}")
            if  _s.sym == C_SemicolonSym || _s.sym == C_AndAndSym ||  _s.sym == C_BarBarSym 
                return
            end
            if _s.sym == C_GreaterSym
                l_count -=1
                if (l_count == 0)
                    break
                end
            elsif _s.sym == C_GreaterGreaterSym
                l_count -=2
                if (l_count == 0)
                    break
                end
            elsif _s.sym == C_LessSym
                l_count +=1
            end
            count +=1
        end
        _s = GetNextSym(count+1) 
        p("filterTemplate1:#{_s.sym}, #{getSymValue(_s)}")
        @scanner.delete_in_line(GetNextSym(offset).pos, _s.pos)
        if(offset == 0)
            Get()
        end
        return _s
    end
    def isTemplatedFnCall(offset)# pass <int, bool....>
        _s =  filterTemplate(offset)
        
        
        if _s.sym == C_LparenSym
          
            return true
        else
            
            return false
        end
    end
    # line 711 "cs.atg"
    def Statements()
        
     #   p "-->Statements1", 10
         ret = ""
        csf = current_scope("FunctionDefinition")
        
        p "===>Statements0:#{csf}", 20
    # line 711 "cs.atg"
    	while (@sym >= C_identifierSym && @sym <= C_hexnumberSym ||
    	       @sym >= C_stringD1Sym && @sym <= C_charD1Sym ||
    	       @sym == C_SemicolonSym ||
    	       @sym == C_LbraceSym ||
    	       @sym >= C_staticSym && @sym <= C_voidSym ||
    	       @sym == C_LparenSym ||
    	       @sym >= C_StarSym && @sym <= C_caseSym ||
    	       @sym >= C_defaultSym && @sym <= C_ifSym ||
    	       @sym >= C_returnSym && @sym <= C_switchSym ||
    	       @sym == C_AndSym ||
    	       @sym >= C_PlusSym && @sym <= C_MinusSym ||
    	       @sym >= C_PlusPlusSym && @sym <= C_MinusMinusSym ||
               # @sym >= C_newSym && @sym <= C_DollarSym ||
               @sym == C_newSym || @sym == C_deleteSym || @sym == C_throwSym || @sym == C_sizeofSym ||
    	       @sym >= C_BangSym && @sym <= C_TildeSym ||  @sym == C_operatorSym || @sym == C_gotoSym || @sym == C_ColonColonSym ||
    	       @sym == C_TypedefSym)  do
    # line 711 "cs.atg"
                #             if (@sym == C_identifierSym)
                #                 @prev_sym = @sym
                #               prev_name = curString()
                # p "nextString = #{nextString()}"
                #            
                #                 Get()
                # if @sym == C_LparenSym
                #     rStatement += "#{prev_name}#{FunctionCall()}"
                #               else
                #                   p "enter ld"
                #     rStatement += LocalDeclaration()+"\n"
                #               end
                p "===>Statements2:#{@sym}"
                
                rStatement = ""
            
    		cs = curString()
    		if @sym == C_identifierSym && cs == "friend"#ignore
                Get()
                FriendClass()
                next
            end
    		if @sym == C_identifierSym && ( cs == "mutable" )#ignore
                Get()
                next
            end
            
            if cs == "public" || cs == "private" || cs == "protected"
                Get()
                Expect(C_ColonSym)
                if cs == "private" 
                    $class_current_mode = "private"
                else
                    $class_current_mode = "public"
                end
                next
            end    		
            
            # label for goto
            if csf && @sym == C_identifierSym && GetNextSym().sym == C_ColonSym
                label = curString()
                current_labeled_block = {
                    :label=>label,
                    :src=>""
                }
                csf.labeled_blocks.push(current_labeled_block)
                csf.hasGoto = true
                Expect(C_identifierSym)
                Expect(C_ColonSym)
               
                next
            end
            
            p "sym:#{@sym},curString:#{curString()}"
            if (@sym == C_identifierSym || @sym >= C_staticSym && @sym <= C_voidSym ||
    		    @sym == C_TypedefSym || @sym == C_operatorSym || @sym == C_ColonColonSym ||
    		    (@sym == C_TildeSym && GetNext() == C_identifierSym)
    		    )
             #    p "enter 1,#{rStatement}"
    		    _retg = gStatement()
    		    if _retg && _retg.strip != ""
    		        rStatement += "\n" if rStatement.strip != ""
    		        rStatement += _retg	
                    p ("===>Statements3:#{rStatement}")
		        end
   
                 p "enter 11, sym #{@sym}(curString()),#{rStatement}"
    		elsif (@sym >= C_identifierSym && @sym <= C_hexnumberSym ||
    		           @sym >= C_stringD1Sym && @sym <= C_charD1Sym ||
    		           @sym == C_SemicolonSym ||
    		           @sym == C_LbraceSym ||
    		           @sym == C_LparenSym ||
    		           @sym >= C_StarSym && @sym <= C_caseSym ||
    		           @sym >= C_defaultSym && @sym <= C_ifSym ||
    		           @sym >= C_returnSym && @sym <= C_switchSym ||
    		           @sym == C_AndSym ||
    		           @sym >= C_PlusSym && @sym <= C_MinusSym ||
    		           @sym >= C_PlusPlusSym && @sym <= C_MinusMinusSym ||
                       # @sym >= C_newSym && @sym <= C_DollarSym ||
                       @sym == C_newSym || @sym == C_deleteSym || @sym == C_throwSym || @sym == C_sizeofSym || @sym == C_gotoSym ||
    		           @sym >= C_BangSym && @sym <= C_TildeSym ) 
    # line 711 "cs.atg"
    			_ret_s = Statement()
    			if _ret_s && _ret_s.strip != ""
    			    rStatement += "\n" if rStatement.strip != ""
    			    rStatement += _ret_s
			    end
    		 else 
    		     GenError(90)
		     end
             
             if csf && csf.hasGoto &&  current_labeled_block
  		        current_labeled_block[:src] += "\n" if current_labeled_block[:src].strip != ""
                 
                current_labeled_block[:src] += rStatement
                p ("=>Statements2:#{current_labeled_block[:label]}=>#{current_labeled_block[:src]}")
             else
 		        ret += "\n" if ret.strip != ""
                 
                ret += rStatement
             end
             
    	end # while
    	return ret
    # line 711 "cs.atg"
    end    
    def operatorName()
	    fname = curString()
        if (fname == "std")
            Get()
		    while @sym == C_ColonColonSym
		        Get()
		        fname += "::#{curString()}"
                Get()
	        end
             p "sym2:#{@sym}"
	        if @sym == C_LessSym # stl type (using template)
                p("type21:before parse stl11", 10)
                filterTemplate()
                p("type21:after parse stl00, #{@sym} #{curString()}")
            end
        elsif fname == "(" || fname == "["
            Get()
            fname += curString()
            Get()
        elsif @sym == C_LessLessSym || @sym == C_GreaterGreaterSym
            Get()
        else
            Get()
        	p "===>operator:#{fname}"
            while @sym != C_identifierSym && @sym != C_constSym && @sym != C_LparenSym
                fname += curString()
                Get()
            end
        end
    	p "===>operator:#{fname}"
        return fname
    end
    
    def isTypeStart(sym=@scanner.nextSym)
        p "===>isTypeStart:#{sym.sym}, val #{getSymValue(sym)}"
        # pos1 = sym.pos
        _sym = sym.sym
        if _sym >= C_staticSym && _sym <= C_voidSym || _sym == C_INSym || _sym == C_OUTSym || @sym == C_INOUTSym
            return true
        end
        if _sym == C_identifierSym
            
            cs = getSymValue(sym)
            p "===>isTypeStart1:sym=#{_sym}, val=#{getSymValue(sym)}"
            
            if cs == "const" # actually will never go here, because const is ignored by Get()->ignoreSym?()
                return true
            end
            
            _n = GetNextFromSym(sym)
            count = 1
            if _n == C_ColonColonSym
                count += 1 # count=2
                _n = GetNextFromSym(sym, count)
                while (_n == C_ColonColonSym)
                    count += 1
                    _n = GetNextFromSym(sym, count)
                    # count +=1
                end
                
            end
            p "--->@sym:#{@sym}"
            _sym11 = GetNextSymFromSym(sym, count)
            p "==>#{@scanner.buffer[_sym11.pos]}"
            p "===>isTypeStart2:#{_n}, #{_sym11.sym}, #{getSymValue(_sym11)}, count = #{count}, "
            if  _n == C_LparenSym  # functioncall 
                _nn_sym = GetNextSymFromSym(sym, count+1)
                if _nn_sym.sym != C_AndSym
                    return false
                else
                    return true # template parameter:    template <size_t count> int c(const B (&t)[count], long fff){

                end
            end
            
            if _n == C_identifierSym  ||# A::B::C d; 
                 _n == C_AndSym # A& d;
               
                return true
            end    
            
            
             
            if _n == C_LessSym #  A::B::C<  parse using of template
                nsym = GetNextSymFromSym(sym, count+1)
                p("parse using template")
                if isTypeStart(nsym) # A::B::C<short>
                    return true
                else
                    p "==>symbol #{getSymValue(sym)} is not type start!"
                    
                    return false # A::B::C<123
                end
            end
            
            varname = getSymValue(sym)
            # if @classdefs[varname] != nil
            if !@in_preprocessing
            
                if find_class(varname)[:v]
                    return true
                else
                    p "==>isTypeStart:class #{getSymValue(sym)} not found"
                end
            end
        end
       p "==>symbol #{getSymValue(sym)} is not type start!"
        return false
    end
    $typedef = {}
    def find_typedef(n)
        p "find_typedef:#{n}, #{$typedef[n].inspect}"
        $typedef[n] 
    end
    
    def addTypeDef(n, t)
        p "addTypeDef1:#{n}, #{t.inspect}", 10
        if t.name
            if $typedef[t.name]
                $typedef[n] = $typedef[t.name]
            else
                $typedef[n] = t
            end
        end
        
    end
    
    $temp_symtab = {}
    # line 689 "cs.atg"
   def LocalDeclaration()
       
       p "---->LocalDeclaration1"
        ret = ""
    # line 690 "cs.atg"

        storageclass = ""
        
        if @sym == C_externSym 
            _n = GetNextSym()
            p "===>LocalDeclaration2:extern:#{_n.sym}"
            
            if _n.sym == C_stringD1Sym 
                p "===>LocalDeclaration3:extern:#{getSymValue(_n)}"
                
                if  getSymValue(_n) == '"C"'
                    p "===>LocalDeclaration4:extern:"
                    Get()
                    Get()
                    return CompoundStatement()
                
                end
                
            end
        end
        
        
        # handle typedef
        type = ""
        if @sym == C_TypedefSym
    	    p "--->typedef"
            Get()
            
            if @sym == C_unionSym 
                Union()
    	        while @sym != C_SemicolonSym
                    
                    if @sym == C_CommaSym
                        Get()
                        next
                    end
                    
                    if @sym == C_identifierSym
                        Get()
                    else
                        if @sym == C_StarSym
                            while @sym == C_StarSym
                                Get()
                            end
                            Expect(C_identifierSym)
                        end
                    end
                        
                end
                return ret
            elsif @sym == C_StructSym   # handle typedef struct _A{...}A,*PA;
                
                clsdef = StructDef()
                p "---1>10, #{@sym}"
                
                added = false if clsdef.class_name == "__struct_dummy_name__"
                
                tn = nil
    	        while @sym != C_SemicolonSym
                    p "---1>13, #{@sym}"
                    
                    if @sym == C_CommaSym
                        Get()
                        next
                    end
                    p "---1>12, #{@sym}"
                    
                    if @sym == C_identifierSym
                        p "---1>11, #{@sym}"
                        sname = curString()
                        if  !added
                            clsdef.class_name = sname
                            current_ruby_scope.add_class(clsdef)
                            added = true
                        else    
                            ret += "#{sname} = #{clsdef.class_name}\n"
                        end
                        Get()
                    else
                        if @sym == C_StarSym
                            while @sym == C_StarSym
                                Get()
                            end
                            Expect(C_identifierSym)
                        end
                    end
                        
                end
            

                return ret
            elsif @sym == C_EnumSym
                ret += Enum()
                Expect(C_identifierSym)
                addTypeDef(prevString(), VarType.new(curString(), "enum"))
                Expect(C_SemicolonSym)
                return ret

            else
                if @sym == C_classSym 
                    Get()
                    Expect(C_identifierSym)
                    t = VarType.new(curString(), "class")
                else
                    t = Type()
                end
                while( @sym == C_StarSym || @sym == C_AndSym)
                    Get()
                end
                if (@sym == C_identifierSym)
                    addTypeDef(curString(), t)
                elsif (@sym == C_LparenSym && GetNextSym().sym == C_StarSym)
                    Get()
                    Expect(C_StarSym)
                    t.name = curString()
                    t.type = "FunctionPointer"
                    addTypeDef(curString(), t)
                    
                end
    	        while @sym != C_SemicolonSym
    	               Get()
    	            p "cs in td:#{@sym},#{curString}"
	            end
                return ""
            end
	        
        end
=begin        
        if @prev_sym == C_identifierSym
            @prev_sym = nil
        else
        
            p "=3>#{@sym}"
        # line 696 "cs.atg"
        	if (@sym >= C_boolSym && @sym <= C_stringSym || @sym == C_identifierSym) 
        # line 696 "cs.atg"
        		type += Type()
        	elsif (@sym >= C_staticSym && @sym <= C_functionSym) 
        # line 696 "cs.atg"
        		storageclass += StorageClass()
        # line 696 "cs.atg"
                # if (@sym >= C_boolSym && @sym <= C_stringSym) 
        # line 696 "cs.atg"
                    # Type()  
                # end       
        	
        	# just ignore typdef, cuz ruby dosen't need any type definition
        	elsif @sym == C_TypedefSym
        	    p "--->typedef"
        	    while @sym != C_SemicolonSym
        	        Get()
    	        end
    	        return ""
        	else 
        	    GenError(98)
    	    end
        end
    # line 699 "cs.atg"
        
        if type != ""
            var_type = VarType.new(type)
        end
 
        
    	while (@sym == C_StarSym || @sym == C_AndSym) 
    	    var_type.ref += 1
    # line 699 "cs.atg"
    		Get()
    # line 699 "cs.atg"
    	end
    	
    	# sometime static occur after type
    	if (@sym >= C_staticSym && @sym <= C_functionSym) 
    		storageclass += StorageClass()
    	end
=end
    
        #dump_pos()
        isOperatorDef = false
        p "---->LocalDeclaration21, #{@sym}, #{curString()}"
        
        prefix = ""
        if @sym == C_ColonColonSym
            p "---->LocalDeclaration212, #{@sym}, #{curString()}"
            prefix = "::"
            Get()
           # if @sym == C_operatorSym
           #     isOperatorDef = true
           #     Get()
           #     
           # end
        
        end
        
        _next = GetNext()
        p "---->LocalDeclaration2, #{@sym}, #{curString()} #{_next}"
        
        while (@sym != C_LparenSym && @sym != C_ColonColonSym && @sym != C_operatorSym &&
                (   @sym >= C_boolSym && @sym <= C_voidSym ||
                    _next == C_identifierSym || _next == C_operatorSym ||
                    _next >= C_boolSym && _next <= C_voidSym || # data type
                    _next >= C_staticSym && _next <= C_externSym ||
                    _next == C_StarSym || _next == C_AndSym || _next == C_ColonColonSym ||
                    _next == C_LessSym # template 
                )
               )
               p "---->LocalDeclaration3, @sym=#{@sym}, curString=#{curString()}, line #{curLine()}, col #{curCol()}"
           #dump_pos()
           
           if @sym == C_identifierSym && _next == C_ColonColonSym  && type != ""
               break
           end
              if @sym == C_identifierSym && curString == "kl" 
                 break
              end
             p "-->sym:#{@sym}, next:#{_next}, line #{@scanner.nextSym.line }, v=#{curString()}"
        	if (@sym >= C_staticSym && @sym <= C_externSym) 
                p "---->LocalDeclaration11"
        		storageclass += StorageClass()
        	elsif (@sym >= C_boolSym && @sym <= C_voidSym)
                p "---->LocalDeclaration12"
                _var_type = Type()
                type += _var_type.name
            elsif @sym == C_identifierSym
                p "---->LocalDeclaration13:#{curString}"
                _var_type = Type()
                type += _var_type.name   # replace last one, to remove decorator like __dll_export
            elsif _next == C_ColonColonSym
                p "---->LocalDeclaration14"
                
                _var_type = Type()
                type += _var_type.name
           # elsif @sym == C_operatorSym
           #     isOperatorDef = true
           #     Get()
            end
        
        
            if type != ""
                p "---->LocalDeclaration15:#{type}, #{_var_type.inspect}"
                
                var_type = _var_type # will be used in check if need add namespace prefix
            end
            if (@sym == C_StarSym || @sym == C_AndSym) 
                p "---->LocalDeclaration16"
                
            	while (@sym == C_StarSym || @sym == C_AndSym) 
            	    var_type.ref += 1
                    # line 699 "cs.atg"
            		Get()
                    # line 699 "cs.atg"
            	end
            	break
        	end
        	 _next = GetNext()
              p "---->LocalDeclaration33, _next:#{_next}"
        end
        var_type.name = prefix + var_type.name if var_type # put "::" before type
#end # if @sym == C_ColonColonSym
 
        p "--->isOperatorDef:#{isOperatorDef}"
        
        # line 702 "cs.atg"
        p "type=#{type}, storageclass=#{storageclass}, prev=#{@prev_sym}, cur=#{@sym}, val #{curString}"
        #dump_pos()
        
        # end of parsing type

        
        
        # variable name, function name, function operator name
=begin
        if @sym == C_identifierSym
            _name = curString()
            
            if _name == "operator"
                op_name = ""
                Get()
               
                begin 
                    op_name += curString()
                    Get()
                end while @sym != C_identifierSym && @sym != C_constSym && @sym != C_LparenSym
            elsif 
        end
=end         
         
    	varname = curString()
    	p "===>32:#{varname}"
    	
    	fname = varname
        
         if @sym == C_operatorSym
            isOperatorDef = true
            Get()
        end
    	p "===>321:#{curString()}, #{isOperatorDef}"
             
    	if isOperatorDef 
            fname = operatorName()
            
	    end
        p "===>LocalDeclaration51:name:#{fname}, #{varname}"
    	p "===>LocalDeclaration6:#{@sym}, #{curString()}"
	    
    	if @sym == C_LparenSym
    	    # for constructor with initialization list in classdef or sturctdef
	    else
            Expect(C_identifierSym)
    	end
    	p "===>33:#{varname}, #{@sym}"
    	if @sym == C_ColonColonSym
    	    # @classdefs.each{|k,v|
    	    #              p "class #{k} = #{v}"
    	    #          }
    	    if @classdefs[varname] == nil #&& varname != "std"
                # raise "class #{varname} not found"
              #  current_ruby_scope.add_class(varname)
	        end
	        class_name = varname
    	    Get()
    	    fname = curString()
            # Expect(C_identifierSym)
    	    p "===>332:class_name=#{class_name}, fname=#{fname}"
            if fname == "operator"
                isOperatorDef = true
                op_name = ""
                Get()
                begin 
                    op_name += curString()
                    Get()
                end while @sym != C_identifierSym && @sym != C_constSym && @sym != C_LparenSym
                p "opname:#{op_name}"
                fname=op_name
            else
                Get()
            end
	    end
    # line 702 "cs.atg"

    # line 706 "cs.atg"
    p "sym333:#{@sym}, val #{curString()} line #{@scanner.currLine}"
    
    if (@sym == C_LessSym)
        filterTemplate()
    end
    	if (@sym == C_LparenSym) 
    # line 706 "cs.atg"
            nn  =  GetNext(2)
            _n = GetNext()
            p "sym331:#{@sym}, #{_n}, #{nn}, curString #{curString()}"
            # if nn != C_RparenSym && nn != C_CommaSym || 
            #     # not following case
            #     # A fn(a)
            #     # A fn(a,
            #     _n == C_voidSym # A fn(void)
            #     fd = FunctionDefinition(class_name)
            # if nn != C_RparenSym && isTypeStart(GetNextSym())
            
            p "---->LocalDeclaration20:#{_n}, #{curString()}"


           # Get()
            #p "---->LocalDeclaration201:#{@sym}, #{curString()}"
            
            gns = GetNextSym()
            p "---->LocalDeclaration210:#{@sym}, #{curString()}"
            
            p "---->LocalDeclaration21:#{gns.sym}, #{getSymValue(gns)}"
           # its = isTypeStart(gns)
           #  p "---->LocalDeclaration22:#{its}"
           p "fname3:#{fname}, #{varname}, #{type}"
           #===
           # it's not possible to diff the "(A*a)" is a formalparamter(A is type) or actual parameter(A is variable)
           #
           #if  _n == C_RparenSym 
           #   twoParts = false
           #   count = 2
           #   _ns = GetNext(count)
           #   while ( true)
           #       if _ns == C_identifierSym
           #            count += 1
           #            _ns = GetNext(count)
           #            if _ns == C_LessSym
           #                filterTemplate()
           #            end
           #            while ( _ns == C_ColonColonSym)
           #                count +=1
           #                GetNext(count)
           #                count +=1
           #                _ns = GetNext(count)
           #             end
           #       else
           #            count += 1
           #             _ns = GetNext(count)
           #       end
           #       while (_ns == C_StarSym || _ns == C_AndSym)
           #           count += 1
           #          _ns = GetNext(count)
           #       end
           #       
           #       
           #       
           #   end
            #===   
           
            # ===
            # it's not possible to diff the case:
            # SBOErr ooErr (A*a)
            # is functiondefinition or local variable instantiated using consturctor
            # 
            #if (type && type != "" ) || 
            # ====    
            p "--->111:#{@sym} #{curString},  #{_n}"

            if !@in_preprocessing
                # add new class for unregcognized symbol           
                gnsstr = getSymValue(gns)
                if gns.sym == C_identifierSym && 
                   # gnsstr[0] == gnsstr[0].upcase  && # usually Class is Upcase at first char
                     !find_var(gnsstr, current_scope) && # not variable
                     find_class(gnsstr)[:v] == nil && # not class
                     find_module_from(gnsstr, nil)[:v] == nil  && # not module
                     find_typedef(gnsstr) == nil # not typedef
                   #  throw "#{gnsstr} is not defined anywhere"
                     @root_class.add_class(ClassDef.new(gnsstr))
                #    $temp_symtab[gnsstr]= current_ruby_scope
                
                    append_file("newclass", "\"#{getSymValue(gns)}\",")
                    p("append newclass #{getSymValue(gns)}")
                end
            end
            
            if (_n == C_EnumSym || # A fn(enum B b);
                isOperatorDef ||  (_n == C_RparenSym && nn != C_SemicolonSym ) || _n == C_PPPSym ||
                 isTypeStart(gns)# || isFunctionFormalParamStart(offset)
                 )# && !find_var(getSymValue(gns), current_scope) # is not var
                # A fn();
                # A fn(a* b) in which a is type
                 
        
                fd = FunctionDefinition(class_name, fname, storageclass)
            else
                p "--->1111:#{@sym}, #{_n}"
                
            	varname = current_scope.add_var(Variable.new(varname, var_type))
                # fc = "#{varname} = #{var_type.name}.new"
                # fc += FunctionCall()
                # p "fc=#{fc}"
            	
                # p "varlist22"
                # line 706 "cs.atg"
                vl = VarList(var_type, varname) # define lots of variables in one line splitted by comma

                # line 706 "cs.atg"
            	Expect(C_SemicolonSym)
            end
            
            
            # fd = FunctionCall()
    	elsif (@sym == C_SemicolonSym ||
    	           @sym >= C_EqualSym && @sym <= C_LbrackSym) 
    	    varname = current_scope.add_var(Variable.new(varname, var_type))
    # line 706 "cs.atg"
            vl = VarList(var_type, varname) # define lots of variables in one line splitted by comma
	
    # line 706 "cs.atg"
    		Expect(C_SemicolonSym)
    	else # if (@sym == C_LparenSym)
    	    GenError(99)
	    end
    # line 706 "cs.atg"
        if fd && fd != ""
            # ret = "def #{fname}#{fd}\nend"
        else
            # _ret = "#{varname}#{vl}"
            # ar = _ret.split(",")
            # ret = ""
            # ar.each{|a|
            #     a = a.strip
            #     p "==>a=#{a}"
            #     if a=~ /[\w\d_]+\s*=.*?$/m
            #         ret += a + "\n"
            #     else
            #     end
            # }
            ret = "#{varname}#{vl}"
            p "localdeclaration3:#{ret}"
            ret = ret.gsub(/^\s*_*[\w_\d]+\s*$/m, "")

            ret = ret.gsub(/\n\n+/, "\n") # or use ret.squeeze("\n")
            # ret2 = ""
            #      ret.each_line{|l|
            #          l = l.gsub("\n", "").strip
            #          if l.size > 0
            #              ret2 += "\n" if ret2 != ""
            #              ret2 += l
            #          end
            #      }
            #      ret = ret2
            p "localdeclaration4:#{ret}, #{ret.size}", 10
            
        end
           
        
        return ret
    end
    
   #def isFunctionFormalParamStart(offset)
   #    _s = GetNextSym(offset)
   #    if _s.sym >= C_shortSym && _s.sym <=C_voidSym
   #        return true
   #    elsif _s.sym == C_identifierSym
   #        _s1= GetNextSym(offset+1)
   #        
   #    end
   #end
    # line 440 "cs.atg"
    def VarList(var_type, var_name)
        pdebug("----->varlist0;#{@sym}, #{curString}")
        p("var_type:#{var_type.inspect}")
        ret = ""
        
        
        if @sym == C_LparenSym
        	ret += " = #{var_type.name}.new"
            s,n = FunctionCall("#{var_type.name}.initialize")
        	ret += s
        elsif ArraySize() != ""
            ret += " = []\n"
        elsif !var_type.is_simpleType && var_type.type != "FunctionPointer"
        	ret += " = #{var_type.name}.new"
        end
    # line 442 "cs.atg"

    	   
    # line 445 "cs.atg"
    	if (@sym == C_EqualSym) 
    	    ret += "="
    # line 445 "cs.atg"
    		Get();
    # line 445 "cs.atg"
            #parsed = false
            #if (@sym == C_identifierSym && GetNextSym.sym == C_SemicolonSym)
            #    if find_method(curString)
            #        ret += ":#{curString}"
            #        parsed = true
            #    end
            #end
    		#
            #ret += Expression() if !parsed
            ret += Expression()
    # line 445 "cs.atg"
    	end
    # line 446 "cs.atg"
    	while (@sym == C_CommaSym) 
    	    ret += "\n"
    # line 446 "cs.atg"
    		Get()
    # line 446 "cs.atg"
            while (@sym == C_StarSym || @sym == C_AndSym)
                Get()
            end
            Expect(C_identifierSym)
            varname = prevString()
            p "varname=#{varname}"
    		
    		newname = current_scope.add_var(Variable.new(varname, var_type))
    	    ret += newname
    		
    # line 447 "cs.atg"
        	
            if @sym == C_LparenSym
            	ret += " = #{var_type.name}.new"
                s,n = FunctionCall("#{var_type.name}.initialize")
            	ret += s
            elsif ArraySize() != ""
                ret += " = []\n"
            elsif !var_type.is_simpleType 
            	ret += " = #{var_type.name}.new"
            end
    # line 455 "cs.atg"

    # line 458 "cs.atg"
    		if (@sym == C_EqualSym) 
    		    ret += " = "
    # line 458 "cs.atg"
    			Get();
    # line 458 "cs.atg"
    			ret += Expression()
    # line 458 "cs.atg"
    		end
    	end
    	pdebug "varlist1:#{ret}"
    	return ret
    end

    # line 461 "cs.atg"
    def ArraySize()
        ret = ""
    # line 461 "cs.atg"
    	while (@sym == C_LbrackSym) 
            ret += "["
    # line 461 "cs.atg"
    		Get();
    # line 461 "cs.atg"
    		if (@sym >= C_identifierSym && @sym <= C_hexnumberSym ||
    		    @sym >= C_stringD1Sym && @sym <= C_charD1Sym ||
    		    @sym == C_LbraceSym ||
    		    @sym == C_LparenSym ||
    		    @sym == C_StarSym ||
    		    @sym == C_AndSym ||
    		    @sym >= C_PlusSym && @sym <= C_MinusSym ||
    		    @sym >= C_PlusPlusSym && @sym <= C_MinusMinusSym ||
    		    @sym >= C_newSym && @sym <= C_DollarSym ||
    		    @sym >= C_BangSym && @sym <= C_TildeSym ||
                @sym == C_deleteSym || @sym == C_throwSym || @sym == C_sizeofSym  ) 
    # line 461 "cs.atg"
    			ret += ConstExpression()
    		end
    # line 461 "cs.atg"
    		Expect(C_RbrackSym)
            ret += "]"
    	end
    	return ret
    end    
    # line 465 "cs.atg"
    
    # class_name should never be nil
    def FunctionDefinition(class_name, fn_name, acc="")
        pdebug "===>FunctionDefinition:#{class_name}::#{fn_name}", 30
        throw "cannot have function defition(#{fn_name}) in a function defintion #{current_scope.class_name}" if current_scope.name == "FunctionDefinition"
        
        ret = ""
        @presrc = "" # predfined code before function body source
        if !@in_preprocessing
            if class_name && class_name != ""
     	       # classdef = @classdefs[class_name]
               classdef = find_class(class_name)[:v]
     	        if !classdef
     	            if current_scope.is_a?(ClassDef)
                        classdef = current_scope
                    end
                    if !classdef
                        classdef = current_ruby_scope.add_class(class_name)
                    end
                end
            else
                if current_scope.is_a?(ClassDef) ||current_scope.is_a?(ModuleDef)
                    classdef = current_scope
                end
                #classdef = current_ruby_scope()
                #class_name = classdef.class_name
            end
        
        end
        pushed = false
        p("==>FunctionDefinition17:#{current_scope.name}, #{classdef}")
        if classdef && classdef != current_scope
            
            in_scope(classdef)
        	throw  "4" if $g_root_moddef.parentScope != nil && fn_name == "t"
            
            pushed = true
        end
        
        if classdef
            p "===>FunctionDefinition3:#{classdef.class_name}@#{classdef}"
        else
            p "===>FunctionDefinition3:#{classdef}"
            
        end
        
        # list_scopes
      #  p "classdef:#{classdef.inspect}"
    # line 466 "cs.atg"
        _sc = Scope.new("FunctionDefinition")
        _sc.class_name = fn_name
        in_scope(_sc)
    # line 509 "cs.atg"
        r,pds = FunctionHeader()
    	ret += r
        
    	if ret.gsub(/\s/,"") == "()"
    	    args_num = 0
	    else
    	    args_num = ret.split(",").size
    	end
    	p "function header:#{fn_name} #{ret}, arg num #{args_num}"
    	if @sym == C_constSym
    	    Get()
	    end
    # line 509 "cs.atg"
        p "--->FunctionDefinition sym:#{@sym}, #{curString()}"
        symValue = curString()
        if @sym == C_SemicolonSym  ||symValue == "const" || @sym==C_overrideSym
            #if just function declaration without body
            # return ""
        	throw  "1" if $g_root_moddef.parentScope != nil && fn_name == "t"
       
        elsif @sym == C_EqualSym
            Get()
            Expression()
            Expect(C_SemicolonSym)
        	throw  "2" if $g_root_moddef.parentScope != nil && fn_name == "t"
            
        else

            # in_scope(classdef) if classdef
            if @sym == C_ColonSym
                p("===>FunctionDefinition2:ctor")
                # member value initialization list, for constructor of class/struct
                p "# initialization list, for constructor of class/struct:#{classdef.class_name}"
                i_list = ""
                Get()
                 m = curString()
                 p "m=#{m}, parent=#{classdef.parent}"
                 if m == classdef.parent
                     m = "super"
                 end
                Expect(C_identifierSym)
               
                Expect(C_LparenSym)
                v,args = ActualParameters()
                Expect(C_RparenSym)
                if m == "super"
                    i_list += "super(#{v})\n"
                else
                    i_list += "@#{m} = #{v}\n"
                end
                while (@sym == C_CommaSym)
                     Get()
                     Expect(C_identifierSym)
                     m = prevString()
                     Expect(C_LparenSym)
                     v = Expression()
                     Expect(C_RparenSym)
                     v = "nil" if v == ""
                     i_list += "@#{m} = #{v}\n"
                     
                end
            end
            
        	fb = FunctionBody()
            
        	fb = i_list + fb if i_list
            p ("FunctionDefinition3:#{fb}")
            
            if current_scope("FunctionDefinition").hasGoto
                blk_src = ""
                current_scope("FunctionDefinition").labeled_blocks.each{|b|
                    blk_src += "label(:#{b[:label]}){\n#{b[:src]}\n}\n"
                }
                fb = "\nframe_start\n#{fb}\n#{blk_src}\nframe_end\n"
            end
        	throw  "2" if $g_root_moddef.parentScope != nil && fn_name == "t"
            
            # out_scope() if classdef
    	end

    	 out_scope() # functiondefinition

    # line 510 "cs.atg"
        method_src = nil
        if (fb)
            ret = "#{ret}\n#{@presrc}\n#{fb}\nend"
            method_src = ret
            ret = ""
        end
        # add_class_method_def(class_name, fn_name, args)
        #p "classdef #{classdef.inspect}"
        if classdef
            p "add method '#{fn_name}'##{args_num} to class '#{classdef.class_name}@#{classdef}':#{method_src}\nacc:#{acc}", 10
            
            classdef.add_method(fn_name, pds, method_src, acc)
        else
            p "add method '#{fn_name}'##{args_num} to root class '#{@root_class}':#{method_src}\nacc:#{acc}", 10
            
            @root_class.add_method(fn_name, pds, method_src, acc)
        end
        #p "classdef #{classdef.inspect}"
        pdebug "===>FunctionDefinition1:#{class_name}::#{fn_name}"
        
        if pushed
            out_scope()
        end
        return ret
    end

    # line 537 "cs.atg"
    def FunctionHeader()
    
    # line 538 "cs.atg"


        ret = ""
        pds = [] #parameters description
        
    # line 545 "cs.atg"
    	Expect(C_LparenSym)
    # line 545 "cs.atg"
    	if (@sym == C_identifierSym ||
    	    @sym >= C_boolSym && @sym <= C_voidSym||
    	   @sym == C_constSym || @sym == C_INSym || @sym == C_OUTSym || @sym == C_INOUTSym || @sym == C_PPPSym  || @sym == C_EnumSym ||
            @sym == C_classSym # only for strange copy ctor A(class A&other);
            ) 
    # line 545 "cs.atg"
            if @sym == C_PPPSym
                current_scope("FunctionDefinition").add_var(Variable.new("*_args_",  "vargs", "*_args_"))
                ret += "*_args_"
                Get()
            else
                r, pds = FormalParamList()
    		    ret += r
            end
    	end
    # line 545 "cs.atg"
    	Expect(C_RparenSym)
    # line 546 "cs.atg"
    _cs = curString()
    p("====>FunctionHeader1:#{@sym}")
        if (@sym == C_identifierSym && ( _cs == 'const') )|| @sym == C_overrideSym
            Get()
        elsif @sym == C_throwSym 
            Get()
            if (@sym == C_LparenSym)
                Get()
                CommaExpression()
                Expect(C_RparenSym)
            else
                CommaExpression()
            end
        end
        
        
        return "(#{ret})", pds
 
    end
    
    # line 567 "cs.atg"
    def FormalParamList()
        p("FormalParamList0")
        $formal_p_count = 0
        pds = []
        ret = ""
    # line 567 "cs.atg"
        pd = FormalParameter()
    	ret += pd[:name]
        pds.push(pd)
    	
    # line 567 "cs.atg"
    	while (@sym == C_CommaSym) 
    	    ret += ","
    # line 567 "cs.atg"
    		Get()
    # line 567 "cs.atg"
            if @sym == C_PPPSym
                current_scope("FunctionDefinition").add_var(Variable.new("*_args_",  "vargs", "*_args_"))
                ret += "*_args_"
                Get()
            else
                pd = FormalParameter()
    		    ret += pd[:name]
                pds.push(pd)
            end
    		
    	end
    	
    	return ret,pds
    end
    
    def parameter_to_var(var_type)
        ret = ""
        p("parameter_to_var0:#{@sym}")
        if @sym == C_identifierSym 
             param_name = varname = curString()
           
            # here parameter in function header cannot be Const (Capital on first char)
            param_name = param_name[0].downcase + param_name[1..param_name.size-1]
         #   param_name = ":#{param_name}" if var_type == "__FunctionPointer__"
            ret += param_name
            cs = current_scope("FunctionDefinition")
            if (cs)
                current_scope("FunctionDefinition").add_var(Variable.new(varname, var_type, param_name))
            else # maybe in stl for parse Template<T>fn(...)
                
            end
            Get()
        else # when in function declaration, parameter name is optional
            ret += "dummy#{$formal_p_count}"
            $formal_p_count +=1
        end
        return ret
    end
    # line 441 "cs.atg"
    def FormalParameter()
        p("FormalParameter0:sym=#{@sym}, curString=#{curString()}")
        
        ret = ""
        pd = {}
    # line 441 "cs.atg"
        # PTYPEDES type = new TYPEDES;
    # line 442 "cs.atg"
        if (@sym == C_identifierSym && curString() == 'const') ||
             @sym == C_classSym # only for strange copy ctor: A(class A&other);
            Get()
        end
    	var_type = Type()
        p("FormalParameter1:sym=#{@sym}, curString=#{curString()}, #{var_type}")
    # line 442 "cs.atg"
        pd[:type] = var_type.name
        td = find_typedef(var_type.name)
        if (td && td.type == "FunctionPointer")
            pd[:type] = "FunctionPointer"
        end
        if @sym == C_LparenSym && GetNextSym().sym == C_AndSym# template parameter:   template <size_t count>  int c(const B (&t)[count], long fff);
            Get()
            Expect(C_AndSym)
            varname= curString()
            ret += parameter_to_var(var_type)
            Expect(C_RparenSym)
            Expect(C_LbrackSym)
            count = curString()
            @presrc += "#{count}=#{varname}.size\n"
            Get()
            Expect(C_RbrackSym)
        elsif  @sym == C_LparenSym && GetNextSym().sym == C_StarSym # function pointer: void fn(long propertyId, bool (*onCanChange)(const CBofNode&, T, bool), ...
            Get()
            Expect(C_StarSym)
            var_type.type = "FunctionPointer"
            ret += parameter_to_var(var_type)
        
            Expect(C_RparenSym)
            FunctionHeader()
            pd[:type] = "FunctionPointer"
        else
        	while (@sym == C_StarSym || @sym == C_AndSym || @sym == C_AndAndSym) 
        # line 442 "cs.atg"
        # line 442 "cs.atg"
        		Get()
        # line 442 "cs.atg"
                # type->refLevel++;
        	end
            p("FormalParameter2:sym=#{@sym}, curString=#{curString()}")
        
        # line 444 "cs.atg"
   
            ret += parameter_to_var(var_type)
            # Expect(C_identifierSym)
    	
        # line 445 "cs.atg"

        # line 450 "cs.atg"
        	ArraySize()
        # line 451 "cs.atg"
        
            if @sym == C_EqualSym #default value for parameter
                Get()
                r = Expression()
                ret += " = #{r}"
                p "===>FormalParameter default value"
            end
        
        end # if @sym == C_LparenSym; else
        pd[:name] = ret
        p "FormalParameter0:pd=#{pd.inspect}"
        return pd
        
    end
    # line 394 "cs.atg"
    def StorageClass()
        ret = ""
    # line 396 "cs.atg"
    	if (@sym >= C_staticSym && @sym <= C_externSym || @sym == C_INSym || @sym == C_OUTSym || @sym == C_INOUTSym) 
    	    ret += curString()
    # line 395 "cs.atg"
    		Get();
        # } elsif (Sym == mySym) {
    # line 396 "cs.atg"
            # Get();
        # elseif (Sym == functionSym) {
    # line 397 "cs.atg"
            # Get();
    	else 
    	    GenError(91)
	    end
	    return ret
    end
    def FullType
        type = Type().name
        if type
            var_type = VarType.new(type)
        end

###############################################
#        int (*pFunction)(float,char,char)=NULL;
#        int (MyClass::*pMemberFunction)(float,char,char)=NULL;
#        int (MyClass::*pConstMemberFunction)(float,char,char) const=NULL;
##############################################
        if @sym == C_LparenSym  # pointer to function
            Get()
            Expect(C_StarSym)
            Expect(C_identifierSym)
            Expect(C_RparenSym)
            FunctionHeader()
        else
        	while (@sym == C_StarSym || @sym == C_AndSym) 
        	    var_type.ref += 1 if var_type
                # line 699 "cs.atg"
        		Get()
                # line 699 "cs.atg"
        	end
    	end
    	return var_type
    end
    def STLType()
        p("STLType0")
          #  Get()
         #  FormalParamList()
        filterTemplate()
         p("STLType1,#{@sym}, #{curString()}")
       #  Get()
         
        #    Expect(C_GreaterSym)
        
    end
    
    def skipUnusableType()
        while (@sym == C_identifierSym && GetNext() != C_ColonColonSym )
            v = curString()
            if ($unusableType.include?(v))
                Get()
            else
                break
            end
        end
    end
    
    # line 400 "cs.atg"
    def Type()
        pdebug("---->type:#{@sym}, #{curString()}")
        ret = ""
        is_simpleType = true
        var_type = nil
        
        while (@sym >= C_staticSym && @sym <= C_constSym || @sym == C_INSym || @sym == C_OUTSym || @sym == C_INOUTSym) 
            StorageClass() # will be ignore
        end
        
        # skip "export", "__dll_..."
        skipUnusableType()
        
    # line 423 "cs.atg"
    	case (@sym) 
=begin
    		when C_boolSym 
    		when C_mixedSym  
    # line 406 "cs.atg"
    			if (Sym == varSym) {
    # line 406 "cs.atg"
    				Get();
    			} elseif (Sym == mixedSym) {
    # line 406 "cs.atg"
    				Get();
    			} else GenError(92);
    # line 407 "cs.atg"

    			#break;
=end
    		when C_shortSym  
    		    ret += curString()
    # line 424 "cs.atg"
    			Get()
    # line 424 "cs.atg"
    			if (@sym == C_intSym) 
    # line 424 "cs.atg"
    				ret += curString()
        		    Get()
    			end
    # line 425 "cs.atg"
    			#break;
    		when C_longSym  
    # line 426 "cs.atg"
    			ret += curString()
    		    Get();
    # line 426 "cs.atg"
    			if (@sym == C_intSym ||
    			    @sym == C_intSym) 
    # line 426 "cs.atg"
    				if (@sym == C_intSym) 
    # line 426 "cs.atg"
    					ret += curString()
            		    Get();
    				elsif (@sym == C_intSym) 
    # line 426 "cs.atg"
    					ret += curString()
            		    Get();
    				
    				else
    				     GenError(93)
				    end
    			end
    # line 427 "cs.atg"
    			#break;
    		when C_unsignedSym  
    # line 428 "cs.atg"
    			ret += curString()
    		    Get();
    # line 428 "cs.atg"
    			while (@sym >= C_shortSym && @sym <= C_doubleSym ) 
    # line 428 "cs.atg"
    				ret += curString()
            	    Get()
    		
    			end
    			#break;
            when C_boolSym
    			ret += curString()
    		    Get()
    		when C_charSym  
    # line 429 "cs.atg"
    			ret += curString()
    		    Get()
    # line 430 "cs.atg"
    			#break;

    		when C_intSym  
    # line 431 "cs.atg"
    			ret += curString()
    		    Get();
    # line 432 "cs.atg"
    			#break;
    		when C_floatSym  
    # line 433 "cs.atg"
    			ret += curString()
    		    Get();
    # line 434 "cs.atg"
    			#break;
    		when C_doubleSym  
    # line 436 "cs.atg"
    			ret += curString()
    		    Get();
    			#break;
    		when C_voidSym  
    # line 436 "cs.atg"
    			ret += curString()
    		    Get();
    			#break;
    	#	when C_stringSym  
    # line 436 "cs.atg"
    		#	ret += curString()
    		  #  Get();
    # line 437 "cs.atg"
    			# break;
            when C_EnumSym
                Get()
                ret += curString()
                Expect(C_identifierSym)
               
    		when C_identifierSym
                _n = curString()
    		    ret += _n
    		    Get()
                p "sym1:#{@sym}, #{curString()}"
                
                if (@sym == C_identifierSym || @sym == C_StarSym || @sym == C_AndSym)
                    if !@in_preprocessing
                        var_type = find_typedef(_n)
                        is_simpleType = false if var_type
                    end
                else
		        
        		    while @sym == C_ColonColonSym
        		        Get()
        		        ret += "::#{curString()}"
        		        Get()
        		        if @sym == C_LessSym # stl type (using template)
                            p("type20:before parse stl0")
        		            STLType()
                            p("type20:after parse stl0, #{@sym} #{curString()}")
                        
        	            end
    		        end
                    # p "sym2:#{@sym}"
    		        if @sym == C_LessSym # stl type (using template)
                        p("type21:before parse stl1", 10)
                        STLType()
                        p("type21:after parse stl0, #{@sym} #{curString()}")
                    
    	            end
    	            while @sym == C_ColonColonSym
        		        Get()
        		        ret += "::#{curString()}"
        		        Get()
    		        
    		        end
                    
                    if !@in_preprocessing
                        r = find_class(ret)
                        ret = r[:prefix] + "::" + ret if r[:prefix]  != ""
                    end
                    is_simpleType = false
    	            p "sym3:#{@sym}, val #{curString()}"
    	            p "ret3:#{ret}"
                   # if (find_class(ret) == nil)
        	       #     p "unknow type:#{ret}"
                   #     
                   #     GenError(116)
                   # end
               
               end
    		else 
    		    GenError(95)
    	    end # case
    	p "type3:ret=#{ret}, #{@sym}, val #{curString()}"

    	#return ret
        if var_type == nil
            r =  VarType.new(ret)
            r.is_simpleType = is_simpleType
            return r
        else
            var_type.is_simpleType = is_simpleType
             return var_type
        end
       
    end
    
    def Label
        ret = ""
    # line 674 "cs.atg"
    	if (@sym == C_caseSym) 
    # line 674 "cs.atg"
            
    		Get()
    # line 674 "cs.atg"
    		constexp=ConstExpression()
    # line 674 "cs.atg"
    		Expect(C_ColonSym)
    		ret += "when #{constexp}\n"
    	elsif (@sym == C_defaultSym) 
    # line 674 "cs.atg"
    		Get()
    # line 674 "cs.atg"
    		Expect(C_ColonSym)
    		ret += "else \n"            
        else 
    	    GenError(97)
	    end
	    
        return ret
    end
    
    def TryStatement()
        pdebug("===>TryStatement")
        Get()
        try_stmt = CompoundStatement()
        Expect(C_identifierSym)
        cs = prevString()
        pdebug("===>TryStatement2, #{@sym}, #{cs}")
        if cs == "catch"# catch (DBMException &e)
            # Get()
            
            pdebug("===>TryStatement3, #{@sym}")
            
            Expect(C_LparenSym)
            # Expect(C_identifierSym)
            #             exptype = prevString()
            #             while (@sym == C_StarSym || @sym == C_AndSym)
            #                 Get()
            #             end
            pdebug("===>TryStatement31, #{@sym}")
            
            if (@sym == C_PPPSym)
                Get()
                Expect(C_RparenSym)
                catch_stmt = CompoundStatement()
                stmt =<<HERE
                begin
                    #{try_stmt}
                rescue 
                    #{catch_stmt}
                end
HERE
            else

            exptype = FullType()
                #Expect(C_identifierSym)
                #expvar = prevString()
                #Expect(C_RparenSym)
            
          
                pdebug("===>TryStatement4, #{@sym}")
            
                if @sym == C_identifierSym
                    Get()                
                    expvar = prevString()
                    p("expvar=#{expvar}")
                    Expect(C_RparenSym)
                else
                   Expect(C_RparenSym)# @sym should already be C_RparenSym
                end
            
            
                catch_stmt = CompoundStatement()
            
                stmt =<<HERE
                begin
                    #{try_stmt}
                rescue #{exptype.name}=>#{expvar}
                    #{catch_stmt}
                end
HERE
            end
        end
        pdebug("===>TryStatement1:#{stmt}")
        return stmt
    end
    # line 657 "cs.atg"
    def Statement()
        p("Statement0", 10)
        stmt = ""
    # line 657 "cs.atg"
    	pdebug("====>statement:sym=#{@sym},curString=#{curString()}")
    # line 658 "cs.atg"
    	while (@sym == C_caseSym ||
    	       @sym == C_defaultSym) 
    # line 658 "cs.atg"
    		stmt += Label()
    	end
        
 
    # line 666 "cs.atg"
        
    	case (@sym) 
    		when C_identifierSym   ,
    		C_numberSym       ,
    		C_hexnumberSym    ,
    		C_stringD1Sym     ,
    		C_charD1Sym       ,
            # C_LbraceSym       ,
    		C_LparenSym       ,
    		C_StarSym         ,
    		C_AndSym          ,
    		C_PlusSym         ,
    		C_MinusSym        ,
    		C_PlusPlusSym     ,
    		C_MinusMinusSym   ,
    		C_newSym          ,
            C_deleteSym,
            C_throwSym,
            C_sizeofSym,
            # C_DollarSym       ,
    		C_BangSym         ,
    		C_TildeSym  
    # line 666 "cs.atg"
    			if @sym == C_identifierSym
    			    cs = curString()
    			    
			        if cs == "try" # try catch statment
			            stmt += TryStatement()
	                else
	                    stmt += AssignmentStatement()
		            end
    			else 
    			    stmt += AssignmentStatement()
			    end
                # break
    		when C_breakSym  
    # line 666 "cs.atg"
    			bs = BreakStatement()
    			if canUseBreak?
    			    stmt += bs
			    end
                # break
            when C_LbraceSym
                stmt += CompoundStatement()
    		when C_continueSym  
    # line 667 "cs.atg"
    			stmt += ContinueStatement()
                # break
    		when C_doSym  
    # line 668 "cs.atg"
    			stmt += DoStatement()
                # break
    		when C_forSym  
    # line 668 "cs.atg"
    			stmt += ForStatement()
                # break
    		when C_ifSym  
    # line 669 "cs.atg"
    			stmt += IfStatement()
                # break
    		when C_SemicolonSym  
    # line 669 "cs.atg"
    			stmt += NullStatement()
    			#break
    		when C_returnSym  
    # line 670 "cs.atg"
    			stmt += ReturnStatement()
    			#break
    		when C_switchSym  
    # line 670 "cs.atg"
    			stmt += SwitchStatement()
    			#break
    		when C_whileSym  
    # line 671 "cs.atg"
    			stmt += WhileStatement()
    			#break
            when C_gotoSym
                stmt += GotoStatement()
            else 
                GenError(96) 
    	end
    # line 671 "cs.atg"
	    p "current symbol:#{@sym}, #{curString()}, #{@scanner.nextSym.line}"
	    pdebug("====>statement1:#{stmt}")
        return stmt
    end

    def GotoStatement()
        Expect(C_gotoSym)
        current_scope("FunctionDefinition").hasGoto = true
        ret = "goto :#{curString}"
        Expect(C_identifierSym)
        
        Expect(C_SemicolonSym)
        
        return ret
    
    end

    # line 679 "cs.atg"
    def AssignmentStatement()
        ret = ""
    # line 679 "cs.atg"
    	pdebug("===>AssignmentStatement:#{@sym}")
    # line 679 "cs.atg"
    	ret += CommaExpression()
    # line 679 "cs.atg"
    	Expect(C_SemicolonSym)
    # line 679 "cs.atg"
    	pdebug("===>AssignmentStatement1:#{ret}")
    	return ret
    end

    # line 681 "cs.atg"
    def BreakStatement()

    # line 681 "cs.atg"
    	Expect(C_breakSym)
    # line 682 "cs.atg"
	            
    # line 687 "cs.atg"
    	Expect(C_SemicolonSym)
    # line 687 "cs.atg"
    
        return "break"
    end

    # line 713 "cs.atg"
    def ContinueStatement()

    # line 713 "cs.atg"
    	Expect(C_continueSym)
    # line 714 "cs.atg"
	
    # line 721 "cs.atg"
    	Expect(C_SemicolonSym)
    # line 721 "cs.atg"
    
        return "next\n"
    end

    # line 724 "cs.atg"
    def DoStatement()
        in_scope("DoStatement")
	    
        ret = ""
    # line 724 "cs.atg"
    	Expect(C_doSym)
    # line 724 "cs.atg"
    	stmt = Statement()
    # line 724 "cs.atg"
    	Expect(C_whileSym)
    # line 724 "cs.atg"
    	Expect(C_LparenSym)
    # line 724 "cs.atg"
    	exp = Expression()
    # line 724 "cs.atg"
    	Expect(C_RparenSym)
    # line 724 "cs.atg"
    	Expect(C_SemicolonSym)
    # line 724 "cs.atg"
	    ret =<<HERE
begin
    #{stmt}
end while (#{exp})
HERE
	    out_scope()
	    return ret
    end

    # line 726 "cs.atg"
    def ForStatement()
        ret = ""
	    in_scope("ForStatement")
    # line 726 "cs.atg"
    	Expect(C_forSym)
    # line 726 "cs.atg"
    	Expect(C_LparenSym)
    	exp1 = ""
=begin
    # line 726 "cs.atg"
    	if (@sym >= C_identifierSym && @sym <= C_numberSym ||
    	    @sym >= C_stringD1Sym && @sym <= C_charD1Sym ||
    	    @sym == C_LbraceSym ||
    	    @sym == C_LparenSym ||
    	    @sym == C_StarSym ||
    	    @sym == C_AndSym ||
    	    @sym >= C_PlusSym && @sym <= C_MinusSym ||
    	    @sym >= C_PlusPlusSym && @sym <= C_MinusMinusSym ||
            # @sym >= C_newSym && @sym <= C_DollarSym ||
            @sym == C_newSym ||
    	    @sym >= C_BangSym && @sym <= C_TildeSym) 
    # line 726 "cs.atg"
            exp1 = Expression()
    	end
    # line 726 "cs.atg"
        Expect(C_SemicolonSym)
    # line 727 "cs.atg"
=end
      exp1= gStatement()
        p "exp1:#{exp1}, SYM:#{@sym}"	

	
    # line 738 "cs.atg"
	    exp2 = ""
    # line 739 "cs.atg"
    	if (@sym >= C_identifierSym && @sym <= C_hexnumberSym ||
    	    @sym >= C_stringD1Sym && @sym <= C_charD1Sym ||
    	    @sym == C_LbraceSym ||
    	    @sym == C_LparenSym ||
    	    @sym == C_StarSym ||
    	    @sym == C_AndSym ||
    	    @sym >= C_PlusSym && @sym <= C_MinusSym ||
    	    @sym >= C_PlusPlusSym && @sym <= C_MinusMinusSym ||
            # @sym >= C_newSym && @sym <= C_DollarSym ||
            @sym == C_newSym || @sym == C_deleteSym || @sym == C_throwSym || @sym == C_sizeofSym ||
    	    @sym >= C_BangSym && @sym <= C_TildeSym) 
    # line 739 "cs.atg"
    		
    		p "exp22:#{exp2}"
    		exp2 = CommaExpression()
    	end
    # line 740 "cs.atg"
	

   	
	p "exp2:#{exp2}"
    # line 746 "cs.atg"
    	Expect(C_SemicolonSym)
    # line 746 "cs.atg"
	        
    # line 747 "cs.atg"

	
	    exp3 = ""
    # line 754 "cs.atg"
    	if (@sym >= C_identifierSym && @sym <= C_hexnumberSym ||
    	    @sym >= C_stringD1Sym && @sym <= C_charD1Sym ||
    	    @sym == C_LbraceSym ||
    	    @sym == C_LparenSym ||
    	    @sym == C_StarSym ||
    	    @sym == C_AndSym ||
    	    @sym >= C_PlusSym && @sym <= C_MinusSym ||
    	    @sym >= C_PlusPlusSym && @sym <= C_MinusMinusSym ||
            # @sym >= C_newSym && @sym <= C_DollarSym ||
            @sym == C_newSym || @sym == C_deleteSym || @sym == C_throwSym || @sym == C_sizeofSym ||
    	    @sym >= C_BangSym && @sym <= C_TildeSym) 
    # line 755 "cs.atg"
		
    # line 758 "cs.atg"
    		exp3= CommaExpression()
    # line 759 "cs.atg"
		    p "exp3:#{exp3}"
    	end

    	stmt = ""
    # line 768 "cs.atg"
    	Expect(C_RparenSym)
    # line 768 "cs.atg"
    	stmt = Statement()
    # line 769 "cs.atg"
        p "for,#{exp1},#{stmt},#{exp2},#{exp3}"
	    ret =<<HERE
#{exp1}
while (#{exp2}) do
    #{stmt}
    
    #{exp3}
end 
HERE
        # ret = ret.gsub(/next|continue/m, exp2)
	    out_scope()
        return ret
    end

    # line 791 "cs.atg"
    def IfStatement()
        exp = ""
    # line 791 "cs.atg"
    	Expect(C_ifSym)
    # line 791 "cs.atg"
    	Expect(C_LparenSym)
    # line 791 "cs.atg"
    	exp = Expression()
    # line 791 "cs.atg"
    	Expect(C_RparenSym)
    # line 792 "cs.atg"
	
	    
	
	   stmt = ""
    # line 828 "cs.atg"
    	stmt =Statement()
	
	_else = ""
    # line 828 "cs.atg"
    # line 828 "cs.atg"
    	if (@sym == C_elseSym) 
    # line 830 "cs.atg"
    		Get()
    # line 831 "cs.atg"
		
		           
    # line 840 "cs.atg"
    		_else = Statement()
    # line 841 "cs.atg"
		
		          
    	end
    # line 848 "cs.atg"
	
       if _else != nil && _else != ""
	    ret =<<HERE1
if #{exp}
    #{stmt}
else
    #{_else}
end
HERE1
       else
        ret =<<HERE2
if #{exp}
    #{stmt}
end
HERE2
       end
        return ret
    end

    # line 858 "cs.atg"
    def NullStatement()

    # line 858 "cs.atg"
    	Expect(C_SemicolonSym)
    # line 858 "cs.atg"
	    return ""
    end

    # line 860 "cs.atg"
    def ReturnStatement()
        exp =""
    # line 860 "cs.atg"
    	Expect(C_returnSym)
    # line 860 "cs.atg"
    	if (@sym >= C_identifierSym && @sym <= C_hexnumberSym ||
    	    @sym >= C_stringD1Sym && @sym <= C_charD1Sym ||
    	    @sym == C_LbraceSym ||
    	    @sym == C_LparenSym ||
    	    @sym == C_StarSym ||
    	    @sym == C_AndSym ||
    	    @sym >= C_PlusSym && @sym <= C_MinusSym ||
    	    @sym >= C_PlusPlusSym && @sym <= C_MinusMinusSym ||
            # @sym >= C_newSym && @sym <= C_DollarSym ||
            @sym == C_newSym || @sym == C_deleteSym || @sym == C_throwSym || @sym == C_sizeofSym ||
    	    @sym >= C_BangSym && @sym <= C_TildeSym ||
            @sym == C_operatorSym) 
    # line 860 "cs.atg"
    		exp +=Expression()
    	end
    # line 861 "cs.atg"
	
    # line 864 "cs.atg"
    	Expect(C_SemicolonSym)
    # line 864 "cs.atg"
	    ret = "return #{exp}"
	    p "===>returnStetment:#{ret}"
	    return ret
    end

    # line 867 "cs.atg"
    def SwitchStatement()
        ret = ""
    # line 867 "cs.atg"
    	Expect(C_switchSym)
    # line 867 "cs.atg"
    	Expect(C_LparenSym)
    # line 869 "cs.atg"
    	exp = Expression()
    # line 872 "cs.atg"
    	Expect(C_RparenSym)
    # line 872 "cs.atg"
    in_scope("SwitchStatement")
    
    	stmt = Statement()
    	ret =<<HERE
case #{exp}\n
#{stmt}
end
HERE
    
    out_scope()
        return ret
    end

    # line 876 "cs.atg"
    def WhileStatement()
        ret = ""
    # line 876 "cs.atg"
    	Expect(C_whileSym)
    # line 876 "cs.atg"
    	Expect(C_LparenSym)
    # line 877 "cs.atg"
	
	 
    # line 886 "cs.atg"
	    exp = Expression()
    # line 887 "cs.atg"
	
    # line 922 "cs.atg"
    	Expect(C_RparenSym)
    	
    	in_scope("WhileStatement")

    # line 922 "cs.atg"
    	stmt = Statement()
    # line 924 "cs.atg"
	ret =<<HERE
while (#{exp})
    #{stmt}
end
HERE
	    out_scope()
	    return ret
    end

 
    # line 966 "cs.atg"
    def Expression
        ret = ""
    # line 966 "cs.atg"
    	pdebug("===>Expression:#{@sym}, #{curString()}")
    	

    	if @sym == C_LbraceSym  # {a, b, c}
    	    Get()
    	    Expression()
    	    while (@sym==C_CommaSym)
    	        Get()
    	        if @sym==C_RbraceSym
    	            break
	            end
    	        Expression()
	        end
    	    Expect(C_RbraceSym)
    	    ret += "\"\""
	    else
    	
        # line 966 "cs.atg"
        	c = Conditional()
        	ret += c
        	pdebug("===>Expression-1:#{ret},#{@sym}, #{curString()}")
    	
        # line 966 "cs.atg"
        	while (@sym == C_EqualSym ||
        	       @sym >= C_StarEqualSym && @sym <= C_GreaterGreaterEqualSym ||
        	       @sym == C_QuestionMarkSym
        	       ) 
        # line 966 "cs.atg"
                pdebug("===>Expression0:#{ret}")
                if @sym == C_QuestionMarkSym  # exp ? A:B
                    Get()
                    p("before questionmark:#{ret}")
                    ret += " ? #{Expression()}"
                    p("after questionmark1:#{ret}, #{@sym}, #{curString()}")
                    
                    Expect(C_ColonSym)
                    ret += " : #{Expression()}"
                else
	                
            		ret += AssignmentOperator()
            		pdebug("===>Expression00:#{ret}")
        	
            # line 966 "cs.atg"
            		ret += Expression()
            		pdebug("===>Expression000:#{ret}")
        	
            # line 967 "cs.atg"

                    # printf("===>AssignmentOperator\n")
                        # if (!doAssign()) 
                        #                       continue;
                end
                
        	end # while
    	end
    		pdebug("===>Expression002:#{ret}, #{@sym},#{curString()}, prev=#{@prev_sym}")
            
        # is type cast e.g. (exp1)exp2, then igore the exp in ()
    	if @sym!= C_EOF_Sym && @sym!= C_LbraceSym && @sym!= C_CommaSym && @sym!= C_RparenSym &&
             @sym!= C_SemicolonSym && @sym!=C_RbrackSym && @sym!=C_RbraceSym && @sym != C_ColonSym &&
             #@sym < C_numberSym && @sym > C_charD1Sym &&
    	     @prev_sym == C_RparenSym # (exp)exp
    	    # (exp)exp
    	    #      ^
            p "sym112:#{@sym}, #{curLine()}, #{curCol()}"
            # Get()
            #           Type()
            #           while (@sym == C_StarSym || @sym == C_AndSym) 
            #               Get()
            #           end
            # Expect(C_RparenSym)
            # Get()
    	    ret = Expression()
	    end
	    

    	pdebug("===>Expression1:#{ret}, sym=#{@sym}, v=#{curString()}")
    	return ret
    end
    
    def CommaExpression()
        ret = Expression()
        
	    while (@sym==C_CommaSym)
	        Get()
	        ret += ";"+Expression()
        end
        return ret
    end

    # line 964 "cs.atg"
    def ConstExpression()
    
    # line 964 "cs.atg"
    	Expression()
    end

    
    # line 2134 "cs.atg"
    def AssignmentOperator()
        ret= curString()
        # p "getname:#{@scanner.GetName}"
    # line 2134 "cs.atg"
    	case @sym 
    		when C_EqualSym  
    # line 2134 "cs.atg"
    			Get();
#break;
    		when C_StarEqualSym  
    # line 2134 "cs.atg"
    			Get();
#break;
    		when C_SlashEqualSym  
    # line 2134 "cs.atg"
    			Get();
#break;
    		when C_PercentEqualSym  
    # line 2134 "cs.atg"
    			Get();
#break;
    		when C_PlusEqualSym  
    # line 2134 "cs.atg"
    			Get();
#break;
    		when C_MinusEqualSym  
    # line 2134 "cs.atg"
    			Get();
#break;
    		when C_AndEqualSym  
    # line 2134 "cs.atg"
    			Get();
#break;
    		when C_UparrowEqualSym  
    # line 2135 "cs.atg"
    			Get();
#break;
    		when C_BarEqualSym  
    # line 2135 "cs.atg"
    			Get();
#break;
    		when C_LessLessEqualSym  
    # line 2135 "cs.atg"
    			Get();
#break;
    		when C_GreaterGreaterEqualSym  
    # line 2135 "cs.atg"
    			Get();
                # break;
    		#when C_LessLessSym  
    		#	Get();
            #    # break;                
    		#when C_GreaterGreaterSym  
    		#	Get();
            #    # break;                
                
    		else 
    		    GenError(97)
    	end
        # p "getname1:#{@scanner.GetName}"
        p "AssignmentOperator:#{ret}"
        return ret
    end
    
    def Conditional()
    	pdebug("===>Conditional:#{@sym}")
    
    # line 975 "cs.atg"
    	ret = LogORExp()
    	pdebug("===>Conditional1:#{ret}")
    	return ret
    end
    def LogORExp()
        ret = ""
    	pdebug("===>LogORExp")
    
    # line 977 "cs.atg"
    	ret += LogANDExp()
    # line 977 "cs.atg"
    # line 977 "cs.atg"
    	while (@sym == C_BarBarSym) 
    # line 977 "cs.atg"
    		ret += curString()
        	
    		Get()
    # line 979 "cs.atg"

    # line 982 "cs.atg"
    		ret += LogANDExp()
    # line 983 "cs.atg"

    		             
    # line 1011 "cs.atg"

	      end
	      
	      return ret
	      pdebug("===>LogORExp1:#{ret}")
      	
    end
    def LogANDExp()
        ret = ""
    	pdebug("===>LogANDExp")
    
    # line 1037 "cs.atg"

    # line 1044 "cs.atg"
    	ret += InclORExp()
    	
    	
    # line 1044 "cs.atg"
    	while (@sym == C_AndAndSym)
    # line 1044 "cs.atg"
    		ret += curString()
        	
    		Get()
    # line 1046 "cs.atg"
    # line 1048 "cs.atg"
    		ret += InclORExp()
    # line 1050 "cs.atg"

    		             
	    end
    # line 1075 "cs.atg"
    pdebug("===>LogANDExp1:#{ret}")
	
        return  ret
    end
    def InclORExp()
        ret = ""
    	pdebug("===>InclORExp")

    # line 1099 "cs.atg"
    	ret += ExclORExp()
    	
    # line 1099 "cs.atg"
    	while (@sym == C_BarSym) 
    # line 1099 "cs.atg"
    		ret += curString()
        	
    		Get()
    # line 1099 "cs.atg"
    		ret += ExclORExp()
    	end
    	pdebug("===>InclORExp1:#{ret}")
    	
    	return ret 
    end

    # line 1101 "cs.atg"
    def ExclORExp()
        ret =""
    	pdebug("===>ExclORExp")
    
    # line 1101 "cs.atg"
    	ret += ANDExp()
    	
    # line 1101 "cs.atg"
    	while (@sym == C_UparrowSym) 
    # line 1101 "cs.atg"
    		ret += curString()
        	
    		Get()
    # line 1101 "cs.atg"
    		ret += ANDExp()
    	end
    	    	pdebug("===>ExclORExp1:#{ret}")
    	return ret
    end

    # line 1103 "cs.atg"
    def ANDExp()
        ret = ""
    	pdebug("===>ANDExp")

    # line 1103 "cs.atg"
    	ret = EqualExp()
    	pdebug("===>ANDExp2:#{ret}")
    	
    # line 1103 "cs.atg"
    	while (@sym == C_AndSym) 
    # line 1103 "cs.atg"
            
            ret += curString()
        	
    		Get()
    # line 1103 "cs.atg"
    		ret += EqualExp()
    	end
    	pdebug("===>ANDExp1:#{ret}")
    	
    	return ret
    end

    # line 1105 "cs.atg"
    def EqualExp()
        ret = ""
    	pdebug("===>EqualExp:#{@sym}")

    # line 1106 "cs.atg"

    	   
    # line 1114 "cs.atg"
    	ret += RelationExp()
    	
        # ret += curString()
    	
    # line 1114 "cs.atg"
    	while (@sym >= C_EqualEqualSym && @sym <= C_BangEqualSym) 
    # line 1116 "cs.atg"
    		if (@sym == C_EqualEqualSym) 
    # line 1114 "cs.atg"
    			ret += curString()
            	Get()
    # line 1115 "cs.atg"
    		elsif (@sym == C_BangEqualSym) 
    # line 1116 "cs.atg"
    			ret += curString()
            	Get()
    # line 1117 "cs.atg"


    		else 
    		    GenError(101)
		    end
    # line 1120 "cs.atg"
    		ret += RelationExp()
    # line 1122 "cs.atg"
        end
    		     pdebug("===>EqualExp1:#{ret}")
             	
    	
    # line 1157 "cs.atg"
        return ret
  
    end
    

    # line 1182 "cs.atg"
    def RelationExp()
    	pdebug("===>RelationExp")
        ret = ""
    # line 1183 "cs.atg"

    
        
    # line 1190 "cs.atg"
    	ret += ShiftExp()
    	pdebug("===>RelationExp1:#{ret}")
        
    # line 1190 "cs.atg"
    	while (@sym == C_LessSym ||
    	       @sym >= C_GreaterSym && @sym <= C_GreaterEqualSym) 
    # line 1190 "cs.atg"
    		ret += curString()
            	pdebug("===>RelationExp2:#{ret}")
    		case (@sym) 
    			when C_LessSym
    # line 1190 "cs.atg"
    				Get()
    # line 1190 "cs.atg"
    			#	break;
    			when C_GreaterSym  
    # line 1190 "cs.atg"
    				Get()
    # line 1190 "cs.atg"
    				#break;
    			when C_LessEqualSym  
    # line 1190 "cs.atg"
    				Get()
    # line 1190 "cs.atg"
    			#	break;
    			when C_GreaterEqualSym  
    # line 1190 "cs.atg"
    				Get()
    # line 1190 "cs.atg"
    				#break;
    			else 
    			    GenError(102)
			    
    			# break
    		end
        	pdebug("===>RelationExp3:#{ret}")
            
    		ret += ShiftExp()
    		
		end
    # line 1191 "cs.atg"
    # line 1193 "cs.atg"

    # line 1222 "cs.atg"

    	pdebug("<===>RelationExp:#{ret}")
    	return ret
    end

    # line 1248 "cs.atg"
    def ShiftExp()
        ret = ""
        pdebug("===>ShiftExp:#{@sym}, #{curString()}")
    	ret += AddExp()
        pdebug("===>ShiftExp01:#{ret}")
        
        # ret += curString()
    # line 1248 "cs.atg"
    # line 1248 "cs.atg"
    	while (@sym >= C_LessLessSym && @sym <= C_GreaterGreaterSym) 
    # line 1248 "cs.atg"
    		if (@sym == C_LessLessSym) 
    # line 1248 "cs.atg"
    			ret += curString()
                Get()
    		 elsif (@sym == C_GreaterGreaterSym) 
    # line 1248 "cs.atg"
    			ret += curString()
            	Get()
    		 else 
    		     GenError(103)
		    end
        	ret += AddExp()
            
    # line 1248 "cs.atg"
	    end
	    pdebug("===>ShiftExp1: #{ret}")
        return ret
    end
    
    def AddExp()
    ret = ""
    # line 1250 "cs.atg"
    # line 1251 "cs.atg"
    	ret += MultExp()
        # ret += curString()
    	
    # line 1251 "cs.atg"
    	while (@sym >= C_PlusSym && @sym <= C_MinusSym) 
    # line 1251 "cs.atg"
    		ret += curString()
			if (@sym == C_PlusSym) 
    # line 1251 "cs.atg"
    			Get()
    # line 1251 "cs.atg"
    		 elsif (@sym == C_MinusSym) 
    # line 1251 "cs.atg"
    			Get()
    # line 1251 "cs.atg"
    		 else 
    		     GenError(104)
		     end
    # line 1251 "cs.atg"
    		ret += MultExp()
    # line 1253 "cs.atg"

    		             
	    end
	    
	    return ret
    end
    # line 1337 "cs.atg"
    def MultExp()
        pdebug "===>MultExp:#{@sym}, #{curString}"
        
        ret = ""
    # line 1337 "cs.atg"
    # line 1338 "cs.atg"
    	ret += CastExp()
    # line 1339 "cs.atg"
    # ret += curString()
    p "===>MultExp2:#{@sym}, #{curString}, #{ret}", 30
    
    # line 1342 "cs.atg"
    	while (@sym == C_SlashSym ||
    	       @sym == C_StarSym ||
    	       @sym == C_PercentSym) 
    # line 1342 "cs.atg"
    		if (@sym == C_StarSym) 
    # line 1342 "cs.atg"
    			ret += curString()
    			Get()
    # line 1342 "cs.atg"
    		elsif (@sym == C_SlashSym) 
    # line 1342 "cs.atg"
    			ret += curString()
    			Get()
    # line 1342 "cs.atg"
    		elsif (@sym == C_PercentSym) 
    # line 1342 "cs.atg"
    			ret += curString()
    			Get()
    # line 1342 "cs.atg"
    		 else 
    		     GenError(105)
		     end
		
		     p "===>MultExp3:#{@sym}, #{curString}"
             
    # line 1342 "cs.atg"
    		ret += CastExp()
    # line 1343 "cs.atg"

    		 
	    end
	    
	    pdebug "==>MultExp:#{ret}"
	    return ret
    end
    
    # line 1396 "cs.atg"
    def CastExp()
    
    # line 1396 "cs.atg"
    	pdebug("===>CastExp")
    # line 1397 "cs.atg"

    # line 1405 "cs.atg"
        ret =	UnaryExp()
    # line 1407 "cs.atg"
       pdebug "<===CastExp:#{ret}"
	   return ret
    end
=begin    
    # line 1538 "cs.atg"
    def UnaryExp()
        ret = ""
    # line 1538 "cs.atg"
    	pdebug("===>UnaryExp1")
    	
    # line 1539 "cs.atg"
    	if (@sym >= C_identifierSym && @sym <= C_numberSym ||
    	    @sym >= C_stringD1Sym && @sym <= C_charD1Sym ||
    	    @sym == C_LbraceSym ||
    	    @sym == C_LparenSym ||
            # @sym >= newSym && @sym <= DollarSym) 
            @sym == newSym) 
    # line 1538 "cs.atg"
    		ret += PostFixExp()
    	elsif (@sym >= C_PlusPlusSym && @sym <= C_MinusMinusSym) 
    # line 1539 "cs.atg"
    	    if (@sym == C_PlusPlusSym) 
    # line 1539 "cs.atg"
    			ret += curString()
            	
    			Get()
    	    elsif (@sym == C_MinusMinusSym) 
    # line 1539 "cs.atg"
    		ret += curString()
        	
    			Get()
    	    else 
    	        GenError(106)
    	    end
    # line 1539 "cs.atg"
    		ret += UnaryExp()
		
    	elsif (@sym == C_StarSym ||
    	           @sym == C_AndSym ||
    	           @sym >= C_PlusSym && @sym <= C_MinusSym ||
    	           @sym >= C_BangSym && @sym <= C_TildeSym) 
    # line 1540 "cs.atg"
    		ret += UnaryOperator()
    # line 1540 "cs.atg"
    		ret += CastExp()
    	 else 
    	    GenError(107)
	    end
	    p "<===UnaryExp1=#{ret}"
	    return ret
    end
=end    
    # line 1572 "cs.atg"
    def PostFixExp()
        ret = ""
        pdebug "====>PostFixExp:#{@sym}, #{curString()}"
    # line 1572 "cs.atg"
    # line 1573 "cs.atg"
    	ret += Primary()
        
        # ret += curString()
         p "====>PostFixExp1:@sym:#{@sym}, #{curString()}, ret=#{ret}"
    # line 1574 "cs.atg"
    	while (@sym == C_LbrackSym ||
    	       @sym == C_LparenSym ||
    	       @sym >= C_PlusPlusSym && @sym <= C_MinusGreaterSym) 
    # line 1646 "cs.atg"
    		case (@sym) 
    			when C_LbrackSym  
    # line 1574 "cs.atg"
    				ret += curString()
        			Get()
    # line 1574 "cs.atg"
    				ret += Expression()
    # line 1574 "cs.atg"
    				ret += curString()
    				Expect(C_RbrackSym)
    			
    # line 1575 "cs.atg"

    			
    			when C_LparenSym  
    # line 1647 "cs.atg"

    
    				    
    # line 1733 "cs.atg"
                    # in c/c++, class member variable and member method cannot have same name, so we don't need to 
                    # check @ here
                    # ret += FunctionCall(&fn)
                    p ("-->237:#{ret}")
                    
                    # in ruby A::B::c() should be A::B.c(), no matter c is static method or not
                    index_collon = ret.rindex("::")
                    index_dot = ret.rindex(".")
                    if index_collon && index_collon > 0 && !index_dot
                        p ("-->236:#{ret}, #{index_collon}, #{index_dot}, #{ret[0..index_collon-1]}")
                        
                        ret = ret[0..index_collon-1]+"."+ret[index_collon+2..ret.size-1]
                    end
                   
                    
                    s,n = FunctionCall(ret)
                    # check if going to call a variable, which is typed as FunctionPointer
                    
                    if !@in_preprocessing

                        method =ret
                        v = find_var(method)
                        p "find_var111:#{method}:#{v}"
                        if v
                            if v.type.type == "FunctionPointer"
                                ret = "method(#{method}).call"
                            end
                        end 
                     end
                    ret += s
                    
                    
                    p ("-->235:#{s}")
    # line 1734 "cs.atg"
    				
    			when C_PointSym  
    # line 1736 "cs.atg"
    # ret += curString()

    # line 1742 "cs.atg"
    				Get()
    # line 1742 "cs.atg"

    # line 1779 "cs.atg"
    				if (@sym == C_identifierSym) 
    				    p "get identifier"
    # line 1759 "cs.atg"
    					ret += ".#{curString}"
    					Get()
    # line 1760 "cs.atg"

    				elsif (@sym == C_LbraceSym) 
    # line 1779 "cs.atg"
    					ret += curString()
            			Get()
    # line 1779 "cs.atg"
    					ret += Expression()
    # line 1780 "cs.atg"

    					      
    # line 1807 "cs.atg"
    					Expect(C_RbraceSym)
    				else 
    				    GenError(108)
				    end
    # line 1826 "cs.atg"

    		

    		
    # line 1869 "cs.atg"
    				while (@sym == C_LparenSym) 
    # line 1870 "cs.atg"


    			

    # line 1894 "cs.atg"
                        # ret += FunctionCall(&fn)
                 
                          s,n =FunctionCall(ret)
                          if !@in_preprocessing
                              r = find_function(method_signature(ret,n))
                              if r[:v]
                                  ret = r[:prefix]+"::"+ret
                              end
                                p("111->#{ret}")
                       
                                method =ret
                                v = find_var(method)
                                p "find_var111:#{method}:#{v}"
                                if v
                                    if v.type.type == "FunctionPointer"
                                        ret = "method(#{method}).call"
                                    end
                                end 
                          end
                          ret += s
                        
    				end
    # line 1896 "cs.atg"

    				

    			
    			when C_MinusGreaterSym  
    # line 1937 "cs.atg"
    				ret += "."
    # line 1937 "cs.atg"
    			
        			Get()
    # line 1937 "cs.atg"
                	
    if @sym == C_operatorSym # call operator directly, e.g. a->operator=(*z);
	    Get()
	    ret += "#{curString}"
	    Get()
    else
    				while (@sym == C_LbraceSym) 
    # line 1937 "cs.atg"
    					ret += curString()
            			Get()
    # line 1937 "cs.atg"
    					
				    end
    # line 1937 "cs.atg"
    				ret += curString()
    				Expect(C_identifierSym)
    # line 1937 "cs.atg"
    				while (@sym == C_RbraceSym) 
    # line 1937 "cs.atg"
    					ret += curString()
            			Get()
    # line 1937 "cs.atg"
    				end
    # line 1938 "cs.atg"
    end
    			when C_PlusPlusSym  
    # line 2025 "cs.atg"
                    # ret += "+=1"
                    ret = "(#{ret}+=1;#{ret}-2)"
        			Get()
    # line 2027 "cs.atg"

    				              
                    # break;
    			when C_MinusMinusSym  
    # line 2079 "cs.atg"
                    # ret += "-=1"
    				ret = "(#{ret}-=1;#{ret}+2)"
        			Get()
    # line 2081 "cs.atg"

    				                      
                    # break;
    			else 
    			    GenError(109)
    		end # case
    	end # while
    	pdebug "<===PostFixExp0:#{ret}"
    	return ret
    end
    # line 1538 "cs.atg"
    def UnaryExp()
        ret = ""
    # line 1538 "cs.atg"
    	pdebug("===>UnaryExp:#{@sym}, #{curString()}")
        # pp "unaryexp", 20
    # line 1539 "cs.atg"
        #         _next = GetNext()
        #         if @sym == C_LparenSym && (_next ==C_identifierSym ||  _next >=C_shortSym && _next <=C_stringSym)
        #            # type cast
        #            Get()
        #            Type()
        #            Expect(C_RparenSym)
        #            CastExp()
        # els
    	cs = curString()
    	if @sym >= C_identifierSym && (cs == 'static_cast' || cs == 'dynamic_cast')
    	    Get()
    	    Expect(C_LessSym)
    	    Type()
  	    	while (@sym == C_StarSym || @sym == C_AndSym) 
        		Get()
        	end
        	Expect(C_GreaterSym)
        	Expect(C_LparenSym)
        	ret += Expression()
        	Expect(C_RparenSym)
        	
    	elsif (@sym >= C_identifierSym && @sym <= C_hexnumberSym ||
    	    @sym >= C_stringD1Sym && @sym <= C_charD1Sym ||
    	    @sym == C_LbraceSym ||
    	    @sym == C_LparenSym ||
            # @sym >= newSym && @sym <= C_DollarSym) 
            @sym == C_newSym || @sym == C_deleteSym || @sym == C_throwSym || @sym == C_sizeofSym || @sym == C_ColonColonSym ||
            @sym == C_defaultSym || @sym == C_operatorSym) 
            
    # line 1538 "cs.atg"
    		ret += PostFixExp()
    	elsif (@sym >= C_PlusPlusSym && @sym <= C_MinusMinusSym) 
    # line 1539 "cs.atg"
    		if (@sym == C_PlusPlusSym) 
    # line 1539 "cs.atg"
    			ret += "+=1"
            	Get() 
    		elsif (@sym == C_MinusMinusSym) 
    # line 1539 "cs.atg"
    			ret += "-=1"
            	Get();
    		else 
    		    GenError(106)
		    end
    # line 1539 "cs.atg"
    		ue = UnaryExp()
    		ret = "(#{ue}#{ret})"
    	elsif (@sym == C_StarSym ||
    	           @sym == C_AndSym ||
    	           @sym >= C_PlusSym && @sym <= C_MinusSym ||
    	           @sym >= C_BangSym && @sym <= C_TildeSym) 
    # line 1540 "cs.atg"
    		if @sym != C_StarSym &&
        	           @sym != C_AndSym
        	    # except case *var and &var
        	    _uo = UnaryOperator()
                ret += _uo
    		    # p "<=====UnaryExp2:#{_uo}"
                
		    else
		        UnaryOperator()
		    end
		    p "<=====UnaryExp3:#{ret}"
    # line 1540 "cs.atg"
    		ret += CastExp()
    	else 
            # pp("dff", 100)
            # GenError(107)
            
	    end
	    pdebug "<=====UnaryExp1:#{ret}"
	    return ret
    end
    
    # line 2791 "cs.atg"
    def UnaryOperator()
        ret = ""
        ret += curString() if @sym != C_AndSym && @sym != C_StarSym
    # line 2791 "cs.atg"
    	case (@sym) 
    		when C_PlusSym  
    # line 2791 "cs.atg"
    			Get();
                # break;
    		when C_MinusSym  
    # line 2791 "cs.atg"
                Get();
                # break;
    		when C_StarSym  
    # line 2791 "cs.atg"
    			Get();
                # break;
    		when C_BangSym 
    # line 2791 "cs.atg"
    			Get();
                # break;
    		when C_AndSym  
    # line 2791 "cs.atg"
    			Get();
                # break;
    		when C_TildeSym  
    # line 2791 "cs.atg"
    			Get();
                # break;
    		else 
    		    GenError(110)
    	end
    	
    	return ret
    end
       
     

    # line 2327 "cs.atg"
    def Primary()
        pdebug "=====>Primary:#{@sym}, #{curString()}"
        ret = ""
    # line 2328 "cs.atg"
    prefix = ""
    if @sym == C_ColonColonSym
        Get()
        #ret += "::"
        prefix = "::"
    end
    # line 2475 "cs.atg"
        isExpression = false
        primary_sym = @sym
    	case @sym
    		when C_identifierSym  
                # varname = translate_varname()},
                varname = prefix+curString()
                
		  

                	Get()
        # line 2334 "cs.atg"
        isOperator = false
                    if @sym == C_ColonColonSym
                        if !@in_preprocessing
                            r = find_class(varname)
                            if !r[:v]
                               # dump_pos(@scanner.nextSym.pos)
                                p "cannot find class #{varname}"
                            else
                                cls = r[:v]
                            end
                        
                            if r[:prefix] != ""
                                varname = "#{r[:prefix]}::#{varname}"
                            end
                       end     
                           # ret += translate_varname(varname)
                           ret += varname
                       
                           #ar = []
                           #ar.push(varname)
                       
                        while (@sym == C_ColonColonSym)
                            
                            # line 2353 "cs.atg"
                            	Get();
                            # line 2353 "cs.atg"
                    p "====>233:#{curString()}, #{ret}"
                            #ret += "::#{translate_varname(curString())}"
                            if @sym == C_operatorSym
                                Get()
                                ret += "#{curString}"
                                p "====>234:#{curString()}, #{ret}"
                                isOperator = true
                            else
                                if cls && cls.functions[curString()]
                                    ret += ".#{curString}"
                                else
                                    ret += "::#{curString}"
                                end

                            end
                           
                           #ar.push(curString())
                            #Expect(C_identifierSym)
                            Get()
                            if @sym == C_LessSym
                                filterTemplate()
                            end

                    	end # while
                        #ret += ar[0..ar.size-2].join("::")
                        #ret += "::" + translate_varname(ar[ar.size-1])
                        
                	else
                	    if varname == "this"
                	        ret += "self"
            	        else
                            if !@in_preprocessing
                                 # p "====>2330:#{current_scope.inspect}"
                        	    cs = current_scope("FunctionDefinition")
            			        if cs && find_var(varname, cs)
            			             p "====>2331:"
            			            ret += find_var(varname, cs).newname
            		            else
=begin			            
        		                ccs =  current_class_scope
        		                 p "====>2332:#{ccs}"
		                
                    			if ccs && find_var(varname, ccs)
                                    # ret += "@#{varname}"
                                    # ccs.vars.each{|k,v|
                                    #                            p "==>var:#{v.inspect}"
                                    #                        }
                                    ret += "@#{find_var(varname, ccs).newname}"
                			    else
                			        # when var is not found, keep it's original name
                			        # Note that const like enum will not be added as var
                			         ret += translate_varname(varname, false)
        			         
                			    end
=end		                
                                    ret += translate_varname(varname, false)

            	                end
                            else
                                ret += varname
                            end
                        end
    		    	
        		    end # if @sym == C_ColonColonSym
                 p "====>primary3:#{@sym}, #{curString()}"
                
                    if @sym == C_LessSym
                        filterTemplate()
                    end
                    p "====>primary4:#{@sym}, #{curString()}"
                    
                    if !@in_preprocessing
                        if @sym != C_LparenSym && # not functioncall
                            !isOperator && !ret.index("::")  && !ret.index(".")
                            if (find_method(ret))
                                ret = ":#{ret}"
                            end
                        end
                    end
                    p "====>primary4:#{ret}"
                    
                #dump_pos()
    # line 2335 "cs.atg"

=begin    	
    # line 2339 "cs.atg"
    			while (@sym >= C_ColonColonSym && @sym <= C_HashHashSym) 
    # line 2353 "cs.atg"
    				if (@sym == C_HashHashSym) 
    				    ret += curString()
                    	
    # line 2339 "cs.atg"
    					Get();
    # line 2339 "cs.atg"
    					Expect(C_identifierSym);
    # line 2340 "cs.atg"
    				elsif (@sym == C_ColonColonSym) 
    				    ret += curString()
                    	
    # line 2353 "cs.atg"
    					Get();
    # line 2353 "cs.atg"
    					Expect(C_identifierSym);
    # line 2354 "cs.atg"
    					       
    				else 
    				    GenError(111)
				    end
    			end # while
    # line 2370 "cs.atg"
=end
    
            when C_sizeofSym
                p("-->primary2:sizeof")
                 Get()
                 Expect(C_LparenSym)
                 if (@sym >=C_boolSym && @sym <= C_voidSym)
                     t = Type().name
                 else
                     t = Expression()
                 end
                 
                 Expect(C_RparenSym)
                 ret += "c_sizeof(#{t})"
            when C_deleteSym
	    	    Get()
			    if @sym == C_LbrackSym # delete [] A
			        Get()
			        Expect(C_RbrackSym)
		        end
		        e =  Expression()
		        ret += "#{e}.__delete"
            when C_throwSym
    	        Get()
                e =  Expression()
		        ret += "throw #{e}"

    		when C_newSym  
    		    p "--->new:#{curString()}"
                # ret += curString()
            	
    # line 2475 "cs.atg"
    			Get()
    # line 2475 "cs.atg"
            if (@sym == C_identifierSym)
                ret += Creator()
            else
                t = Type().name

                # ignore & *
            	while (@sym == C_StarSym || @sym == C_AndSym) 
            		Get()
            	end
                p("new type:#{t}, #{@sym}, #{curString()}")
                if @sym == C_LbrackSym
                    filterSymBefore([C_SemicolonSym])
                    ret += "[]"
                else
                end
            end
                # break;
            # when C_DollarSym  
    # line 2477 "cs.atg"
                # Get();
    # line 2478 "cs.atg"
    			
    		when C_stringD1Sym  
    		    ret += curString()
    # line 2512 "cs.atg"
    			Get();
    # line 2513 "cs.atg"

    		
    		when C_charD1Sym  
    		    ret += curString()
            	
    # line 2563 "cs.atg"
    			Get();
    # line 2564 "cs.atg"

    			        
    		when C_numberSym  
    		    ret += curString()
            	
    # line 2572 "cs.atg"
    			Get();
    # line 2573 "cs.atg"

		when C_hexnumberSym  
		    ret += curString()
        	
			Get();

    		when C_LparenSym  
    		    # ret += curString()
            	
    # line 2593 "cs.atg"
    			Get()
    # line 2593 "cs.atg"
    p "sym555:#{@sym}, val #{curString()}"
    
                if (@sym == C_identifierSym && isTypeStart()) || 
                    @sym == C_constSym || 
                    @sym >= C_boolSym && @sym <= C_voidSym
                    # type cast (A*)
                    if @sym == C_constSym
                        Get()
                    end
                    _next = GetNext()
                    _next2 = GetNext(2)
                    p "--->sym5551_next:#{_next}, _next2:#{_next2}"
                    if (_next == C_RparenSym &&  _next2 != C_QuestionMarkSym) || # not the case: a()?f1:f2
                        ( ( _next == C_StarSym || _next == C_AndSym ) && (_next2 < C_identifierSym || _next2 > C_charD1Sym) ) ||
                        ( @sym >= C_boolSym && @sym <= C_doubleSym && _next >= C_boolSym && _next <= C_doubleSym)
                        vt = FullType()
                        p "vt:#{vt.inspect}"
                        Expect(C_RparenSym)
                        if @sym != C_LbraceSym # in case fn() throw (exp){...}
                            ret += Expression()
                        end
                        bT = true
                    end
                end
                if !bT  # ( Expression )
    		    	exp =Expression()
        			   p "sym556:#{@sym}, val #{curString()}"
        # line 2593 "cs.atg"
        			Expect(C_RparenSym)
        			ret += "(#{exp})"
                    isExpression= true
    			end
                # break;
    		when C_LbraceSym  
    # line 2594 "cs.atg"
                # SetDef();
                # break;
    		when C_QuestionMarkSym
    		    ret += " ? #{Expression} : #{Expression}"
            when C_defaultSym
                ret += "default"
                Get()
            when C_operatorSym
                Get()
                ret += operatorName()
    		else 
    		    GenError(112)
    	end # case
    	
        if primary_sym != C_sizeofSym && !isExpression 
    	    if /\(\s*[\w\d_]+\s*\)/ =~ ret
                # (abc) => abc
                #p ("remove () for #{ret}"), 30

    	        ret = ret.gsub(/\(\s*([\w\d_]+)\s*\)/, '\1')
	        end
        end
    	pdebug "=====>Primary1:#{ret}"
        
        return ret
    end
    
    def find_method(method, arg_num=nil)
        p "find_method1:#{method}, #{arg_num}"
        ar = method.split(".")
        
        if (ar.size >1)
         
            clsdef = find_class(ar[0])[:v]
        else
            clsdef = @root_class
        end
        clsdef = @root_class if !clsdef
        fname = ar[ar.size-1]
        p "find_method3:#{clsdef.class_name}, #{clsdef.functions.inspect}"
        
        if (arg_num)
            ret =  clsdef.methods[method_signature(fname, arg_num)]
        else
            ret =  clsdef.functions[fname]
            
        end
       # p "find_method2:#{method_signature(fname, arg_num)}=>#{clsdef.class_name}, #{ret}"
   #     p clsdef.methods.inspect
        return ret
    end
    # line 2597 "cs.atg"
    def FunctionCall(method)
        pp "functioncall()",20
        ret  =""
        args = []
    # line 2597 "cs.atg"
    	Expect(C_LparenSym);
    # line 2598 "cs.atg"

    	     pdebug("=====>FunctionCall");
    	  
    # line 2605 "cs.atg"
    	if (@sym >= C_identifierSym && @sym  <= C_hexnumberSym ||
    	    @sym >= C_stringD1Sym && @sym  <= C_charD1Sym ||
    	    @sym == C_LbraceSym ||
    	    @sym == C_LparenSym ||
    	    @sym == C_StarSym ||
    	    @sym == C_AndSym ||
    	    @sym >= C_PlusSym && @sym  <= C_MinusSym ||
    	    @sym >= C_PlusPlusSym && @sym  <= C_MinusMinusSym ||
    	    @sym >= C_newSym && @sym  <= C_DollarSym ||
    	    @sym >= C_BangSym && @sym  <= C_TildeSym ) 
    # line 2605 "cs.atg"
            s,args = ActualParameters()
    		ret += s
    	end
    # line 2605 "cs.atg"
    	Expect(C_RparenSym);
    # line 2606 "cs.atg"
        
    # check if this function name is var (passed in as parameter of current function definition)

        # check if one parameter is function pointer
        #method_desc = find_method(method, args.size)
        #if method_desc && method_desc[:args] 
        #    for i in 0..args.size-1
        #        if method_desc[:args][i][:type] == "FunctionPointer"
        #            args[i]= "method(:#{args[i]})"
        #        end
        #    end
        #end
        ret = args.join(",") if args && args.size >0
        ret = "(#{ret})"
        
        ## check if going to call a variable, which is typed as FunctionPointer
        #v = find_var(method)
        #p "find_var111:#{method}:#{v}"
        #if v
        #    if v.type.type == "FunctionPointer"
        #        ret = ".call#{ret}"
        #    end
        #end
        
        
        p "====>FunctionCall1:(#{ret})", 20
        return [ret, args.size]
    end

    # line 2660 "cs.atg"
    def ActualParameters()
        debug "==>ActualParameters:#{@sym}, line #{curLine}, val #{curString()}"
        ret = ""
        args=[]
    # line 2661 "cs.atg"

    	

    # line 2668 "cs.atg"
        r = Expression()
        args.push(r)
    	ret += r
        
    # line 2669 "cs.atg"
       
    	p "ret:#{ret}"
    # line 2701 "cs.atg"
    	while (@sym  == C_CommaSym) 
    # line 2701 "cs.atg"
    		ret += ","
    		
    		Get()
    # line 2701 "cs.atg"
            r = Expression()
            args.push(r)
            ret += r
    
    # line 2703 "cs.atg"

	    end
	    debug "==>ActualParameters1:#{@sym}, line #{curLine}, val #{curString()}, ret=#{ret}"
    # line 2776 "cs.atg"
        return [ret, args]
    end
    def Creator()
        ret = ""
    # line 2244 "cs.atg"
    # line 2245 "cs.atg"
    	className = ClassFullName()
    # line 2246 "cs.atg"

    if !@in_preprocessing

        r = find_class(className)
        if !r[:v]
            #dump_pos(@scanner.nextSym.pos)
            #throw "cannot find class #{className}"
            p "cannot find class #{className}"
        end
        if r[:prefix] != ""
            className = "#{r[:prefix]}::#{className}"
        end
    end
    # line 2287 "cs.atg"
        fCall = ""
    	  
    # line 2302 "cs.atg"
    	while (@sym == C_LparenSym) 
    # line 2302 "cs.atg"
    s,n = FunctionCall("#{className}.initilize")
    		fCall += s
    	end
    # line 2303 "cs.atg"
        
        ret = "#{className}.new#{fCall}"
        p "===>Creator1:#{ret}"
        return ret
    end

    # line 2321 "cs.atg"
    def ClassFullName()
        ret = ""
        
        ret += curString()
    # line 2322 "cs.atg"
    	Expect(C_identifierSym)
        # p "id=#{curString()}"
    # line 2322 "cs.atg"
    # line 2323 "cs.atg"
    	while (@sym == C_ColonColonSym) 
    # line 2323 "cs.atg"
    		ret += curString()    		
    		Get()
    # line 2323 "cs.atg"
    # line 2324 "cs.atg"
    		ret += curString()    		
    		Expect(C_identifierSym)
            # p "id2=#{curString()}"
    # line 2324 "cs.atg"
    	end
    	if @sym == C_LessSym
            filterTemplate()
        end
    	p "==>ClassFullName1:#{ret}"
        return ret
    end
end  # class Parser


load 'cptest.rb'