class CTransactionJournalObject
   def CreateObject(id, env)
      _TRACER("CreateObject")
      return CTransactionJournalObject.new((id,env))

   end

   def CTransactionJournalObject(id, (id, env), (env)
      _TRACER("CSystemBusinessObject")
      m_isVatJournalEntry=false
      m_taxAdaptor=NULL
      m_stornoExtraInfoCreator=NULL
      m_reconcileBPLines=true
      m_pSequenceParameter=NULL
      m_isInCancellingAcctRecon=false
      m_isPostingPreviewMode=false
      m_isPostingTemplate=false

   end

   def ~CTransactionJournalObject()
      _TRACER("~CTransactionJournalObject")
      if m_taxAdaptor
         delete(m_taxAdaptor)

      end

      if m_pSequenceParameter

         m_pSequenceParameter=NULL

      end

      m_reconAcctSet.clear()

   end

   def CompleteKeys()
      dbErr=ooNoErr

      dbErr=CSystemBusinessObject::CompleteKeys()
      if dbErr
         return dbErr

      end

      dagJDT1=GetDAG(JDT

      if dagJDT1.GetDBDMgrPtr().isConnectionCaseSensitive()==true
         return ooNoErr

      end

      dagCRD=GetDAG(CRD)

      dagACT=GetDAG(ACT)

      jeLinesCount=dagJDT1.GetRealSize(dbmDataBuffer)

      rec=0

      begin
         shortName=dagJDT1.GetColStr(JDT1_SHORT_NAME

         if shortName.IsSpacesStr()
            next

         end

         dbErr=GetEnv().GetByOneKey(dagCRD,OCRD_KEYNUM_PRIMARY,shortName)
         if dbErr==ooNoErr
            dagJDT1.CopyColumn(dagCRD,JDT1_SHORT_NAME,rec,OCRD_CARD_CODE,0)

         else
            if dbErr==dbmNoDataFound
               dbErr=GetEnv().GetByOneKey(dagACT,OACT_KEYNUM_PRIMARY,shortName)
               if dbErr==noErr
                  dagJDT1.CopyColumn(dagACT,JDT1_SHORT_NAME,rec,OACT_ACCOUNT_CODE,0)

               else
                  SetErrorField(JDT1_SHORT_NAME)
                  SetErrorLine(rec+)
                  SetArrNum(ao_Arr1)
                  if dbErr==dbmNoDataFound
                     Message(OBJ_MGR_ERROR_MSG,GO_CRD_NAME_MISSING,shortName,OO_ERROR)
                     return ooInvalidObject

                  end

                  return dbErr

               end


            else
               SetErrorField(JDT1_SHORT_NAME)
               SetErrorLine(rec+)
               SetArrNum(ao_Arr1)
               return dbErr

            end

         end



         rec+=1
      end while (rec<jeLinesCount)

      return ooNoErr

   end

   def OnCreate()
      _TRACER("OnCreate")
      ooErr=noErr



      blockLevel=0
      typeBlockLevel = 0


      recCount=0
      ii = 0

      RetVal=0


      lastContraRec=0
      contraCredLines = 0
      contraDebLines = 0


      monSymbol=""











      Sp_Name=""

      mainCurr=""
      frnCurr = ""

      tmpStr=""

      msgStr1=""
      msgStr2 = ""

      moneyStr=""
      moneyMonthStr = ""
      moneyYearStr = ""

      acctCode=""


      balanced=FALSE

      budgetAllYes=FALSE
      bgtDebitSize

      fromImport=FALSE




      bizEnv=GetEnv()



      qc=TRUE
      qc=FALSE

      dagJDT=GetDAG()

      dagJDT1=GetDAG(JDT,ao_Arr1)
      dagJDT2=GetDAG(JDT

      if !dagJDT2.GetRealSize(dbmDataBuffer)
         dagJDT2.SetSize(0,dbmDropData)

      end

      dagCRD=GetDAG(CRD)
      if GetDataSource()==*VAL_OBSERVER_SOURCE&&bizEnv.IsVatPerLine()
         DAG_GetCount(dagJDT1,&numOfRecs)
         rec=0
         begin
            dagJDT1.GetColStr(tmpStr,JDT1_VAT_LINE,rec)
            if tmpStr[0]==VAL_YES[0]
               dagJDT1.GetColMoney(&debAmount,JDT1_DEBIT,rec,DBM_NOT_ARRAY)
               dagJDT1.GetColMoney(&credAmount,JDT1_CREDIT,rec,DBM_NOT_ARRAY)
               if debAmount.IsZero()&&credAmount.IsZero()
                  dagJDT1.GetColStr(tmpStr,JDT1_DEBIT_CREDIT,rec)
                  if tmpStr[0]==VAL_DEBIT[0]
                     dagJDT1.NullifyCol(JDT1_CREDIT,rec)

                  else
                     if tmpStr[0]==VAL_CREDIT[0]
                        dagJDT1.NullifyCol(JDT1_DEBIT,rec)

                     end

                  end


               end


            end



            rec+=1
         end while (rec<numOfRecs)


      end

      SetDebitCreditField()
      contraCredKey[0]='\0'
      contraDebKey[0]='\0'
      transTotal.SetToZero()
      transTotalChk.SetToZero()
      fTransTotal.SetToZero()
      sTransTotal.SetToZero()
      _STR_strcpy(mainCurr,bizEnv.GetMainCurrency())
      _STR_LRTrim(mainCurr)
      dagJDT.GetColMoney(&rateMoney,OJDT_TRANS_RATE,0,DBM_NOT_ARRAY)
      dagJDT.GetColStr(tempStr,OJDT_ORIGN_CURRENCY,0)
      _STR_LRTrim(tempStr)
      if GNCoinCmp(tempStr,mainCurr)==0||rateMoney.IsZero()
         tempStr[0]=0

      end

      DAG_GetCount(dagJDT1,&numOfRecs)
      if VF_RmvZeroLineFromJE(bizEnv)&&!bizEnv.IsZeroLineAllowed()
         rec=0
         begin
            dagJDT1.GetColMoney(&debAmount,JDT1_DEBIT,rec)
            dagJDT1.GetColMoney(&credAmount,JDT1_CREDIT,rec)
            dagJDT1.GetColMoney(&fDebAmount,JDT1_FC_DEBIT,rec)
            dagJDT1.GetColMoney(&fCredAmount,JDT1_FC_CREDIT,rec)
            dagJDT1.GetColMoney(&sDebAmount,JDT1_SYS_DEBIT,rec)
            dagJDT1.GetColMoney(&sCredAmount,JDT1_SYS_CREDIT,rec)

            dagJDT1.GetColMoney(&debBalanceDue,JDT1_BALANCE_DUE_DEBIT,rec)
            dagJDT1.GetColMoney(&credBalanceDue,JDT1_BALANCE_DUE_CREDIT,rec)
            dagJDT1.GetColMoney(&fDebBalanceDue,JDT1_BALANCE_DUE_FC_DEB,rec)
            dagJDT1.GetColMoney(&fCredBalanceDue,JDT1_BALANCE_DUE_FC_CRED,rec)
            dagJDT1.GetColMoney(&sDebBalanceDue,JDT1_BALANCE_DUE_SC_DEB,rec)
            dagJDT1.GetColMoney(&sCredBalanceDue,JDT1_BALANCE_DUE_SC_CRED,rec)
            if debAmount.IsZero()&&credAmount.IsZero()&&fDebAmount.IsZero()&&fCredAmount.IsZero()&&sDebAmount.IsZero()&&sCredAmount.IsZero()&&debBalanceDue.IsZero()&&credBalanceDue.IsZero()&&fDebBalanceDue.IsZero()&&fCredBalanceDue.IsZero()&&sDebBalanceDue.IsZero()&&sCredBalanceDue.IsZero()
               dagJDT1.RemoveRecord(rec)
               rec-=1
               numOfRecs-=1

            end



            rec+=1
         end while (rec<numOfRecs)


      end

      dagJDT.GetColLong(&transType,OJDT_TRANS_TYPE)
      if transType==-1
         dagJDT.SetColLong(JDT,OJDT_TRANS_TYPE)
         transType=JDT

      end


      dagJDT.GetColStr(deferredTax,OJDT_DEFERRED_TAX)
      deferredTax.Trim()
      isDeferredTax=(deferredTax==VAL_YES)

      rec=0
      begin
         dagJDT1.GetColStr(acctKey,JDT1_ACCT_NUM,rec)
         dagJDT1.GetColStr(cardKey,JDT1_SHORT_NAME,rec)
         itsCard=(_STR_stricmp(acctKey,cardKey)!=0)&&(!_STR_IsSpacesStr(cardKey))
         if itsCard
            def bpBalanceChangeLogData
               (bizEnv)
            end

            bpBalanceChangeLogData.SetCode(cardKey)
            bpBalanceChangeLogData.SetControlAcct(acctKey)
            bpBalanceChangeLogData.SetDocType(JDT)
            ooErr=bizEnv.GetByOneKey(dagCRD,GO_PRIMARY_KEY_NUM,cardKey,true)
            if ooErr!=noErr
               if ooErr==dbmNoDataFound
                  Message(OBJ_MGR_ERROR_MSG,GO_CARD_NOT_FOUND_MSG,cardKey,OO_ERROR)
                  return (ooErrNoMsg)

               else
                  return ooErr

               end


            end

            dagCRD.GetColMoney(&tempMoney,OCRD_CURRENT_BALANCE)
            bpBalanceChangeLogData.SetOldAcctBalanceLC(tempMoney)
            dagCRD.GetColMoney(&tempMoney,OCRD_F_BALANCE)
            bpBalanceChangeLogData.SetOldAcctBalanceFC(tempMoney)
            bpBalanceLogDataArray.Add(bpBalanceChangeLogData)

         end

         if _STR_IsSpacesStr(acctKey)
            dagJDT1.CopyColumn(GetDAG(CRD),JDT1_ACCT_NUM,rec,OCRD_DEB_PAY_ACCOUNT,0)
            dagJDT1.GetColStr(acctKey,JDT1_ACCT_NUM,rec)

         end

         ooErr=bizEnv.GetByOneKey(GetDAG(ACT),GO_PRIMARY_KEY_NUM,acctKey,true)
         if ooErr!=noErr
            if ooErr==dbmNoDataFound
               Message(OBJ_MGR_ERROR_MSG,GO_ACT_MISSING,acctKey,OO_ERROR)
               return (ooErrNoMsg)

            else
               return ooErr

            end


         end



         jdtOcrCols=""

         actOcrCols=""

         dimentionLen=VF_CostAcctingEnh(GetEnv())



         rec+=1
      end while (rec<numOfRecs)


   end

   def RettypeBlockLevel(bizEnv, id)
      _TRACER("RettypeBlockLevel")
      case id

      when POR
         if bizEnv.IsApplyBudget(bl_Orders)
            return JDT_TYPE_DOCS_BLOCK

         end


      when PDN
         if bizEnv.IsApplyBudget(bl_Deliveries)
            return JDT_TYPE_DOCS_BLOCK

         end


      when PRQ
         if bizEnv.IsApplyBudget(bl_PurchaseRequest)
            return JDT_TYPE_DOCS_BLOCK

         end


      else
         if bizEnv.IsApplyBudget(bl_Accounting)
            return JDT_TYPE_ACCOUNTING_BLOCK

         end



      end

      return JDT_NOT_TYPE_DOCS_BLOCK

   end

   def RetBlockLevel(bizEnv)
      _TRACER("RetBlockLevel")
      if bizEnv.GetBudgetBlockLevel()==VAL_BLOCK[0]
         return JDT_BGT_BLOCK

      else
         if bizEnv.GetBudgetBlockLevel()==VAL_NO[0]
            return JDT_NOT_BGT_BLOCK

         else
            if bizEnv.GetBudgetBlockLevel()==VAL_WARNING[0]
               return JDT_WARNING_BLOCK

            end

         end

      end

      return JDT_NOT_BGT_BLOCK

   end

   def OnInitData()
      _TRACER("OnInitData")


      dagJDT=GetDAG()

      ooErr=CSystemBusinessObject::OnInitData()
      if ooErr
         return ooErr

      end

      DBM_DATE_Get(dateString,this.GetEnv())
      GetDAG().SetColStr(dateString,OJDT_REF_DATE,0)
      ooErr=InitDataReport340(dagJDT)
      if ooErr
         return ooErr

      end

      return (ooErr)

   end

   def IsCurValid(crnCode, dagCRN)
      _TRACER("IsCurValid")


      bizEnv=GetEnv()

      ooErr=GNCheckCurrencyCode(bizEnv,crnCode,&exist)
      _STR_LRTrim(crnCode)
      if ooErr
         return ooErr
      end

      if !exist
         return dbmNoDataFound

      end

      return noErr

   end

   def IsPaymentBlockValid(dagJDT1, rec)
      _TRACER("IsPaymentBlockValid")

      strPaymentBlocked=""
      strBlockReason = ""

      isAcctLine=false
      isBlockReasonDfltValue = false

      dagJDT1.GetColStr(acctCode,JDT1_ACCT_NUM,rec)
      dagJDT1.GetColStr(shortName,JDT1_SHORT_NAME,rec)
      acctCode.Trim()
      shortName.Trim()
      isAcctLine=(acctCode==shortName)
      dagJDT1.GetColStr(strPaymentBlocked,JDT1_PAYMENT_BLOCK,rec)
      dagJDT1.GetColStr(strBlockReason,JDT1_PAYMENT_BLOCK_REF,rec)
      _STR_LRTrim(strPaymentBlocked)
      _STR_LRTrim(strBlockReason)
      isBlockReasonDfltValue=(((SBOString)))
      NONE_CHOICE==strBlockReason

   end

   def GetYearAndMonthEntry(dagJDT, byRef, rec, month, year)
      _TRACER("GetYearAndMonthEntry")

      if byRef
         dagJDT.GetColStr(date,JDT1_REF_DATE,rec)

      else
         dagJDT.GetColStr(date,JDT1_DUE_DATE,rec)

      end

      GetYearAndMonthEntryByDate(date,month,year)
      return

   end

   def GetYearAndMonthEntryByDate(dateStr, month, year)
      _TRACER("GetYearAndMonthEntryByDate")

      if !dateStr||!month||!year
         return

      end

      *month=*year=0L
      _STR_strcpy(date,dateStr)
      date[6]=0
      *month=_STR_atol(date+)
      date[4]=0
      *year=_STR_atol(date)
      return

   end

   def RecordJDT(env, dagJDT, dagJDT1, reconcileBPLines)
      _TRACER("RecordJDT")

      obj=(CTransactionJournalObject*)

      env.CreateBusinessObject(SBOString(JDT))
      dagLocalJDT=obj.GetDAG(JDT

      dagLocalJDT1=obj.GetDAG(JDT

      dagLocalJDT.Copy(dagJDT,dbmDataBuffer)
      dagLocalJDT1.Copy(dagJDT1,dbmDataBuffer)
      obj.m_reconcileBPLines=reconcileBPLines
      ooErr=obj.OnCreate()
      dagJDT.CopyColumn(dagLocalJDT,OJDT_JDT_NUM,0,OJDT_JDT_NUM,0)
      obj.Destroy()
      return ooErr

   end

   def OnIsValid()
      _TRACER("OnIsValid")

      dagACT
      dagCRD
      dagJDT1
      dagJDT2
      dag = GetDAG()
      dagNNM3
      dagCRD3












      fromBatch=FALSE
      msgHandled = FALSE
      fromImport = FALSE
      fromEoy = FALSE








      msgStr=""

      formatStr=""

      bizEnv=GetEnv()




      dagJDT1=GetDAG(JDT

      dagJDT2=GetDAG(JDT,ao_Arr2)
      DAG_GetCount(dagJDT1,&numOfRecs)
      nonZero=allowFcNotBalanced=allowFcMulty=multyFcDetected=FALSE
      _STR_GetStringResource(formatStr,HASH_FORM_NUM,HASH_TRANS_NUM_STR,&GetEnv())
      if IsExCommand(ooExInternalAutoMode)&&GetExDtCommand()==ooDoNotCheckDates
         fromEoy=TRUE

      end

      dag.GetColLong(&transNum,OJDT_JDT_NUM,0)
      if transNum<0
         transNum=0

      end

      dag.GetColLong(&series,OJDT_SERIES,0)
      if series

         dagNNM3=GetDAG(NNM,ao_Arr3)
         condStruct[0].colNum=NNM3_OBJ_CODE
         condStruct[0].condVal=JDT
         condStruct[0].operation=DBD_EQ
         condStruct[0].relationship=DBD_AND
         condStruct[1].colNum=NNM3_DOC_SUB_TYPE
         condStruct[1].condVal=SUB_TYPE_NONE
         condStruct[1].operation=DBD_EQ
         condStruct[1].relationship=DBD_AND
         condStruct[2].colNum=NNM3_SERIES
         condStruct[2].condVal=series
         condStruct[2].operation=DBD_EQ
         DBD_SetDAGCond(dagNNM3,condStruct,3)
         if DBD_Count(dagNNM3,TRUE)==0
            Message(JTE_JDT_FORM_NUM,JTE_SERIES_NOT_DEFINE_STR,NULL,OO_ERROR)
            return ooInvalidObject

         end

         isSeriesForCncl=false

         ooErr=CNextNumbersObject::IsSeriesForCancellation(bizEnv,series,isSeriesForCncl)
         IF_ERROR_RETURN(ooErr)
         if isSeriesForCncl
            CMessagesManager::GetHandle().Message(_147_APP_MSG_AP_AR_CANNOT_USE_CANCELLATION_SERIES,EMPTY_STR,this)
            return ooInvalidObject

         end


      end

      dag.GetColLong(&canceledTrans,OJDT_STORNO_TO_TRANS,0)
      if canceledTrans>0

         condStruct[0].colNum=OJDT_JDT_NUM
         condStruct[0].condVal=canceledTrans
         condStruct[0].operation=DBD_EQ
         condStruct[0].relationship=DBD_AND
         condStruct[1].colNum=OJDT_STORNO_TO_TRANS
         _STR_strcpy(condStruct[1].condVal,STR_0)
         condStruct[1].operation=DBD_GT
         DBD_SetDAGCond(dag,condStruct,2)
         if DBD_Count(dag,TRUE)>0
            Message(GO_OBJ_ERROR_MSGS(JDT),JDT_STORNO_ERROR,NULL,OO_ERROR)
            return ooInvalidObject

         end

         if GetCurrentBusinessFlow()==bf_Create
            condStruct[0].colNum=OJDT_STORNO_TO_TRANS
            condStruct[0].condVal=canceledTrans
            condStruct[0].operation=DBD_EQ
            condStruct[0].relationship=0
            DBD_SetDAGCond(dag,condStruct,1)
            if DBD_Count(dag,TRUE)>0
               CMessagesManager::GetHandle().Message(_1_APP_MSG_FIN_JDT_CANCELED_ERROR4,EMPTY_STR,this,canceledTrans)
               return ooInvalidObject

            end

            condStruct[0].colNum=OJDT_JDT_NUM
            condStruct[0].condVal=canceledTrans
            condStruct[0].operation=DBD_EQ
            condStruct[0].relationship=DBD_AND
            condStruct[1].colNum=OJDT_AUTO_STORNO
            _STR_strcpy(condStruct[1].condVal,VAL_YES)
            condStruct[1].operation=DBD_EQ
            DBD_SetDAGCond(dag,condStruct,2)
            if DBD_Count(dag,TRUE)>0
               Message(JTE_JDT_FORM_NUM,JTE_CANT_CANCEL_ERROR_STR,NULL,OO_ERROR)
               return ooErrNoMsg

            end


         end


      end

      ooErr=IsValidUserPermissions()
      IF_ERROR_RETURN(ooErr)
      ooErr=ValidateRelations(ao_Main,0,OJDT_TRANS_CODE,TRC)
      if ooErr
         return ooErr

      end

      ooErr=ValidateRelations(ao_Main,0,OJDT_PROJECT,PRJ)
      if ooErr
         return ooErr

      end

      ooErr=ValidateRelations(ao_Main,0,OJDT_INDICATOR,IDC)
      if ooErr
         return ooErr

      end

      ooErr=ValidateRelations(ao_Main,0,OJDT_DOC_TYPE,JET)
      if ooErr
         return ooErr

      end

      if VF_SupplCode(GetEnv())&&GetCurrentBusinessFlow()==bf_None&&(IsExCommand(ooExCloseBatch)||IsExCommand(ooExAddBatchClose))
         dagJDT=GetDAG(JDT


         dagJDT.GetColStr(strBatchNum,OJDT_BATCH_NUM)
         if !strBatchNum.IsNull()&&!strBatchNum.IsEmpty()
            pManager=bizEnv.GetSupplCodeManager()


            dagJDT.GetColStr(PostDate,OJDT_REF_DATE)
            ooErr=pManager.LoadDfltCodeToDag(*this,PostDate)
            IF_ERROR_RETURN(ooErr)
            ooErr=pManager.CheckCode(*this)
            if ooErr
               CMessagesManager::GetHandle().Message(_54_APP_MSG_CORE_SUPPL_CODE_CODE_EXIST,EMPTY_STR,this)
               return ooErrNoMsg

            end


         end


      end

      ooErr=ValidateReportEU()
      if ooErr
         return ooErr

      end

      ooErr=ValidateReport347()
      if ooErr
         return ooErr

      end

      ooErr=ValidateReport340()
      if ooErr
         return ooErr

      end

      if VF_JEWHT(bizEnv)

         dag.GetColStr(tmpStr,OJDT_AUTO_WT)
         tmpStr.Trim()
         if tmpStr==VAL_YES
            dag.GetColStr(tmpStr,OJDT_AUTO_VAT)
            tmpStr.Trim()
            if tmpStr!=VAL_YES
               Message(JTE_JDT2_FORM_NUM,JTE_WT_CANNOT_SET_YES,NULL,OO_ERROR)
               return ooInvalidObject

            end


         end

         if CheckWTValid()
            Message(JTE_JDT2_FORM_NUM,JTE_WT_BP_SIDE_ERR,NULL,OO_ERROR)
            return ooInvalidObject

         end

         if CheckMultiBP()
            SetErrorField(JDT1_SHORT_NAME)
            SetArrNum(ao_Arr1)
            Message(JTE_JDT2_FORM_NUM,JTE_MULTI_BP_WARNING_STR2,NULL,OO_ERROR)
            return ooInvalidObject

         end

         if (tmpStr==VAL_YES)&&(dagJDT2.GetRealSize(dbmDataBuffer)>0)
            ooErr=m_WithholdingTaxMng.ODOCValidateDOC5(*this,dag,dagJDT2,NULL)
            if ooErr
               return ooErr

            end


         end


      end

      if VF_MultipleRegistrationNumber(bizEnv)
         ooErr=ValidateHeaderLocation()
         if ooErr
            return ooErr

         end


      end

      dag.GetColStr(autoStorno,OJDT_AUTO_STORNO,0)
      if autoStorno[0]==VAL_YES[0]
         dag.GetColStr(reverseDate,OJDT_STORNO_DATE,0)
         dag.GetColStr(dateStr,OJDT_REF_DATE,0)
         if _STR_atol(reverseDate)<=_STR_atol(dateStr)
            Message(GO_OBJ_ERROR_MSGS(JDT),JDT_REVERSE_DATE_ERROR,NULL,OO_ERROR)
            return ooInvalidObject

         end

         useNegativeAmount=bizEnv.GetUseNegativeAmount()


         dag.GetColStr(autoWt,OJDT_AUTO_WT,0)
         if useNegativeAmount&&autoWt==VAL_YES&&VF_JEWHT(bizEnv)
            CMessagesManager::GetHandle().Message(_1_APP_MSG_FIN_JDT_NOT_REVERSE_NEG_WT,EMPTY_STR,this)
            return ooInvalidObject

         end

         if GetCurrentBusinessFlow()==bf_Update&&!IsExCommand(ooExAddBatchNoClose)

            dag.GetColLong(&canceledTrans,OJDT_JDT_NUM,0)
            condStruct[0].colNum=OJDT_JDT_NUM
            condStruct[0].condVal=canceledTrans
            condStruct[0].operation=DBD_EQ
            condStruct[0].relationship=DBD_AND
            condStruct[1].colNum=OJDT_STORNO_TO_TRANS
            _STR_strcpy(condStruct[1].condVal,STR_0)
            condStruct[1].operation=DBD_GT
            DBD_SetDAGCond(dag,condStruct,2)
            if DBD_Count(dag,TRUE)>0
               Message(GO_OBJ_ERROR_MSGS(JDT),JDT_STORNO_ERROR,NULL,OO_ERROR)
               return ooInvalidObject

            end

            condStruct[0].colNum=OJDT_STORNO_TO_TRANS
            condStruct[0].condVal=canceledTrans
            condStruct[0].operation=DBD_EQ
            condStruct[0].relationship=0
            DBD_SetDAGCond(dag,condStruct,1)
            if DBD_Count(dag,TRUE)>0
               CMessagesManager::GetHandle().Message(_1_APP_MSG_FIN_JDT_CANCELED_ERROR3,EMPTY_STR,this,canceledTrans)
               return ooInvalidObject

            end


         end


      end

      dag.GetColStr(dateStr,OJDT_REF_DATE,0)
      DBM_DATE_ToLong(&dateNum,dateStr)
      periodManager=bizEnv.GetPeriodCache()

      if _STR_IsSpacesStr(dateStr)
         DBM_DATE_Get(dateStr,bizEnv)
      end

      periodID=periodManager.GetPeriodId(bizEnv

      if coreNoCurrPeriodErr==bizEnv.CheckCompanyPeriodByDate(dateStr.GetString())
         SetErrorField(OJDT_REF_DATE)
         return (ooInvalidObject)

      end

      dag.GetColLong(&transType,OJDT_TRANS_TYPE,0)
      if bizEnv.IsBlockRefDateEdit()&&((transType>OPEN_BLNC_TYPE)||(MANUAL_BANK_TRANS_TYPE==transType))
         rec=0
         begin



         end while (rec)


      end


   end

   def OnUpdate()
      _TRACER("OnUpdate")



      bizEnv=GetEnv()


      periodMode=bizEnv.GetPeriodMode()
      if periodMode==ooPeriodLockedMode
         return (ooLockedPeriodErr)

      end

      dagJDT1=GetDAG(JDT,ao_Arr1)
      if VF_CashflowReport(bizEnv)
         def objCFTId
            (CFT)
         end

         dagCFT=GetDAGNoOpen(objCFTId)

         if dagCFT
            bo=static_cast


         end


      end


   end

   def OnAutoComplete()
      _TRACER("OnAutoComplete")
      ooErr=noErr


      sysCurr=""

      localCurr=""

      tempCurr=""

      lineCurr=""

      dateStr=""

      batchNum=""

      indicator=""





      sysFound=FALSE
      needBaseSum



      dagJDT=NULL
      dagJDT1 = NULL
      dagACT = NULL
      dagCRD = NULL

      bizEnv=GetEnv()

      StdMap

   end

   def CalculationFrnAmmounts(dagACT, dagCRD, found)
      ooErr=noErr

      dagJDT=NULL
      dagJDT1 = NULL

      mainCurr=""
      frnCurr = ""





      dateStr=""

      needFC=false
      bpFC = false

      bizEnv=GetEnv()

      StdMap

   end

   def CalculationSystAmmountOfTrans()
      _TRACER("CalculationSystAmmountOfTrans")
      ooErr=ooNoErr

      dagJDT=NULL
      dagJDT1 = NULL


      sideOfDebit
      forceBalance = true






      mainCurr
      lineCurr
      systCurr
      currStr
      prevCurr = ""


      bizEnv=GetEnv()

      dagJDT=GetDAG()
      dagJDT1=GetDAG(JDT,ao_Arr1)
      multiFrgCurr=false
      frgCurr=false
      getOnlyFromLocal=false
      notTranslateToSys=false
      hasOneFrgCurr=false
      _STR_strcpy(mainCurr,bizEnv.GetMainCurrency())
      _STR_strcpy(systCurr,bizEnv.GetSystemCurrency())
      DAG_GetCount(dagJDT1,&numOfRecs)
      tmpMoney.SetToZero()
      systMoney.SetToZero()
      rateLine.SetToZero()
      systDebTotal.SetToZero()
      systCredTotal.SetToZero()
      credFTotal.SetToZero()
      debFTotal.SetToZero()
      credit.SetToZero()
      debit.SetToZero()
      dagJDT.GetColStr(refDate,OJDT_REF_DATE,0)
      rec=0
      begin
         dagJDT1.GetColMoney(&tmpMoney,JDT1_FC_CREDIT,rec,DBM_NOT_ARRAY)
         MONEY_Add(&credFTotal,&tmpMoney)
         dagJDT1.GetColMoney(&tmpMoney,JDT1_FC_DEBIT,rec,DBM_NOT_ARRAY)
         MONEY_Add(&debFTotal,&tmpMoney)


         rec+=1
      end while (rec<numOfRecs)

      if !GNCoinCmp(mainCurr,systCurr)
         notTranslateToSys=true
         getOnlyFromLocal=true

      end

      if MONEY_Cmp(&credFTotal,&debFTotal)
         if !getOnlyFromLocal
            dagJDT.GetColStr(tmpStr,OJDT_AUTO_VAT,0)
            if tmpStr[0]==VAL_NO[0]
               getOnlyFromLocal=true

            else
               vatFound=false

               rec=0
               begin
                  dagJDT1.GetColStr(tmpStr,bizEnv.IsVatPerLine())


                  rec+=1
               end while (rec<numOfRecs)


            end


         end


      end


   end

   def CompleteForeignAmount()
      _TRACER("CompleteForeignAmount")
      ooErr=ooNoErr





      lineCurr
      prevCurr = ""

      found=false





      bizEnv=GetEnv()

      dagJDT=GetDAG()
      dagJDT1=GetDAG(JDT,ao_Arr1)
      dagACT=GetDAG(ACT)
      dagCRD=GetDAG(CRD)
      ooErr=CalculationFrnAmmounts(dagACT,dagCRD,found)
      case ooErr

      when ooUndefinedCurrency
         Message(ERROR_MESSAGES_STR,OO_UNDEFINED_CURRENCY,NULL,OO_ERROR)

      when ooNoRateErr
         Message(ERROR_MESSAGES_STR,OO_RATE_MISSING,NULL,OO_ERROR)

      when ooInvalidCardCode
         Message(OBJ_MGR_ERROR_MSG,GO_CRD_NAME_MISSING,NULL,OO_ERROR)


      end

      if ooErr
         return ooErr

      end

      _STR_strcpy(mainCurr,bizEnv.GetMainCurrency())
      dagJDT.GetColStr(refDate,OJDT_REF_DATE,0)
      DAG_GetCount(dagJDT1,&numOfRecs)
      if !found
         return ooNoErr

      end

      rec=0
      begin
         dagJDT1.GetColStr(lineCurr,JDT1_FC_CURRENCY,rec)
         _STR_LRTrim(lineCurr)
         if lineCurr[0]&&prevCurr[0]&&GNCoinCmp(prevCurr,lineCurr)
            return ooNoErr

         end

         if lineCurr[0]
            _STR_strcpy(prevCurr,lineCurr)

         end



         rec+=1
      end while (rec<numOfRecs)

      debit.SetToZero()
      credit.SetToZero()
      rec=0
      begin



      end while (rec)


   end

   def UpdateAccumulators(bizObject, rec, isCard)
      _TRACER("UpdateAccumulators")
      ooErr=noErr

      dagBGT=NULL
      dagBGT1 = NULL

      blockLevel=0
      typeBlockLevel = 0
      transType

      formatStr=""

      transTypeStr=""

      bgtStr=""

      acctCode=""

      finYear=""

      tmpStr=""

      bgtDebitSize=FALSE

      jdtDebitSize=FALSE


      budgetAllYes=FALSE





      bizEnv=bizObject.GetEnv()

      if isCard
         return (ooNoErr)

      end

      if bizEnv.IsComputeBudget()==FALSE
         return (ooNoErr)

      end

      tmpM.SetToZero()
      budgMoney.SetToZero()
      testMoney.SetToZero()
      testYearMoney.SetToZero()
      testTmpM.SetToZero()
      testYearTmpM.SetToZero()
      bizObject.GetDAG(ACT).GetColStr(bgtStr,OACT_BUDGET,0)
      _STR_LRTrim(bgtStr)
      if !_STR_strcmp(bgtStr,VAL_NO)
         return ooNoErr

      end

      localDags=FALSE
      if !DAG_IsValid(bizObject.GetDAG(BGT))
         dagBGT=bizObject.OpenDAG(BGT,ao_Main)
         _STR_strcpy(tmpStr,bizEnv.ObjectToTable(BGT,ao_Arr1))
         dagBGT1=bizObject.OpenDAG(BGT,ao_Arr1)
         localDags=TRUE
         _MEM_MYRPT0(_T("BGT Table not _STR_open"))

      else
         dagBGT=bizObject.GetDAG(BGT)
         dagBGT1=bizObject.GetDAG(BGT,ao_Arr1)

      end

      bizObject.GetDAG(ACT).GetColStr(acctCode,OACT_ACCOUNT_CODE,0)
      _STR_LRTrim(acctCode)
      bizObject.GetDAG(JDT,ao_Arr1).GetColStr(tmpStr,JDT1_REF_DATE,rec)
      bizEnv.GetCompanyDateRange(finYear,NULL)
      ooErr=CBudgetGeneralObject::GetBudgetRecords(dagBGT,dagBGT1,NULL,NULL,acctCode,finYear,-1,tmpStr,TRUE,true)
      if ooErr
         if localDags
            dagBGT.Close()
            dagBGT1.Close()

         end

         if ooErr!=dbmNoDataFound
            return ooErr

         end

         if ooErr==dbmNoDataFound
            return ooNoErr

         end


      end

      transType=bizObject.GetID().strtol()
      blockLevel=RetBlockLevel(bizEnv)
      typeBlockLevel=RettypeBlockLevel(bizEnv,transType)
      bizObject.GetDAG(JDT,ao_Arr1).GetColMoney(&debBudgMoney,JDT1_DEBIT,rec,DBM_NOT_ARRAY)
      if !debBudgMoney.IsZero()
         jdtDebitSize=TRUE

      end

      bizObject.GetDAG(JDT,ao_Arr1).GetColMoney(&credBudgMoney,JDT1_CREDIT,rec,DBM_NOT_ARRAY)
      bizObject.GetDAG(JDT,ao_Arr1).GetColMoney(&debBudgSysMoney,JDT1_SYS_DEBIT,rec,DBM_NOT_ARRAY)
      bizObject.GetDAG(JDT,ao_Arr1).GetColMoney(&credBudgSysMoney,JDT1_SYS_CREDIT,rec,DBM_NOT_ARRAY)
      if bizObject.IsExCommand(ooDontCheckTranses)&&blockLevel>=JDT_WARNING_BLOCK&&typeBlockLevel==JDT_TYPE_ACCOUNTING_BLOCK&&(OOIsSaleObject(transType)||OOIsPurchaseObject(transType))
         blockLevel=JDT_NOT_BGT_BLOCK

      end

      dagBGT.GetColMoney(&testYearMoney,OBGT_DEB_TOTAL,0,DBM_NOT_ARRAY)
      if !testYearMoney.IsZero()
         bgtDebitSize=TRUE

      end

      if bizEnv.GetBudgetWarningFrequency()==VAL_MONTHLY[0]
         dagBGT1.GetColMoney(&testMoney,BGT1_DEB_TOTAL,0,DBM_NOT_ARRAY)

      else
         dagBGT.GetColMoney(&testMoney,OBGT_DEB_TOTAL,0,DBM_NOT_ARRAY)

      end

      if blockLevel>JDT_NOT_BGT_BLOCK&&bgtDebitSize
         if bizEnv.GetBudgetWarningFrequency()==VAL_YEARLY[0]
            dagBGT.GetColMoney(&budgMoney,OBGT_DEB_REAL_TOTAL,0,DBM_NOT_ARRAY)
            MONEY_Add(&testTmpM,&budgMoney)
            dagBGT.GetColMoney(&budgMoney,OBGT_CRED_REAL_TOTAL,0,DBM_NOT_ARRAY)
            MONEY_Sub(&testTmpM,&budgMoney)

         end

         if bizEnv.GetBudgetWarningFrequency()==VAL_MONTHLY[0]
            dagBGT1.GetColMoney(&budgMoney,BGT1_DEB_REAL_TOTAL,0,DBM_NOT_ARRAY)
            MONEY_Add(&testTmpM,&budgMoney)
            dagBGT1.GetColMoney(&budgMoney,BGT1_CRED_REAL_TOTAL,0,DBM_NOT_ARRAY)
            MONEY_Sub(&testTmpM,&budgMoney)
            dagBGT.GetColMoney(&budgMoney,OBGT_DEB_REAL_TOTAL,0,DBM_NOT_ARRAY)
            MONEY_Add(&testYearTmpM,&budgMoney)
            dagBGT.GetColMoney(&budgMoney,OBGT_CRED_REAL_TOTAL,0,DBM_NOT_ARRAY)
            MONEY_Sub(&testYearTmpM,&budgMoney)

         end

         if jdtDebitSize
            MONEY_Add(&testTmpM,&debBudgMoney)
            MONEY_Add(&testYearTmpM,&debBudgMoney)

         else
            MONEY_Sub(&testTmpM,&credBudgMoney)
            MONEY_Sub(&testYearTmpM,&credBudgMoney)

         end

         ooErr=SetBudgetBlock(bizObject,blockLevel,&testMoney,&testYearMoney,&testTmpM,&testYearTmpM)
         if ooErr
            if localDags
               dagBGT.Close()
               dagBGT1.Close()

            end

            return ooErr

         end


      end

      dagBGT1.GetColMoney(&budgMoney,BGT1_DEB_REAL_TOTAL,0,DBM_NOT_ARRAY)
      MONEY_Add(&budgMoney,&debBudgMoney)
      dagBGT1.SetColMoney(&budgMoney,BGT1_DEB_REAL_TOTAL,0,DBM_NOT_ARRAY)
      dagBGT1.GetColMoney(&budgMoney,BGT1_CRED_REAL_TOTAL,0,DBM_NOT_ARRAY)
      MONEY_Add(&budgMoney,&credBudgMoney)
      dagBGT1.SetColMoney(&budgMoney,BGT1_CRED_REAL_TOTAL,0,DBM_NOT_ARRAY)
      dagBGT1.GetColMoney(&budgMoney,BGT1_DEB_REAL_SYS_TOTAL,0,DBM_NOT_ARRAY)
      MONEY_Add(&budgMoney,&debBudgSysMoney)
      dagBGT1.SetColMoney(&budgMoney,BGT1_DEB_REAL_SYS_TOTAL,0,DBM_NOT_ARRAY)
      dagBGT1.GetColMoney(&budgMoney,BGT1_CRED_REAL_SYS_TOTAL,0,DBM_NOT_ARRAY)
      MONEY_Add(&budgMoney,&credBudgSysMoney)
      dagBGT1.SetColMoney(&budgMoney,BGT1_CRED_REAL_SYS_TOTAL,0,DBM_NOT_ARRAY)
      dagBGT.GetColMoney(&budgMoney,OBGT_DEB_REAL_TOTAL,0,DBM_NOT_ARRAY)
      MONEY_Add(&budgMoney,&debBudgMoney)
      dagBGT.SetColMoney(&budgMoney,OBGT_DEB_REAL_TOTAL,0,DBM_NOT_ARRAY)
      dagBGT.GetColMoney(&budgMoney,OBGT_CRED_REAL_TOTAL,0,DBM_NOT_ARRAY)
      MONEY_Add(&budgMoney,&credBudgMoney)
      dagBGT.SetColMoney(&budgMoney,OBGT_CRED_REAL_TOTAL,0,DBM_NOT_ARRAY)
      dagBGT.GetColMoney(&budgMoney,OBGT_DEB_REAL_SYS_TOTAL,0,DBM_NOT_ARRAY)
      MONEY_Add(&budgMoney,&debBudgSysMoney)
      dagBGT.SetColMoney(&budgMoney,OBGT_DEB_REAL_SYS_TOTAL,0,DBM_NOT_ARRAY)
      dagBGT.GetColMoney(&budgMoney,OBGT_CRED_REAL_SYS_TOTAL,0,DBM_NOT_ARRAY)
      MONEY_Add(&budgMoney,&credBudgSysMoney)
      dagBGT.SetColMoney(&budgMoney,OBGT_CRED_REAL_SYS_TOTAL,0,DBM_NOT_ARRAY)
      ooErr=GOUpdateProc(*bizObject,dagBGT)
      if localDags
         dagBGT.Close()
         dagBGT1.Close()

      end

      return (ooErr)

   end

   def SetBudgetBlock(bizObject, blockLevel, testMoney, testYearMoney, testTmpM, testYearTmpM, workWithUI)
      _TRACER("SetBudgetBlock")
      ooErr=noErr


      monSymbol=""

      msgStr1=""
      msgStr2 = ""

      moneyStr=""
      moneyMonthStr = ""
      moneyYearStr = ""



      retBtn
      numTemplatesApplied = 0

      budgetAllYes=FALSE
      fromImport = FALSE
      doTemlates = FALSE

      ObjType=bizObject.GetID().strtol()

      bizEnv=bizObject.GetEnv()

      dagWDD=bizObject.GetDAG(WDD)
      numTemplatesApplied=dagWDD.GetRealSize(dbmDataBuffer)
      doTemlates=(Boolean)((OOIsSaleObject(ObjType)||OOIsPurchaseObject(ObjType))&&bizEnv.IsWorkFlow())
      if blockLevel<=JDT_NOT_BGT_BLOCK
         return ooNoErr

      end

      budgetAllYes=bizObject.IsExCommand(ooDontUpdateBudget)
      fromImport=bizObject.IsExCommand(ooImportData)
      if fromImport
         doTemlates=FALSE

      end

      _STR_strcpy(monSymbol,bizEnv.GetMainCurrency())
      strKeyTmp=bizObject.GetKeyStr()
      strKeyTmp.Trim()
      bizObject.SetKeyStr(strKeyTmp)
      MONEY_Sub(testMoney,testTmpM)
      if testMoney.IsPositive()||testMoney.IsZero()
         return ooNoErr

      end

      MONEY_Multiply(testMoney,-1,testMoney)
      MONEY_ToText(testMoney,moneyMonthStr,RC_SUM,monSymbol,bizEnv)
      MONEY_Sub(testYearMoney,testYearTmpM)
      MONEY_Multiply(testYearMoney,-1,testYearMoney)
      MONEY_ToText(testYearMoney,moneyYearStr,RC_SUM,monSymbol,bizEnv)
      if doTemlates
         condVal=(bizEnv.GetBudgetWarningFrequency()==VAL_MONTHLY[0])

      end


   end

   def GetBudgBlockErrorMessage(MonthmoneyStr, YearmoneyStr, acctKey, messgNumber, TCHAR*retMsgErr)
      _TRACER("GetBudgBlockErrorMessage")
      yearWarning=FALSE

      MformatStr=""

      YformatStr=""

      tmpStr=""



      monSymbol=""


      bizEnv=GetEnv()

      strKey=acctKey
      strKey.Trim()
      _STR_strcpy(accountFormat,strKey.GetBuffer())
      bizEnv.GetAccountSegmentsByCode(accountFormat,accountFormat,TRUE)
      _STR_strcpy(retMsgErr,_T(""))
      if bizEnv.GetBudgetWarningFrequency()==VAL_MONTHLY[0]
         _STR_GetStringResource(MformatStr,BGT0_FORM_NUM,BGT0_CHECK_MONTH_TOTAL_STR,&GetEnv())
         MONEY_FromText(&tmpMoney,YearmoneyStr,RC_SUM,monSymbol,bizEnv)
         if tmpMoney.IsPositive()
            _STR_GetStringResource(YformatStr,BGT0_FORM_NUM,BGT0_CHECK_YEAR_TOTAL_STR,&GetEnv())

         else
            MONEY_Multiply(&tmpMoney,-1L,&tmpMoney)
            MONEY_ToText(&tmpMoney,YearmoneyStr,RC_SUM,monSymbol,bizEnv)
            _STR_GetStringResource(YformatStr,BGT0_FORM_NUM,BGT0_BLNS_YEAR_TOTAL_STR,&GetEnv())

         end


      else
         yearWarning=TRUE
         _STR_GetStringResource(YformatStr,BGT0_FORM_NUM,BGT0_CHECK_YEAR_TOTAL_STR,&GetEnv())

      end

      if messgNumber==MONTH_ALERT_MESSAGE
         _STR_strcat(MformatStr,_T("\n"))
         _STR_strcat(MformatStr,YformatStr)
         _STR_sprintf(retMsgErr,MformatStr,accountFormat,MonthmoneyStr,accountFormat,YearmoneyStr)

      end

      if messgNumber==YEAR_ALERT_MESSAGE
         _STR_sprintf(retMsgErr,YformatStr,accountFormat,YearmoneyStr)

      end

      if messgNumber==BLOCK_ONE_MESSAGE
         if yearWarning
            _STR_sprintf(retMsgErr,YformatStr,accountFormat,YearmoneyStr)

         else
            _STR_sprintf(retMsgErr,MformatStr,accountFormat,MonthmoneyStr)

         end


      end

      return ooNoErr

   end

   def DocBudgetRestriction(bizObject, acctCode, Sum, refDate, budgetAllYes, isWorkWithUI)
      _TRACER("DocBudgetRestriction")
      ooErr=ooNoErr


      acctNum=0
      objType = bizObject.GetID().strtol()

      blockLevel=0
      typeBlockLevel



      tmpStr=""

      bgtStr=""

      finYear=""

      bgtDebitSide=FALSE





      bizEnv=bizObject.GetEnv()

      if bizEnv.IsComputeBudget()==FALSE
         bizObject.SetExCommand(ooDontUpdateBudget,fa_Set)
         return (ooNoErr)

      end

      blockLevel=RetBlockLevel(bizEnv)
      pDocObject=dynamic_cast


   end

   def UpdateDocBudget(bizObject, updateBgtPtr, dagDOC1, rec)
      _TRACER("UpdateDocBudget")
      ooErr=ooNoErr

      dagBGT=NULL
      dagBGT1 = NULL

      dagAct=NULL

      tmpStr=""

      finYear=""

      localDags=FALSE

      bgtDebitSide=FALSE
      subMoneyOper = FALSE



      acctNum=0



      bizEnv=bizObject.GetEnv()

      if !DAG::IsValid(dagDOC1)
         return dbmBadDAG

      end

      if bizEnv.IsComputeBudget()==FALSE
         return (ooNoErr)

      end

      case updateBgtPtr.objType

      when RDR
      when POR
      when PDN
      when DLN
      when PRQ

      when RDN
      when RPD
         subMoneyOper=TRUE

      else
         return (ooNoErr)


      end

      if (bizEnv.IsContInventory()||(bizEnv.IsCurrentLocalSettings(ITALY_SETTINGS)&&bizEnv.IsPurchaseAccounting()))&&(updateBgtPtr.objType==PDN||updateBgtPtr.objType==RPD)


         dagDOC1.GetColStr(itemCode,INV1_ITEM_CODE,rec)
         ooErr=CItemMasterData::IsInventoryItemEx(bizEnv,bizObject.GetDAGNoOpen(SBOString(ITM)),itemCode,result)
         if ooErr
            if ooErr==dbmNoDataFound
               ooErr=ooNoErr

            else
               return ooErr

            end


         else
            if result==true
               return ooNoErr

            end


         end


      end

      dagActWrp=bizEnv.GetDagPool().Get(make_pair(ACT

      dagAct=dagActWrp.GetPtr()
      dagBGT=bizObject.GetDAG(BGT)
      dagBGT1=bizObject.GetDAG(BGT,ao_Arr1)
      acctNum=0
      begin



      end while (acctNum)


   end

   def GetSRObjectBudgetAcc(object)
      _TRACER("GetSRObjectBudgetAcc")
      case object

      when QUT
      when PQT
         return baccNone

      when RDR
      when DLN
         return baccFutureIncomeInAcc

      when RDN
         return baccFutureIncomeOutAcc

      when POR
      when PDN
         return baccFutureExpenseInAcc

      when RPD
         return baccFutureExpenseOutAcc

      when INV
      when CIN
      when RPC
      when DPI
         return baccJdtInAcc

      when RIN
      when PCH
      when DPO
         return baccJdtOutAcc


      end

      return -1

   end

   def SetContraAccounts(dagJdt1, firstRec, maxRec, contraDebKey, contraCredKey, contraDebLines, contraCredLines)
      _TRACER("SetContraAccounts")




      env=GetEnv()

      DAG_GetCount(dagJdt1,&numOfRecs)
      if maxRec>numOfRecs
         maxRec=numOfRecs

      end

      if VF_EnableCorrAct(env)
         if contraCredLines==1&&contraDebLines>1
            contraDebKey[0]=_T('\0')

         else
            if contraDebLines==1&&contraCredLines>1
               contraCredKey[0]=_T('\0')

            else
               if contraDebLines>1&&contraCredLines>1
                  contraDebKey[0]=contraCredKey[0]=_T('\0')
                  SetErrorField(JDT1_CONTRA_ACT)
                  SetErrorLine(1)
                  Message(OBJ_MGR_ERROR_MSG,GO_CONTRA_ACNT_MISSING,NULL,OO_WARNING)

               end

            end

         end


      end

      rec=firstRec
      begin



      end while (rec)


   end

   def ValidateRelations(ArrOffset, rec, field, object, showError)
      _TRACER("ValidateRelations")


      dag=GetDAG(JDT

      bizEnv=GetEnv()

      isVat=FALSE

      tmpStr=""


      condNum=1

      dag.GetColStr(condStruct[0].condVal,field,rec)
      _STR_LRTrim(condStruct[0].condVal)
      condStruct[0].operation=DBD_EQ
      if object==VTG
         dag.GetColStr(tmpStr,JDT1_VAT_LINE,rec)
         if tmpStr[0]==VAL_YES[0]
            dag.GetColStr(accountNum,JDT1_ACCT_NUM,rec)
            if accountNum.IsSpacesStr()
               dag.GetColStr(vatGroup,JDT1_VAT_GROUP,rec)
               _STR_LRTrim(vatGroup)
               CMessagesManager::GetHandle().Message(_1_APP_MSG_FIN_TE_TAX_ACCOUNT_MISSING1,EMPTY_STR,&bizEnv,vatGroup.GetBuffer())
               return ooInvalidObject

            end

            dag.GetColStr(shortName,JDT1_SHORT_NAME,rec)
            shortName.Trim()
            isVat=TRUE
            condStruct[0].relationship=DBD_AND
            condStruct[condNum].bracketOpen=1
            condStruct[condNum].colNum=OVTG_ACCOUNT
            condStruct[condNum].condVal=shortName
            condStruct[condNum].operation=DBD_EQ
            condStruct[condNum+=1].relationship=DBD_OR
            condStruct[condNum].colNum=OVTG_EQU_VAT_ACCOUNT
            condStruct[condNum].condVal=shortName
            condStruct[condNum].operation=DBD_EQ
            condStruct[condNum+=1].relationship=DBD_OR
            condStruct[condNum].colNum=OVTG_DEFERRED_ACC
            condStruct[condNum].condVal=shortName
            condStruct[condNum].operation=DBD_EQ
            condStruct[condNum+=1].relationship=DBD_OR
            condStruct[condNum].colNum=OVTG_ACQSITION_TAX
            condStruct[condNum].condVal=shortName
            condStruct[condNum].operation=DBD_EQ
            condStruct[condNum+=1].relationship=DBD_OR
            condStruct[condNum].colNum=OVTG_NON_DEDUCT_ACC
            condStruct[condNum].condVal=shortName
            condStruct[condNum].operation=DBD_EQ
            condStruct[condNum+=1].relationship=DBD_OR
            condStruct[condNum].bracketOpen=1
            condStruct[condNum].colNum=OVTG_NON_DEDUCTIBLE
            condStruct[condNum].operation=DBD_NE
            _STR_strcpy(condStruct[condNum].condVal,STR_0)
            condStruct[condNum+=1].relationship=DBD_AND
            condStruct[condNum].bracketOpen=1
            condStruct[condNum].colNum=OVTG_NON_DEDUCT_ACC
            condStruct[condNum].operation=DBD_EQ
            condStruct[condNum+=1].relationship=DBD_OR
            condStruct[condNum].colNum=OVTG_NON_DEDUCT_ACC
            condStruct[condNum].operation=DBD_IS_NULL
            condStruct[condNum].bracketClose=3
            condStruct[condNum+=1].relationship=0

         end


      end

      if !condStruct[0].condVal.IsEmpty()
         _STR_strcpy(tableStruct[0].tableCode,bizEnv.ObjectToTable(SBOString(object),ao_Main))
         if object==VTG&&isVat
            DBD_SetDAGCond(dag,condStruct,condNum)

         else
            DBD_SetDAGCond(dag,condStruct,1)

         end

         DBD_SetTablesList(dag,tableStruct,1)
         count=DBD_Count(dag

         if count<=0
            if showError
               SetErrorField(field)

               GetEnv().GetTableDescription(tableStruct[0].tableCode,tableDesc)
               CMessagesManager::GetHandle().Message(_1_APP_MSG_FIN_ITM_RELATED_ERR_FORMAT,EMPTY_STR,this,condStruct[0].condVal.GetBuffer(),tableDesc.GetBuffer())

            end

            return ooInvalidObject

         end


      end

      return ooNoErr

   end

   def OnCanUpdate()
      _TRACER("OnCanUpdate")




      *fCodePtr
      oopp=GetOnUpdateParams()

      dag=oopp.pDag

      bizEnv=GetEnv()

      editableInUpdate=(Boolean)(bizEnv.GetPermission(PRM_ID_UPDATE_POSTING)==OO_PRM_FULL)
      fCodePtr=DAG_GetAlias(dag)
      isHeader=_STR_stricmp(fCodePtr,bizEnv.ObjectToTable(JDT))==0
      if VF_JEWHT(bizEnv)
         tmp=bizEnv.ObjectToTable(JDT

         if tmp==fCodePtr
            return OnCanJDT2Update()

         end


      end

      if isHeader
         i=0
         begin
            case oopp.colsList[i].GetColNum()

            when OJDT_REF_DATE
               SetErrorField(oopp.colsList[i].GetColNum())
               SetErrorLine(-1)
               return dbmColumnNotUpdatable
               break
            when OJDT_TAX_DATE
               if bizEnv.IsBlockTaxDateEdit()
                  if !oopp.colsList[i].GetBackupValue().IsEmpty()
                     SetErrorLine(-1)
                     SetErrorField(oopp.colsList[i].GetColNum())
                     return dbmColumnNotUpdatable

                  end


               end

               break
            when OJDT_REF1
            when OJDT_REF2
            when OJDT_REF3
            when OJDT_TRANS_CODE
            when OJDT_INDICATOR
            when OJDT_ADJ_TRAN
            when OJDT_PROJECT
            when OJDT_ORIGN_CURRENCY
            when OJDT_TRANS_RATE
               if !editableInUpdate
                  SetErrorLine(-1)
                  SetErrorField(oopp.colsList[i].GetColNum())
                  return dbmColumnNotUpdatable

               end

               break
            when OJDT_REPORT_347
            when OJDT_REPORT_EU
               if bizEnv.IsCurrentLocalSettings(SPAIN_SETTINGS)
                  if oopp.colsList[i].GetBackupValue().Compare(VAL_YES)==0


                     dag.GetColLong(&objAbs,OJDT_JDT_NUM)
                     if oopp.colsList[i].GetColNum()==OJDT_REPORT_347
                        CRFLObject::IsTransactionAlreadyReported(isReported,RT_347,bizEnv,JDT,objAbs)

                     else
                        CRFLObject::IsTransactionAlreadyReported(isReported,RT_349,bizEnv,JDT,objAbs)

                     end

                     if isReported
                        SetErrorLine(-1)
                        SetErrorField(oopp.colsList[i].GetColNum())
                        return dbmColumnNotUpdatable

                     end


                  end


               end


               break
            when OJDT_BLOCK_DUNNING_LETTER
               if !IsBlockDunningLetterUpdateable()
                  SetErrorLine(-1)
                  SetErrorField(OJDT_BLOCK_DUNNING_LETTER)
                  return dbmColumnNotUpdatable

               end


               break
            when OJDT_DUE_DATE
               if this.IsPaymentOrdered()
                  SetErrorLine(-1)
                  SetErrorField(OJDT_DUE_DATE)
                  return dbmColumnNotUpdatable

               end


               break
            when OJDT_DEFERRED_TAX
               SetErrorLine(-1)
               SetErrorField(OJDT_DUE_DATE)
               return dbmColumnNotUpdatable

               break

            end



            i+=1
         end while (i<oopp.colsList.GetSize())


      else
         i=0
         begin



         end while (i)


      end


   end

   def DocBudgetCurrentSum(bizObject, currentMoney, acctCode)
      _TRACER("DocBudgetCurrentSum")
      sboErr=ooNoErr



      dagRES
      dagObj
      dagDOC = bizObject.GetDAG()


      (0)
      dagObj=bizObject.GetDAG(bizObject.GetID(),ao_Arr1)
      if !DAG::IsValid(dagObj)
         return dbmBadDAG

      end

      dagDOC.GetColMoney(&docDiscount,OINV_DISC_PERCENT)
      currentMoney.SetToZero()
      resStruct[0].colNum=INV1_TOTAL
      DBD_SetDAGRes(dagObj,resStruct,1)
      condStruct[0].colNum=INV1_ABS_ENTRY
      condStruct[0].operation=DBD_EQ
      condStruct[0].condVal=bizObject.GetKeyStr()
      condStruct[0].relationship=DBD_AND
      condStruct[1].colNum=INV1_ACCOUNT_CODE
      condStruct[1].operation=DBD_EQ
      condStruct[1].condVal=acctCode
      DBD_SetDAGCond(dagObj,condStruct,2)
      sboErr=DBD_GetInNewFormat(dagObj,&dagRES)
      if !sboErr
         rec=0

         begin



         end while (rec)


      end


   end

   def OnUpgrade()
      _TRACER("OnUpgrade")
      ooErr=ooNoErr









      bizEnv=GetEnv()


      if UpgradeVersionCheck(OJDT_UPG_DUE_DATE_VER)
         def upgradeBlock
            (_T("Due Date"))
         end

         dagJDT=OpenDAG(JDT,ao_Main)
         _STR_strcpy(tableStruct[0].tableCode,bizEnv.ObjectToTable(JDT,ao_Main))
         _STR_strcpy(tableStruct[1].tableCode,bizEnv.ObjectToTable(JDT,ao_Arr1))
         tableStruct[1].doJoin=TRUE
         tableStruct[1].joinedToTable=0
         tableStruct[1].numOfConds=1
         tableStruct[1].joinConds=joinCondStruct
         joinCondStruct[0].compareCols=TRUE
         joinCondStruct[0].compTableIndex=0
         joinCondStruct[0].compColNum=OJDT_JDT_NUM
         joinCondStruct[0].tableIndex=1
         joinCondStruct[0].colNum=JDT1_TRANS_ABS
         joinCondStruct[0].operation=DBD_EQ
         condStruct[0].colNum=OJDT_DUE_DATE
         condStruct[0].operation=DBD_IS_NULL
         condStruct[0].relationship=DBD_AND
         condStruct[1].tableIndex=1
         condStruct[1].colNum=JDT1_LINE_ID
         _STR_strcpy(condStruct[1].condVal,STR_0)
         condStruct[1].operation=DBD_EQ
         resStruct[0].colNum=OJDT_JDT_NUM
         resStruct[1].tableIndex=1
         resStruct[1].colNum=JDT1_DUE_DATE
         DBD_SetTablesList(dagJDT,tableStruct,2)
         DBD_SetDAGCond(dagJDT,condStruct,2)
         DBD_SetDAGRes(dagJDT,resStruct,2)
         ooErr=DBD_GetInNewFormat(dagJDT,&dagRES)
         if !ooErr
            DAG_GetCount(dagRES,&numOfRecs)
            rec=0
            begin
               updStruct[0].colNum=OJDT_DUE_DATE
               dagRES.GetColStr(updStruct[0].updateVal,1,rec)
               condStruct[0].colNum=OJDT_JDT_NUM
               condStruct[0].operation=DBD_EQ
               dagRES.GetColStr(condStruct[0].condVal,0,rec)
               condStruct[0].relationship=0
               DBD_SetDAGCond(dagJDT,condStruct,1)
               DBD_SetDAGUpd(dagJDT,updStruct,1)
               ooErr=DBD_UpdateCols(dagJDT)


               rec+=1
            end while (rec<numOfRecs)


         end

         DAG_Close(dagJDT)
         upgradeBlock.MarkSuccess()

      end

      if bizEnv.IsVatPerLine()&&UpgradeVersionCheck(OJDT_UPG_AUTO_VAT_VER)
         def upgradeBlock
            (_T("Auto VAT"))
         end

         dagJDT1=OpenDAG(JDT,ao_Arr1)
         _MEM_Clear(condStruct,2)
         condStruct[0].colNum=JDT1_VAT_GROUP
         condStruct[0].operation=DBD_NOT_NULL
         condStruct[0].relationship=DBD_AND
         condStruct[1].colNum=JDT1_VAT_GROUP
         condStruct[1].operation=DBD_NE
         condStruct[1].relationship=0
         DBD_SetDAGCond(dagJDT1,condStruct,2)
         updStruct[0].colNum=JDT1_VAT_LINE
         _STR_strcpy(updStruct[0].updateVal,VAL_YES)
         DBD_SetDAGUpd(dagJDT1,updStruct,1)
         ooErr=DBD_UpdateCols(dagJDT1)
         DAG_Close(dagJDT1)
         upgradeBlock.MarkSuccess()

      end

      if UpgradeVersionCheck(OJDT_UPG_SRC_LINE_VER)
         def upgradeBlock
            (_T("Source Line Version"))
         end

         dagJDT1=OpenDAG(JDT,ao_Arr1)
         _MEM_Clear(condStruct,8)
         condStruct[0].bracketOpen=1
         condStruct[0].colNum=JDT1_TRANS_TYPE
         condStruct[0].operation=DBD_EQ
         condStruct[0].condVal=INV
         condStruct[0].relationship=DBD_OR
         condStruct[1].colNum=JDT1_TRANS_TYPE
         condStruct[1].operation=DBD_EQ
         condStruct[1].condVal=RIN
         condStruct[1].relationship=DBD_OR
         condStruct[2].colNum=JDT1_TRANS_TYPE
         condStruct[2].operation=DBD_EQ
         condStruct[2].condVal=PCH
         condStruct[2].relationship=DBD_OR
         condStruct[3].colNum=JDT1_TRANS_TYPE
         condStruct[3].operation=DBD_EQ
         condStruct[3].condVal=RPC
         condStruct[3].bracketClose=1
         condStruct[3].relationship=DBD_AND
         condStruct[4].compareCols=TRUE
         condStruct[4].colNum=JDT1_SHORT_NAME
         condStruct[4].operation=DBD_NE
         condStruct[4].compColNum=JDT1_ACCT_NUM
         condStruct[4].relationship=DBD_AND
         condStruct[5].bracketOpen=1
         condStruct[5].colNum=JDT1_SRC_LINE
         condStruct[5].operation=DBD_EQ
         _STR_strcpy(condStruct[5].condVal,EMPTY_STR)
         condStruct[5].relationship=DBD_OR
         condStruct[6].colNum=JDT1_SRC_LINE
         condStruct[6].operation=DBD_IS_NULL
         condStruct[6].relationship=DBD_OR
         condStruct[7].colNum=JDT1_SRC_LINE
         condStruct[7].operation=DBD_EQ
         condStruct[7].condVal=()


      end


   end

   def SetToZeroNullLineTypeCols()
      _TRACER("SetToZeroNullLineTypeCols")
      ooErr=noErr


      updateZeroColNum=""

      dagJDT1=GetDAG(JDT,ao_Arr1)
      ooErr=GNUpdateNullColumnsToZero(dagJDT1,updateZeroColNum,1)
      if ooErr
         return ooErr

      end

      return ooErr

   end

   def SetToZeroOldLineTypeCols()
      _TRACER("SetToZeroOldLineTypeCols")
      ooErr=noErr

      dagJDT1=GetDAG(JDT

      conditions=&(dagJDT1.GetDBDParams().GetConditions())


      conditions.Clear()
      condPtr=&conditions.AddCondition()
      condPtr.bracketOpen=1
      condPtr.colNum=JDT1_TRANS_TYPE
      condPtr.operation=DBD_EQ
      condPtr.condVal=RCT
      condPtr.relationship=DBD_OR
      condPtr=&conditions.AddCondition()
      condPtr.colNum=JDT1_TRANS_TYPE
      condPtr.operation=DBD_EQ
      condPtr.condVal=VPM
      condPtr.bracketClose=1
      condPtr.relationship=DBD_AND
      condPtr=&(conditions.AddCondition())

      condPtr.operation=DBD_NOT_EXISTS
      condPtr.SetSubQueryParams(&subParams)
      condPtr.tableIndex=DBD_NO_TABLE
      condPtr.relationship=0
      bizEnv=GetEnv()

      subTables=&(subParams.GetCondTables())

      tablePtr=&subTables.AddTable()

      tablePtr.tableCode=bizEnv.ObjectToTable(JDT,ao_Arr1)

      subResStruct[0].tableIndex=0
      subResStruct[0].colNum=JDT1_TRANS_ABS
      subConditions=&(subParams.GetConditions())

      condPtr=&(subConditions.AddCondition())
      condPtr.origTableIndex=0
      condPtr.origTableLevel=1
      condPtr.colNum=JDT1_TRANS_ABS
      condPtr.operation=DBD_EQ
      condPtr.compareCols=true
      condPtr.compTableIndex=0
      condPtr.compColNum=JDT1_TRANS_ABS
      condPtr.relationship=DBD_AND
      condPtr=&(subConditions.AddCondition())
      condPtr.tableIndex=0
      condPtr.colNum=JDT1_SHORT_NAME
      condPtr.operation=DBD_NE
      condPtr.compareCols=true
      condPtr.compTableIndex=0
      condPtr.compColNum=JDT1_ACCT_NUM
      condPtr.relationship=DBD_AND
      condPtr=&(subConditions.AddCondition())
      condPtr.tableIndex=0
      condPtr.colNum=JDT1_LINE_TYPE
      condPtr.operation=DBD_NE
      condPtr.condVal=()


   end

   def CompleteTrans()
      _TRACER("CompleteTrans")






      bizEnv=GetEnv()

      _STR_strcpy(mainCurrency,bizEnv.GetMainCurrency())
      dagJDT=GetDAG(JDT)
      dagJDT1=GetDAG(JDT,ao_Arr1)
      dagCRD=GetDAG(CRD)
      DAG_GetCount(dagJDT,&numOfRecs)
      if !numOfRecs
         DAG_SetSize(dagJDT,1,dbmDropData)

      end

      if dagJDT.IsNullCol(OJDT_REF_DATE,0)
         if dagJDT1.IsNullCol(JDT1_DUE_DATE,0)
            DBM_DATE_Get(curDate,GetEnv())

         else
            dagJDT1.GetColStr(curDate,JDT1_DUE_DATE,0)

         end

         dagJDT.SetColStr(curDate,OJDT_REF_DATE,0)

      else
         dagJDT.GetColStr(curDate,OJDT_REF_DATE,0)

      end

      dagJDT.GetColLong(&transType,OJDT_TRANS_TYPE,0)
      if transType==-1
         dagJDT.SetColLong(JDT,OJDT_TRANS_TYPE,0)

      end

      if dagJDT.IsNullCol(OJDT_DUE_DATE,0)
         dagJDT.CopyColumn(dagJDT,OJDT_DUE_DATE,0,OJDT_REF_DATE,0)

      else
         dagJDT.GetColStr(curDate,OJDT_DUE_DATE,0)

      end

      if dagJDT.IsNullCol(OJDT_TAX_DATE,0)
         dagJDT.CopyColumn(dagJDT,OJDT_TAX_DATE,0,OJDT_REF_DATE,0)

      end

      DAG_GetCount(dagJDT1,&numOfRecs)
      if numOfRecs<=0
         Message(OBJ_MGR_ERROR_MSG,GO_NO_TOTAL_IN_DOC_LINES,NULL,OO_ERROR)
         return ooInvalidObject

      end

      rec=0
      begin



      end while (rec)


   end

   def CompleteJdtLine()
      _TRACER("CompleteJdtLine")
      ooErr=noErr




      bizEnv=GetEnv()

      mbEnabled=false
      isAutoCompleteBPLFromUD = false

      CBusinessPlaceObject::BPLInfo
      bplInfo
      dagJDT=GetDAG()
      dagJDT1=GetDAG(JDT,ao_Arr1)
      DAG_GetCount(dagJDT1,&numOfRecs)
      mbEnabled=VF_MultiBranch_EnabledInOADM(bizEnv)
      isAutoCompleteBPLFromUD=mbEnabled&&GetDataSource()==*VAL_OBSERVER_SOURCE&&CBusinessPlaceObject::IsAutoCompleteBPLFromUserDefaults(GetID().strtol())
      rec=0
      begin



      end while (rec)


   end

   def SetJDTLineSrc(line, absEntry, srcLine)
      _TRACER("SetJDTLineSrc")
      ooErr=noErr


      dagJDT1=GetDAG(JDT,ao_Arr1)
      if !DAG_IsValid(dagJDT1)
         return (dbmBadDAG)

      end

      dagJDT1.SetColLong(absEntry,JDT1_SRC_ABS_ID,line)
      dagJDT1.SetColLong(srcLine,JDT1_SRC_LINE,line)
      return ooErr

   end

   def DoSingleStorno(/)
      _TRACER("DoSingleStorno")
      ooErr=noErr

      fld1List=""

      fldList=""





      msgStr=""






      bizEnv=GetEnv()

      dagJDT=GetDAG()

      dagJDT1=GetDAG(JDT

      dagJDT.GetColStr(keyStr,OJDT_JDT_NUM,0)
      _STR_LRTrim(keyStr)
      dagJDT.GetColLong(&transNum,OJDT_JDT_NUM,0)
      condStruct[0].colNum=OJDT_STORNO_TO_TRANS
      condStruct[0].condVal=transNum
      condStruct[0].operation=DBD_EQ
      condStruct[0].relationship=0
      DBD_SetDAGCond(dagJDT,condStruct,1)
      if DBD_Count(dagJDT,TRUE)>0
         CMessagesManager::GetHandle().Message(_1_APP_MSG_FIN_JDT_CANCELED_ERROR2,EMPTY_STR,this,transNum)
         return ooInvalidObject

      end

      periodManager=bizEnv.GetPeriodCache()

      if GetDataSource()!=*VAL_OBSERVER_SOURCE
         dagJDT.GetColStr(refDate,OJDT_STORNO_DATE,0)
         if checkDate&&(coreNoCurrPeriodErr==bizEnv.CheckCompanyPeriodByDate(refDate))
            SetErrorLine(-1)
            SetErrorField(OJDT_REF_DATE)
            return (ooInvalidObject)

         end

         dagJDT.SetColStr(refDate,OJDT_REF_DATE,0)
         dagJDT.SetColStr(refDate,OJDT_TAX_DATE,0)
         DAG_GetCount(dagJDT1,&count)
         rec=0
         begin
            dagJDT1.SetColStr(refDate,JDT1_REF_DATE,rec)

            dagJDT1.GetColStr(ocrCode,JDT1_OCR_CODE,rec)

            COverheadCostRateObject::GetValidFrom(bizEnv,ocrCode,refDate.GetString(),validFrom)
            dagJDT1.SetColStr(validFrom,JDT1_VALID_FROM,rec)
            dagJDT1.SetColStr(refDate,JDT1_TAX_DATE,rec)


            rec+=1
         end while (rec<count)


      end

      dagJDT.SetColStr(EMPTY_STR,OJDT_STORNO_DATE,0)
      dagJDT.SetColStr(VAL_NO,OJDT_AUTO_STORNO,0)
      dagJDT.SetColLong(0,OJDT_NUMBER,0)
      if GetDataSource()==*VAL_OBSERVER_SOURCE
         ooErr=dagJDT.GetChangesList(0,colsList)
         if ooErr
            return ooErr

         end


         dagJDT.GetColStr(keyDate,OJDT_REF_DATE)
         if keyDate.Trim().IsEmpty()
            DBM_DATE_Get(keyDate,bizEnv)
         end

         periodID=periodManager.GetPeriodId(bizEnv

         DAG_GetCount(dagJDT1,&count)
         ii=0
         begin



         end while (ii)


      end


   end

   def ReconcileCertainLines()
      _TRACER("ReconcileCertainLines")
      ooErr=noErr






      numOfConds=0




      bizEnv=GetEnv()



      pMM=NULL

      shouldAddLine2Match=true

      shouldCancelRecons=true

      dagJdt=GetDAG()
      dagJdt1=GetDAG(JDT,ao_Arr1)
      dagJdt.GetColStr(date,OJDT_REF_DATE,0)
      dagJdt.GetColLong(&transNum,OJDT_STORNO_TO_TRANS,0)
      dagJdt.GetColLong(&newTransNum,OJDT_JDT_NUM,0)
      condStruct[numOfConds].colNum=JDT1_TRANS_ABS
      condStruct[numOfConds].operation=DBD_EQ
      condStruct[numOfConds].condVal=transNum
      condStruct[numOfConds+=1].relationship=DBD_AND
      condStruct[numOfConds].colNum=JDT1_ACCT_NUM
      condStruct[numOfConds].operation=DBD_NE
      condStruct[numOfConds].compareCols=TRUE
      condStruct[numOfConds].compColNum=JDT1_SHORT_NAME
      condStruct[numOfConds+=1].relationship=0
      DBD_SetDAGCond(dagJdt1,condStruct,numOfConds)
      resStruct[0].colNum=JDT1_SHORT_NAME
      resStruct[0].group_by=true
      DBD_SetDAGRes(dagJdt1,resStruct,1)
      ooErr=DBD_GetInNewFormat(dagJdt1,&dagRES)
      if m_isInCancellingAcctRecon
         dagRES.SetSize(m_reconAcctSet.size(),dbmDropData)
         std::set

      end


   end

   def UpgradeBoeActs()
      _TRACER("UpgradeBoeActs")

      dagCRD
      dagACT
      dagJDT1
      dagRES = NULL
      dagRES2 = NULL
      dagAnswer = NULL


      *updateActBalanceCond

   end

   def FixVendorsAndSpainBoeBalance()
      _TRACER("FixVendorsAndSpainBoeBalance")






      numOfCardConds=0
      numOfActsConds = 0
      numOfConds = 0
      numOfRecs
      rec

      firstErr=FALSE


      bizEnv=GetEnv()

      _STR_strcpy(tableStruct[0].tableCode,bizEnv.ObjectToTable(JDT,ao_Arr1))
      dagJDT1=OpenDAG(JDT,ao_Arr1)
      _STR_strcpy(tableStruct[1].tableCode,bizEnv.ObjectToTable(CRD,ao_Arr3))
      tableStruct[1].doJoin=TRUE
      tableStruct[1].joinedToTable=0
      tableStruct[1].numOfConds=1
      tableStruct[1].joinConds=joinCondStruct
      joinCondStruct[0].compareCols=TRUE
      joinCondStruct[0].compTableIndex=0
      joinCondStruct[0].compColNum=JDT1_ACCT_NUM
      joinCondStruct[0].tableIndex=1
      joinCondStruct[0].colNum=CRD3_ACCOUNT_CODE
      joinCondStruct[0].operation=DBD_EQ
      condStruct[numOfConds].compareCols=TRUE
      condStruct[numOfConds].colNum=JDT1_SHORT_NAME
      condStruct[numOfConds].operation=DBD_EQ
      condStruct[numOfConds].compColNum=CRD3_CARD_CODE
      condStruct[numOfConds].tableIndex=0
      condStruct[numOfConds].compTableIndex=1
      condStruct[numOfConds+=1].relationship=DBD_AND
      if VF_BOEAsInSpain(bizEnv)
         condStruct[numOfConds].bracketOpen=1
         condStruct[numOfConds].tableIndex=1
         condStruct[numOfConds].colNum=CRD3_ACCOUNT_TYPE
         _STR_strcpy(condStruct[numOfConds].condVal,ARP_TYPE_BoE_RECEIVABLE)
         condStruct[numOfConds].operation=DBD_EQ
         condStruct[numOfConds+=1].relationship=DBD_OR

      end

      condStruct[numOfConds].tableIndex=1
      condStruct[numOfConds].colNum=CRD3_ACCOUNT_TYPE
      _STR_strcpy(condStruct[numOfConds].condVal,ARP_TYPE_BoE_PAYABLE)
      condStruct[numOfConds].operation=DBD_EQ
      condStruct[numOfConds+=1].relationship=0
      if VF_BOEAsInSpain(bizEnv)
         condStruct[numOfConds-].bracketClose=1

      end

      resStruct[0].colNum=JDT1_SHORT_NAME
      resStruct[0].tableIndex=0
      resStruct[0].group_by=TRUE
      DBD_SetDAGCond(dagJDT1,condStruct,numOfConds)
      DBD_SetDAGRes(dagJDT1,resStruct,1)
      DBD_SetTablesList(dagJDT1,tableStruct,2)
      ooErr=DBD_GetInNewFormat(dagJDT1,&dagRES)
      if ooErr&&ooErr!=dbmNoDataFound
         DAG_Close(dagJDT1)
         return ooErr

      else
         if ooErr
            firstErr=TRUE
            DAG_SetSize(dagRES,0,dbmDropData)

         end

      end

      dagRES.Detach()
      _MEM_Clear(condStruct,numOfConds)
      _MEM_Clear(tableStruct,2)
      _STR_strcpy(tableStruct[0].tableCode,bizEnv.ObjectToTable(JDT,ao_Arr1))
      numOfConds=0
      if VF_BOEAsInSpain(bizEnv)
         ooErr=ARP_GetAccountByType(GetEnv(),NULL,ARP_TYPE_BoE_RECEIVABLE,tmpStr,TRUE,VAL_CUSTOMER)
         if !ooErr&&!_STR_IsSpacesStr(tmpStr)
            _STR_strcpy(condStruct[numOfConds].condVal,tmpStr)
            condStruct[numOfConds].tableIndex=0
            condStruct[numOfConds].colNum=JDT1_ACCT_NUM
            condStruct[numOfConds].operation=DBD_EQ
            condStruct[numOfConds+=1].relationship=DBD_OR

         end


      end

      ooErr=ARP_GetAccountByType(GetEnv(),NULL,ARP_TYPE_BoE_PAYABLE,tmpStr,TRUE,VAL_VENDOR)
      if !ooErr&&!_STR_IsSpacesStr(tmpStr)
         _STR_strcpy(condStruct[numOfConds].condVal,tmpStr)
         condStruct[numOfConds].tableIndex=0
         condStruct[numOfConds].colNum=JDT1_ACCT_NUM
         condStruct[numOfConds].operation=DBD_EQ
         condStruct[numOfConds+=1].relationship=0

      end

      if numOfConds
         DBD_SetDAGCond(dagJDT1,condStruct,numOfConds)
         DBD_SetDAGRes(dagJDT1,resStruct,1)
         DBD_SetTablesList(dagJDT1,tableStruct,1)
         ooErr=DBD_GetInNewFormat(dagJDT1,&dagRES2)
         dagRES2.Detach()

      end

      if !ooErr&&numOfConds
         dagRES.Concat(dagRES2,dbmDataBuffer)
         DAG_Close(dagRES2)

      else
         if ooErr==dbmNoDataFound
            DAG_Close(dagRES2)
            if firstErr
               DAG_Close(dagRES)
               DAG_Close(dagJDT1)
               return ooNoErr

            end


         else
            if ooErr
               DAG_Close(dagRES2)
               DAG_Close(dagRES)
               DAG_Close(dagJDT1)
               return ooErr

            end

         end

      end

      DAG_GetCount(dagRES,&numOfRecs)
      if !numOfRecs
         DAG_Close(dagRES)
         return ooNoErr

      end

      updateCardBalanceCond=DBD_CondStruct.new()[numOfRecs]
      rec=0
      begin
         updateCardBalanceCond[numOfCardConds].colNum=OCRD_CARD_CODE
         updateCardBalanceCond[numOfCardConds].operation=DBD_EQ
         dagRES.GetColStr(tmpStr,0,rec)
         _STR_strcpy(updateCardBalanceCond[numOfCardConds].condVal,tmpStr)
         updateCardBalanceCond[numOfCardConds+=1].relationship=DBD_OR


         rec+=1
      end while (rec<numOfRecs)

      updateCardBalanceCond[numOfCardConds-].relationship=0
      dagCRD=OpenDAG(CRD,ao_Main)
      DBD_SetDAGCond(dagCRD,updateCardBalanceCond,numOfCardConds)
      ooErr=DBD_Get(dagCRD)
      if ooErr
         delete[]
         updateCardBalanceCond
         DAG_Close(dagCRD)
         return ooNoErr

      end


      RBARebuildAccountsAndCardsInternal(NULL,dagCRD,FALSE)

      updateCardBalanceCond
      DAG_Close(dagCRD)
      return ooNoErr

   end

   def IsCardAlreadyThere(updateCardBalanceCond, cardCode, startingRec, numOfCardConds)
      _TRACER("IsCardAlreadyThere")

      ii=startingRec
      begin
         if !_STR_strcmp(updateCardBalanceCond[ii].condVal,cardCode)
            return TRUE

         end



         ii+=1
      end while (ii<numOfCardConds)

      return FALSE

   end

   def UpgradePeriodIndic()
      _TRACER("UpgradePeriodIndic")



      sboErr=ooNoErr

      dagJDT1=OpenDAG(JDT,ao_Arr1)
      condStruct[0].colNum=JDT1_TRANS_TYPE
      condStruct[0].operation=DBD_EQ
      condStruct[0].condVal=RCT
      condStruct[0].relationship=DBD_OR
      condStruct[1].colNum=JDT1_TRANS_TYPE
      condStruct[1].operation=DBD_EQ
      condStruct[1].condVal=VPM
      DBD_SetDAGCond(dagJDT1,condStruct,2)
      UpdateStruct[0].colNum=JDT1_SRC_ABS_ID
      UpdateStruct[0].srcColNum=JDT1_CREATED_BY
      UpdateStruct[0].SetUpdateColSource(DBD_UpdStruct::ucs_SrcCol)
      DBD_SetDAGUpd(dagJDT1,UpdateStruct,1)
      sboErr=DBD_UpdateCols(dagJDT1)
      DAG_Close(dagJDT1)
      return sboErr

   end

   def OnCheckIntegrityOnCreate()
      _TRACER("OnCheckIntegrityOnCreate")

      ooErr=OJDTCheckIntegrityOfJournalEntry(this,false)
      if ooErr
         return ooErr

      end

      return noErr

   end

   def OnCheckIntegrityOnUpdate()
      _TRACER("OnCheckIntegrityOnUpdate")

      ooErr=OJDTCheckIntegrityOfJournalEntry(this,false)
      if ooErr
         return ooErr

      end

      return noErr

   end

   def OJDTCheckIntegrityOfJournalEntry(bizObject, checkForgn)
      _TRACER("OJDTCheckIntegrityOfJournalEntry")

      dagJDT=bizObject.GetDAGNoOpen(SBOString(JDT))

      if !dagJDT
         _MEM_ASSERT(0)
         return ooNoErr

      end

      numOfRecs=dagJDT.GetRecordCount()

      if numOfRecs==1

         dagJDT.GetColStr(tmpStr,OJDT_JDT_NUM)
         tmpStr.Trim()
         if tmpStr.IsSpacesStr()
            numOfRecs=0

         end


      end

      if numOfRecs==0
         return ooNoErr

      end

      ooErr=OJDTCheckJDT1IsNotEmpty(bizObject)
      IF_ERROR_RETURN(ooErr)
      ooErr=OJDTValidateJDTOfLocalCard(bizObject)
      IF_ERROR_RETURN(ooErr)
      ooErr=OJDTValidateJDT1Accounts(bizObject)
      IF_ERROR_RETURN(ooErr)
      ooErr=OJDTCheckBalnaceTransection(bizObject,checkForgn)
      IF_ERROR_RETURN(ooErr)
      ooErr=CostAccountingAssignmentCheck(bizObject)
      IF_ERROR_RETURN(ooErr)
      return ooNoErr

   end

   def OJDTCheckJDT1IsNotEmpty(bizObject)
      _TRACER("OJDTCheckJDT1IsNotEmpty")



      dagJDT=bizObject.GetDAGNoOpen(SBOString(JDT))
      if !dagJDT
         _MEM_ASSERT(0)
         return ooNoErr

      end

      dagJDT1=bizObject.GetDAG(SBOString(JDT),ao_Arr1)
      numOfRecs=dagJDT1.GetRecordCount()
      if numOfRecs<=0
         bizObject.Message(GO_OBJ_ERROR_MSGS(JDT),JDT_WITH_NO_LINES_ERR,NULL,OO_ERROR)
         return ooInvalidObject

      end

      if numOfRecs==1
         dagJDT1.GetColStr(keyCol1,JDT1_TRANS_ABS)
         dagJDT1.GetColStr(keyCol2,JDT1_LINE_ID)
         if keyCol1.IsSpacesStr()||keyCol2.IsSpacesStr()
            bizObject.Message(GO_OBJ_ERROR_MSGS(JDT),JDT_WITH_NO_LINES_ERR,NULL,OO_ERROR)
            return ooInvalidObject

         end


      end

      return ooNoErr

   end

   def OJDTValidateJDT1Accounts(bizObject)






      bizEnv=bizObject.GetEnv()

      dagACT=bizObject.GetDAG(ACT,ao_Main)
      dagJDT1=bizObject.GetDAG(JDT,ao_Arr1)
      numOfRecs=dagJDT1.GetRealSize(dbmDataBuffer)
      lock=!(bizObject.IsUpdateNum()||bizObject.IsExCommand3(ooEx3DontTouchNextNum))

      jj=0
      begin
         dagJDT1.GetColStr(actNum,JDT1_ACCT_NUM,jj)
         if _STR_IsSpacesStr(actNum)
            return (ooInvalidAcctCode)

         end

         ooErr=bizEnv.GetByOneKey(dagACT,OACT_KEYNUM_PRIMARY,actNum,lock)
         if ooErr
            if ooErr==dbmNoDataFound
               return (ooInvalidAcctCode)

            else
               return ooErr

            end


         end

         dagACT.GetColStr(tmpStr,OACT_POSTABLE,0)
         if _STR_strcmp(tmpStr,VAL_YES)!=0
            dagACT.GetColStr(code,OACT_ACCOUNT_CODE)
            bizObject.Message(OBJ_MGR_ERROR_MSG,GO_NON_POSTABLE_ACT_IN_TRANS_MSG,code,OO_ERROR)
            return (ooInvalidObject)

         end

         dagACT.GetColStr(tmpCurr,OACT_ACT_CURR,0)
         dagJDT1.GetColStr(Curr,JDT1_FC_CURRENCY,jj)
         if GNCoinCmp(tmpCurr,BAD_CURRENCY_STR)!=0
            if !_STR_SpacesString(Curr,_STR_strlen(Curr))
               if GNCoinCmp(tmpCurr,Curr)!=0
                  dagACT.GetColStr(tmpStr,OACT_ACCOUNT_CODE)
                  ooErr=bizEnv.GetAccountSegmentsByCode(tmpStr,code,true)
                  IF_ERROR_RETURN(ooErr)
                  bizObject.Message(OBJ_MGR_ERROR_MSG,GO_ACT_COIN_DIFFERS,code,OO_ERROR)
                  return (ooInvalidObject)

               end


            end


         end



         jj+=1
      end while (jj<numOfRecs)

      return ooNoErr

   end

   def OJDTValidateJDTOfLocalCard(bizObject)
      _TRACER("OJDTValidateJDTOfLocalCard")





      isLocalCard=false


      bizEnv=bizObject.GetEnv()

      _STR_strcpy(localCurr,bizEnv.GetMainCurrency())
      dagJDT1=bizObject.GetDAGNoOpen(SBOString(JDT),ao_Arr1)
      if !dagJDT1
         _MEM_ASSERT(0)
         return ooNoErr

      end

      dagJDT=bizObject.GetDAGNoOpen(SBOString(JDT))
      if !dagJDT
         _MEM_ASSERT(0)
         return ooNoErr

      end

      numOfRecs=dagJDT1.GetRecordCount()
      rec=0
      begin



      end while (rec)


   end

   def OJDTCheckFcInLocalCard(bizObject, dagJDT1, rec)
      _TRACER("OJDTCheckFcInLocalCard")

      dagJDT1.GetColMoney(&tmpM,JDT1_FC_CREDIT,rec)
      if tmpM!=0
         bizObject.Message(GO_OBJ_ERROR_MSGS(JDT),JDT_LOCAL_BP_WITH_FC_AMOUNTS_ERR,NULL,OO_ERROR)
         return ooInvalidObject

      end

      dagJDT1.GetColMoney(&tmpM,JDT1_FC_DEBIT,rec)
      if tmpM!=0
         bizObject.Message(GO_OBJ_ERROR_MSGS(JDT),JDT_LOCAL_BP_WITH_FC_AMOUNTS_ERR,NULL,OO_ERROR)
         return ooInvalidObject

      end

      return ooNoErr

   end

   def OJDTCheckBalnaceTransection(bizObject, checkForgn)
      _TRACER("OJDTCheckBalnaceTransection")
      dagJDT1=NULL




      dagJDT1=bizObject.GetDAGNoOpen(SBOString(JDT),ao_Arr1)
      if !dagJDT1
         _MEM_ASSERT(0)
         return ooNoErr

      end

      DAG_GetCount(dagJDT1,&records)
      rec=0
      begin
         dagJDT1.GetColMoney(&tmpM,JDT1_CREDIT,rec,DBM_NOT_ARRAY)
         ooErr=MONEY_Add(&credit,&tmpM)
         if ooErr
            return ooErr

         end

         dagJDT1.GetColMoney(&tmpM,JDT1_DEBIT,rec,DBM_NOT_ARRAY)
         ooErr=MONEY_Add(&debit,&tmpM)
         if ooErr
            return ooErr

         end

         dagJDT1.GetColMoney(&tmpM,JDT1_SYS_CREDIT,rec,DBM_NOT_ARRAY)
         ooErr=MONEY_Add(&creditS,&tmpM)
         if ooErr
            return ooErr

         end

         dagJDT1.GetColMoney(&tmpM,JDT1_SYS_DEBIT,rec,DBM_NOT_ARRAY)
         ooErr=MONEY_Add(&debitS,&tmpM)
         if ooErr
            return ooErr

         end

         dagJDT1.GetColMoney(&tmpM,JDT1_FC_CREDIT,rec,DBM_NOT_ARRAY)
         ooErr=MONEY_Add(&creditF,&tmpM)
         if ooErr
            return ooErr

         end

         dagJDT1.GetColMoney(&tmpM,JDT1_FC_DEBIT,rec,DBM_NOT_ARRAY)
         ooErr=MONEY_Add(&debitF,&tmpM)
         if ooErr
            return ooErr

         end



         rec+=1
      end while (rec<records)

      if (MONEY_Cmp(&credit,&debit)!=0)||(MONEY_Cmp(&creditS,&debitS)!=0)
         return OJDTWriteErrorMessage(bizObject)

      end

      if checkForgn
         if (MONEY_Cmp(&creditF,&debitF)!=0)
            return OJDTWriteErrorMessage(bizObject)

         end


      end

      return ooNoErr

   end

   def ComplateStampLine()
      _TRACER("ComplateStampLine")
      ooErr=noErr




      sysCurr=""

      localCurr=""

      currency=""

      dateStr=""












      bizEnv=GetEnv()





      dagJDT=GetDAG(JDT)
      dagJDT1=GetDAG(JDT,ao_Arr1)
      dagACT=GetDAG(ACT)
      dagVTG=GetDAG(VTG)
      dagJDT.GetColStr(stampTax,OJDT_STAMP_TAX,0)
      DAG_GetCount(dagJDT1,&numOfRecs)
      if bizEnv.IsVatPerLine()
         dagJDT.GetColStr(tmpStr,OJDT_AUTO_VAT,0)
         if tmpStr[0]==VAL_YES[0]
            rec=0
            begin



            end while (rec)


         end


      end


   end

   def CopyNoType(other)
      _TRACER("CopyNoType")
      CSystemBusinessObject::CopyNoType(other)
      if other.GetID()==JDT
         bizObject=(CTransactionJournalObject*)&other

         m_jrnlKeys=bizObject.GetJournalKeys()
         m_stornoExtraInfoCreator=((CTransactionJournalObject&))
         other

      end


   end

   def RecordHist(bizObject, dag)
      _TRACER("RecordHist")

      num=0
      series
      seqCode



      bizEnv=bizObject.GetEnv()

      dagOBJ=bizObject.GetDAG()

      bizObjId=bizObject.GetID().strtol()

      sboErr=IsValidUserPermissions()
      IF_ERROR_RETURN(sboErr)
      dag.GetColLong(&series,OJDT_SERIES)
      if !(bizObjId!=JDT&&bizObject.IsUpdateNum())
         if !series

            dag.GetColStr(refDate,OJDT_REF_DATE)
            if refDate.Trim().IsSpacesStr()
               DBM_DATE_Get(refDate,bizEnv)
            end

            series=bizEnv.GetDefaultSeriesByDate(bizObject.GetBPLId(),SBOString(JDT),refDate)
            dag.SetColLong(series,OJDT_SERIES,0)

         end


      end

      if VF_MultipleRegistrationNumber(bizEnv)
         dag.GetColLong(&seqCode,OJDT_SEQ_CODE)
         if seqCode==0||seqCode==-1
            seqManager=GetEnv().GetSequenceManager()

            sboErr=seqManager.LoadDfltSeq(*this)
            if !sboErr
               sboErr=seqManager.FillDAGBySeq(*this)
               if !sboErr
                  sboErr=seqManager.HandleSerial(*this)
                  IF_ERROR_RETURN(sboErr)

               end


            end


         end


      end

      if VF_SupplCode(GetEnv())
         pManager=bizEnv.GetSupplCodeManager()


         dag.GetColStr(strNum,OJDT_SUPPL_CODE)
         if strNum.IsNull()||strNum.IsEmpty()

            dag.GetColStr(PostDate,OJDT_REF_DATE)
            sboErr=pManager.CodeChange(*this,PostDate)
            IF_ERROR_RETURN(sboErr)
            sboErr=pManager.CheckCode(*this)
            if sboErr
               CMessagesManager::GetHandle().Message(_54_APP_MSG_CORE_SUPPL_CODE_CODE_EXIST,EMPTY_STR,this)
               return ooInvalidObject

            end


         end


      end

      dag.GetColLong(&transType,OJDT_TRANS_TYPE)
      if bizEnv.IsLocalSettingsFlag(lsf_IsDocNumMethod)
         if transType!=OPEN_BLNC_TYPE&&transType!=CLOSE_BLNC_TYPE&&transType!=MANUAL_BANK_TRANS_TYPE
            dag.GetColLong(&num,OJDT_NUMBER)

         end

         dag.SetColLong(series,OJDT_DOC_SERIES,0)

      else
         if transType<0||transType==JDT||!bizEnv.IsSerieObject(SBOString(transType))
            dag.SetColLong(series,OJDT_DOC_SERIES,0)

         end


      end

      SetSeries(series)
      if !num
         sboErr=GetNextSerial(TRUE)

      else
         sboErr=GetNextAutoKey(TRUE)

      end

      if sboErr
         return (sboErr)

      end

      theKey=GetInternalKey()

      if !num
         num=GetNextNum()

      end

      dag.SetLongByColType(theKey,ABSOLUTE_ENT_FLD,0)
      dag.SetColLong(num,OJDT_NUMBER,0)
      if _STR_atol(bizObject.GetID())!=JDT
         dagOBJ.GetLongByColType(&theKey,ABSOLUTE_ENT_FLD,0)

      else
         dag.GetColLong(&createdBy,OJDT_CREATED_BY)
         if (transType==DPS||transType==DPT||transType==RCT||transType==VPM||transType==MRV||transType==IPF||transType==ITR||transType==CHO||transType==JST||transType==IQR||transType==IQI||transType==IWZ||transType==ACQ||transType==ACD||transType==DRN||transType==MDP||transType==FTR||transType==FAR||transType==RTI)&&createdBy!=0
            theKey=createdBy

         end

         if VF_ExciseInvoice(bizEnv)&&transType==WTR&&createdBy>0
            theKey=createdBy

         end


      end

      dag.SetColLong(theKey,OJDT_CREATED_BY,0)
      dag.GetColLong(&baseRef,OJDT_BASE_REF)
      if _STR_atol(bizObject.GetID())==JDT&&(transType==DPS||transType==DPT||transType==RCT||transType==VPM||transType==MRV||transType==IPF||transType==ITR||transType==CHO||transType==JST||transType==IQR||transType==IQI||transType==IWZ||transType==ACQ||transType==ACD||transType==DRN||transType==MDP||transType==FTR||transType==FAR||transType==RTI)&&baseRef!=0
         theKey=baseRef

      else
         dagOBJ.GetLongByColType(&theKey,SERIAL_NUM_FLD,0)

      end

      if VF_ExciseInvoice(bizEnv)&&transType==WTR&&baseRef>0
         theKey=baseRef

      end

      _STR_ltoa(theKey,baseRefStr)
      dag.SetColStr(baseRefStr,OJDT_BASE_REF,0)
      if !(bizObject.IsUpdateNum()||bizObject.IsExCommand3(ooEx3DontTouchNextNum))
         bizObject.SetInternalKey(theKey)

      end

      return sboErr

   end

   def OnCanCancel()
      bizEnv=GetEnv()

      ooErr=noErr

      canCancelJE=false

      if IsPaymentOrdered()
         return false

      end

      dagJDT=GetDAG()

      dagJDT1=GetDAG(JDT

      sourceDoc=0

      dagJDT.GetColLong(&sourceDoc,OJDT_TRANS_TYPE,0)
      if sourceDoc==JDT||sourceDoc==OPEN_BLNC_TYPE||sourceDoc==CLOSE_BLNC_TYPE||sourceDoc==MANUAL_BANK_TRANS_TYPE||(sourceDoc==WTR&&VF_ExciseInvoice(bizEnv)&&this.m_isVatJournalEntry)
         canCancelJE=true

         canceledTrans=0

         dagJDT.GetColStrAndTrim(autoStrorno,OJDT_AUTO_STORNO,0)
         if autoStrorno==VAL_YES
            canCancelJE=false

         end

         dagJDT.GetColLong(&canceledTrans,OJDT_STORNO_TO_TRANS,0)
         if canceledTrans>0
            canCancelJE=false

         end


      end

      if VF_MultiBranch_EnabledInOADM(bizEnv)&&(sourceDoc==RCT||sourceDoc==VPM)
         dagORCT=GetDAG(sourceDoc)

         if dagORCT!=NULL
            isCentralizedPayment=dagORCT.GetColStrAndTrim(ORCT_BPL_CENT_PMT

            pmntTransId=dagORCT.GetColStrAndTrim(ORCT_TRANS_NUM

            currTransId=dagJDT.GetColStrAndTrim(OJDT_JDT_NUM

            createdBy=dagJDT.GetColStrAndTrim(OJDT_CREATED_BY

            pmtAbsEntry=dagORCT.GetColStrAndTrim(ORCT_ABS_ENTRY

            if isCentralizedPayment==VAL_YES&&pmntTransId!=currTransId&&createdBy==pmtAbsEntry
               canCancelJE=true

            end


         end


      end

      canceledTrans=0

      dagJDT.GetColLong(&canceledTrans,OJDT_JDT_NUM,0)
      try
      def stmt
         (bizEnv)
      end

      tOJDT=stmt.From(bizEnv.ObjectToTable(JDT

      stmt.Select().Count().Col(tOJDT,OJDT_JDT_NUM)
      stmt.Where().Col(tOJDT,OJDT_STORNO_TO_TRANS).EQ().Val(canceledTrans)

      stmt.Execute(pResDag)
      cancelNum=0

      pResDag.GetColLong(&cancelNum,0)
      if cancelNum>0
         canCancelJE=false

      end


      catch(DBMException&e)
      ooErr=e.GetCode()

      return canCancelJE

   end

   def OnCancel()
      _TRACER("OnCancel")





      bizEnv=GetEnv()

      dagJDT=GetDAG()

      dagJDT1=GetDAG(JDT

      if !OnCanCancel()
         Message(JTE_JDT_FORM_NUM,JTE_CANT_CANCEL_ERROR_STR,NULL,OO_ERROR)
         return ooErrNoMsg

      end

      dagJDT.GetColLong(&sourceDoc,OJDT_TRANS_TYPE,0)
      dagJDT.GetColStr(dateStr,OJDT_REF_DATE,0)
      dagJDT.GetColLong(&canceledTrans,OJDT_JDT_NUM)
      condStruct[0].colNum=OJDT_JDT_NUM
      condStruct[0].condVal=canceledTrans
      condStruct[0].operation=DBD_EQ
      condStruct[0].relationship=DBD_AND
      condStruct[1].colNum=OJDT_REF_DATE
      _STR_strcpy(condStruct[1].condVal,dateStr)
      condStruct[1].operation=DBD_GT
      DBD_SetDAGCond(dagJDT,condStruct,2)
      if DBD_Count(dagJDT,TRUE)>0
         Message(GO_OBJ_ERROR_MSGS(JDT),JDT_REVERSE_DATE_ERROR,NULL,OO_ERROR)
         return ooErrNoMsg

      end

      condStruct[1].colNum=OJDT_AUTO_STORNO
      _STR_strcpy(condStruct[1].condVal,VAL_YES)
      condStruct[1].operation=DBD_EQ
      DBD_SetDAGCond(dagJDT,condStruct,2)
      if DBD_Count(dagJDT,TRUE)>0
         Message(JTE_JDT_FORM_NUM,JTE_CANT_CANCEL_ERROR_STR,NULL,OO_ERROR)
         return ooErrNoMsg

      end

      condStruct[0].colNum=OJDT_JDT_NUM
      condStruct[0].condVal=canceledTrans
      condStruct[0].operation=DBD_EQ
      condStruct[0].relationship=DBD_AND
      condStruct[1].colNum=OJDT_STORNO_TO_TRANS
      _STR_strcpy(condStruct[1].condVal,STR_0)
      condStruct[1].operation=DBD_GT
      DBD_SetDAGCond(dagJDT,condStruct,2)
      if DBD_Count(dagJDT,TRUE)>0
         Message(GO_OBJ_ERROR_MSGS(JDT),JDT_STORNO_ERROR,NULL,OO_ERROR)
         return ooErrNoMsg

      end

      condStruct[0].colNum=OJDT_STORNO_TO_TRANS
      condStruct[0].condVal=canceledTrans
      condStruct[0].operation=DBD_EQ
      condStruct[0].relationship=0
      DBD_SetDAGCond(dagJDT,condStruct,1)
      if DBD_Count(dagJDT,TRUE)>0
         _STR_GetStringResource(msgStr,GO_OBJ_ERROR_MSGS(JDT),JDT_CANCELED_ERROR,&GetEnv())
         _STR_sprintf(tmpStr,msgStr,canceledTrans)
         Message(-1,-1,tmpStr,OO_ERROR)
         return ooErrNoMsg

      end

      if sourceDoc!=OPEN_BLNC_TYPE&&sourceDoc!=CLOSE_BLNC_TYPE&&sourceDoc!=MANUAL_BANK_TRANS_TYPE&&!(sourceDoc==WTR&&VF_ExciseInvoice(bizEnv)&&this.m_isVatJournalEntry)
         dagJDT.SetColLong(JDT,OJDT_TRANS_TYPE,0)

      end

      sboErr=DBD_GetKeyGroup(dagJDT1,JDT1_KEYNUM_PRIMARY,SBOString(canceledTrans),TRUE)
      if sboErr
         return (sboErr)

      end

      series=GetEnv().GetDefaultSeries(SBOString(JDT))
      dagJDT.SetColLong(series,OJDT_SERIES)
      sboErr=DoSingleStorno()
      if sboErr
         return sboErr

      end

      return ooNoErr

   end

   def IsPeriodIndicCondNeeded()
      _TRACER("IsPeriodIndicCondNeeded")
      return GetEnv().IsLocalSettingsFlag(lsf_IsDocNumMethod)

   end

   def BuildRelatedBoeQuery(tableStruct, numOfConds, iterationType, numOfTables, condStruct, joinCondStructForOtherObj, joinCondStructBoe)
      _TRACER("BuildRelatedBoeQuery")

      bizEnv=GetEnv()

      if iterationType==JDT_BOT_TYPE
         _STR_strcpy(tableStruct[(*numOfTables)+=1].tableCode,bizEnv.ObjectToTable(BOT,ao_Main))
         absJoinField=OBOT_ABS_ENTRY
         jdt1JoinField=JDT1_SRC_ABS_ID
         objJoinField=BOT

      else
         if iterationType==JDT_RCT_TYPE
            _STR_strcpy(tableStruct[(*numOfTables)+=1].tableCode,bizEnv.ObjectToTable(RCT,ao_Main))
            absJoinField=ORCT_NUM
            _STR_strcpy(tableStruct[(*numOfTables)+=1].tableCode,bizEnv.ObjectToTable(BOE,ao_Main))
            objJoinField=RCT
            jdt1JoinField=JDT1_CREATED_BY

         else
            _STR_strcpy(tableStruct[(*numOfTables)+=1].tableCode,bizEnv.ObjectToTable(DPS,ao_Main))
            absJoinField=ODPS_ABS_ENT
            objJoinField=DPS
            jdt1JoinField=JDT1_SRC_ABS_ID

         end

      end

      tableStruct[1].doJoin=TRUE
      tableStruct[1].joinedToTable=0
      tableStruct[1].numOfConds=2
      tableStruct[1].joinConds=joinCondStructForOtherObj
      joinCondStructForOtherObj[0].compareCols=TRUE
      joinCondStructForOtherObj[0].compTableIndex=0
      joinCondStructForOtherObj[0].compColNum=jdt1JoinField
      joinCondStructForOtherObj[0].tableIndex=1
      joinCondStructForOtherObj[0].colNum=absJoinField
      joinCondStructForOtherObj[0].operation=DBD_EQ
      joinCondStructForOtherObj[0].relationship=DBD_AND
      joinCondStructForOtherObj[1].tableIndex=0
      joinCondStructForOtherObj[1].colNum=JDT1_TRANS_TYPE
      joinCondStructForOtherObj[1].condVal=objJoinField
      joinCondStructForOtherObj[1].operation=DBD_EQ
      if iterationType==JDT_BOT_TYPE
         condStruct[*numOfConds].bracketOpen=1
         condStruct[*numOfConds].colNum=OBOT_STATUS_FROM
         condStruct[*numOfConds].operation=DBD_EQ
         condStruct[*numOfConds].tableIndex=1
         _STR_strcpy(condStruct[*numOfConds].condVal,VAL_BOE_DEPOSITED)
         condStruct[(*numOfConds)+=1].relationship=DBD_AND
         condStruct[*numOfConds].colNum=JDT1_LINE_ID
         condStruct[*numOfConds].operation=DBD_EQ
         condStruct[*numOfConds].tableIndex=0
         condStruct[*numOfConds].condVal=1L
         condStruct[(*numOfConds)+=1].relationship=DBD_OR
         condStruct[*numOfConds].colNum=OBOT_STATUS_FROM
         condStruct[*numOfConds].operation=DBD_EQ
         condStruct[*numOfConds].tableIndex=1
         _STR_strcpy(condStruct[*numOfConds].condVal,VAL_BOE_PAID)
         condStruct[(*numOfConds)+=1].relationship=DBD_AND
         condStruct[*numOfConds].colNum=JDT1_LINE_ID
         condStruct[*numOfConds].operation=DBD_EQ
         condStruct[*numOfConds].tableIndex=0
         condStruct[*numOfConds].condVal=0L
         condStruct[(*numOfConds)+=1].relationship=DBD_AND
         condStruct[(*numOfConds)-].bracketClose=1

      else
         if iterationType==JDT_RCT_TYPE
            tableStruct[2].doJoin=TRUE
            tableStruct[2].joinedToTable=2
            tableStruct[2].numOfConds=2
            tableStruct[2].joinConds=joinCondStructBoe
            joinCondStructBoe[0].compareCols=TRUE
            joinCondStructBoe[0].compTableIndex=1
            joinCondStructBoe[0].compColNum=ORCT_BOE_NUM
            joinCondStructBoe[0].tableIndex=2
            joinCondStructBoe[0].colNum=OBOE_BOE_NUM
            joinCondStructBoe[0].operation=DBD_EQ
            joinCondStructBoe[0].relationship=DBD_AND
            joinCondStructBoe[1].tableIndex=2
            joinCondStructBoe[1].colNum=OBOE_TYPE
            _STR_strcpy(joinCondStructBoe[1].condVal,VAL_INPUT)
            joinCondStructBoe[1].operation=DBD_EQ
            condStruct[*numOfConds].colNum=ORCT_CANCELED
            condStruct[*numOfConds].operation=DBD_EQ
            condStruct[*numOfConds].tableIndex=1
            _STR_strcpy(condStruct[*numOfConds].condVal,VAL_YES)
            condStruct[(*numOfConds)+=1].relationship=DBD_AND
            condStruct[*numOfConds].colNum=OBOE_STATUS
            condStruct[*numOfConds].operation=DBD_EQ
            condStruct[*numOfConds].tableIndex=2
            _STR_strcpy(condStruct[*numOfConds].condVal,VAL_BOE_FAILED)
            condStruct[(*numOfConds)+=1].relationship=DBD_AND
            condStruct[*numOfConds].colNum=JDT1_SRC_LINE
            condStruct[*numOfConds].operation=DBD_EQ
            condStruct[*numOfConds].tableIndex=0
            condStruct[*numOfConds].condVal=PMN_VAL_BOE
            condStruct[(*numOfConds)+=1].relationship=DBD_AND
            condStruct[*numOfConds].colNum=JDT1_DEBIT
            condStruct[*numOfConds].operation=DBD_LE
            condStruct[*numOfConds].tableIndex=0
            condStruct[*numOfConds].condVal=0L
            condStruct[(*numOfConds)+=1].relationship=DBD_AND

         else
            condStruct[*numOfConds].colNum=ODPS_DEPOS_TYPE
            condStruct[*numOfConds].operation=DBD_EQ
            condStruct[*numOfConds].tableIndex=1
            _STR_strcpy(condStruct[*numOfConds].condVal,VAL_BOE)
            condStruct[(*numOfConds)+=1].relationship=DBD_AND

         end

      end


   end

   def AmountChangedSinceMDRAssigned_APA(mdrObj, dagJDT1, rec, changedDim)
      changed=false





      dagJDT1.GetColMoney(&amount,JDT1_FC_DEBIT,rec)
      if amount.IsZero()
         dagJDT1.GetColMoney(&amount,JDT1_FC_CREDIT,rec)
         if amount.IsZero()
            dagJDT1.GetColMoney(&amount,JDT1_DEBIT,rec)
            if amount.IsZero()
               dagJDT1.GetColMoney(&amount,JDT1_CREDIT,rec)

            end


         end


      end


      def dim
         (DIM)
      end

      dimObj=static_cast


   end

   def UpgradeDpmLineTypeUsingJDT1(paymentObj)
      _TRACER("UpgradeDpmLineTypeUsingJDT1")
      ooErr=noErr

      dagJDT1
      dagRES = NULL






      numOfConds=0
      numOfRecs


      bizEnv=GetEnv()


      isIncoming=(paymentObj==RCT)


   end

   def UpgradeDpmLineTypeUsingRCT2(object)
      _TRACER("UpgradeDpmLineTypeUsingRCT2")
      ooErr=noErr

      dagRes=NULL

      dagQuery=GetDAG()

      dpmStageArr=""



   end

   def UpgradeDpmLineTypeExecuteQuery(dagQuery, dagRes, object, isFirst)
      _TRACER("UpgradeDpmLineTypeExecuteQuery")
      ooErr=noErr

      bizEnv=GetEnv()

      const
      pmtMainTableNum=0

      const
      pmtJDT1TableNum=0


   end

   def UpgradeDpmLineTypeUpdate(dagRes, object, isFirst)
      _TRACER("UpgradeDpmLineTypeUpdate")
      ooErr=noErr

      dagJDT1=GetDAG(JDT



      conditions=&(params.GetConditions())


      JDT1UpdateStruct[0].colNum=JDT1_LINE_TYPE
      JDT1UpdateStruct[0].updateVal=isFirst

   end

   def ValidateReportEU()
      _TRACER("ValidateReportEU")
      bizEnv=GetEnv()

      if !bizEnv.IsLocalSettingsFlag(lsf_IsEC)
         return ooNoErr

      end

      dagJDT=GetDAG()

      sboErr=ooNoErr


      dagJDT.GetColStr(reportEUStr,OJDT_REPORT_EU)
      if reportEUStr.Compare(VAL_YES)
         return ooNoErr

      end

      sboErr=ValidateVatReportTransType()
      if sboErr==noErr
         numOfBPfound=0

         validateFedTaxId=bizEnv.IsVatPerLine()

         sboErr=GetNumOfBPRecords(numOfBPfound,validateFedTaxId)
         IF_ERROR_RETURN(sboErr)
         if numOfBPfound!=1
            Message(GO_OBJ_ERROR_MSGS(JDT),JDT_EU_REPORT_DIFFER_ONE_BP_ERR,NULL,OO_ERROR)
            sboErr=errNoMsg

         end


      end

      if sboErr!=noErr
         SetErrorField(-1)
         SetErrorField(OJDT_REPORT_EU)

      end

      return sboErr

   end

   def ValidateReport347()
      _TRACER("ValidateReport347")
      bizEnv=GetEnv()

      if !bizEnv.IsCurrentLocalSettings(SPAIN_SETTINGS)
         return ooNoErr

      end

      dagJDT=GetDAG()

      sboErr=ooNoErr


      dagJDT.GetColStr(report347Str,OJDT_REPORT_347)
      if report347Str.Compare(VAL_YES)
         return ooNoErr

      end

      sboErr=ValidateVatReportTransType()
      if sboErr==noErr
         numOfBPfound=0

         sboErr=GetNumOfBPRecords(numOfBPfound,false)
         IF_ERROR_RETURN(sboErr)
         if numOfBPfound!=1
            Message(GO_OBJ_ERROR_MSGS(JDT),JDT_347_REPORT_DIFFER_ONE_BP_ERR,NULL,OO_ERROR)
            sboErr=errNoMsg

         end


      end

      if sboErr!=noErr
         SetErrorField(-1)
         SetErrorField(OJDT_REPORT_347)

      end

      return sboErr

   end

   def ValidateVatReportTransType()
      _TRACER("ValidateVatReportTransType")
      sboErr=ooNoErr

      dagJDT=GetDAG()

      if IsManualJE(dagJDT)==false
         Message(GO_OBJ_ERROR_MSGS(JDT),JDT_REPORT_MANUAL_TRANS_ONLY_ERR,NULL,OO_ERROR)
         sboErr=errNoMsg

      end

      return sboErr

   end

   def ValidateBPLEx(bizObject)
      ooErr=noErr

      env=bizObject.GetEnv()

      boJDT=static_cast


   end

   def ValidateBPL(/)
      ooErr=noErr

      env=GetEnv()

      if !VF_MultiBranch_EnabledInOADM(env)
         return noErr

      end

      dagJDT=GetDAG(JDT

      if !DAG::IsValid(dagJDT)
         return noErr

      end


      dagJDT1=GetDAG(JDT

      if !DAG::IsValid(dagJDT1)
         return noErr

      end

      dag1Size=dagJDT1.GetRealSize(dbmDataBuffer)

      dag1Row=0

      begin
         BPLName=dagJDT1.GetColStrAndTrim(JDT1_BPL_NAME

         BPLId=dagJDT1.GetColStr(JDT1_BPL_ID

         BPLIds.insert(BPLId)
         if !CBusinessPlaceObject::IsBPLIdValidForObject(BPLId,JDT,env)
            SetArrNum(ao_Arr1)
            SetErrorLine(dag1Row+)
            SetErrorField(JDT1_BPL_ID)
            Message(CBusinessPlaceObject::ERROR_STRING_LIST_ID,CBusinessPlaceObject::ERRMSG_CANNOT_SELECT_DISABLED_BPL_STR,BPLName,OO_ERROR)
            return ooInvalidObject

         end

         def tmpUserCode
            (env.GetUserCode())
         end

         if !CBusinessPlaceObject::IsBPLIdAssignedToObject(env,BPLId,USR,tmpUserCode)
            SetArrNum(ao_Arr1)
            SetErrorLine(dag1Row+)
            SetErrorField(JDT1_BPL_ID)
            BPLName=dagJDT1.GetColStr(JDT1_BPL_NAME

            CMessagesManager::GetHandle().Message(_132_APP_MSG_AP_AR_USER_NOT_ASSINED_BPL,EMPTY_STR,this,(const))


         end



         dag1Row+=1
      end while (dag1Row<dag1Size)


   end

   def ValidateBPLNumberingSeries()
      env=GetEnv()

      if !VF_MultiBranch_EnabledInOADM(env)
         return noErr

      end

      series=GetSeries()

      if series<=0
         GetDAG().GetColLong(&series,OJDT_SERIES)

      end


      dagJDT1=GetArrayDAG(ao_Arr1)

      dag1Size=dagJDT1.GetRealSize(dbmDataBuffer)

      dag1Row=0

      begin
         BPLId=dagJDT1.GetColStr(JDT1_BPL_ID

         BPLIds.insert(BPLId)


         dag1Row+=1
      end while (dag1Row<dag1Size)

      SBOLongSet::iterator
      begin


         it!=BPLIds.end()
      end while (it=BPLIds.begin())

      it+=1

   end

   def IsBalancedByBPL()
      env=GetEnv()

      if !VF_MultiBranch_EnabledInOADM(env)
         return noErr

      end



   end

   def GetNumOfBPRecords(numOfBPfound, false*/)
      _TRACER("GetNumOfBPRecords")
      dagJDT1=GetDAG(JDT

      recCount=dagJDT1.GetRecordCount()


      indexOfMissingTaxId=-1

      foundECTax=false

      bizEnv=GetEnv()

      numOfBPfound=0
      ii=0

      begin
         dagJDT1.GetColStr(actCode,JDT1_ACCT_NUM,ii)
         dagJDT1.GetColStr(shortName,JDT1_SHORT_NAME,ii)
         if actCode.Compare(shortName)!=0
            numOfBPfound+=1

            if validateFedTaxId&&indexOfMissingTaxId<0
               dagJDT1.GetColStr(fedTaxId,JDT1_TAX_ID_NUMBER,ii)
               if fedTaxId.IsSpacesStr()
                  indexOfMissingTaxId=ii

               end


            end

            ndif

         end


         if validateFedTaxId&&!foundECTax
            dagJDT1.GetColStr(taxGroup,JDT1_VAT_GROUP,ii)
            taxGroup.Trim()
            if !taxGroup.IsSpacesStr()&&bizEnv.GetTaxGroupCache().IsEC(bizEnv,taxGroup)
               foundECTax=true

            end


         end

         ndif


         ii+=1
      end while (ii<recCount)


      if validateFedTaxId&&foundECTax&&indexOfMissingTaxId>=0
         if CMessagesManager::GetHandle().DisplayMessage(_48_APP_MSG_FIN_JDT_MISSING_FEDERAL_TAX_ID)!=DIALOG_YES_BTN
            return errNoMsg

         end


      end

      ndif
      return noErr

   end

   def UpgradeWorkOrderStep1()
      ooErr=ooNoErr









      dagJDT=GetDAG()
      tables[0].tableCode=this.GetEnv().ObjectToTable(JDT)
      tables[1].tableCode=this.GetEnv().ObjectToTable(WKO)
      join[0].colNum=OJDT_REF1
      join[0].tableIndex=0
      join[0].compareCols=true
      join[0].compColNum=OWKO_SERIAL_NUM
      join[0].compTableIndex=1
      join[0].operation=DBD_EQ
      join[0].relationship=DBD_AND
      join[1].colNum=OJDT_TRANS_TYPE
      join[1].tableIndex=0
      join[1].compareCols=false
      join[1].condVal=68L
      join[1].operation=DBD_EQ
      join[1].relationship=0
      tables[1].joinConds=&join[0]
      tables[1].doJoin=true
      tables[1].joinedToTable=0
      tables[1].numOfConds=2
      tables[1].outerJoin=false
      updateStruct[0].colNum=OJDT_CREATED_BY
      updateStruct[0].srcColNum=OWKO_ORDER_NUM
      updateStruct[0].SetUpdateColSource(DBD_UpdStruct::ucs_UseRes)
      pResCol=updateStruct[0].GetResObject().AddResCol()

      pResCol.SetTableIndex(1)
      pResCol.SetColNum(OWKO_ORDER_NUM)
      updateStruct[1].colNum=OJDT_BASE_REF
      updateStruct[1].srcColNum=OWKO_SERIAL_NUM
      updateStruct[1].SetUpdateColSource(DBD_UpdStruct::ucs_UseRes)
      pResCol=updateStruct[1].GetResObject().AddResCol()
      pResCol.SetTableIndex(1)
      pResCol.SetColNum(OWKO_SERIAL_NUM)
      cond[0].colNum=OJDT_CREATED_BY
      cond[0].tableIndex=0
      cond[0].compareCols=true
      cond[0].operation=DBD_NE
      cond[0].compColNum=OWKO_ORDER_NUM
      cond[0].compTableIndex=1
      cond[0].relationship=DBD_AND
      cond[1].bracketOpen=1
      cond[1].SetSubQueryParams(subQueryParams)
      cond[1].tableIndex=DBD_NO_TABLE
      cond[1].operation=DBD_EQ
      _STR_strcpy(cond[1].condVal,STR_1)
      cond[1].bracketClose=1
      cond[1].relationship=DBD_AND
      cond[2].bracketOpen=1
      cond[2].SetSubQueryParams(subQueryParams2)
      cond[2].tableIndex=DBD_NO_TABLE
      cond[2].operation=DBD_EQ
      _STR_strcpy(cond[2].condVal,STR_1)
      cond[2].bracketClose=1
      cond[2].relationship=0
      subtables1[0].tableCode=this.GetEnv().ObjectToTable(WKO)
      subres1[0].colNum=OWKO_SERIAL_NUM
      subres1[0].tableIndex=0
      subres1[0].agreg_type=DBD_COUNT
      subcond1[0].colNum=OWKO_SERIAL_NUM
      subcond1[0].tableIndex=0
      subcond1[0].compareCols=true
      subcond1[0].operation=DBD_EQ
      subcond1[0].compColNum=OWKO_SERIAL_NUM
      subcond1[0].origTableIndex=1
      subcond1[0].origTableLevel=1
      subcond1[0].relationship=0
      DBD_SetCond(subQueryParams,subcond1,1)
      DBD_SetRes(subQueryParams,subres1,1)
      DBD_SetParamTablesList(subQueryParams,subtables1,1)
      subtables2[0].tableCode=this.GetEnv().ObjectToTable(JDT)
      subres2[0].colNum=OJDT_TRANS_TYPE
      subres2[0].tableIndex=0
      subres2[0].agreg_type=DBD_COUNT
      subcond2[0].colNum=OJDT_REF1
      subcond2[0].tableIndex=0
      subcond2[0].compareCols=true
      subcond2[0].operation=DBD_EQ
      subcond2[0].compColNum=OJDT_REF1
      subcond2[0].origTableIndex=0
      subcond2[0].origTableLevel=1
      subcond2[0].relationship=DBD_AND
      subcond2[1].colNum=OJDT_TRANS_TYPE
      subcond2[1].tableIndex=0
      subcond2[1].compareCols=false
      subcond2[1].operation=DBD_EQ
      subcond2[1].condVal=68L
      subcond2[1].relationship=0
      DBD_SetCond(subQueryParams2,subcond2,2)
      DBD_SetRes(subQueryParams2,subres2,1)
      DBD_SetParamTablesList(subQueryParams2,subtables2,1)
      DBD_SetDAGCond(dagJDT,cond,3)
      DBD_SetDAGUpd(dagJDT,updateStruct,2)
      DBD_SetTablesList(dagJDT,tables,2)
      ooErr=DBD_UpdateCols(dagJDT)
      return ooErr

   end

   def UpgradeWorkOrderStep2()
      ooErr=ooNoErr





      dagJDT1=GetDAG(JDT,ao_Arr1)
      tables[0].tableCode=this.GetEnv().ObjectToTable(JDT,ao_Arr1)
      tables[1].tableCode=this.GetEnv().ObjectToTable(JDT)
      join[0].colNum=JDT1_TRANS_ABS
      join[0].tableIndex=0
      join[0].compareCols=true
      join[0].compColNum=OJDT_JDT_NUM
      join[0].compTableIndex=1
      join[0].operation=DBD_EQ
      join[0].relationship=0
      tables[1].joinConds=&join[0]
      tables[1].doJoin=true
      tables[1].joinedToTable=0
      tables[1].numOfConds=1
      tables[1].outerJoin=false
      updateStruct[0].colNum=JDT1_CREATED_BY
      updateStruct[0].srcColNum=OJDT_CREATED_BY
      updateStruct[0].SetUpdateColSource(DBD_UpdStruct::ucs_UseRes)
      pResCol=updateStruct[0].GetResObject().AddResCol()

      pResCol.SetTableIndex(1)
      pResCol.SetColNum(OJDT_CREATED_BY)
      cond[0].colNum=OJDT_CREATED_BY
      cond[0].tableIndex=1
      cond[0].compareCols=true
      cond[0].operation=DBD_NE
      cond[0].compColNum=JDT1_CREATED_BY
      cond[0].compTableIndex=0
      cond[0].relationship=DBD_AND
      cond[1].colNum=OJDT_TRANS_TYPE
      cond[1].tableIndex=1
      cond[1].compareCols=false
      cond[1].operation=DBD_EQ
      cond[1].condVal=68L
      cond[1].relationship=0
      DBD_SetDAGCond(dagJDT1,cond,2)
      DBD_SetDAGUpd(dagJDT1,updateStruct,1)
      DBD_SetTablesList(dagJDT1,tables,2)
      ooErr=DBD_UpdateCols(dagJDT1)
      return ooErr

   end

   def UpgradeWorkOrderStep3()
      ooErr=ooNoErr









      dagJDT=GetDAG()
      tables[0].tableCode=this.GetEnv().ObjectToTable(JDT)
      tables[1].tableCode=this.GetEnv().ObjectToTable(INM)
      join[0].colNum=OJDT_CREATED_BY
      join[0].tableIndex=0
      join[0].compareCols=true
      join[0].compColNum=OINM_CREATED_BY
      join[0].compTableIndex=1
      join[0].operation=DBD_EQ
      join[0].relationship=DBD_AND
      join[1].colNum=OJDT_TRANS_TYPE
      join[1].tableIndex=0
      join[1].compareCols=false
      join[1].condVal=68L
      join[1].operation=DBD_EQ
      join[1].relationship=DBD_AND
      join[2].colNum=OINM_TYPE
      join[2].tableIndex=1
      join[2].compareCols=false
      join[2].condVal=68L
      join[2].operation=DBD_EQ
      join[2].relationship=0
      tables[1].joinConds=&join[0]
      tables[1].doJoin=true
      tables[1].joinedToTable=0
      tables[1].numOfConds=3
      tables[1].outerJoin=false
      updateStruct[0].colNum=OJDT_CREATE_DATE
      updateStruct[0].srcColNum=OINM_CREATE_DATE
      updateStruct[0].SetUpdateColSource(DBD_UpdStruct::ucs_UseRes)
      pResCol=updateStruct[0].GetResObject().AddResCol()

      pResCol.SetTableIndex(1)
      pResCol.SetColNum(OINM_CREATE_DATE)
      cond[0].colNum=OJDT_CREATE_DATE
      cond[0].tableIndex=0
      cond[0].compareCols=false
      cond[0].operation=DBD_IS_NULL
      cond[0].relationship=DBD_AND
      cond[1].bracketOpen=1
      cond[1].SetSubQueryParams(subQueryParams)
      cond[1].tableIndex=DBD_NO_TABLE
      cond[1].operation=DBD_EQ
      cond[1].compareCols=true
      cond[1].compColNum=OINM_TRANS_SEQUENCE
      cond[1].compTableIndex=1
      cond[1].bracketClose=1
      cond[1].relationship=0
      subtables1[0].tableCode=this.GetEnv().ObjectToTable(INM)
      subres1[0].colNum=OINM_TRANS_SEQUENCE
      subres1[0].tableIndex=0
      subres1[0].agreg_type=DBD_MIN
      subcond1[0].colNum=OINM_TYPE
      subcond1[0].tableIndex=0
      subcond1[0].compareCols=true
      subcond1[0].operation=DBD_EQ
      subcond1[0].compColNum=OINM_TYPE
      subcond1[0].origTableIndex=1
      subcond1[0].origTableLevel=1
      subcond1[0].relationship=DBD_AND
      subcond1[1].colNum=OINM_CREATED_BY
      subcond1[1].tableIndex=0
      subcond1[1].compareCols=true
      subcond1[1].operation=DBD_EQ
      subcond1[1].compColNum=OINM_CREATED_BY
      subcond1[1].origTableIndex=1
      subcond1[1].origTableLevel=1
      subcond1[1].relationship=0
      DBD_SetCond(subQueryParams,subcond1,2)
      DBD_SetRes(subQueryParams,subres1,1)
      DBD_SetParamTablesList(subQueryParams,subtables1,1)
      DBD_SetDAGCond(dagJDT,cond,2)
      DBD_SetDAGUpd(dagJDT,updateStruct,1)
      DBD_SetTablesList(dagJDT,tables,2)
      ooErr=DBD_UpdateCols(dagJDT)
      return ooErr

   end

   def UpgradeWorkOrderStep4()
      ooErr=ooNoErr





      dagINM=GetDAG(INM)
      tables[0].tableCode=this.GetEnv().ObjectToTable(INM)
      tables[1].tableCode=this.GetEnv().ObjectToTable(JDT)
      join[0].colNum=OINM_CREATED_BY
      join[0].tableIndex=0
      join[0].compareCols=true
      join[0].compColNum=OJDT_CREATED_BY
      join[0].compTableIndex=1
      join[0].operation=DBD_EQ
      join[0].relationship=DBD_AND
      join[1].colNum=OJDT_TRANS_TYPE
      join[1].tableIndex=1
      join[1].compareCols=false
      join[1].condVal=68L
      join[1].operation=DBD_EQ
      join[1].relationship=DBD_AND
      join[2].colNum=OINM_TYPE
      join[2].tableIndex=0
      join[2].compareCols=false
      join[2].condVal=68L
      join[2].operation=DBD_EQ
      join[2].relationship=0
      tables[1].joinConds=&join[0]
      tables[1].doJoin=true
      tables[1].joinedToTable=0
      tables[1].numOfConds=3
      tables[1].outerJoin=false
      updateStruct[0].colNum=OINM_CREATE_DATE
      updateStruct[0].srcColNum=OJDT_CREATE_DATE
      updateStruct[0].SetUpdateColSource(DBD_UpdStruct::ucs_UseRes)
      pResCol=updateStruct[0].GetResObject().AddResCol()

      pResCol.SetTableIndex(1)
      pResCol.SetColNum(OJDT_CREATE_DATE)
      cond[0].colNum=OINM_CREATE_DATE
      cond[0].tableIndex=0
      cond[0].compareCols=false
      cond[0].operation=DBD_IS_NULL
      cond[0].relationship=0
      DBD_SetDAGCond(dagINM,cond,1)
      DBD_SetDAGUpd(dagINM,updateStruct,1)
      DBD_SetTablesList(dagINM,tables,2)
      ooErr=DBD_UpdateCols(dagINM)
      return ooErr

   end

   def UpgradeLandedCosErr()
      ooErr=ooNoErr







      dagJDT=GetDAG()
      tables[0].tableCode=this.GetEnv().ObjectToTable(INM)
      tables[1].tableCode=this.GetEnv().ObjectToTable(IPF)
      tables[2].tableCode=this.GetEnv().ObjectToTable(JDT)
      joinCondition1[0].colNum=OINM_TYPE
      joinCondition1[0].tableIndex=0
      joinCondition1[0].compareCols=false
      joinCondition1[0].condVal=69L
      joinCondition1[0].operation=DBD_EQ
      joinCondition1[0].relationship=DBD_AND
      joinCondition1[1].colNum=OINM_CREATED_BY
      joinCondition1[1].tableIndex=0
      joinCondition1[1].compareCols=true
      joinCondition1[1].compColNum=OIPF_ABS_ENTRY
      joinCondition1[1].compTableIndex=1
      joinCondition1[1].operation=DBD_EQ
      joinCondition1[1].relationship=0
      tables[1].joinConds=joinCondition1
      tables[1].doJoin=true
      tables[1].joinedToTable=0
      tables[1].numOfConds=2
      tables[1].outerJoin=false
      joinCondition2[0].colNum=OJDT_TRANS_TYPE
      joinCondition2[0].tableIndex=2
      joinCondition2[0].compareCols=false
      joinCondition2[0].condVal=69L
      joinCondition2[0].operation=DBD_EQ
      joinCondition2[0].relationship=DBD_AND
      joinCondition2[1].colNum=OINM_CREATED_BY
      joinCondition2[1].tableIndex=0
      joinCondition2[1].compareCols=true
      joinCondition2[1].compColNum=OJDT_CREATED_BY
      joinCondition2[1].compTableIndex=2
      joinCondition2[1].operation=DBD_EQ
      joinCondition2[1].relationship=DBD_AND
      joinCondition2[2].colNum=OJDT_JDT_NUM
      joinCondition2[2].tableIndex=2
      joinCondition2[2].compareCols=true
      joinCondition2[2].compColNum=OIPF_JDT_NUM
      joinCondition2[2].compTableIndex=1
      joinCondition2[2].operation=DBD_EQ
      joinCondition2[2].relationship=0
      tables[2].joinConds=joinCondition2
      tables[2].doJoin=true
      tables[2].joinedToTable=0
      tables[2].numOfConds=3
      tables[2].outerJoin=false
      Res[0].colNum=OJDT_CREATE_DATE
      Res[0].tableIndex=2
      Res[1].colNum=OINM_CREATE_DATE
      Res[1].tableIndex=0
      Res[2].colNum=OJDT_JDT_NUM
      Res[2].tableIndex=2
      Res[3].colNum=OINM_NUM
      Res[3].tableIndex=0
      cond[0].colNum=OJDT_CREATE_DATE
      cond[0].tableIndex=2
      cond[0].compareCols=false
      cond[0].operation=DBD_IS_NULL
      cond[0].relationship=0
      DBD_SetDAGCond(dagJDT,cond,1)
      DBD_SetDAGRes(dagJDT,Res,4)
      DBD_SetTablesList(dagJDT,tables,3)
      ooErr=DBD_GetInNewFormat(dagJDT,&dagRes)
      if ooErr
         if ooErr==dbmNoDataFound
            return ooNoErr
         else
            return ooErr
         end


      end

      numOfRecords=dagRes.GetRecordCount()
      tables2[0].tableCode=this.GetEnv().ObjectToTable(JDT)
      i=0

      begin



      end while (i)


   end

   def UpgradeWorkOrderErr()
      ooErr=ooNoErr

      ooErr=UpgradeWorkOrderStep1()
      if ooErr
         return ooErr
      end

      ooErr=UpgradeWorkOrderStep2()
      if ooErr
         return ooErr
      end

      ooErr=UpgradeWorkOrderStep3()
      if ooErr
         return ooErr
      end

      ooErr=UpgradeWorkOrderStep4()
      if ooErr
         return ooErr
      end

      return ooErr

   end

   def OJDTFillJDT1FromAccounts(accountsArrayFrom, accountsArrayRes, srcObject)
      _TRACER("OJDTFillJDT1FromAccounts")

      isNegative
      linesAdded = false


      dagJDT1=GetArrayDAG(ao_Arr1)

      dagJDT=GetDAG()

      bizEnv=GetEnv()

      if !DAG_IsValid(dagJDT1)
         return (dbmBadDAG)

      end

      numOfAccts=accountsArrayFrom.GetSize()
      if numOfAccts<=0
         return ooNoErr

      end

      ii=0

      begin
         if !accountsArrayFrom[ii].allowZeros
            if accountsArrayFrom[ii].sum==0&&accountsArrayFrom[ii].sysSum==0&&accountsArrayFrom[ii].frgnSum==0
               next


            end


         end

         linesAdded=true
         accountsArrayRes.Add((accountsArrayFrom[ii].Clone()))
         jdtLine=accountsArrayRes.GetSize()-
         if jdtLine==0L
            DAG_SetSize(dagJDT1,1,dbmDropData)
            dagJDT1.SetBackupSize(1,dbmDropData)

         else
            DAG_SetSize(dagJDT1,jdtLine+,dbmKeepData)

         end

         if !_STR_IsSpacesStr(accountsArrayRes[jdtLine].actCode)
            dagJDT1.SetColStr(accountsArrayRes[jdtLine].actCode,JDT1_ACCT_NUM,jdtLine)

         end

         if !_STR_IsSpacesStr(accountsArrayRes[jdtLine].shortName)
            dagJDT1.SetColStr(accountsArrayRes[jdtLine].shortName,JDT1_SHORT_NAME,jdtLine)

         end

         if !_STR_IsSpacesStr(accountsArrayRes[jdtLine].contraAct)
            dagJDT1.SetColStr(accountsArrayRes[jdtLine].contraAct,JDT1_CONTRA_ACT,jdtLine)

         end

         nDimCount=1

         if VF_CostAcctingEnh(GetEnv())
            nDimCount=DIMENSION_MAX

         end


         dagJDT1.GetColStr(postDate,JDT1_REF_DATE,jdtLine)
         dim=0

         begin



         end while (dim)



         +=1ii
      end while (ii<numOfAccts)


   end

   def OJDTFillAccountsFromJDT1RES(dag, resDagFields, accountsArrayRes)
      _TRACER("OJDTFillAccountsFromJDT1RES")



      numOfRecs=dag.GetRecordCount()
      rec=0
      begin



      end while (rec)


   end

   def SetVatJournalEntryFlag()
      _TRACER("SetVatJournalEntryFlag")
      m_isVatJournalEntry=true

   end

   def OnGetTaxAdaptor()
      _TRACER("OnGetTaxAdaptor")
      if !m_taxAdaptor
         m_taxAdaptor=CTaxAdaptorJournalEntry.new((this))

      end

      return m_taxAdaptor

   end

   def CreateTax()
      _TRACER("CreateTax")
      taxAdaptor=OnGetTaxAdaptor()

      if !taxAdaptor
         return ooNoErr

      end

      ooErr=ooNoErr

      if VF_DeferredTaxInJE(GetEnv())
         ooErr=taxAdaptor.SetJEDeferredTax()
         if ooErr
            return ooErr

         end


      end

      dagJDT=GetDAG()


      dagJDT.GetColLong(&transId,OJDT_JDT_NUM)
      return taxAdaptor.Create(transId)

   end

   def UpdateTax()
      _TRACER("UpdateTax")
      taxAdaptor=OnGetTaxAdaptor()

      if !taxAdaptor
         return ooNoErr

      end

      dagJDT=GetDAG()


      dagJDT.GetColLong(&transId,OJDT_JDT_NUM)
      return taxAdaptor.Update(transId)

   end

   def LoadTax()
      _TRACER("LoadTax")
      taxAdaptor=OnGetTaxAdaptor()

      if !taxAdaptor
         return ooNoErr

      end

      dagJDT=GetDAG()


      dagJDT.GetColLong(&transId,OJDT_JDT_NUM)

      ooErr=taxAdaptor.Load(transId)
      if ooErr==dbmNoDataFound
         ooErr=ooNoErr

      end

      return ooErr

   end

   def OJDTSetPaymentJdtOpenBalanceSums(paymentObject, dagJDT1, resDagFields, fromOffset, foundCaseK)
      _TRACER("OJDTSetPaymentJdtOpenBalanceSums")

      sboErr=noErr


      sboErr=CTransactionJournalObject::OJDTFillAccountsFromJDT1RES(dagJDT1,resDagFields,(AccountsArray*)&actsArray)
      if sboErr
         return sboErr

      end

      sboErr=paymentObject.CalculateSplitLinesMatchSums(&actsArray,false)
      if sboErr
         return sboErr

      end

      actsArraySize=actsArray.GetSize()




      ii=0

      begin
         dagJDT1.GetColLong(&internalMatch,resDagFields[JDT_PAYMENT_UPG_DOC_INTR_MATCH],fromOffset+)
         dagJDT1.GetColLong(&multMatch,resDagFields[JDT_PAYMENT_UPG_DOC_MULT_MATCH],fromOffset+)
         dagJDT1.GetColStr(closed,resDagFields[JDT_PAYMENT_UPG_DOC_CLOSED],fromOffset+)
         if ((internalMatch!=0)&&(!foundCaseK))||(multMatch!=0)||(closed==VAL_YES)
            next


         end

         if actsArray[ii].GetMatchTotalLineFlag()
            tmpM=actsArray[ii].sum
            tmpFC=actsArray[ii].frgnSum
            tmpSC=actsArray[ii].sysSum

         else
            if actsArray[ii].debCred==CREDIT
               dagJDT1.GetColMoney(&tmpM,resDagFields[JDT_PAYMENT_UPG_DOC_BALANCE_DUE_CREDIT],fromOffset+)
               dagJDT1.GetColMoney(&tmpFC,resDagFields[JDT_PAYMENT_UPG_DOC_BALANCE_DUE_FC_CRED],fromOffset+)
               dagJDT1.GetColMoney(&tmpSC,resDagFields[JDT_PAYMENT_UPG_DOC_BALANCE_DUE_SC_CRED],fromOffset+)

            else
               dagJDT1.GetColMoney(&tmpM,resDagFields[JDT_PAYMENT_UPG_DOC_BALANCE_DUE_DEBIT],fromOffset+)
               dagJDT1.GetColMoney(&tmpFC,resDagFields[JDT_PAYMENT_UPG_DOC_BALANCE_DUE_FC_DEB],fromOffset+)
               dagJDT1.GetColMoney(&tmpSC,resDagFields[JDT_PAYMENT_UPG_DOC_BALANCE_DUE_SC_DEB],fromOffset+)

            end


         end

         tmpM+=actsArray[ii].GetMatchSum()
         tmpFC+=actsArray[ii].GetMatchSumFC()
         tmpSC+=actsArray[ii].GetMatchSumSC()
         if actsArray[ii].debCred==CREDIT
            dagJDT1.SetColMoney(&tmpM,resDagFields[JDT_PAYMENT_UPG_DOC_BALANCE_DUE_CREDIT],fromOffset+)
            dagJDT1.SetColMoney(&tmpFC,resDagFields[JDT_PAYMENT_UPG_DOC_BALANCE_DUE_FC_CRED],fromOffset+)
            dagJDT1.SetColMoney(&tmpSC,resDagFields[JDT_PAYMENT_UPG_DOC_BALANCE_DUE_SC_CRED],fromOffset+)

         else
            dagJDT1.SetColMoney(&tmpM,resDagFields[JDT_PAYMENT_UPG_DOC_BALANCE_DUE_DEBIT],fromOffset+)
            dagJDT1.SetColMoney(&tmpFC,resDagFields[JDT_PAYMENT_UPG_DOC_BALANCE_DUE_FC_DEB],fromOffset+)
            dagJDT1.SetColMoney(&tmpSC,resDagFields[JDT_PAYMENT_UPG_DOC_BALANCE_DUE_SC_DEB],fromOffset+)

         end



         ii+=1
      end while (ii<actsArraySize)

      return noErr

   end

   def UpgradeOJDTCreatedByForWOR()
      _TRACER("UpgradeOJDTCreatedByForWOR")
      sboErr=noErr

      bizEnv=GetEnv()

      dagRes
      dagJDT = GetDAG()
      dagQuery = GetDAG(CRD)




      dagQuery.GetDBDParams().Clear()
      resStruct[0].tableIndex=0
      resStruct[0].colNum=OWOR_NUM
      resStruct[0].group_by=true
      resStruct[1].tableIndex=0
      resStruct[1].colNum=OWOR_ABS_ENTRY
      resStruct[1].agreg_type=DBD_MAX

      tables=dagQuery.GetDBDParams().GetCondTables()

      tablePtr=&tables.AddTable()
      tablePtr.tableCode=bizEnv.ObjectToTable(WOR)
      tablePtr=&tables.AddTable()
      tablePtr.tableCode=bizEnv.ObjectToTable(JDT)
      tablePtr.doJoin=true
      tablePtr.joinedToTable=0
      tablePtr.numOfConds=2
      tablePtr.joinConds=join
      join[0].compareCols=true
      join[0].compColNum=OWOR_NUM
      join[0].compTableIndex=0
      join[0].colNum=OJDT_CREATED_BY
      join[0].tableIndex=1
      join[0].operation=DBD_EQ
      join[0].relationship=DBD_AND
      join[1].compareCols=false
      join[1].colNum=OJDT_TRANS_TYPE
      join[1].tableIndex=1
      join[1].operation=DBD_EQ
      join[1].condVal=WOR
      join[1].relationship=0
      DBD_SetDAGRes(dagQuery,resStruct,2)
      sortStruct[0].colNum=OWOR_NUM
      DBD_SetDAGSort(dagQuery,sortStruct,1)
      sboErr=DBD_GetInNewFormat(dagQuery,&dagRes)
      if sboErr
         return (sboErr==dbmNoDataFound)

      end


   end

   def GetBaseEntry(dagRes, docNum)
      _TRACER("GetBaseEntry")


      start=0
      DAG_GetCount(dagRes,&numOfRecs)
      if !numOfRecs
         return -1

      end

   end=numOfRecs-
   begin
      mid=(start++)/2
      dagRes.GetColLong(&DagDocNum,0,mid)
      if docNum==DagDocNum
         dagRes.GetColLong(&result,1,mid)
         return result

      else
         if docNum>DagDocNum
            start=mid+

         else
         end=mid-

      end

   end


end while (start<=end)

return -1

end

def SetDebitCreditField()
_TRACER("SetDebitCreditField")



dagJDT1=GetDAG(JDT,ao_Arr1)
DAG_GetCount(dagJDT1,&numOfRecs)
rec=0
begin
   if dagJDT1.IsNullCol(JDT1_DEBIT_CREDIT,rec)
      dagJDT1.GetColMoney(&debAmount,JDT1_DEBIT,rec,DBM_NOT_ARRAY)
      if !debAmount.IsZero()
         dagJDT1.SetColStr(VAL_DEBIT,JDT1_DEBIT_CREDIT,rec)
         next


      end

      dagJDT1.GetColMoney(&credAmount,JDT1_CREDIT,rec,DBM_NOT_ARRAY)
      if !credAmount.IsZero()
         dagJDT1.SetColStr(VAL_CREDIT,JDT1_DEBIT_CREDIT,rec)
         next


      end

      dagJDT1.GetColMoney(&debAmount,JDT1_SYS_DEBIT,rec,DBM_NOT_ARRAY)
      if !debAmount.IsZero()
         dagJDT1.SetColStr(VAL_DEBIT,JDT1_DEBIT_CREDIT,rec)
         next


      end

      dagJDT1.GetColMoney(&credAmount,JDT1_SYS_CREDIT,rec,DBM_NOT_ARRAY)
      if !credAmount.IsZero()
         dagJDT1.SetColStr(VAL_CREDIT,JDT1_DEBIT_CREDIT,rec)
         next


      end

      dagJDT1.GetColMoney(&debAmount,JDT1_FC_DEBIT,rec,DBM_NOT_ARRAY)
      if !debAmount.IsZero()
         dagJDT1.SetColStr(VAL_DEBIT,JDT1_DEBIT_CREDIT,rec)
         next


      end

      dagJDT1.GetColMoney(&credAmount,JDT1_FC_CREDIT,rec,DBM_NOT_ARRAY)
      if !credAmount.IsZero()
         dagJDT1.SetColStr(VAL_CREDIT,JDT1_DEBIT_CREDIT,rec)
         next


      end

      dagJDT1.GetColMoney(&debAmount,JDT1_BALANCE_DUE_DEBIT,rec,DBM_NOT_ARRAY)
      if !debAmount.IsZero()
         dagJDT1.SetColStr(VAL_DEBIT,JDT1_DEBIT_CREDIT,rec)
         next


      end

      dagJDT1.GetColMoney(&credAmount,JDT1_BALANCE_DUE_CREDIT,rec,DBM_NOT_ARRAY)
      if !credAmount.IsZero()
         dagJDT1.SetColStr(VAL_CREDIT,JDT1_DEBIT_CREDIT,rec)
         next


      end

      dagJDT1.GetColMoney(&debAmount,JDT1_BALANCE_DUE_FC_DEB,rec,DBM_NOT_ARRAY)
      if !debAmount.IsZero()
         dagJDT1.SetColStr(VAL_DEBIT,JDT1_DEBIT_CREDIT,rec)
         next


      end

      dagJDT1.GetColMoney(&credAmount,JDT1_BALANCE_DUE_FC_CRED,rec,DBM_NOT_ARRAY)
      if !credAmount.IsZero()
         dagJDT1.SetColStr(VAL_CREDIT,JDT1_DEBIT_CREDIT,rec)
         next


      end

      dagJDT1.GetColMoney(&debAmount,JDT1_BALANCE_DUE_SC_DEB,rec,DBM_NOT_ARRAY)
      if !debAmount.IsZero()
         dagJDT1.SetColStr(VAL_DEBIT,JDT1_DEBIT_CREDIT,rec)
         next


      end

      dagJDT1.GetColMoney(&credAmount,JDT1_BALANCE_DUE_SC_CRED,rec,DBM_NOT_ARRAY)
      if !credAmount.IsZero()
         dagJDT1.SetColStr(VAL_CREDIT,JDT1_DEBIT_CREDIT,rec)
         next


      end


   end



   rec+=1
end while (rec<numOfRecs)

return ooNoErr

end

def UpgradeOJDTWithFolio()
_TRACER("UpgradeOJDTWithFolio")
dagJDT=NULL
dagJDT1 = NULL
dagFolioRes






ooErr=noErr

bizEnv=GetEnv()

dagJDT1=GetArrayDAG(ao_Arr1)
dagJDT=GetDAG()
ooErr=dagJDT.GetFirstChunk(UPG_OJDT_FOLIO_CHUNK_SIZE)
while (ooErr==noErr)
   numOfRecs=dagJDT.GetRealSize(dbmDataBuffer)
   rec=0
   begin
      dagJDT.GetColLong(&curTransId,OJDT_JDT_NUM,rec)
      dagJDT.GetColLong(&curTransType,OJDT_TRANS_TYPE,rec)
      dagJDT.GetColLong(&curCreatedBy,OJDT_CREATED_BY,rec)
      case curTransType

      when DLN
      when RDN
      when INV
      when RIN
      when DPI
      when DPO
      when PDN
      when RPD
      when PCH
      when RPC
      when IGN
      when IGE
      when WTR
         prefCol=OINV_FOLIO_PREFIX
         folioCol=OINV_FOLIO_NUMBER
         break
      when BOE
         prefCol=OBOE_FOLIO_PREFIX
         folioCol=OBOE_FOLIO_NUMBER
         break
      else
         next


      end

      folioResStruct[0].tableIndex=0
      folioResStruct[0].colNum=prefCol
      folioResStruct[1].tableIndex=0
      folioResStruct[1].colNum=folioCol
      tables=dagJDT1.GetDBDParams().GetCondTables()

      tables.Clear()
      table=&tables.AddTable()
      table.tableCode=bizEnv.ObjectToTable(curTransType)
      conditions=dagJDT1.GetDBDParams().GetConditions()

      conditions.Clear()
      cond=&conditions.AddCondition()
      cond.colNum=OINV_ABS_ENTRY
      cond.tableIndex=0
      cond.operation=DBD_EQ
      cond.condVal=curCreatedBy
      DBD_SetDAGRes(dagJDT1,folioResStruct,2)
      ooErr=DBD_GetInNewFormat(dagJDT1,&dagFolioRes)
      if ooErr
         if ooErr==dbmNoDataFound
            ooErr=noErr
            next


         end

         return ooErr

      end

      dagFolioRes.GetColStr(curPrefix,0)
      dagFolioRes.GetColStr(curFolioNum,1)
      dagJDT.SetColStr(curPrefix,OJDT_FOLIO_PREFIX,rec)
      dagJDT.SetColStr(curFolioNum,OJDT_FOLIO_NUMBER,rec)


      rec+=1
   end while (rec<numOfRecs)

   ooErr=dagJDT.UpdateAll()
   if ooErr
      return ooErr

   end

   ooErr=dagJDT.GetNextChunk(UPG_OJDT_FOLIO_CHUNK_SIZE)

end

if ooErr==dbmNoDataFound
   ooErr=noErr

end

return ooErr

end

def OnInitFlow()
_TRACER("OnInitFlow")
bizEnv=GetEnv()

bizEnv.AddCache(ACT)
bizEnv.AddCache(CRD)
return ooNoErr

end

def CancelJournalEntryInObject(objectId, postingDate/*=EMPTY_STR*/, taxDate/*=EMPTY_STR*/, dueDate/*=EMPTY_STR*/)
_TRACER("CancelJournalEntryInObject")


dagOBJ=GetDAG(objectId.GetBuffer())

colNum=dagOBJ.GetColumnByType(CREATED_JDT_NUM_FLD)

if colNum<0
   colNum=dagOBJ.GetColumnByType(TRANS_ABS_ENT_FLD)

end

dagOBJ.GetColStr(jdtNum,colNum)
ooErr=GetByKey(jdtNum,OJDT_KEYNUM_PRIMARY)
if ooErr&&ooErr!=dbmNoDataFound&&ooErr!=dbmArrayRecordNotFound
   return ooErr

end

dagJDT=GetDAG()

dagJDT1=GetArrayDAG(ao_Arr1)

ooErr=DBD_GetKeyGroup(dagJDT1,JDT1_KEYNUM_PRIMARY,jdtNum,TRUE)
if ooErr
   return (ooErr)

end

bizEnv=GetEnv()

DBM_DATE_Get(sysDate,bizEnv)
dateColNum=dagOBJ.GetColumnByType(DATE_FLD)

if postingDate.IsSpacesStr()
   if dateColNum>0
      dagOBJ.GetColStr(postingDate,dateColNum,0)
      dagJDT.SetColStr(postingDate,OJDT_STORNO_DATE)

   else
      postingDate=sysDate

   end


end

cancelMode=JE_CANCEL_DATE_FUTURE

if postingDate.strtol()<sysDate.strtol()
   if GetExCommand2()&ooEx2SetCurrentRefDate
      cancelMode=JE_CANCEL_DATE_SYSTEM

   else
      cancelMode=JE_CANCEL_DATE_ORIGINAL

   end


end

if GetExCommand2()&ooEx2SetCurrentRefDate
   cancelDate=sysDate

else
   cancelDate=postingDate

end

if sysDate.strtol()<postingDate.strtol()
   cancelDate=postingDate

end

if taxDate.IsSpacesStr()
   taxDate=cancelDate

end

SetJECancelDate(bizEnv,cancelDate,dagOBJ,dagJDT,dagJDT1,taxDate,dueDate,cancelMode,sysDate)
series=bizEnv.GetDefaultSeriesByDate(dagJDT1.GetColStr(JDT1_BPL_ID

dagJDT.SetColLong(series,OJDT_SERIES)
ooErr=DoSingleStorno()
return ooErr

end

def SetJECancelDate(bizEnv, sCancelDate, dagOBJ, dagJDT, dagJDT1, taxDate, dueDate, cancelMode, sysDate)
_TRACER("SetJECancelDate")

dagJDT.GetColLong(&objType,OJDT_TRANS_TYPE)
isPayment=RCT==objType||VPM==objType

useFutureCancelMode=!isPayment

dagJDT.SetColStr(sCancelDate,OJDT_REF_DATE)
dagJDT.SetColStr(taxDate,OJDT_TAX_DATE)
if useFutureCancelMode
   if dueDate.IsSpacesStr()
      dagJDT.SetColStr(sCancelDate,OJDT_DUE_DATE)

   else
      dagJDT.SetColStr(dueDate,OJDT_DUE_DATE)

   end


else
   if JE_CANCEL_DATE_SYSTEM==cancelMode
      dagJDT.SetColStr(sysDate,OJDT_DUE_DATE)

   end


end

dagJDT.SetColStr(sCancelDate,OJDT_STORNO_DATE)
jdt1RecCount=dagJDT1.GetRecordCount()

row=0

begin

   dagJDT1.GetColStr(ocrCode,JDT1_OCR_CODE,row)

   COverheadCostRateObject::GetValidFrom(bizEnv,ocrCode,sCancelDate,validFrom)
   dagJDT1.SetColStr(validFrom,JDT1_VALID_FROM,row)
   if useFutureCancelMode
      dagJDT1.SetColStr(taxDate,JDT1_TAX_DATE,row)
      dagJDT1.SetColStr(sCancelDate,JDT1_REF_DATE,row)
      if dueDate.IsSpacesStr()
         dagJDT1.SetColStr(sCancelDate,JDT1_DUE_DATE,row)

      else
         dagJDT1.SetColStr(dueDate,JDT1_DUE_DATE,row)

      end


   else
      if JE_CANCEL_DATE_SYSTEM==cancelMode
         dagJDT1.SetColStr(sysDate,JDT1_DUE_DATE,row)
         dagJDT1.SetColStr(sysDate,JDT1_REF_DATE,row)
         dagJDT1.SetColStr(sysDate,JDT1_TAX_DATE,row)

      end


   end



   row+=1
end while (row<jdt1RecCount)

dagOBJ.SetStrByColType(sCancelDate,CANCELLATION_DATE_FLD)

end

def UpgradeJDTCreateDate()
_TRACER("UpgradeJDTCreateDate")










dagJDT=GetDAG()
resStruct[0].colNum=OJDT_JDT_NUM
resStruct[0].agreg_type=0
DBD_SetDAGRes(dagJDT,resStruct,1)
conditions=&dagJDT.GetDBDParams().GetConditions()
cond=&conditions.AddCondition()
cond.colNum=OJDT_CREATE_DATE
cond.operation=DBD_IS_NULL
cond.relationship=DBD_AND
cond=&conditions.AddCondition()
cond.bracketOpen=2
cond.colNum=OJDT_TRANS_TYPE
cond.operation=DBD_EQ
cond.condVal=PDN
cond.relationship=DBD_AND
cond=&conditions.AddCondition()
UpgradeCreateDateSubQuery(&subParamsPDN,subResStructPDN,subTableStructPDN,subCondPDN,PDN)
cond.SetSubQueryParams(&subParamsPDN)
cond.tableIndex=DBD_NO_TABLE
cond.operation=DBD_NOT_EXISTS
cond.bracketClose=1
cond.relationship=DBD_OR
cond=&conditions.AddCondition()
cond.bracketOpen=1
cond.colNum=OJDT_TRANS_TYPE
cond.operation=DBD_EQ
cond.condVal=RPD
cond.relationship=DBD_AND
cond=&conditions.AddCondition()
UpgradeCreateDateSubQuery(&subParamsRPD,subResStructRPD,subTableStructRPD,subCondRPD,RPD)
cond.SetSubQueryParams(&subParamsRPD)
cond.tableIndex=DBD_NO_TABLE
cond.operation=DBD_NOT_EXISTS
cond.bracketClose=2
cond.relationship=0
sort[0].colNum=OJDT_JDT_NUM
DBD_SetDAGSort(dagJDT,sort,1)
ooErr=DBD_GetInNewFormat(dagJDT,&dagRES1)
if ooErr
   if ooErr==dbmNoDataFound
      ooErr=noErr

   end

   return ooErr

end

dagRES1.Detach()
resStruct[0].colNum=OJDT_JDT_NUM
resStruct[0].agreg_type=DBD_MAX
resStruct[1].colNum=OJDT_CREATE_DATE
resStruct[1].group_by=true
DBD_SetDAGRes(dagJDT,resStruct,2)
conditions=&dagJDT.GetDBDParams().GetConditions()
cond=&conditions.AddCondition()
cond.colNum=OJDT_CREATE_DATE
cond.operation=DBD_NOT_NULL
cond.relationship=0
ooErr=DBD_GetInNewFormat(dagJDT,&dagRES2)
if ooErr
   dagRES1.Close()
   if ooErr==dbmNoDataFound
      ooErr=noErr

   end

   return ooErr

end

cols=""

oreder=""

dagRES2.SortByCols(cols,oreder,1,false,false)
numOfRecsRES1
numOfRecsRES2
updateTransNum
transOfNewDateInRES2
jj = 0


updStruct[0].colNum=OJDT_CREATE_DATE
numOfRecsRES1=dagRES1.GetRecordCount()
numOfRecsRES2=dagRES2.GetRecordCount()
ii=0

begin
   dagRES1.GetColLong(&updateTransNum,RES1_TRANS_ABS,ii)
   while (jj<numOfRecsRES2)
      dagRES2.GetColLong(&transOfNewDateInRES2,RES2_TRANS_ABS,jj)
      if updateTransNum<transOfNewDateInRES2
         conditions=&dagJDT.GetDBDParams().GetConditions()
         cond=&conditions.AddCondition()
         cond.colNum=OJDT_JDT_NUM
         cond.operation=DBD_EQ
         cond.condVal=SBOString(updateTransNum)
         cond.relationship=0
         dagRES2.GetColStr(updStruct[0].updateVal,RES2_CREATEDATE,jj)
         DBD_SetDAGUpd(dagJDT,updStruct,1)
         ooErr=DBD_UpdateCols(dagJDT)
         if ooErr
            dagRES1.Close()
            return ooErr

         end

         break

      end

      jj+=1

   end



   ii+=1
end while (ii<numOfRecsRES1)

dagRES1.Close()
return noErr

end

def UpgradeCreateDateSubQuery(subParams, subResStruct, subTableStruct, subCond, objectID)
_TRACER("UpgradeCreateDateSubQuery")
bizEnv=GetEnv()

isPDN=(objectID==PDN)

_STR_strcpy(subTableStruct[0].tableCode,bizEnv.ObjectToTable(isPDN))

end

def UpgradeJDTCanceledDeposit()
_TRACER("UpgradeJDTCanceledDeposit")









dagJDT=GetDAG()
dagJDT1=GetDAG(JDT,ao_Arr1)
resStruct[0].colNum=OJDT_JDT_NUM
resStruct[1].colNum=OJDT_NUMBER
DBD_SetDAGRes(dagJDT,resStruct,2)
conditions=&dagJDT.GetDBDParams().GetConditions()
cond=&conditions.AddCondition()
cond.colNum=OJDT_TRANS_TYPE
cond.operation=DBD_EQ
cond.condVal=SBOString(DPS)
cond.relationship=DBD_AND
_STR_strcpy(subTableStruct[0].tableCode,GetEnv().ObjectToTable(DPS))
subResStruct[0].colNum=ODPS_ABS_ENT
subResStruct[0].tableIndex=0
subCond[0].compareCols=TRUE
subCond[0].tableIndex=0
subCond[0].colNum=OJDT_JDT_NUM
subCond[0].compColNum=ODPS_TRANS_ABS
subCond[0].operation=DBD_EQ
subCond[0].origTableIndex=0
subCond[0].origTableLevel=1
subCond[0].relationship=0
DBD_SetParamTablesList(&subParams,subTableStruct,1)
DBD_SetCond(&subParams,subCond,1)
DBD_SetRes(&subParams,subResStruct,1)
cond=&conditions.AddCondition()
cond.SetSubQueryParams(&subParams)
cond.tableIndex=DBD_NO_TABLE
cond.operation=DBD_NOT_EXISTS
cond.relationship=0
ooErr=DBD_GetInNewFormat(dagJDT,&dagRES)
if ooErr
   if ooErr==dbmNoDataFound
      ooErr=noErr

   end

   return ooErr

end


updStructJDT[0].colNum=OJDT_TRANS_TYPE
updStructJDT[1].colNum=OJDT_CREATED_BY
updStructJDT[2].colNum=OJDT_BASE_REF
updStructJDT1[0].colNum=JDT1_TRANS_TYPE
updStructJDT1[1].colNum=JDT1_CREATED_BY
updStructJDT1[2].colNum=JDT1_BASE_REF
updStructJDT[0].updateVal=SBOString(JDT)
updStructJDT1[0].updateVal=SBOString(JDT)
numOfRecs=dagRES.GetRecordCount()

ii=0

begin



end while (ii)


end

def UpgradeJDT1VatLineToNo()
sboErr=noErr

bizEnv=GetEnv()






queryDag=GetDAG()

_STR_strcpy(subQueryTableStruct[0].tableCode,bizEnv.ObjectToTable(JDT,ao_Main))
DBD_SetParamTablesList(subQueryParams,subQueryTableStruct,1)
subQueryRES[0].tableIndex=0
subQueryRES[0].colNum=OJDT_JDT_NUM
DBD_SetRes(subQueryParams,subQueryRES,1)
subConds[0].compareCols=true
subConds[0].origTableLevel=1
subConds[0].origTableIndex=0
subConds[0].colNum=JDT1_TRANS_ABS
subConds[0].operation=DBD_EQ
subConds[0].compTableIndex=0
subConds[0].compColNum=OJDT_JDT_NUM
subConds[0].relationship=DBD_AND
subConds[1].colNum=OJDT_AUTO_VAT
subConds[1].operation=DBD_EQ
subConds[1].condVal=VAL_NO
subConds[1].relationship=DBD_AND
subConds[2].bracketOpen=1
subConds[2].colNum=OJDT_TRANS_TYPE
subConds[2].operation=DBD_EQ
subConds[2].condVal=MANUAL_BANK_TRANS_TYPE
subConds[2].relationship=DBD_OR
subConds[3].colNum=OJDT_TRANS_TYPE
subConds[3].operation=DBD_EQ
subConds[3].condVal=JDT
subConds[3].bracketClose=1
subConds[3].relationship=0
DBD_SetCond(subQueryParams,subConds,4)
updStruct[0].colNum=JDT1_VAT_LINE
updStruct[0].updateVal=VAL_NO
DBD_SetDAGUpd(queryDag,updStruct,1)
_STR_strcpy(tableStruct[0].tableCode,bizEnv.ObjectToTable(JDT,ao_Arr1))
DBD_SetTablesList(queryDag,tableStruct,1)
mainConds[0].colNum=JDT1_VAT_LINE
mainConds[0].operation=DBD_EQ
mainConds[0].condVal=VAL_YES
mainConds[0].relationship=DBD_AND
mainConds[1].bracketOpen=1
mainConds[1].colNum=JDT1_VAT_GROUP
mainConds[1].operation=DBD_IS_NULL
mainConds[1].relationship=DBD_OR
mainConds[2].colNum=JDT1_VAT_GROUP
mainConds[2].operation=DBD_EQ
mainConds[2].condVal=EMPTY_STR
mainConds[2].bracketClose=1
mainConds[2].relationship=DBD_AND
mainConds[3].tableIndex=-1
mainConds[3].operation=DBD_EXISTS
mainConds[3].SetSubQueryParams(subQueryParams)
mainConds[3].relationship=0
DBD_SetDAGCond(queryDag,mainConds,4)
sboErr=DBD_UpdateCols(queryDag)
if sboErr&&sboErr!=dbmNoDataFound
   return sboErr

end

return noErr

end

def UpgradeYearTransfer()




dagJDT=GetDAG()
conditions=&dagJDT.GetDBDParams().GetConditions()
cond=&conditions.AddCondition()
cond.colNum=OJDT_TRANS_TYPE
cond.operation=DBD_EQ
cond.condVal=OPEN_BLNC_TYPE
cond.relationship=DBD_AND
cond=&conditions.AddCondition()
cond.colNum=OJDT_BATCH_NUM
cond.operation=DBD_NOT_NULL
cond.relationship=DBD_AND
cond=&conditions.AddCondition()
cond.colNum=OJDT_BATCH_NUM
cond.operation=DBD_NE
cond.condVal=STR_0
cond.relationship=DBD_AND
cond=&conditions.AddCondition()
cond.colNum=OJDT_DATA_SOURCE
cond.operation=DBD_EQ
cond.condVal=VAL_UNKNOWN_SOURCE
cond.relationship=0
updStructJDT[0].colNum=OJDT_DATA_SOURCE
updStructJDT[0].updateVal=VAL_YEAR_TRANSFER_SOURCE
DBD_SetDAGUpd(dagJDT,updStructJDT,1)
return DBD_UpdateCols(dagJDT)

end

def AddRowByParent(pParentDAG, lParentRow, pChildDAG)
lDagSize=pChildDAG.GetSize(dbmDataBuffer)

sboErr=pChildDAG.SetSize(lDagSize+

if sboErr!=noErr
   return sboErr
end

if pChildDAG.GetTableName()==m_env.ObjectToTable(JDT,ao_Arr1)&&NULL!=pParentDAG
   pChildDAG.CopyColumn(pParentDAG,JDT1_TRANS_ABS,lDagSize,OJDT_JDT_NUM,lParentRow)
   pChildDAG.SetColLong(lDagSize,JDT1_LINE_ID,lDagSize)

end

if pChildDAG.GetTableName()==m_env.ObjectToTable(CFT,ao_Main)&&NULL!=pParentDAG
   pChildDAG.CopyColumn(pParentDAG,OCFT_JDT_ID,lDagSize,JDT1_TRANS_ABS,lParentRow)
   pChildDAG.CopyColumn(pParentDAG,OCFT_JDT_LINE_ID,lDagSize,JDT1_LINE_ID,lParentRow)

end

return noErr

end

def GetFirstRowByParent(pParentDAG, lParentRow, pChildDAG)
if pChildDAG.GetTableName()==m_env.ObjectToTable(CFT,ao_Main)&&NULL!=pParentDAG
   lDagSize=pChildDAG.GetSize(dbmDataBuffer)

   if lDagSize==0
      return -1

   end



   pParentDAG.GetColLong(&transId,JDT1_TRANS_ABS,lParentRow)
   pParentDAG.GetColLong(&lineId,JDT1_LINE_ID,lParentRow)
   ii=0

   begin


      pChildDAG.GetColLong(&jeAbsID,OCFT_JDT_ID,ii)
      pChildDAG.GetColLong(&jeLineId,OCFT_JDT_LINE_ID,ii)
      if jeAbsID==transId&&jeLineId==lineId
         return ii

      end



      ii+=1
   end while (ii<lDagSize)


end

if pChildDAG.GetTableName()==m_env.ObjectToTable(JDT,ao_Arr1)
   lDagSize=pChildDAG.GetSize(dbmDataBuffer)

   if lDagSize==0
      return -1

   end


   pParentDAG.GetColLong(&transId,OJDT_JDT_NUM,lParentRow)
   ii=0

   begin

      pChildDAG.GetColLong(&transAbs,JDT1_TRANS_ABS,ii)
      if transAbs==transId
         return ii

      end



      ii+=1
   end while (ii<lDagSize)


else
   if VF_JEWHT(m_env)&&pChildDAG.GetTableName()==m_env.ObjectToTable(JDT,ao_Arr2)
      lDagSize=pChildDAG.GetSize(dbmDataBuffer)

      if lDagSize==0
         return -1

      end


      pParentDAG.GetColLong(&transId,OJDT_JDT_NUM,lParentRow)
      ii=0

      begin

         pChildDAG.GetColLong(&transAbs,JDT2_ABS_ENTRY,ii)
         if transAbs==transId
            return ii

         end



         ii+=1
      end while (ii<lDagSize)


   else
      return CSystemBusinessObject::GetFirstRowByParent(pParentDAG,lParentRow,pChildDAG)

   end


end

return -1

end

def GetNextRow(pParentDAG, pDAG, lRow, bNext)
if pDAG.GetTableName()==m_env.ObjectToTable(CFT,ao_Main)&&NULL!=pParentDAG
   lDagSize=pDAG.GetSize(dbmDataBuffer)

   if lRow<0||lRow>=lDagSize
      return -1

   end

   delta=bNext


end


end

def GetLogicRowCount(pParentDAG, lParentRow, pDAG)
_TRACER("GetLogicRowCount")
if pDAG.GetTableName()==m_env.ObjectToTable(JDT,ao_Arr1)
   return pDAG.GetRealSize(dbmDataBuffer)

else
   return CBusinessService::GetLogicRowCount(pParentDAG,lParentRow,pDAG)

end


end

def RepairTaxTable()
sboErr=0

bizEnv=GetEnv()








queryDag=GetDAG(TAX

if !bizEnv.IsVatPerLine()
   return noErr

end

_STR_strcpy(subQueryTableStruct[0].tableCode,bizEnv.ObjectToTable(TAX,ao_Arr1))
_STR_strcpy(subQueryTableStruct[1].tableCode,bizEnv.ObjectToTable(TAX,ao_Main))
_STR_strcpy(subQueryTableStruct[2].tableCode,bizEnv.ObjectToTable(JDT,ao_Arr1))
subQueryTableStruct[1].doJoin=TRUE
subQueryTableStruct[1].joinedToTable=0
subQueryTableStruct[1].numOfConds=1
subQueryTableStruct[1].joinConds=joinToTAX1
subQueryTableStruct[2].doJoin=TRUE
subQueryTableStruct[2].joinedToTable=1
subQueryTableStruct[2].numOfConds=3
subQueryTableStruct[2].joinConds=joinToOTAX
joinToTAX1[0].compareCols=TRUE
joinToTAX1[0].compColNum=TAX1_ABS_ENTRY
joinToTAX1[0].compTableIndex=1
joinToTAX1[0].colNum=OTAX_ABS_ENTRY
joinToTAX1[0].tableIndex=0
joinToTAX1[0].operation=DBD_EQ
joinToOTAX[0].compareCols=TRUE
joinToOTAX[0].compColNum=OTAX_SOURCE_OBJ_ABS_ENTRY
joinToOTAX[0].compTableIndex=1
joinToOTAX[0].colNum=JDT1_TRANS_ABS
joinToOTAX[0].tableIndex=2
joinToOTAX[0].operation=DBD_EQ
joinToOTAX[0].relationship=DBD_AND
joinToOTAX[1].compareCols=TRUE
joinToOTAX[1].compColNum=TAX1_SRC_LINE_NUM
joinToOTAX[1].compTableIndex=0
joinToOTAX[1].colNum=JDT1_LINE_ID
joinToOTAX[1].tableIndex=2
joinToOTAX[1].operation=DBD_EQ
joinToOTAX[1].relationship=DBD_AND
joinToOTAX[2].colNum=OTAX_SOURCE_OBJ_TYPE
joinToOTAX[2].tableIndex=1
joinToOTAX[2].operation=DBD_EQ
joinToOTAX[2].condVal=JDT
DBD_SetParamTablesList(subQueryParams,subQueryTableStruct,3)
subQueryRES[0].tableIndex=0
subQueryRES[0].colNum=TAX1_ABS_ENTRY
DBD_SetRes(subQueryParams,subQueryRES,1)
subConds[0].tableIndex=2
subConds[0].colNum=JDT1_VAT_GROUP
subConds[0].operation=DBD_IS_NULL
subConds[0].relationship=DBD_OR
subConds[1].tableIndex=2
subConds[1].colNum=JDT1_VAT_GROUP
subConds[1].operation=DBD_EQ
subConds[1].condVal=EMPTY_STR
DBD_SetCond(subQueryParams,subConds,2)
mainConds[0].colNum=OTAX_ABS_ENTRY
mainConds[0].operation=DBD_IN
mainConds[0].SetSubQueryParams(subQueryParams)
mainConds[0].relationship=0
DBD_SetDAGCond(queryDag,mainConds,1)
DBD_RemoveRecords(queryDag)
_STR_strcpy(subQuery2TableStruct[0].tableCode,bizEnv.ObjectToTable(TAX,ao_Main))
DBD_SetParamTablesList(subQuery2Params,subQuery2TableStruct,1)
subQueryRES[0].colNum=OTAX_ABS_ENTRY
DBD_SetRes(subQuery2Params,subQueryRES,1)
_STR_strcpy(tableStruct[0].tableCode,bizEnv.ObjectToTable(TAX,ao_Arr1))
DBD_SetTablesList(queryDag,tableStruct,1)
_MEM_Clear(mainConds,1)
mainConds[0].colNum=TAX1_ABS_ENTRY
mainConds[0].operation=DBD_NOT_IN
mainConds[0].SetSubQueryParams(subQuery2Params)
mainConds[0].relationship=0
DBD_SetDAGCond(queryDag,mainConds,1)
DBD_RemoveRecords(queryDag)
return noErr

end

def IsBlockDunningLetterUpdateable()
transType=GetID()

return (transType==JDT||transType==NOB||transType==OPEN_BLNC_TYPE||transType==CLOSE_BLNC_TYPE)

end

def UpgradeJDTIndianAutoVat()
_TRACER("UpgradeJDTIndianAutoVat")
sboErr=noErr


bizEnv=GetEnv()








dagJDT=GetDAG()

dagJDT.ClearQueryParams()
tables[0].tableCode=bizEnv.ObjectToTable(JDT,ao_Main)
tables[1].tableCode=bizEnv.ObjectToTable(JDT,ao_Arr1)
tables[1].doJoin=true
tables[1].joinedToTable=0
tables[1].numOfConds=1
tables[1].joinConds=&join[0]
join[0].compareCols=true
join[0].compTableIndex=1
join[0].compColNum=JDT1_TRANS_ABS
join[0].operation=DBD_EQ
join[0].tableIndex=0
join[0].colNum=OJDT_JDT_NUM
condition[0].tableIndex=0
condition[0].colNum=OJDT_AUTO_VAT
condition[0].operation=DBD_EQ
condition[0].condVal=VAL_YES
condition[0].relationship=DBD_AND
condition[1].tableIndex=1
condition[1].colNum=JDT1_VAT_LINE
condition[1].operation=DBD_EQ
condition[1].condVal=VAL_YES
condition[1].relationship=DBD_AND
condition[2].tableIndex=1
condition[2].colNum=JDT1_VAT_GROUP
condition[2].operation=DBD_NOT_NULL
condition[2].relationship=0
resStruct[0].tableIndex=0
resStruct[0].colNum=OJDT_JDT_NUM
resStruct[0].group_by=true
DBD_SetTablesList(dagJDT,tables,2)
DBD_SetDAGCond(dagJDT,condition,3)
DBD_SetDAGRes(dagJDT,resStruct,1)
sboErr=DBD_GetInNewFormat(dagJDT,&dagRes)
if sboErr
   if sboErr==dbmNoDataFound
      sboErr=noErr

   end

   return sboErr

end

dagJDT1=GetDAG(JDT

sortStruct[0].colNum=JDT1_TRANS_ABS
sortStruct[1].colNum=JDT1_LINE_ID
numOfTrans=dagRes.GetRecordCount()

workLoad=1000

step=numOfTrans/workLoad


i=0

begin

   if i<step
      begin=i*workLoad
      end=(i+)*workLoad

   else
      begin=i*workLoad
      end=numOfTrans
      if begin>=end
         break

      end


   end

   transValues.Clear()
   j=begin

      begin

         dagRes.GetColLong(&transID,0,j)
         transValues.Add(transID)


         +=1j
      end while (j<end)

      dagJDT1.ClearQueryParams()
      conditions=&dagJDT1.GetDBDParams().GetConditions()
      cond=&conditions.AddCondition()
      cond.colNum=JDT1_TRANS_ABS
      cond.operation=DBD_IN
      cond.SetValuesArray(transValues)
      DBD_SetDAGSort(dagJDT1,sortStruct,2)
      DBD_Get(dagJDT1)
      sboErr=UpgradeJDTIndianAutoVatInt(dagJDT1)
      if sboErr
         return sboErr

      end



      +=1i
   end while (i<=step)

   return sboErr

end

def CheckColChanged(dag, col, /)
   if !_DBM_DataAccessGate::IsValid(dag)
      return false

   end



   ooErr=dag.GetChangesList(rec,colList)
   IF_ERROR_RETURN_VALUE(ooErr,false)

   colCount=colList.GetSize()
   colIndex=0

   begin
      currCol=colList[colIndex].GetColNum()
      if currCol==col
         return true

      end



      +=1colIndex
   end while (colIndex<colCount)

   return false

end

def UpgradeJDTIndianAutoVatInt(dagJDT1)
   isVatLine=false

   currentTransID=-1

   currentTaxType=0

   totalLines=dagJDT1.GetRecordCount()



   i=0

   begin
      dagJDT1.GetColStr(tmpStr,JDT1_DEBIT_CREDIT,i)
      if tmpStr.Compare(VAL_DEBIT)
         dagJDT1.SetColStr(JTE_VAL_AP,JDT1_TAX_POSTING_ACCOUNT,i)

      else
         dagJDT1.SetColStr(JTE_VAL_AR,JDT1_TAX_POSTING_ACCOUNT,i)

      end

      dagJDT1.GetColStr(tmpStr,JDT1_VAT_GROUP,i)
      dagJDT1.NullifyCol(JDT1_VAT_GROUP,i)
      dagJDT1.SetColStr(tmpStr,JDT1_TAX_CODE,i)
      dagJDT1.SetColStr(VAL_YES,JDT1_IS_NET,i)
      dagJDT1.GetColLong(&tmpL,JDT1_TRANS_ABS,i)
      if tmpL!=currentTransID
         currentTransID=tmpL
         currentTaxType=0
         isVatLine=false
         next


      end

      dagJDT1.GetColStr(tmpStr,JDT1_VAT_LINE,i)
      if tmpStr.Compare(VAL_YES)
         currentTaxType=0
         isVatLine=false
         next


      else
         if !isVatLine
            currentTaxType=0
            isVatLine=true

         else
            +=1currentTaxType

         end


      end

      dagJDT1.SetColLong(currentTaxType,JDT1_TAX_TYPE,i)


      +=1i
   end while (i<totalLines)

   return dagJDT1.UpdateAll()

end

def UpgradeOJDTUpdateDocType()
   sboErr=ooNoErr

   bizEnv=GetEnv()

   dagJDT=bizEnv.OpenDAG(JDT)




   srcStr=bizEnv.GetDefaultJEType()
   srcStr.Trim()
   condStruct[0].colNum=OJDT_DOC_TYPE
   condStruct[0].operation=DBD_IS_NULL
   condStruct[0].relationship=DBD_OR
   condStruct[1].colNum=OJDT_DOC_TYPE
   condStruct[1].operation=DBD_EQ
   _STR_strcpy(condStruct[1].condVal,_T(""))
   condStruct[1].relationship=0
   sboErr=DBD_SetDAGCond(dagJDT,condStruct,2)
   if sboErr
      dagJDT.Close()
      return sboErr

   end

   updStruct[0].colNum=OJDT_DOC_TYPE
   _STR_strcpy(updStruct[0].updateVal,srcStr)
   sboErr=DBD_SetDAGUpd(dagJDT,updStruct,1)
   if sboErr
      dagJDT.Close()
      return sboErr

   end

   sboErr=DBD_UpdateCols(dagJDT)
   dagJDT.Close()
   return sboErr

end

def GetSeqParam()
   if m_pSequenceParameter==NULL
      m_pSequenceParameter=CSequenceParameter.new((OJDT_SEQ_CODE,OJDT_SERIAL))

   end

   return m_pSequenceParameter

end

def ValidateHeaderLocation()
   _TRACER("ValidateHeaderLocation")
   dagJDT=GetDAG()


   dagJDT.GetColStr(autoVat,OJDT_AUTO_VAT)
   dagJDT.GetColStr(regNo,OJDT_GEN_REG_NO)
   if autoVat==VAL_YES||regNo==VAL_YES

      dagJDT.GetColLong(&location,OJDT_LOCATION)
      if !location
         SetErrorField(OJDT_LOCATION)
         Message(GO_OBJ_ERROR_MSGS(JDT),JDT_NEED_LOCATION_ERR,NULL,OO_ERROR)
         return (ooInvalidObject)

      end


   end

   return ooNoErr

end

def ValidateRowLocation(rec)
   _TRACER("ValidateRowLocation")
   dagJDT1=GetDAG(JDT


   dagJDT1.GetColStr(vatLine,JDT1_VAT_LINE,rec)
   if vatLine==VAL_YES

      dagJDT1.GetColStr(taxCode,JDT1_TAX_CODE,rec)
      if !taxCode.IsEmpty()

         dagJDT1.GetColLong(&location,JDT1_LOCATION,rec)
         if !location
            SetArrNum(ao_Arr1)
            SetErrorField(OJDT_LOCATION)
            SetErrorLine(rec+)
            Message(GO_OBJ_ERROR_MSGS(JDT),JDT_NEED_LOCATION_ERR,NULL,OO_ERROR)
            return (ooInvalidObject)

         end


      end


   end

   dagJDT=GetDAG(JDT


   dagJDT.GetColLong(&objType,OJDT_TRANS_TYPE)
   if objType==JDT||objType==-1

      dagJDT1.GetColLong(&maType,JDT1_MATERIAL_TYPE,rec)
      dagJDT1.GetColLong(&cenvatCon,JDT1_CENVAT_COM,rec)
      if isValidCENVAT(cenvatCon)||isValidMatType(maType)

         dagJDT1.GetColLong(&location,JDT1_LOCATION,rec)
         if !location
            SetArrNum(ao_Arr1)
            SetErrorField(OJDT_LOCATION)
            SetErrorLine(rec+)
            Message(GO_OBJ_ERROR_MSGS(JDT),JDT_NEED_LOCATION_ERR,NULL,OO_ERROR)
            return (ooInvalidObject)

         end


      end


   end

   return ooNoErr

end

def CompleteLocations()
   dagJDT=GetDAG()

   dagJDT1=GetDAG(ao_Arr1)


   dagJDT.GetColStr(autoVat,OJDT_AUTO_VAT)
   dagJDT.GetColStr(regNo,OJDT_GEN_REG_NO)
   if autoVat==VAL_YES||regNo==VAL_YES
      location=0

      dagJDT.GetColLong(&location,OJDT_LOCATION)
      if !location
         seq=0

         dagJDT.GetColLong(&seq,OJDT_SEQ_CODE)
         if seq
            location=GetEnv().GetSequenceManager().GetLocation(*this,seq)
            dagJDT.SetColLong(location,OJDT_LOCATION)

         end


      end

      dagJDT.GetColLong(&location,OJDT_LOCATION)
      if location
         recCount=dagJDT1.GetRecordCount()


         rec=0

         begin
            dagJDT1.GetColStr(taxCode,JDT1_TAX_CODE,rec)
            if !taxCode.IsEmpty()
               dagJDT1.GetColLong(&location,JDT1_LOCATION,rec)
               if !location
                  dagJDT1.CopyColumn(dagJDT,JDT1_LOCATION,rec,OJDT_LOCATION,0)

               end


            end



            rec+=1
         end while (rec<recCount)


      end


   end

   return ooNoErr

end

def CanArchiveAddWhere(bizEnv, canArchiveStmt, archiveDate, tObjectTable)
   subQ_unReconciledBPlines=*canArchiveStmt.CreateSubquery()

   tJDT1=subQ_unReconciledBPlines.From("JDT1")

   subQ_unReconciledBPlines.Select().Col(tJDT1,JDT1_TRANS_ABS)
   subQ_unReconciledBPlines.Where().Col(tJDT1,JDT1_TRANS_ABS).EQ().Col(tObjectTable,OJDT_JDT_NUM).And().OpenBracket()
   if bizEnv.IsLocalSettingsFlag(lsf_EnableCardClosingPeriod)
      subQ_unReconciledBPlines.Where().OpenBracket()

   end

   subQ_unReconciledBPlines.Where().Col(tJDT1,JDT1_SHORT_NAME).NE().Col(tJDT1,JDT1_ACCT_NUM).And().OpenBracket().Col(tJDT1,JDT1_BALANCE_DUE_CREDIT).NE().Val(0).Or().Col(tJDT1,JDT1_BALANCE_DUE_FC_CRED).NE().Val(0).Or().Col(tJDT1,JDT1_BALANCE_DUE_DEBIT).NE().Val(0).Or().Col(tJDT1,JDT1_BALANCE_DUE_FC_DEB).NE().Val(0).CloseBracket().CloseBracket()
   if bizEnv.IsLocalSettingsFlag(lsf_EnableCardClosingPeriod)
      subQ_unReconciledBPlines.Where().Or().Col(tJDT1,JDT1_SRC_LINE).EQ().Val(PMN_VAL_CLOSE_PER).CloseBracket()

   end

   temp=archiveDate


   temp.ToStr(dateStr,bizEnv)
   if !dateStr.IsEmpty()
      canArchiveStmt.Where().Col(tObjectTable,OJDT_REF_DATE).LE().Val(temp).And()

   end

   canArchiveStmt.Where().Col(tObjectTable,OJDT_TRANS_TYPE).NE().Val(CLOSE_BLNC_TYPE).And().NotExists().OpenBracket().Subquery(subQ_unReconciledBPlines).CloseBracket()
   return noErr

end

def GetArchiveDocNumCol(outArcDocNumCol)
   outArcDocNumCol=OJDT_JDT_NUM
   return noErr

end

def CompleteDataForArchivingLog()
   sboErr=CBusinessObjectBase::CompleteDataForArchivingLog()

   IF_ERROR_RETURN(sboErr)
   bizEnv=GetEnv()

   selectedBPTempTbl=GetArchiveSelectedBPTblName()

   if !selectedBPTempTbl.IsEmpty()&&bizEnv.GetCompanyConnection().DBisTableExists(selectedBPTempTbl,&bizEnv)
      dagTMP_ARC=GetDAG(TMP)

      tempArcTableName=dagTMP_ARC.GetTableName()

      try
      def updStmt
         (bizEnv)
      end

      updTbl=updStmt.Update(tempArcTableName)

      stmt=*updStmt.CreateSubquery()

      tTDAR=stmt.From(tempArcTableName)

      tOJDT=stmt.Join(bizEnv.ObjectToTable(JDT)

      stmt.On(tOJDT).Col(tOJDT,OJDT_JDT_NUM).EQ().Col(tTDAR,TDAR_DOC_ABS).And().Col(tTDAR,TDAR_DOC_TYPE).EQ().Val(JDT)
      tJDT1=stmt.Join(bizEnv.ObjectToTable(JDT

      stmt.On(tJDT1).Col(tJDT1,JDT1_TRANS_ABS).EQ().Col(tOJDT,OJDT_JDT_NUM)
      tSelBPs=stmt.Join(selectedBPTempTbl

      stmt.On(tSelBPs).Col(tSelBPs,TSEL_BP_CARD_CODE_COL).EQ().Col(tJDT1,JDT1_SHORT_NAME)
      stmt.Where().Col(tOJDT,OJDT_TRANS_TYPE).EQ().Val(JDT).And().Col(tJDT1,JDT1_ACCT_NUM).NE().Col(tJDT1,JDT1_SHORT_NAME)
      stmt.Select().Col(tTDAR,TDAR_DOC_ABS)
      stmt.Distinct()
      updStmt.Set(TDAR_CARD_CODE).Val(_T("--"))
      updStmt.Where().Col(updTbl,TDAR_DOC_TYPE).EQ().Val(JDT).And().Col(updTbl,TDAR_DOC_ABS).In().Subquery(stmt)
      updStmt.Execute()

      catch(DBMException&e)
      return e.GetCode()

      try
      def updStmt
         (bizEnv)
      end

      stmt=*updStmt.CreateSubquery()

      tTDAR=stmt.From(tempArcTableName)

      tOJDT=stmt.Join(bizEnv.ObjectToTable(JDT)

      stmt.On(tOJDT).Col(tOJDT,OJDT_JDT_NUM).EQ().Col(tTDAR,TDAR_DOC_ABS).And().Col(tTDAR,TDAR_DOC_TYPE).EQ().Val(JDT)
      tJDT1=stmt.Join(bizEnv.ObjectToTable(JDT

      stmt.On(tJDT1).Col(tJDT1,JDT1_TRANS_ABS).EQ().Col(tOJDT,OJDT_JDT_NUM)
      tSelBPs=stmt.Join(selectedBPTempTbl

      stmt.On(tSelBPs).Col(tSelBPs,TSEL_BP_CARD_CODE_COL).EQ().Col(tJDT1,JDT1_SHORT_NAME)
      stmt.Where().Col(tOJDT,OJDT_TRANS_TYPE).EQ().Val(JDT).And().Col(tJDT1,JDT1_ACCT_NUM).NE().Col(tJDT1,JDT1_SHORT_NAME).And().Col(tSelBPs,0).IsNull()
      stmt.Select().Col(tTDAR,TDAR_DOC_ABS)
      stmt.Distinct()
      updTbl=updStmt.Update(tempArcTableName)

      updStmt.Set(TDAR_CAN_ARC_OBJ).Val(VAL_DOCUMENT_FROM_DIFF_BP_FAIL)
      updStmt.Where().Col(updTbl,TDAR_DOC_TYPE).EQ().Val(JDT).And().Col(updTbl,TDAR_DOC_ABS).In().Subquery(stmt)
      updStmt.Execute()

      catch(DBMException&e)
      return e.GetCode()


   end

   return noErr

end

def GetTransIdByDoc(bizEnv, transId, transtype, createdby, /)
   sboErr=noErr

   try

   def stmt
      (bizEnv)
   end

   tJDT=stmt.From(bizEnv.ObjectToTable(JDT

   stmt.Top(1)
   stmt.Select().Col(tJDT,OJDT_JDT_NUM)
   stmt.Where().Col(tJDT,OJDT_TRANS_TYPE).EQ().Val(transtype).And().Col(tJDT,OJDT_CREATED_BY).EQ().Val(createdby)
   if returnMinTransId
      stmt.OrderBy(tJDT,OJDT_JDT_NUM,false)
   else
      stmt.OrderBy(tJDT,OJDT_JDT_NUM,true)
   end

   if stmt.Execute(dagRes)>0L
      dagRes.GetColLong(&transId,0L)

   else
      sboErr=dbmNoDataFound

   end


   catch(DBMException&e)
   sboErr=e.GetCode()

   return sboErr

end

def BeforeDeleteArchivedObject(arcDelPref)
   sboErr=noErr



   dagDAR=GetDAG(DAR)


   dagDAR.GetColLong(&JEPref.arc_entry,ODAR_ABS_ENTRY)
   dagDAR.GetColStr(tempStr,ODAR_JE_BY_PROJ)
   JEPref.byProject=tempStr[0]==VAL_YES[0]
   dagDAR.GetColStr(tempStr,ODAR_JE_BY_PROF)
   JEPref.byProfitCenter=tempStr[0]==VAL_YES[0]
   dagDAR.GetColStr(tempStr,ODAR_JE_BY_DIM2)
   JEPref.byDimension2=(tempStr==VAL_YES)
   dagDAR.GetColStr(tempStr,ODAR_JE_BY_DIM3)
   JEPref.byDimension3=(tempStr==VAL_YES)
   dagDAR.GetColStr(tempStr,ODAR_JE_BY_DIM4)
   JEPref.byDimension4=(tempStr==VAL_YES)
   dagDAR.GetColStr(tempStr,ODAR_JE_BY_DIM5)
   JEPref.byDimension5=(tempStr==VAL_YES)
   dagDAR.GetColStr(tempStr,ODAR_JE_BY_CURR)
   JEPref.byCurrency=tempStr[0]==VAL_YES[0]
   dagDAR.GetColStr(JEPref.periodLen,ODAR_JE_PERIOD_LEN)
   dagDAR.GetColStr(JEPref.ref1,ODAR_JE_REF1)
   dagDAR.GetColStr(JEPref.ref2,ODAR_JE_REF2)
   dagDAR.GetColStr(JEPref.memo,ODAR_JE_MEMO)
   dagDAR.GetColStr(JEPref.toDate,ODAR_PERIOD_DATE)
   try
   _LOGMSG(logDebugComponent,logNoteSeverity,_T("In CTransactionJournalObject::BeforeDeleteArchivedObject - starting JEComp.execute()"))
   def JEComp
      (GetEnv(),&JEPref)
   end

   sboErr=JEComp.execute()
   if sboErr
      _LOGMSG(logDebugComponent,logErrorSeverity,_T("Error in CTransactionJournalObject::BeforeDeleteArchivedObject - error in JEComp.execute()"))
      return sboErr

   end

   _LOGMSG(logDebugComponent,logNoteSeverity,_T("In CTransactionJournalObject::BeforeDeleteArchivedObject - JEComp.execute() ended successfully"))

   catch(nsDataArchive::CDataArchiveException&e)
   _LOGMSG(logDebugComponent,logErrorSeverity,_T("Error in CTransactionJournalObject::BeforeDeleteArchivedObject - exception was thrown in the Constructor of CJECompression"))
   return e.GetSBOErr()

   ndif
   return sboErr

end

def AfterDeleteArchivedObject(arcDelPref)
   sboErr=noErr


   try
   dagACT=NULL

   dagCRD=NULL

   sboErr=GLFillActListDAG(&dagACT,GetEnv())
   if sboErr
      _LOGMSG(logDebugComponent,logErrorSeverity,_T("Error in CTransactionJournalObject::AfterDeleteArchivedObject - GLFillActListDAG"))
      return sboErr

   end

   def stmt
      (GetEnv())
   end

   tCRD=stmt.From(GetEnv().ObjectToTable(CRD))

   stmt.Select().Col(tCRD,OCRD_CARD_CODE)
   stmt.Select().Col(tCRD,OCRD_CARD_NAME)
   stmt.Select().Col(tCRD,OCRD_CARD_TYPE)
   numOfReturnedRecs=stmt.Execute(&dagCRD)

   _LOGMSG(logDebugComponent,logNoteSeverity,_T("In CTransactionJournalObject::AfterDeleteArchivedObject - starting RBARebuildAccountsAndCardsInternal (dagACT, dagCRD, FALSE)"))
   sboErr=RBARebuildAccountsAndCardsInternal(dagACT,dagCRD,FALSE)
   DAG_Close(dagCRD)
   DAG_Close(dagACT)
   if sboErr
      _LOGMSG(logDebugComponent,logErrorSeverity,_T("Error in CTransactionJournalObject::AfterDeleteArchivedObject - RBARebuildAccountsAndCardsInternal"))
      return sboErr

   end

   _LOGMSG(logDebugComponent,logNoteSeverity,_T("In CTransactionJournalObject::AfterDeleteArchivedObject - RBARebuildAccountsAndCardsInternal (dagACT, dagCRD, FALSE) ended successfully"))

   catch(DBMException&e)
   _LOGMSG(logDebugComponent,logErrorSeverity,_T("Error in CTransactionJournalObject::AfterDeleteArchivedObject - Exception was thrown"))
   return e.GetCode()

   ndif
   return sboErr

end

def GetWtSumField(currSource)
   cols=""

   return cols[currSource-]

end

def UpdateWTInfo()
   ooErr=ooNoErr

   bizEnv=GetEnv()

   dagJDT=GetDAG(JDT)

   dagJDT1=GetDAG(JDT




   recCountJDT1=dagJDT1.GetRecordCount()




   StdArray

end

def GetWithHoldingTax(onlyPaymentCateg, row)
   dagJDT2=GetArrayDAG(ao_Arr2)

   dagJDT1=GetArrayDAG(ao_Arr1)


   deb.FromDAG(dagJDT1,row,JDT1_DEBIT,JDT1_FC_DEBIT,JDT1_SYS_DEBIT)
   cred.FromDAG(dagJDT1,row,JDT1_CREDIT,JDT1_FC_CREDIT,JDT1_SYS_CREDIT)
   docTotal=deb-
   docTotal.Abs()
   return CDocumentObject::GetWTTaxSet(dagJDT2,docTotal,onlyPaymentCateg,row)

end

def LoadObjInfoFromDags(objInfo, dagObj, dagWTaxs, dagObjRows)
   sboErr=noErr


   deb.FromDAG(dagObjRows,objInfo.m_ObjectRow,JDT1_DEBIT,JDT1_FC_DEBIT,JDT1_SYS_DEBIT)
   cred.FromDAG(dagObjRows,objInfo.m_ObjectRow,JDT1_CREDIT,JDT1_FC_CREDIT,JDT1_SYS_CREDIT)
   objInfo.m_DocTotal=deb-
   objInfo.m_DocTotal.Abs()
   tmpWTTaxSet=CDocumentObject::GetWTTaxSet(dagWTaxs

   objInfo.SetDocWTaxArray(tmpWTTaxSet)
   deb.FromDAG(dagObjRows,objInfo.m_ObjectRow,JDT1_BALANCE_DUE_DEBIT,JDT1_BALANCE_DUE_FC_DEB,JDT1_BALANCE_DUE_SC_DEB)
   cred.FromDAG(dagObjRows,objInfo.m_ObjectRow,JDT1_BALANCE_DUE_CREDIT,JDT1_BALANCE_DUE_FC_CRED,JDT1_BALANCE_DUE_SC_CRED)
   deb-=cred
   objInfo.m_DocApplied=objInfo.m_DocTotal-
   dagObj.GetColStr(objInfo.m_DocCurrency,OJDT_TRANS_CURR)
   if objInfo.m_DocCurrency.IsEmpty()
      objInfo.m_DocCurrency=objInfo.m_bizEnv.GetMainCurrency()

   end

   return sboErr

end

def GetWTaxReconDags(dagOBJ, dagObjWTax, dagObjRows)
   dagOBJ=GetDAG()
   dagObjWTax=GetArrayDAG(ao_Arr2)
   dagObjRows=GetArrayDAG(ao_Arr1)
   return noErr

end

def CreateDocInfoQry(docInfoQry)
   bizEnv=GetEnv()

   objType=GetID().strtol()

   tableObj=docInfoQry.From(bizEnv.ObjectToTable(objType

   tableObjRow=docInfoQry.Join(bizEnv.ObjectToTable(objType

   docInfoQry.On(tableObjRow).Col(tableObj,OJDT_JDT_NUM).EQ().Col(tableObjRow,JDT1_TRANS_ABS)
   tableObjWtax=docInfoQry.Join(bizEnv.ObjectToTable(objType

   docInfoQry.On(tableObjWtax).Col(tableObj,OJDT_JDT_NUM).EQ().Col(tableObjWtax,JDT2_ABS_ENTRY).And().Col(tableObjWtax,JDT2_CATEGORY).EQ().Val(VAL_CATEGORY_PAYMENT)
   docInfoQry.Select().Col(tableObjRow,JDT1_TRANS_ABS)
   docInfoQry.Select().Col(tableObjRow,JDT1_LINE_ID)
   docInfoQry.Select().Max().Col(tableObj,OJDT_TRANS_CURR).As(OJDT_TRANS_CURR_ALIAS)
   docInfoQry.Select().Max().Col(tableObjRow,JDT1_CREDIT).Sub().Max().Col(tableObjRow,JDT1_DEBIT).As(JDT1_CREDIT_ALIAS)
   docInfoQry.Select().Max().Col(tableObjRow,JDT1_FC_CREDIT).Sub().Max().Col(tableObjRow,JDT1_FC_DEBIT).As(JDT1_FC_CREDIT_ALIAS)
   docInfoQry.Select().Max().Col(tableObjRow,JDT1_SYS_CREDIT).Sub().Max().Col(tableObjRow,JDT1_SYS_DEBIT).As(JDT1_SYS_CREDIT_ALIAS)
   docInfoQry.Select().Max().Col(tableObjRow,JDT1_CREDIT).Sub().Max().Col(tableObjRow,JDT1_DEBIT).Sub().Max().Col(tableObjRow,JDT1_BALANCE_DUE_CREDIT).Add().Max().Col(tableObjRow,JDT1_BALANCE_DUE_DEBIT).As(JDT1_BALANCE_DUE_CREDIT_ALIAS)
   docInfoQry.Select().Max().Col(tableObjRow,JDT1_FC_CREDIT).Sub().Max().Col(tableObjRow,JDT1_FC_DEBIT).Sub().Max().Col(tableObjRow,JDT1_BALANCE_DUE_FC_CRED).Add().Max().Col(tableObjRow,JDT1_BALANCE_DUE_FC_DEB).As(JDT1_BALANCE_DUE_FC_CRED_ALIAS)
   docInfoQry.Select().Max().Col(tableObjRow,JDT1_SYS_CREDIT).Sub().Max().Col(tableObjRow,JDT1_SYS_DEBIT).Sub().Max().Col(tableObjRow,JDT1_BALANCE_DUE_SC_CRED).Add().Max().Col(tableObjRow,JDT1_BALANCE_DUE_SC_DEB).As(JDT1_BALANCE_DUE_SC_CRED_ALIAS)
   docInfoQry.Select().Sum().Col(tableObjWtax,JDT2_WT_AMOUNT).As(JDT2_WT_AMOUNT_ALIAS)
   docInfoQry.Select().Sum().Col(tableObjWtax,JDT2_WT_AMOUNT_FC).As(JDT2_WT_AMOUNT_FC_ALIAS)
   docInfoQry.Select().Sum().Col(tableObjWtax,JDT2_WT_AMOUNT_SC).As(JDT2_WT_AMOUNT_SC_ALIAS)
   docInfoQry.Select().Sum().Col(tableObjWtax,JDT2_WT_APPLIED_AMOUNT).As(JDT2_WT_APPLIED_AMOUNT_ALIAS)
   docInfoQry.Select().Sum().Col(tableObjWtax,JDT2_WT_APPLIED_AMOUNT_FC).As(JDT2_WT_APPLIED_AMOUNT_FC_ALIAS)
   docInfoQry.Select().Sum().Col(tableObjWtax,JDT2_WT_APPLIED_AMOUNT_SC).As(JDT2_WT_APPLIED_AMOUNT_SC_ALIAS)
   docInfoQry.Select(tableObj,OJDT_LOC_TOTAL).Val(0L).As(_T("DummyCol2"))
   docInfoQry.Select(tableObj,OJDT_FC_TOTAL).Val(0L).As(_T("DummyCol3"))
   docInfoQry.Select(tableObj,OJDT_SYS_TOTAL).Val(0L).As(_T("DummyCol4"))
   docInfoQry.GroupBy(tableObjRow,JDT1_TRANS_ABS)
   docInfoQry.GroupBy(tableObjRow,JDT1_LINE_ID)
   return noErr

end

def YouHaveBeenReconciled(yourMatchData)
   ooErr=ooNoErr

   if VF_JEWHT(GetEnv())
      ooErr=UpdateWTOnRecon(yourMatchData)

   end

   return ooErr

end

def YouHaveBeenUnReconciled(yourMatchData)
   ooErr=ooNoErr

   if VF_JEWHT(GetEnv())
      ooErr=UpdateWTOnCancelRecon(yourMatchData)

   end

   return ooErr

end

def UpdateWTOnRecon(yourMatchData)
   ooErr=ooNoErr

   env=GetEnv()

   withholdingCodeSet=GetWithHoldingTax(true)

   if withholdingCodeSet.size()==0
      return ooNoErr

   end

   dagJDT2=GetArrayDAG(ao_Arr2)

   numOfRecsJDT2=dagJDT2.GetRealSize(dbmDataBuffer)

   if (numOfRecsJDT2>1&&!VF_AllowMixedWHTCategories(env))||(withholdingCodeSet.size()>1)
      _MEM_MYRPT0(_T())

   end


end

def GetJDTReconStatus()
   dagJDT1=GetArrayDAG(ao_Arr1)

   numRec=dagJDT1.GetRecordCount()



   creditSide=false

   rec=0

   begin
      dagJDT1.GetColStr(acctCode,JDT1_ACCT_NUM,rec)
      dagJDT1.GetColStr(shrtName,JDT1_SHORT_NAME,rec)
      if acctCode==shrtName
         next


      end

      dagJDT1.GetColMoney(&mny,JDT1_DEBIT,rec)
      if mny.IsZero()
         creditSide=true

      end

      balDueCol=creditSide



      rec+=1
   end while (rec<numRec)


end

def CalcPaidRatioOfOpenDoc(paidSum, paidSumInLocal, transRowId, calcFromTotal)
   dagJDT=GetDAG()

   dagJDT1=GetArrayDAG(ao_Arr1)



   local=true

   dagJDT.GetColStr(docCurrency,OINV_DOC_CURRENCY)
   mainCurrency=GetEnv().GetMainCurrency()
   def tmpDocCur
      (docCurrency)
   end

end

def OnCanJDT2Update()
   ooErr=ooNoErr

   oopp=GetOnUpdateParams()

   return ooNoErr
   i=0

   begin
      case oopp.colsList[i].GetColNum()

      when INV5_WT_APPLIED_AMOUNT
      when INV5_WT_APPLIED_AMOUNT_SC
      when INV5_WT_APPLIED_AMOUNT_FC
         return ooNoErr
      else
         SetErrorField(oopp.colsList[i].GetColNum())
         SetErrorLine(-1)
         return dbmColumnNotUpdatable

      end



      i+=1
   end while (i<oopp.colsList.GetSize())

   return ooNoErr

end

def UpdateWTOnCancelRecon(yourMatchData)
   _TRACER("UpdateWTOnCancelRecon")

   withholdingCodeSet=GetWithHoldingTax(true)

   if withholdingCodeSet.size()==0
      return ooNoErr

   end

   dagJDT2=GetArrayDAG(ao_Arr2)

   numOfRecsJDT2=dagJDT2.GetRealSize(dbmDataBuffer)

   if (numOfRecsJDT2>1&&!VF_AllowMixedWHTCategories(GetEnv()))||(withholdingCodeSet.size()>1)
      _MEM_MYRPT0(_T())

   end


end

def CheckWTValid()
   _TRACER("CheckWTValid")
   ooErr=ooNoErr

   dagJDT=GetDAG(JDT)

   dagJDT1=GetDAG(JDT

   dagJDT2=GetDAG(JDT



   isBpCredit
   hasBPline = false
   hasLiableline = false

   dagJDT.GetColStr(tmpStr,OJDT_AUTO_WT)
   if tmpStr[0]==VAL_NO[0]
      return ooNoErr

   end

   recCount=dagJDT1.GetRealSize(dbmDataBuffer)

   rec=0

   begin
      dagJDT1.GetColStr(acctNum,JDT1_ACCT_NUM,rec)
      dagJDT1.GetColStr(shortName,JDT1_SHORT_NAME,rec)
      if acctNum.Trim()!=shortName.Trim()
         hasBPline=true
         dagJDT1.GetColMoney(&tmpMny,JDT1_DEBIT,rec)
         mnyBPDebit+=tmpMny
         dagJDT1.GetColMoney(&tmpMny,JDT1_CREDIT,rec)
         mnyBPCred+=tmpMny

      end



      rec+=1
   end while (rec<recCount)


   if mnyBPCred>=mnyBPDebit
      isBpCredit=true
      bpDebCre=VAL_CREDIT

   else
      isBpCredit=false
      bpDebCre=VAL_DEBIT

   end


   GetWTCredDebt(wtDebCre)

   dagJDT.GetColMoney(&baseAmt,OJDT_WT_BASE_AMOUNT)
   numJdt2Rec=dagJDT2.GetRecordCount()

   if hasBPline&&(!baseAmt.IsZero())&&(bpDebCre!=wtDebCre)&&numJdt2Rec>0
      return dbdError

   end

   return ooErr

end

def GetWTBaseNetAmountField(curr)

   case curr

   when JDT_WT_LOCAL_CURRENCY
      column=OJDT_WT_BASE_AMOUNT

   when JDT_WT_SYS_CURRENCY
      column=OJDT_WT_BASE_AMOUNT_SC

   when JDT_WT_FC_CURRENCY
      column=OJDT_WT_BASE_AMOUNT_FC


   end

   return column

end

def GetWTBaseVATAmountField(curr)

   case curr

   when JDT_WT_LOCAL_CURRENCY
      column=OJDT_WT_BASE_VAT_AMNT

   when JDT_WT_SYS_CURRENCY
      column=OJDT_WT_BASE_VAT_AMNT_SC

   when JDT_WT_FC_CURRENCY
      column=OJDT_WT_BASE_VAT_AMNT_FC


   end

   return column

end

def CheckMultiBP()
   _TRACER("CheckMultiBP")
   dagJDT=GetDAG(JDT)

   dagJDT1=GetDAG(JDT


   dagJDT.GetColStr(autoWT,OJDT_AUTO_WT)
   if autoWT==VAL_YES
      recJDT1=dagJDT1.GetRealSize(dbmDataBuffer)


      rec=0

      begin
         dagJDT1.GetColStr(acct,JDT1_ACCT_NUM,rec)
         dagJDT1.GetColStr(shortname,JDT1_SHORT_NAME,rec)
         acct.Trim()
         shortname.Trim()
         if acct!=shortname
            if !firstBP.IsEmpty()
               if firstBP!=shortname
                  return ooInvalidObject

               end


            else
               firstBP=shortname

            end


         end



         rec+=1
      end while (rec<recJDT1)


   end

   return ooNoErr

end

def WTGetBPCodeImp(dagJDT, dagJDT1)

   dagJDT.GetColStr(autoWT,OJDT_AUTO_WT)
   autoWT.Trim()
   if autoWT==VAL_YES
      recJDT1=dagJDT1.GetRealSize(dbmDataBuffer)


      rec=0

      begin
         dagJDT1.GetColStr(acct,JDT1_ACCT_NUM,rec)
         dagJDT1.GetColStr(shortname,JDT1_SHORT_NAME,rec)
         acct.Trim()
         shortname.Trim()
         if acct!=shortname
            return shortname

         end



         rec+=1
      end while (rec<recJDT1)


   end

   return EMPTY_STR

end

def WTGetBpCode()
   _TRACER("WTGetBpCode")
   dagJDT=GetDAG(JDT)

   dagJDT1=GetDAG(JDT

   return WTGetBPCodeImp(dagJDT,dagJDT1)

end

def WTGetCurrencyImp(dagJDT, dagJDT1)

   dagJDT.GetColStr(autoWT,OJDT_AUTO_WT)
   autoWT.Trim()
   if autoWT==VAL_YES
      recJDT1=dagJDT1.GetRealSize(dbmDataBuffer)


      rec=0

      begin
         dagJDT1.GetColStr(acct,JDT1_ACCT_NUM,rec)
         dagJDT1.GetColStr(shortname,JDT1_SHORT_NAME,rec)
         dagJDT1.GetColStr(curr,JDT1_FC_CURRENCY,rec)
         acct.Trim()
         shortname.Trim()
         curr.Trim()
         if acct!=shortname
            return curr

         end



         rec+=1
      end while (rec<recJDT1)


   end

   return EMPTY_STR

end

def WTGetCurrency()
   _TRACER("WTGetBpCode")
   dagJDT=GetDAG(JDT)

   dagJDT1=GetDAG(JDT

   return WTGetCurrencyImp(dagJDT,dagJDT1)

end

def GetDfltWTCodes(wtInfo)
   return CDocumentObject::ODOCLoadWTPrefsFromCard(*this,&wtInfo.cardWTLiable,wtInfo.wtDefaultCode,wtInfo.VATwtDefaultCode,wtInfo.ITwtDefaultCode,wtInfo.wtBaseType,wtInfo.wtCategory)

end

def GetBPCurrencySource()
   currency=WTGetCurrency()

   mainCurr=m_env.GetMainCurrency()

   sysCurr=m_env.GetSystemCurrency()

   if currency==mainCurr||EMPTY_STR==currency||BAD_CURRENCY_STR==currency
      return JDT_WT_LOCAL_CURRENCY

   end

   if currency==sysCurr
      return JDT_WT_SYS_CURRENCY

   end

   return JDT_WT_FC_CURRENCY

end

def GetBPLineCurrency()
   dagJDT1=GetDAG(JDT

   recCount=dagJDT1.GetRealSize(dbmDataBuffer)


   currency=m_env.GetMainCurrency()

   rec=0

   begin
      dagJDT1.GetColStr(acctCode,JDT1_ACCT_NUM,rec)
      acctCode.Trim()
      dagJDT1.GetColStr(shortName,JDT1_SHORT_NAME,rec)
      shortName.Trim()
      if shortName!=acctCode
         dagJDT1.GetColStr(bpCurr,JDT1_FC_CURRENCY,rec)
         if bpCurr.Trim()!=EMPTY_STR
            currency=bpCurr
            break

         end


      end



      rec+=1
   end while (rec<recCount)

   return currency

end

def SetCurrRateForDOC(dagDOC)
   ooErr=noErr

   env=GetEnv()


   dagJDT=GetDAG(JDT)

   if !DAG::IsValid(dagDOC)
      return ooErrNoMsg

   end

   dagDOC.GetColMoney(&rate,OINV_DOC_RATE)
   if rate.IsZero()
      if CalcBpCurrRateForDocRate(rate)==ooErr
         dagDOC.SetColMoney(&rate,OINV_DOC_RATE)

      end


   end

   ooErr=SetSysCurrRateForDOC(dagDOC)
   return ooErr

end

def SetCurrForAutoCompleteDOC5()
   case WTGetCurrSource()

   when INV_LOCAL_CURRENCY
      m_WithholdingTaxMng.m_curSourceForAutoComplete[0]=INV_LOCAL_CURRENCY
      m_WithholdingTaxMng.m_curSourceForAutoComplete[1]=INV_SYSTEM_CURRENCY
      m_WithholdingTaxMng.m_curSourceForAutoComplete[2]=INV_CARD_CURRENCY


   when INV_SYSTEM_CURRENCY
      m_WithholdingTaxMng.m_curSourceForAutoComplete[0]=INV_SYSTEM_CURRENCY
      m_WithholdingTaxMng.m_curSourceForAutoComplete[1]=INV_CARD_CURRENCY
      m_WithholdingTaxMng.m_curSourceForAutoComplete[2]=INV_LOCAL_CURRENCY


   when INV_CARD_CURRENCY
      m_WithholdingTaxMng.m_curSourceForAutoComplete[0]=INV_CARD_CURRENCY
      m_WithholdingTaxMng.m_curSourceForAutoComplete[1]=INV_LOCAL_CURRENCY
      m_WithholdingTaxMng.m_curSourceForAutoComplete[2]=INV_SYSTEM_CURRENCY



   end

   return ooNoErr

end

def PrePareDataForWT(wtAllCurBaseCalcParamsPtr, currSource, dagDOC, wtInfo)
   ooErr=ooNoErr

   dagJDT=GetDAG(JDT)

   baseCalcParam=wtAllCurBaseCalcParamsPtr.GetWtBaseCalcParams(currSource)

   GetCRDDag()
   GetDfltWTCodes(wtInfo)
   if !dagDOC.GetRecordCount()
      dagDOC.SetSize(1,dbmDropData)

   end

   dagDOC.SetColStr(GetBPLineCurrency(),OINV_DOC_CURRENCY)
   dagDOC.CopyColumn(dagJDT,OINV_DATE,0,OJDT_REF_DATE,0)
   if m_env.IsLocalSettingsFlag(lsf_EnableLA1WHT)
      dagDOC.SetColMoney(&baseCalcParam.m_wtBaseNetAmount,nsDocument::ODOCGetWTBaseNetAmountField(currSource))
      dagDOC.SetColMoney(&baseCalcParam.m_wtBaseVATAmount,nsDocument::ODOCGetWTBaseVatAmountField(currSource))

   else
      wtBaseAmount=baseCalcParam.GetWTBaseAmount(wtInfo.wtBaseType)

      dagDOC.SetColMoney(&wtBaseAmount,nsDocument::ODOCGetWTBaseAmountField(currSource))

   end

   SetCurrRateForDOC(dagDOC)
   SetCurrForAutoCompleteDOC5()

   ooErr=m_WithholdingTaxMng.ODOCAutoCompleteDOC5(*this,cplPara)
   if ooErr
      Message(cplPara.errNode.strId,cplPara.errNode.index,NULL,OO_ERROR)
      return ooErr

   end

   return ooErr

end

def JDTCalcWTTable(wtInfo, currSource, dagDOC, wtAllCurBaseCalcParamsPtr)
   ooErr=ooNoErr

   wtCurBaseCalcParamsPtr=wtAllCurBaseCalcParamsPtr.GetWtBaseCalcParams(currSource)

   wtInParamTableChangeListPtr=NULL



   if m_env.IsLocalSettingsFlag(lsf_EnableLA1WHT)
      wtTableDefaultCodes.SetVATWtDefaultcode(wtInfo.VATwtDefaultCode)
      wtTableDefaultCodes.SetITWtDefaultcode(wtInfo.ITwtDefaultCode)

   else
      wtTableDefaultCodes.SetWtDefaultcode(wtInfo.wtDefaultCode)

   end

   m_WithholdingTaxMng.ODOCCalcWTTable(*this,wtCurBaseCalcParamsPtr,wtInParamTableChangeListPtr,wtTableDefaultCodes,currSource,&wtTotalAmountM,-1,dagDOC)
   return ooErr

end

def GetJDT1MoneyCol(currSource, isDebit)
   cols=""

   return cols[currSource-][isDebit?

   end

   def GetVATMoneyCol(currSource)
      cols=""

      return cols[currSource-]

   end

   def GetWTCredDebt(debCre)
      _TRACER("GETWTCredDebt")
      ooErr=ooNoErr

      dagJDT1=GetDAG(JDT

      dagJDT2=GetDAG(JDT

      recCount=dagJDT1.GetRealSize(dbmDataBuffer)





      if !DAG::IsValid(dagJDT1)
         return ooErrNoMsg

      end

      rec=0

      begin
         dagJDT1.GetColStr(wtLiable,JDT1_WT_LIABLE,rec)
         if wtLiable.Trim()==VAL_YES
            dagJDT1.GetColMoney(&tmpDebAmt,JDT1_DEBIT,rec)
            debitSumNet+=tmpDebAmt
            dagJDT1.GetColMoney(&tmpCreAmt,JDT1_CREDIT,rec)
            creditSumNet+=tmpCreAmt
            dagJDT1.GetColMoney(&tmpVatAmt,JDT1_TOTAL_TAX,rec)
            if !tmpDebAmt.IsZero()
               debitSumVat+=tmpVatAmt

            else
               if !tmpCreAmt.IsZero()
                  creditSumVat+=tmpVatAmt

               end

            end


         end



         rec+=1
      end while (rec<recCount)

      if dagJDT2.GetRecordCount()>0

         dagJDT2.GetColStr(wtBaseType,INV5_BASE_TYPE)
         if VAL_BASETYPE_NET==wtBaseType
            debitSum=debitSumNet
            creditSum=creditSumNet

         else
            if VAL_BASETYPE_VAT==wtBaseType
               debitSum=debitSumVat
               creditSum=creditSumVat

            else
               if VAL_BASETYPE_GROSS==wtBaseType
                  debitSum=debitSumNet+
                  creditSum=creditSumNet+

               end

            end

         end


      end

      if debitSum>=creditSum
         debCre=VAL_CREDIT

      else
         debCre=VAL_DEBIT

      end

      return noErr

   end

   def GetWTBaseAmount(currSource, baseParam)
      _TRACER("GetWTBaseAmount")
      ooErr=ooNoErr

      dagJDT=GetDAG(JDT)

      dagJDT1=GetDAG(JDT

      recCount=dagJDT1.GetRealSize(dbmDataBuffer)

      bizEnv=GetEnv()





      rec=0

      begin
         dagJDT1.GetColStr(wtLiable,JDT1_WT_LIABLE,rec)
         if wtLiable.Trim()==VAL_YES
            isDebit=false
            dagJDT1.GetColMoney(&mnyTmp,GetJDT1MoneyCol(currSource,true),rec)
            if !mnyTmp.IsZero()
               isDebit=true

            end

            sum+=mnyTmp
            dagJDT1.GetColMoney(&mnyTmp,GetJDT1MoneyCol(currSource,false),rec)
            sum-=mnyTmp
            if mnyTmp.IsZero()&&(!isDebit)
               next


            end

            dagJDT1.GetColMoney(&mnyTmp,GetVATMoneyCol(currSource),rec)

            if currSource==JDT_WT_FC_CURRENCY
               realCurr=WTGetCurrency()

               realCurr.Trim()
               dubtCurr.Trim()
               mainCurr=bizEnv.GetMainCurrency().Trim()

               frgnCurr=realCurr

               SBO_ASSERT(dubtCurr.IsEmpty()||dubtCurr==mainCurr)
               SBO_ASSERT(dubtCurr!=frgnCurr)
               frgnAmnt=1


               dagJDT.GetColStr(dateStr,OJDT_REF_DATE)
               dateStr.Trim()
               GNLocalToForeignRate(&mnyTmp,frgnCurr.GetBuffer(),dateStr.GetBuffer(),0.0,&frgnAmnt,bizEnv)
               mnyTmp=frgnAmnt
               mnyTmp.Round(RC_SUM,frgnCurr,bizEnv)

            end

            if isDebit
               sumVAT+=mnyTmp

            else
               sumVAT-=mnyTmp

            end


         end



         rec+=1
      end while (rec<recCount)

      if !baseParam.GetIsBaseAmountsReady()
         baseParam.Init()

      end

      mnySumTmp=sum+

      baseParam.m_wtBaseNetAmount=sum.AbsVal()
      baseParam.m_wtBaseVATAmount=sumVAT.AbsVal()
      baseParam.m_wtBaseAmount=mnySumTmp.AbsVal()
      return ooErr

   end

   def GetCRDDag()
      _TRACER("GetCRDDag")
      ooErr=ooNoErr

      dagCRD=GetDAG(CRD)

      dagJDT1=GetDAG(JDT

      recCount=dagJDT1.GetRealSize(dbmDataBuffer)


      rec=0

      begin
         dagJDT1.GetColStr(acctCode,JDT1_ACCT_NUM,rec)
         acctCode.Trim()
         dagJDT1.GetColStr(shortName,JDT1_SHORT_NAME,rec)
         shortName.Trim()
         if shortName!=acctCode

            cond[0].colNum=OCRD_CARD_CODE
            cond[0].operation=DBD_EQ
            cond[0].condVal=shortName
            DBD_SetDAGCond(dagCRD,cond,1)
            ooErr=DBD_Get(dagCRD)
            break

         end



         rec+=1
      end while (rec<recCount)

      return ooErr

   end

   def WTGetCurrSource()
      _TRACER("WTGetCurrSource")
      bizEnv=GetEnv()


      mainCurr=bizEnv.GetMainCurrency()

      sysCurr=bizEnv.GetSystemCurrency()

      currency=GetBPLineCurrency()
      currency.Trim()
      if (EMPTY_STR==currency)||(currency==mainCurr)||(GNCoinCmp(currency,BAD_CURRENCY_STR)==0)
         return JDT_WT_LOCAL_CURRENCY

      end

      if currency==sysCurr
         return JDT_WT_SYS_CURRENCY

      end

      return JDT_WT_FC_CURRENCY

   end

   def WtAutoAddJDT1Line(dagJDT1, jdt1RecSize, dagJDT2, jdt2CurRec, isDebit, wtSide)
      _TRACER("WtAutoAddJDT1Line")
      ooErr=noErr



      toJDT1fields=""

      fromJDTfields=""

      dagJDT1.SetSize(jdt1RecSize+,dbmKeepData)
      dagJDT2.GetColMoney(&mnyAmt,INV5_WT_AMOUNT,jdt2CurRec)
      dagJDT1.SetColMoney(&mnyAmt,GetJDT1MoneyCol(JDT_WT_LOCAL_CURRENCY,isDebit),jdt1RecSize)
      dagJDT2.GetColMoney(&mnyAmt,INV5_WT_AMOUNT_SC,jdt2CurRec)
      dagJDT1.SetColMoney(&mnyAmt,GetJDT1MoneyCol(JDT_WT_SYS_CURRENCY,isDebit),jdt1RecSize)
      if WTGetCurrSource()==JDT_WT_FC_CURRENCY
         dagJDT2.GetColMoney(&mnyAmt,INV5_WT_AMOUNT_FC,jdt2CurRec)
         dagJDT1.SetColMoney(&mnyAmt,GetJDT1MoneyCol(JDT_WT_FC_CURRENCY,isDebit),jdt1RecSize)

      end

      dagJDT1.SetColStr(VAL_YES,JDT1_WT_Line,jdt1RecSize)
      dagJDT1.SetColStr(wtSide,JDT1_DEBIT_CREDIT,jdt1RecSize)
      dagJDT1.CopyColumn(dagJDT2,JDT1_ACCT_NUM,jdt1RecSize,INV5_ACCOUNT,jdt2CurRec)
      dagJDT1.CopyColumn(dagJDT2,JDT1_SHORT_NAME,jdt1RecSize,INV5_ACCOUNT,jdt2CurRec)
      dagJDT1.SetColLong(JDT,JDT1_TRANS_TYPE,jdt1RecSize)
      ii=0

      begin
         dagJDT1.GetColStr(tmpStr,toJDT1fields[ii],jdt1RecSize)
         tmpStr.Trim()
         if tmpStr==EMPTY_STR
            dagJDT1.GetColStr(tmpStr,toJDT1fields[ii],jdt1RecSize,fromJDTfields[ii],0)

         end



         ii+=1
      end while (toJDT1fields[ii]>=0)

      if WTGetCurrSource()==JDT_WT_FC_CURRENCY
         dagJDT1.SetColStr(GetBPLineCurrency(),JDT1_FC_CURRENCY,jdt1RecSize)

      end

      return ooErr

   end

   def WtUpdJDT1LineAmt(dagJDT1, jdt1CurRow, dagJDT2, jdt2CurRow, isDebit, wtAcctCode, wtSide)
      ooErr=ooNoErr



      dagJDT1.GetColMoney(&oldWT,GetJDT1MoneyCol(JDT_WT_LOCAL_CURRENCY,isDebit),jdt1CurRow)
      dagJDT1.GetColMoney(&oldWTSC,GetJDT1MoneyCol(JDT_WT_SYS_CURRENCY,isDebit),jdt1CurRow)
      dagJDT1.GetColMoney(&oldWTFC,GetJDT1MoneyCol(JDT_WT_FC_CURRENCY,isDebit),jdt1CurRow)
      dagJDT2.GetColMoney(&mnyAmt,INV5_WT_AMOUNT,jdt2CurRow)
      mnyAmt+=oldWT
      dagJDT1.SetColMoney(&mnyAmt,GetJDT1MoneyCol(JDT_WT_LOCAL_CURRENCY,isDebit),jdt1CurRow)
      dagJDT2.GetColMoney(&mnyAmt,INV5_WT_AMOUNT_SC,jdt2CurRow)
      mnyAmt+=oldWTSC
      dagJDT1.SetColMoney(&mnyAmt,GetJDT1MoneyCol(JDT_WT_SYS_CURRENCY,isDebit),jdt1CurRow)
      dagJDT2.GetColMoney(&mnyAmt,INV5_WT_AMOUNT_FC,jdt2CurRow)
      mnyAmt+=oldWTFC
      dagJDT1.SetColMoney(&mnyAmt,GetJDT1MoneyCol(JDT_WT_FC_CURRENCY,isDebit),jdt1CurRow)
      return ooErr

   end

   def OJDTIsDueDateRangeValid()
      _TRACER("OJDTIsDueDateRangeValid")
      env=GetEnv()

      if !VF_PaymentDueDate(env)||!ContainsCardLine()
         return true

      end




      ooErr=env.GetPDDData(pddEnabled,maxDaysForDueDate)
      if (ooErr!=ooNoErr)||!pddEnabled||(maxDaysForDueDate<=-1L)
         return true

      end


      dagJDT=GetDAG()
      if !DAG_IsValid(dagJDT)||(dagJDT.GetRealSize(dbmDataBuffer)<=0L)
         return true

      end


      dateField=dagJDT.GetColumnByType(DUE_DATE_FLD)
      if dateField<0L
         return true

      end


      ooErr=dagJDT.GetColStr(temp,dateField)
      IF_ERROR_RETURN_VALUE(ooErr,true)

      ooErr=DBM_DATE_ToLong(&dueDate,temp)
      IF_ERROR_RETURN_VALUE(ooErr,true)
      dateField=dagJDT.GetColumnByType(TAX_DATE_FLD)
      if dateField<0L
         return true

      end

      ooErr=dagJDT.GetColStr(temp,dateField)
      IF_ERROR_RETURN_VALUE(ooErr,true)

      ooErr=DBM_DATE_ToLong(&docDate,temp)
      IF_ERROR_RETURN_VALUE(ooErr,true)
      return ((dueDate-)<=maxDaysForDueDate)

   end

   def OJDTIsDocumentOrDueDateChanged()
      _TRACER("OJDTIsDocumentOrDueDateChanged")

      dagJDT=GetDAG()
      return CheckColChanged(dagJDT,OJDT_TAX_DATE)||CheckColChanged(dagJDT,OJDT_DUE_DATE)

   end

   def CompleteWTInfo()
      ooErr=ooNoErr

      dagJDT=GetDAG(JDT)


      dagJDT.GetColStr(autoWT,OJDT_AUTO_WT)
      autoWT.Trim()
      if autoWT==VAL_NO
         return ooErr

      end

      wtAllCurBaseCalcParamsPtr=CWTAllCurBaseCalcParams.new(())

      currSource=""

      wtInfo=CJDTWTInfo.new(())

      dagDOC=m_env.OpenDAG(INV

      PrePareDataForWT(wtAllCurBaseCalcParamsPtr,GetBPCurrencySource(),dagDOC,wtInfo)
      dagJDT2=GetDAG(JDT

      numOfRecs=dagJDT2.GetRecordCount()

      i=0

      begin
         wtAllCurBaseCalcParamsPtr.InitWTBaseCalcParams(currSource[i])
         GetWTBaseAmount(currSource[i],wtAllCurBaseCalcParamsPtr.GetWtBaseCalcParams(currSource[i]))
         if numOfRecs>0
            wtCurrSource=GetBPCurrencySource()

            if (currSource[i]!=INV_CARD_CURRENCY)||(currSource[i]==INV_CARD_CURRENCY&&wtCurrSource==INV_CARD_CURRENCY)
               m_WithholdingTaxMng.ODOCAutoCompleteDOC5(*this,currSource[i],wtAllCurBaseCalcParamsPtr.GetWtBaseCalcParams(currSource[i]),false,dagDOC)

            end


         else
            JDTCalcWTTable(wtInfo,currSource[i],dagDOC,wtAllCurBaseCalcParamsPtr)

         end



         i+=1
      end while (currSource[i])

      UpdateWTAmounts(wtAllCurBaseCalcParamsPtr)
      dagDOC.Close()


      return ooErr

   end

   def CompleteWTLine()
      ooErr=ooNoErr

      dagJDT=NULL
      dagJDT1 = NULL
      dagJDT2 = NULL


      dagJDT=GetDAG(JDT)
      if !DAG::IsValid(dagJDT)
         return ooErrNoMsg

      end

      dagJDT.GetColStr(autoWT,OJDT_AUTO_WT)
      autoWT.Trim()
      if autoWT!=VAL_YES
         return ooNoErr

      end

      ooErr=CompleteWTInfo()
      IF_ERROR_RETURN(ooErr)
      dagJDT1=GetDAG(JDT,ao_Arr1)
      dagJDT2=GetDAG(JDT,ao_Arr2)
      dagJDT2.GetColStr(wtCategory,INV5_CATEGORY)
      wtCategory.Trim()
      if wtCategory==VAL_CATEGORY_PAYMENT
         return ooNoErr

      end

      GetWTCredDebt(wtSide)
      isDebit=(wtSide==VAL_DEBIT)

      found=false

      jdt1RecSize=0
      jdt2RecSize = 0

      row=0



      jdt1RecSize=dagJDT1.GetRealSize(dbmDataBuffer)
      jdt2RecSize=dagJDT2.GetRealSize(dbmDataBuffer)
      rec=0

      begin
         dagJDT2.GetColStr(acctCode,INV5_ACCOUNT,rec)
         acctCode.Trim()
         found=false
         row=0
         begin
            dagJDT1.GetColStr(tmpStr,JDT1_WT_Line,row)
            if tmpStr.Trim()!=VAL_YES
               next


            end

            dagJDT1.GetColStr(tmpStr,JDT1_ACCT_NUM,row)
            if tmpStr.Trim()==acctCode
               found=true
               break

            end



            row+=1
         end while (row<jdt1RecSize)

         if found
            ooErr=WtUpdJDT1LineAmt(dagJDT1,row,dagJDT2,rec,isDebit,acctCode,wtSide)

         else
            ooErr=WtAutoAddJDT1Line(dagJDT1,jdt1RecSize,dagJDT2,rec,isDebit,wtSide)
            jdt1RecSize+=1

         end



         rec+=1
      end while (rec<jdt2RecSize)

      return ooErr

   end

   def UpdateWTAmounts(wtAllCurBaseCalcParamsPtr)
      ooErr=ooNoErr

      dagJDT2=GetDAG(JDT

      dagJDT=GetDAG(JDT)

      recCount=dagJDT2.GetRecordCount()


      currency=""

      rec=0

      begin
         i=0

         begin
            dagJDT2.GetColMoney(&mnyTmp,m_WithholdingTaxMng.ODOC5GetWTTaxAmountField(currency[i]),rec)
            wtSums[i]+=mnyTmp


            i+=1
         end while (currency[i])



         rec+=1
      end while (rec<recCount)


      dagJDT2.GetColStr(strRecBaseType,INV5_BASE_TYPE,0)
      i=0

      begin
         wtCurBaseCalcParamsPtr=wtAllCurBaseCalcParamsPtr.GetWtBaseCalcParams(currency[i])

         if m_env.IsLocalSettingsFlag(lsf_EnableLA1WHT)
            dagJDT.SetColMoney(&wtCurBaseCalcParamsPtr.m_wtBaseNetAmount,CTransactionJournalObject::GetWTBaseNetAmountField(currency[i]))
            dagJDT.SetColMoney(&wtCurBaseCalcParamsPtr.m_wtBaseVATAmount,CTransactionJournalObject::GetWTBaseVATAmountField(currency[i]))

         else
            if VAL_BASETYPE_NET==strRecBaseType
               dagJDT.SetColMoney(&wtCurBaseCalcParamsPtr.m_wtBaseNetAmount,CTransactionJournalObject::GetWTBaseNetAmountField(currency[i]))

            else
               dagJDT.SetColMoney(&wtCurBaseCalcParamsPtr.m_wtBaseAmount,CTransactionJournalObject::GetWTBaseNetAmountField(currency[i]))

            end


         end

         dagJDT.SetColMoney(&wtSums[i],CTransactionJournalObject::GetWtSumField(currency[i]))


         i+=1
      end while (currency[i])

      return ooErr

   end

   def CalcBpCurrRateForDocRate(rate)
      ooErr=ooNoErr

      dagJDT1=GetDAG(JDT

      env=GetEnv()


      recJDT1=dagJDT1.GetRealSize(dbmDataBuffer)


      flag=false

      rec=0

      begin
         dagJDT1.GetColStr(acct,JDT1_ACCT_NUM,rec)
         dagJDT1.GetColStr(shortname,JDT1_SHORT_NAME,rec)
         acct.Trim()
         shortname.Trim()
         if acct!=shortname
            dagJDT1.GetColMoney(&mLocal,JDT1_CREDIT,rec)
            dagJDT1.GetColMoney(&mFrgn,JDT1_FC_CREDIT,rec)
            if mLocal.IsPositive()&&mFrgn.IsPositive()
               flag=true

            else
               dagJDT1.GetColMoney(&mLocal,JDT1_DEBIT,rec)
               dagJDT1.GetColMoney(&mFrgn,JDT1_FC_DEBIT,rec)
               if mLocal.IsPositive()&&mFrgn.IsPositive()
                  flag=true

               end


            end

            break

         end



         rec+=1
      end while (rec<recJDT1)

      if flag
         if env.IsDirectRate()
            rate=mLocal.MulAndDiv(1L)
            L

         end


      end


   end

   def SetSysCurrRateForDOC(dagDOC)
      ooErr=noErr

      env=GetEnv()


      dagJDT=GetDAG(JDT)

      if !DAG::IsValid(dagDOC)
         return ooErrNoMsg

      end

      dagDOC.GetColMoney(&rate,OINV_SYSTEM_RATE)
      if rate.IsPositive()
         return ooErr

      end


      _STR_strcpy(mainCurrecny,env.GetMainCurrency().GetBuffer())
      _STR_strcpy(sysCurrency,env.GetSystemCurrency().GetBuffer())
      rateVal1.FromDouble(MONEY_PERCISION_MUL)
      sysCurrAsMain=(bool)

      !GNCoinCmp(sysCurrency,mainCurrecny)
      if rate.IsZero()
         rate=1L
         if !sysCurrAsMain
            ooErr=nsDocument::ODOCGetAndWaitUntilRateByDag(sysCurrency,dagJDT,&rate,env)

         else
            rate=rateVal1

         end


      else
         if rate.IsNegative()||(sysCurrAsMain&&(rate!=rateVal1))
            ooErr=ooErrNoMsg

         end

      end

      dagDOC.SetColMoney(&rate,OINV_SYSTEM_RATE)
      if ooErr
         Message(ERROR_MESSAGES_STR,OO_ILLEGAL_SUM,sysCurrency,OO_ERROR)
         SetErrorField(OINV_SYSTEM_RATE)
         return ooErrNoMsg

      end

      return ooErr

   end

   def UpgradeERDBaseTrans()
      ooErr=ooNoErr

      ooErr=UpgradeERDBaseTransFromBackup()
      if ooErr
         if ooErr==dbmTableNotFound
            ooErr=0

         else
            return ooErr

         end


      end

      ooErr=UpgradeERDBaseTransFromRef3()
      return ooErr

   end

   def UpgradeERDBaseTransFromBackup()
      ooErr=ooNoErr
      tmpErr

      bizEnv=GetEnv()






      bizEnv.GetColAttributes(bizEnv.ObjectToTable(JDT,ao_Main),OJDT_JDT_NUM,&colAttr,FALSE)
      DBMTableDefs::FormatOneDBField(&colAttr)
      colList.Add(colAttr)
      bizEnv.GetColAttributes(bizEnv.ObjectToTable(JDT,ao_Main),OJDT_BASE_REF,&colAttr,FALSE)
      DBMTableDefs::FormatOneDBField(&colAttr)
      colList.Add(colAttr)
      ooErr=bizEnv.GetTD(dbmFixedTD).CreateFixedDefinition(JDT_ERDBASETRANSFIX_BT_NAME,colList,keyList)
      if ooErr
         return ooErr

      end


      queryParams.Clear()

      tablePtr=&(queryParams.GetCondTables().AddTable())
      tablePtr.tableCode=JDT_ERDBASETRANSFIX_BT_NAME

      resStruct[JDT_ERDBASETRANSFIX_BT_COL_TRANS_ID].tableIndex=0
      resStruct[JDT_ERDBASETRANSFIX_BT_COL_TRANS_ID].colNum=JDT_ERDBASETRANSFIX_BT_COL_TRANS_ID
      resStruct[JDT_ERDBASETRANSFIX_BT_COL_BASE_REF].tableIndex=0
      resStruct[JDT_ERDBASETRANSFIX_BT_COL_BASE_REF].colNum=JDT_ERDBASETRANSFIX_BT_COL_BASE_REF
      queryParams.dbdResPtr=resStruct
      queryParams.numOfResCols=2
      dagRes=NULL

      dagQuery=bizEnv.OpenDAG(JDT

      dagQuery.SetDBDParms(&queryParams)
      ooErr=DBD_GetInNewFormat(dagQuery,&dagRes)
      if ooErr
         if ooErr==-1
            ooErr=dbmTableNotFound


         else
            if ooErr==dbmNoDataFound
               dagRes.SetSize(0,dbmDropData)
               ooErr=noErr

            else


            end

         end


      end

      numOfRecs=dagRes.GetRecordCount()
      rec=0
      begin
         dagRes.GetColLong(&transId,JDT_ERDBASETRANSFIX_BT_COL_TRANS_ID,rec)
         dagRes.GetColLong(&baseRef,JDT_ERDBASETRANSFIX_BT_COL_BASE_REF,rec)
         ooErr=UpgradeERDBaseTransUpdateOne(transId,baseRef)
         if ooErr


         end



         +=1rec
      end while (rec<numOfRecs)

      leave

   end

   def UpgradeERDBaseTransUpdateOne(transId, erdBaseTrans)
      ooErr=ooNoErr

      bizEnv=GetEnv()

      dagJDT=bizEnv.OpenDAG(JDT




      conditions=&(dagJDT.GetDBDParams().GetConditions())
      conditions.Clear()
      condPtr=&conditions.AddCondition()
      condPtr.colNum=OJDT_JDT_NUM
      condPtr.operation=DBD_EQ
      condPtr.condVal=transId
      condPtr.relationship=0
      updStruct[0].colNum=OJDT_BASE_TRANS_ID
      updStruct[0].updateVal=erdBaseTrans
      ooErr=DBD_SetDAGUpd(dagJDT,updStruct,1)
      if ooErr
         dagJDT.Close()
         return ooErr

      end

      ooErr=DBD_UpdateCols(dagJDT)
      dagJDT.Close()
      return ooErr

   end

   def UpgradeERDBaseTransFromRef3()
      ooErr=ooNoErr

      bizEnv=GetEnv()






      UpgradeERDBaseTransPopulateAbbrevMap(abbrevMap)
      queryParams.Clear()
      tablePtr=&(queryParams.GetCondTables().AddTable())
      tablePtr.tableCode=bizEnv.ObjectToTable(JDT,ao_Arr1)
      tablePtr=&(queryParams.GetCondTables().AddTable())
      tablePtr.tableCode=bizEnv.ObjectToTable(JDT,ao_Main)
      tablePtr.doJoin=true
      tablePtr.joinedToTable=JDT_ERDBASETRANSFIX_JDT1_TABLE_NUM
      tablePtr.numOfConds=JDT_ERDBASETRANSFIX_OJDT_NUM_OF_JOINS
      tablePtr.joinConds=joinCondsOJDT
      condNum=0
      joinCondsOJDT[condNum].compareCols=true
      joinCondsOJDT[condNum].tableIndex=JDT_ERDBASETRANSFIX_OJDT_TABLE_NUM
      joinCondsOJDT[condNum].colNum=OJDT_JDT_NUM
      joinCondsOJDT[condNum].compTableIndex=JDT_ERDBASETRANSFIX_JDT1_TABLE_NUM
      joinCondsOJDT[condNum].compColNum=JDT1_TRANS_ABS
      joinCondsOJDT[condNum].operation=DBD_EQ
      joinCondsOJDT[condNum+=1].relationship=0

      resStruct[JDT_ERDBASETRANSFIX_TRANSID_RES].tableIndex=JDT_ERDBASETRANSFIX_OJDT_TABLE_NUM
      resStruct[JDT_ERDBASETRANSFIX_TRANSID_RES].colNum=OJDT_JDT_NUM
      resStruct[JDT_ERDBASETRANSFIX_LINEID_RES].tableIndex=JDT_ERDBASETRANSFIX_JDT1_TABLE_NUM
      resStruct[JDT_ERDBASETRANSFIX_LINEID_RES].colNum=JDT1_LINE_ID
      resStruct[JDT_ERDBASETRANSFIX_ACCOUNT_RES].tableIndex=JDT_ERDBASETRANSFIX_JDT1_TABLE_NUM
      resStruct[JDT_ERDBASETRANSFIX_ACCOUNT_RES].colNum=JDT1_ACCT_NUM
      resStruct[JDT_ERDBASETRANSFIX_SHORTNAME_RES].tableIndex=JDT_ERDBASETRANSFIX_JDT1_TABLE_NUM
      resStruct[JDT_ERDBASETRANSFIX_SHORTNAME_RES].colNum=JDT1_SHORT_NAME
      resStruct[JDT_ERDBASETRANSFIX_REF3_RES].tableIndex=JDT_ERDBASETRANSFIX_JDT1_TABLE_NUM
      resStruct[JDT_ERDBASETRANSFIX_REF3_RES].colNum=JDT1_REF3_LINE
      queryParams.dbdResPtr=resStruct
      queryParams.numOfResCols=JDT_ERDBASETRANSFIX_RES_SIZE

      condPtr=&(queryParams.GetConditions().AddCondition())
      condPtr.tableIndex=JDT_ERDBASETRANSFIX_OJDT_TABLE_NUM
      condPtr.colNum=OJDT_TRANS_TYPE
      condPtr.operation=DBD_EQ
      condPtr.condVal=JDT
      condPtr.relationship=DBD_AND
      condPtr=&(queryParams.GetConditions().AddCondition())
      condPtr.tableIndex=JDT_ERDBASETRANSFIX_JDT1_TABLE_NUM
      condPtr.colNum=JDT1_FC_CREDIT
      condPtr.operation=DBD_EQ
      condPtr.condVal=0L
      condPtr.relationship=DBD_AND
      condPtr=&(queryParams.GetConditions().AddCondition())
      condPtr.tableIndex=JDT_ERDBASETRANSFIX_JDT1_TABLE_NUM
      condPtr.colNum=JDT1_FC_DEBIT
      condPtr.operation=DBD_EQ
      condPtr.condVal=0L
      condPtr.relationship=DBD_AND
      condPtr=&(queryParams.GetConditions().AddCondition())
      condPtr.tableIndex=JDT_ERDBASETRANSFIX_JDT1_TABLE_NUM
      condPtr.colNum=JDT1_FC_CURRENCY
      condPtr.operation=DBD_NOT_NULL
      condPtr.relationship=DBD_AND
      condPtr=&(queryParams.GetConditions().AddCondition())
      condPtr.tableIndex=JDT_ERDBASETRANSFIX_OJDT_TABLE_NUM
      condPtr.colNum=OJDT_BASE_TRANS_ID
      condPtr.operation=DBD_IS_NULL
      condPtr.relationship=DBD_AND
      condPtr=&(queryParams.GetConditions().AddCondition())
      condPtr.tableIndex=JDT_ERDBASETRANSFIX_JDT1_TABLE_NUM
      condPtr.colNum=JDT1_REF3_LINE
      condPtr.operation=DBD_PATTERN
      condPtr.condVal=_T("*/*/*")
      condPtr.relationship=0

      key.SetSegmentsCount(2)
      key.SetSegmentColumn(0,JDT_ERDBASETRANSFIX_TRANSID_RES)
      key.SetSegmentColumn(1,JDT_ERDBASETRANSFIX_LINEID_RES)
      dagRes=NULL

      dagQuery=bizEnv.OpenDAG(BOT

      dagQuery.SetDBDParms(&queryParams)
      ooErr=dagQuery.GetFirstChunk(JDT_ERDBASETRANSFIX_BATCH_SIZE,key,&dagRes)
      if (ooErr)&&(ooErr!=dbmNoDataFound)
         dagQuery.Close()
         return ooErr

      end

      while (ooErr!=dbmNoDataFound)
         numOfRecs=dagRes.GetRecordCount()
         rec=0
         begin


            dagRes.GetColLong(&transId,JDT_ERDBASETRANSFIX_TRANSID_RES,rec)
            dagRes.GetColStr(account,JDT_ERDBASETRANSFIX_ACCOUNT_RES,rec)
            dagRes.GetColStr(shortName,JDT_ERDBASETRANSFIX_SHORTNAME_RES,rec)
            dagRes.GetColStr(ref3Line,JDT_ERDBASETRANSFIX_REF3_RES,rec)
            baseTransCandidate=0
            ooErr=UpgradeERDBaseTransFindBaseTrans(abbrevMap,account,shortName,ref3Line,&baseTransCandidate)
            if ooErr
               if ooErr!=dbmNoDataFound
                  dagQuery.Close()
                  return ooErr

               end


            else
               if baseTransCandidate
                  ooErr=UpgradeERDBaseTransUpdateOne(transId,baseTransCandidate)
                  if ooErr
                     dagQuery.Close()
                     return ooErr

                  end


               end

            end



            +=1rec
         end while (rec<numOfRecs)

         ooErr=dagQuery.GetNextChunk(JDT_ERDBASETRANSFIX_BATCH_SIZE,key,&dagRes)
         if (ooErr)&&(ooErr!=dbmNoDataFound)
            dagQuery.Close()
            return ooErr

         end


      end

      dagQuery.Close()
      return ooNoErr

   end

   def UpgradeERDBaseTransFindBaseTrans(objectMap, inAccount, inShortName, inRef3Line, outBaseTransCandidate)
      ooErr=ooNoErr

      bizEnv=GetEnv()





      numOfCandidates=0



      sep1Pos=inRef3Line.Find(JDT_ERDBASETRANSFIX_REF3_SEPARATOR)
      periodCode=inRef3Line.Left(sep1Pos)
      sep2Pos=inRef3Line.Find(JDT_ERDBASETRANSFIX_REF3_SEPARATOR,sep1Pos+)
      docTypeCode=inRef3Line.Mid(sep1Pos+,sep2Pos--)
      docNum=inRef3Line.Mid(sep2Pos+)

      omIt=objectMap.begin()
      begin
         if omIt.second.find(docTypeCode)!=omIt.second.end()
            objectId=omIt.first

            queryParams.Clear()
            tablePtr=&(queryParams.GetCondTables().AddTable())
            tablePtr.tableCode=bizEnv.ObjectToTable(objectId,ao_Main)
            tablePtr=&(queryParams.GetCondTables().AddTable())
            tablePtr.tableCode=bizEnv.ObjectToTable(FPR,ao_Main)
            tablePtr.doJoin=true
            tablePtr.joinedToTable=0
            tablePtr.numOfConds=1
            tablePtr.joinConds=joinCondsOFPR
            condNum=0
            joinCondsOFPR[condNum].compareCols=true
            joinCondsOFPR[condNum].tableIndex=1
            joinCondsOFPR[condNum].colNum=OFPR_ABS_ENTRY
            joinCondsOFPR[condNum].compTableIndex=0
            joinCondsOFPR[condNum].compColNum=UpgradeERDBaseTransGetFPRCol(objectId)
            joinCondsOFPR[condNum].operation=DBD_EQ
            joinCondsOFPR[condNum+=1].relationship=0

            resStruct[0].tableIndex=0
            resStruct[0].colNum=UpgradeERDBaseTransGetTransIdCol(objectId)
            queryParams.dbdResPtr=resStruct
            queryParams.numOfResCols=1

            UpgradeERDBaseTransAddDocNumConds(objectId,docNum,queryParams.GetConditions())
            condPtr=&(queryParams.GetConditions().AddCondition())
            condPtr.tableIndex=1
            condPtr.colNum=OFPR_CODE
            condPtr.operation=DBD_EQ
            condPtr.condVal=periodCode
            condPtr.relationship=DBD_AND


            condPtr=&(queryParams.GetConditions().AddCondition())
            condPtr.SetUseSubQuery(true)
            subQueryParams.GetCondTables().Clear()
            tablePtr=&(subQueryParams.GetCondTables().AddTable())
            tablePtr.tableCode=bizEnv.ObjectToTable(JDT,ao_Arr1)
            subResStruct[0].agreg_type=DBD_COUNT
            subResStruct[0].tableIndex=0
            subResStruct[0].colNum=JDT1_TRANS_ABS
            subQueryParams.dbdResPtr=subResStruct
            subQueryParams.numOfResCols=1
            subQueryParams.GetConditions().Clear()
            subCondPtr=&(subQueryParams.GetConditions().AddCondition())

            subCondPtr.origTableLevel=1
            subCondPtr.origTableIndex=0
            subCondPtr.compareCols=true
            subCondPtr.colNum=UpgradeERDBaseTransGetTransIdCol(objectId)
            subCondPtr.operation=DBD_EQ
            subCondPtr.compTableIndex=0
            subCondPtr.compColNum=JDT1_TRANS_ABS
            subCondPtr.relationship=DBD_AND
            subCondPtr=&(subQueryParams.GetConditions().AddCondition())
            subCondPtr.tableIndex=0
            subCondPtr.colNum=JDT1_ACCT_NUM
            subCondPtr.operation=DBD_EQ
            subCondPtr.condVal=inAccount
            subCondPtr.relationship=DBD_AND
            subCondPtr=&(subQueryParams.GetConditions().AddCondition())
            subCondPtr.tableIndex=0
            subCondPtr.colNum=JDT1_SHORT_NAME
            subCondPtr.operation=DBD_EQ
            subCondPtr.condVal=inShortName
            subCondPtr.relationship=DBD_AND
            subCondPtr=&(subQueryParams.GetConditions().AddCondition())
            subCondPtr.tableIndex=0
            subCondPtr.colNum=JDT1_FC_CURRENCY
            subCondPtr.operation=DBD_NE
            subCondPtr.condVal=bizEnv.GetMainCurrency()
            subCondPtr.relationship=DBD_AND
            subCondPtr=&(subQueryParams.GetConditions().AddCondition())
            subCondPtr.tableIndex=0
            subCondPtr.colNum=JDT1_FC_CURRENCY
            subCondPtr.operation=DBD_NOT_NULL
            subCondPtr.relationship=0
            condPtr.SetSubQueryParams(&subQueryParams)
            condPtr.tableIndex=DBD_NO_TABLE
            condPtr.operation=DBD_GT
            condPtr.condVal=0L
            condPtr.relationship=0

            dagRes=NULL

            dagQuery=bizEnv.OpenDAG(BOT

            dagQuery.SetDBDParms(&queryParams)
            ooErr=DBD_GetInNewFormat(dagQuery,&dagRes)
            if ooErr
               if ooErr==dbmNoDataFound
                  dagRes.SetSize(0,dbmDropData)
                  ooErr=ooNoErr

               else
                  dagQuery.Close()
                  return ooErr

               end


            end

            if dagRes.GetRecordCount()>0
               numOfCandidates+=dagRes.GetRecordCount()
               dagRes.GetColLong(outBaseTransCandidate,0,0)

            end

            dagQuery.Close()

         end



         +=1omIt
      end while (omIt!=objectMap.end())

      if numOfCandidates==1
         ooErr=ooNoErr

      else
         ooErr=dbmNoDataFound

      end

      return ooErr

   end

   def UpgradeERDBaseTransAddDocNumConds(objectId, docNum, conds)

      if objectId==JDT
         condPtr=&(conds.AddCondition())
         condPtr.bracketOpen=1
         condPtr.tableIndex=0
         condPtr.colNum=OJDT_NUMBER
         condPtr.operation=DBD_EQ
         condPtr.condVal=docNum
         condPtr.relationship=DBD_OR
         condPtr=&(conds.AddCondition())
         condPtr.tableIndex=0
         condPtr.colNum=OJDT_JDT_NUM
         condPtr.operation=DBD_EQ
         condPtr.condVal=docNum
         condPtr.bracketClose=1

      else
         if objectId==RCT||objectId==VPM
            condPtr=&(conds.AddCondition())
            condPtr.tableIndex=0
            condPtr.colNum=ORCT_NUM
            condPtr.operation=DBD_EQ
            condPtr.condVal=docNum
            condPtr.relationship=DBD_AND
            condPtr=&(conds.AddCondition())
            condPtr.tableIndex=0
            condPtr.colNum=ORCT_CANCELED
            condPtr.operation=DBD_NE
            condPtr.condVal=VAL_YES

         else
            condPtr=&(conds.AddCondition())
            condPtr.tableIndex=0
            condPtr.colNum=OINV_NUM
            condPtr.operation=DBD_EQ
            condPtr.condVal=docNum

         end

      end

      condPtr.relationship=DBD_AND

   end

   def UpgradeERDBaseTransGetTransIdCol(objectId)
      if objectId==JDT
         return OJDT_JDT_NUM

      else
         if objectId==RCT||objectId==VPM
            return ORCT_TRANS_NUM

         else
            return OINV_TRANS_NUM

         end

      end


   end

   def UpgradeERDBaseTransGetFPRCol(objectId)
      if objectId==JDT
         return OJDT_FINANCE_PERIOD

      else
         if objectId==RCT||objectId==VPM
            return ORCT_FINANCE_PERIOD

         else
            return OINV_FINANCE_PERIOD

         end

      end


   end

   def UpgradeERDBaseTransPopulateAbbrevMap(abbrevMap)

      docAbbrevs.insert(_T("IN"))
      docAbbrevs.insert(_T("FP"))
      docAbbrevs.insert(_T("VS"))
      docAbbrevs.insert(_T("PF"))
      docAbbrevs.insert(_T("FA"))
      abbrevMap[INV]=docAbbrevs
      docAbbrevs.clear()
      docAbbrevs.insert(_T("CN"))
      docAbbrevs.insert(_T("DP"))
      docAbbrevs.insert(_T("KI"))
      docAbbrevs.insert(_T("ZP"))
      docAbbrevs.insert(_T("KR"))
      docAbbrevs.insert(_T("OD"))
      abbrevMap[RIN]=docAbbrevs
      docAbbrevs.clear()
      docAbbrevs.insert(_T("PU"))
      docAbbrevs.insert(_T("FN"))
      docAbbrevs.insert(_T("SS"))
      docAbbrevs.insert(_T("FZ"))
      docAbbrevs.insert(_T("FV"))
      docAbbrevs.insert(_T("DF"))
      abbrevMap[PCH]=docAbbrevs
      docAbbrevs.clear()
      docAbbrevs.insert(_T("PC"))
      docAbbrevs.insert(_T("DN"))
      docAbbrevs.insert(_T("SJ"))
      docAbbrevs.insert(_T("ZK"))
      docAbbrevs.insert(_T("KM"))
      docAbbrevs.insert(_T("DN"))
      abbrevMap[RPC]=docAbbrevs
      docAbbrevs.clear()
      docAbbrevs.insert(_T("CV"))
      docAbbrevs.insert(_T("CU"))
      docAbbrevs.insert(_T("OF"))
      docAbbrevs.insert(_T("BH"))
      docAbbrevs.insert(_T("SV"))
      docAbbrevs.insert(_T("SZ"))
      docAbbrevs.insert(_T("CN"))
      abbrevMap[CPI]=docAbbrevs
      docAbbrevs.clear()
      docAbbrevs.insert(_T("CS"))
      docAbbrevs.insert(_T("OF"))
      docAbbrevs.insert(_T("KH"))
      docAbbrevs.insert(_T("VV"))
      docAbbrevs.insert(_T("SK"))
      docAbbrevs.insert(_T("CP"))
      docAbbrevs.insert(_T("CE"))
      abbrevMap[CSI]=docAbbrevs
      docAbbrevs.clear()
      docAbbrevs.insert(_T("RC"))
      docAbbrevs.insert(_T("BP"))
      docAbbrevs.insert(_T("FB"))
      docAbbrevs.insert(_T("KP"))
      docAbbrevs.insert(_T("DP"))
      abbrevMap[RCT]=docAbbrevs
      docAbbrevs.clear()
      docAbbrevs.insert(_T("PS"))
      docAbbrevs.insert(_T("BV"))
      docAbbrevs.insert(_T("FK"))
      docAbbrevs.insert(_T("FZ"))
      docAbbrevs.insert(_T("ZD"))
      docAbbrevs.insert(_T("PD"))
      abbrevMap[VPM]=docAbbrevs
      docAbbrevs.clear()
      docAbbrevs.insert(_T("JE"))
      docAbbrevs.insert(_T("ZD"))
      docAbbrevs.insert(_T("NB"))
      docAbbrevs.insert(_T("KS"))
      docAbbrevs.insert(_T("UZ"))
      abbrevMap[JDT]=docAbbrevs

   end

   def UpgradeDOC6VatPaidForFullyBasedCreditMemos(objID)
      ooErr=noErr

      env=GetEnv()

      def updStmt
         (env)
      end

      try
      tDoc6=updStmt.Update(env.ObjectToTable(objID

      tOdoc=updStmt.Update(env.ObjectToTable(objID

      updStmt.Set(INV6_VAT_APPLIED).Col(tDoc6,INV6_VAT_SUM)
      updStmt.Set(INV6_VAT_APPLIED_SYS).Col(tDoc6,INV6_VAT_SYS)
      updStmt.Set(INV6_VAT_APPLIED_FRGN).Col(tDoc6,INV6_VAT_FRGN)
      updStmt.Where().Col(tDoc6,INV6_ABS_ENTRY).EQ().Col(tOdoc,OINV_ABS_ENTRY).And().Col(tDoc6,INV6_STATUS).EQ().Val(VAL_CLOSE).And().Col(tOdoc,OINV_STATUS).EQ().Val(VAL_CLOSE).And().Col(tDoc6,INV6_VAT_APPLIED).EQ().Val(0L)
      updStmt.Execute()

      catch(DBMException&e)
      ooErr=e.GetCode()
      return ooErr

      return ooErr

   end

   def UpgradeODOCVatPaidForFullyBasedCreditMemos(objID)
      ooErr=noErr

      env=GetEnv()

      def updStmt
         (env)
      end

      try
      tOdoc=updStmt.Update(env.ObjectToTable(objID

      updStmt.Set(OINV_VAT_APPLIED).Col(tOdoc,OINV_VAT_SUM)
      updStmt.Set(OINV_VAT_APPLIED_SYS).Col(tOdoc,OINV_VAT_SYS)
      updStmt.Set(OINV_VAT_APPLIED_FRGN).Col(tOdoc,OINV_VAT_FRGN)
      updStmt.Where().Col(tOdoc,OINV_VAT_APPLIED).EQ().Val(0L).And().Col(tOdoc,OINV_STATUS).EQ().Val(VAL_CLOSE)
      updStmt.Execute()

      catch(DBMException&e)
      ooErr=e.GetCode()
      return ooErr

      return ooErr

   end

   def GetCreateDate()
      date=EMPTY_STR

      dag=GetDAG()

      if dag
         dag.GetColStr(date,OJDT_CREATE_DATE)

      end

      return Date(date)

   end

   def RepairEquVatRateOfJDT1()
      ooErr=ooNoErr

      objectId=""

      i=0

      begin
         ooErr=RepairEquVatRateOfJDT1ForOneObject(objectId[i])
         IF_ERROR_RETURN(ooErr)


         i+=1
      end while (objectId[i]!=NOB)

      return ooErr

   end

   def RepairEquVatRateOfJDT1ForOneObject(objectId)
      ooErr=ooNoErr


      def bq
         (&GetEnv())
      end

      bq.AddTable(TAX,ao_Arr1,&tableTAX1)
      bq.AddJoin(TAX,ao_Main,&tableOTAX,tableTAX1,SMU_BQ_INNER_JOIN)
      bq.ConditionContext_SetToJoin(tableOTAX)
      bq.AddConditions().Col(tableOTAX,OTAX_ABS_ENTRY).EQ().Col(tableTAX1,TAX1_ABS_ENTRY)
      bq.AddJoin(JDT,ao_Main,&tableOJDT,tableOTAX,SMU_BQ_INNER_JOIN)
      bq.ConditionContext_SetToJoin(tableOJDT)
      bq.AddConditions().Col(tableOJDT,OJDT_TRANS_TYPE).EQ().Col(tableOTAX,OTAX_SOURCE_OBJ_TYPE).AND().Col(tableOJDT,OJDT_BASE_REF).EQ().Col(tableOTAX,OTAX_SOURCE_OBJ_ABS_ENTRY)
      bq.AddJoin(JDT,ao_Arr1,&tableJDT1,tableOJDT,SMU_BQ_INNER_JOIN)
      bq.ConditionContext_SetToJoin(tableJDT1)
      bq.AddConditions().Col(tableJDT1,JDT1_TRANS_ABS).EQ().Col(tableOJDT,OJDT_JDT_NUM).AND().Col(tableJDT1,JDT1_VAT_LINE).EQ().Val(VAL_YES).AND().Col(tableJDT1,JDT1_VAT_GROUP).EQ().Col(tableTAX1,TAX1_TAX_CODE)
      bq.AddJoin(objectId,ao_Main,&tableOINV,tableOTAX,SMU_BQ_INNER_JOIN)
      bq.ConditionContext_SetToJoin(tableOINV)
      bq.AddConditions().Col(tableOINV,INV1_ABS_ENTRY).EQ().Col(tableOTAX,OTAX_SOURCE_OBJ_ABS_ENTRY)
      bq.ConditionContext_SetToWherePart()
      bq.AddConditions().Col(tableTAX1,TAX1_EQ_PERCENT).NE().Val(STR_0).AND().Col(tableOTAX,OTAX_SOURCE_OBJ_TYPE).EQ().Val(objectId)
      bq.AddCondition_AND()
      bq.AddCondition_BracketOpen()
      version=VERSION_2007_226

      begin
         def versionStr
            (version)
         end


         version+=1
      end while (version<=VERSION_2007_227)


   end

   def UpdateIncorrectEquVatRate(dagRes)
      ooErr=ooNoErr



      rec=dagRes.GetRecordCount()-


      begin


         rec>=0
      end while ()

      rec-=1

   end

   def UpdateIncorrectEquVatRateOneRec(dagRes, rec)
      ooErr=ooNoErr



      dagRes.GetColLong(&transId,resJdt1TransId,rec)
      dagRes.GetColLong(&lineId,resJdt1Line_ID,rec)
      dagRes.GetColMoney(&equVatRate,resTax1EqPercent,rec)


      conds[0].colNum=JDT1_TRANS_ABS
      conds[0].operation=DBD_EQ
      conds[0].condVal=transId
      conds[0].relationship=DBD_AND
      conds[1].colNum=JDT1_LINE_ID
      conds[1].operation=DBD_EQ
      conds[1].condVal=lineId
      conds[1].relationship=0
      updateStruct[0].colNum=JDT1_EQU_VAT_PERCENT
      equVatRate.ToSBOString(updateStruct[0].updateVal)
      dagJDT1=GetEnv().OpenDAG(JDT

      DBD_SetDAGCond(dagJDT1,conds,2)
      DBD_SetDAGUpd(dagJDT1,updateStruct,1)
      ooErr=DBD_UpdateCols(dagJDT1)
      dagJDT1.Close()
      return ooErr

   end

   def UpgradeJDTCEEPerioEndReconcilations()
      _TRACER("UpgradeJDTCEEPerioEndReconcilations")
      sboErr=noErr


      bizEnv=GetEnv()







      dagJDT1=GetDAG()

      dagJDT1.ClearQueryParams()
      tables[0].tableCode=bizEnv.ObjectToTable(JDT,ao_Arr1)
      tables[1].tableCode=bizEnv.ObjectToTable(JDT,ao_Main)
      tables[2].tableCode=bizEnv.ObjectToTable(ITR,ao_Arr1)
      tables[3].tableCode=bizEnv.ObjectToTable(ITR,ao_Main)
      tables[1].doJoin=true
      tables[1].joinedToTable=0
      tables[1].numOfConds=1
      tables[1].joinConds=join1
      join1[0].compareCols=true
      join1[0].compColNum=JDT1_TRANS_ABS
      join1[0].compTableIndex=0
      join1[0].colNum=OJDT_JDT_NUM
      join1[0].tableIndex=1
      join1[0].operation=DBD_EQ
      tables[2].doJoin=true
      tables[2].joinedToTable=0
      tables[2].numOfConds=1
      tables[2].joinConds=join2
      join2[0].compareCols=true
      join2[0].compColNum=JDT1_TRANS_ABS
      join2[0].compTableIndex=0
      join2[0].colNum=ITR1_TRANS_ID
      join2[0].tableIndex=2
      join2[0].operation=DBD_EQ
      tables[3].doJoin=true
      tables[3].joinedToTable=2
      tables[3].numOfConds=1
      tables[3].joinConds=join3
      join3[0].compareCols=true
      join3[0].compColNum=ITR1_RECON_NUM
      join3[0].compTableIndex=2
      join3[0].colNum=OITR_RECON_NUM
      join3[0].tableIndex=3
      join3[0].operation=DBD_EQ
      DBD_SetTablesList(dagJDT1,tables,4)
      resStruct[CPE_RES_RECON_NUM].tableIndex=2
      resStruct[CPE_RES_RECON_NUM].colNum=ITR1_RECON_NUM
      resStruct[CPE_RES_LINE_SEQUENCE].tableIndex=2
      resStruct[CPE_RES_LINE_SEQUENCE].colNum=ITR1_LINE_SEQUENCE
      resStruct[CPE_RES_TRANS_ID].tableIndex=2
      resStruct[CPE_RES_TRANS_ID].colNum=ITR1_TRANS_ID
      resStruct[CPE_RES_TRANS_LINE_ID].tableIndex=2
      resStruct[CPE_RES_TRANS_LINE_ID].colNum=ITR1_TRANS_LINE_ID
      resStruct[CPE_RES_SRC_OBJ_TYPE].tableIndex=2
      resStruct[CPE_RES_SRC_OBJ_TYPE].colNum=ITR1_SRC_OBJ_TYPE
      DBD_SetDAGRes(dagJDT1,resStruct,5)
      conditions=&dagJDT1.GetDBDParams().GetConditions()
      cond=&conditions.AddCondition()
      cond.bracketOpen=true
      cond.colNum=JDT1_BALANCE_DUE_DEBIT
      cond.condVal=_T("0.00")
      cond.operation=DBD_NE
      cond.relationship=DBD_OR
      cond=&conditions.AddCondition()
      cond.colNum=JDT1_BALANCE_DUE_CREDIT
      cond.condVal=_T("0.00")
      cond.operation=DBD_NE
      cond.relationship=DBD_OR
      cond=&conditions.AddCondition()
      cond.colNum=JDT1_BALANCE_DUE_FC_DEB
      cond.condVal=_T("0.00")
      cond.operation=DBD_NE
      cond.relationship=DBD_OR
      cond=&conditions.AddCondition()
      cond.colNum=JDT1_BALANCE_DUE_FC_CRED
      cond.condVal=_T("0.00")
      cond.operation=DBD_NE
      cond.relationship=DBD_OR
      cond=&conditions.AddCondition()
      cond.colNum=JDT1_BALANCE_DUE_SC_DEB
      cond.condVal=_T("0.00")
      cond.operation=DBD_NE
      cond.relationship=DBD_OR
      cond=&conditions.AddCondition()
      cond.colNum=JDT1_BALANCE_DUE_SC_CRED
      cond.condVal=_T("0.00")
      cond.operation=DBD_NE
      cond.bracketClose=true
      cond.relationship=DBD_AND
      cond=&conditions.AddCondition()
      cond.bracketOpen=true
      cond.tableIndex=1
      cond.colNum=OJDT_TRANS_TYPE
      cond.condVal=SBOString(OPEN_BLNC_TYPE)
      cond.operation=DBD_EQ
      cond.relationship=DBD_OR
      cond=&conditions.AddCondition()
      cond.tableIndex=1
      cond.colNum=OJDT_TRANS_TYPE
      cond.condVal=SBOString(CLOSE_BLNC_TYPE)
      cond.operation=DBD_EQ
      cond.bracketClose=true
      cond.relationship=DBD_AND
      cond=&conditions.AddCondition()
      cond.bracketOpen=true
      cond.tableIndex=2
      cond.colNum=ITR1_SRC_OBJ_TYPE
      cond.condVal=SBOString(OPEN_BLNC_TYPE)
      cond.operation=DBD_EQ
      cond.relationship=DBD_OR
      cond=&conditions.AddCondition()
      cond.tableIndex=2
      cond.colNum=ITR1_SRC_OBJ_TYPE
      cond.condVal=SBOString(CLOSE_BLNC_TYPE)
      cond.operation=DBD_EQ
      cond.bracketClose=true
      cond.relationship=DBD_AND
      cond=&conditions.AddCondition()
      cond.tableIndex=3
      cond.condVal=JDT
      cond.colNum=OITR_INIT_OBJ_TYPE
      cond.operation=DBD_EQ
      sboErr=DBD_GetInNewFormat(dagJDT1,&dagRes)
      if sboErr
         if sboErr==dbmNoDataFound
            sboErr=noErr

         end

         return sboErr

      end






      numOfRecon=dagRes.GetRecordCount()

      dagUpdate=OpenDAG(JDT,ao_Arr1)
      i=0
      begin
         tables[0].tableCode=bizEnv.ObjectToTable(JDT,ao_Arr1)
         DBD_SetTablesList(dagUpdate,tables,1)
         updStruct[0].Clear()
         updStruct[0].colNum=JDT1_BALANCE_DUE_DEBIT
         updStruct[0].srcColNum=JDT1_DEBIT
         updStruct[0].SetUpdateColSource(DBD_UpdStruct::ucs_SrcCol)
         updStruct[1].Clear()
         updStruct[1].colNum=JDT1_BALANCE_DUE_FC_DEB
         updStruct[1].srcColNum=JDT1_FC_DEBIT
         updStruct[1].SetUpdateColSource(DBD_UpdStruct::ucs_SrcCol)
         updStruct[2].Clear()
         updStruct[2].colNum=JDT1_BALANCE_DUE_SC_DEB
         updStruct[2].srcColNum=JDT1_SYS_DEBIT
         updStruct[2].SetUpdateColSource(DBD_UpdStruct::ucs_SrcCol)
         updStruct[3].Clear()
         updStruct[3].colNum=JDT1_BALANCE_DUE_CREDIT
         updStruct[3].srcColNum=JDT1_CREDIT
         updStruct[3].SetUpdateColSource(DBD_UpdStruct::ucs_SrcCol)
         updStruct[4].Clear()
         updStruct[4].colNum=JDT1_BALANCE_DUE_FC_CRED
         updStruct[4].srcColNum=JDT1_FC_CREDIT
         updStruct[4].SetUpdateColSource(DBD_UpdStruct::ucs_SrcCol)
         updStruct[5].Clear()
         updStruct[5].colNum=JDT1_BALANCE_DUE_SC_CRED
         updStruct[5].srcColNum=JDT1_SYS_CREDIT
         updStruct[5].SetUpdateColSource(DBD_UpdStruct::ucs_SrcCol)
         DBD_SetDAGUpd(dagUpdate,updStruct,6)
         condStruct[0].Clear()
         condStruct[0].tableIndex=0
         condStruct[0].colNum=JDT1_TRANS_ABS
         dagRes.GetColStr(condStruct[0].condVal,CPE_RES_TRANS_ID,i)
         condStruct[0].operation=DBD_EQ
         condStruct[0].relationship=DBD_AND
         condStruct[1].Clear()
         condStruct[1].tableIndex=0
         condStruct[1].colNum=JDT1_LINE_ID
         dagRes.GetColStr(condStruct[1].condVal,CPE_RES_TRANS_LINE_ID,i)
         condStruct[1].operation=DBD_EQ
         DBD_SetDAGCond(dagUpdate,condStruct,2)
         sboErr=DBD_UpdateCols(dagUpdate)
         if sboErr&&sboErr!=dbmNoDataFound
            return sboErr

         end

         dagUpdate.ClearQueryParams()


         i+=1
      end while (i<numOfRecon)

      i=0
      begin
         dagRes.GetColLong(&srcObjTyp,4,i)
         if srcObjTyp==CLOSE_BLNC_TYPE
            tables[0].tableCode=bizEnv.ObjectToTable(ITR,ao_Arr1)
            tables[1].tableCode=bizEnv.ObjectToTable(JDT,ao_Arr1)
            tables[1].doJoin=false
            DBD_SetTablesList(dagUpdate,tables,2)
            updStruct[0].Clear()
            updStruct[0].colNum=ITR1_TRANS_LINE_ID
            updStruct[0].updateVal=0L
            updStruct[0].SetUpdateColSource(DBD_UpdStruct::ucs_Orig)
            updStruct[1].Clear()
            updStruct[1].colNum=ITR1_IS_CREDIT
            updStruct[1].srcColNum=JDT1_DEBIT_CREDIT
            updStruct[1].SetUpdateColSource(DBD_UpdStruct::ucs_UseRes)
            pResCol=updStruct[1].GetResObject().AddResCol()
            pResCol.SetTableIndex(1)
            pResCol.SetColNum(JDT1_DEBIT_CREDIT)
            updStruct[2].Clear()
            updStruct[2].colNum=ITR1_SHORT_NAME
            updStruct[2].srcColNum=JDT1_SHORT_NAME
            updStruct[2].SetUpdateColSource(DBD_UpdStruct::ucs_UseRes)
            pResCol=updStruct[2].GetResObject().AddResCol()
            pResCol.SetTableIndex(1)
            pResCol.SetColNum(JDT1_SHORT_NAME)
            updStruct[3].Clear()
            updStruct[3].colNum=ITR1_ACCT_NUM
            updStruct[3].srcColNum=JDT1_ACCT_NUM
            updStruct[3].SetUpdateColSource(DBD_UpdStruct::ucs_UseRes)
            pResCol=updStruct[3].GetResObject().AddResCol()
            pResCol.SetTableIndex(1)
            pResCol.SetColNum(JDT1_ACCT_NUM)
            DBD_SetDAGUpd(dagUpdate,updStruct,4)
            condStruct[0].Clear()
            condStruct[0].tableIndex=1
            condStruct[0].colNum=JDT1_TRANS_ABS
            dagRes.GetColStr(condStruct[0].condVal,CPE_RES_TRANS_ID,i)
            condStruct[0].operation=DBD_EQ
            condStruct[0].relationship=DBD_AND
            condStruct[1].Clear()
            condStruct[1].tableIndex=1
            condStruct[1].colNum=JDT1_LINE_ID
            condStruct[1].condVal=0L
            condStruct[1].operation=DBD_EQ
            condStruct[1].relationship=DBD_AND
            condStruct[2].Clear()
            condStruct[2].tableIndex=0
            condStruct[2].colNum=ITR1_RECON_NUM
            dagRes.GetColStr(condStruct[2].condVal,CPE_RES_RECON_NUM,i)
            condStruct[2].operation=DBD_EQ
            condStruct[2].relationship=DBD_AND
            condStruct[3].Clear()
            condStruct[3].tableIndex=0
            condStruct[3].colNum=ITR1_LINE_SEQUENCE
            dagRes.GetColStr(condStruct[3].condVal,CPE_RES_LINE_SEQUENCE,i)
            condStruct[3].operation=DBD_EQ
            DBD_SetDAGCond(dagUpdate,condStruct,4)
            sboErr=DBD_UpdateCols(dagUpdate)
            if sboErr&&sboErr!=dbmNoDataFound
               return sboErr

            end

            dagUpdate.ClearQueryParams()

         end



         i+=1
      end while (i<numOfRecon)

      i=0
      begin
         dagRes.GetColLong(&srcObjTyp,4,i)
         if srcObjTyp==OPEN_BLNC_TYPE
            tables[0].tableCode=bizEnv.ObjectToTable(ITR,ao_Arr1)
            tables[1].tableCode=bizEnv.ObjectToTable(JDT,ao_Arr1)
            tables[1].doJoin=false
            DBD_SetTablesList(dagUpdate,tables,2)
            updStruct[0].Clear()
            updStruct[0].colNum=ITR1_TRANS_LINE_ID
            updStruct[0].updateVal=1L
            updStruct[0].SetUpdateColSource(DBD_UpdStruct::ucs_Orig)
            updStruct[1].Clear()
            updStruct[1].colNum=ITR1_IS_CREDIT
            updStruct[1].srcColNum=JDT1_DEBIT_CREDIT
            updStruct[1].SetUpdateColSource(DBD_UpdStruct::ucs_UseRes)
            pResCol=updStruct[1].GetResObject().AddResCol()
            pResCol.SetTableIndex(1)
            pResCol.SetColNum(JDT1_DEBIT_CREDIT)
            updStruct[2].Clear()
            updStruct[2].colNum=ITR1_SHORT_NAME
            updStruct[2].srcColNum=JDT1_SHORT_NAME
            updStruct[2].SetUpdateColSource(DBD_UpdStruct::ucs_UseRes)
            pResCol=updStruct[2].GetResObject().AddResCol()
            pResCol.SetTableIndex(1)
            pResCol.SetColNum(JDT1_SHORT_NAME)
            updStruct[3].Clear()
            updStruct[3].colNum=ITR1_ACCT_NUM
            updStruct[3].srcColNum=JDT1_ACCT_NUM
            updStruct[3].SetUpdateColSource(DBD_UpdStruct::ucs_UseRes)
            pResCol=updStruct[3].GetResObject().AddResCol()
            pResCol.SetTableIndex(1)
            pResCol.SetColNum(JDT1_ACCT_NUM)
            DBD_SetDAGUpd(dagUpdate,updStruct,4)
            condStruct[0].Clear()
            condStruct[0].tableIndex=1
            condStruct[0].colNum=JDT1_TRANS_ABS
            dagRes.GetColStr(condStruct[0].condVal,CPE_RES_TRANS_ID,i)
            condStruct[0].operation=DBD_EQ
            condStruct[0].relationship=DBD_AND
            condStruct[1].Clear()
            condStruct[1].tableIndex=1
            condStruct[1].colNum=JDT1_LINE_ID
            condStruct[1].condVal=1L
            condStruct[1].operation=DBD_EQ
            condStruct[1].relationship=DBD_AND
            condStruct[2].Clear()
            condStruct[2].tableIndex=0
            condStruct[2].colNum=ITR1_RECON_NUM
            dagRes.GetColStr(condStruct[2].condVal,CPE_RES_RECON_NUM,i)
            condStruct[2].operation=DBD_EQ
            condStruct[2].relationship=DBD_AND
            condStruct[3].Clear()
            condStruct[3].tableIndex=0
            condStruct[3].colNum=ITR1_LINE_SEQUENCE
            dagRes.GetColStr(condStruct[3].condVal,CPE_RES_LINE_SEQUENCE,i)
            condStruct[3].operation=DBD_EQ
            DBD_SetDAGCond(dagUpdate,condStruct,4)
            sboErr=DBD_UpdateCols(dagUpdate)
            if sboErr&&sboErr!=dbmNoDataFound
               return sboErr

            end

            dagUpdate.ClearQueryParams()

         end



         i+=1
      end while (i<numOfRecon)

      i=0
      begin
         tables[0].tableCode=bizEnv.ObjectToTable(ITR,ao_Main)
         tables[1].tableCode=bizEnv.ObjectToTable(ITR,ao_Arr1)
         tables[1].doJoin=false
         tables[2].tableCode=bizEnv.ObjectToTable(JDT,ao_Arr1)
         tables[2].doJoin=false
         DBD_SetTablesList(dagUpdate,tables,3)
         updStruct[0].Clear()
         updStruct[0].colNum=OITR_IS_CARD
         updStruct[0].updateVal=VAL_CARD
         updStruct[0].SetUpdateColSource(DBD_UpdStruct::ucs_Orig)
         DBD_SetDAGUpd(dagUpdate,updStruct,1)
         condStruct[0].Clear()
         condStruct[0].tableIndex=0
         condStruct[0].colNum=OITR_RECON_NUM
         dagRes.GetColStr(condStruct[0].condVal,CPE_RES_RECON_NUM,i)
         condStruct[0].operation=DBD_EQ
         condStruct[0].relationship=DBD_AND
         condStruct[1].Clear()
         condStruct[1].tableIndex=0
         condStruct[1].colNum=OITR_RECON_NUM
         condStruct[1].compareCols=true
         condStruct[1].compTableIndex=1
         condStruct[1].compColNum=ITR1_RECON_NUM
         condStruct[1].operation=DBD_EQ
         condStruct[1].relationship=DBD_AND
         condStruct[2].Clear()
         condStruct[2].tableIndex=1
         condStruct[2].colNum=ITR1_LINE_SEQUENCE
         condStruct[2].condVal=0L
         condStruct[2].operation=DBD_EQ
         condStruct[2].relationship=DBD_AND
         condStruct[3].Clear()
         condStruct[3].tableIndex=1
         condStruct[3].colNum=ITR1_TRANS_ID
         condStruct[3].compareCols=true
         condStruct[3].compTableIndex=2
         condStruct[3].compColNum=JDT1_TRANS_ABS
         condStruct[3].operation=DBD_EQ
         condStruct[3].relationship=DBD_AND
         condStruct[4].Clear()
         condStruct[4].tableIndex=1
         condStruct[4].colNum=ITR1_TRANS_LINE_ID
         condStruct[4].compareCols=true
         condStruct[4].compTableIndex=2
         condStruct[4].compColNum=JDT1_LINE_ID
         condStruct[4].operation=DBD_EQ
         condStruct[4].relationship=DBD_AND
         condStruct[5].Clear()
         condStruct[5].tableIndex=2
         condStruct[5].colNum=JDT1_SHORT_NAME
         condStruct[5].compareCols=true
         condStruct[5].compTableIndex=2
         condStruct[5].compColNum=JDT1_ACCT_NUM
         condStruct[5].operation=DBD_NE
         DBD_SetDAGCond(dagUpdate,condStruct,6)
         sboErr=DBD_UpdateCols(dagUpdate)
         if sboErr&&sboErr!=dbmNoDataFound
            return sboErr

         end

         dagUpdate.ClearQueryParams()


         i+=1
      end while (i<numOfRecon)

      i=0
      begin
         tables[0].tableCode=bizEnv.ObjectToTable(ITR,ao_Main)
         tables[1].tableCode=bizEnv.ObjectToTable(ITR,ao_Arr1)
         tables[1].doJoin=false
         DBD_SetTablesList(dagUpdate,tables,2)
         updStruct[0].Clear()
         updStruct[0].colNum=OITR_RECON_CURRENCY
         updStruct[0].srcColNum=ITR1_FRGN_CURRENCY
         updStruct[0].SetUpdateColSource(DBD_UpdStruct::ucs_UseRes)
         pResCol=updStruct[0].GetResObject().AddResCol()
         pResCol.SetTableIndex(1)
         pResCol.SetColNum(ITR1_FRGN_CURRENCY)
         updStruct[1].Clear()
         updStruct[1].colNum=OITR_TOTAL
         updStruct[1].srcColNum=ITR1_RECON_SUM_FC
         updStruct[1].SetUpdateColSource(DBD_UpdStruct::ucs_UseRes)
         pResCol=updStruct[1].GetResObject().AddResCol()
         pResCol.SetTableIndex(1)
         pResCol.SetColNum(ITR1_RECON_SUM_FC)
         DBD_SetDAGUpd(dagUpdate,updStruct,2)
         condStruct[0].Clear()
         condStruct[0].tableIndex=0
         condStruct[0].colNum=OITR_RECON_NUM
         dagRes.GetColStr(condStruct[0].condVal,CPE_RES_RECON_NUM,i)
         condStruct[0].operation=DBD_EQ
         condStruct[0].relationship=DBD_AND
         condStruct[1].Clear()
         condStruct[1].tableIndex=0
         condStruct[1].colNum=OITR_RECON_NUM
         condStruct[1].compareCols=true
         condStruct[1].compTableIndex=1
         condStruct[1].compColNum=ITR1_RECON_NUM
         condStruct[1].operation=DBD_EQ
         condStruct[1].relationship=DBD_AND
         condStruct[2].Clear()
         condStruct[2].tableIndex=1
         condStruct[2].colNum=ITR1_LINE_SEQUENCE
         condStruct[2].condVal=0L
         condStruct[2].operation=DBD_EQ
         condStruct[2].relationship=DBD_AND
         condStruct[3].Clear()
         condStruct[3].tableIndex=1
         condStruct[3].colNum=ITR1_FRGN_CURRENCY
         condStruct[3].operation=DBD_NOT_NULL
         condStruct[3].relationship=DBD_AND
         condStruct[4].Clear()
         condStruct[4].tableIndex=1
         condStruct[4].colNum=ITR1_FRGN_CURRENCY
         condStruct[4].condVal=EMPTY_STR
         condStruct[4].operation=DBD_NE
         DBD_SetDAGCond(dagUpdate,condStruct,5)
         sboErr=DBD_UpdateCols(dagUpdate)
         if sboErr&&sboErr!=dbmNoDataFound
            return sboErr

         end

         dagUpdate.ClearQueryParams()


         i+=1
      end while (i<numOfRecon)

      i=0
      begin
         tables[0].tableCode=bizEnv.ObjectToTable(ITR,ao_Arr1)
         DBD_SetTablesList(dagUpdate,tables,1)
         updStruct[0].Clear()
         updStruct[0].colNum=ITR1_SUM_IN_MATCH_CURR
         updStruct[0].srcColNum=ITR1_RECON_SUM_FC
         updStruct[0].SetUpdateColSource(DBD_UpdStruct::ucs_SrcCol)
         DBD_SetDAGUpd(dagUpdate,updStruct,1)
         condStruct[0].Clear()
         condStruct[0].tableIndex=0
         condStruct[0].colNum=ITR1_RECON_NUM
         dagRes.GetColStr(condStruct[0].condVal,CPE_RES_RECON_NUM,i)
         condStruct[0].operation=DBD_EQ
         condStruct[0].relationship=DBD_AND
         condStruct[1].Clear()
         condStruct[1].tableIndex=0
         condStruct[1].colNum=ITR1_FRGN_CURRENCY
         condStruct[1].operation=DBD_NOT_NULL
         condStruct[1].relationship=DBD_AND
         condStruct[2].Clear()
         condStruct[2].tableIndex=0
         condStruct[2].colNum=ITR1_FRGN_CURRENCY
         condStruct[2].condVal=EMPTY_STR
         condStruct[2].operation=DBD_NE
         DBD_SetDAGCond(dagUpdate,condStruct,3)
         sboErr=DBD_UpdateCols(dagUpdate)
         if sboErr&&sboErr!=dbmNoDataFound
            return sboErr

         end

         dagUpdate.ClearQueryParams()


         i+=1
      end while (i<numOfRecon)

      i=0
      begin
         tables[0].tableCode=bizEnv.ObjectToTable(JDT,ao_Arr1)
         tables[1].tableCode=bizEnv.ObjectToTable(ITR,ao_Arr1)
         tables[1].doJoin=false
         DBD_SetTablesList(dagUpdate,tables,2)
         updStruct[0].Clear()
         updStruct[0].colNum=JDT1_BALANCE_DUE_DEBIT
         updStruct[0].updateVal=0L
         updStruct[1].Clear()
         updStruct[1].colNum=JDT1_BALANCE_DUE_FC_DEB
         updStruct[1].updateVal=0L
         updStruct[2].Clear()
         updStruct[2].colNum=JDT1_BALANCE_DUE_SC_DEB
         updStruct[2].updateVal=0L
         updStruct[3].Clear()
         updStruct[3].colNum=JDT1_BALANCE_DUE_CREDIT
         updStruct[3].updateVal=0L
         updStruct[4].Clear()
         updStruct[4].colNum=JDT1_BALANCE_DUE_FC_CRED
         updStruct[4].updateVal=0L
         updStruct[5].Clear()
         updStruct[5].colNum=JDT1_BALANCE_DUE_SC_CRED
         updStruct[5].updateVal=0L
         DBD_SetDAGUpd(dagUpdate,updStruct,6)
         condStruct[0].Clear()
         condStruct[0].tableIndex=1
         condStruct[0].colNum=ITR1_RECON_NUM
         dagRes.GetColStr(condStruct[0].condVal,CPE_RES_RECON_NUM,i)
         condStruct[0].operation=DBD_EQ
         condStruct[0].relationship=DBD_AND
         condStruct[1].Clear()
         condStruct[1].tableIndex=0
         condStruct[1].colNum=JDT1_TRANS_ABS
         condStruct[1].compareCols=true
         condStruct[1].compTableIndex=1
         condStruct[1].compColNum=ITR1_TRANS_ID
         condStruct[1].operation=DBD_EQ
         condStruct[1].relationship=DBD_AND
         condStruct[2].Clear()
         condStruct[2].tableIndex=0
         condStruct[2].colNum=JDT1_LINE_ID
         condStruct[2].compareCols=true
         condStruct[2].compTableIndex=1
         condStruct[2].compColNum=ITR1_TRANS_LINE_ID
         condStruct[2].operation=DBD_EQ
         DBD_SetDAGCond(dagUpdate,condStruct,3)
         sboErr=DBD_UpdateCols(dagUpdate)
         if sboErr&&sboErr!=dbmNoDataFound
            return sboErr

         end

         dagUpdate.ClearQueryParams()


         i+=1
      end while (i<numOfRecon)

      return noErr

   end

   def CostAccountingAssignmentCheck(bizObject)
      sboErr=noErr





      bizEnv=bizObject.GetEnv()

      costAccountingRelevantFields=""

      costAccountingFields=""

      dagACT=bizObject.GetDAG(ACT,ao_Main)
      dagJDT1=bizObject.GetDAG(JDT,ao_Arr1)
      numOfRecs=dagJDT1.GetRealSize(dbmDataBuffer)
      i=0

      begin
         if bizEnv.IsCostAccountingBlocked(i)
            rec=0

            begin
               dagJDT1.GetColStr(accountCode,JDT1_ACCT_NUM,rec)
               sboErr=bizEnv.GetByOneKey(dagACT,OACT_KEYNUM_PRIMARY,accountCode,true)
               if sboErr
                  if sboErr==dbmNoDataFound
                     return ooInvalidObject

                  else
                     return sboErr

                  end


               end

               dagACT.GetColStr(costAccountRelevant,costAccountingRelevantFields[i],0)
               dagJDT1.GetColStr(costAccountingField,costAccountingFields[i],rec)
               costAccountingField.Trim()
               if !costAccountRelevant.Compare(VAL_YES)&&(costAccountingField.IsEmpty()||costAccountingField.IsNull())
                  sboErr=bizEnv.GetAccountSegmentsByCode(accountCode,accountFormat,true)
                  IF_ERROR_RETURN(sboErr)
                  if i
                     CMessagesManager::GetHandle().Message(_54_APP_MSG_FIN_NEED_DISTRIBUTION_RULE,EMPTY_STR,bizObject,accountFormat,i)

                  else
                     CMessagesManager::GetHandle().Message(_54_APP_MSG_FIN_NEED_PROJECT_ASSIGNMENT,EMPTY_STR,bizObject,accountFormat)

                  end

                  return ooInvalidObject

               end



               rec+=1
            end while (rec<numOfRecs)


         end



         i+=1
      end while (i<1+)

      return sboErr

   end

   def SetReconAcct(isInCancellingAcctRecon, acct)
      m_isInCancellingAcctRecon=isInCancellingAcctRecon
      if m_reconAcctSet.find(acct)==m_reconAcctSet.end()
         m_reconAcctSet.insert(acct)

      end

      return

   end

   def LogBPAccountBalance(bpBalanceLogDataArray, keyNum)
      size=bpBalanceLogDataArray.size()

      dagCRD=GetDAG(CRD)

      ooErr=noErr


      i=0

      begin
         bpBalanceChangeLogData=bpBalanceLogDataArray[i]

         ooErr=GetEnv().GetByOneKey(dagCRD,GO_PRIMARY_KEY_NUM,bpBalanceChangeLogData.GetCode(),true)
         if ooErr
            return

         end

         dagCRD.GetColMoney(&tempMoney,OCRD_CURRENT_BALANCE)
         bpBalanceChangeLogData.SetNewAcctBalanceLC(tempMoney)
         dagCRD.GetColMoney(&tempMoney,OCRD_F_BALANCE)
         bpBalanceChangeLogData.SetNewAcctBalanceFC(tempMoney)
         bpBalanceChangeLogData.SetKeyNum(keyNum)
         bpBalanceChangeLogData.Log()


         i+=1
      end while (i<size)


   end

   def IsManualJE(dagJDT)
      _TRACER("IsManualJE")
      result=false


      dagJDT.GetColStr(transType,OJDT_TRANS_TYPE,0)
      transType.Trim()
      return ((transType.CompareNoCase(SBOString(JDT))==0)||(transType.CompareNoCase(SBOString(NONE_CHOICE))==0))

   end

   def IsCardLine(rec)

      dagJDT1=GetArrayDAG(ao_Arr1)
      if !DAG_IsValid(dagJDT1)


      end


      recCount=dagJDT1.GetRealSize(dbmDataBuffer)
      if rec<0L||rec>=recCount


      end



      ooErr=dagJDT1.GetColStr(accountNumber,JDT1_ACCT_NUM,rec,false,true)
      IF_ERROR_THROW(ooErr)
      ooErr=dagJDT1.GetColStr(shortName,JDT1_SHORT_NAME,rec,false,true)
      IF_ERROR_THROW(ooErr)
      accountNumber.Trim()
      shortName.Trim()
      return (accountNumber!=shortName&&!shortName.IsEmpty())

   end

   def ContainsCardLine()

      dagJDT1=GetArrayDAG(ao_Arr1)
      if !DAG_IsValid(dagJDT1)


      end


      recCount=dagJDT1.GetRealSize(dbmDataBuffer)
      rec=0L

      begin
         if IsCardLine(rec)
            return true

         end



         +=1rec
      end while (rec<recCount)

      return false

   end

   def InitDataReport340(dagJDT)
      _TRACER("InitDataReport340")
      sboErr=ooNoErr

      bizEnv=GetEnv()

      if GetDataSource()==*VAL_OBSERVER_SOURCE
         dagJDT.NullifyCol(OJDT_RESIDENCE_NUM,0)

      end

      return sboErr

   end

   def CompleteReport340(dagJDT, dagJDT1)
      _TRACER("CompleteReport340")
      sboErr=ooNoErr

      bizEnv=GetEnv()

      dagCRD=GetDAG(CRD)




      if GetDataSource()==*VAL_OBSERVER_SOURCE
         dagJDT.GetColStr(residenNum,OJDT_RESIDENCE_NUM,0)
         if residenNum.GetLength()<=0
            atLeasOneBPFound=false
            if IsManualJE(dagJDT)==true
               numOfRecs=dagJDT1.GetRealSize(dbmDataBuffer)
               if numOfRecs>0
                  rec=0

                  begin
                     dagJDT1.GetColStr(account,JDT1_ACCT_NUM,rec)
                     dagJDT1.GetColStr(shortName,JDT1_SHORT_NAME,rec)
                     if account.CompareNoCase(shortName)!=0
                        if bizEnv.GetByOneKey(dagCRD,OCRD_KEYNUM_PRIMARY,shortName,true)==ooNoErr
                           dagCRD.GetColStr(residenNum,OCRD_RESIDENCE_NUM,0)
                           dagJDT.SetColStr(residenNum,OJDT_RESIDENCE_NUM,0)
                           dagJDT.SetColStr(residenNum,OJDT_RESIDENCE_NUM,0,true,true)
                           atLeasOneBPFound=true
                           break

                        end


                     end



                     rec+=1
                  end while (rec<numOfRecs)


               end


            end

            if atLeasOneBPFound==false
               dagJDT.GetDefaultValue(OJDT_RESIDENCE_NUM,residenNum)
               dagJDT.SetColStr(residenNum,OJDT_RESIDENCE_NUM,0)
               dagJDT.SetColStr(residenNum,OJDT_RESIDENCE_NUM,0,true,true)

            end


         end


      end

      return sboErr

   end

   def ValidateReport340()
      _TRACER("ValidateReport340")
      sboErr=ooNoErr

      bizEnv=GetEnv()

      dagJDT=GetDAG()


      if GetCurrentBusinessFlow()==bf_Create
         return sboErr

      end

      dagJDT.GetColStr(residenNumOrig,OJDT_RESIDENCE_NUM,0,true,true)
      dagJDT.GetColStr(residenNumNew,OJDT_RESIDENCE_NUM,0)
      if residenNumOrig.GetLength()>0&&residenNumOrig.Compare(residenNumNew)!=0&&IsManualJE(dagJDT)==false
         SetErrorField(OJDT_RESIDENCE_NUM)
         Message(GO_OBJ_ERROR_MSGS(JDT),JDT_340_REPORT_RESIDENNUM_CHNG_ERR,NULL,OO_ERROR)
         return ooInvalidObject

      end

      dagJDT.GetColStr(operatCodeOrig,OJDT_OPERATION_CODE,0,true,true)
      dagJDT.GetColStr(operatCodeNew,OJDT_OPERATION_CODE,0)
      if operatCodeOrig.GetLength()>0&&operatCodeOrig.Compare(operatCodeNew)!=0&&IsManualJE(dagJDT)==false
         SetErrorField(OJDT_OPERATION_CODE)
         Message(GO_OBJ_ERROR_MSGS(JDT),JDT_340_REPORT_OPERATCODE_CHNG_ERR,NULL,OO_ERROR)
         return ooInvalidObject

      end

      return sboErr

   end

   def OJDTGetRate(bizObject, curSource, rate)



      dagJDT=bizObject.GetDAG()

      dagJDT.GetColLong(&transType,OJDT_TRANS_TYPE)
      if transType==TRT||transType==RCR
         *rate=1L

      else
         case curSource

         when JDT_SYSTEM_CURRENCY
            _STR_strcpy(currency,bizObject.GetEnv().GetSystemCurrency())

         when JDT_CARD_CURRENCY
            _STR_strcpy(currency,bizObject.GetEnv().GetMainCurrency())


         end

         dagJDT.GetColStr(postingDate,OJDT_REF_DATE)
         TZGetAndWaitUntilRate(currency,postingDate,rate,TRUE,bizObject.GetEnv())

      end


   end

   def HandleFCExchangeRounding(dagJDT1, StdMap<SBOString, FCRoundingStruct, False, currencyMap)



      (-1)


      size=dagJDT1.GetRecordCount()
      idx=0
      begin
         debit.FromDAG(dagJDT1,idx,JDT1_DEBIT,JDT1_FC_DEBIT,JDT1_SYS_DEBIT)
         credit.FromDAG(dagJDT1,idx,JDT1_CREDIT,JDT1_FC_CREDIT,JDT1_SYS_CREDIT)
         dagJDT1.GetColStr(currency,JDT1_FC_CURRENCY,idx)
         dagJDT1.GetColStr(vatLine,JDT1_VAT_LINE,idx)
         vatLine.Trim()
         currency.Trim()
         if !currency.IsEmpty()&&(debit.GetFcSum()!=0||credit.GetFcSum()!=0)
            currencyMap.Lookup(currency,roundingStruct)
            if vatLine!=VAL_YES
               roundingStruct.lastNonZeroFCLine=idx

            end

            roundingStruct.totalDebitMinusCredit+=(debit-)
            currencyMap[currency]=roundingStruct

         end

         totalDebitMinusCredit+=(debit-)


         idx+=1
      end while (idx<size)

      if totalDebitMinusCredit.GetLcSum()==0&&totalDebitMinusCredit.GetScSum()==0
         return ooNoErr

      end

      StdMap

   end

   def UpgradeFederalTaxIdOnJERow()
      bizEnv=GetEnv()

      def stmt
         (bizEnv)
      end




      try
      tJDT1=stmt.From(bizEnv.ObjectToTable(JDT

      tOCRD=stmt.Join(bizEnv.ObjectToTable(CRD

      stmt.On(tOCRD).Col(tJDT1,JDT1_SHORT_NAME).EQ().Col(tOCRD,OCRD_CARD_CODE)
      tCRD1=stmt.Join(bizEnv.ObjectToTable(CRD

      stmt.On(tCRD1).Col(tOCRD,OCRD_CARD_CODE).EQ().Col(tCRD1,CRD1_CARD_CODE).And().Col(tOCRD,OCRD_SHIP_TO_DEFAULT).EQ().Col(tCRD1,CRD1_ADDRESS_NAME)
      stmt.Select().Col(tOCRD,OCRD_CARD_CODE)
      stmt.Select().Col(tOCRD,OCRD_CARD_TYPE)
      stmt.Select().Col(tOCRD,OCRD_TAX_ID_NUMBER).As(JE_TAX_ID_ON_HEADER_ALIAS)
      stmt.Select().Col(tCRD1,CRD1_TAX_ID_NUMBER).As(JE_TAX_ID_ON_LINE_ALIAS)
      stmt.Distinct()
      stmt.Where().Col(tJDT1,JDT1_ACCT_NUM).NE().Col(tJDT1,JDT1_SHORT_NAME).And().Col(tJDT1,JDT1_TRANS_TYPE).EQ().Val(JDT).And().OpenBracket().Col(tOCRD,OCRD_TAX_ID_NUMBER).IsNotNull().Or().Col(tCRD1,CRD1_TAX_ID_NUMBER).IsNotNull().CloseBracket()
      countRes=stmt.Execute(dagRes)

      catch(DBMException&e)
      return e.GetCode()

      ii=0

      begin
         crdTaxID=EMPTY_STR
         dagRes.GetColStr(cardCode,dagRes.GetColumnByAlias(OCRD_CARD_CODE_ALIAS),ii)
         dagRes.GetColStr(cardType,dagRes.GetColumnByAlias(OCRD_CARD_TYPE_ALIAS),ii)
         cardCode.Trim()
         cardType.Trim()
         if cardType==VAL_CUSTOMER&&!GetEnv().IsLatinAmericaTaxSystem()
            dagRes.GetColStr(crdTaxID,dagRes.GetColumnByAlias(JE_TAX_ID_ON_LINE_ALIAS),ii)

         end

         if crdTaxID.IsSpacesStr()
            dagRes.GetColStr(crdTaxID,dagRes.GetColumnByAlias(JE_TAX_ID_ON_HEADER_ALIAS),ii)

         end

         crdTaxID.Trim()
         def ustmt
            (bizEnv)
         end

         try
         tJDT1=ustmt.Update(bizEnv.ObjectToTable(JDT

         ustmt.Set(JDT1_TAX_ID_NUMBER).Val(crdTaxID)
         ustmt.Where().Col(tJDT1,JDT1_ACCT_NUM).NE().Col(tJDT1,JDT1_SHORT_NAME).And().Col(tJDT1,JDT1_SHORT_NAME).EQ().Val(cardCode).And().Col(tJDT1,JDT1_TRANS_TYPE).EQ().Val(JDT)
         ustmt.Execute()

         catch(DBMException&e)
         return e.GetCode()



         ii+=1
      end while (ii<countRes)


      objArray=""

      objNum=0

      begin
         def ustmt
            (bizEnv)
         end

         try
         tJDT1=ustmt.Update(bizEnv.ObjectToTable(JDT

         tOINV=ustmt.Update(bizEnv.ObjectToTable(objArray[objNum]

         ustmt.Set(JDT1_TAX_ID_NUMBER).Col(tOINV,OINV_TAX_ID_NUMBER)
         ustmt.Where().Col(tOINV,OINV_TRANS_NUM).EQ().Col(tJDT1,JDT1_TRANS_ABS).And().Col(tJDT1,JDT1_ACCT_NUM).NE().Col(tJDT1,JDT1_SHORT_NAME).And().Col(tOINV,OINV_CARD_CODE).EQ().Col(tJDT1,JDT1_SHORT_NAME)
         ustmt.Execute()

         catch(DBMException&e)
         return e.GetCode()



         objNum+=1
      end while (objArray[objNum]!=NOB)


      return noErr

   end

   def UpgradeDprId(isSalesObject, introVersion1_Including, introVersion2)
      sboErr=ooNoErr

      env=GetEnv()

      paymentObjType=isSalesObject


   end

   def UpdateDprIdOnJERow(paymentObjType, dagRES)
      sboErr=ooNoErr

      env=GetEnv()

      countRes=dagRES.GetRealSize(dbmDataBuffer)

      rec=0

      begin



      end while (rec)


   end

   def UpgradeDprIdForOneDprPayment(isSalesObject, introVersion)
      sboErr=ooNoErr

      env=GetEnv()

      paymentObjType=isSalesObject


   end

   def OnGetByKey()
      ooErr=ooNoErr

      dagJDT=NULL
      dagJDT1 = NULL
      dagCFT = NULL

      bizEnv=GetEnv()

      ooErr=CSystemBusinessObject::OnGetByKey()
      if ooErr&&ooErr!=dbmArrayRecordNotFound
         return ooErr

      end

      dagJDT=GetDAG()
      dagJDT1=GetDAG(JDT,ao_Arr1)

      dagJDT.GetColStr(transID,OJDT_JDT_NUM,0)

      res=0

      try
      if VF_CashflowReport(bizEnv)
         def objID
            (CFT)
         end

         dagCFT=GetDAG(objID)
         def stmtCFT
            (bizEnv)
         end

         tOCFT=stmtCFT.From(bizEnv.ObjectToTable(CFT))

         stmtCFT.Where().Col(tOCFT,OCFT_JDT_ID).EQ().Val(transID).And().Col(tOCFT,OCFT_STATUS).NE().Val(CFT_STATUS_CREDSUM)
         res=stmtCFT.Execute(dagRes)
         dagCFT.Copy(dagRes,dbmBothBuffers)

      end


      catch(DBMException&e)
      return e.GetCode()

      ooErr=LoadTax()
      if ooErr
         return ooErr

      end

      return ooErr

   end

   def OnGetCostAccountingFields(costAccountingFieldMap)


      costAccountingFields.projects.Add(OJDT_PROJECT)
      costAccountingFieldMap[ao_Main]=costAccountingFields
      costAccountingFields.projects.RemoveAll()
      costAccountingFields.projects.Add(JDT1_PROJECT)
      distrRule.Add(JDT1_OCR_CODE)
      distrRule.Add(JDT1_OCR_CODE2)
      distrRule.Add(JDT1_OCR_CODE3)
      distrRule.Add(JDT1_OCR_CODE4)
      distrRule.Add(JDT1_OCR_CODE5)
      costAccountingFields.distributionRules.Add(distrRule)
      costAccountingFieldMap[ao_Arr1]=costAccountingFields

   end

   def OJDTValidateCostAcountingStatus(bizObject, dagJDT)
      sboErr=noErr


      dagJDT1=bizObject.GetDAG(JDT,ao_Arr1)
      journalEntry=(CTransactionJournalObject*)

      bizObject.CreateBusinessObject(JDT)
      def jdtCleaner
         ((CBusinessObject*&))
      end
      journalEntry

   end

   def GetLinkMapMetaData(el)
      ooErr=CBusinessObjectBase::GetLinkMapMetaData(el)

      IF_ERROR_RETURN(ooErr)
      dagJDT=GetDAG()

      ooErr=AddLinkMapIconMetaData(el,dagJDT,OJDT_PRINTED,VAL_YES,LinkMap::ILMVertex::imdPrinted,LINKMAP_ICONSTR_PRINTED)
      IF_ERROR_RETURN(ooErr)
      ooErr=AddLinkMapStringMetaData(el,dagJDT,OJDT_NUMBER)
      IF_ERROR_RETURN(ooErr)
      ooErr=AddLinkMapStringMetaData(el,dagJDT,OJDT_REF_DATE)
      IF_ERROR_RETURN(ooErr)
      ooErr=AddLinkMapStringMetaData(el,dagJDT,OJDT_MEMO)
      IF_ERROR_RETURN(ooErr)
      return ooNoErr

   end

   def ReconcileDeferredTaxAcctLines()
      sboErr=ooNoErr

      bizEnv=GetEnv()

      dagJDT=GetDAG()

      dagJDT1=GetArrayDAG(ao_Arr1)






      dagJDT.GetColStr(stornoNum,OJDT_STORNO_TO_TRANS)
      if stornoNum.IsEmpty()||!bizEnv.IsLocalSettingsFlag(lsf_EnableDeferredTax)
         return ooNoErr

      end

      dagJDT.GetColStr(date,OJDT_REF_DATE)
      bizEnv.OpenDAG(dagStornoJDT1,JDT,ao_Arr1)
      sboErr=bizEnv.GetByOneKey(dagStornoJDT1,JDT1_KEYNUM_PRIMARY,stornoNum)
      IF_ERROR_RETURN(sboErr)
      def deferredMM
         (bizEnv,false,date.GetString(),JDT,stornoNum,rt_Reversal)
      end


      rec=0

      begin
         dagJDT1.GetColLong(&tmpL,JDT1_INTERIM_ACCT_TYPE,rec)
         interimType=(eInterimAcctType)
         tmpL
         if interimType==IAT_DeferTaxInterim_Type
            dagJDT1.GetColLong(&transId,JDT1_TRANS_ABS,rec)
            dagJDT1.GetColLong(&lineId,JDT1_LINE_ID,rec)
            deferredMM.AddMatchDataLine(transId,lineId)

         end



         +=1rec
      end while (rec<dagJDT1.GetRealSize(dbmDataBuffer))

      rec=0

      begin
         dagStornoJDT1.GetColLong(&tmpL,JDT1_INTERIM_ACCT_TYPE,rec)
         interimType=(eInterimAcctType)
         tmpL
         if interimType==IAT_DeferTaxInterim_Type
            sboErr=CManualMatchManager::CancelAllReconsOfJournalLine(bizEnv,stornoNum.strtol(),rec,false,date.GetString())
            IF_ERROR_RETURN(sboErr)
            dagStornoJDT1.GetColLong(&transId,JDT1_TRANS_ABS,rec)
            dagStornoJDT1.GetColLong(&lineId,JDT1_LINE_ID,rec)
            deferredMM.AddMatchDataLine(transId,lineId)

         end



         +=1rec
      end while (rec<dagStornoJDT1.GetRealSize(dbmDataBuffer))

      sboErr=deferredMM.Reconcile()
      return sboErr

   end

   def IsPaymentOrdered()
      dagJDT1=GetArrayDAG(ao_Arr1)

      numOfRecs=dagJDT1.GetRecordCount()

      i=0

      begin



      end while (i)


   end

   def IsPaymentOrdered(bizEnv, transId, isOrdered)
      ooErr=ooNoErr

      isOrdered=false
      try
      def stmt
         (bizEnv)
      end

      tJDT1=stmt.From(bizEnv.ObjectToTable(JDT

      stmt.Select().Count()
      stmt.Where().Col(tJDT1,JDT1_TRANS_ABS).EQ().Val(transId).And().Col(tJDT1,JDT1_ORDERED).EQ().Val(VAL_YES)

      numOfRecs=stmt.Execute(pResDag)

      if numOfRecs>=1
         isOrdered=true

      end


      catch(DBMException&e)
      ooErr=e.GetCode()
      return ooErr

      return ooNoErr

   end

   def IsScAdjustment(isScAdjustment)
      dagJDT1=GetArrayDAG(ao_Arr1)

      numOfRecs=dagJDT1.GetRecordCount()

      ooErr=noErr

      bizEnv=GetEnv()


      dagJDT1.GetColLong(&transID,JDT1_TRANS_ABS,0)
      isScAdjustment=false
      rec=0

      begin

         dagJDT1.GetColLong(&lineNum,JDT1_LINE_ID,rec)
         dagRes=NULL

         ooErr=CManualMatchManager::GetReconciliationByTransaction(bizEnv,transID,lineNum,&dagRes)
         if ooErr
            dagRes.Close()
            if ooErr=dbmNoDataFound
               ooErr=noErr
               next


            else
               return ooErr

            end


         end

         sizeOfRes=dagRes.GetRecordCount()


         i=0

         begin
            dagRes.GetColLong(&reconType,REC_RES_RECON_TYPE,i)
            if reconType==rt_ScAdjument
               isScAdjustment=true
               break

            end



            i+=1
         end while (i<sizeOfRes)

         dagRes.Close()
         if isScAdjustment
            break

         end



         rec+=1
      end while (rec<numOfRecs)

      return ooNoErr

   end

   def OnCommand(command)
      SetExCommand(ooExAutoMode,fa_SetSolo)
      SetExDtCommand(ooOBServerDT,fa_SetSolo)
      def odHelper
         (*this)
      end

      case command

      when JournalEntryDocumentTypeService_CmdCode_RefDateChange
         return odHelper.ODRefDateChange()

      when JournalEntryDocumentTypeService_CmdCode_MemoChange
         return odHelper.ODMemoChange()

      else
         return CSystemBusinessObject::OnCommand(command)

      end

      return noErr

   end

   def OnSetDynamicMetaData(commandCode)
      ooErr=noErr

      if commandCode==BusinessService_CmdCode_GetByParams||commandCode==BusinessService_CmdCode_Add
         headerFields=""

         i=0

         begin
            ooErr=SetDynamicMetaData(ao_Main,headerFields[i],false)


            +=1i
         end while (headerFields[i]>0)

         SetDynamicMetaData(ao_Arr1,JDT1_LINE_MEMO,true,-1)
         cols=""

         i=0

         begin
            ooErr=SetDynamicMetaData(ao_Arr1,cols[i],false,-1)


            +=1i
         end while (cols[i]>0)


      end

      SetBOActionMetaData(BusinessService_CmdCode_Cancel,OnCanCancel())
      return ooErr

   end


end
false
