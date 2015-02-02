load 'log.rb'
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
        p "haha"
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
        p "expect #{n}, sym = #{@sym}, line #{@scanner.nextSym.line} col #{@scanner.nextSym.col} pos #{@scanner.nextSym.pos} sym #{@scanner.nextSym.sym}"
        if @sym == n 
            Get()
        else 
            GenError(n)
        end
    end
    
    def GenError(errorNo)
        p "error #{errorNo}, line #{@scanner.nextSym.line} col #{@scanner.nextSym.col} sym #{@scanner.nextSym.sym}"
        p("stack:", 30)
        @error.StoreErr(errorNo, @scanner.nextSym)
    end
    # Scanner
    #    Error
    #    Sym

end