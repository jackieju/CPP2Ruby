require "cr_scan.rb"
COCO_WCHAR_MAX =65535
MIN_BUFFER_LENGTH =1024
MAX_BUFFER_LENGTH =(64*MIN_BUFFER_LENGTH)
HEAP_BLOCK_SIZE =(64*1024)
# COCO_CPP_NAMESPACE_SEPARATOR =L':'
=begin
# string handling, wide character
wchar_t* coco_string_create(const wchar_t *value)
wchar_t* coco_string_create(const wchar_t *value, int startIndex, int length)
wchar_t* coco_string_create_upper(const wchar_t* data)
wchar_t* coco_string_create_lower(const wchar_t* data)
wchar_t* coco_string_create_lower(const wchar_t* data, int startIndex, int dataLen)
wchar_t* coco_string_create_append(const wchar_t* data1, const wchar_t* data2)
wchar_t* coco_string_create_append(const wchar_t* data, const wchar_t value)
void  coco_string_delete(wchar_t* &data)
int   coco_string_length(const wchar_t* data)
bool  coco_string_endswith(const wchar_t* data, const wchar_t *value)
int   coco_string_indexof(const wchar_t* data, const wchar_t value)
int   coco_string_lastindexof(const wchar_t* data, const wchar_t value)
void  coco_string_merge(wchar_t* &data, const wchar_t* value)
bool  coco_string_equal(const wchar_t* data1, const wchar_t* data2)
int   coco_string_compareto(const wchar_t* data1, const wchar_t* data2)
int   coco_string_hash(const wchar_t* data)

# string handling, ascii character
wchar_t* coco_string_create(const char *value)
char* coco_string_create_char(const wchar_t *value)
void  coco_string_delete(char* &data)
=end



class Token  

public
	# int kind;     # token kind
	#  int pos;      # token position in the source text (starting at 0)
	#  int col;      # token column (starting at 1)
	#  int line;     # token line (starting at 1)
	#  wchar_t* val; # token value
	#  Token *next;  # ML 2005-03-11 Peek tokens are kept in linked list
	
	def initialize()
	    @kind = 0
    	@pos  = 0
    	@col  = 0
    	@line = 0
    	@val  = nil
    	@next = nil
    end
    # ~Token()
end

=begin
class Buffer 
# This Buffer supports the following cases:
# 1) seekable stream (file)
#    a) whole stream in buffer
#    b) part of stream in buffer
# 2) non seekable stream (network, console)
private
	# unsigned char *buf; # input buffer
	#  int bufCapacity;    # capacity of buf
	#  int bufStart;       # position of first byte in buffer relative to input stream
	#  int bufLen;         # length of buffer
	#  int fileLen;        # length of input stream (may change if the stream is no file)
	#  int bufPos;         # current position in buffer
	#  FILE* stream;       # input stream (seekable)
	#  bool isUserStream;  # was the stream opened by the user?
	
	def ReadNextStreamChunk()
	    
    end
	def CanSeek()    # true if stream can be seeked otherwise false
	end
public
    # static const int EoF = COCO_WCHAR_MAX + 1

	def initialize(s, isUserStream)
    end
	def initialize(buf, len)
    end
	def initialize(b)
    end
    # virtual ~Buffer()
	
	def Close()
    end
	def Read()
    end
	def Peek()
    end
	def GetString( beg,  end1)
	end
	def GetPos()
    end
	def SetPos(value)
    end
end

class UTF8Buffer : public Buffer {
public:
	UTF8Buffer(Buffer *b) : Buffer(b) {}
	virtual int Read()
}
=end
=begin
#-----------------------------------------------------------------------------------
# StartStates  -- maps characters to start states of tokens
#-----------------------------------------------------------------------------------
class StartStates {
private:
	class Elem {
	public:
		int key, val
		Elem *next
		Elem(int key, int val) { this->key = key; this->val = val; next = NULL; }
	}

