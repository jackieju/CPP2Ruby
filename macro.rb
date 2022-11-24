# process macro of c/c++
load "cp.rb"

# hide_p_in_file(__FILE__)
class Preprocessor < Parser
    attr_accessor :ifstack, :file_save
 
    def Preprocess(include_predined_file = true)
        if $g_cur_parse_file
            @file_save = "pre.part.#{$g_cur_parse_file.split("/").last}.#{Time.now.to_i}" 
        else
            @file_save = "pre.#{Time.now.to_i}" 
        end
        @in_preprocessing = true
        @ifstack = []
        @ifstack_before_inc = []
        @saved_line = 0
        @count = 0
              
         if include_predined_file 
             include_file("c_macros.c") # predefined macros
             include_file("./macros.c") # same file in user's working dir
         end

         
         Get()
         p "sym3333:#{@sym}"
         # _preprocess(false)
         _preprocess()
         @in_preprocessing = false
         # @scanner.Reset()
         # ret = expand_macro(@scanner.buffer)
         # p "after expand_macro: #{ret}"
         p "after preprocess:line #{@scanner.currLine}"
         s = read_file(@file_save)
         s = "" if !s
         return s+ @scanner.buffer
     end
     # def _preprocess(stop_on_unkown_directive = true)
     #        while (@sym!=C_EOF_Sym)
     # 
     #             p "sym2:#{@sym}, #{curString()}"
     #            if @sym == C_PreProcessorSym
     #                @directive = preprocess_directive()
     #                return @directive if stop_on_unkown_directive && @directive
     #            end
     #            # if @sym == C_identifierSym
     #            #     cs = curString()
     #            #     if ifdefined?(cs)
     #            #         @macros[n]
     #            #     end
     #            # end
     #            Get()
     #        end
     #    end
     
     def add_macro(n,v)
         @macros = {} if @macros == nil
         @macros[n] = v
     end
     def push_ifstack
         cl = @scanner.current_line
         @ifstack.push(cl)
         indent = ""
         for i in 1..@ifstack.size
             indent += "---+"
         end
         append_file("ifstack", "#{indent}>#{cl}\n")
     end
     def pop_ifstack
         cl = @ifstack.pop
         indent = ""
         for i in 1..@ifstack.size+1
             indent += "---+"
         end
         append_file("ifstack", "#{indent}<#{cl}\n")
     end
     # process every directive
     def preprocess_directive(doprepro)
=begin        
           _str1 = curString()
           # pp "preprocessor: #{@sym}, #{_str1}", 20
           Get()
           _str2 = curString()
           @directive = "#{_str1}#{_str2}"
