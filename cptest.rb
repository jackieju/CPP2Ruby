
######### test ################
#=begin
def test(testall=false)
# s = "{1;a=1;}"
# s = "{1;a=1;b=2;    }"
s = <<HERE
    {
   
        if (a==1)
            a = 1;
        else if (a>=3)
            a =2;
        else if (a ==4)
            a = 0;
        
    }
HERE
s=<<HERE
{
if (m_pSequenceParameter)
{
	delete=m_pSequenceParameter;
	m_pSequenceParameter = NULL;
}

}
HERE
s1 =<<HERE
{
    int* *a = 11;
    _TRACER("UpdateDocBudget");
    SBOErr          ooErr = ooNoErr;
    PDAG            dagBGT =NULL, dagBGT1=NULL;
    PDAG            dagAct = NULL;

    TCHAR           tmpStr[256]={0};
    TCHAR           finYear[OBGT_FINANCIAL_YEAR_LEN+1]={0};

    Boolean         localDags = FALSE;
    Boolean         bgtDebitSide = FALSE, subMoneyOper = FALSE;

    long            openInvField, openInvSysField;
    long            openInvFieldArr, openInvSysFieldArr;
    long            acctNum=0;

    MONEY           budgMoney;
    MONEY           tmpM, tmpSysM;
    CBizEnv         &bizEnv = bizObject->GetEnv ();
 
    if (!DAG::IsValid (dagDOC1))
    {
        return dbmBadDAG;
    }

    if (bizEnv.IsComputeBudget () == FALSE )
    {
        return  (ooNoErr);
    }

    switch (updateBgtPtr->objType)
    {
        case RDR:
        case POR:
        case PDN:
        case DLN:
        case PRQ:
        break;

        case RDN:
        case RPD:
            subMoneyOper = TRUE;
        break;

        default:
            return (ooNoErr);
        break;
    }
    
    int a = 1;
    b = 10;
    for ( int i = 0;i < b; i++)
        a(i);
        CBizEnv    &bizEnv = GetEnv ();
    return 20;
}   
HERE
s2 = <<HERE
{

   a[0]=0;
}
HERE
s3=<<HERE
//a = 1;
#include "a.h"
#fdaaslk
#include "bss.h"
b =1;
enum
{
	resTax1AbsEntry = 0L,
	resTax1TaxCode, 
	resTax1EqPercent,
	resJdt1TransId,
	resJdt1Line_ID,
};
HERE
s=<<HERE
#define cc 1
#if 0
a = 1
#elif ccc
a = 2
#elif cc
a = 22
#else
a =3
#endif

#ifdef bb
c = 1
#elif ccc
c = 2
#elif ccc
c = 22
#else
c =3
#endif

#define MDR_ASSIGN_STR_NUM 						80304
#define INVALID_OCR_FOR_POSTDATE_INDEX 			13
#define AMOUNT_CHANGED_INDEX 					15
#define ROW_DIMENSION_LOCATION					16
HERE

s4=<<HERE
#define bbb 1
#ifdef bbb
a=12;
#else
a=11;
#define bb 1
c=1;
d=1;
#endif
HERE


s5 =<<HERE
#dfsfffff
#adfa
ff=1;
HERE
s6 =<<HERE
//a = 1;
//#define bbc

//abc=1;

#include "a.h"

//#fdaaslk
//c=1;
//#include "bss.h"
//b =1;
HERE
s7=<<HERE
#include "a.h"
HERE
s8=<<HERE

#define		JDT_WARNING_BLOCK	3
#ifdef JDT_WARNING_BLOCK1
a = 1
#else
a = 2
#endif

HERE

s9=<<HERE
B c = A(b);
HERE
s10=<<HERE
class Test{
    int a;
    void test1(){
        printf("show test1");
        a = 1;
    }
}
int Test::test(int a, B* b){
    printf("int");
    printf("int");
    a = 1;
    
}
HERE
s11=<<HERE
//StdMap<SBOString, FCRoundingStruct, False, False> currencyRoundingMap;
std::map<SBOString, FCRoundingStruct, False, False> currencyRoundingMap;

