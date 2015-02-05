class CJDTDeferredTaxUtil
   def InitDeferredTaxStatus()
      dagJDT=m_bo.GetDAG(JDT)


      dagJDT.GetColStr(autoVat,OJDT_AUTO_VAT,0)
      autoVat.Trim()
      dagJDT.GetColStr(deferredTax,OJDT_DEFERRED_TAX,0)
      deferredTax.Trim()
      if autoVat==VAL_NO&&deferredTax==VAL_YES
         m_dts=dts_Invalid
         return m_dts

      end

      if autoVat==VAL_NO&&deferredTax==VAL_YES
         m_dts=dts_Invalid
         return m_dts

      end

      if deferredTax==VAL_NO
         m_dts=dts_Skip
         return m_dts

      end

      m_dts=dts_Deferred
      return m_dts

   end

   def GetDeferredTaxStatus()
      if m_dts!=dts_None
         return m_dts

      end

      return InitDeferredTaxStatus()

   end

   def IsValidDeferredTaxStatus()
      return GetDeferredTaxStatus()!=dts_Invalid

   end

   def IsValidBPLines()
      isValidLine=true

      dagJDT1=m_bo.GetDAG(JDT

      bpLineCount=0

      recJDT1=dagJDT1.GetRealSize(dbmDataBuffer)


      rec=0

      begin
         dagJDT1.GetColStr(acct,JDT1_ACCT_NUM,rec)
         dagJDT1.GetColStr(shortname,JDT1_SHORT_NAME,rec)
         acct.Trim()
         shortname.Trim()
         if acct!=shortname
            bpLineCount+=1

         end



         rec+=1
      end while (rec<recJDT1)

      if bpLineCount!=1
         isValidLine=false

      end

      return isValidLine

   end

   def IsBPWithEqTax(bpCode, bizEnv)

      bizEnv.OpenDAG(dagCRD,SBOString(CRD))
      dagCRD.GetBySegment(OACT_KEYNUM_PRIMARY,bpCode)

      dagCRD.GetColStr(eqTax,OCRD_EQUALIZATION)
      eqTax.Trim()
      return eqTax==VAL_YES

   end

   def SkipValidate()
      return GetDeferredTaxStatus()==dts_Skip

   end

   def IsValid()
      if !IsValidDeferredTaxStatus()
         return false

      end

      if SkipValidate()
         return true

      end

      if !IsValidBPLines()
         CMessagesManager::GetHandle().Message(_147_APP_MSG_FIN_JDT_DEFERRED_TAX_NO_MULTI_BP,EMPTY_STR,m_bo)
         return false

      end

      if IsBPWithEqTax()
         CMessagesManager::GetHandle().Message(_147_APP_MSG_FIN_JDT_DEFERRED_TAX_BP_WITH_EQ_TAX,EMPTY_STR,m_bo)
         return false

      end

      if !IsValidDeferredTax()
         CMessagesManager::GetHandle().Message(_147_APP_MSG_FIN_JDT_DEFERRED_TAX_WITH_EQ_TAX,EMPTY_STR,m_bo)
         return false

      end

      return true

   end


end
false