	Elem **tab

public:
	StartStates() { tab = new Elem*[128]; memset(tab, 0, 128 * sizeof(Elem*)); }
	virtual ~StartStates() {
		for (int i = 0; i < 128; ++i) {
			Elem *e = tab[i]
			while (e != NULL) {
				Elem *next = e->next
				delete e
				e = next
			}
		}
		delete [] tab
	}

	void set(int key, int val) {
		Elem *e = new Elem(key, val)
		int k = ((unsigned int) key) % 128
		e->next = tab[k]; tab[k] = e
	}

	int state(int key) {
		Elem *e = tab[((unsigned int) key) % 128]
		while (e != NULL && e->key != key) e = e->next
		return e == NULL ? 0 : e->val
	}
}

#-------------------------------------------------------------------------------------------
# KeywordMap  -- maps strings to integers (identifiers to keyword kinds)
#-------------------------------------------------------------------------------------------
class KeywordMap {
private:
	class Elem {
	public:
		wchar_t *key
		int val
		Elem *next
		Elem(const wchar_t *key, int val) { this->key = coco_string_create(key); this->val = val; next = NULL; }
		virtual ~Elem() { coco_string_delete(key); }
	}

	Elem **tab

public:
	KeywordMap() { tab = new Elem*[128]; memset(tab, 0, 128 * sizeof(Elem*)); }
	virtual ~KeywordMap() {
		for (int i = 0; i < 128; ++i) {
			Elem *e = tab[i]
			while (e != NULL) {
				Elem *next = e->next
				delete e
				e = next
			}
		}
		delete [] tab
	}

	void set(const wchar_t *key, int val) {
		Elem *e = new Elem(key, val)
		int k = coco_string_hash(key) % 128
		e->next = tab[k]; tab[k] = e
	}

	int get(const wchar_t *key, int defaultVal) {
		Elem *e = tab[coco_string_hash(key) % 128]
		while (e != NULL && !coco_string_equal(e->key, key)) e = e->next
		return e == NULL ? defaultVal : e->val
	}
}
=end
=begin
class Scanner {
private
    # void *firstHeap
    # void *heap
    # void *heapTop
    # void **heapEnd
    # 
    # unsigned char EOL
    # int eofSym
    # int noSym
    # int maxT
    # int charSetSize
    # StartStates start
    # KeywordMap keywords

    # Token *t;         # current token
    # wchar_t *tval;    # text of current token
    # int tvalLength;   # length of text of current token
    # int tlen;         # length of current token
    # 
    # Token *tokens;    # list of tokens already peeked (first token is a dummy)
    # Token *pt;        # current peek token
    # 
    # int ch;           # current input character
    # 
    # int pos;          # byte position of current character
    # int line;         # line number of current character
    # int col;          # column number of current character
    # int oldEols;      # EOLs that appeared in a comment

	def CreateHeapBlock()
    end
	def CreateToken()
    end
	def AppendVal(t)
    end
	def SetScannerBehindT()
    end
	def Init()
    end
	def NextCh()
    end
	def AddCh()
    end
	def Comment0()
    end
	def Comment1()
    end

	def NextToken()
    end

public:
	buffer;   # scanner buffer
	
	def initialize(const unsigned char* buf, int len)
    end
	def initialize(const wchar_t* fileName)
    end
	def Scanner(FILE* s)
    end
    # ~Scanner()
	def Scan()
    end
	def Peek()
    end
	def ResetPeek()
    end

end # end Scanner
=end

Scan_Ch        Ch





class CScanner <  CRScanner
   def Scan_NextCh    
       @nextCh
   def Scan_ComEols   
       @comEols
   end
   def Scan_CurrLine 
        @currLine
    end

   def Scan_CurrCol  
        @currCol
        end
        
   def Scan_LineStart 
       @lineStart
       end
       
   def Scan_BuffPos   
       @buffPos
       end
       
