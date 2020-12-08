class BizEnv
    def GetMainCurrency
    end
end

# global method
def trace(m)
    p m
end
def GNCoinCmp(s1, s2)
    s1.casecmp?(s2)
end

# constant, but has be too implemented by method, because of the naming
def noErr
    1
end

def ao_Arr1
    "JDT1"
end

def ao_Arr2
    "JDT2"
end

def GetEnv()
    if $g_env == nil
        $g_env = BizEnv.new
    end
    return $g_env
end

def GetDataSource
    nil
end

def GetDAG(*args)
    return nil if !$g_data
    p "param1:#{args[0]}"
    if args.size == 0
        args.push(DEFAULT_BO)
    end
        
    dag = Dag.new()
    node = nil
    args.each{|arg|
        found = false
        $g_data.each{|a|
            if a["table"] == arg
                
                a[:sub] = [] 
                if (!node)
                    dag.root = a
                    node = dag.root
                else
                     node[:sub].push(a)
                     node =  node[:sub][0]
                 end
                found = true
            end
        }
        if !found
            p("#{arg} not found")
        end
    }
    p "===>2:"+dag.inspect
    
    return dag

end

def DAG_GetCount(dag, num)
    
end

def ooNoErr 
    0
end

# constant which can be ruby constant directly
JDT = "OJDT" # dummy, not needed
CRD = "OCRD"

OJDT_TRANS_RATE = "TransRate"
OJDT_ORIGN_CURRENCY = "OrignCurr"

DBM_NOT_ARRAY = 1

# settings for this b1 service
DEFAULT_BO = JDT

# data source 
# defined in _AppVals.h
VAL_OBSERVER_SOURCE = "d"
