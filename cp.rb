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

$g_classdefs = {} if $g_classdefs == nil
if $ar_classdefs
    $ar_classdefs.each{|cls|
        add_class(cls)
    }
    p "===>$ar_classdefs:#{$ar_classdefs.inspect}"
end

def dump_classes_as_ruby(classdefs)
       
        classdefs.each{|k,v|
            p "class #{k}:"
            p "       class name: #{v.class_name}"
            p "       parent: #{v.parent}"
            p "       modules: #{v.modules}"
            p "       methods: #{v.methods.size}"
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
            if class_name == "::"
                    class_name ="_global_"
                    class_template = <<HERE
                    #{s_methods}
                    #{v.src}
HERE
            else
                if v.parent
                    class_template =<<HERE
            class #{class_name} < #{v.parent}
            #{s_methods}
            end
HERE
                else
                    class_template =<<HERE
            class #{class_name}
            #{s_methods}
            end
HERE
                end
            end
            
            if $output_dir && $output_dir != ""
                wfname = "#{$output_dir}/#{class_name.downcase}.rb"
            else
                wfname = "#{class_name.downcase}.rb"
            end
            write_class(wfname, class_template)
            
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
    def find_class(varname)
        p("@classdefs:#{@classdefs.inspect}")
        @classdefs.each{|k,v|
                 p "find_class #{k}=#{v}"
        }
         if @classdefs[varname]
             return @classdefs[varname]
         end
         return nil
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
        end while (@sym > C_MAXT || ignoreSym?(@sym))
        # p "get()2: #{@sym}"
        # p "Get()2 #{@scanner.nextSym.sym}, line #{@scanner.nextSym.line}, col #{@scanner.nextSym.col}, value #{curString()}"
        # p("Get()3:#{@sym}, #{curString()}, line #{curLine}", 20)
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
        pos1,pos2 = @scanner.delete_lines(p1, p2, inclue)
        # p "after delete_lines:#{pos1}, #{pos2}, pos #{pos}, buffer:#{@scanner.buffer}", 10
        # Get() if pos != @scanner.buffPos
        Get() if pos >pos1 && pos <= pos2
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
    	in_scope("::")
    	
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
    	       @sym >= C_staticSym && @sym <= C_stringSym ||
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
               @sym == C_deleteSym || @sym == C_throwSym || @sym == C_sizeofSym 
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
        
    	Expect(C_identifierSym) # parent class name
    	parent_class_name = prevString()
    	p "parent class name = #{parent_class_name}"
    	clsdef.parent=parent_class_name
    # line 247 "cs.atg"
        
        while (@sym==C_CommaSym)
            Get()
            if (@sym == C_identifierSym && decorators.include?(curString()) )
                Get()  # Expect(C_identifierSym) # public/private
            end
            Expect(C_identifierSym)
        end


    # line 264 "cs.atg"
        # Expect(C_SemicolonSym)
    end
    
    def ClassDef
        p("ClassDef0", 10)
        pdebug("===>ClassDef:#{@sym}, #{curString()}")
        # line 267 "cs.atg"
        	Expect(C_classSym)
        # line 267 "cs.atg"
        
        # filter out declaration between 'class' and class name
            p("ClassDef0:#{@sym}, #{curString()}")

            filterSymBefore([C_ColonSym, C_LbraceSym], 1)
          #  Get()
            p("after filterSymBefore: #{@sym}, #{curString()}")
        	_class_name = curString()
        	Expect(C_identifierSym)
        	clsdef = ClassDef.new(_class_name)
            # class_name = _class_name[0].upcase + _class_name[1.._class_name.size-1]
        # line 268 "cs.atg"

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
    	    
    	    @classdefs[_class_name] = clsdef
            # @classdefs.each{|k,v|
            #               p "classdef #{k}=#{v}"
            #           }
    end
    
    def FriendClass()
             Expect(C_classSym)
                Expect(C_identifierSym)
                Expect(C_SemicolonSym)
    end
    # line 297 "cs.atg"
    def ClassBody(clsdef)
       
        in_scope(clsdef)
        pdebug("===>ClassBody:#{@sym}, #{curString()}");
    
    # line 298 "cs.atg"

    # line 322 "cs.atg"
    	Expect(C_LbraceSym)
    	$class_current_mode = "public"
    # line 322 "cs.atg"
    	while (@sym >= C_identifierSym && @sym <= C_hexnumberSym ||
    	       @sym >= C_stringD1Sym && @sym <= C_charD1Sym ||
    	       @sym == C_SemicolonSym ||
    	       @sym >= C_classSym && @sym <= C_LbraceSym ||
    	       @sym >= C_staticSym && @sym <= C_stringSym ||
    	       @sym == C_LparenSym ||
    	       @sym >= C_StarSym && @sym <= C_caseSym ||
    	       @sym >= C_defaultSym && @sym <= C_ifSym ||
    	       @sym >= C_returnSym && @sym <= C_switchSym ||
    	       @sym == C_AndSym ||
    	       @sym >= C_PlusSym && @sym <= C_MinusSym ||
    	       @sym >= C_PlusPlusSym && @sym <= C_MinusMinusSym ||
    	       @sym >= C_newSym && @sym <= C_DollarSym ||
    	       @sym >= C_BangSym && @sym <= C_TildeSym ||
               @sym == C_deleteSym || @sym == C_throwSym || @sym == C_sizeofSym ) 
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
    		Definition()
		
    	end
    # line 322 "cs.atg"
    	Expect(C_RbraceSym)
    # line 324 "cs.atg"

    	 out_scope()
    end
    
    def Enum()
        ret = ""
        pdebug("===>Enum:#{@sym}, #{curString()}");
    	Get()
    	
    	if @sym == C_identifierSym # enum name before {}
    	    Get()
	    end
        Expect(C_LbraceSym)
    	base = 0
    	while @sym == C_identifierSym
    	    a = curString()
    	    # to constant
    	    a = a[0].upcase+a[1..a.size-1]
    	    
    	    Get()
    	    if (@sym == C_EqualSym)
    	        Get()
    	        v = curString()
    	        Expect(C_numberSym)
    	        p "v=#{v}, sym:#{@sym}"
    	        if v =~ /^([\d.]+)\w*$/
    	            v = $1
	            end
    	        base = v.to_i
                # Get()
	        end
	        ret += "#{a} = #{base}\n"
	        p "#{a} = #{base}\n"
	        p "sym:#{@sym}"
	        if @sym == C_CommaSym
	            Get()
	            base += 1
            end
            p "==>enum22:#{@sym}, #{SYMS[@sym]}, #{curString}", 10
            
    	end
    	
    	Expect(C_RbraceSym)
    	pdebug("===>Enum1:#{@sym}, #{ret}")
    	return ret
    end
    
    def StructDef()
        pdebug("===>StructDef:#{@sym}, #{curString()}");
        	Expect(C_StructSym)
        # line 267 "cs.atg"
        	_class_name = curString()
        	Expect(C_identifierSym)
        	clsdef = ClassDef.new(_class_name)
            # class_name = _class_name[0].upcase + _class_name[1.._class_name.size-1]
        # line 268 "cs.atg"

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
    	    
    	    @classdefs[_class_name] = clsdef
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
    	elsif (@sym == C_EnumSym)
    	    ret += Enum()
    	elsif (@sym == C_StructSym)
    	    StructDef()
	    # elsif
	    #          [ StorageClass ] Type { "*" } identifier
	    #                                    ( FunctionDefinition | VarList ";" ) 
	    #                                    | Inheritance .
    	elsif (@sym >= C_EOF_Sym && @sym <= C_hexnumberSym ||
    	           @sym >= C_stringD1Sym && @sym <= C_charD1Sym ||
    	           @sym == C_SemicolonSym ||
    	           @sym >= C_LbraceSym && @sym <= C_stringSym ||
    	           @sym == C_LparenSym ||
    	           @sym >= C_StarSym && @sym <= C_caseSym ||
    	           @sym >= C_defaultSym && @sym <= C_ifSym ||
    	           @sym >= C_returnSym && @sym <= C_switchSym ||
    	           @sym == C_AndSym ||
    	           @sym >= C_PlusSym && @sym <= C_MinusSym ||
    	           @sym >= C_PlusPlusSym && @sym <= C_MinusMinusSym ||
    	           @sym >= C_newSym && @sym <= C_DollarSym ||
    	           @sym >= C_BangSym && @sym <= C_TildeSym ||
    	           @sym == C_TypedefSym || @sym == C_deleteSym || @sym == C_throwSym || @sym == C_sizeofSym 
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
        @root_class = add_class("::")
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
        elsif @sym == C_TildeSym 
            if ['class', 'struct'].include?(current_scope.name)
                Get()
                Expect(C_identifierSym)
                FunctionDefinition(current_scope.class_name, "uninitialize")
	        end     
		elsif (@sym == C_identifierSym )
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
	                else
	                    count = 3
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
    	            
    	        elsif cs == "virtual" && ['class', 'struct'].include?(current_scope.name)
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
 
    	        elsif _next == C_LparenSym  && ['class', 'struct'].include?(current_scope.name)# for constructor in class or struct
    	            p "--> in class scope"
    	            if current_scope.class_name == cs # constructor
    	                Get()
                        rStatement += FunctionDefinition(current_scope.class_name, "initialize")
	                elsif cs=="~" # deconstructor
                        Get()
                        Expect(C_identifierSym)
	                    rStatement += FunctionDefinition(current_scope.class_name, "uninitialize")                        
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
        	        _next == C_TypedefSym || _next == C_staticSym #||
                    # _next == C_ColonColonSym # TODO this will unsupport A::B::C.callmethod()
        	        rStatement += LocalDeclaration()
                else #maybe functioncall
                    rStatement += Statement()
                    # p "statement return #{rStatement}"
                end
        elsif (@sym >= C_staticSym && @sym <= C_stringSym || @sym == C_TypedefSym )
        # line 711 "cs.atg"
        		rStatement += LocalDeclaration()
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
        rStatement = ""
    # line 711 "cs.atg"
    	while (@sym >= C_identifierSym && @sym <= C_hexnumberSym ||
    	       @sym >= C_stringD1Sym && @sym <= C_charD1Sym ||
    	       @sym == C_SemicolonSym ||
    	       @sym == C_LbraceSym ||
    	       @sym >= C_staticSym && @sym <= C_stringSym ||
    	       @sym == C_LparenSym ||
    	       @sym >= C_StarSym && @sym <= C_caseSym ||
    	       @sym >= C_defaultSym && @sym <= C_ifSym ||
    	       @sym >= C_returnSym && @sym <= C_switchSym ||
    	       @sym == C_AndSym ||
    	       @sym >= C_PlusSym && @sym <= C_MinusSym ||
    	       @sym >= C_PlusPlusSym && @sym <= C_MinusMinusSym ||
               # @sym >= C_newSym && @sym <= C_DollarSym ||
               @sym == C_newSym || @sym == C_deleteSym || @sym == C_throwSym || @sym == C_sizeofSym ||
    	       @sym >= C_BangSym && @sym <= C_TildeSym ||
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
            p "sym:#{@sym},curString:#{curString}"
            if (@sym == C_identifierSym || @sym >= C_staticSym && @sym <= C_stringSym ||
    		    @sym == C_TypedefSym ||
    		    (@sym == C_TildeSym && GetNext() == C_identifierSym)
    		    )
                # p "enter 1,#{rStatement}"
    		    _retg = gStatement()
    		    if _retg && _retg.strip != ""
    		        rStatement += "\n" if rStatement.strip != ""
    		        rStatement += _retg	
		        end
                # p "enter 11,#{rStatement}"
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
                       @sym == C_newSym || @sym == C_deleteSym || @sym == C_throwSym || @sym == C_sizeofSym ||
    		           @sym >= C_BangSym && @sym <= C_TildeSym) 
    # line 711 "cs.atg"
    			_ret_s = Statement()
    			if _ret_s && _ret_s.strip != ""
    			    rStatement += "\n" if rStatement.strip != ""
    			    rStatement += _ret_s
			    end
    		 else 
    		     GenError(90)
		     end
    	end # while
    	return rStatement
    # line 711 "cs.atg"
    end    
    
    
    def isTypeStart(sym=@scanner.nextSym)
        p "===>isTypeStart:#{sym.sym}, val #{getSymValue(sym)}"
        # pos1 = sym.pos
        _sym = sym.sym
        if _sym >= C_staticSym && _sym <= C_voidSym 
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
                return false
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
            if find_class(varname)
                return true
            else
                p "==>isTypeStart:class #{getSymValue(sym)} not found"
            end
            
        end
       p "==>symbol #{getSymValue(sym)} is not type start!"
        return false
    end
    # line 689 "cs.atg"
   def LocalDeclaration()
       p "---->LocalDeclaration1"
        ret = ""
    # line 690 "cs.atg"

        storageclass = ""
        type = ""
        if @sym == C_TypedefSym
    	    p "--->typedef"
    	    while @sym != C_SemicolonSym
    	        Get()
    	        p "cs in td:#{@sym},#{curString}"
	        end
	        return ""
        end
=begin        
        if @prev_sym == C_identifierSym
            @prev_sym = nil
        else
        
            p "=3>#{@sym}"
        # line 696 "cs.atg"
        	if (@sym >= C_varSym && @sym <= C_stringSym || @sym == C_identifierSym) 
        # line 696 "cs.atg"
        		type += Type()
        	elsif (@sym >= C_staticSym && @sym <= C_functionSym) 
        # line 696 "cs.atg"
        		storageclass += StorageClass()
        # line 696 "cs.atg"
                # if (@sym >= C_varSym && @sym <= C_stringSym) 
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
    
        p "---->LocalDeclaration2, #{@sym}, #{curString()}"
        dump_pos()
        
        _next = GetNext()
        while (@sym != C_LparenSym && @sym != C_ColonColonSym &&
                (   _next == C_identifierSym ||
                    _next >= C_varSym && _next <= C_stringSym || 
                    _next >= C_staticSym && _next <= C_functionSym ||
                    _next == C_StarSym || _next == C_AndSym || _next == C_ColonColonSym ||
                    _next == C_LessSym # template
                )
               )
               p "---->LocalDeclaration3, @sym=#{@sym}, curString=#{curString()}, line #{curLine()}, col #{curCol()}"
           dump_pos()
           
           if @sym == C_identifierSym && _next == C_ColonColonSym  && type != ""
               break
           end
              if @sym == C_identifierSym && curString == "kl" 
                 break
              end
             p "-->sym:#{@sym}, next:#{_next}, line #{@scanner.nextSym.line }, v=#{curString()}"
        	if (@sym >= C_staticSym && @sym <= C_functionSym) 
                p "---->LocalDeclaration11"
        		storageclass += StorageClass()
        	elsif (@sym >= C_varSym && @sym <= C_stringSym)
                p "---->LocalDeclaration12"
                
                type += Type()
            elsif @sym == C_identifierSym
                p "---->LocalDeclaration13"
                
                type = Type()   # replace last one, to remove decorator like __dll_export
            elsif _next == C_ColonColonSym
                p "---->LocalDeclaration14"
                
                type = Type() 
            end
            if type != ""
                p "---->LocalDeclaration15"
                
                var_type = VarType.new(type) # not used, will just skip var type
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
        end

 
        
        # line 702 "cs.atg"
        p "type=#{type}, storageclass=#{storageclass}, prev=#{@prev_sym}, cur=#{@sym}, val #{curString}"
        dump_pos()
        
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
    	
        isOperatorDef = false;
    	fname = varname
    	if fname =="operator"
            isOperatorDef = true
    	    Get()
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
            end
        	p "===>operator:#{fname}"
            
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
                add_class(varname)
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
            if isOperatorDef ||  _n == C_RparenSym ||
                 isTypeStart(gns)# || isFunctionFormalParamStart(offset)
                # A fn();
                # A fn(a* b) in which a is type
                fd = FunctionDefinition(class_name, fname, storageclass)
            else
            	varname = current_scope.add_var(Variable.new(varname, var_type))
                # fc = "#{varname} = #{var_type.name}.new"
                # fc += FunctionCall()
                # p "fc=#{fc}"
            	
                # p "varlist22"
                # line 706 "cs.atg"
                vl = VarList(var_type) # define lots of variables in one line splitted by comma

                # line 706 "cs.atg"
            	Expect(C_SemicolonSym)
            end
            
            # fd = FunctionCall()
    	elsif (@sym == C_SemicolonSym ||
    	           @sym >= C_EqualSym && @sym <= C_LbrackSym) 
    	    varname = current_scope.add_var(Variable.new(varname, var_type))
    # line 706 "cs.atg"
            vl = VarList(var_type) # define lots of variables in one line splitted by comma
	
    # line 706 "cs.atg"
    		Expect(C_SemicolonSym)
    	else 
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
    def VarList(var_type)
        pdebug("varlist")
        
        ret = ""
        
        
        if @sym == C_LparenSym
        	ret += " = #{var_type.name}.new"
        	ret += FunctionCall()
        end
        
    # line 441 "cs.atg"
    	ArraySize();
    # line 442 "cs.atg"

    	   
    # line 445 "cs.atg"
    	if (@sym == C_EqualSym) 
    	    ret += "="
    # line 445 "cs.atg"
    		Get();
    # line 445 "cs.atg"
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
            	ret += FunctionCall()
            end
    # line 454 "cs.atg"
    		ArraySize()
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
    
    # line 461 "cs.atg"
    	while (@sym == C_LbrackSym) 
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
    			ConstExpression()
    		end
    # line 461 "cs.atg"
    		Expect(C_RbrackSym)
    	end
    	return ""
    end    
    # line 465 "cs.atg"
    def FunctionDefinition(class_name, fn_name, acc="")
        pdebug "===>FunctionDefinition:#{class_name}::#{fn_name}", 30
        ret = ""
        if class_name
 	        classdef = @classdefs[class_name]
 	        if !classdef
 	            if current_scope.is_a?(ClassDef)
                    classdef = current_scope
                end
            end
        else
            if current_scope.is_a?(ClassDef)
                classdef = current_scope
            end
        end
        pushed = false
        if classdef && classdef != current_scope
            in_scope(classdef)
            pushed = true
        end
        # list_scopes
      #  p "classdef:#{classdef.inspect}"
    # line 466 "cs.atg"
        in_scope("FunctionDefinition")
    # line 509 "cs.atg"
    	ret += FunctionHeader()
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
        if @sym == C_SemicolonSym  ||symValue == "const" || symValue == "override"
            #if just function declaration without body
            # return ""
        elsif @sym == C_EqualSym
            Get()
            Expression()
            Expect(C_SemicolonSym)
        else

            # in_scope(classdef) if classdef
            if @sym == C_ColonSym
                # member value initialization list, for constructor of class/struct
                p "# initialization list, for constructor of class/struct:#{classdef}"
                i_list = ""
                Get()
                 m = curString()
                 p "m=#{m}, parent=#{classdef.parent}"
                 if m == classdef.parent
                     m = "super"
                 end
                Expect(C_identifierSym)
               
                Expect(C_LparenSym)
                v = ActualParameters()
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
                     
                     i_list += "@#{m} = #{v}\n"
                     
                end
            end
        	fb = FunctionBody()
        	fb = i_list + fb if i_list
            # out_scope() if classdef
    	end
    	 out_scope() # functiondefinition
    # line 510 "cs.atg"
        method_src = nil
        if (fb)
            ret = "#{ret}\n#{fb}\nend"
            method_src = ret
        end
        # add_class_method_def(class_name, fn_name, args)
        p "add mehtod '#{fn_name}' to class '#{class_name}':#{ret}"
        p "classdef #{classdef.inspect}"
        if classdef
            classdef.add_method(fn_name, args_num, method_src, acc)
        else
            @root_class.add_method(fn_name, args_num, method_src, acc)
        end
        p "classdef #{classdef.inspect}"
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

    # line 545 "cs.atg"
    	Expect(C_LparenSym)
    # line 545 "cs.atg"
    	if (@sym == C_identifierSym ||
    	    @sym >= C_varSym && @sym <= C_stringSym||
    	   @sym == C_constSym) 
    # line 545 "cs.atg"
    		ret += FormalParamList()
    	end
    # line 545 "cs.atg"
    	Expect(C_RparenSym)
    # line 546 "cs.atg"
    _cs = curString()
        if @sym == C_identifierSym && ( _cs == 'const' || _cs == 'override')
            Get()
            
        end
        
        return "(#{ret})"
 
    end
    
    # line 567 "cs.atg"
    def FormalParamList()
        p("FormalParamList0")
        $formal_p_count = 0
        ret = ""
    # line 567 "cs.atg"
    	ret += FormalParameter()
    	
    # line 567 "cs.atg"
    	while (@sym == C_CommaSym) 
    	    ret += ","
    # line 567 "cs.atg"
    		Get()
    # line 567 "cs.atg"
    		ret += FormalParameter()
    		
    	end
    	
    	return ret
    end
    # line 441 "cs.atg"
    def FormalParameter()
        ret = ""
    # line 441 "cs.atg"
        # PTYPEDES type = new TYPEDES;
    # line 442 "cs.atg"
        if @sym == C_identifierSym && curString() == 'const'
            Get()
        end
    	var_type = Type()
        p("FormalParameter1:sym=#{@sym}, curString=#{curString()}")
    # line 442 "cs.atg"
    	while (@sym == C_StarSym || @sym == C_AndSym || @sym == C_AndAndSym) 
    # line 442 "cs.atg"
    # line 442 "cs.atg"
    		Get()
    # line 442 "cs.atg"
            # type->refLevel++;
    	end
        p("FormalParameter2:sym=#{@sym}, curString=#{curString()}")
        
    # line 444 "cs.atg"
   
        if @sym == C_identifierSym 
             param_name = varname = curString()
           
            # here parameter in function header cannot be Const (Capital on first char)
            param_name = param_name[0].downcase + param_name[1..param_name.size-1]
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
        
    
        return ret
        
    end
    # line 394 "cs.atg"
    def StorageClass()
        ret = ""
    # line 396 "cs.atg"
    	if (@sym >= C_staticSym && @sym <= C_constSym) 
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
        type = Type()
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
        
        
        while (@sym >= C_staticSym && @sym <= C_constSym) 
            StorageClass()
        end
        
     
        skipUnusableType()
        
    # line 423 "cs.atg"
    	case (@sym) 
=begin
    		when C_varSym 
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
    			if (@sym >= C_intSym && @sym <= C_intSym ||
    			    @sym == C_intSym) 
    # line 428 "cs.atg"
    				if (@sym == C_intSym) 
    # line 428 "cs.atg"
    					ret += curString()
            		    Get()
    				elsif (Sym == C_intSym) 
    # line 428 "cs.atg"
    					ret += curString()
            		    Get()
    				elsif (@sym == C_intSym) 
    # line 428 "cs.atg"
    					ret += curString()
            		    Get()
    				else 
    				    GenError(94)
				    end
    			end
    			#break;
    		when C_charSym  
    # line 429 "cs.atg"
    			ret += curString()
    		    Get();
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
    		when C_stringSym  
    # line 436 "cs.atg"
    			ret += curString()
    		    Get();
    # line 437 "cs.atg"
    			# break;
    		when C_identifierSym
    		    ret += curString()
    		    Get()
                p "sym1:#{@sym}, #{curString()}"
		        
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
	            p "sym3:#{@sym}, val #{curString()}"
	            p "ret3:#{ret}"
               # if (find_class(ret) == nil)
    	       #     p "unknow type:#{ret}"
               #     
               #     GenError(116)
               # end
    		else 
    		    GenError(95)
    	end # case
    	p "type3:ret=#{ret}, #{@sym}, val #{curString()}"

    	return ret
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
        end
        stmt =<<HERE
        begin
            #{try_stmt}
        rescue #{exptype.name}=>#{expvar}
            #{catch_stmt}
        end
HERE
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
            else 
                GenError(96) 
    	end
    # line 671 "cs.atg"
	    p "current symbol:#{@sym}, #{curString()}, #{@scanner.nextSym.line}"
	    pdebug("====>statement1:#{stmt}")
        return stmt
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
    	    @sym >= C_BangSym && @sym <= C_TildeSym) 
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
    p "===>MultExp2:#{@sym}, #{curString}"
    
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
                    
                    index_collon = ret.rindex("::")
                    index_dot = ret.rindex(".")
                    if index_collon and !index_dot
                        ret = ret[0..index_collon-1]+"."+ret[index_collon+2..ret.size-1]
                    end
                    ret += FunctionCall()
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
                        ret += FunctionCall()
    				end
    # line 1896 "cs.atg"

    				

    			
    			when C_MinusGreaterSym  
    # line 1937 "cs.atg"
    				ret += "."
    # line 1937 "cs.atg"
    			
        			Get()
    # line 1937 "cs.atg"
                	
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
    	pdebug "==>PostFixExp1:#{ret}"
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
            @sym == C_newSym || @sym == C_deleteSym || @sym == C_throwSym || @sym == C_sizeofSym ||
            @sym == C_defaultSym) 
            
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

    # line 2475 "cs.atg"
    
        primary_sym = @sym
    	case @sym
    		when C_identifierSym  
                # varname = translate_varname()
                varname = curString()
                
		  

                	Get()
        # line 2334 "cs.atg"
                    if @sym == C_ColonColonSym
                        ret += translate_varname(varname)
                        while (@sym == C_ColonColonSym)
                            p "====>233:#{curString()}"
                            # line 2353 "cs.atg"
                            	Get();
                            # line 2353 "cs.atg"
                    
                            ret += "::#{translate_varname(curString())}"
                            Expect(C_identifierSym)
                    	end
                	else
                	    if varname == "this"
                	        ret += "self"
            	        else
        	            
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
                        end
    		    	
        		    end # if @sym == C_ColonColonSym
                 p "====>primary3:#{@sym}, #{curString()}"
                
                    if @sym == C_LessSym
                        filterTemplate()
                    end
                    p "====>primary4:#{@sym}, #{curString()}"
                dump_pos()
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
                 if (@sym >=C_shortSym && @sym <= C_voidSym)
                     t = Type()
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
                t = Type()

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
                    @sym >= C_shortSym && @sym <= C_stringSym
                    # type cast (A*)
                    if @sym == C_constSym
                        Get()
                    end
                    _next = GetNext()
                    _next2 = GetNext(2)
                    p "_next:#{_next}, _next2:#{_next2}"
                    if (_next == C_RparenSym&&  _next2 != C_QuestionMarkSym) || 
                        ( ( _next == C_StarSym || _next == C_AndSym ) && (_next2 < C_identifierSym || _next2 > C_charD1Sym) )
                        vt = FullType()
                        p "vt:#{vt.inspect}"
                        Expect(C_RparenSym)
                        ret += Expression()
                        bT = true
                    end
                end
                if !bT  # ( Expression )
    		    	exp =Expression()
        			   p "sym556:#{@sym}, val #{curString()}"
        # line 2593 "cs.atg"
        			Expect(C_RparenSym)
        			ret += "(#{exp})"
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
    		else 
    		    GenError(112)
    	end # case
    	
        if primary_sym != C_sizeofSym
    	    if /\(\s*[\w\d_]+\s*\)/ =~ ret
                # (abc) => abc
    	        ret = ret.gsub(/\(\s*([\w\d_]+)\s*\)/, '\1')
	        end
        end
    	pdebug "=====>Primary1:#{ret}"
        
        return ret
    end
    
    # line 2597 "cs.atg"
    def FunctionCall()
        pp "functioncall()",20
        ret  =""
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
    	    @sym >= C_BangSym && @sym  <= C_TildeSym) 
    # line 2605 "cs.atg"
    		ret += ActualParameters()
    	end
    # line 2605 "cs.atg"
    	Expect(C_RparenSym);
    # line 2606 "cs.atg"
        p "====>FunctionCall1:(#{ret})", 20
        return "(#{ret})"
    end

    # line 2660 "cs.atg"
    def ActualParameters()
        debug "==>ActualParameters:#{@sym}, line #{curLine}, val #{curString()}"
	    
        ret = ""
    # line 2661 "cs.atg"

    	

    # line 2668 "cs.atg"
    	ret += Expression()
    # line 2669 "cs.atg"

    	p "ret:#{ret}"
    # line 2701 "cs.atg"
    	while (@sym  == C_CommaSym) 
    # line 2701 "cs.atg"
    		ret += curString()
    		
    		Get()
    # line 2701 "cs.atg"
    		ret += Expression()
    # line 2703 "cs.atg"

	    end
	    debug "==>ActualParameters1:#{@sym}, line #{curLine}, val #{curString()}, ret=#{ret}"
    # line 2776 "cs.atg"
        return ret
    end
    def Creator()
        ret = ""
    # line 2244 "cs.atg"
    # line 2245 "cs.atg"
    	className = ClassFullName()
    # line 2246 "cs.atg"

    
    # line 2287 "cs.atg"
        fCall = ""
    	  
    # line 2302 "cs.atg"
    	while (@sym == C_LparenSym) 
    # line 2302 "cs.atg"
    		fCall += FunctionCall()
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
    	p "==>ClassFullName1:#{ret}"
        return ret
    end
