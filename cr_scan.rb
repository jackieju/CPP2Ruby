class AbsToken 
    attr_accessor :len, :pos, :col, :line, :sym
  public
    # virtual ~AbsToken() { }
    # int  Sym;              // Token Number
    # int  Line, Col;        // line and column of current Token
    # int  Len;              // length of current Token
    # long Pos;              // file position of current Token
   
   def GetSym()
       return @sym
   end
   
   def SetSym( sym)
       return @sym = sym
   end
   
   def GetPos()
       return @pos
   end
   
   def init( sym = 0,  line = 0,  col = 0,  pos = 0,  len = 0)
       @sym = sym
       @line = line
       @col = col
       @pos = pos
       @len = len
   end
 
  def clone
      ret = AbsToken.new
      ret.init(sym, line, col, pos, len)
      return ret
  end
end

class AbsScanner 
    attr_accessor :nextSym, :currSym, :buffer, :buffPos, :ch
    def initialize
        p "init absscanner"
        @nextSym = AbsToken.new
        @nextSym.init
        p "nextSym=#{nextSym}"
        @currSym = AbsToken.new
        @currSym.init
    end
=begin

  public:
    # virtual ~AbsScanner() {}

    AbsToken CurrSym;      // current (most recently parsed) token
    AbsToken @nextSym;      // next (look ahead) token

    virtual int Get() = 0


    virtual void Reset() = 0


    virtual unsigned char CurrentCh(long pos) = 0


    virtual void GetString(AbsToken *Sym, char *Buffer, int Max) = 0


    virtual void GetString(long Pos, char *Buffer, int Max) = 0


    virtual void GetName(AbsToken *Sym, char *Buffer, int Max) = 0



    virtual long GetLine(long Pos, char *Line, int Max) = 0


=end
end

class AbsError 
=begin

  public:
    # virtual ~AbsError() { }

    # virtual void Store(int nr, int line, int col, long pos) = 0
    # 
    # virtual void StoreErr(int nr, AbsToken &Token) = 0
    # 
    # virtual void StoreWarn(int nr, AbsToken &Token) = 0
    # 
    # virtual void SummarizeErrors() = 0
=end
end
LF_CHAR = 10
CR_CHAR = 13
EOF_CHAR = 0
TAB_CHAR = 9
TAB_SIZE = 8
            
def Upcase(c)
   return (c >= 'a' && c <= 'z') ? c-32 : c; 
end



