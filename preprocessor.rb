# process macro of c/c++
load "cp.rb"

# hide_p_in_file(__FILE__)
class Preprocessor < Parser
 
    def Preprocess(include_predined_file = true)
         if include_predined_file 
             include_file("c_macros.c") # predefined macros
         end
         @in_preprocessing = true
         Get()
         p "sym3333:#{@sym},#{curString()}, #{@directive}"
         # _preprocess(false)
         _preprocess()
         @in_preprocessing = false
         # @scanner.Reset()
         # ret = expand_macro(@scanner.buffer)
         # p "after expand_macro: #{ret}"
         return @scanner.buffer
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
    # def GetD()
    #     @directive = nil
    #     super
    #     if @sym == C_PreProcessorSym
    #         _str1 = curString()
    #         super
    #         _str2 = curString()
    #         p "#{_str1},#{_str2}"
    #         @directive = "#{_str1}#{_str2}"
    #     end
    # end
     def GetDirective()
         @directive = nil
         Get()
         while @sym != C_EOF_Sym && @sym != C_PreProcessorSym
            # p "GetDirective:sym=#{@sym}, v=#{curString()}"
             #if @sym == C_EOF_Sym
            #     @directive = C_EOF_Sym
            #     return @directive
            # end
             Get()
         end
         if (@sym == C_PreProcessorSym)
             @directive = curString()
         end
         #_str1 = curString()
         ## pp "preprocessor: #{@sym}, #{_str1}", 20
         #Get()
         #_str2 = curString()
         #@directive = "#{_str1}#{_str2}"
         #return @directive
     end
     
     def _preprocess(until_find = [], process_directive = true)
         while (@sym!=C_EOF_Sym)
            
              p "sym2:#{@sym}, #{curString()}"
             if @sym == C_PreProcessorSym
                 #_str1 = curString()
                 ## pp "preprocessor: #{@sym}, #{_str1}", 20
                 #Get()
                 #_str2 = curString()
                 #@directive = "#{_str1}#{_str2}"
                 @directive = curString()
                 p "_preprocess directive=#{@directive}, until_find=#{until_find.inspect}, process_directive=#{process_directive}"
                 if until_find.include?(@directive)
                     p "--->222", 10
                     return @directive
                 elsif process_directive == true
                     @directive = preprocess_directive()
                     next
                 end
                 # return @directive if stop_on_unkown_directive && @directive
             else
                 if @sym == C_identifierSym
                     idf = curString()
                     p "prepcoess identifier:#{idf}", 10
                     p_start = @scanner.nextSym.pos
                     p_end = p_start + @scanner.nextSym.len
                     res = ""
                     Get()
                     # p "nextsym:#{@scanner.nextSym.sym}"
                     # p_end = @scanner.nextSym.pos
                    
                     if ifdefined?(idf)
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
                         p "p_start=#{p_start},p_end=#{p_end}"
                         if p_start <= 0 
                             s = res + @scanner.buffer[p_end..@scanner.buffer.size-1]
                         else
                             s = @scanner.buffer[0..p_start-1] + res + @scanner.buffer[p_end..@scanner.buffer.size-1]
                         end
                         old_size = @scanner.buffer.size
                         # p "before replace:#{@scanner.buffer}"
                         @scanner.buffer = s
                         @scanner.buffPos += s.size()-old_size
                         # p "after replace:#{@scanner.buffer}"
                         next
                     end
                            
                 end
             end
             # if @sym == C_identifierSym
             #     cs = curString()
             #     if ifdefined?(cs)
             #         @macros[n]
             #     end
             # end
             Get()
         end # while
     end

      
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
    
     def show_macros
         p "====macros====="
         @macros.each{|n,v|

          p "===>#{n}=>#{v}"
      }
     end
     
     def ifdefined?(n)
         return @macros[n] != nil
     end
     # get the whole preprocessor directive
     def GetPre()
         GetDirective()
     end
     
     def pre_if()
         Get()
          n = curString()
         
          if n=~ /^\d+$/
             idf = (n.to_i !=0)
          else
             idf = (ifdefined?(n) && @macros[n].to_i != 0)
          end
         
          @scanner.delete_curline
=begin          
          pos1 = @scanner.buffPos
          @directive=_preprocess(["#else", "#endif", "#elif"], idf)
          p "directive=#{@directive}", 10
          pos2 = @scanner.buffPos
         

        
          if !idf
              # p "-->33333, pos #{@scanner.buffPos}, current ch #{@scanner.cch.inspect}"
              @scanner.delete_lines(pos1, pos2, false) # delete whole block
              # p "-->33333, pos #{@scanner.buffPos}, current ch #{@scanner.cch.inspect}"
             
          else
              p "-->333332"
             
              # @scanner.delete_prevline # only delete #preprocess(#else or #endif) line
          end        
         # pre = GetPre()
        
         # _str1 = curString()
         #   Get()
         #   _str2 = curString()
         #   directive = "#{_str1}#{_str2}"
=end
         _pre_afterif(idf)
                  

         pre_elif(idf)
         pre_else(idf)
         pre_endif(idf)
     end
     def pre_elif(idf)
         while @directive == "\#elif"
            pre_if()
         end
     end    
=begin
     def pre_elif(idf)
         while @directive == "\#elif"
             # Get()
             Get()
              n1 = curString()
              # p "==>112:#{n1}, #{@scanner.buffPos}"
              delete_curline
              
              pos11 = @scanner.buffPos
              @directive=_preprocess(["#else", "#endif", "#elif"], !idf)
              p "directive=#{@directive}", 10
             
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
             # p "111=>#{@scanner.buffer}, pos #{@scanner.buffPos}, #{@scanner.dump_char}"
             # delete_prevline # delete #else line
             delete_curline
             # p "112=>#{@scanner.buffer}, pos #{@scanner.buffPos}, idf=#{idf}"
                
              pos11 = @scanner.buffPos
              @directive=_preprocess(["#else", "#endif", "#elif"], !idf)
              # p "pre_else: directive=#{@directive}, pos #{@scanner.buffPos}, buffer #{@scanner.buffer}, #{@scanner.dump_char}", 20
              # p "222=>#{@scanner.buffer}, pos #{@scanner.buffPos}, ch #{@scanner.cch.inspect}"
             
              pos22 = @scanner.buffPos
              # p "hahaha11:#{directive}"
        
             if idf
                 # p "==>pos11:#{pos11}, #{pos22}, buffer #{@scanner.buffer}"
                 delete_lines(pos11, pos22, false) # delete whole else part include #endif
                 # p "==>pos12:#{pos11}, #{pos22}, buffer #{@scanner.buffer}"
                
             else
                 # pos is next char after current directive
                 # delete_prevline # only delete #endif line
             end

             if @directive == "\#endif"
                 # p "hahaha:#{directive}"
                 # @scanner.delete_curline
             end
         end
     end
=end     
     def _pre_afterif(idf)
         count = 1
         pos1 = @scanner.buffPos
         
         p "@directive1:#{@directive}, sym:#{@sym}，count=#{count}"
         
         if (idf)
             GetDirective()
             while @directive
                 p "_pre_afterif1:@directive:#{@directive}, pos #{@scanner.buffPos}, sym:#{@sym}，count=#{count}, buff:#{@scanner.buffer}", 10
                 if @directive == "#endif"
                     count -=1
                     if count == 0
                         break
                     end
                 elsif @directive == "#elif"  || @directive == "#else"
                     if count == 1
                         break
                     end
                     
                 elsif @directive == "#if" || @directive == "#ifdef" || @directive == "#ifndef"
                     count += 1
                 end
                 preprocess_directive() if @directive
                 GetDirective()
             end
         else
             while @directive
                 p "_pre_afterif2:@directive:#{@directive}, sym:#{@sym}，count=#{count}"
                 if @directive == "#endif" || @directive == "#elif"  || @directive == "#else"
                     count -=1
                     if count == 0
                         pos2 = @scanner.buffPos
                         delete_lines(pos1, pos2, false) # delete whole block (...)#else
                         break
                     end
                 elsif @directive == "#if" || @directive == "#ifdef" || @directive == "#ifndef"
                     count += 1
                 end
                 GetDirective()
             end
             
         end
         p "@directive2:#{@directive}, sym:#{@sym}，pos=#{@scanner.buffPos}"
         
     end
     def pre_ifdef(ifndef=false)
          Get()
          n = curString()
          # p "n=#{n}, pos #{@scanner.buffPos}, buffer #{@scanner.buffer}"
          delete_curline  # delele line #ifdef
          # p "pos #{@scanner.buffPos}, buffer #{@scanner.buffer}"
         
          idf = ifdefined?(n)
          pp "idf=#{idf}, @sym=#{@sym}",20
          if ifndef
              idf = !idf
          end
          _pre_afterif(idf)
          p "idf1=#{idf}, @sym=#{@sym}, @directive=#{@directive}"
          
          pre_elif(idf)
          p "idf2=#{idf}, @sym=#{@sym}, @directive=#{@directive}"
          
          pre_else(idf)
          p "idf3=#{idf}, @sym=#{@sym}, @directive=#{@directive}"
          
          pre_endif(idf)