end  # class Parser

######### test ################
#=begin
def test(testall=false)
# s = "{1;a=1;}"
# s = "{1;a=1;b=2;    }"
s = <<HERE
    {
   
        if (a==1)
            a = 1;
        else if (a>=3)
            a =2;
        else if (a ==4)
            a = 0;
        
    }
HERE
s=<<HERE
{
if (m_pSequenceParameter)
{
	delete=m_pSequenceParameter;
	m_pSequenceParameter = NULL;
}

}
HERE
s1 =<<HERE
{
    int* *a = 11;
    _TRACER("UpdateDocBudget");
    SBOErr          ooErr = ooNoErr;
    PDAG            dagBGT =NULL, dagBGT1=NULL;
    PDAG            dagAct = NULL;

    TCHAR           tmpStr[256]={0};
    TCHAR           finYear[OBGT_FINANCIAL_YEAR_LEN+1]={0};

    Boolean         localDags = FALSE;
    Boolean         bgtDebitSide = FALSE, subMoneyOper = FALSE;

    long            openInvField, openInvSysField;
    long            openInvFieldArr, openInvSysFieldArr;
    long            acctNum=0;

    MONEY           budgMoney;
    MONEY           tmpM, tmpSysM;
    CBizEnv         &bizEnv = bizObject->GetEnv ();
 
    if (!DAG::IsValid (dagDOC1))
    {
        return dbmBadDAG;
    }

    if (bizEnv.IsComputeBudget () == FALSE )
    {
        return  (ooNoErr);
    }

    switch (updateBgtPtr->objType)
    {
        case RDR:
        case POR:
        case PDN:
        case DLN:
        case PRQ:
        break;

        case RDN:
        case RPD:
            subMoneyOper = TRUE;
        break;

        default:
            return (ooNoErr);
        break;
    }
    
    int a = 1;
    b = 10;
    for ( int i = 0;i < b; i++)
        a(i);
        CBizEnv    &bizEnv = GetEnv ();
    return 20;
}   
HERE
s2 = <<HERE
{

   a[0]=0;
}
HERE
s3=<<HERE
//a = 1;
#include "a.h"
#fdaaslk
#include "bss.h"
b =1;
enum
{
	resTax1AbsEntry = 0L,
	resTax1TaxCode, 
	resTax1EqPercent,
	resJdt1TransId,
	resJdt1Line_ID,
};
HERE
s=<<HERE
#define cc 1
#if 0
a = 1
#elif ccc
a = 2
#elif cc
a = 22
#else
a =3
#endif

