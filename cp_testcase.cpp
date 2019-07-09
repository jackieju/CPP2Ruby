// testcase 0 
class CJDTStornoExtraInfoCreator{
CJDTStornoExtraInfoCreator(){
    
}
}
CJDTStornoExtraInfoCreator * CJDTStornoExtraInfoCreator::operator=(const CJDTStornoExtraInfoCreator & other){
    
}

// testcase 1 
_LOGMSG(logDebugComponent, logNoteSeverity, 
	_T("In CTransactionJournalObject::BeforeDeleteArchivedObject - starting JEComp.execute()"));



// testcase 2 
try{
    
}catch (nsDataArchive::CDataArchiveException& e){
    
}

// testcase 3 
    _MEM_MYRPT0 (_T("CDocumentObject::UpdateWTOnRecon -                  JDT2 should contain 1 rec at the most for reconciliation!"));

// testcase 4 
a = 1U;

// testcase 5 
fdafa;
a = 1U;
//b= 1usl;

// testcase 6 

StdMap<SBOString, FCRoundingStruct, False, False>::const_iterator itr = currencyMap.begin();
a=1;

// testcase 7 
void CTransactionJournalObject:: OJDTGetDocCurrency(CBusinessObject* bizObject, TCHAR *docCurrency)
{
	PDAG	dagJDT = bizObject->GetDAG ();
	CBizEnv	&bizEnv = bizObject->GetEnv();

	dagJDT->GetColStr (docCurrency, OJDT_TRANS_CURR);
	if (_STR_IsSpacesStr (docCurrency))
	{
		_STR_strcpy (docCurrency, bizEnv.GetMainCurrency ());
	}
}

// testcase 8 
    CTransactionJournalObject::IsPaymentOrdered(bizEnv, canceledTrans, ordered);

// testcase 9 
    class A{
        int a;
    }
    void A::test(){
        a = 1;
    }

// testcase 10 
    class A{
        int a;
        void test();
    }
    void A::test(){
        a = 1;
    }

// testcase 11 
		//PDAG dagJDT1 = GetDAG (JDT, ao_Arr1);
		PDAG dagJDT1 = GetDAG (JDT, ao_Arr1), b=1;

// testcase 12 
//char *a="\n";
_STR_strcat (MformatStr, _T("\n"));
_MEM_MYRPT0 (_T("CDocumentObject::UpdateWTOnRecon - \
             JDT2 should contain 1 rec at the most for reconciliation!"));

// testcase 13 
class A{
    FOUNDATION_EXPORT static CBusinessObject	*CreateObject (const TCHAR *id, CBizEnv &env);
}

// testcase 14 

    _MEM_MYRPT0 (_T("CDocumentObject::UpdateWTOnRecon - \
                 JDT2 should contain 1 rec at the most for reconciliation!"));
                 _STR_strcat (MformatStr, _T("\n"));

              