# from CR_SCAN.hpp
class CRScanner < AbsScanner 

  public
    def initialize()
        super
        @buffer = nil
         Reset()
    end
    
    def initialize(s, ing)
        p "init CRScanner"
        
        super()
        @buffer = s
        @ignoreCase = ing
        p "next sym = #{nextSym}"
        
        Reset()
        p "next sym = #{nextSym}"
        p "init CRScanner OK"
    end 

    # def CRScanner(ignoreCase)
    #     @buffer = NULL
    #     @ignoreCase = ignoreCase
    # end
    # 
    # 
    # def initialize( srcFile, ignoreCase)
    #     @buffer = nil
    #     ReadFile(srcFile)
    #     Reset()
    #     @ignoreCase = ignoreCase
    # end

    # ~CRScanner()

    def Reset(buffPos=nil, currLine=nil, lineStart=nil, currCol=nil)
        if !currLine
            @currLine = 1 
        else
            @currLine = currLine
        end
        if !lineStart
            @lineStart = 0 
        else
            @lineStart = lineStart
        end
        if !buffPos
            @buffPos = -1 
        else
             @buffPos = buffPos
        end
        if !currCol
            @currCol = 0 
        else
            @currCol = currCol
        end
        @comEols = 0
        @nextSym = AbsToken.new
        @nextSym.init()
        NextCh()
    end


    def EqualStr(s)
        
        # p "EqualStr: #{s}, #{@buffer[nextSym.pos..@buffer.size-1]}"
        # raise ("EqualStr")
        # long pos; char c;
         if (nextSym.len != s.size) 
             return false
         end
         pos = nextSym.pos
         s.each_char{|cc|
           c = CurrentCh(pos)
           pos+=1
           # if (IgnoreCase) c = Upcase(c);
           if (c != cc)
               return false
           end
         }
         return true    
    end


    def SetIgnoreCase() 
        @ignoreCase = 1
     end

    def Get()
        raise("not implemented")
        
    end
    def GetString(sym, buffer,  max)
        raise("not implemented")
        
    end
    def GetString( pos, buffer,  max)
        raise("not implemented")
        
    end
    def GetSymValue(sym)
        ret = ""
        # p "sym #{sym.sym} pos #{sym.pos} "
         len = sym.len
         pos = sym.pos

        while (true) 
            _cch =  CurrentCh(pos) 
         break if _cch == nil
          ret += _cch
          pos +=1
          len -=1
          if len <=0
              break
          end
        end
        return ret
    end
    def GetSymString(sym)
        ret = ""
        # p "sym len #{sym.len} "
         len = sym.len
         pos = sym.pos

        while (len > 0) 
            c = CurrentCh(pos)
            break if c == nil
          ret += c
          pos +=1
          len -=1
          # if len <=0
          #             break
          #         end
        end
        return ret
    end
    # def GetName(sym)
    #     ret = ""
    #     p "sym len #{sym.len} "
    #      len = sym.len
    #      pos = sym.pos
    # 
    #     while (len > 0) 
    #         c = CurrentCh(pos)
    #         break if c == nil
    #       ret += c
    #       pos +=1
    #       len -=1
    #       # if len <=0
    #       #             break
    #       #         end
    #     end
    #     return ret
    # end
    def GetLine( pos,  line,  max)
        raise("not implemented")
        
    end
    def cur_line()
        @buffer.lines[@currLine-1]
    end
    def _get()
        @buffPos+=1
        @ch = CurrentCh(@buffPos)
        return @ch
    end
    # include_current_char: returned string includes current char
    def NextLine(include_current_char = false, from = nil)
        p "from:#{from}, ch #{@buffer[from]}" if from 
        ret = ""
        if include_current_char
            if from 
                ret_start = from
                # ret = "#{@buffer[from]}"
                @buffPos = from
            else
                ret_start = @buffPos
                # ret = "#{@buffer[@buffPos]}"
            end
        else
            if from 
                ret_start = from +1
                @buffPos = from +1
            else
                ret_start = @buffPos+1
            end
        end
        @ch = @buffer[buffPos]
        p "nextline ret_start:#{ret_start}, ch #{@ch}, @buffPos:#{@buffPos}, pos #{@buffPos}", 20
        if cch() == "\n"
        else
            begin # while (@ch != "\n")
                # p "NextLine() @ch=#{@ch}"
                # @buffPos+=1
                #            # p "@buffPos=#{@buffPos}"
                #            @ch = CurrentCh(@buffPos)
                # _get()
                # return @buffer[ret_start..@buffer.size-1] if @ch == nil || @ch.to_byte == EOF_CHAR
                return ret if @ch == nil || @ch.to_byte == EOF_CHAR
                if (@ch == "\\")
                   while (_get() =~ /\s/)
                   end
                   if @ch == "\n"
                       _get()
                   end
                end
                p "@ch011=#{@ch.to_byte}, #{@buffer[ret_start..@buffPos]}, pos #{@buffPos}, ret=#{ret}"
                if (@ch == '"')
                    ret += "\""
                    p "@ch222:#{@ch}"
                    _get()
                    while @ch != '"'
                        p "@ch333:#{@ch.to_byte}, pos #{@buffPos}"
                     
                        if @ch == "\\"
                            ret += "\\"
                            _get()
                              p "@ch = #{@ch.to_byte}, #{@buffer[ret_start..@buffPos]}"
                        elsif (@ch >= ' ' && @ch <= '!' ||
                      	    @ch >= '#' && @ch.to_byte <= 255)
                            ret += @ch
                            _get()
                        elsif @ch.to_byte == 13 || @ch.to_byte == 10 || @ch == nil || @ch.to_byte == EOF_CHAR
                            break
                        else
                            ret += @ch
                            _get()
                        end
                        p "ret:#{ret}"
                    end
                    
                    ret += '"'
                elsif @ch == '/'
                    _pos = @buffPos
                    line = @currLine
                    Comment()
                    ret += @ch
                    p "pos=#{@buffPos}, @ch1111 = #{@ch.to_byte}, #{@buffer[ret_start..@buffPos]}"
                    
                    if @currLine > line # if multi line comments
                        break
                        # return @buffer[ret_start.._pos]
                    end
                else
                    ret += @ch
                end
                _get()
                # p "@ch2 = #{@ch.to_byte}, #{@buffer[ret_start..@buffPos]}, ret=#{ret}"
            end while (@ch != "\n")
        end
        p "nextline2:#{ret}"
        
        @ch = '\0' if @ch == nil
            
        p "@ch3 = #{@ch.to_byte}, #{@buffer[ret_start..@buffPos]}"
     
        # bufferpos point to "\n"
     
        ret_end = @buffPos-1 #return value not include \n
        @currLine += 1
        @currCol = 1
        @lineStart = @buffPos + 1
        
        _get()
        @ch = '\0' if @ch == nil
        p "@ch4 = #{@ch.to_byte}, #{@buffer[ret_start..@buffPos]}"
        
        return "" if ret_end < ret_start
        p "nextline:#{@buffer[ret_start..ret_end]}", 30
        p "nextline1:#{ret}"
        # return @buffer[ret_start..ret_end]
        return ret
    end
    
    # return skipped content
    # include_current_char: returned string includes current char
    def skip_curline(include_current_char = false, from=nil)
        ret = NextLine(include_current_char, from)
        # p "after skip current line, pos #{@buffPos}, ch = #{@buffer[@buffPos].to_byte}"
        # pp "after skip current line:@buffPos=#{@buffPos}, buffer=#{@buffer}, ret=#{ret}", 20
        return ret
    end
    def cch()
        CurrentCh(@buffPos)
    end
    # def NextSym
    #     @nextSym
    # end
  private
    # unsigned char *Buffer
  protected
    # int   @comEols;         // number of EOLs in a comment
    #    long  @buffPos;         // current position in buf
    #    int   CurrCol;         // current Column Number
    #    long  InputLen;        // source file size
    #    int   @currLine;        // current input line (may be higher than line)
    #    long  @lineStart;       // start position of current line
    #    unsigned char  Ch
    #    int   IgnoreCase


    def ReadFile( srcFile)
        raise("not implemented")
    end
   
    def CurrentCh( pos)
        # p "buffer:#{@buffer}"
        # p "pos:#{pos}"
        return @buffer[pos]
    end

    def NextCh()
        # p "NextCh() @ch=#{@ch}"
        @buffPos+=1
        # p "@buffPos=#{@buffPos}"
        @ch = CurrentCh(@buffPos)
        return if @ch == nil
        if (@ignoreCase) 
            @ch = Upcase(@ch)
        end
         # p "@ch=#{@ch}"
        if (@ch == TAB_CHAR) 
            @currCol += TAB_SIZE - (@currCol % TAB_SIZE)
        elsif (@ch.to_byte == LF_CHAR) 
          @currLine+=1
          @currCol = 0
          @lineStart = @buffPos + 1
        end
        @currCol+=1
    end
    


end

