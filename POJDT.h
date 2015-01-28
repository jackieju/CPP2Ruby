#pragma once
#ifndef POJDT_H
#define POJDT_H

#include	"OPRC.h"	
#include	"OOCR.h"	
#include	"JDT1.h"	
#include	"OCRD.h"
#include	"OINV.h"	
#include	"OBGT.h"	
#include	"BGT1.h"	
#include	"CRD3.h"	
#include	"PODocStructs.h"
#include	"_MatchMgr.h"
#include	"TaxAdaptorJournalEntry.h"
#include	"TaxData.h"
#include    "INV6.h"
#include    "PODIM.h"//VF_CostAcctingEnh
#include    "POMDR.h"
#include	"SequenceManager.h"
#include	"DBQStatement.h"
#include    "VirtualFlags.h"
#include	"SMU_BuildQuery.h"
#include    "POCRD.h"

#define MSG_STR_LIST						80315
//#define JTE_ACCOUNTING_VOUCHER_DOC_TYPE		110
//#define JTE_NO_DOC_TYPE_STR_APA				140	
//#define GW_ACCOUNTING_VOUCHER_DOC_TYPE				110 //VF_GBInterface
#include    "_WithholdingTaxMgr.h"
#include	"PODOC_Signature.h"

#define		JDT_UPDATE_DEDUCT_SP_NAME		_T("TmSp_SetVendorDeductPercent")
#define		OJDT_UPG_DUE_DATE_VER			VERSION_64_23	
#define		OJDT_UPG_SRC_LINE_VER			VERSION_2007_MR
#define		OJDT_UPG_AUTO_VAT_VER			VERSION_2004_MR	 
#define		OJDT_SYS_BASE_SUM_VER			VERSION_65_59
#define		OJDT_BOE_CONTROL_ACTS_VER		VERSION_65_61
#define		OJDT_BOE_CONTROL_ACTS_VEND_VER	VERSION_65_77
#define		OJDT_UPG_PERIOD_IND_VER			VERSION_65_67
#define		OJDT_PAID_JDT_VER				VERSION_2004_5
#define		OACT_UPG_SERIAL_VER				VERSION_2004_40
#define		OJDT_UPG_PERIOD_IND_VER_67		VERSION_2004_42
#define		OJDT_UPG_ZERO_TAX_VER			VERSION_2004_160
#define		OJDT_UPG_FIN_REP_VER			VERSION_2005_MR
#define		OJDT_GIUL_CRD_CODE_VER			VERSION_2005_15
#define		OJDT_UPG_BASE_REF_VER			VERSION_2005_15
#define		OJDT_DPM_LINE_TYPE_VER			VERSION_2005_106
#define		OJDT_DOC_SERIES_VER				VERSION_2005_117
#define		OJDT_CTRL_ACT_COL_VER			VERSION_2007_34
#define		OJDT_DEBIT_CREDIT_VER			VERSION_2007_010
#define		OJDT_RESET_CPRF_AGING_REP		VERSION_2007_53
#define		OJDT_UPGRADE_VAT_LINE_TO_NO_VER	VERSION_2007_53

#define		JDT_NOT_BGT_BLOCK	1
#define		JDT_BGT_BLOCK		2
#define		JDT_WARNING_BLOCK	3

#define		JDT_NOT_TYPE_DOCS_BLOCK		-1
#define		JDT_TYPE_DOCS_BLOCK			4
#define		JDT_TYPE_ACCOUNTING_BLOCK	5

#define		BLOCK_ONE_MESSAGE			1
#define		MONTH_ALERT_MESSAGE			2
#define		YEAR_ALERT_MESSAGE			3

#define		JDT_CANCELED_ERROR				2
#define		JDT_STORNO_ERROR				3
#define		JDT_BOTH_SIDE_ERROR				4
#define		JDT_BASE_SUM_WITHOUT_VAT		5
#define		JDT_REVERSE_DATE_ERROR			6
#define		JDT_LEAD_CODE_ERROR				7
#define		JDT_BLOCK_REFDATE_ERROR			8
#define		JDT_OB_ACT_NOT_BAL_ERR			9
#define		JDT_WITH_NO_LINES_ERR				10
#define		JDT_LOCAL_BP_WITH_FC_AMOUNTS_ERR	11
#define		JDT_EU_REPORT_DIFFER_ONE_BP_ERR		12
#define		JDT_347_REPORT_DIFFER_ONE_BP_ERR	13
#define		JDT_REPORT_MANUAL_TRANS_ONLY_ERR	14
#define		JDT_NEED_LOCATION_ERR				17
#define		JDT_340_REPORT_RESIDENNUM_CHNG_ERR	22 // VF_Model340_EnabledInOADM
#define		JDT_340_REPORT_OPERATCODE_CHNG_ERR	23 // VF_Model340_EnabledInOADM


//VF_JEWHT   message string
#define     JTE_MULTI_BP_WARNING_STR1			22
#define     JTE_MULTI_BP_WARNING_STR2	        23 //je_wht
#define     JTE_WT_BP_SIDE_ERR                  24 //je_WHT
//can not set Manage WTax"=Yes, when "Automatic tax" = No.
#define     JTE_WT_CANNOT_SET_YES               25

// VF_EnablePostingPreview
#define		JTE_PP_FORM_TITLE_STR				29
#define		JTE_PP_CLOSE_BUTTON_STR				30

#define		JTE_STORNO_STR				7
#define		JTE_STORNO_IRU_STR			65

// defines from CREATE NEW COMPANY
#define		CNC_FORM_NUM				70
#define		CNC_PERIOD_MISSING_STR		3

// Res fields of boe upgrade
#define		RES_TRANS_ABS				0
#define		RES_LINE_ID					1
#define		RES_ACCT_NUM				2
#define		RES_INTR_MATCH				3
#define		RES_SHORT_NAME				4
#define		RES_NUM_OF_RES				5

// Res fields for CreateDate upgrade
#define		RES1_TRANS_ABS				0
#define		RES2_TRANS_ABS				0
#define		RES2_CREATEDATE				1

