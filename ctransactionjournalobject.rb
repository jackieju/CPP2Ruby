class CTransactionJournalObject
    def ValidateRelations(ArrOffset, rec, field, object, showError)
	dag=	GetDAG(JDT,ArrOffset)
	bizEnv= GetEnv ()
	isVat=@ FALSE
	condNum= 1
	isVat=@ TRUE
	count= DBD_Count (dag, TRUE)

    end
    
    def CalculationSystAmmountOfTrans()
	ooErr=@ ooNoErr
	dagJDT=@ NULL
	dagJDT1=@ NULL
	forceBalance= true
	prevCurr= {0}
	bizEnv= GetEnv ()
	dagJDT= GetDAG()
	dagJDT1= GetDAG(JDT, ao_Arr1)
	multiFrgCurr= false
	frgCurr= false
	getOnlyFromLocal= false
	notTranslateToSys= false
	hasOneFrgCurr= false
	notTranslateToSys= true
	getOnlyFromLocal= true
	getOnlyFromLocal= true
	vatFound= true
	getOnlyFromLocal= true
	multiFrgCurr= true
	getOnlyFromLocal= true
	getOnlyFromLocal= true
	forceBalance= false
	forceBalance= false
	sideOfDebit= true
	frgCurr= false
	frgCurr= true
	sideOfDebit= false
	systMoney=@ tmpMoney
	hasOneFrgCurr= true
	ooErr= GNTranslateToSysAmmount (&tmpMoney, currStr, refDate, &systMoney, bizEnv)

    end
    
    def CalculationFrnAmmounts(dagACT, dagCRD, found)
	ooErr=@ noErr
	dagJDT=@ NULL
	dagJDT1=@ NULL
	mainCurr= {0}
	frnCurr= {0}
	needFC= false
	bpFC= false
	bizEnv= GetEnv ()
	dagJDT= GetDAG ()
	ooErr= dagJDT.GetColLong(&transCode, OJDT_TRANS_TYPE, 0)
	dagJDT1= GetDAG (JDT, ao_Arr1)
	bpFC= false
	dagCRD= GetDAG (CRD)
	ooErr= dagCRD.GetByKey (shortName)
	ooErr= (dbmNoDataFound == ooErr) ? ooInvalidCardCode : ooErr
	bpFC= GNCoinCmp (bpCurr, BAD_CURRENCY_STR) ? true : false
	multiACT= false
	dagACT= GetDAG (ACT)
	ooErr= dagACT.GetByKey (accName)
	ooErr= (dbmNoDataFound == ooErr) ? ooInvalidAcctCode : ooErr
	multiACT= !GNCoinCmp (actCurr, BAD_CURRENCY_STR)
	tLineCurr=@ bpCurr
	tLineCurr= multiACT ? mainCurr : actCurr
	lineCurr=@ tLineCurr
	uLineCurr=@ gCurr
	uLineCurr=@ lineCurr
	colIndex=@ JDT1_FC_CREDIT
	colIndex=@ JDT1_FC_DEBIT
	ooErr= GNLocalToForeignRate (&money, frnCurr, dateStr, 0.0, &frnAmnt, bizEnv)
	found= true
	ooErr= GNCheckCurrencyCode (bizEnv, currLine, &exist)
	crNull= dagJDT1.IsNullCol (JDT1_FC_CREDIT, rec)
	dbNull= dagJDT1.IsNullCol (JDT1_FC_DEBIT, rec)
	oneValue= false
	remFC= false
	oneValue= true
	oneValue= true
	remFC= money.IsZero ()
	remFC= money.IsZero ()

    end
    
    def IsCurValid(crnCode, dagCRN)
	bizEnv= GetEnv ()
	ooErr= GNCheckCurrencyCode (bizEnv, crnCode, &exist)

    end
    
    def IsPaymentBlockValid(dagJDT1, rec)
	isAcctLine= false
	isBlockReasonDfltValue= false
	isAcctLine= (acctCode == shortName)
	isBlockReasonDfltValue= (((SBOString)NONE_CHOICE == strBlockReason)
	ooErr= ValidateRelations (ao_Arr1, rec, JDT1_PAYMENT_BLOCK_REF, PYB)

    end
    
    def CTransactionJournalObject(id, env)
	
    end
    
    def CTransactionJournalObject(id, bizObject, onlyPaymentCateg, objInfo, dagObj, dagWTaxs, dagOBJ, dagObjWTax, dag, callerFormPtr, linkReturnProc, bizObject, currentMoney, bizObject, rec, bizObject, blockLevel, testMoney, testYearMoney, testTmpM, testYearTmpM, bizObject, acctCode, Sum, refDate, budgetAllYes, dagJDT, byRef, rec, month, dateStr, month, bizEnv, env, dagJDT, dagJDT1, bizObject, updateBgtPtr, dagDOC1, bizObject, bizObject, bizObject, dagJDT1, paymentObject, dagJDT1, resDagFields, fromOffset, dag, resDagFields, bizObject, curSource, bizObject, bizObject, bizEnv, transId, transtype, createdby, bizEnv, bizObject, bizEnv, dagACT, dagJDT, dagJDT, dagJDT, line, absEntry, MonthmoneyStr, YearmoneyStr, acctKey, messgNumber, bizEnv, transId, dagJdt1, firstRec, maxRec, contraDebKey, contraCredKey, contraDebLines, ()
	
    end
    
    def SetJournalKeys(jrnlKeys)
	m_jrnlKeys=@ jrnlKeys

    end
    
    def GetJournalKeys(void)
	
    end
    
    def GetSeqParam(GetTaxAdaptor()
	
    end
    
    def OnGetTaxAdaptor(stornoExtraInfoCreator)
	@m_stornoExtraInfoCreator = @ stornoExtraInfoCreator
    end
    
    def SetToZeroNullLineTypeCols(dagQuery, dagRes, object, dagRes, object, pParentDAG, lParentRow, pParentDAG, lParentRow, pParentDAG, pDAG, lRow, pParentDAG, lParentRow, objectId, postingDate=EMPTY_STR, taxDate=EMPTY_STR, bizEnv, sCancelDate, dagOBJ, dagJDT, dagJDT1, taxDate, dueDate, cancelMode, {JDT1_OCR_CODE, JDT1_OCR_CODE2, JDT1_OCR_CODE3, JDT1_OCR_CODE4, (ocrColumn)
	
    end
    
    def GetValidFromCol({JDT1_VALID_FROM, JDT1_VALID_FROM2, JDT1_VALID_FROM3, JDT1_VALID_FROM4, ()
	
    end
    
    def GetWTBaseNetAmountField(curr)
	column=@ OJDT_WT_BASE_AMOUNT
	column=@ OJDT_WT_BASE_AMOUNT_SC
	column=@ OJDT_WT_BASE_AMOUNT_FC

    end
    
    def IsPostingPreviewMode()
	
    end
    
    def GetLinkMapMetaData(el)
	ooErr= CBusinessObjectBase::GetLinkMapMetaData (el)
	dagJDT= GetDAG ()
	ooErr= AddLinkMapIconMetaData (el, dagJDT, OJDT_PRINTED, VAL_YES, LinkMap::ILMVertex::imdPrinted, LINKMAP_ICONSTR_PRINTED)
	ooErr= AddLinkMapStringMetaData (el, dagJDT, OJDT_NUMBER)
	ooErr= AddLinkMapStringMetaData (el, dagJDT, OJDT_REF_DATE)
	ooErr= AddLinkMapStringMetaData (el, dagJDT, OJDT_MEMO)

    end
    
    def GetIsPostingTemplate()
	
    end
    
    def OnIsValid(bizEnv, canArchiveStmt, archiveDate, (other), ())
	
    end
    
    def OJDTFillJDT1FromAccounts(accountsArrayFrom, accountsArrayRes, updateCardBalanceCond, cardCode, startingRec, tableStruct, numOfConds, iterationType, numOfTables, condStruct, joinCondStructForOtherObj, numOfBPfound, dagRes, subParams, subResStruct, subTableStruct, subCond, dag, col, paidSum, paidSumInLocal, transRowId, wtAllCurBaseCalcParamsPtr, currSource, dagDOC, wtInfo, currSource, dagDOC, currSource, currSource, dagJDT1, jdt1RecSize, dagJDT2, rec, isDebit, dagJDT1, jdt1CurRow, dagJDT2, jdt2CurRow, isDebit, wtAcctCode, transId, objectMap, inAccount, inShortName, inRef3Line, objectId, docNum, mdrObj, dagJDT1, rec, mat_type)
	
    end
    
    def UpgradeDOC6VatPaidForFullyBasedCreditMemos(objID)
	ooErr=@ noErr
	env= GetEnv()
	tOdoc= updStmt.Update(env.ObjectToTable (objID, ao_Main))
	ooErr= e.GetCode()

    end
    
    def UpgradeODOCVatPaidForFullyBasedCreditMemos(objID)
	ooErr=@ noErr
	env= GetEnv()
	ooErr= e.GetCode()

    end
    
    def RepairEquVatRateOfJDT1()
	ooErr=@ ooNoErr
	ooErr= RepairEquVatRateOfJDT1ForOneObject (objectId[i])

    end
    
    def RepairEquVatRateOfJDT1ForOneObject(objectId)
	ooErr=@ ooNoErr
	major= versionStr.Left (1)
	minor= versionStr.Mid (1, 2)
	build= versionStr.Right (3)
	versionStr= major + _T(".") + minor + _T(".") + build + _T(".*")
	dagRes=@ NULL
	dagQuery= GetEnv ().OpenDAG (JDT, ao_Arr1)
	ooErr= dagQuery.GetFirstChunk (UPG_JDT1_EQUVATRATE_CHUNK_SIZE, key, &dagRes)
	ooErr= UpdateIncorrectEquVatRate (dagRes)
	ooErr= dagQuery.GetNextChunk (UPG_JDT1_EQUVATRATE_CHUNK_SIZE, key, &dagRes)
	ooErr=@ ooNoErr

    end
    
    def UpdateIncorrectEquVatRate(dagRes)
	ooErr=@ ooNoErr
	rec= dagRes.GetRecordCount () - 1
	ooErr= UpdateIncorrectEquVatRateOneRec (dagRes, rec)

    end
    
    def UpdateIncorrectEquVatRateOneRec(dagRes, rec)
	ooErr=@ ooNoErr
	dagJDT1= GetEnv ().OpenDAG (JDT, ao_Arr1)
	ooErr= DBD_UpdateCols (dagJDT1)

    end
    
    def InitDataReport340(dagJDT)
	sboErr=@ ooNoErr
	bizEnv= GetEnv ()

    end
    
    def CompleteReport340(dagJDT, dagJDT1)
	sboErr=@ ooNoErr
	bizEnv= GetEnv ()
	dagCRD= GetDAG (CRD)
	atLeasOneBPFound= false
	numOfRecs= dagJDT1.GetRealSize (dbmDataBuffer)
	atLeasOneBPFound= true

    end
    
    def ValidateReport340()
	sboErr=@ ooNoErr
	bizEnv= GetEnv ()
	dagJDT= GetDAG ()

    end
    
    def HandleFCExchangeRounding(dagJDT1, StdMap<SBOString, FCRoundingStruct, False, currencyMap)
	size= dagJDT1.GetRecordCount()
	roundingStruct= itr.second

    end
    
    def UpgradeFederalTaxIdOnJERow()
	bizEnv= GetEnv ()
	TransType=@ JDT
	tOCRD= stmt.Join (bizEnv.ObjectToTable (CRD, ao_Main), tJDT1, DBQ_JT_INNER_JOIN)
	tCRD1= stmt.Join (bizEnv.ObjectToTable (CRD, ao_Arr1), tOCRD, DBQ_JT_LEFT_OUTER_JOIN)
	countRes= stmt.Execute (dagRes)
	crdTaxID=@ EMPTY_STR
	ShortName=@ cardCode
	tOINV= ustmt.Update (bizEnv.ObjectToTable (objArray[objNum], ao_Main))

    end
    
    def UpgradeDprId(isSalesObject, introVersion1_Including, introVersion2)
	sboErr=@ ooNoErr
	env= GetEnv ()
	paymentObjType= isSalesObject ? RCT : VPM
	dpmObjType= isSalesObject ? DPI : DPO
	countRes= 0
	tORCT= stmt.From (env.ObjectToTable (paymentObjType, ao_Main))
	tRCT2= stmt.Join (env.ObjectToTable (paymentObjType, ao_Arr2), tORCT)
	major= versionStr.Left (1)
	minor= versionStr.Mid (1, 2)
	build= versionStr.Right (3)
	versionStr= major + _T(".") + minor + _T(".") + build;// + _T(".*")
	countRes= stmt.Execute (dagRES)
	sboErr= UpdateDprIdOnJERow(paymentObjType, dagRES)

    end
    
    def UpgradeDprIdForOneDprPayment(isSalesObject, introVersion)
	sboErr=@ ooNoErr
	env= GetEnv ()
	paymentObjType= isSalesObject ? RCT : VPM
	dpmObjType= isSalesObject ? DPI : DPO
	countRes= 0
	tORCT= stmt.From (env.ObjectToTable (paymentObjType, ao_Main))
	tRCT2= stmt.Join (env.ObjectToTable (paymentObjType, ao_Arr2), tORCT)
	major= versionStr.Left (1)
	minor= versionStr.Mid (1, 2)
	build= versionStr.Right (3)
	versionStr= major + _T(".") + minor + _T(".") + build;// + _T(".*")
	countRes= stmt.Execute (dagRES)
	sboErr= UpdateDprIdOnJERow(paymentObjType, dagRES)

    end
    
    def UpdateDprIdOnJERow(paymentObjType, dagRES)
	sboErr=@ ooNoErr
	env= GetEnv ()
	countRes= dagRES.GetRealSize(dbmDataBuffer)
	tJDT1= ustmt.Update (env.ObjectToTable (JDT, ao_Arr1))

    end
    
    def UpgradeWorkOrderStep1(cenvat)
	
    end
    
    def ValidateHeaderLocation(isInCancellingAcctRecon, bpBalanceLogDataArray, true)
	@m_bZeroBalanceDue = @ set
    end
    
    def IsZeroBalanceDueForCentralizedPayment()
	
    end
    
    def CreateObject(id, env)
	
    end
    
    def CTransactionJournalObject(id, (id, env), (env)
	m_isVatJournalEntry= false
	m_taxAdaptor=@ NULL
	m_stornoExtraInfoCreator=@ NULL
	m_reconcileBPLines= true
	m_pSequenceParameter=@ NULL
	m_isInCancellingAcctRecon= false
	m_isPostingPreviewMode= false
	m_isPostingTemplate= false

    end
    
    def ~CTransactionJournalObject()
	m_pSequenceParameter=@ NULL

    end
    
    def CompleteKeys()
	dbErr=@ ooNoErr
	dbErr= CSystemBusinessObject::CompleteKeys()
	dagJDT1= GetDAG (JDT, ao_Arr1)
	dagCRD= GetDAG (CRD)
	dagACT= GetDAG (ACT)
	jeLinesCount= dagJDT1.GetRealSize (dbmDataBuffer)
	shortName= dagJDT1.GetColStr(JDT1_SHORT_NAME, rec, -1)
	dbErr= GetEnv().GetByOneKey (dagCRD, OCRD_KEYNUM_PRIMARY, shortName)
	dbErr= GetEnv().GetByOneKey (dagACT, OACT_KEYNUM_PRIMARY, shortName)

    end
    
    def OnCreate()
	ooErr=@ noErr
	blockLevel=0
	typeBlockLevel=0
	recCount= 0
	ii= 0
	RetVal= 0
	lastContraRec= 0
	contraCredLines= 0
	contraDebLines= 0
	monSymbol={0}
	AlrType
	balanced=@ FALSE
	budgetAllYes=@ FALSE
	fromImport=@ FALSE
	bizEnv= GetEnv ()
	qc=@ TRUE
	qc=@ FALSE
	dagJDT= GetDAG()
	dagJDT1= GetDAG(JDT, ao_Arr1)
	dagJDT2= GetDAG(JDT, ao_Arr2)
	dagCRD= GetDAG (CRD)
	transType=@ JDT
	isDeferredTax= (deferredTax == VAL_YES)
	itsCard= (_STR_stricmp (acctKey, cardKey) != 0) && (!_STR_IsSpacesStr (cardKey))
	ooErr= bizEnv.GetByOneKey (dagCRD, GO_PRIMARY_KEY_NUM, cardKey, true)
	ooErr= bizEnv.GetByOneKey (GetDAG(ACT), GO_PRIMARY_KEY_NUM, acctKey, true)
	dimentionLen= VF_CostAcctingEnh(GetEnv()) ? DIMENSION_MAX : 1
	dagAct= GetDAG(ACT)
	ooErr= COverheadCostRateObject::GetValidFrom (bizEnv, ocrCode, postDate, validFrom)
	balanced=@ FALSE
	fTransTotalDebChk== fTransTotalCredChk &&
	contraDebLines= contraCredLines = 0
	lastContraRec= rec+1
	transTotalDebChk= transTotalCredChk = fTransTotalDebChk = fTransTotalCredChk = sTransTotalDebChk = sTransTotalCredChk = 0L
	zeroBalanceDue= false
	zeroBalanceDue= true
	isVatLine= (vatLine == VAL_YES)
	regNo= bizEnv.GetNextRegNum (location, RG23APart2, TRUE)
	regNo= bizEnv.GetNextRegNum (location, RG23CPart2, TRUE)
	isNeedToFree= SetDAG ( NULL, false, JDT, ao_Arr1 )
	isNeedToFree2= SetDAG(NULL, false, JDT, ao_Arr2)
	seqManager= bizEnv.GetSequenceManager ()
	ooErr= seqManager.HandleSerial (*this)
	pManager= bizEnv.GetSupplCodeManager()
	ooErr= pManager.CodeChange(*this, PostDate)
	ooErr= pManager.CheckCode(*this)
	ooErr= GORecordHistProc (*this, dagJDT)
	dagCFT= GetDAGNoOpen(objCFTId)
	bo= static_cast<CCashFlowTransactionObject*>(CreateBusinessObject(CFT))
	ooErr= bo.OCFTCreateByJDT (GetDAG(CFT), transAbs, dagJDT1)
	ooErr= PutSignature (dagJDT1)
	ooErr= CWarehouseTransferObject::LinkVatJournalEntry2WTR (bizEnv, wtrKey, vatJournalKey)
	numOfJDT2= dagJDT2.GetRecordCount()
	bizFlow= GetCurrentBusinessFlow()
	useNegativeAmount= bizEnv.GetUseNegativeAmount()
	numOfJDT2= dagJDT2.GetRecordCount()
	fetched= dagJDT1.GetRecordFetchStatus (0)
	ooErr= CSystemBusinessObject::OnUpdate()
	ooErr= updateCenvatByJdt1Line(*this, dagJDT1, rec)
	RetVal=0
	ooErr=  DBD_SpExec (dagJDT, Sp_Name, &RetVal)
	ordered= false
	ooErr= CTransactionJournalObject::IsPaymentOrdered(bizEnv, canceledTrans, ordered)
	ooErr= ReconcileCertainLines()
	ooErr= ReconcileDeferredTaxAcctLines()
	ooErr= CreateTax()
	ooErr= nsDeductHierarchy::UpdateDeductionPercent (bizEnv, transID)
	ooErr= m_digitalSignature.CreateSignature (this)
	ooErr= ValidateBPLNumberingSeries ()
	ooErr= IsBalancedByBPL ()
	ooErr= DBD_SpToDAG (dagJDT1, &dagRES, Sp_Name)
	blockLevel= RetBlockLevel(bizEnv)
	typeBlockLevel= RettypeBlockLevel(bizEnv, GetID().strtol ())
	blockLevel=@ JDT_NOT_BGT_BLOCK
	transType== 30)
	DoAlert= tmpStr[0]
	AlrType= tmpStr[0]
	bgtDebitSize=@ TRUE
	budgetAllYes= IsExCommand( ooDontUpdateBudget)
	fromImport= IsExCommand( ooImportData)
	retBtn= FORM_GEN_Message (msgStr1, ContinueStr, CANCEL_STR(*OOGetEnv(NULL)), YES_TO_ALL_STR(*OOGetEnv(NULL)), 2)
	retBtn= 2
	budgetAllYes= (retBtn == 3 ? TRUE:FALSE)

    end
    
    def RettypeBlockLevel(bizEnv, id)
	
    end
    
    def RetBlockLevel(bizEnv)
	
    end
    
    def OnInitData()
	dagJDT= GetDAG ()
	ooErr= CSystemBusinessObject::OnInitData ()
	ooErr= InitDataReport340 (dagJDT)

    end
    
    def GetYearAndMonthEntry(dagJDT, byRef, rec, month, year)
	
    end
    
    def GetYearAndMonthEntryByDate(dateStr, month, year)
	month= *year = 0L
	month= _STR_atol(date+4)
	year= _STR_atol(date)

    end
    
    def RecordJDT(env, dagJDT, dagJDT1, reconcileBPLines)
	obj= (CTransactionJournalObject *)env.CreateBusinessObject (SBOString (JDT))
	dagLocalJDT= obj.GetDAG(JDT,ao_Main)
	dagLocalJDT1= obj.GetDAG(JDT,ao_Arr1)
	ooErr=obj.OnCreate()

    end
    
    def OnIsValid()
	dag=GetDAG()
	fromBatch=@ FALSE
	msgHandled=@ FALSE
	fromImport=@ FALSE
	fromEoy=@ FALSE
	bizEnv= GetEnv ()
	dagJDT1= GetDAG (JDT, ao_Arr1)
	dagJDT2= GetDAG (JDT, ao_Arr2)
	nonZero= allowFcNotBalanced = allowFcMulty = multyFcDetected = FALSE
	fromEoy=@ TRUE
	transNum= 0
	dagNNM3= GetDAG(NNM, ao_Arr3)
	isSeriesForCncl= false
	ooErr= CNextNumbersObject::IsSeriesForCancellation(bizEnv, series,
	ooErr= IsValidUserPermissions ()
	ooErr= ValidateRelations (ao_Main, 0, OJDT_TRANS_CODE, TRC)
	ooErr= ValidateRelations ( ao_Main, 0, OJDT_PROJECT, PRJ)
	ooErr= ValidateRelations ( ao_Main, 0, OJDT_INDICATOR, IDC)
	ooErr= ValidateRelations ( ao_Main, 0, OJDT_DOC_TYPE, JET)
	dagJDT= GetDAG (JDT, ao_Main)
	pManager= bizEnv.GetSupplCodeManager()
	ooErr= pManager.LoadDfltCodeToDag(*this, PostDate)
	ooErr= pManager.CheckCode(*this)
	ooErr= ValidateReportEU()
	ooErr= ValidateReport347()
	ooErr= ValidateReport340 ()
	ooErr= m_WithholdingTaxMng.ODOCValidateDOC5 (*this, dag, dagJDT2, NULL)
	ooErr= ValidateHeaderLocation()
	useNegativeAmount= bizEnv.GetUseNegativeAmount ()
	periodManager= bizEnv.GetPeriodCache()
	periodID= periodManager.GetPeriodId (bizEnv, dateStr.GetString())
	dag= GetDAG ()
	docType=  bizEnv.GetDefaultJEType()
	fromBatch=@ TRUE
	fromImport=@ TRUE
	dagACT= GetDAG(ACT)
	dagCRD= GetDAG(CRD)
	dagCRD3= GetDAG(CRD, ao_Arr3)
	transNum= 0
	ooErr= nsDocument::CheckTaxCodeInactive (bizEnv, tmpStr)
	ooErr= nsDocument::CheckVatGroupInactive (bizEnv, tmpStr)
	ooErr= ValidateRelations (ao_Arr1, rec, JDT1_PROJECT, PRJ)
	ooErr= ValidateRowLocation(rec)
	ooErr= IsPaymentBlockValid (dagJDT1, rec)
	ooErr= ValidateRelations (ao_Arr1, rec, JDT1_VAT_GROUP, VTG)
	nonZero=@ TRUE
	ooErr= bizEnv.GetByOneKey (dagACT, OACT_KEYNUM_PRIMARY, actNum, true)
	ooErr= OOCheckObjectActive (*this, dagACT, -1, actNum, &checkDate)
	ooErr= OOCheckObjectActive (*this, dagCRD, -1, shortName, &checkDate)
	ooErr= OOCheckObjectActive (*this, dagACT, -1, actNum, &checkDate)
	allowFcMulty=@ TRUE
	allowFcMulty=@ FALSE
	allowFcMulty=@ TRUE
	allowFcMulty=@ TRUE
	msgHandled=@ TRUE
	multyFcDetected=@ TRUE
	exist=@ FALSE
	exist=@ TRUE
	ooErr= ValidateCostAccountingStatus ()
	dagCFT= GetDAGNoOpen(objCFTId)
	bo= static_cast<CCashFlowTransactionObject*>(CreateBusinessObject(CFT))
	tmpTransNum= -1
	isAllCashRelevant= true
	boCOA= static_cast<CChartOfAccounts*>(CreateBusinessObject(ACT))
	isAllCashRelevant=@ FALSE
	boCOA= static_cast<CChartOfAccounts*>(CreateBusinessObject(ACT))
	isDebit=@ FALSE
	isDebit=@ TRUE
	msgHandled=@ TRUE
	retVal= FUEnhDialogBox (NULL, ERROR_MESSAGES_STR, OO_TRANSACTION_NOT_BALANCED,
	msgHandled=@ TRUE
	allowFcNotBalanced=@ TRUE
	allowFcNotBalanced=@ FALSE
	allowFcNotBalanced=@ TRUE
	allowFcNotBalanced=@ TRUE
	msgHandled=@ TRUE
	retVal= FUEnhDialogBox (NULL, ERROR_MESSAGES_STR, OO_TRANSACTION_NOT_BALANCED,
	msgHandled=@ TRUE
	ooErr= ValidateBPL ()
	plaAct= bizEnv.GetGLAccountManager()->GetAccountByDate(EMPTY_STR, mat_plaAct)
	numOfRec= dagJDT1.GetRecordCount()
	cenvat
	mattypeOJDT=@ 0L
	dagJDT= GetDAG ()
	dagERX= OpenDAG (ERX)
	result= DBD_Count (dagERX, TRUE)
	dagJDT= GetDAG ()
	numOfRec= dagJDT1.GetRecordCount ()
	ooErr= validator.CheckBlockDocFromEarlierPostingDate()

    end
    
    def OnUpdate()
	bizEnv= GetEnv ()
	periodMode= bizEnv.GetPeriodMode ()
	dagJDT1= GetDAG(JDT, ao_Arr1)
	dagCFT= GetDAGNoOpen(objCFTId)
	bo= static_cast<CCashFlowTransactionObject*>(CreateBusinessObject(CFT))
	ooErr= bo.OCFTModifyByJDT (GetDAG(CFT))
	dagJDT= GetDAG (JDT)
	dagJDT2= GetDAG(JDT, ao_Arr2)
	ooErr= COverheadCostRateObject::GetValidFrom (bizEnv, ocrCode, postDate, validFrom)
	isOrdered= this.IsPaymentOrdered ()
	transId= -1
	isOrderedInDB= false
	ooErr= CTransactionJournalObject::IsPaymentOrdered (bizEnv, transId, isOrderedInDB)
	recCount= dagJDT2.GetRealSize (dbmDataBuffer)
	ooErr= UpdateWTInfo ()
	dagOLD1= OpenDAG (JDT, ao_Arr1)
	ooErr= dagOLD1.GetByKey (key)
	objectId= transType.Trim ().strtol ()
	series= 0
	isScAdj= false
	ooErr= IsScAdjustment(isScAdj)
	ooErr= ValidateBPLNumberingSeries ()
	ooErr= IsBalancedByBPL ()
	ooErr= CSystemBusinessObject::OnUpdate()

    end
    
    def OnAutoComplete()
	ooErr=@ noErr
	sysCurr={0}
	localCurr={0}
	tempCurr={0}
	sysFound=@FALSE
	dagJDT=@ NULL
	dagJDT1=@ NULL
	dagACT=@ NULL
	dagCRD=@ NULL
	bizEnv= GetEnv ()
	dagJDT= GetDAG (JDT)
	dagJDT1= GetDAG(JDT, ao_Arr1)
	dagACT= GetDAG (ACT)
	dagCRD= GetDAG(CRD)
	ooErr= CompleteKeys ()
	ooErr= CompleteJdtLine ()
	ooErr= bizEnv.GetVatPercent (tmpStr, bizEnv.GetDateForTaxRateDetermination (dagJDT1, rec), &vatPrcnt, &equVatPrcnt)
	needBaseSum=@ TRUE
	vatPrcnt=@ zeroM
	needBaseSum=@ FALSE
	vatPrcnt=@ zeroM
	needBaseSum=@ FALSE
	baseSum=@ money
	baseSum=@ money
	needSetFCToLCRound= false
	needSetFCToLCRound= false
	ooErr= bizEnv.GetByOneKey (dagACT, OACT_KEYNUM_PRIMARY, actNum, true)
	ooErr= GNForeignToLocalRate (&debMoneyFC, lineCurr, dateStr, 0.0, &money,GetEnv())
	ooErr= GNForeignToLocalRate (&credMoneyFC, lineCurr, dateStr, 0.0, &money,GetEnv())
	ooErr= GNForeignToLocalRate (&tmpM, lineCurr, dateStr, 0.0, &money,GetEnv())
	ooErr= GNForeignToLocalRate (&debMoneyFC, lineCurr, dateStr, 0.0, &baseSum,GetEnv())
	ooErr= bizEnv.GetByOneKey (dagACT, OACT_KEYNUM_PRIMARY, actNum, true)
	ooErr= CalculationSystAmmountOfTrans()
	ooErr= CompleteForeignAmount()
	ooErr= CompleteVatLine()
	ooErr= CompleteWTLine ()
	ooErr= CompleteTrans ()
	ooErr= CompleteJdtLine()
	ooErr= dagJDT.GetColStr(transCode, OJDT_TRANS_CODE, 0)
	ooErr= CJournalManager::GetDefaultTransCode(this, dagJDT, dagJDT1, glAcct, transCode, jdtLine)
	ooErr= dagJDT.SetColStr(transCode, OJDT_TRANS_CODE, 0)
	ooErr= CompleteReport340 (dagJDT, dagJDT1)

    end
    
    def CompleteForeignAmount()
	ooErr=@ ooNoErr
	prevCurr= {0}
	found= false
	bizEnv= GetEnv ()
	dagJDT= GetDAG()
	dagJDT1= GetDAG(JDT, ao_Arr1)
	dagACT= GetDAG (ACT)
	dagCRD= GetDAG(CRD)
	ooErr= CalculationFrnAmmounts (dagACT, dagCRD, found)

    end
    
    def UpdateAccumulators(bizObject, rec, isCard)
	ooErr=@ noErr
	dagBGT=@NULL
	dagBGT1=@NULL
	blockLevel=0
	typeBlockLevel=0
	bgtDebitSize=@ FALSE
	jdtDebitSize=@ FALSE
	budgetAllYes=@FALSE
	bizEnv= bizObject.GetEnv ()
	localDags=@ FALSE
	dagBGT= bizObject.OpenDAG(BGT,ao_Main)
	dagBGT1= bizObject.OpenDAG(BGT,ao_Arr1)
	localDags=@ TRUE
	dagBGT1= bizObject.GetDAG(BGT, ao_Arr1)
	ooErr= CBudgetGeneralObject::GetBudgetRecords (dagBGT, dagBGT1, NULL, NULL, acctCode, finYear, -1, tmpStr, TRUE, true)
	transType=bizObject.GetID().strtol ()
	blockLevel= RetBlockLevel(bizEnv)
	typeBlockLevel= RettypeBlockLevel(bizEnv, transType)
	jdtDebitSize=@ TRUE
	blockLevel=@ JDT_NOT_BGT_BLOCK
	bgtDebitSize=@TRUE
	ooErr= SetBudgetBlock (bizObject, blockLevel, &testMoney, &testYearMoney, &testTmpM, &testYearTmpM)
	ooErr= GOUpdateProc (*bizObject, dagBGT)

    end
    
    def SetBudgetBlock(bizObject, blockLevel, testMoney, testYearMoney, testTmpM, testYearTmpM, workWithUI)
	ooErr=@noErr
	monSymbol={0}
	numTemplatesApplied=0
	budgetAllYes=@FALSE
	fromImport=@FALSE
	doTemlates=@FALSE
	ObjType= bizObject.GetID().strtol ()
	bizEnv= bizObject.GetEnv ()
	dagWDD= bizObject.GetDAG(WDD)
	numTemplatesApplied= dagWDD.GetRealSize(dbmDataBuffer)
	doTemlates= (Boolean) ((OOIsSaleObject (ObjType) ||
	budgetAllYes= bizObject.IsExCommand( ooDontUpdateBudget)
	fromImport= bizObject.IsExCommand( ooImportData)
	doTemlates=@ FALSE
	strKeyTmp= bizObject.GetKeyStr()
	condVal= (bizEnv.GetBudgetWarningFrequency ()== VAL_MONTHLY[0] ? moneyMonthStr:moneyYearStr)
	ooErr= ((CDocumentObject *) bizObject).ODOCGetTemplatesByCond ( WDD_COND_VAL_BUDGET, condVal, false)
	isFromDI= (bizObject.GetDataSource() == VAL_OBSERVER_SOURCE[0])
	blockLevel=@ JDT_WARNING_BLOCK
	docObj= dynamic_cast<CDocumentObject *>(bizObject)
	blockLevel=@ JDT_BGT_BLOCK
	strKey= bizObject.GetKeyStr()
	retBtn= FORM_GEN_Message (msgStr1, ContinueStr, CANCEL_STR(*OOGetEnv(NULL)), YES_TO_ALL_STR(*OOGetEnv(NULL)), 2)
	retBtn= 2
	budgetAllYes= (retBtn == 3 ? TRUE:FALSE)

    end
    
    def GetBudgBlockErrorMessage(MonthmoneyStr, YearmoneyStr, acctKey, messgNumber, TCHAR*retMsgErr)
	yearWarning=@ FALSE
	monSymbol={0}
	bizEnv= GetEnv ()
	strKey=@ acctKey

    end
    
    def DocBudgetRestriction(bizObject, acctCode, Sum, refDate, budgetAllYes, isWorkWithUI)
	ooErr=@ ooNoErr
	acctNum=0
	objType= bizObject.GetID().strtol ()
	blockLevel=0
	openInvYearSysField
	bgtDebitSide=@ FALSE
	bizEnv= bizObject.GetEnv()
	blockLevel= RetBlockLevel(bizEnv)
	pDocObject= dynamic_cast<CDocumentObject *>(bizObject)
	bIsCancelDoc= pDocObject && pDocObject.IsCancelDoc()
	typeBlockLevel= RettypeBlockLevel(bizEnv, objType)
	blockLevel=@ JDT_NOT_BGT_BLOCK
	ooErr=@ ooNoErr
	dagBGT= bizObject.GetDAG ( BGT )
	dagBGT1= bizObject.GetDAG ( BGT, ao_Arr1 )
	ooErr= CBudgetGeneralObject::GetBudgetRecords (dagBGT, dagBGT1, NULL, NULL, (TCHAR*)acctCode, finYear, -1, refDate, TRUE)
	bgtDebitSide=@ TRUE
	openInvField= openInvSysField = -1
	openInvYearField=openInvYearSysField =-1
	openInvYearField=@ OBGT_FUTR_OUT_D_R_SUM
	openInvYearSysField=@ OBGT_FUTR_OUT_D_R_SYS_SUM
	openInvField=@ OBGT_FUTR_OUT_D_R_SUM
	openInvSysField=@ OBGT_FUTR_OUT_D_R_SYS_SUM
	openInvSysField=@ BGT1_FUTR_OUT_D_R_SYS_SUM
	testYearTmpM=@ testTmpM
	ooErr= SetBudgetBlock (bizObject,blockLevel, &testMoney, &testYearMoney, &testTmpM, &testYearTmpM, isWorkWithUI)

    end
    
    def UpdateDocBudget(bizObject, updateBgtPtr, dagDOC1, rec)
	ooErr=@ ooNoErr
	dagBGT=@NULL
	dagBGT1=@NULL
	dagAct=@ NULL
	localDags=@ FALSE
	bgtDebitSide=@ FALSE
	subMoneyOper=@ FALSE
	acctNum=0
	bizEnv= bizObject.GetEnv ()
	subMoneyOper=@ TRUE
	ooErr= CItemMasterData::IsInventoryItemEx (bizEnv,
	ooErr=@ ooNoErr
	dagActWrp= bizEnv.GetDagPool().Get(make_pair(ACT, ao_Main))
	dagAct= dagActWrp.GetPtr()
	dagBGT= bizObject.GetDAG(BGT)
	dagBGT1= bizObject.GetDAG(BGT, ao_Arr1)
	ooErr= bizEnv.GetByOneKey (dagAct, 1, updateBgtPtr.acctBgtRecords[acctNum].acctCode)
	ooErr=@ooNoErr
	ooErr= CBudgetGeneralObject::GetBudgetRecords (dagBGT, dagBGT1, NULL, NULL,
	ooErr=@ooNoErr
	bgtDebitSide=@ TRUE
	openInvField=@ OBGT_FUTR_OUT_D_R_SUM
	openInvSysField=@ OBGT_FUTR_OUT_D_R_SYS_SUM
	openInvFieldArr=@ BGT1_FUTR_OUT_D_R_SUM
	openInvSysFieldArr=@ BGT1_FUTR_OUT_D_R_SYS_SUM
	openInvField=@ OBGT_FUTR_IN_C_R_SUM
	openInvSysField=@ OBGT_FUTR_IN_C_R_SYS_SUM
	openInvFieldArr=@ BGT1_FUTR_IN_C_R_SUM
	openInvSysFieldArr=@ BGT1_FUTR_IN_C_R_SYS_SUM
	tmpM= updateBgtPtr.acctBgtRecords[acctNum].sum
	tmpSysM= updateBgtPtr.acctBgtRecords[acctNum].sysSum
	ooErr= GOUpdateProc (*bizObject, dagBGT, true)

    end
    
    def GetSRObjectBudgetAcc(object)
	
    end
    
    def SetContraAccounts(dagJdt1, firstRec, maxRec, contraDebKey, contraCredKey, contraDebLines, contraCredLines)
	env= GetEnv ()
	maxRec=@ numOfRecs
	
			}
		}
	

    end
    
    def OnCanUpdate()
	oopp= GetOnUpdateParams ()
	dag= oopp.pDag
	bizEnv= GetEnv ()
	editableInUpdate= (Boolean)(bizEnv.GetPermission (PRM_ID_UPDATE_POSTING) == OO_PRM_FULL)
	fCodePtr= DAG_GetAlias (dag)
	isHeader= _STR_stricmp (fCodePtr, bizEnv.ObjectToTable (JDT)) == 0
	tmp= bizEnv.ObjectToTable(JDT, ao_Arr2)
	ordered=@ VAL_NO

    end
    
    def DocBudgetCurrentSum(bizObject, currentMoney, acctCode)
	sboErr=@ ooNoErr
	dagDOC= bizObject.GetDAG()
	dagObj= bizObject.GetDAG ( bizObject.GetID() ,ao_Arr1)
	sboErr= DBD_GetInNewFormat(dagObj, &dagRES)
	tmpM= sumRow * docDiscount
	
				}
				(*currentMoney) += sumRow

    end
    
    def OnUpgrade()
	ooErr=@ ooNoErr
	bizEnv= GetEnv ()
	dagJDT= OpenDAG (JDT, ao_Main)
	ooErr= DBD_GetInNewFormat (dagJDT, &dagRES)
	ooErr= DBD_UpdateCols (dagJDT)
	dagJDT1= OpenDAG (JDT, ao_Arr1)
	ooErr= DBD_UpdateCols (dagJDT1)
	dagJDT1= OpenDAG (JDT, ao_Arr1)
	dagJDT1= OpenDAG (JDT, ao_Arr1)
	pResCol= updStruct[0].GetResObject().AddResCol ()
	pResCol= updStruct[0].GetResObject().AddResCol ()
	pResCol= updStruct[0].GetResObject().AddResCol ()
	ooErr= DBD_UpdateCols (dagJDT1)
	pResCol= updStruct[0].GetResObject().AddResCol ()
	pResCol= updStruct[0].GetResObject().AddResCol ()
	pResCol= updStruct[0].GetResObject().AddResCol ()
	ooErr= DBD_UpdateCols (dagJDT1)
	dagJDT1= OpenDAG (JDT, ao_Arr1)
	ooErr= DBD_UpdateCols (dagJDT1)
	ooErr= UpgradeBoeActs()
	ooErr= UpgradePeriodIndic()
	dagJDT= OpenDAG (JDT)
	ooErr= DBD_UpdateCols (dagJDT)
	dagBTF= OpenDAG (BTF)
	ooErr= DBD_UpdateCols (dagBTF)
	ooErr= DBD_UpdateCols (dagJDT)
	dagJDT1= OpenDAG (JDT, ao_Arr1)
	ooErr= DBD_Get (dagJDT1)
	ooErr= DBD_GetInNewFormat (dagJDT1, &dagRES)
	DebitSide= CreditSide = FALSE
	CreditSide=@ TRUE
	DebitSide=@ TRUE
	CreditSide=@ TRUE
	DebitSide=@ TRUE
	ooErr= DBD_UpdateCols (dagJDT1)
	ooErr= DBD_UpdateCols (dagJDT1)
	dagCPRF= OpenDAG (PRF)
	dagCPRF= OpenDAG (PRF)
	dagCPRF= OpenDAG (PRF)
	dagJDT= OpenDAG (JDT)
	ooErr= DBD_GetInNewFormat (dagJDT, &dagRES)
	dagJDT1= OpenDAG (JDT, ao_Arr1)
	ooErr= DBD_UpdateCols (dagJDT1)
	ooErr= DBD_UpdateCols (dagJDT)
	dagJDT1= OpenDAG (JDT, ao_Arr1)
	ooErr= DBD_UpdateCols (dagJDT1)
	ooErr= DBD_UpdateCols (dagJDT1)
	conid= bizEnv.GetCompanyConnectionID()
	ServerType= DBMCconnManager::GetHandle()->GetConnectionType (conid)
	dagJDT= OpenDAG (JDT)
	ooErr= DBD_GetInNewFormat (dagJDT, &dagRES)
	dagTMP= OpenDAG (JDT)
	ooErr= DBD_UpdateCols (dagJDT)
	ooErr= DBD_GetInNewFormat (dagJDT, &dagSeries)
	ooErr= DBD_UpdateCols (dagJDT)
	ooErr= DBD_UpdateCols (dagJDT)
	ooErr= DBD_GetInNewFormat (dagTMP, &dagTransList)
	ooErr= DBD_UpdateCols (dagJDT)
	dagCPRF= OpenDAG (PRF)
	 -1}
	ooErr= SetToZeroNullLineTypeCols ()
	ooErr= SetToZeroOldLineTypeCols ()
	kk= 0
	 -1}
	ooErr= UpgradeDpmLineTypeUsingJDT1 (objArr[kk])
	ooErr= UpgradeDpmLineTypeUsingRCT2 (objArr[kk])
	dagJDT1= OpenDAG (JDT, ao_Arr1)
	ooErr= DBD_UpdateCols (dagJDT1)
	ooErr= DBD_UpdateCols (dagJDT1)
	ooErr= DBD_UpdateCols (dagJDT1)
	ooErr= DBD_UpdateCols (dagJDT1)
	ooErr= DBD_UpdateCols (dagJDT1)
	ooErr= DBD_UpdateCols (dagJDT1)
	ooErr= DBD_UpdateCols (dagJDT1)
	ooErr= DBD_UpdateCols (dagJDT1)
	ooErr= DBD_UpdateCols (dagJDT1)
	ooErr= DBD_UpdateCols (dagJDT1)
	ooErr= DBD_UpdateCols (dagJDT1)
	ooErr= DBD_UpdateCols (dagJDT1)
	ooErr= DBD_UpdateCols (dagJDT1)
	ooErr= DBD_UpdateCols (dagJDT1)
	reconUpgMgr= new CReconUpgMgr (bizEnv, *this)
	ooErr= reconUpgMgr.UpgradeRCT2TransFields ()
	ooErr= reconUpgMgr.UpgradeRCT2NegativeFields ()
	ooErr= reconUpgMgr.BuildViewsForBadPayments ()
	ooErr= reconUpgMgr.Upgrade ()
	ooErr= reconUpgMgr.FixLinkedInvoiceReconciliation()
	ooErr= reconUpgMgr.UpgradePartialReconciliationHistory ()
	ooErr= reconUpgMgr.UpgradePartialReconHistReplaceWrongRecon ()
	ooErr= CReconUpgMgr::UpgradeAuditTrailJETotal (bizEnv)
	connID= m_env.GetCompanyConnectionID ()
	ServerType= DBMCconnManager::GetHandle()->GetConnectionType (connID)
	ooErr= CReconUpgMgr::NullifyFCCurrencyFieldInJDT1 (bizEnv)
	 -1}
	ooErr= UpgradeODOCVatPaidForFullyBasedCreditMemos(objIDs[i])
	ooErr= UpgradeDOC6VatPaidForFullyBasedCreditMemos(objIDs[i])
	isAPA= bizEnv.IsFormerApaLocalSettings ()
	ooErr= UpgradeOJDTCreatedByForWOR ()
	ooErr= UpgradeOJDTWithFolio()
	ooErr= UpgradeJDTCreateDate ()
	ooErr= UpgradeJDTCanceledDeposit ()
	ooErr= UpgradeWorkOrderErr ()
	ooErr= UpgradeLandedCosErr ()
	ooErr= UpgradeYearTransfer ()
	dagCPRF= OpenDAG (PRF)
	ooErr= UpgradeJDT1VatLineToNo ()
	ooErr= UpgradeJDTIndianAutoVat ()
	ooErr= UpgradeOJDTUpdateDocType ()
	dagJDT1= OpenDAG (JDT, ao_Arr1)
	ooErr= DBD_UpdateCols (dagJDT1)
	ooErr= DBD_UpdateCols (dagJDT1)
	dagJDT1= OpenDAG (JDT, ao_Arr1)
	ooErr= DBD_UpdateCols (dagJDT1)
	ooErr= DBD_UpdateCols (dagJDT1)
	ooErr= DBD_UpdateCols (dagJDT1)
	ooErr= DBD_UpdateCols (dagJDT1)
	ooErr= DBD_UpdateCols (dagJDT1)
	ooErr= DBD_UpdateCols (dagJDT1)
	ooErr= RepairTaxTable()
	dagJDT1= OpenDAG (JDT, ao_Arr1)
	ooErr= DBD_UpdateCols (dagJDT1)
	ooErr= UpgradeERDBaseTrans ()
	dagJDT1= OpenDAG (JDT, ao_Arr1)
	ooErr= DBD_UpdateCols (dagJDT1)
	ooErr= UpgradeJDTCEEPerioEndReconcilations ()
	ooErr= RepairEquVatRateOfJDT1 ()
	dagJDT1= OpenDAG (JDT, ao_Arr1)
	ooErr= dagJDT1.UpdateCols ()
	ooErr= UpgradeFederalTaxIdOnJERow ()
	ooErr= UpgradeDprId(true,  VERSION_8_8_314, VERSION_8_8_2_MR)
	ooErr= UpgradeDprId(false, VERSION_8_8_314, VERSION_8_8_2_MR)
	ooErr= UpgradeDprIdForOneDprPayment(true, VERSION_8_8_314)
	ooErr= UpgradeDprIdForOneDprPayment(false, VERSION_8_8_314)

    end
    
    def SetToZeroNullLineTypeCols()
	ooErr=@ noErr
	dagJDT1= GetDAG (JDT, ao_Arr1)
	ooErr= GNUpdateNullColumnsToZero (dagJDT1, updateZeroColNum, 1)

    end
    
    def SetToZeroOldLineTypeCols()
	ooErr=@ noErr
	dagJDT1= GetDAG (JDT, ao_Arr1)
	conditions= &(dagJDT1.GetDBDParams ()->GetConditions ())
	condPtr= &conditions.AddCondition ()
	condPtr= &conditions.AddCondition ()
	condPtr= &(conditions.AddCondition ())
	bizEnv= GetEnv ()
	subTables= &(subParams.GetCondTables ())
	tablePtr= &subTables.AddTable ()
	subConditions= &(subParams.GetConditions ())
	condPtr= &(subConditions.AddCondition ())
	condPtr= &(subConditions.AddCondition ())
	condPtr= &(subConditions.AddCondition ())
	condPtr= &(subConditions.AddCondition ())
	ooErr= DBD_SetDAGUpd (dagJDT1, updateStruct, 1)
	ooErr= DBD_UpdateCols (dagJDT1)

    end
    
    def CompleteTrans()
	bizEnv= GetEnv ()
	dagJDT= GetDAG (JDT)
	dagJDT1= GetDAG (JDT, ao_Arr1)
	dagCRD= GetDAG (CRD)
	dbErr= bizEnv.GetByOneKey (dagCRD, OCRD_KEYNUM_PRIMARY, shortName, true)
	dbErr= DBD_GetInNewFormat (dagCRD, &dagRES)

    end
    
    def CompleteJdtLine()
	ooErr=@ noErr
	bizEnv= GetEnv ()
	mbEnabled= false
	isAutoCompleteBPLFromUD= false
	dagJDT= GetDAG ()
	dagJDT1= GetDAG ( JDT, ao_Arr1)
	mbEnabled= VF_MultiBranch_EnabledInOADM (bizEnv)
	isAutoCompleteBPLFromUD= mbEnabled &&
	lTmp= bizEnv.GetUserDefaultBranch ()
	bizEnv= GetEnv ()
	ooErr= bizEnv.GetByOneKey (dagACT, OACT_KEYNUM_PRIMARY, acctCode)

    end
    
    def SetJDTLineSrc(line, absEntry, srcLine)
	ooErr=@ noErr
	dagJDT1= GetDAG(JDT, ao_Arr1)

    end
    
    def DoSingleStorno(/)
	ooErr=@ noErr
	 -1}
	 -1}
	bizEnv= GetEnv ()
	dagJDT= GetDAG ()
	dagJDT1= GetDAG (JDT, ao_Arr1)
	periodManager= bizEnv.GetPeriodCache()
	ooErr= dagJDT.GetChangesList (0, colsList)
	periodID= periodManager.GetPeriodId (bizEnv, keyDate)
	ooErr= ValidateRelations (ao_Main, 0, OJDT_PROJECT, PRJ)
	ooErr= ValidateRelations ( ao_Main, 0, OJDT_INDICATOR, IDC)
	ooErr= ValidateRelations (ao_Main, 0, OJDT_TRANS_CODE, TRC)
	mdrObj= static_cast<CManualDistributionRuleObject*>(GetEnv().CreateBusinessObject(mdr))
	dimObj= static_cast<CCostAccountingDimension*>(GetEnv().CreateBusinessObject(dim))
	recCount= dagJDT1.GetRecordCount()
	ooErr= LoadTax()
	ooErr= m_stornoExtraInfoCreator.Execute()
	ooErr= OnIsValid()
	dagCFT= GetDAG (CFT)
	bo= static_cast<CCashFlowTransactionObject*>(CreateBusinessObject(CFT))
	ooErr= OnCreate()
	ooErr= OnCheckIntegrityOnCreate()

    end
    
    def ReconcileCertainLines()
	ooErr=@ noErr
	numOfConds= 0
	bizEnv= GetEnv ()
	pMM=@ NULL
	shouldAddLine2Match= true
	shouldCancelRecons= true
	dagJdt= GetDAG()
	dagJdt1= GetDAG(JDT, ao_Arr1)
	ooErr= DBD_GetInNewFormat (dagJdt1, &dagRES)
	ooErr= dagJdt1.Duplicate (&dagDupJdt1, dbmDropData)
	ooErr= DBD_GetKeyGroup (dagDupJdt1, JDT1_KEYNUM_PRIMARY, keyStr, TRUE)
	pMM= new CSystemMatchManager(bizEnv, m_isInCancellingAcctRecon == false, date.GetString (), JDT, transNum, rt_Reversal)
	shouldAddLine2Match= true
	shouldAddLine2Match= m_stornoExtraInfoCreator.IsNeedToAddLineToReconciliation(dagJdt1, rec, false)
	shouldAddLine2Match= true
	shouldCancelRecons= true
	shouldCancelRecons= false
	ooErr= CManualMatchManager::CancelAllReconsOfJournalLine(bizEnv, transNum, rec)
	shouldAddLine2Match= m_stornoExtraInfoCreator.IsNeedToAddLineToReconciliation(dagDupJdt1, rec, true)
	ooErr=  pMM.Reconcile ()

    end
    
    def UpgradeBoeActs()
	dagRES=@NULL
	dagRES2=@NULL
	dagAnswer=@ NULL
	numOfCardConds=0
	numOfActsConds=0
	numOfConds=0
	@firstErr = @ FALSEshortName[JDT1_SHORT_NAME_LEN+1]
	bizEnv= GetEnv ()
	totalNumOfIterations=0
	numOfIterations=0
	numOfTables=0
	ooErr= FixVendorsAndSpainBoeBalance()
	dagJDT1= OpenDAG (JDT, ao_Arr1)
	totalNumOfIterations= 3
	numOfTables= 1
	ooErr= DBD_GetInNewFormat (dagJDT1, &dagAnswer)
	dagAnswer=@ NULL
	dagAnswer=@ NULL
	numOfConds= 0
	numOfTables= 0
	numOfConds= 0
	numOfTables= 0
	ooErr= ARP_GetAccountByType (GetEnv(), NULL, ARP_TYPE_BoE_PRESENTATION, tmpStr, TRUE, VAL_CUSTOMER)
	cmpNumOfConds= 0
	cmpNumOfConds=@ numOfConds
	ooErr= ARP_GetAccountByType (GetEnv(), NULL, ARP_TYPE_BoE_ON_COLLECTION, tmpStr, TRUE, VAL_CUSTOMER)
	ooErr= ARP_GetAccountByType (GetEnv(), NULL, ARP_TYPE_UNPAID_BoE, tmpStr, TRUE, VAL_CUSTOMER)
	ooErr= ARP_GetAccountByType (GetEnv(), NULL, ARP_TYPE_BoE_DISCOUNTED, tmpStr, TRUE, VAL_CUSTOMER)
	ooErr= ARP_GetAccountByType (GetEnv(), NULL, ARP_TYPE_BoE_PRESENTATION, tmpStr, TRUE, VAL_CUSTOMER)
	ooErr= ARP_GetAccountByType (GetEnv(), NULL, ARP_TYPE_BoE_DISCOUNTED, tmpStr, TRUE, VAL_CUSTOMER)
	ooErr= DBD_GetInNewFormat (dagJDT1, &dagAnswer)
	dagAnswer=@ NULL
	dagAnswer=@ NULL
	cond= new DBD_CondStruct[2* numOfRecs]
	updateActBalanceCond= new DBD_CondStruct[numOfRecs]
	updateCardBalanceCond= new DBD_CondStruct[numOfRecs]
	rec=0
	numOfConds= 0
	firstAct=@ TRUE
	intrnMatch=@ matchNum
	ooErr= DBD_UpdateCols (dagJDT1)
	firstAct=@ FALSE
	numOfConds= 0
	dagACT= OpenDAG (ACT, ao_Main)
	ooErr= DBD_Get(dagACT)
	dagCRD= OpenDAG (CRD, ao_Main)
	ooErr= DBD_Get(dagCRD)

    end
    
    def FixVendorsAndSpainBoeBalance()
	numOfCardConds=0
	numOfActsConds=0
	numOfConds=0
	firstErr=@ FALSE
	bizEnv= GetEnv ()
	dagJDT1= OpenDAG (JDT, ao_Arr1)
	ooErr= DBD_GetInNewFormat (dagJDT1, &dagRES)
	firstErr=@ TRUE
	numOfConds= 0
	ooErr= ARP_GetAccountByType (GetEnv(), NULL, ARP_TYPE_BoE_RECEIVABLE, tmpStr, TRUE, VAL_CUSTOMER)
	ooErr= ARP_GetAccountByType (GetEnv(), NULL, ARP_TYPE_BoE_PAYABLE, tmpStr, TRUE, VAL_VENDOR)
	ooErr= DBD_GetInNewFormat (dagJDT1, &dagRES2)
	updateCardBalanceCond= new DBD_CondStruct[numOfRecs]
	dagCRD= OpenDAG (CRD, ao_Main)
	ooErr= DBD_Get(dagCRD)

    end
    
    def IsCardAlreadyThere(updateCardBalanceCond, cardCode, startingRec, numOfCardConds)
	
    end
    
    def UpgradePeriodIndic()
	sboErr=@ ooNoErr
	dagJDT1= OpenDAG (JDT, ao_Arr1)
	sboErr= DBD_UpdateCols(dagJDT1)

    end
    
    def OnCheckIntegrityOnCreate()
	ooErr= OJDTCheckIntegrityOfJournalEntry (this, false)

    end
    
    def OnCheckIntegrityOnUpdate()
	ooErr= OJDTCheckIntegrityOfJournalEntry (this, false)

    end
    
    def OJDTCheckIntegrityOfJournalEntry(bizObject, checkForgn)
	dagJDT= bizObject.GetDAGNoOpen(SBOString(JDT))
	numOfRecs= dagJDT.GetRecordCount()
	numOfRecs= 0
	ooErr= OJDTCheckJDT1IsNotEmpty (bizObject)
	ooErr= OJDTValidateJDTOfLocalCard (bizObject)
	ooErr= OJDTValidateJDT1Accounts (bizObject)
	ooErr= OJDTCheckBalnaceTransection(bizObject, checkForgn)
	ooErr= CostAccountingAssignmentCheck(bizObject)

    end
    
    def OJDTCheckJDT1IsNotEmpty(bizObject)
	dagJDT= bizObject.GetDAGNoOpen(SBOString(JDT))
	dagJDT1= bizObject.GetDAG(SBOString(JDT),ao_Arr1)
	numOfRecs= dagJDT1.GetRecordCount()

    end
    
    def OJDTValidateJDT1Accounts(bizObject)
	bizEnv= bizObject.GetEnv ()
	dagACT= bizObject.GetDAG(ACT, ao_Main)
	dagJDT1= bizObject.GetDAG(JDT, ao_Arr1)
	numOfRecs= dagJDT1.GetRealSize(dbmDataBuffer)
	lock= !(bizObject.IsUpdateNum() || bizObject.IsExCommand3(ooEx3DontTouchNextNum))
	ooErr= bizEnv.GetByOneKey(dagACT, OACT_KEYNUM_PRIMARY, actNum, lock)
	ooErr= bizEnv.GetAccountSegmentsByCode (tmpStr, code, true)

    end
    
    def OJDTValidateJDTOfLocalCard(bizObject)
	isLocalCard= false
	bizEnv= bizObject.GetEnv ()
	dagJDT1= bizObject.GetDAGNoOpen(SBOString(JDT),ao_Arr1)
	dagJDT= bizObject.GetDAGNoOpen(SBOString(JDT))
	numOfRecs= dagJDT1.GetRecordCount()
	dagCRD= bizObject.OpenDAG (CRD)
	ooErr= bizEnv.GetByOneKey(dagCRD, OCRD_KEYNUM_PRIMARY, shortName, true)

    end
    
    def OJDTCheckFcInLocalCard(bizObject, dagJDT1, rec)
	
    end
    
    def OJDTCheckBalnaceTransection(bizObject, checkForgn)
	dagJDT1=@ NULL
	dagJDT1= bizObject.GetDAGNoOpen(SBOString(JDT),ao_Arr1)
	ooErr= MONEY_Add (&credit, &tmpM)
	ooErr= MONEY_Add (&debit, &tmpM)
	ooErr= MONEY_Add (&creditS, &tmpM)
	ooErr= MONEY_Add (&debitS, &tmpM)
	ooErr= MONEY_Add (&creditF, &tmpM)
	ooErr= MONEY_Add (&debitF, &tmpM)

    end
    
    def ComplateStampLine()
	ooErr=@ noErr
	sysCurr={0}
	localCurr={0}
	currency= {0}
	bizEnv= GetEnv ()
	dagJDT= GetDAG (JDT)
	dagJDT1= GetDAG(JDT, ao_Arr1)
	dagACT= GetDAG (ACT)
	dagVTG= GetDAG(VTG)
	money=@ minAmount
	found=@ TRUE
	debitSide=@ FALSE
	debitSide=@ TRUE
	debitSide=@ TRUE
	tmpM2=@ tmpM
	tmpM2=@ tmpM
	found=@ FALSE
	found=@ TRUE
	ooErr= DAG_SetSize (dagJDT1, numOfRecs2 + 1, dbmKeepData)
	ooErr= DBD_GetInNewFormat (dagVTG, &dagRES)
	multiCurr=@ FALSE
	money=@ debit
	money=@ baseDebit
	money=@ debitSC
	money=@ baseDebitSC
	money=@ debit
	ooErr= GNLocalToForeignRate (&money, currency, dateStr, 0.0, &frnAmnt, GetEnv ())
	money=@ credit
	money=@ baseCredit
	money=@ creditSC
	money=@ baseCreditSC
	money=@ credit
	ooErr= GNLocalToForeignRate (&money, currency, dateStr, 0.0, &frnAmnt, GetEnv ())
	EnforceBalance= false
	EnforceBalance= true
	creditSide=@ TRUE
	debitSide=@ TRUE

    end
    
    def CopyNoType(other)
	bizObject= (CTransactionJournalObject*) &other
	m_jrnlKeys= bizObject.GetJournalKeys ()
	m_stornoExtraInfoCreator= ((CTransactionJournalObject&)other).m_stornoExtraInfoCreator
	m_isPostingPreviewMode= bizObject.m_isPostingPreviewMode
	
		}
	

    end
    
    def RecordHist(bizObject, dag)
	num= 0
	bizEnv= bizObject.GetEnv ()
	dagOBJ= bizObject.GetDAG ()
	bizObjId= bizObject.GetID().strtol()
	sboErr= IsValidUserPermissions()
	series= bizEnv.GetDefaultSeriesByDate (bizObject.GetBPLId (), SBOString (JDT), refDate)
	seqManager= GetEnv ().GetSequenceManager ()
	sboErr= seqManager.LoadDfltSeq (*this)
	sboErr= seqManager.FillDAGBySeq (*this)
	sboErr= seqManager.HandleSerial (*this)
	pManager= bizEnv.GetSupplCodeManager()
	sboErr= pManager.CodeChange(*this, PostDate)
	sboErr= pManager.CheckCode(*this)
	sboErr= GetNextSerial (TRUE)
	theKey= GetInternalKey ()
	num= GetNextNum()
	transType== IPF || transType == ITR || transType == CHO || transType == JST || transType == IQR ||
	theKey=@ createdBy
	transType== IPF || transType == ITR || transType == CHO || transType == JST || transType == IQR  ||
	theKey=@ baseRef

    end
    
    def OnCanCancel()
	bizEnv= GetEnv()
	ooErr=@ noErr
	canCancelJE= false
	dagJDT= GetDAG ()
	dagJDT1= GetDAG (JDT, ao_Arr1)
	sourceDoc= 0
	sourceDoc== OPEN_BLNC_TYPE || sourceDoc == CLOSE_BLNC_TYPE ||
	canceledTrans= 0
	canCancelJE= false
	canCancelJE= false
	dagORCT= GetDAG (sourceDoc)
	isCentralizedPayment= dagORCT.GetColStrAndTrim (ORCT_BPL_CENT_PMT, 0, coreSystemDefault)
	pmntTransId= dagORCT.GetColStrAndTrim (ORCT_TRANS_NUM, 0, coreSystemDefault).strtol ()
	currTransId= dagJDT.GetColStrAndTrim (OJDT_JDT_NUM, 0, coreSystemDefault).strtol ()
	createdBy= dagJDT.GetColStrAndTrim (OJDT_CREATED_BY, 0, coreSystemDefault).strtol ()
	pmtAbsEntry= dagORCT.GetColStrAndTrim (ORCT_ABS_ENTRY, 0, coreSystemDefault).strtol ()
	createdBy== pmtAbsEntry
	canceledTrans= 0
	tOJDT= stmt.From (bizEnv.ObjectToTable (JDT, ao_Main))
	cancelNum= 0
	canCancelJE= false
	ooErr= e.GetCode ()

    end
    
    def OnCancel()
	bizEnv= GetEnv()
	dagJDT= GetDAG ()
	dagJDT1= GetDAG (JDT, ao_Arr1)
	sboErr= DBD_GetKeyGroup (dagJDT1, JDT1_KEYNUM_PRIMARY, SBOString(canceledTrans), TRUE)
	series= GetEnv().GetDefaultSeries(SBOString(JDT))
	sboErr= DoSingleStorno ()

    end
    
    def IsPeriodIndicCondNeeded()
	
    end
    
    def BuildRelatedBoeQuery(tableStruct, numOfConds, iterationType, numOfTables, condStruct, joinCondStructForOtherObj, joinCondStructBoe)
	bizEnv= GetEnv ()
	absJoinField=@ OBOT_ABS_ENTRY
	jdt1JoinField=@ JDT1_SRC_ABS_ID
	objJoinField=@ BOT
	absJoinField=@ ORCT_NUM
	objJoinField=@ RCT
	jdt1JoinField=@ JDT1_CREATED_BY
	absJoinField=@ ODPS_ABS_ENT
	objJoinField=@ DPS
	jdt1JoinField=@ JDT1_SRC_ABS_ID
	
		}
	

    end
    
    def AmountChangedSinceMDRAssigned_APA(mdrObj, dagJDT1, rec, changedDim)
	changed= false
	dimObj= static_cast<CCostAccountingDimension*>(GetEnv().CreateBusinessObject(dim))
	changedDim= dimIdx + 1

    end
    
    def UpgradeDpmLineTypeUsingJDT1(paymentObj)
	ooErr=@ noErr
	dagRES=@NULL
	numOfConds=0
	bizEnv= GetEnv ()
	isIncoming= (paymentObj == RCT) ? true : false
	ooErr= ARP_GetAccountByType (bizEnv, NULL, ARP_TYPE_DOWN_PAYMENT, dpAccount, true, (TCHAR*)(isIncoming?VAL_CUSTOMER:VAL_VENDOR))
	dagJDT1= OpenDAG (JDT, ao_Arr1)
	ooErr= DBD_GetInNewFormat (dagJDT1, &dagRES)
	condStruct2= new DBD_CondStruct[NUM_OF_MAX_ITERATIONS*2]
	resSumField= 2
	rec= 0
	numOfConds= 0
	= -1
	val=@ ooCtrlAct_PaidDPRequestType
	val=@ ooCtrlAct_DPRequestType
	ooErr= DBD_UpdateCols (dagJDT1)

    end
    
    def UpgradeDpmLineTypeUsingRCT2(object)
	ooErr=@ noErr
	dagRes=@ NULL
	dagQuery= GetDAG ()
	 
											(long) ooCtrlAct_PaidDPRequestType
	ooErr= UpgradeDpmLineTypeExecuteQuery (dagQuery, &dagRes, object, dpmStageArr[stage] == (long) ooCtrlAct_DPRequestType)
	ooErr=@ noErr
	ooErr= UpgradeDpmLineTypeUpdate (dagRes, object, dpmStageArr[stage] == (long) ooCtrlAct_DPRequestType)

    end
    
    def UpgradeDpmLineTypeExecuteQuery(dagQuery, dagRes, object, isFirst)
	ooErr=@ noErr
	bizEnv= GetEnv ()
	tables= &(dagQuery.GetDBDParams ()->GetCondTables ())
	tablePtr= &tables.AddTable ()
	conditions= &(dagQuery.GetDBDParams ()->GetConditions ())
	condPtr= &(conditions.AddCondition ())
	condPtr= &(conditions.AddCondition ())
	condPtr= &(conditions.AddCondition ())
	subTables= &(subParams.GetCondTables ())
	tablePtr= &subTables.AddTable ()
	subConditions= &(subParams.GetConditions ())
	condPtr= &(subConditions.AddCondition ())
	condPtr= &(subConditions.AddCondition ())
	condPtr= &(subConditions.AddCondition ())
	condPtr= &(subConditions.AddCondition ())
	condPtr= &(subConditions.AddCondition ())
	condPtr= &(subConditions.AddCondition ())
	ooErr= DBD_SetRes (&subParams, subResStruct, 1)
	condPtr= &(conditions.AddCondition ())
	subTables= &(subParamsNoOtherDocs.GetCondTables ())
	tablePtr= &subTables.AddTable ()
	subConditions= &(subParamsNoOtherDocs.GetConditions ())
	condPtr= &(subConditions.AddCondition ())
	condPtr= &(subConditions.AddCondition ())
	condPtr= &(subConditions.AddCondition ())
	condPtr= &(subConditions.AddCondition ())
	ooErr= DBD_SetRes (&subParamsNoOtherDocs, subResStructNoOtherDocs, 1)
	condPtr= &(conditions.AddCondition ())
	condPtr= &(conditions.AddCondition ())
	condPtr= &(conditions.AddCondition ())
	ooErr= DBD_GetInNewFormat (dagQuery, dagRes)

    end
    
    def UpgradeDpmLineTypeUpdate(dagRes, object, isFirst)
	ooErr=@ noErr
	dagJDT1= GetDAG (JDT, ao_Arr1)
	conditions= &(params.GetConditions ())
	condPtr= &(conditions.AddCondition ())
	condPtr= &(conditions.AddCondition ())
	condPtr= &(conditions.AddCondition ())
	condPtr= &(conditions.AddCondition ())
	condPtr= &(conditions.AddCondition ())
	dagResSize= dagRes.GetRealSize (dbmDataBuffer)
	ooErr= DBD_UpdateCols (dagJDT1)

    end
    
    def ValidateReportEU()
	bizEnv= GetEnv ()
	dagJDT= GetDAG ()
	sboErr=@ ooNoErr
	sboErr= ValidateVatReportTransType ()
	numOfBPfound= 0
	validateFedTaxId= bizEnv.IsVatPerLine ()
	sboErr= GetNumOfBPRecords (numOfBPfound, validateFedTaxId)
	sboErr=@ errNoMsg

    end
    
    def ValidateReport347()
	bizEnv= GetEnv ()
	dagJDT= GetDAG ()
	sboErr=@ ooNoErr
	sboErr= ValidateVatReportTransType()
	numOfBPfound= 0
	sboErr= GetNumOfBPRecords (numOfBPfound, false)
	sboErr=@  errNoMsg

    end
    
    def ValidateVatReportTransType()
	sboErr=@ ooNoErr
	dagJDT= GetDAG ()
	sboErr=@ errNoMsg

    end
    
    def ValidateBPLEx(bizObject)
	ooErr=@ noErr
	env= bizObject.GetEnv ()
	boJDT= static_cast<CTransactionJournalObject*> (env.CreateBusinessObject (SBOString (JDT)))
	ooErr= boJDT.ValidateBPL (bizObject.GetID () != SBOString (JDT) ? true : false)

    end
    
    def ValidateBPL(/)
	ooErr=@ noErr
	env= GetEnv ()
	dagJDT= GetDAG (JDT, ao_Main)
	dagJDT1= GetDAG (JDT, ao_Arr1)
	dag1Size= dagJDT1.GetRealSize (dbmDataBuffer)
	BPLName= dagJDT1.GetColStrAndTrim (JDT1_BPL_NAME, dag1Row, coreSystemDefault)
	BPLId= dagJDT1.GetColStr (JDT1_BPL_ID, dag1Row, coreSystemDefault).strtol ()
	BPLName= dagJDT1.GetColStr (JDT1_BPL_NAME, dag1Row, coreSystemDefault).Trim ()
	actCode= dagJDT1.GetColStr (JDT1_ACCT_NUM, dag1Row, coreSystemDefault).Trim ()
	shortName= dagJDT1.GetColStr (JDT1_SHORT_NAME, dag1Row, coreSystemDefault).Trim ()
	BPLName= dagJDT1.GetColStr (JDT1_BPL_NAME, dag1Row, coreSystemDefault).Trim ()
	 /*JDT1_SHORT_NAME
	 -1}
	accountCode= dagJDT1.GetColStr (accountCols[i], dag1Row, coreSystemDefault).Trim ()
	dagJDT2= GetDAG (JDT, ao_Arr2)
	dag2Size= dagJDT2.GetRealSize (dbmDataBuffer)
	wtaxCode= dagJDT2.GetColStr (JDT2_WT_CODE, dag2Row, coreSystemDefault).Trim ()
	dag1Row= -1
	BPLId= dagJDT1.GetColStr (JDT1_BPL_ID, dag1Row, coreSystemDefault).strtol ()
	 -1}
	accountCode= dagJDT2.GetColStr (accountCols[i], dag2Row, coreSystemDefault).Trim ()
	ooErr= IsBalancedByBPL ()

    end
    
    def ValidateBPLNumberingSeries()
	env= GetEnv ()
	series= GetSeries ()
	dagJDT1= GetArrayDAG (ao_Arr1)
	dag1Size= dagJDT1.GetRealSize (dbmDataBuffer)
	BPLId= dagJDT1.GetColStr (JDT1_BPL_ID, dag1Row, coreSystemDefault).strtol ()
	tmpNum= SBOString (series) + SBOString (SUB_TYPE_NONE)
	strObjCode= dagOBJ.GetColStrAndTrim (NNM1_NAME, 0, coreSystemDefault)

    end
    
    def IsBalancedByBPL()
	env= GetEnv ()
	
		}
	
	/*	PDAG dagJDT = GetDAG (JDT, ao_Main)
	transType= -1
	dagJDT1= GetArrayDAG (ao_Arr1)
	dag1Size= dagJDT1.GetRealSize (dbmDataBuffer)
	BPLId= -1

    end
    
    def GetNumOfBPRecords(numOfBPfound, false*/)
	dagJDT1= GetDAG (JDT, ao_Arr1)
	recCount= dagJDT1.GetRecordCount ()
	indexOfMissingTaxId= -1
	foundECTax= false
	bizEnv= GetEnv ()
	numOfBPfound= 0
	indexOfMissingTaxId=@ ii
	foundECTax= true

    end
    
    def UpgradeWorkOrderStep1()
	ooErr=@ooNoErr
	dagJDT=	GetDAG	()
	pResCol= updateStruct[0].GetResObject().AddResCol ()
	pResCol= updateStruct[1].GetResObject().AddResCol ()
	ooErr=	DBD_UpdateCols(dagJDT)

    end
    
    def UpgradeWorkOrderStep2()
	ooErr=@ooNoErr
	dagJDT1=	GetDAG	(JDT, ao_Arr1)
	pResCol= updateStruct[0].GetResObject().AddResCol ()
	ooErr=	DBD_UpdateCols(dagJDT1)

    end
    
    def UpgradeWorkOrderStep3()
	ooErr=@ooNoErr
	dagJDT=	GetDAG	()
	pResCol= updateStruct[0].GetResObject().AddResCol ()
	ooErr=	DBD_UpdateCols(dagJDT)

    end
    
    def UpgradeWorkOrderStep4()
	ooErr=@ooNoErr
	dagINM=	GetDAG	(INM)
	pResCol= updateStruct[0].GetResObject().AddResCol ()
	ooErr=	DBD_UpdateCols(dagINM)

    end
    
    def UpgradeLandedCosErr()
	ooErr=@ooNoErr
	tables2[1]
	dagJDT=	GetDAG()
	ooErr=	DBD_GetInNewFormat(dagJDT, &dagRes)
	numOfRecords= dagRes.GetRecordCount()
	ooErr=	DBD_UpdateCols(dagJDT)

    end
    
    def UpgradeWorkOrderErr()
	ooErr=@ooNoErr
	ooErr=	UpgradeWorkOrderStep1()
	ooErr=	UpgradeWorkOrderStep2()
	ooErr=	UpgradeWorkOrderStep3()
	ooErr=	UpgradeWorkOrderStep4()

    end
    
    def OJDTFillJDT1FromAccounts(accountsArrayFrom, accountsArrayRes, srcObject)
	linesAdded= false
	dagJDT1= GetArrayDAG(ao_Arr1)
	dagJDT= GetDAG()
	bizEnv= GetEnv()
	numOfAccts= accountsArrayFrom.GetSize ()
	linesAdded= true
	jdtLine= accountsArrayRes.GetSize()-1
	nDimCount= 1
	nDimCount=@ DIMENSION_MAX
	isNegative= accountsArrayRes[jdtLine]->sum.IsNegative() || accountsArrayRes[jdtLine]->sysSum.IsNegative() || accountsArrayRes[jdtLine]->frgnSum.IsNegative()
	useNegativeAmount= bizEnv.GetUseNegativeAmount()
	useNegativeAmount= true
	referenceLinksBPtarget= ((_STR_strcmp (accountsArrayRes[jdtLine]->actCode, accountsArrayRes[jdtLine]->shortName) != 0)
	ooErr= CRefLinksDef::ExecuteRefLinks (srcObject, this, (referenceLinksBPtarget) ? RLD_TYPE_BP_LINE_VAL : RLD_TYPE_LINE_VAL, jdtLine)
	dprAbsId= accountsArrayRes[jdtLine]->dprAbsId
	BPLId= CBusinessPlaceObject::IsValidBPLId (accountsArrayRes[jdtLine]->m_BPLId) ? accountsArrayRes[jdtLine]->m_BPLId : GetBPLId ()
	ooErr= CBusinessPlaceObject::GetBPLInfo (bizEnv, BPLId, bplInfo)
	numOfRecs= dagJDT1.GetRecordCount()

    end
    
    def OJDTFillAccountsFromJDT1RES(dag, resDagFields, accountsArrayRes)
	numOfRecs= dag.GetRecordCount()

    end
    
    def SetVatJournalEntryFlag()
	m_isVatJournalEntry= true

    end
    
    def OnGetTaxAdaptor()
	m_taxAdaptor= new CTaxAdaptorJournalEntry(this)

    end
    
    def CreateTax()
	taxAdaptor=  OnGetTaxAdaptor()
	ooErr=@ ooNoErr
	ooErr= taxAdaptor.SetJEDeferredTax()
	dagJDT= GetDAG()

    end
    
    def UpdateTax()
	taxAdaptor=  OnGetTaxAdaptor()
	dagJDT= GetDAG()

    end
    
    def LoadTax()
	taxAdaptor=  OnGetTaxAdaptor()
	dagJDT= GetDAG()
	ooErr= taxAdaptor.Load(transId)
	ooErr=@ ooNoErr

    end
    
    def OJDTSetPaymentJdtOpenBalanceSums(paymentObject, dagJDT1, resDagFields, fromOffset, foundCaseK)
	sboErr=@ noErr
	sboErr= CTransactionJournalObject::OJDTFillAccountsFromJDT1RES (dagJDT1, resDagFields, (AccountsArray*)&actsArray)
	sboErr= paymentObject.CalculateSplitLinesMatchSums (&actsArray, false)
	actsArraySize= actsArray.GetSize ()
	tmpM= actsArray[ii]->sum
	tmpFC= actsArray[ii]->frgnSum
	tmpSC= actsArray[ii]->sysSum

    end
    
    def UpgradeOJDTCreatedByForWOR()
	sboErr=@ noErr
	bizEnv= GetEnv ()
	dagJDT= GetDAG()
	dagQuery= GetDAG(CRD)
	tables= dagQuery.GetDBDParams ()->GetCondTables()
	tablePtr= &tables.AddTable ()
	tablePtr= &tables.AddTable ()
	sboErr= DBD_GetInNewFormat (dagQuery, &dagRes)
	conds= dagJDT.GetDBDParams ()->GetConditions ()
	cond= &conds.AddCondition ()
	sboErr= dagJDT.GetFirstChunk(UPG_OJDT_CREATED_BY_CHUNK_SIZE)
	numOfDoc1Recs= dagJDT.GetRecordCount ()
	newBaseNum= GetBaseEntry (dagRes, oldBaseNum)
	sboErr= dagJDT.UpdateAll ()
	sboErr= dagJDT.GetNextChunk(UPG_OJDT_CREATED_BY_CHUNK_SIZE)
	sboErr=@ noErr

    end
    
    def GetBaseEntry(dagRes, docNum)
	start= 0
	end= numOfRecs - 1
	start= mid + 1

    end
    
    def SetDebitCreditField()
	dagJDT1= GetDAG(JDT,ao_Arr1)

    end
    
    def UpgradeOJDTWithFolio()
	dagJDT=@ NULL
	dagJDT1=@ NULL
	ooErr=@ noErr
	bizEnv= GetEnv()
	dagJDT1= GetArrayDAG (ao_Arr1)
	dagJDT= GetDAG ()
	ooErr= dagJDT.GetFirstChunk (UPG_OJDT_FOLIO_CHUNK_SIZE)
	numOfRecs= dagJDT.GetRealSize(dbmDataBuffer)
	prefCol=@ OINV_FOLIO_PREFIX
	folioCol=@ OINV_FOLIO_NUMBER
	prefCol=@ OBOE_FOLIO_PREFIX
	folioCol=@ OBOE_FOLIO_NUMBER
	tables= dagJDT1.GetDBDParams ()->GetCondTables ()
	table= &tables.AddTable ()
	conditions= dagJDT1.GetDBDParams ()->GetConditions()
	cond= &conditions.AddCondition()
	ooErr= DBD_GetInNewFormat (dagJDT1, &dagFolioRes)
	ooErr=@ noErr
	ooErr= dagJDT.UpdateAll()
	ooErr= dagJDT.GetNextChunk(UPG_OJDT_FOLIO_CHUNK_SIZE)
	ooErr=@ noErr

    end
    
    def OnInitFlow()
	bizEnv= GetEnv ()

    end
    
    def CancelJournalEntryInObject(objectId, postingDate/*=EMPTY_STR*/, taxDate/*=EMPTY_STR*/, dueDate/*=EMPTY_STR*/)
	dagOBJ= GetDAG (objectId.GetBuffer ())
	colNum= dagOBJ.GetColumnByType (CREATED_JDT_NUM_FLD)
	colNum= dagOBJ.GetColumnByType (TRANS_ABS_ENT_FLD)
	ooErr= GetByKey (jdtNum, OJDT_KEYNUM_PRIMARY)
	dagJDT= GetDAG ()
	dagJDT1= GetArrayDAG (ao_Arr1)
	ooErr= DBD_GetKeyGroup (dagJDT1, JDT1_KEYNUM_PRIMARY, jdtNum, TRUE)
	bizEnv= GetEnv()
	dateColNum= dagOBJ.GetColumnByType (DATE_FLD)
	cancelMode=@ JE_CANCEL_DATE_FUTURE
	cancelMode=@ JE_CANCEL_DATE_SYSTEM
	cancelDate=@ sysDate
	cancelDate=@ postingDate
	taxDate=@ cancelDate
	series= bizEnv.GetDefaultSeriesByDate (dagJDT1.GetColStr (JDT1_BPL_ID, 0, coreSystemDefault).strtol (), SBOString (JDT), cancelDate)
	ooErr= DoSingleStorno ()

    end
    
    def SetJECancelDate(bizEnv, sCancelDate, dagOBJ, dagJDT, dagJDT1, taxDate, dueDate, cancelMode, sysDate)
	isPayment= RCT == objType || VPM == objType
	useFutureCancelMode= !isPayment
	jdt1RecCount= dagJDT1.GetRecordCount()

    end
    
    def UpgradeJDTCreateDate()
	dagJDT= GetDAG ()
	conditions= &dagJDT.GetDBDParams ()->GetConditions ()
	cond= &conditions.AddCondition ()
	cond= &conditions.AddCondition ()
	cond= &conditions.AddCondition ()
	cond= &conditions.AddCondition ()
	cond= &conditions.AddCondition ()
	ooErr= DBD_GetInNewFormat (dagJDT, &dagRES1)
	ooErr=@ noErr
	conditions= &dagJDT.GetDBDParams ()->GetConditions ()
	cond= &conditions.AddCondition ()
	ooErr= DBD_GetInNewFormat (dagJDT, &dagRES2)
	ooErr=@ noErr
	jj=0
	numOfRecsRES1= dagRES1.GetRecordCount ()
	numOfRecsRES2= dagRES2.GetRecordCount ()
	conditions= &dagJDT.GetDBDParams ()->GetConditions ()
	cond= &conditions.AddCondition ()
	ooErr= DBD_UpdateCols (dagJDT)

    end
    
    def UpgradeCreateDateSubQuery(subParams, subResStruct, subTableStruct, subCond, objectID)
	bizEnv= GetEnv ()
	isPDN= (objectID == PDN)

    end
    
    def UpgradeJDTCanceledDeposit()
	dagJDT= GetDAG ()
	dagJDT1= GetDAG (JDT, ao_Arr1)
	conditions= &dagJDT.GetDBDParams ()->GetConditions ()
	cond= &conditions.AddCondition ()
	cond= &conditions.AddCondition ()
	
		/*	SELECT T0.[TransId]
	ooErr= DBD_GetInNewFormat (dagJDT, &dagRES)
	ooErr=@ noErr
	numOfRecs= dagRES.GetRecordCount ()
	conditions= &dagJDT.GetDBDParams ()->GetConditions ()
	cond= &conditions.AddCondition ()
	ooErr= DBD_UpdateCols (dagJDT)
	conditions= &dagJDT1.GetDBDParams ()->GetConditions ()
	cond= &conditions.AddCondition ()
	ooErr= DBD_UpdateCols (dagJDT1)

    end
    
    def UpgradeJDT1VatLineToNo()
	sboErr=@ noErr
	bizEnv= GetEnv ()
	queryDag= GetDAG ()
	sboErr= DBD_UpdateCols (queryDag)

    end
    
    def UpgradeYearTransfer()
	dagJDT= GetDAG ()
	conditions= &dagJDT.GetDBDParams ()->GetConditions ()
	cond= &conditions.AddCondition ()
	cond= &conditions.AddCondition ()
	cond= &conditions.AddCondition ()
	cond= &conditions.AddCondition ()

    end
    
    def AddRowByParent(pParentDAG, lParentRow, pChildDAG)
	lDagSize= pChildDAG.GetSize (dbmDataBuffer)
	sboErr= pChildDAG.SetSize (lDagSize + 1, dbmKeepData)

    end
    
    def GetFirstRowByParent(pParentDAG, lParentRow, pChildDAG)
	lDagSize= pChildDAG.GetSize (dbmDataBuffer)
	lDagSize= pChildDAG.GetSize (dbmDataBuffer)

    end
    
    def GetNextRow(pParentDAG, pDAG, lRow, bNext)
	lDagSize= pDAG.GetSize (dbmDataBuffer)
	delta= bNext ? 1 : -1
	lDagSize= pDAG.GetSize (dbmDataBuffer)
	delta= bNext ? 1 : -1
	delta= bNext ? 1 : -1

    end
    
    def GetLogicRowCount(pParentDAG, lParentRow, pDAG)
	
		}
	

    end
    
    def RepairTaxTable()
	sboErr= 0
	bizEnv= GetEnv ()
	queryDag= GetDAG (TAX, ao_Main)

    end
    
    def IsBlockDunningLetterUpdateable()
	transType= GetID ()

    end
    
    def UpgradeJDTIndianAutoVat()
	sboErr=@ noErr
	bizEnv= GetEnv ()
	dagJDT= GetDAG ()
	sboErr= DBD_GetInNewFormat (dagJDT, &dagRes)
	sboErr=@ noErr
	dagJDT1= GetDAG (JDT, ao_Arr1)
	numOfTrans= dagRes.GetRecordCount ()
	workLoad= 1000
	step= numOfTrans / workLoad
	begin= i * workLoad
	end= (i + 1) * workLoad
	end=@ numOfTrans
	conditions= &dagJDT1.GetDBDParams ()->GetConditions ()
	cond= &conditions.AddCondition()
	sboErr= UpgradeJDTIndianAutoVatInt (dagJDT1)

    end
    
    def CheckColChanged(dag, col, /)
	ooErr= dag.GetChangesList (rec, colList)
	colCount= colList.GetSize ()
	currCol= colList[colIndex]->GetColNum ()

    end
    
    def UpgradeJDTIndianAutoVatInt(dagJDT1)
	isVatLine= false
	currentTransID= -1
	currentTaxType= 0
	totalLines= dagJDT1.GetRecordCount()
	currentTransID=@ tmpL
	currentTaxType= 0
	isVatLine= false
	currentTaxType= 0
	isVatLine= false
	isVatLine= true

    end
    
    def UpgradeOJDTUpdateDocType()
	sboErr=@ ooNoErr
	bizEnv= GetEnv ()
	dagJDT= bizEnv.OpenDAG (JDT)
	srcStr= bizEnv.GetDefaultJEType()
	sboErr= DBD_SetDAGCond (dagJDT, condStruct, 2)
	sboErr= DBD_SetDAGUpd (dagJDT, updStruct, 1)
	sboErr= DBD_UpdateCols (dagJDT)

    end
    
    def GetSeqParam()
	m_pSequenceParameter= new CSequenceParameter(OJDT_SEQ_CODE, OJDT_SERIAL)

    end
    
    def ValidateHeaderLocation()
	dagJDT= GetDAG()

    end
    
    def ValidateRowLocation(rec)
	dagJDT1= GetDAG (JDT, ao_Arr1)
	dagJDT= GetDAG(JDT, ao_Main)

    end
    
    def CompleteLocations()
	dagJDT= GetDAG()
	dagJDT1= GetDAG(ao_Arr1)
	location= 0
	seq= 0
	location= GetEnv().GetSequenceManager()->GetLocation(*this, seq)
	recCount= dagJDT1.GetRecordCount()

    end
    
    def CanArchiveAddWhere(bizEnv, canArchiveStmt, archiveDate, tObjectTable)
	subQ_unReconciledBPlines= *canArchiveStmt.CreateSubquery()
	tJDT1= subQ_unReconciledBPlines.From("JDT1")
	temp=@ archiveDate

    end
    
    def GetArchiveDocNumCol(outArcDocNumCol)
	outArcDocNumCol=@ OJDT_JDT_NUM

    end
    
    def CompleteDataForArchivingLog()
	sboErr= CBusinessObjectBase::CompleteDataForArchivingLog ()
	bizEnv= GetEnv ()
	selectedBPTempTbl= GetArchiveSelectedBPTblName ()
	dagTMP_ARC= GetDAG (TMP)
	tempArcTableName= dagTMP_ARC.GetTableName ()
	updTbl= updStmt.Update (tempArcTableName)
	stmt= *updStmt.CreateSubquery()
	tTDAR= stmt.From (tempArcTableName)
	tOJDT= stmt.Join (bizEnv.ObjectToTable (JDT), tTDAR)
	tJDT1= stmt.Join (bizEnv.ObjectToTable (JDT, ao_Arr1), tOJDT)
	tSelBPs= stmt.Join (selectedBPTempTbl, tJDT1)
	stmt= *updStmt.CreateSubquery()
	tTDAR= stmt.From (tempArcTableName)
	tOJDT= stmt.Join (bizEnv.ObjectToTable (JDT), tTDAR)
	tJDT1= stmt.Join (bizEnv.ObjectToTable (JDT, ao_Arr1), tOJDT)
	tSelBPs= stmt.Join (selectedBPTempTbl, tJDT1, DBQ_JT_LEFT_OUTER_JOIN)
	updTbl= updStmt.Update (tempArcTableName)

    end
    
    def GetTransIdByDoc(bizEnv, transId, transtype, createdby, /)
	sboErr=@ noErr
	tJDT= stmt.From (bizEnv.ObjectToTable (JDT, ao_Main))
	sboErr= e.GetCode ()

    end
    
    def BeforeDeleteArchivedObject(arcDelPref)
	sboErr=@ noErr
	dagDAR= GetDAG (DAR)
	sboErr= JEComp.execute()

    end
    
    def AfterDeleteArchivedObject(arcDelPref)
	sboErr=@ noErr
	dagCRD=@ NULL
	sboErr= GLFillActListDAG (&dagACT, GetEnv ())
	tCRD= stmt.From (GetEnv().ObjectToTable (CRD))
	numOfReturnedRecs= stmt.Execute (&dagCRD)
	sboErr= RBARebuildAccountsAndCardsInternal (dagACT, dagCRD, FALSE)

    end
    
    def GetWtSumField(currSource)
	
    end
    
    def UpdateWTInfo()
	ooErr=@ ooNoErr
	bizEnv= GetEnv()
	dagJDT= GetDAG(JDT)
	dagJDT1= GetDAG(JDT, ao_Arr1)
	recCountJDT1= dagJDT1.GetRecordCount()
	mainCurr= bizEnv.GetMainCurrency()
	sysCurr= bizEnv.GetSystemCurrency()
	isCard= shortName != account
	bpLineWt= debit == 0 ? credit : debit
	numBP= cardRec.GetSize()
	i= 0
	rec= cardRec[i]
	precent= cardSum[i].MulAndDiv(100, sum)
	bpLineWt= wtSum.MulAndDiv(precent, 100)
	bpLineWt= wtSumSC.MulAndDiv(precent, 100)
	bpLineWt= wtSumFC.MulAndDiv(precent, 100)
	bpLineWt= wtSum - (sumTmpD - sumTmpC)
	bpLineWtSC= wtSumSC - (sumTmpSCD - sumTmpSCC)
	bpLineWtFC= wtSumFC - (sumTmpFCD - sumTmpFCC)
	bpLineWtSC= wtSumSC + (sumTmpSCD - sumTmpSCC)
	bpLineWtFC= wtSumFC + (sumTmpFCD - sumTmpFCC)
	= -1
	= -1
	= -1

    end
    
    def GetWithHoldingTax(onlyPaymentCateg, row)
	dagJDT2= GetArrayDAG (ao_Arr2)
	dagJDT1= GetArrayDAG (ao_Arr1)
	docTotal= deb - cred

    end
    
    def LoadObjInfoFromDags(objInfo, dagObj, dagWTaxs, dagObjRows)
	sboErr=@ noErr
	tmpWTTaxSet= CDocumentObject::GetWTTaxSet(dagWTaxs, objInfo.m_DocTotal, true)

    end
    
    def GetWTaxReconDags(dagOBJ, dagObjWTax, dagObjRows)
	dagOBJ= GetDAG ()
	dagObjWTax= GetArrayDAG (ao_Arr2)
	dagObjRows= GetArrayDAG (ao_Arr1)

    end
    
    def CreateDocInfoQry(docInfoQry)
	bizEnv= GetEnv ()
	objType= GetID ().strtol ()
	tableObj= docInfoQry.From (bizEnv.ObjectToTable (objType, ao_Main))
	tableObjRow= docInfoQry.Join (bizEnv.ObjectToTable (objType, ao_Arr1), tableObj)
	tableObjWtax= docInfoQry.Join (bizEnv.ObjectToTable (objType, ao_Arr2), tableObj)

    end
    
    def YouHaveBeenReconciled(yourMatchData)
	ooErr=@ ooNoErr
	ooErr= UpdateWTOnRecon(yourMatchData)

    end
    
    def YouHaveBeenUnReconciled(yourMatchData)
	ooErr=@ ooNoErr
	ooErr= UpdateWTOnCancelRecon(yourMatchData)

    end
    
    def UpdateWTOnRecon(yourMatchData)
	ooErr=@ ooNoErr
	env= GetEnv ()
	withholdingCodeSet= GetWithHoldingTax (true)
	dagJDT2= GetArrayDAG (ao_Arr2)
	numOfRecsJDT2= dagJDT2.GetRealSize (dbmDataBuffer)
	dagJDT1= GetArrayDAG (ao_Arr1)
	offset= yourMatchData.transRowId
	dagJDT= GetDAG ()
	status= GetJDTReconStatus ()
	paymCtgWhtRec= 0
	paidWT= yourMatchData.WTSum
	paidFrgnWT= yourMatchData.WTSumFC
	paidSysWT= yourMatchData.WTSumSC
	ooErr= dagJDT1.Update ()
	ooErr= dagJDT1.Update(offset)
	ooErr= dagJDT2.Update (paymCtgWhtRec)

    end
    
    def GetJDTReconStatus()
	dagJDT1= GetArrayDAG (ao_Arr1)
	numRec= dagJDT1.GetRecordCount()
	creditSide= false
	creditSide= true
	balDueCol= creditSide ? JDT1_BALANCE_DUE_CREDIT : JDT1_BALANCE_DUE_DEBIT

    end
    
    def CalcPaidRatioOfOpenDoc(paidSum, paidSumInLocal, transRowId, calcFromTotal)
	dagJDT= GetDAG()
	dagJDT1= GetArrayDAG (ao_Arr1)
	local= true
	mainCurrency= GetEnv ().GetMainCurrency ()
	calcFromLocal= IWithHoldingAble::IsInLocalCurrency (paidSumInLocal, tmpDocCur, tmpMainCur)

    end
    
    def OnCanJDT2Update()
	ooErr=@ ooNoErr
	oopp= GetOnUpdateParams ()

    end
    
    def UpdateWTOnCancelRecon(yourMatchData)
	withholdingCodeSet= GetWithHoldingTax (true)
	dagJDT2= GetArrayDAG (ao_Arr2)
	numOfRecsJDT2= dagJDT2.GetRealSize (dbmDataBuffer)
	paymCtgWhtRec= 0
	dagJDT1= GetArrayDAG (ao_Arr1)
	offset= yourMatchData.transRowId
	dagJDT= GetDAG()
	ooErr= dagJDT.Update ()
	ooErr= dagJDT1.Update(offset)
	ooErr= dagJDT2.Update (paymCtgWhtRec)

    end
    
    def CheckWTValid()
	ooErr=@ ooNoErr
	dagJDT= GetDAG(JDT)
	dagJDT1= GetDAG(JDT, ao_Arr1)
	dagJDT2= GetDAG(JDT, ao_Arr2)
	hasBPline= false
	hasLiableline= false
	recCount= dagJDT1.GetRealSize(dbmDataBuffer)
	hasBPline= true
	isBpCredit= true
	bpDebCre=@ VAL_CREDIT
	bpDebCre=@ VAL_DEBIT
	numJdt2Rec= dagJDT2.GetRecordCount()

    end
    
    def GetWTBaseVATAmountField(curr)
	column=@ OJDT_WT_BASE_VAT_AMNT
	column=@ OJDT_WT_BASE_VAT_AMNT_SC
	column=@ OJDT_WT_BASE_VAT_AMNT_FC

    end
    
    def CheckMultiBP()
	dagJDT= GetDAG(JDT)
	dagJDT1= GetDAG(JDT, ao_Arr1)
	recJDT1= dagJDT1.GetRealSize (dbmDataBuffer)
	firstBP=@ shortname

    end
    
    def WTGetBPCodeImp(dagJDT, dagJDT1)
	recJDT1= dagJDT1.GetRealSize (dbmDataBuffer)

    end
    
    def WTGetBpCode()
	dagJDT= GetDAG (JDT)
	dagJDT1= GetDAG (JDT, ao_Arr1)

    end
    
    def WTGetCurrencyImp(dagJDT, dagJDT1)
	recJDT1= dagJDT1.GetRealSize (dbmDataBuffer)

    end
    
    def WTGetCurrency()
	dagJDT= GetDAG (JDT)
	dagJDT1= GetDAG (JDT, ao_Arr1)

    end
    
    def GetDfltWTCodes(wtInfo)
	
    end
    
    def GetBPCurrencySource()
	currency= WTGetCurrency ()
	mainCurr= m_env.GetMainCurrency()
	sysCurr= m_env.GetSystemCurrency()

    end
    
    def GetBPLineCurrency()
	dagJDT1= GetDAG(JDT, ao_Arr1)
	recCount= dagJDT1.GetRealSize(dbmDataBuffer)
	currency= m_env.GetMainCurrency()
	currency=@ bpCurr

    end
    
    def SetCurrRateForDOC(dagDOC)
	ooErr=@ noErr
	env= GetEnv ()
	dagJDT= GetDAG (JDT)

    end
    
    def SetCurrForAutoCompleteDOC5()
	
    end
    
    def PrePareDataForWT(wtAllCurBaseCalcParamsPtr, currSource, dagDOC, wtInfo)
	ooErr=@ ooNoErr
	dagJDT= GetDAG(JDT)
	baseCalcParam= wtAllCurBaseCalcParamsPtr.GetWtBaseCalcParams(currSource)
	wtBaseAmount= baseCalcParam.GetWTBaseAmount(wtInfo.wtBaseType)
	ooErr= m_WithholdingTaxMng.ODOCAutoCompleteDOC5 (*this, cplPara)

    end
    
    def JDTCalcWTTable(wtInfo, currSource, dagDOC, wtAllCurBaseCalcParamsPtr)
	ooErr=@ ooNoErr
	wtCurBaseCalcParamsPtr=
	wtInParamTableChangeListPtr=@ NULL

    end
    
    def GetJDT1MoneyCol(currSource, isDebit)
	 {JDT1_SYS_DEBIT
	 {JDT1_FC_DEBIT

    end
    
    def GetVATMoneyCol(currSource)
	}

    end
    
    def GetWTCredDebt(debCre)
	ooErr=@ ooNoErr
	dagJDT1= GetDAG(JDT, ao_Arr1)
	dagJDT2= GetDAG(JDT, ao_Arr2)
	recCount= dagJDT1.GetRealSize(dbmDataBuffer)
	debitSum=@ debitSumNet
	creditSum=@ creditSumNet
	debitSum=@ debitSumVat
	creditSum=@ creditSumVat
	debitSum= debitSumNet + debitSumVat
	creditSum= creditSumNet + creditSumVat
	debCre=@ VAL_CREDIT

    end
    
    def GetWTBaseAmount(currSource, baseParam)
	ooErr=@ ooNoErr
	dagJDT= GetDAG (JDT)
	dagJDT1= GetDAG(JDT, ao_Arr1)
	recCount= dagJDT1.GetRealSize(dbmDataBuffer)
	isDebit= false
	isDebit= true
	realCurr= WTGetCurrency ()
	mainCurr= bizEnv.GetMainCurrency().Trim ()
	frgnCurr=@ realCurr
	frgnAmnt= 1
	mnyTmp=@ frgnAmnt
	mnySumTmp= sum + sumVAT

    end
    
    def GetCRDDag()
	ooErr=@ ooNoErr
	dagCRD= GetDAG(CRD)
	dagJDT1= GetDAG(JDT, ao_Arr1)
	recCount= dagJDT1.GetRealSize(dbmDataBuffer)
	ooErr= DBD_Get(dagCRD)

    end
    
    def WTGetCurrSource()
	bizEnv= GetEnv ()
	mainCurr= bizEnv.GetMainCurrency()
	sysCurr= bizEnv.GetSystemCurrency()
	currency= GetBPLineCurrency ()

    end
    
    def WtAutoAddJDT1Line(dagJDT1, jdt1RecSize, dagJDT2, jdt2CurRec, isDebit, wtSide)
	ooErr=@ noErr
	 -1
		}
	OJDT_DUE_DATE
	 -1
		}

    end
    
    def WtUpdJDT1LineAmt(dagJDT1, jdt1CurRow, dagJDT2, jdt2CurRow, isDebit, wtAcctCode, wtSide)
	ooErr=@ ooNoErr

    end
    
    def OJDTIsDueDateRangeValid()
	env= GetEnv ()
	ooErr= env.GetPDDData (pddEnabled, maxDaysForDueDate)
	dagJDT= GetDAG ()
	dateField= dagJDT.GetColumnByType (DUE_DATE_FLD)
	ooErr= dagJDT.GetColStr (temp, dateField)
	ooErr= DBM_DATE_ToLong (&dueDate, temp)
	dateField= dagJDT.GetColumnByType (TAX_DATE_FLD)
	ooErr= dagJDT.GetColStr (temp, dateField)
	ooErr= DBM_DATE_ToLong (&docDate, temp)

    end
    
    def OJDTIsDocumentOrDueDateChanged()
	dagJDT= GetDAG ()

    end
    
    def CompleteWTInfo()
	ooErr=@ ooNoErr
	dagJDT= GetDAG(JDT)
	wtAllCurBaseCalcParamsPtr= new CWTAllCurBaseCalcParams()
	wtInfo= new CJDTWTInfo()
	dagDOC= m_env.OpenDAG(INV, ao_Main)
	dagJDT2= GetDAG(JDT, ao_Arr2)
	numOfRecs= dagJDT2.GetRecordCount ()
	wtCurrSource= GetBPCurrencySource ()

    end
    
    def CompleteWTLine()
	ooErr=@ ooNoErr
	dagJDT=@ NULL
	dagJDT1=@ NULL
	dagJDT2=@ NULL
	dagJDT= GetDAG (JDT)
	ooErr= CompleteWTInfo ()
	dagJDT1= GetDAG (JDT, ao_Arr1)
	dagJDT2= GetDAG (JDT, ao_Arr2)
	isDebit= (wtSide == VAL_DEBIT)
	found= false
	jdt1RecSize= 0
	jdt2RecSize= 0
	row= 0
	jdt1RecSize= dagJDT1.GetRealSize(dbmDataBuffer)
	jdt2RecSize= dagJDT2.GetRealSize(dbmDataBuffer)
	found= false
	found= true
	ooErr= WtUpdJDT1LineAmt (dagJDT1, row, dagJDT2, rec, isDebit, acctCode, wtSide)

    end
    
    def UpdateWTAmounts(wtAllCurBaseCalcParamsPtr)
	ooErr=@ ooNoErr
	dagJDT2= GetDAG(JDT, ao_Arr2)
	dagJDT= GetDAG(JDT)
	recCount= dagJDT2.GetRecordCount()

    end
    
    def CalcBpCurrRateForDocRate(rate)
	ooErr=@ ooNoErr
	dagJDT1= GetDAG (JDT, ao_Arr1)
	env= GetEnv ()
	recJDT1= dagJDT1.GetRealSize (dbmDataBuffer)
	flag= false
	flag= true
	flag= true
	rate= mLocal.MulAndDiv (1LL, mFrgn, &env, false)
	ooErr=@ errNoMsg

    end
    
    def SetSysCurrRateForDOC(dagDOC)
	ooErr=@ noErr
	env= GetEnv ()
	dagJDT= GetDAG (JDT)
	sysCurrAsMain= (bool) !GNCoinCmp (sysCurrency, mainCurrecny)
	rate=@ 1L
	ooErr= nsDocument::ODOCGetAndWaitUntilRateByDag (sysCurrency, dagJDT, &rate, env)
	ooErr=@ ooErrNoMsg

    end
    
    def UpgradeERDBaseTrans()
	ooErr=@ ooNoErr
	ooErr= UpgradeERDBaseTransFromBackup ()
	ooErr= 0
	ooErr= UpgradeERDBaseTransFromRef3 ()

    end
    
    def UpgradeERDBaseTransFromBackup()
	ooErr=@ ooNoErr
	bizEnv= GetEnv()
	ooErr= bizEnv.GetTD(dbmFixedTD).CreateFixedDefinition(JDT_ERDBASETRANSFIX_BT_NAME, colList, keyList)
	tablePtr= &(queryParams.GetCondTables ().AddTable ())
	dagRes=@ NULL
	dagQuery= bizEnv.OpenDAG (JDT, ao_Main)
	ooErr= DBD_GetInNewFormat(dagQuery, &dagRes)
	ooErr=@ dbmTableNotFound
	ooErr=@ noErr
	numOfRecs= dagRes.GetRecordCount ()
	ooErr= UpgradeERDBaseTransUpdateOne (transId, baseRef)
	tmpErr= bizEnv.GetTD (dbmFixedTD).DisposeDefinition (JDT_ERDBASETRANSFIX_BT_NAME)

    end
    
    def UpgradeERDBaseTransUpdateOne(transId, erdBaseTrans)
	ooErr=@ ooNoErr
	bizEnv= GetEnv ()
	dagJDT= bizEnv.OpenDAG (JDT, ao_Main)
	conditions= &(dagJDT.GetDBDParams ()->GetConditions ())
	condPtr= &conditions.AddCondition ()
	ooErr= DBD_SetDAGUpd (dagJDT, updStruct, 1)
	ooErr= DBD_UpdateCols (dagJDT)

    end
    
    def UpgradeERDBaseTransFromRef3()
	ooErr=@ ooNoErr
	bizEnv= GetEnv ()
	tablePtr= &(queryParams.GetCondTables ().AddTable ())
	tablePtr= &(queryParams.GetCondTables ().AddTable ())
	condNum= 0
	condPtr= &(queryParams.GetConditions ().AddCondition ())
	condPtr= &(queryParams.GetConditions ().AddCondition ())
	condPtr= &(queryParams.GetConditions ().AddCondition ())
	condPtr= &(queryParams.GetConditions ().AddCondition ())
	condPtr= &(queryParams.GetConditions ().AddCondition ())
	condPtr= &(queryParams.GetConditions ().AddCondition ())
	dagRes=@ NULL
	dagQuery= bizEnv.OpenDAG(BOT, ao_Arr1)
	ooErr= dagQuery.GetFirstChunk (JDT_ERDBASETRANSFIX_BATCH_SIZE, key, &dagRes)
	numOfRecs= dagRes.GetRecordCount ()
	baseTransCandidate= 0
	ooErr= UpgradeERDBaseTransFindBaseTrans (abbrevMap, account, shortName, ref3Line, &baseTransCandidate)
	ooErr= UpgradeERDBaseTransUpdateOne (transId, baseTransCandidate)
	ooErr= dagQuery.GetNextChunk (JDT_ERDBASETRANSFIX_BATCH_SIZE, key, &dagRes)

    end
    
    def UpgradeERDBaseTransFindBaseTrans(objectMap, inAccount, inShortName, inRef3Line, outBaseTransCandidate)
	ooErr=@ ooNoErr
	bizEnv= GetEnv ()
	numOfCandidates= 0
	sep1Pos= inRef3Line.Find (JDT_ERDBASETRANSFIX_REF3_SEPARATOR)
	periodCode= inRef3Line.Left (sep1Pos)
	sep2Pos= inRef3Line.Find (JDT_ERDBASETRANSFIX_REF3_SEPARATOR, sep1Pos + 1)
	docTypeCode= inRef3Line.Mid (sep1Pos + 1, sep2Pos - sep1Pos - 1)
	docNum= inRef3Line.Mid (sep2Pos + 1)
	objectId= omIt.first
	tablePtr= &(queryParams.GetCondTables ().AddTable ())
	tablePtr= &(queryParams.GetCondTables ().AddTable ())
	condNum= 0
	condPtr= &(queryParams.GetConditions ().AddCondition ())
	condPtr= &(queryParams.GetConditions ().AddCondition ())
	tablePtr= &(subQueryParams.GetCondTables ().AddTable ())
	subCondPtr= &(subQueryParams.GetConditions().AddCondition ())
	subCondPtr= &(subQueryParams.GetConditions().AddCondition ())
	subCondPtr= &(subQueryParams.GetConditions().AddCondition ())
	subCondPtr= &(subQueryParams.GetConditions().AddCondition ())
	subCondPtr= &(subQueryParams.GetConditions().AddCondition ())
	dagRes=@ NULL
	dagQuery= bizEnv.OpenDAG(BOT, ao_Arr1)
	ooErr= DBD_GetInNewFormat (dagQuery, &dagRes)
	ooErr=@ ooNoErr
	ooErr=@ ooNoErr

    end
    
    def UpgradeERDBaseTransAddDocNumConds(objectId, docNum, conds)
	condPtr= &(conds.AddCondition ())
	condPtr= &(conds.AddCondition ())
	condPtr= &(conds.AddCondition ())
	condPtr= &(conds.AddCondition ())

    end
    
    def UpgradeERDBaseTransGetTransIdCol(objectId)
	
		}
	

    end
    
    def UpgradeERDBaseTransGetFPRCol(objectId)
	
		}
	

    end
    
    def UpgradeERDBaseTransPopulateAbbrevMap(abbrevMap)
	
    end
    
    def GetCreateDate()
	date=@ EMPTY_STR
	dag= GetDAG ()

    end
    
    def UpgradeJDTCEEPerioEndReconcilations()
	sboErr=@ noErr
	bizEnv= GetEnv ()
	dagJDT1= GetDAG ()
	
		/*	SELECT T2.[ReconNum]
	conditions= &dagJDT1.GetDBDParams ()->GetConditions ()
	cond= &conditions.AddCondition()
	cond= &conditions.AddCondition()
	cond= &conditions.AddCondition()
	cond= &conditions.AddCondition()
	cond= &conditions.AddCondition()
	cond= &conditions.AddCondition()
	cond= &conditions.AddCondition()
	cond= &conditions.AddCondition()
	cond= &conditions.AddCondition()
	cond= &conditions.AddCondition()
	cond= &conditions.AddCondition()
	sboErr= DBD_GetInNewFormat (dagJDT1, &dagRes)
	sboErr=@ noErr
	numOfRecon= dagRes.GetRecordCount()
	dagUpdate= OpenDAG (JDT, ao_Arr1)
	sboErr= DBD_UpdateCols (dagUpdate)
	pResCol= updStruct[1].GetResObject().AddResCol ()
	pResCol= updStruct[2].GetResObject().AddResCol ()
	pResCol= updStruct[3].GetResObject().AddResCol ()
	sboErr= DBD_UpdateCols (dagUpdate)
	pResCol= updStruct[1].GetResObject().AddResCol ()
	pResCol= updStruct[2].GetResObject().AddResCol ()
	pResCol= updStruct[3].GetResObject().AddResCol ()
	sboErr= DBD_UpdateCols (dagUpdate)
	 [dbo].[ITR1] T1 
	sboErr= DBD_UpdateCols (dagUpdate)
	pResCol= updStruct[0].GetResObject().AddResCol ()
	pResCol= updStruct[1].GetResObject().AddResCol ()
	sboErr= DBD_UpdateCols (dagUpdate)
	sboErr= DBD_UpdateCols (dagUpdate)
	sboErr= DBD_UpdateCols (dagUpdate)

    end
    
    def CostAccountingAssignmentCheck(bizObject)
	sboErr=@ noErr
	bizEnv= bizObject.GetEnv()
	dagACT= bizObject.GetDAG(ACT, ao_Main)
	dagJDT1= bizObject.GetDAG(JDT, ao_Arr1)
	numOfRecs= dagJDT1.GetRealSize(dbmDataBuffer)
	sboErr= bizEnv.GetByOneKey(dagACT, OACT_KEYNUM_PRIMARY, accountCode, true)
	sboErr= bizEnv.GetAccountSegmentsByCode (accountCode, accountFormat, true)

    end
    
    def SetReconAcct(isInCancellingAcctRecon, acct)
	m_isInCancellingAcctRecon=@ isInCancellingAcctRecon

    end
    
    def LogBPAccountBalance(bpBalanceLogDataArray, keyNum)
	size= bpBalanceLogDataArray.size()
	dagCRD= GetDAG(CRD)
	ooErr=@ noErr
	ooErr= GetEnv().GetByOneKey (dagCRD, GO_PRIMARY_KEY_NUM, bpBalanceChangeLogData.GetCode(), true)
	
	    }
	

    end
    
    def IsManualJE(dagJDT)
	result= false

    end
    
    def IsCardLine(rec)
	dagJDT1= GetArrayDAG (ao_Arr1)
	recCount= dagJDT1.GetRealSize (dbmDataBuffer)
	ooErr= dagJDT1.GetColStr (accountNumber, JDT1_ACCT_NUM, rec, false, true)
	ooErr= dagJDT1.GetColStr (shortName, JDT1_SHORT_NAME, rec, false, true)

    end
    
    def ContainsCardLine()
	dagJDT1= GetArrayDAG (ao_Arr1)
	recCount= dagJDT1.GetRealSize (dbmDataBuffer)

    end
    
    def OJDTGetRate(bizObject, curSource, rate)
	dagJDT= bizObject.GetDAG()
	rate=@ 1L
	
		}
	

    end
    
    def OnGetByKey()
	ooErr=@ ooNoErr
	dagJDT=@NULL
	dagJDT1=@NULL
	dagCFT=@NULL
	bizEnv= GetEnv()
	ooErr= CSystemBusinessObject::OnGetByKey ()
	dagJDT= GetDAG()
	dagJDT1= GetDAG(JDT, ao_Arr1)
	res= 0
	dagCFT= GetDAG(objID)
	tOCFT= stmtCFT.From (bizEnv.ObjectToTable (CFT))
	res= stmtCFT.Execute(dagRes)
	ooErr= LoadTax()

    end
    
    def OnGetCostAccountingFields(costAccountingFieldMap)
	
    end
    
    def OJDTValidateCostAcountingStatus(bizObject, dagJDT)
	sboErr=@ noErr
	dagJDT1= bizObject.GetDAG(JDT, ao_Arr1)
	journalEntry= (CTransactionJournalObject*)bizObject.CreateBusinessObject(JDT)

    end
    
    def ReconcileDeferredTaxAcctLines()
	sboErr=@ ooNoErr
	bizEnv= GetEnv ()
	dagJDT= GetDAG ()
	dagJDT1= GetArrayDAG (ao_Arr1)
	sboErr= bizEnv.GetByOneKey (dagStornoJDT1, JDT1_KEYNUM_PRIMARY, stornoNum)
	interimType= (eInterimAcctType)tmpL
	interimType= (eInterimAcctType)tmpL
	sboErr= CManualMatchManager::CancelAllReconsOfJournalLine(bizEnv, stornoNum.strtol (), rec, false, date.GetString ())
	sboErr= deferredMM.Reconcile ()

    end
    
    def IsPaymentOrdered()
	dagJDT1= GetArrayDAG (ao_Arr1)
	numOfRecs= dagJDT1.GetRecordCount ()

    end
    
    def IsPaymentOrdered(bizEnv, transId, isOrdered)
	ooErr=@ ooNoErr
	isOrdered= false
	tJDT1= stmt.From (bizEnv.ObjectToTable (JDT, ao_Arr1))
	numOfRecs= stmt.Execute (pResDag)
	isOrdered= true
	ooErr= e.GetCode ()

    end
    
    def IsScAdjustment(isScAdjustment)
	dagJDT1= GetArrayDAG (ao_Arr1)
	numOfRecs= dagJDT1.GetRecordCount ()
	ooErr=@ noErr
	bizEnv= GetEnv()
	isScAdjustment= false
	dagRes=@ NULL
	ooErr= CManualMatchManager::GetReconciliationByTransaction (bizEnv, transID, lineNum, &dagRes)
	ooErr=@ noErr
	sizeOfRes= dagRes.GetRecordCount()
	isScAdjustment= true

    end
    
    def OnCommand(command)
	
    end
    
    def OnSetDynamicMetaData(commandCode)
	ooErr=@ noErr
	 -1}
	ooErr= SetDynamicMetaData (ao_Main, headerFields[i], false)
	 -1}
	ooErr= SetDynamicMetaData (ao_Arr1, cols[i], false, -1)

    end
    

end