=begin          
           @ifstack.push(idf)
          
          pos1 = @scanner.buffPos
          #@directive = _preprocess(["#else", "#endif", "#elif"], idf)
          count = 1
          while(@directive!=C_EOF_Sym)
              p "@directive:#{@directive}, sym:#{@sym}，count=#{count}"
              if @directive == "#endif"
                  count -=1
                  if count == 0
                      if (!@ifstack.pop)
                          # delete block
                      end
                      break
                  end
              elsif @directive == "#if" || @directive == "#ifdef" || @directive == "#ifndef"
                  preprocess_directive()
                  count += 1
              end
              GetDirective()
          end
          
          p "pre_ifdef: directive=#{@directive}, sym=#{@sym}"
         
          pos2 = @scanner.buffPos
          # p "pos:#{@scanner.buffPos}"
         
          p "pre_ifdef1:pos:#{@scanner.buffPos}, #{@sym}, #{curString()}, #{@scanner.dump_char}, line #{@scanner.currLine}, col #{@scanner.currCol}"
          p "buffer:\n#{@scanner.buffer}"
  # p "===>114:pos1:#{pos1}, pos2 #{pos2}, pos #{@scanner.buffPos}"
          # p "===>113:#{@scanner.buffer}"
          # p "===>114:pos1:#{pos1}, pos2 #{pos2}, pos #{@scanner.buffPos}, buffer=#{@scanner.buffer}, #{@scanner.buffer[@scanner.buffPos].inspect}"
          if !idf
              delete_lines(pos1, pos2, true) # delete whole block (...)#else
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
       
         pre_elif(idf)
         pre_else(idf)
         pre_endif(idf)
=end        
     end
     def pre_endif(idf)
         if @directive == "\#endif"
             p "9999:pos #{@scanner.buffPos},#{@scanner.cch.inspect}, buffer #{@scanner.buffer}", 10
             # @scanner.delete_prevline
             delete_curline
             
             p "99991:pos #{@scanner.buffPos}, sym=#{@sym}, directive=#{@directive}, buffer #{@scanner.buffer}"
             
          #   GetDirective()
             p "99992:pos #{@scanner.buffPos}, sym=#{@sym}, directive=#{@directive}, buffer #{@scanner.buffer}"
             
         end
     end
     def pre_ifndef()
          pre_ifdef(true)
     end    
        
    def pre_else(idf)
        def pre_else(idf)
            if @directive == "\#else"
                delete_curline
                _pre_afterif(!idf)
            end
        end
    end
=begin    
     def pre_define()
          Get()
         n = curString()
       
         v = @scanner.skip_curline
          p "==>define:#{n},#{v}", 10
         macro_str = add_macro(n, v)
         delete_prevline
         # @scanner.delete_line
         # p "pos:#{@scanner.buffPos}, buffer:#{@scanner.buffer}"
         if macro_str
             @scanner.insert_line(macro_str)
         end
     end
=end
     # process every directive
     def preprocess_directive()
=begin        
           _str1 = curString()
           # pp "preprocessor: #{@sym}, #{_str1}", 20
           Get()
           _str2 = curString()
           @directive = "#{_str1}#{_str2}"
=end          
           p "preprocess_directive0 #{@directive}, line=#{@scanner.currLine}", 10
           if  @directive == "\#include"
               p "====>preprocess_directive1"
               Get()
               if (@sym == 4) # string
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
               else # @sym should be 13 # <
                    Get()
                    finclude = curString()
                    p "@sym=#{@sym}"
                    p "current sym:#{@scanner.currSym.sym}"
                    p "fclude:#{finclude}"
                    Get()
               end
               p "-->include file #{finclude}"
               #p self.inspect
               #p @scanner.inspect
               include_file(finclude)  
         elsif @directive == "\#define" 
             p "====>preprocess_directive2"
            
            pre_define()
            
         elsif @directive == "\#ifdef"
             p "====>preprocess_directive3"
            
             pre_ifdef()
         elsif @directive == "\#ifndef"
             p "====>preprocess_directive4"
            
             pre_ifndef()
         elsif @directive == "\#if"
             p "====>preprocess_directive5"
            
             pre_if()
         else
                # @scanner.delete_curline
                # if !["#else", "#endif", "elif"].include?(@directive)
                    # @scanner.skip_curline
                 skip_curline
                # end
                return @directive
         end
         # p "after process directive #{@directive}:#{@scanner.buffer}"
         return nil
     end
     
     def pre_define()
               Get(false)
               # Expect(C_identifierSym)
               p "c0000=#{@sym}, #{curString()}, line #{@scanner.currLine}, ch=#{@scanner.cch.to_byte}"
               n = curString()
               Get(false)
                  # n = prevString()
                  args =[]
                  v = ""
                  p "c1111=#{@sym}, #{curString()}, line #{curLine}"
                  if @sym == C_CRLF_Sym
                      @scanner.skip_curline(true)
                  elsif (@sym == C_LparenSym)
                      Get()
                      Expect(C_identifierSym)
                      args.push(prevString())
                      while (@sym == C_CommaSym)
                          Get()
                          Expect(C_identifierSym)
                          args.push(prevString())
                      end
                      #Expect(C_RparenSym)
                      v = @scanner.skip_curline(true)
                  else
                      v = @scanner.skip_curline(true, @scanner.nextSym.pos)
                  end
           
                  
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
                  delete_prevline
                  # p "pre_define1:pos=#{@scanner.buffPos}, buffer #{@scanner.buffer}, sym:#{@sym}"  

                  v=v.gsub(/(\w[\w\d_]*)/){|m|
                     p m.inspect
                     count = args.index(m)
                     if count
                         "%<#{count}>%"
                     else
                         m
                     end
                   }
                   p "v=#{v}"
                   add_macro(n, v)
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
    def STLType()
       ret = "<"
            Get()
            ret +=FormalParamList()
            Expect(C_GreaterSym)
        ret += ">"
        return 
    end
     def Type()
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
                      	Expect(C_identifierSym)
                    end
          	    else
    		    	
    			        ret += varname
    			    
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

end

def test(testall=false)






s=<<HERE
#ifndef	MNHL_SERVER_MODE
						TCHAR	ContinueStr[50];

						_STR_GetStringResource (ContinueStr, BGT0_FORM_NUM, BGT0_CONTINUE_STR);
retBtn = FORM_GEN_Message (msgStr1, ContinueStr, CANCEL_STR(*OOGetEnv(NULL)), YES_TO_ALL_STR(*OOGetEnv(NULL)), 2);
#else
						retBtn = 2;
#endif
	switch (retBtn)
	{
		case 1://formOKReturn
		case 3://formOKReturn
			budgetAllYes = (retBtn == 3 ? TRUE:FALSE);
			if (budgetAllYes)
			{
				SetExCommand ( ooDontUpdateBudget, fa_Set );
			}

			if (GetEnv ().GetPermission (PRM_ID_BUDGET_BLOCK) != OO_PRM_FULL)
			{
				DisplayError (fuNoPermission);
				return ooErrNoMsg;//fuNoPermission;
			}
			//return ooNoErr;
		break;

		case 2:
			return ooErrNoMsg;
		break;

	}