// Res fields for canceled Deposit upgrade
#define		RES_TRANS_ABS_UPGRADE_DPS	0
#define		RES_NUMBER_UPGRADE_DPS		1

#define		DPS_TYPE_STR			_T("25")
#define		OVER_NO			*VAL_NO
#define		OVER_DIRECT		*VAL_DIRECT
#define		OVER_INDIRECT	*VAL_INDIRECT
#define		JDT_ACT_INCOME	VAL_INCOME

//FILE
#define		RECORD_LEN				150
#define		FILE_TAB				_T("\t")
#define		FILE_NEW_LINE			_T("\r\n")
#define		FILE_NAME				_T("transaction.txt")

// for BOE upgrade 
#define	JDT_BOT_TYPE			0
#define	JDT_RCT_TYPE			1
#define	JDT_DPS_TYPE			2
#define	NUM_OF_BOE_ITERATIONS   3

// for line type upgrade
#define	NUM_OF_MAX_ITERATIONS   30

// for the "UpgradeDpmLineTypeUsingRCT2" function
#define UPG_LINE_TYPE_ORCT_ABS_ENTRY_RES			0
#define UPG_LINE_TYPE_RES_SIZE						1

//je_wht
#define JDT_WT_LOCAL_CURRENCY   INV_LOCAL_CURRENCY
#define JDT_WT_SYS_CURRENCY     INV_SYSTEM_CURRENCY
#define JDT_WT_FC_CURRENCY      INV_CARD_CURRENCY 

#define EQUISITION_ACT_TYPE		1

#define	JTE_VAL_AR				_T("R")
#define	JTE_VAL_AP				_T("P")
#define VAL_MANUAL_UPDATE		_T("M")

// Defines for setting dates in canceled JE for In/Out Payments
#define JE_CANCEL_DATE_SYSTEM			0				// use current system date
#define JE_CANCEL_DATE_ORIGINAL			1				// use original dates from original JE
#define JE_CANCEL_DATE_FUTURE			2				// use original 'undefined' behavior (case for JE with future posting date)

/************************************************************************************
************************************************************************************/
// columns for reconciliation upgrade dag res
#define RES_UPG_DOC_TRANS_ABS				0
#define RES_UPG_DOC_LINE_ID					1
#define RES_UPG_DOC_CREATED_BY				2
#define RES_UPG_DOC_SRC_LINE				3
#define RES_UPG_DOC_BALANCE_DUE_DEBIT		4
#define RES_UPG_DOC_BALANCE_DUE_CREDIT		5
#define RES_UPG_DOC_BALANCE_DUE_FC_DEB		6
#define RES_UPG_DOC_BALANCE_DUE_FC_CRED		7
#define RES_UPG_DOC_BALANCE_DUE_SC_DEB		8
#define RES_UPG_DOC_BALANCE_DUE_SC_CRED		9
#define RES_UPG_DOC_DEBIT_CREDIT			10
#define RES_UPG_DOC_ACT_CODE				11
#define RES_UPG_DOC_SHRT_NAME				12
#define RES_UPG_DOC_LINE_TYPE				13
#define RES_UPG_DOC_DEBIT					14
#define RES_UPG_DOC_FC_DEBIT				15
#define	RES_UPG_DOC_SYS_DEBIT				16
#define RES_UPG_DOC_CREDIT					17
#define RES_UPG_DOC_FC_CREDIT				18
#define	RES_UPG_DOC_SYS_CREDIT				19
#define	RES_UPG_DOC_INTR_MATCH				20
#define RES_UPG_DOC_CLOSED					21
#define RES_UPG_DOC_APPLIED_TO_DATE			22
#define RES_UPG_DOC_APPLIED_FRGN			23
#define	RES_UPG_DOC_APPLIED_SYS				24
#define	RES_UPG_DOC_MULT_MATCH				25

#define RES_UPG_DOC_NUM_OF_RES				26

#define RES_UPG_DOC_VAT_SUM					RES_UPG_DOC_NUM_OF_RES
#define RES_UPG_DOC_VAT_FRGN				RES_UPG_DOC_NUM_OF_RES + 1
#define RES_UPG_DOC_VAT_SYS					RES_UPG_DOC_NUM_OF_RES + 2
#define RES_UPG_DOC_IS_SELF_INV				RES_UPG_DOC_NUM_OF_RES + 3

#define RES_UPG_DOC_NUM_OF_RES_WITH_VAT		RES_UPG_DOC_NUM_OF_RES + 4

/************************************************************************************
************************************************************************************/
#define RES_UPG_REC_SHORT_NAME				0
#define RES_UPG_REC_BP_CURRENCY				1
#define RES_UPG_REC_LC_DIFF_AMNT			2
#define RES_UPG_REC_SC_DIFF_AMNT			3
#define RES_UPG_REC_FC_DIFF_AMNT			4
#define RES_UPG_REC_FC_CURRENCY				5
#define RES_UPG_REC_BALDUE_LC_DIFF_AMNT		6
#define RES_UPG_REC_BALDUE_SC_DIFF_AMNT		7
#define RES_UPG_REC_BALDUE_FC_DIFF_AMNT		8
#define RES_UPG_REC_ACCT_NUM				9

#define RES_UPG_REC_NUM_OF_RES				10

/************************************************************************************
************************************************************************************/
#define RES_UPG_REC_NUM_OF_ABSENTRY_RECORD	500

/************************************************************************************
************************************************************************************/