HERE
s12=<<HERE
a();

HERE
s13=<<HERE
long canceledTrans = 0;
dagJDT->GetColLong (&canceledTrans, OJDT_JDT_NUM, 0);
try
{
	if (cancelNum > 0)
	{
		canCancelJE = false;
	}
}
catch (DBMException &e)
{
	ooErr = e.GetCode ();
}
HERE
s14=<<HERE
virtual bool	IsDeferredAble	() const {return false;}
HERE
s15=<<HERE
// Defines for setting dates in canceled JE for In/Out Payments
/************************************************************************************
************************************************************************************/
// columns for reconciliation upgrade dag res


//CMessagesManager::GetHandle ()->Message (_132_APP_MSG_AP_AR_USER_NOT_ASSINED_BPL, EMPTY_STR, this, (const TCHAR*)BPLName);
aaaa((const TCHAR*)BPLName);
HERE
s0=<<HERE
class CJDTStornoExtraInfoCreator{
CJDTStornoExtraInfoCreator(){
    
}
}
CJDTStornoExtraInfoCreator * CJDTStornoExtraInfoCreator::operator=(const CJDTStornoExtraInfoCreator & other){
    
}
HERE
s1=<<HERE
_LOGMSG(logDebugComponent, logNoteSeverity, 
	_T("In CTransactionJournalObject::BeforeDeleteArchivedObject - starting JEComp.execute()"));


HERE
s2=<<HERE
try{
    
}catch (nsDataArchive::CDataArchiveException& e){
    
}
HERE
s3=<<HERE
    _MEM_MYRPT0 (_T("CDocumentObject::UpdateWTOnRecon - \
                 JDT2 should contain 1 rec at the most for reconciliation!"));
HERE
s4=<<HERE
a = 1U;
HERE
s5=<<HERE
fdafa;
a = 1U;
//b= 1usl;
HERE
s6=<<HERE

StdMap<SBOString, FCRoundingStruct, False, False>::const_iterator itr = currencyMap.begin();
a=1;
HERE
s7=<<HERE
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
HERE
s8=<<HERE
    CTransactionJournalObject::IsPaymentOrdered(bizEnv, canceledTrans, ordered);
HERE
s9=<<HERE
    class A{
        int a;
    }
    void A::test(){
        a = 1;
    }
HERE
s10=<<HERE
    class A{
        int a;
        void test();
    }
    void A::test(){
        a = 1;
    }
HERE
s11 =<<HERE
		//PDAG dagJDT1 = GetDAG (JDT, ao_Arr1);
		PDAG dagJDT1 = GetDAG (JDT, ao_Arr1), b=1;
HERE