// testcase 15 
		 _TRACER("OnCreate");
    	SBOErr	ooErr = noErr;
    	PDAG	dagJDT, dagJDT1, dagCRD=0;
     	PDAG	dagRES;

    	long    blockLevel=0, typeBlockLevel=0;
    	long	retBtn;
    	long	recCount = 0, ii = 0;
    	long	RetVal = 0;
    	long	numOfRecs, rec;
    	long	lastContraRec = 0, contraCredLines = 0, contraDebLines = 0;		// VF_EnableCorrAct
    	long	createdBy, transAbs, transType;

    	Currency	monSymbol={0};

    	MONEY	debAmount, credAmount, transTotal, transTotalChk;
    	MONEY	transTotalCredChk, transTotalDebChk, sTransTotalDebChk, sTransTotalCredChk, fTransTotalDebChk, fTransTotalCredChk;		// VF_EnableCorrAct
    	MONEY	fTransTotal, fDebAmount, fCredAmount;
    	MONEY	sTransTotal, sDebAmount, sCredAmount;
    	MONEY	rateMoney, tempMoney;
    	MONEY	BgtMonthOver, BgtYearOver;
    	MONEY	creditBalDue, debitBalDue, fCreditBalDue, fDebitBalDue, sCreditBalDue, sDebitBalDue;

    	TCHAR	acctKey[GO_MAX_KEY_LEN + 1], tempStr[256];
    	TCHAR	contraCredKey[GO_MAX_KEY_LEN + 1], contraDebKey[GO_MAX_KEY_LEN + 1];
    	TCHAR	cardKey[OCRD_CARD_CODE_LEN + 1];
    	TCHAR	Sp_Name[256] = {0};
    	TCHAR	mainCurr[GO_CURRENCY_LEN+1]={0}, frnCurr[GO_CURRENCY_LEN+1]={0};
    	TCHAR	tmpStr[256]={0};
    	TCHAR	msgStr1[512]={0}, msgStr2[512]={0};	
    	TCHAR	moneyStr[256]={0}, moneyMonthStr[256]={0}, moneyYearStr[256]={0}; 
    	TCHAR	acctCode[OACT_ACCOUNT_CODE_LEN + 1] ={0};
    	TCHAR	DoAlert,AlrType;

    	Boolean		balanced = FALSE;
    	Boolean		budgetAllYes = FALSE, bgtDebitSize; 
    	Boolean		fromImport = FALSE;
    	Boolean		itsCard, qc;

    	DBD_ResStruct	res[5] ;
    	DBD_UpdStruct	Upd[4];
    	CBizEnv			&bizEnv = GetEnv ();
        BPBalanceChangeLogDataArr bpBalanceLogDataArray;

    		qc = FALSE;
    		dagJDT = GetDAG();
        	dagJDT1 = GetDAG(JDT, ao_Arr1);
            PDAG dagJDT2 = GetDAG(JDT, ao_Arr2);

// testcase 16 
    class A{
        int a;
        virtual SBOErr			OnCreate ();
        static void test();
    }
    void A::test(){
        a = 1;
    }
    SBOErr A::OnCreate()
    {
    }

// testcase 17 
++i;

// testcase 18 
// formal argument cannot be a constant
void a(int A){
    
}

// testcase 19 
// formal argument cannot be a constant
a(&t);

// testcase 20 
bizObject=&other;

// testcase 21 
bizObject=L"fsdfsd";

// testcase 22 
// b=(aaaa()+1)?1:2;
if (!forceBalance)
{
	return ooNoErr;
}

dagJDT->GetColMoney (&tmpMoney, (frgCurr) ? OJDT_FC_TOTAL:OJDT_LOC_TOTAL, 0, DBM_NOT_ARRAY);
ooErr = GNTranslateToSysAmmount (&tmpMoney, currStr, refDate, &systMoney, bizEnv);

// testcase 23 
enum eColumnJDT1
{
		// Transaction Key
		JDT1_TRANS_ABS									=	0,
}


class CBizEnv;
class TCHAR;
class CTransactionJournalObject: public CSystemBusinessObject, public IReconcilable, public IWithHoldingAble
{
};
CTransactionJournalObject::CTransactionJournalObject (const TCHAR *id, CBizEnv &env) :
							CSystemBusinessObject (id, env), m_digitalSignature (env)
{
      
}

// testcase 24 
enum{
 ConnID = 1
};
void a(){
     
DBM_ServerTypes   ServerType = DBMCconnManager::GetHandle()->GetConnectionType (ConnID);
DBMCconnManager::GetHandle ()->ChangeConnectionUseCount (m_connectId, increase);
}

// testcase 25 
class A{
    virtual bool	IsDeferredAble	() const {return false;}
	int b;
}
void A::a(){
    b = 0;
}



// testcase 26 
class CJDTStornoExtraInfoCreator{
    
}
CJDTStornoExtraInfoCreator & CJDTStornoExtraInfoCreator::operator=(const CJDTStornoExtraInfoCreator & other)
{
	if(this == &other){
		return *this;
	}

	m_jdtBusinessObject = other.m_jdtBusinessObject;
	
	return *this;
}

// testcase 27 
a = new A(1,2);

// testcase 28 
class CBusinessService;
class CTransactionJournalObject{
    
}
void	CTransactionJournalObject::CopyNoType (const CBusinessService& other)
{
     

		CTransactionJournalObject	*bizObject = (CTransactionJournalObject*) &other;


}


// testcase 29 
int *b = 1;
int a = (int *)&b;