#define UPG_OJDT_FOLIO_CHUNK_SIZE	10000
#define UPG_OJDT_CREATED_BY_CHUNK_SIZE	50000
#define UPG_OJDT_KEY				0
/************************************************************************************
************************************************************************************/
#define JDT_PAYMENT_UPG_DOC_ACT_CODE			0
#define JDT_PAYMENT_UPG_DOC_SHRT_NAME			1
#define JDT_PAYMENT_UPG_DOC_LINE_TYPE			2
#define JDT_PAYMENT_UPG_DOC_SRC_LINE			3
#define JDT_PAYMENT_UPG_DOC_DEBIT_CREDIT		4
#define	JDT_PAYMENT_UPG_DOC_CREDIT				5
#define	JDT_PAYMENT_UPG_DOC_FC_CREDIT			6
#define	JDT_PAYMENT_UPG_DOC_SYS_CREDIT			7
#define	JDT_PAYMENT_UPG_DOC_DEBIT				8
#define	JDT_PAYMENT_UPG_DOC_FC_DEBIT			9
#define	JDT_PAYMENT_UPG_DOC_SYS_DEBIT			10
#define	JDT_PAYMENT_UPG_DOC_BALANCE_DUE_CREDIT	11
#define	JDT_PAYMENT_UPG_DOC_BALANCE_DUE_FC_CRED	12
#define	JDT_PAYMENT_UPG_DOC_BALANCE_DUE_SC_CRED	13
#define	JDT_PAYMENT_UPG_DOC_BALANCE_DUE_DEBIT	14
#define	JDT_PAYMENT_UPG_DOC_BALANCE_DUE_FC_DEB	15
#define	JDT_PAYMENT_UPG_DOC_BALANCE_DUE_SC_DEB	16
#define JDT_PAYMENT_UPG_DOC_INTR_MATCH			17
#define JDT_PAYMENT_UPG_DOC_MULT_MATCH			18
#define JDT_PAYMENT_UPG_DOC_CLOSED				19

#define	JDT_PAYMENT_UPG_NUM_OF_FIELDS			20


enum
{
	resTax1AbsEntry = 0L,
	resTax1TaxCode,
	resTax1EqPercent,
	resJdt1TransId,
	resJdt1Line_ID,
};
#define UPG_JDT1_EQUVATRATE_CHUNK_SIZE			10000


//--------------------------------------------------------------------------
#define JTE_VAT_LINE_ERROR_STR					19
#define JTE_SERIES_NOT_DEFINE_STR				22
#define JTE_APPROVE_SIDE_STR					23
#define JTE_EDIT_VAT_ERROR_STR					26
#define JTE_CANT_CANCEL_ERROR_STR				27
#define JTE_EDIT_SYSTEM_ERROR_STR				28
#define JTE_TAX_POST_ACC_MISSING_STR			31
#define JTE_TAX_POST_ACC_CHANGE_ERR_STR			32
#define JTE_TAX_CODE_CHANGE_ERR_STR				33
#define JTE_VAT_GROUP_CHANGE_ERR_STR			34
#define JTE_TAX_CODE_IN_BP_LINE_STR				35
#define JTE_INTL_RECON_UPGRADE_JDT_STR			36 /* Internal Reconciliation Upgrade Journal */
#define JTE_CAN_NOT_EDIT_VAT_SUM_STR			39
#define JTE_INV_LINKED_PAY_IRU_STR				40 /* Case A1 - Invoice Linked to Reconciled Payment */
#define JTE_CM_LINKED_PAY_IRU_STR				41 /* Case A4 - Credit Memo Linked to Reconciled Payment */
#define JTE_PAY_LINKED_TRANS_IRU_STR			42 /* Case A5 - Payment Linked to Reconciled Transaction */
#define JTE_INV_CM_LINKED_CM_INV_IRU_STR		43 /* Case A6 - Invoice/Credit Linked to Credit/Invoice */
#define JTE_JE_LINKED_PAY_IRU_STR				44 /* Case A7 - Journal Entry Linked to Reconciled Payment */
#define JTE_CANCELLED_RECON_IRU_STR				45 /* Case B - Cancelled Reconciliation */
#define JTE_UNBALANCED_RECON_IRU_STR			46 /* Case D - Unbalanced Reconciliation */
#define JTE_CANCEL_PAY_JE_WITH_PAY_IRU_STR		47 /* Case E - Cancellation of Payment/JE within Payment */
#define JTE_RECON_CANCEL_PAY_JE_IRU_STR			48 /* Case H - Reconciliation of a Cancelled Payment or JE */
#define JTE_PART_EXRATE_DIFF_IRU_STR			49 /* Case I - Partial Exchange Rate Difference Recognition */
#define JTE_BALANCE_UPGRADE_JE_IRU_STR			50 /* Balancing Upgrade Journal Transaction */
#define JTE_DPM_DOUBLE_APPLICATION_JE_IRU_STR	51 /* CEE CASE 2 - Double Applications of Payments of Down Payment Request */
#define JTE_MULTIBP_RATE_IRU_STR				52 /* Case CEE 3 - Missing Exchange Rate Difference behind Multi BPs Reconciliation */
#define JTE_DPM_EX_RATE_DIFF_IRU_STR			53 /* Case K - Exchange Difference Recognition of Payments of DPM Requests */
#define JTE_RECON_DPM_REQUEST_IRU_STR			54 /* Case J - Reconciliation of Payments Associated with DPM Request */
#define JTE_MULTIBP_UNBALANCED_IRU_STR			55 /* Case CEE 7 - Unbalanced Multi BP Reconciliation */
#define JTE_AMOUNT_DIFF_IRU_STR					56 /* Case CEE 10 - Amount Differences */
#define JTE_DPM_DOUBLE_APPL_OF_INV_IRU_STR		57 /* Case CEE 8 - Double Applications of Invoice after Linking of Down Payment */
#define JTE_DPM_REQ_CANCELED_PAY_IRU_STR		58 /* Case CEE 9 - Canceled Payment of DPM Request */
#define JTE_INV_CM_LINKED_CM_INV_IRU_YT_STR     59 /* Case L1    - Year Transfer for Credit Notes*/
#define JTE_YEAR_TRANSFER_PAY_IRU_STR			60 /* Case L2 - Year Transfer for payments */
#define JTE_PMNT_PAID_PMNT_WITH_DOCS_IRU_STR	61 /* Case M - Payment of a Payment Linked to Transactions */
#define JTE_INCONSIST_CONSOLIDATING_BP_STR		62 /* Case N - Consolidating Business Partner */
#define JTE_INCONSIST_CONTROL_ACCOUNT_STR		63 /* Case O - Multiple Control Accounts */
#define JTE_CANCEL_PAY_DIFF_CTRL_ACT_STR		64 /* Case P - Cancelled Payments with different ctrl accounts*/