#define ABC 1 //fdafsa
HERE
s=<<HERE
a = 1;
#define AAA 1//f/sdafs
#define AAAa //f/sdafs
#define BBB "fd/*a*/s//fas" //fdasfsd
#define C(a) c(/*fdfasf*/a, "fd/*af*/s") //fdasfsd
HERE
s=<<HERE
/************************************************************************************/
/************************************************************************************/
SBOErr CTransactionJournalObject::OnCreate()
{
        _TRACER("OnCreate");
	SBOErr	ooErr = noErr;
	PDAG	dagJDT, dagJDT1, dagCRD;
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

#ifdef QC_SHELL_ON
		qc = TRUE;
#else
		qc = FALSE;
#endif

	
		
	dagJDT = GetDAG();
	dagJDT1 = GetDAG(JDT, ao_Arr1);
    PDAG dagJDT2 = GetDAG(JDT, ao_Arr2);
    if(!dagJDT2->GetRealSize(dbmDataBuffer)) 
    {
        dagJDT2->SetSize(0, dbmDropData);
    }
    dagCRD = GetDAG (CRD);
	// If from observer and IsVatPerLine and the vat line is zero amount
	// we need to nullify debit/credit col for the Vat Report, until the
	// Vat Report start to use the new col JDT1_DEBIT_CREDIT. 
	if (GetDataSource () == *VAL_OBSERVER_SOURCE && bizEnv.IsVatPerLine ())
	{
		DAG_GetCount (dagJDT1, &numOfRecs);
		for (rec = 0; rec < numOfRecs; rec++)
		{
			dagJDT1->GetColStr (tmpStr, JDT1_VAT_LINE, rec);
			if (tmpStr[0] == VAL_YES[0])
			{
				dagJDT1->GetColMoney (&debAmount, JDT1_DEBIT, rec, DBM_NOT_ARRAY);
				dagJDT1->GetColMoney (&credAmount, JDT1_CREDIT, rec, DBM_NOT_ARRAY);
				if (debAmount.IsZero() && credAmount.IsZero())
				{
					dagJDT1->GetColStr (tmpStr, JDT1_DEBIT_CREDIT, rec);
					if (tmpStr[0] == VAL_DEBIT[0])
					{
						dagJDT1->NullifyCol (JDT1_CREDIT, rec);
					}
					else if (tmpStr[0] == VAL_CREDIT[0])
					{
						dagJDT1->NullifyCol (JDT1_DEBIT, rec);
					}
				}
			}
		}
	}

	SetDebitCreditField();

	contraCredKey[0] = '\0';
	contraDebKey[0] = '\0';
	
	transTotal.SetToZero();
	transTotalChk.SetToZero();
	fTransTotal.SetToZero();
	sTransTotal.SetToZero();

	_STR_strcpy (mainCurr, bizEnv.GetMainCurrency ());
	_STR_LRTrim (mainCurr);

	// Clear the recalc columns if recalcing to the main currency or if rate is zero //
	dagJDT->GetColMoney (&rateMoney, OJDT_TRANS_RATE, 0, DBM_NOT_ARRAY);
	dagJDT->GetColStr (tempStr, OJDT_ORIGN_CURRENCY, 0);
	_STR_LRTrim (tempStr);
	if (GNCoinCmp (tempStr, mainCurr)==0 || rateMoney.IsZero())
	{
		tempStr[0] = 0;
		//		dagJDT->SetColStr (tempStr, OJDT_ORIGN_CURRENCY, 0);
	}

	DAG_GetCount (dagJDT1, &numOfRecs);

	if (VF_RmvZeroLineFromJE (bizEnv) && !bizEnv.IsZeroLineAllowed ())
	{
	for (rec = 0; rec < numOfRecs; rec++)
	{
			dagJDT1->GetColMoney (&debAmount, JDT1_DEBIT, rec);
			dagJDT1->GetColMoney (&credAmount, JDT1_CREDIT, rec);
			dagJDT1->GetColMoney (&fDebAmount, JDT1_FC_DEBIT, rec);
			dagJDT1->GetColMoney (&fCredAmount, JDT1_FC_CREDIT, rec);
			dagJDT1->GetColMoney (&sDebAmount, JDT1_SYS_DEBIT, rec);
			dagJDT1->GetColMoney (&sCredAmount, JDT1_SYS_CREDIT, rec);
			
			MONEY	debBalanceDue, credBalanceDue, fDebBalanceDue, fCredBalanceDue, sDebBalanceDue, sCredBalanceDue;
			dagJDT1->GetColMoney (&debBalanceDue, JDT1_BALANCE_DUE_DEBIT, rec);
			dagJDT1->GetColMoney (&credBalanceDue, JDT1_BALANCE_DUE_CREDIT, rec);
			dagJDT1->GetColMoney (&fDebBalanceDue, JDT1_BALANCE_DUE_FC_DEB, rec);
			dagJDT1->GetColMoney (&fCredBalanceDue, JDT1_BALANCE_DUE_FC_CRED, rec);
			dagJDT1->GetColMoney (&sDebBalanceDue, JDT1_BALANCE_DUE_SC_DEB, rec);
			dagJDT1->GetColMoney (&sCredBalanceDue, JDT1_BALANCE_DUE_SC_CRED, rec);

			if (debAmount.IsZero() && credAmount.IsZero() &&
				fDebAmount.IsZero() && fCredAmount.IsZero() &&
				sDebAmount.IsZero() && sCredAmount.IsZero() &&
				debBalanceDue.IsZero() && credBalanceDue.IsZero() &&
				fDebBalanceDue.IsZero() && fCredBalanceDue.IsZero() &&
				sDebBalanceDue.IsZero() && sCredBalanceDue.IsZero())
			{
				dagJDT1->RemoveRecord (rec);
				rec--;
				numOfRecs--;
			}
		}
	}

	//Set Transaction type (Creating Object type)
	dagJDT->GetColLong(&transType, OJDT_TRANS_TYPE);

	if (transType == -1)
	{
		dagJDT->SetColLong(JDT, OJDT_TRANS_TYPE);

		transType = JDT;
	}

	SBOString deferredTax;
	dagJDT->GetColStr(deferredTax, OJDT_DEFERRED_TAX);
	deferredTax.Trim ();
	bool isDeferredTax = (deferredTax == VAL_YES);

	for (rec = 0; rec < numOfRecs; rec++)
	{
		dagJDT1->GetColStr (acctKey, JDT1_ACCT_NUM, rec);
		dagJDT1->GetColStr (cardKey, JDT1_SHORT_NAME, rec);

		itsCard = (_STR_stricmp (acctKey, cardKey) != 0) && (!_STR_IsSpacesStr (cardKey));
		if (itsCard )
		{
            CBPBalanceChangeLogData bpBalanceChangeLogData(bizEnv);
            bpBalanceChangeLogData.SetCode(cardKey);
            bpBalanceChangeLogData.SetControlAcct(acctKey);
            bpBalanceChangeLogData.SetDocType(JDT);

			ooErr = bizEnv.GetByOneKey (dagCRD, GO_PRIMARY_KEY_NUM, cardKey, true);
			if (ooErr != noErr)
			{
				if (ooErr == dbmNoDataFound)
				{
					Message (OBJ_MGR_ERROR_MSG, GO_CARD_NOT_FOUND_MSG, cardKey, OO_ERROR);
					return (ooErrNoMsg);
				}
			
				else
				{
					return ooErr;
				}
			}

            dagCRD->GetColMoney(&tempMoney, OCRD_CURRENT_BALANCE);
            bpBalanceChangeLogData.SetOldAcctBalanceLC(tempMoney);
            dagCRD->GetColMoney(&tempMoney, OCRD_F_BALANCE);
            bpBalanceChangeLogData.SetOldAcctBalanceFC(tempMoney);

            bpBalanceLogDataArray.Add(bpBalanceChangeLogData);
		}

		if (_STR_IsSpacesStr (acctKey))
		{
			dagJDT1->CopyColumn (GetDAG(CRD), JDT1_ACCT_NUM, rec, OCRD_DEB_PAY_ACCOUNT, 0);
			dagJDT1->GetColStr (acctKey, JDT1_ACCT_NUM, rec);
		}

		ooErr = bizEnv.GetByOneKey (GetDAG(ACT), GO_PRIMARY_KEY_NUM, acctKey, true);
		if (ooErr != noErr)
		{
			if (ooErr == dbmNoDataFound)
			{
				//Retrieve original parameters
				Message (OBJ_MGR_ERROR_MSG, GO_ACT_MISSING, acctKey, OO_ERROR);
				return (ooErrNoMsg);
			}
		
			else
			{
				return ooErr;
			}
		}

// Set Default Distribution rule
        SBOString	ocrCode;
        PDAG        dagAct;
	    long jdtOcrCols[] = {JDT1_OCR_CODE, JDT1_OCR_CODE2, JDT1_OCR_CODE3, 
                             JDT1_OCR_CODE4, JDT1_OCR_CODE5};
        long actOcrCols[] = {OACT_OVER_CODE, OACT_OVER_CODE2, OACT_OVER_CODE3,
                             OACT_OVER_CODE4, OACT_OVER_CODE5};
        long dimentionLen = VF_CostAcctingEnh(GetEnv()) ? DIMENSION_MAX : 1;
        dagAct = GetDAG(ACT);
		for (long dim = 0; dim < dimentionLen; dim ++)
        {
            if(dagJDT1->IsNullCol(jdtOcrCols[dim], rec))
            {
               dagAct->GetColStr(ocrCode, actOcrCols[dim], 0);
               if(!ocrCode.Trim().IsEmpty())
               {
                    dagJDT1->SetColStr(ocrCode, jdtOcrCols[dim], rec);
               }
            }   
        }
	 
		//
		// set valid from for profict code
		dagJDT1->GetColStr (ocrCode, JDT1_OCR_CODE, rec);
		
		SBOString	postDate, validFrom;
		dagJDT1->GetColStr (postDate, JDT1_REF_DATE, rec);
		ooErr = COverheadCostRateObject::GetValidFrom (bizEnv, ocrCode, postDate, validFrom);
		if (ooErr)
		{
			SetErrorField (JDT1_VALID_FROM);
			SetErrorLine (rec+1);
			return ooErr;
		}
		
		dagJDT1->SetColStr (validFrom, JDT1_VALID_FROM, rec);

		dagJDT1->GetColMoney (&debAmount, JDT1_DEBIT, rec, DBM_NOT_ARRAY);
		dagJDT1->GetColMoney (&credAmount, JDT1_CREDIT, rec, DBM_NOT_ARRAY);
		
		dagJDT1->GetColMoney (&fDebAmount, JDT1_FC_DEBIT, rec, DBM_NOT_ARRAY);
		dagJDT1->GetColMoney (&fCredAmount, JDT1_FC_CREDIT, rec, DBM_NOT_ARRAY);
		
		dagJDT1->GetColMoney (&sDebAmount, JDT1_SYS_DEBIT, rec, DBM_NOT_ARRAY);
		dagJDT1->GetColMoney (&sCredAmount, JDT1_SYS_CREDIT, rec, DBM_NOT_ARRAY);
		
		MONEY_Add (&transTotal, &debAmount);
		MONEY_Add (&transTotalChk, &credAmount);
		MONEY_Add (&fTransTotal, &fDebAmount);
		MONEY_Add (&sTransTotal, &sDebAmount);

		balanced = FALSE;

		if (VF_EnableCorrAct (bizEnv))
		{
			transTotalDebChk += debAmount;		
			transTotalCredChk += credAmount;
			fTransTotalDebChk += fDebAmount;;
			fTransTotalCredChk += fCredAmount;
			sTransTotalDebChk += sDebAmount;;
			sTransTotalCredChk += sCredAmount;

			if (transTotalDebChk == transTotalCredChk &&
				fTransTotalDebChk == fTransTotalCredChk &&
				sTransTotalDebChk == sTransTotalCredChk)
			{
				balanced = TRUE;
			}
		}
		else
		{
			if (!MONEY_Cmp (&transTotal, &transTotalChk))
			{
				balanced = TRUE;
			}
		}

		if (!IsExDtCommand (ooDoAsUpgrade) && transType != DAR)
		{
			//searching for first account in debit side and credit side,
			//to be the contra account
			if (_STR_strlen (contraDebKey) == 0)
			{
				if (debAmount.IsPositive()  ||
					fDebAmount.IsPositive() ||
					sDebAmount.IsPositive() ||
					credAmount.IsNegative() ||
					fCredAmount.IsNegative()||
					sCredAmount.IsNegative())
				{
					_STR_strcpy (contraDebKey, cardKey);
				}
			}

			if (_STR_strlen (contraCredKey) == 0)
			{
				if (credAmount.IsPositive() ||
					fCredAmount.IsPositive()||
					sCredAmount.IsPositive()||
					debAmount.IsNegative()  ||
					fDebAmount.IsNegative() ||
					sDebAmount.IsNegative())
				{
					_STR_strcpy (contraCredKey, cardKey);
				}
			}

			if (VF_EnableCorrAct (bizEnv))
			{
				// Same conditions as above, but because of necessarity to use VF_ flag and
				// different starting condition repeating here

				if (debAmount.IsPositive()  ||
					fDebAmount.IsPositive() ||
					sDebAmount.IsPositive() ||
					credAmount.IsNegative() ||
					fCredAmount.IsNegative()||
					sCredAmount.IsNegative())
				{
					contraDebLines++;
				}
				if (credAmount.IsPositive() ||
					fCredAmount.IsPositive()||
					sCredAmount.IsPositive()||
					debAmount.IsNegative()  ||
					fDebAmount.IsNegative() ||
					sDebAmount.IsNegative())
				{
					contraCredLines++;
				}
			}

			if (balanced && contraDebKey[0] && contraCredKey[0])
			{
				// For non VF_EnableCorrAct code, lastContraRec is always 0
				SetContraAccounts (dagJDT1, lastContraRec, rec+1, contraDebKey, contraCredKey, contraDebLines, contraCredLines);
				contraDebKey[0] = contraCredKey[0] = 0;

				if (VF_EnableCorrAct (bizEnv))
				{
					contraDebLines = contraCredLines = 0;
					lastContraRec = rec+1;
					transTotalDebChk = transTotalCredChk = fTransTotalDebChk = fTransTotalCredChk = sTransTotalDebChk = sTransTotalCredChk = 0L;
				}
			}
		}

		// Copy to balance due
		if (transType != DAR)
		{
			dagJDT1->GetColMoney(&creditBalDue, JDT1_CREDIT,rec);
			dagJDT1->GetColMoney(&debitBalDue, JDT1_DEBIT,rec);
			dagJDT1->GetColMoney(&fCreditBalDue, JDT1_FC_CREDIT,rec);
			dagJDT1->GetColMoney(&fDebitBalDue, JDT1_FC_DEBIT,rec);
			dagJDT1->GetColMoney(&sCreditBalDue, JDT1_SYS_CREDIT,rec);
			dagJDT1->GetColMoney(&sDebitBalDue, JDT1_SYS_DEBIT,rec);


			// VF_MultiBranch_EnabledInOADM
			bool zeroBalanceDue = false;
			if (IsZeroBalanceDueForCentralizedPayment () &&
				dagJDT1->GetColStrAndTrim (JDT1_ACCT_NUM, rec, coreSystemDefault) !=
				dagJDT1->GetColStrAndTrim (JDT1_SHORT_NAME, rec, coreSystemDefault))
			{
				zeroBalanceDue = true;
			}

			if ((!creditBalDue.IsZero() || !debitBalDue.IsZero() ||
				!fCreditBalDue.IsZero() || !fDebitBalDue.IsZero() ||
				!sCreditBalDue.IsZero() || !sDebitBalDue.IsZero())
				&& !zeroBalanceDue)
			{	
				dagJDT1->CopyColumn (dagJDT1, JDT1_BALANCE_DUE_DEBIT, rec, JDT1_DEBIT, rec);
				dagJDT1->CopyColumn (dagJDT1, JDT1_BALANCE_DUE_CREDIT, rec, JDT1_CREDIT, rec);
				dagJDT1->CopyColumn (dagJDT1, JDT1_BALANCE_DUE_SC_DEB, rec, JDT1_SYS_DEBIT, rec);
				dagJDT1->CopyColumn (dagJDT1, JDT1_BALANCE_DUE_SC_CRED, rec, JDT1_SYS_CREDIT, rec);
				dagJDT1->CopyColumn (dagJDT1, JDT1_BALANCE_DUE_FC_DEB, rec, JDT1_FC_DEBIT, rec);	
				dagJDT1->CopyColumn (dagJDT1, JDT1_BALANCE_DUE_FC_CRED, rec, JDT1_FC_CREDIT, rec);
			}
		}	

		SBOString vatLine;
		dagJDT1->GetColStr (vatLine, JDT1_VAT_LINE, rec);
		vatLine.Trim ();
		bool isVatLine = (vatLine == VAL_YES);
		if (isVatLine && isDeferredTax)
		{
			dagJDT1->SetColLong (IAT_DeferTaxInterim_Type, JDT1_INTERIM_ACCT_TYPE, rec);
		}
	} // end of for (rec)

	//budget flag
	if ( IsExCommand( ooDontUpdateBudget))
	{
		SetExCommand ( ooDontUpdateBudget, fa_Clear );
	}
	//budget flag
	
	if (MONEY_Cmp (&transTotal, &transTotalChk) != 0)
	{
		dagJDT->GetColLong (&transAbs, OJDT_JDT_NUM, 0);
		
		_STR_sprintf (tempStr, LONG_FORMAT, transAbs);
		Message (ERROR_MESSAGES_STR,OO_TRANSACTION_NOT_BALANCED, tempStr, OO_ERROR);
		return ((SBOErr)NULL);
	}

	//Set transaction total (one side)
	dagJDT->SetColMoney (&transTotal, OJDT_LOC_TOTAL, 0, DBM_NOT_ARRAY);
	dagJDT->SetColMoney (&fTransTotal, OJDT_FC_TOTAL, 0, DBM_NOT_ARRAY);
	dagJDT->SetColMoney (&sTransTotal, OJDT_SYS_TOTAL, 0, DBM_NOT_ARRAY);

	//Set contra account of each line in transaction
	if (!IsExDtCommand (ooDoAsUpgrade) && transType != DAR)
	{
		if (contraDebKey[0] && contraCredKey[0])
		{
			//Set to JDT1 contra accounts

			// For non VF_EnableCorrAct code, lastContraRec is always 0
			SetContraAccounts (dagJDT1, lastContraRec, numOfRecs, contraDebKey, contraCredKey, contraDebLines, contraCredLines);
		}

		if (VF_EnableCorrAct(bizEnv) && balanced == FALSE)
		{
			// NOTE: This is warning only
			SetErrorField(JDT1_CONTRA_ACT);
			SetErrorLine(1);	
			Message(OBJ_MGR_ERROR_MSG, GO_CONTRA_ACNT_MISSING, NULL, OO_WARNING);
		}
	}

	//@ABMerge ADD I035300 [ExciseInvoice]
	if(VF_ExciseInvoice(bizEnv))
	{
		SBOString genRegNumFlag;
		dagJDT->GetColStr(genRegNumFlag, OJDT_GEN_REG_NO, 0);
		genRegNumFlag.Trim ();
		if(genRegNumFlag == VAL_YES)
		{
			long matType;
			long regNo;
			long location;
			dagJDT->GetColLong(&matType, OJDT_MAT_TYPE, 0);
			dagJDT->GetColLong (&location, OJDT_LOCATION, 0);
			if(matType == 1 || matType == 3)
			{
				regNo = bizEnv.GetNextRegNum (location, RG23APart2, TRUE);
				dagJDT->SetColLong(regNo, OJDT_RG23A_PART2, 0);
				dagJDT->NullifyCol(OJDT_RG23C_PART2, 0);
			}
			else if(matType == 2)
			{
				regNo = bizEnv.GetNextRegNum (location, RG23CPart2, TRUE);
				dagJDT->SetColLong(regNo, OJDT_RG23C_PART2, 0);
				dagJDT->NullifyCol (OJDT_RG23A_PART2, 0);
			}
		}
		else if(genRegNumFlag[0] == VAL_NO[0])
		{
			dagJDT->NullifyCol(OJDT_MAT_TYPE, 0);
			dagJDT->NullifyCol(OJDT_RG23A_PART2, 0);
			dagJDT->NullifyCol(OJDT_RG23C_PART2, 0);
		}
	}
	//@ABMerge END I035300
	
//Do not update related PDAG, set zero pointer into the 'arrTable' entry
	bool isNeedToFree = SetDAG ( NULL, false, JDT, ao_Arr1 );
    bool isNeedToFree2 = SetDAG(NULL, false, JDT, ao_Arr2);
	if (VF_RmvZeroLineFromJE (GetEnv()) && !(GetEnv()).IsZeroLineAllowed ())
	{
		if (dagJDT1->GetRecordCount () == 0)
		{
			dagJDT->Clear ();
			return ooErr; 
		}

		if (dagJDT1->GetRecordCount () == 1)
		{
			dagJDT1->GetColMoney (&debAmount, JDT1_DEBIT, 0);
			dagJDT1->GetColMoney (&credAmount, JDT1_CREDIT, 0);
			dagJDT1->GetColMoney (&fDebAmount, JDT1_FC_DEBIT, 0);
			dagJDT1->GetColMoney (&fCredAmount, JDT1_FC_CREDIT, 0);
			dagJDT1->GetColMoney (&sDebAmount, JDT1_SYS_DEBIT, 0);
			dagJDT1->GetColMoney (&sCredAmount, JDT1_SYS_CREDIT, 0);
			
			MONEY	debBalanceDue, credBalanceDue, fDebBalanceDue, fCredBalanceDue, sDebBalanceDue, sCredBalanceDue;
			dagJDT1->GetColMoney (&debBalanceDue, JDT1_BALANCE_DUE_DEBIT, 0);
			dagJDT1->GetColMoney (&credBalanceDue, JDT1_BALANCE_DUE_CREDIT, 0);
			dagJDT1->GetColMoney (&fDebBalanceDue, JDT1_BALANCE_DUE_FC_DEB, 0);
			dagJDT1->GetColMoney (&fCredBalanceDue, JDT1_BALANCE_DUE_FC_CRED, 0);
			dagJDT1->GetColMoney (&sDebBalanceDue, JDT1_BALANCE_DUE_SC_DEB, 0);
			dagJDT1->GetColMoney (&sCredBalanceDue, JDT1_BALANCE_DUE_SC_CRED, 0);

			if (debAmount.IsZero() && credAmount.IsZero() &&
				fDebAmount.IsZero() && fCredAmount.IsZero() &&
				sDebAmount.IsZero() && sCredAmount.IsZero() &&
				debBalanceDue.IsZero() && credBalanceDue.IsZero() &&
				fDebBalanceDue.IsZero() && fCredBalanceDue.IsZero() &&
				sDebBalanceDue.IsZero() && sCredBalanceDue.IsZero())
			{
				dagJDT->Clear ();
				return ooErr;
			}
		}
	}

	// If Year Transfer Data_Source, then keep it that way.
	SBOString dataSource;
	dagJDT->GetColStr (dataSource, OJDT_DATA_SOURCE);
	dataSource.Trim ();
	if (dataSource.Compare (VAL_YEAR_TRANSFER_SOURCE) == 0)
	{
		SetDataSource (*VAL_YEAR_TRANSFER_SOURCE);
	}
	//Sequence
	if (VF_MultipleRegistrationNumber (GetEnv ()))
	{			
		CSequenceManager* seqManager = bizEnv.GetSequenceManager ();
		ooErr = seqManager->HandleSerial (*this);
		IF_ERROR_RETURN (ooErr);
	}

	//Supplementary Code OnCreate
	if(VF_SupplCode(GetEnv ()))
	{
		CSupplCodeManager* pManager = bizEnv.GetSupplCodeManager();
		Date PostDate;
		dagJDT->GetColStr(PostDate, OJDT_REF_DATE);
		ooErr = pManager->CodeChange(*this, PostDate);
		IF_ERROR_RETURN (ooErr);
		ooErr = pManager->CheckCode(*this);
		if(ooErr)
		{
			CMessagesManager::GetHandle()->Message(_54_APP_MSG_CORE_SUPPL_CODE_CODE_EXIST, EMPTY_STR, this);
			return ooErrNoMsg;
		}
	}
	else if(bizEnv.IsCurrentLocalSettings(CHINA_SETTINGS))	
	{
		if(!dagJDT->IsNullCol(OJDT_SUPPL_CODE, 0L))
		{
			dagJDT->NullifyCol(OJDT_SUPPL_CODE, 0L);
		}
	}


	if (VF_MultiBranch_EnabledInOADM (bizEnv))
	{
		// set selected branch to JDT object for the later validation (Incident 30293)
		if (!CBusinessPlaceObject::IsValidBPLId (GetBPLId ()) && dagJDT1->GetRealSize (dbmDataBuffer) > 0)
		{
			long bplId;
			dagJDT1->GetColLong (&bplId, JDT1_BPL_ID, 0);
			SetBPLId (bplId);
		}
	}
	//Write a header record
	
	ooErr = GORecordHistProc (*this, dagJDT);

	//Restore relative PDAG
	SetDAG ( dagJDT1, isNeedToFree, JDT, ao_Arr1 );
	SetDAG ( dagJDT2, isNeedToFree2, JDT, ao_Arr2 );

	if (ooErr != ooNoErr)
	{
		return (ooErr);
	}
// Record Cash Flow Assignment Transaction before updating 'arrTable' entry.
	if(VF_CashflowReport(bizEnv))
	{
		long	transType;
		dagJDT->GetColLong(&transType, OJDT_TRANS_TYPE);
		if (transType != RCT && transType != VPM)
		{
		SBOString	objCFTId(CFT);
		PDAG dagCFT = GetDAGNoOpen(objCFTId);
		if (dagCFT)
		{
				dagJDT->GetColLong (&transAbs, OJDT_JDT_NUM, 0);

			CCashFlowTransactionObject	*bo = static_cast<CCashFlowTransactionObject*>(CreateBusinessObject(CFT));

			bo->SetDataSource(GetDataSource());

			ooErr = bo->OCFTCreateByJDT (GetDAG(CFT), transAbs, dagJDT1);
			bo->Destroy ();
			if (ooErr != ooNoErr)
			{
				return (ooErr);
			}
		}
	}
	}


	ooErr = PutSignature (dagJDT1);
	if (ooErr)
	{
		return (ooErr);
	}

	if (VF_ExciseInvoice(bizEnv) && this->m_isVatJournalEntry)
	{
		long	wtrKey, vatJournalKey;
		dagJDT->GetColLong(&wtrKey, OJDT_CREATED_BY);
		dagJDT->GetColLong(&vatJournalKey, OJDT_JDT_NUM);
		if (wtrKey <= 0 || vatJournalKey <= 0)
		{
			return ooErrNoMsg;
		}

		dagJDT->SetColLong (0, OJDT_STORNO_TO_TRANS);

		ooErr = CWarehouseTransferObject::LinkVatJournalEntry2WTR (bizEnv, wtrKey, vatJournalKey);
		if (ooErr)
		{
			return ooErr;
		}
	}

	dagJDT->GetColLong (&createdBy, OJDT_CREATED_BY, 0);
	
	//Insert header's absolute entry into the lines
	dagJDT->GetColLong (&transAbs, OJDT_JDT_NUM, 0);

	for (rec=0; rec<numOfRecs; rec++)
	{
		dagJDT1->SetColLong (rec, JDT1_LINE_ID, rec);

		dagJDT1->SetColLong (transAbs, JDT1_TRANS_ABS, rec);
		dagJDT1->SetColLong (transType, JDT1_TRANS_TYPE, rec);

		dagJDT->GetColStr (tempStr, OJDT_BASE_REF, 0);
		dagJDT1->SetColStr (tempStr, JDT1_BASE_REF, rec);
		
		dagJDT->GetColStr (tempStr, OJDT_TRANS_CODE, 0);
		dagJDT1->SetColStr (tempStr, JDT1_TRANS_CODE, rec);

		dagJDT1->SetColLong (createdBy, JDT1_CREATED_BY, rec);
	}

    if(VF_JEWHT(bizEnv) && _DBM_DataAccessGate::IsValid(dagJDT2))
    {
        long numOfJDT2 = dagJDT2->GetRecordCount();
		
        for(long rec2 = 0; rec2 < numOfJDT2; rec2++)
        {
            dagJDT2->SetColLong(transAbs, INV5_ABS_ENTRY, rec2);
            dagJDT2->SetColLong(rec2, INV5_LINE_NUM, rec2);
        }
        UpdateWTInfo();   
    }

	if ((GetDataSource () == *VAL_OBSERVER_SOURCE) && (GetID().strtol() == JDT) &&  _DBM_DataAccessGate::IsValid(dagJDT2))
	{
		BusinessFlow	bizFlow = GetCurrentBusinessFlow();
		SBOString		wt;
		Boolean			useNegativeAmount;

		dagJDT->GetColStr(wt, OJDT_AUTO_WT);
		useNegativeAmount = bizEnv.GetUseNegativeAmount();

		if (bizFlow == bf_Cancel && wt == VAL_YES )
		{

			if (VF_JEWHT(bizEnv) && useNegativeAmount)
			{
				CMessagesManager::GetHandle()->Message (_1_APP_MSG_FIN_JDT_NOT_REVERSE_NEG_WT, EMPTY_STR, this);
				return ooInvalidObject;
			}
			long numOfJDT2 = dagJDT2->GetRecordCount();
			for(long idx = 0; idx < numOfJDT2; idx++)
			{
				dagJDT2->SetRecordFetchStatus(idx, false); 
			}
		}
	}


	Boolean fetched = dagJDT1->GetRecordFetchStatus (0);
	if (true == fetched)
	{
		dagJDT1->SetBackupSize (numOfRecs, dbmDropData);
		for (ii=0; ii < numOfRecs; ii++) 
		{
			dagJDT1->MarkRecAsNew (ii);		
		}
	}

	ooErr = CSystemBusinessObject::OnUpdate();
	if (ooErr)
	{
		return ooErr;
	}

	if(VF_TaxPayment(bizEnv))
	{
		for(rec = 0; rec < dagJDT1->GetRecordCount(); rec++)
		{
			ooErr = updateCenvatByJdt1Line(*this, dagJDT1, rec);
			if (ooErr && ooErr != dbmNoDataFound)
			{
				return ooErr;
			}
		}
	}

//Update Cards and accounts Tzovarim With Stored Proc -	 _T("TmSp_SetBalanceByJdt")
	_STR_strcpy (Sp_Name, _T("TmSp_SetBalanceByJdt"));
	dagJDT->GetColStr (tempStr, OJDT_JDT_NUM, 0);
	_STR_LRTrim (tempStr);
	Upd[0].colNum = dbmInteger;
	_STR_strcpy (Upd[0].updateVal, tempStr);
	DBD_SetDAGUpd (dagJDT, Upd, 1);
	
	RetVal=0;
	ooErr =  DBD_SpExec (dagJDT, Sp_Name, &RetVal);
	SBOString tmpstr(tempStr);
    LogBPAccountBalance(bpBalanceLogDataArray, tmpstr);
	bizEnv.InvalidateCache (bizEnv.ObjectToTable (CRD));
	bizEnv.InvalidateCache (bizEnv.ObjectToTable (ACT));
	
	if (RetVal)
	{
		return RetVal;
	}

	if (ooErr)
	{
		return ooErr;
	}

	long	canceledTrans;
	dagJDT->GetColLong (&canceledTrans, OJDT_STORNO_TO_TRANS, 0);
	if (canceledTrans > 0)
	{
		bool ordered = false;
		ooErr = CTransactionJournalObject::IsPaymentOrdered(bizEnv, canceledTrans, ordered);
		IF_ERROR_RETURN (ooErr);

		if (ordered)
		{
			bizEnv.SetErrorTable (dagJDT1->GetTableName ());
			return dbmDataWasChanged;
		}
	}

	/* When we cancel IRU journals we want to make reconciliation by ourselves and 
	   we don't want CTransactionJournalObject do it automatically */
	if ((canceledTrans > 0) && (m_reconcileBPLines))
	{
		ooErr = ReconcileCertainLines();
		if (ooErr)
		{
			return ooErr;
		}
		
		// auto-reconcile deferred tax account lines when cancel BP reconciliation
		if (!m_isInCancellingAcctRecon)
		{
			ooErr = ReconcileDeferredTaxAcctLines();
			IF_ERROR_RETURN (ooErr);
		}
	}

	//Save Tax information
	ooErr = CreateTax();
	if (ooErr)
	{
		return ooErr;
	}

	//	Update Cards deduction percentage in Deduct Terraces Company _T("TmSp_SetVendorDeductPercent")
	//	Error is not cheaked becouse it's not crutial, and there's no reason to rollback if it failes
	//	Start ====>
	if (VF_EnableDeductAtSrc (GetEnv ()))
	{
		long transID;
		dagJDT->GetColLong (&transID, OJDT_JDT_NUM, 0);
		ooErr = nsDeductHierarchy::UpdateDeductionPercent (bizEnv, transID);
		IF_ERROR_RETURN (ooErr);
		}
	//	<===== End

	if (transType == JDT)
	{
		ooErr = m_digitalSignature.CreateSignature (this);
		IF_ERROR_RETURN (ooErr);
	}

	ooErr = ValidateBPLNumberingSeries ();
	IF_ERROR_RETURN (ooErr);

	ooErr = IsBalancedByBPL ();
	IF_ERROR_RETURN (ooErr);

	//****************************************************************************
	if (bizEnv.IsComputeBudget () == FALSE || bizEnv.IsDuringUpgradeProcess () || transType == DAR)
	{
		return ooErr;
	}

	//Update Budget Acomulators And Look for An Alert with Sp  - _T("TmSp_SetBgtAccumulators_ByJdt")
	_STR_strcpy (Sp_Name	, _T("TmSp_SetBgtAccumulators_ByJdt"));

	res[0].colNum = JDT1_ACCT_NUM;
	res[1].colNum = JDT1_FC_CURRENCY;
	res[2].colNum =	JDT1_FC_CURRENCY;
	res[3].colNum = JDT1_DEBIT;
	res[4].colNum = JDT1_DEBIT;
 
	DBD_SetDAGRes (dagJDT1, res, 5);

	dagJDT->GetColStr (tempStr, OJDT_JDT_NUM, 0);
	_STR_LRTrim (tempStr);
	Upd[0].colNum = dbmInteger;
	_STR_strcpy (Upd[0].updateVal, tempStr);

	Upd[1].colNum = dbmAlphaNumeric;
	_STR_strcpy (Upd[1].updateVal, _T("Y"));

	Upd[2].colNum = dbmAlphaNumeric;
	_STR_strcpy (Upd[2].updateVal, bizEnv.GetCompanyPeriodCategory ());

	DBD_SetDAGUpd (dagJDT1 , Upd, 3);

	ooErr = DBD_SpToDAG (dagJDT1, &dagRES, Sp_Name);
	if (ooErr == dbmNoDataFound)
	{
		return ooNoErr;
	}
	if (ooErr)
	{
		return ooErr;
	}
		
 	blockLevel	= RetBlockLevel(bizEnv);
	typeBlockLevel = RettypeBlockLevel(bizEnv, GetID().strtol ());


	if (blockLevel>=JDT_WARNING_BLOCK && typeBlockLevel == JDT_TYPE_ACCOUNTING_BLOCK && 
		(OOIsSaleObject (transType) || OOIsPurchaseObject (transType)))
	{
		//dont given alert
		blockLevel = JDT_NOT_BGT_BLOCK;
	}

	if (blockLevel>=JDT_WARNING_BLOCK && typeBlockLevel != JDT_TYPE_ACCOUNTING_BLOCK && 
			transType == 30)
	{
		//dont give alert
		blockLevel = JDT_NOT_BGT_BLOCK;
	}

	_STR_strcpy (monSymbol, bizEnv.GetMainCurrency ());

	//Loop threw the records and see witch accounts has faild US !!!
	DAG_GetCount (dagRES, &recCount);
	for (ii = 0 ; ii < recCount ; ii++)
	{
		dagRES->GetColStr (acctCode, 0,ii);

		dagRES->GetColStr (tmpStr, 1,ii);
		DoAlert = tmpStr[0];
	
		dagRES->GetColStr (tmpStr, 2,ii);
		AlrType = tmpStr[0];
	
		dagRES->GetColMoney (&BgtMonthOver, 3, ii, DBM_NOT_ARRAY);
		dagRES->GetColMoney (&BgtYearOver, 4, ii, DBM_NOT_ARRAY);

		if (DoAlert == *VAL_YES)
		{
			transTotal.SetToZero();
			for (rec=0; rec<numOfRecs; rec++)
			{
				dagJDT1->GetColStr (acctKey, JDT1_ACCT_NUM, rec);
				if (_STR_stricmp (acctKey, acctCode) == 0)
				{
					dagJDT1->GetColMoney (&debAmount, JDT1_DEBIT, rec, DBM_NOT_ARRAY);
					dagJDT1->GetColMoney (&credAmount, JDT1_CREDIT, rec, DBM_NOT_ARRAY);
					MONEY_Add (&transTotal, &debAmount);
					MONEY_Sub (&transTotal, &credAmount);
				}
			}
			if (bizEnv.GetBudgetWarningFrequency() == VAL_MONTHLY[0])
			{
				if ((BgtMonthOver.IsPositive() && transTotal.IsPositive()) ||
					(BgtMonthOver.IsNegative() && transTotal.IsNegative()))
				{
					bgtDebitSize	= TRUE;
				}
				else
				{
					bgtDebitSize	= FALSE;
				}
			}
			else
			{
				if ((BgtYearOver.IsPositive() && transTotal.IsPositive()) ||
					(BgtYearOver.IsNegative() && transTotal.IsNegative()))
				{
					bgtDebitSize	= TRUE;
				}
				else
				{
					bgtDebitSize	= FALSE;
				}
			}
		}
		else
		{
		   bgtDebitSize	= FALSE;
		}

		 	//set the blocking of budget
		if (blockLevel > JDT_NOT_BGT_BLOCK  && bgtDebitSize)
		{
			budgetAllYes = IsExCommand( ooDontUpdateBudget) ;

			//the temp flag  used for ImportExportTrans
			fromImport = IsExCommand( ooImportData);

			//MONEY_Multiply (&BgtMonthOver, -1, &BgtMonthOver);

			MONEY_ToText (&BgtMonthOver, moneyMonthStr, RC_SUM, monSymbol, bizEnv);   
			
			MONEY_ToText (&BgtYearOver, moneyYearStr, RC_SUM, monSymbol, bizEnv);   	

			if (bizEnv.GetBudgetWarningFrequency() == VAL_MONTHLY[0])
			{
				GetBudgBlockErrorMessage(moneyMonthStr, moneyYearStr, acctCode, MONTH_ALERT_MESSAGE, msgStr1);
			}
			else
			{
				GetBudgBlockErrorMessage(moneyMonthStr, moneyYearStr, acctCode, YEAR_ALERT_MESSAGE, msgStr1);
			}
		
			switch (blockLevel)
			{
				case JDT_BGT_BLOCK:
					if (typeBlockLevel == JDT_TYPE_ACCOUNTING_BLOCK)
					{
						if (bizEnv.GetBudgetWarningFrequency() == VAL_MONTHLY[0])
						{
						GetBudgBlockErrorMessage (moneyMonthStr, moneyYearStr, acctCode, BLOCK_ONE_MESSAGE, msgStr1);
						_STR_strcat (msgStr1, _T(" , "));
						_STR_strcat (msgStr1,EMPTY_STR );
						Message (-1, -1, msgStr1, OO_ERROR);
						}
						else
						{
								CMessagesManager::GetHandle()->Message(
														_1_APP_MSG_FIN_BGT0_CHECK_YEAR_TOTAL_STR, 
														EMPTY_STR, 
														this,
														acctCode, 
														moneyYearStr);
						}
						
						return ooInvalidObject;
					}
				break;

				case JDT_WARNING_BLOCK:
				////the Message not to bee bring for ImportExportTrans
				if (fromImport|| GetDataSource () == *VAL_OBSERVER_SOURCE)
					{
						_STR_strcat (msgStr1, _T(" , "));
						_STR_strcat (msgStr1,EMPTY_STR );
						Message (-1, -1, msgStr1, OO_ERROR);
					}

					if (budgetAllYes == FALSE)
					{
#ifndef	MNHL_SERVER_MODE
						TCHAR	ContinueStr[50];

						_STR_GetStringResource (ContinueStr, BGT0_FORM_NUM, BGT0_CONTINUE_STR);
						retBtn = FORM_GEN_Message (msgStr1, ContinueStr, CANCEL_STR(*OOGetEnv(NULL)), YES_TO_ALL_STR(*OOGetEnv(NULL)), 2);
#else
						retBtn = 2;
#endif
						switch (retBtn)
						{
							case 1://formOKReturn
							case 3://formOKReturn
								budgetAllYes = (retBtn == 3 ? TRUE:FALSE);
								if (budgetAllYes)
								{
									SetExCommand ( ooDontUpdateBudget, fa_Set );
								}

								if (GetEnv ().GetPermission (PRM_ID_BUDGET_BLOCK) != OO_PRM_FULL)
								{
									DisplayError (fuNoPermission);
									return ooErrNoMsg;//fuNoPermission;
								}
								//return ooNoErr;
							break;

							case 2:
								return ooErrNoMsg;
							break;

						}
					}
				break;
			}//switch of levelBlock
		}//End Of For Looping
	}//blocking	

	if (transType == JDT && bizEnv.IsComputeBudget ())
	{
		Boolean					alertSent;
		CSystemAlertParams		systemAlertsParams;

		systemAlertsParams.m_fromUser = bizEnv.GetUserSignature ();
		systemAlertsParams.m_object = JDT;
		systemAlertsParams.m_params = this;
		systemAlertsParams.m_primaryKey.Format(_T("%d"), transAbs);
		systemAlertsParams.m_secondaryKey = systemAlertsParams.m_primaryKey;

		systemAlertsParams.m_alertID = ALR_BUDGET_ALERT;
		systemAlertsParams.m_flags = 0;
		ALRSendSystemAlert (&systemAlertsParams, &alertSent);
	}

	return ooErr;	
}
/*************************************************************/