#ifdef bb
c = 1
#elif ccc
c = 2
#elif ccc
c = 22
#else
c =3
#endif

#define MDR_ASSIGN_STR_NUM 						80304
#define INVALID_OCR_FOR_POSTDATE_INDEX 			13
#define AMOUNT_CHANGED_INDEX 					15
#define ROW_DIMENSION_LOCATION					16
HERE

s4=<<HERE
#define bbb 1
#ifdef bbb
a=12;
#else
a=11;
#define bb 1
c=1;
d=1;
#endif
HERE


s5 =<<HERE
#dfsfffff
#adfa
ff=1;
HERE
s6 =<<HERE
//a = 1;
//#define bbc

//abc=1;

#include "a.h"

//#fdaaslk
//c=1;
//#include "bss.h"
//b =1;
HERE
s7=<<HERE
#include "a.h"
HERE
s8=<<HERE

#define		JDT_WARNING_BLOCK	3
#ifdef JDT_WARNING_BLOCK1
a = 1
#else
a = 2
#endif

HERE

s9=<<HERE
B c = A(b);
HERE
s10=<<HERE
class Test{
    int a;
    void test1(){
        printf("show test1");
        a = 1;
    }
}
int Test::test(int a, B* b){
    printf("int");
    printf("int");
    a = 1;
    
}
HERE
s11=<<HERE
//StdMap<SBOString, FCRoundingStruct, False, False> currencyRoundingMap;
std::map<SBOString, FCRoundingStruct, False, False> currencyRoundingMap;