#define JTE_CANT_REVERSE_NEGTIVE_WT_JE          67 /*can not reverse negtive wt Jounal Entry*/

// Payment Block PRD.
#define JTE_PAYBLOCK_ALLOWED_IN_MANUAL_JE_STR   76 /*Payment block settings are only permitted in manual journal entry*/
#define JTE_PAYBLOCK_ALLOWED_IN_BP_ACCOUNT_STR  77 /*Payment block settings are only permitted in business partner account*/
#define JTE_BLOCK_REASON_ALLOWED_ERROR_STR      78 /*Block reason is only permitted when payment block is set to "Y"*/
#define JTE_EQUALIZATION_TAX_DISABLED_ERROR_STR	79 /*Equalization tax is disabled as one or more BPs is not Equalization Tax relevant*/

#define JDT_LOCAL_CURRENCY						1
#define JDT_SYSTEM_CURRENCY						2
#define JDT_CARD_CURRENCY						3 
/************************************************************************************
************************************************************************************/

SBOErr	OJDTWriteErrorMessage (CBusinessObject *bizObject);

class CJDTStornoExtraInfoCreator;
class CPaymentDoc;
struct CJDTWTInfo;
class CJDTDeferredTaxUtil;
// VF_ERDPostingPerDoc ERD BaseTrans Upgrade
typedef std::set<SBOString> DocAbbrevSet;
typedef std::map<long,DocAbbrevSet> ObjectAbbrevsMap;
typedef ObjectAbbrevsMap::const_iterator ObjectAbbrevsMapCIt;
struct FCRoundingStruct
{
	FCRoundingStruct()
		:lastNonZeroFCLine(-1), needRounding(false)
	{}

	bool				needRounding;
	CAllCurrencySums	totalDebitMinusCredit;
	long				lastNonZeroFCLine;
};
class CTransactionJournalObject: public CSystemBusinessObject, public IReconcilable, public IWithHoldingAble
{
	friend class CJournalWriter;
public:	
	SBOErr	ValidateRelations (ArrayOffset ArrOffset, long rec, long field, long object, bool showError = true);
private:
	SBOErr	CalculationSystAmmountOfTrans ();
	SBOErr	CalculationFrnAmmounts (PDAG dagACT, PDAG dagCRD, bool& found);
	SBOErr	IsCurValid (TCHAR *crnCode, PDAG unused);
	SBOErr  IsPaymentBlockValid (PDAG dagJDT1, long rec);

protected:
	CTransactionJournalObject (const TCHAR *id, CBizEnv &env);

public:
	virtual ~CTransactionJournalObject(); 
	FOUNDATION_EXPORT static CBusinessObject	*CreateObject (const TCHAR *id, CBizEnv &env);
	virtual void			CopyNoType (const CBusinessService&);
	virtual Boolean			IsPeriodIndicCondNeeded ();

	SBOErr	RecordHist (CBusinessObject& bizObject, PDAG dag);

	virtual	SBOErr	YouHaveBeenReconciled (CMatchData& yourMatchData); 
	virtual	SBOErr	YouHaveBeenUnReconciled (const CMatchData& yourMatchData);
	virtual bool	IsDeferredAble	() const {return false;}
	virtual bool	IsSmallDifferenceAble() const {return false;}
	virtual	bool	IsWithHoldingAble () const {return VF_JEWHT(GetEnv());}
    //// IWithHoldingAble virtual functions
    WithHoldingTaxSet	GetWithHoldingTax (bool onlyPaymentCateg, long installment = 0);  
	virtual SBOErr		LoadObjInfoFromDags (ObjectWTaxInfo &objInfo, PDAG dagObj, PDAG dagWTaxs, PDAG dagObjRows);
	virtual SBOErr		GetWTaxReconDags (PDAG &dagOBJ, PDAG &dagObjWTax, PDAG &dagObjRows);
	virtual SBOErr				CreateDocInfoQry (DBQRetrieveStatement &docInfoQry);
	
#ifndef MNHL_SERVER_MODE
	virtual SBOErr	Display (PDAG dag, PFORM callerFormPtr, PAReturnProc linkReturnProc, FORM_Mode initialMode);
#endif

	// static
	static	SBOErr	DocBudgetCurrentSum (CBusinessObject *bizObject,PMONEY currentMoney, const TCHAR *acctCode);
	static	SBOErr	UpdateAccumulators (CBusinessObject *bizObject,long rec, Boolean isCard);
	static	SBOErr	SetBudgetBlock (CBusinessObject *bizObject,long blockLevel, MONEY *testMoney, MONEY * testYearMoney, MONEY *testTmpM, MONEY *testYearTmpM, 	bool  workWithUI = true);
	static	SBOErr	DocBudgetRestriction (CBusinessObject *bizObject, const TCHAR *acctCode, MONEY *Sum, TCHAR *refDate, 
		Boolean *budgetAllYes, bool isWorkWithUI = true);

	static	void	GetYearAndMonthEntry (PDAG dagJDT, Boolean byRef, long rec, long *month, long *year) ;
	static	void	GetYearAndMonthEntryByDate (TCHAR *dateStr, long *month, long *year);

