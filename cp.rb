load 'sym.rb'
load 'scanner.rb'
load 'cr_parser.rb'
load 'error.rb'
load 'log.rb'
load 'c_classdefs.rb'


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


class Parser < CRParser
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
    def find_class(varname)
               @classdefs.each{|k,v|
                                         p "classdef #{k}=#{v}"
                }
         if @classdefs[varname]
             return @classdefs[varname]
         end
    end
    def add_class(class_name, parent, modules)
        clsdef = ClassDef.new(class_name)
        @classdefs[class_name] = clsdef
    end
    def GetNextSym(step =1)
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
            
            end while (_sym > C_MAXT)
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
            
            end while (_sym > C_MAXT)
            step -= 1
        end
        return _sym
    end
    def GetNextSymFromSym(sym, step =1)
        _scanner = @scanner.clone()
        _scanner.currLine = sym.line
        _scanner.currCol = sym.col
        _scanner.buffPos = sym.pos+sym.len
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
            
            end while (_sym > C_MAXT)
            step -= 1
        end
        return _scanner.nextSym
    end
    def GetNextFromSym(sym, step =1)
        _scanner = @scanner.clone()
        _scanner.currLine = sym.line
        _scanner.currCol = sym.col
        _scanner.buffPos = sym.pos+sym.len
        
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
            
            end while (_sym > C_MAXT)
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
                GenError(114)
                pp "===>114",20
            else
                @included_files[finclude] = 1
            end
        end
    end
    def Get
        # p "sym1=#{@sym}"
         begin 
