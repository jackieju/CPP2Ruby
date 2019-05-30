class Dag

    attr_accessor :root
    def initialize()
        @root = {
            :sub=>[]
        }
    end
    
    #def initialize(ar) # suppose an array
    #    @data = ar
    #    p "==>1:"+@data.class.name
    #end
    
    def GetColMoney(money, column, recordOffset, p3)
        if column.class != String
            # convert to string (column name)
        end

        column = @root["data"][recordOffset][column]
        p "find col for money:#{column.inspect}"
        
    
        return 
    end
    
    def GetColStr(str, column, recordOffset)
        if column.class != String
            # convert to string (column name)
        end

        p @root.inspect
        v = @root["data"][recordOffset][column]
        p "find col for str:#{column.inspect}"
        i=0
        v.each_char{|c|
            str[i] = c
            i +=1
        }
        
    end
    
    def root
        @root
    end
end