	static	long	GetSRObjectBudgetAcc (long object);
	static	long	RettypeBlockLevel(CBizEnv &bizEnv, long id);
	static	long	RetBlockLevel(CBizEnv &bizEnv);
	static	SBOErr	RecordJDT (CBizEnv &env, PDAG dagJDT, PDAG dagJDT1, bool reconcileBPLines = true);
	static	SBOErr	UpdateDocBudget (CBusinessObject *bizObject, AcctGroupRecordBudgetPtr updateBgtPtr, CPDAG dagDOC1, long rec);
	static	SBOErr	OJDTCheckIntegrityOfJournalEntry (CBusinessObject *bizObject, Boolean checkForgn);
	static	SBOErr	OJDTCheckJDT1IsNotEmpty (CBusinessObject *bizObject);
	static	SBOErr	OJDTValidateJDTOfLocalCard (CBusinessObject *bizObject);
	static	SBOErr  OJDTCheckBalnaceTransection (CBusinessObject *bizObject, Boolean checkForgn);
	static  SBOErr  OJDTCheckFcInLocalCard(CBusinessObject *bizObject, PDAG dagJDT1, long rec);
	static	SBOErr	OJDTValidateJDT1Accounts (CBusinessObject *bizObject);
	static  SBOErr  OJDTSetPaymentJdtOpenBalanceSums (CPaymentDoc *paymentObject, PDAG dagJDT1, long *resDagFields, long fromOffset, bool foundCaseK);
	static	SBOErr	OJDTFillAccountsFromJDT1RES (PDAG dag, long *resDagFields, AccountsArray* accountsArrayRes);
    static  long    GetWtSumField(long currSource); //VF_JEWHT
	static  void	OJDTGetRate (CBusinessObject* bizObject, long curSource, MONEY *rate);
	static  void	OJDTGetDocCurrency(CBusinessObject* bizObject, TCHAR *docCurrency);
	static	SBOErr	CostAccountingAssignmentCheck (CBusinessObject* bizObject);
	static	SBOErr	OJDTValidateCostAcountingStatus (CBusinessObject* bizObject, PDAG dagJDT);
	static  SBOErr  GetTransIdByDoc(CBizEnv& bizEnv, long &transId, long transtype, long createdby, bool returnMinTransId = true);

	static  SBOErr  SetJournalDocumentNumber(CBizEnv* bizEnv, CBusinessObject *bizObject, PDAG dagJDT);
	static  SBOErr  UpdateAccountBalance(CBizEnv* bizEnv, PDAG dagACT, PDAG dagJDT, PDAG dagJDT1);


	// VF_PaymentDueDate
	bool	OJDTIsDueDateRangeValid ();
	bool	OJDTIsDocumentOrDueDateChanged ();

	//VF_JEWHT
    SBOErr  CompleteWTInfo(); 
	SBOErr	CompleteWTLine ();								
	SBOString  WTGetBpCode ();
	static SBOString  WTGetBPCodeImp(PDAG dagJDT, PDAG dagJDT1); 
	SBOString	WTGetCurrency ();
    static SBOString   WTGetCurrencyImp(PDAG dagJDT, PDAG dagJDT1);
	SBOErr  SetCurrRateForDOC (PDAG dagDOC);
	SBOErr SetSysCurrRateForDOC( PDAG dagDOC );
    
	SBOErr  SetJDTLineSrc (long line, long absEntry, long srcLine);
	SBOErr	SetDebitCreditField();
	SBOErr	DoSingleStorno (bool checkDate = true);
	SBOErr	ReconcileCertainLines();
	SBOErr	ReconcileDeferredTaxAcctLines();
	SBOErr	GetBudgBlockErrorMessage (TCHAR *MonthmoneyStr, TCHAR *YearmoneyStr, const SBOString& acctKey, long messgNumber, TCHAR*retMsgErr);

	bool	IsPaymentOrdered ();
	static SBOErr	IsPaymentOrdered (CBizEnv& bizEnv, long transId, bool& isOrdered);

	SBOErr	IsScAdjustment (bool &isScAdjustment);

	SBOErr	CompleteJdtLine ();
	SBOErr	CompleteVatLine ();
	SBOErr	ComplateStampLine ();
	SBOErr	CompleteTrans ();
	SBOErr	CompleteForeignAmount();
	void	SetContraAccounts (PDAG dagJdt1, long firstRec, long maxRec, TCHAR *contraDebKey, TCHAR *contraCredKey, long contraDebLines, long contraCredLines);
	void	SetVatJournalEntryFlag ();						// VF_ExciseInvoice
	bool	GetVatJournalEntryFlag () { return m_isVatJournalEntry; };

	void			SetJournalKeys( SJournalKeys * jrnlKeys){ m_jrnlKeys = jrnlKeys; }
	SJournalKeys*	GetJournalKeys(void){ return m_jrnlKeys ; }
	CSequenceParameter*	GetSeqParam();

	CTaxAdaptorJournalEntry* GetTaxAdaptor()
	{
		return OnGetTaxAdaptor();
	}
	virtual CTaxAdaptorJournalEntry* OnGetTaxAdaptor();
	virtual	SBOErr	LoadTax();
	virtual	SBOErr	CreateTax();

	virtual SBOErr	BeforeDeleteArchivedObject	(ArcDeletePrefs& arcDelPref);
	virtual SBOErr	AfterDeleteArchivedObject	(ArcDeletePrefs& arcDelPref);

	void	SetStornoExtraInfoCreator (CJDTStornoExtraInfoCreator* stornoExtraInfoCreator){m_stornoExtraInfoCreator = stornoExtraInfoCreator;}

	// attributes

	//services 
	SBOErr	SetToZeroNullLineTypeCols ();
	SBOErr	SetToZeroOldLineTypeCols ();
	SBOErr	UpgradeDpmLineTypeUsingJDT1 (long paymentObj);
	SBOErr	UpgradeDpmLineTypeUsingRCT2 (long paymentObj);
	SBOErr	UpgradeDpmLineTypeExecuteQuery  (PDAG dagQuery, PDAG *dagRes, long object, bool isFirst);
	SBOErr	UpgradeDpmLineTypeUpdate (PDAG dagRes, long object, bool isFirst);


	virtual					SBOErr AddRowByParent(PDAG pParentDAG, long lParentRow, PDAG pChildDAG);
	virtual					long GetFirstRowByParent(PDAG pParentDAG, long lParentRow, PDAG pChildDAG);
	virtual					long GetNextRow(PDAG pParentDAG, PDAG pDAG, long lRow, bool bNext);
	virtual					long GetLogicRowCount(PDAG pParentDAG, long lParentRow, PDAG pDAG);