=end          
           p "preprocess_directive0 #{@directive}, line=#{@scanner.currLine}", 10
           if @scanner.currLine == 54 && @directive == "\#include"
             #  p "==>preprocess_directive9:#{@scanner.buffer}"
           end
           if @directive == "\#includestackpop"  # you cannot use include_stack_pop, before the sym will only be "#include",because it will stop before "_", check method scanner::Get()
               p "pop stack"

               path = @scanner.include_stack.pop
               if @ifstack_before_inc.last != @ifstack.last
                   p "#{@ifstack_before_inc.last}!=#{@ifstack.last}"
                   throw "---->ifstack cross included file #{path}, error <------"
               end
               @ifstack_before_inc.pop
               indent = ""
               for i in 1..@scanner.include_stack.size+1
                   indent += "----"
               end
               append_file("included_files", "#{indent}<#{path}\n")
        #       p "before delete line:#{@scanner.buffer}"
               # p "-->111#{skip_curline}"
               #p "--->113#{delete_prevline}"
               delete_curline
          #     p "after line2:#{@scanner.buffer}"
               @directive = nil
           elsif  @directive == "\#include"
               p "====>preprocess_directive1"
               Get()
               if (@sym == 4) # string
                   finclude = curString()
                    #p "==>preprocess_directive91:#{@scanner.buffer}"
                   p "fclude111:#{finclude}"
                   
                   p "@sym=#{@sym}"
                   p "current sym:#{@scanner.currSym.sym}"
                   if finclude[0]=="\"" || finclude[0] =="\'"
                         finclude = finclude[1..finclude.size-1]
                   end
                   if finclude[finclude.size-1]=="\"" || finclude[finclude.size-1] =="\'"
                         finclude = finclude[0..finclude.size-2]
                   end
               else # @sym should be 13 # <
                   p("sym:#{@sym}, #{curString}")
                  # p "==>:#{@scanner.buffer}"
                    Get()
                    p "sym33=#{@sym}, #{curString()}"
                    finclude = ""
                    
                    while @sym != C_GreaterSym #&& (@sym == C_PointSym || @sym == C_identifierSym || @sym == C_SlashSym ) # ">"
                        finclude += curString()
                        Get()
                    end
                    p "@sym=#{@sym}"
                    p "current sym:#{@scanner.currSym.sym}"
                    p "fclude:#{finclude}"
               end
               p "-->include file #{finclude}"
               #p self.inspect
               #p @scanner.inspect
             if doprepro
                 ri = include_file(finclude)
                 @ifstack_before_inc.push(@ifstack.last) if ri
             end
               @directive = nil
         elsif @directive == "\#define" 
             p "====>preprocess_directive2"
            
            pre_define(doprepro)
            @directive = nil
            
            
         elsif @directive == "\#ifdef"
             p "====>preprocess_directive3"
             push_ifstack
             
             pre_ifdef(doprepro)
             expect("\#endif")
             
             pop_ifstack       
                   
         elsif @directive == "\#ifndef"
             p "====>preprocess_directive4"
             push_ifstack
             
             pre_ifndef(doprepro)
             expect("\#endif")
             
             pop_ifstack             

         elsif @directive == "\#if"
             p "====>preprocess_directive5"
             push_ifstack
            
             pre_if(doprepro)
             expect("\#endif")
             
             pop_ifstack             

         elsif @directive == "\#undef"
             Get()
             p "undefine #{curString}"
             @macros.delete(curString())
             delete_curline
             @directive = nil
             
         else
                # @scanner.delete_curline
                # if !["#else", "#endif", "elif"].include?(@directive)
                    # @scanner.skip_curline
                    p "before skip_curline:#{@scanner.buffPos}, #{@scanner.buffer[@scanner.buffPos-5..@scanner.buffPos+15]}", 10
                    
                @scanner.skip_curline(true)
                #delete_curline()
                 p "after skip_curline:#{@scanner.buffPos}, #{@scanner.buffer[@scanner.buffPos-5..@scanner.buffPos+15]}", 10
                #  Get()
               #  p "get:#{@scanner.nextSym.inspect}, #{@scanner.ch} #{curString}"
               #  p "buffer:#{@scanner.buffer}"
                
                 
                # end
                @directive = nil
         end
         # p "after process directive #{@directive}:#{@scanner.buffer}"
         return nil
     end
     def ifdefined?(n)
         return @macros[n] != nil
     end
     def pre_define(doprepro)
               Get(false)
               # Expect(C_identifierSym)
               p "c0000=#{@sym}, #{curString()}, line #{@scanner.currLine}, ch=#{@scanner.cch.to_byte}"
               start_pos = @scanner.buffPos
               n = curString()
               p "--->pre_define:#{n}, #{@scanner.buffer[@scanner.buffPos].to_byte}@#{@scanner.buffer[@scanner.buffPos]}"
               args =[]
               v = ""
               hasArg = false
               ch = @scanner.buffer[@scanner.buffPos] 
               if (ch.to_byte >= 9 && # TAB
                   ch.to_byte <= 10 || # LF
                   ch.to_byte == 13 || # CR
                   ch == ' ')
                 #  p "==>define51:#{n}:before skip_curline, #{@scanner.currLine}, #{@scanner.buffer[@scanner.buffPos..@scanner.buffPos+10]}, buffer:#{@scanner.buffer}"
                   
                   v = @scanner.skip_curline(true)
                  # p "==>define51:#{n}:after skip_curline, #{@scanner.currLine}, #{@scanner.buffer[@scanner.buffPos..@scanner.buffPos+10]}"
                   
               else
               Get(false)
                  # n = prevString()
                  vargs = false
                  
                  p "c1111=#{@sym}, #{curString()}, line #{curLine}"
                  if @sym == C_CRLF_Sym
                      @scanner.skip_curline(true)
                  elsif (@sym == C_LparenSym)
                      hasArg = true
                      Get()
                      if @sym == C_RparenSym
                          #Get()
                          p("===>pre_define3:#{@sym},#{curString}")
                      else
                          if (@sym == C_identifierSym)
                              Expect(C_identifierSym)
                              args.push(prevString())
                              while (@sym == C_CommaSym)
                                  Get()
                                  Expect(C_identifierSym)
                                  args.push(prevString())
                              end
                          elsif @sym == C_PPPSym
                              vargs = true
                              Get()
                          end
                      end
                      #Expect(C_RparenSym)
                      v = @scanner.skip_curline(true)
                  else
                      v = @scanner.skip_curline(true, @scanner.nextSym.pos)
                  end
           
              end
              p "macro #{n} defined in line #{@scanner.currLine}"
              
                  # while @sym < C_No_Sym && @sym != C_EOF_Sym
                  #       c = curString()
                  #      if @sym ==C_identifierSym
                  #          count = 0
                  #          args.each{|arg|
                  #             break if arg == c
                  #             count += 1
                  #          }
                  #         if count >= args.size
                  #             v+=c
                  #         else
                  #             v += "%$<#{count}>$%"
                  #          end
                  #      end
                  #      Get()
                  #  end
                  # p "prevString:#{prevString}:curString:#{curString}, #{@scanner.buffer[@scanner.buffPos]}"
                  # v = curString()+@scanner.skip_curline(true)
                  
                  p "==>define:#{n}==#{v}, pos=#{@scanner.buffPos}", 10
                  #delete_prevline
                  # p "pre_define1:pos=#{@scanner.buffPos}, buffer #{@scanner.buffer}, sym:#{@sym}"  
                       # p "before line1:#{@scanner.buffer}"
                      # p "before line1:buffPos:#{@scanner.buffPos},#{@scanner.buffer[@scanner.buffPos]}, #{@scanner.ch},#{@scanner.buffer[@scanner.buffPos..@scanner.buffPos+2]} "
                        pos2 = @scanner.buffPos
                     #   p "delete lines #{start_pos} #{@scanner.buffer[start_pos..start_pos+5]}, #{pos2} #{@scanner.buffer[pos2..pos2+5]}"
                        delete_lines(start_pos, pos2, false)
                       #  p "after line2:#{@scanner.buffer}" 
            #  p "==>define5:#{n}:after delete_lines, #{@scanner.currLine}, #{@scanner.ch}, #{@scanner.buffer[@scanner.buffPos..@scanner.buffPos+10]}"
                    if !vargs # not vararg
                      v=v.gsub(/(\w[\w\d_]*)/){|m|
                         p m.inspect
                         count = args.index(m)
                         if count
                             "%<#{count}>%"
                         else
                             m
                         end
                       }
                       v = v.strip
                   end
                   
                   p "n=#{n}"
                   p "v=#{v}"
                   add_macro(n, {
                       :v=>v,
                       :hasArg=>hasArg
                   }) if doprepro
     end
     
     def ActualParameters()
         debug "==>ActualParameters:#{@sym}, line #{curLine}, val #{curString()}"
         ret = ""
         args=[]
     # line 2661 "cs.atg"

    	

     # line 2668 "cs.atg"
     
     lp = 1
     
     r = ""
     while (@sym != C_CommaSym )
         if @sym == C_RparenSym
             lp -= 1
             if lp == 0
                 break
             end
         elsif @sym == C_LparenSym
             lp += 1
         end
         r += curString()
         
         Get()
         
     end
     
     args.push(r)
     ret += r
        
       
     	p "ret:#{ret}"
        if lp >0
         	while (@sym  == C_CommaSym) 
         		ret += ","
    		
         		Get()
                r = ""
                while (@sym != C_CommaSym )
                    if @sym == C_RparenSym
                        lp -= 1
                        if lp == 0
                            break
                        end
                    elsif @sym == C_LparenSym
                        lp += 1
                    end
                    r += curString()
         
                    Get()
                end
                args.push(r)
                ret += r
     	    end
        end
 	    debug "==>ActualParameters1:#{@sym}, line #{curLine}, val #{curString()}, ret=#{ret}"
     # line 2776 "cs.atg"
         return [ret, args]
     end
     # def preprocess_directive()
     # 
     #           _str1 = curString()
     #           pp "preprocessor: #{@sym}, #{_str1}", 20
     #           Get()
     #           _str2 = curString()
     #           @directive = "#{_str1}#{_str2}"
     #           p "directive=#{@directive}, line=#{@scanner.currLine}"
     #           if @directive == "\#define" 
     # 
     #       
     # 
     #         else
     #                # @scanner.delete_curline
     #             return @directive
     #         end
     #         return nil
     #     end