HERE
s12=<<HERE
a();

HERE
s13=<<HERE
long canceledTrans = 0;
dagJDT->GetColLong (&canceledTrans, OJDT_JDT_NUM, 0);
try
{
	if (cancelNum > 0)
	{
		canCancelJE = false;
	}
}
catch (DBMException &e)
{
	ooErr = e.GetCode ();
}
HERE
s14=<<HERE
virtual bool	IsDeferredAble	() const {return false;}
HERE
s15=<<HERE
// Defines for setting dates in canceled JE for In/Out Payments
/************************************************************************************
************************************************************************************/
// columns for reconciliation upgrade dag res


//CMessagesManager::GetHandle ()->Message (_132_APP_MSG_AP_AR_USER_NOT_ASSINED_BPL, EMPTY_STR, this, (const TCHAR*)BPLName);
aaaa((const TCHAR*)BPLName);
HERE
s0=<<HERE
class CJDTStornoExtraInfoCreator{
CJDTStornoExtraInfoCreator(){
    
}
}
CJDTStornoExtraInfoCreator * CJDTStornoExtraInfoCreator::operator=(const CJDTStornoExtraInfoCreator & other){
    
}
HERE
s1=<<HERE
_LOGMSG(logDebugComponent, logNoteSeverity, 
	_T("In CTransactionJournalObject::BeforeDeleteArchivedObject - starting JEComp.execute()"));