   def Scan_NextLen   
       NextSym.Len
   end
   
   
  public
    def initialize( srcFile,  ignoreCase) 
        super(srcFile, ignoreCase)
    end
    def GetName()
		return super(@CurrSym, MAX_IDENTIFIER_LENGTH-1)
	end
  protected
    @@STATE0 = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                      0,0,0,55,24,33,71,64,51,26,45,46,47,62,42,63,67,38,35,2,2,2,2,2,2,2,2,2,48,37,
                      30,41,57,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
                      1,43,0,44,53,1,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
                      1,1,1,39,49,40,82,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    # static int STATE0[]
    def CheckLiteral( id)
        char c
          c =  CurrentCh(NextSym.Pos)
          # if (IgnoreCase) c = Upcase(c)
          case (c) 
          	when 'b':
          		if (EqualStr("break")) 
          		    return C_breakSym
      		    end
          		break
          	when 'c':
          		if (EqualStr("class"))
          		     return C_classSym
      		     end
          		return C_charSym if (EqualStr("char")) 
          		return C_caseSym if (EqualStr("case")) 
          		return C_continueSym if (EqualStr("continue"))
          		break
          	when 'd':
          		return C_doubleSym if (EqualStr("double")) 
          		return C_defaultSym if (EqualStr("default")) 
          		return C_doSym if (EqualStr("do")) 
          		break
          	when 'e':
          		return C_elseSym if (EqualStr("else")) 
          		break
          	when 'f':
          		return C_functionSym if (EqualStr("function"))  
          		return C_floatSym if (EqualStr("float"))  
          		return C_forSym if (EqualStr("for")) 
          		break
          	when 'i':
          		return C_inheritSym if (EqualStr("inherit")) 
          		return C_intSym if (EqualStr("int")) 
          		return C_ifSym if (EqualStr("if")) 
          		break
          	when 'l':
          		return C_loadSym if (EqualStr("load")) 
          		return C_longSym if (EqualStr("long")) 
          		break
          	when 'm':
          		return C_mySym if (EqualStr("my")) 
          		return C_mixedSym if (EqualStr("mixed")) 
          		break
          	when 'n':
          		return C_newSym if (EqualStr("new")) 
          		break
          	when 'p':
          		return C_packageSym if (EqualStr("package")) 
          		break
          	when 'r':
          		return C_returnSym if (EqualStr("return")) 
          		break
          	when 's':
          		return C_staticSym if (EqualStr("static")) 
          		return C_shortSym if (EqualStr("short")) 
          		return C_stringSym if (EqualStr("string")) 
          		return C_switchSym if (EqualStr("switch")) 
          		break
          	when 'u':
          		return C_useSym if (EqualStr("use")) 
          		return C_unsignedSym if (EqualStr("unsigned")) 
          		break
          	when 'v':
          		return C_varSym if (EqualStr("var")) 
          		return C_voidSym if (EqualStr("void")) 
          		break
          	when 'w':
          		return C_whileSym if (EqualStr("while")) 
          		break

          end
          return id
    end
    def LeftContext(s)
        rais("not implemented")
=begin
        int Level, StartLine, OldCol
          long OldLineStart

          Level = 1; StartLine = CurrLine
          OldLineStart = LineStart; OldCol = CurrCol
          if (Scan_Ch == '/') { 
          	Scan_NextCh()
          	if (Scan_Ch == '*') { 
          		Scan_NextCh()
          		while (1) {
          			if (Scan_Ch== '*') { 
          				Scan_NextCh()
          				if (Scan_Ch == '/') { 
          					Level--; Scan_NextCh(); Scan_ComEols = Scan_CurrLine - StartLine
          					if(Level == 0) return 1
          				}  
          			} else 
          			if (Scan_Ch == EOF_CHAR) return 0
          			else Scan_NextCh()
          		} 
          	} else { 
          		if (Scan_Ch == LF_CHAR) { Scan_CurrLine--; Scan_LineStart = OldLineStart; }
          		Scan_BuffPos -= 2; Scan_CurrCol = OldCol - 1; Scan_NextCh()
          	} 
          } 
          if (Scan_Ch == '/') { 
          	Scan_NextCh()
          	if (Scan_Ch == '/') { 
          		Scan_NextCh()
          		while (1) {
          			if (Scan_Ch== 10) { 
          				Level--; Scan_NextCh(); Scan_ComEols = Scan_CurrLine - StartLine
          				if(Level == 0) return 1
          			} else 
          			if (Scan_Ch == EOF_CHAR) return 0
          			else Scan_NextCh()
          		} 
          	} else { 
          		if (Scan_Ch == LF_CHAR) { Scan_CurrLine--; Scan_LineStart = OldLineStart; }
          		Scan_BuffPos -= 2; Scan_CurrCol = OldCol - 1; Scan_NextCh()
          	} 
          } 