=begin    
     # line 2597 "cs.atg"
     def FunctionCall()
         pp "functioncall()",20
         ret  =""
     # line 2597 "cs.atg"
     	Expect(C_LparenSym);
     # line 2598 "cs.atg"

     	     pdebug("=====>FunctionCall");
        ret = []
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
     		ret = ActualParameters()
     	end
     # line 2605 "cs.atg"
     	Expect(C_RparenSym);
     # line 2606 "cs.atg"
         p "====>FunctionCall1:(#{ret})"
         return ret.inspect
     end
     # line 2660 "cs.atg"
     def ActualParameters()
         debug "==>ActualParameters:#{@sym}, line #{curLine}, val #{curString()}"

         ret = []
     # line 2661 "cs.atg"



     # line 2668 "cs.atg"
     	ret.push(Expression())
     # line 2669 "cs.atg"

     	p "ret:#{ret}"
     # line 2701 "cs.atg"
     	while (@sym  == C_CommaSym) 
     # line 2701 "cs.atg"
            # ret += curString()

     		Get()
     # line 2701 "cs.atg"
     		ret.push(Expression())
     # line 2703 "cs.atg"

 	    end
 	    debug "==>ActualParameters1:#{@sym}, line #{curLine}, val #{curString()}"
     # line 2776 "cs.atg"
         return ret
     end
     # line 966 "cs.atg"
      def Expression
          ret = ""
      # line 966 "cs.atg"
      	pdebug("===>Expression:#{@sym}")


      	if @sym == C_LbraceSym  # {a, b, c}
      	    ret += "{"
      	    Get()
      	    ret += Expression()
      	    while (@sym==C_CommaSym)
      	        ret += ","
      	        Get()
      	        ret += Expression()
  	        end
      	    Expect(C_RbraceSym)
      	    ret += "}"
  	    else

          # line 966 "cs.atg"
          	c = Conditional()
          	ret += c
          	pdebug("===>Expression-1:#{ret}")

          # line 966 "cs.atg"
          	while (@sym == C_EqualSym ||
          	       @sym >= C_StarEqualSym && @sym <= C_GreaterGreaterEqualSym ||
          	       @sym == C_QuestionMarkSym
          	       ) 
          # line 966 "cs.atg"
                  pdebug("===>Expression0:#{ret}")
                  if @sym == C_QuestionMarkSym  # exp ? A:B
                      Get()
                      ret += "?#{Expression()}"
                      Expect(C_ColonSym)
                      ret += ":#{Expression()}"
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

      	if @sym!= C_LbraceSym && @sym!= C_CommaSym && @sym!= C_RparenSym && @sym!= C_SemicolonSym && @sym!=C_RbrackSym && @sym!=C_RbraceSym &&
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
      	    ret += Expression()
  	    end


      	pdebug("===>Expression1:#{ret}")
      	return ret
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
    	return ret
    end

    # line 1103 "cs.atg"
    def ANDExp()
      ret = ""
    	pdebug("===>ANDExp")

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
    # line 1190 "cs.atg"
    	while (@sym == C_LessSym ||
    	       @sym >= C_GreaterSym && @sym <= C_GreaterEqualSym) 
    # line 1190 "cs.atg"
    		ret += curString()
          	pdebug("===>RelationExp3")
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

    	pdebug("<===>RelationExp:#{ret}")
    	return ret
    end

    # line 1248 "cs.atg"
    def ShiftExp()
      ret = ""
      pdebug("===>ShiftExp")
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
    	pdebug("===>CastExp")
    # line 1397 "cs.atg"

    # line 1405 "cs.atg"
      ret =	UnaryExp()
    # line 1407 "cs.atg"
     p "<===CastExpCastExp:#{ret}"
       return ret
    end

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
                    ret += curString()
    # line 1742 "cs.atg"
    				Get()
    # line 1742 "cs.atg"

    # line 1779 "cs.atg"
    				if (@sym == C_identifierSym) 
    				    p "get identifier"
    # line 1759 "cs.atg"
    					ret += curString()
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
    				ret += curString()
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
    	p "==>PostFixExp1:#{ret}"
    	return ret
    end