	SBOErr					CancelJournalEntryInObject (SBOString &objectId, SBOString postingDate=EMPTY_STR, SBOString taxDate=EMPTY_STR, SBOString dueDate=EMPTY_STR);
	static void				SetJECancelDate (CBizEnv& bizEnv, const SBOString& sCancelDate, PDAG dagOBJ, PDAG dagJDT, PDAG dagJDT1, const SBOString& taxDate, 
											const SBOString& dueDate, long cancelMode, const SBOString& sysDate);
	
	//vf_costAcctingenh
	static long   GetOcrCodeCol(long dim)
	{
		long  nCol[]= {JDT1_OCR_CODE, JDT1_OCR_CODE2, JDT1_OCR_CODE3, JDT1_OCR_CODE4, JDT1_OCR_CODE5};
		return nCol[dim];
	}

	static long	GetOcrColDimension(long ocrColumn)
	{
		switch (ocrColumn)
		{
		case JDT1_OCR_CODE:
			return DIMENSION_1;
			break;
		case JDT1_OCR_CODE2:
			return DIMENSION_2;
			break;
		case JDT1_OCR_CODE3:
			return DIMENSION_3;
			break;
		case JDT1_OCR_CODE4:
			return DIMENSION_4;
			break;
		case JDT1_OCR_CODE5:
			return DIMENSION_5;
			break;
		default:
			return 0;
			break;
		}
	}
	
	static long GetValidFromCol(long dim)
	{
		long nCol[] = {JDT1_VALID_FROM, JDT1_VALID_FROM2, JDT1_VALID_FROM3, JDT1_VALID_FROM4, JDT1_VALID_FROM5};
		return nCol[dim];
	}

	CWithholdingTaxManager	&GetWithholdingTaxManager (){return m_WithholdingTaxMng;}	//vf_jewht
	static long             GetWTBaseNetAmountField (long curr);
	static long             GetWTBaseVATAmountField(long curr);
	long    GetBPCurrencySource(); 
	Date	GetCreateDate();

	static bool	IsManualJE (PDAG dagJDT); // VF_Model340_EnabledInOADM

	// VF_PaymentDueDate
	bool	IsCardLine (const long rec);
	bool	ContainsCardLine ();

	// Posting preview (VF_EnablePostingPreview).
	void SetPostingPreviewMode (bool enable = true) { m_isPostingPreviewMode = enable; }
	bool IsPostingPreviewMode () { return m_isPostingPreviewMode; }

	//VF_EnableLinkMap
	virtual	SBOErr			GetLinkMapMetaData (LinkMap::ILMVertex& el);

	SBOErr					ValidateBPL (const bool bValidateSameBPLIDOnLines = false);	// VF_MultiBranch_EnabledInOADM 
	static SBOErr			ValidateBPLEx (CBusinessObject* bizObject);					// VF_MultiBranch_EnabledInOADM 
	void SetIsPostingTemplate (bool isPostingTemplate) {m_isPostingTemplate = isPostingTemplate;}
	bool GetIsPostingTemplate () {return m_isPostingTemplate;}
protected:
	virtual SBOErr			OnIsValid ();
	virtual SBOErr			OnCreate ();
	virtual SBOErr			OnUpdate ();
	virtual SBOErr			OnAutoComplete ();
	virtual SBOErr			OnCanUpdate ();
	virtual	SBOErr			OnInitData ();
	virtual SBOErr			OnUpgrade ();
	virtual SBOErr			OnCancel ();
	virtual	SBOErr			OnCheckIntegrityOnCreate();
	virtual	SBOErr			OnCheckIntegrityOnUpdate();
	virtual	SBOErr			OnInitFlow ();
	virtual SBOErr			OnCommand(long command);
	virtual SBOErr			OnSetDynamicMetaData(long commandCode);

	virtual	SBOErr			OnGetByKey ();
	virtual SBOErr			CompleteKeys ();

	virtual bool			OnCanCancel ();
	//**********************************************************************************************
	// The function below are functions for the archiving feature

	virtual SBOErr			CanArchiveAddWhere(	CBizEnv& bizEnv,
												DBQRetrieveStatement& canArchiveStmt,
												const Date& archiveDate,
												DBQTable& tObjectTable);
	virtual	SBOErr			GetArchiveDocNumCol (long& outArcDocNumCol);
	virtual SBOErr			CompleteDataForArchivingLog	();
	
	// End of functions for Archiving
	//**********************************************************************************************

	CTaxAdaptorJournalEntry*  m_taxAdaptor; 

	//Handle Saving Tax information
	virtual	SBOErr	UpdateTax();

	virtual void	OnGetCostAccountingFields(CostAccountingFieldMap& costAccountingFields);


	CTransactionJournalObject (const CTransactionJournalObject &other)
		: CSystemBusinessObject (other), m_digitalSignature (other.GetEnv ()) {};

private:
	SBOErr	OJDTFillJDT1FromAccounts (const AccountsConstArray& accountsArrayFrom, AccountsArrayRef accountsArrayRes, CBusinessObject *srcObject);
	SBOErr	UpgradeBoeActs();
	Boolean IsCardAlreadyThere (PDBD_Cond updateCardBalanceCond, TCHAR  *cardCode, long startingRec, long numOfCardConds);
	SBOErr  FixVendorsAndSpainBoeBalance ();
	SBOErr	UpgradePeriodIndic();
	void	BuildRelatedBoeQuery (DBD_Tables *tableStruct, long *numOfConds, long iterationType, long *numOfTables, DBD_CondStruct *condStruct, DBD_CondStruct *joinCondStructForOtherObj, DBD_CondStruct *joinCondStructBoe);
	SJournalKeys	*m_jrnlKeys;
	SBOErr	ValidateReportEU ();
	SBOErr	ValidateReport347 ();
	SBOErr	GetNumOfBPRecords (long& numOfBPfound, bool validateFedTaxId = false);
	SBOErr	ValidateVatReportTransType ();
	SBOErr	ValidateBPLNumberingSeries ();	// VF_MultiBranch_EnabledInOADM 
	SBOErr	IsBalancedByBPL ();				// VF_MultiBranch_EnabledInOADM 
	
