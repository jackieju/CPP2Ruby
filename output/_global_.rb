def OJDTWriteErrorMessage(bizObject)
   trace("OJDTWriteErrorMessage")
   dagJDT1=nil
   tmpStr=""
   path=""
   msg=""
   colArr=""
   dagJDT1=bizObject.GetDAGNoOpen(SBOString(JDT),ao_Arr1)
   DAG_GetCount(dagJDT1,records)
   buffer=TCHAR.new[150]
   i=0
   while (colArr[i]!=-1) do
      dagJDT1.GetColAttributes(colArr[i],fldInfo,false)
      _STR_strcpy(tmpStr,fldInfo.alias)
      _STR_LRTrim(tmpStr)
      _STR_strcat(buffer,tmpStr)
      _STR_strcat(buffer,_T("\t"))

      (i+=1;i-2)
   end

   _STR_strcat(buffer,_T("\r\n"))
   _MEM_renew_raw(buffer,TCHAR,buffer.size+150,150)
   rec=0
   while (rec<records) do
      i=0
      while (colArr[i]!=-1) do
         if i==0
            dagJDT1.GetColStr(tmpStr,colArr[i],rec)
         else
            dagJDT1.GetColMoney(sum,colArr[i],rec,DBM_NOT_ARRAY)
            if sum.IsZero()
               tmpStr[0]='\0'
            else
               MONEY_ToText(sum,tmpStr,RC_SUM,SPACE_STR,bizObject.GetEnv())
            end

         end

         _STR_LRTrim(tmpStr)
         _STR_strcat(buffer,tmpStr)
         _STR_strcat(buffer,_T("\t"))

         (i+=1;i-2)
      end

      _STR_strcat(buffer,_T("\r\n"))
      _MEM_renew_raw(buffer,TCHAR,buffer.size+150,buffer.size+1)

      (rec+=1;rec-2)
   end

   _STR_LRTrim(buffer)
   _FILE_GetLocalTempPath(_FILE_PATH_MAX,path)
   _STR_strcat(path,_T("transaction.txt"))
   _FILE_BufferToFile(path,buffer,true)
   buffer.__delete
   cMessagesManager.getHandle().Message(_1_APP_MSG_FIN_OO_TRANSACTION_NOT_BALANCED,EMPTY_STR,bizObject)
   return ooTransNotBalanced
end


ResTax1AbsEntry = 0
ResTax1TaxCode = 1
ResTax1EqPercent = 2
ResJdt1TransId = 3
ResJdt1Line_ID = 4
Dts_None = 0
Dts_Skip = 1
Dts_Deferred = 2
Dts_Invalid = 3