=begin
    # line 1538 "cs.atg"
    def UnaryExp()
      ret = ""
    # line 1538 "cs.atg"
    	pdebug("===>UnaryExp:#{@sym}, #{curString()}");
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
    	    ret += curString()
    	    Get()
    	    ret += curString()
    	    Expect(C_LessSym)
    	    ret += Type()
        	while (@sym == C_StarSym || @sym == C_AndSym) 
        	    ret += curString()
        	    
      		    Get()
      	    end
      	    ret += curString()
      	Expect(C_GreaterSym)
      	ret += curString()
      	Expect(C_LparenSym)
      	ret += Expression()
      	ret += curString()
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
    			ret += curString()
          	Get() 
    		elsif (@sym == C_MinusMinusSym) 
    # line 1539 "cs.atg"
    			ret += curString()
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
          # pp("dff", 100)
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
        
        ret = "new #{className}(#{fCall})"
        p "===>Creator1:#{ret}"
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
    def STLType1()
       ret = "<"
            Get()
            ret +=FormalParamList()
            Expect(C_GreaterSym)
        ret += ">"
        return 
    end
     def Type1()
        pdebug("---->type:#{@sym}")
        ret = ""


        while (@sym >= C_staticSym && @sym <= C_constSym) 
            ret += StorageClass()
        end

    # line 423 "cs.atg"
    	case (@sym) 

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
    		        if @sym == C_LessSym # stl type
    		            ret += STLType()
    	            end
		        end
                p "sym2:#{@sym}"
		        if @sym == C_LessSym # stl type
		            ret += STLType()
	            end
	            p "sym3:#{@sym}, val #{curString()}"
    		else 
    		    GenError(95)
    	end # case
    	return ret
    end
    
    def FullType
        ret = Type()


