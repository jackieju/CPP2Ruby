load 'output/_global_.rb'
# require '_global_.rb'
class CBusinessObject
    
    def save
    end
    def Create ( doAutoComplete = false,  cep = nil)
        # before_create
        # after_create
        # ...
    end
end
class CSystemBusinessObject < CBusinessObject
    def initialize(id,env)
    end
    def InitData()
    end
end
def trace(m)
    p m
end
load 'output/ctransactionjournalobject.rb'

=begin
__DBMC_DAG.h => DAG

SBOErr     CFixedAssetsDocument::CreateJournalEntry()
{
      SBOErr           sboErr = ooNoErr;
      PDAG       dagACQ = GetDAG();
      PDAG       dagACQ2 = GetArrayDAG(ao_Arr2);
      PDAG       dagJDT = GetDAG(JDT);
      PDAG       dagJDT1 = GetDAG(JDT, ao_Arr1);
      long       oldNextNum = 0;
      bool       firstTime = true;
     
      dagACQ->GetColLong(&oldNextNum, OACQ_NUM);
 
    DprAreaToJournalMgrMap::iterator it;
      for(it = m_journalMgrMap.begin(); it != m_journalMgrMap.end(); ++it)
      {
           CJournalManager* journalManager = it->second;
 
        CTransactionJournalObject*     jdtObject =
            static_cast<CTransactionJournalObject*>(GetEnv().CreateBusinessObject(SBOString(JDT)));
        AutoCleanBOHandler  jdtCleaner ((CBusinessObject*&)jdtObject);
 
           if (journalManager->GetNumOfActs() > 0)
           {
                 if(!firstTime && GetEnv().IsLocalSettingsFlag(lsf_IsDocNumMethod))
                 {
                      GetNextSerial(true);
                      dagACQ->SetColLong(GetNextNum(), OACQ_NUM);
                 }
 
                 if (firstTime)
                 {
                      firstTime = false;
                 }
 
                 jdtObject->SetDAG(dagJDT, false);
                 jdtObject->SetDAG(dagJDT1, false, JDT, ao_Arr1);
                 sboErr = jdtObject->InitData();
                 IF_ERROR_RETURN(sboErr);
                 jdtObject->SetDataSource(GetDataSource());
                 sboErr = GOCreateTransStruct(this);
                 IF_ERROR_RETURN(sboErr);
                 dagJDT->CopyColumn(dagACQ, OJDT_LOC_TOTAL, 0, OACQ_TOTAL_SUM, 0);
                 dagJDT->CopyColumn(dagACQ, OJDT_FC_TOTAL, 0, OACQ_TOTAL_FRGN, 0);
                 dagJDT->CopyColumn(dagACQ, OJDT_SYS_TOTAL, 0, OACQ_TOTAL_SYS, 0);
 
                
                 long acq2index = GetRecordLineIndexInACQ2(it->first);
            dagJDT->CopyColumn(dagACQ2, OJDT_MEMO, 0, ACQ2_JOURNAL_MEMO, acq2index);
 
                 CJournalWriter journalWriter(jdtObject, journalManager->GetActsConstList(), this);
 
                 journalManager->DisposeActList();
                 sboErr = journalWriter.Execute();
                 IF_ERROR_RETURN(sboErr);
                 sboErr = jdtObject->CompleteJdtLine();
                 IF_ERROR_RETURN(sboErr);
                 sboErr = jdtObject->Create(true);
                 IF_ERROR_RETURN(sboErr);
 
                 long transNum;
                 dagJDT->GetColLong(&transNum, OJDT_JDT_NUM, 0);
                 SetTransactionNum(it->first, transNum);
                 GetDAG()->CopyColumn(dagJDT, OACQ_TRANS_NUM, 0, OJDT_JDT_NUM, 0);
 
                 // Save data for posting preview.
                 if (IsPostingPreviewMode ())
                 {
                      AddPostingPreviewData (GetDAG (JDT, ao_Main), GetDAG (JDT, ao_Arr1));
                 }
           }
           else
           {
                 GetDAG()->SetColStr(EMPTY_STR, OACQ_JOURNAL_MEMO);
           }
      }
 
      dagACQ->SetColLong(oldNextNum, OACQ_NUM);
      RemoveDprAreaWithoutPosting();
 
      return sboErr;
}
=end
o = CTransactionJournalObject.CreateObject("1", {})

# called by journalWriter.Execute();
#o.OJDTFillJDT1FromAccounts

# complete jdt line
o.CompleteJdtLine()

o.Create()

# maybe called by Create()
# o.OnAutoComplete