HERE
s2=<<HERE
try{
    
}catch (nsDataArchive::CDataArchiveException& e){
    
}
HERE
s3=<<HERE
    _MEM_MYRPT0 (_T("CDocumentObject::UpdateWTOnRecon - \
                 JDT2 should contain 1 rec at the most for reconciliation!"));
HERE
s4=<<HERE
a = 1U;
HERE
s5=<<HERE
fdafa;
a = 1U;
//b= 1usl;
HERE
s6=<<HERE

StdMap<SBOString, FCRoundingStruct, False, False>::const_iterator itr = currencyMap.begin();
a=1;
HERE
s7=<<HERE
void CTransactionJournalObject:: OJDTGetDocCurrency(CBusinessObject* bizObject, TCHAR *docCurrency)
{
	PDAG	dagJDT = bizObject->GetDAG ();
	CBizEnv	&bizEnv = bizObject->GetEnv();

	dagJDT->GetColStr (docCurrency, OJDT_TRANS_CURR);
	if (_STR_IsSpacesStr (docCurrency))
	{
		_STR_strcpy (docCurrency, bizEnv.GetMainCurrency ());
	}
}
HERE
s8=<<HERE
    CTransactionJournalObject::IsPaymentOrdered(bizEnv, canceledTrans, ordered);