###############################################
#        int (*pFunction)(float,char,char)=NULL;
#        int (MyClass::*pMemberFunction)(float,char,char)=NULL;
#        int (MyClass::*pConstMemberFunction)(float,char,char) const=NULL;
##############################################
        if @sym == C_LparenSym  # pointer to function
            Get()
            Expect(C_StarSym)
            Expect(C_identifierSym)
            fname = curString()
            Expect(C_RparenSym)
            fh = FunctionHeader()
            ret += "(*#{fname})(#{fh})"
        else
        	while (@sym == C_StarSym || @sym == C_AndSym) 
        	    #var_type.ref += 1 if var_type
                ret += curString()
                # line 699 "cs.atg"
        		Get()
        		
                # line 699 "cs.atg"
        	end
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
        
        const = ""
        if @sym == C_identifierSym && curString() == 'const'
            Get()
            const = "const"
        end
        
        return "(#{ret})#{const}"
 
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
                      	#Expect(C_identifierSym)
                    Get()
                    if @sym == C_LessSym
                        filterTemplate()
                    end
                  end
          	    else
    		    	
    			        ret += varname
                        if @sym == C_LessSym
                            filterTemplate()
                        end
    			    
    		    end
    # line 2335 "cs.atg"




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
                ret += "("
    # line 2593 "cs.atg"
    			Get()
    # line 2593 "cs.atg"
    p "sym555:#{@sym}, val #{curString()}"
              if @sym == C_identifierSym || @sym == C_constSym || @sym >= C_shortSym && @sym <= C_stringSym
                  if @sym == C_constSym
                      ret += " const "
                      Get()
                  end
                  _next = GetNext()
                  _next2 = GetNext(2)
                  if _next == C_RparenSym || 
                      ( ( _next == C_StarSym || _next == C_AndSym ) && (_next2 < C_identifierSym || _next2 > C_charD1Sym) )
                      ret += FullType()
                      
                      Expect(C_RparenSym)
                      ret += ")"
                      bT = true
                  end
              end
              if !bT  # ( Expression )
    		    	exp =Expression()
      			   p "sym556:#{@sym}, val #{curString()}"
      # line 2593 "cs.atg"
      			Expect(C_RparenSym)
      			ret += "#{exp})"
    			end
              # break;
    		when C_LbraceSym  
    		    ret += "{"
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
=end
    def pre_ifdef(doprepro, ifndef=false)
         Get()
         n = curString()
       #  p "===>pre_ifdef0: #{n}, #{doprepro}, #{ifndef}", 10
         
         #p "pre_ifdef before delete:n=#{n}, line #{@scanner.currLine},  pos #{@scanner.buffPos}, buffer #{@scanner.buffer}", 10
         delete_curline  # delele line #ifdef
         #p "pre_ifdef after delete: line #{@scanner.currLine}, pos #{@scanner.buffPos}, buffer #{@scanner.buffer}"
         
         idf = ifdefined?(n)
       #  pp "===>pre_ifdef2: idf=#{idf}, @sym=#{@sym}",20
          if ifndef
              idf = !idf
          end
          
         pos1 = @scanner.buffPos
         Get()
         @directive=_preprocess(["#else", "#endif", "#elif"], idf)
         p "pre_ifdef: directive=#{@directive}, n=#{n}"
         
         #pos2 = @scanner.buffPos
         # p "pos:#{@scanner.buffPos}"
         pos2 = @scanner.nextSym.pos
      #   p "pre_ifdef1:pos:#{@scanner.buffPos}, #{@sym}, #{curString()}, #{@scanner.dump_char}"
 # p "===>114:pos1:#{pos1}, pos2 #{pos2}, pos #{@scanner.buffPos}"
         # p "===>113:#{@scanner.buffer}"
         # p "===>114:pos1:#{pos1}, pos2 #{pos2}, pos #{@scanner.buffPos}, buffer=#{@scanner.buffer}, #{@scanner.buffer[@scanner.buffPos].inspect}"
         if !idf || !doprepro
             buf = @scanner.buffer
             #p "==>pre_ifdef3:before delete_lines, line #{@scanner.currLine}, #{buf[pos1..pos1+6]}, #{buf[pos2..pos2+6]}, buffer:#{buf}"
             delete_lines(pos1, pos2, false) # delete whole block (...) not include #else
             #p "==>pre_ifdef3:after delete_lines, line #{@scanner.currLine}, #{buf[pos1..pos1+6]}, #{buf[pos2..pos2+6]}, buffer:#{@scanner.buffer}"
    
             # p "===>115:pos #{@scanner.buffPos}, buffer=#{@scanner.buffer}"
         else
             # delete_curline # only delete #preprocess line
         end 
          # p "pre_ifdef2:pos:#{@scanner.buffPos}, #{@sym}, #{curString()}, @directive=#{@directive}"
        # pre = GetPre()
        
        # _str1 = curString()
        #   Get()
        #   _str2 = curString()
        #   directive = "#{_str1}#{_str2}"
        
        # Get()
        
        if doprepro && idf
            doprepro = true
        end
        while @directive == "\#elif"
            idf2 = pre_elif(doprepro) # only when doprepor == true and condition is true then will return true
            if idf2 && doprepro
                doprepro = false # if current one fufill, ignore remaining
            end
        end
 
        pre_else(doprepro, !idf)
        pre_endif(doprepro, idf)
       
    end
    #def pre_elif(idf)
    #    while @directive == "\#elif"
    #        # Get()
    #        Get()
    #         n1 = curString()
    #         # p "==>112:#{n1}, #{@scanner.buffPos}"
    #         delete_curline
    #         pos11 = @scanner.buffPos
    #         Get()
    #         @directive=_preprocess(["#else", "#endif", "#elif"], !idf)
    #         p "directive=#{@directive}", 10
    #         
    #         pos22 = @scanner.buffPos
    #         if !idf
    #            if is_number?(n1)
    #                idf = n1.to_i != 0
    #            else
    #                idf = ifdefined?(n1) && @macros[n1].to_i !=0
    #            end
    #            # p "==>111:#{n1}, #{idf}"
    #            if !idf
    #                delete_lines(pos11, pos22, false)
    #            end
    #        else
    #            delete_lines(pos11, pos22, false)
    #        end
    #     
    #    end
    #end
    def pre_elif(doprepro)
        p "===>pre_elif1:#{doprepro}, #{@scanner.buffer[@scanner.buffPos..@scanner.buffPos+20]}"
        
        idf = _pre_if()
        p "===>pre_elif3:#{doprepro}, #{idf}"
         @scanner.delete_curline
      #   p "===>pre_elif4:after delete curline:#{@scanner.buffer}"
         pos1 = @scanner.buffPos
         @directive=_preprocess(["#else", "#endif", "#elif"], idf)
         #pos2 = @scanner.buffPos
     
         pos2 = @scanner.nextSym.pos
  
         if !idf || !doprepro
             @scanner.delete_lines(pos1, pos2, false) # delete whole block
         end  
         return idf
    end
    def pre_else(doprepro, idf)
    #    p "===>pre_else0:#{idf}, #{doprepro}", 10
        if @directive == "\#else"
           #  p "111=>#{@scanner.buffer}, pos #{@scanner.buffPos}, #{@scanner.dump_char}"
            # delete_prevline # delete #else line
            #p "1113=>#{@scanner.currLine}, #{@scanner.buffer}"
            delete_curline
            #p "112=>#{@scanner.currLine}, #{@scanner.buffer}, pos #{@scanner.buffPos}, idf=#{idf}, #{@scanner.currLine}"
            p "hahaha1110:#{@directive}"
                
            Get()
             pos11 = @scanner.nextSym.pos
            # p "pre_else: sym=#{@sym}, directive=#{@directive}, pos #{@scanner.buffPos}, buffer #{@scanner.buffer}, #{@scanner.dump_char}"
            p "hahaha111:#{@directive}"
             
             @directive=_preprocess(["#endif", "#elif"], idf)
             # p "pre_else: directive=#{@directive}, pos #{@scanner.buffPos}, buffer #{@scanner.buffer}, #{@scanner.dump_char}", 20
             # p "222=>#{@scanner.buffer}, pos #{@scanner.buffPos}, ch #{@scanner.cch.inspect}"
             
            # pos22 = @scanner.buffPos
            pos22 = @scanner.nextSym.pos
            
              p "hahaha11:#{@directive}"
        
            if !idf || !doprepro
                #p "==>pos11:line #{@scanner.currLine}, #{pos11}, #{pos22}, buffer #{@scanner.buffer}"
                delete_lines(pos11, pos22, false) # delete whole else part not include #endif
                 #p "==>pos12:line #{@scanner.currLine}, #{pos11}, #{pos22}, buffer #{@scanner.buffer}"
                
            else
                # pos is next char after current directive
                # delete_prevline # only delete #endif line
            end
           # p "hahaha12:#{@directive}", 10

            if @directive == "\#endif"
                # p "hahaha:#{directive}"
                # @scanner.delete_curline
            end
        end
    end
    def expect(directive)
        throw "Expect directive #{directive}, get #{@directive}" if @directive != directive 
        @directive = nil
    end
    def pre_endif(doprepro, idf)
        if @directive == "\#endif"
            #p "9999:line #{@scanner.currLine}, pos #{@scanner.buffPos},#{@scanner.cch.inspect}, buffer:#{@scanner.buffer}"
            # @scanner.delete_prevline
           # p "==>pre_endif:before delete_curline:#{@scanner.nextSym.inspect}, #{@scanner.buffer[@scanner.buffPos..@scanner.buffPos+15]}"
            delete_curline
            #p "99992:line #{@scanner.currLine}, pos #{@scanner.buffPos},#{@scanner.cch.inspect}, buffer #{@scanner.buffer}", 19
            
        end
    end
    
    def _pre_if()
        #dump_pos
        s = ""
        while (Get(false) != C_CRLF_Sym)
            n = curString()
            p "==>_pre_if:n:#{@sym},#{n}"
            if n == "defined" 
            elsif @sym == C_identifierSym 
                v = @macros[n]
                if v
                    if v[:v] == "" # defined to empty string
                        s += "true"
                    else
                        s +=  v[:v]
                    end
                else # not defined
                    _n = GetNextSym()
                    _n = getSymValue(_n)
                    if [">","<","="].include?(_n[0])
                        s+="0"
                    else
                        _p = getSymValue(@scanner.currSym)
                        
                        if [">","<","="].include?(_p[0])
                            s += "0"
                        else
                            s += "false"
                        end
                    end
                end
            else
                s += n
            end 
            p "_pre_if2:#{s}"
        end
        p "_pre_if2:#{s}"
        return eval(s)
    end
    def pre_if(doprepro)
        p "===>pre_if0:#{doprepro}", 10