	SBOErr	UpgradeOJDTCreatedByForWOR ();
	SBOErr	UpgradeOJDTUpdateDocType ();
	long	GetBaseEntry (PDAG dagRes, long docNum);
	SBOErr	UpgradeOJDTWithFolio ();
	SBOErr	UpgradeJDTCreateDate ();
	void	UpgradeCreateDateSubQuery (PDBD_Params subParams, PDBD_Res subResStruct, DBD_Tables *subTableStruct,
										PDBD_Cond subCond, long objectID);
	SBOErr	UpgradeJDTCanceledDeposit ();
	SBOErr	UpgradeJDT1VatLineToNo ();
	SBOErr	UpgradeYearTransfer ();
	SBOErr  UpgradePaymentFieldsForIRU ();
	SBOErr	RepairTaxTable ();

	SBOErr	UpgradeJDTCEEPerioEndReconcilations ();
	bool    IsBlockDunningLetterUpdateable ();
	SBOErr	UpgradeJDTIndianAutoVat ();
	SBOErr	UpgradeJDTIndianAutoVatInt (PDAG dagJDT1);

	bool	CheckColChanged (const PDAG dag, const long col, const long rec = 0L);

    //VF_JEWHT_BEGIN
    SBOErr  UpdateWTInfo ();      
    SBOErr	UpdateWTOnRecon (CMatchData& yourMatchData);            
    SBOErr  UpdateWTOnCancelRecon (const CMatchData& yourMatchData); 
    SBOString   GetJDTReconStatus ();  
    MONEY	CalcPaidRatioOfOpenDoc (CAllCurrencySums paidSum, bool paidSumInLocal, long transRowId, bool calcFromTotal); 
    SBOErr  OnCanJDT2Update();
    SBOErr  CheckWTValid(); 
    SBOErr  CheckMultiBP(); 
    SBOErr  GetDfltWTCodes(CJDTWTInfo* wtInfo);
    SBOErr  PrePareDataForWT(CWTAllCurBaseCalcParams* wtAllCurBaseCalcParamsPtr,
                                long currSource, PDAG dagDOC, CJDTWTInfo* wtInfo);
    SBOErr  JDTCalcWTTable(CJDTWTInfo* wtInfo, long currSource, PDAG dagDOC,
                           CWTAllCurBaseCalcParams *wtAllCurBaseCalcParamsPtr);
    long    GetJDT1MoneyCol(long currSource, bool isDebit);
    long    GetVATMoneyCol(long currSource);
    SBOErr  GetWTBaseAmount(long currSource, CWTBaseCalcParams* baseParam);
	SBOErr  GetWTCredDebt(SBOString& DebCre);

    SBOString GetBPLineCurrency(); 
    SBOErr  GetCRDDag() ;
    SBOErr  UpdateWTAmounts(CWTAllCurBaseCalcParams *wtAllCurBaseCalcParamsPtr);    
	long    WTGetCurrSource ();
	SBOErr  WtAutoAddJDT1Line (PDAG dagJDT1, long jdt1RecSize, PDAG dagJDT2, 
								long rec, bool isDebit, const SBOString& wtSide);
	SBOErr  WtUpdJDT1LineAmt (PDAG dagJDT1, long jdt1CurRow, PDAG dagJDT2, long jdt2CurRow,
							bool isDebit, const SBOString& wtAcctCode, const SBOString& wtSide);
	SBOErr  SetCurrForAutoCompleteDOC5 ();

	SBOErr CalcBpCurrRateForDocRate(MONEY& rate);
	//VF_JEWHT_END 

	// VF_ERDPostingPerDoc
	SBOErr UpgradeERDBaseTrans ();
	SBOErr UpgradeERDBaseTransFromBackup ();
	SBOErr UpgradeERDBaseTransUpdateOne (long transId, long erdBaseTrans);
	SBOErr UpgradeERDBaseTransFromRef3 ();
	SBOErr UpgradeERDBaseTransFindBaseTrans (const ObjectAbbrevsMap& objectMap, const SBOString& inAccount, const SBOString& inShortName, const SBOString& inRef3Line, long *outBaseTransCandidate);
	long UpgradeERDBaseTransGetFPRCol (long objectId);
	long UpgradeERDBaseTransGetTransIdCol (long objectId);
	void UpgradeERDBaseTransAddDocNumConds (long objectId, const SBOString& docNum, DBD_Conditions& conds);
	void UpgradeERDBaseTransPopulateAbbrevMap (ObjectAbbrevsMap& abbrevMap);

	bool	m_reconcileBPLines;		// reconcile BP Lines in OnCreate by default true

	bool		m_isInCancellingAcctRecon;
	std::set<SBOString>	m_reconAcctSet;

	bool	m_isVatJournalEntry;	// VF_ExciseInvoice

	CJDTStornoExtraInfoCreator*		m_stornoExtraInfoCreator;
	CSequenceParameter*				m_pSequenceParameter;
//[CostAcctingEnh] new mwthods
	//A private function to check if amount has been changed since the MDR was assigned
	bool AmountChangedSinceMDRAssigned_APA(CManualDistributionRuleObject *mdrObj, PDAG dagJDT1, long rec, long *changedDim);

	//@ABMerge ADD I035300 [ExciseInvoice]
	bool isValidMatType(long mat_type)
	{
		if ((mat_type != 0) && (mat_type != -1))
			return true;
		else
			return false;
	};

    CWithholdingTaxManager  m_WithholdingTaxMng;//VF_JEWHT

	// upgrade vat applied field for ORIN, RIN6, ORPC, RPC6
	SBOErr  UpgradeDOC6VatPaidForFullyBasedCreditMemos(long objID);
	SBOErr  UpgradeODOCVatPaidForFullyBasedCreditMemos(long objID);

