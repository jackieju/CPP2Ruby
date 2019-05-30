class CJdtODHelper
   def initialize(bo)
      @m_bo = bo

   end

   def ODRefDateChange()
      ooErr=noErr
      bizEnv=@m_bo.GetEnv()
      objId=@m_bo.GetID().strtol()
      dagJDT=@m_bo.GetDAG(objId,ao_Main)
      dagJDT.GetColStrAndTrim(refDateStr,OJDT_REF_DATE)
      if refDateStr.Trim().IsSpacesStr()
         if tmpDate.SetCurrentDate(bizEnv)==noErr
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
      ooErr=noErr
      bizEnv=@m_bo.GetEnv()
      objId=@m_bo.GetID().strtol()
      dagJDT=@m_bo.GetDAG(objId,ao_Main)
      dagJDT1=@m_bo.GetDAG(objId,ao_Arr1)
      dagJDT.GetColStrAndTrim(headerMemo,OJDT_MEMO)
      jdt1Rec=dagJDT1.GetRealSize(dbmDataBuffer)
      i=0
      while (i<jdt1Rec) do
         dagJDT1.SetColStr(headerMemo,JDT1_LINE_MEMO,i)

         (i+=1)
      end

      return ooErr
   end


end
