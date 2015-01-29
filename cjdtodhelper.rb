class CJdtODHelper
    def CJdtODHelper(m_bo(bo)
	
    end
    
    def ODRefDateChange()
	ooErr=@ noErr
	objId= m_bo.GetID ().strtol ()
	dagJDT= m_bo.GetDAG(objId, ao_Main)
	refDateStr= tmpDate.GetString ()
	pManager= bizEnv.GetSupplCodeManager()
	ooErr= pManager.LoadDfltCodeToDag (m_bo, Date(refDateStr.GetBuffer()))

    end
    
    def ODMemoChange()
	ooErr=@ noErr
	objId= m_bo.GetID ().strtol ()
	dagJDT= m_bo.GetDAG(objId, ao_Main)
	dagJDT1= m_bo.GetDAG(objId, ao_Arr1)
	jdt1Rec= dagJDT1.GetRealSize (dbmDataBuffer)

    end
    

end