	SBOErr RepairEquVatRateOfJDT1 ();
	SBOErr RepairEquVatRateOfJDT1ForOneObject (long objectId);
	SBOErr UpdateIncorrectEquVatRate (PDAG dagRes);
	SBOErr UpdateIncorrectEquVatRateOneRec (PDAG dagRes, long rec);

	// VF_Model340_EnabledInOADM
	SBOErr InitDataReport340 (PDAG dagJDT);
	SBOErr CompleteReport340 (PDAG dagJDT, PDAG dagJDT1);
	SBOErr ValidateReport340 ();

	SBOErr HandleFCExchangeRounding(PDAG dagJDT1, StdMap<SBOString, FCRoundingStruct, False, False> &currencyRoundingMap);
	CJournalEntryDigitalSignature	m_digitalSignature;

	// VF_FederalTaxIdOnJERow
	SBOErr UpgradeFederalTaxIdOnJERow ();

	//Upgrade DprId On BP account posting JE Row
	SBOErr UpgradeDprId(bool isSalesObject, long introVersion1_Including, long introVersion2);

	//Upgrade DprId On BP account posting JE Row for simple DPR payment
	SBOErr UpgradeDprIdForOneDprPayment(bool isSalesObject, long introVersion);

	//Update DprId On BP account posting JE Row
	SBOErr UpdateDprIdOnJERow(long paymentObjType, const APCompanyDAG& dagRES);
	

	// Posting preview (VF_EnablePostingPreview).
	bool m_isPostingPreviewMode;

	bool m_bZeroBalanceDue;	// VF_MultiBranch_EnabledInOADM

	bool m_isPostingTemplate;

public:
	SBOErr	UpgradeWorkOrderStep1 ();
	SBOErr	UpgradeWorkOrderStep2 ();
	SBOErr	UpgradeWorkOrderStep3 ();
	SBOErr	UpgradeWorkOrderStep4 ();
	SBOErr	UpgradeLandedCosErr   ();
	SBOErr	UpgradeWorkOrderErr	  ();

	bool isValidCENVAT(long cenvat)
	{
		if ((cenvat != 0) && (cenvat != -1))
			return true;
		else
			return false;
	}
	//@ABMerge END I035300

	SBOErr ValidateHeaderLocation();
	SBOErr ValidateRowLocation(long rec);
	SBOErr CompleteLocations();

	void	SetReconAcct (bool isInCancellingAcctRecon, SBOString& acct);
    void    LogBPAccountBalance(BPBalanceChangeLogDataArr &bpBalanceLogDataArray, SBOString & keyNum);

	// VF_MultiBranch_EnabledInOADM
	void	SetZeroBalanceDueForCentralizedPayment (bool set = true) {m_bZeroBalanceDue = set;}
	bool	IsZeroBalanceDueForCentralizedPayment () {return m_bZeroBalanceDue;}

};

class CJDTStornoExtraInfoCreator
{
public:
	CJDTStornoExtraInfoCreator (CTransactionJournalObject* jdtBusinessObject): m_jdtBusinessObject(jdtBusinessObject){}
	~CJDTStornoExtraInfoCreator () {}

	//copy constructor
	CJDTStornoExtraInfoCreator(const CJDTStornoExtraInfoCreator & other): m_jdtBusinessObject(other.m_jdtBusinessObject){}
	CJDTStornoExtraInfoCreator & operator=(const CJDTStornoExtraInfoCreator & other);

	virtual	SBOErr	Execute() = 0;
	virtual	bool	IsNeedToAddLineToReconciliation(PDAG dagJDT1, long rec, bool origDag) = 0;
	virtual bool	IsNeedToCancelReconForThisLine  (PDAG dagJDT1, long rec) = 0;
	CTransactionJournalObject* GetJDTBusinessObject() {return m_jdtBusinessObject;}
private:
	CTransactionJournalObject*	m_jdtBusinessObject;
};


struct CJDTWTInfo
{
    Boolean     cardWTLiable;
    TCHAR		wtDefaultCode[OCRD_WT_CODE_LEN+1]; 
    TCHAR		VATwtDefaultCode[OCRD_WT_CODE_LEN+1];  // OCRD_WT_CODE_LEN is used as the VATW
    TCHAR		ITwtDefaultCode[OCRD_ITWT_CODE_LEN+1]; // OCRD_ITWT_CODE_LEN is used as the ITW
    TCHAR		wtBaseType[OWHT_BASE_TYPE_LEN+1];
    TCHAR		wtCategory[OWHT_CATEGORY_LEN+1];    
    void Clear()
    {
        wtDefaultCode[0] = VATwtDefaultCode [0] = ITwtDefaultCode[0] = wtBaseType[0]
        = wtCategory[0] = _T('\0');
        cardWTLiable = false;
    }
};

enum DEFERREDTAXSTATUS
{
	dts_None,
	dts_Skip,
	dts_Deferred,
	dts_Invalid,
};

class CJDTDeferredTaxUtil
{
public:
	CJDTDeferredTaxUtil (CBusinessObject* bo);
	~CJDTDeferredTaxUtil ();

	static bool IsBPWithEqTax(const SBOString bpCode, CBizEnv& bizEnv);
	bool IsValid ();

private:
	DEFERREDTAXSTATUS InitDeferredTaxStatus ();
	DEFERREDTAXSTATUS GetDeferredTaxStatus ();
	bool SkipValidate ();
	bool IsValidDeferredTaxStatus ();
	bool IsValidBPLines();
	bool IsBPWithEqTax();
	bool IsValidDeferredTax();
	bool IsValidOnEqTax();

private:
	CBusinessObject*	m_bo;
	long m_bpLine;
	DEFERREDTAXSTATUS m_dts;
};

//for JE/JV
class CJdtODHelper
{
public: 
	CJdtODHelper(CBusinessObject& bo): m_bo(bo) {};

	//OD OnBoChange
	SBOErr ODRefDateChange ();
	SBOErr ODMemoChange ();

private:
	CBusinessObject&	m_bo;
};

#endif
