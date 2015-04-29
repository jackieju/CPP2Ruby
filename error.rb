load "errmsg.rb"

MINERRORNO = 1000

class ErrDesc 
  public
    def initialize( n,  l = 0,  c = 0)
        @nr = n
        @line = l
        @col = c
        @next = nil
    end

    def SetNext(n)
        @next = n
    end
    def GetNext()
      return @next
    end
    # int nr, line, col
  private
    # ErrDesc *next
end
class AbsError 
        attr_accessor :minUserError, :errorDist, :errors, :error_list  
    
    
    
    
    
end
class CRError < AbsError 
  public
    def initialize(name, s, minUserNo = MINERRORNO, minErr = 2)
         if (!s) 
           p "CRError::CRError: No Scanner specified\n" 
           exit(1)
         end
         @scanner = s
         # strcpy(FileName, name)
         @filename = name
         # lst = stderr
         @errors = 0
         @firstErr = @lastErr = nil
         @errorDist = minErr
         @minErrorDist = minErr
         @minUserError = minUserNo
         
         @error_list = []
    end
    
    def ReportError( nr)

       if (nr <= MinUserError) 
           nr = MinUserError
       end
        StoreErr(nr, @scanner.CurrSym)
    end
    def GetErrorMsg( n) 
         return ""
    end
    def GetUserErrorMsg( n)  return ""
    end
    def SetOutput(file) 
     lst = file
    end

    def PrintListing(scanner=nil)
        p "===== parsing done ===="
        @error_list.each{|e|
            p "error #{e[:errno]}, #{ERRMSG[e[:errno]]},  line #{e[:sym].line+1} col #{e[:sym].col} sym #{SYMS[e[:sym].sym]} val #{@scanner.GetSymString(e[:sym])}"    
            pos = e[:sym].pos
            pos1 = pos -10
            pos2 = pos +10
            pos1 = 0 if pos1 < 0
            pos2 = @scanner.buffer.size-1 if pos2 > @scanner.buffer.size-1
            p "....#{@scanner.buffer[pos1..pos2]}......"
        }
        p "Total #{@error_list.size} errors"
    end
    def SummarizeErrors()
    end
    # int MinUserError
    # int ErrorDist
    # int Errors

    def Store( nr,  line,  col,  pos)
    end
    def StoreErr( nr,  token)
        @error_list.push({
            :errno=>nr,
            :sym=>token
        })
    end
    def StoreWarn( nr,  token)
    end
  protected
    # AbsScanner *Scanner
    # FILE *lst
    # char FileName[256]
    # int MinErrorDist
    # void PrintErrMsg(int nr)
    # void PrintErr(int nr, int col)
    # ErrDesc *FirstErr, *LastErr
end
MAXERROR = 1000000
class MyError < CRError 
public
    def initialize(name, s) 
        super(name, s, MAXERROR) 
    end 
    def GetUserErrorMsg( n)
    end
    def GetErrorMsg( n)
	    if (n <= MAXERROR)
	         return ErrorMsg[n]
	    else
	          return GetUserErrorMsg(n)
        end
	end
	
	def Init(name,  minUserNo = MINERRORNO,  minErr = 2)
		@fileName=name
        # lst = stderr
		@errors = 0
		@firstErr = @lastErr = nil
		@errorDist = MinErr
		@minErrorDist = MinErr
		@minUserError = MinUserNo
	end
	
private
    @@ErrorMsg = ""
end