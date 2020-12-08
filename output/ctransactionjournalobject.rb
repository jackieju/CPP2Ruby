class CTransactionJournalObject < CSystemBusinessObject
   include IReconcilable_module
   include IWithHoldingAble_module

   def ValidateRelations(arrOffset,rec,field,object,showError)
      trace("ValidateRelations")
      condStruct = []

      tableStruct = []

      dag = PDAG.new=GetDAG(JDT,arrOffset)
      bizEnv = CBizEnv.new=GetEnv()
      isVat = Boolean.new=false
      tmpStr = []
      =""
      accountNum = SBOString.new
      vatGroup = SBOString.new
      shortName = SBOString.new
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
               CMessagesManager.GetHandle().Message(_1_APP_MSG_FIN_TE_TAX_ACCOUNT_MISSING1,EMPTY_STR,bizEnv,vatGroup.GetBuffer())
               return ooInvalidObject
            end

            dag.GetColStr(shortName,JDT1_SHORT_NAME,rec)
            shortName.Trim()
            isVat=true
            condStruct[0].relationship=DBD_AND
            condStruct[condNum].bracketOpen=1
            condStruct[condNum].colNum=OVTG_ACCOUNT
            condStruct[condNum].condVal=shortName
            condStruct[condNum].operation=DBD_EQ
            condStruct[(condNum+=1;condNum-2)].relationship=DBD_OR
            condStruct[condNum].colNum=OVTG_EQU_VAT_ACCOUNT
            condStruct[condNum].condVal=shortName
            condStruct[condNum].operation=DBD_EQ
            condStruct[(condNum+=1;condNum-2)].relationship=DBD_OR
            condStruct[condNum].colNum=OVTG_DEFERRED_ACC
            condStruct[condNum].condVal=shortName
            condStruct[condNum].operation=DBD_EQ
            condStruct[(condNum+=1;condNum-2)].relationship=DBD_OR
            condStruct[condNum].colNum=OVTG_ACQSITION_TAX
            condStruct[condNum].condVal=shortName
            condStruct[condNum].operation=DBD_EQ
            condStruct[(condNum+=1;condNum-2)].relationship=DBD_OR
            condStruct[condNum].colNum=OVTG_NON_DEDUCT_ACC
            condStruct[condNum].condVal=shortName
            condStruct[condNum].operation=DBD_EQ
            condStruct[(condNum+=1;condNum-2)].relationship=DBD_OR
            condStruct[condNum].bracketOpen=1
            condStruct[condNum].colNum=OVTG_NON_DEDUCTIBLE
            condStruct[condNum].operation=DBD_NE
            _STR_strcpy(condStruct[condNum].condVal,STR_0)
            condStruct[(condNum+=1;condNum-2)].relationship=DBD_AND
            condStruct[condNum].bracketOpen=1
            condStruct[condNum].colNum=OVTG_NON_DEDUCT_ACC
            condStruct[condNum].operation=DBD_EQ
            condStruct[(condNum+=1;condNum-2)].relationship=DBD_OR
            condStruct[condNum].colNum=OVTG_NON_DEDUCT_ACC
            condStruct[condNum].operation=DBD_IS_NULL
            condStruct[condNum].bracketClose=3
            condStruct[(condNum+=1;condNum-2)].relationship=0
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
         count=DBD_Count(dag,true)
         if count<=0
            if showError
               SetErrorField(field)
               tableDesc = SBOString.new
               GetEnv().GetTableDescription(tableStruct[0].tableCode,tableDesc)
               CMessagesManager.GetHandle().Message(_1_APP_MSG_FIN_ITM_RELATED_ERR_FORMAT,EMPTY_STR,self,condStruct[0].condVal.GetBuffer(),tableDesc.GetBuffer())
            end

            return ooInvalidObject
         end

      end

      return ooNoErr
   end

   def CalculationFrnAmmounts(dagACT,dagCRD,found)
      ooErr=0
      dagJDT = PDAG.new=nil
      dagJDT1 = PDAG.new = nil
      mainCurr = Currency.new=""
      frnCurr = Currency.new = ""
      money = MONEY.new
      frnAmnt = MONEY.new


      lineCurr = SBOString.new
      tLineCurr = SBOString.new
      oldLineCurr = SBOString.new
      bpCurr = SBOString.new
      actCurr = SBOString.new
      accName = SBOString.new
      shortName = SBOString.new
      gCurr = SBOString.new
      uLineCurr = SBOString.new
      dateStr = []
      =""
      needFC=false
      bpFC = false
      bizEnv = CBizEnv.new=GetEnv()
      currencies = StdMap.new
      dagJDT=GetDAG()
      ooErr=dagJDT.GetColLong(transCode,OJDT_TRANS_TYPE,0)
      if ooErr
         return ooErr
      end

      if VAL_OBSERVER_SOURCE!=GetDataSource()||JDT!=transCode
         return ooErr
      end

      dagJDT1=GetDAG(JDT,ao_Arr1)
      _STR_strcpy(mainCurr,bizEnv.GetMainCurrency())
      _STR_LTrim(mainCurr)
      DAG_GetCount(dagJDT1,numOfRecs)
      rec=0
      while (rec<numOfRecs) do
         dagJDT1.GetColStr(tLineCurr,JDT1_FC_CURRENCY,rec)
         tLineCurr.Trim()
         bpFC=false
         if !tLineCurr.GetLength()
            dagJDT1.GetColStr(accName,JDT1_ACCT_NUM,rec)
            dagJDT1.GetColStr(shortName,JDT1_SHORT_NAME,rec)
            if accName.Compare(shortName)
               dagCRD=GetDAG(CRD)
               ooErr=dagCRD.GetByKey(shortName)
               ooErr=(-2028==ooErr) ? ooInvalidCardCode : ooErr
               if ooErr
                  return ooErr
               end

               dagCRD.GetColStr(bpCurr,OCRD_CRD_CURR,0)
               bpCurr.Trim()
               bpFC=GNCoinCmp(bpCurr,BAD_CURRENCY_STR) ? true : false
            end

            multiACT=false
            dagACT=GetDAG(ACT)
            ooErr=dagACT.GetByKey(accName)
            ooErr=(-2028==ooErr) ? ooInvalidAcctCode : ooErr
            if ooErr
               return ooErr
            end

            dagACT.GetColStr(actCurr,OACT_ACT_CURR,0)
            actCurr.Trim()
            multiACT=!GNCoinCmp(actCurr,BAD_CURRENCY_STR)
            if bpFC
               if multiACT||!GNCoinCmp(actCurr,bpCurr)
                  tLineCurr=bpCurr
                  currencies.SetAt(rec,bpCurr)
               else
                  currencies.SetAt(rec,actCurr)
               end

            else
               currencies.SetAt(rec,actCurr)
               tLineCurr=multiACT ? mainCurr : actCurr
            end

         end

         if GNCoinCmp(tLineCurr,mainCurr)&&tLineCurr.GetLength()
            if !lineCurr.GetLength()
               lineCurr=tLineCurr
            end

         end


         (rec+=1)
      end

      if !GNCoinCmp(lineCurr,mainCurr)||!lineCurr.GetLength()
         return ooErr
      end

      rec=0
      while (rec<numOfRecs) do
         if dagJDT1.IsNullCol(JDT1_FC_CURRENCY,rec)
            if currencies.Lookup(rec,gCurr)
               if dagJDT1.IsNullCol(JDT1_FC_CREDIT,rec)&&dagJDT1.IsNullCol(JDT1_FC_DEBIT,rec)
                  if GNCoinCmp(gCurr,mainCurr)
                     uLineCurr=gCurr
                     if !GNCoinCmp(uLineCurr,BAD_CURRENCY_STR)
                        uLineCurr=lineCurr
                     end

                     uLineCurr.ToBuffer(frnCurr)
                     dagJDT1.GetColMoney(money,JDT1_CREDIT,rec)
                     colIndex=JDT1_FC_CREDIT
                     if money.IsZero()
                        colIndex=JDT1_FC_DEBIT
                        dagJDT1.GetColMoney(money,JDT1_DEBIT,rec)
                     end

                     if !money.IsZero()
                        dagJDT1.SetColStr(uLineCurr,JDT1_FC_CURRENCY,rec)
                        dagJDT1.GetColStr(dateStr,JDT1_REF_DATE,rec)
                        ooErr=GNLocalToForeignRate(money,frnCurr,dateStr,0.0,frnAmnt,bizEnv)
                        if ooErr
                           return ooErr
                        end

                        frnAmnt.Round(RC_SUM,lineCurr,bizEnv)
                        dagJDT1.SetColMoney(frnAmnt,colIndex,rec)
                        found=true
                     end

                  end

               else
                  dagJDT1.GetColMoney(money,JDT1_FC_CREDIT,rec)
                  if money.IsZero()
                     dagJDT1.GetColMoney(money,JDT1_FC_DEBIT,rec)
                  end

                  if gCurr.GetLength()>0&&GNCoinCmp(gCurr,BAD_CURRENCY_STR)&&!money.IsZero()
                     if GNCoinCmp(gCurr,mainCurr)
                        dagJDT1.SetColStr(gCurr,JDT1_FC_CURRENCY,rec)
                     end

                  end

               end

            end

         else
            exist = Boolean.new=0
            currLine = Currency.new
            dagJDT1.GetColStr(oldLineCurr,JDT1_FC_CURRENCY,rec)
            oldLineCurr.ToBuffer(currLine)
            ooErr=GNCheckCurrencyCode(bizEnv,currLine,exist)
            if ooErr
               return ooErr
            end

            if !exist
               return ooUndefinedCurrency
            end

            crNull = Boolean.new=dagJDT1.IsNullCol(JDT1_FC_CREDIT,rec)
            dbNull = Boolean.new=dagJDT1.IsNullCol(JDT1_FC_DEBIT,rec)
            oneValue = Boolean.new=false
            remFC = Boolean.new = false
            if crNull&&!dbNull
               oneValue=true
               dagJDT1.GetColMoney(money,JDT1_FC_DEBIT,rec)
            end

            if !crNull&&dbNull
               oneValue=true
               dagJDT1.GetColMoney(money,JDT1_FC_CREDIT,rec)
            end

            if oneValue
               remFC=money.IsZero()
            else
               dagJDT1.GetColMoney(money,JDT1_FC_CREDIT,rec)
               if money.IsZero()
                  dagJDT1.GetColMoney(money,JDT1_FC_DEBIT,rec)
               end

               remFC=money.IsZero()
            end

            if remFC
               dagJDT1.NullifyCol(JDT1_FC_CURRENCY,rec)
            end

         end


         (rec+=1;rec-2)
      end

      return ooErr
   end

   def IsCurValid(crnCode,dagCRN)
      trace("IsCurValid")
      exist = Boolean.new

      bizEnv = CBizEnv.new=GetEnv()
      ooErr=GNCheckCurrencyCode(bizEnv,crnCode,exist)
      _STR_LRTrim(crnCode)
      if ooErr
         return ooErr
      end

      if !exist
         return -2028
      end

      return 0
   end

   def IsPaymentBlockValid(dagJDT1,rec)
      trace("IsPaymentBlockValid")
      acctCode = SBOString.new
      shortName = SBOString.new
      objType = SBOString.new
      strPaymentBlocked = []
      =""
      strBlockReason = []
      = ""
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
      isBlockReasonDfltValue=((NONE_CHOICE==strBlockReason)||_STR_IsSpacesStr(strBlockReason)||dagJDT1.IsNullCol(JDT1_PAYMENT_BLOCK_REF,rec))
      dagJDT1.GetColStr(objType,JDT1_TRANS_TYPE,rec)
      objType.Trim()
      strAllTransactionType = SBOString.new("-1")
      if (JDT!=objType.strtol())&&(strAllTransactionType!=objType)
         if (VAL_YES[0]==strPaymentBlocked[0])||!isBlockReasonDfltValue
            SetErrorLine(rec+1)
            SetErrorField(JDT1_PAYMENT_BLOCK)
            SetArrNum(ao_Arr1)
            Message(JTE_JDT_FORM_NUM,76,nil,OO_ERROR)
            return ooInvalidObject
         end

      end

      if isAcctLine
         if (VAL_YES[0]==strPaymentBlocked[0])||!isBlockReasonDfltValue
            SetErrorLine(rec+1)
            SetErrorField(JDT1_PAYMENT_BLOCK)
            SetArrNum(ao_Arr1)
            Message(JTE_JDT_FORM_NUM,77,nil,OO_ERROR)
            return ooInvalidObject
         end

      end

      if (VAL_NO[0]==strPaymentBlocked[0])||dagJDT1.IsNullCol(JDT1_PAYMENT_BLOCK,rec)
         if !isBlockReasonDfltValue
            SetErrorLine(rec+1)
            SetErrorField(JDT1_PAYMENT_BLOCK_REF)
            SetArrNum(ao_Arr1)
            Message(JTE_JDT_FORM_NUM,78,nil,OO_ERROR)
            return ooInvalidObject
         end

      end

      if !isBlockReasonDfltValue
         ooErr=ValidateRelations(ao_Arr1,rec,JDT1_PAYMENT_BLOCK_REF,PYB)
         if ooErr
            return ooErr
         end

      end

      return 0
   end

   def initialize(id,env)
      @m_digitalSignature = env
      trace("CSystemBusinessObject")
      @m_isVatJournalEntry=false
      @m_taxAdaptor=nil
      @m_stornoExtraInfoCreator=nil
      @m_reconcileBPLines=true
      @m_pSequenceParameter=nil
      @m_isInCancellingAcctRecon=false
      @m_isPostingPreviewMode=false
      @m_isPostingTemplate=false
   end

   def uninitialize()
      trace("~CTransactionJournalObject")
      if @m_taxAdaptor
         (@m_taxAdaptor).__delete
      end

      if @m_pSequenceParameter
         @m_pSequenceParameter.__delete
         @m_pSequenceParameter=nil
      end

      @m_reconAcctSet.clear()
   end

   def self.CreateObject(id,env)
      trace("CreateObject")
      return CTransactionJournalObject.new(id,env)
   end

   def CopyNoType(other)
      trace("CopyNoType")
      CSystemBusinessObject.CopyNoType(other)
      if other.GetID()==JDT
         bizObject = CTransactionJournalObject.new=other
         @m_jrnlKeys=bizObject.GetJournalKeys()
         @m_stornoExtraInfoCreator=(other).m_stornoExtraInfoCreator
         @m_isPostingPreviewMode=bizObject.m_isPostingPreviewMode
      end

   end

   def IsPeriodIndicCondNeeded()
      trace("IsPeriodIndicCondNeeded")
      return GetEnv().IsLocalSettingsFlag(lsf_IsDocNumMethod)
   end

   def RecordHist(bizObject,dag)
      trace("RecordHist")

      num=0



      baseRefStr = []

      bizEnv = CBizEnv.new=bizObject.GetEnv()
      dagOBJ = PDAG.new=bizObject.GetDAG()
      bizObjId=bizObject.GetID().strtol()
      sboErr=IsValidUserPermissions()
      if sboErr
         return sboErr
      end

      dag.GetColLong(series,OJDT_SERIES)
      if !(bizObjId!=JDT&&bizObject.IsUpdateNum())
         if !series
            refDate = SBOString.new
            dag.GetColStr(refDate,OJDT_REF_DATE)
            if refDate.Trim().IsSpacesStr()
               DBM_DATE_Get(refDate,bizEnv)
            end

            series=bizEnv.GetDefaultSeriesByDate(bizObject.GetBPLId(),SBOString(JDT),refDate)
            dag.SetColLong(series,OJDT_SERIES,0)
         end

      end

      if VF_MultipleRegistrationNumber(bizEnv)
         dag.GetColLong(seqCode,OJDT_SEQ_CODE)
         if seqCode==0||seqCode==-1
            seqManager = CSequenceManager.new=GetEnv().GetSequenceManager()
            sboErr=seqManager.LoadDfltSeq(self)
            if !sboErr
               sboErr=seqManager.FillDAGBySeq(self)
               if !sboErr
                  sboErr=seqManager.HandleSerial(self)
                  if sboErr
                     return sboErr
                  end

               end

            end

         end

      end

      if VF_SupplCode(GetEnv())
         pManager = CSupplCodeManager.new=bizEnv.GetSupplCodeManager()
         strNum = SBOString.new
         dag.GetColStr(strNum,OJDT_SUPPL_CODE)
         if strNum.IsNull()||strNum.IsEmpty()
            postDate = Date.new
            dag.GetColStr(postDate,OJDT_REF_DATE)
            sboErr=pManager.CodeChange(self,postDate)
            if sboErr
               return sboErr
            end

            sboErr=pManager.CheckCode(self)
            if sboErr
               CMessagesManager.GetHandle().Message(_54_APP_MSG_CORE_SUPPL_CODE_CODE_EXIST,EMPTY_STR,self)
               return ooInvalidObject
            end

         end

      end

      dag.GetColLong(transType,OJDT_TRANS_TYPE)
      if bizEnv.IsLocalSettingsFlag(lsf_IsDocNumMethod)
         if transType!=OPEN_BLNC_TYPE&&transType!=CLOSE_BLNC_TYPE&&transType!=MANUAL_BANK_TRANS_TYPE
            dag.GetColLong(num,OJDT_NUMBER)
         end

         dag.SetColLong(series,OJDT_DOC_SERIES,0)
      else
         if transType<0||transType==JDT||!bizEnv.IsSerieObject(SBOString(transType))
            dag.SetColLong(series,OJDT_DOC_SERIES,0)
         end

      end

      SetSeries(series)
      if !num
         sboErr=GetNextSerial(true)
      else
         sboErr=GetNextAutoKey(true)
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
         dagOBJ.GetLongByColType(theKey,ABSOLUTE_ENT_FLD,0)
      else
         dag.GetColLong(createdBy,OJDT_CREATED_BY)
         if (transType==DPS||transType==DPT||transType==RCT||transType==VPM||transType==MRV||transType==IPF||transType==ITR||transType==CHO||transType==JST||transType==IQR||transType==IQI||transType==IWZ||transType==ACQ||transType==ACD||transType==DRN||transType==MDP||transType==FTR||transType==FAR||transType==RTI)&&createdBy!=0
            theKey=createdBy
         end

         if VF_ExciseInvoice(bizEnv)&&transType==WTR&&createdBy>0
            theKey=createdBy
         end

      end

      dag.SetColLong(theKey,OJDT_CREATED_BY,0)
      dag.GetColLong(baseRef,OJDT_BASE_REF)
      if _STR_atol(bizObject.GetID())==JDT&&(transType==DPS||transType==DPT||transType==RCT||transType==VPM||transType==MRV||transType==IPF||transType==ITR||transType==CHO||transType==JST||transType==IQR||transType==IQI||transType==IWZ||transType==ACQ||transType==ACD||transType==DRN||transType==MDP||transType==FTR||transType==FAR||transType==RTI)&&baseRef!=0
         theKey=baseRef
      else
         dagOBJ.GetLongByColType(theKey,SERIAL_NUM_FLD,0)
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

   def IsDeferredAble()
      return false
   end

   def IsSmallDifferenceAble()
      return false
   end

   def IsWithHoldingAble()
      return VF_JEWHT(GetEnv())
   end

   def GetWithHoldingTax(onlyPaymentCateg,row)
      dagJDT2 = PDAG.new=GetArrayDAG(ao_Arr2)
      dagJDT1 = PDAG.new=GetArrayDAG(ao_Arr1)
      docTotal = CAllCurrencySums.new
      deb = CAllCurrencySums.new
      cred = CAllCurrencySums.new
      deb.FromDAG(dagJDT1,row,JDT1_DEBIT,JDT1_FC_DEBIT,JDT1_SYS_DEBIT)
      cred.FromDAG(dagJDT1,row,JDT1_CREDIT,JDT1_FC_CREDIT,JDT1_SYS_CREDIT)
      docTotal=deb-cred
      docTotal.Abs()
      return CDocumentObject.GetWTTaxSet(dagJDT2,docTotal,onlyPaymentCateg,row)
   end

   def LoadObjInfoFromDags(objInfo,dagObj,dagWTaxs,dagObjRows)
      sboErr=0
      deb = CAllCurrencySums.new
      cred = CAllCurrencySums.new
      deb.FromDAG(dagObjRows,objInfo.m_ObjectRow,JDT1_DEBIT,JDT1_FC_DEBIT,JDT1_SYS_DEBIT)
      cred.FromDAG(dagObjRows,objInfo.m_ObjectRow,JDT1_CREDIT,JDT1_FC_CREDIT,JDT1_SYS_CREDIT)
      objInfo.m_DocTotal=deb-cred
      objInfo.m_DocTotal.Abs()
      tmpWTTaxSet = WithHoldingTaxSet.new=CDocumentObject.GetWTTaxSet(dagWTaxs,objInfo.m_DocTotal,true)
      objInfo.SetDocWTaxArray(tmpWTTaxSet)
      deb.FromDAG(dagObjRows,objInfo.m_ObjectRow,JDT1_BALANCE_DUE_DEBIT,JDT1_BALANCE_DUE_FC_DEB,JDT1_BALANCE_DUE_SC_DEB)
      cred.FromDAG(dagObjRows,objInfo.m_ObjectRow,JDT1_BALANCE_DUE_CREDIT,JDT1_BALANCE_DUE_FC_CRED,JDT1_BALANCE_DUE_SC_CRED)
      deb-=cred
      objInfo.m_DocApplied=objInfo.m_DocTotal-deb.AbsVal()
      dagObj.GetColStr(objInfo.m_DocCurrency,OJDT_TRANS_CURR)
      if objInfo.m_DocCurrency.IsEmpty()
         objInfo.m_DocCurrency=objInfo.m_bizEnv.GetMainCurrency()
      end

      return sboErr
   end

   def GetWTaxReconDags(dagOBJ,dagObjWTax,dagObjRows)
      dagOBJ=GetDAG()
      dagObjWTax=GetArrayDAG(ao_Arr2)
      dagObjRows=GetArrayDAG(ao_Arr1)
      return 0
   end

   def CreateDocInfoQry(docInfoQry)
      bizEnv = CBizEnv.new=GetEnv()
      objType=GetID().strtol()
      tableObj = DBQTable.new=docInfoQry.From(bizEnv.ObjectToTable(objType,ao_Main))
      tableObjRow = DBQTable.new=docInfoQry.Join(bizEnv.ObjectToTable(objType,ao_Arr1),tableObj)
      docInfoQry.On(tableObjRow).Col(tableObj,OJDT_JDT_NUM).EQ().Col(tableObjRow,JDT1_TRANS_ABS)
      tableObjWtax = DBQTable.new=docInfoQry.Join(bizEnv.ObjectToTable(objType,ao_Arr2),tableObj)
      docInfoQry.On(tableObjWtax).Col(tableObj,OJDT_JDT_NUM).EQ().Col(tableObjWtax,JDT2_ABS_ENTRY).And().Col(tableObjWtax,JDT2_CATEGORY).EQ().Val(VAL_CATEGORY_PAYMENT)
      docInfoQry.Select().Col(tableObjRow,JDT1_TRANS_ABS)
      docInfoQry.Select().Col(tableObjRow,JDT1_LINE_ID)
      docInfoQry.Select().Max().Col(tableObj,OJDT_TRANS_CURR).As(OJDT_TRANS_CURR_ALIAS)
      docInfoQry.Select().Max().Col(tableObjRow,JDT1_CREDIT).Sub().Max().Col(tableObjRow,JDT1_DEBIT).As("Credit")
      docInfoQry.Select().Max().Col(tableObjRow,JDT1_FC_CREDIT).Sub().Max().Col(tableObjRow,JDT1_FC_DEBIT).As("FCCredit")
      docInfoQry.Select().Max().Col(tableObjRow,JDT1_SYS_CREDIT).Sub().Max().Col(tableObjRow,JDT1_SYS_DEBIT).As("SYSCred")
      docInfoQry.Select().Max().Col(tableObjRow,JDT1_CREDIT).Sub().Max().Col(tableObjRow,JDT1_DEBIT).Sub().Max().Col(tableObjRow,JDT1_BALANCE_DUE_CREDIT).Add().Max().Col(tableObjRow,JDT1_BALANCE_DUE_DEBIT).As("BalDueCred")
      docInfoQry.Select().Max().Col(tableObjRow,JDT1_FC_CREDIT).Sub().Max().Col(tableObjRow,JDT1_FC_DEBIT).Sub().Max().Col(tableObjRow,JDT1_BALANCE_DUE_FC_CRED).Add().Max().Col(tableObjRow,JDT1_BALANCE_DUE_FC_DEB).As("BalFcCred")
      docInfoQry.Select().Max().Col(tableObjRow,JDT1_SYS_CREDIT).Sub().Max().Col(tableObjRow,JDT1_SYS_DEBIT).Sub().Max().Col(tableObjRow,JDT1_BALANCE_DUE_SC_CRED).Add().Max().Col(tableObjRow,JDT1_BALANCE_DUE_SC_DEB).As("BalScCred")
      docInfoQry.Select().Sum().Col(tableObjWtax,JDT2_WT_AMOUNT).As(JDT2_WT_AMOUNT_ALIAS)
      docInfoQry.Select().Sum().Col(tableObjWtax,JDT2_WT_AMOUNT_FC).As(JDT2_WT_AMOUNT_FC_ALIAS)
      docInfoQry.Select().Sum().Col(tableObjWtax,JDT2_WT_AMOUNT_SC).As(JDT2_WT_AMOUNT_SC_ALIAS)
      docInfoQry.Select().Sum().Col(tableObjWtax,JDT2_WT_APPLIED_AMOUNT).As(JDT2_WT_APPLIED_AMOUNT_ALIAS)
      docInfoQry.Select().Sum().Col(tableObjWtax,JDT2_WT_APPLIED_AMOUNT_FC).As(JDT2_WT_APPLIED_AMOUNT_FC_ALIAS)
      docInfoQry.Select().Sum().Col(tableObjWtax,JDT2_WT_APPLIED_AMOUNT_SC).As(JDT2_WT_APPLIED_AMOUNT_SC_ALIAS)
      docInfoQry.Select(tableObj,OJDT_LOC_TOTAL).Val(0).As(_T("DummyCol2"))
      docInfoQry.Select(tableObj,OJDT_FC_TOTAL).Val(0).As(_T("DummyCol3"))
      docInfoQry.Select(tableObj,OJDT_SYS_TOTAL).Val(0).As(_T("DummyCol4"))
      docInfoQry.GroupBy(tableObjRow,JDT1_TRANS_ABS)
      docInfoQry.GroupBy(tableObjRow,JDT1_LINE_ID)
      return 0
   end

   def self.DocBudgetCurrentSum(bizObject,currentMoney,acctCode)
      trace("DocBudgetCurrentSum")
      sboErr=ooNoErr
      condStruct = []

      resStruct = []

      dagRES = PDAG.new
      dagObj = PDAG.new
      dagDOC = PDAG.new = bizObject.GetDAG()
      docDiscount = MONEY.new
      tmpM = MONEY.new
      sumRow = MONEY.new(0)
      dagObj=bizObject.GetDAG(bizObject.GetID(),ao_Arr1)
      if !DAG.IsValid(dagObj)
         return -2007
      end

      dagDOC.GetColMoney(docDiscount,OINV_DISC_PERCENT)
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
      sboErr=DBD_GetInNewFormat(dagObj,dagRES)
      if !sboErr
         rec=0
         while (rec<dagRES.GetRealSize(dbmDataBuffer)) do
            dagRES.GetColMoney(sumRow,0,rec)
            if !docDiscount.IsZero()
               tmpM=sumRow*docDiscount
               sumRow-=tmpM
            end

            (currentMoney)+=sumRow

            (rec+=1;rec-2)
         end

      end

      return sboErr
   end

   def self.UpdateAccumulators(bizObject,rec,isCard)
      trace("UpdateAccumulators")
      ooErr=0
      dagBGT = PDAG.new=nil
      dagBGT1 = PDAG.new = nil
      blockLevel=0
      typeBlockLevel = 0

      formatStr = []
      =""
      transTypeStr = []
      =""
      bgtStr = []
      =""
      acctCode = []
      =""
      finYear = []
      =""
      tmpStr = []
      =""
      bgtDebitSize = Boolean.new=false
      jdtDebitSize = Boolean.new=false
      localDags = Boolean.new
      budgetAllYes = Boolean.new=false
      debBudgMoney = MONEY.new
      credBudgMoney = MONEY.new
      debBudgSysMoney = MONEY.new
      credBudgSysMoney = MONEY.new
      testMoney = MONEY.new
      testYearMoney = MONEY.new
      budgMoney = MONEY.new
      tmpM = MONEY.new
      testTmpM = MONEY.new
      testYearTmpM = MONEY.new
      bizEnv = CBizEnv.new=bizObject.GetEnv()
      if isCard
         return (ooNoErr)
      end

      if bizEnv.IsComputeBudget()==false
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

      localDags=false
      if !DAG_IsValid(bizObject.GetDAG(BGT))
         dagBGT=bizObject.OpenDAG(BGT,ao_Main)
         _STR_strcpy(tmpStr,bizEnv.ObjectToTable(BGT,ao_Arr1))
         dagBGT1=bizObject.OpenDAG(BGT,ao_Arr1)
         localDags=true
         _MEM_MYRPT0(_T("BGT Table not _STR_open"))
      else
         dagBGT=bizObject.GetDAG(BGT)
         dagBGT1=bizObject.GetDAG(BGT,ao_Arr1)
      end

      bizObject.GetDAG(ACT).GetColStr(acctCode,OACT_ACCOUNT_CODE,0)
      _STR_LRTrim(acctCode)
      bizObject.GetDAG(JDT,ao_Arr1).GetColStr(tmpStr,JDT1_REF_DATE,rec)
      bizEnv.GetCompanyDateRange(finYear,nil)
      ooErr=CBudgetGeneralObject.GetBudgetRecords(dagBGT,dagBGT1,nil,nil,acctCode,finYear,-1,tmpStr,true,true)
      if ooErr
         if localDags
            dagBGT.Close()
            dagBGT1.Close()
         end

         if ooErr!=-2028
            return ooErr
         end

         if ooErr==-2028
            return ooNoErr
         end

      end

      transType=bizObject.GetID().strtol()
      blockLevel=RetBlockLevel(bizEnv)
      typeBlockLevel=RettypeBlockLevel(bizEnv,transType)
      bizObject.GetDAG(JDT,ao_Arr1).GetColMoney(debBudgMoney,JDT1_DEBIT,rec,DBM_NOT_ARRAY)
      if !debBudgMoney.IsZero()
         jdtDebitSize=true
      end

      bizObject.GetDAG(JDT,ao_Arr1).GetColMoney(credBudgMoney,JDT1_CREDIT,rec,DBM_NOT_ARRAY)
      bizObject.GetDAG(JDT,ao_Arr1).GetColMoney(debBudgSysMoney,JDT1_SYS_DEBIT,rec,DBM_NOT_ARRAY)
      bizObject.GetDAG(JDT,ao_Arr1).GetColMoney(credBudgSysMoney,JDT1_SYS_CREDIT,rec,DBM_NOT_ARRAY)
      if bizObject.IsExCommand(ooDontCheckTranses)&&blockLevel>=3&&typeBlockLevel==5&&(OOIsSaleObject(transType)||OOIsPurchaseObject(transType))
         blockLevel=1
      end

      dagBGT.GetColMoney(testYearMoney,OBGT_DEB_TOTAL,0,DBM_NOT_ARRAY)
      if !testYearMoney.IsZero()
         bgtDebitSize=true
      end

      if bizEnv.GetBudgetWarningFrequency()==VAL_MONTHLY[0]
         dagBGT1.GetColMoney(testMoney,BGT1_DEB_TOTAL,0,DBM_NOT_ARRAY)
      else
         dagBGT.GetColMoney(testMoney,OBGT_DEB_TOTAL,0,DBM_NOT_ARRAY)
      end

      if blockLevel>1&&bgtDebitSize
         if bizEnv.GetBudgetWarningFrequency()==VAL_YEARLY[0]
            dagBGT.GetColMoney(budgMoney,OBGT_DEB_REAL_TOTAL,0,DBM_NOT_ARRAY)
            MONEY_Add(testTmpM,budgMoney)
            dagBGT.GetColMoney(budgMoney,OBGT_CRED_REAL_TOTAL,0,DBM_NOT_ARRAY)
            MONEY_Sub(testTmpM,budgMoney)
         end

         if bizEnv.GetBudgetWarningFrequency()==VAL_MONTHLY[0]
            dagBGT1.GetColMoney(budgMoney,BGT1_DEB_REAL_TOTAL,0,DBM_NOT_ARRAY)
            MONEY_Add(testTmpM,budgMoney)
            dagBGT1.GetColMoney(budgMoney,BGT1_CRED_REAL_TOTAL,0,DBM_NOT_ARRAY)
            MONEY_Sub(testTmpM,budgMoney)
            dagBGT.GetColMoney(budgMoney,OBGT_DEB_REAL_TOTAL,0,DBM_NOT_ARRAY)
            MONEY_Add(testYearTmpM,budgMoney)
            dagBGT.GetColMoney(budgMoney,OBGT_CRED_REAL_TOTAL,0,DBM_NOT_ARRAY)
            MONEY_Sub(testYearTmpM,budgMoney)
         end

         if jdtDebitSize
            MONEY_Add(testTmpM,debBudgMoney)
            MONEY_Add(testYearTmpM,debBudgMoney)
         else
            MONEY_Sub(testTmpM,credBudgMoney)
            MONEY_Sub(testYearTmpM,credBudgMoney)
         end

         ooErr=SetBudgetBlock(bizObject,blockLevel,testMoney,testYearMoney,testTmpM,testYearTmpM)
         if ooErr
            if localDags
               dagBGT.Close()
               dagBGT1.Close()
            end

            return ooErr
         end

      end

      dagBGT1.GetColMoney(budgMoney,BGT1_DEB_REAL_TOTAL,0,DBM_NOT_ARRAY)
      MONEY_Add(budgMoney,debBudgMoney)
      dagBGT1.SetColMoney(budgMoney,BGT1_DEB_REAL_TOTAL,0,DBM_NOT_ARRAY)
      dagBGT1.GetColMoney(budgMoney,BGT1_CRED_REAL_TOTAL,0,DBM_NOT_ARRAY)
      MONEY_Add(budgMoney,credBudgMoney)
      dagBGT1.SetColMoney(budgMoney,BGT1_CRED_REAL_TOTAL,0,DBM_NOT_ARRAY)
      dagBGT1.GetColMoney(budgMoney,BGT1_DEB_REAL_SYS_TOTAL,0,DBM_NOT_ARRAY)
      MONEY_Add(budgMoney,debBudgSysMoney)
      dagBGT1.SetColMoney(budgMoney,BGT1_DEB_REAL_SYS_TOTAL,0,DBM_NOT_ARRAY)
      dagBGT1.GetColMoney(budgMoney,BGT1_CRED_REAL_SYS_TOTAL,0,DBM_NOT_ARRAY)
      MONEY_Add(budgMoney,credBudgSysMoney)
      dagBGT1.SetColMoney(budgMoney,BGT1_CRED_REAL_SYS_TOTAL,0,DBM_NOT_ARRAY)
      dagBGT.GetColMoney(budgMoney,OBGT_DEB_REAL_TOTAL,0,DBM_NOT_ARRAY)
      MONEY_Add(budgMoney,debBudgMoney)
      dagBGT.SetColMoney(budgMoney,OBGT_DEB_REAL_TOTAL,0,DBM_NOT_ARRAY)
      dagBGT.GetColMoney(budgMoney,OBGT_CRED_REAL_TOTAL,0,DBM_NOT_ARRAY)
      MONEY_Add(budgMoney,credBudgMoney)
      dagBGT.SetColMoney(budgMoney,OBGT_CRED_REAL_TOTAL,0,DBM_NOT_ARRAY)
      dagBGT.GetColMoney(budgMoney,OBGT_DEB_REAL_SYS_TOTAL,0,DBM_NOT_ARRAY)
      MONEY_Add(budgMoney,debBudgSysMoney)
      dagBGT.SetColMoney(budgMoney,OBGT_DEB_REAL_SYS_TOTAL,0,DBM_NOT_ARRAY)
      dagBGT.GetColMoney(budgMoney,OBGT_CRED_REAL_SYS_TOTAL,0,DBM_NOT_ARRAY)
      MONEY_Add(budgMoney,credBudgSysMoney)
      dagBGT.SetColMoney(budgMoney,OBGT_CRED_REAL_SYS_TOTAL,0,DBM_NOT_ARRAY)
      ooErr=GOUpdateProc(bizObject,dagBGT)
      if localDags
         dagBGT.Close()
         dagBGT1.Close()
      end

      return (ooErr)
   end

   def self.SetBudgetBlock(bizObject,blockLevel,testMoney,testYearMoney,testTmpM,testYearTmpM,workWithUI)
      trace("SetBudgetBlock")
      ooErr=0
      dagWDD = PDAG.new
      monSymbol = Currency.new=""
      msgStr1 = []
      =""
      msgStr2 = []
      = ""
      moneyStr = []
      =""
      moneyMonthStr = []
      = ""
      moneyYearStr = []
      = ""
      condVal = TCHAR.new
      strKeyTmp = SBOString.new

      numTemplatesApplied = 0
      budgetAllYes = Boolean.new=false
      fromImport = Boolean.new = false
      doTemlates = Boolean.new = false
      objType=bizObject.GetID().strtol()
      bizEnv = CBizEnv.new=bizObject.GetEnv()
      dagWDD=bizObject.GetDAG(WDD)
      numTemplatesApplied=dagWDD.GetRealSize(dbmDataBuffer)
      doTemlates=(Boolean)((OOIsSaleObject(objType)||OOIsPurchaseObject(objType))&&bizEnv.IsWorkFlow())
      if blockLevel<=1
         return ooNoErr
      end

      budgetAllYes=bizObject.IsExCommand(ooDontUpdateBudget)
      fromImport=bizObject.IsExCommand(ooImportData)
      if fromImport
         doTemlates=false
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
         condVal=(bizEnv.GetBudgetWarningFrequency()==VAL_MONTHLY[0] ? moneyMonthStr : moneyYearStr)
         ooErr=(bizObject).ODOCGetTemplatesByCond(WDD_COND_VAL_BUDGET,condVal,false)
         if ooErr
            if ooErr==ooAuthorizRequiered
               (numTemplatesApplied+=1;numTemplatesApplied-2)
            else
               return ooErr
            end

         end

      end

      isFromDI=(bizObject.GetDataSource()==VAL_OBSERVER_SOURCE[0])
      if !workWithUI&&!isFromDI
         if bizEnv.GetBudgetWarningFrequency()==VAL_MONTHLY[0]
            (bizObject).GetBudgBlockErrorMessage(moneyMonthStr,moneyYearStr,bizObject.GetKeyStr(),2,msgStr1)
         else
            (bizObject).GetBudgBlockErrorMessage(moneyYearStr,moneyMonthStr,bizObject.GetKeyStr(),3,msgStr1)
         end

         if numTemplatesApplied!=0&&doTemlates
            blockLevel=3
         end

         docObj = CDocumentObject.new=dynamic_cast(bizObject)
         if blockLevel==3&&docObj&&docObj.IsRecurringInstance()&&nsRecurringTransaction::eConfirm!=docObj.GetRecurringExecuteOption()
            blockLevel=2
         end

         case blockLevel

         when 2
            if bizEnv.GetBudgetWarningFrequency()==VAL_MONTHLY[0]
               (bizObject).GetBudgBlockErrorMessage(moneyMonthStr,moneyYearStr,bizObject.GetKeyStr(),1,msgStr1)
               _STR_strcat(msgStr1,_T(" , "))
               _STR_strcat(msgStr1,EMPTY_STR)
               bizObject.Message(-1,-1,msgStr1,OO_ERROR)
            else
               strKey = SBOString.new
               accountFormat = []

               strKey=bizObject.GetKeyStr()
               strKey.Trim()
               _STR_strcpy(accountFormat,strKey.GetBuffer())
               bizEnv.GetAccountSegmentsByCode(accountFormat,accountFormat,true)
               CMessagesManager.GetHandle().Message(_1_APP_MSG_FIN_BGT0_CHECK_YEAR_TOTAL_STR1,EMPTY_STR,bizEnv,accountFormat,moneyYearStr)
            end

            return ooInvalidObject

         when 3
            if fromImport
               _STR_strcat(msgStr1,_T(" , "))
               _STR_strcat(msgStr1,EMPTY_STR)
               bizObject.Message(-1,-1,msgStr1,OO_ERROR)
            end

            if budgetAllYes==false
               continueStr = []

               _STR_GetStringResource(ContinueStr,BGT0_FORM_NUM,BGT0_CONTINUE_STR)
               retBtn=FORM_GEN_Message(msgStr1,ContinueStr,CANCEL_STR(OOGetEnv(nil)),YES_TO_ALL_STR(OOGetEnv(nil)),2)
               case retBtn

               when 1
               when 3
                  budgetAllYes=(retBtn==3 ? true : false)
                  if budgetAllYes
                     bizObject.SetExCommand(ooDontUpdateBudget,fa_Set)
                  end

                  if bizObject.GetEnv().GetPermission(PRM_ID_BUDGET_BLOCK)!=OO_PRM_FULL
                     OODisplayError(bizObject,fuNoPermission)
                     return ooErrNoMsg
                  end

                  return ooNoErr

               when 2
                  return ooErrNoMsg

               end

            end


         end

      end

      return ooNoErr
   end

   def self.DocBudgetRestriction(bizObject,acctCode,sum,refDate,budgetAllYes,isWorkWithUI)
      trace("DocBudgetRestriction")
      ooErr=ooNoErr
      dagBGT = PDAG.new
      dagBGT1 = PDAG.new
      acctNum=0
      objType = bizObject.GetID().strtol()
      blockLevel=0





      tmpStr = []
      =""
      bgtStr = []
      =""
      finYear = []
      =""
      bgtDebitSide = Boolean.new=false
      budgMoney = MONEY.new
      testTmpM = MONEY.new
      testYearTmpM = MONEY.new
      testMoney = MONEY.new
      testYearMoney = MONEY.new
      openInvMoney = MONEY.new
      openInvYearMoney = MONEY.new
      currentMoney = MONEY.new
      bizEnv = CBizEnv.new=bizObject.GetEnv()
      if bizEnv.IsComputeBudget()==false
         bizObject.SetExCommand(ooDontUpdateBudget,fa_Set)
         return (ooNoErr)
      end

      blockLevel=RetBlockLevel(bizEnv)
      pDocObject = CDocumentObject.new=dynamic_cast(bizObject)
      bIsCancelDoc=pDocObject&&pDocObject.IsCancelDoc()
      if objType==QUT||((objType==RPC||objType==RPD)&&!bIsCancelDoc)||((objType==PDN||objType==PCH)&&bIsCancelDoc)
         return ooNoErr
      end

      if sum.IsNegative()
         return ooNoErr
      end

      typeBlockLevel=RettypeBlockLevel(bizEnv,objType)
      if blockLevel>=2&&typeBlockLevel==5&&objType==RDR
         blockLevel=1
      end

      if blockLevel<=1||typeBlockLevel<=-1
         bizObject.SetExCommand(ooDontUpdateBudget,fa_Set)
         return ooNoErr
      end

      budgMoney.SetToZero()
      testTmpM.SetToZero()
      testMoney.SetToZero()
      testYearMoney.SetToZero()
      openInvMoney.SetToZero()
      openInvYearMoney.SetToZero()
      testYearTmpM.SetToZero()
      currentMoney.SetToZero()
      ooErr=ooNoErr
      dagBGT=bizObject.GetDAG(BGT)
      dagBGT1=bizObject.GetDAG(BGT,ao_Arr1)
      bizEnv.GetCompanyDateRange(finYear,nil)
      ooErr=CBudgetGeneralObject.GetBudgetRecords(dagBGT,dagBGT1,nil,nil,acctCode,finYear,-1,refDate,true)
      if ooErr&&ooErr!=-2028
         return ooErr
      end

      if ooErr==-2028
         return ooNoErr
      end

      dagBGT.GetColMoney(testYearMoney,OBGT_DEB_TOTAL,0,DBM_NOT_ARRAY)
      if !testYearMoney.IsZero()
         bgtDebitSide=true
      end

      if !bgtDebitSide
         return ooNoErr
      end

      openInvField=openInvSysField=-1
      openInvYearField=openInvYearSysField=-1
      case objType

      when POR
      when PDN
      when RPD
      when RPC
      when PRQ
         openInvYearField=OBGT_FUTR_OUT_D_R_SUM
         openInvYearSysField=OBGT_FUTR_OUT_D_R_SYS_SUM
         if bizEnv.GetBudgetWarningFrequency()==VAL_YEARLY[0]
            openInvField=OBGT_FUTR_OUT_D_R_SUM
            openInvSysField=OBGT_FUTR_OUT_D_R_SYS_SUM
         else
            openInvField=BGT1_FUTR_OUT_D_R_SUM
            openInvSysField=BGT1_FUTR_OUT_D_R_SYS_SUM
         end


      end

      dagBGT.GetColMoney(testMoney,OBGT_DEB_TOTAL,0,DBM_NOT_ARRAY)
      if bizEnv.GetBudgetWarningFrequency()==VAL_MONTHLY[0]
         dagBGT1.GetColMoney(testMoney,BGT1_DEB_TOTAL,0,DBM_NOT_ARRAY)
      end

      if bizEnv.GetBudgetWarningFrequency()==VAL_YEARLY[0]
         dagBGT.GetColMoney(budgMoney,OBGT_DEB_REAL_TOTAL,0,DBM_NOT_ARRAY)
         MONEY_Add(testTmpM,budgMoney)
         dagBGT.GetColMoney(budgMoney,OBGT_CRED_REAL_TOTAL,0,DBM_NOT_ARRAY)
         MONEY_Sub(testTmpM,budgMoney)
         testYearTmpM=testTmpM
      end

      if bizEnv.GetBudgetWarningFrequency()==VAL_MONTHLY[0]
         dagBGT1.GetColMoney(budgMoney,BGT1_DEB_REAL_TOTAL,0,DBM_NOT_ARRAY)
         MONEY_Add(testTmpM,budgMoney)
         dagBGT1.GetColMoney(budgMoney,BGT1_CRED_REAL_TOTAL,0,DBM_NOT_ARRAY)
         MONEY_Sub(testTmpM,budgMoney)
         dagBGT.GetColMoney(budgMoney,OBGT_DEB_REAL_TOTAL,0,DBM_NOT_ARRAY)
         MONEY_Add(testYearTmpM,budgMoney)
         dagBGT.GetColMoney(budgMoney,OBGT_CRED_REAL_TOTAL,0,DBM_NOT_ARRAY)
         MONEY_Sub(testYearTmpM,budgMoney)
      end

      if openInvField>0
         if bizEnv.GetBudgetWarningFrequency()==VAL_YEARLY[0]
            dagBGT.GetColMoney(openInvMoney,openInvField,0,DBM_NOT_ARRAY)
         else
            dagBGT1.GetColMoney(openInvMoney,openInvField,0,DBM_NOT_ARRAY)
         end

         dagBGT.GetColMoney(openInvYearMoney,openInvYearField,0,DBM_NOT_ARRAY)
      end

      MONEY_Add(testTmpM,sum)
      MONEY_Add(testTmpM,openInvMoney)
      MONEY_Add(testYearTmpM,sum)
      MONEY_Add(testYearTmpM,openInvYearMoney)
      DocBudgetCurrentSum(bizObject,currentMoney,acctCode)
      MONEY_Sub(testTmpM,currentMoney)
      testYearTmpM-=currentMoney
      _STR_strcpy(tmpStr,bizObject.GetKeyStr())
      bizObject.SetKeyStr(acctCode)
      ooErr=SetBudgetBlock(bizObject,blockLevel,testMoney,testYearMoney,testTmpM,testYearTmpM,isWorkWithUI)
      bizObject.SetKeyStr(tmpStr)
      return ooErr
   end

   def self.GetYearAndMonthEntry(dagJDT,byRef,rec,month,year)
      trace("GetYearAndMonthEntry")
      date = []

      if byRef
         dagJDT.GetColStr(date,JDT1_REF_DATE,rec)
      else
         dagJDT.GetColStr(date,JDT1_DUE_DATE,rec)
      end

      GetYearAndMonthEntryByDate(date,month,year)
      return
   end

   def self.GetYearAndMonthEntryByDate(dateStr,month,year)
      trace("GetYearAndMonthEntryByDate")
      date = []

      if !dateStr||!month||!year
         return
      end

      month=year=0
      _STR_strcpy(date,dateStr)
      date[6]=0
      month=_STR_atol(date+4)
      date[4]=0
      year=_STR_atol(date)
      return
   end

   def self.GetSRObjectBudgetAcc(object)
      trace("GetSRObjectBudgetAcc")
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

   def self.RettypeBlockLevel(bizEnv,id)
      trace("RettypeBlockLevel")
      case id

      when POR
         if bizEnv.IsApplyBudget(bl_Orders)
            return 4
         end


      when PDN
         if bizEnv.IsApplyBudget(bl_Deliveries)
            return 4
         end


      when PRQ
         if bizEnv.IsApplyBudget(bl_PurchaseRequest)
            return 4
         end


      else
         if bizEnv.IsApplyBudget(bl_Accounting)
            return 5
         end


      end

      return -1
   end

   def self.RetBlockLevel(bizEnv)
      trace("RetBlockLevel")
      if bizEnv.GetBudgetBlockLevel()==VAL_BLOCK[0]
         return 2
      else
         if bizEnv.GetBudgetBlockLevel()==VAL_NO[0]
            return 1
         else
            if bizEnv.GetBudgetBlockLevel()==VAL_WARNING[0]
               return 3
            end

         end

      end

      return 1
   end

   def self.RecordJDT(env,dagJDT,dagJDT1,reconcileBPLines)
      trace("RecordJDT")

      obj = CTransactionJournalObject.new=env.CreateBusinessObject(SBOStringJDT)
      dagLocalJDT = PDAG.new=obj.GetDAG(JDT,ao_Main)
      dagLocalJDT1 = PDAG.new=obj.GetDAG(JDT,ao_Arr1)
      dagLocalJDT.Copy(dagJDT,dbmDataBuffer)
      dagLocalJDT1.Copy(dagJDT1,dbmDataBuffer)
      obj.m_reconcileBPLines=reconcileBPLines
      ooErr=obj.OnCreate()
      dagJDT.CopyColumn(dagLocalJDT,OJDT_JDT_NUM,0,OJDT_JDT_NUM,0)
      obj.Destroy()
      return ooErr
   end

   def self.UpdateDocBudget(bizObject,updateBgtPtr,dagDOC1,rec)
      trace("UpdateDocBudget")
      ooErr=ooNoErr
      dagBGT = PDAG.new=nil
      dagBGT1 = PDAG.new = nil
      dagAct = PDAG.new=nil
      tmpStr = []
      =""
      finYear = []
      =""
      localDags = Boolean.new=false
      bgtDebitSide = Boolean.new=false
      subMoneyOper = Boolean.new = false




      acctNum=0
      budgMoney = MONEY.new
      tmpM = MONEY.new
      tmpSysM = MONEY.new
      bizEnv = CBizEnv.new=bizObject.GetEnv()
      if !DAG.IsValid(dagDOC1)
         return -2007
      end

      if bizEnv.IsComputeBudget()==false
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
         subMoneyOper=true

      else
         return (ooNoErr)

      end

      if (bizEnv.IsContInventory()||(bizEnv.IsCurrentLocalSettings(ITALY_SETTINGS)&&bizEnv.IsPurchaseAccounting()))&&(updateBgtPtr.objType==PDN||updateBgtPtr.objType==RPD)
         itemCode = SBOString.new

         dagDOC1.GetColStr(itemCode,INV1_ITEM_CODE,rec)
         ooErr=CItemMasterData.IsInventoryItemEx(bizEnv,bizObject.GetDAGNoOpen(SBOString(ITM)),itemCode,result)
         if ooErr
            if ooErr==-2028
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

      dagActWrp = DagWrapper.new=bizEnv.GetDagPool().Get(make_pair(ACT,ao_Main))
      dagAct=dagActWrp.GetPtr()
      dagBGT=bizObject.GetDAG(BGT)
      dagBGT1=bizObject.GetDAG(BGT,ao_Arr1)
      acctNum=0
      while (acctNum<updateBgtPtr.numOfAcct) do
         _STR_LRTrim(updateBgtPtr.acctBgtRecords[acctNum].acctCode)
         if _STR_IsSpacesStr(updateBgtPtr.acctBgtRecords[acctNum].acctCode)
            next

         end

         if !updateBgtPtr.acctBgtRecords[acctNum].acctCode[0]&&updateBgtPtr.objType==RDR
            next

         end

         ooErr=bizEnv.GetByOneKey(dagAct,1,updateBgtPtr.acctBgtRecords[acctNum].acctCode)
         if ooErr
            if ooErr!=-2028
               return ooErr
            end

            ooErr=ooNoErr
            next

         end

         dagAct.GetColStr(tmpStr,OACT_BUDGET,0)
         _STR_LRTrim(tmpStr)
         if tmpStr[0]==VAL_NO[0]
            next

         end

         docDate = SBOString.new
         dagDOC1.GetColStr(docDate,INV1_DATE,rec)
         bizEnv.GetCompanyDateRangeByDate(docDate,finYear,nil)
         ooErr=CBudgetGeneralObject.GetBudgetRecords(dagBGT,dagBGT1,nil,nil,updateBgtPtr.acctBgtRecords[acctNum].acctCode,finYear,-1,updateBgtPtr.acctBgtRecords[acctNum].date,true,true)
         if ooErr&&ooErr!=-2028
            return ooErr
         end

         if ooErr==-2028
            ooErr=ooNoErr
            next

         end

         dagBGT.GetColMoney(tmpM,OBGT_DEB_TOTAL,0,DBM_NOT_ARRAY)
         if !tmpM.IsZero()
            bgtDebitSide=true
         end

         case updateBgtPtr.objType

         when POR
         when PDN
         when RPD
         when PRQ
            openInvField=OBGT_FUTR_OUT_D_R_SUM
            openInvSysField=OBGT_FUTR_OUT_D_R_SYS_SUM
            openInvFieldArr=BGT1_FUTR_OUT_D_R_SUM
            openInvSysFieldArr=BGT1_FUTR_OUT_D_R_SYS_SUM
            break
         when RDR
         when DLN
         when RDN
            openInvField=OBGT_FUTR_IN_C_R_SUM
            openInvSysField=OBGT_FUTR_IN_C_R_SYS_SUM
            openInvFieldArr=BGT1_FUTR_IN_C_R_SUM
            openInvSysFieldArr=BGT1_FUTR_IN_C_R_SYS_SUM
            break
         end

         tmpM.SetToZero()
         tmpSysM.SetToZero()
         budgMoney.SetToZero()
         tmpM=updateBgtPtr.acctBgtRecords[acctNum].sum
         tmpSysM=updateBgtPtr.acctBgtRecords[acctNum].sysSum
         if subMoneyOper
            MONEY_Multiply(tmpM,-1,tmpM)
            MONEY_Multiply(tmpSysM,-1,tmpSysM)
         end

         dagBGT1.GetColMoney(budgMoney,openInvFieldArr,0,DBM_NOT_ARRAY)
         MONEY_Add(budgMoney,tmpM)
         dagBGT1.SetColMoney(budgMoney,openInvFieldArr,0,DBM_NOT_ARRAY)
         dagBGT.GetColMoney(budgMoney,openInvField,0,DBM_NOT_ARRAY)
         MONEY_Add(budgMoney,tmpM)
         dagBGT.SetColMoney(budgMoney,openInvField,0,DBM_NOT_ARRAY)
         dagBGT1.GetColMoney(budgMoney,openInvSysFieldArr,0,DBM_NOT_ARRAY)
         MONEY_Add(budgMoney,tmpSysM)
         dagBGT1.SetColMoney(budgMoney,openInvSysFieldArr,0,DBM_NOT_ARRAY)
         dagBGT.GetColMoney(budgMoney,openInvSysField,0,DBM_NOT_ARRAY)
         MONEY_Add(budgMoney,tmpSysM)
         dagBGT.SetColMoney(budgMoney,openInvSysField,0,DBM_NOT_ARRAY)
         ooErr=GOUpdateProc(bizObject,dagBGT,true)
         if ooErr
            return ooErr
         end


         (acctNum+=1;acctNum-2)
      end

      return (ooErr)
   end

   def self.OJDTCheckIntegrityOfJournalEntry(bizObject,checkForgn)
      trace("OJDTCheckIntegrityOfJournalEntry")

      dagJDT = PDAG.new=bizObject.GetDAGNoOpen(SBOString(JDT))
      if !dagJDT
         _MEM_ASSERT(0)
         return ooNoErr
      end

      numOfRecs=dagJDT.GetRecordCount()
      if numOfRecs==1
         tmpStr = SBOString.new
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
      if ooErr
         return ooErr
      end

      ooErr=OJDTValidateJDTOfLocalCard(bizObject)
      if ooErr
         return ooErr
      end

      ooErr=OJDTValidateJDT1Accounts(bizObject)
      if ooErr
         return ooErr
      end

      ooErr=OJDTCheckBalnaceTransection(bizObject,checkForgn)
      if ooErr
         return ooErr
      end

      ooErr=CostAccountingAssignmentCheck(bizObject)
      if ooErr
         return ooErr
      end

      return ooNoErr
   end

   def self.OJDTCheckJDT1IsNotEmpty(bizObject)
      trace("OJDTCheckJDT1IsNotEmpty")

      keyCol1 = SBOString.new
      keyCol2 = SBOString.new
      dagJDT1 = PDAG.new
      dagJDT = PDAG.new
      dagJDT=bizObject.GetDAGNoOpen(SBOString(JDT))
      if !dagJDT
         _MEM_ASSERT(0)
         return ooNoErr
      end

      dagJDT1=bizObject.GetDAG(SBOString(JDT),ao_Arr1)
      numOfRecs=dagJDT1.GetRecordCount()
      if numOfRecs<=0
         bizObject.Message(GO_OBJ_ERROR_MSGS(JDT),10,nil,OO_ERROR)
         return ooInvalidObject
      end

      if numOfRecs==1
         dagJDT1.GetColStr(keyCol1,JDT1_TRANS_ABS)
         dagJDT1.GetColStr(keyCol2,JDT1_LINE_ID)
         if keyCol1.IsSpacesStr()||keyCol2.IsSpacesStr()
            bizObject.Message(GO_OBJ_ERROR_MSGS(JDT),10,nil,OO_ERROR)
            return ooInvalidObject
         end

      end

      return ooNoErr
   end

   def self.OJDTValidateJDTOfLocalCard(bizObject)
      trace("OJDTValidateJDTOfLocalCard")



      shortName = SBOString.new
      actCode = SBOString.new
      dagJDT = PDAG.new
      dagJDT1 = PDAG.new
      dagCRD = PDAG.new
      currency = Currency.new
      localCurr = Currency.new
      isLocalCard=false
      tmpM = MONEY.new
      bizEnv = CBizEnv.new=bizObject.GetEnv()
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
      while (rec<numOfRecs) do
         dagJDT1.GetColStr(actCode,JDT1_ACCT_NUM,rec)
         dagJDT1.GetColStr(shortName,JDT1_SHORT_NAME,rec)
         if actCode.Compare(shortName)!=0
            dagCRD=bizObject.OpenDAG(CRD)
            ooErr=bizEnv.GetByOneKey(dagCRD,OCRD_KEYNUM_PRIMARY,shortName,true)
            if ooErr
               dagCRD.Close()
               return ooNoErr
            end

            dagCRD.GetColStr(currency,OCRD_CRD_CURR)
            if GNCoinCmp(localCurr,currency)!=0
               dagCRD.Close()
               next

            else
               ooErr=OJDTCheckFcInLocalCard(bizObject,dagJDT1,rec)
               if ooErr
                  dagCRD.Close()
                  return ooErr
               end

            end

            dagCRD.Close()
         end


         (rec+=1;rec-2)
      end

      return ooNoErr
   end

   def self.OJDTCheckBalnaceTransection(bizObject,checkForgn)
      trace("OJDTCheckBalnaceTransection")
      dagJDT1 = PDAG.new=nil
      credit = MONEY.new
      debit = MONEY.new
      creditS = MONEY.new
      debitS = MONEY.new
      creditF = MONEY.new
      debitF = MONEY.new
      tmpM = MONEY.new



      dagJDT1=bizObject.GetDAGNoOpen(SBOString(JDT),ao_Arr1)
      if !dagJDT1
         _MEM_ASSERT(0)
         return ooNoErr
      end

      DAG_GetCount(dagJDT1,records)
      rec=0
      while (rec<records) do
         dagJDT1.GetColMoney(tmpM,JDT1_CREDIT,rec,DBM_NOT_ARRAY)
         ooErr=MONEY_Add(credit,tmpM)
         if ooErr
            return ooErr
         end

         dagJDT1.GetColMoney(tmpM,JDT1_DEBIT,rec,DBM_NOT_ARRAY)
         ooErr=MONEY_Add(debit,tmpM)
         if ooErr
            return ooErr
         end

         dagJDT1.GetColMoney(tmpM,JDT1_SYS_CREDIT,rec,DBM_NOT_ARRAY)
         ooErr=MONEY_Add(creditS,tmpM)
         if ooErr
            return ooErr
         end

         dagJDT1.GetColMoney(tmpM,JDT1_SYS_DEBIT,rec,DBM_NOT_ARRAY)
         ooErr=MONEY_Add(debitS,tmpM)
         if ooErr
            return ooErr
         end

         dagJDT1.GetColMoney(tmpM,JDT1_FC_CREDIT,rec,DBM_NOT_ARRAY)
         ooErr=MONEY_Add(creditF,tmpM)
         if ooErr
            return ooErr
         end

         dagJDT1.GetColMoney(tmpM,JDT1_FC_DEBIT,rec,DBM_NOT_ARRAY)
         ooErr=MONEY_Add(debitF,tmpM)
         if ooErr
            return ooErr
         end


         (rec+=1;rec-2)
      end

      if (MONEY_Cmp(credit,debit)!=0)||(MONEY_Cmp(creditS,debitS)!=0)
         return OJDTWriteErrorMessage(bizObject)
      end

      if checkForgn
         if (MONEY_Cmp(creditF,debitF)!=0)
            return OJDTWriteErrorMessage(bizObject)
         end

      end

      return ooNoErr
   end

   def self.OJDTCheckFcInLocalCard(bizObject,dagJDT1,rec)
      trace("OJDTCheckFcInLocalCard")
      tmpM = MONEY.new
      dagJDT1.GetColMoney(tmpM,JDT1_FC_CREDIT,rec)
      if tmpM!=0
         bizObject.Message(GO_OBJ_ERROR_MSGS(JDT),11,nil,OO_ERROR)
         return ooInvalidObject
      end

      dagJDT1.GetColMoney(tmpM,JDT1_FC_DEBIT,rec)
      if tmpM!=0
         bizObject.Message(GO_OBJ_ERROR_MSGS(JDT),11,nil,OO_ERROR)
         return ooInvalidObject
      end

      return ooNoErr
   end

   def self.OJDTValidateJDT1Accounts(bizObject)

      dagJDT1 = PDAG.new
      dagACT = PDAG.new
      actNum = []
      code = []

      tmpStr = SBOString.new

      tmpCurr = Currency.new
      curr = Currency.new
      bizEnv = CBizEnv.new=bizObject.GetEnv()
      dagACT=bizObject.GetDAG(ACT,ao_Main)
      dagJDT1=bizObject.GetDAG(JDT,ao_Arr1)
      numOfRecs=dagJDT1.GetRealSize(dbmDataBuffer)
      lock=!(bizObject.IsUpdateNum()||bizObject.IsExCommand3(ooEx3DontTouchNextNum))
      jj=0
      while (jj<numOfRecs) do
         dagJDT1.GetColStr(actNum,JDT1_ACCT_NUM,jj)
         if _STR_IsSpacesStr(actNum)
            return (ooInvalidAcctCode)
         end

         ooErr=bizEnv.GetByOneKey(dagACT,OACT_KEYNUM_PRIMARY,actNum,lock)
         if ooErr
            if ooErr==-2028
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
         dagJDT1.GetColStr(curr,JDT1_FC_CURRENCY,jj)
         if GNCoinCmp(tmpCurr,BAD_CURRENCY_STR)!=0
            if !_STR_SpacesString(curr,curr.size)
               if GNCoinCmp(tmpCurr,curr)!=0
                  dagACT.GetColStr(tmpStr,OACT_ACCOUNT_CODE)
                  ooErr=bizEnv.GetAccountSegmentsByCode(tmpStr,code,true)
                  if ooErr
                     return ooErr
                  end

                  bizObject.Message(OBJ_MGR_ERROR_MSG,GO_ACT_COIN_DIFFERS,code,OO_ERROR)
                  return (ooInvalidObject)
               end

            end

         end


         (jj+=1;jj-2)
      end

      return ooNoErr
   end

   def self.OJDTSetPaymentJdtOpenBalanceSums(paymentObject,dagJDT1,resDagFields,fromOffset,foundCaseK)
      trace("OJDTSetPaymentJdtOpenBalanceSums")
      actsArray = PaymentAccountsArray.new
      sboErr=0
      tmpSC = MONEY.new
      tmpFC = MONEY.new
      tmpM = MONEY.new
      sboErr=CTransactionJournalObject.OJDTFillAccountsFromJDT1RES(dagJDT1,resDagFields,actsArray)
      if sboErr
         return sboErr
      end

      sboErr=paymentObject.CalculateSplitLinesMatchSums(actsArray,false)
      if sboErr
         return sboErr
      end

      actsArraySize=actsArray.GetSize()


      closed = SBOString.new
      ii=0
      while (ii<actsArraySize) do
         dagJDT1.GetColLong(internalMatch,resDagFields[17],fromOffset+ii)
         dagJDT1.GetColLong(multMatch,resDagFields[18],fromOffset+ii)
         dagJDT1.GetColStr(closed,resDagFields[19],fromOffset+ii)
         if ((internalMatch!=0)&&(!foundCaseK))||(multMatch!=0)||(closed==VAL_YES)
            next

         end

         if actsArray[ii].GetMatchTotalLineFlag()
            tmpM=actsArray[ii].sum
            tmpFC=actsArray[ii].frgnSum
            tmpSC=actsArray[ii].sysSum
         else
            if actsArray[ii].debCred==CREDIT
               dagJDT1.GetColMoney(tmpM,resDagFields[11],fromOffset+ii)
               dagJDT1.GetColMoney(tmpFC,resDagFields[12],fromOffset+ii)
               dagJDT1.GetColMoney(tmpSC,resDagFields[13],fromOffset+ii)
            else
               dagJDT1.GetColMoney(tmpM,resDagFields[14],fromOffset+ii)
               dagJDT1.GetColMoney(tmpFC,resDagFields[15],fromOffset+ii)
               dagJDT1.GetColMoney(tmpSC,resDagFields[16],fromOffset+ii)
            end

         end

         tmpM+=actsArray[ii].GetMatchSum()
         tmpFC+=actsArray[ii].GetMatchSumFC()
         tmpSC+=actsArray[ii].GetMatchSumSC()
         if actsArray[ii].debCred==CREDIT
            dagJDT1.SetColMoney(tmpM,resDagFields[11],fromOffset+ii)
            dagJDT1.SetColMoney(tmpFC,resDagFields[12],fromOffset+ii)
            dagJDT1.SetColMoney(tmpSC,resDagFields[13],fromOffset+ii)
         else
            dagJDT1.SetColMoney(tmpM,resDagFields[14],fromOffset+ii)
            dagJDT1.SetColMoney(tmpFC,resDagFields[15],fromOffset+ii)
            dagJDT1.SetColMoney(tmpSC,resDagFields[16],fromOffset+ii)
         end


         (ii+=1;ii-2)
      end

      return 0
   end

   def self.OJDTFillAccountsFromJDT1RES(dag,resDagFields,accountsArrayRes)
      trace("OJDTFillAccountsFromJDT1RES")


      tmpStr = SBOString.new
      actStruct = SPaymentActsData.new
      numOfRecs=dag.GetRecordCount()
      rec=0
      while (rec<numOfRecs) do
         dag.GetColStr(actStruct.actCode,resDagFields[0],rec)
         dag.GetColStr(actStruct.shortName,resDagFields[1],rec)
         dag.GetColLong(actStruct.lineType,resDagFields[2],rec)
         dag.GetColStr(actStruct.srcLine,resDagFields[3],rec)
         dag.GetColStr(tmpStr,resDagFields[4],rec)
         if !dag.IsNullCol(JDT1_DPR_ABS_ID,rec)
            dag.GetColLong(actStruct.dprAbsId,JDT1_DPR_ABS_ID,rec)
         end

         if tmpStr==VAL_CREDIT
            actStruct.debCred=CREDIT
            dag.GetColMoney(actStruct.sum,resDagFields[5],rec)
            dag.GetColMoney(actStruct.frgnSum,resDagFields[6],rec)
            dag.GetColMoney(actStruct.sysSum,resDagFields[7],rec)
         else
            actStruct.debCred=DEBIT
            dag.GetColMoney(actStruct.sum,resDagFields[8],rec)
            dag.GetColMoney(actStruct.frgnSum,resDagFields[9],rec)
            dag.GetColMoney(actStruct.sysSum,resDagFields[10],rec)
         end

         accountsArrayRes.Add(actStruct.Clone())

         (rec+=1;rec-2)
      end

      return ooNoErr
   end

   def self.GetWtSumField(currSource)
      cols = []
      =""
      return cols[currSource-1]
   end

   def self.OJDTGetRate(bizObject,curSource,rate)
      currency = Currency.new
      postingDate = Date.new

      dagJDT = PDAG.new=bizObject.GetDAG()
      dagJDT.GetColLong(transType,OJDT_TRANS_TYPE)
      if transType==TRT||transType==RCR
         rate=1
      else
         case curSource

         when 2
            _STR_strcpy(currency,bizObject.GetEnv().GetSystemCurrency())

         when 3
            _STR_strcpy(currency,bizObject.GetEnv().GetMainCurrency())

         end

         dagJDT.GetColStr(postingDate,OJDT_REF_DATE)
         TZGetAndWaitUntilRate(currency,postingDate,rate,true,bizObject.GetEnv())
      end

   end

   def self.OJDTGetDocCurrency(bizObject,docCurrency)
      dagJDT = PDAG.new=bizObject.GetDAG()
      bizEnv = CBizEnv.new=bizObject.GetEnv()
      dagJDT.GetColStr(docCurrency,OJDT_TRANS_CURR)
      if _STR_IsSpacesStr(docCurrency)
         _STR_strcpy(docCurrency,bizEnv.GetMainCurrency())
      end

   end

   def self.CostAccountingAssignmentCheck(bizObject)
      sboErr=0

      accountFormat = []

      dagJDT1 = PDAG.new
      dagACT = PDAG.new
      accountCode = SBOString.new
      costAccountRelevant = SBOString.new
      costAccountingField = SBOString.new
      bizEnv = CBizEnv.new=bizObject.GetEnv()
      costAccountingRelevantFields = []
      =""
      costAccountingFields = []
      =""
      dagACT=bizObject.GetDAG(ACT,ao_Main)
      dagJDT1=bizObject.GetDAG(JDT,ao_Arr1)
      numOfRecs=dagJDT1.GetRealSize(dbmDataBuffer)
      i=0
      while (i<1+DIMENSION_MAX) do
         if bizEnv.IsCostAccountingBlocked(i)
            rec=0
            while (rec<numOfRecs) do
               dagJDT1.GetColStr(accountCode,JDT1_ACCT_NUM,rec)
               sboErr=bizEnv.GetByOneKey(dagACT,OACT_KEYNUM_PRIMARY,accountCode,true)
               if sboErr
                  if sboErr==-2028
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
                  if sboErr
                     return sboErr
                  end

                  if i
                     CMessagesManager.GetHandle().Message(_54_APP_MSG_FIN_NEED_DISTRIBUTION_RULE,EMPTY_STR,bizObject,accountFormat,i)
                  else
                     CMessagesManager.GetHandle().Message(_54_APP_MSG_FIN_NEED_PROJECT_ASSIGNMENT,EMPTY_STR,bizObject,accountFormat)
                  end

                  return ooInvalidObject
               end


               (rec+=1;rec-2)
            end

         end


         (i+=1;i-2)
      end

      return sboErr
   end

   def self.OJDTValidateCostAcountingStatus(bizObject,dagJDT)
      sboErr=0
      dagJDT1 = PDAG.new
      dagJDT1=bizObject.GetDAG(JDT,ao_Arr1)
      journalEntry = CTransactionJournalObject.new=bizObject.CreateBusinessObjectJDT
      jdtCleaner = AutoCleanBOHandler.new(journalEntry)
      journalEntry.SetDAG(dagJDT,false)
      journalEntry.SetDAG(dagJDT1,false,JDT,ao_Arr1)
      return journalEntry.ValidateCostAccountingStatus()
   end

   def self.GetTransIdByDoc(bizEnv,transId,transtype,createdby,returnMinTransId)
      sboErr=0
      begin
         dagRes = APCompanyDAG.new
         stmt = DBQRetrieveStatement.new(bizEnv)
         tJDT = DBQTable.new=stmt.From(bizEnv.ObjectToTable(JDT,ao_Main))
         stmt.Top(1)
         stmt.Select().Col(tJDT,OJDT_JDT_NUM)
         stmt.Where().Col(tJDT,OJDT_TRANS_TYPE).EQ().Val(transtype).And().Col(tJDT,OJDT_CREATED_BY).EQ().Val(createdby)
         if returnMinTransId
            stmt.OrderBy(tJDT,OJDT_JDT_NUM,false)
         else
            stmt.OrderBy(tJDT,OJDT_JDT_NUM,true)
         end

         if stmt.Execute(dagRes)>0
            dagRes.GetColLong(transId,0)
         else
            sboErr=-2028
         end

      rescue DBMException=>e
         sboErr=e.GetCode()
      end

      return sboErr
   end

   def OJDTIsDueDateRangeValid()
      trace("OJDTIsDueDateRangeValid")
      env = CBizEnv.new=GetEnv()
      if !VF_PaymentDueDate(env)||!ContainsCardLine()
         return true
      end




      ooErr=env.GetPDDData(pddEnabled,maxDaysForDueDate)
      if (ooErr!=ooNoErr)||!pddEnabled||(maxDaysForDueDate<=-1)
         return true
      end

      dagJDT = PDAG.new
      dagJDT=GetDAG()
      if !DAG_IsValid(dagJDT)||(dagJDT.GetRealSize(dbmDataBuffer)<=0)
         return true
      end


      dateField=dagJDT.GetColumnByType(DUE_DATE_FLD)
      if dateField<0
         return true
      end

      temp = SBOString.new
      ooErr=dagJDT.GetColStr(temp,dateField)
      IF_ERROR_RETURN_VALUE(ooErr,true)

      ooErr=DBM_DATE_ToLong(dueDate,temp)
      IF_ERROR_RETURN_VALUE(ooErr,true)
      dateField=dagJDT.GetColumnByType(TAX_DATE_FLD)
      if dateField<0
         return true
      end

      ooErr=dagJDT.GetColStr(temp,dateField)
      IF_ERROR_RETURN_VALUE(ooErr,true)

      ooErr=DBM_DATE_ToLong(docDate,temp)
      IF_ERROR_RETURN_VALUE(ooErr,true)
      return ((dueDate-docDate)<=maxDaysForDueDate)
   end

   def OJDTIsDocumentOrDueDateChanged()
      trace("OJDTIsDocumentOrDueDateChanged")
      dagJDT = PDAG.new
      dagJDT=GetDAG()
      return CheckColChanged(dagJDT,OJDT_TAX_DATE)||CheckColChanged(dagJDT,OJDT_DUE_DATE)
   end

   def self.WTGetBPCodeImp(dagJDT,dagJDT1)
      autoWT = SBOString.new
      dagJDT.GetColStr(autoWT,OJDT_AUTO_WT)
      autoWT.Trim()
      if autoWT==VAL_YES
         recJDT1=dagJDT1.GetRealSize(dbmDataBuffer)
         acct = SBOString.new
         shortname = SBOString.new
         rec=0
         while (rec<recJDT1) do
            dagJDT1.GetColStr(acct,JDT1_ACCT_NUM,rec)
            dagJDT1.GetColStr(shortname,JDT1_SHORT_NAME,rec)
            acct.Trim()
            shortname.Trim()
            if acct!=shortname
               return shortname
            end


            (rec+=1;rec-2)
         end

      end

      return EMPTY_STR
   end

   def self.WTGetCurrencyImp(dagJDT,dagJDT1)
      autoWT = SBOString.new
      dagJDT.GetColStr(autoWT,OJDT_AUTO_WT)
      autoWT.Trim()
      if autoWT==VAL_YES
         recJDT1=dagJDT1.GetRealSize(dbmDataBuffer)
         acct = SBOString.new
         shortname = SBOString.new
         curr = SBOString.new
         rec=0
         while (rec<recJDT1) do
            dagJDT1.GetColStr(acct,JDT1_ACCT_NUM,rec)
            dagJDT1.GetColStr(shortname,JDT1_SHORT_NAME,rec)
            dagJDT1.GetColStr(curr,JDT1_FC_CURRENCY,rec)
            acct.Trim()
            shortname.Trim()
            curr.Trim()
            if acct!=shortname
               return curr
            end


            (rec+=1;rec-2)
         end

      end

      return EMPTY_STR
   end

   def SetCurrRateForDOC(dagDOC)
      ooErr=0
      env = CBizEnv.new=GetEnv()
      rate = MONEY.new
      rateVal1 = MONEY.new
      dagJDT = PDAG.new=GetDAG(JDT)
      if !DAG.IsValid(dagDOC)
         return ooErrNoMsg
      end

      dagDOC.GetColMoney(rate,OINV_DOC_RATE)
      if rate.IsZero()
         if CalcBpCurrRateForDocRate(rate)==ooErr
            dagDOC.SetColMoney(rate,OINV_DOC_RATE)
         end

      end

      ooErr=SetSysCurrRateForDOC(dagDOC)
      return ooErr
   end

   def SetSysCurrRateForDOC(dagDOC)
      ooErr=0
      env = CBizEnv.new=GetEnv()
      rate = MONEY.new
      rateVal1 = MONEY.new
      dagJDT = PDAG.new=GetDAG(JDT)
      if !DAG.IsValid(dagDOC)
         return ooErrNoMsg
      end

      dagDOC.GetColMoney(rate,OINV_SYSTEM_RATE)
      if rate.IsPositive()
         return ooErr
      end

      sysCurrency = Currency.new
      mainCurrecny = Currency.new
      _STR_strcpy(mainCurrecny,env.GetMainCurrency().GetBuffer())
      _STR_strcpy(sysCurrency,env.GetSystemCurrency().GetBuffer())
      rateVal1.FromDouble(MONEY_PERCISION_MUL)
      sysCurrAsMain=!GNCoinCmp(sysCurrency,mainCurrecny)
      if rate.IsZero()
         rate=1
         if !sysCurrAsMain
            ooErr=nsDocument.ODOCGetAndWaitUntilRateByDag(sysCurrency,dagJDT,rate,env)
         else
            rate=rateVal1
         end

      else
         if rate.IsNegative()||(sysCurrAsMain&&(rate!=rateVal1))
            ooErr=ooErrNoMsg
         end

      end

      dagDOC.SetColMoney(rate,OINV_SYSTEM_RATE)
      if ooErr
         Message(ERROR_MESSAGES_STR,OO_ILLEGAL_SUM,sysCurrency,OO_ERROR)
         SetErrorField(OINV_SYSTEM_RATE)
         return ooErrNoMsg
      end

      return ooErr
   end

   def SetJDTLineSrc(line,absEntry,srcLine)
      trace("SetJDTLineSrc")
      ooErr=0
      dagJDT1 = PDAG.new
      dagJDT1=GetDAG(JDT,ao_Arr1)
      if !DAG_IsValid(dagJDT1)
         return (-2007)
      end

      dagJDT1.SetColLong(absEntry,JDT1_SRC_ABS_ID,line)
      dagJDT1.SetColLong(srcLine,JDT1_SRC_LINE,line)
      return ooErr
   end

   def DoSingleStorno(checkDate)
      trace("DoSingleStorno")
      ooErr=0
      fld1List = []
      =""
      fldList = []
      =""



      keyStr = []

      tmpStr = []
      tmpStr2 = []

      msgStr = []
      =""
      refDate = Date.new
      dueDate = Date.new
      taxDate = Date.new
      money = MONEY.new
      zeroM = MONEY.new
      condStruct = []

      upd = []

      colsList = DBM_CL.new
      bizEnv = CBizEnv.new=GetEnv()
      dagJDT = PDAG.new=GetDAG()
      dagJDT1 = PDAG.new=GetDAG(JDT,ao_Arr1)
      dagJDT.GetColStr(keyStr,OJDT_JDT_NUM,0)
      _STR_LRTrim(keyStr)
      dagJDT.GetColLong(transNum,OJDT_JDT_NUM,0)
      condStruct[0].colNum=OJDT_STORNO_TO_TRANS
      condStruct[0].condVal=transNum
      condStruct[0].operation=DBD_EQ
      condStruct[0].relationship=0
      DBD_SetDAGCond(dagJDT,condStruct,1)
      if DBD_Count(dagJDT,true)>0
         CMessagesManager.GetHandle().Message(_1_APP_MSG_FIN_JDT_CANCELED_ERROR2,EMPTY_STR,self,transNum)
         return ooInvalidObject
      end

      periodManager = CPeriodCache.new=bizEnv.GetPeriodCache()
      if GetDataSource()!=VAL_OBSERVER_SOURCE
         dagJDT.GetColStr(refDate,OJDT_STORNO_DATE,0)
         if checkDate&&(-222==bizEnv.CheckCompanyPeriodByDate(refDate))
            SetErrorLine(-1)
            SetErrorField(OJDT_REF_DATE)
            return (ooInvalidObject)
         end

         dagJDT.SetColStr(refDate,OJDT_REF_DATE,0)
         dagJDT.SetColStr(refDate,OJDT_TAX_DATE,0)
         DAG_GetCount(dagJDT1,count)
         rec=0
         while (rec<count) do
            dagJDT1.SetColStr(refDate,JDT1_REF_DATE,rec)
            ocrCode = SBOString.new
            dagJDT1.GetColStr(ocrCode,JDT1_OCR_CODE,rec)
            validFrom = SBOString.new
            COverheadCostRateObject.GetValidFrom(bizEnv,ocrCode,refDate.GetString(),validFrom)
            dagJDT1.SetColStr(validFrom,JDT1_VALID_FROM,rec)
            dagJDT1.SetColStr(refDate,JDT1_TAX_DATE,rec)

            (rec+=1;rec-2)
         end

      end

      dagJDT.SetColStr(EMPTY_STR,OJDT_STORNO_DATE,0)
      dagJDT.SetColStr(VAL_NO,OJDT_AUTO_STORNO,0)
      dagJDT.SetColLong(0,OJDT_NUMBER,0)
      if GetDataSource()==VAL_OBSERVER_SOURCE
         ooErr=dagJDT.GetChangesList(0,colsList)
         if ooErr
            return ooErr
         end

         keyDate = SBOString.new
         dagJDT.GetColStr(keyDate,OJDT_REF_DATE)
         if keyDate.Trim().IsEmpty()
            DBM_DATE_Get(keyDate,bizEnv)
         end

         periodID=periodManager.GetPeriodId(bizEnv,keyDate)
         DAG_GetCount(dagJDT1,count)
         ii=0
         while (ii<colsList.GetSize()) do
            case colsList[ii].GetColNum()

            when OJDT_REF_DATE
               dagJDT.GetColStr(refDate,OJDT_REF_DATE,0)
               if -222==bizEnv.CheckCompanyPeriodByDate(refDate)
                  SetErrorLine(-1)
                  SetErrorField(OJDT_REF_DATE)
                  Message(OBJ_MGR_ERROR_MSG,GO_DATE_OUT_OF_LIMIT,nil,OO_ERROR)
                  return (ooInvalidObject)
               end

               rec=0
               while (rec<count) do
                  dagJDT1.CopyColumn(dagJDT,JDT1_REF_DATE,rec,OJDT_REF_DATE,0)
                  ocrCode = SBOString.new
                  dagJDT1.GetColStr(ocrCode,JDT1_OCR_CODE,rec)
                  validFrom = SBOString.new
                  COverheadCostRateObject.GetValidFrom(bizEnv,ocrCode,refDate.GetString(),validFrom)
                  dagJDT1.SetColStr(validFrom,JDT1_VALID_FROM,rec)

                  (rec+=1;rec-2)
               end

               break
            when OJDT_DUE_DATE
               dagJDT.GetColStr(dueDate,OJDT_DUE_DATE,0)
               if !periodManager.CheckDate(periodID,dueDate.GetString(),wdDueDate)
                  SetErrorLine(-1)
                  SetErrorField(OJDT_DUE_DATE)
                  Message(OBJ_MGR_ERROR_MSG,GO_DATE_OUT_OF_LIMIT,nil,OO_ERROR)
                  return (ooInvalidObject)
               end

               rec=0
               while (rec<count) do
                  dagJDT1.CopyColumn(dagJDT,JDT1_DUE_DATE,rec,OJDT_DUE_DATE,0)

                  (rec+=1;rec-2)
               end

               break
            when OJDT_TAX_DATE
               dagJDT.GetColStr(taxDate,OJDT_TAX_DATE,0)
               if !periodManager.CheckDate(periodID,taxDate.GetString(),wdTaxDate)
                  SetErrorLine(-1)
                  SetErrorField(OJDT_TAX_DATE)
                  Message(OBJ_MGR_ERROR_MSG,GO_DATE_OUT_OF_LIMIT,nil,OO_ERROR)
                  return (ooInvalidObject)
               end

               rec=0
               while (rec<count) do
                  dagJDT1.CopyColumn(dagJDT,JDT1_TAX_DATE,rec,OJDT_TAX_DATE,0)

                  (rec+=1;rec-2)
               end

               break
            when OJDT_REF1
               rec=0
               while (rec<count) do
                  dagJDT1.CopyColumn(dagJDT,JDT1_REF1,rec,OJDT_REF1,0)

                  (rec+=1;rec-2)
               end

               break
            when OJDT_REF2
               rec=0
               while (rec<count) do
                  dagJDT1.CopyColumn(dagJDT,JDT1_REF2,rec,OJDT_REF2,0)

                  (rec+=1;rec-2)
               end

               break
            when OJDT_PROJECT
               ooErr=ValidateRelations(ao_Main,0,OJDT_PROJECT,PRJ)
               if ooErr
                  return ooErr
               end

               rec=0
               while (rec<count) do
                  dagJDT1.CopyColumn(dagJDT,JDT1_PROJECT,rec,OJDT_PROJECT,0)

                  (rec+=1;rec-2)
               end

               break
            when OJDT_INDICATOR
               ooErr=ValidateRelations(ao_Main,0,OJDT_INDICATOR,IDC)
               if ooErr
                  return ooErr
               end

               rec=0
               while (rec<count) do
                  dagJDT1.CopyColumn(dagJDT,JDT1_INDICATOR,rec,OJDT_INDICATOR,0)

                  (rec+=1;rec-2)
               end

               break
            when OJDT_TRANS_CODE
               ooErr=ValidateRelations(ao_Main,0,OJDT_TRANS_CODE,TRC)
               if ooErr
                  return ooErr
               end

               rec=0
               while (rec<count) do
                  dagJDT1.CopyColumn(dagJDT,JDT1_TRANS_CODE,rec,OJDT_TRANS_CODE,0)

                  (rec+=1;rec-2)
               end

               break
            when OJDT_MEMO
               dagJDT1.GetColStr(tmpStr,OJDT_MEMO,0)
               _STR_CleanExtendedEditMarks(tmpStr,' ')
               _STR_LRTrim(tmpStr)
               dagJDT1.SetColStr(tmpStr,OJDT_MEMO,0)
               rec=0
               while (rec<count) do
                  dagJDT1.CopyColumn(dagJDT,JDT1_LINE_MEMO,rec,OJDT_MEMO,0)

                  (rec+=1;rec-2)
               end

               break
            end


            (ii+=1;ii-2)
         end

      end

      if bizEnv.GetUseNegativeAmount()
         ii=0
         while (fldList[ii]>=0) do
            dagJDT.GetColMoney(money,fldList[ii],0,DBM_NOT_ARRAY)
            MONEY_Multiply(money,-1,money)
            dagJDT.SetColMoney(money,fldList[ii],0,DBM_NOT_ARRAY)

            (ii+=1;ii-2)
         end

         DAG_GetCount(dagJDT1,count)
         rec=0
         while (rec<count) do
            ii=0
            while (fld1List[ii]>=0) do
               dagJDT1.GetColMoney(money,fld1List[ii],rec,DBM_NOT_ARRAY)
               MONEY_Multiply(money,-1,money)
               dagJDT1.SetColMoney(money,fld1List[ii],rec,DBM_NOT_ARRAY)

               (ii+=1;ii-2)
            end


            (rec+=1;rec-2)
         end

      else
         DAG_GetCount(dagJDT1,count)
         rec=0
         while (rec<count) do
            dagJDT1.GetColMoney(money,JDT1_DEBIT,rec,DBM_NOT_ARRAY)
            if !money.IsZero()
               dagJDT1.SetColMoney(money,JDT1_CREDIT,rec,DBM_NOT_ARRAY)
               dagJDT1.SetColMoney(zeroM,JDT1_DEBIT,rec,DBM_NOT_ARRAY)
               dagJDT1.SetColStr(VAL_CREDIT,JDT1_DEBIT_CREDIT,rec)
            else
               dagJDT1.GetColMoney(money,JDT1_CREDIT,rec,DBM_NOT_ARRAY)
               if !money.IsZero()
                  dagJDT1.SetColMoney(money,JDT1_DEBIT,rec,DBM_NOT_ARRAY)
                  dagJDT1.SetColMoney(zeroM,JDT1_CREDIT,rec,DBM_NOT_ARRAY)
                  dagJDT1.SetColStr(VAL_DEBIT,JDT1_DEBIT_CREDIT,rec)
               end

            end

            dagJDT1.GetColMoney(money,JDT1_FC_DEBIT,rec,DBM_NOT_ARRAY)
            if !money.IsZero()
               dagJDT1.SetColMoney(money,JDT1_FC_CREDIT,rec,DBM_NOT_ARRAY)
               dagJDT1.SetColMoney(zeroM,JDT1_FC_DEBIT,rec,DBM_NOT_ARRAY)
               dagJDT1.SetColStr(VAL_CREDIT,JDT1_DEBIT_CREDIT,rec)
            else
               dagJDT1.GetColMoney(money,JDT1_FC_CREDIT,rec,DBM_NOT_ARRAY)
               if !money.IsZero()
                  dagJDT1.SetColMoney(money,JDT1_FC_DEBIT,rec,DBM_NOT_ARRAY)
                  dagJDT1.SetColMoney(zeroM,JDT1_FC_CREDIT,rec,DBM_NOT_ARRAY)
                  dagJDT1.SetColStr(VAL_DEBIT,JDT1_DEBIT_CREDIT,rec)
               end

            end

            dagJDT1.GetColMoney(money,JDT1_SYS_DEBIT,rec,DBM_NOT_ARRAY)
            if !money.IsZero()
               dagJDT1.SetColMoney(money,JDT1_SYS_CREDIT,rec,DBM_NOT_ARRAY)
               dagJDT1.SetColMoney(zeroM,JDT1_SYS_DEBIT,rec,DBM_NOT_ARRAY)
               dagJDT1.SetColStr(VAL_CREDIT,JDT1_DEBIT_CREDIT,rec)
            else
               dagJDT1.GetColMoney(money,JDT1_SYS_CREDIT,rec,DBM_NOT_ARRAY)
               if !money.IsZero()
                  dagJDT1.SetColMoney(money,JDT1_SYS_DEBIT,rec,DBM_NOT_ARRAY)
                  dagJDT1.SetColMoney(zeroM,JDT1_SYS_CREDIT,rec,DBM_NOT_ARRAY)
                  dagJDT1.SetColStr(VAL_DEBIT,JDT1_DEBIT_CREDIT,rec)
               end

            end


            (rec+=1;rec-2)
         end

      end

      rec=0
      while (rec<count) do
         dagJDT1.SetColLong(0,JDT1_EXTR_MATCH,rec)

         (rec+=1;rec-2)
      end

      dagJDT.GetColLong(transNum,OJDT_JDT_NUM,0)
      dagJDT.SetColLong(transNum,OJDT_STORNO_TO_TRANS,0)
      dagJDT.GetColStr(tmpStr,OJDT_MEMO,0)
      _STR_LRTrim(tmpStr)
      _STR_GetStringResource(tmpStr2,JTE_JDT_FORM_NUM,7,GetEnv())
      _STR_strcat(tmpStr,tmpStr2)
      _STR_LRTrim(tmpStr)
      _STR_ltoa(transNum,tmpStr2)
      _STR_strcat(tmpStr,_T(" - "))
      _STR_strcat(tmpStr,tmpStr2)
      dagJDT.SetColStr(tmpStr,OJDT_MEMO,0)
      _STR_GetStringResource(tmpStr2,JTE_JDT_FORM_NUM,7,GetEnv())
      _STR_LRTrim(tmpStr2)
      _STR_ltoa(transNum,tmpStr)
      _STR_strcat(tmpStr2,_T(" - "))
      _STR_strcat(tmpStr2,tmpStr)
      rec=0
      while (rec<count) do
         dagJDT1.GetColStr(tmpStr,JDT1_LINE_MEMO,rec)
         _STR_LRTrim(tmpStr)
         _STR_strcat(tmpStr,tmpStr2)
         _STR_LRTrim(tmpStr)
         dagJDT1.SetColStr(tmpStr,JDT1_LINE_MEMO,rec)
         dagJDT1.SetColStr(VAL_NO,JDT1_ORDERED,rec)

         (rec+=1;rec-2)
      end

      if VF_CostAcctingEnh(GetEnv())
         mdr = SBOString.new(MDR)
         mdrObj = CManualDistributionRuleObject.new=static_cast(GetEnv().CreateBusinessObject(mdr))
         dim = SBOString.new(DIM)
         dimInfo = []

         dimObj = CCostAccountingDimension.new=static_cast(GetEnv().CreateBusinessObject(dim))
         dimObj.DIMGetAllDimensionsInfo(dimInfo)
         mdrCodeSrc = []
         mdrCodeDst = []

         cols = []
         =""
         recCount=dagJDT1.GetRecordCount()
         j=0
         while (j<recCount) do
            i=0
            while (i<DIMENSION_MAX) do
               if dimInfo[i].DimActive
                  dagJDT1.GetColStr(mdrCodeSrc,cols[i],j)
                  if mdrObj.RuleIsManual(mdrCodeSrc)
                     mdrObj.DuplicateManualRule(mdrCodeSrc,mdrCodeDst,true)
                     dagJDT1.SetColStr(mdrCodeDst,cols[i],j)
                  end

               end


               (i+=1;i-2)
            end


            (j+=1;j-2)
         end

         dimObj.Destroy()
         mdrObj.Destroy()
      end


      dagJDT.GetColLong(servicePostingSourceId,OJDT_SERV_POST_SRC_ID)
      dagJDT.GetColLong(transType,OJDT_TRANS_TYPE)
      if transType==JDT||(transType==WTR&&VF_ExciseInvoice(bizEnv)&&self.m_isVatJournalEntry)||(transType==DLN&&VF_ServiceTax_EnabledInOADM(bizEnv)&&servicePostingSourceId>0)
         ooErr=LoadTax()
         if ooErr
            return ooErr
         end

         GetTaxAdaptor().Revert(bizEnv.GetUseNegativeAmount())
      end

      if @m_stornoExtraInfoCreator
         ooErr=@m_stornoExtraInfoCreator.Execute()
         if ooErr
            return ooErr
         end

      end

      SetCompanyPeriodByDate()
      ooErr=OnIsValid()
      if ooErr
         ResetCompanyPeriod()
         return ooErr
      end

      if VF_CashflowReport(bizEnv)
         dagCFT = PDAG.new
         dagReversalCFT = PDAG.new
         objCFTId = SBOString.new(CFT)
         dagCFT=GetDAG(CFT)
         dagJDT.GetColLong(transNum,OJDT_JDT_NUM,0)
         bo = CCashFlowTransactionObject.new=static_cast(CreateBusinessObject(CFT))
         bo.OCFTLookupByJDT(-1,transNum,-1,JDT,dagCFT)
         dagCFT.Duplicate(dagReversalCFT,dbmKeepData)
         bo.OCFTCreateReversal(dagReversalCFT,dagCFT)
         DAG_Close(dagReversalCFT)
         bo.Destroy()
      end

      if VF_FIReleaseProc(bizEnv)
         approver = SBOString.new
         CEmployeeObject.HEMGetEmployeeNameByUsrCode(approver,bizEnv,bizEnv.GetUserCode(),true)
         dagJDT.SetColStr(approver,OJDT_APPROVER_NAME,0)
      end

      ooErr=OnCreate()
      if ooErr
         ResetCompanyPeriod()
         return ooErr
      end

      ooErr=OnCheckIntegrityOnCreate()
      ResetCompanyPeriod()
      if ooErr
         return ooErr
      end

      _STR_strcpy(condStruct[0].condVal,keyStr)
      _STR_LRTrim(condStruct[0].condVal)
      condStruct[0].colNum=OJDT_JDT_NUM
      condStruct[0].operation=DBD_EQ
      upd[0].colNum=OJDT_STORNO_DATE
      upd[1].colNum=OJDT_AUTO_STORNO
      _STR_strcpy(upd[1].updateVal,VAL_NO)
      DBD_SetDAGCond(dagJDT,condStruct,1)
      DBD_SetDAGUpd(dagJDT,upd,2)
      DBD_UpdateCols(dagJDT)
      return (ooErr)
   end

   def GetBudgBlockErrorMessage(monthmoneyStr,yearmoneyStr,acctKey,messgNumber,retMsgErr)
      trace("GetBudgBlockErrorMessage")
      yearWarning = Boolean.new=false
      mformatStr = []
      =""
      yformatStr = []
      =""
      tmpStr = []
      =""
      accountFormat = []

      strKey = SBOString.new
      monSymbol = Currency.new=""
      tmpMoney = MONEY.new
      bizEnv = CBizEnv.new=GetEnv()
      strKey=acctKey
      strKey.Trim()
      _STR_strcpy(accountFormat,strKey.GetBuffer())
      bizEnv.GetAccountSegmentsByCode(accountFormat,accountFormat,true)
      _STR_strcpy(retMsgErr,_T(""))
      if bizEnv.GetBudgetWarningFrequency()==VAL_MONTHLY[0]
         _STR_GetStringResource(mformatStr,BGT0_FORM_NUM,BGT0_CHECK_MONTH_TOTAL_STR,GetEnv())
         MONEY_FromText(tmpMoney,yearmoneyStr,RC_SUM,monSymbol,bizEnv)
         if tmpMoney.IsPositive()
            _STR_GetStringResource(yformatStr,BGT0_FORM_NUM,BGT0_CHECK_YEAR_TOTAL_STR,GetEnv())
         else
            MONEY_Multiply(tmpMoney,-1,tmpMoney)
            MONEY_ToText(tmpMoney,yearmoneyStr,RC_SUM,monSymbol,bizEnv)
            _STR_GetStringResource(yformatStr,BGT0_FORM_NUM,BGT0_BLNS_YEAR_TOTAL_STR,GetEnv())
         end

      else
         yearWarning=true
         _STR_GetStringResource(yformatStr,BGT0_FORM_NUM,BGT0_CHECK_YEAR_TOTAL_STR,GetEnv())
      end

      if messgNumber==2
         _STR_strcat(mformatStr,_T("\n"))
         _STR_strcat(mformatStr,yformatStr)
         _STR_sprintf(retMsgErr,mformatStr,accountFormat,monthmoneyStr,accountFormat,yearmoneyStr)
      end

      if messgNumber==3
         _STR_sprintf(retMsgErr,yformatStr,accountFormat,yearmoneyStr)
      end

      if messgNumber==1
         if yearWarning
            _STR_sprintf(retMsgErr,yformatStr,accountFormat,yearmoneyStr)
         else
            _STR_sprintf(retMsgErr,mformatStr,accountFormat,monthmoneyStr)
         end

      end

      return ooNoErr
   end

   def IsPaymentOrdered()
      dagJDT1 = PDAG.new=GetArrayDAG(ao_Arr1)
      numOfRecs=dagJDT1.GetRecordCount()
      i=0
      while (i<numOfRecs) do
         ordered = SBOString.new
         dagJDT1.GetColStr(ordered,JDT1_ORDERED,i)
         if ordered==VAL_YES
            return true
         end


         (i+=1;i-2)
      end

      return false
   end

   def self.IsPaymentOrdered_v3(bizEnv,transId,isOrdered)
      ooErr=ooNoErr
      isOrdered=false
      begin
         stmt = DBQRetrieveStatement.new(bizEnv)
         tJDT1 = DBQTable.new=stmt.From(bizEnv.ObjectToTable(JDT,ao_Arr1))
         stmt.Select().Count()
         stmt.Where().Col(tJDT1,JDT1_TRANS_ABS).EQ().Val(transId).And().Col(tJDT1,JDT1_ORDERED).EQ().Val(VAL_YES)
         pResDag = APCompanyDAG.new
         numOfRecs=stmt.Execute(pResDag)
         if numOfRecs>=1
            isOrdered=true
         end

      rescue DBMException=>e
         ooErr=e.GetCode()
         return ooErr
      end

      return ooNoErr
   end

   def IsScAdjustment(isScAdjustment)
      dagJDT1 = PDAG.new=GetArrayDAG(ao_Arr1)
      numOfRecs=dagJDT1.GetRecordCount()
      ooErr=0
      bizEnv = CBizEnv.new=GetEnv()

      dagJDT1.GetColLong(transID,JDT1_TRANS_ABS,0)
      isScAdjustment=false
      rec=0
      while (rec<numOfRecs) do
         dagJDT1.GetColLong(lineNum,JDT1_LINE_ID,rec)
         dagRes = PDAG.new=nil
         ooErr=CManualMatchManager.GetReconciliationByTransaction(bizEnv,transID,lineNum,dagRes)
         if ooErr
            dagRes.Close()
            if ooErr=-2028
               ooErr=0
               next

            else
               return ooErr
            end

         end

         sizeOfRes=dagRes.GetRecordCount()

         i=0
         while (i<sizeOfRes) do
            dagRes.GetColLong(reconType,REC_RES_RECON_TYPE,i)
            if reconType==rt_ScAdjument
               isScAdjustment=true
               break
            end


            (i+=1;i-2)
         end

         dagRes.Close()
         if isScAdjustment
            break
         end


         (rec+=1;rec-2)
      end

      return ooNoErr
   end

   def SetContraAccounts(dagJdt1,firstRec,maxRec,contraDebKey,contraCredKey,contraDebLines,contraCredLines)
      trace("SetContraAccounts")
      tempStr = []



      debAmount = MONEY.new
      fDebAmount = MONEY.new
      sDebAmount = MONEY.new
      credAmount = MONEY.new
      fCredAmount = MONEY.new
      sCredAmount = MONEY.new
      env = CBizEnv.new=GetEnv()
      DAG_GetCount(dagJdt1,numOfRecs)
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
                  Message(OBJ_MGR_ERROR_MSG,GO_CONTRA_ACNT_MISSING,nil,OO_WARNING)
               end

            end

         end

      end

      rec=firstRec
      while (rec<maxRec) do
         dagJdt1.GetColStr(tempStr,JDT1_CONTRA_ACT,rec)
         _STR_LRTrim(tempStr)
         if tempStr[0]
            next

         end

         dagJdt1.GetColMoney(debAmount,JDT1_DEBIT,rec,DBM_NOT_ARRAY)
         dagJdt1.GetColMoney(credAmount,JDT1_CREDIT,rec,DBM_NOT_ARRAY)
         dagJdt1.GetColMoney(fDebAmount,JDT1_FC_DEBIT,rec,DBM_NOT_ARRAY)
         dagJdt1.GetColMoney(fCredAmount,JDT1_FC_CREDIT,rec,DBM_NOT_ARRAY)
         dagJdt1.GetColMoney(sDebAmount,JDT1_SYS_DEBIT,rec,DBM_NOT_ARRAY)
         dagJdt1.GetColMoney(sCredAmount,JDT1_SYS_CREDIT,rec,DBM_NOT_ARRAY)
         if debAmount.IsPositive()||fDebAmount.IsPositive()||sDebAmount.IsPositive()||credAmount.IsNegative()||fCredAmount.IsNegative()||sCredAmount.IsNegative()
            dagJdt1.SetColStr(contraCredKey,JDT1_CONTRA_ACT,rec)
         else
            if credAmount.IsPositive()||fCredAmount.IsPositive()||sCredAmount.IsPositive()||debAmount.IsNegative()||fDebAmount.IsNegative()||sDebAmount.IsNegative()
               dagJdt1.SetColStr(contraDebKey,JDT1_CONTRA_ACT,rec)
            end

         end


         (rec+=1;rec-2)
      end

   end

   def SetVatJournalEntryFlag()
      trace("SetVatJournalEntryFlag")
      @m_isVatJournalEntry=true
   end

   def GetVatJournalEntryFlag()
      return m_isVatJournalEntry
   end

   def SetJournalKeys(jrnlKeys)
      m_jrnlKeys=jrnlKeys
   end

   def GetJournalKeys(dummy0)
      return m_jrnlKeys
   end

   def GetTaxAdaptor()
      return OnGetTaxAdaptor()
   end

   def OnGetTaxAdaptor()
      trace("OnGetTaxAdaptor")
      if !@m_taxAdaptor
         @m_taxAdaptor=CTaxAdaptorJournalEntry.newself
      end

      return @m_taxAdaptor
   end

   def LoadTax()
      trace("LoadTax")
      taxAdaptor = CTaxAdaptorJournalEntry.new=OnGetTaxAdaptor()
      if !taxAdaptor
         return ooNoErr
      end

      dagJDT = PDAG.new=GetDAG()

      dagJDT.GetColLong(transId,OJDT_JDT_NUM)

      ooErr=taxAdaptor.Load(transId)
      if ooErr==-2028
         ooErr=ooNoErr
      end

      return ooErr
   end

   def CreateTax()
      trace("CreateTax")
      taxAdaptor = CTaxAdaptorJournalEntry.new=OnGetTaxAdaptor()
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

      dagJDT = PDAG.new=GetDAG()

      dagJDT.GetColLong(transId,OJDT_JDT_NUM)
      return taxAdaptor.Create(transId)
   end

   def BeforeDeleteArchivedObject(arcDelPref)
      sboErr=0
      jEPref = JECompressionPrefStruct.new
      dagDAR = PDAG.new=GetDAG(DAR)
      tempStr = SBOString.new
      dagDAR.GetColLong(jEPref.arc_entry,ODAR_ABS_ENTRY)
      dagDAR.GetColStr(tempStr,ODAR_JE_BY_PROJ)
      jEPref.byProject=tempStr[0]==VAL_YES[0]
      dagDAR.GetColStr(tempStr,ODAR_JE_BY_PROF)
      jEPref.byProfitCenter=tempStr[0]==VAL_YES[0]
      dagDAR.GetColStr(tempStr,ODAR_JE_BY_DIM2)
      jEPref.byDimension2=(tempStr==VAL_YES)
      dagDAR.GetColStr(tempStr,ODAR_JE_BY_DIM3)
      jEPref.byDimension3=(tempStr==VAL_YES)
      dagDAR.GetColStr(tempStr,ODAR_JE_BY_DIM4)
      jEPref.byDimension4=(tempStr==VAL_YES)
      dagDAR.GetColStr(tempStr,ODAR_JE_BY_DIM5)
      jEPref.byDimension5=(tempStr==VAL_YES)
      dagDAR.GetColStr(tempStr,ODAR_JE_BY_CURR)
      jEPref.byCurrency=tempStr[0]==VAL_YES[0]
      dagDAR.GetColStr(jEPref.periodLen,ODAR_JE_PERIOD_LEN)
      dagDAR.GetColStr(jEPref.ref1,ODAR_JE_REF1)
      dagDAR.GetColStr(jEPref.ref2,ODAR_JE_REF2)
      dagDAR.GetColStr(jEPref.memo,ODAR_JE_MEMO)
      dagDAR.GetColStr(jEPref.toDate,ODAR_PERIOD_DATE)
      begin
         jEComp = CJECompression.new(GetEnv(),jEPref)
         sboErr=jEComp.execute()
         if sboErr
            return sboErr
         end

      rescue nsDataArchive::CDataArchiveException=>e
         return e.GetSBOErr()
      end

      return sboErr
   end

   def AfterDeleteArchivedObject(arcDelPref)
      sboErr=0
      begin
         dagACT = PDAG.new=nil
         dagCRD = PDAG.new=nil
         sboErr=GLFillActListDAG(dagACT,GetEnv())
         if sboErr
            return sboErr
         end

         stmt = DBQRetrieveStatement.new(GetEnv())
         tCRD = DBQTable.new=stmt.From(GetEnv().ObjectToTable(CRD))
         stmt.Select().Col(tCRD,OCRD_CARD_CODE)
         stmt.Select().Col(tCRD,OCRD_CARD_NAME)
         stmt.Select().Col(tCRD,OCRD_CARD_TYPE)
         numOfReturnedRecs=stmt.Execute(dagCRD)
         sboErr=RBARebuildAccountsAndCardsInternal(dagACT,dagCRD,false)
         DAG_Close(dagCRD)
         DAG_Close(dagACT)
         if sboErr
            return sboErr
         end

      rescue DBMException=>e
         return e.GetCode()
      end

      return sboErr
   end

   def SetStornoExtraInfoCreator(stornoExtraInfoCreator)
      m_stornoExtraInfoCreator=stornoExtraInfoCreator
   end

   def UpgradeDpmLineTypeUsingJDT1(paymentObj)
      trace("UpgradeDpmLineTypeUsingJDT1")
      ooErr=0
      dagJDT1 = PDAG.new
      dagRES = PDAG.new = nil
      condStruct = []

      tableStruct = []

      joinCondStruct = []

      updStruct = []

      resStruct = []

      numOfConds=0

      tmpStr = []

      bizEnv = CBizEnv.new=GetEnv()
      dpAccount = AccountCode.new
      isIncoming=(paymentObj==RCT) ? true : false
      ooErr=ARP_GetAccountByType(bizEnv,nil,ARP_TYPE_DOWN_PAYMENT,dpAccount,true,(isIncoming ? VAL_CUSTOMER : VAL_VENDOR))
      dagJDT1=OpenDAG(JDT,ao_Arr1)
      _STR_strcpy(tableStruct[0].tableCode,bizEnv.ObjectToTable(JDT,ao_Arr1))
      _STR_strcpy(tableStruct[1].tableCode,bizEnv.ObjectToTable(paymentObj,ao_Arr2))
      _STR_strcpy(tableStruct[2].tableCode,bizEnv.ObjectToTable(CRD))
      _STR_strcpy(tableStruct[3].tableCode,bizEnv.ObjectToTable(CRD,ao_Arr3))
      _STR_strcpy(tableStruct[4].tableCode,bizEnv.ObjectToTable(JDT))
      _STR_strcpy(tableStruct[5].tableCode,bizEnv.ObjectToTable(FPR))
      _STR_strcpy(tableStruct[6].tableCode,bizEnv.ObjectToTable(ACP))
      tableStruct[1].doJoin=true
      tableStruct[1].joinedToTable=0
      tableStruct[1].numOfConds=2
      tableStruct[1].joinConds=joinCondStruct[0]
      joinCondStruct[0].compareCols=true
      joinCondStruct[0].compTableIndex=0
      joinCondStruct[0].compColNum=JDT1_CREATED_BY
      joinCondStruct[0].tableIndex=1
      joinCondStruct[0].colNum=RCT2_DOC_KEY
      joinCondStruct[0].operation=DBD_EQ
      joinCondStruct[0].relationship=DBD_AND
      joinCondStruct[1].tableIndex=0
      joinCondStruct[1].colNum=JDT1_TRANS_TYPE
      joinCondStruct[1].operation=DBD_EQ
      joinCondStruct[1].condVal=paymentObj
      tableStruct[2].doJoin=true
      tableStruct[2].joinedToTable=0
      tableStruct[2].numOfConds=1
      tableStruct[2].joinConds=joinCondStruct[2]
      joinCondStruct[2].compareCols=true
      joinCondStruct[2].compTableIndex=0
      joinCondStruct[2].compColNum=JDT1_SHORT_NAME
      joinCondStruct[2].tableIndex=2
      joinCondStruct[2].colNum=OCRD_CARD_CODE
      joinCondStruct[2].operation=DBD_EQ
      tableStruct[3].doJoin=true
      tableStruct[3].joinedToTable=2
      tableStruct[3].numOfConds=2
      tableStruct[3].outerJoin=true
      tableStruct[3].joinConds=joinCondStruct[3]
      joinCondStruct[3].compareCols=true
      joinCondStruct[3].compTableIndex=2
      joinCondStruct[3].compColNum=OCRD_CARD_CODE
      joinCondStruct[3].tableIndex=3
      joinCondStruct[3].colNum=CRD3_CARD_CODE
      joinCondStruct[3].operation=DBD_EQ
      joinCondStruct[3].relationship=DBD_AND
      joinCondStruct[4].tableIndex=3
      joinCondStruct[4].colNum=CRD3_ACCOUNT_TYPE
      joinCondStruct[4].operation=DBD_EQ
      joinCondStruct[4].condVal=ARP_TYPE_DOWN_PAYMENT
      tableStruct[4].doJoin=true
      tableStruct[4].joinedToTable=0
      tableStruct[4].numOfConds=1
      tableStruct[4].joinConds=joinCondStruct[5]
      joinCondStruct[5].compareCols=true
      joinCondStruct[5].compTableIndex=0
      joinCondStruct[5].compColNum=JDT1_TRANS_ABS
      joinCondStruct[5].tableIndex=4
      joinCondStruct[5].colNum=OJDT_JDT_NUM
      joinCondStruct[5].operation=DBD_EQ
      tableStruct[5].doJoin=true
      tableStruct[5].joinedToTable=0
      tableStruct[5].numOfConds=1
      tableStruct[5].joinConds=joinCondStruct[6]
      joinCondStruct[6].compareCols=true
      joinCondStruct[6].compTableIndex=4
      joinCondStruct[6].compColNum=OJDT_FINANCE_PERIOD
      joinCondStruct[6].tableIndex=5
      joinCondStruct[6].colNum=OFPR_ABS_ENTRY
      joinCondStruct[6].operation=DBD_EQ
      tableStruct[6].doJoin=true
      tableStruct[6].joinedToTable=0
      tableStruct[6].numOfConds=1
      tableStruct[6].outerJoin=true
      tableStruct[6].joinConds=joinCondStruct[7]
      joinCondStruct[7].compareCols=true
      joinCondStruct[7].compTableIndex=5
      joinCondStruct[7].compColNum=OFPR_CATEGORY
      joinCondStruct[7].tableIndex=6
      joinCondStruct[7].colNum=OACP_PERIOD_CAT_ID
      joinCondStruct[7].operation=DBD_EQ
      condStruct[numOfConds].compareCols=true
      condStruct[numOfConds].colNum=JDT1_SHORT_NAME
      condStruct[numOfConds].operation=DBD_NE
      condStruct[numOfConds].compColNum=JDT1_ACCT_NUM
      condStruct[numOfConds].tableIndex=0
      condStruct[(numOfConds+=1;numOfConds-2)].relationship=DBD_AND
      condStruct[numOfConds].bracketOpen=1
      condStruct[numOfConds].compareCols=true
      condStruct[numOfConds].colNum=JDT1_ACCT_NUM
      condStruct[numOfConds].operation=DBD_EQ
      condStruct[numOfConds].compColNum=CRD3_ACCOUNT_CODE
      condStruct[numOfConds].tableIndex=0
      condStruct[numOfConds].compTableIndex=3
      condStruct[(numOfConds+=1;numOfConds-2)].relationship=DBD_OR
      condStruct[numOfConds].bracketOpen=1
      condStruct[numOfConds].colNum=CRD3_ACCOUNT_TYPE
      condStruct[numOfConds].operation=DBD_IS_NULL
      condStruct[numOfConds].tableIndex=3
      condStruct[(numOfConds+=1;numOfConds-2)].relationship=DBD_AND
      condStruct[numOfConds].compareCols=true
      condStruct[numOfConds].colNum=JDT1_ACCT_NUM
      condStruct[numOfConds].tableIndex=0
      condStruct[numOfConds].compColNum=isIncoming ? OACP_ARP_C_DOWN_PAYME : OACP_ARP_V_DOWN_PAYME
      condStruct[numOfConds].compTableIndex=6
      condStruct[numOfConds].operation=DBD_EQ
      condStruct[(numOfConds+=1;numOfConds-2)].relationship=DBD_AND
      condStruct[numOfConds-1].bracketClose=2
      condStruct[numOfConds].colNum=RCT2_INVOICE_TYPE
      condStruct[numOfConds].operation=DBD_EQ
      condStruct[numOfConds].tableIndex=1
      condStruct[numOfConds].condVal=isIncoming ? DPI : DPO
      condStruct[(numOfConds+=1;numOfConds-2)].relationship=DBD_AND
      condStruct[numOfConds].colNum=RCT2_DPM_POSTED
      condStruct[numOfConds].operation=DBD_EQ
      condStruct[numOfConds].tableIndex=1
      condStruct[numOfConds].condVal=VAL_NO
      condStruct[(numOfConds+=1;numOfConds-2)].relationship=DBD_AND
      condStruct[numOfConds].bracketOpen=2
      condStruct[numOfConds].colNum=RCT2_PAID_DPM
      condStruct[numOfConds].operation=DBD_EQ
      condStruct[numOfConds].tableIndex=1
      condStruct[numOfConds].condVal=VAL_NO
      condStruct[(numOfConds+=1;numOfConds-2)].relationship=DBD_AND
      condStruct[numOfConds].colNum=isIncoming ? JDT1_CREDIT : JDT1_DEBIT
      condStruct[numOfConds].operation=DBD_GT
      condStruct[numOfConds].tableIndex=0
      condStruct[numOfConds].condVal=0
      condStruct[numOfConds].bracketClose=1
      condStruct[(numOfConds+=1;numOfConds-2)].relationship=DBD_OR
      condStruct[numOfConds].bracketOpen=1
      condStruct[numOfConds].colNum=RCT2_PAID_DPM
      condStruct[numOfConds].operation=DBD_EQ
      condStruct[numOfConds].tableIndex=1
      condStruct[numOfConds].condVal=VAL_YES
      condStruct[(numOfConds+=1;numOfConds-2)].relationship=DBD_AND
      condStruct[numOfConds].colNum=isIncoming ? JDT1_DEBIT : JDT1_CREDIT
      condStruct[numOfConds].operation=DBD_GT
      condStruct[numOfConds].tableIndex=0
      condStruct[numOfConds].condVal=0
      condStruct[numOfConds].bracketClose=2
      condStruct[(numOfConds+=1;numOfConds-2)].relationship=DBD_AND
      condStruct[numOfConds].compareCols=true
      condStruct[numOfConds].colNum=JDT1_ACCT_NUM
      condStruct[numOfConds].operation=DBD_NE
      condStruct[numOfConds].compColNum=OCRD_DEB_PAY_ACCOUNT
      condStruct[numOfConds].tableIndex=0
      condStruct[(numOfConds+=1;numOfConds-2)].compTableIndex=2
      resStruct[0].colNum=JDT1_TRANS_ABS
      resStruct[0].tableIndex=0
      resStruct[0].group_by=true
      resStruct[1].colNum=JDT1_LINE_ID
      resStruct[1].tableIndex=0
      resStruct[1].group_by=true
      resStruct[2].colNum=JDT1_CREDIT
      resStruct[2].tableIndex=0
      resStruct[2].agreg_type=DBD_MIN
      resStruct[3].colNum=JDT1_DEBIT
      resStruct[3].tableIndex=0
      resStruct[3].agreg_type=DBD_MIN
      DBD_SetDAGCond(dagJDT1,condStruct,numOfConds)
      DBD_SetDAGRes(dagJDT1,resStruct,4)
      DBD_SetTablesList(dagJDT1,tableStruct,7)
      ooErr=DBD_GetInNewFormat(dagJDT1,dagRES)
      dagRES.Detach()
      if ooErr==-2028
         DAG_Close(dagRES)
         DAG_Close(dagJDT1)
         return 0
      else
         if ooErr
            DAG_Close(dagRES)
            DAG_Close(dagJDT1)
            return ooErr
         end

      end

      DAG_GetCount(dagRES,numOfRecs)
      condStruct2 = DBD_CondStruct.new=DBD_CondStruct.new[30*2]
      acCondStruct2 = AutoCleanerArrayHandler.new(condStruct2)
      tableStruct2 = []



      tmpM = MONEY.new
      _STR_strcpy(tableStruct2[0].tableCode,bizEnv.ObjectToTable(JDT,ao_Arr1))
      updStruct[0].colNum=JDT1_LINE_TYPE

      if paymentObj==RCT
         resSumField=2
      else
         resSumField=3
      end

      jj=0
      while (jj<2) do
         rec=0
         while (rec<numOfRecs)
            if rec||jj==1
               _MEM_Clear(condStruct2,numOfConds)
            end

            numOfConds=0
            ii=0
            while (ii<30&&rec<numOfRecs) do
               dagRES.GetColMoney(tmpM,resSumField,rec)
               if tmpM==0
                  dagRES.GetColMoney(tmpM,resSumField==2 ? 3 : 2,rec)
                  tmpM*=-1
               end

               if !tmpM.IsPositive()
                  if jj==1
                     val=ooCtrlAct_PaidDPRequestType
                     updStruct[0].updateVal=val
                  else
                     next

                  end

               else
                  if tmpM.IsPositive()
                     if jj==0
                        val=ooCtrlAct_DPRequestType
                        updStruct[0].updateVal=val
                     else
                        next

                     end

                  end

               end

               condStruct2[numOfConds].bracketOpen=1
               dagRES.GetColStr(tmpStr,0,rec)
               condStruct2[numOfConds].condVal=tmpStr
               condStruct2[numOfConds].tableIndex=0
               condStruct2[numOfConds].colNum=JDT1_TRANS_ABS
               condStruct2[numOfConds].operation=DBD_EQ
               condStruct2[(numOfConds+=1;numOfConds-2)].relationship=DBD_AND
               dagRES.GetColStr(tmpStr,1,rec)
               condStruct2[numOfConds].condVal=tmpStr
               condStruct2[numOfConds].tableIndex=0
               condStruct2[numOfConds].colNum=JDT1_LINE_ID
               condStruct2[numOfConds].operation=DBD_EQ
               condStruct2[(numOfConds+=1;numOfConds-2)].relationship=DBD_OR
               condStruct2[numOfConds-1].bracketClose=1

               (ii+=1;ii-2);(rec+=1;rec-2)
            end

            if numOfConds==0
               next

            end

            condStruct2[numOfConds-1].relationship=0
            DBD_SetDAGCond(dagJDT1,condStruct2,numOfConds)
            DBD_SetTablesList(dagJDT1,tableStruct2,1)
            DBD_SetDAGUpd(dagJDT1,updStruct,1)
            ooErr=DBD_UpdateCols(dagJDT1)
            if ooErr
               DAG_Close(dagRES)
               DAG_Close(dagJDT1)
               return ooErr
            end

         end


         (jj+=1;jj-2)
      end

      DAG_Close(dagRES)
      DAG_Close(dagJDT1)
      return ooNoErr
   end

   def UpgradeDpmLineTypeUsingRCT2(object)
      trace("UpgradeDpmLineTypeUsingRCT2")
      ooErr=0
      dagRes = PDAG.new=nil
      dagQuery = PDAG.new=GetDAG()
      dpmStageArr = []
      =""
      stage=0
      while (dpmStageArr[stage]!=NOB) do
         ooErr=UpgradeDpmLineTypeExecuteQuery(dagQuery,dagRes,object,dpmStageArr[stage]==ooCtrlAct_DPRequestType)
         if ooErr==-2028
            ooErr=0
            next

         else
            if ooErr
               return ooErr
            end

         end

         ooErr=UpgradeDpmLineTypeUpdate(dagRes,object,dpmStageArr[stage]==ooCtrlAct_DPRequestType)
         if ooErr
            return ooErr
         end


         (stage+=1)
      end

      return ooErr
   end

   def UpgradeDpmLineTypeExecuteQuery(dagQuery,dagRes,object,isFirst)
      trace("UpgradeDpmLineTypeExecuteQuery")
      ooErr=0
      bizEnv = CBizEnv.new=GetEnv()
      pmtMainTableNum=0
      pmtJDT1TableNum=0
      pmtArr2TableNum=0
      resStruct = []

      resStruct[0].tableIndex=pmtMainTableNum
      resStruct[0].colNum=ORCT_ABS_ENTRY
      dagQuery.GetDBDParams().dbdResPtr=resStruct
      dagQuery.GetDBDParams().numOfResCols=1
      tablePtr = DBD_TablesList.new
      tables = DBD_CondTables.new=(dagQuery.GetDBDParams().GetCondTables())
      tablePtr=tables.AddTable()
      tablePtr.tableCode=bizEnv.ObjectToTable(object,ao_Main)
      condPtr = PDBD_Cond.new
      conditions = DBD_Conditions.new=(dagQuery.GetDBDParams().GetConditions())
      condPtr=(conditions.AddCondition())
      condPtr.tableIndex=pmtMainTableNum
      condPtr.colNum=ORCT_CANCELED
      condPtr.operation=DBD_EQ
      condPtr.condVal=VAL_NO
      condPtr.relationship=DBD_AND
      condPtr=(conditions.AddCondition())
      condPtr.tableIndex=pmtMainTableNum
      condPtr.colNum=ORCT_TYPE
      condPtr.operation=DBD_NE
      condPtr.condVal=VAL_ACCOUNT
      condPtr.relationship=DBD_AND
      condPtr=(conditions.AddCondition())
      subParams = DBD_Params.new
      condPtr.operation=DBD_NOT_EXISTS
      condPtr.SetSubQueryParams(subParams)
      condPtr.tableIndex=DBD_NO_TABLE
      condPtr.relationship=DBD_AND
      subTables = DBD_CondTables.new=(subParams.GetCondTables())
      tablePtr=subTables.AddTable()
      tablePtr.tableCode=bizEnv.ObjectToTable(JDT,ao_Arr1)
      subResStruct = []

      subResStruct[0].tableIndex=0
      subResStruct[0].colNum=JDT1_TRANS_ABS
      subConditions = DBD_Conditions.new=(subParams.GetConditions())
      condPtr=(subConditions.AddCondition())
      condPtr.origTableIndex=pmtMainTableNum
      condPtr.origTableLevel=1
      condPtr.colNum=ORCT_ABS_ENTRY
      condPtr.operation=DBD_EQ
      condPtr.compareCols=true
      condPtr.compTableIndex=pmtJDT1TableNum
      condPtr.compColNum=JDT1_CREATED_BY
      condPtr.relationship=DBD_AND
      condPtr=(subConditions.AddCondition())
      condPtr.origTableIndex=pmtMainTableNum
      condPtr.origTableLevel=1
      condPtr.colNum=ORCT_OBJECT
      condPtr.operation=DBD_EQ
      condPtr.compareCols=true
      condPtr.compTableIndex=pmtJDT1TableNum
      condPtr.compColNum=JDT1_TRANS_TYPE
      condPtr.relationship=DBD_AND
      condPtr=(subConditions.AddCondition())
      condPtr.tableIndex=pmtJDT1TableNum
      condPtr.colNum=JDT1_SHORT_NAME
      condPtr.operation=DBD_NE
      condPtr.compareCols=true
      condPtr.compTableIndex=pmtJDT1TableNum
      condPtr.compColNum=JDT1_ACCT_NUM
      condPtr.relationship=DBD_AND
      condPtr=(subConditions.AddCondition())
      condPtr.bracketOpen=1
      condPtr.tableIndex=pmtJDT1TableNum
      condPtr.colNum=JDT1_SRC_LINE
      condPtr.operation=DBD_NE
      condPtr.condVal=PMN_VAL_BOE
      condPtr.relationship=DBD_OR
      condPtr=(subConditions.AddCondition())
      condPtr.tableIndex=pmtJDT1TableNum
      condPtr.colNum=JDT1_SRC_LINE
      condPtr.operation=DBD_IS_NULL
      condPtr.bracketClose=1
      condPtr.relationship=DBD_AND
      condPtr=(subConditions.AddCondition())
      condPtr.tableIndex=pmtJDT1TableNum
      condPtr.colNum=JDT1_LINE_TYPE
      condPtr.operation=DBD_EQ
      condPtr.condVal=(isFirst) ? ooCtrlAct_DPRequestType : ooCtrlAct_PaidDPRequestType
      condPtr.relationship=0
      ooErr=DBD_SetRes(subParams,subResStruct,1)
      if ooErr
         return ooErr
      end

      condPtr=(conditions.AddCondition())
      subParamsNoOtherDocs = DBD_Params.new
      condPtr.operation=DBD_NOT_EXISTS
      condPtr.SetSubQueryParams(subParamsNoOtherDocs)
      condPtr.tableIndex=DBD_NO_TABLE
      condPtr.relationship=DBD_AND
      subTables=(subParamsNoOtherDocs.GetCondTables())
      tablePtr=subTables.AddTable()
      tablePtr.tableCode=bizEnv.ObjectToTable(object,ao_Arr2)
      subResStructNoOtherDocs = []

      subResStructNoOtherDocs[0].tableIndex=0
      subResStructNoOtherDocs[0].colNum=RCT2_DOC_KEY
      subConditions=(subParamsNoOtherDocs.GetConditions())
      condPtr=(subConditions.AddCondition())
      condPtr.origTableIndex=pmtMainTableNum
      condPtr.origTableLevel=1
      condPtr.colNum=ORCT_ABS_ENTRY
      condPtr.operation=DBD_EQ
      condPtr.compareCols=true
      condPtr.compTableIndex=pmtArr2TableNum
      condPtr.compColNum=RCT2_DOC_KEY
      condPtr.relationship=DBD_AND
      condPtr=(subConditions.AddCondition())
      condPtr.bracketOpen=1
      condPtr.tableIndex=pmtArr2TableNum
      condPtr.colNum=RCT2_INVOICE_TYPE
      condPtr.operation=DBD_NE
      condPtr.condVal=(object==RCT) ? DPI : DPO
      condPtr.relationship=DBD_OR
      condPtr=(subConditions.AddCondition())
      condPtr.tableIndex=pmtArr2TableNum
      condPtr.colNum=RCT2_DPM_POSTED
      condPtr.operation=DBD_NE
      condPtr.condVal=VAL_NO
      condPtr.relationship=DBD_OR
      condPtr=(subConditions.AddCondition())
      condPtr.tableIndex=pmtArr2TableNum
      condPtr.colNum=RCT2_PAID_DPM
      condPtr.operation=DBD_NE
      condPtr.condVal=isFirst ? VAL_NO : VAL_YES
      condPtr.relationship=0
      condPtr.bracketClose=1
      ooErr=DBD_SetRes(subParamsNoOtherDocs,subResStructNoOtherDocs,1)
      if ooErr
         return ooErr
      end

      condPtr=(conditions.AddCondition())
      condPtr.tableIndex=pmtMainTableNum
      condPtr.colNum=ORCT_NO_DOC
      condPtr.operation=DBD_NE
      condPtr.condVal=VAL_YES
      condPtr.relationship=DBD_AND
      condPtr=(conditions.AddCondition())
      condPtr.tableIndex=pmtMainTableNum
      condPtr.colNum=ORCT_NO_DOC_SUM
      condPtr.operation=DBD_EQ
      condPtr.condVal=0
      condPtr.relationship=DBD_AND
      condPtr=(conditions.AddCondition())
      condPtr.tableIndex=pmtMainTableNum
      condPtr.colNum=ORCT_NO_DOC_FRGN
      condPtr.operation=DBD_EQ
      condPtr.condVal=0
      condPtr.relationship=0
      ooErr=DBD_GetInNewFormat(dagQuery,dagRes)
      return ooErr
   end

   def UpgradeDpmLineTypeUpdate(dagRes,object,isFirst)
      trace("UpgradeDpmLineTypeUpdate")
      ooErr=0
      dagJDT1 = PDAG.new=GetDAG(JDT,ao_Arr1)
      params = DBD_Params.new
      jDT1UpdateStruct = []

      conditions = DBD_Conditions.new=(params.GetConditions())
      condPtr = PDBD_Cond.new
      jDT1UpdateStruct[0].colNum=JDT1_LINE_TYPE
      jDT1UpdateStruct[0].updateVal=isFirst ? ooCtrlAct_DPRequestType : ooCtrlAct_PaidDPRequestType
      params.dbdUpdPtr=jDT1UpdateStruct
      params.numOfUpdCols=1
      condPtr=(conditions.AddCondition())
      condPtr.tableIndex=0
      condPtr.colNum=JDT1_TRANS_TYPE
      condPtr.operation=DBD_EQ
      condPtr.condVal=object
      condPtr.relationship=DBD_AND
      condPtr=(conditions.AddCondition())
      condPtr.tableIndex=0
      condPtr.colNum=JDT1_SHORT_NAME
      condPtr.operation=DBD_NE
      condPtr.compareCols=true
      condPtr.compTableIndex=0
      condPtr.compColNum=JDT1_ACCT_NUM
      condPtr.relationship=DBD_AND
      condPtr=(conditions.AddCondition())
      condPtr.bracketOpen=1
      condPtr.tableIndex=0
      condPtr.colNum=JDT1_SRC_LINE
      condPtr.operation=DBD_NE
      condPtr.condVal=PMN_VAL_BOE
      condPtr.relationship=DBD_OR
      condPtr=(conditions.AddCondition())
      condPtr.tableIndex=0
      condPtr.colNum=JDT1_SRC_LINE
      condPtr.operation=DBD_IS_NULL
      condPtr.bracketClose=1
      condPtr.relationship=DBD_AND
      condPtr=(conditions.AddCondition())
      condPtr.tableIndex=0
      condPtr.colNum=JDT1_CREATED_BY
      condPtr.operation=DBD_EQ
      condPtr.relationship=0
      dagResSize=dagRes.GetRealSize(dbmDataBuffer)
      rec=0
      while (rec<dagResSize) do
         dagRes.GetColStr(condPtr.condVal,0,rec)
         dagJDT1.SetDBDParms(params)
         ooErr=DBD_UpdateCols(dagJDT1)
         if ooErr
            params.Clear()
            return ooErr
         end


         (rec+=1)
      end

      params.Clear()
      return ooErr
   end

   def AddRowByParent(pParentDAG,lParentRow,pChildDAG)
      lDagSize=pChildDAG.GetSize(dbmDataBuffer)
      sboErr=pChildDAG.SetSize(lDagSize+1,dbmKeepData)
      if sboErr!=0
         return sboErr
      end

      if pChildDAG.GetTableName()==m_env.ObjectToTable(JDT,ao_Arr1)&&nil!=pParentDAG
         pChildDAG.CopyColumn(pParentDAG,JDT1_TRANS_ABS,lDagSize,OJDT_JDT_NUM,lParentRow)
         pChildDAG.SetColLong(lDagSize,JDT1_LINE_ID,lDagSize)
      end

      if pChildDAG.GetTableName()==m_env.ObjectToTable(CFT,ao_Main)&&nil!=pParentDAG
         pChildDAG.CopyColumn(pParentDAG,OCFT_JDT_ID,lDagSize,JDT1_TRANS_ABS,lParentRow)
         pChildDAG.CopyColumn(pParentDAG,OCFT_JDT_LINE_ID,lDagSize,JDT1_LINE_ID,lParentRow)
      end

      return 0
   end

   def GetFirstRowByParent(pParentDAG,lParentRow,pChildDAG)
      if pChildDAG.GetTableName()==m_env.ObjectToTable(CFT,ao_Main)&&nil!=pParentDAG
         lDagSize=pChildDAG.GetSize(dbmDataBuffer)
         if lDagSize==0
            return -1
         end



         pParentDAG.GetColLong(transId,JDT1_TRANS_ABS,lParentRow)
         pParentDAG.GetColLong(lineId,JDT1_LINE_ID,lParentRow)
         ii=0
         while (ii<lDagSize) do
            pChildDAG.GetColLong(jeAbsID,OCFT_JDT_ID,ii)
            pChildDAG.GetColLong(jeLineId,OCFT_JDT_LINE_ID,ii)
            if jeAbsID==transId&&jeLineId==lineId
               return ii
            end


            (ii+=1;ii-2)
         end

      end

      if pChildDAG.GetTableName()==m_env.ObjectToTable(JDT,ao_Arr1)
         lDagSize=pChildDAG.GetSize(dbmDataBuffer)
         if lDagSize==0
            return -1
         end


         pParentDAG.GetColLong(transId,OJDT_JDT_NUM,lParentRow)
         ii=0
         while (ii<lDagSize) do
            pChildDAG.GetColLong(transAbs,JDT1_TRANS_ABS,ii)
            if transAbs==transId
               return ii
            end


            (ii+=1;ii-2)
         end

      else
         if VF_JEWHT(m_env)&&pChildDAG.GetTableName()==m_env.ObjectToTable(JDT,ao_Arr2)
            lDagSize=pChildDAG.GetSize(dbmDataBuffer)
            if lDagSize==0
               return -1
            end


            pParentDAG.GetColLong(transId,OJDT_JDT_NUM,lParentRow)
            ii=0
            while (ii<lDagSize) do
               pChildDAG.GetColLong(transAbs,JDT2_ABS_ENTRY,ii)
               if transAbs==transId
                  return ii
               end


               (ii+=1;ii-2)
            end

         else
            return CSystemBusinessObject.GetFirstRowByParent(pParentDAG,lParentRow,pChildDAG)
         end

      end

      return -1
   end

   def GetNextRow(pParentDAG,pDAG,lRow,bNext)
      if pDAG.GetTableName()==m_env.ObjectToTable(CFT,ao_Main)&&nil!=pParentDAG
         lDagSize=pDAG.GetSize(dbmDataBuffer)
         if lRow<0||lRow>=lDagSize
            return -1
         end

         delta=bNext ? 1 : -1


         pDAG.GetColLong(transAbs,OCFT_JDT_ID,lRow)
         pDAG.GetColLong(lineID,OCFT_JDT_LINE_ID,lRow)
         rec=lRow+delta
         while (bNext ? rec<lDagSize : rec>=0) do
            pDAG.GetColLong(tmpAbs,OCFT_JDT_ID,rec)
            pDAG.GetColLong(tmpLineId,OCFT_JDT_LINE_ID,rec)
            if tmpAbs==transAbs&&tmpLineId==lineID
               return rec
            end


            rec+=delta
         end

      end

      if pDAG.GetTableName()==m_env.ObjectToTable(JDT,ao_Arr1)
         lDagSize=pDAG.GetSize(dbmDataBuffer)
         if lRow<0||lRow>=lDagSize
            return -1
         end

         delta=bNext ? 1 : -1

         pDAG.GetColLong(transAbs,JDT1_TRANS_ABS,lRow)
         rec=lRow+delta
         while (bNext ? rec<lDagSize : rec>=0) do
            pDAG.GetColLong(tmpAbs,JDT1_TRANS_ABS,rec)
            if tmpAbs==transAbs
               return rec
            end


            rec+=delta
         end

      else
         if VF_JEWHT(m_env)&&pDAG.GetTableName()==m_env.ObjectToTable(JDT,ao_Arr2)
            lDagSize=pDAG.GetSize(dbmDataBuffer)
            if lRow<0||lRow>=lDagSize
               return -1
            end

            delta=bNext ? 1 : -1

            pDAG.GetColLong(transAbs,JDT2_ABS_ENTRY,lRow)
            rec=lRow+delta
            while (bNext ? rec<lDagSize : rec>=0) do
               pDAG.GetColLong(tmpAbs,JDT2_ABS_ENTRY,rec)
               if tmpAbs==transAbs
                  return rec
               end


               rec+=delta
            end

         else
            return CSystemBusinessObject.GetNextRow(pParentDAG,pDAG,lRow,bNext)
         end

      end

      return -1
   end

   def GetLogicRowCount(pParentDAG,lParentRow,pDAG)
      trace("GetLogicRowCount")
      if pDAG.GetTableName()==m_env.ObjectToTable(JDT,ao_Arr1)
         return pDAG.GetRealSize(dbmDataBuffer)
      else
         return CBusinessService.GetLogicRowCount(pParentDAG,lParentRow,pDAG)
      end

   end

   def CancelJournalEntryInObject(objectId,postingDate,taxDate,dueDate)
      trace("CancelJournalEntryInObject")
      cancelDate = SBOString.new
      sysDate = SBOString.new
      jdtNum = SBOString.new

      dagOBJ = PDAG.new=GetDAG(objectId.GetBuffer())
      colNum=dagOBJ.GetColumnByType(CREATED_JDT_NUM_FLD)
      if colNum<0
         colNum=dagOBJ.GetColumnByType(TRANS_ABS_ENT_FLD)
      end

      dagOBJ.GetColStr(jdtNum,colNum)
      ooErr=GetByKey(jdtNum,OJDT_KEYNUM_PRIMARY)
      if ooErr&&ooErr!=-2028&&ooErr!=-1025
         return ooErr
      end

      dagJDT = PDAG.new=GetDAG()
      dagJDT1 = PDAG.new=GetArrayDAG(ao_Arr1)
      ooErr=DBD_GetKeyGroup(dagJDT1,JDT1_KEYNUM_PRIMARY,jdtNum,true)
      if ooErr
         return (ooErr)
      end

      bizEnv = CBizEnv.new=GetEnv()
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

      cancelMode=2
      if postingDate.strtol()<sysDate.strtol()
         if GetExCommand2()&ooEx2SetCurrentRefDate
            cancelMode=0
         else
            cancelMode=1
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
      series=bizEnv.GetDefaultSeriesByDate(dagJDT1.GetColStr(JDT1_BPL_ID,0,coreSystemDefault).strtol(),SBOString(JDT),cancelDate)
      dagJDT.SetColLong(series,OJDT_SERIES)
      ooErr=DoSingleStorno()
      return ooErr
   end

   def self.SetJECancelDate(bizEnv,sCancelDate,dagOBJ,dagJDT,dagJDT1,taxDate,dueDate,cancelMode,sysDate)
      trace("SetJECancelDate")

      dagJDT.GetColLong(objType,OJDT_TRANS_TYPE)
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
         if 0==cancelMode
            dagJDT.SetColStr(sysDate,OJDT_DUE_DATE)
         end

      end

      dagJDT.SetColStr(sCancelDate,OJDT_STORNO_DATE)
      jdt1RecCount=dagJDT1.GetRecordCount()
      row=0
      while (row<jdt1RecCount) do
         ocrCode = SBOString.new
         dagJDT1.GetColStr(ocrCode,JDT1_OCR_CODE,row)
         validFrom = SBOString.new
         COverheadCostRateObject.GetValidFrom(bizEnv,ocrCode,sCancelDate,validFrom)
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
            if 0==cancelMode
               dagJDT1.SetColStr(sysDate,JDT1_DUE_DATE,row)
               dagJDT1.SetColStr(sysDate,JDT1_REF_DATE,row)
               dagJDT1.SetColStr(sysDate,JDT1_TAX_DATE,row)
            end

         end


         (row+=1;row-2)
      end

      dagOBJ.SetStrByColType(sCancelDate,CANCELLATION_DATE_FLD)
   end

   def self.GetOcrCodeCol(dim)
      nCol = []
      =""
      return nCol[dim]
   end

   def self.GetOcrColDimension(ocrColumn)
      case ocrColumn

      when JDT1_OCR_CODE
         return DIMENSION_1

      when JDT1_OCR_CODE2
         return DIMENSION_2

      when JDT1_OCR_CODE3
         return DIMENSION_3

      when JDT1_OCR_CODE4
         return DIMENSION_4

      when JDT1_OCR_CODE5
         return DIMENSION_5

      else
         return 0

      end

   end

   def self.GetValidFromCol(dim)
      nCol = []
      =""
      return nCol[dim]
   end

   def GetWithholdingTaxManager()
      return m_WithholdingTaxMng
   end

   def self.GetWTBaseNetAmountField(curr)
      case curr

      when INV_LOCAL_CURRENCY
         column=OJDT_WT_BASE_AMOUNT

      when INV_SYSTEM_CURRENCY
         column=OJDT_WT_BASE_AMOUNT_SC

      when INV_CARD_CURRENCY
         column=OJDT_WT_BASE_AMOUNT_FC

      end

      return column
   end

   def self.GetWTBaseVATAmountField(curr)
      case curr

      when INV_LOCAL_CURRENCY
         column=OJDT_WT_BASE_VAT_AMNT

      when INV_SYSTEM_CURRENCY
         column=OJDT_WT_BASE_VAT_AMNT_SC

      when INV_CARD_CURRENCY
         column=OJDT_WT_BASE_VAT_AMNT_FC

      end

      return column
   end

   def GetBPCurrencySource()
      currency = SBOString.new=@wTGetCurrency()
      mainCurr = SBOString.new=m_env.GetMainCurrency()
      sysCurr = SBOString.new=m_env.GetSystemCurrency()
      if currency==mainCurr||EMPTY_STR==currency||BAD_CURRENCY_STR==currency
         return INV_LOCAL_CURRENCY
      end

      if currency==sysCurr
         return INV_SYSTEM_CURRENCY
      end

      return INV_CARD_CURRENCY
   end

   def self.IsManualJE(dagJDT)
      trace("IsManualJE")
      result=false
      transType = SBOString.new
      dagJDT.GetColStr(transType,OJDT_TRANS_TYPE,0)
      transType.Trim()
      return ((transType.CompareNoCase(SBOString(JDT))==0)||(transType.CompareNoCase(SBOString(NONE_CHOICE))==0)) ? true : false
   end

   def IsCardLine(rec)
      dagJDT1 = PDAG.new
      dagJDT1=GetArrayDAG(ao_Arr1)
      if !DAG_IsValid(dagJDT1)
         throw -7755
      end


      recCount=dagJDT1.GetRealSize(dbmDataBuffer)
      if rec<0||rec>=recCount
         throw -7760
      end


      accountNumber = SBOString.new
      shortName = SBOString.new
      ooErr=dagJDT1.GetColStr(accountNumber,JDT1_ACCT_NUM,rec,false,true)
      IF_ERROR_THROW(ooErr)
      ooErr=dagJDT1.GetColStr(shortName,JDT1_SHORT_NAME,rec,false,true)
      IF_ERROR_THROW(ooErr)
      accountNumber.Trim()
      shortName.Trim()
      return (accountNumber!=shortName&&!shortName.IsEmpty())
   end

   def ContainsCardLine()
      dagJDT1 = PDAG.new
      dagJDT1=GetArrayDAG(ao_Arr1)
      if !DAG_IsValid(dagJDT1)
         throw -7755
      end


      recCount=dagJDT1.GetRealSize(dbmDataBuffer)
      rec=0
      while (rec<recCount) do
         if IsCardLine(rec)
            return true
         end


         (rec+=1)
      end

      return false
   end

   def SetPostingPreviewMode(enable = true)
      m_isPostingPreviewMode=enable
   end

   def IsPostingPreviewMode()
      return m_isPostingPreviewMode
   end

   def GetLinkMapMetaData(el)
      ooErr=CBusinessObjectBase.GetLinkMapMetaData(el)
      if ooErr
         return ooErr
      end

      dagJDT = PDAG.new=GetDAG()
      ooErr=AddLinkMapIconMetaData(el,dagJDT,OJDT_PRINTED,VAL_YES,LinkMap::ILMVertex::imdPrinted,LINKMAP_ICONSTR_PRINTED)
      if ooErr
         return ooErr
      end

      ooErr=AddLinkMapStringMetaData(el,dagJDT,OJDT_NUMBER)
      if ooErr
         return ooErr
      end

      ooErr=AddLinkMapStringMetaData(el,dagJDT,OJDT_REF_DATE)
      if ooErr
         return ooErr
      end

      ooErr=AddLinkMapStringMetaData(el,dagJDT,OJDT_MEMO)
      if ooErr
         return ooErr
      end

      return ooNoErr
   end

   def ValidateBPL(bValidateSameBPLIDOnLines)
      ooErr=0
      env = CBizEnv.new=GetEnv()
      if !VF_MultiBranch_EnabledInOADM(env)
         return 0
      end

      dagJDT = PDAG.new=GetDAG(JDT,ao_Main)
      if !DAG.IsValid(dagJDT)
         return 0
      end

      bPLIds = SBOLongSet.new
      dagJDT1 = PDAG.new=GetDAG(JDT,ao_Arr1)
      if !DAG.IsValid(dagJDT1)
         return 0
      end

      dag1Size=dagJDT1.GetRealSize(dbmDataBuffer)
      dag1Row=0
      while (dag1Row<dag1Size) do
         bPLName = SBOString.new=dagJDT1.GetColStrAndTrim(JDT1_BPL_NAME,dag1Row,coreSystemDefault)
         bPLId=dagJDT1.GetColStr(JDT1_BPL_ID,dag1Row,coreSystemDefault).strtol()
         bPLIds.insert(BPLId)
         if !CBusinessPlaceObject.IsBPLIdValidForObject(BPLId,JDT,env)
            SetArrNum(ao_Arr1)
            SetErrorLine(dag1Row+1)
            SetErrorField(JDT1_BPL_ID)
            Message(CBusinessPlaceObject::ERROR_STRING_LIST_ID,CBusinessPlaceObject::ERRMSG_CANNOT_SELECT_DISABLED_BPL_STR,BPLName,OO_ERROR)
            return ooInvalidObject
         end

         tmpUserCode = SBOString.new(env.GetUserCode())
         if !CBusinessPlaceObject.IsBPLIdAssignedToObject(env,BPLId,USR,tmpUserCode)
            SetArrNum(ao_Arr1)
            SetErrorLine(dag1Row+1)
            SetErrorField(JDT1_BPL_ID)
            bPLName = SBOString.new=dagJDT1.GetColStr(JDT1_BPL_NAME,dag1Row,coreSystemDefault).Trim()
            CMessagesManager.GetHandle().Message(_132_APP_MSG_AP_AR_USER_NOT_ASSINED_BPL,EMPTY_STR,self,BPLName)
            return ooInvalidObject
         end

         actCode = SBOString.new=dagJDT1.GetColStr(JDT1_ACCT_NUM,dag1Row,coreSystemDefault).Trim()
         shortName = SBOString.new=dagJDT1.GetColStr(JDT1_SHORT_NAME,dag1Row,coreSystemDefault).Trim()
         if actCode!=shortName
            if !CBusinessPlaceObject.IsBPLIdAssignedToObject(env,BPLId,CRD,shortName)
               SetArrNum(ao_Arr1)
               SetErrorLine(dag1Row+1)
               SetErrorField(JDT1_SHORT_NAME)
               bPLName = SBOString.new=dagJDT1.GetColStr(JDT1_BPL_NAME,dag1Row,coreSystemDefault).Trim()
               CMessagesManager.GetHandle().Message(_132_APP_MSG_AP_AR_BP_NOT_ASSIGNED_SELECTED_BPL,shortName,self,BPLName)
               return ooInvalidObject
            end

         end

         accountCols = []
         =""
         i=0
         while (accountCols[i]!=-1) do
            accountCode = SBOString.new=dagJDT1.GetColStr(accountCols[i],dag1Row,coreSystemDefault).Trim()
            if !CBusinessPlaceObject.IsBPLIdAssignedToObject(env,BPLId,ACT,accountCode)
               SetArrNum(ao_Arr1)
               SetErrorLine(dag1Row+1)
               SetErrorField(accountCols[i])
               Message(CBusinessPlaceObject::ERROR_STRING_LIST_ID,CBusinessPlaceObject::ERRMSG_ACT_BPL_DIFFER_FROM_JE_LINE_BPL_STR,accountCode,OO_ERROR)
               return ooInvalidObject
            end


            (i+=1;i-2)
         end

         if bValidateSameBPLIDOnLines&&bPLIds.size()>1
            SetArrNum(ao_Arr1)
            SetErrorLine(BPLId!=GetBPLId() ? dag1Row+1 : 1)
            SetErrorField(JDT1_BPL_ID)
            Message(CBusinessPlaceObject::ERROR_STRING_LIST_ID,CBusinessPlaceObject::ERRMSG_JDT1_BPL_DIFFER_FROM_DOCUMENT_BPL_STR,EMPTY_STR,OO_ERROR)
            return ooInvalidObject
         end


         (dag1Row+=1;dag1Row-2)
      end

      dagJDT2 = PDAG.new=GetDAG(JDT,ao_Arr2)
      if !DAG.IsValid(dagJDT2)
         return 0
      end

      dag2Size=dagJDT2.GetRealSize(dbmDataBuffer)
      dag2Row=0
      while (dag2Row<dag2Size) do
         wtaxCode = SBOString.new=dagJDT2.GetColStr(JDT2_WT_CODE,dag2Row,coreSystemDefault).Trim()
         dag1Row=-1
         dagJDT1.FindColStr(wtaxCode,JDT1_WTAX_CODE,0,dag1Row)
         if dag1Row<0
            next

         end

         bPLId=dagJDT1.GetColStr(JDT1_BPL_ID,dag1Row,coreSystemDefault).strtol()
         accountCols = []
         =""
         i=0
         while (accountCols[i]<0) do
            accountCode = SBOString.new=dagJDT2.GetColStr(accountCols[i],dag2Row,coreSystemDefault).Trim()
            if !CBusinessPlaceObject.IsBPLIdAssignedToObject(env,BPLId,ACT,accountCode)
               SetArrNum(ao_Arr1)
               SetErrorLine(dag1Row+1)
               SetErrorField(JDT1_WTAX_CODE)
               Message(CBusinessPlaceObject::ERROR_STRING_LIST_ID,CBusinessPlaceObject::ERRMSG_ACT_BPL_DIFFER_FROM_JE_LINE_BPL_STR,accountCode,OO_ERROR)
               return ooInvalidObject
            end


            (i+=1;i-2)
         end


         (dag2Row+=1;dag2Row-2)
      end

      ooErr=@isBalancedByBPL()
      if ooErr
         return ooErr
      end

      return 0
   end

   def self.ValidateBPLEx(bizObject)
      ooErr=0
      env = CBizEnv.new=bizObject.GetEnv()
      boJDT = CTransactionJournalObject.new=static_cast(env.CreateBusinessObject(SBOString(JDT)))
      acBo = AutoCleanBOHandler.new(boJDT)
      boJDT.SetDAG(bizObject.GetDAG(JDT,ao_Main),false,JDT,ao_Main)
      boJDT.SetDAG(bizObject.GetDAG(JDT,ao_Arr1),false,JDT,ao_Arr1)
      boJDT.SetDAG(bizObject.GetDAG(JDT,ao_Arr2),false,JDT,ao_Arr2)
      ooErr=boJDT.ValidateBPL(bizObject.GetID()!=SBOString(JDT) ? true : false)
      if ooErr
         return ooErr
      end

      return ooErr
   end

   def SetIsPostingTemplate(isPostingTemplate)
      m_isPostingTemplate=isPostingTemplate
   end

   def GetIsPostingTemplate()
      return m_isPostingTemplate
   end

   def OnIsValid()
      trace("OnIsValid")

      dagACT = PDAG.new
      dagCRD = PDAG.new
      dagJDT1 = PDAG.new
      dagJDT2 = PDAG.new
      dag = PDAG.new = GetDAG()
      dagNNM3 = PDAG.new
      dagCRD3 = PDAG.new


      buttons = []

      creditSumTotal = MONEY.new
      debitSumTotal = MONEY.new
      fCreditSumTotal = MONEY.new
      fDebitSumTotal = MONEY.new
      sCreditSumTotal = MONEY.new
      sDebitSumTotal = MONEY.new
      creditSum = MONEY.new
      debitSum = MONEY.new
      fCreditSum = MONEY.new
      fDebitSum = MONEY.new
      sCreditSum = MONEY.new
      sDebitSum = MONEY.new
      creditBalDue = MONEY.new
      debitBalDue = MONEY.new
      fCreditBalDue = MONEY.new
      fDebitBalDue = MONEY.new
      sCreditBalDue = MONEY.new
      sDebitBalDue = MONEY.new
      tmpM = MONEY.new
      dateStr = Date.new
      reverseDate = Date.new
      transCurr = Currency.new
      actCurr = Currency.new
      lineCurr = Currency.new
      tmpCurr = Currency.new
      curr = Currency.new
      mainCurr = Currency.new
      fromBatch = Boolean.new=false
      msgHandled = Boolean.new = false
      fromImport = Boolean.new = false
      fromEoy = Boolean.new = false
      multyFcDetected = Boolean.new
      code = []

      autoStorno = []

      autoVat = []

      nonZero = TCHAR.new
      tmpStr = []
      allowFcNotBalanced = TCHAR.new
      allowFcMulty = TCHAR.new
      actNum = []
      shortName = []

      cardType = []

      msgStr = []
      =""
      formatStr = []
      =""
      bizEnv = CBizEnv.new=GetEnv()
      cond = []


      dagJDT1=GetDAG(JDT,ao_Arr1)
      dagJDT2=GetDAG(JDT,ao_Arr2)
      DAG_GetCount(dagJDT1,numOfRecs)
      nonZero=allowFcNotBalanced=allowFcMulty=multyFcDetected=false
      _STR_GetStringResource(formatStr,HASH_FORM_NUM,HASH_TRANS_NUM_STR,GetEnv())
      if IsExCommand(ooExInternalAutoMode)&&GetExDtCommand()==ooDoNotCheckDates
         fromEoy=true
      end

      dag.GetColLong(transNum,OJDT_JDT_NUM,0)
      if transNum<0
         transNum=0
      end

      dag.GetColLong(series,OJDT_SERIES,0)
      if series
         condStruct = []

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
         if DBD_Count(dagNNM3,true)==0
            Message(JTE_JDT_FORM_NUM,22,nil,OO_ERROR)
            return ooInvalidObject
         end

         isSeriesForCncl=false
         ooErr=CNextNumbersObject.IsSeriesForCancellation(bizEnv,series,isSeriesForCncl)
         if ooErr
            return ooErr
         end

         if isSeriesForCncl
            CMessagesManager.GetHandle().Message(_147_APP_MSG_AP_AR_CANNOT_USE_CANCELLATION_SERIES,EMPTY_STR,self)
            return ooInvalidObject
         end

      end

      dag.GetColLong(canceledTrans,OJDT_STORNO_TO_TRANS,0)
      if canceledTrans>0
         condStruct = []

         condStruct[0].colNum=OJDT_JDT_NUM
         condStruct[0].condVal=canceledTrans
         condStruct[0].operation=DBD_EQ
         condStruct[0].relationship=DBD_AND
         condStruct[1].colNum=OJDT_STORNO_TO_TRANS
         _STR_strcpy(condStruct[1].condVal,STR_0)
         condStruct[1].operation=DBD_GT
         DBD_SetDAGCond(dag,condStruct,2)
         if DBD_Count(dag,true)>0
            Message(GO_OBJ_ERROR_MSGS(JDT),3,nil,OO_ERROR)
            return ooInvalidObject
         end

         if GetCurrentBusinessFlow()==bf_Create
            condStruct[0].colNum=OJDT_STORNO_TO_TRANS
            condStruct[0].condVal=canceledTrans
            condStruct[0].operation=DBD_EQ
            condStruct[0].relationship=0
            DBD_SetDAGCond(dag,condStruct,1)
            if DBD_Count(dag,true)>0
               CMessagesManager.GetHandle().Message(_1_APP_MSG_FIN_JDT_CANCELED_ERROR4,EMPTY_STR,self,canceledTrans)
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
            if DBD_Count(dag,true)>0
               Message(JTE_JDT_FORM_NUM,27,nil,OO_ERROR)
               return ooErrNoMsg
            end

         end

      end

      ooErr=IsValidUserPermissions()
      if ooErr
         return ooErr
      end

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
         dagJDT = PDAG.new=GetDAG(JDT,ao_Main)
         strBatchNum = SBOString.new
         dagJDT.GetColStr(strBatchNum,OJDT_BATCH_NUM)
         if !strBatchNum.IsNull()&&!strBatchNum.IsEmpty()
            pManager = CSupplCodeManager.new=bizEnv.GetSupplCodeManager()
            postDate = Date.new
            dagJDT.GetColStr(postDate,OJDT_REF_DATE)
            ooErr=pManager.LoadDfltCodeToDag(self,postDate)
            if ooErr
               return ooErr
            end

            ooErr=pManager.CheckCode(self)
            if ooErr
               CMessagesManager.GetHandle().Message(_54_APP_MSG_CORE_SUPPL_CODE_CODE_EXIST,EMPTY_STR,self)
               return ooErrNoMsg
            end

         end

      end

      ooErr=@validateReportEU()
      if ooErr
         return ooErr
      end

      ooErr=@validateReport347()
      if ooErr
         return ooErr
      end

      ooErr=@validateReport340()
      if ooErr
         return ooErr
      end

      if VF_JEWHT(bizEnv)
         tmpStr = SBOString.new
         dag.GetColStr(tmpStr,OJDT_AUTO_WT)
         tmpStr.Trim()
         if tmpStr==VAL_YES
            dag.GetColStr(tmpStr,OJDT_AUTO_VAT)
            tmpStr.Trim()
            if tmpStr!=VAL_YES
               Message(JTE_JDT2_FORM_NUM,25,nil,OO_ERROR)
               return ooInvalidObject
            end

         end

         if @checkWTValid()
            Message(JTE_JDT2_FORM_NUM,24,nil,OO_ERROR)
            return ooInvalidObject
         end

         if @checkMultiBP()
            SetErrorField(JDT1_SHORT_NAME)
            SetArrNum(ao_Arr1)
            Message(JTE_JDT2_FORM_NUM,23,nil,OO_ERROR)
            return ooInvalidObject
         end

         if (tmpStr==VAL_YES)&&(dagJDT2.GetRealSize(dbmDataBuffer)>0)
            ooErr=@m_WithholdingTaxMng.ODOCValidateDOC5(self,dag,dagJDT2,nil)
            if ooErr
               return ooErr
            end

         end

      end

      if VF_MultipleRegistrationNumber(bizEnv)
         ooErr=@validateHeaderLocation()
         if ooErr
            return ooErr
         end

      end

      dag.GetColStr(autoStorno,OJDT_AUTO_STORNO,0)
      if autoStorno[0]==VAL_YES[0]
         dag.GetColStr(reverseDate,OJDT_STORNO_DATE,0)
         dag.GetColStr(dateStr,OJDT_REF_DATE,0)
         if _STR_atol(reverseDate)<=_STR_atol(dateStr)
            Message(GO_OBJ_ERROR_MSGS(JDT),6,nil,OO_ERROR)
            return ooInvalidObject
         end

         useNegativeAmount=bizEnv.GetUseNegativeAmount()
         autoWt = SBOString.new
         dag.GetColStr(autoWt,OJDT_AUTO_WT,0)
         if useNegativeAmount&&autoWt==VAL_YES&&VF_JEWHT(bizEnv)
            CMessagesManager.GetHandle().Message(_1_APP_MSG_FIN_JDT_NOT_REVERSE_NEG_WT,EMPTY_STR,self)
            return ooInvalidObject
         end

         if GetCurrentBusinessFlow()==bf_Update&&!IsExCommand(ooExAddBatchNoClose)
            condStruct = []

            dag.GetColLong(canceledTrans,OJDT_JDT_NUM,0)
            condStruct[0].colNum=OJDT_JDT_NUM
            condStruct[0].condVal=canceledTrans
            condStruct[0].operation=DBD_EQ
            condStruct[0].relationship=DBD_AND
            condStruct[1].colNum=OJDT_STORNO_TO_TRANS
            _STR_strcpy(condStruct[1].condVal,STR_0)
            condStruct[1].operation=DBD_GT
            DBD_SetDAGCond(dag,condStruct,2)
            if DBD_Count(dag,true)>0
               Message(GO_OBJ_ERROR_MSGS(JDT),3,nil,OO_ERROR)
               return ooInvalidObject
            end

            condStruct[0].colNum=OJDT_STORNO_TO_TRANS
            condStruct[0].condVal=canceledTrans
            condStruct[0].operation=DBD_EQ
            condStruct[0].relationship=0
            DBD_SetDAGCond(dag,condStruct,1)
            if DBD_Count(dag,true)>0
               CMessagesManager.GetHandle().Message(_1_APP_MSG_FIN_JDT_CANCELED_ERROR3,EMPTY_STR,self,canceledTrans)
               return ooInvalidObject
            end

         end

      end

      dag.GetColStr(dateStr,OJDT_REF_DATE,0)
      DBM_DATE_ToLong(dateNum,dateStr)
      periodManager = CPeriodCache.new=bizEnv.GetPeriodCache()
      if _STR_IsSpacesStr(dateStr)
         DBM_DATE_Get(dateStr,bizEnv)
      end

      periodID=periodManager.GetPeriodId(bizEnv,dateStr.GetString())
      if -222==bizEnv.CheckCompanyPeriodByDate(dateStr.GetString())
         SetErrorField(OJDT_REF_DATE)
         return (ooInvalidObject)
      end

      dag.GetColLong(transType,OJDT_TRANS_TYPE,0)
      if bizEnv.IsBlockRefDateEdit()&&((transType>OPEN_BLNC_TYPE)||(MANUAL_BANK_TRANS_TYPE==transType))
         rec=0
         while (rec<numOfRecs) do
            dagJDT1.GetColStr(dateStr,JDT1_REF_DATE,rec)
            DBM_DATE_ToLong(tmpNum,dateStr)
            if dateNum!=tmpNum
               Message(GO_OBJ_ERROR_MSGS(JDT),8,nil,OO_ERROR)
               return ooInvalidObject
            end


            (rec+=1;rec-2)
         end

      end

      dag.GetColStr(dateStr,OJDT_TAX_DATE,0)
      DBM_DATE_ToLong(dateNum,dateStr)
      if dateNum<=0
         dag.CopyColumn(dag,OJDT_TAX_DATE,0,OJDT_REF_DATE,0)
         dag.GetColStr(dateStr,OJDT_TAX_DATE,0)
      end

      if !fromEoy&&!periodManager.CheckDate(periodID,dateStr.GetString(),wdTaxDate)
         SetErrorField(OJDT_TAX_DATE)
         Message(OBJ_MGR_ERROR_MSG,GO_DATE_OUT_OF_LIMIT,nil,OO_ERROR)
         return (ooInvalidObject)
      end

      dag.GetColStr(dateStr,OJDT_DUE_DATE,0)
      DBM_DATE_ToLong(dateNum,dateStr)
      if dateNum<=0
         dag.CopyColumn(dag,OJDT_DUE_DATE,0,OJDT_REF_DATE,0)
         dag.GetColStr(dateStr,OJDT_DUE_DATE,0)
      end

      if !fromEoy&&!periodManager.CheckDate(periodID,dateStr.GetString(),wdDueDate)
         SetErrorField(OJDT_DUE_DATE)
         Message(OBJ_MGR_ERROR_MSG,GO_DATE_OUT_OF_LIMIT,nil,OO_ERROR)
         return (ooInvalidObject)
      end

      if VF_HideAutoVAT(bizEnv)
         if GetDataSource()==VAL_OBSERVER_SOURCE
            dag = PDAG.new=GetDAG()
            isAutoVat = SBOString.new
            dag.GetColStr(isAutoVat,OJDT_AUTO_VAT,0)
            if isAutoVat==VAL_YES
               SetErrorField(OJDT_AUTO_VAT)
               return ooInvalidObject
            end

         end

      end

      if VF_GBInterface(bizEnv)&&bizEnv.IsGBInterfaceSupport()
         docType = SBOString.new
         dag.GetColStr(docType,OJDT_DOC_TYPE,0)
         docType.Trim()
         if docType.IsEmpty()
            docType=bizEnv.GetDefaultJEType()
            dag.SetColStr(docType,OJDT_DOC_TYPE,0)
         end

      end

      if IsExCommand(ooExAddBatchNoClose)
         fromBatch=true
      end

      if IsExCommand(ooImportData)
         fromImport=true
      end

      if GetCurrentBusinessFlow()==bf_Create
         blockDunningLetter = SBOString.new
         dag.GetColStr(blockDunningLetter,OJDT_BLOCK_DUNNING_LETTER)
         if blockDunningLetter==VAL_YES&&!IsBlockDunningLetterUpdateable()
            SetErrorField(OJDT_BLOCK_DUNNING_LETTER)
            return -1029
         end

      end

      dagACT=GetDAG(ACT)
      dagCRD=GetDAG(CRD)
      dagCRD3=GetDAG(CRD,ao_Arr3)
      transCurr[0]=0
      dag.GetColStr(autoVat,OJDT_AUTO_VAT,0)
      _STR_strcpy(mainCurr,bizEnv.GetMainCurrency())
      rec=0
      while (rec<numOfRecs) do
         dagJDT1.GetColLong(transNum,JDT1_TRANS_ABS,rec)
         if transNum<0
            transNum=0
         end

         if bizEnv.IsVatPerLine()||bizEnv.IsVatPerCard()
            dagJDT1.GetColStr(tmpStr,bizEnv.IsVatPerLine() ? JDT1_VAT_GROUP : JDT1_TAX_CODE,rec)
            if _STR_IsSpacesStr(tmpStr)
               dagJDT1.GetColMoney(tmpM,JDT1_BASE_SUM,rec,DBM_NOT_ARRAY)
               if !tmpM.IsZero()
                  SetErrorLine(rec+1)
                  SetErrorField(JDT1_BASE_SUM)
                  SetArrNum(ao_Arr1)
                  Message(GO_OBJ_ERROR_MSGS(JDT),5,nil,OO_ERROR)
                  return (ooInvalidObject)
               end

            else
               if bizEnv.IsVatPerCard()
                  if autoVat[0]==VAL_NO[0]
                     SetErrorLine(rec+1)
                     SetErrorField(JDT1_TAX_CODE)
                     SetArrNum(ao_Arr1)
                     Message(JTE_JDT_FORM_NUM,26,nil,OO_ERROR)
                     return (ooInvalidObject)
                  end

                  if VF_InactiveTaxSTC(bizEnv)
                     ooErr=nsDocument.CheckTaxCodeInactive(bizEnv,tmpStr)
                     if ooErr
                        SetArrNum(ao_Arr1)
                        SetErrorField(JDT1_TAX_CODE)
                        SetErrorLine(rec+1)
                        return ooErr
                     end

                  end

               else
                  if bizEnv.IsVatPerLine()
                     if VF_InactiveTaxVTG(bizEnv)
                        ooErr=nsDocument.CheckVatGroupInactive(bizEnv,tmpStr)
                        if ooErr
                           SetArrNum(ao_Arr1)
                           SetErrorField(JDT1_VAT_GROUP)
                           SetErrorLine(rec+1)
                           return ooErr
                        end

                     end

                  end

               end

            end

         end

         if (bizEnv.IsVatPerLine()||bizEnv.IsVatPerCard())&&GetDataSource()==VAL_OBSERVER_SOURCE&&GetCurrentBusinessFlow()==bf_Create&&autoVat[0]==VAL_NO[0]
            dagJDT1.GetColMoney(tmpM,JDT1_VAT_AMOUNT,rec,DBM_NOT_ARRAY)
            if !tmpM.IsZero()
               SetErrorLine(rec+1)
               SetErrorField(JDT1_VAT_AMOUNT)
               SetArrNum(ao_Arr1)
               Message(JTE_JDT_FORM_NUM,26,nil,OO_ERROR)
               return (ooInvalidObject)
            end

            dagJDT1.GetColMoney(tmpM,JDT1_SYS_VAT_AMOUNT,rec,DBM_NOT_ARRAY)
            if !tmpM.IsZero()
               SetErrorLine(rec+1)
               SetErrorField(JDT1_SYS_VAT_AMOUNT)
               SetArrNum(ao_Arr1)
               Message(JTE_JDT_FORM_NUM,26,nil,OO_ERROR)
               return (ooInvalidObject)
            end

            dagJDT1.GetColMoney(tmpM,JDT1_GROSS_VALUE,rec,DBM_NOT_ARRAY)
            if !tmpM.IsZero()
               SetErrorLine(rec+1)
               SetErrorField(JDT1_GROSS_VALUE)
               SetArrNum(ao_Arr1)
               Message(JTE_JDT_FORM_NUM,26,nil,OO_ERROR)
               return (ooInvalidObject)
            end

            dagJDT1.GetColMoney(tmpM,JDT1_GROSS_VALUE_FC,rec,DBM_NOT_ARRAY)
            if !tmpM.IsZero()
               SetErrorLine(rec+1)
               SetErrorField(JDT1_GROSS_VALUE_FC)
               SetArrNum(ao_Arr1)
               Message(JTE_JDT_FORM_NUM,26,nil,OO_ERROR)
               return (ooInvalidObject)
            end

            dagJDT1.GetColStr(tmpStr,JDT1_TAX_POSTING_ACCOUNT,rec)
            if tmpStr[0]!=VAL_NO[0]
               SetErrorLine(rec+1)
               SetErrorField(JDT1_TAX_POSTING_ACCOUNT)
               SetArrNum(ao_Arr1)
               Message(JTE_JDT_FORM_NUM,26,nil,OO_ERROR)
               return (ooInvalidObject)
            end

         end

         ooErr=ValidateRelations(ao_Arr1,rec,JDT1_PROJECT,PRJ)
         if ooErr
            return ooErr
         end

         if VF_MultipleRegistrationNumber(bizEnv)
            ooErr=ValidateRowLocation(rec)
            if ooErr
               return ooErr
            end

         end

         if GetDataSource()==VAL_OBSERVER_SOURCE
            ooErr=IsPaymentBlockValid(dagJDT1,rec)
            if ooErr
               return ooErr
            end

         end

         if GetCurrentBusinessFlow()==bf_Create
            if bizEnv.IsVatPerLine()
               if !(VF_AmountDifferences(m_env)&&(GetExCommand2()&ooEx2IgnoreVatAccount))
                  ooErr=ValidateRelations(ao_Arr1,rec,JDT1_VAT_GROUP,VTG)
               end

            else
               ooErr=ValidateRelations(ao_Arr1,rec,JDT1_TAX_CODE,STC)
            end

            if ooErr
               return ooErr
            end

         end

         dagJDT1.GetColStr(dateStr,JDT1_DUE_DATE,rec)
         if !fromEoy
            if !periodManager.CheckDate(periodID,dateStr.GetString(),wdDueDate)
               SetErrorLine(rec+1)
               SetErrorField(JDT1_DUE_DATE)
               SetArrNum(ao_Arr1)
               Message(OBJ_MGR_ERROR_MSG,GO_DATE_OUT_OF_LIMIT,nil,OO_ERROR)
               return (ooInvalidObject)
            end

            dagJDT1.GetColStr(dateStr,JDT1_REF_DATE,rec)
            if !periodManager.CheckDate(periodID,dateStr.GetString(),wdRefDate)
               SetErrorLine(rec+1)
               SetErrorField(JDT1_REF_DATE)
               SetArrNum(ao_Arr1)
               Message(OBJ_MGR_ERROR_MSG,GO_DATE_OUT_OF_LIMIT,nil,OO_ERROR)
               return ooInvalidObject
            end

            dagJDT1.GetColStr(dateStr,JDT1_TAX_DATE,rec)
            DBM_DATE_ToLong(dateNum,dateStr)
            if dateNum<=0
               dagJDT1.CopyColumn(dagJDT1,JDT1_TAX_DATE,rec,JDT1_REF_DATE,rec)
               dagJDT1.GetColStr(dateStr,JDT1_TAX_DATE,rec)
            end

            if !periodManager.CheckDate(periodID,dateStr.GetString(),wdTaxDate)
               SetErrorLine(rec+1)
               SetErrorField(JDT1_TAX_DATE)
               SetArrNum(ao_Arr1)
               Message(OBJ_MGR_ERROR_MSG,GO_DATE_OUT_OF_LIMIT,nil,OO_ERROR)
               return ooInvalidObject
            end

         end

         dagJDT1.GetColMoney(creditSum,JDT1_CREDIT,rec,DBM_NOT_ARRAY)
         dagJDT1.GetColMoney(debitSum,JDT1_DEBIT,rec,DBM_NOT_ARRAY)
         dagJDT1.GetColMoney(fCreditSum,JDT1_FC_CREDIT,rec,DBM_NOT_ARRAY)
         dagJDT1.GetColMoney(fDebitSum,JDT1_FC_DEBIT,rec,DBM_NOT_ARRAY)
         dagJDT1.GetColMoney(sCreditSum,JDT1_SYS_CREDIT,rec,DBM_NOT_ARRAY)
         dagJDT1.GetColMoney(sDebitSum,JDT1_SYS_DEBIT,rec,DBM_NOT_ARRAY)
         dagJDT1.GetColMoney(creditBalDue,JDT1_BALANCE_DUE_CREDIT,rec,DBM_NOT_ARRAY)
         dagJDT1.GetColMoney(debitBalDue,JDT1_BALANCE_DUE_DEBIT,rec,DBM_NOT_ARRAY)
         dagJDT1.GetColMoney(fCreditBalDue,JDT1_BALANCE_DUE_FC_CRED,rec,DBM_NOT_ARRAY)
         dagJDT1.GetColMoney(fDebitBalDue,JDT1_BALANCE_DUE_FC_DEB,rec,DBM_NOT_ARRAY)
         dagJDT1.GetColMoney(sCreditBalDue,JDT1_BALANCE_DUE_SC_CRED,rec,DBM_NOT_ARRAY)
         dagJDT1.GetColMoney(sDebitBalDue,JDT1_BALANCE_DUE_SC_DEB,rec,DBM_NOT_ARRAY)
         if !creditSum.IsZero()&&!debitSum.IsZero()
            SetErrorLine(rec+1)
            SetErrorField(JDT1_DEBIT)
            SetArrNum(ao_Arr1)
            Message(GO_OBJ_ERROR_MSGS(JDT),4,nil,OO_ERROR)
            return ooInvalidObject
         end

         if !sCreditSum.IsZero()&&!sDebitSum.IsZero()
            SetErrorLine(rec+1)
            SetErrorField(JDT1_SYS_CREDIT)
            SetArrNum(ao_Arr1)
            Message(GO_OBJ_ERROR_MSGS(JDT),4,nil,OO_ERROR)
            return ooInvalidObject
         end

         if !creditSum.IsZero()||!debitSum.IsZero()||!fCreditSum.IsZero()||!fDebitSum.IsZero()||!sCreditSum.IsZero()||!sDebitSum.IsZero()||!creditBalDue.IsZero()||!debitBalDue.IsZero()||!fCreditBalDue.IsZero()||!fDebitBalDue.IsZero()||!sCreditBalDue.IsZero()||!sDebitBalDue.IsZero()
            nonZero=true
         end

         MONEY_Add(creditSumTotal,creditSum)
         MONEY_Add(debitSumTotal,debitSum)
         MONEY_Add(fCreditSumTotal,fCreditSum)
         MONEY_Add(fDebitSumTotal,fDebitSum)
         MONEY_Add(sCreditSumTotal,sCreditSum)
         MONEY_Add(sDebitSumTotal,sDebitSum)
         dagJDT1.GetColStr(actNum,JDT1_ACCT_NUM,rec)
         if _STR_IsSpacesStr(actNum)
            SetErrorLine(rec+1)
            SetErrorField(JDT1_ACCT_NUM)
            SetArrNum(ao_Arr1)
            return ooInvalidAcctCode
         end

         ooErr=bizEnv.GetByOneKey(dagACT,OACT_KEYNUM_PRIMARY,actNum,true)
         if ooErr
            SetErrorLine(rec+1)
            SetErrorField(JDT1_ACCT_NUM)
            SetArrNum(ao_Arr1)
            if ooErr==-2028
               return ooInvalidAcctCode
            else
               return ooErr
            end

         end

         if bizEnv.IsLocalSettingsFlag(lsf_EnableSegmentAcct)
            dagACT.GetColStr(code,OACT_FORMAT_CODE,0)
            GetEnv().AddSegmentSeperator(code)
         else
            dagACT.GetColStr(code,OACT_ACCOUNT_CODE,0)
         end

         dagACT.GetColStr(tmpStr,OACT_POSTABLE,0)
         if _STR_strcmp(tmpStr,VAL_YES)!=0
            SetErrorLine(rec+1)
            SetErrorField(JDT1_ACCT_NUM)
            SetArrNum(ao_Arr1)
            Message(OBJ_MGR_ERROR_MSG,GO_NON_POSTABLE_ACT_IN_TRANS_MSG,code,OO_ERROR)
            return ooInvalidObject
         end

         dagACT.GetColStr(tmpCurr,OACT_ACT_CURR,0)
         dagJDT1.GetColStr(curr,JDT1_FC_CURRENCY,rec)
         if GNCoinCmp(tmpCurr,BAD_CURRENCY_STR)!=0
            if !_STR_SpacesString(curr,curr.size)
               if GNCoinCmp(tmpCurr,curr)!=0
                  Message(OBJ_MGR_ERROR_MSG,GO_ACT_COIN_DIFFERS,code,OO_ERROR)
                  return ooInvalidObject
               end

            end

         end

         dagJDT1.GetColStr(shortName,JDT1_SHORT_NAME,rec)
         if _STR_stricmp(actNum,shortName)==0
            dagACT.GetColStr(tmpStr,OACT_LOC_MAN_TRAN,0)
            if tmpStr[0]==VAL_YES[0]
               SetErrorLine(rec+1)
               SetErrorField(JDT1_ACCT_NUM)
               SetArrNum(ao_Arr1)
               Message(OBJ_MGR_ERROR_MSG,GO_CONTROLING_ACT_IN_TRANS_MSG,code,OO_ERROR)
               return ooInvalidObject
            end

            SetErrorLine(rec+1)
            SetErrorField(JDT1_ACCT_NUM)
            SetArrNum(ao_Arr1)
            checkDate = SBOString.new
            dagJDT1.GetColStr(checkDate,JDT1_REF_DATE,rec)
            ooErr=OOCheckObjectActive(self,dagACT,-1,actNum,checkDate)
            if ooErr
               return ooErr
            end

            SetErrorLine(-1)
            SetErrorField(-1)
            dagACT.GetColStr(actCurr,OACT_ACT_CURR,0)
            _STR_LRTrim(actCurr)
         else
            ooErr=bizEnv.GetByOneKey(dagCRD,OCRD_KEYNUM_PRIMARY,shortName,true)
            if ooErr
               SetErrorLine(rec+1)
               SetErrorField(JDT1_SHORT_NAME)
               SetArrNum(ao_Arr1)
               if ooErr==-2028
                  Message(OBJ_MGR_ERROR_MSG,GO_CRD_NAME_MISSING,shortName,OO_ERROR)
                  return ooInvalidObject
               else
                  return ooErr
               end

            end

            dagCRD.GetColStr(cardType,OCRD_CARD_TYPE,0)
            if _STR_strcmp(cardType,VAL_LEAD)==0
               SetErrorLine(rec+1)
               SetErrorField(JDT1_SHORT_NAME)
               SetArrNum(ao_Arr1)
               Message(OBJ_MGR_ERROR_MSG,7,shortName,OO_ERROR)
               return ooInvalidObject
            end

            dagACT.GetColStr(tmpStr,OACT_LOC_MAN_TRAN,0)
            if tmpStr[0]==VAL_NO[0]
               SetErrorLine(rec+1)
               SetArrNum(ao_Arr1)
               SetErrorField(JDT1_ACCT_NUM)
               Message(OBJ_MGR_ERROR_MSG,GO_CONTROLING_ACT_IN_TRANS_MSG,code,OO_ERROR)
               return ooInvalidObject
            end

            dagCRD.GetColStr(tmpStr,OCRD_DEB_PAY_ACCOUNT,0)
            if _STR_IsSpacesStr(tmpStr)
               SetErrorLine(rec+1)
               SetErrorField(JDT1_ACCT_NUM)
               SetArrNum(ao_Arr1)
               Message(OBJ_MGR_ERROR_MSG,GO_ILLEGAL_CODE,code,OO_ERROR)
               return ooInvalidObject
            end

            dagCRD.GetColStr(actCurr,OCRD_CRD_CURR,0)
            _STR_LRTrim(actCurr)
            SetErrorLine(rec+1)
            SetErrorField(JDT1_SHORT_NAME)
            SetArrNum(ao_Arr1)
            if !fromEoy&&!bizEnv.IsDuringUpgradeProcess()
               checkDate = SBOString.new
               dagJDT1.GetColStr(checkDate,JDT1_REF_DATE,rec)
               ooErr=OOCheckObjectActive(self,dagCRD,-1,shortName,checkDate)
               if ooErr
                  return ooErr
               end

               ooErr=OOCheckObjectActive(self,dagACT,-1,actNum,checkDate)
               if ooErr
                  return ooErr
               end

            end

            SetErrorLine(-1)
            SetErrorField(-1)
         end

         lineCurr[0]=0
         if !fCreditSum.IsZero()
            dagJDT1.GetColStr(lineCurr,JDT1_FC_CURRENCY,rec)
            if IsCurValid(lineCurr,nil)!=0
               SetErrorLine(rec+1)
               Message(OBJ_MGR_ERROR_MSG,GO_INVALID_COIN,lineCurr,OO_ERROR)
               return (ooInvalidObject)
            end

         end

         if !fDebitSum.IsZero()
            dagJDT1.GetColStr(lineCurr,JDT1_FC_CURRENCY,rec)
            if IsCurValid(lineCurr,nil)!=0
               SetErrorLine(rec+1)
               Message(OBJ_MGR_ERROR_MSG,GO_INVALID_COIN,lineCurr,OO_ERROR)
               return (ooInvalidObject)
            end

         end

         _STR_LRTrim(lineCurr)
         allowFcMulty=true
         if bizEnv.GetMultiCurrencyWarningLevel()==VAL_BLOCK
            allowFcMulty=false
         end

         if IsExCommand(ooDontValidateData2)
            allowFcMulty=true
         end

         if IsExCommand(ooExTempData1)
            allowFcMulty=true
         end

         if lineCurr[0]&&GNCoinCmp(actCurr,BAD_CURRENCY_STR)!=0&&GNCoinCmp(lineCurr,actCurr)!=0&&GNCoinCmp(actCurr,mainCurr)!=0
            SetErrorLine(rec+1)
            if fromImport
               _STR_GetStringResource(msgStr,OBJ_MGR_ERROR_MSG,GO_HASH_TRANSACTION_NOT_BALANCED,GetEnv())
               _STR_sprintf(tmpStr,msgStr,transNum,GetErrorLine())
               _STR_sprintf(tmpStr,_T("%s , %s"),tmpStr,shortName)
               Message(OBJ_MGR_ERROR_MSG,GO_ACT_COIN_DIFFERS,tmpStr,OO_ERROR)
            else
               Message(OBJ_MGR_ERROR_MSG,GO_ACT_COIN_DIFFERS,nil,OO_ERROR)
               return (ooInvalidObject)
            end

         end

         if transCurr[0]&&lineCurr[0]&&GNCoinCmp(lineCurr,transCurr)!=0
            if !allowFcMulty
               SetErrorLine(rec+1)
               if fromImport&&!msgHandled
                  msgHandled=true
                  _STR_GetStringResource(msgStr,OBJ_MGR_ERROR_MSG,GO_HASH_TRANSACTION_NOT_BALANCED,GetEnv())
                  _STR_sprintf(tmpStr,msgStr,transNum,GetErrorLine())
                  Message(OBJ_MGR_ERROR_MSG,GO_DIFFERENT_COIN,tmpStr,OO_ERROR)
               else
                  if !fromImport
                     Message(OBJ_MGR_ERROR_MSG,GO_DIFFERENT_COIN,nil,OO_ERROR)
                  end

               end

               if !fromImport&&!fromBatch
                  return (ooInvalidObject)
               end

            end

            multyFcDetected=true
         end

         if !transCurr[0]
            _STR_strcpy(transCurr,lineCurr)
         end


         (rec+=1;rec-2)
      end

      rec=0
      while (rec<numOfRecs) do
         exist = Boolean.new
         dagJDT1.GetColStr(tmpStr,JDT1_CONTRA_ACT,rec)
         _STR_LRTrim(tmpStr)
         if tmpStr[0]
            exist=false
            i=0
            while (i<numOfRecs) do
               dagJDT1.GetColStr(shortName,JDT1_SHORT_NAME,i)
               _STR_LRTrim(shortName)
               if _STR_stricmp(tmpStr,shortName)==0
                  exist=true
                  break
               end


               (i+=1;i-2)
            end

            if !exist
               dag.GetColLong(transType,OJDT_TRANS_TYPE,0)
               if GetDataSource()==VAL_OBSERVER_SOURCE&&!((transType==VPM&&numOfRecs==2)||(transType==RCT&&numOfRecs==2))
                  SetErrorLine(rec+1)
                  SetErrorField(JDT1_CONTRA_ACT)
                  SetArrNum(ao_Arr1)
                  Message(OBJ_MGR_ERROR_MSG,GO_ILLEGAL_CODE,tmpStr,OO_ERROR)
                  return ooErrNoMsg
               else
                  dagJDT1.SetColStr(EMPTY_STR,JDT1_CONTRA_ACT,rec)
               end

            end

         end


         (rec+=1;rec-2)
      end

      ooErr=ValidateCostAccountingStatus()
      if ooErr
         return ooErr
      end

      if VF_CashflowReport(bizEnv)
         dagCFT = PDAG.new
         locMoney = MONEY.new
         sysMoney = MONEY.new
         fcMoney = MONEY.new
         jdt1LocMoney = MONEY.new
         jdt1SysMoney = MONEY.new
         jdt1FcMoney = MONEY.new

         objCFTId = SBOString.new(CFT)
         dagCFT=GetDAGNoOpen(objCFTId)
         if dagCFT
            bo = CCashFlowTransactionObject.new=static_cast(CreateBusinessObject(CFT))
            dag.GetColStr(dateStr,OJDT_REF_DATE,0)
            bo.OCFTAssmInDag(dagCFT,dateStr)
            dag.GetColLong(tmpTransNum,OJDT_JDT_NUM,0)
            if tmpTransNum==0
               tmpTransNum=-1
            end

            isAllCashRelevant=true
            rec=0
            while (rec<numOfRecs) do
               dagJDT1.GetColStr(actNum,JDT1_SHORT_NAME,rec)
               boCOA = CChartOfAccounts.new=static_cast(CreateBusinessObject(ACT))
               boCOA.IsCFWRelevant(actNum,isCashFlowRelevant)
               boCOA.Destroy()
               if !isCashFlowRelevant
                  isAllCashRelevant=false
                  break
               end


               (rec+=1;rec-2)
            end

            rec=0
            while (rec<numOfRecs) do
               isDebit = Boolean.new
               existCFT = Boolean.new
               dagJDT1.GetColStr(actNum,JDT1_SHORT_NAME,rec)
               boCOA = CChartOfAccounts.new=static_cast(CreateBusinessObject(ACT))
               boCOA.IsCFWRelevant(actNum,isCashFlowRelevant)
               boCOA.Destroy()
               if isCashFlowRelevant
                  dagJDT1.GetColMoney(jdt1LocMoney,JDT1_CREDIT,rec,DBM_NOT_ARRAY)
                  dagJDT1.GetColMoney(jdt1FcMoney,JDT1_FC_CREDIT,rec,DBM_NOT_ARRAY)
                  dagJDT1.GetColMoney(jdt1SysMoney,JDT1_SYS_CREDIT,rec,DBM_NOT_ARRAY)
                  isDebit=false
                  if jdt1LocMoney.IsZero()==true
                     dagJDT1.GetColMoney(jdt1LocMoney,JDT1_DEBIT,rec,DBM_NOT_ARRAY)
                     dagJDT1.GetColMoney(jdt1FcMoney,JDT1_FC_DEBIT,rec,DBM_NOT_ARRAY)
                     dagJDT1.GetColMoney(jdt1SysMoney,JDT1_SYS_DEBIT,rec,DBM_NOT_ARRAY)
                     isDebit=true
                  end

                  bo.OCFTLineExistInDag(dagCFT,tmpTransNum,rec,existCFT)
                  if existCFT==false
                     if GetEnv().IsCFWAssignMandatory()==true&&!isAllCashRelevant
                        bo.Destroy()
                        OOMessage(self,GO_OBJ_ERROR_MSGS(CFT),CFT_MANDATORY_ERROR,nil,OO_ERROR)
                        return (ooErrNoMsg)
                     else
                        next

                     end

                  end

                  bo.OCFTGetSumInDag(dagCFT,tmpTransNum,rec,isDebit,locMoney,sysMoney,fcMoney)
                  if MONEY_Cmp(locMoney,jdt1LocMoney)!=0||MONEY_Cmp(fcMoney,jdt1FcMoney)!=0||MONEY_Cmp(sysMoney,jdt1SysMoney)!=0
                     if bo.OCFTAutoBalanceInDag(dagCFT,tmpTransNum,rec,isDebit,jdt1LocMoney,jdt1SysMoney,jdt1FcMoney)!=ooNoErr
                        jdt1DebLocMoney = MONEY.new
                        jdt1DebSysMoney = MONEY.new
                        jdt1DebFcMoney = MONEY.new
                        dagJDT1.GetColMoney(jdt1DebLocMoney,JDT1_CREDIT,rec,DBM_NOT_ARRAY)
                        dagJDT1.GetColMoney(jdt1DebFcMoney,JDT1_FC_CREDIT,rec,DBM_NOT_ARRAY)
                        dagJDT1.GetColMoney(jdt1DebSysMoney,JDT1_SYS_CREDIT,rec,DBM_NOT_ARRAY)
                        jdt1CredLocMoney = MONEY.new
                        jdt1CredSysMoney = MONEY.new
                        jdt1CredFcMoney = MONEY.new
                        dagJDT1.GetColMoney(jdt1CredLocMoney,JDT1_DEBIT,rec,DBM_NOT_ARRAY)
                        dagJDT1.GetColMoney(jdt1CredFcMoney,JDT1_FC_DEBIT,rec,DBM_NOT_ARRAY)
                        dagJDT1.GetColMoney(jdt1CredSysMoney,JDT1_SYS_DEBIT,rec,DBM_NOT_ARRAY)
                        debLocMoney = MONEY.new
                        debSysMoney = MONEY.new
                        debFcMoney = MONEY.new
                        bo.OCFTGetSumInDag(dagCFT,tmpTransNum,rec,true,debLocMoney,debSysMoney,debFcMoney)
                        credLocMoney = MONEY.new
                        credSysMoney = MONEY.new
                        credFcMoney = MONEY.new
                        bo.OCFTGetSumInDag(dagCFT,tmpTransNum,rec,false,credLocMoney,credSysMoney,credFcMoney)
                        if jdt1DebLocMoney-debLocMoney!=jdt1CredLocMoney-credLocMoney||jdt1DebSysMoney-debSysMoney!=jdt1CredSysMoney-credSysMoney||jdt1DebFcMoney-debFcMoney!=jdt1CredFcMoney-credFcMoney
                           bo.Destroy()
                           OOMessage(self,GO_OBJ_ERROR_MSGS(CFT),CFT_UNBALANCED_TRANS_ERROR,nil,OO_ERROR)
                           return (ooInvalidObject)
                        end

                     end

                  end

               end


               (rec+=1;rec-2)
            end

            bo.Destroy()
         end

      end

      if IsExCommand(ooExTempData1)
         SetExDtCommand(ooDoAsUpgrade,fa_SetSolo)
      end

      if !IsExDtCommand(ooDoAsUpgrade)
         if MONEY_Cmp(creditSumTotal,debitSumTotal)||MONEY_Cmp(sCreditSumTotal,sDebitSumTotal)
            if fromBatch
               buttons[0]=FU_DIALOG_SUSPEND_STR
               buttons[1]=FU_DIALOG_CONTINUE_STR
               buttons[2]=FU_DIALOG_EMPTY_STR
               msgHandled=true
               retVal=FUEnhDialogBox(nil,ERROR_MESSAGES_STR,OO_TRANSACTION_NOT_BALANCED,FU_DIALOG_ALERT_ICON,buttons,2,formOKReturn)
               if retVal==formOKReturn
                  return (ooTransNotBalanced)
               end

            else
               _STR_sprintf(tmpStr,formatStr,transNum)
               if fromImport
                  if !msgHandled
                     msgHandled=true
                     Message(ERROR_MESSAGES_STR,OO_TRANSACTION_NOT_BALANCED,tmpStr,OO_ERROR)
                  end

               else
                  Message(ERROR_MESSAGES_STR,OO_TRANSACTION_NOT_BALANCED,tmpStr,OO_ERROR)
                  return (ooTransNotBalanced)
               end

            end

         end

         allowFcNotBalanced=true
         if bizEnv.GetFCBalanceWarningLevel()==VAL_BLOCK
            allowFcNotBalanced=false
         end

         if IsExCommand(ooDontValidateData1)
            allowFcNotBalanced=true
         end

         if MONEY_Cmp(fCreditSumTotal,fDebitSumTotal)
            if allowFcMulty&&multyFcDetected
               allowFcNotBalanced=true
            end

            if !allowFcNotBalanced
               if fromBatch&&!msgHandled
                  if !multyFcDetected
                     buttons[0]=FU_DIALOG_SUSPEND_STR
                     buttons[1]=FU_DIALOG_CONTINUE_STR
                     buttons[2]=FU_DIALOG_EMPTY_STR
                     msgHandled=true
                     retVal=FUEnhDialogBox(nil,ERROR_MESSAGES_STR,OO_TRANSACTION_NOT_BALANCED,FU_DIALOG_ALERT_ICON,buttons,2,formOKReturn)
                     if retVal==formOKReturn
                        return (ooTransNotBalanced)
                     end

                  end

               else
                  if !msgHandled
                     _STR_sprintf(tmpStr,formatStr,transNum)
                     Message(ERROR_MESSAGES_STR,OO_TRANSACTION_NOT_BALANCED,tmpStr,OO_ERROR)
                     if fromImport
                        msgHandled=true
                     else
                        return (ooTransNotBalanced)
                     end

                  end

               end

            end

         end

      end

      if !transCurr[0]
         _STR_strcpy(transCurr,bizEnv.GetMainCurrency())
      else
         if multyFcDetected
            _STR_strcpy(transCurr,BAD_CURRENCY_STR)
         else
            _STR_strcpy(lineCurr,transCurr)
         end

      end

      dag.SetColStr(lineCurr,OJDT_TRANS_CURR,0)
      if VF_MultiBranch_EnabledInOADM(bizEnv)
         ooErr=ValidateBPL()
         if ooErr
            return ooErr
         end

      end

      if IsExCommand(ooDontCheckTranses)
         return ooNoErr
      end

      if nonZero==false
         if transType!=IPF&&!(transType==IQR&&GetEnv().IsContInventory())
            dag.SetErrorTable(GetEnv().ObjectToTable(JDT))
            Message(ERROR_MESSAGES_STR,OO_ZERO_TRANSACTION,nil,OO_ERROR)
            return (ooErrNoMsg)
         end

      end

      if VF_ExciseInvoice(bizEnv)
         plaAct = SBOString.new=bizEnv.GetGLAccountManager().GetAccountByDate(EMPTY_STR,mat_plaAct)
         plaAct.TrimRight()
         numOfRec=dagJDT1.GetRecordCount()


         strFlag = SBOString.new
         dag.GetColStr(strFlag,OJDT_GEN_REG_NO,0)
         strFlag.Trim()
         rec=0
         while (rec<numOfRec) do
            tgtAct = SBOString.new
            dagJDT1.GetColStr(tgtAct,JDT1_ACCT_NUM,rec)
            tgtAct.TrimRight()
            if tgtAct==plaAct
               next

            end

            dagJDT1.GetColLong(mat_type,JDT1_MATERIAL_TYPE,rec)
            dagJDT1.GetColLong(cenvat,JDT1_CENVAT_COM,rec)
            if !isValidCENVAT(cenvat)&&!isValidMatType(mat_type)
               next

            else
               if isValidCENVAT(cenvat)&&isValidMatType(mat_type)
                  mattypeOJDT=0
                  if strFlag==VAL_YES
                     dag.GetColLong(mattypeOJDT,OJDT_MAT_TYPE,0)
                     if mat_type!=mattypeOJDT
                        Message(ERROR_MESSAGES_STR,225,nil,OO_ERROR)
                        return ooInvalidObject
                     end

                  end

               else
                  Message(ERROR_MESSAGES_STR,223,nil,OO_ERROR)
                  return ooInvalidObject
               end

            end


            (rec+=1;rec-2)
         end

      end

      if VF_MultipleRegistrationNumber(bizEnv)
         genRegNumFlag = SBOString.new
         dagJDT = PDAG.new=GetDAG()
         dagJDT.GetColStr(genRegNumFlag,OJDT_GEN_REG_NO,0)
         genRegNumFlag.Trim()
         if genRegNumFlag==VAL_YES
            dagJDT.GetColLong(matType,OJDT_MAT_TYPE,0)
            dagJDT.GetColLong(location,OJDT_LOCATION,0)
            dagERX = PDAG.new=OpenDAG(ERX)
            condStruct = []

            condStruct[0].colNum=OERX_LOC_ID
            condStruct[0].operation=DBD_EQ
            condStruct[0].condVal=location
            DBD_SetDAGCond(dagERX,condStruct,1)
            result=DBD_Count(dagERX,true)
            dagERX.Close()
            if !result
               Message(EXCISE_NUMBER_STR_LIST,EXCISE_NUMBER_NOT_DEF_ERR,nil,OO_ERROR)
               return ooInvalidObject
            end

         end

      end

      if VF_PaymentTraceability(bizEnv)
         dagJDT = PDAG.new=GetDAG()
         cigId = SBOString.new
         cupId = SBOString.new
         desc = SBOString.new
         dagJDT.GetColStr(cigId,OJDT_CIG)
         dagJDT.GetColStr(cupId,OJDT_CUP)
         cigId.Trim()
         cupId.Trim()
         if CCigObject.GetDescription(bizEnv,cigId,desc)!=0
            dag.SetErrorTable(GetEnv().ObjectToTable(JDT))
            SetErrorField(OJDT_CIG)
            CMessagesManager.GetHandle().Message(_54_APP_MSG_FIN_CIG_DOES_NOT_EXIST,EMPTY_STR,self)
            return -10
         end

         if CCupObject.GetDescription(bizEnv,cupId,desc)!=0
            dag.SetErrorTable(GetEnv().ObjectToTable(JDT))
            SetErrorField(OJDT_CUP)
            CMessagesManager.GetHandle().Message(_54_APP_MSG_FIN_CUP_DOES_NOT_EXIST,EMPTY_STR,self)
            return -10
         end

         numOfRec=dagJDT1.GetRecordCount()
         rec=0
         while (rec<numOfRec) do
            dagJDT1.GetColStr(cigId,JDT1_CIG,rec)
            dagJDT1.GetColStr(cupId,JDT1_CUP,rec)
            if CCigObject.GetDescription(bizEnv,cigId,desc)!=0
               SetErrorLine(rec+1)
               SetErrorField(JDT1_CIG)
               SetArrNum(ao_Arr1)
               CMessagesManager.GetHandle().Message(_54_APP_MSG_FIN_CIG_DOES_NOT_EXIST,EMPTY_STR,self)
               return -10
            end

            if CCupObject.GetDescription(bizEnv,cupId,desc)!=0
               SetErrorLine(rec+1)
               SetErrorField(JDT1_CUP)
               SetArrNum(ao_Arr1)
               CMessagesManager.GetHandle().Message(_54_APP_MSG_FIN_CUP_DOES_NOT_EXIST,EMPTY_STR,self)
               return -10
            end


            (rec+=1;rec-2)
         end

      end

      if JDT==transType
         validator = CEarlierPostingDateValidator.new(self,false,_1_APP_MSG_BANK_BLOCK_DOC_WITH_EARLIER_POSTING_DATE)
         ooErr=validator.CheckBlockDocFromEarlierPostingDate()
         if ooErr
            return ooErr
         end

      end

      if GetDataSource()==VAL_OBSERVER_SOURCE&&VF_DeferredTaxInJE(bizEnv)
         if !CJDTDeferredTaxUtil(self).IsValid()
            return -10
         end

      end

      return ooNoErr
   end

   def OnCreate()
      trace("OnCreate")
      ooErr=0
      dagJDT = PDAG.new
      dagJDT1 = PDAG.new
      dagCRD = PDAG.new
      dagRES = PDAG.new
      blockLevel=0
      typeBlockLevel = 0

      recCount=0
      ii = 0
      retVal=0


      lastContraRec=0
      contraCredLines = 0
      contraDebLines = 0


      monSymbol = Currency.new=""
      debAmount = MONEY.new
      credAmount = MONEY.new
      transTotal = MONEY.new
      transTotalChk = MONEY.new
      transTotalCredChk = MONEY.new
      transTotalDebChk = MONEY.new
      sTransTotalDebChk = MONEY.new
      sTransTotalCredChk = MONEY.new
      fTransTotalDebChk = MONEY.new
      fTransTotalCredChk = MONEY.new
      fTransTotal = MONEY.new
      fDebAmount = MONEY.new
      fCredAmount = MONEY.new
      sTransTotal = MONEY.new
      sDebAmount = MONEY.new
      sCredAmount = MONEY.new
      rateMoney = MONEY.new
      tempMoney = MONEY.new
      bgtMonthOver = MONEY.new
      bgtYearOver = MONEY.new
      creditBalDue = MONEY.new
      debitBalDue = MONEY.new
      fCreditBalDue = MONEY.new
      fDebitBalDue = MONEY.new
      sCreditBalDue = MONEY.new
      sDebitBalDue = MONEY.new
      acctKey = []
      tempStr = []

      contraCredKey = []
      contraDebKey = []

      cardKey = []

      sp_Name = []
      =""
      mainCurr = []
      =""
      frnCurr = []
      = ""
      tmpStr = []
      =""
      msgStr1 = []
      =""
      msgStr2 = []
      = ""
      moneyStr = []
      =""
      moneyMonthStr = []
      = ""
      moneyYearStr = []
      = ""
      acctCode = []
      =""
      doAlert = TCHAR.new
      alrType = TCHAR.new
      balanced = Boolean.new=false
      budgetAllYes = Boolean.new=false
      bgtDebitSize = Boolean.new
      fromImport = Boolean.new=false
      itsCard = Boolean.new
      qc = Boolean.new
      res = []

      upd = []

      bizEnv = CBizEnv.new=GetEnv()
      bpBalanceLogDataArray = BPBalanceChangeLogDataArr.new
      qc=false
      dagJDT=GetDAG()
      dagJDT1=GetDAG(JDT,ao_Arr1)
      dagJDT2 = PDAG.new=GetDAG(JDT,ao_Arr2)
      if !dagJDT2.GetRealSize(dbmDataBuffer)
         dagJDT2.SetSize(0,dbmDropData)
      end

      dagCRD=GetDAG(CRD)
      if GetDataSource()==VAL_OBSERVER_SOURCE&&bizEnv.IsVatPerLine()
         DAG_GetCount(dagJDT1,numOfRecs)
         rec=0
         while (rec<numOfRecs) do
            dagJDT1.GetColStr(tmpStr,JDT1_VAT_LINE,rec)
            if tmpStr[0]==VAL_YES[0]
               dagJDT1.GetColMoney(debAmount,JDT1_DEBIT,rec,DBM_NOT_ARRAY)
               dagJDT1.GetColMoney(credAmount,JDT1_CREDIT,rec,DBM_NOT_ARRAY)
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


            (rec+=1;rec-2)
         end

      end

      @setDebitCreditField()
      contraCredKey[0]='\0'
      contraDebKey[0]='\0'
      transTotal.SetToZero()
      transTotalChk.SetToZero()
      fTransTotal.SetToZero()
      sTransTotal.SetToZero()
      _STR_strcpy(mainCurr,bizEnv.GetMainCurrency())
      _STR_LRTrim(mainCurr)
      dagJDT.GetColMoney(rateMoney,OJDT_TRANS_RATE,0,DBM_NOT_ARRAY)
      dagJDT.GetColStr(tempStr,OJDT_ORIGN_CURRENCY,0)
      _STR_LRTrim(tempStr)
      if GNCoinCmp(tempStr,mainCurr)==0||rateMoney.IsZero()
         tempStr[0]=0
      end

      DAG_GetCount(dagJDT1,numOfRecs)
      if VF_RmvZeroLineFromJE(bizEnv)&&!bizEnv.IsZeroLineAllowed()
         rec=0
         while (rec<numOfRecs) do
            dagJDT1.GetColMoney(debAmount,JDT1_DEBIT,rec)
            dagJDT1.GetColMoney(credAmount,JDT1_CREDIT,rec)
            dagJDT1.GetColMoney(fDebAmount,JDT1_FC_DEBIT,rec)
            dagJDT1.GetColMoney(fCredAmount,JDT1_FC_CREDIT,rec)
            dagJDT1.GetColMoney(sDebAmount,JDT1_SYS_DEBIT,rec)
            dagJDT1.GetColMoney(sCredAmount,JDT1_SYS_CREDIT,rec)
            debBalanceDue = MONEY.new
            credBalanceDue = MONEY.new
            fDebBalanceDue = MONEY.new
            fCredBalanceDue = MONEY.new
            sDebBalanceDue = MONEY.new
            sCredBalanceDue = MONEY.new
            dagJDT1.GetColMoney(debBalanceDue,JDT1_BALANCE_DUE_DEBIT,rec)
            dagJDT1.GetColMoney(credBalanceDue,JDT1_BALANCE_DUE_CREDIT,rec)
            dagJDT1.GetColMoney(fDebBalanceDue,JDT1_BALANCE_DUE_FC_DEB,rec)
            dagJDT1.GetColMoney(fCredBalanceDue,JDT1_BALANCE_DUE_FC_CRED,rec)
            dagJDT1.GetColMoney(sDebBalanceDue,JDT1_BALANCE_DUE_SC_DEB,rec)
            dagJDT1.GetColMoney(sCredBalanceDue,JDT1_BALANCE_DUE_SC_CRED,rec)
            if debAmount.IsZero()&&credAmount.IsZero()&&fDebAmount.IsZero()&&fCredAmount.IsZero()&&sDebAmount.IsZero()&&sCredAmount.IsZero()&&debBalanceDue.IsZero()&&credBalanceDue.IsZero()&&fDebBalanceDue.IsZero()&&fCredBalanceDue.IsZero()&&sDebBalanceDue.IsZero()&&sCredBalanceDue.IsZero()
               dagJDT1.RemoveRecord(rec)
               (rec-=1;rec+2)
               (numOfRecs-=1;numOfRecs+2)
            end


            (rec+=1;rec-2)
         end

      end

      dagJDT.GetColLong(transType,OJDT_TRANS_TYPE)
      if transType==-1
         dagJDT.SetColLong(JDT,OJDT_TRANS_TYPE)
         transType=JDT
      end

      deferredTax = SBOString.new
      dagJDT.GetColStr(deferredTax,OJDT_DEFERRED_TAX)
      deferredTax.Trim()
      isDeferredTax=(deferredTax==VAL_YES)
      rec=0
      while (rec<numOfRecs) do
         dagJDT1.GetColStr(acctKey,JDT1_ACCT_NUM,rec)
         dagJDT1.GetColStr(cardKey,JDT1_SHORT_NAME,rec)
         itsCard=(_STR_stricmp(acctKey,cardKey)!=0)&&(!_STR_IsSpacesStr(cardKey))
         if itsCard
            bpBalanceChangeLogData = CBPBalanceChangeLogData.new(bizEnv)
            bpBalanceChangeLogData.SetCode(cardKey)
            bpBalanceChangeLogData.SetControlAcct(acctKey)
            bpBalanceChangeLogData.SetDocType(JDT)
            ooErr=bizEnv.GetByOneKey(dagCRD,GO_PRIMARY_KEY_NUM,cardKey,true)
            if ooErr!=0
               if ooErr==-2028
                  Message(OBJ_MGR_ERROR_MSG,GO_CARD_NOT_FOUND_MSG,cardKey,OO_ERROR)
                  return (ooErrNoMsg)
               else
                  return ooErr
               end

            end

            dagCRD.GetColMoney(tempMoney,OCRD_CURRENT_BALANCE)
            bpBalanceChangeLogData.SetOldAcctBalanceLC(tempMoney)
            dagCRD.GetColMoney(tempMoney,OCRD_F_BALANCE)
            bpBalanceChangeLogData.SetOldAcctBalanceFC(tempMoney)
            bpBalanceLogDataArray.Add(bpBalanceChangeLogData)
         end

         if _STR_IsSpacesStr(acctKey)
            dagJDT1.CopyColumn(GetDAG(CRD),JDT1_ACCT_NUM,rec,OCRD_DEB_PAY_ACCOUNT,0)
            dagJDT1.GetColStr(acctKey,JDT1_ACCT_NUM,rec)
         end

         ooErr=bizEnv.GetByOneKey(GetDAG(ACT),GO_PRIMARY_KEY_NUM,acctKey,true)
         if ooErr!=0
            if ooErr==-2028
               Message(OBJ_MGR_ERROR_MSG,GO_ACT_MISSING,acctKey,OO_ERROR)
               return (ooErrNoMsg)
            else
               return ooErr
            end

         end

         ocrCode = SBOString.new
         dagAct = PDAG.new
         jdtOcrCols = []
         =""
         actOcrCols = []
         =""
         dimentionLen=VF_CostAcctingEnh(GetEnv()) ? DIMENSION_MAX : 1
         dagAct=GetDAG(ACT)
         dim=0
         while (dim<dimentionLen) do
            if dagJDT1.IsNullCol(jdtOcrCols[dim],rec)
               dagAct.GetColStr(ocrCode,actOcrCols[dim],0)
               if !ocrCode.Trim().IsEmpty()
                  dagJDT1.SetColStr(ocrCode,jdtOcrCols[dim],rec)
               end

            end


            (dim+=1;dim-2)
         end

         dagJDT1.GetColStr(ocrCode,JDT1_OCR_CODE,rec)
         postDate = SBOString.new
         validFrom = SBOString.new
         dagJDT1.GetColStr(postDate,JDT1_REF_DATE,rec)
         ooErr=COverheadCostRateObject.GetValidFrom(bizEnv,ocrCode,postDate,validFrom)
         if ooErr
            SetErrorField(JDT1_VALID_FROM)
            SetErrorLine(rec+1)
            return ooErr
         end

         dagJDT1.SetColStr(validFrom,JDT1_VALID_FROM,rec)
         dagJDT1.GetColMoney(debAmount,JDT1_DEBIT,rec,DBM_NOT_ARRAY)
         dagJDT1.GetColMoney(credAmount,JDT1_CREDIT,rec,DBM_NOT_ARRAY)
         dagJDT1.GetColMoney(fDebAmount,JDT1_FC_DEBIT,rec,DBM_NOT_ARRAY)
         dagJDT1.GetColMoney(fCredAmount,JDT1_FC_CREDIT,rec,DBM_NOT_ARRAY)
         dagJDT1.GetColMoney(sDebAmount,JDT1_SYS_DEBIT,rec,DBM_NOT_ARRAY)
         dagJDT1.GetColMoney(sCredAmount,JDT1_SYS_CREDIT,rec,DBM_NOT_ARRAY)
         MONEY_Add(transTotal,debAmount)
         MONEY_Add(transTotalChk,credAmount)
         MONEY_Add(fTransTotal,fDebAmount)
         MONEY_Add(sTransTotal,sDebAmount)
         balanced=false
         if VF_EnableCorrAct(bizEnv)
            transTotalDebChk+=debAmount
            transTotalCredChk+=credAmount
            fTransTotalDebChk+=fDebAmount

            fTransTotalCredChk+=fCredAmount
            sTransTotalDebChk+=sDebAmount

            sTransTotalCredChk+=sCredAmount
            if transTotalDebChk==transTotalCredChk&&fTransTotalDebChk==fTransTotalCredChk&&sTransTotalDebChk==sTransTotalCredChk
               balanced=true
            end

         else
            if !MONEY_Cmp(transTotal,transTotalChk)
               balanced=true
            end

         end

         if !IsExDtCommand(ooDoAsUpgrade)&&transType!=DAR
            if contraDebKey.size==0
               if debAmount.IsPositive()||fDebAmount.IsPositive()||sDebAmount.IsPositive()||credAmount.IsNegative()||fCredAmount.IsNegative()||sCredAmount.IsNegative()
                  _STR_strcpy(contraDebKey,cardKey)
               end

            end

            if contraCredKey.size==0
               if credAmount.IsPositive()||fCredAmount.IsPositive()||sCredAmount.IsPositive()||debAmount.IsNegative()||fDebAmount.IsNegative()||sDebAmount.IsNegative()
                  _STR_strcpy(contraCredKey,cardKey)
               end

            end

            if VF_EnableCorrAct(bizEnv)
               if debAmount.IsPositive()||fDebAmount.IsPositive()||sDebAmount.IsPositive()||credAmount.IsNegative()||fCredAmount.IsNegative()||sCredAmount.IsNegative()
                  (contraDebLines+=1;contraDebLines-2)
               end

               if credAmount.IsPositive()||fCredAmount.IsPositive()||sCredAmount.IsPositive()||debAmount.IsNegative()||fDebAmount.IsNegative()||sDebAmount.IsNegative()
                  (contraCredLines+=1;contraCredLines-2)
               end

            end

            if balanced&&contraDebKey[0]&&contraCredKey[0]
               SetContraAccounts(dagJDT1,lastContraRec,rec+1,contraDebKey,contraCredKey,contraDebLines,contraCredLines)
               contraDebKey[0]=contraCredKey[0]=0
               if VF_EnableCorrAct(bizEnv)
                  contraDebLines=contraCredLines=0
                  lastContraRec=rec+1
                  transTotalDebChk=transTotalCredChk=fTransTotalDebChk=fTransTotalCredChk=sTransTotalDebChk=sTransTotalCredChk=0
               end

            end

         end

         if transType!=DAR
            dagJDT1.GetColMoney(creditBalDue,JDT1_CREDIT,rec)
            dagJDT1.GetColMoney(debitBalDue,JDT1_DEBIT,rec)
            dagJDT1.GetColMoney(fCreditBalDue,JDT1_FC_CREDIT,rec)
            dagJDT1.GetColMoney(fDebitBalDue,JDT1_FC_DEBIT,rec)
            dagJDT1.GetColMoney(sCreditBalDue,JDT1_SYS_CREDIT,rec)
            dagJDT1.GetColMoney(sDebitBalDue,JDT1_SYS_DEBIT,rec)
            zeroBalanceDue=false
            if IsZeroBalanceDueForCentralizedPayment()&&dagJDT1.GetColStrAndTrim(JDT1_ACCT_NUM,rec,coreSystemDefault)!=dagJDT1.GetColStrAndTrim(JDT1_SHORT_NAME,rec,coreSystemDefault)
               zeroBalanceDue=true
            end

            if (!creditBalDue.IsZero()||!debitBalDue.IsZero()||!fCreditBalDue.IsZero()||!fDebitBalDue.IsZero()||!sCreditBalDue.IsZero()||!sDebitBalDue.IsZero())&&!zeroBalanceDue
               dagJDT1.CopyColumn(dagJDT1,JDT1_BALANCE_DUE_DEBIT,rec,JDT1_DEBIT,rec)
               dagJDT1.CopyColumn(dagJDT1,JDT1_BALANCE_DUE_CREDIT,rec,JDT1_CREDIT,rec)
               dagJDT1.CopyColumn(dagJDT1,JDT1_BALANCE_DUE_SC_DEB,rec,JDT1_SYS_DEBIT,rec)
               dagJDT1.CopyColumn(dagJDT1,JDT1_BALANCE_DUE_SC_CRED,rec,JDT1_SYS_CREDIT,rec)
               dagJDT1.CopyColumn(dagJDT1,JDT1_BALANCE_DUE_FC_DEB,rec,JDT1_FC_DEBIT,rec)
               dagJDT1.CopyColumn(dagJDT1,JDT1_BALANCE_DUE_FC_CRED,rec,JDT1_FC_CREDIT,rec)
            end

         end

         vatLine = SBOString.new
         dagJDT1.GetColStr(vatLine,JDT1_VAT_LINE,rec)
         vatLine.Trim()
         isVatLine=(vatLine==VAL_YES)
         if isVatLine&&isDeferredTax
            dagJDT1.SetColLong(IAT_DeferTaxInterim_Type,JDT1_INTERIM_ACCT_TYPE,rec)
         end


         (rec+=1;rec-2)
      end

      if IsExCommand(ooDontUpdateBudget)
         SetExCommand(ooDontUpdateBudget,fa_Clear)
      end

      if MONEY_Cmp(transTotal,transTotalChk)!=0
         dagJDT.GetColLong(transAbs,OJDT_JDT_NUM,0)
         _STR_sprintf(tempStr,LONG_FORMAT,transAbs)
         Message(ERROR_MESSAGES_STR,OO_TRANSACTION_NOT_BALANCED,tempStr,OO_ERROR)
         return (nil)
      end

      dagJDT.SetColMoney(transTotal,OJDT_LOC_TOTAL,0,DBM_NOT_ARRAY)
      dagJDT.SetColMoney(fTransTotal,OJDT_FC_TOTAL,0,DBM_NOT_ARRAY)
      dagJDT.SetColMoney(sTransTotal,OJDT_SYS_TOTAL,0,DBM_NOT_ARRAY)
      if !IsExDtCommand(ooDoAsUpgrade)&&transType!=DAR
         if contraDebKey[0]&&contraCredKey[0]
            SetContraAccounts(dagJDT1,lastContraRec,numOfRecs,contraDebKey,contraCredKey,contraDebLines,contraCredLines)
         end

         if VF_EnableCorrAct(bizEnv)&&balanced==false
            SetErrorField(JDT1_CONTRA_ACT)
            SetErrorLine(1)
            Message(OBJ_MGR_ERROR_MSG,GO_CONTRA_ACNT_MISSING,nil,OO_WARNING)
         end

      end

      if VF_ExciseInvoice(bizEnv)
         genRegNumFlag = SBOString.new
         dagJDT.GetColStr(genRegNumFlag,OJDT_GEN_REG_NO,0)
         genRegNumFlag.Trim()
         if genRegNumFlag==VAL_YES
            dagJDT.GetColLong(matType,OJDT_MAT_TYPE,0)
            dagJDT.GetColLong(location,OJDT_LOCATION,0)
            if matType==1||matType==3
               regNo=bizEnv.GetNextRegNum(location,RG23APart2,true)
               dagJDT.SetColLong(regNo,OJDT_RG23A_PART2,0)
               dagJDT.NullifyCol(OJDT_RG23C_PART2,0)
            else
               if matType==2
                  regNo=bizEnv.GetNextRegNum(location,RG23CPart2,true)
                  dagJDT.SetColLong(regNo,OJDT_RG23C_PART2,0)
                  dagJDT.NullifyCol(OJDT_RG23A_PART2,0)
               end

            end

         else
            if genRegNumFlag[0]==VAL_NO[0]
               dagJDT.NullifyCol(OJDT_MAT_TYPE,0)
               dagJDT.NullifyCol(OJDT_RG23A_PART2,0)
               dagJDT.NullifyCol(OJDT_RG23C_PART2,0)
            end

         end

      end

      isNeedToFree=SetDAG(nil,false,JDT,ao_Arr1)
      isNeedToFree2=SetDAG(nil,false,JDT,ao_Arr2)
      if VF_RmvZeroLineFromJE(GetEnv())&&!(GetEnv()).IsZeroLineAllowed()
         if dagJDT1.GetRecordCount()==0
            dagJDT.Clear()
            return ooErr
         end

         if dagJDT1.GetRecordCount()==1
            dagJDT1.GetColMoney(debAmount,JDT1_DEBIT,0)
            dagJDT1.GetColMoney(credAmount,JDT1_CREDIT,0)
            dagJDT1.GetColMoney(fDebAmount,JDT1_FC_DEBIT,0)
            dagJDT1.GetColMoney(fCredAmount,JDT1_FC_CREDIT,0)
            dagJDT1.GetColMoney(sDebAmount,JDT1_SYS_DEBIT,0)
            dagJDT1.GetColMoney(sCredAmount,JDT1_SYS_CREDIT,0)
            debBalanceDue = MONEY.new
            credBalanceDue = MONEY.new
            fDebBalanceDue = MONEY.new
            fCredBalanceDue = MONEY.new
            sDebBalanceDue = MONEY.new
            sCredBalanceDue = MONEY.new
            dagJDT1.GetColMoney(debBalanceDue,JDT1_BALANCE_DUE_DEBIT,0)
            dagJDT1.GetColMoney(credBalanceDue,JDT1_BALANCE_DUE_CREDIT,0)
            dagJDT1.GetColMoney(fDebBalanceDue,JDT1_BALANCE_DUE_FC_DEB,0)
            dagJDT1.GetColMoney(fCredBalanceDue,JDT1_BALANCE_DUE_FC_CRED,0)
            dagJDT1.GetColMoney(sDebBalanceDue,JDT1_BALANCE_DUE_SC_DEB,0)
            dagJDT1.GetColMoney(sCredBalanceDue,JDT1_BALANCE_DUE_SC_CRED,0)
            if debAmount.IsZero()&&credAmount.IsZero()&&fDebAmount.IsZero()&&fCredAmount.IsZero()&&sDebAmount.IsZero()&&sCredAmount.IsZero()&&debBalanceDue.IsZero()&&credBalanceDue.IsZero()&&fDebBalanceDue.IsZero()&&fCredBalanceDue.IsZero()&&sDebBalanceDue.IsZero()&&sCredBalanceDue.IsZero()
               dagJDT.Clear()
               return ooErr
            end

         end

      end

      dataSource = SBOString.new
      dagJDT.GetColStr(dataSource,OJDT_DATA_SOURCE)
      dataSource.Trim()
      if dataSource.Compare(VAL_YEAR_TRANSFER_SOURCE)==0
         SetDataSource(VAL_YEAR_TRANSFER_SOURCE)
      end

      if VF_MultipleRegistrationNumber(GetEnv())
         seqManager = CSequenceManager.new=bizEnv.GetSequenceManager()
         ooErr=seqManager.HandleSerial(self)
         if ooErr
            return ooErr
         end

      end

      if VF_SupplCode(GetEnv())
         pManager = CSupplCodeManager.new=bizEnv.GetSupplCodeManager()
         postDate = Date.new
         dagJDT.GetColStr(postDate,OJDT_REF_DATE)
         ooErr=pManager.CodeChange(self,postDate)
         if ooErr
            return ooErr
         end

         ooErr=pManager.CheckCode(self)
         if ooErr
            CMessagesManager.GetHandle().Message(_54_APP_MSG_CORE_SUPPL_CODE_CODE_EXIST,EMPTY_STR,self)
            return ooErrNoMsg
         end

      else
         if bizEnv.IsCurrentLocalSettings(CHINA_SETTINGS)
            if !dagJDT.IsNullCol(OJDT_SUPPL_CODE,0)
               dagJDT.NullifyCol(OJDT_SUPPL_CODE,0)
            end

         end

      end

      if VF_MultiBranch_EnabledInOADM(bizEnv)
         if !CBusinessPlaceObject.IsValidBPLId(GetBPLId())&&dagJDT1.GetRealSize(dbmDataBuffer)>0
            dagJDT1.GetColLong(bplId,JDT1_BPL_ID,0)
            SetBPLId(bplId)
         end

      end

      ooErr=GORecordHistProc(self,dagJDT)
      SetDAG(dagJDT1,isNeedToFree,JDT,ao_Arr1)
      SetDAG(dagJDT2,isNeedToFree2,JDT,ao_Arr2)
      if ooErr!=ooNoErr
         return (ooErr)
      end

      if VF_CashflowReport(bizEnv)
         dagJDT.GetColLong(transType,OJDT_TRANS_TYPE)
         if transType!=RCT&&transType!=VPM
            objCFTId = SBOString.new(CFT)
            dagCFT = PDAG.new=GetDAGNoOpen(objCFTId)
            if dagCFT
               dagJDT.GetColLong(transAbs,OJDT_JDT_NUM,0)
               bo = CCashFlowTransactionObject.new=static_cast(CreateBusinessObject(CFT))
               bo.SetDataSource(GetDataSource())
               ooErr=bo.OCFTCreateByJDT(GetDAG(CFT),transAbs,dagJDT1)
               bo.Destroy()
               if ooErr!=ooNoErr
                  return (ooErr)
               end

            end

         end

      end

      ooErr=PutSignature(dagJDT1)
      if ooErr
         return (ooErr)
      end

      if VF_ExciseInvoice(bizEnv)&&self.m_isVatJournalEntry

         dagJDT.GetColLong(wtrKey,OJDT_CREATED_BY)
         dagJDT.GetColLong(vatJournalKey,OJDT_JDT_NUM)
         if wtrKey<=0||vatJournalKey<=0
            return ooErrNoMsg
         end

         dagJDT.SetColLong(0,OJDT_STORNO_TO_TRANS)
         ooErr=CWarehouseTransferObject.LinkVatJournalEntry2WTR(bizEnv,wtrKey,vatJournalKey)
         if ooErr
            return ooErr
         end

      end

      dagJDT.GetColLong(createdBy,OJDT_CREATED_BY,0)
      dagJDT.GetColLong(transAbs,OJDT_JDT_NUM,0)
      rec=0
      while (rec<numOfRecs) do
         dagJDT1.SetColLong(rec,JDT1_LINE_ID,rec)
         dagJDT1.SetColLong(transAbs,JDT1_TRANS_ABS,rec)
         dagJDT1.SetColLong(transType,JDT1_TRANS_TYPE,rec)
         dagJDT.GetColStr(tempStr,OJDT_BASE_REF,0)
         dagJDT1.SetColStr(tempStr,JDT1_BASE_REF,rec)
         dagJDT.GetColStr(tempStr,OJDT_TRANS_CODE,0)
         dagJDT1.SetColStr(tempStr,JDT1_TRANS_CODE,rec)
         dagJDT1.SetColLong(createdBy,JDT1_CREATED_BY,rec)

         (rec+=1;rec-2)
      end

      if VF_JEWHT(bizEnv)&&_DBM_DataAccessGate.IsValid(dagJDT2)
         numOfJDT2=dagJDT2.GetRecordCount()
         rec2=0
         while (rec2<numOfJDT2) do
            dagJDT2.SetColLong(transAbs,INV5_ABS_ENTRY,rec2)
            dagJDT2.SetColLong(rec2,INV5_LINE_NUM,rec2)

            (rec2+=1;rec2-2)
         end

         @updateWTInfo()
      end

      if (GetDataSource()==VAL_OBSERVER_SOURCE)&&(GetID().strtol()==JDT)&&_DBM_DataAccessGate.IsValid(dagJDT2)
         bizFlow = BusinessFlow.new=GetCurrentBusinessFlow()
         wt = SBOString.new
         useNegativeAmount = Boolean.new
         dagJDT.GetColStr(wt,OJDT_AUTO_WT)
         useNegativeAmount=bizEnv.GetUseNegativeAmount()
         if bizFlow==bf_Cancel&&wt==VAL_YES
            if VF_JEWHT(bizEnv)&&useNegativeAmount
               CMessagesManager.GetHandle().Message(_1_APP_MSG_FIN_JDT_NOT_REVERSE_NEG_WT,EMPTY_STR,self)
               return ooInvalidObject
            end

            numOfJDT2=dagJDT2.GetRecordCount()
            idx=0
            while (idx<numOfJDT2) do
               dagJDT2.SetRecordFetchStatus(idx,false)

               (idx+=1;idx-2)
            end

         end

      end

      fetched = Boolean.new=dagJDT1.GetRecordFetchStatus(0)
      if true==fetched
         dagJDT1.SetBackupSize(numOfRecs,dbmDropData)
         ii=0
         while (ii<numOfRecs) do
            dagJDT1.MarkRecAsNew(ii)

            (ii+=1;ii-2)
         end

      end

      ooErr=CSystemBusinessObject.OnUpdate()
      if ooErr
         return ooErr
      end

      if VF_TaxPayment(bizEnv)
         rec=0
         while (rec<dagJDT1.GetRecordCount()) do
            ooErr=updateCenvatByJdt1Line(self,dagJDT1,rec)
            if ooErr&&ooErr!=-2028
               return ooErr
            end


            (rec+=1;rec-2)
         end

      end

      _STR_strcpy(sp_Name,_T("TmSp_SetBalanceByJdt"))
      dagJDT.GetColStr(tempStr,OJDT_JDT_NUM,0)
      _STR_LRTrim(tempStr)
      upd[0].colNum=dbmInteger
      _STR_strcpy(upd[0].updateVal,tempStr)
      DBD_SetDAGUpd(dagJDT,upd,1)
      retVal=0
      ooErr=DBD_SpExec(dagJDT,sp_Name,retVal)
      tmpstr = SBOString.new(tempStr)
      LogBPAccountBalance(bpBalanceLogDataArray,tmpstr)
      bizEnv.InvalidateCache(bizEnv.ObjectToTable(CRD))
      bizEnv.InvalidateCache(bizEnv.ObjectToTable(ACT))
      if retVal
         return retVal
      end

      if ooErr
         return ooErr
      end


      dagJDT.GetColLong(canceledTrans,OJDT_STORNO_TO_TRANS,0)
      if canceledTrans>0
         ordered=false
         ooErr=CTransactionJournalObject.IsPaymentOrdered(bizEnv,canceledTrans,ordered)
         if ooErr
            return ooErr
         end

         if ordered
            bizEnv.SetErrorTable(dagJDT1.GetTableName())
            return -2039
         end

      end

      if (canceledTrans>0)&&(@m_reconcileBPLines)
         ooErr=@reconcileCertainLines()
         if ooErr
            return ooErr
         end

         if !@m_isInCancellingAcctRecon
            ooErr=@reconcileDeferredTaxAcctLines()
            if ooErr
               return ooErr
            end

         end

      end

      ooErr=CreateTax()
      if ooErr
         return ooErr
      end

      if VF_EnableDeductAtSrc(GetEnv())
         dagJDT.GetColLong(transID,OJDT_JDT_NUM,0)
         ooErr=nsDeductHierarchy.UpdateDeductionPercent(bizEnv,transID)
         if ooErr
            return ooErr
         end

      end

      if transType==JDT
         ooErr=@m_digitalSignature.CreateSignature(self)
         if ooErr
            return ooErr
         end

      end

      ooErr=@validateBPLNumberingSeries()
      if ooErr
         return ooErr
      end

      ooErr=@isBalancedByBPL()
      if ooErr
         return ooErr
      end

      if bizEnv.IsComputeBudget()==false||bizEnv.IsDuringUpgradeProcess()||transType==DAR
         return ooErr
      end

      _STR_strcpy(sp_Name,_T("TmSp_SetBgtAccumulators_ByJdt"))
      res[0].colNum=JDT1_ACCT_NUM
      res[1].colNum=JDT1_FC_CURRENCY
      res[2].colNum=JDT1_FC_CURRENCY
      res[3].colNum=JDT1_DEBIT
      res[4].colNum=JDT1_DEBIT
      DBD_SetDAGRes(dagJDT1,res,5)
      dagJDT.GetColStr(tempStr,OJDT_JDT_NUM,0)
      _STR_LRTrim(tempStr)
      upd[0].colNum=dbmInteger
      _STR_strcpy(upd[0].updateVal,tempStr)
      upd[1].colNum=dbmAlphaNumeric
      _STR_strcpy(upd[1].updateVal,_T("Y"))
      upd[2].colNum=dbmAlphaNumeric
      _STR_strcpy(upd[2].updateVal,bizEnv.GetCompanyPeriodCategory())
      DBD_SetDAGUpd(dagJDT1,upd,3)
      ooErr=DBD_SpToDAG(dagJDT1,dagRES,sp_Name)
      if ooErr==-2028
         return ooNoErr
      end

      if ooErr
         return ooErr
      end

      blockLevel=RetBlockLevel(bizEnv)
      typeBlockLevel=RettypeBlockLevel(bizEnv,GetID().strtol())
      if blockLevel>=3&&typeBlockLevel==5&&(OOIsSaleObject(transType)||OOIsPurchaseObject(transType))
         blockLevel=1
      end

      if blockLevel>=3&&typeBlockLevel!=5&&transType==30
         blockLevel=1
      end

      _STR_strcpy(monSymbol,bizEnv.GetMainCurrency())
      DAG_GetCount(dagRES,recCount)
      ii=0
      while (ii<recCount) do
         dagRES.GetColStr(acctCode,0,ii)
         dagRES.GetColStr(tmpStr,1,ii)
         doAlert=tmpStr[0]
         dagRES.GetColStr(tmpStr,2,ii)
         alrType=tmpStr[0]
         dagRES.GetColMoney(bgtMonthOver,3,ii,DBM_NOT_ARRAY)
         dagRES.GetColMoney(bgtYearOver,4,ii,DBM_NOT_ARRAY)
         if doAlert==VAL_YES
            transTotal.SetToZero()
            rec=0
            while (rec<numOfRecs) do
               dagJDT1.GetColStr(acctKey,JDT1_ACCT_NUM,rec)
               if _STR_stricmp(acctKey,acctCode)==0
                  dagJDT1.GetColMoney(debAmount,JDT1_DEBIT,rec,DBM_NOT_ARRAY)
                  dagJDT1.GetColMoney(credAmount,JDT1_CREDIT,rec,DBM_NOT_ARRAY)
                  MONEY_Add(transTotal,debAmount)
                  MONEY_Sub(transTotal,credAmount)
               end


               (rec+=1;rec-2)
            end

            if bizEnv.GetBudgetWarningFrequency()==VAL_MONTHLY[0]
               if (bgtMonthOver.IsPositive()&&transTotal.IsPositive())||(bgtMonthOver.IsNegative()&&transTotal.IsNegative())
                  bgtDebitSize=true
               else
                  bgtDebitSize=false
               end

            else
               if (bgtYearOver.IsPositive()&&transTotal.IsPositive())||(bgtYearOver.IsNegative()&&transTotal.IsNegative())
                  bgtDebitSize=true
               else
                  bgtDebitSize=false
               end

            end

         else
            bgtDebitSize=false
         end

         if blockLevel>1&&bgtDebitSize
            budgetAllYes=IsExCommand(ooDontUpdateBudget)
            fromImport=IsExCommand(ooImportData)
            MONEY_ToText(bgtMonthOver,moneyMonthStr,RC_SUM,monSymbol,bizEnv)
            MONEY_ToText(bgtYearOver,moneyYearStr,RC_SUM,monSymbol,bizEnv)
            if bizEnv.GetBudgetWarningFrequency()==VAL_MONTHLY[0]
               GetBudgBlockErrorMessage(moneyMonthStr,moneyYearStr,acctCode,2,msgStr1)
            else
               GetBudgBlockErrorMessage(moneyMonthStr,moneyYearStr,acctCode,3,msgStr1)
            end

            case blockLevel

            when 2
               if typeBlockLevel==5
                  if bizEnv.GetBudgetWarningFrequency()==VAL_MONTHLY[0]
                     GetBudgBlockErrorMessage(moneyMonthStr,moneyYearStr,acctCode,1,msgStr1)
                     _STR_strcat(msgStr1,_T(" , "))
                     _STR_strcat(msgStr1,EMPTY_STR)
                     Message(-1,-1,msgStr1,OO_ERROR)
                  else
                     CMessagesManager.GetHandle().Message(_1_APP_MSG_FIN_BGT0_CHECK_YEAR_TOTAL_STR,EMPTY_STR,self,acctCode,moneyYearStr)
                  end

                  return ooInvalidObject
               end

               break
            when 3
               if fromImport||GetDataSource()==VAL_OBSERVER_SOURCE
                  _STR_strcat(msgStr1,_T(" , "))
                  _STR_strcat(msgStr1,EMPTY_STR)
                  Message(-1,-1,msgStr1,OO_ERROR)
               end

               if budgetAllYes==false
                  continueStr = []

                  _STR_GetStringResource(ContinueStr,BGT0_FORM_NUM,BGT0_CONTINUE_STR)
                  retBtn=FORM_GEN_Message(msgStr1,ContinueStr,CANCEL_STR(OOGetEnv(nil)),YES_TO_ALL_STR(OOGetEnv(nil)),2)
                  case retBtn

                  when 1
                  when 3
                     budgetAllYes=(retBtn==3 ? true : false)
                     if budgetAllYes
                        SetExCommand(ooDontUpdateBudget,fa_Set)
                     end

                     if GetEnv().GetPermission(PRM_ID_BUDGET_BLOCK)!=OO_PRM_FULL
                        DisplayError(fuNoPermission)
                        return ooErrNoMsg
                     end

                     break
                  when 2
                     return ooErrNoMsg
                     break
                  end

               end

               break
            end

         end


         (ii+=1;ii-2)
      end

      if transType==JDT&&bizEnv.IsComputeBudget()
         alertSent = Boolean.new
         systemAlertsParams = CSystemAlertParams.new
         systemAlertsParams.m_fromUser=bizEnv.GetUserSignature()
         systemAlertsParams.m_object=JDT
         systemAlertsParams.m_params=self
         systemAlertsParams.m_primaryKey.Format(_T("%d"),transAbs)
         systemAlertsParams.m_secondaryKey=systemAlertsParams.m_primaryKey
         systemAlertsParams.m_alertID=ALR_BUDGET_ALERT
         systemAlertsParams.m_flags=0
         ALRSendSystemAlert(systemAlertsParams,alertSent)
      end

      return ooErr
   end

   def OnUpdate()
      trace("OnUpdate")

      dagJDT = PDAG.new
      dagJDT1 = PDAG.new
      dagJDT2 = PDAG.new


      bizEnv = CBizEnv.new=GetEnv()
      periodMode = PeriodMode.new
      periodMode=bizEnv.GetPeriodMode()
      if periodMode==ooPeriodLockedMode
         return (ooLockedPeriodErr)
      end

      dagJDT1=GetDAG(JDT,ao_Arr1)
      if VF_CashflowReport(bizEnv)
         objCFTId = SBOString.new(CFT)
         dagCFT = PDAG.new=GetDAGNoOpen(objCFTId)
         if dagCFT
            bo = CCashFlowTransactionObject.new=static_cast(CreateBusinessObject(CFT))
            bo.SetDataSource(GetDataSource())
            bo.m_isInParentUpdateFlow=(GetCurrentBusinessFlow()==bf_Update)
            ooErr=bo.OCFTModifyByJDT(GetDAG(CFT))
            bo.Destroy()
            if ooErr!=ooNoErr
               return (ooErr)
            end

         end

      end

      dagJDT=GetDAG(JDT)
      dagJDT2=GetDAG(JDT,ao_Arr2)
      DAG_GetCount(dagJDT1,numOfRecs)
      rec=0
      while (rec<numOfRecs) do
         dagJDT1.CopyColumn(dagJDT,JDT1_TRANS_CODE,rec,OJDT_TRANS_CODE,0)
         ocrCode = SBOString.new
         postDate = SBOString.new
         validFrom = SBOString.new
         dagJDT1.GetColStr(ocrCode,JDT1_OCR_CODE,rec)
         dagJDT1.GetColStr(postDate,JDT1_REF_DATE,rec)
         ooErr=COverheadCostRateObject.GetValidFrom(bizEnv,ocrCode,postDate,validFrom)
         if ooErr
            return ooErr
         end

         dagJDT1.SetColStr(validFrom,JDT1_VALID_FROM,rec)

         (rec+=1;rec-2)
      end

      isOrdered=self.IsPaymentOrdered()
      transId=-1
      dagJDT.GetColLong(transId,OJDT_JDT_NUM)
      isOrderedInDB=false
      ooErr=CTransactionJournalObject.IsPaymentOrdered(bizEnv,transId,isOrderedInDB)
      if ooErr
         return ooErr
      end

      if isOrdered!=isOrderedInDB
         bizEnv.SetErrorTable(dagJDT1.GetTableName())
         return -2039
      end

      if VF_JEWHT(bizEnv)
         isAutoWt = SBOString.new
         isAutoWt.Trim()
         dagJDT.GetColStr(isAutoWt,OJDT_AUTO_WT)
         recCount=dagJDT2.GetRealSize(dbmDataBuffer)
         sCategory = SBOString.new
         if recCount>0
            dagJDT2.GetColStr(sCategory,JDT2_CATEGORY)
            sCategory.Trim()
         end

         if (isAutoWt==VAL_YES)&&(sCategory==VAL_CATEGORY_PAYMENT)
            ooErr=@updateWTInfo()
         end

         if ooErr
            return ooErr
         end

      end

      dagOLD1 = PDAG.new=OpenDAG(JDT,ao_Arr1)
      acDagOLD = AutoCleanerDAG.new(dagOLD1)
      key = SBOString.new
      dagJDT.GetColStr(key,OJDT_JDT_NUM,0)
      ooErr=dagOLD1.GetByKey(key)
      if ooErr
         return ooErr
      end

      i=0
      while (i<dagJDT1.GetRealSize(dbmDataBuffer)) do
         oldFederalTaxId = SBOString.new
         newFederalTaxId = SBOString.new
         dagOLD1.GetColStr(oldFederalTaxId,JDT1_TAX_ID_NUMBER,i)
         dagJDT1.GetColStr(newFederalTaxId,JDT1_TAX_ID_NUMBER,i)
         if oldFederalTaxId.Trim()!=newFederalTaxId.Trim()
            acctCode = SBOString.new
            shrtCode = SBOString.new
            dagJDT1.GetColStr(acctCode,JDT1_ACCT_NUM,i)
            dagJDT1.GetColStr(shrtCode,JDT1_SHORT_NAME,i)
            if acctCode.Trim()==shrtCode.Trim()
               SetErrorField(JDT1_TAX_ID_NUMBER)
               return -1029
            end

            if bizEnv.IsCurrentLocalSettings(USA_SETTINGS)
               SetErrorField(JDT1_TAX_ID_NUMBER)
               return -1029
            end

            transType = SBOString.new
            dagJDT.GetColStr(transType,OJDT_TRANS_TYPE)
            objectId=transType.Trim().strtol()
            if objectId!=JDT&&objectId!=NONE_CHOICE
               SetErrorField(JDT1_TAX_ID_NUMBER)
               return -1029
            end

            series=0
            dagJDT.GetColLong(series,OJDT_SERIES)
            if VF_PTCertification(bizEnv)&&CDigitalSignatureBase.IsDigitalSignatureAllowed(self,series)
               SetErrorField(JDT1_TAX_ID_NUMBER)
               return -1029
            end

         end


         (i+=1;i-2)
      end

      isScAdj=false
      ooErr=IsScAdjustment(isScAdj)
      if isScAdj||ooErr
         SetErrorLine(-1)
         SetErrorField(OJDT_AUTO_STORNO)
         CMessagesManager.GetHandle().Message(_147_APP_MSG_FIN_JE_FOR_CONV_DIFF_ADJ_CANNOT_BE_REVERSED,EMPTY_STR,self)
         return ooInvalidObject
      end

      ooErr=@validateBPLNumberingSeries()
      if ooErr
         return ooErr
      end

      ooErr=@isBalancedByBPL()
      if ooErr
         return ooErr
      end

      ooErr=CSystemBusinessObject.OnUpdate()
      return (ooErr)
   end

   def OnAutoComplete()
      trace("OnAutoComplete")
      ooErr=0


      sysCurr = Currency.new=""
      localCurr = Currency.new=""
      tempCurr = Currency.new=""
      lineCurr = []
      =""
      dateStr = []
      =""
      batchNum = []
      =""
      indicator = []
      =""
      tmpStr = []

      actNum = []
      shortName = []

      method = []

      stampTax = []

      sysFound = Boolean.new=false
      needBaseSum = Boolean.new
      money = MONEY.new
      debMoneyFC = MONEY.new
      credMoneyFC = MONEY.new
      zeroM = MONEY.new
      vatPrcnt = MONEY.new
      equVatPrcnt = MONEY.new
      baseSum = MONEY.new
      minAmount = MONEY.new
      fixedAmount = MONEY.new
      tmpM = MONEY.new
      dagJDT = PDAG.new=nil
      dagJDT1 = PDAG.new = nil
      dagACT = PDAG.new = nil
      dagCRD = PDAG.new = nil
      bizEnv = CBizEnv.new=GetEnv()
      currencyRoundingMap = StdMap.new
      roundingStruct = FCRoundingStruct.new
      dagJDT=GetDAG(JDT)
      dagJDT1=GetDAG(JDT,ao_Arr1)
      dagACT=GetDAG(ACT)
      dagCRD=GetDAG(CRD)
      ooErr=CompleteKeys()
      if ooErr
         if ooErr==-2038
            Message(ERROR_MESSAGES_STR,OO_RECORD_LOCKED_BY_ANOTHER_TRAN_STR,nil,OO_ERROR)
         end

         return ooErr
      end

      _STR_strcpy(sysCurr,bizEnv.GetSystemCurrency())
      _STR_strcpy(localCurr,bizEnv.GetMainCurrency())
      zeroM.SetToZero()
      @setDebitCreditField()
      if IsExDtCommand(ooDoAsUpgrade)
         dagJDT.GetColLong(rec,OJDT_JDT_NUM,0)
         SetInternalKey(rec)
      else
         ooErr=@completeTrans()
         if ooErr
            return ooErr
         end

      end

      dagJDT.GetColStr(tmpStr,OJDT_TAX_DATE,0)
      if _STR_atol(tmpStr)<=0
         dagJDT.CopyColumn(dagJDT,OJDT_TAX_DATE,0,OJDT_REF_DATE,0)
      end

      DAG_GetCount(dagJDT1,numOfRecs)
      ooErr=@completeJdtLine()
      if GetDataSource()==VAL_OBSERVER_SOURCE&&!IsExDtCommand(ooOBServerUpdate)
         rec=0
         while (rec<numOfRecs) do
            dagJDT1.SetColStr(VAL_NO,JDT1_VAT_LINE,rec)

            (rec+=1;rec-2)
         end

         if bizEnv.IsVatPerLine()||bizEnv.IsVatPerCard()
            dagJDT.GetColStr(tmpStr,OJDT_AUTO_VAT,0)
            if tmpStr[0]==VAL_NO[0]
               rec=0
               while (rec<numOfRecs) do
                  dagJDT1.GetColStr(tmpStr,bizEnv.IsVatPerLine() ? JDT1_VAT_GROUP : JDT1_TAX_CODE,rec)
                  if !_STR_IsSpacesStr(tmpStr)
                     dagJDT1.SetColStr(VAL_YES,JDT1_VAT_LINE,rec)
                  end


                  (rec+=1;rec-2)
               end

            end

         end

      end

      dagJDT.GetColStr(lineCurr,OJDT_TRANS_CURR,0)
      _STR_LRTrim(lineCurr)
      _STR_strcpy(tempCurr,lineCurr)
      if !tempCurr[0]
         rec=0
         while (rec<numOfRecs) do
            dagJDT1.GetColStr(lineCurr,JDT1_FC_CURRENCY,rec)
            _STR_LRTrim(lineCurr)
            if lineCurr[0]
               break
            end


            (rec+=1;rec-2)
         end

         dagJDT.SetColStr(lineCurr,OJDT_TRANS_CURR,0)
      end

      dagJDT.GetColStr(batchNum,OJDT_BATCH_NUM,0)
      _STR_LRTrim(batchNum)
      dagJDT.GetColStr(indicator,OJDT_INDICATOR,0)
      dagJDT.GetColStr(tmpStr,OJDT_MEMO,0)
      _STR_CleanExtendedEditMarks(tmpStr,' ')
      _STR_LRTrim(tmpStr)
      dagJDT.SetColStr(tmpStr,OJDT_MEMO,0)
      if IsExDtCommand(ooOBServerUpdate)&&!IsExCommand(ooExAddBatchNoClose)
         rec=0
         while (rec<numOfRecs) do
            dagJDT1.GetColStr(tmpStr,JDT1_LINE_MEMO,rec)
            _STR_CleanExtendedEditMarks(tmpStr,' ')
            _STR_LRTrim(tmpStr)
            dagJDT1.SetColStr(tmpStr,JDT1_LINE_MEMO,rec)
            dagJDT1.SetColStr(batchNum,JDT1_BATCH_NUM,rec)
            dagJDT1.SetColStr(indicator,JDT1_INDICATOR,rec)

            (rec+=1;rec-2)
         end

         return ooErr
      end

      dagJDT.GetColStr(stampTax,OJDT_STAMP_TAX,0)
      rec=0
      while (rec<numOfRecs) do
         dagJDT1.GetColStr(tmpStr,JDT1_PAYMENT_BLOCK,rec)
         if VAL_YES[0]==tmpStr[0]
            dagJDT1.GetColStr(tmpStr,JDT1_PAYMENT_BLOCK_REF,rec)
            if dagJDT1.IsNullCol(JDT1_PAYMENT_BLOCK_REF,rec)||_STR_IsSpacesStr(tmpStr)
               dagJDT1.SetColStr(NONE_CHOICE,JDT1_PAYMENT_BLOCK_REF,rec)
            end

         end

         dagJDT1.GetColStr(tmpStr,JDT1_LINE_MEMO,rec)
         _STR_CleanExtendedEditMarks(tmpStr,' ')
         _STR_LRTrim(tmpStr)
         dagJDT1.SetColStr(tmpStr,JDT1_LINE_MEMO,rec)
         dagJDT1.SetColStr(batchNum,JDT1_BATCH_NUM,rec)
         dagJDT1.SetColStr(indicator,JDT1_INDICATOR,rec)
         dagJDT1.GetColStr(dateStr,JDT1_REF_DATE,rec)
         dagJDT1.GetColMoney(debMoneyFC,JDT1_FC_DEBIT,rec,DBM_NOT_ARRAY)
         dagJDT1.GetColMoney(credMoneyFC,JDT1_FC_CREDIT,rec,DBM_NOT_ARRAY)
         if bizEnv.IsVatPerLine()
            dagJDT1.GetColStr(tmpStr,JDT1_VAT_LINE,rec)
            if tmpStr[0]==VAL_YES[0]
               if stampTax[0]==VAL_NO[0]
                  dagJDT1.GetColStr(tmpStr,JDT1_VAT_GROUP,rec)
                  ooErr=bizEnv.GetVatPercent(tmpStr,bizEnv.GetDateForTaxRateDetermination(dagJDT1,rec),vatPrcnt,equVatPrcnt)
                  if ooErr
                     return ooErr
                  end

                  dagJDT1.SetColMoney(vatPrcnt,JDT1_VAT_PERCENT,rec,DBM_NOT_ARRAY)
                  dagJDT1.SetColMoney(equVatPrcnt,JDT1_EQU_VAT_PERCENT,rec)
                  if dagJDT1.IsNullCol(JDT1_BASE_SUM,rec)
                     needBaseSum=true
                  else
                     needBaseSum=false
                  end

               else
                  dagJDT1.GetColStr(tmpStr,JDT1_VAT_GROUP,rec)
                  TZGetStampValue(dagJDT,tmpStr,dateStr,vatPrcnt,minAmount,method,fixedAmount)
                  if method[0]==VAL_RATE[0]
                     dagJDT1.SetColMoney(vatPrcnt,JDT1_VAT_PERCENT,rec,DBM_NOT_ARRAY)
                  else
                     dagJDT1.NullifyCol(JDT1_VAT_PERCENT,rec)
                  end

               end

            else
               dagJDT1.SetColMoney(zeroM,JDT1_BASE_SUM,rec,DBM_NOT_ARRAY)
               dagJDT1.SetColMoney(zeroM,JDT1_VAT_PERCENT,rec,DBM_NOT_ARRAY)
               vatPrcnt=zeroM
               needBaseSum=false
            end

         else
            dagJDT1.NullifyCol(JDT1_VAT_GROUP,rec)
            vatPrcnt=zeroM
            needBaseSum=false
         end

         baseSum.SetToZero()
         if credMoneyFC.IsZero()&&debMoneyFC.IsZero()
            dagJDT1.GetColMoney(money,JDT1_DEBIT,rec,DBM_NOT_ARRAY)
            if needBaseSum&&!money.IsZero()
               baseSum=money
            end

            dagJDT1.GetColMoney(money,JDT1_CREDIT,rec,DBM_NOT_ARRAY)
            if needBaseSum&&baseSum.IsZero()
               baseSum=money
            end

         else
            dagJDT1.GetColStr(lineCurr,JDT1_FC_CURRENCY,rec)
            if _STR_SpacesString(lineCurr,lineCurr.size)
               dagJDT1.GetColStr(actNum,JDT1_ACCT_NUM,rec)
               dagJDT1.GetColStr(shortName,JDT1_SHORT_NAME,rec)
               if _STR_strcmp(actNum,shortName)==0
                  ooErr=bizEnv.GetByOneKey(dagACT,OACT_KEYNUM_PRIMARY,actNum,true)
                  if !ooErr
                     dagACT.GetColStr(lineCurr,OACT_ACT_CURR,0)
                     if GNCoinCmp(lineCurr,BAD_CURRENCY_STR)&&GNCoinCmp(lineCurr,localCurr)
                        dagJDT1.SetColStr(lineCurr,JDT1_FC_CURRENCY,rec)
                     else
                        if GNCoinCmp(lineCurr,BAD_CURRENCY_STR)==0
                           lineCurr[0]=0
                           i=rec-1
                           while (i>0) do
                              dagJDT1.GetColStr(lineCurr,JDT1_FC_CURRENCY,i)
                              if !_STR_SpacesString(lineCurr,lineCurr.size)
                                 dagJDT1.SetColStr(lineCurr,JDT1_FC_CURRENCY,rec)
                                 break
                              end


                              (i-=1;i+2)
                           end

                        else
                           lineCurr[0]=0
                        end

                     end

                  end

               else
                  ooErr=bizEnv.GetByOneKey(dagCRD,OCRD_KEYNUM_PRIMARY,shortName,true)
                  if !ooErr
                     dagCRD.GetColStr(lineCurr,OCRD_CRD_CURR,0)
                     if GNCoinCmp(lineCurr,BAD_CURRENCY_STR)&&GNCoinCmp(lineCurr,localCurr)
                        dagJDT1.SetColStr(lineCurr,JDT1_FC_CURRENCY,rec)
                     else
                        if GNCoinCmp(lineCurr,BAD_CURRENCY_STR)==0
                           lineCurr[0]=0
                           i=rec-1
                           while (i>0) do
                              dagJDT1.GetColStr(lineCurr,JDT1_FC_CURRENCY,i)
                              if !_STR_SpacesString(lineCurr,lineCurr.size)
                                 dagJDT1.SetColStr(lineCurr,JDT1_FC_CURRENCY,rec)
                                 break
                              end


                              (i-=1;i+2)
                           end

                        else
                           lineCurr[0]=0
                        end

                     end

                  end

               end

            end

            if !debMoneyFC.IsZero()
               if dagJDT1.IsNullCol(JDT1_DEBIT,rec)
                  ooErr=GNForeignToLocalRate(debMoneyFC,lineCurr,dateStr,0.0,money,GetEnv())
                  if ooErr
                     if IsExCommand(ooExAutoMode)
                        if ooErr==ooUndefinedCurrency
                           CMessagesManager.GetHandle().Message(_1_APP_MSG_FIN_OO_UNDEFINED_CURRENCY,EMPTY_STR,self)
                        else
                           CMessagesManager.GetHandle().Message(_1_APP_MSG_AP_AR_REPOSTING_SYSTEM_RATE_NOT_DEFINED,EMPTY_STR,self)
                        end

                     end

                     return ooErr
                  end

                  money.Round(RC_SUM,localCurr,bizEnv)
                  dagJDT1.SetColMoney(money,JDT1_DEBIT,rec,DBM_NOT_ARRAY)
                  currencyRoundingMap.Lookup(SBOString(lineCurr).Trim(),roundingStruct)
                  roundingStruct.needRounding=true
                  currencyRoundingMap[SBOString(lineCurr).Trim()]=roundingStruct
               end

            end

            if !credMoneyFC.IsZero()
               if dagJDT1.IsNullCol(JDT1_CREDIT,rec)
                  ooErr=GNForeignToLocalRate(credMoneyFC,lineCurr,dateStr,0.0,money,GetEnv())
                  if ooErr
                     if IsExCommand(ooExAutoMode)
                        if ooErr==ooUndefinedCurrency
                           CMessagesManager.GetHandle().Message(_1_APP_MSG_FIN_OO_UNDEFINED_CURRENCY,EMPTY_STR,self)
                        else
                           CMessagesManager.GetHandle().Message(_1_APP_MSG_AP_AR_REPOSTING_SYSTEM_RATE_NOT_DEFINED,EMPTY_STR,self)
                        end

                     end

                     return ooErr
                  end

                  money.Round(RC_SUM,localCurr,bizEnv)
                  dagJDT1.SetColMoney(money,JDT1_CREDIT,rec,DBM_NOT_ARRAY)
                  currencyRoundingMap.Lookup(SBOString(lineCurr).Trim(),roundingStruct)
                  roundingStruct.needRounding=true
                  currencyRoundingMap[SBOString(lineCurr).Trim()]=roundingStruct
               end

            end

            if !tmpM.IsZero()&&dagJDT1.IsNullCol(JDT1_GROSS_VALUE,rec)
               ooErr=GNForeignToLocalRate(tmpM,lineCurr,dateStr,0.0,money,GetEnv())
               if ooErr
                  if ooErr==ooUndefinedCurrency
                     Message(ERROR_MESSAGES_STR,OO_UNDEFINED_CURRENCY,nil,OO_ERROR)
                  else
                     Message(ERROR_MESSAGES_STR,OO_RATE_MISSING,nil,OO_ERROR)
                  end

                  return ooErr
               end

               MONEY_Round(money,RC_SUM,localCurr,bizEnv)
               dagJDT1.SetColMoney(money,JDT1_GROSS_VALUE,rec,DBM_NOT_ARRAY)
            end

            if needBaseSum
               if !debMoneyFC.IsZero()
                  ooErr=GNForeignToLocalRate(debMoneyFC,lineCurr,dateStr,0.0,baseSum,GetEnv())
               else
                  ooErr=GNForeignToLocalRate(credMoneyFC,lineCurr,dateStr,0.0,baseSum,GetEnv())
               end

               if ooErr
                  if IsExCommand(ooExAutoMode)
                     if ooErr==ooUndefinedCurrency
                        Message(ERROR_MESSAGES_STR,OO_UNDEFINED_CURRENCY,nil,OO_ERROR)
                     else
                        Message(ERROR_MESSAGES_STR,OO_RATE_MISSING,nil,OO_ERROR)
                     end

                  end

                  return ooErr
               end

            end

         end

         if needBaseSum
            MONEY_MulMLAndDivMM(baseSum,100*MONEY_PERCISION_MUL,vatPrcnt,baseSum,false,bizEnv)
            MONEY_Round(baseSum,RC_SUM,localCurr,bizEnv)
            dagJDT1.SetColMoney(baseSum,JDT1_BASE_SUM,rec,DBM_NOT_ARRAY)
         end

         if dagJDT1.IsNullCol(JDT1_PROJECT,rec)
            dagJDT1.GetColStr(actNum,JDT1_ACCT_NUM,rec)
            dagJDT1.GetColStr(shortName,JDT1_SHORT_NAME,rec)
            if _STR_strcmp(actNum,shortName)==0
               ooErr=bizEnv.GetByOneKey(dagACT,OACT_KEYNUM_PRIMARY,actNum,true)
               if !ooErr
                  dagJDT1.CopyColumn(dagACT,JDT1_PROJECT,rec,OACT_PROJECT,0)
               end

            end

         end


         (rec+=1;rec-2)
      end


      dagJDT.GetColLong(transType,OJDT_TRANS_TYPE,0)
      if GetDataSource()!=VAL_OBSERVER_SOURCE&&transType==JDT
         HandleFCExchangeRounding(dagJDT1,currencyRoundingMap)
      end

      if (!IsExDtCommand(ooOBServerUpdate)||IsExCommand(ooExAddBatchNoClose))&&!IsExDtCommand(ooBSPExchangeRateDiff)&&(transType!=ITR)&&!OOIsFixedAssetsObject(transType)
         ooErr=@calculationSystAmmountOfTrans()
         if ooErr
            return ooErr
         end

      end

      if GetDataSource()==VAL_OBSERVER_SOURCE&&!IsExDtCommand(ooOBServerUpdate)
         ooErr=@completeForeignAmount()
         if ooErr
            return ooErr
         end

         ooErr=@completeVatLine()
         if ooErr
            return ooErr
         end

         if VF_JEWHT(bizEnv)
            ooErr=@completeWTLine()
            if ooErr
               return ooErr
            end

         end

         ooErr=@completeTrans()
         if ooErr
            return ooErr
         end

         ooErr=@completeJdtLine()
         if transType==JDT
            HandleFCExchangeRounding(dagJDT1,currencyRoundingMap)
         end

      end

      if bizEnv.IsCurrentLocalSettings(FRANCE_SETTINGS)
         transCode = SBOString.new
         glAcct = SBOString.new

         ooErr=dagJDT.GetColStr(transCode,OJDT_TRANS_CODE,0)
         transCode.Trim()
         if !ooErr&&transCode.IsEmpty()
            ooErr=CJournalManager.GetDefaultTransCode(self,dagJDT,dagJDT1,glAcct,transCode,jdtLine)
            if !ooErr&&jdtLine>=0
               ooErr=dagJDT.SetColStr(transCode,OJDT_TRANS_CODE,0)
            end

         end

      end

      if GetDataSource()==VAL_OBSERVER_SOURCE&&VF_FIReleaseProc(bizEnv)
         creatorName = []

         _MEM_Set(creatorName,0,OJDT_CREATOR_NAME_LEN+1)
         creator = SBOString.new
         CEmployeeObject.HEMGetEmployeeNameByUsrCode(creator,bizEnv,bizEnv.GetUserCode(),true)
         creator.ToBuffer(creatorName,OJDT_CREATOR_NAME_LEN)
         dagJDT.GetColStr(batchNum,OJDT_BATCH_NUM,0)
         _STR_LRTrim(batchNum)
         if batchNum[0]=='\0'&&transType==JDT
            if VF_OD_SFA(bizEnv)
               tmpStr = SBOString.new
               dagJDT.GetColStr(tmpStr,OJDT_CREATOR_NAME,0)
               if tmpStr.IsSpacesStr()
                  dagJDT.SetColStr(creatorName,OJDT_CREATOR_NAME,0)
               end

               dagJDT.GetColStr(tmpStr,OJDT_APPROVER_NAME,0)
               if tmpStr.IsSpacesStr()
                  dagJDT.SetColStr(creatorName,OJDT_APPROVER_NAME,0)
               end

            else
               dagJDT.SetColStr(creatorName,OJDT_CREATOR_NAME,0)
               dagJDT.SetColStr(creatorName,OJDT_APPROVER_NAME,0)
            end

         end

      end

      if VF_MultipleRegistrationNumber(bizEnv)
         @completeLocations()
      end

      ooErr=CompleteReport340(dagJDT,dagJDT1)
      if ooErr
         return ooErr
      end

      return ooErr
   end

   def OnCanUpdate()
      trace("OnCanUpdate")

      editableInUpdate = Boolean.new
      isHeader = Boolean.new
      fCodePtr = TCHAR.new
      oopp = DBM_OUP.new=GetOnUpdateParams()
      dag = PDAG.new=oopp.pDag
      bizEnv = CBizEnv.new=GetEnv()
      editableInUpdate=(Boolean)(bizEnv.GetPermission(PRM_ID_UPDATE_POSTING)==OO_PRM_FULL)
      fCodePtr=DAG_GetAlias(dag)
      isHeader=_STR_stricmp(fCodePtr,bizEnv.ObjectToTable(JDT))==0
      if VF_JEWHT(bizEnv)
         tmp = SBOString.new=bizEnv.ObjectToTable(JDT,ao_Arr2)
         if tmp==fCodePtr
            return @onCanJDT2Update()
         end

      end

      if isHeader
         i=0
         while (i<oopp.colsList.GetSize()) do
            case oopp.colsList[i].GetColNum()

            when OJDT_REF_DATE
               SetErrorField(oopp.colsList[i].GetColNum())
               SetErrorLine(-1)
               return -1029
               break
            when OJDT_TAX_DATE
               if bizEnv.IsBlockTaxDateEdit()
                  if !oopp.colsList[i].GetBackupValue().IsEmpty()
                     SetErrorLine(-1)
                     SetErrorField(oopp.colsList[i].GetColNum())
                     return -1029
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
                  return -1029
               end

               break
            when OJDT_REPORT_347
            when OJDT_REPORT_EU
               if bizEnv.IsCurrentLocalSettings(SPAIN_SETTINGS)
                  if oopp.colsList[i].GetBackupValue().Compare(VAL_YES)==0
                     dag.GetColLong(objAbs,OJDT_JDT_NUM)
                     if oopp.colsList[i].GetColNum()==OJDT_REPORT_347
                        CRFLObject.IsTransactionAlreadyReported(isReported,RT_347,bizEnv,JDT,objAbs)
                     else
                        CRFLObject.IsTransactionAlreadyReported(isReported,RT_349,bizEnv,JDT,objAbs)
                     end

                     if isReported
                        SetErrorLine(-1)
                        SetErrorField(oopp.colsList[i].GetColNum())
                        return -1029
                     end

                  end

               end

               break
            when OJDT_BLOCK_DUNNING_LETTER
               if !IsBlockDunningLetterUpdateable()
                  SetErrorLine(-1)
                  SetErrorField(OJDT_BLOCK_DUNNING_LETTER)
                  return -1029
               end

               break
            when OJDT_DUE_DATE
               if self.IsPaymentOrdered()
                  SetErrorLine(-1)
                  SetErrorField(OJDT_DUE_DATE)
                  return -1029
               end

               break
            when OJDT_DEFERRED_TAX
               SetErrorLine(-1)
               SetErrorField(OJDT_DUE_DATE)
               return -1029
               break
            end


            (i+=1;i-2)
         end

      else
         i=0
         while (i<oopp.colsList.GetSize()) do
            case oopp.colsList[i].GetColNum()

            when JDT1_SHORT_NAME
            when JDT1_REF_DATE
            when JDT1_ACCT_NUM
            when JDT1_FC_CURRENCY
               SetErrorField(oopp.colsList[i].GetColNum())
               return -1029
               break
            when JDT1_DEBIT
            when JDT1_CREDIT
            when JDT1_SYS_CREDIT
            when JDT1_SYS_DEBIT
            when JDT1_FC_DEBIT
            when JDT1_FC_CREDIT
            when JDT1_VAT_AMOUNT
            when JDT1_SYS_VAT_AMOUNT
            when JDT1_GROSS_VALUE
            when JDT1_GROSS_VALUE_FC
               if GetDataSource()==VAL_OBSERVER_SOURCE
                  SetErrorField(oopp.colsList[i].GetColNum())
                  return -1029
               else
                  oopp.colsList[i].SetIngnoreUpdate(true)
               end

               break
            when JDT1_TAX_DATE
               if bizEnv.IsBlockTaxDateEdit()
                  SetErrorField(oopp.colsList[i].GetColNum())
                  return -1029
               end

               break
            when JDT1_REF1
            when JDT1_REF2
            when JDT1_TRANS_CODE
            when JDT1_INDICATOR
            when JDT1_ADJ_TRAN_PERIOD_13
            when JDT1_PROJECT
               if !editableInUpdate
                  SetErrorField(oopp.colsList[i].GetColNum())
                  return -1029
               end

               break
            when JDT1_DUE_DATE
            when JDT1_PAYMENT_BLOCK
            when JDT1_PAYMENT_BLOCK_REF
               ordered = SBOString.new=VAL_NO
               dag.GetColStr(ordered,JDT1_ORDERED,oopp.recOffset)
               if ordered==VAL_YES
                  SetErrorLine(oopp.colsList[i].GetColNum())
                  return -1029
               end

               break
            when JDT1_TAX_ID_NUMBER
               if !editableInUpdate
                  SetErrorField(JDT1_TAX_ID_NUMBER)
                  return -1029
               end

               break
            when JDT1_BPL_ID
               if VF_MultiBranch_EnabledInOADM(bizEnv)&&GetCurrentBusinessFlow()==bf_Update
                  SetErrorField(JDT1_BPL_ID)
                  return -1029
               end

               break
            end


            (i+=1;i-2)
         end

      end

      return ooNoErr
   end

   def OnInitData()
      trace("OnInitData")

      dateString = []

      dagJDT = PDAG.new=GetDAG()
      ooErr=CSystemBusinessObject.OnInitData()
      if ooErr
         return ooErr
      end

      DBM_DATE_Get(dateString,self.GetEnv())
      GetDAG().SetColStr(dateString,OJDT_REF_DATE,0)
      ooErr=InitDataReport340(dagJDT)
      if ooErr
         return ooErr
      end

      return (ooErr)
   end

   def OnUpgrade()
      trace("OnUpgrade")
      ooErr=ooNoErr
      dagJDT = PDAG.new
      dagRES = PDAG.new
      dagJDT1 = PDAG.new
      dagBTF = PDAG.new
      condStruct = []

      tableStruct = []

      joinCondStruct = []

      resStruct = []

      updStruct = []



      bizEnv = CBizEnv.new=GetEnv()
      vatPrcnt = MONEY.new
      sysM = MONEY.new
      tmpM = MONEY.new
      if UpgradeVersionCheck(VERSION_64_23)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("Due Date"))
         dagJDT=OpenDAG(JDT,ao_Main)
         _STR_strcpy(tableStruct[0].tableCode,bizEnv.ObjectToTable(JDT,ao_Main))
         _STR_strcpy(tableStruct[1].tableCode,bizEnv.ObjectToTable(JDT,ao_Arr1))
         tableStruct[1].doJoin=true
         tableStruct[1].joinedToTable=0
         tableStruct[1].numOfConds=1
         tableStruct[1].joinConds=joinCondStruct
         joinCondStruct[0].compareCols=true
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
         ooErr=DBD_GetInNewFormat(dagJDT,dagRES)
         if !ooErr
            DAG_GetCount(dagRES,numOfRecs)
            rec=0
            while (rec<numOfRecs) do
               updStruct[0].colNum=OJDT_DUE_DATE
               dagRES.GetColStr(updStruct[0].updateVal,1,rec)
               condStruct[0].colNum=OJDT_JDT_NUM
               condStruct[0].operation=DBD_EQ
               dagRES.GetColStr(condStruct[0].condVal,0,rec)
               condStruct[0].relationship=0
               DBD_SetDAGCond(dagJDT,condStruct,1)
               DBD_SetDAGUpd(dagJDT,updStruct,1)
               ooErr=DBD_UpdateCols(dagJDT)

               (rec+=1;rec-2)
            end

         end

         DAG_Close(dagJDT)
         upgradeBlock.MarkSuccess()
      end

      if bizEnv.IsVatPerLine()&&UpgradeVersionCheck(VERSION_2004_MR)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("Auto VAT"))
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

      if UpgradeVersionCheck(VERSION_2007_MR)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("Source Line Version"))
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
         condStruct[4].compareCols=true
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
         condStruct[7].condVal=0
         condStruct[7].bracketClose=1
         DBD_SetDAGCond(dagJDT1,condStruct,8)
         _MEM_Clear(updStruct,1)
         updStruct[0].colNum=JDT1_SRC_LINE
         updStruct[0].updateVal=1
         DBD_SetDAGUpd(dagJDT1,updStruct,1)
         DBD_UpdateCols(dagJDT1)
         DAG_Close(dagJDT1)
         upgradeBlock.MarkSuccess()
      end

      if UpgradeVersionCheck(VERSION_65_59)&&bizEnv.IsVatPerLine()
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("System Base Sum Version"))
         dagJDT1=OpenDAG(JDT,ao_Arr1)
         _MEM_Clear(condStruct,3)
         condStruct[0].colNum=JDT1_BASE_SUM
         condStruct[0].operation=DBD_NE
         _STR_strcpy(condStruct[0].condVal,STR_0)
         condStruct[0].relationship=DBD_AND
         condStruct[1].colNum=JDT1_DEBIT
         condStruct[1].operation=DBD_NE
         _STR_strcpy(condStruct[1].condVal,STR_0)
         condStruct[1].relationship=DBD_AND
         condStruct[2].colNum=JDT1_SYS_DEBIT
         condStruct[2].operation=DBD_NE
         _STR_strcpy(condStruct[2].condVal,STR_0)
         DBD_SetDAGCond(dagJDT1,condStruct,3)
         _MEM_Clear(updStruct,1)
         updStruct[0].colNum=JDT1_SYS_BASE_SUM
         updStruct[0].SetUpdateColSource(DBD_UpdStruct::ucs_UseRes)
         updStruct[0].GetResObject().agreg_type=DBD_ROUND
         updStruct[0].GetResObject().colConstVal=OO_SUM_DECIMALS(GetEnv())
         pResCol = DBD_ResColumns.new=updStruct[0].GetResObject().AddResCol()
         pResCol.SetTableIndex(0)
         pResCol.SetColNum(JDT1_BASE_SUM)
         pResCol.SetOperation(DBD_MUL)
         pResCol=updStruct[0].GetResObject().AddResCol()
         pResCol.OpenBracket(1)
         pResCol.SetTableIndex(0)
         pResCol.SetColNum(JDT1_SYS_DEBIT)
         pResCol.SetOperation(DBD_DIV)
         pResCol=updStruct[0].GetResObject().AddResCol()
         pResCol.CloseBracket(1)
         pResCol.SetTableIndex(0)
         pResCol.SetColNum(JDT1_DEBIT)
         DBD_SetDAGUpd(dagJDT1,updStruct,1)
         ooErr=DBD_UpdateCols(dagJDT1)
         condStruct[1].colNum=JDT1_CREDIT
         condStruct[2].colNum=JDT1_SYS_CREDIT
         DBD_SetDAGCond(dagJDT1,condStruct,3)
         updStruct[0].GetResObject().Clear()
         updStruct[0].GetResObject().agreg_type=DBD_ROUND
         updStruct[0].GetResObject().colConstVal=OO_SUM_DECIMALS(GetEnv())
         pResCol=updStruct[0].GetResObject().AddResCol()
         pResCol.SetTableIndex(0)
         pResCol.SetColNum(JDT1_BASE_SUM)
         pResCol.SetOperation(DBD_MUL)
         pResCol=updStruct[0].GetResObject().AddResCol()
         pResCol.OpenBracket(1)
         pResCol.SetTableIndex(0)
         pResCol.SetColNum(JDT1_SYS_CREDIT)
         pResCol.SetOperation(DBD_DIV)
         pResCol=updStruct[0].GetResObject().AddResCol()
         pResCol.CloseBracket(1)
         pResCol.SetTableIndex(0)
         pResCol.SetColNum(JDT1_CREDIT)
         DBD_SetDAGUpd(dagJDT1,updStruct,1)
         ooErr=DBD_UpdateCols(dagJDT1)
         _MEM_Clear(updStruct,1)
         DAG_Close(dagJDT1)
         upgradeBlock.MarkSuccess()
      end

      if UpgradeVersionCheck(VERSION_2004_5)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("Paid JDT"))
         dagJDT1=OpenDAG(JDT,ao_Arr1)
         _MEM_Clear(condStruct,1)
         condStruct[0].colNum=JDT1_INTR_MATCH
         condStruct[0].operation=DBD_NE
         condStruct[0].condVal=0
         condStruct[0].relationship=0
         DBD_SetDAGCond(dagJDT1,condStruct,1)
         updStruct[0].colNum=JDT1_CLOSED
         _STR_strcpy(updStruct[0].updateVal,VAL_YES)
         DBD_SetDAGUpd(dagJDT1,updStruct,1)
         ooErr=DBD_UpdateCols(dagJDT1)
         DAG_Close(dagJDT1)
         upgradeBlock.MarkSuccess()
      end

      if UpgradeVersionCheck(VERSION_65_61)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("BOE Control Account"))
         ooErr=@upgradeBoeActs()
         if ooErr
            return ooErr
         end

         upgradeBlock.MarkSuccess()
      end

      vmPeriodInd = MajorReleaseVersionMappingMap.new
      vmPeriodInd.SetAt(b1mr_2004A,VERSION_2004_42)
      if UpgradeVersionCheck(VERSION_65_67,true,true,vmPeriodInd)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("Period Indicator"))
         ooErr=@upgradePeriodIndic()
         if ooErr
            return ooErr
         end

         upgradeBlock.MarkSuccess()
      end

      if UpgradeVersionCheck(VERSION_2004_40)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("Account Serial"))
         dagJDT=OpenDAG(JDT)
         if !(bizEnv.IsLocalSettingsFlag(lsf_IsDocNumMethod))
            updStruct[0].colNum=OJDT_SERIES
            sysDate = SBOString.new
            DBM_DATE_Get(sysDate,bizEnv)
            updStruct[0].updateVal=bizEnv.GetDefaultSeriesByDate(GetBPLId(),GetID(),sysDate)
            DBD_SetDAGUpd(dagJDT,updStruct,1)
            ooErr=DBD_UpdateCols(dagJDT)
            if ooErr
               dagJDT.Close()
               return ooErr
            end

            dagBTF=OpenDAG(BTF)
            DBD_SetDAGUpd(dagBTF,updStruct,1)
            ooErr=DBD_UpdateCols(dagBTF)
            dagBTF.Close()
            if ooErr
               dagJDT.Close()
               return ooErr
            end

         end

         updStruct[0].colNum=OJDT_NUMBER
         updStruct[0].SetUpdateColSource(DBD_UpdStruct::ucs_SrcCol)
         updStruct[0].srcColNum=OJDT_JDT_NUM
         DBD_SetDAGUpd(dagJDT,updStruct,1)
         ooErr=DBD_UpdateCols(dagJDT)
         if ooErr
            dagJDT.Close()
            return ooErr
         end

         dagJDT.Close()
         upgradeBlock.MarkSuccess()
      end

      if UpgradeVersionCheck(VERSION_2004_160)&&bizEnv.IsVatPerLine()
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("Zero Tax"))
         dagJDT1=OpenDAG(JDT,ao_Arr1)
         _MEM_Clear(condStruct,7)
         condStruct[0].colNum=JDT1_TRANS_TYPE
         condStruct[0].operation=DBD_EQ
         condStruct[0].condVal=JDT
         condStruct[0].relationship=DBD_AND
         condStruct[1].colNum=JDT1_VAT_GROUP
         condStruct[1].operation=DBD_NOT_NULL
         condStruct[1].relationship=DBD_AND
         condStruct[2].colNum=JDT1_VAT_GROUP
         condStruct[2].operation=DBD_NE
         condStruct[2].relationship=DBD_AND
         condStruct[3].colNum=JDT1_DEBIT
         condStruct[3].operation=DBD_EQ
         _STR_strcpy(condStruct[3].condVal,STR_0)
         condStruct[3].relationship=DBD_AND
         condStruct[4].colNum=JDT1_CREDIT
         condStruct[4].operation=DBD_EQ
         _STR_strcpy(condStruct[4].condVal,STR_0)
         condStruct[4].relationship=DBD_AND
         condStruct[5].colNum=JDT1_SYS_DEBIT
         condStruct[5].operation=DBD_EQ
         _STR_strcpy(condStruct[5].condVal,STR_0)
         condStruct[5].relationship=DBD_AND
         condStruct[6].colNum=JDT1_SYS_CREDIT
         condStruct[6].operation=DBD_EQ
         _STR_strcpy(condStruct[6].condVal,STR_0)
         DBD_SetDAGCond(dagJDT1,condStruct,7)
         ooErr=DBD_Get(dagJDT1)
         if !ooErr

            debitSide = Boolean.new
            creditSide = Boolean.new
            _MEM_Clear(resStruct,4)
            resStruct[0].colNum=JDT1_DEBIT
            resStruct[1].colNum=JDT1_CREDIT
            resStruct[2].colNum=JDT1_SYS_DEBIT
            resStruct[3].colNum=JDT1_SYS_CREDIT
            DAG_GetCount(dagJDT1,numOfRecs)
            rec=0
            while (rec<numOfRecs) do
               dagJDT1.GetColLong(jdtNum,JDT1_TRANS_ABS,rec)
               dagJDT1.GetColLong(lineId,JDT1_LINE_ID,rec)
               _MEM_Clear(condStruct,2)
               condStruct[0].colNum=JDT1_TRANS_ABS
               condStruct[0].operation=DBD_EQ
               condStruct[0].condVal=jdtNum
               condStruct[0].relationship=DBD_AND
               condStruct[1].compareCols=true
               condStruct[1].colNum=JDT1_SHORT_NAME
               condStruct[1].operation=DBD_NE
               condStruct[1].compColNum=JDT1_ACCT_NUM
               DBD_SetDAGCond(dagJDT1,condStruct,2)
               DBD_SetDAGRes(dagJDT1,resStruct,4)
               ooErr=DBD_GetInNewFormat(dagJDT1,dagRES)
               if !ooErr
                  debitSide=creditSide=false
                  dagRES.GetColMoney(tmpM,0,0,DBM_NOT_ARRAY)
                  if !tmpM.IsZero()
                     creditSide=true
                  end

                  dagRES.GetColMoney(tmpM,1,0,DBM_NOT_ARRAY)
                  if !tmpM.IsZero()
                     debitSide=true
                  end

                  dagRES.GetColMoney(tmpM,2,0,DBM_NOT_ARRAY)
                  if !tmpM.IsZero()
                     creditSide=true
                  end

                  dagRES.GetColMoney(tmpM,3,0,DBM_NOT_ARRAY)
                  if !tmpM.IsZero()
                     debitSide=true
                  end

                  if debitSide
                     _MEM_Clear(condStruct,2)
                     condStruct[0].colNum=JDT1_TRANS_ABS
                     condStruct[0].operation=DBD_EQ
                     condStruct[0].condVal=jdtNum
                     condStruct[0].relationship=DBD_AND
                     condStruct[1].colNum=JDT1_LINE_ID
                     condStruct[1].operation=DBD_EQ
                     condStruct[1].condVal=lineId
                     DBD_SetDAGCond(dagJDT1,condStruct,2)
                     _MEM_Clear(updStruct,2)
                     updStruct[0].colNum=JDT1_CREDIT
                     updStruct[1].colNum=JDT1_SYS_CREDIT
                     DBD_SetDAGUpd(dagJDT1,updStruct,2)
                     ooErr=DBD_UpdateCols(dagJDT1)
                     if ooErr
                        DAG_Close(dagJDT1)
                        return ooErr
                     end

                  else
                     if creditSide
                        _MEM_Clear(condStruct,2)
                        condStruct[0].colNum=JDT1_TRANS_ABS
                        condStruct[0].operation=DBD_EQ
                        condStruct[0].condVal=jdtNum
                        condStruct[0].relationship=DBD_AND
                        condStruct[1].colNum=JDT1_LINE_ID
                        condStruct[1].operation=DBD_EQ
                        condStruct[1].condVal=lineId
                        DBD_SetDAGCond(dagJDT1,condStruct,2)
                        _MEM_Clear(updStruct,2)
                        updStruct[0].colNum=JDT1_DEBIT
                        updStruct[1].colNum=JDT1_SYS_DEBIT
                        DBD_SetDAGUpd(dagJDT1,updStruct,2)
                        ooErr=DBD_UpdateCols(dagJDT1)
                        if ooErr
                           DAG_Close(dagJDT1)
                           return ooErr
                        end

                     end

                  end

               end


               (rec+=1;rec-2)
            end

         end

         DAG_Close(dagJDT1)
         upgradeBlock.MarkSuccess()
      end

      if UpgradeVersionCheck(VERSION_2005_MR)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("Financial Report"))
         dagCPRF = PDAG.new=OpenDAG(PRF)
         _MEM_Clear(condStruct,1)
         condStruct[0].condVal=363
         condStruct[0].colNum=CPRF_FORM
         condStruct[0].operation=DBD_EQ
         condStruct[0].relationship=0
         DBD_SetDAGCond(dagCPRF,condStruct,1)
         DBD_RemoveRecords(dagCPRF)
         condStruct[0].condVal=365
         DBD_SetDAGCond(dagCPRF,condStruct,1)
         DBD_RemoveRecords(dagCPRF)
         DAG_Close(dagCPRF)
         upgradeBlock.MarkSuccess()
      end

      if UpgradeVersionCheck(VERSION_2005_15)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("Card Code"))
         dagCPRF = PDAG.new=OpenDAG(PRF)
         _MEM_Clear(condStruct,1)
         condStruct[0].condVal=964
         condStruct[0].colNum=CPRF_FORM
         condStruct[0].operation=DBD_EQ
         condStruct[0].relationship=0
         DBD_SetDAGCond(dagCPRF,condStruct,1)
         DBD_RemoveRecords(dagCPRF)
         condStruct[0].condVal=965
         DBD_SetDAGCond(dagCPRF,condStruct,1)
         DBD_RemoveRecords(dagCPRF)
         DAG_Close(dagCPRF)
         upgradeBlock.MarkSuccess()
      end

      vmTrialBalance = MajorReleaseVersionMappingMap.new
      vmTrialBalance.SetAt(b1mr_2007A,VERSION_2007_60)
      if UpgradeVersionCheck(VERSION_2005_320,true,true,vmTrialBalance)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("CPRF"))
         dagCPRF = PDAG.new=OpenDAG(PRF)
         _MEM_Clear(condStruct,1)
         condStruct[0].condVal=167
         condStruct[0].colNum=CPRF_FORM
         condStruct[0].operation=DBD_EQ
         condStruct[0].relationship=0
         DBD_SetDAGCond(dagCPRF,condStruct,1)
         DBD_RemoveRecords(dagCPRF)
         DAG_Close(dagCPRF)
         upgradeBlock.MarkSuccess()
      end

      if UpgradeVersionCheck(VERSION_2005_15)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("Base Reference"))
         dagJDT=OpenDAG(JDT)
         _MEM_Clear(condStruct,2)
         condStruct[0].colNum=OJDT_TRANS_TYPE
         condStruct[0].operation=DBD_EQ
         condStruct[0].condVal=JDT
         condStruct[0].relationship=DBD_AND
         condStruct[1].colNum=OJDT_BASE_REF
         condStruct[1].operation=DBD_NE
         condStruct[1].compareCols=true
         condStruct[1].compColNum=OJDT_NUMBER
         DBD_SetDAGCond(dagJDT,condStruct,2)
         _MEM_Clear(resStruct,2)
         resStruct[0].colNum=OJDT_JDT_NUM
         resStruct[1].colNum=OJDT_NUMBER
         DBD_SetDAGRes(dagJDT,resStruct,2)
         ooErr=DBD_GetInNewFormat(dagJDT,dagRES)
         if !ooErr
            dagJDT1=OpenDAG(JDT,ao_Arr1)
            DAG_GetCount(dagRES,numOfRecs)
            rec=0
            while (rec<numOfRecs) do
               updStruct[0].colNum=JDT1_BASE_REF
               dagRES.GetColStr(updStruct[0].updateVal,1,rec)
               condStruct[0].colNum=JDT1_TRANS_ABS
               condStruct[0].operation=DBD_EQ
               dagRES.GetColStr(condStruct[0].condVal,0,rec)
               condStruct[0].relationship=0
               DBD_SetDAGCond(dagJDT1,condStruct,1)
               DBD_SetDAGUpd(dagJDT1,updStruct,1)
               ooErr=DBD_UpdateCols(dagJDT1)
               if ooErr
                  dagJDT.Close()
                  dagJDT1.Close()
                  return ooErr
               end


               (rec+=1;rec-2)
            end

            dagJDT1.Close()
            condStruct[0].colNum=OJDT_TRANS_TYPE
            condStruct[0].operation=DBD_EQ
            condStruct[0].condVal=JDT
            condStruct[0].relationship=DBD_AND
            condStruct[1].colNum=OJDT_BASE_REF
            condStruct[1].operation=DBD_NE
            condStruct[1].compareCols=true
            condStruct[1].compColNum=OJDT_NUMBER
            DBD_SetDAGCond(dagJDT,condStruct,2)
            updStruct[0].colNum=OJDT_BASE_REF
            updStruct[0].SetUpdateColSource(DBD_UpdStruct::ucs_SrcCol)
            updStruct[0].srcColNum=OJDT_NUMBER
            DBD_SetDAGUpd(dagJDT,updStruct,1)
            ooErr=DBD_UpdateCols(dagJDT)
            if ooErr
               dagJDT.Close()
               return ooErr
            end

         end

         dagJDT.Close()
         upgradeBlock.MarkSuccess()
      end

      if bizEnv.IsVatPerLine()&&UpgradeVersionCheck(VERSION_2005_113)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("VAT Infromation")+VERSION_2005_113)
         dagJDT1=OpenDAG(JDT,ao_Arr1)
         _MEM_Clear(condStruct,5)
         condStruct[0].colNum=JDT1_TRANS_TYPE
         condStruct[0].operation=DBD_EQ
         condStruct[0].condVal=JDT
         condStruct[0].relationship=DBD_AND
         condStruct[1].colNum=JDT1_VAT_GROUP
         condStruct[1].operation=DBD_NOT_NULL
         condStruct[1].relationship=DBD_AND
         condStruct[2].colNum=JDT1_VAT_GROUP
         condStruct[2].operation=DBD_NE
         condStruct[2].relationship=DBD_AND
         condStruct[3].colNum=JDT1_DEBIT
         condStruct[3].operation=DBD_NE
         _STR_strcpy(condStruct[3].condVal,STR_0)
         condStruct[3].relationship=DBD_AND
         condStruct[4].colNum=JDT1_CREDIT
         condStruct[4].operation=DBD_IS_NULL
         DBD_SetDAGCond(dagJDT1,condStruct,5)
         _MEM_Clear(updStruct,2)
         updStruct[0].colNum=JDT1_CREDIT
         _STR_strcpy(updStruct[0].updateVal,STR_0)
         updStruct[1].colNum=JDT1_SYS_CREDIT
         _STR_strcpy(updStruct[1].updateVal,STR_0)
         DBD_SetDAGUpd(dagJDT1,updStruct,2)
         ooErr=DBD_UpdateCols(dagJDT1)
         if ooErr
            DAG_Close(dagJDT1)
            return ooErr
         end

         condStruct[3].colNum=JDT1_CREDIT
         condStruct[4].colNum=JDT1_DEBIT
         DBD_SetDAGCond(dagJDT1,condStruct,5)
         updStruct[0].colNum=JDT1_DEBIT
         updStruct[1].colNum=JDT1_SYS_DEBIT
         DBD_SetDAGUpd(dagJDT1,updStruct,2)
         ooErr=DBD_UpdateCols(dagJDT1)
         if ooErr
            DAG_Close(dagJDT1)
            return ooErr
         end

         DAG_Close(dagJDT1)
         upgradeBlock.MarkSuccess()
      end

      if UpgradeVersionCheck(VERSION_2005_117)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("Doc Series"))
         dagSeries = PDAG.new
         dagTransList = PDAG.new




         condStruct1 = []

         conid=bizEnv.GetCompanyConnectionID()
         serverType = DBM_ServerTypes.new=DBMCconnManager.GetHandle().GetConnectionType(conid)
         dagJDT=OpenDAG(JDT)
         _MEM_Clear(resStruct,1)
         resStruct[0].colNum=OJDT_TRANS_TYPE
         resStruct[0].group_by=true
         DBD_SetDAGRes(dagJDT,resStruct,1)
         ooErr=DBD_GetInNewFormat(dagJDT,dagRES)
         if ooErr
            DAG_Close(dagJDT)
            return ooNoErr
         end

         dagRES.Detach()
         dagTMP = PDAG.new=OpenDAG(JDT)
         DAG_GetCount(dagRES,numOfRecs)
         rec=0
         while (rec<numOfRecs) do
            dagRES.GetColLong(transType,0,rec)
            if transType<0||transType==JDT||!bizEnv.IsSerieObject(SBOString(transType))
               _MEM_Clear(condStruct,1)
               condStruct[0].colNum=OJDT_TRANS_TYPE
               condStruct[0].operation=DBD_EQ
               condStruct[0].condVal=transType
               DBD_SetDAGCond(dagJDT,condStruct,1)
               _MEM_Clear(updStruct,1)
               updStruct[0].colNum=OJDT_DOC_SERIES
               updStruct[0].SetUpdateColSource(DBD_UpdStruct::ucs_SrcCol)
               updStruct[0].srcColNum=OJDT_SERIES
               DBD_SetDAGUpd(dagJDT,updStruct,1)
               ooErr=DBD_UpdateCols(dagJDT)
               if ooErr
                  dagJDT.Close()
                  dagRES.Close()
                  dagTMP.Close()
                  return ooErr
               end

            else
               _STR_strcpy(tableStruct[0].tableCode,bizEnv.ObjectToTable(JDT,ao_Main))
               _STR_strcpy(tableStruct[1].tableCode,bizEnv.ObjectToTable(transType,ao_Main))
               tableStruct[1].doJoin=true
               tableStruct[1].joinedToTable=0
               tableStruct[1].numOfConds=1
               tableStruct[1].joinConds=joinCondStruct
               bizEnv.GetTypeColList(tableStruct[1].tableCode,ABSOLUTE_ENT_FLD,numInList,listOfFlds)
               joinCondStruct[0].compareCols=true
               joinCondStruct[0].compTableIndex=0
               joinCondStruct[0].compColNum=OJDT_CREATED_BY
               joinCondStruct[0].tableIndex=1
               joinCondStruct[0].colNum=listOfFlds[0]
               joinCondStruct[0].operation=DBD_EQ
               bizEnv.DisposeColList(listOfFlds)
               _MEM_Clear(condStruct,1)
               condStruct[0].colNum=OJDT_TRANS_TYPE
               condStruct[0].operation=DBD_EQ
               condStruct[0].condVal=transType
               DBD_SetDAGCond(dagJDT,condStruct,1)
               _MEM_Clear(resStruct,1)
               bizEnv.GetTypeColList(tableStruct[1].tableCode,SERIES_FLD,numInList,listOfFlds)
               resStruct[0].colNum=listOfFlds[0]
               resStruct[0].tableIndex=1
               resStruct[0].group_by=true
               bizEnv.DisposeColList(listOfFlds)
               DBD_SetTablesList(dagJDT,tableStruct,2)
               DBD_SetDAGCond(dagJDT,condStruct,1)
               DBD_SetDAGRes(dagJDT,resStruct,1)
               ooErr=DBD_GetInNewFormat(dagJDT,dagSeries)
               if ooErr
                  next

               end

               DAG_GetCount(dagSeries,numOfSeries)
               if numOfSeries==1
                  dagSeries.GetColLong(series,0,0)
                  _MEM_Clear(condStruct,1)
                  condStruct[0].colNum=OJDT_TRANS_TYPE
                  condStruct[0].operation=DBD_EQ
                  condStruct[0].condVal=transType
                  DBD_SetDAGCond(dagJDT,condStruct,1)
                  _MEM_Clear(updStruct,1)
                  updStruct[0].colNum=OJDT_DOC_SERIES
                  updStruct[0].updateVal=series
                  DBD_SetDAGUpd(dagJDT,updStruct,1)
                  ooErr=DBD_UpdateCols(dagJDT)
                  if ooErr
                     dagJDT.Close()
                     dagRES.Close()
                     dagTMP.Close()
                     return ooErr
                  end

               else
                  if serverType==st_MSSQL
                     _MEM_Clear(condStruct,2)
                     condStruct[0].colNum=OJDT_TRANS_TYPE
                     condStruct[0].operation=DBD_EQ
                     condStruct[0].condVal=transType
                     condStruct[0].relationship=DBD_AND
                     bizEnv.GetTypeColList(tableStruct[1].tableCode,SERIES_FLD,numInList,listOfFlds)
                     condStruct[1].colNum=listOfFlds[0]
                     condStruct[1].tableIndex=1
                     condStruct[1].operation=DBD_EQ
                     bizEnv.DisposeColList(listOfFlds)
                     _MEM_Clear(updStruct,1)
                     updStruct[0].colNum=OJDT_DOC_SERIES
                     i=0
                     while (i<numOfSeries) do
                        dagSeries.GetColLong(series,0,i)
                        condStruct[1].condVal=series
                        updStruct[0].updateVal=series
                        DBD_SetTablesList(dagJDT,tableStruct,2)
                        DBD_SetDAGCond(dagJDT,condStruct,2)
                        DBD_SetDAGUpd(dagJDT,updStruct,1)
                        ooErr=DBD_UpdateCols(dagJDT)
                        if ooErr
                           dagJDT.Close()
                           dagRES.Close()
                           dagTMP.Close()
                           return ooErr
                        end


                        (i+=1;i-2)
                     end

                  else
                     _MEM_Clear(condStruct,2)
                     condStruct[0].colNum=OJDT_TRANS_TYPE
                     condStruct[0].operation=DBD_EQ
                     condStruct[0].condVal=transType
                     condStruct[0].relationship=DBD_AND
                     bizEnv.GetTypeColList(tableStruct[1].tableCode,SERIES_FLD,numInList,listOfFlds)
                     condStruct[1].colNum=listOfFlds[0]
                     condStruct[1].tableIndex=1
                     condStruct[1].operation=DBD_EQ
                     bizEnv.DisposeColList(listOfFlds)
                     _MEM_Clear(resStruct,1)
                     resStruct[0].colNum=OJDT_JDT_NUM
                     _MEM_Clear(updStruct,1)
                     updStruct[0].colNum=OJDT_DOC_SERIES
                     i=0
                     while (i<numOfSeries) do
                        dagSeries.GetColLong(series,0,i)
                        condStruct[1].condVal=series
                        updStruct[0].updateVal=series
                        DBD_SetTablesList(dagTMP,tableStruct,2)
                        DBD_SetDAGCond(dagTMP,condStruct,2)
                        DBD_SetDAGRes(dagTMP,resStruct,1)
                        ooErr=DBD_GetInNewFormat(dagTMP,dagTransList)
                        if ooErr
                           next

                        end

                        DAG_GetCount(dagTransList,listNum)
                        j=0
                        while (j<listNum) do
                           dagTransList.GetColLong(transNum,0,j)
                           condStruct1[0].colNum=OJDT_JDT_NUM
                           condStruct1[0].operation=DBD_EQ
                           condStruct1[0].condVal=transNum
                           DBD_SetDAGCond(dagJDT,condStruct1,1)
                           DBD_SetDAGUpd(dagJDT,updStruct,1)
                           ooErr=DBD_UpdateCols(dagJDT)
                           if ooErr
                              dagJDT.Close()
                              dagRES.Close()
                              dagTMP.Close()
                              return ooErr
                           end


                           (j+=1;j-2)
                        end


                        (i+=1;i-2)
                     end

                  end

               end

            end


            (rec+=1;rec-2)
         end

         dagJDT.Close()
         dagRES.Close()
         dagTMP.Close()
         upgradeBlock.MarkSuccess()
      end

      if UpgradeVersionCheck(VERSION_2007_34)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("Control Account Col"))
         dagCPRF = PDAG.new=OpenDAG(PRF)
         formNum = []
         =""

         _MEM_Clear(condStruct,1)
         condStruct[0].colNum=CPRF_FORM
         condStruct[0].operation=DBD_EQ
         condStruct[0].relationship=0
         i=0
         while (formNum[i]>0) do
            condStruct[0].condVal=formNum[i]
            DBD_SetDAGCond(dagCPRF,condStruct,1)
            DBD_RemoveRecords(dagCPRF)

            (i+=1;i-2)
         end

         DAG_Close(dagCPRF)
         upgradeBlock.MarkSuccess()
      end

      if UpgradeVersionCheck(VERSION_2007_MR)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("DPM lines"))
         ooErr=@setToZeroNullLineTypeCols()
         if ooErr
            return ooErr
         end

         ooErr=@setToZeroOldLineTypeCols()
         if ooErr
            return ooErr
         end

         kk=0
         objArr = []
         = ""
         while (objArr[kk]!=-1)
            ooErr=UpgradeDpmLineTypeUsingJDT1(objArr[kk])
            if ooErr
               return ooErr
            end

            ooErr=UpgradeDpmLineTypeUsingRCT2(objArr[kk])
            if ooErr
               return ooErr
            end

            (kk+=1;kk-2)
         end

         upgradeBlock.MarkSuccess()
      end

      if UpgradeVersionCheck(VERSION_2007_010)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("Debit Credit"))
         dagJDT1=OpenDAG(JDT,ao_Arr1)
         _MEM_Clear(condStruct,2)
         _MEM_Clear(updStruct,1)
         condStruct[0].colNum=JDT1_DEBIT_CREDIT
         condStruct[0].operation=DBD_IS_NULL
         condStruct[0].relationship=DBD_AND
         condStruct[1].colNum=JDT1_DEBIT
         condStruct[1].operation=DBD_NE
         condStruct[1].condVal=0
         DBD_SetDAGCond(dagJDT1,condStruct,2)
         updStruct[0].colNum=JDT1_DEBIT_CREDIT
         _STR_strcpy(updStruct[0].updateVal,VAL_DEBIT)
         DBD_SetDAGUpd(dagJDT1,updStruct,1)
         ooErr=DBD_UpdateCols(dagJDT1)
         condStruct[1].colNum=JDT1_CREDIT
         DBD_SetDAGCond(dagJDT1,condStruct,2)
         _STR_strcpy(updStruct[0].updateVal,VAL_CREDIT)
         DBD_SetDAGUpd(dagJDT1,updStruct,1)
         ooErr=DBD_UpdateCols(dagJDT1)
         condStruct[1].colNum=JDT1_SYS_DEBIT
         DBD_SetDAGCond(dagJDT1,condStruct,2)
         _STR_strcpy(updStruct[0].updateVal,VAL_DEBIT)
         DBD_SetDAGUpd(dagJDT1,updStruct,1)
         ooErr=DBD_UpdateCols(dagJDT1)
         condStruct[1].colNum=JDT1_SYS_CREDIT
         DBD_SetDAGCond(dagJDT1,condStruct,2)
         _STR_strcpy(updStruct[0].updateVal,VAL_CREDIT)
         DBD_SetDAGUpd(dagJDT1,updStruct,1)
         ooErr=DBD_UpdateCols(dagJDT1)
         condStruct[1].colNum=JDT1_FC_DEBIT
         DBD_SetDAGCond(dagJDT1,condStruct,2)
         _STR_strcpy(updStruct[0].updateVal,VAL_DEBIT)
         DBD_SetDAGUpd(dagJDT1,updStruct,1)
         ooErr=DBD_UpdateCols(dagJDT1)
         condStruct[1].colNum=JDT1_FC_CREDIT
         DBD_SetDAGCond(dagJDT1,condStruct,2)
         _STR_strcpy(updStruct[0].updateVal,VAL_CREDIT)
         DBD_SetDAGUpd(dagJDT1,updStruct,1)
         ooErr=DBD_UpdateCols(dagJDT1)
         _MEM_Clear(condStruct,3)
         condStruct[0].colNum=JDT1_DEBIT_CREDIT
         condStruct[0].operation=DBD_IS_NULL
         condStruct[0].relationship=DBD_AND
         condStruct[1].colNum=JDT1_DEBIT
         condStruct[1].operation=DBD_IS_NULL
         condStruct[1].relationship=DBD_AND
         condStruct[2].colNum=JDT1_CREDIT
         condStruct[2].operation=DBD_EQ
         condStruct[2].condVal=0
         DBD_SetDAGCond(dagJDT1,condStruct,3)
         updStruct[0].colNum=JDT1_DEBIT_CREDIT
         _STR_strcpy(updStruct[0].updateVal,VAL_CREDIT)
         DBD_SetDAGUpd(dagJDT1,updStruct,1)
         ooErr=DBD_UpdateCols(dagJDT1)
         condStruct[1].colNum=JDT1_CREDIT
         condStruct[1].operation=DBD_IS_NULL
         condStruct[1].relationship=DBD_AND
         condStruct[2].colNum=JDT1_DEBIT
         condStruct[2].operation=DBD_EQ
         condStruct[2].condVal=0
         DBD_SetDAGCond(dagJDT1,condStruct,3)
         updStruct[0].colNum=JDT1_DEBIT_CREDIT
         _STR_strcpy(updStruct[0].updateVal,VAL_DEBIT)
         DBD_SetDAGUpd(dagJDT1,updStruct,1)
         ooErr=DBD_UpdateCols(dagJDT1)
         _MEM_Clear(condStruct,2)
         _MEM_Clear(updStruct,1)
         condStruct[0].colNum=JDT1_DEBIT_CREDIT
         condStruct[0].operation=DBD_EQ
         _STR_strcpy(condStruct[0].condVal,VAL_CREDIT)
         condStruct[0].relationship=DBD_AND
         condStruct[1].colNum=JDT1_DEBIT
         condStruct[1].operation=DBD_NE
         condStruct[1].condVal=0
         DBD_SetDAGCond(dagJDT1,condStruct,2)
         updStruct[0].colNum=JDT1_DEBIT_CREDIT
         _STR_strcpy(updStruct[0].updateVal,VAL_DEBIT)
         DBD_SetDAGUpd(dagJDT1,updStruct,1)
         ooErr=DBD_UpdateCols(dagJDT1)
         condStruct[1].colNum=JDT1_SYS_DEBIT
         DBD_SetDAGCond(dagJDT1,condStruct,2)
         DBD_SetDAGUpd(dagJDT1,updStruct,1)
         ooErr=DBD_UpdateCols(dagJDT1)
         condStruct[1].colNum=JDT1_FC_DEBIT
         DBD_SetDAGCond(dagJDT1,condStruct,2)
         DBD_SetDAGUpd(dagJDT1,updStruct,1)
         ooErr=DBD_UpdateCols(dagJDT1)
         _STR_strcpy(condStruct[0].condVal,VAL_DEBIT)
         condStruct[1].colNum=JDT1_CREDIT
         DBD_SetDAGCond(dagJDT1,condStruct,2)
         updStruct[0].colNum=JDT1_DEBIT_CREDIT
         _STR_strcpy(updStruct[0].updateVal,VAL_CREDIT)
         DBD_SetDAGUpd(dagJDT1,updStruct,1)
         ooErr=DBD_UpdateCols(dagJDT1)
         condStruct[1].colNum=JDT1_SYS_CREDIT
         DBD_SetDAGCond(dagJDT1,condStruct,2)
         DBD_SetDAGUpd(dagJDT1,updStruct,1)
         ooErr=DBD_UpdateCols(dagJDT1)
         condStruct[1].colNum=JDT1_FC_CREDIT
         DBD_SetDAGCond(dagJDT1,condStruct,2)
         DBD_SetDAGUpd(dagJDT1,updStruct,1)
         ooErr=DBD_UpdateCols(dagJDT1)
         DAG_Close(dagJDT1)
         upgradeBlock.MarkSuccess()
      end

      reconUpgMgr = CReconUpgMgr.new=CReconUpgMgr.new(bizEnv,self)
      if UpgradeVersionCheck(VERSION_2007_58)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("UpgradeRCT2"))
         ooErr=reconUpgMgr.UpgradeRCT2TransFields()
         if ooErr
            return ooErr
         end

         upgradeBlock.MarkSuccess()
      end

      if UpgradeVersionCheck(VERSION_2007_60)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("UpgradeRCT2 Negative Part"))
         ooErr=reconUpgMgr.UpgradeRCT2NegativeFields()
         if ooErr
            return ooErr
         end

         upgradeBlock.MarkSuccess()
      end

      if UpgradeVersionCheck(VERSION_2007_MR)||UpgradeVersionCheck(VERSION_2007_53)||UpgradeVersionRangeCheck(VERSION_2007_53,VERSION_2007B_38,true,true)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("Build Views For Bad Payments"))
         ooErr=reconUpgMgr.BuildViewsForBadPayments()
         if ooErr
            reconUpgMgr.ClearViewsForBadPayments()
            reconUpgMgr.__delete
            return ooErr
         end

         upgradeBlock.MarkSuccess()
      end

      if UpgradeVersionCheck(VERSION_2007_MR)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("Clear Views For Bad Payments"))
         ooErr=reconUpgMgr.Upgrade()
         if ooErr
            reconUpgMgr.ClearViewsForBadPayments()
            reconUpgMgr.__delete
            return ooErr
         end

         upgradeBlock.MarkSuccess()
      end

      vmLinkedInv = MajorReleaseVersionMappingMap.new
      vmLinkedInv.SetAt(b1mr_2007B,VERSION_2007B_39)
      if UpgradeVersionCheck(VERSION_2007_81,false,true,vmLinkedInv)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("Fix Linked Invoice Reconciliation"))
         ooErr=reconUpgMgr.FixLinkedInvoiceReconciliation()
         if ooErr
            reconUpgMgr.ClearViewsForBadPayments()
            reconUpgMgr.__delete
            return ooErr
         end

         upgradeBlock.MarkSuccess()
      end

      if UpgradeVersionCheck(VERSION_2007_53)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("Upgrade Partial Reconciliation History"))
         ooErr=reconUpgMgr.UpgradePartialReconciliationHistory()
         if ooErr
            reconUpgMgr.ClearViewsForBadPayments()
            reconUpgMgr.__delete
            return ooErr
         end

         upgradeBlock.MarkSuccess()
      end

      if UpgradeVersionRangeCheck(VERSION_2007B_MR,VERSION_2007B_38,true,true)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("Upgrade Partial ReconHist Replace WrongRecon"))
         ooErr=reconUpgMgr.UpgradePartialReconHistReplaceWrongRecon()
         if ooErr
            reconUpgMgr.ClearViewsForBadPayments()
            reconUpgMgr.__delete
            return ooErr
         end

         upgradeBlock.MarkSuccess()
      end

      reconUpgMgr.ClearViewsForBadPayments()
      reconUpgMgr.__delete
      if UpgradeVersionRangeCheck(VERSION_2007_MR,VERSION_2007_50)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("Upgrade Audit Trail JE Total"))
         ooErr=CReconUpgMgr.UpgradeAuditTrailJETotal(bizEnv)
         if ooErr
            return ooErr
         end

         upgradeBlock.MarkSuccess()
      end

      connID=m_env.GetCompanyConnectionID()
      serverType = DBM_ServerTypes.new=DBMCconnManager.GetHandle().GetConnectionType(connID)
      if UpgradeVersionRangeCheck(VERSION_2007_MR,VERSION_2007_53)&&(serverType!=st_DB2)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("Nullify FCCurrency Field In JDT1"))
         ooErr=CReconUpgMgr.NullifyFCCurrencyFieldInJDT1(bizEnv)
         if ooErr
            return ooErr
         end

         upgradeBlock.MarkSuccess()
      end

      if UpgradeVersionCheck(VERSION_8_8_MR)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("Upgrade Documents VatPaid For Fully Based Credit Memos"))
         objIDs = []
         =""
         i=0
         while (objIDs[i]>=0) do
            ooErr=UpgradeODOCVatPaidForFullyBasedCreditMemos(objIDs[i])
            if ooErr
               return ooErr
            end

            ooErr=UpgradeDOC6VatPaidForFullyBasedCreditMemos(objIDs[i])
            if ooErr
               return ooErr
            end


            (i+=1;i-2)
         end

         upgradeBlock.MarkSuccess()
      end

      isAPA=bizEnv.IsFormerApaLocalSettings()
      if (isAPA&&UpgradeVersionCheck(VERSION_2005B_242))||(!isAPA&&UpgradeVersionCheck(VERSION_2007_22))
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("Upgrade OJDT Created By For WOR"))
         ooErr=@upgradeOJDTCreatedByForWOR()
         if ooErr
            return ooErr
         end

         upgradeBlock.MarkSuccess()
      end

      if (bizEnv.IsChileFolio()||bizEnv.IsMexicoFolio())&&UpgradeVersionCheck(VERSION_2007_MR)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("Upgrade OJDT With Folio"))
         ooErr=@upgradeOJDTWithFolio()
         if ooErr
            return ooErr
         end

         upgradeBlock.MarkSuccess()
      end

      if bizEnv.OADMGetColStr(OADM_CONT_INVENTORY).Compare(VAL_YES)==0&&UpgradeVersionCheck(VERSION_2007_37)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("Upgrade JDT Create Date"))
         ooErr=@upgradeJDTCreateDate()
         if ooErr
            return ooErr
         end

         upgradeBlock.MarkSuccess()
      end

      if UpgradeVersionCheck(VERSION_2007_37)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("Upgrade JDT Canceled Deposit"))
         ooErr=@upgradeJDTCanceledDeposit()
         if ooErr
            return ooErr
         end

         upgradeBlock.MarkSuccess()
      end

      if (serverType!=st_DB2)&&UpgradeVersionCheck(VERSION_2005_319)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("Upgrade Work Order & Landed Cost"))
         ooErr=@upgradeWorkOrderErr()
         if ooErr
            return ooErr
         end

         ooErr=@upgradeLandedCosErr()
         if ooErr
            return ooErr
         end

         upgradeBlock.MarkSuccess()
      end

      if UpgradeVersionCheck(VERSION_2007_53)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("Upgrade Year Transfer"))
         ooErr=@upgradeYearTransfer()
         if ooErr
            return ooErr
         end

         upgradeBlock.MarkSuccess()
      end

      if UpgradeVersionCheck(VERSION_2007_53)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("Remove PRF records"))
         dagCPRF = PDAG.new=OpenDAG(PRF)
         _MEM_Clear(condStruct,1)
         condStruct[0].condVal=964
         condStruct[0].colNum=CPRF_FORM
         condStruct[0].operation=DBD_EQ
         condStruct[0].relationship=0
         DBD_SetDAGCond(dagCPRF,condStruct,1)
         DBD_RemoveRecords(dagCPRF)
         condStruct[0].condVal=965
         DBD_SetDAGCond(dagCPRF,condStruct,1)
         DBD_RemoveRecords(dagCPRF)
         DAG_Close(dagCPRF)
         upgradeBlock.MarkSuccess()
      end

      if UpgradeVersionCheck(VERSION_2007_53)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("Upgrade JDT1 VatLine To No"))
         ooErr=@upgradeJDT1VatLineToNo()
         if ooErr
            return ooErr
         end

         upgradeBlock.MarkSuccess()
      end

      if bizEnv.IsCurrentLocalSettings(INDIA_SETTINGS)&&UpgradeVersionCheck(VERSION_2007B_38)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("Upgrade JDT Indian AutoVat"))
         ooErr=@upgradeJDTIndianAutoVat()
         if ooErr
            return ooErr
         end

         upgradeBlock.MarkSuccess()
      end

      if UpgradeVersionCheck(VERSION_2007_54)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("Upgrade JDT1 Balance related from version")+VERSION_2007_54)
         dagJDT1=OpenDAG(JDT,ao_Arr1)
         _MEM_Clear(condStruct,1)
         condStruct[0].colNum=JDT1_BALANCE_DUE_CREDIT
         condStruct[0].operation=DBD_IS_NULL
         DBD_SetDAGCond(dagJDT1,condStruct,1)
         _MEM_Clear(updStruct,3)
         updStruct[0].colNum=JDT1_BALANCE_DUE_CREDIT
         _STR_strcpy(updStruct[0].updateVal,STR_0)
         updStruct[1].colNum=JDT1_BALANCE_DUE_SC_CRED
         _STR_strcpy(updStruct[1].updateVal,STR_0)
         updStruct[2].colNum=JDT1_BALANCE_DUE_FC_CRED
         _STR_strcpy(updStruct[2].updateVal,STR_0)
         DBD_SetDAGUpd(dagJDT1,updStruct,3)
         ooErr=DBD_UpdateCols(dagJDT1)
         if ooErr
            DAG_Close(dagJDT1)
            return ooErr
         end

         condStruct[0].colNum=JDT1_BALANCE_DUE_DEBIT
         DBD_SetDAGCond(dagJDT1,condStruct,1)
         updStruct[0].colNum=JDT1_BALANCE_DUE_DEBIT
         updStruct[1].colNum=JDT1_BALANCE_DUE_SC_DEB
         updStruct[2].colNum=JDT1_BALANCE_DUE_FC_DEB
         DBD_SetDAGUpd(dagJDT1,updStruct,3)
         ooErr=DBD_UpdateCols(dagJDT1)
         if ooErr
            DAG_Close(dagJDT1)
            return ooErr
         end

         DAG_Close(dagJDT1)
         upgradeBlock.MarkSuccess()
      end

      if UpgradeVersionCheck(VERSION_2007_55)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("Upgrade JDT1 Balance related from version")+VERSION_2007_55)
         dagJDT1=OpenDAG(JDT,ao_Arr1)
         _MEM_Clear(condStruct,2)
         _MEM_Clear(updStruct,1)
         condStruct[0].colNum=JDT1_DEBIT_CREDIT
         condStruct[0].operation=DBD_IS_NULL
         condStruct[0].relationship=DBD_AND
         condStruct[1].colNum=JDT1_BALANCE_DUE_DEBIT
         condStruct[1].operation=DBD_NE
         condStruct[1].condVal=0
         DBD_SetDAGCond(dagJDT1,condStruct,2)
         updStruct[0].colNum=JDT1_DEBIT_CREDIT
         _STR_strcpy(updStruct[0].updateVal,VAL_DEBIT)
         DBD_SetDAGUpd(dagJDT1,updStruct,1)
         ooErr=DBD_UpdateCols(dagJDT1)
         condStruct[1].colNum=JDT1_BALANCE_DUE_CREDIT
         DBD_SetDAGCond(dagJDT1,condStruct,2)
         _STR_strcpy(updStruct[0].updateVal,VAL_CREDIT)
         DBD_SetDAGUpd(dagJDT1,updStruct,1)
         ooErr=DBD_UpdateCols(dagJDT1)
         condStruct[1].colNum=JDT1_BALANCE_DUE_SC_DEB
         DBD_SetDAGCond(dagJDT1,condStruct,2)
         _STR_strcpy(updStruct[0].updateVal,VAL_DEBIT)
         DBD_SetDAGUpd(dagJDT1,updStruct,1)
         ooErr=DBD_UpdateCols(dagJDT1)
         condStruct[1].colNum=JDT1_BALANCE_DUE_SC_CRED
         DBD_SetDAGCond(dagJDT1,condStruct,2)
         _STR_strcpy(updStruct[0].updateVal,VAL_CREDIT)
         DBD_SetDAGUpd(dagJDT1,updStruct,1)
         ooErr=DBD_UpdateCols(dagJDT1)
         condStruct[1].colNum=JDT1_BALANCE_DUE_FC_DEB
         DBD_SetDAGCond(dagJDT1,condStruct,2)
         _STR_strcpy(updStruct[0].updateVal,VAL_DEBIT)
         DBD_SetDAGUpd(dagJDT1,updStruct,1)
         ooErr=DBD_UpdateCols(dagJDT1)
         condStruct[1].colNum=JDT1_BALANCE_DUE_FC_CRED
         DBD_SetDAGCond(dagJDT1,condStruct,2)
         _STR_strcpy(updStruct[0].updateVal,VAL_CREDIT)
         DBD_SetDAGUpd(dagJDT1,updStruct,1)
         ooErr=DBD_UpdateCols(dagJDT1)
         DAG_Close(dagJDT1)
         upgradeBlock.MarkSuccess()
      end

      if UpgradeVersionCheck(VERSION_2007_MR)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("Repair Tax Table"))
         ooErr=@repairTaxTable()
         if ooErr
            return ooErr
         end

         upgradeBlock.MarkSuccess()
      end

      vmDunningDate = MajorReleaseVersionMappingMap.new
      vmDunningDate.SetAt(b1mr_2007A,VERSION_2007_60)
      if UpgradeVersionCheck(VERSION_2005_320,true,true,vmDunningDate)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("Upgrade Dunning date"))
         updStruct = []

         dagJDT1=OpenDAG(JDT,ao_Arr1)
         updStruct[0].srcColNum=JDT1_LAST_DUNNING_DATE
         updStruct[0].colNum=JDT1_LEVEL_UPDATE_DATE
         updStruct[0].SetUpdateColSource(DBD_UpdStruct::ucs_SrcCol)
         DBD_SetDAGUpd(dagJDT1,updStruct,1)
         ooErr=DBD_UpdateCols(dagJDT1)
         DAG_Close(dagJDT1)
         if ooErr
            return ooErr
         end

         upgradeBlock.MarkSuccess()
      end

      if VF_ERDPostingPerDoc(GetEnv())&&UpgradeVersionCheck(VERSION_2007_79)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("Upgrade ERD Base Trans"))
         ooErr=@upgradeERDBaseTrans()
         if ooErr
            return ooErr
         end

         upgradeBlock.MarkSuccess()
      end

      if bizEnv.IsLocalSettingsFlag(lsf_EnableEqualizationVat)&&UpgradeVersionCheck(VERSION_2007_SP1)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("upgrade new columns in JDT1: EQ tax rate, EQ tax amount, Total tax"))
         updateStruct = []

         dagJDT1=OpenDAG(JDT,ao_Arr1)
         updateStruct[0].colNum=JDT1_EQU_VAT_PERCENT
         updateStruct[0].updateVal=STR_0
         updateStruct[1].colNum=JDT1_EQU_VAT_AMOUNT
         updateStruct[1].updateVal=STR_0
         updateStruct[2].colNum=JDT1_SYS_EQU_VAT_AMOUNT
         updateStruct[2].updateVal=STR_0
         updateStruct[3].srcColNum=JDT1_VAT_AMOUNT
         updateStruct[3].colNum=JDT1_TOTAL_TAX
         updateStruct[3].SetUpdateColSource(DBD_UpdStruct::ucs_SrcCol)
         updateStruct[4].srcColNum=JDT1_SYS_VAT_AMOUNT
         updateStruct[4].colNum=JDT1_SYS_TOTAL_TAX
         updateStruct[4].SetUpdateColSource(DBD_UpdStruct::ucs_SrcCol)
         DBD_SetDAGUpd(dagJDT1,updateStruct,5)
         ooErr=DBD_UpdateCols(dagJDT1)
         dagJDT1.Close()
         if ooErr
            return ooErr
         end

         upgradeBlock.MarkSuccess()
      end

      vmCEEPerioEndRecon = MajorReleaseVersionMappingMap.new
      vmCEEPerioEndRecon.SetAt(b1mr_88,VERSION_8_8_221)
      if UpgradeVersionCheck(VERSION_2007_82,true,true,vmCEEPerioEndRecon)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("Upgrade JDT CE EPerio End Reconcilations"))
         if VF_EndclosingOpeningAndClosingAcct(bizEnv)
            ooErr=@upgradeJDTCEEPerioEndReconcilations()
            if ooErr
               return ooErr
            end

         end

         upgradeBlock.MarkSuccess()
      end

      if bizEnv.IsLocalSettingsFlag(lsf_EnableEqualizationVat)&&UpgradeVersionRangeCheck(VERSION_2007_226,VERSION_2007_228)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("Repair Equ Vat Rate Of JDT1"))
         ooErr=@repairEquVatRateOfJDT1()
         if ooErr
            return ooErr
         end

         upgradeBlock.MarkSuccess()
      end

      if UpgradeVersionCheck(VERSION_8_8_223)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("Update [Exchange rate difference] -and- [manual JE with foreign currency]"))
         cols = []
         =""
         dagJDT1=OpenDAG(JDT,ao_Arr1)
         i=0
         while (i<12) do
            _MEM_Clear(condStruct,1)
            condStruct[0].colNum=cols[i]
            condStruct[0].operation=DBD_IS_NULL
            condStruct[0].relationship=0
            DBD_SetDAGCond(dagJDT1,condStruct,1)
            _MEM_Clear(updStruct,1)
            updStruct[0].colNum=cols[i]
            _STR_strcpy(updStruct[0].updateVal,STR_0)
            DBD_SetDAGUpd(dagJDT1,updStruct,1)
            ooErr=dagJDT1.UpdateCols()
            if ooErr
               dagJDT1.Close()
               return ooErr
            end


            (i+=1;i-2)
         end

         dagJDT1.Close()
         upgradeBlock.MarkSuccess()
      end

      if UpgradeVersionCheck(VERSION_8_8_233)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("Federal Tax ID On JE Row"))
         ooErr=@upgradeFederalTaxIdOnJERow()
         if ooErr
            return ooErr
         end

         upgradeBlock.MarkSuccess()
      end

      if UpgradeVersionRangeCheck(VERSION_8_8_314,VERSION_8_8_2_67,true,false)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("Upgrade DprId On JE Row"))
         ooErr=UpgradeDprId(true,VERSION_8_8_314,VERSION_8_8_2_MR)
         if ooErr
            return ooErr
         end

         ooErr=UpgradeDprId(false,VERSION_8_8_314,VERSION_8_8_2_MR)
         if ooErr
            return ooErr
         end

         upgradeBlock.MarkSuccess()
      end

      if UpgradeVersionCheck(VERSION_8_8_2_74)
         upgradeBlock = ObjectUpgradeErrorLogger.new(_T("Upgrade DprId On JE Row for simple DPR payment"))
         ooErr=UpgradeDprIdForOneDprPayment(true,VERSION_8_8_314)
         if ooErr
            return ooErr
         end

         ooErr=UpgradeDprIdForOneDprPayment(false,VERSION_8_8_314)
         if ooErr
            return ooErr
         end

         upgradeBlock.MarkSuccess()
      end

      return ooNoErr
   end

   def OnCancel()
      trace("OnCancel")

      condStruct = []



      dateStr = Date.new
      msgStr = []
      tmpStr = []

      bizEnv = CBizEnv.new=GetEnv()
      dagJDT = PDAG.new=GetDAG()
      dagJDT1 = PDAG.new=GetDAG(JDT,ao_Arr1)
      if !OnCanCancel()
         Message(JTE_JDT_FORM_NUM,27,nil,OO_ERROR)
         return ooErrNoMsg
      end

      dagJDT.GetColLong(sourceDoc,OJDT_TRANS_TYPE,0)
      dagJDT.GetColStr(dateStr,OJDT_REF_DATE,0)
      dagJDT.GetColLong(canceledTrans,OJDT_JDT_NUM)
      condStruct[0].colNum=OJDT_JDT_NUM
      condStruct[0].condVal=canceledTrans
      condStruct[0].operation=DBD_EQ
      condStruct[0].relationship=DBD_AND
      condStruct[1].colNum=OJDT_REF_DATE
      _STR_strcpy(condStruct[1].condVal,dateStr)
      condStruct[1].operation=DBD_GT
      DBD_SetDAGCond(dagJDT,condStruct,2)
      if DBD_Count(dagJDT,true)>0
         Message(GO_OBJ_ERROR_MSGS(JDT),6,nil,OO_ERROR)
         return ooErrNoMsg
      end

      condStruct[1].colNum=OJDT_AUTO_STORNO
      _STR_strcpy(condStruct[1].condVal,VAL_YES)
      condStruct[1].operation=DBD_EQ
      DBD_SetDAGCond(dagJDT,condStruct,2)
      if DBD_Count(dagJDT,true)>0
         Message(JTE_JDT_FORM_NUM,27,nil,OO_ERROR)
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
      if DBD_Count(dagJDT,true)>0
         Message(GO_OBJ_ERROR_MSGS(JDT),3,nil,OO_ERROR)
         return ooErrNoMsg
      end

      condStruct[0].colNum=OJDT_STORNO_TO_TRANS
      condStruct[0].condVal=canceledTrans
      condStruct[0].operation=DBD_EQ
      condStruct[0].relationship=0
      DBD_SetDAGCond(dagJDT,condStruct,1)
      if DBD_Count(dagJDT,true)>0
         _STR_GetStringResource(msgStr,GO_OBJ_ERROR_MSGS(JDT),2,GetEnv())
         _STR_sprintf(tmpStr,msgStr,canceledTrans)
         Message(-1,-1,tmpStr,OO_ERROR)
         return ooErrNoMsg
      end

      if sourceDoc!=OPEN_BLNC_TYPE&&sourceDoc!=CLOSE_BLNC_TYPE&&sourceDoc!=MANUAL_BANK_TRANS_TYPE&&!(sourceDoc==WTR&&VF_ExciseInvoice(bizEnv)&&self.m_isVatJournalEntry)
         dagJDT.SetColLong(JDT,OJDT_TRANS_TYPE,0)
      end

      sboErr=DBD_GetKeyGroup(dagJDT1,JDT1_KEYNUM_PRIMARY,SBOString(canceledTrans),true)
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

   def OnCheckIntegrityOnCreate()
      trace("OnCheckIntegrityOnCreate")

      ooErr=OJDTCheckIntegrityOfJournalEntry(self,false)
      if ooErr
         return ooErr
      end

      return 0
   end

   def OnCheckIntegrityOnUpdate()
      trace("OnCheckIntegrityOnUpdate")

      ooErr=OJDTCheckIntegrityOfJournalEntry(self,false)
      if ooErr
         return ooErr
      end

      return 0
   end

   def OnInitFlow()
      trace("OnInitFlow")
      bizEnv = CBizEnv.new=GetEnv()
      bizEnv.AddCache(ACT)
      bizEnv.AddCache(CRD)
      return ooNoErr
   end

   def OnCommand(command)
      SetExCommand(ooExAutoMode,fa_SetSolo)
      SetExDtCommand(ooOBServerDT,fa_SetSolo)


      case command

      when JournalEntryDocumentTypeService_CmdCode_RefDateChange
         return odHelper.ODRefDateChange()

      when JournalEntryDocumentTypeService_CmdCode_MemoChange
         return odHelper.ODMemoChange()

      else
         return CSystemBusinessObject.OnCommand(command)
      end

      return 0
   end

   def OnSetDynamicMetaData(commandCode)
      ooErr=0
      if commandCode==BusinessService_CmdCode_GetByParams||commandCode==BusinessService_CmdCode_Add
         headerFields = []
         =""
         i=0
         while (headerFields[i]>0) do
            ooErr=SetDynamicMetaData(ao_Main,headerFields[i],false)

            (i+=1)
         end

         SetDynamicMetaData(ao_Arr1,JDT1_LINE_MEMO,true,-1)
         cols = []
         =""
         i=0
         while (cols[i]>0) do
            ooErr=SetDynamicMetaData(ao_Arr1,cols[i],false,-1)

            (i+=1)
         end

      end

      SetBOActionMetaData(BusinessService_CmdCode_Cancel,OnCanCancel())
      return ooErr
   end

   def OnGetByKey()
      ooErr=ooNoErr
      dagJDT = PDAG.new=nil
      dagJDT1 = PDAG.new = nil
      dagCFT = PDAG.new = nil
      bizEnv = CBizEnv.new=GetEnv()
      ooErr=CSystemBusinessObject.OnGetByKey()
      if ooErr&&ooErr!=-1025
         return ooErr
      end

      dagJDT=GetDAG()
      dagJDT1=GetDAG(JDT,ao_Arr1)
      transID = SBOString.new
      dagJDT.GetColStr(transID,OJDT_JDT_NUM,0)
      dagRes = APCompanyDAG.new
      res=0
      begin
         if VF_CashflowReport(bizEnv)
            objID = SBOString.new(CFT)
            dagCFT=GetDAG(objID)
            stmtCFT = DBQRetrieveStatement.new(bizEnv)
            tOCFT = DBQTable.new=stmtCFT.From(bizEnv.ObjectToTable(CFT))
            stmtCFT.Where().Col(tOCFT,OCFT_JDT_ID).EQ().Val(transID).And().Col(tOCFT,OCFT_STATUS).NE().Val(CFT_STATUS_CREDSUM)
            res=stmtCFT.Execute(dagRes)
            dagCFT.Copy(dagRes,dbmBothBuffers)
         end

      rescue DBMException=>e
         return e.GetCode()
      end

      ooErr=LoadTax()
      if ooErr
         return ooErr
      end

      return ooErr
   end

   def CompleteKeys()
      dbErr=ooNoErr
      dbErr=CSystemBusinessObject.CompleteKeys()
      if dbErr
         return dbErr
      end

      dagJDT1 = PDAG.new=GetDAG(JDT,ao_Arr1)
      if dagJDT1.GetDBDMgrPtr().isConnectionCaseSensitive()==true
         return ooNoErr
      end

      dagCRD = PDAG.new=GetDAG(CRD)
      dagACT = PDAG.new=GetDAG(ACT)
      jeLinesCount=dagJDT1.GetRealSize(dbmDataBuffer)
      rec=0
      while (rec<jeLinesCount) do
         shortName = SBOString.new=dagJDT1.GetColStr(JDT1_SHORT_NAME,rec,-1)
         if shortName.IsSpacesStr()
            next

         end

         dbErr=GetEnv().GetByOneKey(dagCRD,OCRD_KEYNUM_PRIMARY,shortName)
         if dbErr==ooNoErr
            dagJDT1.CopyColumn(dagCRD,JDT1_SHORT_NAME,rec,OCRD_CARD_CODE,0)
         else
            if dbErr==-2028
               dbErr=GetEnv().GetByOneKey(dagACT,OACT_KEYNUM_PRIMARY,shortName)
               if dbErr==0
                  dagJDT1.CopyColumn(dagACT,JDT1_SHORT_NAME,rec,OACT_ACCOUNT_CODE,0)
               else
                  SetErrorField(JDT1_SHORT_NAME)
                  SetErrorLine(rec+1)
                  SetArrNum(ao_Arr1)
                  if dbErr==-2028
                     Message(OBJ_MGR_ERROR_MSG,GO_CRD_NAME_MISSING,shortName,OO_ERROR)
                     return ooInvalidObject
                  end

                  return dbErr
               end

            else
               SetErrorField(JDT1_SHORT_NAME)
               SetErrorLine(rec+1)
               SetArrNum(ao_Arr1)
               return dbErr
            end

         end


         (rec+=1;rec-2)
      end

      return ooNoErr
   end

   def OnCanCancel()
      bizEnv = CBizEnv.new=GetEnv()
      ooErr=0
      canCancelJE=false
      if IsPaymentOrdered()
         return false
      end

      dagJDT = PDAG.new=GetDAG()
      dagJDT1 = PDAG.new=GetDAG(JDT,ao_Arr1)
      sourceDoc=0
      dagJDT.GetColLong(sourceDoc,OJDT_TRANS_TYPE,0)
      if sourceDoc==JDT||sourceDoc==OPEN_BLNC_TYPE||sourceDoc==CLOSE_BLNC_TYPE||sourceDoc==MANUAL_BANK_TRANS_TYPE||(sourceDoc==WTR&&VF_ExciseInvoice(bizEnv)&&self.m_isVatJournalEntry)
         canCancelJE=true
         autoStrorno = SBOString.new
         canceledTrans=0
         dagJDT.GetColStrAndTrim(autoStrorno,OJDT_AUTO_STORNO,0)
         if autoStrorno==VAL_YES
            canCancelJE=false
         end

         dagJDT.GetColLong(canceledTrans,OJDT_STORNO_TO_TRANS,0)
         if canceledTrans>0
            canCancelJE=false
         end

      end

      if VF_MultiBranch_EnabledInOADM(bizEnv)&&(sourceDoc==RCT||sourceDoc==VPM)
         dagORCT = PDAG.new=GetDAG(sourceDoc)
         if dagORCT!=nil
            isCentralizedPayment = SBOString.new=dagORCT.GetColStrAndTrim(ORCT_BPL_CENT_PMT,0,coreSystemDefault)
            pmntTransId=dagORCT.GetColStrAndTrim(ORCT_TRANS_NUM,0,coreSystemDefault).strtol()
            currTransId=dagJDT.GetColStrAndTrim(OJDT_JDT_NUM,0,coreSystemDefault).strtol()
            createdBy=dagJDT.GetColStrAndTrim(OJDT_CREATED_BY,0,coreSystemDefault).strtol()
            pmtAbsEntry=dagORCT.GetColStrAndTrim(ORCT_ABS_ENTRY,0,coreSystemDefault).strtol()
            if isCentralizedPayment==VAL_YES&&pmntTransId!=currTransId&&createdBy==pmtAbsEntry
               canCancelJE=true
            end

         end

      end

      canceledTrans=0
      dagJDT.GetColLong(canceledTrans,OJDT_JDT_NUM,0)
      begin
         stmt = DBQRetrieveStatement.new(bizEnv)
         tOJDT = DBQTable.new=stmt.From(bizEnv.ObjectToTable(JDT,ao_Main))
         stmt.Select().Count().Col(tOJDT,OJDT_JDT_NUM)
         stmt.Where().Col(tOJDT,OJDT_STORNO_TO_TRANS).EQ().Val(canceledTrans)
         pResDag = APCompanyDAG.new
         stmt.Execute(pResDag)
         cancelNum=0
         pResDag.GetColLong(cancelNum,0)
         if cancelNum>0
            canCancelJE=false
         end

      rescue DBMException=>e
         ooErr=e.GetCode()
      end

      return canCancelJE
   end

   def CanArchiveAddWhere(bizEnv,canArchiveStmt,archiveDate,tObjectTable)
      subQ_unReconciledBPlines = DBQRetrieveStatement.new=canArchiveStmt.CreateSubquery()
      tJDT1 = DBQTable.new=subQ_unReconciledBPlines.From("JDT1")
      subQ_unReconciledBPlines.Select().Col(tJDT1,JDT1_TRANS_ABS)
      subQ_unReconciledBPlines.Where().Col(tJDT1,JDT1_TRANS_ABS).EQ().Col(tObjectTable,OJDT_JDT_NUM).And().OpenBracket()
      if bizEnv.IsLocalSettingsFlag(lsf_EnableCardClosingPeriod)
         subQ_unReconciledBPlines.Where().OpenBracket()
      end

      subQ_unReconciledBPlines.Where().Col(tJDT1,JDT1_SHORT_NAME).NE().Col(tJDT1,JDT1_ACCT_NUM).And().OpenBracket().Col(tJDT1,JDT1_BALANCE_DUE_CREDIT).NE().Val(0).Or().Col(tJDT1,JDT1_BALANCE_DUE_FC_CRED).NE().Val(0).Or().Col(tJDT1,JDT1_BALANCE_DUE_DEBIT).NE().Val(0).Or().Col(tJDT1,JDT1_BALANCE_DUE_FC_DEB).NE().Val(0).CloseBracket().CloseBracket()
      if bizEnv.IsLocalSettingsFlag(lsf_EnableCardClosingPeriod)
         subQ_unReconciledBPlines.Where().Or().Col(tJDT1,JDT1_SRC_LINE).EQ().Val(PMN_VAL_CLOSE_PER).CloseBracket()
      end

      temp = Date.new=archiveDate
      dateStr = SBOString.new
      temp.ToStr(dateStr,bizEnv)
      if !dateStr.IsEmpty()
         canArchiveStmt.Where().Col(tObjectTable,OJDT_REF_DATE).LE().Val(temp).And()
      end

      canArchiveStmt.Where().Col(tObjectTable,OJDT_TRANS_TYPE).NE().Val(CLOSE_BLNC_TYPE).And().NotExists().OpenBracket().Subquery(subQ_unReconciledBPlines).CloseBracket()
      return 0
   end

   def GetArchiveDocNumCol(outArcDocNumCol)
      outArcDocNumCol=OJDT_JDT_NUM
      return 0
   end

   def CompleteDataForArchivingLog()
      sboErr=CBusinessObjectBase.CompleteDataForArchivingLog()
      if sboErr
         return sboErr
      end

      bizEnv = CBizEnv.new=GetEnv()
      selectedBPTempTbl = SBOString.new=GetArchiveSelectedBPTblName()
      if !selectedBPTempTbl.IsEmpty()&&bizEnv.GetCompanyConnection().DBisTableExists(selectedBPTempTbl,bizEnv)
         dagTMP_ARC = PDAG.new=GetDAG(TMP)
         tempArcTableName = SBOString.new=dagTMP_ARC.GetTableName()
         begin
            updStmt = DBQUpdateStatement.new(bizEnv)
            updTbl = DBQTable.new=updStmt.Update(tempArcTableName)
            stmt = DBQRetrieveStatement.new=updStmt.CreateSubquery()
            tTDAR = DBQTable.new=stmt.From(tempArcTableName)
            tOJDT = DBQTable.new=stmt.Join(bizEnv.ObjectToTable(JDT),tTDAR)
            stmt.On(tOJDT).Col(tOJDT,OJDT_JDT_NUM).EQ().Col(tTDAR,TDAR_DOC_ABS).And().Col(tTDAR,TDAR_DOC_TYPE).EQ().Val(JDT)
            tJDT1 = DBQTable.new=stmt.Join(bizEnv.ObjectToTable(JDT,ao_Arr1),tOJDT)
            stmt.On(tJDT1).Col(tJDT1,JDT1_TRANS_ABS).EQ().Col(tOJDT,OJDT_JDT_NUM)
            tSelBPs = DBQTable.new=stmt.Join(selectedBPTempTbl,tJDT1)
            stmt.On(tSelBPs).Col(tSelBPs,TSEL_BP_CARD_CODE_COL).EQ().Col(tJDT1,JDT1_SHORT_NAME)
            stmt.Where().Col(tOJDT,OJDT_TRANS_TYPE).EQ().Val(JDT).And().Col(tJDT1,JDT1_ACCT_NUM).NE().Col(tJDT1,JDT1_SHORT_NAME)
            stmt.Select().Col(tTDAR,TDAR_DOC_ABS)
            stmt.Distinct()
            updStmt.Set(TDAR_CARD_CODE).Val(_T("--"))
            updStmt.Where().Col(updTbl,TDAR_DOC_TYPE).EQ().Val(JDT).And().Col(updTbl,TDAR_DOC_ABS).In().Subquery(stmt)
            updStmt.Execute()
         rescue DBMException=>e
            return e.GetCode()
         end

         begin
            updStmt = DBQUpdateStatement.new(bizEnv)
            stmt = DBQRetrieveStatement.new=updStmt.CreateSubquery()
            tTDAR = DBQTable.new=stmt.From(tempArcTableName)
            tOJDT = DBQTable.new=stmt.Join(bizEnv.ObjectToTable(JDT),tTDAR)
            stmt.On(tOJDT).Col(tOJDT,OJDT_JDT_NUM).EQ().Col(tTDAR,TDAR_DOC_ABS).And().Col(tTDAR,TDAR_DOC_TYPE).EQ().Val(JDT)
            tJDT1 = DBQTable.new=stmt.Join(bizEnv.ObjectToTable(JDT,ao_Arr1),tOJDT)
            stmt.On(tJDT1).Col(tJDT1,JDT1_TRANS_ABS).EQ().Col(tOJDT,OJDT_JDT_NUM)
            tSelBPs = DBQTable.new=stmt.Join(selectedBPTempTbl,tJDT1,DBQ_JT_LEFT_OUTER_JOIN)
            stmt.On(tSelBPs).Col(tSelBPs,TSEL_BP_CARD_CODE_COL).EQ().Col(tJDT1,JDT1_SHORT_NAME)
            stmt.Where().Col(tOJDT,OJDT_TRANS_TYPE).EQ().Val(JDT).And().Col(tJDT1,JDT1_ACCT_NUM).NE().Col(tJDT1,JDT1_SHORT_NAME).And().Col(tSelBPs,0).IsNull()
            stmt.Select().Col(tTDAR,TDAR_DOC_ABS)
            stmt.Distinct()
            updTbl = DBQTable.new=updStmt.Update(tempArcTableName)
            updStmt.Set(TDAR_CAN_ARC_OBJ).Val(VAL_DOCUMENT_FROM_DIFF_BP_FAIL)
            updStmt.Where().Col(updTbl,TDAR_DOC_TYPE).EQ().Val(JDT).And().Col(updTbl,TDAR_DOC_ABS).In().Subquery(stmt)
            updStmt.Execute()
         rescue DBMException=>e
            return e.GetCode()
         end

      end

      return 0
   end

   def UpdateTax()
      trace("UpdateTax")
      taxAdaptor = CTaxAdaptorJournalEntry.new=OnGetTaxAdaptor()
      if !taxAdaptor
         return ooNoErr
      end

      dagJDT = PDAG.new=GetDAG()

      dagJDT.GetColLong(transId,OJDT_JDT_NUM)
      return taxAdaptor.Update(transId)
   end

   def OnGetCostAccountingFields(costAccountingFieldMap)
      costAccountingFields = CostAccountingField.new
      distrRule = LongArray.new
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

   def initialize_v1(other)
      @m_digitalSignature = other.GetEnv()

   end

   def OJDTFillJDT1FromAccounts(accountsArrayFrom,accountsArrayRes,srcObject)
      trace("OJDTFillJDT1FromAccounts")



      linesAdded = false
      zeroSum = MONEY.new
      dagJDT1 = PDAG.new=GetArrayDAG(ao_Arr1)
      dagJDT = PDAG.new=GetDAG()
      bizEnv = CBizEnv.new=GetEnv()
      if !DAG_IsValid(dagJDT1)
         return (-2007)
      end

      numOfAccts=accountsArrayFrom.GetSize()
      if numOfAccts<=0
         return ooNoErr
      end

      ii=0
      while (ii<numOfAccts) do
         if !accountsArrayFrom[ii].allowZeros
            if accountsArrayFrom[ii].sum==0&&accountsArrayFrom[ii].sysSum==0&&accountsArrayFrom[ii].frgnSum==0
               next

            end

         end

         linesAdded=true
         accountsArrayRes.Add((accountsArrayFrom[ii].Clone()))
         jdtLine=accountsArrayRes.GetSize()-1
         if jdtLine==0
            DAG_SetSize(dagJDT1,1,dbmDropData)
            dagJDT1.SetBackupSize(1,dbmDropData)
         else
            DAG_SetSize(dagJDT1,jdtLine+1,dbmKeepData)
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

         postDate = SBOString.new
         dagJDT1.GetColStr(postDate,JDT1_REF_DATE,jdtLine)
         dim=0
         while (dim<nDimCount) do
            if !_STR_IsSpacesStr(accountsArrayRes[jdtLine].ocrCode[dim])
               dagJDT1.SetColStr(accountsArrayRes[jdtLine].ocrCode[dim],GetOcrCodeCol(dim),jdtLine)
               validFrom = SBOString.new
               COverheadCostRateObject.GetValidFrom(bizEnv,accountsArrayRes[jdtLine].ocrCode[dim],postDate,validFrom)
               dagJDT1.SetColStr(validFrom,GetValidFromCol(dim),jdtLine)
            end


            (dim+=1;dim-2)
         end

         if !_STR_IsSpacesStr(accountsArrayRes[jdtLine].prjCode)
            dagJDT1.SetColStr(accountsArrayRes[jdtLine].prjCode,JDT1_PROJECT,jdtLine)
         end

         if VF_PaymentTraceability(bizEnv)
            if accountsArrayRes[jdtLine].cig!=0
               dagJDT1.SetColLong(accountsArrayRes[jdtLine].cig,JDT1_CIG,jdtLine)
            end

            if accountsArrayRes[jdtLine].cup!=0
               dagJDT1.SetColLong(accountsArrayRes[jdtLine].cup,JDT1_CUP,jdtLine)
            end

         end

         isNegative=accountsArrayRes[jdtLine].sum.IsNegative()||accountsArrayRes[jdtLine].sysSum.IsNegative()||accountsArrayRes[jdtLine].frgnSum.IsNegative()
         useNegativeAmount=bizEnv.GetUseNegativeAmount()

         dagJDT.GetColLong(transType,OJDT_TRANS_TYPE)
         if transType==RCT||transType==VPM
            useNegativeAmount=true
         end

         if isNegative&&!useNegativeAmount
            accountsArrayRes[jdtLine].sum*=-1
            accountsArrayRes[jdtLine].sysSum*=-1
            accountsArrayRes[jdtLine].frgnSum*=-1
            if accountsArrayRes[jdtLine].debCred==DEBIT
               accountsArrayRes[jdtLine].debCred=CREDIT
            else
               accountsArrayRes[jdtLine].debCred=DEBIT
            end

         end

         if accountsArrayRes[jdtLine].debCred==DEBIT
            dagJDT1.SetColMoney(accountsArrayRes[jdtLine].sum,JDT1_DEBIT,jdtLine)
            dagJDT1.SetColMoney(accountsArrayRes[jdtLine].sysSum,JDT1_SYS_DEBIT,jdtLine)
            dagJDT1.SetColMoney(accountsArrayRes[jdtLine].frgnSum,JDT1_FC_DEBIT,jdtLine)
            if accountsArrayRes[jdtLine].nullifyOppsSumCols
               dagJDT1.NullifyCol(JDT1_CREDIT,jdtLine)
               dagJDT1.NullifyCol(JDT1_SYS_CREDIT,jdtLine)
               dagJDT1.NullifyCol(JDT1_FC_CREDIT,jdtLine)
            else
               dagJDT1.SetColMoney(zeroSum,JDT1_CREDIT,jdtLine)
               dagJDT1.SetColMoney(zeroSum,JDT1_SYS_CREDIT,jdtLine)
               dagJDT1.SetColMoney(zeroSum,JDT1_FC_CREDIT,jdtLine)
            end

         else
            dagJDT1.SetColMoney(accountsArrayRes[jdtLine].sum,JDT1_CREDIT,jdtLine)
            dagJDT1.SetColMoney(accountsArrayRes[jdtLine].sysSum,JDT1_SYS_CREDIT,jdtLine)
            dagJDT1.SetColMoney(accountsArrayRes[jdtLine].frgnSum,JDT1_FC_CREDIT,jdtLine)
            if accountsArrayRes[jdtLine].nullifyOppsSumCols
               dagJDT1.NullifyCol(JDT1_DEBIT,jdtLine)
               dagJDT1.NullifyCol(JDT1_SYS_DEBIT,jdtLine)
               dagJDT1.NullifyCol(JDT1_FC_DEBIT,jdtLine)
            else
               dagJDT1.SetColMoney(zeroSum,JDT1_DEBIT,jdtLine)
               dagJDT1.SetColMoney(zeroSum,JDT1_SYS_DEBIT,jdtLine)
               dagJDT1.SetColMoney(zeroSum,JDT1_FC_DEBIT,jdtLine)
            end

         end

         if !_STR_IsSpacesStr(accountsArrayRes[jdtLine].vatGroup)
            dagJDT1.SetColStr(accountsArrayRes[jdtLine].vatGroup,JDT1_VAT_GROUP,jdtLine)
            dagJDT1.SetColMoney(accountsArrayRes[jdtLine].vatPrcnt,JDT1_VAT_PERCENT,jdtLine)
            dagJDT1.SetColMoney(accountsArrayRes[jdtLine].equVatPrcnt,JDT1_EQU_VAT_PERCENT,jdtLine)
            dagJDT1.SetColMoney(accountsArrayRes[jdtLine].vatBaseSum,JDT1_BASE_SUM,jdtLine)
            dagJDT1.SetColMoney(accountsArrayRes[jdtLine].vatBaseSC,JDT1_SYS_BASE_SUM,jdtLine)
            dagJDT1.SetColStr(VAL_YES,JDT1_VAT_LINE,jdtLine)
         end

         dagJDT1.SetColLong(accountsArrayRes[jdtLine].lineType,JDT1_LINE_TYPE,jdtLine)
         if !accountsArrayRes[jdtLine].frgnSum.IsZero()&&!_STR_IsSpacesStr(accountsArrayRes[jdtLine].curCurrency)
            dagJDT1.SetColStr(accountsArrayRes[jdtLine].curCurrency,JDT1_FC_CURRENCY,jdtLine)
         end

         if !_STR_IsSpacesStr(accountsArrayRes[jdtLine].dueDate)
            dagJDT1.SetColStr(accountsArrayRes[jdtLine].dueDate,JDT1_DUE_DATE,jdtLine)
         end

         if !_STR_IsSpacesStr(accountsArrayRes[jdtLine].taxDate)
            dagJDT1.SetColStr(accountsArrayRes[jdtLine].taxDate,JDT1_TAX_DATE,jdtLine)
         end

         if accountsArrayRes[jdtLine].debCred==DEBIT
            dagJDT1.SetColStr(VAL_DEBIT,JDT1_DEBIT_CREDIT,jdtLine)
         else
            dagJDT1.SetColStr(VAL_CREDIT,JDT1_DEBIT_CREDIT,jdtLine)
         end

         if !_STR_IsSpacesStr(accountsArrayRes[jdtLine].refDate)
            dagJDT1.SetColStr(accountsArrayRes[jdtLine].refDate,JDT1_REF_DATE,jdtLine)
            ocrCode = SBOString.new
            dagJDT1.GetColStr(ocrCode,JDT1_OCR_CODE,jdtLine)
            validFrom = SBOString.new
            COverheadCostRateObject.GetValidFrom(bizEnv,ocrCode,accountsArrayRes[jdtLine].refDate.GetString(),validFrom)
            dagJDT1.SetColStr(validFrom,JDT1_VALID_FROM,jdtLine)
         end

         if !_STR_IsSpacesStr(accountsArrayRes[jdtLine].vatDate)
            dagJDT1.SetColStr(accountsArrayRes[jdtLine].vatDate,JDT1_VAT_DATE,jdtLine)
         end

         if !_STR_IsSpacesStr(accountsArrayRes[jdtLine].ref1)
            dagJDT1.SetColStr(accountsArrayRes[jdtLine].ref1,JDT1_REF1,jdtLine)
         end

         if !_STR_IsSpacesStr(accountsArrayRes[jdtLine].ref2)
            dagJDT1.SetColStr(accountsArrayRes[jdtLine].ref2,JDT1_REF2,jdtLine)
         end

         if !_STR_IsSpacesStr(accountsArrayRes[jdtLine].refLine)
            dagJDT1.SetColStr(accountsArrayRes[jdtLine].refLine,JDT1_REF3_LINE,jdtLine)
         end

         if !_STR_IsSpacesStr(accountsArrayRes[jdtLine].indicator)
            dagJDT1.SetColStr(accountsArrayRes[jdtLine].indicator,JDT1_INDICATOR,jdtLine)
         end

         if !_STR_IsSpacesStr(accountsArrayRes[jdtLine].paymentRef)
            dagJDT1.SetColStr(accountsArrayRes[jdtLine].paymentRef,JDT1_PAYMENT_REF,jdtLine)
         end

         if !_STR_IsSpacesStr(accountsArrayRes[jdtLine].srcAbsId)
            dagJDT1.SetColStr(accountsArrayRes[jdtLine].srcAbsId,JDT1_SRC_ABS_ID,jdtLine)
         end

         if !_STR_IsSpacesStr(accountsArrayRes[jdtLine].srcLine)
            dagJDT1.SetColStr(accountsArrayRes[jdtLine].srcLine,JDT1_SRC_LINE,jdtLine)
         end

         if !_STR_IsSpacesStr(accountsArrayRes[jdtLine].checkAbs)
            dagJDT1.SetColStr(accountsArrayRes[jdtLine].checkAbs,JDT1_CHECK_ABS,jdtLine)
         end

         if !_STR_IsSpacesStr(accountsArrayRes[jdtLine].relType)
            dagJDT1.SetColStr(accountsArrayRes[jdtLine].relType,JDT1_REL_TYPE,jdtLine)
         end

         if !_STR_IsSpacesStr(accountsArrayRes[jdtLine].lineMemo)
            dagJDT1.SetColStr(accountsArrayRes[jdtLine].lineMemo,JDT1_LINE_MEMO,jdtLine)
         end

         if VF_TaxPayment(bizEnv)
            dagJDT1.SetColLong(accountsArrayRes[jdtLine].com_vat,JDT1_CENVAT_COM,jdtLine)
            dagJDT1.SetColLong(accountsArrayRes[jdtLine].mat_type,JDT1_MATERIAL_TYPE,jdtLine)
         end

         if VF_MultipleRegistrationNumber(bizEnv)&&accountsArrayRes[jdtLine].location!=0
            dagJDT1.SetColLong(accountsArrayRes[jdtLine].location,JDT1_LOCATION,jdtLine)
         end

         if VF_WTaxAccumulateControl(bizEnv)&&!_STR_IsSpacesStr(accountsArrayRes[jdtLine].m_WTCode)
            dagJDT1.SetColStr(accountsArrayRes[jdtLine].m_WTCode,JDT1_WTAX_CODE,jdtLine)
         end

         if nil!=srcObject
            referenceLinksBPtarget=((_STR_strcmp(accountsArrayRes[jdtLine].actCode,accountsArrayRes[jdtLine].shortName)!=0)&&(!_STR_IsSpacesStr(accountsArrayRes[jdtLine].shortName)))
            ooErr=CRefLinksDef.ExecuteRefLinks(srcObject,self,(referenceLinksBPtarget) ? RLD_TYPE_BP_LINE_VAL : RLD_TYPE_LINE_VAL,jdtLine)
            if ooErr
               return (ooErr)
            end

         end

         dprAbsId=accountsArrayRes[jdtLine].dprAbsId
         if -1!=dprAbsId
            dagJDT1.SetColLong(dprAbsId,JDT1_DPR_ABS_ID,jdtLine)
         end

         dagJDT1.SetColLong(accountsArrayRes[jdtLine].interimAcctType,JDT1_INTERIM_ACCT_TYPE,jdtLine)
         if VF_MultiBranch_EnabledInOADM(bizEnv)&&(CBusinessPlaceObject.IsValidBPLId(accountsArrayRes[jdtLine].m_BPLId)||CBusinessPlaceObject.IsValidBPLId(GetBPLId()))
            bPLId=CBusinessPlaceObject.IsValidBPLId(accountsArrayRes[jdtLine].m_BPLId) ? accountsArrayRes[jdtLine].m_BPLId : GetBPLId()
            bplInfo = CBusinessPlaceObject::BPLInfo.new
            ooErr=CBusinessPlaceObject.GetBPLInfo(bizEnv,BPLId,bplInfo)
            if ooErr
               return ooErr
            end

            dagJDT1.SetColLong(bplInfo.GetBPLId(),JDT1_BPL_ID,jdtLine)
            dagJDT1.SetColStr(bplInfo.GetBPLName(),JDT1_BPL_NAME,jdtLine)
            dagJDT1.SetColStr(bplInfo.GetVatRegNum(),JDT1_VAT_REG_NUM,jdtLine)
         else
            dagJDT1.NullifyCol(JDT1_BPL_ID,jdtLine)
            dagJDT1.NullifyCol(JDT1_BPL_NAME,jdtLine)
            dagJDT1.NullifyCol(JDT1_VAT_REG_NUM,jdtLine)
         end


         (ii+=1)
      end

      if bizEnv.IsCurrentLocalSettings(FRANCE_SETTINGS)
         glAcct = SBOString.new
         transCode1 = SBOString.new
         transCode2 = SBOString.new


         CJournalManager.GetDefaultTransCode(self,dagJDT,dagJDT1,glAcct,transCode1,jdtLine)
         if jdtLine>=0&&!glAcct.IsEmpty()&&!transCode1.IsEmpty()
            dagJDT.GetColStr(transCode2,OJDT_TRANS_CODE,0)
            if transCode2.IsEmpty()
               dagJDT.SetColStr(transCode1,OJDT_TRANS_CODE,0)
               numOfRecs=dagJDT1.GetRecordCount()
               rec=0
               while (rec<=numOfRecs) do
                  dagJDT1.SetColStr(transCode1,JDT1_TRANS_CODE,rec)

                  (rec+=1;rec-2)
               end

            else
               dagJDT1.SetColStr(transCode2,JDT1_TRANS_CODE,jdtLine)
            end

         end

      end

      if !linesAdded
         return -2028
      end

      return ooNoErr
   end

   def IsCardAlreadyThere(updateCardBalanceCond,cardCode,startingRec,numOfCardConds)
      trace("IsCardAlreadyThere")

      ii=startingRec
      while (ii<numOfCardConds) do
         if !_STR_strcmp(updateCardBalanceCond[ii].condVal,cardCode)
            return true
         end


         (ii+=1;ii-2)
      end

      return false
   end

   def BuildRelatedBoeQuery(tableStruct,numOfConds,iterationType,numOfTables,condStruct,joinCondStructForOtherObj,joinCondStructBoe)
      trace("BuildRelatedBoeQuery")


      bizEnv = CBizEnv.new=GetEnv()
      if iterationType==0
         _STR_strcpy(tableStruct[((numOfTables)+=1;(numOfTables)-2)].tableCode,bizEnv.ObjectToTable(BOT,ao_Main))
         absJoinField=OBOT_ABS_ENTRY
         jdt1JoinField=JDT1_SRC_ABS_ID
         objJoinField=BOT
      else
         if iterationType==1
            _STR_strcpy(tableStruct[((numOfTables)+=1;(numOfTables)-2)].tableCode,bizEnv.ObjectToTable(RCT,ao_Main))
            absJoinField=ORCT_NUM
            _STR_strcpy(tableStruct[((numOfTables)+=1;(numOfTables)-2)].tableCode,bizEnv.ObjectToTable(BOE,ao_Main))
            objJoinField=RCT
            jdt1JoinField=JDT1_CREATED_BY
         else
            _STR_strcpy(tableStruct[((numOfTables)+=1;(numOfTables)-2)].tableCode,bizEnv.ObjectToTable(DPS,ao_Main))
            absJoinField=ODPS_ABS_ENT
            objJoinField=DPS
            jdt1JoinField=JDT1_SRC_ABS_ID
         end

      end

      tableStruct[1].doJoin=true
      tableStruct[1].joinedToTable=0
      tableStruct[1].numOfConds=2
      tableStruct[1].joinConds=joinCondStructForOtherObj
      joinCondStructForOtherObj[0].compareCols=true
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
      if iterationType==0
         condStruct[numOfConds].bracketOpen=1
         condStruct[numOfConds].colNum=OBOT_STATUS_FROM
         condStruct[numOfConds].operation=DBD_EQ
         condStruct[numOfConds].tableIndex=1
         _STR_strcpy(condStruct[numOfConds].condVal,VAL_BOE_DEPOSITED)
         condStruct[((numOfConds)+=1;(numOfConds)-2)].relationship=DBD_AND
         condStruct[numOfConds].colNum=JDT1_LINE_ID
         condStruct[numOfConds].operation=DBD_EQ
         condStruct[numOfConds].tableIndex=0
         condStruct[numOfConds].condVal=1
         condStruct[((numOfConds)+=1;(numOfConds)-2)].relationship=DBD_OR
         condStruct[numOfConds].colNum=OBOT_STATUS_FROM
         condStruct[numOfConds].operation=DBD_EQ
         condStruct[numOfConds].tableIndex=1
         _STR_strcpy(condStruct[numOfConds].condVal,VAL_BOE_PAID)
         condStruct[((numOfConds)+=1;(numOfConds)-2)].relationship=DBD_AND
         condStruct[numOfConds].colNum=JDT1_LINE_ID
         condStruct[numOfConds].operation=DBD_EQ
         condStruct[numOfConds].tableIndex=0
         condStruct[numOfConds].condVal=0
         condStruct[((numOfConds)+=1;(numOfConds)-2)].relationship=DBD_AND
         condStruct[(numOfConds)-1].bracketClose=1
      else
         if iterationType==1
            tableStruct[2].doJoin=true
            tableStruct[2].joinedToTable=2
            tableStruct[2].numOfConds=2
            tableStruct[2].joinConds=joinCondStructBoe
            joinCondStructBoe[0].compareCols=true
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
            condStruct[numOfConds].colNum=ORCT_CANCELED
            condStruct[numOfConds].operation=DBD_EQ
            condStruct[numOfConds].tableIndex=1
            _STR_strcpy(condStruct[numOfConds].condVal,VAL_YES)
            condStruct[((numOfConds)+=1;(numOfConds)-2)].relationship=DBD_AND
            condStruct[numOfConds].colNum=OBOE_STATUS
            condStruct[numOfConds].operation=DBD_EQ
            condStruct[numOfConds].tableIndex=2
            _STR_strcpy(condStruct[numOfConds].condVal,VAL_BOE_FAILED)
            condStruct[((numOfConds)+=1;(numOfConds)-2)].relationship=DBD_AND
            condStruct[numOfConds].colNum=JDT1_SRC_LINE
            condStruct[numOfConds].operation=DBD_EQ
            condStruct[numOfConds].tableIndex=0
            condStruct[numOfConds].condVal=PMN_VAL_BOE
            condStruct[((numOfConds)+=1;(numOfConds)-2)].relationship=DBD_AND
            condStruct[numOfConds].colNum=JDT1_DEBIT
            condStruct[numOfConds].operation=DBD_LE
            condStruct[numOfConds].tableIndex=0
            condStruct[numOfConds].condVal=0
            condStruct[((numOfConds)+=1;(numOfConds)-2)].relationship=DBD_AND
         else
            condStruct[numOfConds].colNum=ODPS_DEPOS_TYPE
            condStruct[numOfConds].operation=DBD_EQ
            condStruct[numOfConds].tableIndex=1
            _STR_strcpy(condStruct[numOfConds].condVal,VAL_BOE)
            condStruct[((numOfConds)+=1;(numOfConds)-2)].relationship=DBD_AND
         end

      end

   end

   def GetNumOfBPRecords(numOfBPfound,validateFedTaxId)
      trace("GetNumOfBPRecords")
      dagJDT1 = PDAG.new=GetDAG(JDT,ao_Arr1)
      recCount=dagJDT1.GetRecordCount()
      actCode = SBOString.new
      shortName = SBOString.new
      fedTaxId = SBOString.new
      taxGroup = SBOString.new
      indexOfMissingTaxId=-1
      foundECTax=false
      bizEnv = CBizEnv.new=GetEnv()
      numOfBPfound=0
      ii=0
      while (ii<recCount) do
         dagJDT1.GetColStr(actCode,JDT1_ACCT_NUM,ii)
         dagJDT1.GetColStr(shortName,JDT1_SHORT_NAME,ii)
         if actCode.Compare(shortName)!=0
            (numOfBPfound+=1;numOfBPfound-2)
            if validateFedTaxId&&indexOfMissingTaxId<0
               dagJDT1.GetColStr(fedTaxId,JDT1_TAX_ID_NUMBER,ii)
               if fedTaxId.IsSpacesStr()
                  indexOfMissingTaxId=ii
               end

            end

         end

         if validateFedTaxId&&!foundECTax
            dagJDT1.GetColStr(taxGroup,JDT1_VAT_GROUP,ii)
            taxGroup.Trim()
            if !taxGroup.IsSpacesStr()&&bizEnv.GetTaxGroupCache().IsEC(bizEnv,taxGroup)
               foundECTax=true
            end

         end


         (ii+=1;ii-2)
      end

      if validateFedTaxId&&foundECTax&&indexOfMissingTaxId>=0
         if CMessagesManager.GetHandle().DisplayMessage(_48_APP_MSG_FIN_JDT_MISSING_FEDERAL_TAX_ID)!=DIALOG_YES_BTN
            return -10
         end

      end

      return 0
   end

   def GetBaseEntry(dagRes,docNum)
      trace("GetBaseEntry")



      start=0
      DAG_GetCount(dagRes,numOfRecs)
      if !numOfRecs
         return -1
      end

      _translated_end=numOfRecs-1
      begin
         mid=(start+_translated_end+1)/2
         dagRes.GetColLong(dagDocNum,0,mid)
         if docNum==dagDocNum
            dagRes.GetColLong(result,1,mid)
            return result
         else
            if docNum>dagDocNum
               start=mid+1
            else
               _translated_end=mid-1
            end

         end

      end while (start<=_translated_end)

      return -1
   end

   def UpgradeCreateDateSubQuery(subParams,subResStruct,subTableStruct,subCond,objectID)
      trace("UpgradeCreateDateSubQuery")
      bizEnv = CBizEnv.new=GetEnv()
      isPDN=(objectID==PDN)
      _STR_strcpy(subTableStruct[0].tableCode,bizEnv.ObjectToTable(isPDN ? PDN : RPD))
      subResStruct[0].colNum=isPDN ? OPDN_ABS_ENTRY : ORPD_ABS_ENTRY
      subResStruct[0].tableIndex=0
      subCond[0].compareCols=true
      subCond[0].tableIndex=0
      subCond[0].colNum=OJDT_JDT_NUM
      subCond[0].compColNum=isPDN ? OPDN_TRANS_NUM : ORPD_TRANS_NUM
      subCond[0].operation=DBD_EQ
      subCond[0].origTableIndex=0
      subCond[0].origTableLevel=1
      subCond[0].relationship=0
      DBD_SetParamTablesList(subParams,subTableStruct,1)
      DBD_SetCond(subParams,subCond,1)
      DBD_SetRes(subParams,subResStruct,1)
   end

   def IsBlockDunningLetterUpdateable()
      transType = SBOString.new=GetID()
      return (transType==JDT||transType==NOB||transType==OPEN_BLNC_TYPE||transType==CLOSE_BLNC_TYPE)
   end

   def UpgradeJDTIndianAutoVatInt(dagJDT1)
      isVatLine=false
      currentTransID=-1
      currentTaxType=0
      totalLines=dagJDT1.GetRecordCount()

      tmpStr = SBOString.new
      i=0
      while (i<totalLines) do
         dagJDT1.GetColStr(tmpStr,JDT1_DEBIT_CREDIT,i)
         if tmpStr.Compare(VAL_DEBIT)
            dagJDT1.SetColStr(_T("P"),JDT1_TAX_POSTING_ACCOUNT,i)
         else
            dagJDT1.SetColStr(_T("R"),JDT1_TAX_POSTING_ACCOUNT,i)
         end

         dagJDT1.GetColStr(tmpStr,JDT1_VAT_GROUP,i)
         dagJDT1.NullifyCol(JDT1_VAT_GROUP,i)
         dagJDT1.SetColStr(tmpStr,JDT1_TAX_CODE,i)
         dagJDT1.SetColStr(VAL_YES,JDT1_IS_NET,i)
         dagJDT1.GetColLong(tmpL,JDT1_TRANS_ABS,i)
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
               (currentTaxType+=1)
            end

         end

         dagJDT1.SetColLong(currentTaxType,JDT1_TAX_TYPE,i)

         (i+=1)
      end

      return dagJDT1.UpdateAll()
   end

   def CheckColChanged(dag,col,rec)
      if !_DBM_DataAccessGate.IsValid(dag)
         return false
      end

      colList = DBM_CL.new

      ooErr=dag.GetChangesList(rec,colList)
      IF_ERROR_RETURN_VALUE(ooErr,false)


      colCount=colList.GetSize()
      colIndex=0
      while (colIndex<colCount) do
         currCol=colList[colIndex].GetColNum()
         if currCol==col
            return true
         end


         (colIndex+=1)
      end

      return false
   end

   def UpdateWTOnRecon(yourMatchData)
      ooErr=ooNoErr
      env = CBizEnv.new=GetEnv()
      withholdingCodeSet = WithHoldingTaxSet.new=GetWithHoldingTax(true)
      if withholdingCodeSet.size()==0
         return ooNoErr
      end

      dagJDT2 = PDAG.new=GetArrayDAG(ao_Arr2)
      numOfRecsJDT2=dagJDT2.GetRealSize(dbmDataBuffer)
      if (numOfRecsJDT2>1&&!VF_AllowMixedWHTCategories(env))||(withholdingCodeSet.size()>1)
         _MEM_MYRPT0(_T("CDocumentObject::UpdateWTOnRecon - \
         JDT2 should contain 1 rec at the most for reconciliation!"))
         BOOM
         return ooInvalidAction
      end

      tmpApplied = MONEY.new
      paidWT = MONEY.new
      paidFrgnWT = MONEY.new
      paidSysWT = MONEY.new
      status = SBOString.new
      dagJDT1 = PDAG.new=GetArrayDAG(ao_Arr1)
      offset=yourMatchData.transRowId
      dagJDT = PDAG.new=GetDAG()
      status=@getJDTReconStatus()
      paymCtgWhtRec=0
      if VF_AllowMixedWHTCategories(env)
         whtCategory = SBOString.new
         paymCtgWhtRec=0
         while (paymCtgWhtRec<numOfRecsJDT2) do
            dagJDT2.GetColStr(whtCategory,JDT2_CATEGORY,paymCtgWhtRec)
            whtCategory.Trim()
            if whtCategory==VAL_CATEGORY_PAYMENT
               break
            end


            (paymCtgWhtRec+=1;paymCtgWhtRec-2)
         end

      end

      if status==VAL_CLOSE
         dagJDT2.GetColMoney(paidWT,INV5_WT_AMOUNT,paymCtgWhtRec)
         dagJDT2.GetColMoney(tmpApplied,INV5_WT_APPLIED_AMOUNT,paymCtgWhtRec)
         dagJDT2.SetColMoney(paidWT,INV5_WT_APPLIED_AMOUNT,paymCtgWhtRec)
         paidWT-=tmpApplied
         dagJDT2.GetColMoney(paidFrgnWT,INV5_WT_AMOUNT_FC,paymCtgWhtRec)
         dagJDT2.GetColMoney(tmpApplied,INV5_WT_APPLIED_AMOUNT_FC,paymCtgWhtRec)
         dagJDT2.SetColMoney(paidFrgnWT,INV5_WT_APPLIED_AMOUNT_FC,paymCtgWhtRec)
         paidFrgnWT-=tmpApplied
         dagJDT2.GetColMoney(paidSysWT,INV5_WT_AMOUNT_SC,paymCtgWhtRec)
         dagJDT2.GetColMoney(tmpApplied,INV5_WT_APPLIED_AMOUNT_SC,paymCtgWhtRec)
         dagJDT2.SetColMoney(paidSysWT,INV5_WT_APPLIED_AMOUNT_SC,paymCtgWhtRec)
         paidSysWT-=tmpApplied
         dagJDT1.CopyColumn(dagJDT1,JDT1_WT_APPLIED,offset,JDT1_WT_SUM,offset)
         dagJDT1.CopyColumn(dagJDT1,JDT1_WT_APPLIED_FC,offset,JDT1_WT_SUM_FC,offset)
         dagJDT1.CopyColumn(dagJDT1,JDT1_WT_APPLIED_SC,offset,JDT1_WT_APPLIED_SC,offset)
         dagJDT.CopyColumn(dagJDT,OJDT_WT_APPLIED,0,OJDT_WT_SUM,0)
         dagJDT.CopyColumn(dagJDT,OJDT_WT_SUM_SC,0,OJDT_WT_SUM_SC,0)
         dagJDT.CopyColumn(dagJDT,OJDT_WT_SUM_FC,0,OJDT_WT_SUM_FC,0)
      else
         mainCurrency = Currency.new
         sysCurrency = Currency.new
         docCurrency = Currency.new
         _STR_strcpy(mainCurrency,env.GetMainCurrency())
         _STR_strcpy(sysCurrency,env.GetSystemCurrency())
         dagJDT.GetColStr(docCurrency,OJDT_TRANS_CURR)
         if _STR_IsSpacesStr(docCurrency)
            _STR_strcpy(docCurrency,mainCurrency)
         end

         dagJDT2.GetColMoney(tmpApplied,INV5_WT_APPLIED_AMOUNT,paymCtgWhtRec)
         paidWT=yourMatchData.WTSum
         tmpApplied+=paidWT
         dagJDT2.SetColMoney(tmpApplied,INV5_WT_APPLIED_AMOUNT,paymCtgWhtRec)
         dagJDT2.GetColMoney(tmpApplied,INV5_WT_APPLIED_AMOUNT_FC,paymCtgWhtRec)
         paidFrgnWT=yourMatchData.WTSumFC
         tmpApplied+=paidFrgnWT
         dagJDT2.SetColMoney(tmpApplied,INV5_WT_APPLIED_AMOUNT_FC,paymCtgWhtRec)
         dagJDT2.GetColMoney(tmpApplied,INV5_WT_APPLIED_AMOUNT_SC,paymCtgWhtRec)
         paidSysWT=yourMatchData.WTSumSC
         tmpApplied+=paidSysWT
         dagJDT2.SetColMoney(tmpApplied,INV5_WT_APPLIED_AMOUNT_SC,paymCtgWhtRec)
         dagJDT1.GetColMoney(tmpApplied,JDT1_WT_APPLIED,offset)
         tmpApplied+=paidWT
         dagJDT1.SetColMoney(tmpApplied,JDT1_WT_APPLIED,offset)
         dagJDT1.GetColMoney(tmpApplied,JDT1_WT_APPLIED_FC,offset)
         tmpApplied+=paidFrgnWT
         dagJDT1.SetColMoney(tmpApplied,JDT1_WT_APPLIED_FC,offset)
         dagJDT1.GetColMoney(tmpApplied,JDT1_WT_APPLIED_SC,offset)
         tmpApplied+=paidSysWT
         dagJDT1.SetColMoney(tmpApplied,JDT1_WT_APPLIED_SC,offset)
         dagJDT.GetColMoney(tmpApplied,OJDT_WT_APPLIED,offset)
         tmpApplied+=paidWT
         dagJDT.SetColMoney(tmpApplied,OJDT_WT_APPLIED,offset)
         dagJDT.GetColMoney(tmpApplied,OJDT_WT_APPLIED_FC,offset)
         tmpApplied+=paidFrgnWT
         dagJDT.SetColMoney(tmpApplied,OJDT_WT_APPLIED_FC,offset)
         dagJDT.GetColMoney(tmpApplied,OJDT_WT_APPLIED_SC,offset)
         tmpApplied+=paidSysWT
         dagJDT.SetColMoney(tmpApplied,OJDT_WT_APPLIED_SC,offset)
      end

      ooErr=dagJDT1.Update()
      if ooErr
         return ooErr
      end

      ooErr=dagJDT1.Update(offset)
      if ooErr
         return ooErr
      end

      ooErr=dagJDT2.Update(paymCtgWhtRec)
      if ooErr
         return ooErr
      end

      return ooNoErr
   end

   def UpdateWTOnCancelRecon(yourMatchData)
      trace("UpdateWTOnCancelRecon")

      withholdingCodeSet = WithHoldingTaxSet.new=GetWithHoldingTax(true)
      if withholdingCodeSet.size()==0
         return ooNoErr
      end

      dagJDT2 = PDAG.new=GetArrayDAG(ao_Arr2)
      numOfRecsJDT2=dagJDT2.GetRealSize(dbmDataBuffer)
      if (numOfRecsJDT2>1&&!VF_AllowMixedWHTCategories(GetEnv()))||(withholdingCodeSet.size()>1)
         _MEM_MYRPT0(_T("CDocumentObject::UpdateWTOnCancelRecon \
         - DOC5 should contain 1 rec at the most for reconciliation!"))
         BOOM
         return ooInvalidAction
      end

      paymCtgWhtRec=0
      if VF_AllowMixedWHTCategories(GetEnv())
         whtCategory = SBOString.new
         paymCtgWhtRec=0
         while (paymCtgWhtRec<numOfRecsJDT2) do
            dagJDT2.GetColStr(whtCategory,JDT2_CATEGORY,paymCtgWhtRec)
            whtCategory.Trim()
            if whtCategory==VAL_CATEGORY_PAYMENT
               break
            end


            (paymCtgWhtRec+=1;paymCtgWhtRec-2)
         end

      end

      tmpApplied = MONEY.new
      wtApplied = CAllCurrencySums.new(yourMatchData.WTSum,yourMatchData.WTSumFC,yourMatchData.WTSumSC)
      dagJDT2.GetColMoney(tmpApplied,INV5_WT_APPLIED_AMOUNT,paymCtgWhtRec)
      tmpApplied+=wtApplied.m_SumLc
      dagJDT2.SetColMoney(tmpApplied,INV5_WT_APPLIED_AMOUNT,paymCtgWhtRec)
      dagJDT2.GetColMoney(tmpApplied,INV5_WT_APPLIED_AMOUNT_FC,paymCtgWhtRec)
      tmpApplied+=wtApplied.m_SumFc
      dagJDT2.SetColMoney(tmpApplied,INV5_WT_APPLIED_AMOUNT_FC,paymCtgWhtRec)
      dagJDT2.GetColMoney(tmpApplied,INV5_WT_APPLIED_AMOUNT_SC,paymCtgWhtRec)
      tmpApplied+=wtApplied.m_SumSc
      dagJDT2.SetColMoney(tmpApplied,INV5_WT_APPLIED_AMOUNT_SC,paymCtgWhtRec)
      dagJDT1 = PDAG.new=GetArrayDAG(ao_Arr1)
      offset=yourMatchData.transRowId
      dagJDT1.GetColMoney(tmpApplied,JDT1_WT_APPLIED,offset)
      tmpApplied+=wtApplied.m_SumLc
      dagJDT1.SetColMoney(tmpApplied,JDT1_WT_APPLIED,offset)
      dagJDT1.GetColMoney(tmpApplied,JDT1_WT_APPLIED_FC,offset)
      tmpApplied+=wtApplied.m_SumFc
      dagJDT1.SetColMoney(tmpApplied,JDT1_WT_APPLIED_FC,offset)
      dagJDT1.GetColMoney(tmpApplied,JDT1_WT_APPLIED_SC,offset)
      tmpApplied+=wtApplied.m_SumSc
      dagJDT1.SetColMoney(tmpApplied,JDT1_WT_APPLIED_SC,offset)
      dagJDT = PDAG.new=GetDAG()
      dagJDT.GetColMoney(tmpApplied,OJDT_WT_APPLIED,offset)
      tmpApplied+=wtApplied.m_SumLc
      dagJDT.SetColMoney(tmpApplied,OJDT_WT_APPLIED,offset)
      dagJDT.GetColMoney(tmpApplied,OJDT_WT_APPLIED_FC,offset)
      tmpApplied+=wtApplied.m_SumFc
      dagJDT.SetColMoney(tmpApplied,OJDT_WT_APPLIED_FC,offset)
      dagJDT.GetColMoney(tmpApplied,OJDT_WT_APPLIED_SC,offset)
      tmpApplied+=wtApplied.m_SumSc
      dagJDT.SetColMoney(tmpApplied,OJDT_WT_APPLIED_SC,offset)
      ooErr=dagJDT.Update()
      if ooErr
         return ooErr
      end

      ooErr=dagJDT1.Update(offset)
      if ooErr
         return ooErr
      end

      ooErr=dagJDT2.Update(paymCtgWhtRec)
      if ooErr
         return ooErr
      end

      return ooNoErr
   end

   def CalcPaidRatioOfOpenDoc(paidSum,paidSumInLocal,transRowId,calcFromTotal)
      dagJDT = PDAG.new=GetDAG()
      dagJDT1 = PDAG.new=GetArrayDAG(ao_Arr1)
      total = CAllCurrencySums.new
      tmpMny = CAllCurrencySums.new
      mainCurrency = SBOString.new
      docCurrency = SBOString.new
      local=true
      dagJDT.GetColStr(docCurrency,OINV_DOC_CURRENCY)
      mainCurrency=GetEnv().GetMainCurrency()
      tmpDocCur = CCurrency.new(docCurrency)
      tmpMainCur = CCurrency.new(mainCurrency)
      calcFromLocal=IWithHoldingAble.IsInLocalCurrency(paidSumInLocal,tmpDocCur,tmpMainCur)
      if calcFromTotal
         total.FromDAG(dagJDT1,transRowId,JDT1_DEBIT,JDT1_FC_DEBIT,JDT1_SYS_DEBIT)
         tmpMny.FromDAG(dagJDT1,transRowId,JDT1_CREDIT,JDT1_FC_CREDIT,JDT1_SYS_CREDIT)
         total-=tmpMny
         total.Abs()
      else
         total.FromDAG(dagJDT1,transRowId,JDT1_BALANCE_DUE_DEBIT,JDT1_BALANCE_DUE_FC_DEB,JDT1_BALANCE_DUE_SC_DEB)
         tmpMny.FromDAG(dagJDT1,transRowId,JDT1_BALANCE_DUE_CREDIT,JDT1_BALANCE_DUE_FC_CRED,JDT1_BALANCE_DUE_SC_CRED)
         total-=tmpMny
         total.Abs()
      end

      return IWithHoldingAble.CalcPaidRatioOfOpenDocInt(paidSum,paidSumInLocal,total,calcFromLocal)

   end

   def GetDfltWTCodes(wtInfo)
      return CDocumentObject.ODOCLoadWTPrefsFromCard(self,wtInfo.cardWTLiable,wtInfo.wtDefaultCode,wtInfo.VATwtDefaultCode,wtInfo.ITwtDefaultCode,wtInfo.wtBaseType,wtInfo.wtCategory)
   end

   def PrePareDataForWT(wtAllCurBaseCalcParamsPtr,currSource,dagDOC,wtInfo)
      ooErr=ooNoErr
      dagJDT = PDAG.new=GetDAG(JDT)
      baseCalcParam = CWTBaseCalcParams.new=wtAllCurBaseCalcParamsPtr.GetWtBaseCalcParams(currSource)
      @getCRDDag()
      GetDfltWTCodes(wtInfo)
      if !dagDOC.GetRecordCount()
         dagDOC.SetSize(1,dbmDropData)
      end

      dagDOC.SetColStr(@getBPLineCurrency(),OINV_DOC_CURRENCY)
      dagDOC.CopyColumn(dagJDT,OINV_DATE,0,OJDT_REF_DATE,0)
      if m_env.IsLocalSettingsFlag(lsf_EnableLA1WHT)
         dagDOC.SetColMoney(baseCalcParam.m_wtBaseNetAmount,nsDocument.ODOCGetWTBaseNetAmountField(currSource))
         dagDOC.SetColMoney(baseCalcParam.m_wtBaseVATAmount,nsDocument.ODOCGetWTBaseVatAmountField(currSource))
      else
         wtBaseAmount = MONEY.new=baseCalcParam.GetWTBaseAmount(wtInfo.wtBaseType)
         dagDOC.SetColMoney(wtBaseAmount,nsDocument.ODOCGetWTBaseAmountField(currSource))
      end

      SetCurrRateForDOC(dagDOC)
      @setCurrForAutoCompleteDOC5()
      cplPara = CWTCompleteDOC5Params.new
      ooErr=@m_WithholdingTaxMng.ODOCAutoCompleteDOC5(self,cplPara)
      if ooErr
         Message(cplPara.errNode.strId,cplPara.errNode.index,nil,OO_ERROR)
         return ooErr
      end

      return ooErr
   end

   def JDTCalcWTTable(wtInfo,currSource,dagDOC,wtAllCurBaseCalcParamsPtr)
      ooErr=ooNoErr
      wtCurBaseCalcParamsPtr = CWTBaseCalcParams.new=wtAllCurBaseCalcParamsPtr.GetWtBaseCalcParams(currSource)
      wtInParamTableChangeListPtr = CWTTableChangeList.new=nil
      wtTotalAmountM = MONEY.new
      wtTableDefaultCodes = CWTTableDefaultCodes.new
      if m_env.IsLocalSettingsFlag(lsf_EnableLA1WHT)
         wtTableDefaultCodes.SetVATWtDefaultcode(wtInfo.VATwtDefaultCode)
         wtTableDefaultCodes.SetITWtDefaultcode(wtInfo.ITwtDefaultCode)
      else
         wtTableDefaultCodes.SetWtDefaultcode(wtInfo.wtDefaultCode)
      end

      @m_WithholdingTaxMng.ODOCCalcWTTable(self,wtCurBaseCalcParamsPtr,wtInParamTableChangeListPtr,wtTableDefaultCodes,currSource,wtTotalAmountM,-1,dagDOC)
      return ooErr
   end

   def GetJDT1MoneyCol(currSource,isDebit)
      cols = []
      =""
      return cols[currSource-1][isDebit ? 0 : 1]
   end

   def GetVATMoneyCol(currSource)
      cols = []
      =""
      return cols[currSource-1]
   end

   def GetWTBaseAmount(currSource,baseParam)
      trace("GetWTBaseAmount")
      ooErr=ooNoErr
      dagJDT = PDAG.new=GetDAG(JDT)
      dagJDT1 = PDAG.new=GetDAG(JDT,ao_Arr1)
      recCount=dagJDT1.GetRealSize(dbmDataBuffer)
      bizEnv = CBizEnv.new=GetEnv()
      wtLiable = SBOString.new
      amount = SBOString.new
      sum = MONEY.new
      mnyTmp = MONEY.new
      sumVAT = MONEY.new

      rec=0
      while (rec<recCount) do
         dagJDT1.GetColStr(wtLiable,JDT1_WT_LIABLE,rec)
         if wtLiable.Trim()==VAL_YES
            isDebit=false
            dagJDT1.GetColMoney(mnyTmp,GetJDT1MoneyCol(currSource,true),rec)
            if !mnyTmp.IsZero()
               isDebit=true
            end

            sum+=mnyTmp
            dagJDT1.GetColMoney(mnyTmp,GetJDT1MoneyCol(currSource,false),rec)
            sum-=mnyTmp
            if mnyTmp.IsZero()&&(!isDebit)
               next

            end

            dagJDT1.GetColMoney(mnyTmp,GetVATMoneyCol(currSource),rec)
            dubtCurr = SBOString.new
            if currSource==INV_CARD_CURRENCY
               realCurr = SBOString.new=@wTGetCurrency()
               realCurr.Trim()
               dubtCurr.Trim()
               mainCurr = SBOString.new=bizEnv.GetMainCurrency().Trim()
               frgnCurr = SBOString.new=realCurr
               SBO_ASSERT(dubtCurr.IsEmpty()||dubtCurr==mainCurr)
               SBO_ASSERT(dubtCurr!=frgnCurr)
               frgnAmnt = MONEY.new=1
               dateStr = SBOString.new
               dagJDT.GetColStr(dateStr,OJDT_REF_DATE)
               dateStr.Trim()
               GNLocalToForeignRate(mnyTmp,frgnCurr.GetBuffer(),dateStr.GetBuffer(),0.0,frgnAmnt,bizEnv)
               mnyTmp=frgnAmnt
               mnyTmp.Round(RC_SUM,frgnCurr,bizEnv)
            end

            if isDebit
               sumVAT+=mnyTmp
            else
               sumVAT-=mnyTmp
            end

         end


         (rec+=1;rec-2)
      end

      if !baseParam.GetIsBaseAmountsReady()
         baseParam.Init()
      end

      mnySumTmp = MONEY.new=sum+sumVAT
      baseParam.m_wtBaseNetAmount=sum.AbsVal()
      baseParam.m_wtBaseVATAmount=sumVAT.AbsVal()
      baseParam.m_wtBaseAmount=mnySumTmp.AbsVal()
      return ooErr
   end

   def GetWTCredDebt(debCre)
      trace("GETWTCredDebt")
      ooErr=ooNoErr
      dagJDT1 = PDAG.new=GetDAG(JDT,ao_Arr1)
      dagJDT2 = PDAG.new=GetDAG(JDT,ao_Arr2)
      recCount=dagJDT1.GetRealSize(dbmDataBuffer)
      wtLiable = SBOString.new
      debitSumNet = MONEY.new
      creditSumNet = MONEY.new
      debitSumVat = MONEY.new
      creditSumVat = MONEY.new
      tmpDebAmt = MONEY.new
      tmpCreAmt = MONEY.new
      tmpVatAmt = MONEY.new
      debitSum = MONEY.new
      creditSum = MONEY.new
      if !DAG.IsValid(dagJDT1)
         return ooErrNoMsg
      end

      rec=0
      while (rec<recCount) do
         dagJDT1.GetColStr(wtLiable,JDT1_WT_LIABLE,rec)
         if wtLiable.Trim()==VAL_YES
            dagJDT1.GetColMoney(tmpDebAmt,JDT1_DEBIT,rec)
            debitSumNet+=tmpDebAmt
            dagJDT1.GetColMoney(tmpCreAmt,JDT1_CREDIT,rec)
            creditSumNet+=tmpCreAmt
            dagJDT1.GetColMoney(tmpVatAmt,JDT1_TOTAL_TAX,rec)
            if !tmpDebAmt.IsZero()
               debitSumVat+=tmpVatAmt
            else
               if !tmpCreAmt.IsZero()
                  creditSumVat+=tmpVatAmt
               end

            end

         end


         (rec+=1;rec-2)
      end

      if dagJDT2.GetRecordCount()>0
         wtBaseType = SBOString.new
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
                  debitSum=debitSumNet+debitSumVat
                  creditSum=creditSumNet+creditSumVat
               end

            end

         end

      end

      if debitSum>=creditSum
         debCre=VAL_CREDIT
      else
         debCre=VAL_DEBIT
      end

      return 0
   end

   def UpdateWTAmounts(wtAllCurBaseCalcParamsPtr)
      ooErr=ooNoErr
      dagJDT2 = PDAG.new=GetDAG(JDT,ao_Arr2)
      dagJDT = PDAG.new=GetDAG(JDT)
      recCount=dagJDT2.GetRecordCount()
      mnyTmp = MONEY.new
      wtSums = []

      currency = []
      =""
      rec=0
      while (rec<recCount) do
         i=0
         while (currency[i]) do
            dagJDT2.GetColMoney(mnyTmp,@m_WithholdingTaxMng.ODOC5GetWTTaxAmountField(currency[i]),rec)
            wtSums[i]+=mnyTmp

            (i+=1;i-2)
         end


         (rec+=1;rec-2)
      end

      strRecBaseType = SBOString.new
      dagJDT2.GetColStr(strRecBaseType,INV5_BASE_TYPE,0)
      i=0
      while (currency[i]) do
         wtCurBaseCalcParamsPtr = CWTBaseCalcParams.new=wtAllCurBaseCalcParamsPtr.GetWtBaseCalcParams(currency[i])
         if m_env.IsLocalSettingsFlag(lsf_EnableLA1WHT)
            dagJDT.SetColMoney(wtCurBaseCalcParamsPtr.m_wtBaseNetAmount,CTransactionJournalObject.GetWTBaseNetAmountField(currency[i]))
            dagJDT.SetColMoney(wtCurBaseCalcParamsPtr.m_wtBaseVATAmount,CTransactionJournalObject.GetWTBaseVATAmountField(currency[i]))
         else
            if VAL_BASETYPE_NET==strRecBaseType
               dagJDT.SetColMoney(wtCurBaseCalcParamsPtr.m_wtBaseNetAmount,CTransactionJournalObject.GetWTBaseNetAmountField(currency[i]))
            else
               dagJDT.SetColMoney(wtCurBaseCalcParamsPtr.m_wtBaseAmount,CTransactionJournalObject.GetWTBaseNetAmountField(currency[i]))
            end

         end

         dagJDT.SetColMoney(wtSums[i],CTransactionJournalObject.GetWtSumField(currency[i]))

         (i+=1;i-2)
      end

      return ooErr
   end

   def WTGetCurrSource()
      trace("WTGetCurrSource")
      bizEnv = CBizEnv.new=GetEnv()
      currency = SBOString.new
      mainCurr = SBOString.new=bizEnv.GetMainCurrency()
      sysCurr = SBOString.new=bizEnv.GetSystemCurrency()
      currency=@getBPLineCurrency()
      currency.Trim()
      if (EMPTY_STR==currency)||(currency==mainCurr)||(GNCoinCmp(currency,BAD_CURRENCY_STR)==0)
         return INV_LOCAL_CURRENCY
      end

      if currency==sysCurr
         return INV_SYSTEM_CURRENCY
      end

      return INV_CARD_CURRENCY
   end

   def WtAutoAddJDT1Line(dagJDT1,jdt1RecSize,dagJDT2,jdt2CurRec,isDebit,wtSide)
      trace("WtAutoAddJDT1Line")
      ooErr=0
      tmpStr = SBOString.new
      mnyAmt = MONEY.new
      toJDT1fields = []
      =""
      fromJDTfields = []
      =""
      dagJDT1.SetSize(jdt1RecSize+1,dbmKeepData)
      dagJDT2.GetColMoney(mnyAmt,INV5_WT_AMOUNT,jdt2CurRec)
      dagJDT1.SetColMoney(mnyAmt,GetJDT1MoneyCol(INV_LOCAL_CURRENCY,isDebit),jdt1RecSize)
      dagJDT2.GetColMoney(mnyAmt,INV5_WT_AMOUNT_SC,jdt2CurRec)
      dagJDT1.SetColMoney(mnyAmt,GetJDT1MoneyCol(INV_SYSTEM_CURRENCY,isDebit),jdt1RecSize)
      if WTGetCurrSource()==INV_CARD_CURRENCY
         dagJDT2.GetColMoney(mnyAmt,INV5_WT_AMOUNT_FC,jdt2CurRec)
         dagJDT1.SetColMoney(mnyAmt,GetJDT1MoneyCol(INV_CARD_CURRENCY,isDebit),jdt1RecSize)
      end

      dagJDT1.SetColStr(VAL_YES,JDT1_WT_Line,jdt1RecSize)
      dagJDT1.SetColStr(wtSide,JDT1_DEBIT_CREDIT,jdt1RecSize)
      dagJDT1.CopyColumn(dagJDT2,JDT1_ACCT_NUM,jdt1RecSize,INV5_ACCOUNT,jdt2CurRec)
      dagJDT1.CopyColumn(dagJDT2,JDT1_SHORT_NAME,jdt1RecSize,INV5_ACCOUNT,jdt2CurRec)
      dagJDT1.SetColLong(JDT,JDT1_TRANS_TYPE,jdt1RecSize)
      ii=0
      while (toJDT1fields[ii]>=0) do
         dagJDT1.GetColStr(tmpStr,toJDT1fields[ii],jdt1RecSize)
         tmpStr.Trim()
         if tmpStr==EMPTY_STR
            dagJDT1.GetColStr(tmpStr,toJDT1fields[ii],jdt1RecSize,fromJDTfields[ii],0)
         end


         (ii+=1;ii-2)
      end

      if WTGetCurrSource()==INV_CARD_CURRENCY
         dagJDT1.SetColStr(@getBPLineCurrency(),JDT1_FC_CURRENCY,jdt1RecSize)
      end

      return ooErr
   end

   def WtUpdJDT1LineAmt(dagJDT1,jdt1CurRow,dagJDT2,jdt2CurRow,isDebit,wtAcctCode,wtSide)
      ooErr=ooNoErr
      mnyAmt = MONEY.new
      oldWT = MONEY.new
      oldWTSC = MONEY.new
      oldWTFC = MONEY.new
      dagJDT1.GetColMoney(oldWT,GetJDT1MoneyCol(INV_LOCAL_CURRENCY,isDebit),jdt1CurRow)
      dagJDT1.GetColMoney(oldWTSC,GetJDT1MoneyCol(INV_SYSTEM_CURRENCY,isDebit),jdt1CurRow)
      dagJDT1.GetColMoney(oldWTFC,GetJDT1MoneyCol(INV_CARD_CURRENCY,isDebit),jdt1CurRow)
      dagJDT2.GetColMoney(mnyAmt,INV5_WT_AMOUNT,jdt2CurRow)
      mnyAmt+=oldWT
      dagJDT1.SetColMoney(mnyAmt,GetJDT1MoneyCol(INV_LOCAL_CURRENCY,isDebit),jdt1CurRow)
      dagJDT2.GetColMoney(mnyAmt,INV5_WT_AMOUNT_SC,jdt2CurRow)
      mnyAmt+=oldWTSC
      dagJDT1.SetColMoney(mnyAmt,GetJDT1MoneyCol(INV_SYSTEM_CURRENCY,isDebit),jdt1CurRow)
      dagJDT2.GetColMoney(mnyAmt,INV5_WT_AMOUNT_FC,jdt2CurRow)
      mnyAmt+=oldWTFC
      dagJDT1.SetColMoney(mnyAmt,GetJDT1MoneyCol(INV_CARD_CURRENCY,isDebit),jdt1CurRow)
      return ooErr
   end

   def CalcBpCurrRateForDocRate(rate)
      ooErr=ooNoErr
      dagJDT1 = PDAG.new=GetDAG(JDT,ao_Arr1)
      env = CBizEnv.new=GetEnv()
      mLocal = MONEY.new
      mFrgn = MONEY.new
      recJDT1=dagJDT1.GetRealSize(dbmDataBuffer)
      acct = SBOString.new
      shortname = SBOString.new
      curr = SBOString.new
      flag=false
      rec=0
      while (rec<recJDT1) do
         dagJDT1.GetColStr(acct,JDT1_ACCT_NUM,rec)
         dagJDT1.GetColStr(shortname,JDT1_SHORT_NAME,rec)
         acct.Trim()
         shortname.Trim()
         if acct!=shortname
            dagJDT1.GetColMoney(mLocal,JDT1_CREDIT,rec)
            dagJDT1.GetColMoney(mFrgn,JDT1_FC_CREDIT,rec)
            if mLocal.IsPositive()&&mFrgn.IsPositive()
               flag=true
            else
               dagJDT1.GetColMoney(mLocal,JDT1_DEBIT,rec)
               dagJDT1.GetColMoney(mFrgn,JDT1_FC_DEBIT,rec)
               if mLocal.IsPositive()&&mFrgn.IsPositive()
                  flag=true
               end

            end

            break
         end


         (rec+=1;rec-2)
      end

      if flag
         if env.IsDirectRate()
            rate=mLocal.MulAndDiv(1,mFrgn,env,false)
         else
            rate=mFrgn.MulAndDiv(1,mLocal,env,false)
         end

      else
         rate.FromDouble(MONEY_PERCISION_MUL)
         ooErr=-10
      end

      return ooErr
   end

   def UpgradeERDBaseTransUpdateOne(transId,erdBaseTrans)
      ooErr=ooNoErr
      bizEnv = CBizEnv.new=GetEnv()
      dagJDT = PDAG.new=bizEnv.OpenDAG(JDT,ao_Main)
      updStruct = []

      conditions = DBD_Conditions.new
      condPtr = PDBD_Cond.new
      conditions=(dagJDT.GetDBDParams().GetConditions())
      conditions.Clear()
      condPtr=conditions.AddCondition()
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

   def UpgradeERDBaseTransFindBaseTrans(objectMap,inAccount,inShortName,inRef3Line,outBaseTransCandidate)
      ooErr=ooNoErr
      bizEnv = CBizEnv.new=GetEnv()

      tablePtr = DBD_TablesList.new
      joinCondsOFPR = []

      queryParams = DBD_Params.new
      numOfCandidates=0


      periodCode = SBOString.new
      docTypeCode = SBOString.new
      docNum = SBOString.new
      sep1Pos=inRef3Line.Find(_T('/'))
      periodCode=inRef3Line.Left(sep1Pos)
      sep2Pos=inRef3Line.Find(_T('/'),sep1Pos+1)
      docTypeCode=inRef3Line.Mid(sep1Pos+1,sep2Pos-sep1Pos-1)
      docNum=inRef3Line.Mid(sep2Pos+1)
      omIt = ObjectAbbrevsMap::const_iterator.new
      omIt=objectMap.begin()
      while (omIt!=objectMap.end()) do
         if omIt.second.find(docTypeCode)!=omIt.second.end()
            objectId=omIt.first
            queryParams.Clear()
            tablePtr=(queryParams.GetCondTables().AddTable())
            tablePtr.tableCode=bizEnv.ObjectToTable(objectId,ao_Main)
            tablePtr=(queryParams.GetCondTables().AddTable())
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
            joinCondsOFPR[(condNum+=1;condNum-2)].relationship=0
            resStruct = []

            resStruct[0].tableIndex=0
            resStruct[0].colNum=UpgradeERDBaseTransGetTransIdCol(objectId)
            queryParams.dbdResPtr=resStruct
            queryParams.numOfResCols=1
            condPtr = PDBD_Cond.new
            UpgradeERDBaseTransAddDocNumConds(objectId,docNum,queryParams.GetConditions())
            condPtr=(queryParams.GetConditions().AddCondition())
            condPtr.tableIndex=1
            condPtr.colNum=OFPR_CODE
            condPtr.operation=DBD_EQ
            condPtr.condVal=periodCode
            condPtr.relationship=DBD_AND
            subQueryParams = DBD_Params.new
            subResStruct = []

            condPtr=(queryParams.GetConditions().AddCondition())
            condPtr.SetUseSubQuery(true)
            subQueryParams.GetCondTables().Clear()
            tablePtr=(subQueryParams.GetCondTables().AddTable())
            tablePtr.tableCode=bizEnv.ObjectToTable(JDT,ao_Arr1)
            subResStruct[0].agreg_type=DBD_COUNT
            subResStruct[0].tableIndex=0
            subResStruct[0].colNum=JDT1_TRANS_ABS
            subQueryParams.dbdResPtr=subResStruct
            subQueryParams.numOfResCols=1
            subQueryParams.GetConditions().Clear()
            subCondPtr = PDBD_Cond.new=(subQueryParams.GetConditions().AddCondition())
            subCondPtr.origTableLevel=1
            subCondPtr.origTableIndex=0
            subCondPtr.compareCols=true
            subCondPtr.colNum=UpgradeERDBaseTransGetTransIdCol(objectId)
            subCondPtr.operation=DBD_EQ
            subCondPtr.compTableIndex=0
            subCondPtr.compColNum=JDT1_TRANS_ABS
            subCondPtr.relationship=DBD_AND
            subCondPtr=(subQueryParams.GetConditions().AddCondition())
            subCondPtr.tableIndex=0
            subCondPtr.colNum=JDT1_ACCT_NUM
            subCondPtr.operation=DBD_EQ
            subCondPtr.condVal=inAccount
            subCondPtr.relationship=DBD_AND
            subCondPtr=(subQueryParams.GetConditions().AddCondition())
            subCondPtr.tableIndex=0
            subCondPtr.colNum=JDT1_SHORT_NAME
            subCondPtr.operation=DBD_EQ
            subCondPtr.condVal=inShortName
            subCondPtr.relationship=DBD_AND
            subCondPtr=(subQueryParams.GetConditions().AddCondition())
            subCondPtr.tableIndex=0
            subCondPtr.colNum=JDT1_FC_CURRENCY
            subCondPtr.operation=DBD_NE
            subCondPtr.condVal=bizEnv.GetMainCurrency()
            subCondPtr.relationship=DBD_AND
            subCondPtr=(subQueryParams.GetConditions().AddCondition())
            subCondPtr.tableIndex=0
            subCondPtr.colNum=JDT1_FC_CURRENCY
            subCondPtr.operation=DBD_NOT_NULL
            subCondPtr.relationship=0
            condPtr.SetSubQueryParams(subQueryParams)
            condPtr.tableIndex=DBD_NO_TABLE
            condPtr.operation=DBD_GT
            condPtr.condVal=0
            condPtr.relationship=0
            dagRes = PDAG.new=nil
            dagQuery = PDAG.new=bizEnv.OpenDAG(BOT,ao_Arr1)
            dagQuery.SetDBDParms(queryParams)
            ooErr=DBD_GetInNewFormat(dagQuery,dagRes)
            if ooErr
               if ooErr==-2028
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


         (omIt+=1)
      end

      if numOfCandidates==1
         ooErr=ooNoErr
      else
         ooErr=-2028
      end

      return ooErr
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

   def UpgradeERDBaseTransAddDocNumConds(objectId,docNum,conds)
      condPtr = PDBD_Cond.new
      if objectId==JDT
         condPtr=(conds.AddCondition())
         condPtr.bracketOpen=1
         condPtr.tableIndex=0
         condPtr.colNum=OJDT_NUMBER
         condPtr.operation=DBD_EQ
         condPtr.condVal=docNum
         condPtr.relationship=DBD_OR
         condPtr=(conds.AddCondition())
         condPtr.tableIndex=0
         condPtr.colNum=OJDT_JDT_NUM
         condPtr.operation=DBD_EQ
         condPtr.condVal=docNum
         condPtr.bracketClose=1
      else
         if objectId==RCT||objectId==VPM
            condPtr=(conds.AddCondition())
            condPtr.tableIndex=0
            condPtr.colNum=ORCT_NUM
            condPtr.operation=DBD_EQ
            condPtr.condVal=docNum
            condPtr.relationship=DBD_AND
            condPtr=(conds.AddCondition())
            condPtr.tableIndex=0
            condPtr.colNum=ORCT_CANCELED
            condPtr.operation=DBD_NE
            condPtr.condVal=VAL_YES
         else
            condPtr=(conds.AddCondition())
            condPtr.tableIndex=0
            condPtr.colNum=OINV_NUM
            condPtr.operation=DBD_EQ
            condPtr.condVal=docNum
         end

      end

      condPtr.relationship=DBD_AND
   end

   def UpgradeERDBaseTransPopulateAbbrevMap(abbrevMap)
      docAbbrevs = std::set.new
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

   def AmountChangedSinceMDRAssigned_APA(mdrObj,dagJDT1,rec,changedDim)
      changed = Boolean.new=false
      amount = MONEY.new
      ocrCode = []

      formatStr = []

      tmpStr = SBOString.new
      dagJDT1.GetColMoney(amount,JDT1_FC_DEBIT,rec)
      if amount.IsZero()
         dagJDT1.GetColMoney(amount,JDT1_FC_CREDIT,rec)
         if amount.IsZero()
            dagJDT1.GetColMoney(amount,JDT1_DEBIT,rec)
            if amount.IsZero()
               dagJDT1.GetColMoney(amount,JDT1_CREDIT,rec)
            end

         end

      end

      dimInfo = []

      dim = SBOString.new(DIM)
      dimObj = CCostAccountingDimension.new=static_cast(GetEnv().CreateBusinessObject(dim))
      dimObj.DIMGetAllDimensionsInfo(dimInfo)
      flds = []
      =""
      dimIdx=0
      while (dimIdx<DIMENSION_MAX) do
         if dimInfo[dimIdx].DimActive
            dagJDT1.GetColStr(ocrCode,flds[dimIdx],rec)
            _STR_LRTrim(ocrCode)
            if mdrObj.RuleIsManual(ocrCode)
               mdrObj.AmountIsChangedForManualRule(ocrCode,amount,changed)
               if changed
                  _STR_GetStringResource(formatStr,80304,16,coreSystemDefault,GetEnv())
                  tmpStr.Format(formatStr,rec+1,dimIdx+1)
                  Message(80304,15,tmpStr,OO_ERROR)
                  changedDim=dimIdx+1
                  break
               end

            end

         end


         (dimIdx+=1;dimIdx-2)
      end

      dimObj.Destroy()
      return changed
   end

   def isValidMatType(mat_type)
      if (mat_type!=0)&&(mat_type!=-1)
         return true
      else
         return false
      end

   end

   def UpgradeDOC6VatPaidForFullyBasedCreditMemos(objID)
      ooErr=0
      env = CBizEnv.new=GetEnv()
      updStmt = DBQUpdateStatement.new(env)
      begin
         tDoc6 = DBQTable.new=updStmt.Update(env.ObjectToTable(objID,ao_Arr6))
         tOdoc = DBQTable.new=updStmt.Update(env.ObjectToTable(objID,ao_Main))
         updStmt.Set(INV6_VAT_APPLIED).Col(tDoc6,INV6_VAT_SUM)
         updStmt.Set(INV6_VAT_APPLIED_SYS).Col(tDoc6,INV6_VAT_SYS)
         updStmt.Set(INV6_VAT_APPLIED_FRGN).Col(tDoc6,INV6_VAT_FRGN)
         updStmt.Where().Col(tDoc6,INV6_ABS_ENTRY).EQ().Col(tOdoc,OINV_ABS_ENTRY).And().Col(tDoc6,INV6_STATUS).EQ().Val(VAL_CLOSE).And().Col(tOdoc,OINV_STATUS).EQ().Val(VAL_CLOSE).And().Col(tDoc6,INV6_VAT_APPLIED).EQ().Val(0)
         updStmt.Execute()
      rescue DBMException=>e
         ooErr=e.GetCode()
         return ooErr
      end

      return ooErr
   end

   def UpgradeODOCVatPaidForFullyBasedCreditMemos(objID)
      ooErr=0
      env = CBizEnv.new=GetEnv()
      updStmt = DBQUpdateStatement.new(env)
      begin
         tOdoc = DBQTable.new=updStmt.Update(env.ObjectToTable(objID,ao_Main))
         updStmt.Set(OINV_VAT_APPLIED).Col(tOdoc,OINV_VAT_SUM)
         updStmt.Set(OINV_VAT_APPLIED_SYS).Col(tOdoc,OINV_VAT_SYS)
         updStmt.Set(OINV_VAT_APPLIED_FRGN).Col(tOdoc,OINV_VAT_FRGN)
         updStmt.Where().Col(tOdoc,OINV_VAT_APPLIED).EQ().Val(0).And().Col(tOdoc,OINV_STATUS).EQ().Val(VAL_CLOSE)
         updStmt.Execute()
      rescue DBMException=>e
         ooErr=e.GetCode()
         return ooErr
      end

      return ooErr
   end

   def RepairEquVatRateOfJDT1ForOneObject(objectId)
      ooErr=ooNoErr
      tableTAX1 = SMU_BQ_Table.new
      tableOTAX = SMU_BQ_Table.new
      tableOJDT = SMU_BQ_Table.new
      tableJDT1 = SMU_BQ_Table.new
      tableOINV = SMU_BQ_Table.new
      bq = SMU_BQ_Context.new(GetEnv())
      bq.AddTable(TAX,ao_Arr1,tableTAX1)
      bq.AddJoin(TAX,ao_Main,tableOTAX,tableTAX1,SMU_BQ_INNER_JOIN)
      bq.ConditionContext_SetToJoin(tableOTAX)
      bq.AddConditions().Col(tableOTAX,OTAX_ABS_ENTRY).EQ().Col(tableTAX1,TAX1_ABS_ENTRY)
      bq.AddJoin(JDT,ao_Main,tableOJDT,tableOTAX,SMU_BQ_INNER_JOIN)
      bq.ConditionContext_SetToJoin(tableOJDT)
      bq.AddConditions().Col(tableOJDT,OJDT_TRANS_TYPE).EQ().Col(tableOTAX,OTAX_SOURCE_OBJ_TYPE).AND().Col(tableOJDT,OJDT_BASE_REF).EQ().Col(tableOTAX,OTAX_SOURCE_OBJ_ABS_ENTRY)
      bq.AddJoin(JDT,ao_Arr1,tableJDT1,tableOJDT,SMU_BQ_INNER_JOIN)
      bq.ConditionContext_SetToJoin(tableJDT1)
      bq.AddConditions().Col(tableJDT1,JDT1_TRANS_ABS).EQ().Col(tableOJDT,OJDT_JDT_NUM).AND().Col(tableJDT1,JDT1_VAT_LINE).EQ().Val(VAL_YES).AND().Col(tableJDT1,JDT1_VAT_GROUP).EQ().Col(tableTAX1,TAX1_TAX_CODE)
      bq.AddJoin(objectId,ao_Main,tableOINV,tableOTAX,SMU_BQ_INNER_JOIN)
      bq.ConditionContext_SetToJoin(tableOINV)
      bq.AddConditions().Col(tableOINV,INV1_ABS_ENTRY).EQ().Col(tableOTAX,OTAX_SOURCE_OBJ_ABS_ENTRY)
      bq.ConditionContext_SetToWherePart()
      bq.AddConditions().Col(tableTAX1,TAX1_EQ_PERCENT).NE().Val(STR_0).AND().Col(tableOTAX,OTAX_SOURCE_OBJ_TYPE).EQ().Val(objectId)
      bq.AddCondition_AND()
      bq.AddCondition_BracketOpen()
      version=VERSION_2007_226
      while (version<=VERSION_2007_227) do
         versionStr = SBOString.new(version)
         major = SBOString.new
         minor = SBOString.new
         build = SBOString.new
         major=versionStr.Left(1)
         minor=versionStr.Mid(1,2)
         build=versionStr.Right(3)
         versionStr=major+_T(".")+minor+_T(".")+build+_T(".*")
         bq.AddCondition_CompareColumnWithString(tableOINV,(objectId==RCT||objectId==VPM) ? ORCT_VERSION_NUM : OINV_VERSION_NUM,DBD_PATTERN,versionStr)
         if version!=VERSION_2007_227
            bq.AddCondition_OR()
         end


         (version+=1;version-2)
      end

      bq.AddCondition_BracketClose()
      bq.AddResultColumn(resTax1AbsEntry,tableTAX1,TAX1_ABS_ENTRY)
      bq.AddResultColumn(resTax1TaxCode,tableTAX1,TAX1_TAX_CODE)
      bq.AddResultColumn(resTax1EqPercent,tableTAX1,TAX1_EQ_PERCENT)
      bq.AddResultColumn(resJdt1TransId,tableJDT1,JDT1_TRANS_ABS)
      bq.AddResultColumn(resJdt1Line_ID,tableJDT1,JDT1_LINE_ID)
      bq.AddSortParam(tableJDT1,JDT1_TRANS_ABS,false)
      bq.AddSortParam(tableJDT1,JDT1_LINE_ID,false)
      bq.SetFlag(DBD_FLAG_DISTINCT_DAG,true)
      key = DBM_KA.new
      key.SetSegmentsCount(2)
      key.SetSegmentColumn(0,resJdt1TransId)
      key.SetSegmentColumn(1,resJdt1Line_ID)
      dagRes = PDAG.new=nil
      dagQuery = PDAG.new=GetEnv().OpenDAG(JDT,ao_Arr1)
      bq.AssignToDAG(dagQuery)
      ooErr=dagQuery.GetFirstChunk(10000,key,dagRes)
      if ooErr&&ooErr!=-2028
         dagQuery.Close()
         return ooErr
      end

      while (ooErr==ooNoErr)
         ooErr=UpdateIncorrectEquVatRate(dagRes)
         if ooErr
            dagQuery.Close()
            return ooErr
         end

         ooErr=dagQuery.GetNextChunk(10000,key,dagRes)
      end

      if ooErr==-2028
         ooErr=ooNoErr
      end

      dagQuery.Close()
      return ooErr
   end

   def UpdateIncorrectEquVatRate(dagRes)
      ooErr=ooNoErr


      vatGroup = SBOString.new
      nextVatGroup = SBOString.new
      rec=dagRes.GetRecordCount()-1

      while (rec>=0) do
         ooErr=UpdateIncorrectEquVatRateOneRec(dagRes,rec)
         if ooErr
            return ooErr
         end

         dagRes.GetColLong(absEntry,resTax1AbsEntry,rec)
         dagRes.GetColStr(vatGroup,resTax1TaxCode,rec)
         vatGroup.Trim()
         if rec-1>=0
            dagRes.GetColLong(nextAbsEntry,resTax1AbsEntry,rec-1)
            dagRes.GetColStr(nextVatGroup,resTax1TaxCode,rec-1)
            nextVatGroup.Trim()
         else
            break
         end

         if absEntry==nextAbsEntry&&vatGroup==nextVatGroup
            (rec-=1;rec+2)
         end


         (rec-=1;rec+2)
      end

      return ooErr
   end

   def UpdateIncorrectEquVatRateOneRec(dagRes,rec)
      ooErr=ooNoErr


      equVatRate = MONEY.new
      dagRes.GetColLong(transId,resJdt1TransId,rec)
      dagRes.GetColLong(lineId,resJdt1Line_ID,rec)
      dagRes.GetColMoney(equVatRate,resTax1EqPercent,rec)
      conds = []

      updateStruct = []

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
      dagJDT1 = PDAG.new=GetEnv().OpenDAG(JDT,ao_Arr1)
      DBD_SetDAGCond(dagJDT1,conds,2)
      DBD_SetDAGUpd(dagJDT1,updateStruct,1)
      ooErr=DBD_UpdateCols(dagJDT1)
      dagJDT1.Close()
      return ooErr
   end

   def InitDataReport340(dagJDT)
      trace("InitDataReport340")
      sboErr=ooNoErr
      bizEnv = CBizEnv.new=GetEnv()
      if GetDataSource()==VAL_OBSERVER_SOURCE
         dagJDT.NullifyCol(OJDT_RESIDENCE_NUM,0)
      end

      return sboErr
   end

   def CompleteReport340(dagJDT,dagJDT1)
      trace("CompleteReport340")
      sboErr=ooNoErr
      bizEnv = CBizEnv.new=GetEnv()
      dagCRD = PDAG.new=GetDAG(CRD)
      residenNum = SBOString.new
      account = SBOString.new
      shortName = SBOString.new


      if GetDataSource()==VAL_OBSERVER_SOURCE
         dagJDT.GetColStr(residenNum,OJDT_RESIDENCE_NUM,0)
         if residenNum.GetLength()<=0
            atLeasOneBPFound=false
            if IsManualJE(dagJDT)==true
               numOfRecs=dagJDT1.GetRealSize(dbmDataBuffer)
               if numOfRecs>0
                  rec=0
                  while (rec<numOfRecs) do
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


                     (rec+=1;rec-2)
                  end

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

   def HandleFCExchangeRounding(dagJDT1,currencyMap)
      totalDebitMinusCredit = CAllCurrencySums.new
      debit = CAllCurrencySums.new
      credit = CAllCurrencySums.new
      amount = MONEY.new

      lastNonZeroFCLine = long.new(-1)
      currency = SBOString.new
      vatLine = SBOString.new
      roundingStruct = FCRoundingStruct.new
      size=dagJDT1.GetRecordCount()
      idx=0
      while (idx<size) do
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

            roundingStruct.totalDebitMinusCredit+=(debit-credit)
            currencyMap[currency]=roundingStruct
         end

         totalDebitMinusCredit+=(debit-credit)

         (idx+=1;idx-2)
      end

      if totalDebitMinusCredit.GetLcSum()==0&&totalDebitMinusCredit.GetScSum()==0
         return ooNoErr
      end

      itr = StdMap::const_iterator.new=currencyMap.begin()

      while (itr!=currencyMap.end()) do
         roundingStruct=itr.second
         if roundingStruct.needRounding&&roundingStruct.totalDebitMinusCredit.GetFcSum()==0&&(roundingStruct.totalDebitMinusCredit.GetLcSum()!=0||roundingStruct.totalDebitMinusCredit.GetScSum()!=0)&&roundingStruct.lastNonZeroFCLine!=-1
            dagJDT1.GetColMoney(amount,JDT1_FC_DEBIT,roundingStruct.lastNonZeroFCLine)
            if amount!=0
               dagJDT1.GetColMoney(amount,JDT1_DEBIT,roundingStruct.lastNonZeroFCLine)
               amount-=roundingStruct.totalDebitMinusCredit.GetLcSum()
               dagJDT1.SetColMoney(amount,JDT1_DEBIT,roundingStruct.lastNonZeroFCLine)
               dagJDT1.GetColMoney(amount,JDT1_SYS_DEBIT,roundingStruct.lastNonZeroFCLine)
               amount-=roundingStruct.totalDebitMinusCredit.GetScSum()
               dagJDT1.SetColMoney(amount,JDT1_SYS_DEBIT,roundingStruct.lastNonZeroFCLine)
            else
               dagJDT1.GetColMoney(amount,JDT1_CREDIT,roundingStruct.lastNonZeroFCLine)
               amount+=roundingStruct.totalDebitMinusCredit.GetLcSum()
               dagJDT1.SetColMoney(amount,JDT1_CREDIT,roundingStruct.lastNonZeroFCLine)
               dagJDT1.GetColMoney(amount,JDT1_SYS_CREDIT,roundingStruct.lastNonZeroFCLine)
               amount+=roundingStruct.totalDebitMinusCredit.GetScSum()
               dagJDT1.SetColMoney(amount,JDT1_SYS_CREDIT,roundingStruct.lastNonZeroFCLine)
            end

         end


         (itr+=1)
      end

      return ooNoErr
   end

   def UpgradeDprId(isSalesObject,introVersion1_Including,introVersion2)
      sboErr=ooNoErr
      env = CBizEnv.new=GetEnv()
      paymentObjType=isSalesObject ? RCT : VPM
      dpmObjType=isSalesObject ? DPI : DPO
      dagRES = APCompanyDAG.new
      countRes=0
      begin
         stmt = DBQRetrieveStatement.new(env)
         tORCT = DBQTable.new=stmt.From(env.ObjectToTable(paymentObjType,ao_Main))
         tRCT2 = DBQTable.new=stmt.Join(env.ObjectToTable(paymentObjType,ao_Arr2),tORCT)
         stmt.On(tRCT2).Col(tRCT2,RCT2_DOC_KEY).EQ().Col(tORCT,ORCT_ABS_ENTRY).And().Col(tORCT,ORCT_CANCELED).NE().Val(VAL_YES)
         stmt.Select().Col(tORCT,ORCT_VERSION_NUM)
         stmt.Select().Col(tORCT,ORCT_OBJECT)
         stmt.Select().Col(tRCT2,RCT2_DOC_KEY)
         stmt.Select().Col(tRCT2,RCT2_LINE_ID)
         stmt.Select().Col(tRCT2,RCT2_INVOICE_KEY)
         versionNums = SBOCollection_SBOString.new
         i=0
         version = introVersion1_Including
         while (i<15&&version<introVersion2) do
            versionStr = SBOString.new(version)
            major = SBOString.new
            minor = SBOString.new
            build = SBOString.new
            major=versionStr.Left(1)
            minor=versionStr.Mid(1,2)
            build=versionStr.Right(3)
            versionStr=major+_T(".")+minor+_T(".")+build
            versionNums.Add(versionStr)

            (i+=1;i-2);(version+=1;version-2)
         end

         stmt.Where().Col(tRCT2,RCT2_INVOICE_TYPE).EQ().Val(dpmObjType).And().Col(tRCT2,RCT2_PAID_DPM).EQ().Val(VAL_NO)
         stmt.Where().And().OpenBracket()
         j=0
         while (j<versionNums.GetSize()) do
            stmt.Where().Col(tORCT,ORCT_VERSION_NUM).StartsWith().Val(versionNums[j])
            if j!=versionNums.GetSize()-1
               stmt.Where().Or()
            end


            (j+=1;j-2)
         end

         stmt.Where().CloseBracket()
         countRes=stmt.Execute(dagRES)
         if countRes<1
            return sboErr
         end

      rescue DBMException=>e
         return e.GetCode()
      end

      sboErr=UpdateDprIdOnJERow(paymentObjType,dagRES)
      return sboErr
   end

   def UpgradeDprIdForOneDprPayment(isSalesObject,introVersion)
      sboErr=ooNoErr
      env = CBizEnv.new=GetEnv()
      paymentObjType=isSalesObject ? RCT : VPM
      dpmObjType=isSalesObject ? DPI : DPO
      dagRES = APCompanyDAG.new
      countRes=0
      begin
         stmt = DBQRetrieveStatement.new(env)
         tORCT = DBQTable.new=stmt.From(env.ObjectToTable(paymentObjType,ao_Main))
         tRCT2 = DBQTable.new=stmt.Join(env.ObjectToTable(paymentObjType,ao_Arr2),tORCT)
         stmt.On(tRCT2).Col(tRCT2,RCT2_DOC_KEY).EQ().Col(tORCT,ORCT_ABS_ENTRY).And().Col(tORCT,ORCT_CANCELED).NE().Val(VAL_YES)
         stmt.Select().Min().Col(tORCT,ORCT_VERSION_NUM).As(ORCT_VERSION_NUM_ALIAS)
         stmt.Select().Min().Col(tORCT,ORCT_OBJECT).As(ORCT_OBJECT_ALIAS)
         stmt.Select().Col(tRCT2,RCT2_DOC_KEY).As(RCT2_DOC_KEY_ALIAS)
         stmt.Select().Min().Col(tRCT2,RCT2_LINE_ID).As(RCT2_LINE_ID_ALIAS)
         stmt.Select().Min().Col(tRCT2,RCT2_INVOICE_KEY).As(RCT2_INVOICE_KEY_ALIAS)
         versionStr = SBOString.new(introVersion)
         major = SBOString.new
         minor = SBOString.new
         build = SBOString.new
         major=versionStr.Left(1)
         minor=versionStr.Mid(1,2)
         build=versionStr.Right(3)
         versionStr=major+_T(".")+minor+_T(".")+build
         stmt.Where().Col(tRCT2,RCT2_INVOICE_TYPE).EQ().Val(dpmObjType).And().Col(tRCT2,RCT2_PAID_DPM).EQ().Val(VAL_NO).And().Col(tORCT,ORCT_VERSION_NUM).LT().Val(versionStr)
         stmt.GroupBy(tRCT2,RCT2_DOC_KEY)
         stmt.Having().Count().Col(tRCT2,RCT2_DOC_KEY).EQ().Val(1)
         countRes=stmt.Execute(dagRES)
         if countRes<1
            return sboErr
         end

      rescue DBMException=>e
         return e.GetCode()
      end

      sboErr=UpdateDprIdOnJERow(paymentObjType,dagRES)
      return sboErr
   end

   def UpdateDprIdOnJERow(paymentObjType,dagRES)
      sboErr=ooNoErr
      env = CBizEnv.new=GetEnv()
      countRes=dagRES.GetRealSize(dbmDataBuffer)
      rec=0
      while (rec<countRes) do
         dagRES.GetColLong(paymentDocEntry,dagRES.GetColumnByAlias(RCT2_DOC_KEY_ALIAS),rec)
         dagRES.GetColLong(paymentLineId,dagRES.GetColumnByAlias(RCT2_LINE_ID_ALIAS),rec)
         dagRES.GetColLong(dprDocEntry,dagRES.GetColumnByAlias(RCT2_INVOICE_KEY_ALIAS),rec)
         begin
            ustmt = DBQUpdateStatement.new(env)
            tJDT1 = DBQTable.new=ustmt.Update(env.ObjectToTable(JDT,ao_Arr1))
            ustmt.Set(JDT1_DPR_ABS_ID).Val(dprDocEntry)
            ustmt.Where().Col(tJDT1,JDT1_TRANS_TYPE).EQ().Val(paymentObjType).And().Col(tJDT1,JDT1_CREATED_BY).EQ().Val(paymentDocEntry).And().Col(tJDT1,JDT1_LINE_TYPE).EQ().Val(ooCtrlAct_DPRequestType).And().Col(tJDT1,JDT1_DPR_ABS_ID).IsNull().And().OpenBracket().Col(tJDT1,JDT1_SRC_LINE).IsNull().Or().Col(tJDT1,JDT1_SRC_LINE).EQ().Val(paymentLineId).Or().Col(tJDT1,JDT1_SRC_LINE).LT().Val(0).CloseBracket()
            ustmt.Execute()
         rescue DBMException=>e
            return e.GetCode()
         end


         (rec+=1;rec-2)
      end

      return sboErr
   end

   def isValidCENVAT(cenvat)
      if (cenvat!=0)&&(cenvat!=-1)
         return true
      else
         return false
      end

   end

   def ValidateRowLocation(rec)
      trace("ValidateRowLocation")
      dagJDT1 = PDAG.new=GetDAG(JDT,ao_Arr1)
      vatLine = SBOString.new
      dagJDT1.GetColStr(vatLine,JDT1_VAT_LINE,rec)
      if vatLine==VAL_YES
         taxCode = SBOString.new
         dagJDT1.GetColStr(taxCode,JDT1_TAX_CODE,rec)
         if !taxCode.IsEmpty()
            dagJDT1.GetColLong(location,JDT1_LOCATION,rec)
            if !location
               SetArrNum(ao_Arr1)
               SetErrorField(OJDT_LOCATION)
               SetErrorLine(rec+1)
               Message(GO_OBJ_ERROR_MSGS(JDT),17,nil,OO_ERROR)
               return (ooInvalidObject)
            end

         end

      end

      dagJDT = PDAG.new=GetDAG(JDT,ao_Main)

      dagJDT.GetColLong(objType,OJDT_TRANS_TYPE)
      if objType==JDT||objType==-1

         dagJDT1.GetColLong(maType,JDT1_MATERIAL_TYPE,rec)
         dagJDT1.GetColLong(cenvatCon,JDT1_CENVAT_COM,rec)
         if isValidCENVAT(cenvatCon)||isValidMatType(maType)
            dagJDT1.GetColLong(location,JDT1_LOCATION,rec)
            if !location
               SetArrNum(ao_Arr1)
               SetErrorField(OJDT_LOCATION)
               SetErrorLine(rec+1)
               Message(GO_OBJ_ERROR_MSGS(JDT),17,nil,OO_ERROR)
               return (ooInvalidObject)
            end

         end

      end

      return ooNoErr
   end

   def SetReconAcct(isInCancellingAcctRecon,acct)
      @m_isInCancellingAcctRecon=isInCancellingAcctRecon
      if @m_reconAcctSet.find(acct)==@m_reconAcctSet.end()
         @m_reconAcctSet.insert(acct)
      end

      return
   end

   def LogBPAccountBalance(bpBalanceLogDataArray,keyNum)
      size=bpBalanceLogDataArray.size()
      dagCRD = PDAG.new=GetDAG(CRD)
      ooErr=0
      tempMoney = MONEY.new
      i=0
      while (i<size) do
         bpBalanceChangeLogData = CBPBalanceChangeLogData.new=bpBalanceLogDataArray[i]
         ooErr=GetEnv().GetByOneKey(dagCRD,GO_PRIMARY_KEY_NUM,bpBalanceChangeLogData.GetCode(),true)
         if ooErr
            return
         end

         dagCRD.GetColMoney(tempMoney,OCRD_CURRENT_BALANCE)
         bpBalanceChangeLogData.SetNewAcctBalanceLC(tempMoney)
         dagCRD.GetColMoney(tempMoney,OCRD_F_BALANCE)
         bpBalanceChangeLogData.SetNewAcctBalanceFC(tempMoney)
         bpBalanceChangeLogData.SetKeyNum(keyNum)
         bpBalanceChangeLogData.Log()

         (i+=1;i-2)
      end

   end

   def SetZeroBalanceDueForCentralizedPayment(set = true)
      @m_bZeroBalanceDue=set
   end

   def IsZeroBalanceDueForCentralizedPayment()
      return @m_bZeroBalanceDue
   end

   def CalculationSystAmmountOfTrans()
      trace("CalculationSystAmmountOfTrans")
      ooErr=ooNoErr
      dagJDT = PDAG.new=nil
      dagJDT1 = PDAG.new = nil



      forceBalance = true
      refDate = Date.new




      tmpMoney = MONEY.new
      systMoney = MONEY.new
      rateLine = MONEY.new
      opMoney = MONEY.new
      credit = MONEY.new
      debit = MONEY.new
      systCredTotal = MONEY.new
      systDebTotal = MONEY.new
      credFTotal = MONEY.new
      debFTotal = MONEY.new
      mainCurr = Currency.new
      lineCurr = Currency.new
      systCurr = Currency.new
      currStr = Currency.new
      prevCurr = Currency.new = ""
      tmpStr = []

      bizEnv = CBizEnv.new=GetEnv()
      dagJDT=GetDAG()
      dagJDT1=GetDAG(JDT,ao_Arr1)
      multiFrgCurr=false
      frgCurr=false
      getOnlyFromLocal=false
      notTranslateToSys=false
      hasOneFrgCurr=false
      _STR_strcpy(mainCurr,bizEnv.GetMainCurrency())
      _STR_strcpy(systCurr,bizEnv.GetSystemCurrency())
      DAG_GetCount(dagJDT1,numOfRecs)
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
      while (rec<numOfRecs) do
         dagJDT1.GetColMoney(tmpMoney,JDT1_FC_CREDIT,rec,DBM_NOT_ARRAY)
         MONEY_Add(credFTotal,tmpMoney)
         dagJDT1.GetColMoney(tmpMoney,JDT1_FC_DEBIT,rec,DBM_NOT_ARRAY)
         MONEY_Add(debFTotal,tmpMoney)

         (rec+=1;rec-2)
      end

      if !GNCoinCmp(mainCurr,systCurr)
         notTranslateToSys=true
         getOnlyFromLocal=true
      end

      if MONEY_Cmp(credFTotal,debFTotal)
         if !getOnlyFromLocal
            dagJDT.GetColStr(tmpStr,OJDT_AUTO_VAT,0)
            if tmpStr[0]==VAL_NO[0]
               getOnlyFromLocal=true
            else
               vatFound=false
               rec=0
               while (rec<numOfRecs) do
                  dagJDT1.GetColStr(tmpStr,bizEnv.IsVatPerLine() ? JDT1_VAT_GROUP : JDT1_TAX_CODE,rec)
                  if !_STR_IsSpacesStr(tmpStr)
                     vatFound=true
                     break
                  end


                  (rec+=1;rec-2)
               end

               if !vatFound
                  getOnlyFromLocal=true
               else
                  forceBalance=false
               end

            end

         end

      end

      tmpMoney.SetToZero()
      credFTotal.SetToZero()
      debFTotal.SetToZero()
      if !getOnlyFromLocal
         rec=0
         while (rec<numOfRecs) do
            dagJDT1.GetColStr(lineCurr,JDT1_FC_CURRENCY,rec)
            _STR_LRTrim(lineCurr)
            if lineCurr[0]&&prevCurr[0]&&GNCoinCmp(prevCurr,lineCurr)
               multiFrgCurr=true
               getOnlyFromLocal=true
            end

            if lineCurr[0]
               _STR_strcpy(prevCurr,lineCurr)
            end


            (rec+=1;rec-2)
         end

      end

      if !getOnlyFromLocal
         rec=0
         while (rec<numOfRecs) do
            dagJDT1.GetColStr(lineCurr,JDT1_FC_CURRENCY,rec)
            _STR_LRTrim(lineCurr)
            if lineCurr[0]
               dagJDT1.GetColMoney(tmpMoney,JDT1_FC_CREDIT,rec,DBM_NOT_ARRAY)
               if tmpMoney.IsZero()
                  dagJDT1.GetColMoney(tmpMoney,JDT1_FC_DEBIT,rec,DBM_NOT_ARRAY)
                  if tmpMoney.IsZero()
                     getOnlyFromLocal=true
                     break
                  end

               end

            end


            (rec+=1;rec-2)
         end

      end

      if GetDataSource()==VAL_OBSERVER_SOURCE
         rec=0
         while (rec<numOfRecs) do
            if !dagJDT1.IsNullCol(JDT1_SYS_CREDIT,rec)||!dagJDT1.IsNullCol(JDT1_SYS_DEBIT,rec)
               if bizEnv.IsBlockSystemCurrency()
                  SetErrorLine(rec+1)
                  SetErrorField(JDT1_SYS_CREDIT)
                  SetArrNum(ao_Arr1)
                  Message(JTE_JDT_FORM_NUM,28,nil,OO_ERROR)
                  return (ooInvalidObject)
               end

               forceBalance=false
            end


            (rec+=1;rec-2)
         end

      end

      if forceBalance
         rec=0
         while (rec<numOfRecs) do
            dagJDT1.GetColMoney(tmpMoney,JDT1_CREDIT,rec,DBM_NOT_ARRAY)
            MONEY_Add(credit,tmpMoney)
            dagJDT1.GetColMoney(tmpMoney,JDT1_DEBIT,rec,DBM_NOT_ARRAY)
            MONEY_Add(debit,tmpMoney)

            (rec+=1;rec-2)
         end

         if MONEY_Cmp(credit,debit)
            forceBalance=false
         end

      end

      rec=0
      while (rec<numOfRecs) do
         sideOfDebit=true
         _STR_strcpy(currStr,mainCurr)
         tmpMoney.SetToZero()
         systMoney.SetToZero()
         if !getOnlyFromLocal
            frgCurr=false
            dagJDT1.GetColStr(lineCurr,JDT1_FC_CURRENCY,rec)
            _STR_LRTrim(lineCurr)
            if GNCoinCmp(mainCurr,lineCurr)&&lineCurr[0]
               frgCurr=true
            else
               _STR_strcpy(lineCurr,mainCurr)
            end

            if frgCurr
               _STR_strcpy(currStr,lineCurr)
            else
               _STR_strcpy(lineCurr,mainCurr)
            end

         end

         dagJDT1.GetColMoney(tmpMoney,(frgCurr) ? JDT1_FC_DEBIT : JDT1_DEBIT,rec,DBM_NOT_ARRAY)
         if tmpMoney.IsZero()
            sideOfDebit=false
            dagJDT1.GetColMoney(tmpMoney,(frgCurr) ? JDT1_FC_CREDIT : JDT1_CREDIT,rec,DBM_NOT_ARRAY)
         end

         if tmpMoney.IsZero()
            next

         end

         if !forceBalance&&!dagJDT1.IsNullCol(sideOfDebit ? JDT1_SYS_DEBIT : JDT1_SYS_CREDIT,rec)
            dagJDT1.GetColMoney(opMoney,sideOfDebit ? JDT1_SYS_CREDIT : JDT1_SYS_DEBIT,rec,DBM_NOT_ARRAY)
            if !opMoney.IsZero()
               SetErrorLine(rec+1)
               SetErrorField(JDT1_SYS_CREDIT)
               SetArrNum(ao_Arr1)
               Message(GO_OBJ_ERROR_MSGS(JDT),4,nil,OO_ERROR)
               return (ooInvalidObject)
            end

            if GetDataSource()==VAL_OBSERVER_SOURCE
               next

            end

         end

         if (!GNCoinCmp(lineCurr,systCurr)&&!getOnlyFromLocal)||notTranslateToSys
            systMoney=tmpMoney
         else
            ooErr=GNTranslateToSysAmmount(tmpMoney,currStr,refDate,systMoney,GetEnv())
            if ooErr||systMoney.IsZero()
               if IsExCommand(ooExAutoMode)
                  if ooErr==ooUndefinedCurrency
                     Message(ERROR_MESSAGES_STR,OO_UNDEFINED_CURRENCY,nil,OO_ERROR)
                  else
                     Message(ERROR_MESSAGES_STR,OO_RATE_MISSING,nil,OO_ERROR)
                  end

               end

               return ooErr
            end

         end

         MONEY_Round(systMoney,RC_SUM,systCurr,bizEnv)
         if sideOfDebit
            MONEY_Add(systDebTotal,systMoney)
            MONEY_Add(debFTotal,tmpMoney)
         else
            MONEY_Add(systCredTotal,systMoney)
            MONEY_Add(credFTotal,tmpMoney)
         end

         if sideOfDebit&&!systMoney.IsZero()
            dagJDT1.SetColMoney(systMoney,JDT1_SYS_DEBIT,rec,DBM_NOT_ARRAY)
         else
            if !sideOfDebit&&!systMoney.IsZero()
               dagJDT1.SetColMoney(systMoney,JDT1_SYS_CREDIT,rec,DBM_NOT_ARRAY)
            end

         end

         if frgCurr&&!hasOneFrgCurr
            hasOneFrgCurr=true
         end


         (rec+=1;rec-2)
      end

      if !forceBalance
         return ooNoErr
      end

      dagJDT.GetColMoney(tmpMoney,(frgCurr) ? OJDT_FC_TOTAL : OJDT_LOC_TOTAL,0,DBM_NOT_ARRAY)
      ooErr=GNTranslateToSysAmmount(tmpMoney,currStr,refDate,systMoney,bizEnv)
      if !ooErr
         MONEY_Round(systMoney,RC_SUM,systCurr,bizEnv)
         dagJDT.SetColMoney(systMoney,OJDT_SYS_TOTAL,0,DBM_NOT_ARRAY)
         MONEY_Add(tmpMoney,debFTotal)
         MONEY_Sub(tmpMoney,credFTotal)
         MONEY_Sub(systDebTotal,systCredTotal)
         tmpMoney.SetToZero()
         if !systDebTotal.IsZero()
            (rec-=1;rec+2)
            if systDebTotal.IsPositive()
               if sideOfDebit
                  dagJDT1.GetColMoney(tmpMoney,JDT1_SYS_DEBIT,rec,DBM_NOT_ARRAY)
                  MONEY_Sub(tmpMoney,systDebTotal)
                  dagJDT1.SetColMoney(tmpMoney,JDT1_SYS_DEBIT,rec,DBM_NOT_ARRAY)
               else
                  dagJDT1.GetColMoney(tmpMoney,JDT1_SYS_CREDIT,rec,DBM_NOT_ARRAY)
                  MONEY_Add(tmpMoney,systDebTotal)
                  dagJDT1.SetColMoney(tmpMoney,JDT1_SYS_CREDIT,rec,DBM_NOT_ARRAY)
               end

            else
               if sideOfDebit
                  dagJDT1.GetColMoney(tmpMoney,JDT1_SYS_DEBIT,rec,DBM_NOT_ARRAY)
                  MONEY_Sub(tmpMoney,systDebTotal)
                  dagJDT1.SetColMoney(tmpMoney,JDT1_SYS_DEBIT,rec,DBM_NOT_ARRAY)
               else
                  dagJDT1.GetColMoney(tmpMoney,JDT1_SYS_CREDIT,rec,DBM_NOT_ARRAY)
                  MONEY_Add(tmpMoney,systDebTotal)
                  dagJDT1.SetColMoney(tmpMoney,JDT1_SYS_CREDIT,rec,DBM_NOT_ARRAY)
               end

            end

         end

      end

      return ooNoErr
   end

   def CompleteForeignAmount()
      trace("CompleteForeignAmount")
      ooErr=ooNoErr
      dagJDT = PDAG.new
      dagJDT1 = PDAG.new
      dagACT = PDAG.new
      dagCRD = PDAG.new


      tmpStr = []

      lineCurr = Currency.new
      prevCurr = Currency.new = ""
      found=false
      tmpMoney = MONEY.new
      frnAmnt = MONEY.new
      money = MONEY.new
      debit = MONEY.new
      credit = MONEY.new
      delta = MONEY.new
      refDate = Date.new
      mainCurr = Currency.new
      bizEnv = CBizEnv.new=GetEnv()
      dagJDT=GetDAG()
      dagJDT1=GetDAG(JDT,ao_Arr1)
      dagACT=GetDAG(ACT)
      dagCRD=GetDAG(CRD)
      ooErr=CalculationFrnAmmounts(dagACT,dagCRD,found)
      case ooErr

      when ooUndefinedCurrency
         Message(ERROR_MESSAGES_STR,OO_UNDEFINED_CURRENCY,nil,OO_ERROR)

      when ooNoRateErr
         Message(ERROR_MESSAGES_STR,OO_RATE_MISSING,nil,OO_ERROR)

      when ooInvalidCardCode
         Message(OBJ_MGR_ERROR_MSG,GO_CRD_NAME_MISSING,nil,OO_ERROR)

      end

      if ooErr
         return ooErr
      end

      _STR_strcpy(mainCurr,bizEnv.GetMainCurrency())
      dagJDT.GetColStr(refDate,OJDT_REF_DATE,0)
      DAG_GetCount(dagJDT1,numOfRecs)
      if !found
         return ooNoErr
      end

      rec=0
      while (rec<numOfRecs) do
         dagJDT1.GetColStr(lineCurr,JDT1_FC_CURRENCY,rec)
         _STR_LRTrim(lineCurr)
         if lineCurr[0]&&prevCurr[0]&&GNCoinCmp(prevCurr,lineCurr)
            return ooNoErr
         end

         if lineCurr[0]
            _STR_strcpy(prevCurr,lineCurr)
         end


         (rec+=1;rec-2)
      end

      debit.SetToZero()
      credit.SetToZero()
      rec=0
      while (rec<numOfRecs) do
         dagJDT1.GetColMoney(money,JDT1_DEBIT,rec,DBM_NOT_ARRAY)
         MONEY_Add(debit,money)
         dagJDT1.GetColMoney(money,JDT1_CREDIT,rec,DBM_NOT_ARRAY)
         MONEY_Add(credit,money)

         (rec+=1;rec-2)
      end

      if MONEY_Cmp(debit,credit)==0
         debit.SetToZero()
         credit.SetToZero()
         rec=0
         while (rec<numOfRecs) do
            dagJDT1.GetColMoney(money,JDT1_FC_DEBIT,rec,DBM_NOT_ARRAY)
            MONEY_Add(debit,money)
            dagJDT1.GetColMoney(money,JDT1_FC_CREDIT,rec,DBM_NOT_ARRAY)
            MONEY_Add(credit,money)

            (rec+=1;rec-2)
         end

         if MONEY_Cmp(debit,credit)
            MONEY_Sub(debit,credit)
            MONEY_FromLong(0.02*MONEY_PERCISION_MUL,delta)
            if debit.IsNegative()
               MONEY_Multiply(delta,-1,delta)
               if debit<delta
                  return ooNoErr
               end

            else
               if debit>delta
                  return ooNoErr
               end

            end

            dagJDT1.GetColStr(tmpStr,JDT1_DEBIT_CREDIT,rec)
            if tmpStr[0]==VAL_DEBIT[0]
               dagJDT1.GetColMoney(money,JDT1_FC_DEBIT,numOfRecs-1,DBM_NOT_ARRAY)
               if !money.IsZero()
                  MONEY_Sub(money,debit)
                  dagJDT1.SetColMoney(money,JDT1_FC_DEBIT,numOfRecs-1,DBM_NOT_ARRAY)
               end

            else
               dagJDT1.GetColMoney(money,JDT1_FC_CREDIT,numOfRecs-1,DBM_NOT_ARRAY)
               if !money.IsZero()
                  MONEY_Add(money,debit)
                  dagJDT1.SetColMoney(money,JDT1_FC_CREDIT,numOfRecs-1,DBM_NOT_ARRAY)
               end

            end

         end

      end

      return ooNoErr
   end

   def SetToZeroNullLineTypeCols()
      trace("SetToZeroNullLineTypeCols")
      ooErr=0
      dagJDT1 = PDAG.new
      updateZeroColNum = []
      =""
      dagJDT1=GetDAG(JDT,ao_Arr1)
      ooErr=GNUpdateNullColumnsToZero(dagJDT1,updateZeroColNum,1)
      if ooErr
         return ooErr
      end

      return ooErr
   end

   def SetToZeroOldLineTypeCols()
      trace("SetToZeroOldLineTypeCols")
      ooErr=0
      dagJDT1 = PDAG.new=GetDAG(JDT,ao_Arr1)
      conditions = DBD_Conditions.new=(dagJDT1.GetDBDParams().GetConditions())
      condPtr = PDBD_Cond.new
      conditions.Clear()
      condPtr=conditions.AddCondition()
      condPtr.bracketOpen=1
      condPtr.colNum=JDT1_TRANS_TYPE
      condPtr.operation=DBD_EQ
      condPtr.condVal=RCT
      condPtr.relationship=DBD_OR
      condPtr=conditions.AddCondition()
      condPtr.colNum=JDT1_TRANS_TYPE
      condPtr.operation=DBD_EQ
      condPtr.condVal=VPM
      condPtr.bracketClose=1
      condPtr.relationship=DBD_AND
      condPtr=(conditions.AddCondition())
      subParams = DBD_Params.new
      condPtr.operation=DBD_NOT_EXISTS
      condPtr.SetSubQueryParams(subParams)
      condPtr.tableIndex=DBD_NO_TABLE
      condPtr.relationship=0
      bizEnv = CBizEnv.new=GetEnv()
      subTables = DBD_CondTables.new=(subParams.GetCondTables())
      tablePtr = DBD_TablesList.new=subTables.AddTable()
      tablePtr.tableCode=bizEnv.ObjectToTable(JDT,ao_Arr1)
      subResStruct = []

      subResStruct[0].tableIndex=0
      subResStruct[0].colNum=JDT1_TRANS_ABS
      subConditions = DBD_Conditions.new=(subParams.GetConditions())
      condPtr=(subConditions.AddCondition())
      condPtr.origTableIndex=0
      condPtr.origTableLevel=1
      condPtr.colNum=JDT1_TRANS_ABS
      condPtr.operation=DBD_EQ
      condPtr.compareCols=true
      condPtr.compTableIndex=0
      condPtr.compColNum=JDT1_TRANS_ABS
      condPtr.relationship=DBD_AND
      condPtr=(subConditions.AddCondition())
      condPtr.tableIndex=0
      condPtr.colNum=JDT1_SHORT_NAME
      condPtr.operation=DBD_NE
      condPtr.compareCols=true
      condPtr.compTableIndex=0
      condPtr.compColNum=JDT1_ACCT_NUM
      condPtr.relationship=DBD_AND
      condPtr=(subConditions.AddCondition())
      condPtr.tableIndex=0
      condPtr.colNum=JDT1_LINE_TYPE
      condPtr.operation=DBD_NE
      condPtr.condVal=ooCtrlAct_DPRequestType
      condPtr.relationship=DBD_AND
      condPtr=(subConditions.AddCondition())
      condPtr.tableIndex=0
      condPtr.colNum=JDT1_LINE_TYPE
      condPtr.operation=DBD_NE
      condPtr.condVal=ooCtrlAct_PaidDPRequestType
      condPtr.relationship=0
      updateStruct = []

      updateStruct[0].colNum=JDT1_LINE_TYPE
      updateStruct[0].updateVal=0
      ooErr=DBD_SetDAGUpd(dagJDT1,updateStruct,1)
      if ooErr
         return ooErr
      end

      ooErr=DBD_UpdateCols(dagJDT1)
      if ooErr
         return ooErr
      end

      return ooErr
   end

   def CompleteTrans()
      trace("CompleteTrans")

      dagJDT = PDAG.new
      dagJDT1 = PDAG.new
      dagCRD = PDAG.new


      curDate = Date.new
      mainCurrency = Currency.new
      shortName = []

      bizEnv = CBizEnv.new=GetEnv()
      _STR_strcpy(mainCurrency,bizEnv.GetMainCurrency())
      dagJDT=GetDAG(JDT)
      dagJDT1=GetDAG(JDT,ao_Arr1)
      dagCRD=GetDAG(CRD)
      DAG_GetCount(dagJDT,numOfRecs)
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

      dagJDT.GetColLong(transType,OJDT_TRANS_TYPE,0)
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

      DAG_GetCount(dagJDT1,numOfRecs)
      if numOfRecs<=0
         Message(OBJ_MGR_ERROR_MSG,GO_NO_TOTAL_IN_DOC_LINES,nil,OO_ERROR)
         return ooInvalidObject
      end

      rec=0
      while (rec<numOfRecs) do
         if dagJDT1.IsNullCol(JDT1_DUE_DATE,rec)
            dagJDT1.SetColStr(curDate,JDT1_DUE_DATE,rec)
         end

         if dagJDT1.IsNullCol(JDT1_SHORT_NAME,rec)
            dagJDT1.CopyColumn(dagJDT1,JDT1_SHORT_NAME,rec,JDT1_ACCT_NUM,rec)
         else
            if dagJDT1.IsNullCol(JDT1_ACCT_NUM,rec)&&!dagJDT1.IsNullCol(JDT1_SHORT_NAME,rec)
               dagJDT1.GetColStr(shortName,JDT1_SHORT_NAME,rec)
               if !_STR_IsSpacesStr(shortName)
                  dbErr=bizEnv.GetByOneKey(dagCRD,OCRD_KEYNUM_PRIMARY,shortName,true)
                  if dbErr
                     dagJDT1.CopyColumn(dagJDT1,JDT1_ACCT_NUM,rec,JDT1_SHORT_NAME,rec)
                  else
                     dagJDT1.CopyColumn(dagCRD,JDT1_ACCT_NUM,rec,OCRD_DEB_PAY_ACCOUNT,0)
                  end

               end

            end

         end

         if dagJDT1.IsNullCol(JDT1_ACCT_NUM,rec)&&dagJDT1.IsNullCol(JDT1_SHORT_NAME,rec)&&bizEnv.IsVatPerLine()&&!dagJDT1.IsNullCol(JDT1_VAT_GROUP,rec)
            dagRES = PDAG.new
            tableStruct = []

            condStruct = []

            resStruct = []

            _STR_strcpy(tableStruct[0].tableCode,bizEnv.ObjectToTable(SBOString(VTG),ao_Main))
            resStruct[0].colNum=OVTG_ACCOUNT
            condStruct[0].colNum=OVTG_GROUP_CODE
            condStruct[0].operation=DBD_EQ
            dagJDT1.GetColStr(condStruct[0].condVal,JDT1_VAT_GROUP,rec)
            _STR_LRTrim(condStruct[0].condVal)
            if !condStruct[0].condVal.IsEmpty()
               DBD_SetTablesList(dagCRD,tableStruct,1)
               DBD_SetDAGCond(dagCRD,condStruct,1)
               DBD_SetDAGRes(dagCRD,resStruct,1)
               dbErr=DBD_GetInNewFormat(dagCRD,dagRES)
               if !dbErr
                  dagJDT1.CopyColumn(dagRES,JDT1_ACCT_NUM,rec,0,0)
                  dagJDT1.CopyColumn(dagRES,JDT1_SHORT_NAME,rec,0,0)
               end

            end

         end


         (rec+=1;rec-2)
      end

      return ooNoErr
   end

   def CompleteJdtLine()
      trace("CompleteJdtLine")
      ooErr=0
      dagJDT1 = PDAG.new
      dagJDT = PDAG.new



      bizEnv = CBizEnv.new=GetEnv()
      mbEnabled=false
      isAutoCompleteBPLFromUD = false
      bplInfo = CBusinessPlaceObject::BPLInfo.new
      dagJDT=GetDAG()
      dagJDT1=GetDAG(JDT,ao_Arr1)
      DAG_GetCount(dagJDT1,numOfRecs)
      mbEnabled=VF_MultiBranch_EnabledInOADM(bizEnv)
      isAutoCompleteBPLFromUD=mbEnabled&&GetDataSource()==VAL_OBSERVER_SOURCE&&CBusinessPlaceObject.IsAutoCompleteBPLFromUserDefaults(GetID().strtol())
      rec=0
      while (rec<numOfRecs) do
         if mbEnabled
            if isAutoCompleteBPLFromUD&&!IsColumnChangedByDI(dagJDT1,rec,JDT1_BPL_ID)&&!CBusinessPlaceObject.IsValidBPLId(dagJDT1.GetColStr(JDT1_BPL_ID,rec,coreSystemDefault).strtol())
               lTmp=bizEnv.GetUserDefaultBranch()
               if CBusinessPlaceObject.IsValidBPLId(lTmp)
                  dagJDT1.SetColLong(lTmp,JDT1_BPL_ID,rec)
                  SetBPLId(lTmp)
               end

            end

            dagJDT1.GetColLong(lTmp,JDT1_BPL_ID,rec)
            CBusinessPlaceObject.GetBPLInfo(bizEnv,lTmp,bplInfo)
            dagJDT1.SetColStr(bplInfo.GetBPLName(),JDT1_BPL_NAME,rec)
            dagJDT1.SetColStr(bplInfo.GetVatRegNum(),JDT1_VAT_REG_NUM,rec)
         end

         if dagJDT1.IsNullCol(JDT1_LINE_MEMO,rec)
            dagJDT1.CopyColumn(dagJDT,JDT1_LINE_MEMO,rec,OJDT_MEMO,0)
         end

         if dagJDT1.IsNullCol(JDT1_REF_DATE,rec)
            dagJDT1.CopyColumn(dagJDT,JDT1_REF_DATE,rec,OJDT_REF_DATE,0)
            ocrCode = SBOString.new
            postDate = SBOString.new
            dagJDT1.GetColStr(ocrCode,JDT1_OCR_CODE,rec)
            dagJDT1.GetColStr(postDate,JDT1_REF_DATE,rec)
            validFrom = SBOString.new
            COverheadCostRateObject.GetValidFrom(GetEnv(),ocrCode,postDate,validFrom)
            dagJDT1.SetColStr(validFrom,JDT1_VALID_FROM,rec)
         end

         if VF_EnableVATDate(GetEnv())
            if dagJDT1.IsNullCol(JDT1_VAT_DATE,rec)
               dagJDT1.CopyColumn(dagJDT,JDT1_VAT_DATE,rec,OJDT_VAT_DATE,0)
            end

         end

         if dagJDT1.IsNullCol(JDT1_TAX_DATE,rec)
            dagJDT1.CopyColumn(dagJDT,JDT1_TAX_DATE,rec,OJDT_TAX_DATE,0)
         end

         if dagJDT1.IsNullCol(JDT1_REF2,rec)
            dagJDT1.CopyColumn(dagJDT,JDT1_REF2,rec,OJDT_REF2,0)
         end

         if dagJDT1.IsNullCol(JDT1_REF1,rec)
            dagJDT1.CopyColumn(dagJDT,JDT1_REF1,rec,OJDT_REF1,0)
         end

         if dagJDT1.IsNullCol(JDT1_PROJECT,rec)
            projectCode = SBOString.new
            dagJDT.GetColStr(projectCode,OJDT_PROJECT,0)
            if projectCode.IsEmpty()
               acctCode = SBOString.new
               bizEnv = CBizEnv.new=GetEnv()
               dagACT = APCompanyDAG.new
               OpenDAG(dagACT,ACT)
               dagJDT1.GetColStr(acctCode,JDT1_ACCT_NUM,rec)
               ooErr=bizEnv.GetByOneKey(dagACT,OACT_KEYNUM_PRIMARY,acctCode)
               if ooErr
                  return ooErr
               end

               dagJDT1.CopyColumn(dagACT,JDT1_PROJECT,rec,OACT_PROJECT,0)
            else
               dagJDT1.SetColStr(projectCode,JDT1_PROJECT,rec)
            end

         end

         dagJDT1.CopyColumn(dagJDT,JDT1_TRANS_TYPE,rec,OJDT_TRANS_TYPE,0)
         dagJDT1.CopyColumn(dagJDT,JDT1_BASE_REF,rec,OJDT_BASE_REF,0)
         dagJDT1.CopyColumn(dagJDT,JDT1_CREATED_BY,rec,OJDT_CREATED_BY,0)

         (rec+=1;rec-2)
      end

      return ooErr
   end

   def ReconcileCertainLines()
      trace("ReconcileCertainLines")
      ooErr=0
      dagJdt1 = PDAG.new
      dagJdt = PDAG.new
      dagDupJdt1 = PDAG.new
      dagRES = PDAG.new
      shortName = SBOString.new
      bPOrACTCode = SBOString.new
      keyStr = []



      numOfConds=0




      date = Date.new
      bizEnv = CBizEnv.new=GetEnv()
      condStruct = []

      resStruct = []

      pMM = CSystemMatchManager.new=nil
      shouldAddLine2Match=true
      shouldCancelRecons=true
      dagJdt=GetDAG()
      dagJdt1=GetDAG(JDT,ao_Arr1)
      dagJdt.GetColStr(date,OJDT_REF_DATE,0)
      dagJdt.GetColLong(transNum,OJDT_STORNO_TO_TRANS,0)
      dagJdt.GetColLong(newTransNum,OJDT_JDT_NUM,0)
      condStruct[numOfConds].colNum=JDT1_TRANS_ABS
      condStruct[numOfConds].operation=DBD_EQ
      condStruct[numOfConds].condVal=transNum
      condStruct[(numOfConds+=1;numOfConds-2)].relationship=DBD_AND
      condStruct[numOfConds].colNum=JDT1_ACCT_NUM
      condStruct[numOfConds].operation=DBD_NE
      condStruct[numOfConds].compareCols=true
      condStruct[numOfConds].compColNum=JDT1_SHORT_NAME
      condStruct[(numOfConds+=1;numOfConds-2)].relationship=0
      DBD_SetDAGCond(dagJdt1,condStruct,numOfConds)
      resStruct[0].colNum=JDT1_SHORT_NAME
      resStruct[0].group_by=true
      DBD_SetDAGRes(dagJdt1,resStruct,1)
      ooErr=DBD_GetInNewFormat(dagJdt1,dagRES)
      if @m_isInCancellingAcctRecon
         dagRES.SetSize(@m_reconAcctSet.size(),dbmDropData)
         itr = std::set::iterator.new=@m_reconAcctSet.begin()
         rec=0
         while (itr!=@m_reconAcctSet.end()) do
            dagRES.SetColStr(itr,0,rec)
            (rec+=1;rec-2)

            (itr+=1)
         end

      else
         if ooErr
            return ooNoErr
         end

      end

      DAG_GetCount(dagRES,numOfBPOrACTs)
      ooErr=dagJdt1.Duplicate(dagDupJdt1,dbmDropData)
      if ooErr
         return ooErr
      end

      DAG_SetSize(dagDupJdt1,1,dbmDropData)
      dagJdt.GetColStr(keyStr,OJDT_STORNO_TO_TRANS,0)
      _STR_LRTrim(keyStr)
      ooErr=DBD_GetKeyGroup(dagDupJdt1,JDT1_KEYNUM_PRIMARY,keyStr,true)
      if ooErr
         DAG_Close(dagDupJdt1)
         return (ooErr)
      end

      DAG_GetCount(dagRES,numOfBPOrACTs)
      bPOrACT_rec=0
      while (bPOrACT_rec<numOfBPOrACTs) do
         pMM=CSystemMatchManager.new(bizEnv,@m_isInCancellingAcctRecon==false,date.GetString(),JDT,transNum,rt_Reversal)
         dagRES.GetColStr(bPOrACTCode,0,bPOrACT_rec)
         bPOrACTCode.Trim()
         DAG_GetCount(dagJdt1,numOfRecs)
         rec=0
         while (rec<numOfRecs) do
            shouldAddLine2Match=true
            dagJdt1.GetColStr(shortName,JDT1_SHORT_NAME,rec)
            shortName.Trim()
            if shortName==bPOrACTCode
               if @m_stornoExtraInfoCreator
                  shouldAddLine2Match=@m_stornoExtraInfoCreator.IsNeedToAddLineToReconciliation(dagJdt1,rec,false)
               end

               if shouldAddLine2Match
                  pMM.AddMatchDataLine(newTransNum,rec)
               end

            end


            (rec+=1;rec-2)
         end

         DAG_GetCount(dagDupJdt1,numOfRecs)
         rec=0
         while (rec<numOfRecs) do
            shouldAddLine2Match=true
            shouldCancelRecons=true
            dagDupJdt1.GetColStr(shortName,JDT1_SHORT_NAME,rec)
            shortName.Trim()
            if shortName==bPOrACTCode
               if @m_stornoExtraInfoCreator
                  if !@m_stornoExtraInfoCreator.IsNeedToCancelReconForThisLine(dagDupJdt1,rec)
                     shouldCancelRecons=false
                  end

               end

               if shouldCancelRecons
                  ooErr=CManualMatchManager.CancelAllReconsOfJournalLine(bizEnv,transNum,rec)
                  if ooErr
                     DAG_Close(dagDupJdt1)
                     pMM.__delete
                     return (ooErr)
                  end

               end

               if @m_stornoExtraInfoCreator
                  shouldAddLine2Match=@m_stornoExtraInfoCreator.IsNeedToAddLineToReconciliation(dagDupJdt1,rec,true)
               end

               if shouldAddLine2Match
                  pMM.AddMatchDataLine(transNum,rec)
               end

            end


            (rec+=1;rec-2)
         end

         ooErr=pMM.Reconcile()
         pMM.__delete
         if ooErr
            DAG_Close(dagDupJdt1)
            return ooErr
         end


         (bPOrACT_rec+=1;bPOrACT_rec-2)
      end

      DAG_Close(dagDupJdt1)
      return ooErr
   end

   def UpgradeBoeActs()
      trace("UpgradeBoeActs")

      dagCRD = PDAG.new
      dagACT = PDAG.new
      dagJDT1 = PDAG.new
      dagRES = PDAG.new = nil
      dagRES2 = PDAG.new = nil
      dagAnswer = PDAG.new = nil
      updateCardBalanceCond = DBD_CondStruct.new
      updateActBalanceCond = DBD_CondStruct.new
      cond = DBD_CondStruct.new
      condStruct = []

      tableStruct = []

      joinCondStruct = []
      joinCondStructForOtherObj = []
      joinCondStructBoe = []

      resStruct = []

      updStruct = []


      numOfCardConds = 0
      numOfActsConds = 0
      numOfConds = 0

      firstAct = Boolean.new
      firstErr = Boolean.new = false

      columns = []
      = ""
      orders = []
      =""
      savedShortName = []
      shortName = []
      savedAcc = []
      tmpStr = []

      bizEnv = CBizEnv.new=GetEnv()
      iterationType = []
      =""
      totalNumOfIterations=0
      numOfIterations = 0
      numOfTables = 0
      if !bizEnv.IsLocalSettingsFlag(lsf_EnableBOE)
         return ooNoErr
      end

      if UpgradeVersionCheck(VERSION_65_77)
         ooErr=@fixVendorsAndSpainBoeBalance()
         if ooErr
            return ooErr
         end

      end

      if VF_BOEAsInSpain(bizEnv)
         return ooNoErr
      end

      _STR_strcpy(tableStruct[0].tableCode,bizEnv.ObjectToTable(JDT,ao_Arr1))
      dagJDT1=OpenDAG(JDT,ao_Arr1)
      if bizEnv.IsCurrentLocalSettings(FRANCE_SETTINGS)||VF_OpenFRBoE(bizEnv)
         totalNumOfIterations=3
      else
         totalNumOfIterations=2
      end

      ii=0
      while (ii<3) do
         if !(bizEnv.IsCurrentLocalSettings(FRANCE_SETTINGS)||VF_OpenFRBoE(bizEnv))&&iterationType[ii]==1
            next

         end

         _STR_strcpy(tableStruct[0].tableCode,bizEnv.ObjectToTable(JDT,ao_Arr1))
         numOfTables=1
         BuildRelatedBoeQuery(tableStruct,numOfConds,iterationType[ii],numOfTables,condStruct,joinCondStructForOtherObj,joinCondStructBoe)
         _STR_strcpy(tableStruct[(numOfTables+=1;numOfTables-2)].tableCode,bizEnv.ObjectToTable(CRD,ao_Arr3))
         tableStruct[numOfTables-1].doJoin=true
         tableStruct[numOfTables-1].joinedToTable=0
         tableStruct[numOfTables-1].numOfConds=1
         tableStruct[numOfTables-1].joinConds=joinCondStruct
         joinCondStruct[0].compareCols=true
         joinCondStruct[0].compTableIndex=0
         joinCondStruct[0].compColNum=JDT1_ACCT_NUM
         joinCondStruct[0].tableIndex=numOfTables-1
         joinCondStruct[0].colNum=CRD3_ACCOUNT_CODE
         joinCondStruct[0].operation=DBD_EQ
         condStruct[numOfConds].compareCols=true
         condStruct[numOfConds].colNum=JDT1_SHORT_NAME
         condStruct[numOfConds].operation=DBD_NE
         condStruct[numOfConds].compColNum=JDT1_ACCT_NUM
         condStruct[numOfConds].tableIndex=0
         condStruct[(numOfConds+=1;numOfConds-2)].relationship=DBD_AND
         condStruct[numOfConds].compareCols=true
         condStruct[numOfConds].colNum=JDT1_SHORT_NAME
         condStruct[numOfConds].operation=DBD_EQ
         condStruct[numOfConds].compColNum=CRD3_CARD_CODE
         condStruct[numOfConds].tableIndex=0
         condStruct[numOfConds].compTableIndex=numOfTables-1
         condStruct[(numOfConds+=1;numOfConds-2)].relationship=DBD_AND
         if bizEnv.IsCurrentLocalSettings(ITALY_SETTINGS)
            condStruct[numOfConds].tableIndex=numOfTables-1
            condStruct[numOfConds].colNum=CRD3_ACCOUNT_TYPE
            _STR_strcpy(condStruct[numOfConds].condVal,ARP_TYPE_BoE_PRESENTATION)
            condStruct[numOfConds].operation=DBD_EQ
            condStruct[(numOfConds+=1;numOfConds-2)].relationship=0
         else
            if bizEnv.IsCurrentLocalSettings(FRANCE_SETTINGS)||VF_OpenFRBoE(bizEnv)
               condStruct[numOfConds].bracketOpen=1
               condStruct[numOfConds].tableIndex=numOfTables-1
               condStruct[numOfConds].colNum=CRD3_ACCOUNT_TYPE
               _STR_strcpy(condStruct[numOfConds].condVal,ARP_TYPE_BoE_ON_COLLECTION)
               condStruct[numOfConds].operation=DBD_EQ
               condStruct[(numOfConds+=1;numOfConds-2)].relationship=DBD_OR
               condStruct[numOfConds].tableIndex=numOfTables-1
               condStruct[numOfConds].colNum=CRD3_ACCOUNT_TYPE
               _STR_strcpy(condStruct[numOfConds].condVal,ARP_TYPE_BoE_DISCOUNTED)
               condStruct[numOfConds].operation=DBD_EQ
               condStruct[(numOfConds+=1;numOfConds-2)].relationship=DBD_OR
               condStruct[numOfConds].tableIndex=numOfTables-1
               condStruct[numOfConds].colNum=CRD3_ACCOUNT_TYPE
               _STR_strcpy(condStruct[numOfConds].condVal,ARP_TYPE_UNPAID_BoE)
               condStruct[numOfConds].operation=DBD_EQ
               condStruct[numOfConds].bracketClose=1
               condStruct[(numOfConds+=1;numOfConds-2)].relationship=0
            else
               if bizEnv.IsCurrentLocalSettings(PORTUGAL_SETTINGS)||VF_Boleto(bizEnv)
                  condStruct[numOfConds].bracketOpen=1
                  condStruct[numOfConds].tableIndex=numOfTables-1
                  condStruct[numOfConds].colNum=CRD3_ACCOUNT_TYPE
                  _STR_strcpy(condStruct[numOfConds].condVal,ARP_TYPE_BoE_PRESENTATION)
                  condStruct[numOfConds].operation=DBD_EQ
                  condStruct[(numOfConds+=1;numOfConds-2)].relationship=DBD_OR
                  condStruct[numOfConds].tableIndex=numOfTables-1
                  condStruct[numOfConds].colNum=CRD3_ACCOUNT_TYPE
                  _STR_strcpy(condStruct[numOfConds].condVal,ARP_TYPE_BoE_DISCOUNTED)
                  condStruct[numOfConds].operation=DBD_EQ
                  condStruct[numOfConds].bracketClose=1
                  condStruct[(numOfConds+=1;numOfConds-2)].relationship=0
               end

            end

         end

         condStruct[numOfConds-1].relationship=0
         resStruct[0].colNum=JDT1_TRANS_ABS
         resStruct[0].tableIndex=0
         resStruct[1].colNum=JDT1_LINE_ID
         resStruct[1].tableIndex=0
         resStruct[2].colNum=JDT1_ACCT_NUM
         resStruct[2].tableIndex=0
         resStruct[3].colNum=JDT1_INTR_MATCH
         resStruct[3].tableIndex=0
         resStruct[4].colNum=JDT1_SHORT_NAME
         resStruct[4].tableIndex=0
         DBD_SetDAGCond(dagJDT1,condStruct,numOfConds)
         DBD_SetDAGRes(dagJDT1,resStruct,5)
         DBD_SetTablesList(dagJDT1,tableStruct,numOfTables)
         ooErr=DBD_GetInNewFormat(dagJDT1,dagAnswer)
         dagAnswer.Detach()
         if !ooErr&&numOfConds>1
            if nil!=dagRES
               dagRES.Concat(dagAnswer,dbmDataBuffer)
            else
               dagAnswer.Duplicate(dagRES,dbmKeepData)
            end

            DAG_Close(dagAnswer)
            dagAnswer=nil
         else
            if ooErr==-2028
               (numOfIterations+=1;numOfIterations-2)
               if numOfIterations==totalNumOfIterations
                  dagAnswer.Duplicate(dagRES,dbmKeepData)
                  DAG_SetSize(dagRES,0,dbmDropData)
               end

               DAG_Close(dagAnswer)
               dagAnswer=nil
            else
               if ooErr
                  DAG_Close(dagAnswer)
                  if dagRES
                     DAG_Close(dagRES)
                  end

                  DAG_Close(dagJDT1)
                  return ooErr
               end

            end

         end

         _MEM_Clear(condStruct,numOfConds)
         _MEM_Clear(tableStruct,numOfTables)
         numOfConds=0
         numOfTables=0

         (ii+=1;ii-2)
      end

      ii=0
      while (ii<3) do
         if !(bizEnv.IsCurrentLocalSettings(FRANCE_SETTINGS)||VF_OpenFRBoE(bizEnv))&&iterationType[ii]==1
            next

         end

         _MEM_Clear(condStruct,numOfConds)
         _MEM_Clear(tableStruct,numOfTables)
         numOfConds=0
         numOfTables=0
         _STR_strcpy(tableStruct[(numOfTables+=1;numOfTables-2)].tableCode,bizEnv.ObjectToTable(JDT,ao_Arr1))
         condStruct[numOfConds].compareCols=true
         condStruct[numOfConds].colNum=JDT1_SHORT_NAME
         condStruct[numOfConds].operation=DBD_NE
         condStruct[numOfConds].compColNum=JDT1_ACCT_NUM
         condStruct[numOfConds].tableIndex=0
         condStruct[(numOfConds+=1;numOfConds-2)].relationship=DBD_AND
         BuildRelatedBoeQuery(tableStruct,numOfConds,iterationType[ii],numOfTables,condStruct,joinCondStructForOtherObj,joinCondStructBoe)
         if bizEnv.IsCurrentLocalSettings(ITALY_SETTINGS)
            ooErr=ARP_GetAccountByType(GetEnv(),nil,ARP_TYPE_BoE_PRESENTATION,tmpStr,true,VAL_CUSTOMER)
            if !ooErr&&!_STR_IsSpacesStr(tmpStr)
               _STR_strcpy(condStruct[numOfConds].condVal,tmpStr)
               condStruct[numOfConds].tableIndex=0
               condStruct[numOfConds].colNum=JDT1_ACCT_NUM
               condStruct[numOfConds].operation=DBD_EQ
               condStruct[(numOfConds+=1;numOfConds-2)].relationship=0
            end

         else
            if bizEnv.IsCurrentLocalSettings(FRANCE_SETTINGS)||VF_OpenFRBoE(bizEnv)
               cmpNumOfConds=0
               cmpNumOfConds=numOfConds
               condStruct[numOfConds].bracketOpen=1
               ooErr=ARP_GetAccountByType(GetEnv(),nil,ARP_TYPE_BoE_ON_COLLECTION,tmpStr,true,VAL_CUSTOMER)
               if !ooErr&&!_STR_IsSpacesStr(tmpStr)
                  _STR_strcpy(condStruct[numOfConds].condVal,tmpStr)
                  condStruct[numOfConds].tableIndex=0
                  condStruct[numOfConds].colNum=JDT1_ACCT_NUM
                  condStruct[numOfConds].operation=DBD_EQ
                  condStruct[numOfConds].relationship=DBD_OR
                  (numOfConds+=1;numOfConds-2)
               end

               ooErr=ARP_GetAccountByType(GetEnv(),nil,ARP_TYPE_UNPAID_BoE,tmpStr,true,VAL_CUSTOMER)
               if !ooErr&&!_STR_IsSpacesStr(tmpStr)
                  _STR_strcpy(condStruct[numOfConds].condVal,tmpStr)
                  condStruct[numOfConds].tableIndex=0
                  condStruct[numOfConds].colNum=JDT1_ACCT_NUM
                  condStruct[numOfConds].operation=DBD_EQ
                  condStruct[numOfConds].relationship=DBD_OR
                  (numOfConds+=1;numOfConds-2)
               end

               ooErr=ARP_GetAccountByType(GetEnv(),nil,ARP_TYPE_BoE_DISCOUNTED,tmpStr,true,VAL_CUSTOMER)
               if !ooErr&&!_STR_IsSpacesStr(tmpStr)
                  _STR_strcpy(condStruct[numOfConds].condVal,tmpStr)
                  condStruct[numOfConds].tableIndex=0
                  condStruct[numOfConds].colNum=JDT1_ACCT_NUM
                  condStruct[numOfConds].operation=DBD_EQ
                  condStruct[numOfConds].relationship=0
                  (numOfConds+=1;numOfConds-2)
               end

               if cmpNumOfConds<numOfConds
                  condStruct[numOfConds-1].bracketClose=1
               else
                  condStruct[cmpNumOfConds].bracketClose=1
               end

            else
               if bizEnv.IsCurrentLocalSettings(PORTUGAL_SETTINGS)||VF_Boleto(bizEnv)
                  condStruct[numOfConds].bracketOpen=1
                  ooErr=ARP_GetAccountByType(GetEnv(),nil,ARP_TYPE_BoE_PRESENTATION,tmpStr,true,VAL_CUSTOMER)
                  if !ooErr&&!_STR_IsSpacesStr(tmpStr)
                     _STR_strcpy(condStruct[numOfConds].condVal,tmpStr)
                     condStruct[numOfConds].tableIndex=0
                     condStruct[numOfConds].colNum=JDT1_ACCT_NUM
                     condStruct[numOfConds].operation=DBD_EQ
                     condStruct[numOfConds].relationship=DBD_OR
                     (numOfConds+=1;numOfConds-2)
                  end

                  ooErr=ARP_GetAccountByType(GetEnv(),nil,ARP_TYPE_BoE_DISCOUNTED,tmpStr,true,VAL_CUSTOMER)
                  if !ooErr&&!_STR_IsSpacesStr(tmpStr)
                     _STR_strcpy(condStruct[numOfConds].condVal,tmpStr)
                     condStruct[numOfConds].tableIndex=0
                     condStruct[numOfConds].colNum=JDT1_ACCT_NUM
                     condStruct[numOfConds].operation=DBD_EQ
                     condStruct[numOfConds].relationship=0
                     (numOfConds+=1;numOfConds-2)
                  end

                  condStruct[numOfConds-1].bracketClose=1
               end

            end

         end

         if numOfConds>1
            condStruct[numOfConds].bracketClose=1
            condStruct[numOfConds-1].relationship=0
            DBD_SetDAGCond(dagJDT1,condStruct,numOfConds)
            DBD_SetDAGRes(dagJDT1,resStruct,5)
            DBD_SetTablesList(dagJDT1,tableStruct,numOfTables)
            ooErr=DBD_GetInNewFormat(dagJDT1,dagAnswer)
            dagAnswer.Detach()
         end

         if !ooErr&&numOfConds>1
            dagRES.Concat(dagAnswer,dbmDataBuffer)
            DAG_Close(dagAnswer)
            dagAnswer=nil
         else
            if ooErr==-2028
               DAG_Close(dagAnswer)
               dagAnswer=nil
            else
               if ooErr
                  DAG_Close(dagAnswer)
                  DAG_Close(dagRES)
                  DAG_Close(dagJDT1)
                  return ooErr
               end

            end

         end


         (ii+=1;ii-2)
      end

      DAG_GetCount(dagRES,numOfRecs)
      if !numOfRecs
         DAG_Close(dagJDT1)
         DAG_Close(dagRES)
         return ooNoErr
      end

      dagRES.SortByCols(columns,orders,3,false,false)
      _MEM_Clear(condStruct,numOfConds)
      cond=DBD_CondStruct.new[2*numOfRecs]
      updateActBalanceCond=DBD_CondStruct.new[numOfRecs]
      updateCardBalanceCond=DBD_CondStruct.new[numOfRecs]
      rec=0
      while (rec<numOfRecs) do
         dagRES.GetColStr(tmpStr,4,rec)
         if !IsCardAlreadyThere(updateCardBalanceCond,tmpStr,0,numOfCardConds)
            updateCardBalanceCond[numOfCardConds].colNum=OCRD_CARD_CODE
            updateCardBalanceCond[numOfCardConds].operation=DBD_EQ
            _STR_strcpy(updateCardBalanceCond[numOfCardConds].condVal,tmpStr)
            updateCardBalanceCond[(numOfCardConds+=1;numOfCardConds-2)].relationship=DBD_OR
         end


         (rec+=1;rec-2)
      end

      updateCardBalanceCond[numOfCardConds-1].relationship=0
      rec=0
      numOfConds=0
      firstAct=true
      while (rec<numOfRecs)
         dagRES.GetColStr(savedAcc,2,rec)
         _STR_LRTrim(savedAcc)
         dagRES.GetColLong(intrnMatch,3,rec)
         dagRES.GetColStr(savedShortName,4,rec)
         while (rec<numOfRecs)
            dagRES.GetColStr(tmpStr,2,rec)
            _STR_LRTrim(tmpStr)
            dagRES.GetColLong(tmpL,3,rec)
            dagRES.GetColStr(shortName,4,rec)
            if _STR_strcmp(tmpStr,savedAcc)||tmpL!=intrnMatch||_STR_strcmp(shortName,savedShortName)
               break
            end

            cond[numOfConds].bracketOpen=1
            cond[numOfConds].colNum=JDT1_TRANS_ABS
            cond[numOfConds].operation=DBD_EQ
            dagRES.GetColStr(tmpStr,0,rec)
            _STR_strcpy(cond[numOfConds].condVal,tmpStr)
            cond[(numOfConds+=1;numOfConds-2)].relationship=DBD_AND
            cond[numOfConds].colNum=JDT1_LINE_ID
            cond[numOfConds].operation=DBD_EQ
            dagRES.GetColStr(tmpStr,1,rec)
            _STR_strcpy(cond[numOfConds].condVal,tmpStr)
            cond[(numOfConds+=1;numOfConds-2)].relationship=DBD_OR
            cond[numOfConds-1].bracketClose=1
            (rec+=1;rec-2)
         end

         cond[numOfConds-1].relationship=0
         if intrnMatch<0
            GOGetNextSystemMatch(GetEnv(),savedAcc,matchNum,false)
            intrnMatch=matchNum
         end

         updStruct[0].colNum=JDT1_SHORT_NAME
         updStruct[0].SetUpdateColSource(DBD_UpdStruct::ucs_SrcCol)
         updStruct[0].srcColNum=JDT1_ACCT_NUM
         updStruct[1].colNum=JDT1_INTR_MATCH
         _STR_sprintf(tmpStr,LONG_FORMAT,intrnMatch)
         _STR_strcpy(updStruct[1].updateVal,tmpStr)
         DBD_SetDAGCond(dagJDT1,cond,numOfConds)
         DBD_SetDAGUpd(dagJDT1,updStruct,2)
         ooErr=DBD_UpdateCols(dagJDT1)
         if ooErr
            cond.__delete
            updateCardBalanceCond.__delete
            updateActBalanceCond.__delete
            DAG_Close(dagJDT1)
            DAG_Close(dagRES)
            return ooErr
         end

         if _STR_strcmp(tmpStr,savedAcc)||firstAct
            updateActBalanceCond[numOfActsConds].colNum=OACT_ACCOUNT_CODE
            updateActBalanceCond[numOfActsConds].operation=DBD_EQ
            _STR_strcpy(updateActBalanceCond[numOfActsConds].condVal,savedAcc)
            updateActBalanceCond[(numOfActsConds+=1;numOfActsConds-2)].relationship=DBD_OR
         end

         firstAct=false
         if rec>=numOfRecs
            break
         end

         numOfConds=0
      end

      DAG_Close(dagRES)
      DAG_Close(dagJDT1)
      updateActBalanceCond[numOfActsConds-1].relationship=0
      dagACT=OpenDAG(ACT,ao_Main)
      DBD_SetDAGCond(dagACT,updateActBalanceCond,numOfActsConds)
      ooErr=DBD_Get(dagACT)
      if ooErr
         cond.__delete
         updateCardBalanceCond.__delete
         updateActBalanceCond.__delete
         DAG_Close(dagACT)
         return ooErr
      end

      dagCRD=OpenDAG(CRD,ao_Main)
      DBD_SetDAGCond(dagCRD,updateCardBalanceCond,numOfCardConds)
      ooErr=DBD_Get(dagCRD)
      if ooErr
         cond.__delete
         updateCardBalanceCond.__delete
         updateActBalanceCond.__delete
         DAG_Close(dagCRD)
         DAG_Close(dagACT)
         return ooErr
      end

      RBARebuildAccountsAndCardsInternal(dagACT,dagCRD,false)
      cond.__delete
      updateCardBalanceCond.__delete
      updateActBalanceCond.__delete
      DAG_Close(dagCRD)
      DAG_Close(dagACT)
      return ooNoErr
   end

   def FixVendorsAndSpainBoeBalance()
      trace("FixVendorsAndSpainBoeBalance")

      dagCRD = PDAG.new
      dagJDT1 = PDAG.new
      dagRES = PDAG.new
      dagRES2 = PDAG.new
      updateCardBalanceCond = DBD_CondStruct.new
      condStruct = []

      tableStruct = []

      joinCondStruct = []

      resStruct = []

      numOfCardConds=0
      numOfActsConds = 0
      numOfConds = 0

      firstErr = Boolean.new=false
      tmpStr = []

      bizEnv = CBizEnv.new=GetEnv()
      _STR_strcpy(tableStruct[0].tableCode,bizEnv.ObjectToTable(JDT,ao_Arr1))
      dagJDT1=OpenDAG(JDT,ao_Arr1)
      _STR_strcpy(tableStruct[1].tableCode,bizEnv.ObjectToTable(CRD,ao_Arr3))
      tableStruct[1].doJoin=true
      tableStruct[1].joinedToTable=0
      tableStruct[1].numOfConds=1
      tableStruct[1].joinConds=joinCondStruct
      joinCondStruct[0].compareCols=true
      joinCondStruct[0].compTableIndex=0
      joinCondStruct[0].compColNum=JDT1_ACCT_NUM
      joinCondStruct[0].tableIndex=1
      joinCondStruct[0].colNum=CRD3_ACCOUNT_CODE
      joinCondStruct[0].operation=DBD_EQ
      condStruct[numOfConds].compareCols=true
      condStruct[numOfConds].colNum=JDT1_SHORT_NAME
      condStruct[numOfConds].operation=DBD_EQ
      condStruct[numOfConds].compColNum=CRD3_CARD_CODE
      condStruct[numOfConds].tableIndex=0
      condStruct[numOfConds].compTableIndex=1
      condStruct[(numOfConds+=1;numOfConds-2)].relationship=DBD_AND
      if VF_BOEAsInSpain(bizEnv)
         condStruct[numOfConds].bracketOpen=1
         condStruct[numOfConds].tableIndex=1
         condStruct[numOfConds].colNum=CRD3_ACCOUNT_TYPE
         _STR_strcpy(condStruct[numOfConds].condVal,ARP_TYPE_BoE_RECEIVABLE)
         condStruct[numOfConds].operation=DBD_EQ
         condStruct[(numOfConds+=1;numOfConds-2)].relationship=DBD_OR
      end

      condStruct[numOfConds].tableIndex=1
      condStruct[numOfConds].colNum=CRD3_ACCOUNT_TYPE
      _STR_strcpy(condStruct[numOfConds].condVal,ARP_TYPE_BoE_PAYABLE)
      condStruct[numOfConds].operation=DBD_EQ
      condStruct[(numOfConds+=1;numOfConds-2)].relationship=0
      if VF_BOEAsInSpain(bizEnv)
         condStruct[numOfConds-1].bracketClose=1
      end

      resStruct[0].colNum=JDT1_SHORT_NAME
      resStruct[0].tableIndex=0
      resStruct[0].group_by=true
      DBD_SetDAGCond(dagJDT1,condStruct,numOfConds)
      DBD_SetDAGRes(dagJDT1,resStruct,1)
      DBD_SetTablesList(dagJDT1,tableStruct,2)
      ooErr=DBD_GetInNewFormat(dagJDT1,dagRES)
      if ooErr&&ooErr!=-2028
         DAG_Close(dagJDT1)
         return ooErr
      else
         if ooErr
            firstErr=true
            DAG_SetSize(dagRES,0,dbmDropData)
         end

      end

      dagRES.Detach()
      _MEM_Clear(condStruct,numOfConds)
      _MEM_Clear(tableStruct,2)
      _STR_strcpy(tableStruct[0].tableCode,bizEnv.ObjectToTable(JDT,ao_Arr1))
      numOfConds=0
      if VF_BOEAsInSpain(bizEnv)
         ooErr=ARP_GetAccountByType(GetEnv(),nil,ARP_TYPE_BoE_RECEIVABLE,tmpStr,true,VAL_CUSTOMER)
         if !ooErr&&!_STR_IsSpacesStr(tmpStr)
            _STR_strcpy(condStruct[numOfConds].condVal,tmpStr)
            condStruct[numOfConds].tableIndex=0
            condStruct[numOfConds].colNum=JDT1_ACCT_NUM
            condStruct[numOfConds].operation=DBD_EQ
            condStruct[(numOfConds+=1;numOfConds-2)].relationship=DBD_OR
         end

      end

      ooErr=ARP_GetAccountByType(GetEnv(),nil,ARP_TYPE_BoE_PAYABLE,tmpStr,true,VAL_VENDOR)
      if !ooErr&&!_STR_IsSpacesStr(tmpStr)
         _STR_strcpy(condStruct[numOfConds].condVal,tmpStr)
         condStruct[numOfConds].tableIndex=0
         condStruct[numOfConds].colNum=JDT1_ACCT_NUM
         condStruct[numOfConds].operation=DBD_EQ
         condStruct[(numOfConds+=1;numOfConds-2)].relationship=0
      end

      if numOfConds
         DBD_SetDAGCond(dagJDT1,condStruct,numOfConds)
         DBD_SetDAGRes(dagJDT1,resStruct,1)
         DBD_SetTablesList(dagJDT1,tableStruct,1)
         ooErr=DBD_GetInNewFormat(dagJDT1,dagRES2)
         dagRES2.Detach()
      end

      if !ooErr&&numOfConds
         dagRES.Concat(dagRES2,dbmDataBuffer)
         DAG_Close(dagRES2)
      else
         if ooErr==-2028
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

      DAG_GetCount(dagRES,numOfRecs)
      if !numOfRecs
         DAG_Close(dagRES)
         return ooNoErr
      end

      updateCardBalanceCond=DBD_CondStruct.new[numOfRecs]
      rec=0
      while (rec<numOfRecs) do
         updateCardBalanceCond[numOfCardConds].colNum=OCRD_CARD_CODE
         updateCardBalanceCond[numOfCardConds].operation=DBD_EQ
         dagRES.GetColStr(tmpStr,0,rec)
         _STR_strcpy(updateCardBalanceCond[numOfCardConds].condVal,tmpStr)
         updateCardBalanceCond[(numOfCardConds+=1;numOfCardConds-2)].relationship=DBD_OR

         (rec+=1;rec-2)
      end

      updateCardBalanceCond[numOfCardConds-1].relationship=0
      dagCRD=OpenDAG(CRD,ao_Main)
      DBD_SetDAGCond(dagCRD,updateCardBalanceCond,numOfCardConds)
      ooErr=DBD_Get(dagCRD)
      if ooErr
         updateCardBalanceCond.__delete
         DAG_Close(dagCRD)
         return ooNoErr
      end

      RBARebuildAccountsAndCardsInternal(nil,dagCRD,false)
      updateCardBalanceCond.__delete
      DAG_Close(dagCRD)
      return ooNoErr
   end

   def UpgradePeriodIndic()
      trace("UpgradePeriodIndic")
      condStruct = []

      updateStruct = []

      dagJDT1 = PDAG.new
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
      updateStruct[0].colNum=JDT1_SRC_ABS_ID
      updateStruct[0].srcColNum=JDT1_CREATED_BY
      updateStruct[0].SetUpdateColSource(DBD_UpdStruct::ucs_SrcCol)
      DBD_SetDAGUpd(dagJDT1,updateStruct,1)
      sboErr=DBD_UpdateCols(dagJDT1)
      DAG_Close(dagJDT1)
      return sboErr
   end

   def CompleteVatLine()
      trace("CompleteVatLine")
      ooErr=0


      tmpStr = []
      formatStr = []

      stampTax = []

      actNum = []

      shortName = []

      defaultVat = []

      vatGroup = []

      taxPostAcct = []

      dateStr = []
      =""
      money = MONEY.new
      delta = MONEY.new
      tmpM = MONEY.new
      debit = MONEY.new
      credit = MONEY.new
      dagJDT = PDAG.new
      dagJDT1 = PDAG.new
      dagVTG = PDAG.new
      dagACT = PDAG.new
      dagRES = PDAG.new
      bizEnv = CBizEnv.new=GetEnv()
      debitSide = Boolean.new
      creditSide = Boolean.new
      found = Boolean.new
      condStruct = []

      resStruct = []

      localCurr = Currency.new
      sysCurr = Currency.new
      dagJDT=GetDAG(JDT)
      dagJDT1=GetDAG(JDT,ao_Arr1)
      dagACT=GetDAG(ACT)
      dagVTG=GetDAG(VTG)
      dagJDT.GetColStr(stampTax,OJDT_STAMP_TAX,0)
      if stampTax[0]==VAL_YES[0]
         if bizEnv.IsVatPerLine()
            if GetDataSource()==VAL_OBSERVER_SOURCE
               return @complateStampLine()
            else
               return ooNoErr
            end

         else
            return ooErrNoMsg
         end

      end

      _STR_strcpy(localCurr,bizEnv.GetMainCurrency())
      _STR_strcpy(sysCurr,bizEnv.GetSystemCurrency())
      DAG_GetCount(dagJDT1,numOfRecs)
      if bizEnv.IsVatPerLine()||bizEnv.IsVatPerCard()
         dagJDT.GetColStr(tmpStr,OJDT_AUTO_VAT,0)
         if tmpStr[0]==VAL_YES[0]
            if GetDataSource()==VAL_OBSERVER_SOURCE
               rec=0
               while (rec<numOfRecs) do
                  dagJDT1.GetColStr(actNum,JDT1_ACCT_NUM,rec)
                  dagJDT1.GetColStr(shortName,JDT1_SHORT_NAME,rec)
                  if _STR_strcmp(actNum,shortName)==0
                     if bizEnv.IsVatPerLine()
                        condStruct[0].colNum=OVTG_ACCOUNT
                        condStruct[0].operation=DBD_EQ
                        _STR_strcpy(condStruct[0].condVal,shortName)
                        condStruct[0].relationship=0
                        DBD_SetDAGCond(dagVTG,condStruct,1)
                        if DBD_Count(dagVTG,true)>0
                           Message(JTE_JDT_FORM_NUM,19,nil,OO_ERROR)
                           return ooErrNoMsg
                        end

                     end

                     ooErr=bizEnv.GetByOneKey(dagACT,OACT_KEYNUM_PRIMARY,actNum,true)
                     if !ooErr
                        if bizEnv.IsVatPerLine()
                           dagACT.GetColStr(defaultVat,OACT_DFLT_VAT_GROUP,0)
                           dagJDT1.GetColStr(vatGroup,JDT1_VAT_GROUP,rec)
                           if !_STR_IsSpacesStr(vatGroup)
                              dagACT.GetColStr(tmpStr,OACT_ALLOW_VAT_CHANGE,0)
                              if tmpStr[0]==VAL_NO[0]
                                 if _STR_strcmp(vatGroup,defaultVat)!=0
                                    Message(JTE_JDT_FORM_NUM,34,nil,OO_ERROR)
                                    return ooErrNoMsg
                                 end

                              end

                           else
                              dagJDT1.SetColStr(defaultVat,JDT1_VAT_GROUP,rec)
                           end

                        else
                           dagACT.GetColStr(defaultVat,OACT_DFLT_TAX_CODE,0)
                           dagJDT1.GetColStr(vatGroup,JDT1_TAX_CODE,rec)
                           if !_STR_IsSpacesStr(vatGroup)
                              dagJDT1.GetColStr(tmpStr,JDT1_TAX_POSTING_ACCOUNT,rec)
                              if tmpStr[0]==VAL_NO[0]
                                 Message(JTE_JDT_FORM_NUM,31,nil,OO_ERROR)
                                 return ooErrNoMsg
                              end

                              dagACT.GetColStr(tmpStr,OACT_ALLOW_VAT_CHANGE,0)
                              if tmpStr[0]==VAL_NO[0]
                                 if _STR_strcmp(vatGroup,defaultVat)!=0
                                    Message(JTE_JDT_FORM_NUM,33,nil,OO_ERROR)
                                    return ooErrNoMsg
                                 end

                                 dagJDT1.GetColStr(taxPostAcct,JDT1_TAX_POSTING_ACCOUNT,rec)
                                 dagACT.GetColStr(tmpStr,OACT_DFLT_POST_ACCT,0)
                                 if taxPostAcct[0]!=tmpStr[0]
                                    Message(JTE_JDT_FORM_NUM,32,nil,OO_ERROR)
                                    return ooErrNoMsg
                                 end

                              end

                           else
                              dagJDT1.SetColStr(defaultVat,JDT1_TAX_CODE,rec)
                              dagJDT1.CopyColumn(dagACT,JDT1_TAX_POSTING_ACCOUNT,rec,OACT_DFLT_POST_ACCT,0)
                           end

                        end

                        dagJDT1.GetColStr(vatGroup,bizEnv.IsVatPerLine() ? JDT1_VAT_GROUP : JDT1_TAX_CODE,rec)
                        if !_STR_IsSpacesStr(vatGroup)
                           if dagJDT1.IsNullCol(JDT1_GROSS_VALUE,rec)&&dagJDT1.IsNullCol(JDT1_GROSS_VALUE_FC,rec)
                              dagJDT1.SetColStr(VAL_YES,JDT1_IS_NET,rec)
                              if !dagJDT1.IsNullCol(JDT1_VAT_AMOUNT,rec)
                                 if bizEnv.IsVatPerLine()
                                    condStruct[0].colNum=OVTG_GROUP_CODE
                                    condStruct[0].operation=DBD_EQ
                                    _STR_strcpy(condStruct[0].condVal,vatGroup)
                                    DBD_SetDAGCond(dagVTG,condStruct,1)
                                    resStruct[0].colNum=OVTG_CATEGORY
                                    DBD_SetDAGRes(dagVTG,resStruct,1)
                                    DBD_GetInNewFormat(dagVTG,dagRES)
                                    dagRES.GetColStr(tmpStr,0,0)
                                    if tmpStr[0]==VAL_OUTPUT[0]
                                       SetErrorLine(rec+1)
                                       SetErrorField(JDT1_VAT_AMOUNT)
                                       SetArrNum(ao_Arr1)
                                       Message(JTE_JDT_FORM_NUM,39,nil,OO_ERROR)
                                       return (ooInvalidObject)
                                    end

                                    dagJDT1.SetColStr(_T("M"),JDT1_IS_NET,rec)
                                    if dagJDT1.IsNullCol(JDT1_SYS_VAT_AMOUNT,rec)
                                       dagJDT1.GetColMoney(money,JDT1_VAT_AMOUNT,rec,DBM_NOT_ARRAY)
                                       if !money.IsZero()
                                          sysMoney = MONEY.new
                                          dagJDT1.GetColStr(dateStr,JDT1_REF_DATE,rec)
                                          GNTranslateToSysAmmount(money,localCurr,dateStr,sysMoney,bizEnv)
                                          MONEY_Round(sysMoney,RC_TAX,sysCurr,bizEnv)
                                          dagJDT1.SetColMoney(sysMoney,JDT1_SYS_VAT_AMOUNT,rec,DBM_NOT_ARRAY)
                                       end

                                    end

                                 else
                                    SetErrorLine(rec+1)
                                    SetErrorField(JDT1_VAT_AMOUNT)
                                    SetArrNum(ao_Arr1)
                                    Message(JTE_JDT_FORM_NUM,39,nil,OO_ERROR)
                                    return (ooInvalidObject)
                                 end

                              end

                           else
                              dagJDT1.SetColStr(VAL_NO,JDT1_IS_NET,rec)
                              if dagJDT1.IsNullCol(JDT1_DEBIT_CREDIT,rec)
                                 if bizEnv.IsVatPerLine()
                                    condStruct[0].colNum=OVTG_GROUP_CODE
                                    condStruct[0].operation=DBD_EQ
                                    _STR_strcpy(condStruct[0].condVal,vatGroup)
                                    DBD_SetDAGCond(dagVTG,condStruct,1)
                                    resStruct[0].colNum=OVTG_CATEGORY
                                    DBD_SetDAGRes(dagVTG,resStruct,1)
                                    DBD_GetInNewFormat(dagVTG,dagRES)
                                    dagRES.GetColStr(tmpStr,0,0)
                                    if tmpStr[0]!=VAL_OUTPUT[0]
                                       debitSide=true
                                    else
                                       debitSide=false
                                    end

                                 else
                                    dagJDT1.GetColStr(tmpStr,JDT1_TAX_POSTING_ACCOUNT,rec)
                                    if tmpStr[0]==_T("R")[0]
                                       debitSide=false
                                    else
                                       debitSide=true
                                    end

                                 end

                                 if debitSide
                                    dagJDT1.SetColStr(VAL_DEBIT,JDT1_DEBIT_CREDIT,rec)
                                 else
                                    dagJDT1.SetColStr(VAL_CREDIT,JDT1_DEBIT_CREDIT,rec)
                                 end

                              end

                           end

                        end

                     end

                  else
                     dagJDT1.GetColStr(vatGroup,bizEnv.IsVatPerLine() ? JDT1_VAT_GROUP : JDT1_TAX_CODE,rec)
                     if !_STR_IsSpacesStr(vatGroup)
                        Message(JTE_JDT_FORM_NUM,35,nil,OO_ERROR)
                        return ooErrNoMsg
                     end

                  end


                  (rec+=1;rec-2)
               end

            end

            ooErr=GetTaxAdaptor().CalcTaxWithManualUpdate()
            if ooErr
               return ooErr
            end

            debit.SetToZero()
            credit.SetToZero()
            DAG_GetCount(dagJDT1,numOfRecs)
            rec=0
            while (rec<numOfRecs) do
               dagJDT1.GetColMoney(money,JDT1_DEBIT,rec,DBM_NOT_ARRAY)
               MONEY_Add(debit,money)
               dagJDT1.GetColMoney(money,JDT1_CREDIT,rec,DBM_NOT_ARRAY)
               MONEY_Add(credit,money)

               (rec+=1;rec-2)
            end

            if MONEY_Cmp(debit,credit)
               MONEY_FromLong(0.02*MONEY_PERCISION_MUL,delta)
               dagJDT1.GetColStr(tmpStr,JDT1_VAT_LINE,numOfRecs-1)
               if tmpStr[0]==VAL_YES[0]
                  enforceBalance=false
                  MONEY_Sub(debit,credit)
                  if debit.IsNegative()
                     MONEY_Multiply(delta,-1,delta)
                     if debit>delta
                        enforceBalance=true
                     end

                  else
                     if debit<delta
                        enforceBalance=true
                     end

                  end

                  if enforceBalance
                     rec=numOfRecs-1
                     while (rec>=0) do
                        dagJDT1.GetColStr(vatGroup,bizEnv.IsVatPerLine() ? JDT1_VAT_GROUP : JDT1_TAX_CODE,rec)
                        if _STR_IsSpacesStr(vatGroup)
                           dagJDT1.GetColStr(tmpStr,JDT1_DEBIT_CREDIT,rec)
                           if tmpStr[0]==VAL_DEBIT[0]
                              dagJDT1.GetColMoney(money,JDT1_DEBIT,rec,DBM_NOT_ARRAY)
                              if !money.IsZero()
                                 MONEY_Sub(money,debit)
                                 dagJDT1.SetColMoney(money,JDT1_DEBIT,rec,DBM_NOT_ARRAY)
                                 break
                              end

                           else
                              dagJDT1.GetColMoney(money,JDT1_CREDIT,rec,DBM_NOT_ARRAY)
                              if !money.IsZero()
                                 MONEY_Add(money,debit)
                                 dagJDT1.SetColMoney(money,JDT1_CREDIT,rec,DBM_NOT_ARRAY)
                                 break
                              end

                           end

                        end


                        (rec-=1;rec+2)
                     end

                  end

               end

            end

            debit.SetToZero()
            credit.SetToZero()
            rec=0
            while (rec<numOfRecs) do
               dagJDT1.GetColMoney(money,JDT1_DEBIT,rec,DBM_NOT_ARRAY)
               MONEY_Add(debit,money)
               dagJDT1.GetColMoney(money,JDT1_CREDIT,rec,DBM_NOT_ARRAY)
               MONEY_Add(credit,money)

               (rec+=1;rec-2)
            end

            if MONEY_Cmp(debit,credit)==0
               debit.SetToZero()
               credit.SetToZero()
               rec=0
               while (rec<numOfRecs) do
                  dagJDT1.GetColMoney(money,JDT1_SYS_DEBIT,rec,DBM_NOT_ARRAY)
                  MONEY_Add(debit,money)
                  dagJDT1.GetColMoney(money,JDT1_SYS_CREDIT,rec,DBM_NOT_ARRAY)
                  MONEY_Add(credit,money)

                  (rec+=1;rec-2)
               end

               if MONEY_Cmp(debit,credit)
                  dagJDT1.GetColStr(tmpStr,JDT1_VAT_LINE,numOfRecs-1)
                  if tmpStr[0]==VAL_YES[0]||GetDataSource()!=VAL_OBSERVER_SOURCE
                     found=false
                     MONEY_Sub(debit,credit)
                     rec=numOfRecs-1
                     while (rec>=0) do
                        dagJDT1.GetColStr(vatGroup,bizEnv.IsVatPerLine() ? JDT1_VAT_GROUP : JDT1_TAX_CODE,rec)
                        if _STR_IsSpacesStr(vatGroup)
                           dagJDT1.GetColStr(tmpStr,JDT1_DEBIT_CREDIT,rec)
                           if tmpStr[0]==VAL_DEBIT[0]
                              dagJDT1.GetColMoney(money,JDT1_SYS_DEBIT,rec,DBM_NOT_ARRAY)
                              if !money.IsZero()
                                 MONEY_Sub(money,debit)
                                 dagJDT1.SetColMoney(money,JDT1_SYS_DEBIT,rec,DBM_NOT_ARRAY)
                                 found=true
                                 break
                              end

                           else
                              dagJDT1.GetColMoney(money,JDT1_SYS_CREDIT,rec,DBM_NOT_ARRAY)
                              if !money.IsZero()
                                 MONEY_Add(money,debit)
                                 dagJDT1.SetColMoney(money,JDT1_SYS_CREDIT,rec,DBM_NOT_ARRAY)
                                 found=true
                                 break
                              end

                           end

                        end


                        (rec-=1;rec+2)
                     end

                     if !found
                        rec=numOfRecs-1
                        while (rec>=0) do
                           dagJDT1.GetColStr(vatGroup,bizEnv.IsVatPerLine() ? JDT1_VAT_GROUP : JDT1_TAX_CODE,rec)
                           dagJDT1.GetColStr(tmpStr,JDT1_VAT_LINE,rec)
                           if !_STR_IsSpacesStr(vatGroup)&&tmpStr[0]!=VAL_YES[0]
                              dagJDT1.GetColStr(tmpStr,JDT1_DEBIT_CREDIT,rec)
                              if tmpStr[0]==VAL_DEBIT[0]
                                 dagJDT1.GetColMoney(money,JDT1_SYS_DEBIT,rec,DBM_NOT_ARRAY)
                                 if !money.IsZero()
                                    MONEY_Sub(money,debit)
                                    dagJDT1.SetColMoney(money,JDT1_SYS_DEBIT,rec,DBM_NOT_ARRAY)
                                    found=true
                                    break
                                 end

                              else
                                 dagJDT1.GetColMoney(money,JDT1_SYS_CREDIT,rec,DBM_NOT_ARRAY)
                                 if !money.IsZero()
                                    MONEY_Add(money,debit)
                                    dagJDT1.SetColMoney(money,JDT1_SYS_CREDIT,rec,DBM_NOT_ARRAY)
                                    found=true
                                    break
                                 end

                              end

                           end


                           (rec-=1;rec+2)
                        end

                     end

                  end

               end

            end

         else
            rec=0
            while (rec<numOfRecs) do
               dagJDT1.GetColStr(tmpStr,JDT1_VAT_GROUP,rec)
               if !_STR_IsSpacesStr(tmpStr)
                  if dagJDT1.IsNullCol(JDT1_DEBIT_CREDIT,rec)
                     if (dagJDT1.IsNullCol(JDT1_DEBIT,rec)&&!dagJDT1.IsNullCol(JDT1_CREDIT,rec))||(dagJDT1.IsNullCol(JDT1_SYS_DEBIT,rec)&&!dagJDT1.IsNullCol(JDT1_SYS_CREDIT,rec))
                        dagJDT1.SetColStr(VAL_CREDIT,JDT1_DEBIT_CREDIT,rec)
                     else
                        if (!dagJDT1.IsNullCol(JDT1_DEBIT,rec)&&dagJDT1.IsNullCol(JDT1_CREDIT,rec))||(!dagJDT1.IsNullCol(JDT1_SYS_DEBIT,rec)&&dagJDT1.IsNullCol(JDT1_SYS_CREDIT,rec))
                           dagJDT1.SetColStr(VAL_DEBIT,JDT1_DEBIT_CREDIT,rec)
                        else
                           debitSide=creditSide=false
                           rec2=0
                           while (rec2<numOfRecs) do
                              if rec2!=rec
                                 dagJDT1.GetColStr(actNum,JDT1_ACCT_NUM,rec2)
                                 dagJDT1.GetColStr(shortName,JDT1_SHORT_NAME,rec2)
                                 _STR_LRTrim(actNum)
                                 _STR_LRTrim(shortName)
                                 if _STR_stricmp(shortName,actNum)
                                    dagJDT1.GetColStr(tmpStr,JDT1_DEBIT_CREDIT,rec2)
                                    if tmpStr[0]==VAL_DEBIT[0]
                                       creditSide=true
                                       break
                                    end

                                    if tmpStr[0]==VAL_CREDIT[0]
                                       debitSide=true
                                       break
                                    end

                                 end

                              end


                              (rec2+=1;rec2-2)
                           end

                           if debitSide
                              dagJDT1.SetColStr(VAL_DEBIT,JDT1_DEBIT_CREDIT,rec)
                           else
                              if creditSide
                                 dagJDT1.SetColStr(VAL_CREDIT,JDT1_DEBIT_CREDIT,rec)
                              else
                                 _STR_GetStringResource(formatStr,JTE_JDT_FORM_NUM,23,GetEnv())
                                 _STR_sprintf(tmpStr,formatStr,rec+1)
                                 Message(-1,-1,tmpStr,OO_ERROR)
                                 return ooErrNoMsg
                              end

                           end

                        end

                     end

                  end

               end


               (rec+=1;rec-2)
            end

            ooErr=GetTaxAdaptor().ConvertJDTDagToTaxData()
            if ooErr
               return ooErr
            end

         end

      end

      return ooNoErr
   end

   def ComplateStampLine()
      trace("ComplateStampLine")
      ooErr=0




      tmpStr = []
      formatStr = []

      sysCurr = Currency.new=""
      localCurr = Currency.new=""
      currency = Currency.new=""
      dateStr = []
      =""
      stampTax = []

      actNum = []
      shortName = []

      method = []

      vatGroup = []

      tmpM = MONEY.new
      tmpM2 = MONEY.new
      money = MONEY.new
      vatPrcnt = MONEY.new
      minAmount = MONEY.new
      fixedAmount = MONEY.new
      frnAmnt = MONEY.new
      hundP = MONEY.new
      delta = MONEY.new
      debit = MONEY.new
      credit = MONEY.new
      baseDebit = MONEY.new
      baseCredit = MONEY.new
      zeroM = MONEY.new
      baseDebitSC = MONEY.new
      baseCreditSC = MONEY.new
      debitSC = MONEY.new
      creditSC = MONEY.new
      debMoneyFC = MONEY.new
      credMoneyFC = MONEY.new
      dagJDT = PDAG.new
      dagJDT1 = PDAG.new
      dagVTG = PDAG.new
      dagACT = PDAG.new
      dagRES = PDAG.new
      bizEnv = CBizEnv.new=GetEnv()
      found = Boolean.new
      multiCurr = Boolean.new
      debitSide = Boolean.new
      creditSide = Boolean.new
      condStruct = []

      resStruct = []

      dagJDT=GetDAG(JDT)
      dagJDT1=GetDAG(JDT,ao_Arr1)
      dagACT=GetDAG(ACT)
      dagVTG=GetDAG(VTG)
      dagJDT.GetColStr(stampTax,OJDT_STAMP_TAX,0)
      DAG_GetCount(dagJDT1,numOfRecs)
      if bizEnv.IsVatPerLine()
         dagJDT.GetColStr(tmpStr,OJDT_AUTO_VAT,0)
         if tmpStr[0]==VAL_YES[0]
            rec=0
            while (rec<numOfRecs) do
               dagJDT1.GetColStr(actNum,JDT1_ACCT_NUM,rec)
               dagJDT1.GetColStr(shortName,JDT1_SHORT_NAME,rec)
               if _STR_strcmp(actNum,shortName)==0
                  condStruct[0].colNum=OVTG_ACCOUNT
                  condStruct[0].operation=DBD_EQ
                  _STR_strcpy(condStruct[0].condVal,shortName)
                  condStruct[0].relationship=0
                  DBD_SetDAGCond(dagVTG,condStruct,1)
                  if DBD_Count(dagVTG,true)>0
                     Message(JTE_JDT_FORM_NUM,19,nil,OO_ERROR)
                     return ooErrNoMsg
                  end

                  dagJDT1.GetColStr(vatGroup,JDT1_VAT_GROUP,rec)
                  if !_STR_IsSpacesStr(vatGroup)
                     dagJDT1.GetColMoney(tmpM,JDT1_GROSS_VALUE,rec,DBM_NOT_ARRAY)
                     if tmpM.IsZero()
                        if dagJDT1.IsNullCol(JDT1_VAT_AMOUNT,rec)
                           dagJDT1.GetColMoney(money,JDT1_DEBIT,rec,DBM_NOT_ARRAY)
                           if money.IsZero()
                              dagJDT1.GetColMoney(money,JDT1_CREDIT,rec,DBM_NOT_ARRAY)
                           end

                           if !money.IsZero()
                              dagJDT1.GetColStr(dateStr,JDT1_REF_DATE,rec)
                              TZGetStampValue(dagJDT,vatGroup,dateStr,vatPrcnt,minAmount,method,fixedAmount)
                              if method[0]==VAL_RATE[0]
                                 MONEY_MulMMAndDivML(money,vatPrcnt,100*MONEY_PERCISION_MUL,money,false,bizEnv)


                                 MONEY_Round(money,RC_TAX,localCurr,bizEnv,tmpRoundingData)
                                 if !minAmount.IsZero()
                                    if MONEY_Cmp(money,minAmount)<0
                                       money=minAmount
                                    end

                                 end

                              else
                                 money=fixedAmount
                              end

                              dagJDT1.SetColMoney(money,JDT1_VAT_AMOUNT,rec,DBM_NOT_ARRAY)
                           end

                        end

                        if dagJDT1.IsNullCol(JDT1_SYS_VAT_AMOUNT,rec)
                           dagJDT1.GetColMoney(money,JDT1_VAT_AMOUNT,rec,DBM_NOT_ARRAY)
                           if !money.IsZero()
                              sysMoney = MONEY.new
                              dagJDT1.GetColStr(dateStr,JDT1_REF_DATE,rec)
                              GNTranslateToSysAmmount(money,localCurr,dateStr,sysMoney,bizEnv)


                              MONEY_Round(sysMoney,RC_TAX,sysCurr,bizEnv,tmpRoundingData)
                              dagJDT1.SetColMoney(sysMoney,JDT1_SYS_VAT_AMOUNT,rec,DBM_NOT_ARRAY)
                           end

                        end

                        dagJDT1.GetColMoney(money,JDT1_DEBIT,rec,DBM_NOT_ARRAY)
                        if money.IsZero()
                           dagJDT1.GetColMoney(money,JDT1_CREDIT,rec,DBM_NOT_ARRAY)
                        end

                        dagJDT1.GetColMoney(tmpM,JDT1_VAT_AMOUNT,rec,DBM_NOT_ARRAY)
                        MONEY_Add(money,tmpM)
                        MONEY_Round(money,RC_SUM,localCurr,bizEnv)
                        dagJDT1.SetColMoney(money,JDT1_GROSS_VALUE,rec,DBM_NOT_ARRAY)
                     else
                        debitSide=found=false
                        dagJDT1.GetColMoney(tmpM,JDT1_DEBIT,rec,DBM_NOT_ARRAY)
                        if tmpM.IsZero()
                           dagJDT1.GetColMoney(tmpM,JDT1_CREDIT,rec,DBM_NOT_ARRAY)
                           if !tmpM.IsZero()
                              found=true
                              debitSide=false
                           end

                        else
                           found=true
                           debitSide=true
                        end

                        if !found
                           condStruct[0].colNum=OVTG_GROUP_CODE
                           condStruct[0].operation=DBD_EQ
                           _STR_strcpy(condStruct[0].condVal,vatGroup)
                           DBD_SetDAGCond(dagVTG,condStruct,1)
                           resStruct[0].colNum=OVTG_CATEGORY
                           DBD_SetDAGRes(dagACT,resStruct,1)
                           DBD_GetInNewFormat(dagACT,dagRES)
                           dagRES.GetColStr(tmpStr,0,0)
                           if tmpStr[0]!=VAL_OUTPUT[0]
                              debitSide=true
                           else
                              debitSide=false
                           end

                        end

                        dagJDT1.GetColMoney(tmpM,JDT1_GROSS_VALUE,rec,DBM_NOT_ARRAY)
                        if !tmpM.IsZero()
                           dagJDT1.GetColStr(dateStr,JDT1_REF_DATE,rec)
                           TZGetStampValue(dagJDT,vatGroup,dateStr,vatPrcnt,minAmount,method,fixedAmount)
                           if method[0]==VAL_RATE[0]
                              if MONEY_Cmp(tmpM,minAmount)>0
                                 MONEY_FromLong(100*MONEY_PERCISION_MUL,hundP)
                                 MONEY_Add(hundP,vatPrcnt)
                                 MONEY_MulMLAndDivMM(tmpM,100*MONEY_PERCISION_MUL,hundP,tmpM,false,bizEnv)
                                 MONEY_Round(tmpM,RC_PRICE,currency,bizEnv)
                                 if debitSide
                                    dagJDT1.SetColMoney(tmpM,JDT1_DEBIT,rec,DBM_NOT_ARRAY)
                                 else
                                    dagJDT1.SetColMoney(tmpM,JDT1_CREDIT,rec,DBM_NOT_ARRAY)
                                 end

                                 tmpM2=tmpM
                                 dagJDT1.GetColMoney(tmpM,JDT1_GROSS_VALUE,rec,DBM_NOT_ARRAY)
                                 MONEY_Sub(tmpM,tmpM2)
                                 dagJDT1.SetColMoney(tmpM,JDT1_VAT_AMOUNT,rec,DBM_NOT_ARRAY)
                                 if GNCoinCmp(localCurr,sysCurr)!=0
                                    sysMoney = MONEY.new
                                    dagJDT1.GetColStr(dateStr,JDT1_REF_DATE,rec)
                                    GNTranslateToSysAmmount(tmpM,localCurr,dateStr,sysMoney,bizEnv)


                                    MONEY_Round(sysMoney,RC_TAX,sysCurr,bizEnv,tmpRoundingData)
                                    dagJDT1.SetColMoney(sysMoney,JDT1_SYS_VAT_AMOUNT,rec,DBM_NOT_ARRAY)
                                 else
                                    dagJDT1.SetColMoney(tmpM,JDT1_SYS_VAT_AMOUNT,rec,DBM_NOT_ARRAY)
                                 end

                              else
                                 if debitSide
                                    dagJDT1.SetColMoney(zeroM,JDT1_DEBIT,rec,DBM_NOT_ARRAY)
                                 else
                                    dagJDT1.SetColMoney(zeroM,JDT1_CREDIT,rec,DBM_NOT_ARRAY)
                                 end

                                 dagJDT1.SetColMoney(zeroM,JDT1_VAT_AMOUNT,rec,DBM_NOT_ARRAY)
                                 dagJDT1.SetColMoney(zeroM,JDT1_SYS_VAT_AMOUNT,rec,DBM_NOT_ARRAY)
                              end

                           else
                              if MONEY_Cmp(tmpM,fixedAmount)>0
                                 MONEY_Sub(tmpM,fixedAmount)
                                 MONEY_Round(tmpM,RC_PRICE,currency,bizEnv)
                                 if debitSide
                                    dagJDT1.SetColMoney(tmpM,JDT1_DEBIT,rec,DBM_NOT_ARRAY)
                                 else
                                    dagJDT1.SetColMoney(tmpM,JDT1_CREDIT,rec,DBM_NOT_ARRAY)
                                 end

                                 tmpM2=tmpM
                                 dagJDT1.GetColMoney(tmpM,JDT1_GROSS_VALUE,rec,DBM_NOT_ARRAY)
                                 MONEY_Sub(tmpM,tmpM2)
                                 dagJDT1.SetColMoney(tmpM,JDT1_VAT_AMOUNT,rec,DBM_NOT_ARRAY)
                                 if GNCoinCmp(localCurr,sysCurr)!=0
                                    sysMoney = MONEY.new
                                    dagJDT1.GetColStr(dateStr,JDT1_REF_DATE,rec)
                                    GNTranslateToSysAmmount(tmpM,localCurr,dateStr,sysMoney,bizEnv)


                                    MONEY_Round(sysMoney,RC_TAX,sysCurr,bizEnv,tmpRoundingData)
                                    dagJDT1.SetColMoney(sysMoney,JDT1_SYS_VAT_AMOUNT,rec,DBM_NOT_ARRAY)
                                 else
                                    dagJDT1.SetColMoney(tmpM,JDT1_SYS_VAT_AMOUNT,rec,DBM_NOT_ARRAY)
                                 end

                              else
                                 if debitSide
                                    dagJDT1.SetColMoney(zeroM,JDT1_DEBIT,rec,DBM_NOT_ARRAY)
                                 else
                                    dagJDT1.SetColMoney(zeroM,JDT1_CREDIT,rec,DBM_NOT_ARRAY)
                                 end

                                 dagJDT1.SetColMoney(zeroM,JDT1_VAT_AMOUNT,rec,DBM_NOT_ARRAY)
                                 dagJDT1.SetColMoney(zeroM,JDT1_SYS_VAT_AMOUNT,rec,DBM_NOT_ARRAY)
                              end

                           end

                        end

                     end

                  end

               else
                  dagJDT1.GetColStr(vatGroup,JDT1_VAT_GROUP,rec)
                  if !_STR_IsSpacesStr(vatGroup)
                     Message(JTE_JDT_FORM_NUM,35,nil,OO_ERROR)
                     return ooErrNoMsg
                  end

               end


               (rec+=1;rec-2)
            end

            dagJDT.GetColStr(dateStr,OJDT_REF_DATE,0)
            rec=0
            while (rec<numOfRecs) do
               dagJDT1.GetColStr(vatGroup,JDT1_VAT_GROUP,rec)
               if !_STR_IsSpacesStr(vatGroup)
                  dagJDT1.GetColStr(tmpStr,JDT1_VAT_LINE,rec)
                  if tmpStr[0]==VAL_NO[0]
                     found=false
                     DAG_GetCount(dagJDT1,numOfRecs2)
                     rec2=0
                     while (rec2<numOfRecs2) do
                        dagJDT1.GetColStr(tmpStr,JDT1_VAT_LINE,rec2)
                        if tmpStr[0]==VAL_YES[0]
                           dagJDT1.GetColStr(tmpStr,JDT1_VAT_GROUP,rec2)
                           if _STR_strcmp(tmpStr,vatGroup)==0
                              found=true
                           end

                        end


                        (rec2+=1;rec2-2)
                     end

                     if !found
                        ooErr=DAG_SetSize(dagJDT1,numOfRecs2+1,dbmKeepData)
                        if ooErr
                           return ooErr
                        end

                        dagJDT1.SetColStr(VAL_YES,JDT1_VAT_LINE,numOfRecs2)
                        dagJDT1.SetColStr(vatGroup,JDT1_VAT_GROUP,numOfRecs2)
                        condStruct[0].colNum=OVTG_GROUP_CODE
                        condStruct[0].operation=DBD_EQ
                        _STR_strcpy(condStruct[0].condVal,vatGroup)
                        condStruct[0].relationship=0
                        DBD_SetDAGCond(dagVTG,condStruct,1)
                        resStruct[0].colNum=OVTG_ACCOUNT
                        DBD_SetDAGRes(dagVTG,resStruct,1)
                        ooErr=DBD_GetInNewFormat(dagVTG,dagRES)
                        if ooErr
                           return ooErr
                        end

                        dagJDT1.CopyColumn(dagRES,JDT1_SHORT_NAME,numOfRecs2,0,0)
                        dagJDT1.CopyColumn(dagRES,JDT1_ACCT_NUM,numOfRecs2,0,0)
                     end

                  end

               end


               (rec+=1;rec-2)
            end

            DAG_GetCount(dagJDT1,numOfRecs)
            rec=0
            while (rec<numOfRecs) do
               dagJDT1.GetColStr(tmpStr,JDT1_VAT_LINE,rec)
               if tmpStr[0]==VAL_YES[0]
                  baseDebit.SetToZero()
                  baseCredit.SetToZero()
                  debit.SetToZero()
                  credit.SetToZero()
                  debMoneyFC.SetToZero()
                  credMoneyFC.SetToZero()
                  baseDebitSC.SetToZero()
                  baseCreditSC.SetToZero()
                  debitSC.SetToZero()
                  creditSC.SetToZero()
                  currency[0]=0
                  multiCurr=false
                  dagJDT1.GetColStr(vatGroup,JDT1_VAT_GROUP,rec)
                  rec2=0
                  while (rec2<numOfRecs) do
                     dagJDT1.GetColStr(tmpStr,JDT1_VAT_LINE,rec2)
                     if tmpStr[0]==VAL_NO[0]
                        dagJDT1.GetColStr(tmpStr,JDT1_VAT_GROUP,rec2)
                        if _STR_strcmp(tmpStr,vatGroup)==0
                           dagJDT1.GetColMoney(money,JDT1_DEBIT,rec2,DBM_NOT_ARRAY)
                           if !money.IsZero()
                              MONEY_Add(baseDebit,money)
                              dagJDT1.GetColMoney(money,JDT1_VAT_AMOUNT,rec2,DBM_NOT_ARRAY)
                              MONEY_Add(debit,money)
                              dagJDT1.GetColMoney(money,JDT1_SYS_DEBIT,rec2,DBM_NOT_ARRAY)
                              MONEY_Add(baseDebitSC,money)
                              dagJDT1.GetColMoney(money,JDT1_SYS_VAT_AMOUNT,rec2,DBM_NOT_ARRAY)
                              MONEY_Add(debitSC,money)
                              dagJDT1.GetColMoney(money,JDT1_FC_DEBIT,rec2,DBM_NOT_ARRAY)
                              if !money.IsZero()
                                 dagJDT1.GetColStr(dateStr,JDT1_REF_DATE,rec2)
                                 bizEnv.GetVatPercent(vatGroup,bizEnv.GetDateForTaxRateDetermination(dagJDT1,rec2),vatPrcnt)
                                 MONEY_MulMMAndDivML(money,vatPrcnt,100*MONEY_PERCISION_MUL,money,false,bizEnv)


                                 MONEY_Round(money,RC_TAX,localCurr,bizEnv,tmpRoundingData)
                                 MONEY_Add(debMoneyFC,money)
                                 dagJDT1.GetColStr(tmpStr,JDT1_FC_CURRENCY,rec2)
                                 _STR_LRTrim(tmpStr)
                                 if !currency[0]
                                    _STR_strcpy(currency,tmpStr)
                                 else
                                    if GNCoinCmp(currency,tmpStr)
                                       multiCurr=true
                                    end

                                 end

                              end

                           else
                              dagJDT1.GetColMoney(money,JDT1_CREDIT,rec2,DBM_NOT_ARRAY)
                              if !money.IsZero()
                                 MONEY_Add(baseCredit,money)
                                 dagJDT1.GetColMoney(money,JDT1_VAT_AMOUNT,rec2,DBM_NOT_ARRAY)
                                 MONEY_Add(credit,money)
                                 dagJDT1.GetColMoney(money,JDT1_SYS_CREDIT,rec2,DBM_NOT_ARRAY)
                                 MONEY_Add(baseCreditSC,money)
                                 dagJDT1.GetColMoney(money,JDT1_SYS_VAT_AMOUNT,rec2,DBM_NOT_ARRAY)
                                 MONEY_Add(creditSC,money)
                              end

                              dagJDT1.GetColMoney(money,JDT1_FC_CREDIT,rec2,DBM_NOT_ARRAY)
                              if !money.IsZero()
                                 dagJDT1.GetColStr(dateStr,JDT1_REF_DATE,rec2)
                                 bizEnv.GetVatPercent(vatGroup,bizEnv.GetDateForTaxRateDetermination(dagJDT1,rec2),vatPrcnt)
                                 MONEY_MulMMAndDivML(money,vatPrcnt,100*MONEY_PERCISION_MUL,money,false,bizEnv)


                                 MONEY_Round(money,RC_TAX,localCurr,bizEnv,tmpRoundingData)
                                 MONEY_Add(credMoneyFC,money)
                                 dagJDT1.GetColStr(tmpStr,JDT1_FC_CURRENCY,rec2)
                                 _STR_LRTrim(tmpStr)
                                 if !currency[0]
                                    _STR_strcpy(currency,tmpStr)
                                 else
                                    if GNCoinCmp(currency,tmpStr)
                                       multiCurr=true
                                    end

                                 end

                              end

                           end

                        end

                     end


                     (rec2+=1;rec2-2)
                  end

                  MONEY_Round(debit,RC_SUM,localCurr,bizEnv)
                  MONEY_Round(credit,RC_SUM,localCurr,bizEnv)
                  MONEY_Round(debitSC,RC_SUM,sysCurr,bizEnv)
                  MONEY_Round(creditSC,RC_SUM,sysCurr,bizEnv)
                  MONEY_Round(debMoneyFC,RC_SUM,currency,bizEnv)
                  MONEY_Round(credMoneyFC,RC_SUM,currency,bizEnv)
                  if !debit.IsZero()||!baseDebit.IsZero()
                     if credit.IsZero()&&baseCredit.IsZero()
                        dagJDT1.SetColStr(VAL_DEBIT,JDT1_DEBIT_CREDIT,rec)
                        dagJDT1.SetColMoney(debit,JDT1_DEBIT,rec,DBM_NOT_ARRAY)
                        dagJDT1.SetColMoney(baseDebit,JDT1_BASE_SUM,rec,DBM_NOT_ARRAY)
                        dagJDT1.SetColMoney(debitSC,JDT1_SYS_DEBIT,rec,DBM_NOT_ARRAY)
                        dagJDT1.SetColMoney(baseDebitSC,JDT1_SYS_BASE_SUM,rec,DBM_NOT_ARRAY)
                        if currency[0]&&!multiCurr
                           dagJDT1.SetColMoney(debMoneyFC,JDT1_FC_DEBIT,rec,DBM_NOT_ARRAY)
                           dagJDT1.SetColStr(currency,JDT1_FC_CURRENCY,rec)
                        end

                     else
                        if MONEY_Cmp(debit,credit)>0
                           dagJDT1.SetColStr(VAL_DEBIT,JDT1_DEBIT_CREDIT,rec)
                           money=debit
                           MONEY_Sub(money,credit)
                           dagJDT1.SetColMoney(money,JDT1_DEBIT,rec,DBM_NOT_ARRAY)
                           money=baseDebit
                           MONEY_Sub(money,baseCredit)
                           dagJDT1.SetColMoney(money,JDT1_BASE_SUM,rec,DBM_NOT_ARRAY)
                           money=debitSC
                           MONEY_Sub(money,creditSC)
                           dagJDT1.SetColMoney(money,JDT1_SYS_DEBIT,rec,DBM_NOT_ARRAY)
                           money=baseDebitSC
                           MONEY_Sub(money,baseCreditSC)
                           dagJDT1.SetColMoney(money,JDT1_SYS_BASE_SUM,rec,DBM_NOT_ARRAY)
                           if currency[0]&&!multiCurr
                              money=debit
                              MONEY_Sub(money,credit)
                              ooErr=GNLocalToForeignRate(money,currency,dateStr,0.0,frnAmnt,GetEnv())
                              if ooErr
                                 return (ooErr)
                              end

                              dagJDT1.SetColMoney(frnAmnt,JDT1_FC_DEBIT,rec,DBM_NOT_ARRAY)
                              dagJDT1.SetColStr(currency,JDT1_FC_CURRENCY,rec)
                           end

                        else
                           dagJDT1.SetColStr(VAL_CREDIT,JDT1_DEBIT_CREDIT,rec)
                           money=credit
                           MONEY_Sub(money,debit)
                           dagJDT1.SetColMoney(money,JDT1_CREDIT,rec,DBM_NOT_ARRAY)
                           money=baseCredit
                           MONEY_Sub(money,baseDebit)
                           dagJDT1.SetColMoney(money,JDT1_BASE_SUM,rec,DBM_NOT_ARRAY)
                           money=creditSC
                           MONEY_Sub(money,debitSC)
                           dagJDT1.SetColMoney(money,JDT1_SYS_CREDIT,rec,DBM_NOT_ARRAY)
                           money=baseCreditSC
                           MONEY_Sub(money,baseDebitSC)
                           dagJDT1.SetColMoney(money,JDT1_SYS_BASE_SUM,rec,DBM_NOT_ARRAY)
                           if currency[0]&&!multiCurr
                              money=credit
                              MONEY_Sub(money,debit)
                              ooErr=GNLocalToForeignRate(money,currency,dateStr,0.0,frnAmnt,GetEnv())
                              if ooErr
                                 return (ooErr)
                              end

                              dagJDT1.SetColMoney(frnAmnt,JDT1_FC_CREDIT,rec,DBM_NOT_ARRAY)
                              dagJDT1.SetColStr(currency,JDT1_FC_CURRENCY,rec)
                           end

                        end

                     end

                  else
                     if !credit.IsZero()||!baseCredit.IsZero()
                        dagJDT1.SetColStr(VAL_CREDIT,JDT1_DEBIT_CREDIT,rec)
                        dagJDT1.SetColMoney(credit,JDT1_CREDIT,rec,DBM_NOT_ARRAY)
                        dagJDT1.SetColMoney(baseCredit,JDT1_BASE_SUM,rec,DBM_NOT_ARRAY)
                        dagJDT1.SetColMoney(creditSC,JDT1_SYS_CREDIT,rec,DBM_NOT_ARRAY)
                        dagJDT1.SetColMoney(baseCreditSC,JDT1_SYS_BASE_SUM,rec,DBM_NOT_ARRAY)
                        if currency[0]&&!multiCurr
                           dagJDT1.SetColMoney(credMoneyFC,JDT1_FC_CREDIT,rec,DBM_NOT_ARRAY)
                           dagJDT1.SetColStr(currency,JDT1_FC_CURRENCY,rec)
                        end

                     end

                  end

               end


               (rec+=1;rec-2)
            end

            debit.SetToZero()
            credit.SetToZero()
            rec=0
            while (rec<numOfRecs) do
               dagJDT1.GetColMoney(money,JDT1_DEBIT,rec,DBM_NOT_ARRAY)
               MONEY_Add(debit,money)
               dagJDT1.GetColMoney(money,JDT1_CREDIT,rec,DBM_NOT_ARRAY)
               MONEY_Add(credit,money)

               (rec+=1;rec-2)
            end

            if MONEY_Cmp(debit,credit)
               MONEY_FromLong(0.02*MONEY_PERCISION_MUL,delta)
               dagJDT1.GetColStr(tmpStr,JDT1_VAT_LINE,numOfRecs-1)
               if tmpStr[0]==VAL_YES[0]
                  enforceBalance=false
                  MONEY_Sub(debit,credit)
                  if debit.IsNegative()
                     MONEY_Multiply(delta,-1,delta)
                     if debit>delta
                        enforceBalance=true
                     end

                  else
                     if debit<delta
                        enforceBalance=true
                     end

                  end

                  if enforceBalance
                     rec=numOfRecs-1
                     while (rec>=0) do
                        dagJDT1.GetColStr(vatGroup,JDT1_VAT_GROUP,rec)
                        if _STR_IsSpacesStr(vatGroup)
                           dagJDT1.GetColStr(tmpStr,JDT1_DEBIT_CREDIT,rec)
                           if tmpStr[0]==VAL_DEBIT[0]
                              dagJDT1.GetColMoney(money,JDT1_DEBIT,rec,DBM_NOT_ARRAY)
                              if !money.IsZero()
                                 MONEY_Sub(money,debit)
                                 dagJDT1.SetColMoney(money,JDT1_DEBIT,rec,DBM_NOT_ARRAY)
                                 break
                              end

                           else
                              dagJDT1.GetColMoney(money,JDT1_CREDIT,rec,DBM_NOT_ARRAY)
                              if !money.IsZero()
                                 MONEY_Add(money,debit)
                                 dagJDT1.SetColMoney(money,JDT1_CREDIT,rec,DBM_NOT_ARRAY)
                                 break
                              end

                           end

                        end


                        (rec-=1;rec+2)
                     end

                  end

               end

            end

            debit.SetToZero()
            credit.SetToZero()
            rec=0
            while (rec<numOfRecs) do
               dagJDT1.GetColMoney(money,JDT1_DEBIT,rec,DBM_NOT_ARRAY)
               MONEY_Add(debit,money)
               dagJDT1.GetColMoney(money,JDT1_CREDIT,rec,DBM_NOT_ARRAY)
               MONEY_Add(credit,money)

               (rec+=1;rec-2)
            end

            if MONEY_Cmp(debit,credit)==0
               debit.SetToZero()
               credit.SetToZero()
               rec=0
               while (rec<numOfRecs) do
                  dagJDT1.GetColMoney(money,JDT1_SYS_DEBIT,rec,DBM_NOT_ARRAY)
                  MONEY_Add(debit,money)
                  dagJDT1.GetColMoney(money,JDT1_SYS_CREDIT,rec,DBM_NOT_ARRAY)
                  MONEY_Add(credit,money)

                  (rec+=1;rec-2)
               end

               if MONEY_Cmp(debit,credit)
                  dagJDT1.GetColStr(tmpStr,JDT1_VAT_LINE,numOfRecs-1)
                  if tmpStr[0]==VAL_YES[0]
                     MONEY_Sub(debit,credit)
                     rec=numOfRecs-1
                     while (rec>=0) do
                        dagJDT1.GetColStr(vatGroup,JDT1_VAT_GROUP,rec)
                        if _STR_IsSpacesStr(vatGroup)
                           dagJDT1.GetColStr(tmpStr,JDT1_DEBIT_CREDIT,rec)
                           if tmpStr[0]==VAL_DEBIT[0]
                              dagJDT1.GetColMoney(money,JDT1_SYS_DEBIT,rec,DBM_NOT_ARRAY)
                              if !money.IsZero()
                                 MONEY_Sub(money,debit)
                                 dagJDT1.SetColMoney(money,JDT1_SYS_DEBIT,rec,DBM_NOT_ARRAY)
                                 break
                              end

                           else
                              dagJDT1.GetColMoney(money,JDT1_SYS_CREDIT,rec,DBM_NOT_ARRAY)
                              if !money.IsZero()
                                 MONEY_Add(money,debit)
                                 dagJDT1.SetColMoney(money,JDT1_SYS_CREDIT,rec,DBM_NOT_ARRAY)
                                 break
                              end

                           end

                        end


                        (rec-=1;rec+2)
                     end

                  end

               end

            end

         else
            rec=0
            while (rec<numOfRecs) do
               dagJDT1.GetColStr(tmpStr,JDT1_VAT_GROUP,rec)
               if !_STR_IsSpacesStr(tmpStr)
                  if dagJDT1.IsNullCol(JDT1_DEBIT_CREDIT,rec)
                     dagJDT1.SetColStr(VAL_YES,JDT1_VAT_LINE,rec)
                     if (dagJDT1.IsNullCol(JDT1_DEBIT,rec)&&!dagJDT1.IsNullCol(JDT1_CREDIT,rec))||(dagJDT1.IsNullCol(JDT1_SYS_DEBIT,rec)&&!dagJDT1.IsNullCol(JDT1_SYS_CREDIT,rec))
                        dagJDT1.SetColStr(VAL_CREDIT,JDT1_DEBIT_CREDIT,rec)
                     else
                        if (!dagJDT1.IsNullCol(JDT1_DEBIT,rec)&&dagJDT1.IsNullCol(JDT1_CREDIT,rec))||(!dagJDT1.IsNullCol(JDT1_SYS_DEBIT,rec)&&dagJDT1.IsNullCol(JDT1_SYS_CREDIT,rec))
                           dagJDT1.SetColStr(VAL_DEBIT,JDT1_DEBIT_CREDIT,rec)
                        else
                           debitSide=creditSide=false
                           rec2=0
                           while (rec2<numOfRecs) do
                              if rec2!=rec
                                 dagJDT1.GetColStr(actNum,JDT1_ACCT_NUM,rec2)
                                 dagJDT1.GetColStr(shortName,JDT1_SHORT_NAME,rec2)
                                 _STR_LRTrim(actNum)
                                 _STR_LRTrim(shortName)
                                 if _STR_stricmp(shortName,actNum)
                                    dagJDT1.GetColStr(tmpStr,JDT1_DEBIT_CREDIT,rec2)
                                    if tmpStr[0]==VAL_DEBIT[0]
                                       creditSide=true
                                       break
                                    end

                                    if tmpStr[0]==VAL_CREDIT[0]
                                       debitSide=true
                                       break
                                    end

                                 end

                              end


                              (rec2+=1;rec2-2)
                           end

                           if debitSide
                              dagJDT1.SetColStr(VAL_DEBIT,JDT1_DEBIT_CREDIT,rec)
                           else
                              if creditSide
                                 dagJDT1.SetColStr(VAL_CREDIT,JDT1_DEBIT_CREDIT,rec)
                              else
                                 _STR_GetStringResource(formatStr,JTE_JDT_FORM_NUM,23,GetEnv())
                                 _STR_sprintf(tmpStr,formatStr,rec+1)
                                 Message(-1,-1,tmpStr,OO_ERROR)
                                 return ooErrNoMsg
                              end

                           end

                        end

                     end

                  end

               end


               (rec+=1;rec-2)
            end

         end

      end

      return ooNoErr
   end

   def ValidateReportEU()
      trace("ValidateReportEU")
      bizEnv = CBizEnv.new=GetEnv()
      if !bizEnv.IsLocalSettingsFlag(lsf_IsEC)
         return ooNoErr
      end

      dagJDT = PDAG.new=GetDAG()
      sboErr=ooNoErr
      reportEUStr = SBOString.new
      dagJDT.GetColStr(reportEUStr,OJDT_REPORT_EU)
      if reportEUStr.Compare(VAL_YES)
         return ooNoErr
      end

      sboErr=@validateVatReportTransType()
      if sboErr==0
         numOfBPfound=0
         validateFedTaxId=bizEnv.IsVatPerLine()
         sboErr=GetNumOfBPRecords(numOfBPfound,validateFedTaxId)
         if sboErr
            return sboErr
         end

         if numOfBPfound!=1
            Message(GO_OBJ_ERROR_MSGS(JDT),12,nil,OO_ERROR)
            sboErr=-10
         end

      end

      if sboErr!=0
         SetErrorField(-1)
         SetErrorField(OJDT_REPORT_EU)
      end

      return sboErr
   end

   def ValidateReport347()
      trace("ValidateReport347")
      bizEnv = CBizEnv.new=GetEnv()
      if !bizEnv.IsCurrentLocalSettings(SPAIN_SETTINGS)
         return ooNoErr
      end

      dagJDT = PDAG.new=GetDAG()
      sboErr=ooNoErr
      report347Str = SBOString.new
      dagJDT.GetColStr(report347Str,OJDT_REPORT_347)
      if report347Str.Compare(VAL_YES)
         return ooNoErr
      end

      sboErr=@validateVatReportTransType()
      if sboErr==0
         numOfBPfound=0
         sboErr=GetNumOfBPRecords(numOfBPfound,false)
         if sboErr
            return sboErr
         end

         if numOfBPfound!=1
            Message(GO_OBJ_ERROR_MSGS(JDT),13,nil,OO_ERROR)
            sboErr=-10
         end

      end

      if sboErr!=0
         SetErrorField(-1)
         SetErrorField(OJDT_REPORT_347)
      end

      return sboErr
   end

   def ValidateVatReportTransType()
      trace("ValidateVatReportTransType")
      sboErr=ooNoErr
      dagJDT = PDAG.new=GetDAG()
      if IsManualJE(dagJDT)==false
         Message(GO_OBJ_ERROR_MSGS(JDT),14,nil,OO_ERROR)
         sboErr=-10
      end

      return sboErr
   end

   def ValidateBPLNumberingSeries()
      env = CBizEnv.new=GetEnv()
      if !VF_MultiBranch_EnabledInOADM(env)
         return 0
      end

      series=GetSeries()
      if series<=0
         GetDAG().GetColLong(series,OJDT_SERIES)
      end

      bPLIds = SBOLongSet.new
      dagJDT1 = PDAG.new=GetArrayDAG(ao_Arr1)
      dag1Size=dagJDT1.GetRealSize(dbmDataBuffer)
      dag1Row=0
      while (dag1Row<dag1Size) do
         bPLId=dagJDT1.GetColStr(JDT1_BPL_ID,dag1Row,coreSystemDefault).strtol()
         bPLIds.insert(BPLId)

         (dag1Row+=1;dag1Row-2)
      end

      it = SBOLongSet::iterator.new=bPLIds.begin()
      while (it!=bPLIds.end()) do
         tmpNum = SBOString.new=SBOString(series)+SBOString(SUB_TYPE_NONE)
         if !CBusinessPlaceObject.IsBPLIdAssignedToObject(env,it,NNM,tmpNum)
            SetArrNum(ao_Main)
            SetErrorLine(-1)
            SetErrorField(OJDT_SERIES)
            dagOBJ = APCompanyDAG.new
            strObjCode = SBOString.new
            OpenDAG(dagOBJ,NNM,ao_Arr1)
            if dagOBJ
               dagOBJ.GetByKey(SBOString(series))
            end

            if dagOBJ&&dagOBJ.GetRealSizedbmDataBuffer>0
               strObjCode=dagOBJ.GetColStrAndTrim(NNM1_NAME,0,coreSystemDefault)
            end

            Message(CBusinessPlaceObject::ERROR_STRING_LIST_ID,CBusinessPlaceObject::ERRMSG_BPL_NOT_ASSIGNED_TO_SERIES_STR,strObjCode,OO_ERROR)
            return ooInvalidObject
         end


         (it+=1;it-2)
      end

      return 0
   end

   def IsBalancedByBPL()
      env = CBizEnv.new=GetEnv()
      if !VF_MultiBranch_EnabledInOADM(env)
         return 0
      end



      debits = std::map.new
      credits = std::map.new
      dagJDT1 = PDAG.new=GetArrayDAG(ao_Arr1)
      dag1Size=dagJDT1.GetRealSize(dbmDataBuffer)
      rec=0
      while (rec<dag1Size) do
         bPLId=-1
         amount = CAllCurrencySums.new
         dagJDT1.GetColLong(BPLId,JDT1_BPL_ID,rec)
         if debits.find(BPLId)==debits.end()
            debits[BPLId]=CAllCurrencySums()
         end

         if credits.find(BPLId)==credits.end()
            credits[BPLId]=CAllCurrencySums()
         end

         amount.FromDAG(dagJDT1,rec,JDT1_DEBIT,JDT1_FC_DEBIT,JDT1_SYS_DEBIT)
         debits[BPLId]+=amount
         amount.FromDAG(dagJDT1,rec,JDT1_CREDIT,JDT1_FC_CREDIT,JDT1_SYS_CREDIT)
         credits[BPLId]+=amount

         (rec+=1;rec-2)
      end

      itDeb = SUMMED_BALANCE::iterator.new=debits.begin()
      while (itDeb!=debits.end()) do
         itCred = SUMMED_BALANCE::iterator.new=credits.find(itDeb.first)
         if itCred==credits.end()
            CMessagesManager.GetHandle().Message(_132_APP_MSG_FIN_UNBALANCED_TRANS_FOR_BRANCH,EMPTY_STR,self)
            return ooInvalidObject
         end

         if itCred.second!=itDeb.second
            CMessagesManager.GetHandle().Message(_132_APP_MSG_FIN_UNBALANCED_TRANS_FOR_BRANCH,EMPTY_STR,self)
            return ooInvalidObject
         end


         (itDeb+=1;itDeb-2)
      end

      return 0
   end

   def UpgradeWorkOrderStep1()
      ooErr=ooNoErr
      cond = []
      join = []

      updateStruct = []

      tables = []

      dagJDT = PDAG.new
      subQueryParams = []
      subQueryParams2 = []

      subcond1 = []
      subcond2 = []

      subres1 = []
      subres2 = []

      subtables1 = []
      subtables2 = []

      dagJDT=GetDAG()
      tables[0].tableCode=self.GetEnv().ObjectToTable(JDT)
      tables[1].tableCode=self.GetEnv().ObjectToTable(WKO)
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
      join[1].condVal=68
      join[1].operation=DBD_EQ
      join[1].relationship=0
      tables[1].joinConds=join[0]
      tables[1].doJoin=true
      tables[1].joinedToTable=0
      tables[1].numOfConds=2
      tables[1].outerJoin=false
      updateStruct[0].colNum=OJDT_CREATED_BY
      updateStruct[0].srcColNum=OWKO_ORDER_NUM
      updateStruct[0].SetUpdateColSource(DBD_UpdStruct::ucs_UseRes)
      pResCol = DBD_ResColumns.new=updateStruct[0].GetResObject().AddResCol()
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
      subtables1[0].tableCode=self.GetEnv().ObjectToTable(WKO)
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
      subtables2[0].tableCode=self.GetEnv().ObjectToTable(JDT)
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
      subcond2[1].condVal=68
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
      cond = []
      join = []

      updateStruct = []

      tables = []

      dagJDT1 = PDAG.new
      dagJDT1=GetDAG(JDT,ao_Arr1)
      tables[0].tableCode=self.GetEnv().ObjectToTable(JDT,ao_Arr1)
      tables[1].tableCode=self.GetEnv().ObjectToTable(JDT)
      join[0].colNum=JDT1_TRANS_ABS
      join[0].tableIndex=0
      join[0].compareCols=true
      join[0].compColNum=OJDT_JDT_NUM
      join[0].compTableIndex=1
      join[0].operation=DBD_EQ
      join[0].relationship=0
      tables[1].joinConds=join[0]
      tables[1].doJoin=true
      tables[1].joinedToTable=0
      tables[1].numOfConds=1
      tables[1].outerJoin=false
      updateStruct[0].colNum=JDT1_CREATED_BY
      updateStruct[0].srcColNum=OJDT_CREATED_BY
      updateStruct[0].SetUpdateColSource(DBD_UpdStruct::ucs_UseRes)
      pResCol = DBD_ResColumns.new=updateStruct[0].GetResObject().AddResCol()
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
      cond[1].condVal=68
      cond[1].relationship=0
      DBD_SetDAGCond(dagJDT1,cond,2)
      DBD_SetDAGUpd(dagJDT1,updateStruct,1)
      DBD_SetTablesList(dagJDT1,tables,2)
      ooErr=DBD_UpdateCols(dagJDT1)
      return ooErr
   end

   def UpgradeWorkOrderStep3()
      ooErr=ooNoErr
      cond = []
      join = []

      updateStruct = []

      tables = []

      dagJDT = PDAG.new
      subQueryParams = []

      subcond1 = []

      subres1 = []

      subtables1 = []

      dagJDT=GetDAG()
      tables[0].tableCode=self.GetEnv().ObjectToTable(JDT)
      tables[1].tableCode=self.GetEnv().ObjectToTable(INM)
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
      join[1].condVal=68
      join[1].operation=DBD_EQ
      join[1].relationship=DBD_AND
      join[2].colNum=OINM_TYPE
      join[2].tableIndex=1
      join[2].compareCols=false
      join[2].condVal=68
      join[2].operation=DBD_EQ
      join[2].relationship=0
      tables[1].joinConds=join[0]
      tables[1].doJoin=true
      tables[1].joinedToTable=0
      tables[1].numOfConds=3
      tables[1].outerJoin=false
      updateStruct[0].colNum=OJDT_CREATE_DATE
      updateStruct[0].srcColNum=OINM_CREATE_DATE
      updateStruct[0].SetUpdateColSource(DBD_UpdStruct::ucs_UseRes)
      pResCol = DBD_ResColumns.new=updateStruct[0].GetResObject().AddResCol()
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
      subtables1[0].tableCode=self.GetEnv().ObjectToTable(INM)
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
      cond = []
      join = []

      updateStruct = []

      tables = []

      dagINM = PDAG.new
      dagINM=GetDAG(INM)
      tables[0].tableCode=self.GetEnv().ObjectToTable(INM)
      tables[1].tableCode=self.GetEnv().ObjectToTable(JDT)
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
      join[1].condVal=68
      join[1].operation=DBD_EQ
      join[1].relationship=DBD_AND
      join[2].colNum=OINM_TYPE
      join[2].tableIndex=0
      join[2].compareCols=false
      join[2].condVal=68
      join[2].operation=DBD_EQ
      join[2].relationship=0
      tables[1].joinConds=join[0]
      tables[1].doJoin=true
      tables[1].joinedToTable=0
      tables[1].numOfConds=3
      tables[1].outerJoin=false
      updateStruct[0].colNum=OINM_CREATE_DATE
      updateStruct[0].srcColNum=OJDT_CREATE_DATE
      updateStruct[0].SetUpdateColSource(DBD_UpdStruct::ucs_UseRes)
      pResCol = DBD_ResColumns.new=updateStruct[0].GetResObject().AddResCol()
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
      cond = []
      cond2 = []
      joinCondition1 = []
      joinCondition2 = []

      updateStruct = []

      tables = []
      tables2 = []

      dagJDT = PDAG.new
      dagRes = PDAG.new
      res = []


      dagJDT=GetDAG()
      tables[0].tableCode=self.GetEnv().ObjectToTable(INM)
      tables[1].tableCode=self.GetEnv().ObjectToTable(IPF)
      tables[2].tableCode=self.GetEnv().ObjectToTable(JDT)
      joinCondition1[0].colNum=OINM_TYPE
      joinCondition1[0].tableIndex=0
      joinCondition1[0].compareCols=false
      joinCondition1[0].condVal=69
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
      joinCondition2[0].condVal=69
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
      res[0].colNum=OJDT_CREATE_DATE
      res[0].tableIndex=2
      res[1].colNum=OINM_CREATE_DATE
      res[1].tableIndex=0
      res[2].colNum=OJDT_JDT_NUM
      res[2].tableIndex=2
      res[3].colNum=OINM_NUM
      res[3].tableIndex=0
      cond[0].colNum=OJDT_CREATE_DATE
      cond[0].tableIndex=2
      cond[0].compareCols=false
      cond[0].operation=DBD_IS_NULL
      cond[0].relationship=0
      DBD_SetDAGCond(dagJDT,cond,1)
      DBD_SetDAGRes(dagJDT,res,4)
      DBD_SetTablesList(dagJDT,tables,3)
      ooErr=DBD_GetInNewFormat(dagJDT,dagRes)
      if ooErr
         if ooErr==-2028
            return ooNoErr
         else
            return ooErr
         end

      end

      numOfRecords=dagRes.GetRecordCount()
      tables2[0].tableCode=self.GetEnv().ObjectToTable(JDT)
      i=0
      while (i<numOfRecords) do
         updateStruct[0].colNum=OJDT_CREATE_DATE
         dagRes.GetColStr(updateStruct[0].updateVal,1,i)
         cond2[0].colNum=OJDT_JDT_NUM
         cond2[0].tableIndex=0
         cond2[0].compareCols=false
         cond2[0].operation=DBD_EQ
         dagRes.GetColStr(cond2[0].condVal,2,i)
         cond2[0].relationship=0
         DBD_SetDAGUpd(dagJDT,updateStruct,1)
         DBD_SetTablesList(dagJDT,tables2,1)
         DBD_SetDAGCond(dagJDT,cond2,1)
         ooErr=DBD_UpdateCols(dagJDT)
         if ooErr
            return ooErr
         end


         (i+=1;i-2)
      end

      return ooNoErr
   end

   def UpgradeWorkOrderErr()
      ooErr=ooNoErr
      ooErr=@upgradeWorkOrderStep1()
      if ooErr
         return ooErr
      end

      ooErr=@upgradeWorkOrderStep2()
      if ooErr
         return ooErr
      end

      ooErr=@upgradeWorkOrderStep3()
      if ooErr
         return ooErr
      end

      ooErr=@upgradeWorkOrderStep4()
      if ooErr
         return ooErr
      end

      return ooErr
   end

   def UpgradeOJDTCreatedByForWOR()
      trace("UpgradeOJDTCreatedByForWOR")
      sboErr=0
      bizEnv = CBizEnv.new=GetEnv()
      dagRes = PDAG.new
      dagJDT = PDAG.new = GetDAG()
      dagQuery = PDAG.new = GetDAG(CRD)
      join = []

      resStruct = []

      sortStruct = []

      dagQuery.GetDBDParams().Clear()
      resStruct[0].tableIndex=0
      resStruct[0].colNum=OWOR_NUM
      resStruct[0].group_by=true
      resStruct[1].tableIndex=0
      resStruct[1].colNum=OWOR_ABS_ENTRY
      resStruct[1].agreg_type=DBD_MAX
      tablePtr = DBD_TablesList.new
      tables = DBD_CondTables.new=dagQuery.GetDBDParams().GetCondTables()
      tablePtr=tables.AddTable()
      tablePtr.tableCode=bizEnv.ObjectToTable(WOR)
      tablePtr=tables.AddTable()
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
      sboErr=DBD_GetInNewFormat(dagQuery,dagRes)
      if sboErr
         return (sboErr==-2028) ? ooNoErr : sboErr
      end

      conds = DBD_Conditions.new=dagJDT.GetDBDParams().GetConditions()
      cond = PDBD_Cond.new
      cond=conds.AddCondition()
      cond.colNum=OJDT_TRANS_TYPE
      cond.operation=DBD_EQ
      cond.condVal=WOR
      cond.relationship=0
      sboErr=dagJDT.GetFirstChunk(50000)
      if sboErr
         return sboErr
      end

      while (sboErr==0)

         numOfDoc1Recs = dagJDT.GetRecordCount()
         rec=0
         while (rec<numOfDoc1Recs) do
            dagJDT.GetColLong(oldBaseNum,OJDT_CREATED_BY,rec)
            newBaseNum=GetBaseEntry(dagRes,oldBaseNum)
            if newBaseNum<0
               next

            end

            dagJDT.SetColLong(newBaseNum,OJDT_CREATED_BY,rec)

            (rec+=1;rec-2)
         end

         sboErr=dagJDT.UpdateAll()
         if sboErr
            break
         end

         sboErr=dagJDT.GetNextChunk(50000)
      end

      if sboErr==-2028
         sboErr=0
      end

      return sboErr
   end

   def SetDebitCreditField()
      trace("SetDebitCreditField")
      dagJDT1 = PDAG.new


      debAmount = MONEY.new
      credAmount = MONEY.new
      dagJDT1=GetDAG(JDT,ao_Arr1)
      DAG_GetCount(dagJDT1,numOfRecs)
      rec=0
      while (rec<numOfRecs) do
         if dagJDT1.IsNullCol(JDT1_DEBIT_CREDIT,rec)
            dagJDT1.GetColMoney(debAmount,JDT1_DEBIT,rec,DBM_NOT_ARRAY)
            if !debAmount.IsZero()
               dagJDT1.SetColStr(VAL_DEBIT,JDT1_DEBIT_CREDIT,rec)
               next

            end

            dagJDT1.GetColMoney(credAmount,JDT1_CREDIT,rec,DBM_NOT_ARRAY)
            if !credAmount.IsZero()
               dagJDT1.SetColStr(VAL_CREDIT,JDT1_DEBIT_CREDIT,rec)
               next

            end

            dagJDT1.GetColMoney(debAmount,JDT1_SYS_DEBIT,rec,DBM_NOT_ARRAY)
            if !debAmount.IsZero()
               dagJDT1.SetColStr(VAL_DEBIT,JDT1_DEBIT_CREDIT,rec)
               next

            end

            dagJDT1.GetColMoney(credAmount,JDT1_SYS_CREDIT,rec,DBM_NOT_ARRAY)
            if !credAmount.IsZero()
               dagJDT1.SetColStr(VAL_CREDIT,JDT1_DEBIT_CREDIT,rec)
               next

            end

            dagJDT1.GetColMoney(debAmount,JDT1_FC_DEBIT,rec,DBM_NOT_ARRAY)
            if !debAmount.IsZero()
               dagJDT1.SetColStr(VAL_DEBIT,JDT1_DEBIT_CREDIT,rec)
               next

            end

            dagJDT1.GetColMoney(credAmount,JDT1_FC_CREDIT,rec,DBM_NOT_ARRAY)
            if !credAmount.IsZero()
               dagJDT1.SetColStr(VAL_CREDIT,JDT1_DEBIT_CREDIT,rec)
               next

            end

            dagJDT1.GetColMoney(debAmount,JDT1_BALANCE_DUE_DEBIT,rec,DBM_NOT_ARRAY)
            if !debAmount.IsZero()
               dagJDT1.SetColStr(VAL_DEBIT,JDT1_DEBIT_CREDIT,rec)
               next

            end

            dagJDT1.GetColMoney(credAmount,JDT1_BALANCE_DUE_CREDIT,rec,DBM_NOT_ARRAY)
            if !credAmount.IsZero()
               dagJDT1.SetColStr(VAL_CREDIT,JDT1_DEBIT_CREDIT,rec)
               next

            end

            dagJDT1.GetColMoney(debAmount,JDT1_BALANCE_DUE_FC_DEB,rec,DBM_NOT_ARRAY)
            if !debAmount.IsZero()
               dagJDT1.SetColStr(VAL_DEBIT,JDT1_DEBIT_CREDIT,rec)
               next

            end

            dagJDT1.GetColMoney(credAmount,JDT1_BALANCE_DUE_FC_CRED,rec,DBM_NOT_ARRAY)
            if !credAmount.IsZero()
               dagJDT1.SetColStr(VAL_CREDIT,JDT1_DEBIT_CREDIT,rec)
               next

            end

            dagJDT1.GetColMoney(debAmount,JDT1_BALANCE_DUE_SC_DEB,rec,DBM_NOT_ARRAY)
            if !debAmount.IsZero()
               dagJDT1.SetColStr(VAL_DEBIT,JDT1_DEBIT_CREDIT,rec)
               next

            end

            dagJDT1.GetColMoney(credAmount,JDT1_BALANCE_DUE_SC_CRED,rec,DBM_NOT_ARRAY)
            if !credAmount.IsZero()
               dagJDT1.SetColStr(VAL_CREDIT,JDT1_DEBIT_CREDIT,rec)
               next

            end

         end


         (rec+=1;rec-2)
      end

      return ooNoErr
   end

   def UpgradeOJDTWithFolio()
      trace("UpgradeOJDTWithFolio")
      dagJDT = PDAG.new=nil
      dagJDT1 = PDAG.new = nil
      dagFolioRes = PDAG.new
      cond = PDBD_Cond.new
      table = DBD_TablesList.new
      folioResStruct = []



      curFolioNum = SBOString.new
      curPrefix = SBOString.new
      ooErr=0
      bizEnv = CBizEnv.new=GetEnv()
      dagJDT1=GetArrayDAG(ao_Arr1)
      dagJDT=GetDAG()
      ooErr=dagJDT.GetFirstChunk(10000)
      while (ooErr==0)
         numOfRecs=dagJDT.GetRealSize(dbmDataBuffer)
         rec=0
         while (rec<numOfRecs) do
            dagJDT.GetColLong(curTransId,OJDT_JDT_NUM,rec)
            dagJDT.GetColLong(curTransType,OJDT_TRANS_TYPE,rec)
            dagJDT.GetColLong(curCreatedBy,OJDT_CREATED_BY,rec)
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
            tables = DBD_CondTables.new=dagJDT1.GetDBDParams().GetCondTables()
            tables.Clear()
            table=tables.AddTable()
            table.tableCode=bizEnv.ObjectToTable(curTransType)
            conditions = DBD_Conditions.new=dagJDT1.GetDBDParams().GetConditions()
            conditions.Clear()
            cond=conditions.AddCondition()
            cond.colNum=OINV_ABS_ENTRY
            cond.tableIndex=0
            cond.operation=DBD_EQ
            cond.condVal=curCreatedBy
            DBD_SetDAGRes(dagJDT1,folioResStruct,2)
            ooErr=DBD_GetInNewFormat(dagJDT1,dagFolioRes)
            if ooErr
               if ooErr==-2028
                  ooErr=0
                  next

               end

               return ooErr
            end

            dagFolioRes.GetColStr(curPrefix,0)
            dagFolioRes.GetColStr(curFolioNum,1)
            dagJDT.SetColStr(curPrefix,OJDT_FOLIO_PREFIX,rec)
            dagJDT.SetColStr(curFolioNum,OJDT_FOLIO_NUMBER,rec)

            (rec+=1;rec-2)
         end

         ooErr=dagJDT.UpdateAll()
         if ooErr
            return ooErr
         end

         ooErr=dagJDT.GetNextChunk(10000)
      end

      if ooErr==-2028
         ooErr=0
      end

      return ooErr
   end

   def UpgradeJDTCreateDate()
      trace("UpgradeJDTCreateDate")

      dagRES1 = PDAG.new
      dagRES2 = PDAG.new
      dagJDT = PDAG.new
      resStruct = []

      conditions = DBD_Conditions.new
      cond = PDBD_Cond.new
      subParamsPDN = DBD_Params.new
      subParamsRPD = DBD_Params.new
      subResStructPDN = []
      subResStructRPD = []

      subTableStructPDN = []
      subTableStructRPD = []

      subCondPDN = []
      subCondRPD = []

      sort = []

      dagJDT=GetDAG()
      resStruct[0].colNum=OJDT_JDT_NUM
      resStruct[0].agreg_type=0
      DBD_SetDAGRes(dagJDT,resStruct,1)
      conditions=dagJDT.GetDBDParams().GetConditions()
      cond=conditions.AddCondition()
      cond.colNum=OJDT_CREATE_DATE
      cond.operation=DBD_IS_NULL
      cond.relationship=DBD_AND
      cond=conditions.AddCondition()
      cond.bracketOpen=2
      cond.colNum=OJDT_TRANS_TYPE
      cond.operation=DBD_EQ
      cond.condVal=PDN
      cond.relationship=DBD_AND
      cond=conditions.AddCondition()
      UpgradeCreateDateSubQuery(subParamsPDN,subResStructPDN,subTableStructPDN,subCondPDN,PDN)
      cond.SetSubQueryParams(subParamsPDN)
      cond.tableIndex=DBD_NO_TABLE
      cond.operation=DBD_NOT_EXISTS
      cond.bracketClose=1
      cond.relationship=DBD_OR
      cond=conditions.AddCondition()
      cond.bracketOpen=1
      cond.colNum=OJDT_TRANS_TYPE
      cond.operation=DBD_EQ
      cond.condVal=RPD
      cond.relationship=DBD_AND
      cond=conditions.AddCondition()
      UpgradeCreateDateSubQuery(subParamsRPD,subResStructRPD,subTableStructRPD,subCondRPD,RPD)
      cond.SetSubQueryParams(subParamsRPD)
      cond.tableIndex=DBD_NO_TABLE
      cond.operation=DBD_NOT_EXISTS
      cond.bracketClose=2
      cond.relationship=0
      sort[0].colNum=OJDT_JDT_NUM
      DBD_SetDAGSort(dagJDT,sort,1)
      ooErr=DBD_GetInNewFormat(dagJDT,dagRES1)
      if ooErr
         if ooErr==-2028
            ooErr=0
         end

         return ooErr
      end

      dagRES1.Detach()
      resStruct[0].colNum=OJDT_JDT_NUM
      resStruct[0].agreg_type=DBD_MAX
      resStruct[1].colNum=OJDT_CREATE_DATE
      resStruct[1].group_by=true
      DBD_SetDAGRes(dagJDT,resStruct,2)
      conditions=dagJDT.GetDBDParams().GetConditions()
      cond=conditions.AddCondition()
      cond.colNum=OJDT_CREATE_DATE
      cond.operation=DBD_NOT_NULL
      cond.relationship=0
      ooErr=DBD_GetInNewFormat(dagJDT,dagRES2)
      if ooErr
         dagRES1.Close()
         if ooErr==-2028
            ooErr=0
         end

         return ooErr
      end

      cols = []
      =""
      oreder = []
      =""
      dagRES2.SortByCols(cols,oreder,1,false,false)

      jj = 0
      updStruct = []

      updStruct[0].colNum=OJDT_CREATE_DATE
      numOfRecsRES1=dagRES1.GetRecordCount()
      numOfRecsRES2=dagRES2.GetRecordCount()
      ii=0
      while (ii<numOfRecsRES1) do
         dagRES1.GetColLong(updateTransNum,0,ii)
         while (jj<numOfRecsRES2)
            dagRES2.GetColLong(transOfNewDateInRES2,0,jj)
            if updateTransNum<transOfNewDateInRES2
               conditions=dagJDT.GetDBDParams().GetConditions()
               cond=conditions.AddCondition()
               cond.colNum=OJDT_JDT_NUM
               cond.operation=DBD_EQ
               cond.condVal=SBOString(updateTransNum)
               cond.relationship=0
               dagRES2.GetColStr(updStruct[0].updateVal,1,jj)
               DBD_SetDAGUpd(dagJDT,updStruct,1)
               ooErr=DBD_UpdateCols(dagJDT)
               if ooErr
                  dagRES1.Close()
                  return ooErr
               end

               break
            end

            (jj+=1;jj-2)
         end


         (ii+=1;ii-2)
      end

      dagRES1.Close()
      return 0
   end

   def UpgradeJDTCanceledDeposit()
      trace("UpgradeJDTCanceledDeposit")

      resStruct = []

      conditions = DBD_Conditions.new
      cond = PDBD_Cond.new
      subParams = DBD_Params.new
      subResStruct = []

      subTableStruct = []

      subCond = []

      dagJDT = PDAG.new
      dagJDT1 = PDAG.new
      dagRES = PDAG.new
      dagJDT=GetDAG()
      dagJDT1=GetDAG(JDT,ao_Arr1)
      resStruct[0].colNum=OJDT_JDT_NUM
      resStruct[1].colNum=OJDT_NUMBER
      DBD_SetDAGRes(dagJDT,resStruct,2)
      conditions=dagJDT.GetDBDParams().GetConditions()
      cond=conditions.AddCondition()
      cond.colNum=OJDT_TRANS_TYPE
      cond.operation=DBD_EQ
      cond.condVal=SBOString(DPS)
      cond.relationship=DBD_AND
      _STR_strcpy(subTableStruct[0].tableCode,GetEnv().ObjectToTable(DPS))
      subResStruct[0].colNum=ODPS_ABS_ENT
      subResStruct[0].tableIndex=0
      subCond[0].compareCols=true
      subCond[0].tableIndex=0
      subCond[0].colNum=OJDT_JDT_NUM
      subCond[0].compColNum=ODPS_TRANS_ABS
      subCond[0].operation=DBD_EQ
      subCond[0].origTableIndex=0
      subCond[0].origTableLevel=1
      subCond[0].relationship=0
      DBD_SetParamTablesList(subParams,subTableStruct,1)
      DBD_SetCond(subParams,subCond,1)
      DBD_SetRes(subParams,subResStruct,1)
      cond=conditions.AddCondition()
      cond.SetSubQueryParams(subParams)
      cond.tableIndex=DBD_NO_TABLE
      cond.operation=DBD_NOT_EXISTS
      cond.relationship=0
      ooErr=DBD_GetInNewFormat(dagJDT,dagRES)
      if ooErr
         if ooErr==-2028
            ooErr=0
         end

         return ooErr
      end

      updStructJDT = []
      updStructJDT1 = []

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
      while (ii<numOfRecs) do
         conditions=dagJDT.GetDBDParams().GetConditions()
         cond=conditions.AddCondition()
         cond.colNum=OJDT_JDT_NUM
         cond.operation=DBD_EQ
         dagRES.GetColStr(cond.condVal,0,ii)
         cond.relationship=0
         dagRES.GetColStr(updStructJDT[1].updateVal,0,ii)
         dagRES.GetColStr(updStructJDT[2].updateVal,1,ii)
         DBD_SetDAGUpd(dagJDT,updStructJDT,3)
         ooErr=DBD_UpdateCols(dagJDT)
         if ooErr
            return ooErr
         end

         conditions=dagJDT1.GetDBDParams().GetConditions()
         cond=conditions.AddCondition()
         cond.colNum=JDT1_TRANS_ABS
         cond.operation=DBD_EQ
         dagRES.GetColStr(cond.condVal,0,ii)
         cond.relationship=0
         dagRES.GetColStr(updStructJDT1[1].updateVal,0,ii)
         dagRES.GetColStr(updStructJDT1[2].updateVal,1,ii)
         DBD_SetDAGUpd(dagJDT1,updStructJDT1,3)
         ooErr=DBD_UpdateCols(dagJDT1)
         if ooErr
            return ooErr
         end


         (ii+=1;ii-2)
      end

      return 0
   end

   def UpgradeJDT1VatLineToNo()
      sboErr=0
      bizEnv = CBizEnv.new=GetEnv()
      subQueryParams = []

      subQueryRES = []

      tableStruct = []
      subQueryTableStruct = []

      mainConds = []
      subConds = []

      updStruct = []

      queryDag = PDAG.new=GetDAG()
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
      if sboErr&&sboErr!=-2028
         return sboErr
      end

      return 0
   end

   def UpgradeYearTransfer()
      conditions = DBD_Conditions.new
      cond = PDBD_Cond.new
      updStructJDT = []

      dagJDT = PDAG.new
      dagJDT=GetDAG()
      conditions=dagJDT.GetDBDParams().GetConditions()
      cond=conditions.AddCondition()
      cond.colNum=OJDT_TRANS_TYPE
      cond.operation=DBD_EQ
      cond.condVal=OPEN_BLNC_TYPE
      cond.relationship=DBD_AND
      cond=conditions.AddCondition()
      cond.colNum=OJDT_BATCH_NUM
      cond.operation=DBD_NOT_NULL
      cond.relationship=DBD_AND
      cond=conditions.AddCondition()
      cond.colNum=OJDT_BATCH_NUM
      cond.operation=DBD_NE
      cond.condVal=STR_0
      cond.relationship=DBD_AND
      cond=conditions.AddCondition()
      cond.colNum=OJDT_DATA_SOURCE
      cond.operation=DBD_EQ
      cond.condVal=VAL_UNKNOWN_SOURCE
      cond.relationship=0
      updStructJDT[0].colNum=OJDT_DATA_SOURCE
      updStructJDT[0].updateVal=VAL_YEAR_TRANSFER_SOURCE
      DBD_SetDAGUpd(dagJDT,updStructJDT,1)
      return DBD_UpdateCols(dagJDT)
   end

   def RepairTaxTable()
      sboErr=0
      bizEnv = CBizEnv.new=GetEnv()
      subQueryParams = []

      subQueryRES = []

      tableStruct = []
      subQueryTableStruct = []

      joinToTAX1 = []
      joinToOTAX = []

      mainConds = []
      subConds = []

      subQuery2Params = []

      subQuery2TableStruct = []

      queryDag = PDAG.new=GetDAG(TAX,ao_Main)
      if !bizEnv.IsVatPerLine()
         return 0
      end

      _STR_strcpy(subQueryTableStruct[0].tableCode,bizEnv.ObjectToTable(TAX,ao_Arr1))
      _STR_strcpy(subQueryTableStruct[1].tableCode,bizEnv.ObjectToTable(TAX,ao_Main))
      _STR_strcpy(subQueryTableStruct[2].tableCode,bizEnv.ObjectToTable(JDT,ao_Arr1))
      subQueryTableStruct[1].doJoin=true
      subQueryTableStruct[1].joinedToTable=0
      subQueryTableStruct[1].numOfConds=1
      subQueryTableStruct[1].joinConds=joinToTAX1
      subQueryTableStruct[2].doJoin=true
      subQueryTableStruct[2].joinedToTable=1
      subQueryTableStruct[2].numOfConds=3
      subQueryTableStruct[2].joinConds=joinToOTAX
      joinToTAX1[0].compareCols=true
      joinToTAX1[0].compColNum=TAX1_ABS_ENTRY
      joinToTAX1[0].compTableIndex=1
      joinToTAX1[0].colNum=OTAX_ABS_ENTRY
      joinToTAX1[0].tableIndex=0
      joinToTAX1[0].operation=DBD_EQ
      joinToOTAX[0].compareCols=true
      joinToOTAX[0].compColNum=OTAX_SOURCE_OBJ_ABS_ENTRY
      joinToOTAX[0].compTableIndex=1
      joinToOTAX[0].colNum=JDT1_TRANS_ABS
      joinToOTAX[0].tableIndex=2
      joinToOTAX[0].operation=DBD_EQ
      joinToOTAX[0].relationship=DBD_AND
      joinToOTAX[1].compareCols=true
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
      return 0
   end

   def UpgradeJDTIndianAutoVat()
      trace("UpgradeJDTIndianAutoVat")
      sboErr=0
      dagRes = PDAG.new
      bizEnv = CBizEnv.new=GetEnv()
      conditions = DBD_Conditions.new
      condition = []

      cond = PDBD_Cond.new
      resStruct = []

      sortStruct = []

      tables = []

      join = []

      dagJDT = PDAG.new=GetDAG()
      dagJDT.ClearQueryParams()
      tables[0].tableCode=bizEnv.ObjectToTable(JDT,ao_Main)
      tables[1].tableCode=bizEnv.ObjectToTable(JDT,ao_Arr1)
      tables[1].doJoin=true
      tables[1].joinedToTable=0
      tables[1].numOfConds=1
      tables[1].joinConds=join[0]
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
      sboErr=DBD_GetInNewFormat(dagJDT,dagRes)
      if sboErr
         if sboErr==-2028
            sboErr=0
         end

         return sboErr
      end

      dagJDT1 = PDAG.new=GetDAG(JDT,ao_Arr1)
      sortStruct[0].colNum=JDT1_TRANS_ABS
      sortStruct[1].colNum=JDT1_LINE_ID
      numOfTrans=dagRes.GetRecordCount()
      workLoad=1000
      step=numOfTrans/workLoad
      transValues = SBOCollection_SBOString.new
      i=0
      while (i<=step) do

         if i<step
            _translated_begin=i*workLoad
            _translated_end=(i+1)*workLoad
         else
            _translated_begin=i*workLoad
            _translated_end=numOfTrans
            if _translated_begin>=_translated_end
               break
            end

         end

         transValues.Clear()
         j=_translated_begin
         while (j<_translated_end) do
            dagRes.GetColLong(transID,0,j)
            transValues.Add(transID)

            (j+=1)
         end

         dagJDT1.ClearQueryParams()
         conditions=dagJDT1.GetDBDParams().GetConditions()
         cond=conditions.AddCondition()
         cond.colNum=JDT1_TRANS_ABS
         cond.operation=DBD_IN
         cond.SetValuesArray(transValues)
         DBD_SetDAGSort(dagJDT1,sortStruct,2)
         DBD_Get(dagJDT1)
         sboErr=UpgradeJDTIndianAutoVatInt(dagJDT1)
         if sboErr
            return sboErr
         end


         (i+=1)
      end

      return sboErr
   end

   def UpgradeOJDTUpdateDocType()
      sboErr=ooNoErr
      bizEnv = CBizEnv.new=GetEnv()
      dagJDT = PDAG.new=bizEnv.OpenDAG(JDT)
      condStruct = []

      updStruct = []

      srcStr = SBOString.new
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
      if @m_pSequenceParameter==nil
         @m_pSequenceParameter=CSequenceParameter.new(OJDT_SEQ_CODE,OJDT_SERIAL)
      end

      return @m_pSequenceParameter
   end

   def ValidateHeaderLocation()
      trace("ValidateHeaderLocation")
      dagJDT = PDAG.new=GetDAG()
      autoVat = SBOString.new
      regNo = SBOString.new
      dagJDT.GetColStr(autoVat,OJDT_AUTO_VAT)
      dagJDT.GetColStr(regNo,OJDT_GEN_REG_NO)
      if autoVat==VAL_YES||regNo==VAL_YES
         dagJDT.GetColLong(location,OJDT_LOCATION)
         if !location
            SetErrorField(OJDT_LOCATION)
            Message(GO_OBJ_ERROR_MSGS(JDT),17,nil,OO_ERROR)
            return (ooInvalidObject)
         end

      end

      return ooNoErr
   end

   def CompleteLocations()
      dagJDT = PDAG.new=GetDAG()
      dagJDT1 = PDAG.new=GetDAG(ao_Arr1)
      autoVat = SBOString.new
      regNo = SBOString.new
      dagJDT.GetColStr(autoVat,OJDT_AUTO_VAT)
      dagJDT.GetColStr(regNo,OJDT_GEN_REG_NO)
      if autoVat==VAL_YES||regNo==VAL_YES
         location=0
         dagJDT.GetColLong(location,OJDT_LOCATION)
         if !location
            seq=0
            dagJDT.GetColLong(seq,OJDT_SEQ_CODE)
            if seq
               location=GetEnv().GetSequenceManager().GetLocation(self,seq)
               dagJDT.SetColLong(location,OJDT_LOCATION)
            end

         end

         dagJDT.GetColLong(location,OJDT_LOCATION)
         if location
            recCount=dagJDT1.GetRecordCount()
            taxCode = SBOString.new
            rec=0
            while (rec<recCount) do
               dagJDT1.GetColStr(taxCode,JDT1_TAX_CODE,rec)
               if !taxCode.IsEmpty()
                  dagJDT1.GetColLong(location,JDT1_LOCATION,rec)
                  if !location
                     dagJDT1.CopyColumn(dagJDT,JDT1_LOCATION,rec,OJDT_LOCATION,0)
                  end

               end


               (rec+=1;rec-2)
            end

         end

      end

      return ooNoErr
   end

   def UpdateWTInfo()
      ooErr=ooNoErr
      bizEnv = CBizEnv.new=GetEnv()
      dagJDT = PDAG.new=GetDAG(JDT)
      dagJDT1 = PDAG.new=GetDAG(JDT,ao_Arr1)
      wtSum = MONEY.new
      wtSumSC = MONEY.new
      wtSumFC = MONEY.new
      sum = MONEY.new
      bpLineWt = MONEY.new
      debit = MONEY.new
      credit = MONEY.new
      recCountJDT1=dagJDT1.GetRecordCount()
      shortName = SBOString.new
      account = SBOString.new

      cardRec = LongArray.new
      cardSum = StdArray.new
      cardSide = StdArray.new
      wtSide = SBOString.new
      GetWTCredDebt(wtSide)
      mainCurr = SBOString.new
      sysCurr = SBOString.new
      fcCurr = SBOString.new
      mainCurr=bizEnv.GetMainCurrency()
      sysCurr=bizEnv.GetSystemCurrency()
      dagJDT.GetColStr(fcCurr,OJDT_TRANS_CURR)
      rec=0
      while (rec<recCountJDT1) do
         dagJDT1.GetColStr(shortName,JDT1_SHORT_NAME,rec)
         shortName.Trim()
         dagJDT1.GetColStr(account,JDT1_ACCT_NUM,rec)
         account.Trim()
         isCard=shortName!=account
         if isCard
            cardRec.Add(rec)
            dagJDT1.GetColMoney(debit,JDT1_DEBIT,rec)
            dagJDT1.GetColMoney(credit,JDT1_CREDIT,rec)
            bpLineWt=debit==0 ? credit : debit
            if credit==0
               cardSide.Add(VAL_DEBIT)
            else
               cardSide.Add(VAL_CREDIT)
            end

            cardSum.Add(bpLineWt)
            sum+=(debit-credit)
         end


         (rec+=1;rec-2)
      end

      sum.Abs()
      dagJDT.GetColMoney(wtSum,OJDT_WT_SUM)
      dagJDT.GetColMoney(wtSumSC,OJDT_WT_SUM_SC)
      dagJDT.GetColMoney(wtSumFC,OJDT_WT_SUM_FC)
      numBP=cardRec.GetSize()
      sumTmpD = MONEY.new
      sumTmpSCD = MONEY.new
      sumTmpFCD = MONEY.new
      sumTmpC = MONEY.new
      sumTmpSCC = MONEY.new
      sumTmpFCC = MONEY.new
      if numBP<=0
         return ooErr
      end

      i=0

      while (i<numBP-1) do
         rec=cardRec[i]
         precent = MONEY.new=cardSum[i].MulAndDiv(100,sum)
         bpLineWt=wtSum.MulAndDiv(precent,100)
         bpLineWt.Round(RC_SUM,mainCurr,bizEnv)
         dagJDT1.SetColMoney(bpLineWt,JDT1_WT_SUM,rec)
         if cardSide[i]==VAL_DEBIT
            sumTmpD+=bpLineWt
         else
            sumTmpC+=bpLineWt
         end

         bpLineWt=wtSumSC.MulAndDiv(precent,100)
         bpLineWt.Round(RC_SUM,sysCurr,bizEnv)
         dagJDT1.SetColMoney(bpLineWt,JDT1_WT_SUM_SC,rec)
         if cardSide[i]==VAL_DEBIT
            sumTmpSCD+=bpLineWt
         else
            sumTmpSCC+=bpLineWt
         end

         bpLineWt=wtSumFC.MulAndDiv(precent,100)
         bpLineWt.Round(RC_SUM,fcCurr,bizEnv)
         dagJDT1.SetColMoney(bpLineWt,JDT1_WT_SUM_FC,rec)
         if cardSide[i]==VAL_DEBIT
            sumTmpFCD+=bpLineWt
         else
            sumTmpFCC+=bpLineWt
         end


         (i+=1;i-2)
      end

      bpLineWtSC = MONEY.new
      bpLineWtFC = MONEY.new
      if wtSide==VAL_DEBIT
         bpLineWt=wtSum-(sumTmpD-sumTmpC)
         bpLineWtSC=wtSumSC-(sumTmpSCD-sumTmpSCC)
         bpLineWtFC=wtSumFC-(sumTmpFCD-sumTmpFCC)
      else
         bpLineWt=wtSum+(sumTmpD-sumTmpC)
         bpLineWtSC=wtSumSC+(sumTmpSCD-sumTmpSCC)
         bpLineWtFC=wtSumFC+(sumTmpFCD-sumTmpFCC)
      end

      if wtSide!=cardSide[i]
         bpLineWt*=-1
         bpLineWtSC*=-1
         bpLineWtFC*=-1
      end

      dagJDT1.SetColMoney(bpLineWt,JDT1_WT_SUM,cardRec[i])
      dagJDT1.SetColMoney(bpLineWtSC,JDT1_WT_SUM_SC,cardRec[i])
      dagJDT1.SetColMoney(bpLineWtFC,JDT1_WT_SUM_FC,cardRec[i])
      return ooErr
   end

   def GetJDTReconStatus()
      dagJDT1 = PDAG.new=GetArrayDAG(ao_Arr1)
      numRec=dagJDT1.GetRecordCount()
      acctCode = SBOString.new
      shrtName = SBOString.new
      mny = MONEY.new
      creditSide=false
      rec=0
      while (rec<numRec) do
         dagJDT1.GetColStr(acctCode,JDT1_ACCT_NUM,rec)
         dagJDT1.GetColStr(shrtName,JDT1_SHORT_NAME,rec)
         if acctCode==shrtName
            next

         end

         dagJDT1.GetColMoney(mny,JDT1_DEBIT,rec)
         if mny.IsZero()
            creditSide=true
         end

         balDueCol=creditSide ? JDT1_BALANCE_DUE_CREDIT : JDT1_BALANCE_DUE_DEBIT
         dagJDT1.GetColMoney(mny,balDueCol,rec)
         if !mny.IsZero()
            return VAL_OPEN
         end


         (rec+=1;rec-2)
      end

      return VAL_CLOSE
   end

   def OnCanJDT2Update()
      ooErr=ooNoErr
      oopp = DBM_OUP.new=GetOnUpdateParams()
      return ooNoErr
      i=0
      while (i<oopp.colsList.GetSize()) do
         case oopp.colsList[i].GetColNum()

         when INV5_WT_APPLIED_AMOUNT
         when INV5_WT_APPLIED_AMOUNT_SC
         when INV5_WT_APPLIED_AMOUNT_FC
            return ooNoErr
         else
            SetErrorField(oopp.colsList[i].GetColNum())
            SetErrorLine(-1)
            return -1029
         end


         (i+=1;i-2)
      end

      return ooNoErr
   end

   def CheckWTValid()
      trace("CheckWTValid")
      ooErr=ooNoErr
      dagJDT = PDAG.new=GetDAG(JDT)
      dagJDT1 = PDAG.new=GetDAG(JDT,ao_Arr1)
      dagJDT2 = PDAG.new=GetDAG(JDT,ao_Arr2)
      tmpStr = SBOString.new
      acctNum = SBOString.new
      shortName = SBOString.new
      tmpMny = MONEY.new
      mnyBPDebit = MONEY.new
      mnyBPCred = MONEY.new

      hasBPline = false
      hasLiableline = false
      dagJDT.GetColStr(tmpStr,OJDT_AUTO_WT)
      if tmpStr[0]==VAL_NO[0]
         return ooNoErr
      end

      recCount=dagJDT1.GetRealSize(dbmDataBuffer)
      rec=0
      while (rec<recCount) do
         dagJDT1.GetColStr(acctNum,JDT1_ACCT_NUM,rec)
         dagJDT1.GetColStr(shortName,JDT1_SHORT_NAME,rec)
         if acctNum.Trim()!=shortName.Trim()
            hasBPline=true
            dagJDT1.GetColMoney(tmpMny,JDT1_DEBIT,rec)
            mnyBPDebit+=tmpMny
            dagJDT1.GetColMoney(tmpMny,JDT1_CREDIT,rec)
            mnyBPCred+=tmpMny
         end


         (rec+=1;rec-2)
      end

      bpDebCre = SBOString.new
      if mnyBPCred>=mnyBPDebit
         isBpCredit=true
         bpDebCre=VAL_CREDIT
      else
         isBpCredit=false
         bpDebCre=VAL_DEBIT
      end

      wtDebCre = SBOString.new
      GetWTCredDebt(wtDebCre)
      baseAmt = MONEY.new
      dagJDT.GetColMoney(baseAmt,OJDT_WT_BASE_AMOUNT)
      numJdt2Rec=dagJDT2.GetRecordCount()
      if hasBPline&&(!baseAmt.IsZero())&&(bpDebCre!=wtDebCre)&&numJdt2Rec>0
         return -1
      end

      return ooErr
   end

   def CheckMultiBP()
      trace("CheckMultiBP")
      dagJDT = PDAG.new=GetDAG(JDT)
      dagJDT1 = PDAG.new=GetDAG(JDT,ao_Arr1)
      autoWT = SBOString.new
      dagJDT.GetColStr(autoWT,OJDT_AUTO_WT)
      if autoWT==VAL_YES
         recJDT1=dagJDT1.GetRealSize(dbmDataBuffer)
         acct = SBOString.new
         shortname = SBOString.new
         firstBP = SBOString.new
         rec=0
         while (rec<recJDT1) do
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


            (rec+=1;rec-2)
         end

      end

      return ooNoErr
   end

   def WTGetBpCode()
      trace("WTGetBpCode")
      dagJDT = PDAG.new=GetDAG(JDT)
      dagJDT1 = PDAG.new=GetDAG(JDT,ao_Arr1)
      return WTGetBPCodeImp(dagJDT,dagJDT1)
   end

   def WTGetCurrency()
      trace("WTGetBpCode")
      dagJDT = PDAG.new=GetDAG(JDT)
      dagJDT1 = PDAG.new=GetDAG(JDT,ao_Arr1)
      return WTGetCurrencyImp(dagJDT,dagJDT1)
   end

   def GetBPLineCurrency()
      dagJDT1 = PDAG.new=GetDAG(JDT,ao_Arr1)
      recCount=dagJDT1.GetRealSize(dbmDataBuffer)
      acctCode = SBOString.new
      shortName = SBOString.new
      bpCurr = SBOString.new
      currency = SBOString.new=m_env.GetMainCurrency()
      rec=0
      while (rec<recCount) do
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


         (rec+=1;rec-2)
      end

      return currency
   end

   def SetCurrForAutoCompleteDOC5()
      case WTGetCurrSource()

      when INV_LOCAL_CURRENCY
         @m_WithholdingTaxMng.m_curSourceForAutoComplete[0]=INV_LOCAL_CURRENCY
         @m_WithholdingTaxMng.m_curSourceForAutoComplete[1]=INV_SYSTEM_CURRENCY
         @m_WithholdingTaxMng.m_curSourceForAutoComplete[2]=INV_CARD_CURRENCY

      when INV_SYSTEM_CURRENCY
         @m_WithholdingTaxMng.m_curSourceForAutoComplete[0]=INV_SYSTEM_CURRENCY
         @m_WithholdingTaxMng.m_curSourceForAutoComplete[1]=INV_CARD_CURRENCY
         @m_WithholdingTaxMng.m_curSourceForAutoComplete[2]=INV_LOCAL_CURRENCY

      when INV_CARD_CURRENCY
         @m_WithholdingTaxMng.m_curSourceForAutoComplete[0]=INV_CARD_CURRENCY
         @m_WithholdingTaxMng.m_curSourceForAutoComplete[1]=INV_LOCAL_CURRENCY
         @m_WithholdingTaxMng.m_curSourceForAutoComplete[2]=INV_SYSTEM_CURRENCY

      end

      return ooNoErr
   end

   def GetCRDDag()
      trace("GetCRDDag")
      ooErr=ooNoErr
      dagCRD = PDAG.new=GetDAG(CRD)
      dagJDT1 = PDAG.new=GetDAG(JDT,ao_Arr1)
      recCount=dagJDT1.GetRealSize(dbmDataBuffer)
      acctCode = SBOString.new
      shortName = SBOString.new
      rec=0
      while (rec<recCount) do
         dagJDT1.GetColStr(acctCode,JDT1_ACCT_NUM,rec)
         acctCode.Trim()
         dagJDT1.GetColStr(shortName,JDT1_SHORT_NAME,rec)
         shortName.Trim()
         if shortName!=acctCode
            cond = []

            cond[0].colNum=OCRD_CARD_CODE
            cond[0].operation=DBD_EQ
            cond[0].condVal=shortName
            DBD_SetDAGCond(dagCRD,cond,1)
            ooErr=DBD_Get(dagCRD)
            break
         end


         (rec+=1;rec-2)
      end

      return ooErr
   end

   def CompleteWTInfo()
      ooErr=ooNoErr
      dagJDT = PDAG.new=GetDAG(JDT)
      autoWT = SBOString.new
      dagJDT.GetColStr(autoWT,OJDT_AUTO_WT)
      autoWT.Trim()
      if autoWT==VAL_NO
         return ooErr
      end

      wtAllCurBaseCalcParamsPtr = CWTAllCurBaseCalcParams.new=CWTAllCurBaseCalcParams.new()
      currSource = []
      =""
      wtInfo = CJDTWTInfo.new=CJDTWTInfo.new()
      dagDOC = PDAG.new=m_env.OpenDAG(INV,ao_Main)
      PrePareDataForWT(wtAllCurBaseCalcParamsPtr,GetBPCurrencySource(),dagDOC,wtInfo)
      dagJDT2 = PDAG.new=GetDAG(JDT,ao_Arr2)
      numOfRecs=dagJDT2.GetRecordCount()
      i=0
      while (currSource[i]) do
         wtAllCurBaseCalcParamsPtr.InitWTBaseCalcParams(currSource[i])
         GetWTBaseAmount(currSource[i],wtAllCurBaseCalcParamsPtr.GetWtBaseCalcParams(currSource[i]))
         if numOfRecs>0
            wtCurrSource=GetBPCurrencySource()
            if (currSource[i]!=INV_CARD_CURRENCY)||(currSource[i]==INV_CARD_CURRENCY&&wtCurrSource==INV_CARD_CURRENCY)
               @m_WithholdingTaxMng.ODOCAutoCompleteDOC5(self,currSource[i],wtAllCurBaseCalcParamsPtr.GetWtBaseCalcParams(currSource[i]),false,dagDOC)
            end

         else
            JDTCalcWTTable(wtInfo,currSource[i],dagDOC,wtAllCurBaseCalcParamsPtr)
         end


         (i+=1;i-2)
      end

      UpdateWTAmounts(wtAllCurBaseCalcParamsPtr)
      dagDOC.Close()
      wtAllCurBaseCalcParamsPtr.__delete
      wtInfo.__delete
      return ooErr
   end

   def CompleteWTLine()
      ooErr=ooNoErr
      dagJDT = PDAG.new=nil
      dagJDT1 = PDAG.new = nil
      dagJDT2 = PDAG.new = nil
      wtCategory = SBOString.new
      wtSide = SBOString.new
      autoWT = SBOString.new
      dagJDT=GetDAG(JDT)
      if !DAG.IsValid(dagJDT)
         return ooErrNoMsg
      end

      dagJDT.GetColStr(autoWT,OJDT_AUTO_WT)
      autoWT.Trim()
      if autoWT!=VAL_YES
         return ooNoErr
      end

      ooErr=@completeWTInfo()
      if ooErr
         return ooErr
      end

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
      tmpStr = SBOString.new
      acctCode = SBOString.new
      mnyAmt = MONEY.new
      jdt1RecSize=dagJDT1.GetRealSize(dbmDataBuffer)
      jdt2RecSize=dagJDT2.GetRealSize(dbmDataBuffer)
      rec=0
      while (rec<jdt2RecSize) do
         dagJDT2.GetColStr(acctCode,INV5_ACCOUNT,rec)
         acctCode.Trim()
         found=false
         row=0
         while (row<jdt1RecSize) do
            dagJDT1.GetColStr(tmpStr,JDT1_WT_Line,row)
            if tmpStr.Trim()!=VAL_YES
               next

            end

            dagJDT1.GetColStr(tmpStr,JDT1_ACCT_NUM,row)
            if tmpStr.Trim()==acctCode
               found=true
               break
            end


            (row+=1;row-2)
         end

         if found
            ooErr=WtUpdJDT1LineAmt(dagJDT1,row,dagJDT2,rec,isDebit,acctCode,wtSide)
         else
            ooErr=WtAutoAddJDT1Line(dagJDT1,jdt1RecSize,dagJDT2,rec,isDebit,wtSide)
            (jdt1RecSize+=1;jdt1RecSize-2)
         end


         (rec+=1;rec-2)
      end

      return ooErr
   end

   def UpgradeERDBaseTrans()
      ooErr=ooNoErr
      ooErr=@upgradeERDBaseTransFromBackup()
      if ooErr
         if ooErr==-2004
            ooErr=0
         else
            return ooErr
         end

      end

      ooErr=@upgradeERDBaseTransFromRef3()
      return ooErr
   end

   def UpgradeERDBaseTransFromBackup()

      frame_start
      ooErr=ooNoErr

      bizEnv = CBizEnv.new=GetEnv()
      colList = ColumnInfoList.new
      keyList = KeyInfoList.new
      colAttr = DBM_CA.new




      bizEnv.GetColAttributes(bizEnv.ObjectToTable(JDT,ao_Main),OJDT_JDT_NUM,colAttr,false)
      DBMTableDefs.FormatOneDBField(colAttr)
      colList.Add(colAttr)
      bizEnv.GetColAttributes(bizEnv.ObjectToTable(JDT,ao_Main),OJDT_BASE_REF,colAttr,false)
      DBMTableDefs.FormatOneDBField(colAttr)
      colList.Add(colAttr)
      ooErr=bizEnv.GetTD(dbmFixedTD).CreateFixedDefinition(_T("ibd_ERDBaseRefBackup"),colList,keyList)
      if ooErr
         return ooErr
      end

      queryParams = DBD_Params.new
      queryParams.Clear()
      tablePtr = DBD_TablesList.new
      tablePtr=(queryParams.GetCondTables().AddTable())
      tablePtr.tableCode=_T("ibd_ERDBaseRefBackup")
      resStruct = []

      resStruct[0].tableIndex=0
      resStruct[0].colNum=0
      resStruct[1].tableIndex=0
      resStruct[1].colNum=1
      queryParams.dbdResPtr=resStruct
      queryParams.numOfResCols=2
      dagRes = PDAG.new=nil
      dagQuery = PDAG.new=bizEnv.OpenDAG(JDT,ao_Main)
      dagQuery.SetDBDParms(queryParams)
      ooErr=DBD_GetInNewFormat(dagQuery,dagRes)
      if ooErr
         if ooErr==-1
            ooErr=-2004
            goto :leave
         else
            if ooErr==-2028
               dagRes.SetSize(0,dbmDropData)
               ooErr=0
            else
               goto :leave
            end

         end

      end

      numOfRecs=dagRes.GetRecordCount()
      rec=0
      while (rec<numOfRecs) do
         dagRes.GetColLong(transId,0,rec)
         dagRes.GetColLong(baseRef,1,rec)
         ooErr=UpgradeERDBaseTransUpdateOne(transId,baseRef)
         if ooErr
            goto :leave
         end


         (rec+=1)
      end

      label(:leave){
         dagQuery.Close()
         tmpErr=bizEnv.GetTD(dbmFixedTD).DisposeDefinition(_T("ibd_ERDBaseRefBackup"))
         if !ooErr
            return tmpErr
         end

         return ooErr
      }

      frame_end

   end

   def UpgradeERDBaseTransFromRef3()
      ooErr=ooNoErr
      bizEnv = CBizEnv.new=GetEnv()


      tablePtr = DBD_TablesList.new
      joinCondsOJDT = []

      queryParams = DBD_Params.new
      abbrevMap = std::map.new
      UpgradeERDBaseTransPopulateAbbrevMap(abbrevMap)
      queryParams.Clear()
      tablePtr=(queryParams.GetCondTables().AddTable())
      tablePtr.tableCode=bizEnv.ObjectToTable(JDT,ao_Arr1)
      tablePtr=(queryParams.GetCondTables().AddTable())
      tablePtr.tableCode=bizEnv.ObjectToTable(JDT,ao_Main)
      tablePtr.doJoin=true
      tablePtr.joinedToTable=0
      tablePtr.numOfConds=1
      tablePtr.joinConds=joinCondsOJDT
      condNum=0
      joinCondsOJDT[condNum].compareCols=true
      joinCondsOJDT[condNum].tableIndex=1
      joinCondsOJDT[condNum].colNum=OJDT_JDT_NUM
      joinCondsOJDT[condNum].compTableIndex=0
      joinCondsOJDT[condNum].compColNum=JDT1_TRANS_ABS
      joinCondsOJDT[condNum].operation=DBD_EQ
      joinCondsOJDT[(condNum+=1;condNum-2)].relationship=0
      resStruct = []

      resStruct[0].tableIndex=1
      resStruct[0].colNum=OJDT_JDT_NUM
      resStruct[1].tableIndex=0
      resStruct[1].colNum=JDT1_LINE_ID
      resStruct[2].tableIndex=0
      resStruct[2].colNum=JDT1_ACCT_NUM
      resStruct[3].tableIndex=0
      resStruct[3].colNum=JDT1_SHORT_NAME
      resStruct[4].tableIndex=0
      resStruct[4].colNum=JDT1_REF3_LINE
      queryParams.dbdResPtr=resStruct
      queryParams.numOfResCols=5
      condPtr = PDBD_Cond.new
      condPtr=(queryParams.GetConditions().AddCondition())
      condPtr.tableIndex=1
      condPtr.colNum=OJDT_TRANS_TYPE
      condPtr.operation=DBD_EQ
      condPtr.condVal=JDT
      condPtr.relationship=DBD_AND
      condPtr=(queryParams.GetConditions().AddCondition())
      condPtr.tableIndex=0
      condPtr.colNum=JDT1_FC_CREDIT
      condPtr.operation=DBD_EQ
      condPtr.condVal=0
      condPtr.relationship=DBD_AND
      condPtr=(queryParams.GetConditions().AddCondition())
      condPtr.tableIndex=0
      condPtr.colNum=JDT1_FC_DEBIT
      condPtr.operation=DBD_EQ
      condPtr.condVal=0
      condPtr.relationship=DBD_AND
      condPtr=(queryParams.GetConditions().AddCondition())
      condPtr.tableIndex=0
      condPtr.colNum=JDT1_FC_CURRENCY
      condPtr.operation=DBD_NOT_NULL
      condPtr.relationship=DBD_AND
      condPtr=(queryParams.GetConditions().AddCondition())
      condPtr.tableIndex=1
      condPtr.colNum=OJDT_BASE_TRANS_ID
      condPtr.operation=DBD_IS_NULL
      condPtr.relationship=DBD_AND
      condPtr=(queryParams.GetConditions().AddCondition())
      condPtr.tableIndex=0
      condPtr.colNum=JDT1_REF3_LINE
      condPtr.operation=DBD_PATTERN
      condPtr.condVal=_T("*/*/*")
      condPtr.relationship=0
      key = DBM_KA.new
      key.SetSegmentsCount(2)
      key.SetSegmentColumn(0,0)
      key.SetSegmentColumn(1,1)
      dagRes = PDAG.new=nil
      dagQuery = PDAG.new=bizEnv.OpenDAG(BOT,ao_Arr1)
      dagQuery.SetDBDParms(queryParams)
      ooErr=dagQuery.GetFirstChunk(10000,key,dagRes)
      if (ooErr)&&(ooErr!=-2028)
         dagQuery.Close()
         return ooErr
      end

      while (ooErr!=-2028)
         numOfRecs=dagRes.GetRecordCount()
         rec=0
         while (rec<numOfRecs) do

            account = SBOString.new
            shortName = SBOString.new
            ref3Line = SBOString.new
            dagRes.GetColLong(transId,0,rec)
            dagRes.GetColStr(account,2,rec)
            dagRes.GetColStr(shortName,3,rec)
            dagRes.GetColStr(ref3Line,4,rec)
            baseTransCandidate=0
            ooErr=UpgradeERDBaseTransFindBaseTrans(abbrevMap,account,shortName,ref3Line,baseTransCandidate)
            if ooErr
               if ooErr!=-2028
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


            (rec+=1)
         end

         ooErr=dagQuery.GetNextChunk(10000,key,dagRes)
         if (ooErr)&&(ooErr!=-2028)
            dagQuery.Close()
            return ooErr
         end

      end

      dagQuery.Close()
      return ooNoErr
   end

   def GetCreateDate()
      date = SBOString.new=EMPTY_STR
      dag = PDAG.new=GetDAG()
      if dag
         dag.GetColStr(date,OJDT_CREATE_DATE)
      end

      return Date(date)
   end

   def RepairEquVatRateOfJDT1()
      ooErr=ooNoErr
      objectId = []
      =""
      i=0
      while (objectId[i]!=NOB) do
         ooErr=RepairEquVatRateOfJDT1ForOneObject(objectId[i])
         if ooErr
            return ooErr
         end


         (i+=1;i-2)
      end

      return ooErr
   end

   def UpgradeJDTCEEPerioEndReconcilations()
      trace("UpgradeJDTCEEPerioEndReconcilations")
      sboErr=0
      dagRes = PDAG.new
      bizEnv = CBizEnv.new=GetEnv()
      conditions = DBD_Conditions.new
      cond = PDBD_Cond.new
      tables = []

      join1 = []
      join2 = []
      join3 = []

      resStruct = []

      sortStruct = []

      dagJDT1 = PDAG.new=GetDAG()
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
      resStruct[0].tableIndex=2
      resStruct[0].colNum=ITR1_RECON_NUM
      resStruct[1].tableIndex=2
      resStruct[1].colNum=ITR1_LINE_SEQUENCE
      resStruct[2].tableIndex=2
      resStruct[2].colNum=ITR1_TRANS_ID
      resStruct[3].tableIndex=2
      resStruct[3].colNum=ITR1_TRANS_LINE_ID
      resStruct[4].tableIndex=2
      resStruct[4].colNum=ITR1_SRC_OBJ_TYPE
      DBD_SetDAGRes(dagJDT1,resStruct,5)
      conditions=dagJDT1.GetDBDParams().GetConditions()
      cond=conditions.AddCondition()
      cond.bracketOpen=true
      cond.colNum=JDT1_BALANCE_DUE_DEBIT
      cond.condVal=_T("0.00")
      cond.operation=DBD_NE
      cond.relationship=DBD_OR
      cond=conditions.AddCondition()
      cond.colNum=JDT1_BALANCE_DUE_CREDIT
      cond.condVal=_T("0.00")
      cond.operation=DBD_NE
      cond.relationship=DBD_OR
      cond=conditions.AddCondition()
      cond.colNum=JDT1_BALANCE_DUE_FC_DEB
      cond.condVal=_T("0.00")
      cond.operation=DBD_NE
      cond.relationship=DBD_OR
      cond=conditions.AddCondition()
      cond.colNum=JDT1_BALANCE_DUE_FC_CRED
      cond.condVal=_T("0.00")
      cond.operation=DBD_NE
      cond.relationship=DBD_OR
      cond=conditions.AddCondition()
      cond.colNum=JDT1_BALANCE_DUE_SC_DEB
      cond.condVal=_T("0.00")
      cond.operation=DBD_NE
      cond.relationship=DBD_OR
      cond=conditions.AddCondition()
      cond.colNum=JDT1_BALANCE_DUE_SC_CRED
      cond.condVal=_T("0.00")
      cond.operation=DBD_NE
      cond.bracketClose=true
      cond.relationship=DBD_AND
      cond=conditions.AddCondition()
      cond.bracketOpen=true
      cond.tableIndex=1
      cond.colNum=OJDT_TRANS_TYPE
      cond.condVal=SBOString(OPEN_BLNC_TYPE)
      cond.operation=DBD_EQ
      cond.relationship=DBD_OR
      cond=conditions.AddCondition()
      cond.tableIndex=1
      cond.colNum=OJDT_TRANS_TYPE
      cond.condVal=SBOString(CLOSE_BLNC_TYPE)
      cond.operation=DBD_EQ
      cond.bracketClose=true
      cond.relationship=DBD_AND
      cond=conditions.AddCondition()
      cond.bracketOpen=true
      cond.tableIndex=2
      cond.colNum=ITR1_SRC_OBJ_TYPE
      cond.condVal=SBOString(OPEN_BLNC_TYPE)
      cond.operation=DBD_EQ
      cond.relationship=DBD_OR
      cond=conditions.AddCondition()
      cond.tableIndex=2
      cond.colNum=ITR1_SRC_OBJ_TYPE
      cond.condVal=SBOString(CLOSE_BLNC_TYPE)
      cond.operation=DBD_EQ
      cond.bracketClose=true
      cond.relationship=DBD_AND
      cond=conditions.AddCondition()
      cond.tableIndex=3
      cond.condVal=JDT
      cond.colNum=OITR_INIT_OBJ_TYPE
      cond.operation=DBD_EQ
      sboErr=DBD_GetInNewFormat(dagJDT1,dagRes)
      if sboErr
         if sboErr==-2028
            sboErr=0
         end

         return sboErr
      end

      dagUpdate = PDAG.new
      updStruct = []

      condStruct = []

      pResCol = DBD_ResColumns.new


      numOfRecon=dagRes.GetRecordCount()
      dagUpdate=OpenDAG(JDT,ao_Arr1)
      i=0
      while (i<numOfRecon) do
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
         dagRes.GetColStr(condStruct[0].condVal,2,i)
         condStruct[0].operation=DBD_EQ
         condStruct[0].relationship=DBD_AND
         condStruct[1].Clear()
         condStruct[1].tableIndex=0
         condStruct[1].colNum=JDT1_LINE_ID
         dagRes.GetColStr(condStruct[1].condVal,3,i)
         condStruct[1].operation=DBD_EQ
         DBD_SetDAGCond(dagUpdate,condStruct,2)
         sboErr=DBD_UpdateCols(dagUpdate)
         if sboErr&&sboErr!=-2028
            return sboErr
         end

         dagUpdate.ClearQueryParams()

         (i+=1;i-2)
      end

      i=0
      while (i<numOfRecon) do
         dagRes.GetColLong(srcObjTyp,4,i)
         if srcObjTyp==CLOSE_BLNC_TYPE
            tables[0].tableCode=bizEnv.ObjectToTable(ITR,ao_Arr1)
            tables[1].tableCode=bizEnv.ObjectToTable(JDT,ao_Arr1)
            tables[1].doJoin=false
            DBD_SetTablesList(dagUpdate,tables,2)
            updStruct[0].Clear()
            updStruct[0].colNum=ITR1_TRANS_LINE_ID
            updStruct[0].updateVal=0
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
            dagRes.GetColStr(condStruct[0].condVal,2,i)
            condStruct[0].operation=DBD_EQ
            condStruct[0].relationship=DBD_AND
            condStruct[1].Clear()
            condStruct[1].tableIndex=1
            condStruct[1].colNum=JDT1_LINE_ID
            condStruct[1].condVal=0
            condStruct[1].operation=DBD_EQ
            condStruct[1].relationship=DBD_AND
            condStruct[2].Clear()
            condStruct[2].tableIndex=0
            condStruct[2].colNum=ITR1_RECON_NUM
            dagRes.GetColStr(condStruct[2].condVal,0,i)
            condStruct[2].operation=DBD_EQ
            condStruct[2].relationship=DBD_AND
            condStruct[3].Clear()
            condStruct[3].tableIndex=0
            condStruct[3].colNum=ITR1_LINE_SEQUENCE
            dagRes.GetColStr(condStruct[3].condVal,1,i)
            condStruct[3].operation=DBD_EQ
            DBD_SetDAGCond(dagUpdate,condStruct,4)
            sboErr=DBD_UpdateCols(dagUpdate)
            if sboErr&&sboErr!=-2028
               return sboErr
            end

            dagUpdate.ClearQueryParams()
         end


         (i+=1;i-2)
      end

      i=0
      while (i<numOfRecon) do
         dagRes.GetColLong(srcObjTyp,4,i)
         if srcObjTyp==OPEN_BLNC_TYPE
            tables[0].tableCode=bizEnv.ObjectToTable(ITR,ao_Arr1)
            tables[1].tableCode=bizEnv.ObjectToTable(JDT,ao_Arr1)
            tables[1].doJoin=false
            DBD_SetTablesList(dagUpdate,tables,2)
            updStruct[0].Clear()
            updStruct[0].colNum=ITR1_TRANS_LINE_ID
            updStruct[0].updateVal=1
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
            dagRes.GetColStr(condStruct[0].condVal,2,i)
            condStruct[0].operation=DBD_EQ
            condStruct[0].relationship=DBD_AND
            condStruct[1].Clear()
            condStruct[1].tableIndex=1
            condStruct[1].colNum=JDT1_LINE_ID
            condStruct[1].condVal=1
            condStruct[1].operation=DBD_EQ
            condStruct[1].relationship=DBD_AND
            condStruct[2].Clear()
            condStruct[2].tableIndex=0
            condStruct[2].colNum=ITR1_RECON_NUM
            dagRes.GetColStr(condStruct[2].condVal,0,i)
            condStruct[2].operation=DBD_EQ
            condStruct[2].relationship=DBD_AND
            condStruct[3].Clear()
            condStruct[3].tableIndex=0
            condStruct[3].colNum=ITR1_LINE_SEQUENCE
            dagRes.GetColStr(condStruct[3].condVal,1,i)
            condStruct[3].operation=DBD_EQ
            DBD_SetDAGCond(dagUpdate,condStruct,4)
            sboErr=DBD_UpdateCols(dagUpdate)
            if sboErr&&sboErr!=-2028
               return sboErr
            end

            dagUpdate.ClearQueryParams()
         end


         (i+=1;i-2)
      end

      i=0
      while (i<numOfRecon) do
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
         dagRes.GetColStr(condStruct[0].condVal,0,i)
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
         condStruct[2].condVal=0
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
         if sboErr&&sboErr!=-2028
            return sboErr
         end

         dagUpdate.ClearQueryParams()

         (i+=1;i-2)
      end

      i=0
      while (i<numOfRecon) do
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
         dagRes.GetColStr(condStruct[0].condVal,0,i)
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
         condStruct[2].condVal=0
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
         if sboErr&&sboErr!=-2028
            return sboErr
         end

         dagUpdate.ClearQueryParams()

         (i+=1;i-2)
      end

      i=0
      while (i<numOfRecon) do
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
         dagRes.GetColStr(condStruct[0].condVal,0,i)
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
         if sboErr&&sboErr!=-2028
            return sboErr
         end

         dagUpdate.ClearQueryParams()

         (i+=1;i-2)
      end

      i=0
      while (i<numOfRecon) do
         tables[0].tableCode=bizEnv.ObjectToTable(JDT,ao_Arr1)
         tables[1].tableCode=bizEnv.ObjectToTable(ITR,ao_Arr1)
         tables[1].doJoin=false
         DBD_SetTablesList(dagUpdate,tables,2)
         updStruct[0].Clear()
         updStruct[0].colNum=JDT1_BALANCE_DUE_DEBIT
         updStruct[0].updateVal=0
         updStruct[1].Clear()
         updStruct[1].colNum=JDT1_BALANCE_DUE_FC_DEB
         updStruct[1].updateVal=0
         updStruct[2].Clear()
         updStruct[2].colNum=JDT1_BALANCE_DUE_SC_DEB
         updStruct[2].updateVal=0
         updStruct[3].Clear()
         updStruct[3].colNum=JDT1_BALANCE_DUE_CREDIT
         updStruct[3].updateVal=0
         updStruct[4].Clear()
         updStruct[4].colNum=JDT1_BALANCE_DUE_FC_CRED
         updStruct[4].updateVal=0
         updStruct[5].Clear()
         updStruct[5].colNum=JDT1_BALANCE_DUE_SC_CRED
         updStruct[5].updateVal=0
         DBD_SetDAGUpd(dagUpdate,updStruct,6)
         condStruct[0].Clear()
         condStruct[0].tableIndex=1
         condStruct[0].colNum=ITR1_RECON_NUM
         dagRes.GetColStr(condStruct[0].condVal,0,i)
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
         if sboErr&&sboErr!=-2028
            return sboErr
         end

         dagUpdate.ClearQueryParams()

         (i+=1;i-2)
      end

      return 0
   end

   def ValidateReport340()
      trace("ValidateReport340")
      sboErr=ooNoErr
      bizEnv = CBizEnv.new=GetEnv()
      dagJDT = PDAG.new=GetDAG()
      residenNumOrig = SBOString.new
      residenNumNew = SBOString.new
      operatCodeOrig = SBOString.new
      operatCodeNew = SBOString.new
      if GetCurrentBusinessFlow()==bf_Create
         return sboErr
      end

      dagJDT.GetColStr(residenNumOrig,OJDT_RESIDENCE_NUM,0,true,true)
      dagJDT.GetColStr(residenNumNew,OJDT_RESIDENCE_NUM,0)
      if residenNumOrig.GetLength()>0&&residenNumOrig.Compare(residenNumNew)!=0&&IsManualJE(dagJDT)==false
         SetErrorField(OJDT_RESIDENCE_NUM)
         Message(GO_OBJ_ERROR_MSGS(JDT),22,nil,OO_ERROR)
         return ooInvalidObject
      end

      dagJDT.GetColStr(operatCodeOrig,OJDT_OPERATION_CODE,0,true,true)
      dagJDT.GetColStr(operatCodeNew,OJDT_OPERATION_CODE,0)
      if operatCodeOrig.GetLength()>0&&operatCodeOrig.Compare(operatCodeNew)!=0&&IsManualJE(dagJDT)==false
         SetErrorField(OJDT_OPERATION_CODE)
         Message(GO_OBJ_ERROR_MSGS(JDT),23,nil,OO_ERROR)
         return ooInvalidObject
      end

      return sboErr
   end

   def UpgradeFederalTaxIdOnJERow()
      bizEnv = CBizEnv.new=GetEnv()
      stmt = DBQRetrieveStatement.new(bizEnv)
      dagRes = APDAG.new

      cardCode = SBOString.new
      cardType = SBOString.new
      crdTaxID = SBOString.new
      begin
         tJDT1 = DBQTable.new=stmt.From(bizEnv.ObjectToTable(JDT,ao_Arr1))
         tOCRD = DBQTable.new=stmt.Join(bizEnv.ObjectToTable(CRD,ao_Main),tJDT1,DBQ_JT_INNER_JOIN)
         stmt.On(tOCRD).Col(tJDT1,JDT1_SHORT_NAME).EQ().Col(tOCRD,OCRD_CARD_CODE)
         tCRD1 = DBQTable.new=stmt.Join(bizEnv.ObjectToTable(CRD,ao_Arr1),tOCRD,DBQ_JT_LEFT_OUTER_JOIN)
         stmt.On(tCRD1).Col(tOCRD,OCRD_CARD_CODE).EQ().Col(tCRD1,CRD1_CARD_CODE).And().Col(tOCRD,OCRD_SHIP_TO_DEFAULT).EQ().Col(tCRD1,CRD1_ADDRESS_NAME)
         stmt.Select().Col(tOCRD,OCRD_CARD_CODE)
         stmt.Select().Col(tOCRD,OCRD_CARD_TYPE)
         stmt.Select().Col(tOCRD,OCRD_TAX_ID_NUMBER).As(_T("OCRDLicTradNum"))
         stmt.Select().Col(tCRD1,CRD1_TAX_ID_NUMBER).As(_T("CRD1LicTradNum"))
         stmt.Distinct()
         stmt.Where().Col(tJDT1,JDT1_ACCT_NUM).NE().Col(tJDT1,JDT1_SHORT_NAME).And().Col(tJDT1,JDT1_TRANS_TYPE).EQ().Val(JDT).And().OpenBracket().Col(tOCRD,OCRD_TAX_ID_NUMBER).IsNotNull().Or().Col(tCRD1,CRD1_TAX_ID_NUMBER).IsNotNull().CloseBracket()
         countRes=stmt.Execute(dagRes)
      rescue DBMException=>e
         return e.GetCode()
      end

      ii=0
      while (ii<countRes) do
         crdTaxID=EMPTY_STR
         dagRes.GetColStr(cardCode,dagRes.GetColumnByAlias(OCRD_CARD_CODE_ALIAS),ii)
         dagRes.GetColStr(cardType,dagRes.GetColumnByAlias(OCRD_CARD_TYPE_ALIAS),ii)
         cardCode.Trim()
         cardType.Trim()
         if cardType==VAL_CUSTOMER&&!GetEnv().IsLatinAmericaTaxSystem()
            dagRes.GetColStr(crdTaxID,dagRes.GetColumnByAlias(_T("CRD1LicTradNum")),ii)
         end

         if crdTaxID.IsSpacesStr()
            dagRes.GetColStr(crdTaxID,dagRes.GetColumnByAlias(_T("OCRDLicTradNum")),ii)
         end

         crdTaxID.Trim()
         ustmt = DBQUpdateStatement.new(bizEnv)
         begin
            tJDT1 = DBQTable.new=ustmt.Update(bizEnv.ObjectToTable(JDT,ao_Arr1))
            ustmt.Set(JDT1_TAX_ID_NUMBER).Val(crdTaxID)
            ustmt.Where().Col(tJDT1,JDT1_ACCT_NUM).NE().Col(tJDT1,JDT1_SHORT_NAME).And().Col(tJDT1,JDT1_SHORT_NAME).EQ().Val(cardCode).And().Col(tJDT1,JDT1_TRANS_TYPE).EQ().Val(JDT)
            ustmt.Execute()
         rescue DBMException=>e
            return e.GetCode()
         end


         (ii+=1;ii-2)
      end

      objArray = []
      =""
      objNum=0
      while (objArray[objNum]!=NOB) do
         ustmt = DBQUpdateStatement.new(bizEnv)
         begin
            tJDT1 = DBQTable.new=ustmt.Update(bizEnv.ObjectToTable(JDT,ao_Arr1))
            tOINV = DBQTable.new=ustmt.Update(bizEnv.ObjectToTable(objArray[objNum],ao_Main))
            ustmt.Set(JDT1_TAX_ID_NUMBER).Col(tOINV,OINV_TAX_ID_NUMBER)
            ustmt.Where().Col(tOINV,OINV_TRANS_NUM).EQ().Col(tJDT1,JDT1_TRANS_ABS).And().Col(tJDT1,JDT1_ACCT_NUM).NE().Col(tJDT1,JDT1_SHORT_NAME).And().Col(tOINV,OINV_CARD_CODE).EQ().Col(tJDT1,JDT1_SHORT_NAME)
            ustmt.Execute()
         rescue DBMException=>e
            return e.GetCode()
         end


         (objNum+=1;objNum-2)
      end

      return 0
   end

   def ReconcileDeferredTaxAcctLines()
      sboErr=ooNoErr
      bizEnv = CBizEnv.new=GetEnv()
      dagJDT = PDAG.new=GetDAG()
      dagJDT1 = PDAG.new=GetArrayDAG(ao_Arr1)
      date = Date.new


      stornoNum = SBOString.new
      dagStornoJDT1 = APCompanyDAG.new
      interimType = eInterimAcctType.new
      dagJDT.GetColStr(stornoNum,OJDT_STORNO_TO_TRANS)
      if stornoNum.IsEmpty()||!bizEnv.IsLocalSettingsFlag(lsf_EnableDeferredTax)
         return ooNoErr
      end

      dagJDT.GetColStr(date,OJDT_REF_DATE)
      bizEnv.OpenDAG(dagStornoJDT1,JDT,ao_Arr1)
      sboErr=bizEnv.GetByOneKey(dagStornoJDT1,JDT1_KEYNUM_PRIMARY,stornoNum)
      if sboErr
         return sboErr
      end

      deferredMM = CSystemMatchManager.new(bizEnv,false,date.GetString(),JDT,stornoNum,rt_Reversal)

      rec=0
      while (rec<dagJDT1.GetRealSize(dbmDataBuffer)) do
         dagJDT1.GetColLong(tmpL,JDT1_INTERIM_ACCT_TYPE,rec)
         interimType=tmpL
         if interimType==IAT_DeferTaxInterim_Type
            dagJDT1.GetColLong(transId,JDT1_TRANS_ABS,rec)
            dagJDT1.GetColLong(lineId,JDT1_LINE_ID,rec)
            deferredMM.AddMatchDataLine(transId,lineId)
         end


         (rec+=1)
      end

      rec=0
      while (rec<dagStornoJDT1.GetRealSize(dbmDataBuffer)) do
         dagStornoJDT1.GetColLong(tmpL,JDT1_INTERIM_ACCT_TYPE,rec)
         interimType=tmpL
         if interimType==IAT_DeferTaxInterim_Type
            sboErr=CManualMatchManager.CancelAllReconsOfJournalLine(bizEnv,stornoNum.strtol(),rec,false,date.GetString())
            if sboErr
               return sboErr
            end

            dagStornoJDT1.GetColLong(transId,JDT1_TRANS_ABS,rec)
            dagStornoJDT1.GetColLong(lineId,JDT1_LINE_ID,rec)
            deferredMM.AddMatchDataLine(transId,lineId)
         end


         (rec+=1)
      end

      sboErr=deferredMM.Reconcile()
      return sboErr
   end


   @calculationSystAmmountOfTrans = SBOErr.new()





























































































   @completeWTInfo = SBOErr.new()
   @completeWTLine = SBOErr.new()
   @wTGetBpCode = SBOString.new()


   @wTGetCurrency = SBOString.new()








   @setDebitCreditField = SBOErr.new()


   @reconcileCertainLines = SBOErr.new()
   @reconcileDeferredTaxAcctLines = SBOErr.new()








   @completeJdtLine = SBOErr.new()
   @completeVatLine = SBOErr.new()
   @complateStampLine = SBOErr.new()
   @completeTrans = SBOErr.new()
   @completeForeignAmount = SBOErr.new()








   @getSeqParam = CSequenceParameter.new()












   @setToZeroNullLineTypeCols = SBOErr.new()
   @setToZeroOldLineTypeCols = SBOErr.new()






























   @getCreateDate = Date.new()






















































   @m_taxAdaptor = CTaxAdaptorJournalEntry.new








   @upgradeBoeActs = SBOErr.new()


   @fixVendorsAndSpainBoeBalance = SBOErr.new()
   @upgradePeriodIndic = SBOErr.new()


   @m_jrnlKeys = SJournalKeys.new
   @validateReportEU = SBOErr.new()
   @validateReport347 = SBOErr.new()


   @validateVatReportTransType = SBOErr.new()
   @validateBPLNumberingSeries = SBOErr.new()
   @isBalancedByBPL = SBOErr.new()
   @upgradeOJDTCreatedByForWOR = SBOErr.new()
   @upgradeOJDTUpdateDocType = SBOErr.new()


   @upgradeOJDTWithFolio = SBOErr.new()
   @upgradeJDTCreateDate = SBOErr.new()


   @upgradeJDTCanceledDeposit = SBOErr.new()
   @upgradeJDT1VatLineToNo = SBOErr.new()
   @upgradeYearTransfer = SBOErr.new()
   @upgradePaymentFieldsForIRU = SBOErr.new()
   @repairTaxTable = SBOErr.new()
   @upgradeJDTCEEPerioEndReconcilations = SBOErr.new()


   @upgradeJDTIndianAutoVat = SBOErr.new()




   @updateWTInfo = SBOErr.new()




   @getJDTReconStatus = SBOString.new()


   @onCanJDT2Update = SBOErr.new()
   @checkWTValid = SBOErr.new()
   @checkMultiBP = SBOErr.new()














   @getBPLineCurrency = SBOString.new()
   @getCRDDag = SBOErr.new()








   @setCurrForAutoCompleteDOC5 = SBOErr.new()


   @upgradeERDBaseTrans = SBOErr.new()
   @upgradeERDBaseTransFromBackup = SBOErr.new()


   @upgradeERDBaseTransFromRef3 = SBOErr.new()










   @m_reconcileBPLines
   @m_isInCancellingAcctRecon
   @m_reconAcctSet = std::set.new
   @m_isVatJournalEntry
   @m_stornoExtraInfoCreator = CJDTStornoExtraInfoCreator.new
   @m_pSequenceParameter = CSequenceParameter.new




   @m_WithholdingTaxMng = CWithholdingTaxManager.new




   @repairEquVatRateOfJDT1 = SBOErr.new()










   @validateReport340 = SBOErr.new()


   @m_digitalSignature = CJournalEntryDigitalSignature.new
   @upgradeFederalTaxIdOnJERow = SBOErr.new()






   @m_isPostingPreviewMode
   @m_bZeroBalanceDue
   @m_isPostingTemplate
   @upgradeWorkOrderStep1 = SBOErr.new()
   @upgradeWorkOrderStep2 = SBOErr.new()
   @upgradeWorkOrderStep3 = SBOErr.new()
   @upgradeWorkOrderStep4 = SBOErr.new()
   @upgradeLandedCosErr = SBOErr.new()
   @upgradeWorkOrderErr = SBOErr.new()

   @validateHeaderLocation = SBOErr.new()


   @completeLocations = SBOErr.new()






end
