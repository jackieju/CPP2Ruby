class AbsToken 

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
        @buffer = nil
    end
    
    def initialize(s, ing)
        @buffer = s
        @ignoreCase = ing
    end 

    # def CRScanner(ignoreCase)
    #     @buffer = NULL
    #     @ignoreCase = ignoreCase
    # end
    # 
    # 
    # def initialize( SrcFile, ignoreCase)
    #     @buffer = NULL
    #     ReadFile(SrcFile)
    #     Reset()
    #     IgnoreCase = ignoreCase
    # end


    # ~CRScanner()

    def Reset()
        @currLine = 1
        @lineStart = 0
        @buffPos = -1
        @currCol = 0
        @comEols = 0
        @nextSym = AbsToken.new.init()
        NextCh()
    end


    def EqualStr(s)
        raise("not implemented")
        
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
    def GetName(sym)
        ret = ""
         len = sym.Len
         pos = sym.Pos

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
    def GetLine( pos,  line,  max)
        raise("not implemented")
        
    end
    def NextSym
        @nextSym
    end
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
        return @buffer[Pos]
    end
    def NextCh()
        @buffPos+=1
        @ch = CurrentCh(@buffPos)
        if (@ignoreCase) 
            @ch = Upcase(@ch)
        end
        if (@ch == TAB_CHAR) 
            @currCol += TAB_SIZE - (@currCol % TAB_SIZE)
        elsif (@ch == LF_CHAR) 
          @currLine+=1
          @currCol = 0
          @lineStart = @buffPos + 1
        end
        @currCol+=1
    end
end