long CTransactionJournalObject::RettypeBlockLevel(CBizEnv &bizEnv, long id)
{
        _TRACER("RettypeBlockLevel");
	switch (id)
	{
		case POR:
			if(bizEnv.IsApplyBudget (bl_Orders))
			{
				return JDT_TYPE_DOCS_BLOCK;
			}
		break;

		case PDN:
			if (bizEnv.IsApplyBudget (bl_Deliveries))
			{
				return JDT_TYPE_DOCS_BLOCK;
			}
		break;
		case PRQ:
			if (bizEnv.IsApplyBudget (bl_PurchaseRequest))
			{
				return JDT_TYPE_DOCS_BLOCK;
			}
		break;

		default:
			if (bizEnv.IsApplyBudget (bl_Accounting))
			{
				return JDT_TYPE_ACCOUNTING_BLOCK;
			}
		break;
	}
	return 	JDT_NOT_TYPE_DOCS_BLOCK;
}
HERE


s=<<HERE
#include "b.h"
a = 1;
#ifndef a_h
#define a_h
b = 1;
c=1;
#endif
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
s =<<HERE
#pragma once fdffd \
dfasfd\
fdas
#include "b.h"
HERE





s=<<HERE
#ifndef ADD
a=32;
#else
a=3;
#endif
#if 1
a=1;
#else
a=2;
#endif
HERE


