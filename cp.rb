require 'scanner.rb'
require 'cr_parser.rb'
require 'error.rb'
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
  if (Sym == n) 
      Get()
      GenError(n)
  end
end
=end
EOF_Sym =	0	# EOF */
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
    
    def Get
        p "sym=#{@sym}"
         begin 
            @sym = @scanner.Get()
            @scanner.NextSym.SetSym(Sym)
            if (@sym <= C_MAXT) 
                @error.ErrorDist +=1
            
            else 
                if (@sym == C_PreProcessorSym) # /*86*/
                  # line 65 "cs.atg"
=begin
                  	char str[256];
                  	str = @scanner.GetName(@scanner.NextSym)
              	
                  	p = strchr(str, ' ');
        
                  	if ( p != NULL )
                  	    *p=0; 
                  	    directive = str + sizeof(char);
                  	    #// proce include 
                  	    if (strcmp(str, "include") == 0){
                  	            // get content
                  	            p += sizeof(char);
                  	            while ( (*p == ' ' || *p == '\t' ) && *p != '\0' ){
                  	                    p += sizeof(char);              
                  	            }
                  	            if ( *p != '\0' )
                  	                    content = p;
                  	    end

                  	end
=end
              	    
                else
                    #/* Empty Stmt */ ;
                    @scanner.NextSym = @scanner.CurrSym;
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
    	Statements()
    # line 709 "cs.atg"
    	Expect(C_RbraceSym)
    end
    # line 711 "cs.atg"
    def Statements()

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
    	       @sym >= C_newSym && @sym <= C_DollarSym ||
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
    		           @sym >= C_newSym && @sym <= C_DollarSym ||
    		           @sym >= C_BangSym && @sym <= C_TildeSym) 
    # line 711 "cs.atg"
    			Statement()
    		 else 
    		     GenError(90)
		     end
    	end
    # line 711 "cs.atg"
    end    
    # line 689 "cs.atg"
   def LocalDeclaration()
    
    # line 690 "cs.atg"



    # line 696 "cs.atg"
    	if (@sym >= C_varSym && @sym <= C_stringSym) 
    # line 696 "cs.atg"
    		Type(type)
    	elsif (@sym >= C_staticSym && @sym <= C_functionSym) 
    # line 696 "cs.atg"
    		StorageClass();
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
    		VarList(type, szName)
    # line 706 "cs.atg"
    		Expect(C_SemicolonSym)
    	else 
    	    GenError(99)
	    end
    # line 706 "cs.atg"
    end

    # line 657 "cs.atg"
    def Statement()

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
    		when identifierSym: 
    		when numberSym: 
    		when stringD1Sym: 
    		when charD1Sym: 
    		when LbraceSym: 
    		when LparenSym: 
    		when StarSym: 
    		when AndSym: 
    		when PlusSym: 
    		when MinusSym: 
    		when PlusPlusSym: 
    		when MinusMinusSym: 
    		when newSym: 
    		when DollarSym: 
    		when BangSym: 
    		when TildeSym:  
    # line 666 "cs.atg"
    			AssignmentStatement()
    			break
    		when breakSym:  
    # line 666 "cs.atg"
    			BreakStatement()
    			break
    		when continueSym:  
    # line 667 "cs.atg"
    			ContinueStatement()
    			break
    		when doSym:  
    # line 668 "cs.atg"
    			DoStatement()
    			break
    		when forSym:  
    # line 668 "cs.atg"
    			ForStatement()
    			break
    		when ifSym:  
    # line 669 "cs.atg"
    			IfStatement()
    			break
    		when SemicolonSym:  
    # line 669 "cs.atg"
    			NullStatement()
    			break
    		when returnSym:  
    # line 670 "cs.atg"
    			ReturnStatement()
    			break
    		when switchSym:  
    # line 670 "cs.atg"
    			SwitchStatement()
    			break
    		when whileSym:  
    # line 671 "cs.atg"
    			WhileStatement()
    			break
            # default :GenError(96); break
    	end
    # line 671 "cs.atg"
	        
    end

    # line 679 "cs.atg"
    def AssignmentStatement()

    # line 679 "cs.atg"
    	debug("===>AssignmentStatement1")
    # line 679 "cs.atg"
    	Expression()
    # line 679 "cs.atg"
    	Expect(C_SemicolonSym)
    # line 679 "cs.atg"
    	debug("===>AssignmentStatement2");
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
    	    @sym >= C_newSym && @sym <= C_DollarSym ||
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
    	    @sym >= C_newSym && @sym <= C_DollarSym ||
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
    	    @sym >= C_newSym && @sym <= C_DollarSym ||
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

    # line 791 "cs.atg"
    	Expect(C_ifSym)
    # line 791 "cs.atg"
    	Expect(C_LparenSym)
    # line 791 "cs.atg"
    	Expression()
    # line 791 "cs.atg"
    	Expect(C_RparenSym)
    # line 792 "cs.atg"
	
	    
	
	   
    # line 828 "cs.atg"
    	Statement()
    # line 828 "cs.atg"
    # line 828 "cs.atg"
    	if (@sym == C_elseSym) 
    # line 830 "cs.atg"
    		Get()
    # line 831 "cs.atg"
		
		           
    # line 840 "cs.atg"
    		Statement()
    # line 841 "cs.atg"
		
		          
    	end
    # line 848 "cs.atg"
	

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
    	    @sym >= C_newSym && @sym <= C_DollarSym ||
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
end  # class Parser
s = "{a=1;}"
scanner = CScanner.new(s, 0)
error = MyError.new("whaterver", scanner)
parser = Parser.new(scanner, error)
parser.Get
parser.FunctionBody