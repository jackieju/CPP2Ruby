class CBusinessObject
    
    def save
    end
    def Create ( doAutoComplete = false,  cep = nil)
        # before_create
        # after_create
        # ...
    end
    alias :Create :save
end
class CSystemBusinessObject < CBusinessObject
    def initialize(id, env)
    end
    def InitData()
    end
end

class BObject < CSystemBusinessObject
    def context
        @context = {} if @context == nil
        @context
    end
    def initilize(context)
        
    end

end