s=<<HERE

#define		JDT_WARNING_BLOCK1	3
#ifdef JDT_WARNING_BLOCK1
a = 1;
#else
a = 2;
#endif

HERE
s=<<HERE
#if 0
a=3;
#else
a =1;
#endif
HERE
s =<<HERE
#define LOG(m, l) log(m, l);\
m++;\
l--
#define A 10
a=A;
LOG("FAFAF", 10);
LOG("B", 3);
LOG(aaa, 3);
HERE


s=<<HERE
#if 1
a=3;
#else
a =1;
#endif
HERE





s=<<HERE
#ifndef B
#define B 31
#else
#define A 33
#endif
HERE
s=<<HERE
#ifndef XML_RESOURCE_TOOLS_TABLE_JDT1_H
#define XML_RESOURCE_TOOLS_TABLE_JDT1_H
#define	JDT1_KEYNUM_JDT1CHECKA_LEN							31

#endif

HERE
s=<<HERE
#include "JDT1.h"
HERE
s=<<HERE
#include "qa.h"
HERE

s=<<HERE
#define		FILE_TAB				_T("\\t\\n")
FILE_TAB
HERE
s=<<HERE
printf('-----------1');
#if 1
a=3;
#else
a =1;
#endif
printf('-----------2');
#if 0
a=33;
#else
a =11;
#endif
HERE

