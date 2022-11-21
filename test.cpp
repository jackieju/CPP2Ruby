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
/*
auto fn=[](int a){};
void func3(std::vector<int>& v) {
  std::for_each(v.begin(), v.end(), [](int) {  });
}

*/
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