// testcase 30 
(*currentMoney) += sumRow;

// testcase 31 
class A;
A B(1,2);

// testcase 32 
//int a = b & c;
//int a = &b;

//int a = b(1,(int *)&b);
delete a;


// testcase 33 
A<true> a;
b = 1;

// testcase 34 
template<int a> class A{int f(){};};
b = 1;

// testcase 35 
template <bool isDisassembly>
class CWorkOrderATPSelectStrategy
{
};

a =1;


// testcase 36 
struct RECORDQUANTITYARRAY{};
void fabdfsd(const RECORDQUANTITYARRAY&  a,int b);
//void PrepareRecordQtyArray(const RECORDQUANTITYARRAY& qtyArr, long recCount, RECORDQUANTITYARRAY& recQtyArray, long startIndex);


// testcase 37 
abc<bool, int>().fn();
std::ff<bool, int> a=1;

// testcase 38 
//template <bool isDisassembly> a<true,1>::fn(){};
template <bool isDisassembly> void fn(){};
a =1;
template<typename T>
T* OffsetPtr (T* x, int y)
{
	return reinterpret_cast<T*>(y);
}

// testcase 39 
fn<int, bool>().a();


// testcase 40 
class xxx CName:CParent{
}


// testcase 41 
void    SetDBDParms (std::unique_ptr<DBD_Params>&& params) { m_queries[0] = std::move (params); }



// testcase 42 
SBOString   SerializeToXml (SBOXmlParser *pXmlParser, std::vector<long> &fieldsArr, bool includeTableDef = false);


// testcase 43 
mutable std::unique_ptr<SBOLock>	m_lock=1;


// testcase 44 
virtual SBOErr Execute () override { return m_dag->UpdateAll (m_checkBackup); }


// testcase 45 
DagCleaner () = default;


// testcase 46 


// testcase 47 


// testcase 48 

// testcase 49 


// testcase 50 

int a =0;
for (long i = 0, a=1 ; i < b; i++)
{
}

for (long i1 = 0; i1 < dbKeyCount && dbAliasIndexMap.size () > 0; ++i1)
    {}
	for (long i2 = 0; i2 < columns.GetCount (); ++i2)
        {}

// testcase 51 
dagResult->m_dataElements = new char*[sizeof (void*)];
a = new A::B(1,2);

// testcase 52 
//DBM_ServerTypes   ServerType = DBMCconnManager::GetHandle()->GetConnectionType (ConnID);
DBMCconnManager::GetHandle ()->ChangeConnectionUseCount (m_connectId, increase);

// testcase 53 
_DBM_DataAccessGate::SetEnvironment (v);
void _DBM_DataAccessGate::SetEnvironment (CDBMEnv *env);
void _DBM_DataAccessGate::SetEnvironment (CDBMEnv *env){};
B** _DBM_DataAccessGate::SetEnvironment (CDBMEnv *env){};

void _DBM_DataAccessGate::SetEnvironment (int *env);
void _DBM_DataAccessGate::SetEnvironment (int *env){};


// testcase 54 
DBM_DAG_Cell_Ptr dataBuffer = recOffset < m_dataCount ? (DBM_DAG_Cell_Ptr) this->GetRecordOffsetPtr (recOffset, false) : nullptr;
//DBM_DAG_Cell_Ptr dataBuffer = recOffset < m_dataCount ? (DBM_DAG_Cell_Ptr)this->GetRecordOffsetPtr (recOffset) : nullptr;

// testcase 55 

bp.flags = 0x00000001;

// testcase 56 
throw "a";
throw a;
throw A();
throw CDagException (coreInvalidPointer, GetTableName (), "_DBM_DataAccessGate::CompareBuffers failed. DataBuffer is nullptr.");
bool      IsYearTransferedDocumentsInCompany() throw (CBusinessException);
bool      IsYearTransferedDocumentsInCompany() throw CBusinessException;

bool      IsYearTransferedDocumentsInCompany() throw (CBusinessException, B);


// testcase 57 
 i = 0, keyOff = 0;
for (i = 0, keyOff = 0; i < segmentCount && keyOff < keyLen; i++){}

for (int i = 0, keyOff = 0; i < segmentCount && keyOff < keyLen; i++);
 

