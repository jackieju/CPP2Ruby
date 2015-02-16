load "cr_scan.rb"
load "rubyutility.rb"
class String
    def to_byte
        # self.bytes[0] # not work for ruby 1.8.7
        self[0].ord
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

# Scan_Ch        Ch




           MAX_IDENTIFIER_LENGTH = 1000
class CScanner <  CRScanner
    
    attr_accessor :currLine
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
        # char c

          c =  CurrentCh(nextSym.pos)
         
          # if (IgnoreCase) c = Upcase(c)
          case (c) 
          	when 'b'
          		if (EqualStr("break")) 
          		    return C_breakSym
      		    end
          		#break
          	when 'c'
          		if (EqualStr("class"))
          		     return C_classSym
      		     end
          		return C_charSym if (EqualStr("char")) 
          		return C_caseSym if (EqualStr("case")) 
          		return C_continueSym if (EqualStr("continue"))
          		#break
          	when 'd'
          		return C_doubleSym if (EqualStr("double")) 
          		return C_defaultSym if (EqualStr("default")) 
          		return C_doSym if (EqualStr("do")) 
          		#break
          	when 'e'
          		return C_elseSym if (EqualStr("else")) 
          		return C_EnumSym if (EqualStr("enum")) 
          		
          		#break
          	when 'f'
          		return C_functionSym if (EqualStr("function"))  
          		return C_floatSym if (EqualStr("float"))  
          		return C_forSym if (EqualStr("for")) 
          		#break
          	when 'i'
          		return C_inheritSym if (EqualStr("inherit")) 
                return C_intSym if (EqualStr("int")) 
           		return C_ifSym if (EqualStr("if")) 
          		#break
          	when 'l'
          		return C_loadSym if (EqualStr("load")) 
          		return C_longSym if (EqualStr("long")) 
          		#break
          	when 'm'
          		return C_mySym if (EqualStr("my")) 
          		return C_mixedSym if (EqualStr("mixed")) 
          		#break
          	when 'n'
          		return C_newSym if (EqualStr("new")) 
          		#break
          	when 'p'
          		return C_packageSym if (EqualStr("package")) 
          		#break
          	when 'r'
          		return C_returnSym if (EqualStr("return")) 
          		#break
          	when 's'
          		return C_staticSym if (EqualStr("static")) 
          		return C_shortSym if (EqualStr("short")) 
          		return C_stringSym if (EqualStr("string")) 
          		return C_switchSym if (EqualStr("switch")) 
          		#break
          	when 'u'
          		return C_useSym if (EqualStr("use")) 
          		return C_unsignedSym if (EqualStr("unsigned")) 
          		#break
          	when 'v'
          		return C_varSym if (EqualStr("var")) 
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
    def Comment()
        # int Level, StartLine, OldCol
        #       long OldLineStart
        # p "comment1"
          level = 1
           startLine = @currLine
          oldLineStart = @lineStart
           oldCol = @currCol
          if (@ch == '/') 
          	Scan_NextCh()
          	if (@ch == '*')  
          		Scan_NextCh()
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
                
          		if (@ch == nil || @ch.to_byte == LF_CHAR) 
          		     @currLine-=1
          		      @lineStart = oldLineStart
          		end
          		@buffPos -= 2
          		@currCol = oldCol - 1
          		Scan_NextCh()
          	end 
          end # if (@ch == '/') 
          if (@ch == '/')  
          	Scan_NextCh()
          	if (@ch == '/')  
          		Scan_NextCh()
          		while (1)
                    # p "comment4:level #{level}, ch #{@ch}"
                    
          			if (@ch.to_byte == 10)  
          				level-=1
          				Scan_NextCh()
          				@comEols = @currLine - startLine
          				if(level == 0) 
          				    return 1
      				    end
          			elsif (@ch == nil || @ch.to_byte == EOF_CHAR) 
          			    return 0
          			else
          			    Scan_NextCh()
      			    end
          		end 
          	else  
                # p "comment5"
                
          		if (@ch == nil || @ch.to_byte == LF_CHAR)
          		     @currLine-=1
          		      @lineStart = oldLineStart 
      		     end
          		@buffPos -= 2
          		 @currCol = oldCol - 1
          		  Scan_NextCh()
          	end 
          end  # if (@ch == '/')  

          return 0
    end
