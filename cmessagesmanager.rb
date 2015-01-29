class CMessagesManager
    def GetHandle()->Message(_1_APP_MSG_FIN_OO_TRANSACTION_NOT_BALANCED, EMPTY_STR, ()
	ooErr=@ noErr
	bizEnv= GetEnv ()
	dagJDT= GetDAG (JDT)
	dagJDT1= GetDAG(JDT, ao_Arr1)
	dagACT= GetDAG (ACT)
	dagVTG= GetDAG(VTG)
	ooErr= bizEnv.GetByOneKey (dagACT, OACT_KEYNUM_PRIMARY, actNum, true)
	debitSide=@ TRUE
	debitSide=@ FALSE
	ooErr= GetTaxAdaptor()->CalcTaxWithManualUpdate()
	EnforceBalance= false
	EnforceBalance= true
	found= false
	found= true
	found= true
	found= true
	found= true
	creditSide=@ TRUE
	debitSide=@ TRUE
	ooErr= GetTaxAdaptor()->ConvertJDTDagToTaxData()

    end
    

end
