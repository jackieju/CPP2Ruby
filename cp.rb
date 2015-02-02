load 'scanner.rb'
load 'cr_parser.rb'
load 'error.rb'

def format_msg(msg, cat="", stack=0)
    _stack = stack + 1
    
    cat = cat.upcase
    trace = ""
    ret = ""
    
    time = Time.now
    st =  "#{time.strftime("%Y-%m-%d %H:%M:%S")}.#{time.usec.to_s[0,2]}"
    
    begin
        raise Exception.new
    rescue Exception=>e
        if e.backtrace.size >=2 && stack >= 0
            _stack  += 1
            _stack = e.backtrace.size-1 if _stack >= e.backtrace.size
            trace = e.backtrace[2.._stack].join("\n") 
        end
    end    
    
    m = msg
    if msg.is_a?(Exception)
        m = "!!!Exception:#{m.inspect}:\n#{m.backtrace[0..9].join("\n")}"
    end
    m_cat = ""
    m_cat = "\##{cat}" if cat && cat!=""
    ret = "#{$$}|#{st}#{m_cat}]#{m}(#{trace})"

    return ret
end

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
C_EOF_Sym =	0	# EOF */
C_identifierSym =	1	# identifier */
C_numberSym =	2	# number */
C_hexnumberSym =	3	# hexnumber */
C_stringD1Sym	= 4	# string1 */
C_charD1Sym	= 5	# char1 */
C_librarySym	= 6	# library */
C_useSym	= 7	# "use" */
C_PointSym	= 8	# "." */
C_SemicolonSym	= 9	# ";" */
C_loadSym	= 10	# "load" */
C_EqualSym	= 11	# "=" */
C_inheritSym	= 12	# "inherit" */
C_classSym	= 13	# "class" */
C_LbraceSym	= 14	# "{" */
C_RbraceSym	= 15	# "}" */
C_staticSym	= 16	# "static" */
C_mySym = 	17	# "my" */
C_functionSym	= 18	# "function" */
C_objectSym	= 19	# "object" */
C_varSym =	20	 # "var" */
C_mixedSym	= 21	# "mixed" */
C_shortSym	= 22	# "short" */
C_intSym	= 23	# "int" */
C_longSym	= 24	# "long" */
C_floatSym	= 25	# "float" */
C_unsignedSym	= 26	# "unsigned" */
C_charSym	= 27	# "char" */
C_doubleSym	= 28	# "double" */
C_voidSym	= 29	# "void" */
C_stringSym	= 30	# "string" */
C_CommaSym	= 31	# "," */
C_LbrackSym	= 32	# "[" */
C_RbrackSym	= 33	# "]" */
C_LparenSym	= 34	# "(" */
C_RparenSym	= 35	# ")" */
C_StarSym	= 36	# "*" */
C_caseSym	= 37	# "case" */
C_ColonSym	= 38	# ":" */
C_defaultSym	= 39	# "default" */
C_breakSym	= 40	# "break" */
C_continueSym	= 41	# "continue" */
C_doSym	= 42	# "do" */
C_whileSym	= 43	# "while" */
C_forSym	= 44	# "for" */
C_ifSym	= 45	# "if" */
C_elseSym	= 46	# "else" */
C_returnSym	= 47	# "return" */
C_switchSym	= 48	# "switch" */
C_BarBarSym	= 49	# "||" */
C_AndAndSym	= 50	# "&&" */
C_BarSym	= 51	# "|" */
C_UparrowSym	= 52	# "^" */
C_AndSym	= 53	# "&" */
C_EqualEqualSym	= 54	# "==" */
C_BangEqualSym	= 55	# "!=" */
C_LessSym	= 56	# "<" */
C_GreaterSym	= 57	# ">" */
C_LessEqualSym	= 58	# "<=" */
C_GreaterEqualSym	= 59	# ">=" */
C_LessLessSym	= 60	# "<<" */
C_GreaterGreaterSym	= 61	# ">>" */
C_PlusSym	= 62	# "+" */
C_MinusSym	= 63	# "-" */
C_SlashSym	= 64	# "/" */
C_PercentSym	= 65	# "%" */
C_PlusPlusSym	= 66	# "++" */
C_MinusMinusSym	= 67	# "--" */
C_MinusGreaterSym	= 68	# "->" */
C_ColonColonSym	= 69	# "::" */
C_newSym	= 70	# "new" */
C_StarEqualSym	= 71	# "*=" */
C_SlashEqualSym	= 72	# "/=" */
C_PercentEqualSym	= 73	# "%=" */
C_PlusEqualSym	= 74	# "+=" */
C_MinusEqualSym	= 75	# "-=" */
C_AndEqualSym	= 76	# "&=" */
C_UparrowEqualSym	= 77	# "^=" */
C_BarEqualSym	= 78	# "|=" */
C_LessLessEqualSym	= 79	# "<<=" */
C_GreaterGreaterEqualSym	= 80	# ">>=" */
C_BangSym	= 81	# "!" */
C_TildeSym	= 82	# "~" */
C_No_Sym	= 83	# not */
C_PreProcessorSym	= 84	# PreProcessor */
C_MAXT    =  C_No_Sym   # Max Terminals */