HERE
s9=<<HERE
    class A{
        int a;
    }
    void A::test(){
        a = 1;
    }
HERE
s10=<<HERE
    class A{
        int a;
        void test();
    }
    void A::test(){
        a = 1;
    }
HERE
s11 =<<HERE
		//PDAG dagJDT1 = GetDAG (JDT, ao_Arr1);
		PDAG dagJDT1 = GetDAG (JDT, ao_Arr1), b=1;
HERE

s12=<<HERE
//char *a="\\n";
_STR_strcat (MformatStr, _T("\\n"));
_MEM_MYRPT0 (_T("CDocumentObject::UpdateWTOnRecon - \\
             JDT2 should contain 1 rec at the most for reconciliation!"));
HERE
s13=<<HERE
class A{
    FOUNDATION_EXPORT static CBusinessObject	*CreateObject (const TCHAR *id, CBizEnv &env);
}
HERE
s14=<<HERE

    _MEM_MYRPT0 (_T("CDocumentObject::UpdateWTOnRecon - \\
                 JDT2 should contain 1 rec at the most for reconciliation!"));
                 _STR_strcat (MformatStr, _T("\\n"));

              
HERE
s15 =<<HERE
		 _TRACER("OnCreate");
    	SBOErr	ooErr = noErr;
    	PDAG	dagJDT, dagJDT1, dagCRD=0;
     	PDAG	dagRES;

    	long    blockLevel=0, typeBlockLevel=0;
    	long	retBtn;
    	long	recCount = 0, ii = 0;
    	long	RetVal = 0;
    	long	numOfRecs, rec;
    	long	lastContraRec = 0, contraCredLines = 0, contraDebLines = 0;		// VF_EnableCorrAct
    	long	createdBy, transAbs, transType;

    	Currency	monSymbol={0};

    	MONEY	debAmount, credAmount, transTotal, transTotalChk;
    	MONEY	transTotalCredChk, transTotalDebChk, sTransTotalDebChk, sTransTotalCredChk, fTransTotalDebChk, fTransTotalCredChk;		// VF_EnableCorrAct
    	MONEY	fTransTotal, fDebAmount, fCredAmount;
    	MONEY	sTransTotal, sDebAmount, sCredAmount;
    	MONEY	rateMoney, tempMoney;
    	MONEY	BgtMonthOver, BgtYearOver;
    	MONEY	creditBalDue, debitBalDue, fCreditBalDue, fDebitBalDue, sCreditBalDue, sDebitBalDue;

    	TCHAR	acctKey[GO_MAX_KEY_LEN + 1], tempStr[256];
    	TCHAR	contraCredKey[GO_MAX_KEY_LEN + 1], contraDebKey[GO_MAX_KEY_LEN + 1];
    	TCHAR	cardKey[OCRD_CARD_CODE_LEN + 1];
    	TCHAR	Sp_Name[256] = {0};
    	TCHAR	mainCurr[GO_CURRENCY_LEN+1]={0}, frnCurr[GO_CURRENCY_LEN+1]={0};
    	TCHAR	tmpStr[256]={0};
    	TCHAR	msgStr1[512]={0}, msgStr2[512]={0};	
    	TCHAR	moneyStr[256]={0}, moneyMonthStr[256]={0}, moneyYearStr[256]={0}; 
    	TCHAR	acctCode[OACT_ACCOUNT_CODE_LEN + 1] ={0};
    	TCHAR	DoAlert,AlrType;

    	Boolean		balanced = FALSE;
    	Boolean		budgetAllYes = FALSE, bgtDebitSize; 
    	Boolean		fromImport = FALSE;
    	Boolean		itsCard, qc;

    	DBD_ResStruct	res[5] ;
    	DBD_UpdStruct	Upd[4];
    	CBizEnv			&bizEnv = GetEnv ();
        BPBalanceChangeLogDataArr bpBalanceLogDataArray;

    		qc = FALSE;
    		dagJDT = GetDAG();
        	dagJDT1 = GetDAG(JDT, ao_Arr1);
            PDAG dagJDT2 = GetDAG(JDT, ao_Arr2);
HERE
s16=<<HERE
    class A{
        int a;
        virtual SBOErr			OnCreate ();
        static void test();
    }
    void A::test(){
        a = 1;
    }
    SBOErr A::OnCreate()
    {
    }
HERE
s17=<<HERE
++i;
HERE
s18=<<HERE
// formal argument cannot be a constant
void a(int A){
    
}
HERE
s19=<<HERE
// formal argument cannot be a constant
a(&t);
HERE
s20=<<HERE
bizObject=&other;
HERE
s21=<<HERE
bizObject=L"fsdfsd";
HERE
s22=<<HERE
bool CJDTDeferredTaxUtil::IsBPWithEqTax(const SBOString bpCode, CBizEnv& bizEnv)
{
	APCompanyDAG dagCRD;	
	bizEnv.OpenDAG (dagCRD, SBOString(CRD));
	dagCRD->GetBySegment (OACT_KEYNUM_PRIMARY, bpCode);
	SBOString eqTax;
	dagCRD->GetColStr (eqTax, OCRD_EQUALIZATION);
	eqTax.Trim();

	return eqTax == VAL_YES;
}


bool CJDTDeferredTaxUtil:: IsBPWithEqTax()
{
	PDAG dagJDT1 = m_bo->GetDAG (JDT, ao_Arr1);
	SBOString bpCode;
	dagJDT1->GetColStr (bpCode, JDT1_SHORT_NAME, m_bpLine);
	bpCode.Trim ();
	CBizEnv& bizEnv = m_bo->GetEnv();

	return CJDTDeferredTaxUtil:: IsBPWithEqTax (bpCode, bizEnv);
}

bool CJDTDeferredTaxUtil:: IsValidDeferredTax()
{
	return IsValidOnEqTax();
}

bool CJDTDeferredTaxUtil:: IsValidOnEqTax()
{
	CBizEnv& bizEnv = m_bo->GetEnv();
	if (!bizEnv.IsLocalSettingsFlag (lsf_EnableEqualizationVat))
	{
		return true;
	}

	bool isValidLine = true;
	PDAG dagJDT1 = m_bo->GetDAG(JDT, ao_Arr1);
    long bpLineCount = 0;
    long recJDT1 = dagJDT1->GetRealSize (dbmDataBuffer);
    SBOString acct, shortname;
    CTaxGroupCache *taxGroupCache = bizEnv.GetTaxGroupCache ();
	SBOString vatGroup, eqTaxAcct, vatLine;	
	
    for(long rec = 0; rec < recJDT1; rec++)
    {
        dagJDT1->GetColStr(vatLine, JDT1_VAT_LINE, rec);
		vatLine.Trim ();
        if(vatLine == VAL_YES)    
        {
			dagJDT1->GetColStr(vatGroup, JDT1_VAT_GROUP, rec);
			vatGroup.Trim ();
			taxGroupCache->GetAcctInfo (bizEnv, vatGroup, OVTG_EQU_VAT_ACCOUNT, eqTaxAcct);		
			eqTaxAcct.Trim();
			if (!eqTaxAcct.IsEmpty ())
			{
				isValidLine = false;
				break;
			}
        }
    }

	return isValidLine;
}

bool CJDTDeferredTaxUtil::SkipValidate ()
{
	return GetDeferredTaxStatus () == dts_Skip;
}

bool CJDTDeferredTaxUtil::IsValid ()
{
	if (!IsValidDeferredTaxStatus ())
	{
		return false;
	}

	if (SkipValidate ())
	{
		return true;
	}

	if (!IsValidBPLines())
	{
		CMessagesManager::GetHandle()->Message (_147_APP_MSG_FIN_JDT_DEFERRED_TAX_NO_MULTI_BP, EMPTY_STR, m_bo);
		return false;
	}

	if (IsBPWithEqTax())
	{
		CMessagesManager::GetHandle()->Message (_147_APP_MSG_FIN_JDT_DEFERRED_TAX_BP_WITH_EQ_TAX, EMPTY_STR, m_bo);
		return false;
	}

	if (!IsValidDeferredTax())
	{
		CMessagesManager::GetHandle()->Message (_147_APP_MSG_FIN_JDT_DEFERRED_TAX_WITH_EQ_TAX, EMPTY_STR, m_bo);
		return false;
	}

	return true;
}
HERE
s22=<<HERE
// b=(aaaa()+1)?1:2;
if (!forceBalance)
{
	return ooNoErr;
}

dagJDT->GetColMoney (&tmpMoney, (frgCurr) ? OJDT_FC_TOTAL:OJDT_LOC_TOTAL, 0, DBM_NOT_ARRAY);
ooErr = GNTranslateToSysAmmount (&tmpMoney, currStr, refDate, &systMoney, bizEnv);
HERE
s23=<<HERE
enum eColumnJDT1
{
		// Transaction Key
		JDT1_TRANS_ABS									=	0,
}


class CBizEnv;
class TCHAR;
class CTransactionJournalObject: public CSystemBusinessObject, public IReconcilable, public IWithHoldingAble
{
};
CTransactionJournalObject::CTransactionJournalObject (const TCHAR *id, CBizEnv &env) :
							CSystemBusinessObject (id, env), m_digitalSignature (env)
{
      
}
HERE
s24=<<HERE
enum{
 ConnID = 1
};
void a(){
     
DBM_ServerTypes   ServerType = DBMCconnManager::GetHandle()->GetConnectionType (ConnID);
DBMCconnManager::GetHandle ()->ChangeConnectionUseCount (m_connectId, increase);
}
HERE
s25=<<HERE
class A{
    virtual bool	IsDeferredAble	() const {return false;}
	int b;
}
void A::a(){
    b = 0;
}


HERE
s26=<<HERE
class CJDTStornoExtraInfoCreator{
    
}
CJDTStornoExtraInfoCreator & CJDTStornoExtraInfoCreator::operator=(const CJDTStornoExtraInfoCreator & other)
{
	if(this == &other){
		return *this;
	}

	m_jdtBusinessObject = other.m_jdtBusinessObject;
	
	return *this;
}
HERE
s27=<<HERE
a = new A(1,2);
HERE
s28=<<HERE
class CBusinessService;
class CTransactionJournalObject{
    
}
void	CTransactionJournalObject::CopyNoType (const CBusinessService& other)
{
     

		CTransactionJournalObject	*bizObject = (CTransactionJournalObject*) &other;


}

HERE
s29=<<HERE
int *b = 1;
int a = (int *)&b;
HERE
s30=<<HERE
(*currentMoney) += sumRow;
HERE
s31=<<HERE
class A;
A B(1,2);
HERE
s32=<<HERE
//int a = b & c;
//int a = &b;

//int a = b(1,(int *)&b);
delete a;

HERE

s33=<<HERE
A<true> a;
b = 1;
HERE
s34=<<HERE
template<int a>class A{int f(){};};
b = 1;
HERE
s35=<<HERE
template <bool isDisassembly>
class CWorkOrderATPSelectStrategy
{
};

a =1;

HERE
s36=<<HERE
struct RECORDQUANTITYARRAY{};
void fabdfsd(const RECORDQUANTITYARRAY&  a,int b);
//void PrepareRecordQtyArray(const RECORDQUANTITYARRAY& qtyArr, long recCount, RECORDQUANTITYARRAY& recQtyArray, long startIndex);

HERE
s37=<<HERE
abc<bool, int>().fn();
std::ff<bool, int> a=1;
HERE
s38=<<HERE
//template <bool isDisassembly> a<true,1>::fn(){};
template <bool isDisassembly> void fn(){};
a =1;
template<typename T>
T* OffsetPtr (T* x, int y)
{
	return reinterpret_cast<T*>(y);
}
HERE
s39=<<HERE
fn<int, bool>().a();

HERE

s40=<<HERE
class xxx CName:CParent{
}

HERE
s41=<<HERE
void    SetDBDParms (std::unique_ptr<DBD_Params>&& params) { m_queries[0] = std::move (params); }


HERE
s42=<<HERE
template<typename EnumT, typename std::enable_if<std::is_enum<EnumT>::value, int>::type = 0>
EnumT				GetColStrEnum (const long colNum, const long recOffset = 0L) const;


HERE
s42=<<HERE
SBOString   SerializeToXml (SBOXmlParser *pXmlParser, std::vector<long> &fieldsArr, bool includeTableDef = false);

HERE
s43=<<HERE
mutable std::unique_ptr<SBOLock>	m_lock=1;

HERE
s44=<<HERE
virtual SBOErr Execute () override { return m_dag->UpdateAll (m_checkBackup); }

HERE
s45=<<HERE
DagCleaner () = default;

HERE
s46=<<HERE
operator std::default_delete<DAG> () const { return std::default_delete<DAG> (); }

HERE
s47=<<HERE
void operator() (DAG* pDag) const;

HERE

s48=<<HERE
//B1_ENGINE_API std::wostream& operator << (std::wostream& stream, const _DBM_DataAccessGate& dag);
HERE
s49=<<HERE

std::wostream& operator << (std::wostream& stream, const _DBM_DataAccessGate& dag);
std::wostream& operator << (std::wostream& stream, const _DBM_DataAccessGate& dag){};

HERE

s50=<<HERE

int a =0;
for (long i = 0, a=1 ; i < b; i++)
{
}

for (long i1 = 0; i1 < dbKeyCount && dbAliasIndexMap.size () > 0; ++i1)
    {}
	for (long i2 = 0; i2 < columns.GetCount (); ++i2)
        {}
HERE
 
 
s51=<<HERE
dagResult->m_dataElements = new char*[sizeof (void*)];
a = new A::B(1,2);
HERE
s52=<<HERE
//DBM_ServerTypes   ServerType = DBMCconnManager::GetHandle()->GetConnectionType (ConnID);
DBMCconnManager::GetHandle ()->ChangeConnectionUseCount (m_connectId, increase);
HERE
s53=<<HERE
_DBM_DataAccessGate::SetEnvironment (v);
void _DBM_DataAccessGate::SetEnvironment (CDBMEnv *env);
void _DBM_DataAccessGate::SetEnvironment (CDBMEnv *env){};
B** _DBM_DataAccessGate::SetEnvironment (CDBMEnv *env){};

void _DBM_DataAccessGate::SetEnvironment (int *env);
void _DBM_DataAccessGate::SetEnvironment (int *env){};

HERE
s54=<<HERE
DBM_DAG_Cell_Ptr dataBuffer = recOffset < m_dataCount ? (DBM_DAG_Cell_Ptr) this->GetRecordOffsetPtr (recOffset, false) : nullptr;
//DBM_DAG_Cell_Ptr dataBuffer = recOffset < m_dataCount ? (DBM_DAG_Cell_Ptr)this->GetRecordOffsetPtr (recOffset) : nullptr;
HERE
s55=<<HERE

bp.flags = 0x00000001;
HERE
s56=<<HERE
throw "a";
throw a;
throw A();
throw CDagException (coreInvalidPointer, GetTableName (), "_DBM_DataAccessGate::CompareBuffers failed. DataBuffer is nullptr.");
HERE
s57=<<HERE
 i = 0, keyOff = 0;
for (i = 0, keyOff = 0; i < segmentCount && keyOff < keyLen; i++){}

for (int i = 0, keyOff = 0; i < segmentCount && keyOff < keyLen; i++);
 
HERE
s58=<<HERE
i = sizeof(short);
 i = sizeof(a->b());
HERE

s59=<<HERE
//TCHAR tmpStr[256] = { 0 };

//DBM_DAG_BufferParams bp = { 0 };
//DBM_DAG_BufferParams bp1 = {0  };
//conds.SetSize (numOfConds);

//DBM_DAG_BufferParams bp{ 0 };
HERE



s60=<<HERE
stream << "[invalid DAG]";

HERE

s61=<<HERE
std::wostream& operator << (std::wostream& stream, const _DBM_DataAccessGate& dag)
{}
HERE

s62=<<HERE
#ifdef A
a = 1;
#ifdef B
b = 1;
#endif
#endif
HERE

s_notsupport=<<HERE # lumda
std::remove_copy_if (diffColsList.begin (), diffColsList.end (), std::back_inserter (newDiffColsList),
	[] (const DBM_ChangedColumn& c) { return c.GetColType () != dbmText && c.GetBackupValue ().IsEmpty () && c.GetValue ().IsEmpty (); });
auto Cleanup = [&] () {}
std::wostream& operator << (std::wostream& stream, const _DBM_DataAccessGate& dag)
{
	return operator << (stream, &dag);
}
HERE



if !testall
   
    s = s62
else

    r = ""
    for i in 0..100
        begin
            si = eval("s#{i}")
        rescue
            break
        end
        if si !=nil
            r += si +"\n"
        end
    end
    s = r
    p(" ==== find #{i} testcase")
end

p s

scanner = CScanner.new(s, false)
p "===>scanner =#{scanner}"
p "==>#{scanner.nextSym}"
$sc = scanner
$sc_cur = scanner.currSym.sym
error = MyError.new("whaterver", scanner)
parser = Parser.new(scanner, error)

parser.Get
# puts "FunctionBody return \n#{parser.send("FunctionBody")}"
ret = parser.C

# parser.Preprocess

# scanner.Reset
# parser.Get

# ret = parser.C

p "parsing result:#{ret}"
error.PrintListing
parser.dump_classes_as_ruby
end # end of test
 

#=end
#test(false)

