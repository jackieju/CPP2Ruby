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
     #endif 
    SBOString typeStr (static_cast<TCHAR> (dbmAlphaNumeric));