          return 0
=end       
    end
    def Comment()
        # int Level, StartLine, OldCol
        #       long OldLineStart
    
          level = 1
           startLine = CurrLine
          oldLineStart = LineStart
           oldCol = CurrCol
          if (Scan_Ch == '/') 
          	Scan_NextCh()
          	if (Scan_Ch == '*')  
          		Scan_NextCh()
          		while (1) 
          			if (Scan_Ch== '*') 
          				Scan_NextCh()
          				if (Scan_Ch == '/') 
          					Level--; Scan_NextCh(); Scan_ComEols = Scan_CurrLine - StartLine
          					if(Level == 0) 
          					    return 1
      					    end
          				end  
          			elsif (Scan_Ch == EOF_CHAR) 
          			    return 0
          			else
          			     Scan_NextCh()
      			    end
          	    end # while
          	else  
          		if (Scan_Ch == LF_CHAR) 
          		     Scan_CurrLine-=1
          		      Scan_LineStart = OldLineStart
          		end
          		Scan_BuffPos -= 2
          		Scan_CurrCol = OldCol - 1
          		Scan_NextCh()
          	end 
          end # if (Scan_Ch == '/') 
          if (Scan_Ch == '/')  
          	Scan_NextCh()
          	if (Scan_Ch == '/')  
          		Scan_NextCh()
          		while (1)
          			if (Scan_Ch== 10)  
          				Level--
          				Scan_NextCh()
          				Scan_ComEols = Scan_CurrLine - StartLine
          				if(Level == 0) 
          				    return 1
      				    end
          			elsif (Scan_Ch == EOF_CHAR) 
          			    return 0
          			else
          			    Scan_NextCh()
          		end 
          	else  
          		if (Scan_Ch == LF_CHAR)
          		     Scan_CurrLine-=1
          		      Scan_LineStart = OldLineStart 
      		     end
          		Scan_BuffPos -= 2
          		 Scan_CurrCol = OldCol - 1
          		  Scan_NextCh()
          	end 
          end  # if (Scan_Ch == '/')  

          return 0
    end
    def Get()
        int state, ctx

          start:
            while (Scan_Ch >= 9 && Scan_Ch <= 10 ||
                   Scan_Ch == 13 ||
                   Scan_Ch == ' ') Scan_NextCh()
            if ((Scan_Ch == '/') && Comment()) goto start

            CurrSym = NextSym
            NextSym.Init(0, CurrLine, CurrCol - 1, BuffPos, 0)
            NextSym.Len  = 0; ctx = 0

            if (Ch == EOF_CHAR) return EOF_Sym
            state = STATE0[Ch]
            while(1) 
              Scan_NextCh()
              NextSym.Len+=1
              case (state) 
           