// testcase 58 
i = sizeof(short);
 i = sizeof(a->b());

// testcase 59 
//TCHAR tmpStr[256] = { 0 };

//DBM_DAG_BufferParams bp = { 0 };
//DBM_DAG_BufferParams bp1 = {0  };
//conds.SetSize (numOfConds);

//DBM_DAG_BufferParams bp{ 0 };

// testcase 60 
stream << "[invalid DAG]";


// testcase 61 


// testcase 62 
#ifdef A
a = 1;
#ifdef B
b = 1;
#endif
#endif
a=1;

// testcase 63 
void MONEY::ToInt64 (char *sboI64) const
{
	*sboI64 = m_data;
}

// testcase 64 
 SBOErr          CreateSystemFilterConds(IN  DBD_Params* pdbdParams, OUT std::vector<DBD_CondStruct>&   dataOwnershipConds);
SBOErr          A::CreateSystemFilterConds(IN  DBD_Params* pdbdParams, OUT std::vector<DBD_CondStruct>&   dataOwnershipConds){
    int a = 1;
}

// testcase 65 
//inline
friend class ObjWrapper1<Obj, Key, Creator>;
template<typename Obj, typename Key, typename Creator>  class ObjWrapper2;


// testcase 66 
//B1_OBSERVER_API CBusinessException (WarningLevel warningLevel, ILanguageSettings& env, long msgUid, ...);
int a(...);

// testcase 67 
class WarningLevel{};
class ILanguageSettings{};
B1_OBSERVER_API CBusinessException (WarningLevel warningLevel, ILanguageSettings& env, long msgUid, ...);
int a(...);
int aaaaaa(...){};


// testcase 68 

class CBusinessException{
//B1_OBSERVER_API virtual ~CBusinessException (); //B1_OBSERVER_API needs to be defined to empty in c_macro.c
}

// testcase 69 
enum eColumnJDT1
{
		// Transaction Key
		JDT1_TRANS_ABS									=	0
}
enum{
 ConnID = 1
};
enum
{
	resTax1AbsEntry = 0L,
	resTax1TaxCode, 
	resTax1EqPercent,
	resJdt1TransId,
	resJdt1Line_ID,
};
class A{
enum class MessageSource { FromSboErr, FromStringIndex, FromMessageUid }
}
enum class LocalSettings : long
	{
		INVALID = -1L,
		Argentina = 0L,
		Austria,
		AustraliaNZ,
		Belgian,
		Brazil,
		Canada
    }

// testcase 70 

namespace LinkMap
{
    
    
    };

// testcase 71 
class BBB{
}
namespace nn
{
    class AAAA{
        ~_DataOwnershipMgr();
    }
    int a(){};
    
}
int b(){};

// testcase 72 
namespace R1{
    namespace Permission1{
        class A{
            int a(){}
            int b(){}
        }
        int bb(){
            c=1;
        }
        int cc(){
        }
    }
}
//R::Permission::A *a=new R::Permission::A();

//using namespace R::Permission;
//A *a= new A();
bb();

// testcase 73 
typedef struct _GiulSum
{
	MONEY		sums[NUM_OF_CURRENCY];
	_GiulSum () {}
}GiulSum, *GiulSumPtr;

// testcase 74 
A strAllTransactionType(1);
SBOErr IsCurValid (TCHAR *crnCode, PDAG unused);

// testcase 75 
namespace s{
    class MONEY1{
    }
}
using namespace s;
int a;
MONEY1	debAmount1;
MONEY	debAmount, credAmount, transTotal, transTotalChk;
TCHAR	acctKey1[GO_MAX_KEY_LEN + 1];
TCHAR	acctKey[GO_MAX_KEY_LEN + 1], tempStr[256];
void     SetCompanyInfo(CCompanyInfo* pComInfo) {m_company = pComInfo;} 

// testcase 76 
//void     SetCompanyInfo(CCompanyInfo* pComInfo) {m_company = pComInfo;} 
//a = (CompareTo(b) <  0);

