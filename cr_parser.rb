load 'log.rb'
class Scope
    attr_accessor :name, :vars
    def initialize(name)
        @name = name
        @vars = {}
    end

end
class CRParser 
# Abstract Parser
  public
    def initialize(s = nil, e = nil)
        if (!e || !s) 
          p "CRParser::CRParser: No Scanner or No Error Mgr\n"
          exit(1)
        end
        @scanner = s
        @error = e
        @sym = 0
        @sstack = [] # scope stack
        p "haha"
    end
    
    def canUseBreak?
        i = @sstack.size-1
        while (i>=0)
            if @sstack[i].name == "FunctionBody" 
                return false
            end
            
            if  @sstack[i].name == "ForStatement" || @sstack[i].name == "WhileStatement" || @sstack[i].name == "DoStatement"
                return true
            end
            i -= 1
        end
        return false
        
    end
    
    
    # Constructs abstract parser, and associates it with scanner S and
    # customized error reporter E

    def CRParser
        p("Abstract CRParser::Parse() called\n")
        exit(1)
        
    end

    def Parse()
        
    end
    # Abstract parser

    def SynError(errorNo)
        if (errorNo <= @error.MinUserError) 
            errorNo = @error.MinUserError
        end    
        @error.StoreErr(errorNo, @scanner.nextSym)
             
    end
    # Records syntax error ErrorNo

    def SemError(errorNo)
        if (errorNo <= @error.MinUserError)
             errorNo = @error.MinUserError
         end
        @error.StoreErr(errorNo, @scanner.CurrSym)
    end
    # Records semantic error ErrorNo


	

  protected

    def Get()
        p "get"
    end
    
    def In(symbolSet, i)
        return symbolSet[i / NSETBITS] & (1 << (i % NSETBITS))
        
    end
    
    def Expect(n)
        p "expect #{SYMS[n]}, sym = #{@sym}, line #{@scanner.nextSym.line} col #{@scanner.nextSym.col} pos #{@scanner.nextSym.pos} sym #{SYMS[@scanner.nextSym.sym]}"
        if @sym == n 
            Get()
        else 
            GenError(n)
        end
    end
    
    def GenError(errorNo)
        p "error #{errorNo}, line #{@scanner.nextSym.line} col #{@scanner.nextSym.col} sym #{@scanner.nextSym.sym} val #{@scanner.GetName()}"
        p "line:#{@scanner.cur_line()}"
        p("stack:", 30)
        @error.StoreErr(errorNo, @scanner.nextSym.clone)
    end
    # Scanner
    #    Error
    #    Sym

end