load "cr_scan.rb"
load "rubyutility.rb"
load "log.rb"

class String
    def to_byte
        # self.bytes[0] # not work for ruby 1.8.7
        self[0].ord # to Decimal
    end
end
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


=begin
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
=end

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
	DEF nEXTcH()
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

# Scan_Ch        Ch




           MAX_IDENTIFIER_LENGTH = 1000
class CScanner <  CRScanner
    
    attr_accessor :currLine, :currCol, :include_stack
   def Scan_NextCh    
       NextCh()
   end
   # def Scan_ComEols   
   #     @comEols
   # end
   # def Scan_CurrLine 
   #      @currLine
   #  end

   # def Scan_CurrCol  
   #      @currCol
   #      end
        
   # def Scan_LineStart 
   #     @lineStart
   #     end
       
   # def Scan_BuffPos   
   #     @buffPos
   #     end
       
   def Scan_NextLen   
       nextSym.len
   end
   
   
  public
    # def initialize( srcFile,  ignoreCase) 
    #     super(srcFile, ignoreCase)
    # end
    def initialize( str="",  ignoreCase=true) 
        super(str, ignoreCase)
        @include_stack = []
    end

    def current_line
        pos1 = nextSym.pos
        while pos1-1 >= 0 && buffer[pos1-1] != "\n"
            pos1 -=1
        end
        pos2 = nextSym.pos
        while buffer[pos2+1] && buffer[pos2+1] != "\n"
            pos2 +=1
        end
        return buffer[pos1..pos2]
    end
    def set(_str, _ignoreCase, _currSym, _nextSym, _currLine, _currCol, _lineStart, _pos, _ch, _comEols)
        @ch = _ch
        @buffer = _str
        @ignoreCase = _ignoreCase
        @currSym = AbsToken.new
        @currSym.init(_currSym.sym, _currSym.line, _currSym.col, _currSym.pos, _currSym.len)
        @nextSym = AbsToken.new
        @nextSym.init(_nextSym.sym, _nextSym.line, _nextSym.col, _nextSym.pos, _nextSym.len)  
        @currLine = _currLine
        @currCol = _currCol
        @lineStart = _lineStart
        @buffPos = _pos
        @comEols = _comEols
    end
    
    def clone()
        sc = CScanner.new
        sc.set(@buffer, @ignoreCase, @currSym, @nextSym, @currLine, @currCol, @lineStart, @buffPos, @ch, @comEols)
        return sc
    end
    
    def GetName()

        # return super(@CurrSym, MAX_IDENTIFIER_LENGTH-1)
        # return super(@currSym)
        return GetSymString(@currSym)
	end
	def GetNextName()
	    return GetSymValue(@nextSym)
    end
  protected
    # @@STATE0 = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    #              0,0,0,55,24,33,71,64,51,26,45,46,47,62,42,63,67,38,35,2,2,2,2,2,2,2,2,2,48,37,
    #                    30,41,57,83,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    #                    1,43,0,44,53,1,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    #                    1,1,1,39,49,40,82,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    #                    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    #                    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    #                    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    #                    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    
    # the index of the array is the character's acsii code (ch.to_byte), value of array element is the status code.                 
    @@STATE0 =  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                 0, 0, 0,55,24,33,71,64,51,26,
                 45,46,47,62,42,63,67,38,35,2,
                 2, 2, 2, 2, 2, 2, 2, 2, 48, 37,
                30,41,57,83, 0, 1, 1, 1, 1, 1,
                 1, 1, 1, 1, 1, 1, 84, 1, 1, 1,
                 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                 1,43, 0,44,53, 1, 0, 1, 1, 1,
                 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                 1, 1, 1,39,49,40,82, 0, 0, 0,
                 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                 0, 0, 0, 0, 0, 0]
    # static int STATE0[]
    def CheckLiteral( id)
        # char c

          c =  CurrentCh(nextSym.pos)
         
          # if (IgnoreCase) c = Upcase(c)
          case (c) 
        	when 'a'
        		
              return C_autoSym if (EqualStr("auto")) 
          	when 'b'
          		
                return C_breakSym if (EqualStr("break")) 
                return C_boolSym if (EqualStr("bool")) 
          		#break
          	when 'c'
          		if (EqualStr("class"))
          		     return C_classSym
      		     end
          		return C_charSym if (EqualStr("char")) 
          		return C_caseSym if (EqualStr("case")) 
          		return C_continueSym if (EqualStr("continue"))
          		return C_constSym if (EqualStr("const")) 
          		#if (EqualStr("const")) 
                #    p("return const", 10)
                #    return C_constSym
                #end
          		#break
          	when 'd'
          		return C_doubleSym if (EqualStr("double")) 
          		return C_defaultSym if (EqualStr("default")) 
          		return C_doSym if (EqualStr("do")) 
          		return C_deleteSym if (EqualStr("delete")) 
                
          		#break
          	when 'e'
          		return C_elseSym if (EqualStr("else")) 
          		return C_EnumSym if (EqualStr("enum")) 
          		return C_externSym if (EqualStr("extern")) 
          		
          		#break
          	when 'f'
#          		return C_functionSym if (EqualStr("function"))  
          		return C_floatSym if (EqualStr("float"))  
          		#return C_finalSym if (EqualStr("final"))  
          		return C_forSym if (EqualStr("for")) 
          		#break
            when 'g'
                return C_gotoSym if EqualStr("goto")
          	when 'i'
          		return C_inheritSym if (EqualStr("inherit")) 
           		return C_inlineSym if (EqualStr("inline")) 
                return C_intSym if (EqualStr("int")) 
           		return C_ifSym if (EqualStr("if")) 
            when 'I'
                return C_INSym if (EqualStr("IN"))
                return C_INOUTSym if (EqualStr("INOUT"))  
          		#break
                
          	when 'l'
          		#return C_loadSym if (EqualStr("load")) 
          		return C_longSym if (EqualStr("long")) 
          		#break
          	when 'm'
          		return C_mySym if (EqualStr("my")) 
          		return C_mixedSym if (EqualStr("mixed")) 
          		#break
          	when 'n'
          		return C_namespaceSym if (EqualStr("namespace")) 
                
          		return C_newSym if (EqualStr("new")) 
          		#break
            when 'o'
                return C_overrideSym if EqualStr("override")
                return C_operatorSym if EqualStr("operator")
            when 'O'
                return C_OUTSym if EqualStr("OUT")
          	when 'p'
          		#return C_packageSym if (EqualStr("package")) 
          		#break
          	when 'r'
          		return C_returnSym if (EqualStr("return")) 
          		#break
          	when 's'
          		return C_staticSym if (EqualStr("static")) 
          		return C_shortSym if (EqualStr("short")) 
          		#return C_stringSym if (EqualStr("string")) 
          		return C_switchSym if (EqualStr("switch")) 
          		return C_StructSym if (EqualStr("struct")) 
          		return C_sizeofSym if (EqualStr("sizeof")) 
          		
          		#break
          	when 't'
          	    return C_typenameSym if (EqualStr("typename")) 
          	    return C_TypedefSym if (EqualStr("typedef")) 
          		return C_throwSym if (EqualStr("throw")) 
                return C_templateSym if (EqualStr("template")) 
          	when 'u'
                return C_unionSym if EqualStr("union")
          		return C_usingSym if (EqualStr("using")) 
          		#return C_useSym if (EqualStr("use")) 
          		return C_unsignedSym if (EqualStr("unsigned")) 
          		#break
          	when 'v'
          		#return C_varSym if (EqualStr("var")) 
          		return C_voidSym if (EqualStr("void")) 
          		#break
          	when 'w'
          		return C_whileSym if (EqualStr("while")) 
          		#break

          end
          return id
    end
    def LeftContext(s)
        rais("not implemented")