// testcase 77 
CJDTStornoExtraInfoCreator * CJDTStornoExtraInfoCreator::operator=(const CJDTStornoExtraInfoCreator & other){}
CJDTStornoExtraInfoCreator & CJDTStornoExtraInfoCreator::operator=(const CJDTStornoExtraInfoCreator & other)
{
	if(this == &other){
		return *this;
	}

	m_jdtBusinessObject = other.m_jdtBusinessObject;
	
	return *this;
}
operator std::default_delete<DAG> () const { return std::default_delete<DAG> (); }
void operator() (DAG* pDag) const;

std::wostream& operator << (std::wostream& stream, const _DBM_DataAccessGate& dag);
std::wostream& operator << (std::wostream& stream, const _DBM_DataAccessGate& dag){};
std::wostream& operator << (std::wostream& stream, const _DBM_DataAccessGate& dag)
{}
static void *operator new[] (size_t size);
ObjPool& operator= (const ObjPool&) = delete;
bool operator <  (const DocSubTypeStruct &other) const { return  (CompareTo(other) <  0); }

std::wostream& operator << (std::wostream& stream, const _DBM_DataAccessGate& dag)
{
	return operator << (stream, &dag);
}

// prepreccssor will define B1_ENGINE_API to empty
//B1_ENGINE_API
 std::wostream& operator << (std::wostream& stream, const _DBM_DataAccessGate& dag);
 const CAllCurrencySums operator- () const { return CAllCurrencySums (-m_SumLc, -m_SumFc, -m_SumSc); }
 CToolTipPreviewObjectDataConfig::operator=(other);


// testcase 78 

namespace nsDocument
{
class CDOC1CardCodeUpgrader : public CBaseUpgrader
{
    struct MktDocKey
    {
        }; 
}

// testcase 79 
class CPeriodCache{
CPeriodCache (class CPeriodCache& other);
}
CPeriodCache::CPeriodCache (class CPeriodCache& other){
}
}

// testcase 80 
 static SBOErr AutoCompleteITM(CItemMasterData * pThis, int loadFromDb = true);
 oActCodeTmp1->operator= (*oActCodeTmp2);  // Call operator= directly

// testcase 81 
class A{
MONEY_RoundRule GetRoundRule (const IRoundingData* roundingData) override;
}

// testcase 82 
 SBOErr CompleteTotals(const TotalsPair (&totalFields)[fieldsCount], PDAG pBudgetDag);

// testcase 83 
extern void ALRSetColParams (ALRColParamsPtr colParams, PDAG dagALR, long recOffset);
extern void a();

// testcase 84 
class A{
    public:
    void c(int a){
       
    };
}

AA::operator=(1);
AA::a(1);
void AA::operator=(int a){a = 1;};
hasher.digestBuffer((unsigned char*)temp.get(), length, true);
class AA{
}
bool AA::operator=(AA other){u=1;};
class AA{};
//a(AA& bb){bb=1;};

A fn(int bb, int c){};
try{
    a = 1;
}
catch(...){
    a = 2;
}
if (thouseSepStr[0] == L'');
L"";

// testcase 85 

int main(char*arg[]){
    goto l;
    
    int a = 1;
    if (a == 1)
        if (a == 1)
            goto l;
l:
    int b = 1;
    fn();
    
    return;
}



// testcase 86 
//::TreeType  treeType;
//int b = ::a;
//
//void m(){
//    int a = ::a;
//}
//class A{
//    int a;
//    ::TreeType TreeType;
//}
//class CDocumentObject: public CTypedBofDocumentObject<CDocumentObjectRoot>, public IIVIAble, public std::CPostingPreviewSource, public IApprovalObject, public CElectronicDocument, public IGDPAction
  //  {}
 //   SBOErr	ODOCUndoDoc						(enum ObjectMethod sourceProc){};
 class ArcDeletePrefs 
 {
 public:
 	// CTORs:
 	ArcDeletePrefs(): m_dagRES(NULL), m_ArchiveDate() {}
 int aaaa(){};
}
void ArcDeletePrefs::b(){}

