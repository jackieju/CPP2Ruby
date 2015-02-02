class CTransactionJournalObject
    def CreateObject(id, env)
	
    end
    
    def CTransactionJournalObject(id, (id, env), (env)
	
    end
    
    def ~CTransactionJournalObject()
	
    end
    
    def CompleteKeys()
	
    end
    
    def OnCreate()
	
    end
    
    def RettypeBlockLevel(bizEnv, id)
	
    end
    
    def RetBlockLevel(bizEnv)
	
    end
    
    def OnInitData()
	
    end
    
    def IsCurValid(crnCode, dagCRN)
	
    end
    
    def IsPaymentBlockValid(dagJDT1, rec)
	
    end
    
    def GetYearAndMonthEntry(dagJDT, byRef, rec, month, year)
	
    end
    
    def GetYearAndMonthEntryByDate(dateStr, month, year)
	
    end
    
    def RecordJDT(env, dagJDT, dagJDT1, reconcileBPLines)
	
    end
    
    def OnIsValid()
	
    end
    
    def OnUpdate()
	
    end
    
    def OnAutoComplete()
	
    end
    
    def CalculationFrnAmmounts(dagACT, dagCRD, found)
	
    end
    
    def CalculationSystAmmountOfTrans()
	
    end
    
    def CompleteForeignAmount()
	
    end
    
    def UpdateAccumulators(bizObject, rec, isCard)
	
    end
    
    def SetBudgetBlock(bizObject, blockLevel, testMoney, testYearMoney, testTmpM, testYearTmpM, workWithUI)
	
    end
    
    def GetBudgBlockErrorMessage(MonthmoneyStr, YearmoneyStr, acctKey, messgNumber, TCHAR*retMsgErr)
	
    end
    
    def DocBudgetRestriction(bizObject, acctCode, Sum, refDate, budgetAllYes, isWorkWithUI)
	
    end
    
    def UpdateDocBudget(bizObject, updateBgtPtr, dagDOC1, rec)
	
    end
    
    def GetSRObjectBudgetAcc(object)
	
    end
    
    def SetContraAccounts(dagJdt1, firstRec, maxRec, contraDebKey, contraCredKey, contraDebLines, contraCredLines)
	
    end
    
    def ValidateRelations(ArrOffset, rec, field, object, showError)
	
    end
    
    def OnCanUpdate()
	
    end
    
    def DocBudgetCurrentSum(bizObject, currentMoney, acctCode)
	
    end
    
    def OnUpgrade()
	
    end
    
    def SetToZeroNullLineTypeCols()
	
    end
    
    def SetToZeroOldLineTypeCols()
	
    end
    
    def CompleteTrans()
	
    end
    
    def CompleteJdtLine()
	
    end
    
    def SetJDTLineSrc(line, absEntry, srcLine)
	
    end
    
    def DoSingleStorno(/)
	
    end
    
    def ReconcileCertainLines()
	
    end
    
    def UpgradeBoeActs()
	
    end
    
    def FixVendorsAndSpainBoeBalance()
	
    end
    
    def IsCardAlreadyThere(updateCardBalanceCond, cardCode, startingRec, numOfCardConds)
	
    end
    
    def UpgradePeriodIndic()
	
    end
    
    def OnCheckIntegrityOnCreate()
	
    end
    
    def OnCheckIntegrityOnUpdate()
	
    end
    
    def OJDTCheckIntegrityOfJournalEntry(bizObject, checkForgn)
	
    end
    
    def OJDTCheckJDT1IsNotEmpty(bizObject)
	
    end
    
    def OJDTValidateJDT1Accounts(bizObject)
	
    end
    
    def OJDTValidateJDTOfLocalCard(bizObject)
	
    end
    
    def OJDTCheckFcInLocalCard(bizObject, dagJDT1, rec)
	
    end
    
    def OJDTCheckBalnaceTransection(bizObject, checkForgn)
	
    end
    
    def ComplateStampLine()
	
    end
    
    def CopyNoType(other)
	
    end
    
    def RecordHist(bizObject, dag)
	
    end
    
    def OnCanCancel()
	
    end
    
    def OnCancel()
	
    end
    
    def IsPeriodIndicCondNeeded()
	
    end
    
    def BuildRelatedBoeQuery(tableStruct, numOfConds, iterationType, numOfTables, condStruct, joinCondStructForOtherObj, joinCondStructBoe)
	
    end
    
    def AmountChangedSinceMDRAssigned_APA(mdrObj, dagJDT1, rec, changedDim)
	
    end
    
    def UpgradeDpmLineTypeUsingJDT1(paymentObj)
	
    end
    
    def UpgradeDpmLineTypeUsingRCT2(object)
	
    end
    
    def UpgradeDpmLineTypeExecuteQuery(dagQuery, dagRes, object, isFirst)
	
    end
    
    def UpgradeDpmLineTypeUpdate(dagRes, object, isFirst)
	
    end
    
    def ValidateReportEU()
	
    end
    
    def ValidateReport347()
	
    end
    
    def ValidateVatReportTransType()
	
    end
    
    def ValidateBPLEx(bizObject)
	
    end
    
    def ValidateBPL(/)
	
    end
    
    def ValidateBPLNumberingSeries()
	
    end
    
    def IsBalancedByBPL()
	
    end
    
    def GetNumOfBPRecords(numOfBPfound, false*/)
	
    end
    
    def UpgradeWorkOrderStep1()
	
    end
    
    def UpgradeWorkOrderStep2()
	
    end
    
    def UpgradeWorkOrderStep3()
	
    end
    
    def UpgradeWorkOrderStep4()
	
    end
    
    def UpgradeLandedCosErr()
	
    end
    
    def UpgradeWorkOrderErr()
	
    end
    
    def OJDTFillJDT1FromAccounts(accountsArrayFrom, accountsArrayRes, srcObject)
	
    end
    
    def OJDTFillAccountsFromJDT1RES(dag, resDagFields, accountsArrayRes)
	
    end
    
    def SetVatJournalEntryFlag()
	
    end
    
    def OnGetTaxAdaptor()
	
    end
    
    def CreateTax()
	
    end
    
    def UpdateTax()
	
    end
    
    def LoadTax()
	
    end
    
    def OJDTSetPaymentJdtOpenBalanceSums(paymentObject, dagJDT1, resDagFields, fromOffset, foundCaseK)
	
    end
    
    def UpgradeOJDTCreatedByForWOR()
	
    end
    
    def GetBaseEntry(dagRes, docNum)
	
    end
    
    def SetDebitCreditField()
	
    end
    
    def UpgradeOJDTWithFolio()
	
    end
    
    def OnInitFlow()
	
    end
    
    def CancelJournalEntryInObject(objectId, postingDate/*=EMPTY_STR*/, taxDate/*=EMPTY_STR*/, dueDate/*=EMPTY_STR*/)
	
    end
    
    def SetJECancelDate(bizEnv, sCancelDate, dagOBJ, dagJDT, dagJDT1, taxDate, dueDate, cancelMode, sysDate)
	
    end
    
    def UpgradeJDTCreateDate()
	
    end
    
    def UpgradeCreateDateSubQuery(subParams, subResStruct, subTableStruct, subCond, objectID)
	
    end
    
    def UpgradeJDTCanceledDeposit()
	
    end
    
    def UpgradeJDT1VatLineToNo()
	
    end
    
    def UpgradeYearTransfer()
	
    end
    
    def AddRowByParent(pParentDAG, lParentRow, pChildDAG)
	
    end
    
    def GetFirstRowByParent(pParentDAG, lParentRow, pChildDAG)
	
    end
    
    def GetNextRow(pParentDAG, pDAG, lRow, bNext)
	
    end
    
    def GetLogicRowCount(pParentDAG, lParentRow, pDAG)
	
    end
    
    def RepairTaxTable()
	
    end
    
    def IsBlockDunningLetterUpdateable()
	
    end
    
    def UpgradeJDTIndianAutoVat()
	
    end
    
    def CheckColChanged(dag, col, /)
	
    end
    
    def UpgradeJDTIndianAutoVatInt(dagJDT1)
	
    end
    
    def UpgradeOJDTUpdateDocType()
	
    end
    
    def GetSeqParam()
	
    end
    
    def ValidateHeaderLocation()
	
    end
    
    def ValidateRowLocation(rec)
	
    end
    
    def CompleteLocations()
	
    end
    
    def CanArchiveAddWhere(bizEnv, canArchiveStmt, archiveDate, tObjectTable)
	
    end
    
    def GetArchiveDocNumCol(outArcDocNumCol)
	
    end
    
    def CompleteDataForArchivingLog()
	
    end
    
    def GetTransIdByDoc(bizEnv, transId, transtype, createdby, /)
	
    end
    
    def BeforeDeleteArchivedObject(arcDelPref)
	
    end
    
    def AfterDeleteArchivedObject(arcDelPref)
	
    end
    
    def GetWtSumField(currSource)
	
    end
    
    def UpdateWTInfo()
	
    end
    
    def GetWithHoldingTax(onlyPaymentCateg, row)
	
    end
    
    def LoadObjInfoFromDags(objInfo, dagObj, dagWTaxs, dagObjRows)
	
    end
    
    def GetWTaxReconDags(dagOBJ, dagObjWTax, dagObjRows)
	
    end
    
    def CreateDocInfoQry(docInfoQry)
	
    end
    
    def YouHaveBeenReconciled(yourMatchData)
	
    end
    
    def YouHaveBeenUnReconciled(yourMatchData)
	
    end
    
    def UpdateWTOnRecon(yourMatchData)
	
    end
    
    def GetJDTReconStatus()
	
    end
    
    def CalcPaidRatioOfOpenDoc(paidSum, paidSumInLocal, transRowId, calcFromTotal)
	
    end
    
    def OnCanJDT2Update()
	
    end
    
    def UpdateWTOnCancelRecon(yourMatchData)
	
    end
    
    def CheckWTValid()
	
    end
    
    def GetWTBaseNetAmountField(curr)
	
    end
    
    def GetWTBaseVATAmountField(curr)
	
    end
    
    def CheckMultiBP()
	
    end
    
    def WTGetBPCodeImp(dagJDT, dagJDT1)
	
    end
    
    def WTGetBpCode()
	
    end
    
    def WTGetCurrencyImp(dagJDT, dagJDT1)
	
    end
    
    def WTGetCurrency()
	
    end
    
    def GetDfltWTCodes(wtInfo)
	
    end
    
    def GetBPCurrencySource()
	
    end
    
    def GetBPLineCurrency()
	
    end
    
    def SetCurrRateForDOC(dagDOC)
	
    end
    
    def SetCurrForAutoCompleteDOC5()
	
    end
    
    def PrePareDataForWT(wtAllCurBaseCalcParamsPtr, currSource, dagDOC, wtInfo)
	
    end
    
    def JDTCalcWTTable(wtInfo, currSource, dagDOC, wtAllCurBaseCalcParamsPtr)
	
    end
    
    def GetJDT1MoneyCol(currSource, isDebit)
	
    end
    
    def GetVATMoneyCol(currSource)
	
    end
    
    def GetWTCredDebt(debCre)
	
    end
    
    def GetWTBaseAmount(currSource, baseParam)
	
    end
    
    def GetCRDDag()
	
    end
    
    def WTGetCurrSource()
	
    end
    
    def WtAutoAddJDT1Line(dagJDT1, jdt1RecSize, dagJDT2, jdt2CurRec, isDebit, wtSide)
	
    end
    
    def WtUpdJDT1LineAmt(dagJDT1, jdt1CurRow, dagJDT2, jdt2CurRow, isDebit, wtAcctCode, wtSide)
	
    end
    
    def OJDTIsDueDateRangeValid()
	
    end
    
    def OJDTIsDocumentOrDueDateChanged()
	
    end
    
    def CompleteWTInfo()
	
    end
    
    def CompleteWTLine()
	
    end
    
    def UpdateWTAmounts(wtAllCurBaseCalcParamsPtr)
	
    end
    
    def CalcBpCurrRateForDocRate(rate)
	
    end
    
    def SetSysCurrRateForDOC(dagDOC)
	
    end
    
    def UpgradeERDBaseTrans()
	
    end
    
    def UpgradeERDBaseTransFromBackup()
	
    end
    
    def UpgradeERDBaseTransUpdateOne(transId, erdBaseTrans)
	
    end
    
    def UpgradeERDBaseTransFromRef3()
	
    end
    
    def UpgradeERDBaseTransFindBaseTrans(objectMap, inAccount, inShortName, inRef3Line, outBaseTransCandidate)
	
    end
    
    def UpgradeERDBaseTransAddDocNumConds(objectId, docNum, conds)
	
    end
    
    def UpgradeERDBaseTransGetTransIdCol(objectId)
	
    end
    
    def UpgradeERDBaseTransGetFPRCol(objectId)
	
    end
    
    def UpgradeERDBaseTransPopulateAbbrevMap(abbrevMap)
	
    end
    
    def UpgradeDOC6VatPaidForFullyBasedCreditMemos(objID)
	
    end
    
    def UpgradeODOCVatPaidForFullyBasedCreditMemos(objID)
	
    end
    
    def GetCreateDate()
	
    end
    
    def RepairEquVatRateOfJDT1()
	
    end
    
    def RepairEquVatRateOfJDT1ForOneObject(objectId)
	
    end
    
    def UpdateIncorrectEquVatRate(dagRes)
	
    end
    
    def UpdateIncorrectEquVatRateOneRec(dagRes, rec)
	
    end
    
    def UpgradeJDTCEEPerioEndReconcilations()
	
    end
    
    def CostAccountingAssignmentCheck(bizObject)
	
    end
    
    def SetReconAcct(isInCancellingAcctRecon, acct)
	
    end
    
    def LogBPAccountBalance(bpBalanceLogDataArray, keyNum)
	
    end
    
    def IsManualJE(dagJDT)
	
    end
    
    def IsCardLine(rec)
	
    end
    
    def ContainsCardLine()
	
    end
    
    def InitDataReport340(dagJDT)
	
    end
    
    def CompleteReport340(dagJDT, dagJDT1)
	
    end
    
    def ValidateReport340()
	
    end
    
    def OJDTGetRate(bizObject, curSource, rate)
	
    end
    
    def HandleFCExchangeRounding(dagJDT1, StdMap<SBOString, FCRoundingStruct, False, currencyMap)
	
    end
    
    def UpgradeFederalTaxIdOnJERow()
	
    end
    
    def UpgradeDprId(isSalesObject, introVersion1_Including, introVersion2)
	
    end
    
    def UpdateDprIdOnJERow(paymentObjType, dagRES)
	
    end
    
    def UpgradeDprIdForOneDprPayment(isSalesObject, introVersion)
	
    end
    
    def OnGetByKey()
	
    end
    
    def OnGetCostAccountingFields(costAccountingFieldMap)
	
    end
    
    def OJDTValidateCostAcountingStatus(bizObject, dagJDT)
	
    end
    
    def GetLinkMapMetaData(el)
	
    end
    
    def ReconcileDeferredTaxAcctLines()
	
    end
    
    def IsPaymentOrdered()
	
    end
    
    def IsPaymentOrdered(bizEnv, transId, isOrdered)
	
    end
    
    def IsScAdjustment(isScAdjustment)
	
    end
    
    def OnCommand(command)
	
    end
    
    def OnSetDynamicMetaData(commandCode)
	
    end
    

end
