class CTransactionJournalObject < CSystemBusinessObject
   def IsDeferredAble()
      return false
   end

   def IsSmallDifferenceAble()
      return false
   end

   def IsWithHoldingAble()
      return VF_JEWHT(GetEnv())
   end

   def self.SetJournalDocumentNumber(bizEnv,bizObject,dagJDT)
      ooErr=noErr
      num=0

      dagOBJ=bizObject.GetDAG()
      dag=dagJDT
      bizObject.SetExCommand3(ooEx3DontTouchNextNum,fa_Clear)
      dag.GetColLong(series,OJDT_SERIES)
      if !series
         dag.GetColStr(refDate,OJDT_REF_DATE)
         if refDate.Trim().IsSpacesStr()
            DBM_DATE_Get(refDate,bizEnv)
         end

         series=bizEnv.GetDefaultSeriesByDate(bizObject.GetBPLId(),SBOString(JDT),refDate)
         dag.SetColLong(series,OJDT_SERIES,0)
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

      bizJDT=bizEnv.CreateBusinessObject(SBOString(JDT))
      bizJDT.SetSeries(series)
      ooErr=bizJDT.GetNextSerial(true)
      if ooErr
         return ooErr
      end

      num=bizJDT.GetNextNum()
      bizJDT.Destroy()
      bizJDT=nil
      dag.SetColLong(num,OJDT_NUMBER,0)
      return ooErr
   end

   def self.UpdateAccountBalance(bizEnv,dagACT,dagJDT,dagJDT1)
      ooErr=noErr
      ct=dagJDT1.GetRecordCount()
      i=0
      while (i<ct) do
         dagJDT1.GetColStrAndTrim(actKey,JDT1_ACCT_NUM,i)
         ooErr=dagACT.FindColStr(actKey,OACT_ACCOUNT_CODE,0,row)
         if ooErr
            return ooErr
         end

         dagACT.GetColMoney(actAmount,OACT_CURRENT_BALANCE,row)
         dagACT.GetColMoney(fActAmount,OACT_F_BALANCE,row)
         dagACT.GetColMoney(sysActAmount,OACT_S_BALANCE,row)
         dagJDT1.GetColMoney(sum,JDT1_CREDIT,i)
         dagJDT1.GetColMoney(sysSum,JDT1_SYS_CREDIT,i)
         dagJDT1.GetColMoney(frgnSum,JDT1_FC_CREDIT,i)
         dagJDT1.GetColMoney(sumDebit,JDT1_DEBIT,i)
         dagJDT1.GetColMoney(sysSumDebit,JDT1_SYS_DEBIT,i)
         dagJDT1.GetColMoney(frgnSumDebit,JDT1_FC_DEBIT,i)
         sum-=sumDebit
         frgnSum-=frgnSumDebit
         sysSum-=sysSumDebit
         add=true
         dagJDT.GetColStr(credit,JDT1_DEBIT_CREDIT,i)
         if credit==VAL_CREDIT
            add=!add
         end

         if bizEnv.GetBalanceStyle()==balanceTrueStyle
            add=!add
         end

         if add
            actAmount+=sum
            fActAmount+=frgnSum
            sysActAmount+=sysSum
         else
            actAmount-=sum
            fActAmount-=frgnSum
            sysActAmount-=sysSum
         end

         currStr=""
         dagACT.GetColStr(currStr,OACT_ACT_CURR,row)
         _STR_LRTrim(currStr)
         if !GNCoinCmp(currStr,BAD_CURRENCY_STR)
            fActAmount.SetToZero()
         end

         dagACT.SetColMoney(actAmount,OACT_CURRENT_BALANCE,row)
         dagACT.SetColMoney(sysActAmount,OACT_S_BALANCE,row)
         dagACT.SetColMoney(fActAmount,OACT_F_BALANCE,row)

         (i+=1;i-2)
      end

      return ooErr
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

   def SetStornoExtraInfoCreator(stornoExtraInfoCreator)
      m_stornoExtraInfoCreator=stornoExtraInfoCreator
   end

   def self.GetOcrCodeCol(dim)
      nCol=""
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
      nCol=""
      return nCol[dim]
   end

   def GetWithholdingTaxManager()
      return m_WithholdingTaxMng
   end

   def SetPostingPreviewMode(enable = true)
      m_isPostingPreviewMode=enable
   end

   def IsPostingPreviewMode()
      return m_isPostingPreviewMode
   end

   def SetIsPostingTemplate(isPostingTemplate)
      m_isPostingTemplate=isPostingTemplate
   end

   def GetIsPostingTemplate()
      return m_isPostingTemplate
   end

   def initialize(other)
      super(other)
      @m_digitalSignature = other.GetEnv()

   end

   def isValidMatType(mat_type)
      if (mat_type!=0)&&(mat_type!=-1)
         return true
      else
         return false
      end

   end

   def isValidCENVAT(cenvat)
      if (cenvat!=0)&&(cenvat!=-1)
         return true
      else
         return false
      end

   end

   def SetZeroBalanceDueForCentralizedPayment(set = true)
      @m_bZeroBalanceDue=set
   end

   def IsZeroBalanceDueForCentralizedPayment()
      return @m_bZeroBalanceDue
   end


end