class Parser < CRParser
    # def Parse()
    #     @scanner->Reset()
    #     Get()
    #     C()
    # end
    def Get
        p "sym1=#{@sym}"
         begin 
            @sym = @scanner.Get()
            p "sym2=#{@sym}"
            pp("hhhh", 30) if @sym==9
            @scanner.nextSym.SetSym(@sym)
            if (@sym <= C_MAXT) 
                @error.errorDist +=1
            
            else 
                if (@sym == C_PreProcessorSym) # /*86*/
                  # line 65 "cs.atg"
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
                    @scanner.nextSym = @scanner.CurrSym;
                end
            end
        end while (@sym > C_MAXT)
        p "sym2#{@sym}"
        
    end
    
    # def initialize(scanner, error)
    #     @scanner = scanner
    #     @error = MyError.new("whaterver", scanner)
    # end

    # line 561 "cs.atg"
    def FunctionBody()

    # line 561 "cs.atg"
    	CompoundStatement()
    # line 562 "cs.atg"
	
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
    	       @sym >= C_BangSym && @sym <= C_TildeSym)  do
    # line 711 "cs.atg"
    		if (@sym >= C_staticSym && @sym <= C_stringSym) 
    # line 711 "cs.atg"
    			LocalDeclaration()
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
    			rStatement += Statement()+"\n"
    		 else 
    		     GenError(90)
		     end
    	end
    	return rStatement
    # line 711 "cs.atg"
    end    
    # line 689 "cs.atg"
   def LocalDeclaration()
        return
    # line 690 "cs.atg"



    # line 696 "cs.atg"
    	if (@sym >= C_varSym && @sym <= C_stringSym) 
    # line 696 "cs.atg"
    		Type(type)
    	elsif (@sym >= C_staticSym && @sym <= C_functionSym) 
    # line 696 "cs.atg"
    		StorageClass()
    # line 696 "cs.atg"
    		if (@sym >= C_varSym && @sym <= C_stringSym) 
    # line 696 "cs.atg"
    			Type(type)  
    		end  		
    	else 
    	    GenError(98)
	    end
    # line 699 "cs.atg"
    	while (@sym == C_StarSym) 
    # line 699 "cs.atg"
    		Get()
    # line 699 "cs.atg"
    	end
    # line 702 "cs.atg"
    	Expect(C_identifierSym)
    # line 702 "cs.atg"

    # line 706 "cs.atg"
    	if (@sym == C_LparenSym) 
    # line 706 "cs.atg"
    		FunctionDefinition()
    	elsif (@sym == C_SemicolonSym ||
    	           @sym >= C_EqualSym && @sym <= C_LbrackSym) 
    # line 706 "cs.atg"
    # line 706 "cs.atg"
    		Expect(C_SemicolonSym)
    	else 
    	    GenError(99)
	    end
    # line 706 "cs.atg"
    end

    # line 657 "cs.atg"
    def Statement()
        stmt = ""
    # line 657 "cs.atg"
    	debug("====>statement")
    # line 658 "cs.atg"
    	while (@sym == C_caseSym ||
    	       @sym == C_defaultSym) 
    # line 658 "cs.atg"
    		Label()
    	end
    # line 666 "cs.atg"
        
    	case (@sym) 
    		when C_identifierSym   ,
    		C_numberSym       ,
    		C_stringD1Sym     ,
    		C_charD1Sym       ,
    		C_LbraceSym       ,
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
    			stmt = AssignmentStatement()
                # break
    		when C_breakSym  
    # line 666 "cs.atg"
    			stmt = BreakStatement()
                # break
    		when C_continueSym  
    # line 667 "cs.atg"
    			stmt = ContinueStatement()
                # break
    		when C_doSym  
    # line 668 "cs.atg"
    			stmt = DoStatement()
                # break
    		when C_forSym  
    # line 668 "cs.atg"
    			stmt = ForStatement()
                # break
    		when C_ifSym  
    # line 669 "cs.atg"
    			stmt = IfStatement()
                # break
    		when C_SemicolonSym  
    # line 669 "cs.atg"
    			stmt = NullStatement()
    			#break
    		when C_returnSym  
    # line 670 "cs.atg"
    			stmt = ReturnStatement()
    			#break
    		when C_switchSym  
    # line 670 "cs.atg"
    			stmt = SwitchStatement()
    			#break
    		when C_whileSym  
    # line 671 "cs.atg"
    			stmt = WhileStatement()
    			#break
            else 
                GenError(96) 
    	end
    # line 671 "cs.atg"
	    
	    debug("====>statement1:#{stmt}")
        return stmt
    end

    # line 679 "cs.atg"
    def AssignmentStatement()
        ret = ""
    # line 679 "cs.atg"
    	debug("===>AssignmentStatement1")
    # line 679 "cs.atg"
    	ret += Expression()
    # line 679 "cs.atg"
    	Expect(C_SemicolonSym)
    # line 679 "cs.atg"
    	debug("===>AssignmentStatement2")
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
    end

    # line 713 "cs.atg"
    def ContinueStatement()

    # line 713 "cs.atg"
    	Expect(C_continueSym)
    # line 714 "cs.atg"
	
	       
	
    # line 721 "cs.atg"
    	Expect(C_SemicolonSym)
    # line 721 "cs.atg"
    end

    # line 724 "cs.atg"
    def DoStatement()

    # line 724 "cs.atg"
    	Expect(C_doSym)
    # line 724 "cs.atg"
    	Statement()
    # line 724 "cs.atg"
    	Expect(C_whileSym)
    # line 724 "cs.atg"
    	Expect(C_LparenSym)
    # line 724 "cs.atg"
    	Expression()
    # line 724 "cs.atg"
    	Expect(C_RparenSym)
    # line 724 "cs.atg"
    	Expect(C_SemicolonSym)
    # line 724 "cs.atg"
	        
    end

    # line 726 "cs.atg"
    def ForStatement()

    # line 726 "cs.atg"
    	Expect(C_forSym)
    # line 726 "cs.atg"
    	Expect(C_LparenSym)
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
    		Expression()
    	end
    # line 726 "cs.atg"
    	Expect(C_SemicolonSym)
    # line 727 "cs.atg"
	

	
    # line 738 "cs.atg"
	        
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
    		Expression()
    	end
    # line 740 "cs.atg"
	
	   
	
    # line 746 "cs.atg"
    	Expect(C_SemicolonSym)
    # line 746 "cs.atg"
	        
    # line 747 "cs.atg"

	
	
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
    		Expression()
    # line 759 "cs.atg"
		
    	end
    # line 768 "cs.atg"
    	Expect(C_RparenSym)
    # line 768 "cs.atg"
    	Statement()
    # line 769 "cs.atg"
	

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
	
       if _else != nil
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
	        
    end

    # line 860 "cs.atg"
    def ReturnStatement()

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
    		Expression()
    	end
    # line 861 "cs.atg"
	
    # line 864 "cs.atg"
    	Expect(C_SemicolonSym)
    # line 864 "cs.atg"
	        
    end

    # line 867 "cs.atg"
    def SwitchStatement()

    # line 867 "cs.atg"
    	Expect(C_switchSym)
    # line 867 "cs.atg"
    	Expect(C_LparenSym)
    # line 869 "cs.atg"
    	Expression()
    # line 872 "cs.atg"
    	Expect(C_RparenSym)
    # line 872 "cs.atg"
    	Statement()
    end

    # line 876 "cs.atg"
    def WhileStatement()

    # line 876 "cs.atg"
    	Expect(C_whileSym)
    # line 876 "cs.atg"
    	Expect(C_LparenSym)
    # line 877 "cs.atg"
	
	 
    # line 886 "cs.atg"
    	Expression()
    # line 887 "cs.atg"
	
    # line 922 "cs.atg"
    	Expect(C_RparenSym)
    # line 922 "cs.atg"
    	Statement()
    # line 924 "cs.atg"
	
	 
    end

 
    # line 966 "cs.atg"
    def Expression
        ret = ""
    # line 966 "cs.atg"
    	debug("===>Expression")
    # line 966 "cs.atg"
    	c = Conditional()
    	ret += c
    	debug("===>Expression-1:#{ret}")
    	
    # line 966 "cs.atg"
    	while (@sym == C_EqualSym ||
    	       @sym >= C_StarEqualSym && @sym <= C_GreaterGreaterEqualSym) 
    # line 966 "cs.atg"
            debug("===>Expression0:#{ret}")
	
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
    	debug("===>Expression1:#{ret}")
    	return ret
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
    	debug("===>Conditional")
    
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
    	debug("===>EqualExp")

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
    
    def curString()
        ret = @scanner.GetName()
        p "------#{ret}"
        return ret
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
        ret = ""
    # line 1337 "cs.atg"
    # line 1338 "cs.atg"
    	ret += CastExp()
    # line 1339 "cs.atg"
    # ret += curString()

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
    				Expect(RbrackSym)
    # line 1575 "cs.atg"

    			
    			when C_LparenSym  
    # line 1647 "cs.atg"

    
    				    
    # line 1733 "cs.atg"
                    # ret += FunctionCall(&fn)
                    ret += FunctionCall()
    # line 1734 "cs.atg"
    				
    			when C_PointSym  
    # line 1736 "cs.atg"
    				       
	ret += curString()

    # line 1742 "cs.atg"
    				Get()
    # line 1742 "cs.atg"

    # line 1779 "cs.atg"
    				if (@sym == C_identifierSym) 
    				    p "get identifier"
    # line 1759 "cs.atg"
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
                        ret += FunctionCall
    				end
    # line 1896 "cs.atg"

    				

    			
    			when C_MinusGreaterSym  
    # line 1937 "cs.atg"
    				
    # line 1937 "cs.atg"
    				ret += curString()
        			Get()
    # line 1937 "cs.atg"
                	
    				while (@sym == C_LbraceSym) 
    # line 1937 "cs.atg"
    					ret += curString()
            			Get()
    # line 1937 "cs.atg"
    					
				    end
    # line 1937 "cs.atg"
    				Expect(identifierSym)
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
    				ret += curString()
        			Get()
    # line 2027 "cs.atg"

    				              
                    # break;
    			when C_MinusMinusSym  
    # line 2079 "cs.atg"
    				ret += curString()
        			Get()
    # line 2081 "cs.atg"

    				                      
                    # break;
    			else 
    			    GenError(109)
    		end # case
    	end # while
    	p "==>primary:#{ret}"
    	return ret
    end
    # line 1538 "cs.atg"
    def UnaryExp()
        ret = ""
    # line 1538 "cs.atg"
    	debug("===>UnaryExp:#{@sym}");
    	pp "unaryexp", 20
    # line 1539 "cs.atg"
    	if (@sym >= C_identifierSym && @sym <= C_numberSym ||
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
    			ret += curString()
            	Get()
    		elsif (@sym == C_MinusMinusSym) 
    # line 1539 "cs.atg"
    			ret += curString()
            	Get();
    		else GenError(106);
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
    # line 2327 "cs.atg"
    def Primary()
        ret = ""
    # line 2328 "cs.atg"
	ret += curString()

    # line 2475 "cs.atg"
    	case @sym
    		when C_identifierSym  
    # line 2334 "cs.atg"
    			Get();
    # line 2335 "cs.atg"

    	
    # line 2339 "cs.atg"
    			while (@sym >= C_ColonColonSym && @sym <= C_HashHashSym) 
    # line 2353 "cs.atg"
    				if (@sym == C_HashHashSym) 
    # line 2339 "cs.atg"
    					Get();
    # line 2339 "cs.atg"
    					Expect(C_identifierSym);
    # line 2340 "cs.atg"
    				elsif (@sym == C_ColonColonSym) 
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


    	
    		when C_newSym  
    # line 2475 "cs.atg"
    			Get()
    # line 2475 "cs.atg"
                # Creator();
                # break;
            # when C_DollarSym  
    # line 2477 "cs.atg"
                # Get();
    # line 2478 "cs.atg"
    			
    		when C_stringD1Sym  
    # line 2512 "cs.atg"
    			Get();
    # line 2513 "cs.atg"

    		
    		when C_charD1Sym  
    # line 2563 "cs.atg"
    			Get();
    # line 2564 "cs.atg"

    			        
    		when C_numberSym  
    # line 2572 "cs.atg"
    			Get();
    # line 2573 "cs.atg"

    		when C_LparenSym  
    # line 2593 "cs.atg"
    			Get()
    # line 2593 "cs.atg"
    			ret +=Expression()
    # line 2593 "cs.atg"
    			Expect(RparenSym)
                # break;
    		when C_LbraceSym  
    # line 2594 "cs.atg"
                # SetDef();
                # break;
    		else 
    		    GenError(112)
    	end # case
        return ret
    end
    
    # line 2597 "cs.atg"
    def FunctionCall()
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
        return ret
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
    		
    		Get();
    # line 2701 "cs.atg"
    		ret += Expression();
    # line 2703 "cs.atg"

	    end
    # line 2776 "cs.atg"
        return ret
    end


end  # class Parser

######### test ################
=begin
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

scanner = CScanner.new(s, false)
p "==>#{scanner.nextSym}"

error = MyError.new("whaterver", scanner)
parser = Parser.new(scanner, error)
parser.Get
puts "FunctionBody return #{parser.FunctionBody}"
=end