=begin
        Get()
         n = curString()
         p "===>pre_if:n=#{n}"
         
         neg = false
         if n == "!"
             neg = true
             Get()
             n = curString()
         end
         p "===>pre_if2:n=#{n}"
         
         if n=~ /^\d+$/ # if 0 or other number
            idf = (n.to_i !=0)
        elsif n == "defined"
            Get() # (
            inp = false
            if curString == "("
                inp = true           
                Get()
              
            end
             n = curString()
             Get() if inp # )
            p "===>pre_if3:n=#{n}"
            idf = !( ifdefined?(n) == false || ( @macros[n].to_i ==0 && @macros[n].to_i.to_s == @macros[n] ))
            p "===>pre_if4:idf=#{idf}, #{@macros[n].inspect}, #{ifdefined?(n)}, "
            #show_macros if n == "__cplusplus"
         else           # if WIN32
           # idf = (ifdefined?(n)# && (@macros[n].to_i.to_s == @macros[n] && @macros[n].to_i != 0) )
            idf = !( ifdefined?(n) == false || ( @macros[n].to_i ==0 && @macros[n].to_i.to_s == @macros[n] ))

         end
         idf = !idf if neg
         p "===>pre_if5:idf=#{idf} "
=end         
        idf = _pre_if()
        p "===>pre_if6:idf=#{idf}"
        # p "===>pre_if8:#{@scanner.buffer}", 10
         @scanner.delete_curline
        # p "===>pre_if7:#{@scanner.buffer}"
         
         pos1 = @scanner.buffPos
         @directive=_preprocess(["#else", "#endif", "#elif"], idf)
      #  p "===>pre_if:directive=#{@directive}", 10
         #pos2 = @scanner.buffPos
         
         pos2 = @scanner.nextSym.pos
        # p ("pos1:#{pos1}, #{@scanner.buffer[pos1..pos1+5]}, currSym:#{@scanner.currSym.sym}")
         
        # p ("pos2:#{pos2}, #{@scanner.buffer[pos2..pos2+5]}, currSym:#{@scanner.currSym.sym}")
         if !idf || !doprepro
             #p "-->33333, pos #{@scanner.buffPos}, current ch #{@scanner.cch.inspect}"
             #p "before replace #{idf}:#{@scanner.buffer}"
            # p "===>pre_if63:pos1:#{pos1}, pos2:#{pos2}, #{@scanner.buffer[pos1..pos1+10]}"
             @scanner.delete_lines(pos1, pos2, false) # delete whole block
             #p "-->33333, pos #{@scanner.buffPos}, current ch #{@scanner.cch.inspect}"
             
           #  p "after replace #{idf}:#{@scanner.buffer}"
             
         else
             p "-->333332"
             
             # @scanner.delete_prevline # only delete #preprocess(#else or #endif) line
         end        
        # pre = GetPre()
        
        # _str1 = curString()
        #   Get()
        #   _str2 = curString()
        #   directive = "#{_str1}#{_str2}"
        
        if doprepro && idf
            doprepro = true
        end
        p "===>pre_if33:directive=#{@directive}"
        while @directive == "\#elif"
            idf2 = pre_elif(doprepro) # only when doprepor == true and condition is true then will return true
            if idf2 && doprepro
                doprepro = false # if current one fufill, ignore remaining
            end
        end
        p "===>pre_if34:directive=#{@directive}"
        
        pre_else(doprepro, !idf)
        p "===>pre_if35:directive=#{@directive}"
        
        pre_endif(doprepro, idf)
    end
    def pre_ifndef(doprepro)
         pre_ifdef(doprepro, true)
    end    
    def _preprocess(until_find = [], process_directive = true)
        while (@sym!=C_EOF_Sym)
            
             #p "_preprocess1:sym2: line #{@scanner.currLine}, sym #{@sym}, d:#{@directive}, #{curString()}, #{@scanner.buffer[@scanner.buffPos..@scanner.buffPos+10]}"
            if @sym == C_PreProcessorSym
                #_str1 = curString()
                ## pp "preprocessor: #{@sym}, #{_str1}", 20
                #Get()
                #_str2 = curString()
                #@directive = "#{_str1}#{_str2}"
                @directive = curString()
                #p "_preprocess directive3:#{@directive}, #{@scanner.buffer[@scanner.buffPos-30..@scanner.buffPos+30]}"
                #p "_preprocess directive=#{@directive}, until_find=#{until_find.inspect}, process_directive=#{process_directive}", 10
              
                if until_find.include?(@directive)
                   # p "222222#{@directive}"
              #      p "--->222", 10
                    return @directive
            #    elsif process_directive == true
               else
                  # p "1111111#{@directive}"
                    preprocess_directive(process_directive)
                    #@directive = preprocess_directive()
                    #next
                    
                end
                # return @directive if stop_on_unkown_directive && @directive
            else
                if @sym == C_identifierSym 
                    #p "prepcoess identifier3:#{@scanner.nextSym.inspect}"
                    #p "prepcoess identifier31:#{@scanner.buffer[@scanner.nextSym.pos..@scanner.nextSym.pos+10]}"
                    #p "prepcoess identifier31:#{@scanner.buffer[@scanner.buffPos..@scanner.buffPos+10]}"
                    idf = curString()
                    #p "prepcoess identifier:#{idf}", 10
                    p_start = @scanner.nextSym.pos
                    p_end = p_start + @scanner.nextSym.len-1
                    res = ""
                    # p "nextsym:#{@scanner.nextSym.sym}"
                    # p_end = @scanner.nextSym.pos
                    hasArg = false
                    sym_pos = @scanner.nextSym.pos
                    __t = Time.now.to_f
                    if idf == "_CACHE_READ_LOCK_"
                       # throw "ffff"
                    end
                    if ifdefined?(idf)
                         Get()
                         _res = @macros[idf]
                        res = _res[:v]
                        #p "===>defined:#{idf}, #{@sym}, #{res}"
                        if @sym == C_LparenSym && _res[:hasArg] == true
                            p "hasarg"
                            hasArg = true
                            Get()
                            v,args = ActualParameters()
                            #args = ActualParameters()
                            p "args:#{args}"
                            p_end = @scanner.nextSym.pos
                            
                            Expect(C_RparenSym)
                            p "end:#{p_end}"
                            
                            if hasArg == _res[:hasArg] # fill arg
                                cs = @macros[idf][:v]
                                p "cs:#{cs}"
                                res = cs.gsub(/%<\d+>%/){|m|
                                    index = -1
                                    m.scan(/%<(\d+)>%/){|i|
                                        p i.inspect
                                        index = i[0].to_i

                                    }
                                    args[index] 
                                }
                              res = res.gsub("__VA_ARGS__", v)
                              #res = res.gsub("__VA_ARGS__", args.join(","))
                                p "--->result:#{res}"
                            end
                        end
                        
                        # handle ##
                        res = res.gsub(/\s*##\s*/,"")
                        
                        p "defined:#{idf}"
                        p "#{hasArg}==#{_res[:hasArg]}=#{hasArg == _res[:hasArg]}"
                        
                         if hasArg == _res[:hasArg] # macro only match when both has arg or not
                            #p "p_start=#{p_start},p_end=#{p_end}, #{@scanner.buffer[p_start..p_end]}"
                            #p "pos:#{@scanner.buffer[@scanner.buffPos..@scanner.buffPos+10]}"
                            p "sym:#{@sym}"
                            replaced = @scanner.buffer[p_start..p_end]
                           # lines_replaced = replaced.scan(/\n/).count
                            if p_start <= 0 
                                s = res + @scanner.buffer[p_end+1..@scanner.buffer.size-1]
                            else
                                s = @scanner.buffer[0..p_start-1] + res + @scanner.buffer[p_end+1..@scanner.buffer.size-1]
                            end
                        
                            old_size = @scanner.buffer.size
                             sizediff = s.size()-old_size
                            po = @scanner.buffPos
                           #  p "before replace #{idf}:#{@scanner.buffPos},#{@scanner.buffer[po..po+10]}"
                            # p "before replace #{idf}:#{@scanner.buffer}"
                        
                            @scanner.buffer = s
                           @scanner.buffPos = sym_pos
                          @scanner.fix_ch
                         #  p "after replace macro #{idf}:#{@scanner.buffer[@scanner.buffPos..@scanner.buffPos+10]}"
                       
                           Get()
                          # p "after replace macro2 #{idf}:#{@sym}, #{curString}"
                            #@scanner.buffPos += sizediff
                            #po = @scanner.buffPos
                            #p "size diff:#{s.size()-old_size}"
                           #  p "after replace #{idf}:#{@scanner.buffPos},#{@scanner.buffer[po..po+10]}"
                           #  p "after replace #{idf}:#{@scanner.buffer}"
                       
                            # @scanner.currLine -= lines_replaced if lines_replaced>0   
                            # @scanner.nextSym.line -= lines_replaced if lines_replaced>0
                            #@scanner.nextSym.pos += sizediff
                            #if lines_replaced == 0
                            #    @scanner.nextSym.col += sizediff
                            #else
                            #    pos_ns = @scanner.nextSym.pos
                            #    i = 0
                            #    while (@scanner.buffer[pos_ns]!="\n" && pos_ns >=0)
                            #        pos_ns-=1
                            #        i+=1
                            #    end
                            #    @scanner.nextSym.col = i-1
                            #end
                             # currSym maybe already replaced
                           #  @scanner.currSym.line -= lines_replaced if lines_replaced>0
                           #  @scanner.currSym.pos += sizediff
                           p "@@@ replace macro #{idf} line #{@scanner.currLine} cost #{Time.now.to_f - __t}"
                   
                            next
                        end
                    end #if ifdefined?(idf)
                elsif @sym == C_inlineSym #ignore inline statement
                    __t = Time.now.to_f
                    p_start = @scanner.nextSym.pos
                    p_end = p_start + @scanner.nextSym.len
                    Get()
                   # p "p_start=#{p_start},p_end=#{p_end}"
                    if p_start <= 0 
                        s = @scanner.buffer[p_end..@scanner.buffer.size-1]
                    else
                        s = @scanner.buffer[0..p_start-1] + @scanner.buffer[p_end..@scanner.buffer.size-1]
                    end
                    old_size = @scanner.buffer.size
                    # p "before replace:#{@scanner.buffer}"
                    @scanner.buffer = s
                    @scanner.buffPos += s.size()-old_size
                    # p "after replace:#{@scanner.buffer}"
                    p "@@@ remove inline cost #{Time.now.to_f - __t}"
                    next
                elsif @sym == C_classSym # to gather all classes name
                    _n = GetNextSym().sym
                    if _n != C_CommaSym && _n != C_GreaterSym # not as parameter in template. e.g. template<class A, class B>
                        Get()
                        $pre_classlist = {} if $pre_classlist == nil
                        $pre_classlist[curString()]=1
                    end
                elsif @sym == C_templateSym
                    filterTemplate(1)
                end
            end
            # if @sym == C_identifierSym
            #     cs = curString()
            #     if ifdefined?(cs)
            #         @macros[n]
            #     end
            # end
            #p "before get:buffer(#{@scanner.buffer.size}):#{@scanner.buffer}"
            
            Get()
            # p "_preprocess0:sym3:#{@sym}, d:#{@directive}, #{@scanner.nextSym.inspect}, #{curString()}"
            @count += 1
            if @count > 100
                p "==>count:#{@scanner.currLine}, #{@saved_line}, #{@scanner.remain_enough_line?(31)} "
                @count = 0
                if @scanner.currLine - @saved_line > 10000 && @scanner.remain_enough_line?(31)
                p "before save:#{@scanner.currLine}"
                    ln = @scanner.save_part(@file_save)
                    @saved_line +=ln
                    p "saved #{ln} to #{@file_save}"
                    p "after save:#{@scanner.currLine}, #{@saved_line}"
                end
            end
        end # while
       # p "buffer(#{@scanner.buffer.size}):#{@scanner.buffer}"
       # p "bufferPos:#{@scanner.buffPos}, #{@sym}, d:#{@directive}, #{@scanner.nextSym.inspect}, #{curString()}"
        #throw "shouldn't goto here"
    end
    
    

    def dump_pos(pos=@scanner.buffPos, lines = 5)
        pos=@scanner.buffPos if pos == nil
            
        p("start dump pos in macro.rb:pos #{pos}, buf size #{@scanner.buffer.size}, line #{@scanner.currLine}, saved line #{@saved_line}#{@scanner.buffer[pos..pos+100]}", 5)
        lino = get_lineno_by_pos(pos)+1
        lino += @saved_line
        
        p "---- dump position ----"
        i = lines
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
        
        pos1 = @scanner.buffPos
        pos1 -= 30
        pos1 = 0 if pos1 < 0
        p "==>#{@scanner.buffer[pos1..@scanner.buffPos+30]}"
        
    end    
	

=begin      
    def expand_macro(cs)
        ret = ""
        pos = 0
        Get()
        while @sym != C_EOF_Sym
            idf = curString()
            p_start = @scanner.nextSym.pos
            res = "" 
            Get()
            p_end = @scanner.nextSym.pos
            
            if ifdefined?(idf)
                p "start:#{p_start}, #{idf}"
                res = @macros[idf]
                if @sym == C_LparenSym
                    Get()
                    args = ActualParameters()
                    p "args:#{args}"
                    Expect(C_RparenSym)
                    p_end = @scanner.nextSym.pos
                    p "end:#{p_end}"
                    
                    cs = @macros[idf]
                    p "cs:#{cs}"
                    res = cs.gsub(/%<\d+>%/){|m|
                        index = -1
                        m.scan(/%<(\d+)>%/){|i|
                            p i.inspect
                            index = i[0].to_i
                           
                        }
                        args[index] 
                    }
                    p "--->result:#{res}"
                end
                ret += @scanner.buffer[pos..p_start-1]
                ret += res
                pos = p_end
     
            end
            
        end
        ret += @scanner.buffer[pos..@scanner.buffer.size-1]
       
        
       p ret
      
      p "====macros====="
      @macros.each{|n,v|
      
       p "===>#{n}=>#{v}"
      }
      
       return ret
    
    end
    

=end    
    
    def show_macros
        p "====macros====="
        @macros.each{|n,v|
        p "===>#{n}=>#{v}"
     }
    end
    
    def dump_macros_to_file(fname)
        s = ""
        @macros.each{|n,v|
            s+="#{n}=>#{v}\n"
     }
     save_to_file(s, fname)
    end
    def dump_classes_to_file(fname)
        s = ""
        list = $pre_classlist.keys.sort
        p "=====>list classes:"
        p list.inspect
        list.each{|n|
            s+="#{n}\n"
     }
     save_to_file(s, fname)
     p "classes list dumped to file #{fname}"
     
    end
end # class Preprocessor






load 'macrotest.rb'
