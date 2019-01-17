class CJdtODHelper
   def ODRefDateChange()
      ooErr=0
      bizEnv=@m_bo.GetEnv()
      objId=@m_bo.GetID().strtol()
      dagJDT=@m_bo.GetDAG(objId,ao_Main)
      dagJDT.GetColStrAndTrim(refDateStr,OJDT_REF_DATE)
      if refDateStr.Trim().IsSpacesStr()
         if tmpDate.SetCurrentDate(bizEnv)==0
            refDateStr=tmpDate.GetString()
         end

      end

      dagJDT.SetColStr(refDateStr,OJDT_TAX_DATE,0)
      if VF_SupplCode(bizEnv)
         pManager=bizEnv.GetSupplCodeManager()
         ooErr=pManager.LoadDfltCodeToDag(@m_bo,Date(refDateStr.GetBuffer()))
      end

      return ooErr
   end

   def ODMemoChange()
      ooErr=0
      bizEnv=@m_bo.GetEnv()
      objId=@m_bo.GetID().strtol()
      dagJDT=@m_bo.GetDAG(objId,ao_Main)
      dagJDT1=@m_bo.GetDAG(objId,ao_Arr1)
      dagJDT.GetColStrAndTrim(headerMemo,OJDT_MEMO)
      jdt1Rec=dagJDT1.GetRealSize(dbmDataBuffer)
      i=0
      begin
         dagJDT1.SetColStr(headerMemo,JDT1_LINE_MEMO,i)

         (i+=1)
      end while (i<jdt1Rec)

      return ooErr
   end


end