=begin
        int Level, StartLine, OldCol
          long OldLineStart

          Level = 1; StartLine = CurrLine
          OldLineStart = LineStart; OldCol = @currCol
          if (@ch == '/') { 
          	Scan_NextCh()
          	if (@ch == '*') { 
          		Scan_NextCh()
          		while (1) {
          			if (@ch== '*') { 
          				Scan_NextCh()
          				if (@ch == '/') { 
          					Level--; Scan_NextCh(); Scan_ComEols = @currLine - StartLine
          					if(Level == 0) return 1
          				}  
          			} else 
          			if (@ch == EOF_CHAR) return 0
          			else Scan_NextCh()
          		} 
          	} else { 
          		if (@ch == LF_CHAR) { @currLine--; @lineStart = OldLineStart; }
          		@buffPos -= 2; @currCol = OldCol - 1; Scan_NextCh()
          	} 
          } 
          if (@ch == '/') { 
          	Scan_NextCh()
          	if (@ch == '/') { 
          		Scan_NextCh()
          		while (1) {
          			if (@ch== 10) { 
          				Level--; Scan_NextCh(); Scan_ComEols = @currLine - StartLine
          				if(Level == 0) return 1
          			} else 
          			if (@ch == EOF_CHAR) return 0
          			else Scan_NextCh()
          		} 
          	} else { 
          		if (@ch == LF_CHAR) { @currLine--; @lineStart = OldLineStart; }
          		@buffPos -= 2; @currCol = OldCol - 1; Scan_NextCh()
          	} 
          } 

          return 0
=end       
    end
    
    # return 1: comments completed
    # return 0: comments not completed but encounter nil or EOF
    def Comment()
        # int Level, StartLine, OldCol
        #       long OldLineStart
        # p "comment1"
          level = 1
          startLine = @currLine
          oldLineStart = @lineStart
          oldCol = @currCol
          # p "comments:pos #{@buffPos}, ch #{@ch}"
          if (@ch == '/') 
              Scan_NextCh()
              # p "comments3:pos #{@buffPos}, ch #{@ch}"
              
          	  if (@ch == '*')  
          		  Scan_NextCh()
                  # p "comments2:pos #{@buffPos}, ch #{@ch}"
          		  while (1) 
          			  if (@ch== '*') 
          				  Scan_NextCh()
          				  if (@ch == '/')
          				      level-=1
          					  Scan_NextCh()
          					  @comEols = @currLine - startLine
          					  if(level == 0) 
          					      return 1
          					  end
          				  end  
          			  elsif (@ch == nil || @ch.to_byte == EOF_CHAR) 
          			      return 0
          			  else
          			      Scan_NextCh()
      			      end
          	      end # while
          	  else  
          	      # p "comment3"
                  # p "comments4:pos #{@buffPos}, ch #{@ch}"
                  
          	      if (@ch == nil || @ch.to_byte == LF_CHAR) 
                         @currLine -= 1
                         @lineStart = oldLineStart
                  end
                  @buffPos -= 2
                  @currCol = oldCol - 1
                  Scan_NextCh()
              end # if (@ch == '*') 
          end # if (@ch == '/') 
           # p "comments5:pos #{@buffPos}, ch #{@ch}"
           
          if (@ch == '/')  
          	Scan_NextCh()
            # p "comments6:pos #{@buffPos}, ch #{@ch}"
            
          	if (@ch == '/')  # 2
          		Scan_NextCh()
                # p "comments7:pos #{@buffPos}, ch #{@ch}"
              	
          		while (1)
                    # p "comment4:level #{level}, ch #{@ch}"
                    
          			if (@ch.to_byte == 10)  
          				
          				level-=1
          			    # comment following 2 lines out, cuz we need it stop before LRCF
          			    # Scan_NextCh()
          			    # @comEols = @currLine - startLine
          				
          				if(level == 0) 
                            # p "comments9:pos #{@buffPos}, ch #{@ch}"
          				    
          				    # make it stop before CRLF
                    		# if @ch.to_byte == 10 || @ch.to_byte==13
                    		#                                  @currLine -= 1
                    		#                                  @lineStart = oldLineStart
                    		#                                  @buffPos -= 2
                    		#                                  @currCol = oldCol - 1
                    		#                                  p "comments90:pos #{@buffPos}, ch #{@ch}"
                    		#                                 
                    		#                                  Scan_NextCh()
                    		#                             end
            		        # end of change
                            # p "comments91:pos #{@buffPos}, ch #{@ch}"
          				    
          				    return 1
      				    end
          			elsif (@ch == nil || @ch.to_byte == EOF_CHAR) 
                        # p "comments8:pos #{@buffPos}, ch #{@ch}"
                
          			    return 0
          			else
          			    Scan_NextCh()
      			    end
          		end # while (1)
                # p "comments7:pos #{@buffPos}, ch #{@ch}"
          		
          	else  
                # p "comment5"
                # p "comments71:pos #{@buffPos}, ch #{@ch}"
          		
          		if (@ch == nil || @ch.to_byte == LF_CHAR)
                    # p "comments72:pos #{@buffPos}, ch #{@ch}"
                    
          		     @currLine-=1
          		      @lineStart = oldLineStart 
      		    end
          		@buffPos -= 2
          		@currCol = oldCol - 1
          		Scan_NextCh()
          	end # if (@ch == '/')  2
          end  # if (@ch == '/')  
            # p "comments10:pos #{@buffPos}, ch #{@ch}"

          return 0
    end
