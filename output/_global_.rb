def OJDTWriteErrorMessage(bizObject)
   trace("OJDTWriteErrorMessage")
   dagJDT1 = PDAG.new=nil
   fldInfo = DBM_CA.new
   sum = MONEY.new
   buffer = TCHAR.new
   tmpStr = []
   =""
   path = []
   =""
   msg = []
   =""


   colArr = []
   =""
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
   CMessagesManager.GetHandle().Message(_1_APP_MSG_FIN_OO_TRANSACTION_NOT_BALANCED,EMPTY_STR,bizObject)
   return ooTransNotBalanced
end


JDT1_TRANS_ABS = 0
JDT1_LINE_ID = 1
JDT1_ACCT_NUM = 2
JDT1_DEBIT = 3
JDT1_CREDIT = 4
JDT1_SYS_CREDIT = 5
JDT1_SYS_DEBIT = 6
JDT1_FC_DEBIT = 7
JDT1_FC_CREDIT = 8
JDT1_FC_CURRENCY = 9
JDT1_DUE_DATE = 10
JDT1_SRC_ABS_ID = 11
JDT1_SRC_LINE = 12
JDT1_SHORT_NAME = 13
JDT1_INTR_MATCH = 14
JDT1_EXTR_MATCH = 15
JDT1_CONTRA_ACT = 16
JDT1_LINE_MEMO = 17
JDT1_REF3_LINE = 18
JDT1_TRANS_TYPE = 19
JDT1_REF_DATE = 20
JDT1_REF2_DATE = 21
JDT1_REF1 = 22
JDT1_REF2 = 23
JDT1_CREATED_BY = 24
JDT1_BASE_REF = 25
JDT1_PROJECT = 26
JDT1_TRANS_CODE = 27
JDT1_OCR_CODE = 28
JDT1_TAX_DATE = 29
JDT1_SYSTEM_RATE = 30
JDT1_MTH_DATE = 31
JDT1_TO_MTH_SUM = 32
JDT1__USER_ = 33
JDT1_BATCH_NUM = 34
JDT1_FINANCE_PERIOD = 35
JDT1_REL_TRANS_ABS = 36
JDT1_REL_LINE_ID = 37
JDT1_REL_TYPE = 38
JDT1_LOG_INSTANCE = 39
JDT1_VAT_GROUP = 40
JDT1_BASE_SUM = 41
JDT1_VAT_PERCENT = 42
JDT1_INDICATOR = 43
JDT1_ADJ_TRAN_PERIOD_13 = 44
JDT1_REVAL_SRC = 45
JDT1_OBJECT = 46
JDT1_VAT_DATE = 47
JDT1_PAYMENT_REF = 48
JDT1_SYS_BASE_SUM = 49
JDT1_MULT_MATCH = 50
JDT1_VAT_LINE = 51
JDT1_VAT_AMOUNT = 52
JDT1_SYS_VAT_AMOUNT = 53
JDT1_CLOSED = 54
JDT1_GROSS_VALUE = 55
JDT1_CHECK_ABS = 56
JDT1_LINE_TYPE = 57
JDT1_DEBIT_CREDIT = 58
JDT1_SEQUENCE_NR = 59
JDT1_STORNO_ACC = 60
JDT1_BALANCE_DUE_DEBIT = 61
JDT1_BALANCE_DUE_CREDIT = 62
JDT1_BALANCE_DUE_FC_DEB = 63
JDT1_BALANCE_DUE_FC_CRED = 64
JDT1_BALANCE_DUE_SC_DEB = 65
JDT1_BALANCE_DUE_SC_CRED = 66
JDT1_IS_NET = 67
JDT1_DUNNING_WIZ_BLOCKED = 68
JDT1_DUNNING_LEVEL = 69
JDT1_LAST_DUNNING_DATE = 70
JDT1_TAX_TYPE = 71
JDT1_TAX_POSTING_ACCOUNT = 72
JDT1_STA_CODE = 73
JDT1_STA_TYPE = 74
JDT1_TAX_CODE = 75
JDT1_VALID_FROM = 76
JDT1_GROSS_VALUE_FC = 77
JDT1_LEVEL_UPDATE_DATE = 78
JDT1_OCR_CODE2 = 79
JDT1_OCR_CODE3 = 80
JDT1_OCR_CODE4 = 81
JDT1_OCR_CODE5 = 82
JDT1_MI_ENTRY = 83
JDT1_MIV_ENTRY = 84
JDT1_CLSINTP = 85
JDT1_CENVAT_COM = 86
JDT1_MATERIAL_TYPE = 87
JDT1_POSTING_TYPE = 88
JDT1_VALID_FROM2 = 89
JDT1_VALID_FROM3 = 90
JDT1_VALID_FROM4 = 91
JDT1_VALID_FROM5 = 92
JDT1_LOCATION = 93
JDT1_WTAX_CODE = 94
JDT1_EQU_VAT_PERCENT = 95
JDT1_EQU_VAT_AMOUNT = 96
JDT1_SYS_EQU_VAT_AMOUNT = 97
JDT1_TOTAL_TAX = 98
JDT1_SYS_TOTAL_TAX = 99
JDT1_WT_LIABLE = 100
JDT1_WT_Line = 101
JDT1_WT_APPLIED = 102
JDT1_WT_APPLIED_SC = 103
JDT1_WT_APPLIED_FC = 104
JDT1_WT_SUM = 105
JDT1_WT_SUM_FC = 106
JDT1_WT_SUM_SC = 107
JDT1_PAYMENT_BLOCK = 108
JDT1_PAYMENT_BLOCK_REF = 109
JDT1_TAX_ID_NUMBER = 110
JDT1_INTERIM_ACCT_TYPE = 111
JDT1_DPR_ABS_ID = 112
JDT1_MATCH_REF = 113
JDT1_ORDERED = 114
JDT1_CUP = 115
JDT1_CIG = 116
JDT1_BPL_ID = 117
JDT1_BPL_NAME = 118
JDT1_VAT_REG_NUM = 119
JDT1_SUBLEDGERFLAG = 120


JDT1_KEYNUM_PRIMARY = 1
JDT1_KEYNUM_SHORT_NAME = 2
JDT1_KEYNUM_ACCOUNT = 3
JDT1_KEYNUM_TRANS_TYPE = 4
JDT1_KEYNUM_PROFIT_ID = 5
JDT1_KEYNUM_CURRENCY = 6
JDT1_KEYNUM_DUEDATE = 7
JDT1_KEYNUM_REFDATE = 8
JDT1_KEYNUM_INTRNMATCH = 9
JDT1_KEYNUM_JDT1BASEL = 10
JDT1_KEYNUM_JDT1CHECKA = 11


ResTax1AbsEntry = 0
ResTax1TaxCode = 1
ResTax1EqPercent = 2
ResJdt1TransId = 3
ResJdt1Line_ID = 4






















Dts_None = 0
Dts_Skip = 1
Dts_Deferred = 2
Dts_Invalid = 3


































































































































































































