// testcase 87 
static	bool			IsDupSeriesName (PDAG dagNNM1, PDAG dagNNM3, long* series, SBOString& objectId)
{
	SBOString temp(SUB_TYPE_NONE);
	return IsDupSeriesName (dagNNM1, dagNNM3, series, objectId, temp);
}
A a(){
    A t();
    b();
}
A t(1);
class ArcDeletePrefs 
{
public:
	// CTORs:
	ArcDeletePrefs(): m_dagRES(NULL), m_ArchiveDate() {}
	ArcDeletePrefs(const Date& archiveDate, SBOString tmpTblName): 
		m_dagRES(NULL), m_ArchiveDate(archiveDate), m_TmpArcTblName(tmpTblName) {};

	// DTOR:
	//B1_OBSERVER_API ~ArcDeletePrefs();

	PDAG		m_dagRES;
	Date		m_ArchiveDate;
	SBOString	m_TmpArcTblName;

}; 

// testcase 88 
CTransactionJournalObject::CTransactionJournalObject (const TCHAR *id, CBizEnv &env) :
							CSystemBusinessObject (id, env), m_digitalSignature (env){
                            }

// testcase 89 


#define __RegisterSensitiveFieldInner(objectId, offset, column, defaultVal, beginVersion,  tryDKey)
#define DECLARE_SENSITIVE_FIELD()public:	class SensitiveFieldsHolder	{	public:		SensitiveFieldsHolder();		const SensitiveFieldList* GetSensitiveFields() const {return &m_sensitiveFieldList;}		~SensitiveFieldsHolder(){m_sensitiveFieldList.clear ();}	private:		SensitiveFieldList m_sensitiveFieldList;	};private:	static const SensitiveFieldsHolder sfHolder;
#define BEGIN_REGISTER_SENSITIVE_FIELD(TYPE)	const TYPE::SensitiveFieldsHolder TYPE::sfHolder;	
#define REGISTER_SENSITIVE_FIELD_DKEY(objectId, offset, column, defaultVal, beginVersion)
#define REGISTER_SENSITIVE_FIELD_SKEY(objectId, offset, column, defaultVal, beginVersion)
#define END_REGISTER_SENSITIVE_FIELD()
class ArcDeletePrefs 
{
public:
	// CTORs:
	ArcDeletePrefs(): m_dagRES(nil), m_ArchiveDate() {}
	ArcDeletePrefs(const Date& archiveDate, SBOString tmpTblName): 
		m_dagRES(nil), m_ArchiveDate(archiveDate), m_TmpArcTblName(tmpTblName) {};

	// DTOR:
	 ~ArcDeletePrefs();

	PDAG		m_dagRES;
	Date		m_ArchiveDate;
	SBOString	m_TmpArcTblName;

}; 

// testcase 90 
typedef bool (*CALLBACK)(const CBofNode&, const SBOString&);
template <typename T> void fn1(bool (*onCanChange)(const CBofNode&, T, bool), void (*onChanged)(CBofNode&, T, bool), T value, CALLBACK valueIsNull){
    onCanChange(3,false);
    valueIsNull(1,2);
};
template <typename T> void A::fn2(long propertyId, long columnId, bool (*onCanChange)(const CBofNode&, T, bool), void (*onChanged)(CBofNode&, T, bool), T value, fn3 valueIsNull){
    onCanChange(3,false);
};
fn1<int>(b,c, 3,4);
A a;
a.fn2(1,2,b,c, 3,4);
CALLBACK fn3;
fn3 = fn1;
fn3(3,4);
void fn4(int a, int b){ return a+b;}
fn4(3, 4);
int d = fn4(2,3);


// testcase 91 
SBOErr	CTransactionJournalObject::OnUpdate()
{
        trace("OnUpdate");
    }

// testcase 92 
#define B1_OBSERVER_API
typedef bool (*DBD_ProgressCallback) (void *userData, long curr, long max);
typedef bool (*DBD_FilterCallback) (PDAG pDag, long rec, void *param1, void *param2);
typedef SBOErr (*DBD_CondCallback) (void *form, DBD_Params *addedParams);
void     SetProgressCallback (DBD_ProgressCallback progressProc, void* userData, CProgressIndicator *progressPtr);
B1_OBSERVER_API bool IsGrossPriceMode() { return GetEnv().EnableGrossPriceMode() && GetPriceMode().CompareNoCase(SBOString(STR_PRICE_MODE_GROSS_PRICE)) == 0; }