s=<<HERE
try{
    _LOGMSG(logDebugComponent, logNoteSeverity, 
	    _T("In CTransactionJournalObject::BeforeDeleteArchivedObject - starting JEComp.execute()"))
	    CJECompression	JEComp(GetEnv(), &JEPref);
		
}	
    catch (nsDataArchive::CDataArchiveException& e){
    
}
HERE




s=<<HERE
#ifdef QC_SHELL_ON
		qc = TRUE;
#else
		qc = FALSE;
#endif


HERE
s=<<HERE
#pragma once
#ifdef POJDT_H
#endif
HERE
s=<<HERE

		JDT1_CREDIT										=	4,
#define	JDT1_CREDIT_LEN										20
#define	JDT1_CREDIT_ALIAS									L"Credit"

		// System Credit Amount
		JDT1_SYS_CREDIT									=	5,

    	docInfoQry.Select ().Max ().Col (tableObjRow, JDT1_CREDIT).Sub ().Max ().Col (tableObjRow, JDT1_DEBIT).As (JDT1_CREDIT_ALIAS);

HERE
s=<<HERE
// included from file c_macros.c
#define TRUE true
#define FALSE false
#define NULL nil
#define _LOGMSG(a,b,c)

HERE
s1=<<HERE
#if 0
#define B 31
#else
#define A 33
#endif
A
HERE

s3=<<HERE
#define _DEBUG 
#ifdef _DEBUG
b=1;
#ifdef _WINDOWS
b=2;
#else
#endif
#endif
a=1;
HERE
if !testall
   
    s = s3
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

    p "==>#{s}"
    scanner = CScanner.new(s, false)
    error = MyError.new("whaterver", scanner)
    parser = Preprocessor.new(scanner, error)
    # parser.Get
    p "preprocess content:#{scanner.buffer}"
    content = parser.Preprocess(false)
    p "====== result ======"
    p content
    parser.show_macros
    error.PrintListing
end
 test