s12=<<HERE
//char *a="\\n";
_STR_strcat (MformatStr, _T("\\n"));
_MEM_MYRPT0 (_T("CDocumentObject::UpdateWTOnRecon - \\
             JDT2 should contain 1 rec at the most for reconciliation!"));
HERE
s13=<<HERE
class A{
    FOUNDATION_EXPORT static CBusinessObject	*CreateObject (const TCHAR *id, CBizEnv &env);
}
HERE
s14=<<HERE

    _MEM_MYRPT0 (_T("CDocumentObject::UpdateWTOnRecon - \\
                 JDT2 should contain 1 rec at the most for reconciliation!"));
                 _STR_strcat (MformatStr, _T("\\n"));

              
HERE
s15 =<<HERE
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
HERE
s16=<<HERE
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
HERE
s17=<<HERE
++i;
HERE
s18=<<HERE
// formal argument cannot be a constant
void a(int A){
    
}
HERE
s19=<<HERE
// formal argument cannot be a constant
a(&t);
HERE
s20=<<HERE
bizObject=&other;
HERE
s21=<<HERE
bizObject=L"fsdfsd";
HERE
s22=<<HERE
bool CJDTDeferredTaxUtil::IsBPWithEqTax(const SBOString bpCode, CBizEnv& bizEnv)
{
	APCompanyDAG dagCRD;	
	bizEnv.OpenDAG (dagCRD, SBOString(CRD));
	dagCRD->GetBySegment (OACT_KEYNUM_PRIMARY, bpCode);
	SBOString eqTax;
	dagCRD->GetColStr (eqTax, OCRD_EQUALIZATION);
	eqTax.Trim();

	return eqTax == VAL_YES;
}


bool CJDTDeferredTaxUtil:: IsBPWithEqTax()
{
	PDAG dagJDT1 = m_bo->GetDAG (JDT, ao_Arr1);
	SBOString bpCode;
	dagJDT1->GetColStr (bpCode, JDT1_SHORT_NAME, m_bpLine);
	bpCode.Trim ();
	CBizEnv& bizEnv = m_bo->GetEnv();

	return CJDTDeferredTaxUtil:: IsBPWithEqTax (bpCode, bizEnv);
}

bool CJDTDeferredTaxUtil:: IsValidDeferredTax()
{
	return IsValidOnEqTax();
}

bool CJDTDeferredTaxUtil:: IsValidOnEqTax()
{
	CBizEnv& bizEnv = m_bo->GetEnv();
	if (!bizEnv.IsLocalSettingsFlag (lsf_EnableEqualizationVat))
	{
		return true;
	}

	bool isValidLine = true;
	PDAG dagJDT1 = m_bo->GetDAG(JDT, ao_Arr1);
    long bpLineCount = 0;
    long recJDT1 = dagJDT1->GetRealSize (dbmDataBuffer);
    SBOString acct, shortname;
    CTaxGroupCache *taxGroupCache = bizEnv.GetTaxGroupCache ();
	SBOString vatGroup, eqTaxAcct, vatLine;	
	
    for(long rec = 0; rec < recJDT1; rec++)
    {
        dagJDT1->GetColStr(vatLine, JDT1_VAT_LINE, rec);
		vatLine.Trim ();
        if(vatLine == VAL_YES)    
        {
			dagJDT1->GetColStr(vatGroup, JDT1_VAT_GROUP, rec);
			vatGroup.Trim ();
			taxGroupCache->GetAcctInfo (bizEnv, vatGroup, OVTG_EQU_VAT_ACCOUNT, eqTaxAcct);		
			eqTaxAcct.Trim();
			if (!eqTaxAcct.IsEmpty ())
			{
				isValidLine = false;
				break;
			}
        }
    }

	return isValidLine;
}

bool CJDTDeferredTaxUtil::SkipValidate ()
{
	return GetDeferredTaxStatus () == dts_Skip;
}

bool CJDTDeferredTaxUtil::IsValid ()
{
	if (!IsValidDeferredTaxStatus ())
	{
		return false;
	}

	if (SkipValidate ())
	{
		return true;
	}

	if (!IsValidBPLines())
	{
		CMessagesManager::GetHandle()->Message (_147_APP_MSG_FIN_JDT_DEFERRED_TAX_NO_MULTI_BP, EMPTY_STR, m_bo);
		return false;
	}

	if (IsBPWithEqTax())
	{
		CMessagesManager::GetHandle()->Message (_147_APP_MSG_FIN_JDT_DEFERRED_TAX_BP_WITH_EQ_TAX, EMPTY_STR, m_bo);
		return false;
	}

	if (!IsValidDeferredTax())
	{
		CMessagesManager::GetHandle()->Message (_147_APP_MSG_FIN_JDT_DEFERRED_TAX_WITH_EQ_TAX, EMPTY_STR, m_bo);
		return false;
	}

	return true;
}
HERE
s22=<<HERE
// b=(aaaa()+1)?1:2;
if (!forceBalance)
{
	return ooNoErr;
}

dagJDT->GetColMoney (&tmpMoney, (frgCurr) ? OJDT_FC_TOTAL:OJDT_LOC_TOTAL, 0, DBM_NOT_ARRAY);
ooErr = GNTranslateToSysAmmount (&tmpMoney, currStr, refDate, &systMoney, bizEnv);
HERE
s23=<<HERE
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
HERE
s24=<<HERE
enum{
 ConnID = 1
};
void a(){
     
DBM_ServerTypes   ServerType = DBMCconnManager::GetHandle()->GetConnectionType (ConnID);
DBMCconnManager::GetHandle ()->ChangeConnectionUseCount (m_connectId, increase);
}
HERE
s25=<<HERE
class A{
    virtual bool	IsDeferredAble	() const {return false;}
	int b;
}
void A::a(){
    b = 0;
}


HERE
s26=<<HERE
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
HERE
s27=<<HERE
a = new A(1,2);
HERE
s28=<<HERE
class CBusinessService;
class CTransactionJournalObject{
    
}
void	CTransactionJournalObject::CopyNoType (const CBusinessService& other)
{
     

		CTransactionJournalObject	*bizObject = (CTransactionJournalObject*) &other;


}

HERE
s29=<<HERE
int *b = 1;
int a = (int *)&b;
HERE
s30=<<HERE
(*currentMoney) += sumRow;
HERE
s31=<<HERE
class A;
A B(1,2);
HERE
s32=<<HERE
//int a = b & c;
//int a = &b;

//int a = b(1,(int *)&b);
delete a;

HERE

s33=<<HERE
A<true> a;
b = 1;
HERE
s34=<<HERE
template<int a>class A{int f(){};};
b = 1;
HERE
s35=<<HERE
template <bool isDisassembly>
class CWorkOrderATPSelectStrategy
{
};

a =1;

HERE
s36=<<HERE
struct RECORDQUANTITYARRAY{};
void fabdfsd(const RECORDQUANTITYARRAY&  a,int b);
//void PrepareRecordQtyArray(const RECORDQUANTITYARRAY& qtyArr, long recCount, RECORDQUANTITYARRAY& recQtyArray, long startIndex);

HERE
s37=<<HERE
abc<bool, int>().fn();
std::ff<bool, int> a=1;
HERE
s38=<<HERE
//template <bool isDisassembly> a<true,1>::fn(){};
template <bool isDisassembly> void fn(){};
a =1;
template<typename T>
T* OffsetPtr (T* x, int y)
{
	return reinterpret_cast<T*>(y);
}
HERE
s39=<<HERE
fn<int, bool>().a();

HERE

s40=<<HERE
class xxx CName:CParent{
}

HERE
s41=<<HERE
void    SetDBDParms (std::unique_ptr<DBD_Params>&& params) { m_queries[0] = std::move (params); }


HERE
s42=<<HERE
template<typename EnumT, typename std::enable_if<std::is_enum<EnumT>::value, int>::type = 0>
EnumT				GetColStrEnum (const long colNum, const long recOffset = 0L) const;


HERE
s42=<<HERE
SBOString   SerializeToXml (SBOXmlParser *pXmlParser, std::vector<long> &fieldsArr, bool includeTableDef = false);

HERE
s43=<<HERE
mutable std::unique_ptr<SBOLock>	m_lock=1;

HERE
s44=<<HERE
virtual SBOErr Execute () override { return m_dag->UpdateAll (m_checkBackup); }

HERE
s45=<<HERE
DagCleaner () = default;

HERE
s46=<<HERE

HERE
s47=<<HERE

HERE

s48=<<HERE
HERE
s49=<<HERE

HERE

s50=<<HERE

int a =0;
for (long i = 0, a=1 ; i < b; i++)
{
}

for (long i1 = 0; i1 < dbKeyCount && dbAliasIndexMap.size () > 0; ++i1)
    {}
	for (long i2 = 0; i2 < columns.GetCount (); ++i2)
        {}
HERE
 
 
s51=<<HERE
dagResult->m_dataElements = new char*[sizeof (void*)];
a = new A::B(1,2);
HERE
s52=<<HERE
//DBM_ServerTypes   ServerType = DBMCconnManager::GetHandle()->GetConnectionType (ConnID);
DBMCconnManager::GetHandle ()->ChangeConnectionUseCount (m_connectId, increase);
HERE
s53=<<HERE
_DBM_DataAccessGate::SetEnvironment (v);
void _DBM_DataAccessGate::SetEnvironment (CDBMEnv *env);
void _DBM_DataAccessGate::SetEnvironment (CDBMEnv *env){};
B** _DBM_DataAccessGate::SetEnvironment (CDBMEnv *env){};

void _DBM_DataAccessGate::SetEnvironment (int *env);
void _DBM_DataAccessGate::SetEnvironment (int *env){};

HERE
s54=<<HERE
DBM_DAG_Cell_Ptr dataBuffer = recOffset < m_dataCount ? (DBM_DAG_Cell_Ptr) this->GetRecordOffsetPtr (recOffset, false) : nullptr;
//DBM_DAG_Cell_Ptr dataBuffer = recOffset < m_dataCount ? (DBM_DAG_Cell_Ptr)this->GetRecordOffsetPtr (recOffset) : nullptr;
HERE
s55=<<HERE

bp.flags = 0x00000001;
HERE
s56=<<HERE
throw "a";
throw a;
throw A();
throw CDagException (coreInvalidPointer, GetTableName (), "_DBM_DataAccessGate::CompareBuffers failed. DataBuffer is nullptr.");
bool      IsYearTransferedDocumentsInCompany() throw (CBusinessException);
bool      IsYearTransferedDocumentsInCompany() throw CBusinessException;

bool      IsYearTransferedDocumentsInCompany() throw (CBusinessException, B);

HERE
s57=<<HERE
 i = 0, keyOff = 0;
for (i = 0, keyOff = 0; i < segmentCount && keyOff < keyLen; i++){}

for (int i = 0, keyOff = 0; i < segmentCount && keyOff < keyLen; i++);
 
HERE
s58=<<HERE
i = sizeof(short);
 i = sizeof(a->b());
HERE

s59=<<HERE
//TCHAR tmpStr[256] = { 0 };

//DBM_DAG_BufferParams bp = { 0 };
//DBM_DAG_BufferParams bp1 = {0  };
//conds.SetSize (numOfConds);

//DBM_DAG_BufferParams bp{ 0 };
HERE



s60=<<HERE
stream << "[invalid DAG]";

HERE

s61=<<HERE

HERE

s62=<<HERE
#ifdef A
a = 1;
#ifdef B
b = 1;
#endif
#endif
a=1;
HERE

s63=<<HERE
void MONEY::ToInt64 (char *sboI64) const
{
	*sboI64 = m_data;
}
HERE

s64=<<HERE
 SBOErr          CreateSystemFilterConds(IN  DBD_Params* pdbdParams, OUT std::vector<DBD_CondStruct>&   dataOwnershipConds);
SBOErr          A::CreateSystemFilterConds(IN  DBD_Params* pdbdParams, OUT std::vector<DBD_CondStruct>&   dataOwnershipConds){
    int a = 1;
}
HERE

s65=<<HERE
//inline
friend class ObjWrapper1<Obj, Key, Creator>;
template<typename Obj, typename Key, typename Creator>  class ObjWrapper2;

HERE
s66=<<HERE
//B1_OBSERVER_API CBusinessException (WarningLevel warningLevel, ILanguageSettings& env, long msgUid, ...);
int a(...);
HERE
s67=<<HERE
B1_OBSERVER_API CBusinessException (WarningLevel warningLevel, ILanguageSettings& env, long msgUid, ...);
int a(...);
int aaaaaa(...){};

HERE
s68=<<HERE

class CBusinessException{
//B1_OBSERVER_API virtual ~CBusinessException (); //B1_OBSERVER_API needs to be defined to empty in c_macro.c
}
HERE
s69=<<HERE
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
HERE

s70=<<HERE

namespace LinkMap
{
    
    
    };
HERE

s71=<<HERE
HERE

s71=<<HERE
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
HERE

s72=<<HERE
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
HERE

# typedef struct
s73 =<<HERE
typedef struct _GiulSum
{
	MONEY		sums[NUM_OF_CURRENCY];
	_GiulSum () {}
}GiulSum, *GiulSumPtr;
HERE

s74=<<HERE
A strAllTransactionType(1);
SBOErr IsCurValid (TCHAR *crnCode, PDAG unused);
HERE

s75=<<HERE
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
HERE

s76=<<HERE
//void     SetCompanyInfo(CCompanyInfo* pComInfo) {m_company = pComInfo;} 
//a = (CompareTo(b) <  0);
HERE

#operator
s77=<<HERE
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

HERE
s78=<<HERE

namespace nsDocument
{
class CDOC1CardCodeUpgrader : public CBaseUpgrader
{
    struct MktDocKey
    {
        }; 
}
HERE

s79=<<HERE
class CPeriodCache{
CPeriodCache (class CPeriodCache& other);
}
CPeriodCache::CPeriodCache (class CPeriodCache& other){
}
}
HERE

s80=<<HERE
 static SBOErr AutoCompleteITM(CItemMasterData * pThis, int loadFromDb = true);
 oActCodeTmp1->operator= (*oActCodeTmp2);  // Call operator= directly
HERE

s81=<<HERE
class A{
MONEY_RoundRule GetRoundRule (const IRoundingData* roundingData) override;
}
HERE


s82=<<HERE
 SBOErr CompleteTotals(const TotalsPair (&totalFields)[fieldsCount], PDAG pBudgetDag);
HERE

s83=<<HERE
extern void ALRSetColParams (ALRColParamsPtr colParams, PDAG dagALR, long recOffset);
extern void a();
HERE

s84=<<HERE
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
if (thouseSepStr[0] == L'\x07');
L"\x07";
HERE

s85=<<HERE
int main(char*arg[]){
    int a = 1;
    if (a == 1)
        if (a == 1)
            goto l;
l:
    int b = 1;
    fn();
    return;
}
HERE
s86=<<HERE
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
HERE

s87=<<HERE
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
HERE

s88=<<HERE
CTransactionJournalObject::CTransactionJournalObject (const TCHAR *id, CBizEnv &env) :
							CSystemBusinessObject (id, env), m_digitalSignature (env){
                            }
HERE

s89=<<HERE


#define __RegisterSensitiveFieldInner(objectId, offset, column, defaultVal, beginVersion,  tryDKey)\

#define DECLARE_SENSITIVE_FIELD()\
public:\
	class SensitiveFieldsHolder\
	{\
	public:\
		SensitiveFieldsHolder();\
		const SensitiveFieldList* GetSensitiveFields() const {return &m_sensitiveFieldList;}\
		~SensitiveFieldsHolder(){m_sensitiveFieldList.clear ();}\
	private:\
		SensitiveFieldList m_sensitiveFieldList;\
	};\
private:\
	static const SensitiveFieldsHolder sfHolder;\

#define BEGIN_REGISTER_SENSITIVE_FIELD(TYPE)\
	const TYPE::SensitiveFieldsHolder TYPE::sfHolder;\
	
#define REGISTER_SENSITIVE_FIELD_DKEY(objectId, offset, column, defaultVal, beginVersion)\

#define REGISTER_SENSITIVE_FIELD_SKEY(objectId, offset, column, defaultVal, beginVersion)\

#define END_REGISTER_SENSITIVE_FIELD()\

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
HERE
s90=<<HERE
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

HERE
s91=<<HERE
SBOErr	CTransactionJournalObject::OnUpdate()
{
        trace("OnUpdate");
    }
HERE
s92=<<HERE
#define B1_OBSERVER_API
typedef bool (*DBD_ProgressCallback) (void *userData, long curr, long max);
typedef bool (*DBD_FilterCallback) (PDAG pDag, long rec, void *param1, void *param2);
typedef SBOErr (*DBD_CondCallback) (void *form, DBD_Params *addedParams);
void     SetProgressCallback (DBD_ProgressCallback progressProc, void* userData, CProgressIndicator *progressPtr);
B1_OBSERVER_API bool IsGrossPriceMode() { return GetEnv().EnableGrossPriceMode() && GetPriceMode().CompareNoCase(SBOString(STR_PRICE_MODE_GROSS_PRICE)) == 0; }
HERE

s93=<<HERE
typedef union _BigInt
{
    int i64[SIZE_IN_INT64];
    uint64_t u64[SIZE_IN_INT64];
    int i32[SIZE_IN_INT32];
    uint32_t u32[SIZE_IN_INT32];
} BigInt;
BigInt data;
HERE

s94=<<HERE
extern "C"{
    int a=1;
    void main(){
    }
    int b(){
        c();
    }
}
HERE

s95=<<HERE
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
HERE
s96=<<HERE
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
HERE
s97=<<HERE
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
HERE
s98=<<HERE
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
HERE
s99=<<HERE
//for (auto fkv : EFMMapping::Map)
//{
//	if (value == fkv.second)
//	{
//		result = fkv.first;
//		break;
//	}
//}
//for (auto itr = m_WtAmountsChangeStatus.begin (); itr != m_WtAmountsChangeStatus.end (); ++itr){
//    Clear (itr->first);
//}
//for (; _First < _Last; _First += _Stride)
	//_Val = 16777619U * _Val ^ (size_t) _Keyval[_First];
// const auto &str = GetAttributeString (colIndex, arrayOffset, line);

//template <class HT, typename ParamType, typename KeyType, class DT>
//typename CMulticastDelegateByKey<HT, ParamType, KeyType, DT>::FuncType CMulticastDelegateByKey<HT, ParamType, KeyType, DT>::GetHandler (KeyType key, long index) const{
//}
//bool result = (m_ht->*((*handlerArr)[i]))(params, handled);
//bool result =  (m_objHandler->*m_functionHandler)();
const TNode& operator[] (ptrdiff_t n) const { 
    return const_cast (this)->operator[] (n); 
}
HERE

s_notsupport=<<HERE # lumda
std::remove_copy_if (diffColsList.begin (), diffColsList.end (), std::back_inserter (newDiffColsList),
	[] (const DBM_ChangedColumn& c) { return c.GetColType () != dbmText && c.GetBackupValue ().IsEmpty () && c.GetValue ().IsEmpty (); });
auto Cleanup = [&] () {}

// operator =, and call operator directly
void	operator += (const SBOString& str)
{
	operator +=((const TCHAR*)str);
}
// multi call to multiple parent classs's constructor is not support, generated ruby will only call one "super(xxx)"
class CTaxMoneyOverflowException : virtual public CTaxException, public CMoneyOverflowFormulaException, public C
{
public:
	CTaxMoneyOverflowException (long id, const SBOString& op1, const SBOString& op2, const SBOString& op, CBizEnv& env)
	: CTaxException (id, env), CMoneyOverflowFormulaException (id, op1, op2, op) {}
    
		//: CTaxException (id, env){}
        
	virtual ~CTaxMoneyOverflowException() {}

	virtual SBOString GetDescription ();
};
HERE



if !testall
   
    s = s99
else

    r = ""
    for i in 0..100
        begin
            si = eval("#test case #{i}\ns#{i}")
        rescue
            break
        end
        if si !=nil
            r += si +"\n"
        end
    end
    s = r
    p(" ==== find #{i} testcase")
end

p s

scanner = CScanner.new(s, false)
p "===>scanner =#{scanner}"
p "==>#{scanner.nextSym}"
$sc = scanner
$sc_cur = scanner.currSym.sym
error = MyError.new("whaterver", scanner)
parser = Parser.new(scanner, error)

parser.Get
# puts "FunctionBody return \n#{parser.send("FunctionBody")}"
begin
    ret = parser.C

# parser.Preprocess

# scanner.Reset
# parser.Get

# ret = parser.C

    p "parsing result:#{ret}"
    error.PrintListing

    p "---->list classes"
    def list_classes(cls, tabs=0)

        cls.each{|k,v|
            for i in 0..tabs
                print("\t")
            end
            print "class #{k}@#{v}\n"
            if v
                list_classes(v.modules,tabs+1)
                list_classes(v.classes,tabs+1)
            end
        }
    
    end
    list_classes($g_classdefs)
    parser.dump_classes_as_ruby
    end # end of test
 
rescue Exception=>e
    parser.dump_pos
    throw e
end


#=end
test(false)
p "$typedef:#{$typedef.inspect}"

# execute after test

