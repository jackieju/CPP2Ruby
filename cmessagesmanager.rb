class CMessagesManager
def GetHandle()->Message(_1_APP_MSG_FIN_OO_TRANSACTION_NOT_BALANCED, EMPTY_STR, ()
	_TRACER("CompleteVatLine")
	ooErr=noErr
	
	
	
	
	
	
	
	
	
	dateStr=""
	
	
	
	
	bizEnv=GetEnv()
	
	
	
	
	
	dagJDT=GetDAG(JDT)
	dagJDT1=GetDAG(JDT,ao_Arr1)
	dagACT=GetDAG(ACT)
	dagVTG=GetDAG(VTG)
	dagJDT.GetColStr(stampTax,OJDT_STAMP_TAX,0)
	if stampTax[0]==VAL_YES[0]
	    if bizEnv.IsVatPerLine()
	    if GetDataSource()==*VAL_OBSERVER_SOURCE
	    return ComplateStampLine()
	
	else
	    return ooNoErr
	
	end
	
	
	else
	    return ooErrNoMsg
	
	end
	
	
	end
	
	_STR_strcpy(localCurr,bizEnv.GetMainCurrency())
	_STR_strcpy(sysCurr,bizEnv.GetSystemCurrency())
	DAG_GetCount(dagJDT1,&numOfRecs)
	if bizEnv.IsVatPerLine()||bizEnv.IsVatPerCard()
	    dagJDT.GetColStr(tmpStr,OJDT_AUTO_VAT,0)
	if tmpStr[0]==VAL_YES[0]
	    if GetDataSource()==*VAL_OBSERVER_SOURCE
	    rec=0
	begin
	    
	    
	    
	end while (rec)
	
	
	end
	
	
	end
	
	
	end
	

end
    

end
