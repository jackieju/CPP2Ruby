class CJDTDeferredTaxUtil
   def self.IsBPWithEqTax(bpCode,bizEnv)
      bizEnv.OpenDAG(dagCRD,SBOString(CRD))
      dagCRD.GetBySegment(OACT_KEYNUM_PRIMARY,bpCode)
      dagCRD.GetColStr(eqTax,OCRD_EQUALIZATION)
      eqTax.Trim()
      return eqTax==VAL_YES
   end

   def IsValid()
      if !IsValidDeferredTaxStatus()
         return false
      end

      if SkipValidate()
         return true
      end

      if !IsValidBPLines()
         cMessagesManager.getHandle().Message(_147_APP_MSG_FIN_JDT_DEFERRED_TAX_NO_MULTI_BP,EMPTY_STR,@m_bo)
         return false
      end

      if IsBPWithEqTax()
         cMessagesManager.getHandle().Message(_147_APP_MSG_FIN_JDT_DEFERRED_TAX_BP_WITH_EQ_TAX,EMPTY_STR,@m_bo)
         return false
      end

      if !IsValidDeferredTax()
         cMessagesManager.getHandle().Message(_147_APP_MSG_FIN_JDT_DEFERRED_TAX_WITH_EQ_TAX,EMPTY_STR,@m_bo)
         return false
      end

      return true
   end

   def InitDeferredTaxStatus()
      dagJDT=@m_bo.GetDAG(JDT)
      dagJDT.GetColStr(autoVat,OJDT_AUTO_VAT,0)
      autoVat.Trim()
      dagJDT.GetColStr(deferredTax,OJDT_DEFERRED_TAX,0)
      deferredTax.Trim()
      if autoVat==VAL_NO&&deferredTax==VAL_YES
         @m_dts=dts_Invalid
         return @m_dts
      end

      if autoVat==VAL_NO&&deferredTax==VAL_YES
         @m_dts=dts_Invalid
         return @m_dts
      end

      if deferredTax==VAL_NO
         @m_dts=dts_Skip
         return @m_dts
      end

      @m_dts=dts_Deferred
      return @m_dts
   end

   def GetDeferredTaxStatus()
      if @m_dts!=dts_None
         return @m_dts
      end

      return InitDeferredTaxStatus()
   end

   def SkipValidate()
      return GetDeferredTaxStatus()==dts_Skip
   end

   def IsValidDeferredTaxStatus()
      return GetDeferredTaxStatus()!=dts_Invalid
   end

   def IsValidBPLines()
      isValidLine=true
      dagJDT1=@m_bo.GetDAG(JDT,ao_Arr1)
      bpLineCount=0
      recJDT1=dagJDT1.GetRealSize(dbmDataBuffer)
      rec=0
      begin
         dagJDT1.GetColStr(acct,JDT1_ACCT_NUM,rec)
         dagJDT1.GetColStr(shortname,JDT1_SHORT_NAME,rec)
         acct.Trim()
         shortname.Trim()
         if acct!=shortname
            (bpLineCount+=1;bpLineCount-2)
         end


         (rec+=1;rec-2)
      end while (rec<recJDT1)

      if bpLineCount!=1
         isValidLine=false
      end

      return isValidLine
   end

   def IsBPWithEqTax()
      dagJDT1=@m_bo.GetDAG(JDT,ao_Arr1)
      dagJDT1.GetColStr(bpCode,JDT1_SHORT_NAME,@m_bpLine)
      bpCode.Trim()
      bizEnv=@m_bo.GetEnv()
      return cJDTDeferredTaxUtil.isBPWithEqTax(bpCode,bizEnv)
   end

   def IsValidDeferredTax()
      return IsValidOnEqTax()
   end

   def IsValidOnEqTax()
      bizEnv=@m_bo.GetEnv()
      if !bizEnv.IsLocalSettingsFlag(lsf_EnableEqualizationVat)
         return true
      end

      isValidLine=true
      dagJDT1=@m_bo.GetDAG(JDT,ao_Arr1)
      bpLineCount=0
      recJDT1=dagJDT1.GetRealSize(dbmDataBuffer)
      taxGroupCache=bizEnv.GetTaxGroupCache()
      rec=0
      begin
         dagJDT1.GetColStr(vatLine,JDT1_VAT_LINE,rec)
         vatLine.Trim()
         if vatLine==VAL_YES
            dagJDT1.GetColStr(vatGroup,JDT1_VAT_GROUP,rec)
            vatGroup.Trim()
            taxGroupCache.GetAcctInfo(bizEnv,vatGroup,OVTG_EQU_VAT_ACCOUNT,eqTaxAcct)
            eqTaxAcct.Trim()
            if !eqTaxAcct.IsEmpty()
               isValidLine=false
               break
            end

         end


         (rec+=1;rec-2)
      end while (rec<recJDT1)

      return isValidLine
   end

   def initialize(bo)
      @m_bo = bo
      @m_bpLine = -1
      @m_dts = dts_None

   end

   def uninitialize()

   end


end
