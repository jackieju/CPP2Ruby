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
end

class AbsScanner 
    attr_accessor :nextSym, :currSym
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

    def Reset()
        @currLine = 1
        @lineStart = 0
        @buffPos = -1
        @currCol = 0
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
        p "sym==== "
         len = sym.len
         pos = sym.pos

        while (true) 
          ret += CurrentCh(pos)
          pos +=1
          len -=1
          if len <=0
              break
          end
        end
        return ret
    end
    def GetName(sym)
        ret = ""
        p "sym len #{sym.len} "
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
    def GetLine( pos,  line,  max)
        raise("not implemented")
        
    end
    def cur_line()
        @buffer.lines[@currLine-1]
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
        return @buffer[pos]
    end
    def NextCh()
        p "NextCh() @ch=#{@ch}"
        @buffPos+=1
        p "@buffPos=#{@buffPos}"
        @ch = CurrentCh(@buffPos)
        return if @ch == nil
        if (@ignoreCase) 
            @ch = Upcase(@ch)
        end
         p "@ch=#{@ch}"
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

