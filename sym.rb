=begin
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
=end
C_EOF_Sym	= 0	# EOF */
C_identifierSym = 1	# identifier */
C_numberSym = 2	# number */
C_hexnumberSym = 3	# hexnumber */
C_stringD1Sym = 4	# string1 */
C_charD1Sym = 5	# char1 */
C_librarySym = 6	# library */
#C_useSym = 7	# "use" */
C_SemicolonSym = 8	# ";" */
#C_loadSym = 9	# "load" */
C_packageSym = 10	# "package" */
C_SlashSym = 11	# "/" */
C_inheritSym = 12	# "inherit" */
C_LessSym = 13	# "<" */
C_classSym = 14	# "class" */
C_LbraceSym = 15	# "{" */
C_RbraceSym = 16	# "}" */
C_staticSym = 17	# "static" */
C_constSym = 18   # "const" */
C_mySym = 19	# "my" */
C_externSym = 20	# "extern" */
C_varSym = 21	# "var" */
C_boolSym = 22	# "bool" */
C_shortSym = 23	# "short" */
C_intSym = 24	# "int" */
C_longSym = 25	# "long" */
C_floatSym = 26	# "float" */
C_unsignedSym = 27	# "unsigned" */
C_charSym = 28	# "char" */
C_doubleSym = 29	# "double" */
C_voidSym = 30	# "void" */
#C_stringSym = 31	# keyword "string" */
C_EqualSym = 32	# "=" */
C_CommaSym = 33	# ",        " */
C_LbrackSym =                   34	# "[" */
C_RbrackSym =                   35	# "]" */
C_LparenSym =                   36	# "(" */
C_RparenSym =                   37	# ")" */
C_StarSym =                     38	# "*" */
C_caseSym =                     39	# "case" */
C_ColonSym =                    40	# ":" */
C_defaultSym =                  41	# "default" */
C_breakSym =                    42	# "break" */
C_continueSym =                 43	# "continue" */
C_doSym =                       44	# "do" */
C_whileSym =                    45	# "while" */
C_forSym =                      46	# "for" */
C_ifSym =                       47	# "if" */
C_elseSym =                     48	# "else" */
C_returnSym =                   49	# "return" */
C_switchSym =                   50	# "switch" */
C_BarBarSym =                   51	# "||" */
C_AndAndSym =                   52	# "&&" */
C_BarSym =                      53	# "|" */
C_UparrowSym =                  54	# "^" */
C_AndSym =                      55	# "&" */
C_EqualEqualSym =               56	# "==" */
C_BangEqualSym =                57	# "!=" */
C_GreaterSym =                  58	# ">" */
C_LessEqualSym =                59	# "<=" */
C_GreaterEqualSym =             60	# ">=" */
C_LessLessSym =                 61	# "<<" */
C_GreaterGreaterSym =           62	# ">>" */
C_PlusSym =                     63	# "+" */
C_MinusSym =                    64	# "-" */
C_PercentSym =                  65	# "%" */
C_PlusPlusSym =                 66	# "++" */
C_MinusMinusSym =               67	# "--" */
C_PointSym =                    68	# "." */
C_MinusGreaterSym =             69	# "->" */
C_ColonColonSym =               70	# "::" */
C_HashHashSym =                 71	# "##" */
C_newSym =                      72	# "new" */
C_DollarSym =                   73	# "$" */
C_StarEqualSym =                74	# "*=" */
C_SlashEqualSym =               75	# "/=" */
C_PercentEqualSym =             76	# "%=" */
C_PlusEqualSym =                77	# "+=" */
C_MinusEqualSym =               78	# "-=" */
C_AndEqualSym =                 79	# "&=" */
C_UparrowEqualSym =             80	# "^=" */
C_BarEqualSym =                 81	# "|=" */
C_LessLessEqualSym =            82	# "<<=" */
C_GreaterGreaterEqualSym =      83	# ">>=" */
C_BangSym =                     84	# "!" */
C_TildeSym =                    85	# "~" */
C_EnumSym =                     86  # "enum"
C_StructSym =                   87  # "struct"
C_TypedefSym =                  88  # "typedef"
C_QuestionMarkSym =             89  # "?"
C_CRLF_Sym =                    90  # ""
C_deleteSym =                   91  # "delete"
C_throwSym =                    92  # "throw"
C_sizeofSym =                   93  # "sizeof"
C_INSym =                       94  # "IN"
C_OUTSym =                      95  # "OUT"
C_INOUTSym =                    96  # "INOUT"
C_inlineSym =                   97  # "inline"
C_PPPSym =                      98   # "..."
C_namespaceSym =                99     # "..."
C_usingSym =                    100    # "using"
C_finalSym =                    101    # "final"
C_operatorSym =                 102    # "operator"
C_overrideSym =                 103    # "override"
C_gotoSym =                     104    # "goto

#*** insert new sym here ***#   
C_No_Sym =                      105	# not */
C_PreProcessorSym =             106	# PreProcessor */

C_MAXT = C_No_Sym	# Max Terminals */

# how to add new sym
# 1. add definition in above. e.g. 
# C_OUTSym =                         95 
# 2. add entry in SYMS below
# 3. add code in scanner.rb->CheckLiteral()
# e.g.             
#            when 'O'
#                return C_OUTSym if EqualStr("OUT")
# 4. sometimes you need to add condition in cp.rb->C() to enter Definition()


SYMS=[                                                



"EOF"                         ,
"identifier"               ,
"number"                       ,
"hexnumber"                ,
"string1"                  ,
"char1"                        ,
"library"                  ,
"use"                        ,
";"                      ,
"load"                       ,
"package"                ,
"/"                          ,
"inherit"                ,
"<"                          ,
"class"                      ,
"{"                      ,
"}"                      ,
"static"                 ,
"const"                     ,
"my"                         ,
"extern"               ,
"var"                        ,
"bool"                      ,
"short"                      ,
"int"                        ,
"long"                       ,
"float"                      ,
"unsigned"               ,
"char"                       ,
"double"                 ,
"void"                       ,
"string"                 ,
"="                          ,
","                          ,
"["                      ,
"]"                      ,
"("                      ,
")"                      ,
"*"                          ,
"case"                       ,
":"                          ,
"default"                ,
"break"                      ,
"continue"               ,
"do"                         ,
"while"                      ,
"for"                        ,
"if"                         ,
"else"                       ,
"return"                 ,
"switch"                 ,
"||"                     ,
"&&"                     ,
"|"                          ,
"^"                      ,
"&"                          ,
"=="                 ,
"!="                     ,
">"                      ,
"<="                     ,
">="                 ,
"<<"                     ,
">>"             ,
"+"                          ,
"-"                          ,
"%"                      ,
"++"                     ,
"--"                 ,
"."                          ,
"->"                 ,
"::"                 ,
"##"                  ,
"new"                        ,
"$"                      ,
"*="                     ,
"/="                 ,
"%="                 ,
"+="                     ,
"-="                 ,
"&="                     ,
"^="                 ,
"|="                     ,
"<<="                ,
">>="        ,
"!"                          ,
"~"                          ,
"enum",
"struct",
"typedef",
"?",
"CRLF",
"delete",
"throw",
"sizeof",
"IN",
"OUT",
"INOUT",
"inline",
"...",
"namespace",
"using",
"final",
"operator",
"override",
"goto",
"not"                          ,
"PreProcessor"         ,
    ]