public
    def delete_prevline
        pos = nextSym.pos
      #  p "-=-->delete_prevline:pos #{@buffPos}, cur line #{@currLine}, ch #{@buffer[@buffPos].inspect}, buffer size #{@buffer.size}, buffer=#{@buffer}", 10
        return if pos <=0
        
        
        if pos > @buffer.size-1
            return delete_line(@buffer.size-1)
        end
        # p "ch[#{pos}]:#{@buffer[pos]}, #{@buffer[pos].to_byte}"
        if CurrentCh(pos) == "\n" 
            # break if CurrentCh(pos) == nil
            pos -=1
          # p "ch[#{pos}]:#{@buffer[pos]}, #{@buffer[pos].to_byte}"
            # p cch().to_byte
        end
        if CurrentCh(pos) == "\r" 
            # break if CurrentCh(pos) == nil
            pos -=1
          # p "ch[#{pos}]:#{@buffer[pos]}, #{@buffer[pos].to_byte}"
            # p cch().to_byte
        end
        # p "-=-->pos1:#{pos}"
        while CurrentCh(pos) != nil && CurrentCh(pos) != "\n"
            pos -= 1
            # p "ch[#{pos}]:#{@buffer[pos]}, #{@buffer[pos].to_byte}"
        end
        p "-=-->pos2:#{pos}"
        pos = 0 if pos < 0
       # old_size = @buffer.size
        # p "-=-->pos3:#{pos}, #{@buffer[pos].to_byte}"
        
        delete_line(pos)
        # @buffPos -= old_size - @buffer.size
        
    end
    # insert before pos line
    def insert_line(str, pos=nil)
        __t = Time.now.to_f
        # p "insert line #{str}, pos=#{pos}, @buffPos=#{@buffPos}"
        # pp "insert line #{str}, pos=#{pos}, #{self.inspect}"
        # pp "old buffer before insert:#{@buffer}", 20
        pos = @buffPos if pos == nil
        while @buffer[pos] == "\n"
            pos -= 1
        end
        while @buffer[pos] != nil && @buffer[pos] != "\n"
            pos -= 1
        end
        pos = -1 if pos <-1
        str += "\n"
        # p "insert_line:pos=#{pos}"
        str1 = ""
        if pos >0 
            str1 = @buffer[0..pos]
        end
        str2 = @buffer[pos+1..@buffer.size-1]
        # p "str1:#{str1}"
        @buffer = "#{str1}#{str}#{str2}"
        # p "new buffer after insert:#{@buffer}"
        p "@@@ insert line cost #{Time.now.to_f - __t}"
        
    end
    
    
    def delete_curline
        delete_line()
    end
    
    # delete lines where from line pos1 located1 to line pos2 located
    def delete_lines(pos1, pos2, include_last_line=true)
        __t = Time.now.to_f
        
     #   pp "===>delete_lines, pos=#{pos1},#{pos2}, @buffPo=#{@buffPos}, buffer=#{@buffer}", 20
        
        replace_start = pos1
        replace_end = pos2
       # p "replace_start:#{dump_char(replace_start-2)}|#{dump_char(replace_start-1)}|#{dump_char(replace_start)}|#{dump_char(replace_start+1)}"
       # p "replace_end:#{replace_end}(#{@buffer[replace_end]})  #{dump_char(replace_end-2)}|#{dump_char(replace_end-1)}|#{dump_char(replace_end)}|#{dump_char(replace_end+1)}"
                
         # to line start
         if @buffer[replace_start] == "\n" || @buffer[replace_start] == "\r" 
             if @buffer[replace_start] == "\r" 
                 replace_start -=1
             elsif @buffer[replace_start] == "\n" 
                 replace_start -=1
                 replace_start -=1 if @buffer[replace_start] == "\r"
             end
         end
        while (@buffer[replace_start] != "\n" && @buffer[replace_start] != "\r" && replace_start >=0)
            replace_start -=1
        end
        if @buffer[replace_start] == "\n" || @buffer[replace_start] == "\r"  
            replace_start +=1 
        end
        
       # p "replace_start1:#{dump_char(replace_start-2)}|#{dump_char(replace_start-1)}|#{dump_char(replace_start)}|#{dump_char(replace_start+1)}"
       # p "replace_end1:#{replace_end}(#{@buffer[replace_end]})  #{dump_char(replace_end-2)}|#{dump_char(replace_end-1)}|#{dump_char(replace_end)}|#{dump_char(replace_end+1)}"
        
        if include_last_line
            # to line end
            while (@buffer[replace_end] != "\n" && @buffer[replace_end] != "\r")
                replace_end +=1
            end
        else
            #while (@buffer[replace_end] == "\n" || @buffer[replace_end] == "\r")
            #    replace_end -=1
            #end1
           # p "replace_start2:#{dump_char(replace_start-2)}|#{dump_char(replace_start-1)}|#{dump_char(replace_start)}|#{dump_char(replace_start+1)}"
           # p "replace_end2:#{replace_end}(#{@buffer[replace_end]}) #{dump_char(replace_end-2)}|#{dump_char(replace_end-1)}|#{dump_char(replace_end)}|#{dump_char(replace_end+1)}"
            
            while (@buffer[replace_end] != "\n" && @buffer[replace_end] != "\r" && @buffer[replace_end] !=nil)
                replace_end -=1
            end         
           # p "replace_start3:#{dump_char(replace_start-2)}|#{dump_char(replace_start-1)}|#{dump_char(replace_start)}|#{dump_char(replace_start+1)}"
           # p "replace_end3:#{replace_end} #{dump_char(replace_end-2)}|#{dump_char(replace_end-1)}|#{dump_char(replace_end)}|#{dump_char(replace_end+1)}"
               
        end
        

        p "replace_start=#{replace_start}, #{buffer[replace_start..replace_start+10]}, replace_end=#{replace_end}, ,#{buffer[replace_end..replace_end+10]}, buffPos=#{@buffPos}"
        
        if replace_end > replace_start       
        
            #calculate line
            line_count_before_pos = 0
            if @buffPos > replace_start && @buffPos < replace_end
                i = replace_start
                i = 0 if i < 0
                while (i < @buffPos)
                    i +=1
                    line_count_before_pos += 1 if buffer[i] == "\n"
                end
            end

            replaced = @buffer[replace_start..replace_end]
            line_count = replaced.count("\n")
        
            p "replace_start=#{replace_start} #{@buffer[replace_start..replace_start+10]}, replace_end=#{replace_end}, #{@buffer[replace_end..replace_end+10]}, buffPos=#{@buffPos}"
            p "line count:#{line_count}"
            str1 = ""
                    
            if replace_start > 0 
                str1 = @buffer[0..replace_start-1]
            end
            old_buffer_size = @buffer.size
            deleted_content = @buffer[replace_start..replace_end]
            @buffer = "#{str1}#{@buffer[replace_end+1..@buffer.size-1]}"
            size_diff = @buffer.size - old_buffer_size
            @nextSym.pos += size_diff if @nextSym.pos > replace_end
            @currSym.pos += size_diff if @currSym.pos > replace_end
           # p "buffer:#{@buffer}"
            # if include_last_line
            #     @buffPos = replace_start
            # else
            #     @buffPos -= (old_buffer_size - @buffer.size )
            # end
            p "==>789L:line #{@currLine}, #{@buffPos}, size change #{old_buffer_size-@buffer.size}"
             if @buffPos >= replace_end
                  @buffPos -= (old_buffer_size - @buffer.size )
                  @currLine -= line_count
                  @lineStart -= (old_buffer_size-@buffer.size)
                 #  p "==>7892L:#{@buffPos}, #{@currLine}"
                  #Reset(@buffPos, @currLine, @lineStart, @currCol)
                 # p "==>7893L:#{@buffPos}"
             elsif @buffPos > replace_start# &&  @buffPos <replace_end
                 # adjust buffPos
                if replace_start < 0
                    @buffPos = -1
                else                    
                    @buffPos = replace_start-1 # -1 because will scann_nextch()
                end
                # adjust currLine, lineStart
                if @buffPos >= replace_end
                    @currLine -= line_count
                    @lineStart += size_diff
                else
                    @currCol = 0
                    @currLine -= line_count_before_pos
                end
              #  Reset(@buffPos, @currLine, @lineStart, @currCol)
                 
              Scan_NextCh()
                 
            end
        end
        
        
        # pp "===>delete_lines2, pos=#{pos1},#{pos2}, @buffPo=#{@buffPos}, buffer=#{@buffer}", 20 
        p "@@@ delete lines#{line_count}/#{size_diff} cost #{Time.now.to_f - __t}", 5
      #  p "buffer(#{@buffer.size}):#{@buffer}"
      #  p "deleted:#{deleted_content}"
      #  p "buffPos:#{buffPos}, #{nextSym.inspect}"
        return [replace_start, replace_end] 
    end
    
    def dump_char(pos=@buffPos)
        if @buffer[pos]  == nil
            return "(nil)"
        elsif @buffer[pos].to_byte == 10 || @buffer[pos].to_byte == 13 || @buffer[pos].to_byte ==0
            return "'\\#{@buffer[pos].to_byte}'@#{pos})"
        else
            return "'#{@buffer[pos]}'(#{@buffer[pos].to_byte}@#{pos})"
        end
    end
    
    def delete_in_line(from, to) # delete content from pos(from) to pos(to)(not include to)
        __t = Time.now.to_f
        
        p ("delete_in_line:from #{from}(#{buffer[from..from+5]}), #{to}(#{buffer[to..to+5]}), #{@buffPos}"), 10
        replace_start = from 
         replace_end = to
         
         str1 = ""
         if replace_start >= 1
             str1 = @buffer[0..replace_start-1]
         end
         old_size = @buffer.size   
         str = str1+@buffer[replace_end..@buffer.size-1]
          @buffer=str
          if @buffPos > replace_start# &&  @buffPos <replace_end
              if replace_start < 0
                  @buffPos = -1
              else
                  @buffPos = replace_start-1
              end
              Reset(@buffPos, @currLine, @lineStart, @currCol)
          end
          
          @ch = CurrentCh(@buffPos)
          p "pos after deleteinline:#{@buffPos}"
         # p "after delete_in_line:#{@buffer}"
         # p "buffer  after deleteinline:#{@buffer}", 10
         p "@@@ delete in line cost #{Time.now.to_f - __t}"
         
    end
    def delete_line(pos=nil)
        __t = Time.now.to_f
        p "replace_start333:#{nextSym.inspect}, pos=#{pos}, #{GetSymValue(nextSym)}"
        
        pos = nextSym.pos if pos == nil
        if pos >= @buffer.size
            pos -=1
        end
        return if pos >= @buffer.size || pos < 0 || pos == nil
       # p "===>delete_line, #{@buffer[pos..pos+20].inspect}, @buffPos=#{@buffPos}, #{@buffer}", 10
        
     #   pp "===>delete_line, pos=#{pos}, ch=#{@buffer[pos].inspect}, @buffPos=#{@buffPos}, buffer=#{@buffer}", 20
        
        # replace_start is excluded, replace_end is excluded
        replace_start = pos 
        replace_start = 0 if replace_start < 0
        replace_end = pos
      #  p "replace_start333:#{replace_start}, #{replace_end}, #{@buffer[replace_start].to_byte if @buffer[replace_start]},#{@buffer.size}, #{@buffer}"
        
        #if @buffer[replace_start] == nil
        #    replace_start -=1
        #end
        #if @buffer[replace_end] == nil
        #    replace_end -=1
        #end
      #  p "replace_start1:#{dump_char(replace_start)}, #{cch}"
    #  p "replace_start2:#{replace_start}(#{@buffer[replace_start]}) #{dump_char(replace_start-3)}|#{dump_char(replace_start-2)}|#{dump_char(replace_start-1)}|#{dump_char(replace_start)}|#{dump_char(replace_start+1)}"
    #  p "replace_end2:#{replace_end}(#{@buffer[replace_end]}) #{dump_char(replace_start-3)}|#{dump_char(replace_end-2)}|#{dump_char(replace_end-1)}|#{dump_char(replace_end)}|#{dump_char(replace_end+1)}"
    
        
        # to line start
        if @buffer[replace_start] == "\n" 
            replace_start -=1
        end
        if @buffer[replace_start] == "\r" 
            replace_start -=1
        end

      #  p "replace_start2:#{dump_char(replace_start)}"

        #move replace_start before the first pos which will be replaced
        while (@buffer[replace_start] && @buffer[replace_start] != "\n" && @buffer[replace_start] != "\r" )
            replace_start -=1
        #    p "replace_start3:#{dump_char(replace_start)}"
            
        end
      #  p "replace_start4:#{dump_char(replace_start)}"
        
        # to line end
        # p "==>replace_end=#{replace_end}, #{@buffer[replace_end]}, #{@buffer[replace_end].to_byte}"
        while (@buffer[replace_end] && @buffer[replace_end] != "\n" && @buffer[replace_end] != "\r" )
            replace_end +=1
       #     p "==>replace_end2=#{replace_end}, #{@buffer[replace_end]}"
            
        end

        if @buffer[replace_end] == "\r"
             replace_end +=1
        end     
        if @buffer[replace_end] == "\n"
            replace_end +=1
        end 
            #     
            # while @buffer[replace_end] == "\n" || @buffer[replace_end] == "\r"
            #     replace_end +=1
            # end
        

        # p "c:#{c}"
        # p "str1:#{@buffer[0..replace_start]}"
        # p "str2:#{@buffer[@buffPos..@buffer.size-1]}"
        str1 = ""
        if replace_start >= 0
            str1 = @buffer[0..replace_start]
        end
      #  p "replace_start:#{dump_char(replace_start-2)}|#{dump_char(replace_start-1)}|#{dump_char(replace_start)}|#{dump_char(replace_start+1)}"
       # p "replace_end:#{dump_char(replace_end-2)}|#{dump_char(replace_end-1)}|#{dump_char(replace_end)}|#{dump_char(replace_end+1)}"
        
        # p "delete_line3: replace_start=#{replace_start}, replace_end=#{replace_end}, #{@buffer[replace_start+1..replace_end]}\n=====\n#{@buffer[replace_end+1..replace_end+15]}", 20
        
        # p "str1=#{str1}"
        # p "str2=#{@buffer[replace_end..@buffer.size-1]}"    
        old_size = @buffer.size   
        str = str1+@buffer[replace_end..@buffer.size-1]
     #   p "buffer1:#{@buffer}"
       # p "replace_start:#{replace_start}, #{replace_end}, #{@buffer[replace_start].to_byte}"
         @currLine -= @buffer[replace_start+1..replace_end-1].count("\n")
        @buffer=str
        # p "buffer2:#{@buffer}"
       
        if @buffPos > replace_start# &&  @buffPos <replace_end
            if replace_start < 0
                @buffPos = -1
            else
                @buffPos = replace_start
            end
            if @buffPos >= replace_end
               # @currLine = @currLine-1
                @lineStart -= (old_size-@buffer.size)
            end
            if @buffPos < replace_end
                @currCol = 0
            end
            Reset(@buffPos, @currLine, @lineStart, @currCol)
        end
        @ch = CurrentCh(@buffPos)
        # p "new buffer after delete current line(from #{pos} to #{@buffer.size-1}): #{@buffer[pos..@buffer.size-1]}, ||\n#{@buffer}"
        # p "buffer3(size=#{@buffer.size}, pos #{@buffPos}):#{@buffer[0..552]}"
        # p "buffer4(size=#{@buffer.size}):#{@buffer[0..431]}\n=========\n#{@buffer[432..552]}"
        
        # p "===>delete_line1:pos=#{@buffPos}, ch=#{@ch}, #{@buffer[@buffPos..@buffPos+10]},buffer:#{@buffer}"
       # p "pos:#{@buffPos}, #{@ch}, buffer:#{@buffer}"
       p "@@@ delete line cost #{Time.now.to_f - __t}"
        
    end
    
    def fix_ch
        @ch = CurrentCh(@buffPos)
    end
    def include_file(fname, dir=nil)
        __t = Time.now.to_f
        
        p("->->include file #{fname}", 10   )
        
        ret = true
        dirs = nil
        if $g_options
           # $g_search_dirs = $g_options[:include_dirs] if !$g_search_dirs
           dirs = $g_options[:include_dirs]  
        end
        
        dirs = [] if !dirs
        dirs.push(dir) if dir
        path = find_file(fname, dirs)
        c = read_file(path) if path
      #  p "read file #{path}, return #{c}"
        # if c == nil #|| c == ""
        #     delete_curline
        #     return false
        # end
        p "=>include_stack:#{@include_stack.inspect}"
        
        if c == nil
           c = "// include failed, include file #{fname} from file #{@include_stack.last}\n"
           ret = false
           append_file("err", c)
        else
         
              #begin
              #  c.encode("utf-8")
              # # "UTF-8"
              #rescue
              #  #"ISO-8859-1"
              #  p "--->encoding not utf-8"
              #  c = c.force_encoding('iso-8859-1').encode('utf-8')
              #end
              if ! c.valid_encoding?
                c = c.encode("UTF-16be", :invalid=>:replace, :replace=>"?").encode('UTF-8')
              end
           c = "// included file #{path} from file #{@include_stack.last} \n#{c}\n // end include file #{path} from file #{@include_stack.last} \n#includestackpop #{path}\n"   # you cannot use include_stack_pop, before the sym will only be "#include",because it will stop before "_", check method Get()
           @include_stack.push(path)
           indent = ""
           for i in 1..@include_stack.size
               indent += "----"
           end
           append_file("included_files", "#{indent}>#{path}\n")
        end
        # p "===>432q42#{@buffer[@buffPos..@buffer.size-1]}"
        p "before includefile #{fname}:#{@buffPos}, #{@buffer[@buffPos..@buffPos+20]}"
        replace_start = @buffPos-1
       
        # replace_end = @buffPos
        # p "3323:#{replace_start}, #{@buffer[replace_start].inspect}"

        while (@buffer[replace_start] != "\n" && @buffer[replace_start] != "\r" && replace_start >=0)
            replace_start -=1
        end
        # p "===>432q42#{@buffer[replace_start..@buffer.size-1]}"
        # while (@buffer[replace_end] != "\n" && @buffer[replace_end] != "\r")
        #     replace_end +=1
        # end
        # while @buffer[replace_end] == "\n" || @buffer[replace_end] == "\r"
        #     replace_end +=1
        # end
        # p "3, replace_start=#{replace_start}, @buffPos=#{@buffPos}"
        # p "c:#{c}"
        # p "str1:#{@buffer[0..replace_start]}"
        # p "str2:#{@buffer[@buffPos..@buffer.size-1]}"
        # p "3324:#{replace_start}, #{@buffer[replace_start].inspect}"

        if replace_start < 0
            str = c+@buffer[@buffPos..@buffer.size-1]
            @buffer=str
            
            @buffPos = -1
           
        else
            str = @buffer[0..replace_start]+c+@buffer[@buffPos..@buffer.size-1]
            @buffer=str
            
            @buffPos = replace_start
        end
         Scan_NextCh()
         # p "3325:#{@ch}"
         p "after includefile #{fname}:#{@buffPos}, #{@buffer[@buffPos..@buffPos+20]}"
         
        # p "new buffer after include: #{@buffer[@buffPos..@buffer.size-1]}"
        
        # p "new buffer after include :#{@buffer}"
        # p "pos1:#{@buffPos}, #{@buffer[@buffPos..@buffPos+30]}"
        p "@@@ include file cost #{Time.now.to_f - __t}"
        
        return ret
    end
    # # get next next sym
    #  def getNext()
    #      sc = CScanner.new
    #      sc.set(@buffer, @ignoreCase, @currSym, @nextSym, @currLine, @currCol, @lineStart, @buffPos, @ch, @comEols))
    #      return sc.Get()
    #      
    #  end
    # get next sym
    
    # should'nt do this in a cycle like #ifdef #if
    def save_part(fname)
        @saved_line = 0 if !@save_line
        pos = @buffPos
        p "save_part1:#{pos}, #{currLine}, #{@saved_line}"
        while pos>=0 && @buffer[pos] != "\n"
            pos -=1
        end
        for i in 0..5
            if pos >= 0
                pos -= 1 if @buffer[pos] == "\n"
                while pos>=0 && @buffer[pos] != "\n"
                    pos -=1
                end 
            end
        end
        pos = 0 if pos < 0
        # now pos will be \n 
        p "save_part:#{pos}"
        content = @buffer[0..pos]
        #p "content:#{content}"
        append_file(fname, content)
        lineLost = content.count("\n")
        p "save line #{lineLost}"
        
        @saved_line += lineLost
        @buffer = @buffer[pos+1..@buffer.size-1]
        sizeDiff = pos+1
        @buffPos -= sizeDiff
      #  @currLine = @buffer[0..@buffPos].count("\n")+1
        @nextSym.pos -=sizeDiff
        @nextSym.line -= lineLost
        @currSym.pos -= sizeDiff
        @currSym.line -= lineLost
        
        return lineLost
        
    end
    
    def remain_enough_line?(n)
        #p "=>remain_enough_line?"
        pos = @buffPos
        i = 0
        while i <= n && pos < @buffer.size-1
           while @buffer[pos] != "\n" && pos < @buffer.size-1
               pos += 1
           end
           i +=1 if @buffer[pos] == "\n"
           pos +=1 
        end
        return i > n
    end

    def Get(ignore_crlf=true)
        # int state, ctx
    # p "pos:#{@buffPos}, line #{@currLine}, ch #{cch()}, @ch #{@ch}"
     #    @ch = @buffer[buffPos]
   #  p "pos:#{@buffPos}, line #{@currLine}, ch #{cch()}, @ch #{@ch}"
         
        return C_EOF_Sym if @ch == nil
        
         # filter white space and comments
         begin
            return C_EOF_Sym if @ch == nil

            
            # filter white space
            while (@ch.to_byte >= 9 && # TAB
                    @ch.to_byte <= 10 || # LF
                   @ch.to_byte == 13 || # CR
                   @ch == ' ' || # space
                   @ch == '\\'
                   ) 
                    # p "get30:#{@ch}, #{@buffPos}"
                    if !ignore_crlf && ( @ch.to_byte == 13|| ch.to_byte == 10)
                        p "crlf:#{@ch.to_byte}, pos #{@buffPos}"
                        @currSym = nextSym.clone
                        nextSym.init(0, @currLine, @currCol - 1, @buffPos, 1)
                        nextSym.len  = 1
                        Scan_NextCh()
                        
                        return C_CRLF_Sym
                    end
                    Scan_NextCh()
                     # p "get31:#{@ch}, #{@buffPos}"
                    return C_EOF_Sym if @ch == nil 
            end
        end while ((@ch == '/') && Comment()==1) 
        # p "get3:#{@ch}"
        # if $sc_cur != $sc.currSym.sym
        #     pp("!!!===", 20)
        # end
            @currSym = nextSym.clone
            # p "!!!!!#{self}::currSym changed to #{@currSym.sym}", 29
            # if $sc_cur != $sc.currSym.sym
            #          pp("!!!===", 20)
            #      end
            nextSym.init(0, @currLine, @currCol - 1, @buffPos, 0)
            nextSym.len  = 0
             ctx = 0
             # p "get4:#{@ch}"

            if (@ch.to_byte == EOF_CHAR || @ch == nil) 
                return C_EOF_Sym
            end
            
            if !ignore_crlf &&  ( @ch.to_byte == 13|| ch.to_byte == 10)
                p "crlf:#{@ch.to_byte}, pos #{@buffPos}"
                @currSym = nextSym.clone
                nextSym.init(0, @currLine, @currCol - 1, @buffPos, 1)
                nextSym.len  = 1
                 Scan_NextCh()
                return C_CRLF_Sym
            end
            
            state = @@STATE0[@ch.to_byte]
           #   p "--->111ch:#{@ch[0].ord}=#{ch[0]}, #{state}=#{state}", 10
            while(1) 
             #   p "st:#{state}, #{nextSym.len}, #{@ch}, #{@buffer[buffPos]}"
              
              Scan_NextCh()
              # p "ch:#{@ch}, #{@buffer[nextSym.pos+nextSym.len]}, stat #{state}"
              nextSym.len+=1
          #    p "st1:#{state}, #{nextSym.len}, #{@ch}, #{@buffer[buffPos]}"

                if state == 33 &&  (@ch == ' ' || @ch.to_byte == 9) # is '#', support "#   define"
                #    p "bufpos:#{buffPos}"
                    del_start = @buffPos
                    while (@ch == ' ' || @ch.to_byte == 9)
                        Scan_NextCh()
                        nextSym.len+=1
                    end
                    del_end = @buffPos -1
                    str1 = @buffer[0..del_start - 1]
                    str2 = @buffer[del_end + 1..@buffer.size-1]
                 #   p ("#{del_start}, #{del_end}, #{@buffPos}, #{str1}, #{str2}")
                    
                    @buffer = str1 + str2
                    delnum = del_end- del_start+1
                    @buffPos -= delnum
                    @currCol -= delnum
                    nextSym.len -= delnum
                  #  p "after delete333:#{@buffer}"
                end
                
              #  p ("state:#{state}, #{@ch}, #{@ch.to_byte}")
                
              case (state) 
           
              when 1
              	if (@ch >= '0' && @ch <= '9' ||
              	    @ch >= 'A' && @ch <= 'Z' ||
              	    @ch == '_' ||
              	    @ch >= 'a' && @ch <= 'z') 
              	    #;
              	    else
                        # p "C_identifierSym #{CurrentCh(nextSym.pos)}"
              	        return CheckLiteral(C_identifierSym)
             
          	        end
              	#break
              when 2
              	if (@ch == 'U')
                    # state = 5
                    Scan_NextCh()
                    return C_numberSym
              	elsif (@ch == 'u') 
                    # state = 6
                    Scan_NextCh()
                    return C_numberSym
              	elsif (@ch == 'L') 
              	    p "=>L1"
                    # state = 7 
                    Scan_NextCh()
                     if @ch == 'L'
                         Scan_NextCh()
                     end
                     return C_numberSym
              	elsif (@ch == 'l') 
                    # state = 8 
                    Scan_NextCh()
                    return C_numberSym
              	elsif (@ch == '.') 
              	    state = 4 
              	elsif (@ch >= '0' && @ch <= '9') 
              	else
              	    return C_numberSym
          	    end
              	#break
              when 4
              	if (@ch == 'U') 
                    # state = 13 
                    Scan_NextCh()
                    return C_numberSym
              	elsif (@ch == 'u') 
                    # state = 14 
                    Scan_NextCh()
                    return C_numberSym
              	elsif (@ch == 'L')
              	    p "=>L11"
                     # state = 15 
                     Scan_NextCh()
                     if @ch == 'L'
                         Scan_NextCh()
                     end
                     return C_numberSym
              	elsif (@ch == 'l') 
                    # state = 16 
                    Scan_NextCh()
                    return C_numberSym
              	elsif (@ch >= '0' && @ch <= '9') 
              	else
              	    return C_numberSym 
          	    end
              	#break
              when 5
              	return C_numberSym 
              when 6
              	return C_numberSym 
              when 7
              	return C_numberSym 
              when 8
              	return C_numberSym 
              when 13
              	return C_numberSym 
              when 14
              	return C_numberSym 
              when 15
              	return C_numberSym 
              when 16
              	return C_numberSym 
              when 18
              	if (@ch >= '0' && @ch <= '9' ||
              	    @ch >= 'A' && @ch <= 'F' ||
              	    @ch >= 'a' && @ch <= 'f')
              	    state = 19
                else
              	    return C_No_Sym
          	    end
              	#break
              when 19
              	if (@ch == 'U') 
                    # state = 20
                    Scan_NextCh()
                    return C_numberSym
              	elsif (@ch == 'u') 
                    # state = 21
                    Scan_NextCh()
                    return C_numberSym
              	elsif (@ch == 'L') 
              	    p "=>L111"
                    # state = 22
                    Scan_NextCh()
                     if @ch == 'L'
                         Scan_NextCh()
                     end
                     return C_numberSym
              	elsif (@ch == 'l') 
                    # state = 23
                    Scan_NextCh()
                    return C_numberSym
              	elsif (@ch >= '0' && @ch <= '9' ||
              	    @ch >= 'A' && @ch <= 'F' ||
              	    @ch >= 'a' && @ch <= 'f') 
                else
              	    return C_hexnumberSym
                end
              	#break
              when 20
              	return C_hexnumberSym
              when 21
              	return C_hexnumberSym
              when 22
              	return C_hexnumberSym
              when 23
              	return C_hexnumberSym
              when 24
                # p "->111:#{@ch}"
              	if (@ch == '"' )  # if meet second ", then it's string
              	    state = 25
                    # p "->1111:#{@ch}"
          	    elsif @ch == "\\" # using \ for multi lines string
                    Scan_NextCh()
                    if @ch == "\n"
                        nextSym.len+=1
                    else
                        nextSym.len+=1
                    end
                    # p "->112:#{@ch}"
              	elsif (@ch >= ' ' && @ch <= '!' ||
              	    @ch >= '#' && @ch.to_byte <= 255) 
                    # p "->113:#{@ch}"
          	        
              	   # same state
              	else
                    # temperary solution for Chinese string
              	    #return C_No_Sym
              	end
              	#break
              when 25
              	return C_stringD1Sym
              when 26
              	if (@ch >= ' ' && @ch <= '&' ||
              	    @ch >= '(' && @ch <= '[' ||
              	    @ch >= ']' && @ch.to_byte <= 255) 
              	    state = 28
              	elsif (@ch.to_byte == 92) 
              	    state = 36
                else
              	    return C_No_Sym
              	end
              	#break
              when 28
              	if (@ch.to_byte == 39) 
              	    state = 29
              	else
              	    return C_No_Sym
          	    end
              	#break
              when 29
              	return C_charD1Sym
              when 30
                  # p "fdaklfdjlajsdkj-----, ch=#{@ch}, #{currLine}"
                # if (@ch == '.' ||
                #     @ch >= '0' && @ch <= ':' ||
                #     @ch >= 'A' && @ch <= 'Z' ||
                #     @ch.to_byte == 92 ||
                #     @ch >= 'a' && @ch <= 'z') 
                #     state = 31
                # elsif (@ch == '=') 
                if (@ch == '=') 
              	    state = 58
              	elsif (@ch == '<') 
              	    state = 60
          	    else
              	    return C_LessSym
          	    end
              	#break
              when 31 # for librarySym, not used
              	if (@ch == '>')
              	     state = 32
              	elsif (@ch == '.' ||
              	    @ch >= '0' && @ch <= ':' ||
              	    @ch >= 'A' && @ch <= 'Z' ||
              	    @ch.to_byte == 92 ||
              	    @ch >= 'a' && @ch <= 'z') 
              	    # /*same state*/
          	    else
              	    return C_No_Sym
          	    end
              	#break
              when 32
              	return librarySym
              when 33
              	if (@ch >= 'A' && @ch <= 'Z' ||
              	    @ch >= 'a' && @ch <= 'z') 
              	    state = 34
              	elsif (@ch == '#') 
              	    state = 70
              	else
              	    return C_No_Sym
          	    end
              	#break
              when 34
            	if (@ch >= 'A' && @ch <= 'Z' ||
            	    @ch >= 'a' && @ch <= 'z') 
                else
                    return C_PreProcessorSym
                end
              when 35 # number with post: 100L, 100u
              	if (@ch == 'U') 
                    # state = 5
                    Scan_NextCh()
                    return C_numberSym
              	elsif (@ch == 'u') 
                    # state = 6
                    Scan_NextCh()
                    return C_numberSym
              	elsif (@ch == 'L') 
              	    p "=>L133"
                    # state = 7
                    Scan_NextCh()
                     if @ch == 'L'
                         Scan_NextCh()
                     end
                     return C_numberSym
              	elsif (@ch == 'l') 
                    # state = 8
                    Scan_NextCh()
                    return C_numberSym
              	elsif (@ch == '.') 
              	    state = 4
              	elsif (@ch >= '0' && @ch <= '9') 
              	    state = 2
              	elsif (@ch == 'X' ||
              	    @ch == 'x') 
              	    state = 18
              	else
              	    return C_numberSym
          	    end
              	#break
              when 36
              	if (@ch >= ' ' && @ch <= '&' ||
              	    @ch >= '(' && @ch.to_byte <= 255) 
              	    state = 28
              	elsif (@ch == 39) 
              	    state = 29
              	else
              	    return C_No_Sym
          	    end
              	#break
              when 37
              	return C_SemicolonSym
              when 38
              	if (@ch == '=') 
              	    state = 73
          	    else
              	    return C_SlashSym    
          	    end            
              	#break                         
              when 39                        
              	return C_LbraceSym              
              when 40                        
              	return C_RbraceSym              
              when 41                        
              	if (@ch == '=') 
              	    state = 54
              	else
              	    return C_EqualSym
          	    end
              	#break
              when 42
              	return C_CommaSym
              when 43
              	return C_LbrackSym
              when 44
              	return C_RbrackSym
              when 45
              	return C_LparenSym
              when 46
              	return C_RparenSym
              when 47
              	if (@ch == '=') 
              	    state = 72
          	    else
                  	return C_StarSym            
              	end                           
              	#break                         
              when 48                        
              	if (@ch == ':') 
              	    state = 69
          	    else
              	    return C_ColonSym    
          	    end           
              	#break                         
              when 49                        
              	if (@ch == '|') 
              	    state = 50
              	elsif (@ch == '=') 
              	    state = 79
          	    else
                    return C_BarSym
                end
              	#break
              when 50
              	return C_BarBarSym
              when 51
              	if (@ch == '&') 
              	    state = 52
              	elsif (@ch == '=') 
              	    state = 77
          	    else
              	    return C_AndSym
          	    end
              	#break
              when 52
              	return C_AndAndSym
              when 53
              	if (@ch == '=') 
              	    state = 78
              	else
              	    return C_UparrowSym
          	    end
              	#break
              when 54
              	return C_EqualEqualSym
              when 55
              	if (@ch == '=') 
              	    state = 56
          	    else
              	    return C_BangSym   
              	end             
              	#break                         
              when 56                        
              	return C_BangEqualSym           
              when 57                        
              	if (@ch == '=') 
              	    state = 59
              	elsif (@ch == '>') 
              	    state = 61
              	else
              	    return C_GreaterSym
          	    end
              	#break
              when 58
              	return C_LessEqualSym
              when 59
              	return C_GreaterEqualSym
              when 60
              	if (@ch == '=') 
              	    state = 80
          	    else
                    
              	    return C_LessLessSym     
          	    end       
              	#break                         
              when 61                        
              	if (@ch == '=') 
              	    state = 81
          	    else
              	    return C_GreaterGreaterSym      
          	    end
              	#break                         
              when 62                        
              	if (@ch == '+') 
              	    state = 65
              	elsif (@ch == '=') 
              	    state = 75
          	    else
                    return C_PlusSym
                end
              	#break
              when 63 #'-'
              	if (@ch == '-') 
              	    state = 66
          	    elsif (@ch == '>') 
          	        state = 68
              	elsif (@ch == '=') 
              	    state = 76
              	else
              	    return C_MinusSym
          	    end               
              	#break                         
              when 64                        
              	if (@ch == '=') 
              	    state = 74
                else
              	    return C_PercentSym
          	    end
              	#break
              when 65
              	return C_PlusPlusSym
              when 66
              	return C_MinusMinusSym
              when 67
                 if (@ch == '.') 
                    state = 85
                else
                    return C_PointSym
                end
              when 68
              	return C_MinusGreaterSym
              when 69
              	return C_ColonColonSym
              when 70
              	return C_HashHashSym
              when 71
              	return C_DollarSym
              when 72
              	return C_StarEqualSym
              when 73
              	return C_SlashEqualSym
              when 74
              	return C_PercentEqualSym
              when 75
              	return C_PlusEqualSym
              when 76
              	return C_MinusEqualSym
              when 77
              	return C_AndEqualSym
              when 78
              	return C_UparrowEqualSym
              when 79
              	return C_BarEqualSym
              when 80
              	return C_LessLessEqualSym
              when 81
              	return C_GreaterGreaterEqualSym
              when 82
              	return C_TildeSym
              when 83
                  return C_QuestionMarkSym 
              when 84 # parse L"fdasf", which means store every char in 16bit wchar_t, it's only for windows. so we just use normal string
                  if (@ch == '"' || @ch == "'" ) 
                      nextSym.pos+=1
                      nextSym.len-=1
                      
                	  state = 24 if @ch == '"'
                      state = 87 if @ch == "'"
            	  else
            	        state = 1
        	      end
              when 85
                 if @ch == '.'
                     state = 86
                 end
             when 86
                    return C_PPPSym
                when 87
                    # p "->111:#{@ch}"
                  	if ( @ch == "'")  # if meet second ', then it's string,
                  	    state = 25
                        # p "->1111:#{@ch}"
              	    elsif @ch == "\\" # using \ for multi lines string
                        Scan_NextCh()
                        if @ch == "\n"
                            nextSym.len+=1
                        else
                            nextSym.len+=1
                        end
                        # p "->112:#{@ch}"
                  	elsif (@ch >= ' ' && @ch <= '!' ||
                  	    @ch >= '#' && @ch.to_byte <= 255) 
                        # p "->113:#{@ch}"
          	        
                  	   # same state
                  	else
                        # temperary solution for Chinese string
                  	    #return C_No_Sym
                  	end
              else
                   return C_No_Sym
             end #case
        end #while
    end
end