# p "Get0:@sym=#{@sym}, len=#{@scanner.nextSym.len}, nextSym=#{@scanner.nextSym.sym}, string=#{@scanner.GetSymString(@scanner.nextSym)}, pos=#{@scanner.buffPos}, @ch=#{@scanner.ch}"
            @prev_sym = @sym
            @sym = @scanner.Get()
 # p "Get1:@sym=#{@sym}, len=#{@scanner.nextSym.len}, nextSym=#{@scanner.nextSym.sym}, string=#{@scanner.GetSymString(@scanner.nextSym)}, pos=#{@scanner.buffPos}, @ch=#{@scanner.ch}"
            # p "Get(): sym = #{@sym}, line #{@scanner.nextSym.line} col #{@scanner.nextSym.col} pos #{@scanner.nextSym.pos} sym #{SYMS[@sym]}"
            # p "sym1=#{@sym}"
            # pp("hhhh", 30) if @sym==9
            @scanner.nextSym.SetSym(@sym)
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
        end while (@sym > C_MAXT)
        # p "Get()2 #{@scanner.nextSym.sym}, line #{@scanner.nextSym.line}, col #{@scanner.nextSym.col}, value #{curString()}"
        
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
    def ifdefined?(n)
        return @macros[n] != nil
    end
    # get the whole preprocessor directive
    def GetPre()
        while Get() != C_PreProcessorSym
        end
        
        if @sym == C_PreProcessorSym
            Get()
             _str2 = curString()
            @directive = "#{_str1}#{_str2}"
        end
        return @directive
    end
    def pre_if()
        Get()
         n = curString()
         @scanner.delete_curline
         
         pos1 = @scanner.buffPos
         @directive=_preprocess()
         pos2 = @scanner.buffPos
         
         if n=~ /^\d+$/
            idf = (n.to_i !=0)
         else
            idf = (ifdefined?(n) && @macros[n].to_i != 0)
         end
         
         if !idf
             @scanner.delete_lines(pos1, pos2, false) # delete whole block
         else
             @scanner.delete_curline # only delete #preprocess line
         end        
        # pre = GetPre()
        
        # _str1 = curString()
        #   Get()
        #   _str2 = curString()
        #   directive = "#{_str1}#{_str2}"
        

        pre_elif(idf)
         pre_else(idf)
         pre_endif(idf)
    end
    def is_number?(s)
        s =~ /^\d+\w?$/
    end
    def delete_curline
        pos = @scanner.buffPos
        
        @scanner.delete_curline
            Get() if pos != @scanner.buffPos
    end
    def delete_prevline
        pos = @scanner.buffPos
        @scanner.delete_prevline
        # Get() if pos != @scanner.buffPos
        # p "==>sym2221:#{@sym}, #{curString()}"
    end
    def delete_lines(p1,p2,inclue = true)
        pos = @scanner.buffPos
        @scanner.delete_lines(p1, p2, inclue)
        
        Get() if pos != @scanner.buffPos
    end
    def pre_elif(idf)
        while @directive == "\#elif"
            # Get()
            Get()
             n1 = curString()
             # p "==>112:#{n1}, #{@scanner.buffPos}"
             delete_curline
             pos11 = @scanner.buffPos
             @directive=_preprocess()
             pos22 = @scanner.buffPos
             if !idf
                if is_number?(n1)
                    idf = n1.to_i != 0
                else
                    idf = ifdefined?(n1) && @macros[n1].to_i !=0
                end
                # p "==>111:#{n1}, #{idf}"
                if !idf
                    delete_lines(pos11, pos22, false)
                end
            else
                delete_lines(pos11, pos22, false)
            end
         
        end
    end
    def pre_else(idf)
        if @directive == "\#else"
            delete_curline # delete #else line
             pos11 = @scanner.buffPos
             @directive=_preprocess()
             pos22 = @scanner.buffPos
             # p "hahaha11:#{directive}"
        
            if idf
                delete_lines(pos11, pos22) # delete whole else part include
            else
                delete_curline # only delete #end line
            end
            if @directive == "\#endif"
                # p "hahaha:#{directive}"
                @scanner.delete_curline
            end
        end
    end
    def pre_ifdef(ifndef=false)
         Get()
         n = curString()
         p "n=#{n}"
         delete_curline
         idf = ifdefined?(n)
         # pp "idf=#{idf}",20
          if ifndef
              idf = !idf
          end
          
         pos1 = @scanner.buffPos
         @directive=_preprocess()
         pos2 = @scanner.buffPos
         # p "pos:#{@scanner.buffPos}"
         
 
         p "===>113:#{@scanner.buffer}"
         if !idf
             delete_lines(pos1, pos2, false) # delete whole block
         else
             delete_curline # only delete #preprocess line
         end 
          p "pos1:#{@scanner.buffPos}"
        # pre = GetPre()
        
        # _str1 = curString()
        #   Get()
        #   _str2 = curString()
        #   directive = "#{_str1}#{_str2}"
        
        # Get()
        
        pre_elif(idf)
        pre_else(idf)
        pre_endif(idf)
       
    end
    def pre_endif(idf)
        if @directive == "\#endif"
                # @scanner.delete_curline
        end
    end
    def pre_ifndef()
         pre_ifdef(true)
    end    
    # process every directive
    def preprocess_directive()
          _str1 = curString()
          # pp "preprocessor: #{@sym}, #{_str1}", 20
          Get()
          _str2 = curString()
          @directive = "#{_str1}#{_str2}"
          p "directive=#{@directive}, line=#{@scanner.currLine}"
          if  @directive == "\#include"
              Get()
              finclude = curString()
              p "@sym=#{@sym}"
              p "current sym:#{@scanner.currSym.sym}"
              p "fclude:#{finclude}"
              if finclude[0]=="\"" || finclude[0] =="\'"
                    finclude = finclude[1..finclude.size-1]
              end
              if finclude[finclude.size-1]=="\"" || finclude[finclude.size-1] =="\'"
                    finclude = finclude[0..finclude.size-2]
              end
              p "include file #{finclude}"
              include_file(finclude)  
        elsif @directive == "\#define" 
            
            Get()
            n = curString()
           
            v = @scanner.skip_curline
             p "==>define:#{n},#{v}"
            macro_str = add_macro(n, v)
            delete_prevline
            # @scanner.delete_line
            # p "pos:#{@scanner.buffPos}, buffer:#{@scanner.buffer}"
            if macro_str
                @scanner.insert_line(macro_str)
            end
        elsif @directive == "\#ifdef"
            pre_ifdef()
        elsif @directive == "\#ifndef"
            pre_ifndef()
        elsif @directive == "\#if"
            pre_if()
        else
               # @scanner.delete_curline
            return @directive
        end
        return nil
    end
    def _preprocess(stop_on_unkown_directive = true)
        while (@sym!=C_EOF_Sym)
            
             p "sym2:#{@sym}, #{curString()}"
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
        p "after preprocess: #{@scanner.buffer}"
        return @scanner.buffer
    end
    # line 98 "cs.atg"
    def C()
        pclass()
        @sstack.push(Scope.new("::"))
    	
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
    	while (@sym >= C_identifierSym && @sym <= C_numberSym ||
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
    	       @sym == C_StructSym) 
    # line 137 "cs.atg"
    		ret += Definition()
    	end
    # line 137 "cs.atg"
    	Expect(C_EOF_Sym)
    # line 137 "cs.atg"
        
        @sstack.pop
    	return ret
    end
    
    # line 246 "cs.atg"
    def Inheritance(clsdef)
        # TODO
        debug("===>Inheritance:#{@sym}, #{curString()}");
    
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
    	parent_class_name = curString()
    	p "parent class name = #{parent_class_name}"
    	
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
        debug("===>ClassDef:#{@sym}, #{curString()}")
        # line 267 "cs.atg"
        	Expect(C_classSym)
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
       
        @sstack.push(clsdef)
        debug("===>ClassBody:#{@sym}, #{curString()}");
    
    # line 298 "cs.atg"

    # line 322 "cs.atg"
    	Expect(C_LbraceSym)
    	$class_current_mode = "public"
    # line 322 "cs.atg"
    	while (@sym >= C_identifierSym && @sym <= C_numberSym ||
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
    	       @sym >= C_BangSym && @sym <= C_TildeSym) 
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

    	 @sstack.pop
    end
    
    def Enum()
        ret = ""
        debug("===>Enum:#{@sym}, #{curString()}");
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
    	        Expect(C_numberSym)
    	        v = curString()
    	        if v =~ /^([\d.]+)\w*$/
    	            v = $1
	            end
    	        base = v.to_i
    	        Get()
	        end
	        ret += "#{a} = #{base}\n"
	        if @sym == C_CommaSym
	            Get()
	            base += 1
            end
            p "==>enum22:#{SYMS[@sym]}"
            
    	end
    	
    	Expect(C_RbraceSym)
    	debug("===>Enum1:#{@sym}, #{ret}");
    	return ret
    end
    
    def StructDef()
        debug("===>StructDef:#{@sym}, #{curString()}");
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
    	debug("===>Definition:#{@sym}, #{curString()}");
    # line 219 "cs.atg"
    	if (@sym == C_classSym) 
    # line 219 "cs.atg"
    		ClassDef()
            # p "--->classDef11, #{@sym}, #{curString()}"
    	elsif (@sym == C_EnumSym)
    	    Enum()
    	elsif (@sym == C_StructSym)
    	    StructDef()
	    # elsif
	    #          [ StorageClass ] Type { "*" } identifier
	    #                                    ( FunctionDefinition | VarList ";" ) 
	    #                                    | Inheritance .
    	elsif (@sym >= C_EOF_Sym && @sym <= C_numberSym ||
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
    	           @sym == C_TypedefSym ) 
    # line 219 "cs.atg"
    		ret += Statements()
    	else 
    	    GenError(89)
	    end
	    return ret
    end
    
    def initialize(scanner, error)
        # @scanner = scanner
        #         @error = MyError.new("whaterver", scanner)
        super(scanner, error)
        @included_files = {}
        @macros = {}
        @classdefs=$g_classdefs
        p "init end"
        pclass
    end
    
    # line 561 "cs.atg"
    def FunctionBody()
    	@sstack.push(Scope.new("FunctionBody"))
    # line 561 "cs.atg"
    	ret = CompoundStatement()
    # line 562 "cs.atg"
	    @sstack.pop()
	    return ret
    end
    # line 709 "cs.atg"
    def CompoundStatement()

    # line 709 "cs.atg"
    	Expect(C_LbraceSym)
    # line 709 "cs.atg"
    	ret = Statements()
    # line 709 "cs.atg"
    	Expect(C_RbraceSym)
    	
    	return ret
    end
    
    # general statement, can be local definition or statement
    def gStatement()
        p "-->gStatement1, line #{@scanner.currLine}, sym=#{@sym}, val=#{curString()}"
        rStatement = ""
        if @sym == C_TildeSym 
            if ['class', 'struct'].include?(current_scope.name)
                Get()
                Expect(C_identifierSym)
                FunctionDefinition(current_scope.class_name)
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
    	            if _nn.sym == C_TildeSym
    	                LocalDeclaration() # deconstructor
    	            elsif _nn.sym == C_identifierSym && _c_nn == cs # constructor
    	            #    A::A
                    #_nn--->^
    	                LocalDeclaration() 
	                else
	                    count = 3
	                    _nnn = GetNext(count)
	                    while ( _nnn== C_ColonColonSym)
	                        count +=1
	                        GetNext(count)
	                        count +=1
	                        _nnn = GetNext(count)
                        end
                        if _nnn == C_LessSym || # template,e.g. A::B::C<D,F> t;
                            _nnn == C_identifierSym # A::B::C t;
                            LocalDeclaration()
                        else
	                        rStatement += Statement() # functioncall A::B::C.method();
                        end
    	            end 
    	            
    	        elsif cs == "virtual" && ['class', 'struct'].include?(current_scope.name)
    	            Get()
	                if curString() == "~"
	                    Get()
	                    Expect(C_identifierSym)
    	                FunctionDefinition(current_scope.class_name)
	                else
	                    while GetNext() != C_LparenSym
	                        Get()
                        end
                        Get()
     	                FunctionDefinition(current_scope.class_name)
    
                    end
 
    	        elsif _next == C_LparenSym  && ['class', 'struct'].include?(current_scope.name)# for constructor in class for struct
    	            p "--> in class scope"
    	            if current_scope.class_name == cs # constructor
    	                Get()
                        rStatement += FunctionDefinition(current_scope.class_name)
	                elsif cs=="~" # deconstructor
                        Get()
                        Expect(C_identifierSym)
	                    rStatement += FunctionDefinition(current_scope.class_name)                        
                    end
    	        elsif _next == C_LessSym # template
    	           LocalDeclaration() 
        	    elsif  _next == C_identifierSym || _next == C_AndSym || _next == C_StarSym ||
        	        _next == C_TypedefSym || _next == C_staticSym #||
                    # _next == C_ColonColonSym # TODO this will unsupport A::B::C.callmethod()
        	        rStatement += LocalDeclaration()
                else
                    rStatement += Statement()
                    # p "statement return #{rStatement}"
                end
        elsif (@sym >= C_staticSym && @sym <= C_stringSym || @sym == C_TypedefSym )
        # line 711 "cs.atg"
        		rStatement += LocalDeclaration()
       end
        return rStatement
    end
    # line 711 "cs.atg"
    def Statements()
        rStatement = ""
    # line 711 "cs.atg"
    	while (@sym >= C_identifierSym && @sym <= C_numberSym ||
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
               @sym == C_newSym || 
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
            p "sym:#{@sym}"
            if (@sym == C_identifierSym || @sym >= C_staticSym && @sym <= C_stringSym ||
    		    @sym == C_TypedefSym ||
    		    (@sym == C_TildeSym && GetNext() == C_identifierSym)
    		    )
    		    p "enter 1"
    		    rStatement += "\n" if rStatement != ""
    		    rStatement += gStatement()	
    		 elsif (@sym >= C_identifierSym && @sym <= C_numberSym ||
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
                       @sym == C_newSym ||
    		           @sym >= C_BangSym && @sym <= C_TildeSym) 
    # line 711 "cs.atg"
    			rStatement += "\n" if rStatement != ""
    			rStatement += Statement()
    		 else 
    		     GenError(90)
		     end
    	end # while
    	return rStatement
    # line 711 "cs.atg"
    end    
    
    
    def isTypeStart(sym)
        # pos1 = sym.pos
        _sym = sym.sym
        if _sym >= C_shortSym && _sym <= C_voidSym
            return true
        end
        if _sym == C_identifierSym
            _n = GetNextFromSym(sym)
            count = 1
            if _n == C_ColonColonSym
                count = 2
                _n = GetNextFromSym(sym, count)
                while (_n == C_ColonColonSym)
                    count += 1
                    GetNextFromSym(sym, count)
                    count +=1
                end
                
            end
                
            if _n == C_identifierSym # A::B::C d; 
                return true
            end    
             
            if _n == C_LessSym # A::B::C<
                nsym = GetNextSymFromSym(_sym, count+1)
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
    _next = GetNext()
    while (@sym != C_LparenSym && 
            (   _next == C_identifierSym || _next >= C_varSym && _next <= C_stringSym || _next >= C_staticSym && _next <= C_functionSym ||
                _next == C_StarSym || _next == C_AndSym || _next == C_ColonColonSym ||
                _next == C_LessSym # template
            )
           )
           p "---->LocalDeclaration3, #{@sym}, #{curString()}"
           
          if @sym == C_identifierSym && curString == "operator"
             break
          end
         p "-->sym:#{@sym}, next:#{_next}, line #{@scanner.nextSym.line }, v=#{curString()}"
    	if (@sym >= C_staticSym && @sym <= C_functionSym) 
    		storageclass += StorageClass()
    	elsif (@sym >= C_varSym && @sym <= C_stringSym)
            type += Type()
        elsif @sym == C_identifierSym
            type = Type()   # replace last one, to remove decorator like __dll_export
            
        end
        if type != ""
            var_type = VarType.new(type)
        end
    	while (@sym == C_StarSym || @sym == C_AndSym) 
    	    var_type.ref += 1
            # line 699 "cs.atg"
    		Get()
            # line 699 "cs.atg"
    	end
    	 _next = GetNext()
    end

    # line 702 "cs.atg"
        p "type=#{type}, storageclass=#{storageclass}, prev=#{@prev_sym}, cur=#{@sym}, val #{curString}"
    	varname = curString()
    	fname = varname
    	if fname =="operator"
    	    Get()
    	    fname = curString()
    	    Get()
	    end
	    
    	if @sym == C_LparenSym
    	    # for constructor with initialization list in classdef or sturctdef
	    else
        	Expect(C_identifierSym)
    	end
    	p "===>33:#{varname}"
    	if @sym == C_ColonColonSym
    	    # @classdefs.each{|k,v|
    	    #              p "class #{k} = #{v}"
    	    #          }
    	    if @classdefs[varname] == nil #&& varname != "std"
    	        raise "class #{varname} not found"
	        end
	        class_name = varname
    	    Get()
    	    fname = curString()
    	    p "===>332:#{fname}"
    	    Expect(C_identifierSym)
	    end
    # line 702 "cs.atg"

    # line 706 "cs.atg"
    p "sym333:#{@sym}, lin #{@scanner.currLine}"
    	if (@sym == C_LparenSym) 
    # line 706 "cs.atg"
            nn  =  GetNext(2)
            _n = GetNext()
            p "sym331:#{nn}, #{_n}"
            # if nn != C_RparenSym && nn != C_CommaSym || 
            #     # not following case
            #     # A fn(a)
            #     # A fn(a,
            #     _n == C_voidSym # A fn(void)
            #     fd = FunctionDefinition(class_name)
            # if nn != C_RparenSym && isTypeStart(GetNextSym())
            if _n == C_RparenSym || isTypeStart(GetNextSym())
                # A fn();
                # A fn(a* b)
                fd = FunctionDefinition(class_name)
            else
            	current_scope.add_var(Variable.new(varname, var_type))
                # fc = "#{varname} = #{var_type.name}.new"
                # fc += FunctionCall()
                # p "fc=#{fc}"
            	
                # line 706 "cs.atg"
                vl = VarList(var_type) # define lots of variables in one line splitted by comma

                # line 706 "cs.atg"
            	Expect(C_SemicolonSym)
            end
            
            # fd = FunctionCall()
    	elsif (@sym == C_SemicolonSym ||
    	           @sym >= C_EqualSym && @sym <= C_LbrackSym) 
    	    current_scope.add_var(Variable.new(varname, var_type))
    # line 706 "cs.atg"
            vl = VarList(var_type) # define lots of variables in one line splitted by comma
	
    # line 706 "cs.atg"
    		Expect(C_SemicolonSym)
    	else 
    	    GenError(99)
	    end
    # line 706 "cs.atg"
        if fd && fd != ""
            ret = "def #{fname}#{fd}\nend"
        else
            _ret = "#{varname}#{vl}"
            ar = _ret.split(",")
            ret = ""
            ar.each{|a|
                a = a.strip
                p "==>a=#{a}"
                if a=~ /[\w\d_]+\s*=.*?$/m
                    ret += a + "\n"
                else
                end
            }
        end
        return ret
    end
    # line 440 "cs.atg"
    def VarList(var_type)
    
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
            varname = curString()
    		ret += varname
    		Expect(C_identifierSym)
    		current_scope.add_var(Variable.new(varname, var_type))
    	    
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
    	return ret
    end

    # line 461 "cs.atg"
    def ArraySize()
    
    # line 461 "cs.atg"
    	while (@sym == C_LbrackSym) 
    # line 461 "cs.atg"
    		Get();
    # line 461 "cs.atg"
    		if (@sym >= C_identifierSym && @sym <= C_numberSym ||
    		    @sym >= C_stringD1Sym && @sym <= C_charD1Sym ||
    		    @sym == C_LbraceSym ||
    		    @sym == C_LparenSym ||
    		    @sym == C_StarSym ||
    		    @sym == C_AndSym ||
    		    @sym >= C_PlusSym && @sym <= C_MinusSym ||
    		    @sym >= C_PlusPlusSym && @sym <= C_MinusMinusSym ||
    		    @sym >= C_newSym && @sym <= C_DollarSym ||
    		    @sym >= C_BangSym && @sym <= C_TildeSym) 
    # line 461 "cs.atg"
    			ConstExpression()
    		end
    # line 461 "cs.atg"
    		Expect(C_RbrackSym)
    	end
    	return ""
    end    
    # line 465 "cs.atg"
    def FunctionDefinition(class_name = nil)
        ret = ""
        if class_name
 	        classdef = @classdefs[class_name]
        end
    # line 466 "cs.atg"

    # line 509 "cs.atg"
    	ret += FunctionHeader()
    # line 509 "cs.atg"
        # p "--->FunctionDefinition sym:#{@sym}"
        if @sym == C_SemicolonSym 
            #if just function declaration without body
            return ""
        elsif @sym == C_EqualSym
            Get()
            Expression()
            Expect(C_SemicolonSym)
        else

            @sstack.push(classdef) if classdef
            if @sym == C_ColonSym
                # initialization list, for constructor of class/struct
                
                i_list = ""
                Get()
                Expect(C_identifierSym)
                m = curString()
                
                Expect(C_LparenSym)
                v = ActualParameters()
                Expect(C_RparenSym)
                i_list += "@#{m} = #{v}\n"
                while (@sym == C_CommaSym)
                     Get()
                     Expect(C_identifierSym)
                     m = curString()
                     Expect(C_LparenSym)
                     v = Expression()
                     Expect(C_RparenSym)
                     
                     i_list += "@#{m} = #{v}\n"
                     
                end
            end
        	fb = FunctionBody()
        	fb = i_list + fb if i_list
        	@sstack.pop if classdef
    	end
    # line 510 "cs.atg"
        
        if (fb && fb != "")
            ret = "#{ret}\n#{fb}"
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
    	    @sym >= C_varSym && @sym <= C_stringSym) 
    # line 545 "cs.atg"
    		ret += FormalParamList()
    	end
    # line 545 "cs.atg"
    	Expect(C_RparenSym)
    # line 546 "cs.atg"
        
        if @sym == C_identifierSym && curString() == 'const'
            Get()
            
        end
        
        return "(#{ret})"
 
    end
    
    # line 567 "cs.atg"
    def FormalParamList()
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
    	type = Type()
    # line 442 "cs.atg"
    	while (@sym == C_StarSym || @sym == C_AndSym) 
    # line 442 "cs.atg"
    # line 442 "cs.atg"
    		Get()
    # line 442 "cs.atg"
            # type->refLevel++;
    	end
    # line 444 "cs.atg"
   
        if @sym == C_identifierSym 
            ret += curString()
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
    	if (@sym == C_staticSym) 
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
    # line 400 "cs.atg"
    def Type()
        debug("---->type:#{@sym}")
        ret = ""
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
    			if (Sym == C_intSym) 
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
                p "sym1:#{@sym}"
		        
    		    while @sym == C_ColonColonSym
    		        Get()
    		        ret += "::#{curString()}"
    		        Get()
		        end
                p "sym2:#{@sym}"
		        if @sym == C_LessSym # stl type
		            Get()
		            FormalParamList()
		            Expect(C_GreaterSym)
	            end
	            p "sym3:#{@sym}, val #{curString()}"
    		else 
    		    GenError(95)
    	end # case
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
    # line 657 "cs.atg"
    def Statement()
        stmt = ""
    # line 657 "cs.atg"
    	debug("====>statement:#{@sym},#{curString()}")
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
            # C_DollarSym       ,
    		C_BangSym         ,
    		C_TildeSym  
    # line 666 "cs.atg"
    			stmt += AssignmentStatement()
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
	    p "current symbol:#{curString()}, #{@scanner.nextSym.line}"
	    debug("====>statement1:#{stmt}")
        return stmt
    end

    # line 679 "cs.atg"
    def AssignmentStatement()
        ret = ""
    # line 679 "cs.atg"
    	debug("===>AssignmentStatement:#{@sym}")
    # line 679 "cs.atg"
    	ret += Expression()
    # line 679 "cs.atg"
    	Expect(C_SemicolonSym)
    # line 679 "cs.atg"
    	debug("===>AssignmentStatement1:#{ret}")
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
        @sstack.push(Scope.new("DoStatement"))
	    
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
	    @sstack.pop()
	    return ret
    end

    # line 726 "cs.atg"
    def ForStatement()
        ret = ""
	    @sstack.push(Scope.new("ForStatement"))
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
        p "exp1:#{exp1}"	

	
    # line 738 "cs.atg"
	        exp2 = ""
    # line 739 "cs.atg"
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
    # line 739 "cs.atg"
    		exp2 = Expression()
    	end
    # line 740 "cs.atg"
	

   	
	p "exp2:#{exp2}"
    # line 746 "cs.atg"
    	Expect(C_SemicolonSym)
    # line 746 "cs.atg"
	        
    # line 747 "cs.atg"

	
	    exp3 = ""
    # line 754 "cs.atg"
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
    # line 755 "cs.atg"
		
    # line 758 "cs.atg"
    		exp3= Expression()
    # line 759 "cs.atg"
		
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
begin
    #{stmt}
    
    #{exp3}