// testcase 93 
typedef union _BigInt
{
    int i64[SIZE_IN_INT64];
    uint64_t u64[SIZE_IN_INT64];
    int i32[SIZE_IN_INT32];
    uint32_t u32[SIZE_IN_INT32];
} BigInt;
BigInt data;

// testcase 94 
extern "C"{
    int a=1;
    void main(){
    }
    int b(){
        c();
    }
}

// testcase 95 
//template<typename KEY, typename VALUE, typename FREE_KEY, typename FREE_VALUE>
//class StdMap
//{
//	// The condition in static_assert must depend on template parameters for this to work.
//	static_assert (!std::is_same<FREE_KEY, True>::value, "StdMap<KEY, VALUE, True, FREE_VALUE> is no longer supported. Please use std::map<KEY, VALUE> instead.");
//	static_assert (!std::is_same<FREE_KEY, Count>::value, "StdMap<KEY, VALUE, Count, FREE_VALUE> is no longer supported. Please use std::map<KEY, VALUE> instead.");
//
//	static_assert (!std::is_same<FREE_VALUE, False>::value, "StdMap<KEY, VALUE, False, False> is no longer supported. Please use std::map<KEY, VALUE> instead.");
//	static_assert (!std::is_same<FREE_VALUE, Count>::value, "StdMap<KEY, VALUE, False, Count> is no longer supported. Please use std::map<KEY, std::shared_ptr<VALUE>> instead.");
//};
//void	operator += (const SBOString& str)
//{
//	operator +=((const TCHAR*)str);
//}
class C{

	operator unsigned long () const;
	operator bool() const;
	operator int32_t() const;
	operator int64_t() const;
	operator uint32_t () const;
	operator uint64_t () const;
	operator double () const ;
	operator const TCHAR * () const{};
    void a(){};
    void a(int b){};
}
void c(int a, int b){
    puts("v2");
};
void c(){
    puts("v0");

};
void c(int a){
    puts("v1");
    
};
c();
c(1);
c(3,2);
void d(...){
}

// testcase 96 
class CTaxException{
    public:
    CTaxException(long id,CBizEnv& env){
    }
}
class CMoneyOverflowFormulaException{
    public:
    CMoneyOverflowFormulaException(long id, const SBOString& op1, const SBOString& op2, const SBOString& op){
    }
    void hello(){}
}
class C{
    public:
    C(){}
}
class CTaxMoneyOverflowException : virtual public CTaxException, public CMoneyOverflowFormulaException, public C
{
public:
	CTaxMoneyOverflowException (long id, const SBOString& op1, const SBOString& op2, const SBOString& op, CBizEnv& env)
	: CTaxException (id, env), CMoneyOverflowFormulaException (id, op1, op2, op) {}
    
		//: CTaxException (id, env){}
        
	virtual ~CTaxMoneyOverflowException() {}

	virtual SBOString GetDescription ();
};

// testcase 97 
//A::B C::D::c(It a, It b){
//}
//struct A* b;
//template<class F>
//ObjectPtr<F>::ObjectPtr (const ObjectPtr<F>& sp)
//{
//
//}
//namespace std
//{
//	template<>
//	class hash<SBOString>
//		: public unary_function < SBOString, size_t >
//	{	// hash functor
//    }
//}
// bool VectorContains (const std::vector<SBOString>& vector, const SBOString& value)
//{
//	return std::find (vector.cbegin (), vector.cend (), value) != vector.cend ();
//}
//template<typename TList, typename TValue>
//bool ListContains (const std::list<TList>& list, const TValue& value)
//{
//	return std::find (list.cbegin (), list.cend (), value) != list.cend ();
//}
//template<int a>class A{int f(){};};
//template<class F>
//ObjectPtr<F>::~ObjectPtr ()
//{
//	if (m_refCount)
//	{
//		m_refCount->DecRefCount ();
//	}
//}
//int a;
//template
//bool b(){};
//A::B c;
//class A
//{
//public:
//	A(): m_readerCount(0), m_readerRestoreCount(0), m_writerCount(0){}
//}

