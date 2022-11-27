#define PPPP1
#ifdef PPPP
__dllexport__ void SetUIInvoker(UIInvokerBase *invoker);

//B1_OBSERVER_API void a();
//__dllexport__ void Clear ();

//void aaaaa(){
    bool b(false);
    //b= true;
//}
    class PosArray;
    bool ZeroProfitCenterIsExisting(PosArray *posArray, long& rowOfZeroPC);
    
    LinkMap::CLMProviderMetaDataCached *GetLinkMapRetrieverCachedData() const;
    class sSnBDirectionType;
void        GetLineDirection     (sSnBDirectionType *direction, long m_docType, MONEY quantity, bool bForWTRToWhsDirection = false);    
 
 
// lambda
/* https://stackoverflow.com/questions/7627098/what-is-a-lambda-expression-in-c11 
You can capture by both reference and value, which you can specify using & and = respectively:

[&epsilon, zeta] captures epsilon by reference and zeta by value
[&] captures all variables used in the lambda by reference
[=] captures all variables used in the lambda by value
[&, epsilon] captures all variables used in the lambda by reference but captures epsilon by value
[=, &epsilon] captures all variables used in the lambda by value but captures epsilon by reference
*/
/*
auto fn=[](int a){};
void func3(std::vector<int>& v) {
  std::for_each(v.begin(), v.end(), [](int) {  });
}
 auto acctHasZeroSum = [](const SActsList *acct) -> bool
        {
            return !acct->allowZeros && acct->sum.IsZero() && acct->sysSum.IsZero() && acct->frgnSum.IsZero();
        };

        //Create JDT line only if sum is not zero
        if (acctHasZeroSum (accountsArrayFrom[ii]))
        {
            continue;
        }


*/

// multi catch
try
{
    printf("ffff");
}
catch (const DBMTransException& e)
{
    printf("ffff1");
    
}
catch (const DBMException& e)
{
    printf("ffff33");
    
}


auto fn=[](int a){};
auto fn2=[&](int a)->bool{printf("ee");};



// for 
for (auto &iter : resultMap)
{
    printf("ee");
}

// functiondefinition or local declaration
class ClientPreview;
class SBOString;
void a (){
 SBOString path(ClientPreview::GetInstance ().GetResourceFolder ());
}


// list initialization
class CProcedureDepends;
	CProcedureDepends	procDepends{ env.GetLocalSettings(), upgDataPtr->GetDagSCSP(), newCompConnId, CProcedureDepends::S_UPGRADE_COMPANY };

    
    ON_SCOPE_EXIT(if (pDAGTemp != nullptr) pDAGTemp->Close(););
    
  
    __dllexport__ virtual ~CBusinessException ();
    SBOString typeStr (static_cast<TCHAR> (dbmAlphaNumeric));
    
    
     bool operator< (const FirstAllocMapKey& r) const {
         return  1 ? (m_locCode < r.m_locCode) : (m_index < r.m_index);
    }

    namespace LinkMap{
        class CLMProviderMetaDataCached;
    }
    class A{
     LinkMap::CLMProviderMetaDataCached *GetLinkMapRetrieverCachedData() const;
 }
 
 
 int a=00;
 


	void OpenDAGByName (std::unique_ptr<DAG>& dag, const DBM_TableAlias table, const SBOString& contextId = L"");
   

    class DagUniquePtr;
    class CINF;
    void m(){
    switch(action)
                {
                    case 1: //continue
                        break;
                    case 2: //retry
                        goto retry;
                    case 3: //stop and flag company
                    case 4: //stop and do not flag company
                    default:
                        DagUniquePtr dagCINF(env.OpenDAG(CINF));
                        DBD_GetAllRecs(dagCINF.get());
                        dagCINF->SetColStr(action == 3 ? VAL_COMPANY_INVALID : VAL_COMPANY_VALID, CINF_COMPANY_STATUS);
                        dagCINF->UpdateAll();
                        index = 9999;
                        break;
                }
    
            }
    

    
            stmt.Where().Col(tDoc1Table, INV1_ABS_ENTRY).EQ().Val (absEntry).And().\
               Col(tDoc1Table, INV1_LINE_NUM).EQ().Val (lineNum);
 
    

            template <size_t count> int c(const B (&t)[count], long fff){}
            
            bool     SetDAG (std::unique_ptr&& dag, const SBOString& objectId, ArrayOffset arrayOffset = ao_Main);   
    

    
    enum class LocalSettings : unsigned char
    	{
    		INVALID = -1L,
    		Argentina = 0L,
    		Austria,
    		AustraliaNZ,
    		Belgian,
    		Brazil,
    		Canada
        }
        
        
        class MRPPeriodDataInWarehouses: public std::map<SBOString, MRPPeriodData>
        {
        public:
            // the day of whose requirement will be fulfilled.
            MRPPeriodDataInWarehouses():std::map<SBOString, MRPPeriodData>() {IsEndOfTolerancePeriod = true;}
            bool        IsEndOfTolerancePeriod;
        };
        
        class A : public B
        {
            A():B(){}
        }
        

        
    typedef struct _ForecastKey
    {
        long        forecastDocEntry;
        SBOString   itemCode;
        SBOString   warehouse;
        long        longDate;

        bool        operator< (struct _ForecastKey const & other) const
        {
            if (forecastDocEntry != other.forecastDocEntry)
            {
                return forecastDocEntry < other.forecastDocEntry;
            }
            if (itemCode == other.itemCode )
            {
                if(warehouse == other.warehouse)
                {
                    return (longDate < other.longDate);
                }
                return warehouse < other.warehouse;
            }
            return (itemCode < other.itemCode);
        }


    } ForecastKey;
    
    bool        op (struct _ForecastKey const & other) const{};
     
    
    
    void        LotSizeByOrderMultiples (INOUT MRPPeriodData &curPeriodData, IN const SBOString &itemCode, IN const SBOString &curWhsCode, IN const MONEY& maxRcmQty);
    
     SBOErr ODOCUndoDoc      (enum ObjectMethod sourceProc);
     

#endif
     
    