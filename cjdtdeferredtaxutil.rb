class CJDTDeferredTaxUtil
    def CJDTDeferredTaxUtil(bo)
	
    end
    
    def IsValid()
	
    end
    
    def InitDeferredTaxStatus()
	dagJDT= m_bo.GetDAG(JDT)
	m_dts=@ dts_Invalid
	m_dts=@ dts_Invalid
	m_dts=@ dts_Skip
	m_dts=@ dts_Deferred

    end
    
    def GetDeferredTaxStatus()
	
    end
    
    def SkipValidate()
	
    end
    
    def IsValidDeferredTaxStatus()
	
    end
    
    def IsValidBPLines()
	isValidLine= true
	dagJDT1= m_bo.GetDAG(JDT, ao_Arr1)
	bpLineCount= 0
	recJDT1= dagJDT1.GetRealSize (dbmDataBuffer)
	isValidLine= false

    end
    
    def IsBPWithEqTax()
	
    end
    
    def IsValidDeferredTax()
	
    end
    
    def IsValidOnEqTax()
	
    end
    
    def IsBPWithEqTax(bpCode, bizEnv)
	eqTax== VAL_YES

    end
    

end