public
    def delete_prevline
        # p "-=-->delete_prevline:#{@buffPos}"
        pos = @buffPos
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
        # p "-=-->pos2:#{pos}"
        pos = 0 if pos < 0
        old_size = @buffer.size
        # p "-=-->pos3:#{pos}, #{@buffer[pos].to_byte}"
        
        delete_line(pos)
        # @buffPos -= old_size - @buffer.size
        
    end
    # insert before pos line
    def insert_line(str, pos=nil)
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
    end
    
    
    def delete_curline
        delete_line()
    end
    
    def delete_lines(pos1, pos2, include_last_line=true)
        # pp "===>delete_lines, pos=#{pos1},#{pos2}, @buffPo=#{@buffPos}, buffer=#{@buffer}", 20
        
        replace_start = pos1
        replace_end = pos2-1
        
         # to line start
        while (@buffer[replace_start] != "\n" && @buffer[replace_start] != "\r")
            replace_start -=1
        end
        if include_last_line
            # to line end
            while (@buffer[replace_end] != "\n" && @buffer[replace_end] != "\r")
                replace_end +=1
            end
        else
            while (@buffer[replace_end] == "\n" || @buffer[replace_end] == "\r")
                replace_end -=1
            end
            while (@buffer[replace_end] != "\n" && @buffer[replace_end] != "\r" && @buffer[replace_end] !=nil)
                replace_end -=1
            end            
        end
        

        p "replace_start=#{replace_start}, replace_end=#{replace_end}"
        
        if replace_end > replace_start       
        
            #calculate line
            line_count_before_pos = 0
            if @buffPos > replace_start && @buffPos < replace_end
                i = replace_start
                i = 0 if i < 0
                while (i < @buffPos)
                    i +=1
                    line_count_before_pos += 1 if cch() == "\n"
                end
            end
            line_count=0
            i = replace_start
            i = 0 if i < 0
            while (i < replace_end)
                i +=1
                line_count += 1 if cch() == "\n"
            end
        
        
        
            str1 = ""
            if replace_start >= 0 
                str1 = @buffer[0..replace_start]
            end
            old_buffer_size = @buffer.size
            @buffer = "#{str1}#{@buffer[replace_end..@buffer.size-1]}"
            # if include_last_line
            #     @buffPos = replace_start
            # else
            #     @buffPos -= (old_buffer_size - @buffer.size )
            # end
             if @buffPos > replace_start# &&  @buffPos <replace_end
                if replace_start < 0
                    @buffPos = -1
                else
                    @buffPos = replace_start-1
                end
                if @buffPos >= replace_end
                    @currLine -= line_count
                    @lineStart -= (old_buffer_size-@buffer.size)
                end
                if @buffPos < replace_end
                    @currCol = 0
                    @currLine -= line_count_before_pos
                end
                Reset(@buffPos, @currLine, @lineStart, @currCol)
            end
        end
        
        
        # pp "===>delete_lines2, pos=#{pos1},#{pos2}, @buffPo=#{@buffPos}, buffer=#{@buffer}", 20 
    end
    
    def delete_line(pos=nil)
        pp "===>delete_line, pos=#{pos}, @buffPos=#{@buffPos}, buffer=#{@buffer}", 20
        pos = @buffPos if pos == nil
        # replace_start is excluded, replace_end is excluded
        replace_start = pos-1 
        replace_start = 0 if replace_start < 0
        replace_end = pos
        # to line start
        if @buffer[replace_start] == "\r" 
            replace_start -=1
        end
        if @buffer[replace_start] == "\n" 
            replace_start -=1
        end

        #move replace_start before the first pos which will be replaced
        while (@buffer[replace_start] && @buffer[replace_start] != "\n" && @buffer[replace_start] != "\r" )
            replace_start -=1
        end
        
        # to line end
        p "==>replace_end=#{replace_end}"
        while (@buffer[replace_end] && @buffer[replace_end] != "\n" && @buffer[replace_end] != "\r" )
            replace_end +=1
        end
        if replace_end == "\n"
            replace_end +=1
        end
        if replace_end == "\r"
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
        p "replace_start=#{replace_start}, replace_end=#{replace_end}, #{@buffer[replace_start+1..replace_start+15]}"
        # p "str1=#{str1}"
        # p "str2=#{@buffer[replace_end..@buffer.size-1]}"    
        old_size = @buffer.size   
        str = str1+@buffer[replace_end..@buffer.size-1]
        @buffer=str
        
        if @buffPos > replace_start# &&  @buffPos <replace_end
            if replace_start < 0
                @buffPos = -1
            else
                @buffPos = replace_start-1
            end
            if @buffPos >= replace_end
                @currLine = @currLine-1
                @lineStart -= (old_size-@buffer.size)
            end
            if @buffPos < replace_end
                @currCol = 0
            end
            Reset(@buffPos, @currLine, @lineStart, @currCol)
        end
        
        # p "new buffer after delete current line: #{@buffer[pos..@buffer.size-1]}"
        p "===>delete_line1:pos=#{@buffPos}, ch=#{@ch}, #{@buffer[@buffPos..@buffPos+10]},buffer:#{@buffer}"
        # p "pos:#{@buffPos}"
    end
    def include_file(fname)
        ret = true
        path = find_file(fname)
        c = read_file(path) if path
        p "read file #{path}, return #{c}"
        # if c == nil #|| c == ""
        #     delete_curline
        #     return false
        # end
        
        if c == nil
           c = "\# include file #{fname} failed"
           ret = false
        else
           c = "\# included from file #{fname}\n#{c}"   
        end
        # p "===>432q42#{@buffer[@buffPos..@buffer.size-1]}"
        replace_start = @buffPos-1
        replace_end = @buffPos
        while (@buffer[replace_start] != "\n" && @buffer[replace_start] != "\r")
            replace_start -=1
        end
        # p "===>432q42#{@buffer[replace_start..@buffer.size-1]}"
        while (@buffer[replace_end] != "\n" && @buffer[replace_end] != "\r")
            replace_end +=1
        end
        while @buffer[replace_end] == "\n" || @buffer[replace_end] == "\r"
            replace_end +=1
        end
        # p "3, replace_start=#{replace_start}, @buffPos=#{@buffPos}"
        # p "c:#{c}"
        # p "str1:#{@buffer[0..replace_start]}"
        # p "str2:#{@buffer[@buffPos..@buffer.size-1]}"
        if replace_start < 0
            str = c+@buffer[@buffPos..@buffer.size-1]
            @buffPos = 0
        else
            str = @buffer[0..replace_start]+c+@buffer[@buffPos..@buffer.size-1]
            @buffPos = replace_start
        end
        
        # p "new buffer after include: #{@buffer[@buffPos..@buffer.size-1]}"
        @buffer=str
        
        p "pos1:#{@buffPos}"
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
    def Get()
        # int state, ctx
  
        
        return C_EOF_Sym if @ch == nil
        
         begin
            return C_EOF_Sym if @ch == nil
            while (@ch.to_byte >= 9 && @ch.to_byte <= 10 ||
                   @ch.to_byte == 13 ||
                   @ch == ' ')
                    Scan_NextCh()
                    return C_EOF_Sym if @ch == nil 
            end
        end while ((@ch == '/') && Comment()==1) 
        # p "get1:#{@ch}"
        # if $sc_cur != $sc.currSym.sym
        #     pp("!!!===", 20)
        # end
            @currSym = nextSym
            # p "!!!!!#{self}::currSym changed to #{@currSym.sym}", 29
            # if $sc_cur != $sc.currSym.sym
            #          pp("!!!===", 20)
            #      end
            nextSym.init(0, @currLine, @currCol - 1, @buffPos, 0)
            nextSym.len  = 0
             ctx = 0
             # if $sc_cur != $sc.currSym.sym
             #     pp("!!!===", 20)
             # end
            if (@ch == EOF_CHAR || @ch == nil) 
                return C_EOF_Sym
            end
            state = @@STATE0[@ch.to_byte]
            while(1) 
              Scan_NextCh()
              nextSym.len+=1
              case (state) 
           
              when 1
              	if (@ch >= '0' && @ch <= '9' ||
              	    @ch >= 'A' && @ch <= 'Z' ||
              	    @ch == '_' ||
              	    @ch >= 'a' && @ch <= 'z') 
              	    #;
              	    else

              	        return CheckLiteral(C_identifierSym)
             
          	        end
              	#break
              when 2
              	if (@ch == 'U')
              	    state = 5
              	elsif (@ch == 'u') 
              	    state = 6
              	elsif (@ch == 'L') 
              	    state = 7 
              	elsif (@ch == 'l') 
              	    state = 8 
              	elsif (@ch == '.') 
              	    state = 4 
              	elsif (@ch >= '0' && @ch <= '9') 
              	else
              	    return C_numberSym
          	    end
              	#break
              when 4
              	if (@ch == 'U') 
              	    state = 13 
              	elsif (@ch == 'u') 
              	    state = 14 
              	elsif (@ch == 'L')
              	     state = 15 
              	elsif (@ch == 'l') 
              	    state = 16 
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
              	    state = 20
              	elsif (@ch == 'u') 
              	    state = 21
              	elsif (@ch == 'L') 
              	    state = 22
              	elsif (@ch == 'l') 
              	    state = 23
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
              	if (@ch == '"') 
              	    state = 25
              	elsif (@ch >= ' ' && @ch <= '!' ||
              	    @ch >= '#' && @ch.to_byte <= 255) 
              	else
              	    return C_No_Sym
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
              	if (@ch == '.' ||
              	    @ch >= '0' && @ch <= ':' ||
              	    @ch >= 'A' && @ch <= 'Z' ||
              	    @ch.to_byte == 92 ||
              	    @ch >= 'a' && @ch <= 'z') 
              	    state = 31
              	elsif (@ch == '=') 
              	    state = 58
              	elsif (@ch == '<') 
              	    state = 60
          	    else
              	    return C_LessSym
          	    end
              	#break
              when 31
              	if (@ch == '>')
              	     state = 32
              	elsif (@ch == '.' ||
              	    @ch >= '0' && @ch <= ':' ||
              	    @ch >= 'A' && @ch <= 'Z' ||
              	    @ch.to_byte == 92 ||
              	    @ch >= 'a' && @ch <= 'z') 
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
              	return C_PreProcessorSym
              when 35
              	if (@ch == 'U') 
              	    state = 5
              	elsif (@ch == 'u') 
              	    state = 6
              	elsif (@ch == 'L') 
              	    state = 7
              	elsif (@ch == 'l') 
              	    state = 8
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
              when 63
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
              	return C_PointSym
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

              else
                   return C_No_Sym
             end #case
        end #while
    end
end