end while (#{exp2})
HERE
        # ret = ret.gsub(/next|continue/m, exp2)
	    @sstack.pop()
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
    @sstack.push(Scope.new("SwitchStatement"))
    
    	stmt = Statement()
    	ret =<<HERE
case #{exp}\n
#{stmt}
end
HERE
    
    @sstack.pop()
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
    	
    	@sstack.push(Scope.new("WhileStatement"))

    # line 922 "cs.atg"
    	stmt = Statement()
    # line 924 "cs.atg"
	ret =<<HERE
while (#{exp})
    #{stmt}
end
HERE
	    @sstack.pop
	    return ret
    end

 
    # line 966 "cs.atg"
    def Expression
        ret = ""
    # line 966 "cs.atg"
    	debug("===>Expression:#{@sym}")
    	

    	if @sym == C_LbraceSym  # {a, b, c}
    	    Get()
    	    Expression()
    	    while (@sym==C_CommaSym)
    	        Get()
    	        Expression()
	        end
    	    Expect(C_RbraceSym)
    	    ret += "\"\""
	    else
    	
        # line 966 "cs.atg"
        	c = Conditional()
        	ret += c
        	debug("===>Expression-1:#{ret}")
    	
        # line 966 "cs.atg"
        	while (@sym == C_EqualSym ||
        	       @sym >= C_StarEqualSym && @sym <= C_GreaterGreaterEqualSym ||
        	       @sym == C_QuestionMarkSym
        	       ) 
        # line 966 "cs.atg"
                debug("===>Expression0:#{ret}")
                if @sym == C_QuestionMarkSym  # exp ? A:B
                    Get()
                    ret += "?#{Expression()}"
                    Expect(C_ColonSym)
                    ret += "#{Expression()}"
                else
	                
            		ret += AssignmentOperator()
            		debug("===>Expression00:#{ret}")
        	
            # line 966 "cs.atg"
            		ret += Expression()
            		debug("===>Expression000:#{ret}")
        	
            # line 967 "cs.atg"

                    # printf("===>AssignmentOperator\n")
                        # if (!doAssign()) 
                        #                       continue;
                end
                
        	end # while
    	end
    	
    	if @sym!= C_CommaSym && @sym!= C_RparenSym && @sym!= C_SemicolonSym && @sym!=C_RbrackSym && @sym!=C_RbraceSym &&
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
	    
    	debug("===>Expression1:#{ret}")
    	return ret
    end

    # line 964 "cs.atg"
    def ConstExpression()
    
    # line 964 "cs.atg"
    	Expression()
    end

    
    # line 2134 "cs.atg"
    def AssignmentOperator()
        ret= @scanner.GetName
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
    		else 
    		    GenError(97)
    	end
        # p "getname1:#{@scanner.GetName}"
        p "AssignmentOperator:#{ret}"
        return ret
    end
    
    def Conditional()
    	debug("===>Conditional:#{@sym}")
    
    # line 975 "cs.atg"
    	ret = LogORExp()
    	debug("===>Conditional1:#{ret}")
    	return ret
    end
    def LogORExp()
        ret = ""
    	debug("===>LogORExp")
    
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
	      debug("===>LogORExp1:#{ret}")
      	
    end
    def LogANDExp()
        ret = ""
    	debug("===>LogANDExp")
    
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
    debug("===>LogANDExp1:#{ret}")
	
        return  ret
    end
    def InclORExp()
        ret = ""
    	debug("===>InclORExp")

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
    	debug("===>InclORExp1:#{ret}")
    	
    	return ret 
    end

    # line 1101 "cs.atg"
    def ExclORExp()
        ret =""
    	debug("===>ExclORExp")
    
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
    	return ret
    end

    # line 1103 "cs.atg"
    def ANDExp()
        ret = ""
    	debug("===>ANDExp")

    # line 1103 "cs.atg"
    	ret = EqualExp()
    	
    # line 1103 "cs.atg"
    	while (@sym == C_AndSym) 
    # line 1103 "cs.atg"
    		ret += curString()
        	
    		Get()
    # line 1103 "cs.atg"
    		ret += EqualExp()
    	end
    	return ret
    end

    # line 1105 "cs.atg"
    def EqualExp()
        ret = ""
    	debug("===>EqualExp:#{@sym}")

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
    		     debug("===>EqualExp1:#{ret}")
             	
    	
    # line 1157 "cs.atg"
        return ret
  
    end
    
    def curLine()
        @scanner.currLine
    end
    def curCol()
        @scanner.currCol
    end
    def curString()
        ret = @scanner.GetName()
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
    # line 1182 "cs.atg"
    def RelationExp()
    	debug("===>RelationExp")
        ret = ""
    # line 1183 "cs.atg"

    
        
    # line 1190 "cs.atg"
    	ret += ShiftExp()
    # line 1190 "cs.atg"
    	while (@sym == C_LessSym ||
    	       @sym >= C_GreaterSym && @sym <= C_GreaterEqualSym) 
    # line 1190 "cs.atg"
    		ret += curString()
            	debug("===>RelationExp3")
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
    		ret += ShiftExp()
    		
		end
    # line 1191 "cs.atg"
    # line 1193 "cs.atg"

    # line 1222 "cs.atg"

    	debug("<===>RelationExp:#{ret}")
    	return ret
    end

    # line 1248 "cs.atg"
    def ShiftExp()
        ret = ""
        debug("===>ShiftExp")
    	ret += AddExp()
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
    # line 1248 "cs.atg"
	    end
	    debug("===>ShiftExp1: #{ret}")
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
    		MultExp()
    # line 1253 "cs.atg"

    		             
	    end
	    
	    return ret
    end
    # line 1337 "cs.atg"
    def MultExp()
        p "===>MultExp:#{@sym}, #{curString}"
        
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
	    
	    p "==>MultExp:#{ret}"
	    return ret
    end
    
    # line 1396 "cs.atg"
    def CastExp()
    
    # line 1396 "cs.atg"
    	debug("===>CastExp")
    # line 1397 "cs.atg"

    # line 1405 "cs.atg"
        ret =	UnaryExp()
    # line 1407 "cs.atg"
       p "<===CastExpCastExp:#{ret}"
	   return ret
    end
=begin    
    # line 1538 "cs.atg"
    def UnaryExp()
        ret = ""
    # line 1538 "cs.atg"
    	debug("===>UnaryExp1")
    	
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
        p "====>PostFixExp:#{@sym}"
    # line 1572 "cs.atg"
    # line 1573 "cs.atg"
    	ret += Primary()
        # ret += curString()
        # p "@sym:#{@sym}"
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
    				ret += "+=1"
        			Get()
    # line 2027 "cs.atg"

    				              
                    # break;
    			when C_MinusMinusSym  
    # line 2079 "cs.atg"
    				ret += "-=1"
        			Get()
    # line 2081 "cs.atg"

    				                      
                    # break;
    			else 
    			    GenError(109)
    		end # case
    	end # while
    	p "==>PostFixExp1:#{ret}"
    	return ret
    end
    # line 1538 "cs.atg"
    def UnaryExp()
        ret = ""
    # line 1538 "cs.atg"
    	debug("===>UnaryExp:#{@sym}, #{curString()}");
    	pp "unaryexp", 20
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
        	
    	elsif (@sym >= C_identifierSym && @sym <= C_numberSym ||
    	    @sym >= C_stringD1Sym && @sym <= C_charD1Sym ||
    	    @sym == C_LbraceSym ||
    	    @sym == C_LparenSym ||
            # @sym >= newSym && @sym <= C_DollarSym) 
            @sym == C_newSym) 
            
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
    	    pp("dff", 100)
    	    GenError(107)
	    end
	    p "<=====UnaryExp1:#{ret}"
	    return ret
    end
    
    # line 2791 "cs.atg"
    def UnaryOperator()
        ret = ""
        ret += curString()
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
        p "=====>Primary:#{@sym}, #{curString()}"
        ret = ""
    # line 2328 "cs.atg"

    # line 2475 "cs.atg"
    	case @sym
    		when C_identifierSym  
    		    varname = curString()
                
            	Get()
    # line 2334 "cs.atg"
                if @sym == C_ColonColonSym
                    ret += varname
                    while (@sym == C_ColonColonSym)
                        p "====>233:#{curString()}"
                        # line 2353 "cs.atg"
                        	Get();
                        # line 2353 "cs.atg"
                    
                            ret += "::#{curString()}"
                        	Expect(C_identifierSym)
                	end
            	else
    		    	ccs =  current_class_scope
        			if ccs && ccs.vars[varname]
        			    ret += "@#{varname}"
    			    else
    			        ret += varname
    			    end
    		    end
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

    	
    		when C_newSym  
    		    p "--->new:#{curString()}"
                # ret += curString()
            	
    # line 2475 "cs.atg"
    			Get()
    # line 2475 "cs.atg"
                ret += Creator()
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

    		when C_LparenSym  
    		    # ret += curString()
            	
    # line 2593 "cs.atg"
    			Get()
    # line 2593 "cs.atg"
    p "sym555:#{@sym}, val #{curString()}"
                if @sym == C_identifierSym || @sym >=C_shortSym && @sym <= C_stringSym
                    _next = GetNext()
                    _next2 = GetNext(2)
                    if _next == C_RparenSym || 
                        ( ( _next == C_StarSym || _next == C_AndSym ) && (_next2 < C_identifierSym || _next2 > C_charD1Sym) )
                        FullType()
                        Expect(C_RparenSym)
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
    		    ret += "?#{Expression} :#{Expression}"
    		else 
    		    GenError(112)
    	end # case
    	p "=====>Primary1:#{ret}"
        
        return ret
    end
    
    # line 2597 "cs.atg"
    def FunctionCall()
        pp "functioncall()",20
        ret  =""
    # line 2597 "cs.atg"
    	Expect(C_LparenSym);
    # line 2598 "cs.atg"

    	     debug("=====>FunctionCall");
    	  
    # line 2605 "cs.atg"
    	if (@sym >= C_identifierSym && @sym  <= C_numberSym ||
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
        p "====>FunctionCall1:(#{ret})"
        return "(#{ret})"
    end

    # line 2660 "cs.atg"
    def ActualParameters()
        ret = ""
    # line 2661 "cs.atg"

    	

    # line 2668 "cs.atg"
    	ret += Expression()
    # line 2669 "cs.atg"

    	    
    # line 2701 "cs.atg"
    	while (@sym  == C_CommaSym) 
    # line 2701 "cs.atg"
    		ret += curString()
    		
    		Get()
    # line 2701 "cs.atg"
    		ret += Expression()
    # line 2703 "cs.atg"

	    end
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
        
        ret = "#{className}.new(#{fCall})"
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
def test
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
s =<<HERE
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
s = <<HERE
{

   a[0]=0;
}
HERE
s=<<HERE
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

s=<<HERE
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


s =<<HERE
#dfsfffff
#adfa
ff=1;
HERE
s =<<HERE
//a = 1;
//#define bbc

//abc=1;

#include "a.h"

//#fdaaslk
//c=1;
//#include "bss.h"
//b =1;
HERE
s=<<HERE
#include "a.h"
HERE
s=<<HERE

#define		JDT_WARNING_BLOCK	3
#ifdef JDT_WARNING_BLOCK1
a = 1
#else
a = 2
#endif

HERE

s=<<HERE
B c = A(b);
HERE
s=<<HERE
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
s=<<HERE
//StdMap<SBOString, FCRoundingStruct, False, False> currencyRoundingMap;
std::map<SBOString, FCRoundingStruct, False, False> currencyRoundingMap;

HERE
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

end
#=end
test