              when 1:
              	if (Scan_Ch >= '0' && Scan_Ch <= '9' ||
              	    Scan_Ch >= 'A' && Scan_Ch <= 'Z' ||
              	    Scan_Ch == '_' ||
              	    Scan_Ch >= 'a' && Scan_Ch <= 'z') ; 
              	    else
              	        return CheckLiteral(identifierSym)
          	        end
              	break
              when 2:
              	if (Scan_Ch == 'U')
              	    state = 5
              	elsif (Scan_Ch == 'u') 
              	    state = 6
              	elsif (Scan_Ch == 'L') 
              	    state = 7 
              	elsif (Scan_Ch == 'l') 
              	    state = 8 
              	elsif (Scan_Ch == '.') 
              	    state = 4 
              	elsif (Scan_Ch >= '0' && Scan_Ch <= '9') 
              	e   lse
              	    return numberSym
          	    end
              	break
              when 4:
              	if (Scan_Ch == 'U') 
              	    state = 13 
              	elsif (Scan_Ch == 'u') 
              	    state = 14 
              	elsif (Scan_Ch == 'L')
              	     state = 15 
              	elsif (Scan_Ch == 'l') 
              	    state = 16 
              	elsif (Scan_Ch >= '0' && Scan_Ch <= '9') 
              	else
              	    return C_numberSym 
          	    end
              	break
              when 5:
              	return C_numberSym 
              when 6:
              	return C_numberSym 
              when 7:
              	return C_numberSym 
              when 8:
              	return C_numberSym 
              when 13:
              	return C_numberSym 
              when 14:
              	return C_numberSym 
              when 15:
              	return C_numberSym 
              when 16:
              	return C_numberSym 
              when 18:
              	if (Scan_Ch >= '0' && Scan_Ch <= '9' ||
              	    Scan_Ch >= 'A' && Scan_Ch <= 'F' ||
              	    Scan_Ch >= 'a' && Scan_Ch <= 'f')
              	    state = 19
                else
              	    return No_Sym
          	    end
              	break
              when 19:
              	if (Scan_Ch == 'U') 
              	    state = 20
              	elsif (Scan_Ch == 'u') 
              	    state = 21
              	elsif (Scan_Ch == 'L') 
              	    state = 22
              	elsif (Scan_Ch == 'l') 
              	    state = 23
              	elsif (Scan_Ch >= '0' && Scan_Ch <= '9' ||
              	    Scan_Ch >= 'A' && Scan_Ch <= 'F' ||
              	    Scan_Ch >= 'a' && Scan_Ch <= 'f') 
                else
              	    return C_hexnumberSym
                end
              	break
              when 20:
              	return C_hexnumberSym
              when 21:
              	return C_hexnumberSym
              when 22:
              	return C_hexnumberSym
              when 23:
              	return C_hexnumberSym
              when 24:
              	if (Scan_Ch == '"') state = 25; else
              	if (Scan_Ch >= ' ' && Scan_Ch <= '!' ||
              	    Scan_Ch >= '#' && Scan_Ch <= 255) 
              	else
              	    return No_Sym
              	end
              	break
              when 25:
              	return stringD1Sym
              when 26:
              	if (Scan_Ch >= ' ' && Scan_Ch <= '&' ||
              	    Scan_Ch >= '(' && Scan_Ch <= '[' ||
              	    Scan_Ch >= ']' && Scan_Ch <= 255) state = 28; else
              	if (Scan_Ch == 92) state = 36; else
              	return No_Sym
              	break
              when 28:
              	if (Scan_Ch == 39) state = 29; else
              	return No_Sym
              	break
              when 29:
              	return charD1Sym
              when 30:
              	if (Scan_Ch == '.' ||
              	    Scan_Ch >= '0' && Scan_Ch <= ':' ||
              	    Scan_Ch >= 'A' && Scan_Ch <= 'Z' ||
              	    Scan_Ch == 92 ||
              	    Scan_Ch >= 'a' && Scan_Ch <= 'z') state = 31; else
              	if (Scan_Ch == '=') state = 58; else
              	if (Scan_Ch == '<') state = 60; else
              	return LessSym
              	break
              when 31:
              	if (Scan_Ch == '>') state = 32; else
              	if (Scan_Ch == '.' ||
              	    Scan_Ch >= '0' && Scan_Ch <= ':' ||
              	    Scan_Ch >= 'A' && Scan_Ch <= 'Z' ||
              	    Scan_Ch == 92 ||
              	    Scan_Ch >= 'a' && Scan_Ch <= 'z') ; else
              	return No_Sym
              	break
              when 32:
              	return librarySym
              when 33:
              	if (Scan_Ch >= 'A' && Scan_Ch <= 'Z' ||
              	    Scan_Ch >= 'a' && Scan_Ch <= 'z') state = 34; else
              	if (Scan_Ch == '#') state = 70; else
              	return No_Sym
              	break
              when 34:
              	return PreProcessorSym
              when 35:
              	if (Scan_Ch == 'U') state = 5; else
              	if (Scan_Ch == 'u') state = 6; else
              	if (Scan_Ch == 'L') state = 7; else
              	if (Scan_Ch == 'l') state = 8; else
              	if (Scan_Ch == '.') state = 4; else
              	if (Scan_Ch >= '0' && Scan_Ch <= '9') state = 2; else
              	if (Scan_Ch == 'X' ||
              	    Scan_Ch == 'x') state = 18; else
              	return numberSym
              	break
              when 36:
              	if (Scan_Ch >= ' ' && Scan_Ch <= '&' ||
              	    Scan_Ch >= '(' && Scan_Ch <= 255) state = 28; else
              	if (Scan_Ch == 39) state = 29; else
              	return No_Sym
              	break
              when 37:
              	return SemicolonSym
              when 38:
              	if (Scan_Ch == '=') state = 73; else
              	return SlashSym
              	break
              when 39:
              	return LbraceSym
              when 40:
              	return RbraceSym
              when 41:
              	if (Scan_Ch == '=') state = 54; else
              	return EqualSym
              	break
              when 42:
              	return CommaSym
              when 43:
              	return LbrackSym
              when 44:
              	return RbrackSym
              when 45:
              	return LparenSym
              when 46:
              	return RparenSym
              when 47:
              	if (Scan_Ch == '=') state = 72; else
              	return StarSym
              	break
              when 48:
              	if (Scan_Ch == ':') state = 69; else
              	return ColonSym
              	break
              when 49:
              	if (Scan_Ch == '|') state = 50; else
              	if (Scan_Ch == '=') state = 79; else
              	return BarSym
              	break
              when 50:
              	return BarBarSym
              when 51:
              	if (Scan_Ch == '&') state = 52; else
              	if (Scan_Ch == '=') state = 77; else
              	return AndSym
              	break
              when 52:
              	return AndAndSym
              when 53:
              	if (Scan_Ch == '=') state = 78; else
              	return UparrowSym
              	break
              when 54:
              	return EqualEqualSym
              when 55:
              	if (Scan_Ch == '=') state = 56; else
              	return BangSym
              	break
              when 56:
              	return BangEqualSym
              when 57:
              	if (Scan_Ch == '=') state = 59; else
              	if (Scan_Ch == '>') state = 61; else
              	return GreaterSym
              	break
              when 58:
              	return LessEqualSym
              when 59:
              	return GreaterEqualSym
              when 60:
              	if (Scan_Ch == '=') state = 80; else
              	return LessLessSym
              	break
              when 61:
              	if (Scan_Ch == '=') state = 81; else
              	return GreaterGreaterSym
              	break
              when 62:
              	if (Scan_Ch == '+') state = 65; else
              	if (Scan_Ch == '=') state = 75; else
              	return PlusSym
              	break
              when 63:
              	if (Scan_Ch == '-') state = 66; else
              	if (Scan_Ch == '>') state = 68; else
              	if (Scan_Ch == '=') state = 76; else
              	return MinusSym
              	break
              when 64:
              	if (Scan_Ch == '=') state = 74; else
              	return PercentSym
              	break
              when 65:
              	return PlusPlusSym
              when 66:
              	return MinusMinusSym
              when 67:
              	return PointSym
              when 68:
              	return MinusGreaterSym
              when 69:
              	return ColonColonSym
              when 70:
              	return HashHashSym
              when 71:
              	return DollarSym
              when 72:
              	return StarEqualSym
              when 73:
              	return SlashEqualSym
              when 74:
              	return PercentEqualSym
              when 75:
              	return PlusEqualSym
              when 76:
              	return MinusEqualSym
              when 77:
              	return AndEqualSym
              when 78:
              	return UparrowEqualSym
              when 79:
              	return BarEqualSym
              when 80:
              	return LessLessEqualSym
              when 81:
              	return GreaterGreaterEqualSym
              when 82:
              	return TildeSym

              default: return No_Sym; 
             end #case
        end #while
    end
end