//class  SBOProcessSemaphore {};
//
//template <class ACE_LOCK, typename TYPE> class ACE_Atomic_Op;
//class ACE_Thread_Mutex;
//
//    void fn(){
//	CLogManager::GetInstance ()->Log (logSysMessageComponent, logErrorSeverity, errStr, __FILE__, __LINE__);;
//
//m_op1 = op1;}
//
//void fn1(){
//return false;
//}
//
//template<class F>
//F* ObjectPtr<F>::operator-> () const
//{
//	if (m_refCount == nullptr)
//	{
//		return nullptr;
//	}
//	return m_refCount->GetHandle ();
//}
//template<class F>
//ObjectPtr<F>::operator F* () const
//{
//	if (m_refCount == nullptr)
//	{
//		return nullptr;
//	}
//	return m_refCount->GetHandle ();
//}

template<class F>
bool ObjectPtr<F>::operator== (const ObjectPtr<F>& sp) const
{
	return m_refCount == sp.GetRefCount ();
}
class CSystemAlertParams
{
public:

	union
	{
		CBusinessObject* m_bo;
		CBizEnv* m_env;
	};
	//virtual long GetObjectType () const override { 
    //    return m_dagDOC == nullptr ? NOB : dynamic_cast<CBizEnv&> (*m_dagDOC->GetEnv ()).TableToObject (m_dagDOC->GetTableName (), false).strtol (); 
    //}
    
};
//bool a = m_dagDOC == nullptr ? NOB : dynamic_cast<CBizEnv&> (*m_dagDOC->GetEnv ()).TableToObject (m_dagDOC->GetTableName (), false).strtol (); 
int a =  dynamic_cast<CBizEnv&> (*m_dagDOC->GetEnv ()).TableToObject (m_dagDOC->GetTableName (), false).strtol (); 

// testcase 98 
template <typename ClassType,typename MemberFunctionType>
class CMemberFunctionEventHandler : public IEventHandler
{
public:
	CMemberFunctionEventHandler(ClassType* pObjHandler, const MemberFunctionType memberFunc):
	m_objHandler(pObjHandler),
	m_functionHandler(memberFunc)
	{
	}

	virtual ~CMemberFunctionEventHandler(){};

protected:	
	virtual SBOErr Invoke()
	{
		if(m_objHandler != nil && m_functionHandler!= nil)
		{
			return (m_objHandler->*m_functionHandler)();
		}
		return 0+TraceErrorGroup1(0);
	}		

private:
	ClassType*  m_objHandler;
	MemberFunctionType  m_functionHandler;
};

// testcase 99 
for (auto fkv : EFMMapping::Map)
{
	if (value == fkv.second)
	{
		result = fkv.first;
		break;
	}
}
for (auto itr = m_WtAmountsChangeStatus.begin (); itr != m_WtAmountsChangeStatus.end (); ++itr){
    Clear (itr->first);
}
for (; _First < _Last; _First += _Stride)
	_Val = 16777619U * _Val ^ (size_t) _Keyval[_First];
 const auto &str = GetAttributeString (colIndex, arrayOffset, line);

template <class HT, typename ParamType, typename KeyType, class DT>
typename CMulticastDelegateByKey<HT, ParamType, KeyType, DT>::FuncType CMulticastDelegateByKey<HT, ParamType, KeyType, DT>::GetHandler (KeyType key, long index) const{
}
bool result = (m_ht->*((*handlerArr)[i]))(params, handled);
bool result =  (m_objHandler->*m_functionHandler)();
const TNode& operator[] (ptrdiff_t n) const { 
    return const_cast (this)->operator[] (n); 
}
template<class F>
F* ObjectPtr<F>::operator-> () const{}

template <typename T, typename ...Args>
void						SetDisplayObjectUserInterface (long objectType, Args&&... args){};

typedef struct _BarcodeFuncs
{
	void (*GetFieldValue)(BarcodeHandler handle, const TCHAR *tableName, const TCHAR *fieldName, TCHAR *value);
	ErrCode (*GetFieldLength) (BarcodeHandler handle, const TCHAR *tableName, const TCHAR *fieldName, long *pLength);

}BarcodeFuncs,*PBarcodeFuncs;
class A{
}
void A::fn(){
    {
 SBOString objCFTId(CFT);
}
}


// testcase 100 
// test function polymophysim with different number of parameter
void fn(){}
void fn(int a){}

