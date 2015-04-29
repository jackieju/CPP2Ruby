#include "stdafx.h"
#include "__Versions.h"	
#include "__DBMC_DataManager.h"

#include    "POJDT.h"
#include	"CPRF.h"
#include    "Perms.h"
#include    "PODoc.h"
#include    "ponnm.h"
#include    "PABGT.h"
#include    "PAHash.h"
#include    "PAARP.h"
#include    "PAAlerts.h"
#include    "POITM.h"
#include    "PARebl.h"
#include    "OBOT.h"
#include    "ODPS.h"
#include    "ORCT.h"
#include    "OBOE.h"
#include    "OPDN.h"
#include    "ORPD.h"
#include	"OTAX.h"
#include	"TAX1.h"
#include    "BSOPB.h"
#include    "CreateNewCompany.h"
#include	"B1ServicesDefines.h"
#include	"POCINF.h"
#include	"RCT2.h"
#include	"PAECVat.h"
#include	"PORFL.h"
#include	"PORIN.h"
#include	"PORPC.h"
#include	"POWOR.h"
#include	"POFPR.h"
#include	"POOCR.h"
#include	"POWTR.h"
// MultipleOpenPeriods
#include	"_PeriodCache.h"
#include	"PODoc11.h"
#include	"ReconUpgMgr.h"
#include	"OIPF.h"
#include	"OACP.h"
#include	"POFixedAssetsDocument.h"

#include    "JDT2.h"
#include	"ODAR.h"
#include	"JECompression.h"

#include	"DBQStatement.h"
#include	"DataArchiveMgr.h"

#include    "POMDR.h"//vf_costaccting
// VF_CashflowReport
#include	"POCFT.h"
#include	"POACT.h"
#include	"POERX.h"
//VF_TaxPayment
#include "patpw_utility.h"
// VF_FederalTaxIdOnJERow
#include	"CRD1.h"

#include "_AutoCleaner.h"

#include "POCIG.h"
#include "POCUP.h"
#include "SupplCodeManager.h"
#include "AppMsg_CORE_Defines.h"

#include "EarlierPostingDateValidator.h"
#include "AppMsg_BANK_Defines.h"

// VF_MultiBranch_EnabledInOADM
#include "POBPL.h"

#include "DBQUtils.h"

#include "TDAR.h"

//vf_costaccting
#define MDR_ASSIGN_STR_NUM 						80304
#define INVALID_OCR_FOR_POSTDATE_INDEX 			13
#define AMOUNT_CHANGED_INDEX 					15
#define ROW_DIMENSION_LOCATION					16

//@ABMerge ADD I035300 [ExciseInvoice]
#define OO_MATTYPE_CENVAT_UNPAIRED		223 
#define OO_MATTYPE_ROW_HEAD_UNMATCHED	225 

#include "_GLAccountManager.h"
//@ABMerge END I035300

//VF_FIReleaseProc
#include "POHEM.h"

#include "AppMsg_FIN_Defines.h"
#include "_MESSAGES_MANAGER.h"
#include "AppMsg_AP_AR_Defines.h"

#include "PORLD.h"

#include "AppUpgradeLogger.h"

#include "OGen/LinkMap/LinkMapCommon.h"

// VF_FederalTaxIdOnJERow
#define JE_TAX_ID_ON_HEADER_ALIAS		_T("OCRDLicTradNum")
#define JE_TAX_ID_ON_LINE_ALIAS			_T("CRD1LicTradNum")


/************************************************************************************/
/************************************************************************************/
CBusinessObject	*CTransactionJournalObject::CreateObject (const TCHAR *id, CBizEnv &env)
{	
        _TRACER("CreateObject");
	return new CTransactionJournalObject (id, env);
}

/************************************************************************************/
/************************************************************************************/
CTransactionJournalObject::CTransactionJournalObject (const TCHAR *id, CBizEnv &env) :
							CSystemBusinessObject (id, env), m_digitalSignature (env)
{
        _TRACER("CSystemBusinessObject");
	m_isVatJournalEntry = false;	// VF_ExciseInvoice
	m_taxAdaptor = NULL;
	m_stornoExtraInfoCreator = NULL;
	m_reconcileBPLines = true;
	m_pSequenceParameter = NULL;
	m_isInCancellingAcctRecon = false;
	m_isPostingPreviewMode = false;
	m_isPostingTemplate = false;
}
/************************************************************************************/
/************************************************************************************/
CTransactionJournalObject::~CTransactionJournalObject() 
{
        _TRACER("~CTransactionJournalObject");
	if (m_taxAdaptor)
	{
		delete(m_taxAdaptor);
	}
	if (m_pSequenceParameter)
	{
		delete m_pSequenceParameter;
		m_pSequenceParameter = NULL;
	}

	m_reconAcctSet.clear ();
}
/************************************************************************************/
/************************************************************************************/
SBOErr	CTransactionJournalObject::CompleteKeys ()
{
	SBOErr dbErr = ooNoErr;

	dbErr = CSystemBusinessObject::CompleteKeys();
	if (dbErr)
	{
		return dbErr;
	}
	
	PDAG dagJDT1 = GetDAG (JDT, ao_Arr1);

	if(dagJDT1->GetDBDMgrPtr()->isConnectionCaseSensitive() == true)
	{
		return ooNoErr; 
	}

	PDAG dagCRD = GetDAG (CRD);
	PDAG dagACT = GetDAG (ACT);
	long jeLinesCount = dagJDT1->GetRealSize (dbmDataBuffer);

	for (long rec = 0; rec < jeLinesCount; rec++)
	{
		SBOString shortName = dagJDT1->GetColStr(JDT1_SHORT_NAME, rec, -1);
		if (shortName.IsSpacesStr())
			continue;
		
		dbErr = GetEnv().GetByOneKey (dagCRD, OCRD_KEYNUM_PRIMARY, shortName);
		if (dbErr == ooNoErr)
		{
			dagJDT1->CopyColumn (dagCRD, JDT1_SHORT_NAME, rec, OCRD_CARD_CODE, 0);
		}
		else if (dbErr == dbmNoDataFound)
		{
			dbErr = GetEnv().GetByOneKey (dagACT, OACT_KEYNUM_PRIMARY, shortName);
			if (dbErr == noErr)
			{
				dagJDT1->CopyColumn (dagACT, JDT1_SHORT_NAME, rec, OACT_ACCOUNT_CODE, 0);
			}
			else 
			{
				SetErrorField (JDT1_SHORT_NAME);
				SetErrorLine (rec+1);
				SetArrNum (ao_Arr1);

				if (dbErr == dbmNoDataFound)
				{
					Message(OBJ_MGR_ERROR_MSG, GO_CRD_NAME_MISSING, shortName, OO_ERROR);
					return ooInvalidObject;
				}
				return dbErr;
			}
		}
		else
		{
			SetErrorField (JDT1_SHORT_NAME);
			SetErrorLine (rec+1);
			SetArrNum (ao_Arr1);
			return dbErr;
		}
	}

	return ooNoErr;
}
/************************************************************************************/
/************************************************************************************/
SBOErr CTransactionJournalObject::OnCreate()
{
        _TRACER("OnCreate");
	SBOErr	ooErr = noErr;
	PDAG	dagJDT, dagJDT1, dagCRD;
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

#ifdef QC_SHELL_ON
		qc = TRUE;
#else
		qc = FALSE;
#endif

	
		
	dagJDT = GetDAG();
	dagJDT1 = GetDAG(JDT, ao_Arr1);
    PDAG dagJDT2 = GetDAG(JDT, ao_Arr2);
    if(!dagJDT2->GetRealSize(dbmDataBuffer)) 
    {
        dagJDT2->SetSize(0, dbmDropData);
    }
    dagCRD = GetDAG (CRD);
	// If from observer and IsVatPerLine and the vat line is zero amount
	// we need to nullify debit/credit col for the Vat Report, until the
	// Vat Report start to use the new col JDT1_DEBIT_CREDIT. 
	if (GetDataSource () == *VAL_OBSERVER_SOURCE && bizEnv.IsVatPerLine ())
	{
		DAG_GetCount (dagJDT1, &numOfRecs);
		for (rec = 0; rec < numOfRecs; rec++)
		{
			dagJDT1->GetColStr (tmpStr, JDT1_VAT_LINE, rec);
			if (tmpStr[0] == VAL_YES[0])
			{
				dagJDT1->GetColMoney (&debAmount, JDT1_DEBIT, rec, DBM_NOT_ARRAY);
				dagJDT1->GetColMoney (&credAmount, JDT1_CREDIT, rec, DBM_NOT_ARRAY);
				if (debAmount.IsZero() && credAmount.IsZero())
				{
					dagJDT1->GetColStr (tmpStr, JDT1_DEBIT_CREDIT, rec);
					if (tmpStr[0] == VAL_DEBIT[0])
					{
						dagJDT1->NullifyCol (JDT1_CREDIT, rec);
					}
					else if (tmpStr[0] == VAL_CREDIT[0])
					{
						dagJDT1->NullifyCol (JDT1_DEBIT, rec);
					}
				}
			}
		}
	}

	SetDebitCreditField();

	contraCredKey[0] = '\0';
	contraDebKey[0] = '\0';
	
	transTotal.SetToZero();
	transTotalChk.SetToZero();
	fTransTotal.SetToZero();
	sTransTotal.SetToZero();

	_STR_strcpy (mainCurr, bizEnv.GetMainCurrency ());
	_STR_LRTrim (mainCurr);

	// Clear the recalc columns if recalcing to the main currency or if rate is zero //
	dagJDT->GetColMoney (&rateMoney, OJDT_TRANS_RATE, 0, DBM_NOT_ARRAY);
	dagJDT->GetColStr (tempStr, OJDT_ORIGN_CURRENCY, 0);
	_STR_LRTrim (tempStr);
	if (GNCoinCmp (tempStr, mainCurr)==0 || rateMoney.IsZero())
	{
		tempStr[0] = 0;
		//		dagJDT->SetColStr (tempStr, OJDT_ORIGN_CURRENCY, 0);
	}

	DAG_GetCount (dagJDT1, &numOfRecs);

	if (VF_RmvZeroLineFromJE (bizEnv) && !bizEnv.IsZeroLineAllowed ())
	{
	for (rec = 0; rec < numOfRecs; rec++)
	{
			dagJDT1->GetColMoney (&debAmount, JDT1_DEBIT, rec);
			dagJDT1->GetColMoney (&credAmount, JDT1_CREDIT, rec);
			dagJDT1->GetColMoney (&fDebAmount, JDT1_FC_DEBIT, rec);
			dagJDT1->GetColMoney (&fCredAmount, JDT1_FC_CREDIT, rec);
			dagJDT1->GetColMoney (&sDebAmount, JDT1_SYS_DEBIT, rec);
			dagJDT1->GetColMoney (&sCredAmount, JDT1_SYS_CREDIT, rec);
			
			MONEY	debBalanceDue, credBalanceDue, fDebBalanceDue, fCredBalanceDue, sDebBalanceDue, sCredBalanceDue;
			dagJDT1->GetColMoney (&debBalanceDue, JDT1_BALANCE_DUE_DEBIT, rec);
			dagJDT1->GetColMoney (&credBalanceDue, JDT1_BALANCE_DUE_CREDIT, rec);
			dagJDT1->GetColMoney (&fDebBalanceDue, JDT1_BALANCE_DUE_FC_DEB, rec);
			dagJDT1->GetColMoney (&fCredBalanceDue, JDT1_BALANCE_DUE_FC_CRED, rec);
			dagJDT1->GetColMoney (&sDebBalanceDue, JDT1_BALANCE_DUE_SC_DEB, rec);
			dagJDT1->GetColMoney (&sCredBalanceDue, JDT1_BALANCE_DUE_SC_CRED, rec);

			if (debAmount.IsZero() && credAmount.IsZero() &&
				fDebAmount.IsZero() && fCredAmount.IsZero() &&
				sDebAmount.IsZero() && sCredAmount.IsZero() &&
				debBalanceDue.IsZero() && credBalanceDue.IsZero() &&
				fDebBalanceDue.IsZero() && fCredBalanceDue.IsZero() &&
				sDebBalanceDue.IsZero() && sCredBalanceDue.IsZero())
			{
				dagJDT1->RemoveRecord (rec);
				rec--;
				numOfRecs--;
			}
		}
	}

	//Set Transaction type (Creating Object type)
	dagJDT->GetColLong(&transType, OJDT_TRANS_TYPE);

	if (transType == -1)
	{
		dagJDT->SetColLong(JDT, OJDT_TRANS_TYPE);

		transType = JDT;
	}

	SBOString deferredTax;
	dagJDT->GetColStr(deferredTax, OJDT_DEFERRED_TAX);
	deferredTax.Trim ();
	bool isDeferredTax = (deferredTax == VAL_YES);

	for (rec = 0; rec < numOfRecs; rec++)
	{
		dagJDT1->GetColStr (acctKey, JDT1_ACCT_NUM, rec);
		dagJDT1->GetColStr (cardKey, JDT1_SHORT_NAME, rec);

		itsCard = (_STR_stricmp (acctKey, cardKey) != 0) && (!_STR_IsSpacesStr (cardKey));
		if (itsCard )
		{
            CBPBalanceChangeLogData bpBalanceChangeLogData(bizEnv);
            bpBalanceChangeLogData.SetCode(cardKey);
            bpBalanceChangeLogData.SetControlAcct(acctKey);
            bpBalanceChangeLogData.SetDocType(JDT);

			ooErr = bizEnv.GetByOneKey (dagCRD, GO_PRIMARY_KEY_NUM, cardKey, true);
			if (ooErr != noErr)
			{
				if (ooErr == dbmNoDataFound)
				{
					Message (OBJ_MGR_ERROR_MSG, GO_CARD_NOT_FOUND_MSG, cardKey, OO_ERROR);
					return (ooErrNoMsg);
				}
			
				else
				{
					return ooErr;
				}
			}

            dagCRD->GetColMoney(&tempMoney, OCRD_CURRENT_BALANCE);
            bpBalanceChangeLogData.SetOldAcctBalanceLC(tempMoney);
            dagCRD->GetColMoney(&tempMoney, OCRD_F_BALANCE);
            bpBalanceChangeLogData.SetOldAcctBalanceFC(tempMoney);

            bpBalanceLogDataArray.Add(bpBalanceChangeLogData);
		}

		if (_STR_IsSpacesStr (acctKey))
		{
			dagJDT1->CopyColumn (GetDAG(CRD), JDT1_ACCT_NUM, rec, OCRD_DEB_PAY_ACCOUNT, 0);
			dagJDT1->GetColStr (acctKey, JDT1_ACCT_NUM, rec);
		}

		ooErr = bizEnv.GetByOneKey (GetDAG(ACT), GO_PRIMARY_KEY_NUM, acctKey, true);
		if (ooErr != noErr)
		{
			if (ooErr == dbmNoDataFound)
			{
				//Retrieve original parameters
				Message (OBJ_MGR_ERROR_MSG, GO_ACT_MISSING, acctKey, OO_ERROR);
				return (ooErrNoMsg);
			}
		
			else
			{
				return ooErr;
			}
		}

// Set Default Distribution rule
        SBOString	ocrCode;
        PDAG        dagAct;
	    long jdtOcrCols[] = {JDT1_OCR_CODE, JDT1_OCR_CODE2, JDT1_OCR_CODE3, 
                             JDT1_OCR_CODE4, JDT1_OCR_CODE5};
        long actOcrCols[] = {OACT_OVER_CODE, OACT_OVER_CODE2, OACT_OVER_CODE3,
                             OACT_OVER_CODE4, OACT_OVER_CODE5};
        long dimentionLen = VF_CostAcctingEnh(GetEnv()) ? DIMENSION_MAX : 1;
        dagAct = GetDAG(ACT);
		for (long dim = 0; dim < dimentionLen; dim ++)
        {
            if(dagJDT1->IsNullCol(jdtOcrCols[dim], rec))
            {
               dagAct->GetColStr(ocrCode, actOcrCols[dim], 0);
               if(!ocrCode.Trim().IsEmpty())
               {
                    dagJDT1->SetColStr(ocrCode, jdtOcrCols[dim], rec);
               }
            }   
        }
	 
		//
		// set valid from for profict code
		dagJDT1->GetColStr (ocrCode, JDT1_OCR_CODE, rec);
		
		SBOString	postDate, validFrom;
		dagJDT1->GetColStr (postDate, JDT1_REF_DATE, rec);
		ooErr = COverheadCostRateObject::GetValidFrom (bizEnv, ocrCode, postDate, validFrom);
		if (ooErr)
		{
			SetErrorField (JDT1_VALID_FROM);
			SetErrorLine (rec+1);
			return ooErr;
		}
		
		dagJDT1->SetColStr (validFrom, JDT1_VALID_FROM, rec);

		dagJDT1->GetColMoney (&debAmount, JDT1_DEBIT, rec, DBM_NOT_ARRAY);
		dagJDT1->GetColMoney (&credAmount, JDT1_CREDIT, rec, DBM_NOT_ARRAY);
		
		dagJDT1->GetColMoney (&fDebAmount, JDT1_FC_DEBIT, rec, DBM_NOT_ARRAY);
		dagJDT1->GetColMoney (&fCredAmount, JDT1_FC_CREDIT, rec, DBM_NOT_ARRAY);
		
		dagJDT1->GetColMoney (&sDebAmount, JDT1_SYS_DEBIT, rec, DBM_NOT_ARRAY);
		dagJDT1->GetColMoney (&sCredAmount, JDT1_SYS_CREDIT, rec, DBM_NOT_ARRAY);
		
		MONEY_Add (&transTotal, &debAmount);
		MONEY_Add (&transTotalChk, &credAmount);
		MONEY_Add (&fTransTotal, &fDebAmount);
		MONEY_Add (&sTransTotal, &sDebAmount);

		balanced = FALSE;

		if (VF_EnableCorrAct (bizEnv))
		{
			transTotalDebChk += debAmount;		
			transTotalCredChk += credAmount;
			fTransTotalDebChk += fDebAmount;;
			fTransTotalCredChk += fCredAmount;
			sTransTotalDebChk += sDebAmount;;
			sTransTotalCredChk += sCredAmount;

			if (transTotalDebChk == transTotalCredChk &&
				fTransTotalDebChk == fTransTotalCredChk &&
				sTransTotalDebChk == sTransTotalCredChk)
			{
				balanced = TRUE;
			}
		}
		else
		{
			if (!MONEY_Cmp (&transTotal, &transTotalChk))
			{
				balanced = TRUE;
			}
		}

		if (!IsExDtCommand (ooDoAsUpgrade) && transType != DAR)
		{
			//searching for first account in debit side and credit side,
			//to be the contra account
			if (_STR_strlen (contraDebKey) == 0)
			{
				if (debAmount.IsPositive()  ||
					fDebAmount.IsPositive() ||
					sDebAmount.IsPositive() ||
					credAmount.IsNegative() ||
					fCredAmount.IsNegative()||
					sCredAmount.IsNegative())
				{
					_STR_strcpy (contraDebKey, cardKey);
				}
			}

			if (_STR_strlen (contraCredKey) == 0)
			{
				if (credAmount.IsPositive() ||
					fCredAmount.IsPositive()||
					sCredAmount.IsPositive()||
					debAmount.IsNegative()  ||
					fDebAmount.IsNegative() ||
					sDebAmount.IsNegative())
				{
					_STR_strcpy (contraCredKey, cardKey);
				}
			}

			if (VF_EnableCorrAct (bizEnv))
			{
				// Same conditions as above, but because of necessarity to use VF_ flag and
				// different starting condition repeating here

				if (debAmount.IsPositive()  ||
					fDebAmount.IsPositive() ||
					sDebAmount.IsPositive() ||
					credAmount.IsNegative() ||
					fCredAmount.IsNegative()||
					sCredAmount.IsNegative())
				{
					contraDebLines++;
				}
				if (credAmount.IsPositive() ||
					fCredAmount.IsPositive()||
					sCredAmount.IsPositive()||
					debAmount.IsNegative()  ||
					fDebAmount.IsNegative() ||
					sDebAmount.IsNegative())
				{
					contraCredLines++;
				}
			}

			if (balanced && contraDebKey[0] && contraCredKey[0])
			{
				// For non VF_EnableCorrAct code, lastContraRec is always 0
				SetContraAccounts (dagJDT1, lastContraRec, rec+1, contraDebKey, contraCredKey, contraDebLines, contraCredLines);
				contraDebKey[0] = contraCredKey[0] = 0;

				if (VF_EnableCorrAct (bizEnv))
				{
					contraDebLines = contraCredLines = 0;
					lastContraRec = rec+1;
					transTotalDebChk = transTotalCredChk = fTransTotalDebChk = fTransTotalCredChk = sTransTotalDebChk = sTransTotalCredChk = 0L;
				}
			}
		}

		// Copy to balance due
		if (transType != DAR)
		{
			dagJDT1->GetColMoney(&creditBalDue, JDT1_CREDIT,rec);
			dagJDT1->GetColMoney(&debitBalDue, JDT1_DEBIT,rec);
			dagJDT1->GetColMoney(&fCreditBalDue, JDT1_FC_CREDIT,rec);
			dagJDT1->GetColMoney(&fDebitBalDue, JDT1_FC_DEBIT,rec);
			dagJDT1->GetColMoney(&sCreditBalDue, JDT1_SYS_CREDIT,rec);
			dagJDT1->GetColMoney(&sDebitBalDue, JDT1_SYS_DEBIT,rec);


			// VF_MultiBranch_EnabledInOADM
			bool zeroBalanceDue = false;
			if (IsZeroBalanceDueForCentralizedPayment () &&
				dagJDT1->GetColStrAndTrim (JDT1_ACCT_NUM, rec, coreSystemDefault) !=
				dagJDT1->GetColStrAndTrim (JDT1_SHORT_NAME, rec, coreSystemDefault))
			{
				zeroBalanceDue = true;
			}

			if ((!creditBalDue.IsZero() || !debitBalDue.IsZero() ||
				!fCreditBalDue.IsZero() || !fDebitBalDue.IsZero() ||
				!sCreditBalDue.IsZero() || !sDebitBalDue.IsZero())
				&& !zeroBalanceDue)
			{	
				dagJDT1->CopyColumn (dagJDT1, JDT1_BALANCE_DUE_DEBIT, rec, JDT1_DEBIT, rec);
				dagJDT1->CopyColumn (dagJDT1, JDT1_BALANCE_DUE_CREDIT, rec, JDT1_CREDIT, rec);
				dagJDT1->CopyColumn (dagJDT1, JDT1_BALANCE_DUE_SC_DEB, rec, JDT1_SYS_DEBIT, rec);
				dagJDT1->CopyColumn (dagJDT1, JDT1_BALANCE_DUE_SC_CRED, rec, JDT1_SYS_CREDIT, rec);
				dagJDT1->CopyColumn (dagJDT1, JDT1_BALANCE_DUE_FC_DEB, rec, JDT1_FC_DEBIT, rec);	
				dagJDT1->CopyColumn (dagJDT1, JDT1_BALANCE_DUE_FC_CRED, rec, JDT1_FC_CREDIT, rec);
			}
		}	

		SBOString vatLine;
		dagJDT1->GetColStr (vatLine, JDT1_VAT_LINE, rec);
		vatLine.Trim ();
		bool isVatLine = (vatLine == VAL_YES);
		if (isVatLine && isDeferredTax)
		{
			dagJDT1->SetColLong (IAT_DeferTaxInterim_Type, JDT1_INTERIM_ACCT_TYPE, rec);
		}
	} // end of for (rec)

	//budget flag
	if ( IsExCommand( ooDontUpdateBudget))
	{
		SetExCommand ( ooDontUpdateBudget, fa_Clear );
	}
	//budget flag
	
	if (MONEY_Cmp (&transTotal, &transTotalChk) != 0)
	{
		dagJDT->GetColLong (&transAbs, OJDT_JDT_NUM, 0);
		
		_STR_sprintf (tempStr, LONG_FORMAT, transAbs);
		Message (ERROR_MESSAGES_STR,OO_TRANSACTION_NOT_BALANCED, tempStr, OO_ERROR);
		return ((SBOErr)NULL);
	}

	//Set transaction total (one side)
	dagJDT->SetColMoney (&transTotal, OJDT_LOC_TOTAL, 0, DBM_NOT_ARRAY);
	dagJDT->SetColMoney (&fTransTotal, OJDT_FC_TOTAL, 0, DBM_NOT_ARRAY);
	dagJDT->SetColMoney (&sTransTotal, OJDT_SYS_TOTAL, 0, DBM_NOT_ARRAY);

	//Set contra account of each line in transaction
	if (!IsExDtCommand (ooDoAsUpgrade) && transType != DAR)
	{
		if (contraDebKey[0] && contraCredKey[0])
		{
			//Set to JDT1 contra accounts

			// For non VF_EnableCorrAct code, lastContraRec is always 0
			SetContraAccounts (dagJDT1, lastContraRec, numOfRecs, contraDebKey, contraCredKey, contraDebLines, contraCredLines);
		}

		if (VF_EnableCorrAct(bizEnv) && balanced == FALSE)
		{
			// NOTE: This is warning only
			SetErrorField(JDT1_CONTRA_ACT);
			SetErrorLine(1);	
			Message(OBJ_MGR_ERROR_MSG, GO_CONTRA_ACNT_MISSING, NULL, OO_WARNING);
		}
	}

	//@ABMerge ADD I035300 [ExciseInvoice]
	if(VF_ExciseInvoice(bizEnv))
	{
		SBOString genRegNumFlag;
		dagJDT->GetColStr(genRegNumFlag, OJDT_GEN_REG_NO, 0);
		genRegNumFlag.Trim ();
		if(genRegNumFlag == VAL_YES)
		{
			long matType;
			long regNo;
			long location;
			dagJDT->GetColLong(&matType, OJDT_MAT_TYPE, 0);
			dagJDT->GetColLong (&location, OJDT_LOCATION, 0);
			if(matType == 1 || matType == 3)
			{
				regNo = bizEnv.GetNextRegNum (location, RG23APart2, TRUE);
				dagJDT->SetColLong(regNo, OJDT_RG23A_PART2, 0);
				dagJDT->NullifyCol(OJDT_RG23C_PART2, 0);
			}
			else if(matType == 2)
			{
				regNo = bizEnv.GetNextRegNum (location, RG23CPart2, TRUE);
				dagJDT->SetColLong(regNo, OJDT_RG23C_PART2, 0);
				dagJDT->NullifyCol (OJDT_RG23A_PART2, 0);
			}
		}
		else if(genRegNumFlag[0] == VAL_NO[0])
		{
			dagJDT->NullifyCol(OJDT_MAT_TYPE, 0);
			dagJDT->NullifyCol(OJDT_RG23A_PART2, 0);
			dagJDT->NullifyCol(OJDT_RG23C_PART2, 0);
		}
	}
	//@ABMerge END I035300
	
//Do not update related PDAG, set zero pointer into the 'arrTable' entry
	bool isNeedToFree = SetDAG ( NULL, false, JDT, ao_Arr1 );
    bool isNeedToFree2 = SetDAG(NULL, false, JDT, ao_Arr2);
	if (VF_RmvZeroLineFromJE (GetEnv()) && !(GetEnv()).IsZeroLineAllowed ())
	{
		if (dagJDT1->GetRecordCount () == 0)
		{
			dagJDT->Clear ();
			return ooErr; 
		}

		if (dagJDT1->GetRecordCount () == 1)
		{
			dagJDT1->GetColMoney (&debAmount, JDT1_DEBIT, 0);
			dagJDT1->GetColMoney (&credAmount, JDT1_CREDIT, 0);
			dagJDT1->GetColMoney (&fDebAmount, JDT1_FC_DEBIT, 0);
			dagJDT1->GetColMoney (&fCredAmount, JDT1_FC_CREDIT, 0);
			dagJDT1->GetColMoney (&sDebAmount, JDT1_SYS_DEBIT, 0);
			dagJDT1->GetColMoney (&sCredAmount, JDT1_SYS_CREDIT, 0);
			
			MONEY	debBalanceDue, credBalanceDue, fDebBalanceDue, fCredBalanceDue, sDebBalanceDue, sCredBalanceDue;
			dagJDT1->GetColMoney (&debBalanceDue, JDT1_BALANCE_DUE_DEBIT, 0);
			dagJDT1->GetColMoney (&credBalanceDue, JDT1_BALANCE_DUE_CREDIT, 0);
			dagJDT1->GetColMoney (&fDebBalanceDue, JDT1_BALANCE_DUE_FC_DEB, 0);
			dagJDT1->GetColMoney (&fCredBalanceDue, JDT1_BALANCE_DUE_FC_CRED, 0);
			dagJDT1->GetColMoney (&sDebBalanceDue, JDT1_BALANCE_DUE_SC_DEB, 0);
			dagJDT1->GetColMoney (&sCredBalanceDue, JDT1_BALANCE_DUE_SC_CRED, 0);

			if (debAmount.IsZero() && credAmount.IsZero() &&
				fDebAmount.IsZero() && fCredAmount.IsZero() &&
				sDebAmount.IsZero() && sCredAmount.IsZero() &&
				debBalanceDue.IsZero() && credBalanceDue.IsZero() &&
				fDebBalanceDue.IsZero() && fCredBalanceDue.IsZero() &&
				sDebBalanceDue.IsZero() && sCredBalanceDue.IsZero())
			{
				dagJDT->Clear ();
				return ooErr;
			}
		}
	}

	// If Year Transfer Data_Source, then keep it that way.
	SBOString dataSource;
	dagJDT->GetColStr (dataSource, OJDT_DATA_SOURCE);
	dataSource.Trim ();
	if (dataSource.Compare (VAL_YEAR_TRANSFER_SOURCE) == 0)
	{
		SetDataSource (*VAL_YEAR_TRANSFER_SOURCE);
	}
	//Sequence
	if (VF_MultipleRegistrationNumber (GetEnv ()))
	{			
		CSequenceManager* seqManager = bizEnv.GetSequenceManager ();
		ooErr = seqManager->HandleSerial (*this);
		IF_ERROR_RETURN (ooErr);
	}

	//Supplementary Code OnCreate
	if(VF_SupplCode(GetEnv ()))
	{
		CSupplCodeManager* pManager = bizEnv.GetSupplCodeManager();
		Date PostDate;
		dagJDT->GetColStr(PostDate, OJDT_REF_DATE);
		ooErr = pManager->CodeChange(*this, PostDate);
		IF_ERROR_RETURN (ooErr);
		ooErr = pManager->CheckCode(*this);
		if(ooErr)
		{
			CMessagesManager::GetHandle()->Message(_54_APP_MSG_CORE_SUPPL_CODE_CODE_EXIST, EMPTY_STR, this);
			return ooErrNoMsg;
		}
	}
	else if(bizEnv.IsCurrentLocalSettings(CHINA_SETTINGS))	
	{
		if(!dagJDT->IsNullCol(OJDT_SUPPL_CODE, 0L))
		{
			dagJDT->NullifyCol(OJDT_SUPPL_CODE, 0L);
		}
	}


	if (VF_MultiBranch_EnabledInOADM (bizEnv))
	{
		// set selected branch to JDT object for the later validation (Incident 30293)
		if (!CBusinessPlaceObject::IsValidBPLId (GetBPLId ()) && dagJDT1->GetRealSize (dbmDataBuffer) > 0)
		{
			long bplId;
			dagJDT1->GetColLong (&bplId, JDT1_BPL_ID, 0);
			SetBPLId (bplId);
		}
	}
	//Write a header record
	
	ooErr = GORecordHistProc (*this, dagJDT);

	//Restore relative PDAG
	SetDAG ( dagJDT1, isNeedToFree, JDT, ao_Arr1 );
	SetDAG ( dagJDT2, isNeedToFree2, JDT, ao_Arr2 );

	if (ooErr != ooNoErr)
	{
		return (ooErr);
	}
// Record Cash Flow Assignment Transaction before updating 'arrTable' entry.
	if(VF_CashflowReport(bizEnv))
	{
		long	transType;
		dagJDT->GetColLong(&transType, OJDT_TRANS_TYPE);
		if (transType != RCT && transType != VPM)
		{
		SBOString	objCFTId(CFT);
		PDAG dagCFT = GetDAGNoOpen(objCFTId);
		if (dagCFT)
		{
				dagJDT->GetColLong (&transAbs, OJDT_JDT_NUM, 0);

			CCashFlowTransactionObject	*bo = static_cast<CCashFlowTransactionObject*>(CreateBusinessObject(CFT));

			bo->SetDataSource(GetDataSource());

			ooErr = bo->OCFTCreateByJDT (GetDAG(CFT), transAbs, dagJDT1);
			bo->Destroy ();
			if (ooErr != ooNoErr)
			{
				return (ooErr);
			}
		}
	}
	}


	ooErr = PutSignature (dagJDT1);
	if (ooErr)
	{
		return (ooErr);
	}

	if (VF_ExciseInvoice(bizEnv) && this->m_isVatJournalEntry)
	{
		long	wtrKey, vatJournalKey;
		dagJDT->GetColLong(&wtrKey, OJDT_CREATED_BY);
		dagJDT->GetColLong(&vatJournalKey, OJDT_JDT_NUM);
		if (wtrKey <= 0 || vatJournalKey <= 0)
		{
			return ooErrNoMsg;
		}

		dagJDT->SetColLong (0, OJDT_STORNO_TO_TRANS);

		ooErr = CWarehouseTransferObject::LinkVatJournalEntry2WTR (bizEnv, wtrKey, vatJournalKey);
		if (ooErr)
		{
			return ooErr;
		}
	}

	dagJDT->GetColLong (&createdBy, OJDT_CREATED_BY, 0);
	
	//Insert header's absolute entry into the lines
	dagJDT->GetColLong (&transAbs, OJDT_JDT_NUM, 0);

	for (rec=0; rec<numOfRecs; rec++)
	{
		dagJDT1->SetColLong (rec, JDT1_LINE_ID, rec);

		dagJDT1->SetColLong (transAbs, JDT1_TRANS_ABS, rec);
		dagJDT1->SetColLong (transType, JDT1_TRANS_TYPE, rec);

		dagJDT->GetColStr (tempStr, OJDT_BASE_REF, 0);
		dagJDT1->SetColStr (tempStr, JDT1_BASE_REF, rec);
		
		dagJDT->GetColStr (tempStr, OJDT_TRANS_CODE, 0);
		dagJDT1->SetColStr (tempStr, JDT1_TRANS_CODE, rec);

		dagJDT1->SetColLong (createdBy, JDT1_CREATED_BY, rec);
	}

    if(VF_JEWHT(bizEnv) && _DBM_DataAccessGate::IsValid(dagJDT2))
    {
        long numOfJDT2 = dagJDT2->GetRecordCount();
		
        for(long rec2 = 0; rec2 < numOfJDT2; rec2++)
        {
            dagJDT2->SetColLong(transAbs, INV5_ABS_ENTRY, rec2);
            dagJDT2->SetColLong(rec2, INV5_LINE_NUM, rec2);
        }
        UpdateWTInfo();   
    }

	if ((GetDataSource () == *VAL_OBSERVER_SOURCE) && (GetID().strtol() == JDT) &&  _DBM_DataAccessGate::IsValid(dagJDT2))
	{
		BusinessFlow	bizFlow = GetCurrentBusinessFlow();
		SBOString		wt;
		Boolean			useNegativeAmount;

		dagJDT->GetColStr(wt, OJDT_AUTO_WT);
		useNegativeAmount = bizEnv.GetUseNegativeAmount();

		if (bizFlow == bf_Cancel && wt == VAL_YES )
		{

			if (VF_JEWHT(bizEnv) && useNegativeAmount)
			{
				CMessagesManager::GetHandle()->Message (_1_APP_MSG_FIN_JDT_NOT_REVERSE_NEG_WT, EMPTY_STR, this);
				return ooInvalidObject;
			}
			long numOfJDT2 = dagJDT2->GetRecordCount();
			for(long idx = 0; idx < numOfJDT2; idx++)
			{
				dagJDT2->SetRecordFetchStatus(idx, false); 
			}
		}
	}


	Boolean fetched = dagJDT1->GetRecordFetchStatus (0);
	if (true == fetched)
	{
		dagJDT1->SetBackupSize (numOfRecs, dbmDropData);
		for (ii=0; ii < numOfRecs; ii++) 
		{
			dagJDT1->MarkRecAsNew (ii);		
		}
	}

	ooErr = CSystemBusinessObject::OnUpdate();
	if (ooErr)
	{
		return ooErr;
	}

	if(VF_TaxPayment(bizEnv))
	{
		for(rec = 0; rec < dagJDT1->GetRecordCount(); rec++)
		{
			ooErr = updateCenvatByJdt1Line(*this, dagJDT1, rec);
			if (ooErr && ooErr != dbmNoDataFound)
			{
				return ooErr;
			}
		}
	}

//Update Cards and accounts Tzovarim With Stored Proc -	 _T("TmSp_SetBalanceByJdt")
	_STR_strcpy (Sp_Name, _T("TmSp_SetBalanceByJdt"));
	dagJDT->GetColStr (tempStr, OJDT_JDT_NUM, 0);
	_STR_LRTrim (tempStr);
	Upd[0].colNum = dbmInteger;
	_STR_strcpy (Upd[0].updateVal, tempStr);
	DBD_SetDAGUpd (dagJDT, Upd, 1);
	
	RetVal=0;
	ooErr =  DBD_SpExec (dagJDT, Sp_Name, &RetVal);
	SBOString tmpstr(tempStr);
    LogBPAccountBalance(bpBalanceLogDataArray, tmpstr);
	bizEnv.InvalidateCache (bizEnv.ObjectToTable (CRD));
	bizEnv.InvalidateCache (bizEnv.ObjectToTable (ACT));
	
	if (RetVal)
	{
		return RetVal;
	}

	if (ooErr)
	{
		return ooErr;
	}

	long	canceledTrans;
	dagJDT->GetColLong (&canceledTrans, OJDT_STORNO_TO_TRANS, 0);
	if (canceledTrans > 0)
	{
		bool ordered = false;
		ooErr = CTransactionJournalObject::IsPaymentOrdered(bizEnv, canceledTrans, ordered);
		IF_ERROR_RETURN (ooErr);

		if (ordered)
		{
			bizEnv.SetErrorTable (dagJDT1->GetTableName ());
			return dbmDataWasChanged;
		}
	}

	/* When we cancel IRU journals we want to make reconciliation by ourselves and 
	   we don't want CTransactionJournalObject do it automatically */
	if ((canceledTrans > 0) && (m_reconcileBPLines))
	{
		ooErr = ReconcileCertainLines();
		if (ooErr)
		{
			return ooErr;
		}
		
		// auto-reconcile deferred tax account lines when cancel BP reconciliation
		if (!m_isInCancellingAcctRecon)
		{
			ooErr = ReconcileDeferredTaxAcctLines();
			IF_ERROR_RETURN (ooErr);
		}
	}

	//Save Tax information
	ooErr = CreateTax();
	if (ooErr)
	{
		return ooErr;
	}

	//	Update Cards deduction percentage in Deduct Terraces Company _T("TmSp_SetVendorDeductPercent")
	//	Error is not cheaked becouse it's not crutial, and there's no reason to rollback if it failes
	//	Start ====>
	if (VF_EnableDeductAtSrc (GetEnv ()))
	{
		long transID;
		dagJDT->GetColLong (&transID, OJDT_JDT_NUM, 0);
		ooErr = nsDeductHierarchy::UpdateDeductionPercent (bizEnv, transID);
		IF_ERROR_RETURN (ooErr);
		}
	//	<===== End

	if (transType == JDT)
	{
		ooErr = m_digitalSignature.CreateSignature (this);
		IF_ERROR_RETURN (ooErr);
	}

	ooErr = ValidateBPLNumberingSeries ();
	IF_ERROR_RETURN (ooErr);

	ooErr = IsBalancedByBPL ();
	IF_ERROR_RETURN (ooErr);

	//****************************************************************************
	if (bizEnv.IsComputeBudget () == FALSE || bizEnv.IsDuringUpgradeProcess () || transType == DAR)
	{
		return ooErr;
	}

	//Update Budget Acomulators And Look for An Alert with Sp  - _T("TmSp_SetBgtAccumulators_ByJdt")
	_STR_strcpy (Sp_Name	, _T("TmSp_SetBgtAccumulators_ByJdt"));

	res[0].colNum = JDT1_ACCT_NUM;
	res[1].colNum = JDT1_FC_CURRENCY;
	res[2].colNum =	JDT1_FC_CURRENCY;
	res[3].colNum = JDT1_DEBIT;
	res[4].colNum = JDT1_DEBIT;
 
	DBD_SetDAGRes (dagJDT1, res, 5);

	dagJDT->GetColStr (tempStr, OJDT_JDT_NUM, 0);
	_STR_LRTrim (tempStr);
	Upd[0].colNum = dbmInteger;
	_STR_strcpy (Upd[0].updateVal, tempStr);

	Upd[1].colNum = dbmAlphaNumeric;
	_STR_strcpy (Upd[1].updateVal, _T("Y"));

	Upd[2].colNum = dbmAlphaNumeric;
	_STR_strcpy (Upd[2].updateVal, bizEnv.GetCompanyPeriodCategory ());

	DBD_SetDAGUpd (dagJDT1 , Upd, 3);

	ooErr = DBD_SpToDAG (dagJDT1, &dagRES, Sp_Name);
	if (ooErr == dbmNoDataFound)
	{
		return ooNoErr;
	}
	if (ooErr)
	{
		return ooErr;
	}
		
 	blockLevel	= RetBlockLevel(bizEnv);
	typeBlockLevel = RettypeBlockLevel(bizEnv, GetID().strtol ());


	if (blockLevel>=JDT_WARNING_BLOCK && typeBlockLevel == JDT_TYPE_ACCOUNTING_BLOCK && 
		(OOIsSaleObject (transType) || OOIsPurchaseObject (transType)))
	{
		//dont given alert
		blockLevel = JDT_NOT_BGT_BLOCK;
	}

	if (blockLevel>=JDT_WARNING_BLOCK && typeBlockLevel != JDT_TYPE_ACCOUNTING_BLOCK && 
			transType == 30)
	{
		//dont give alert
		blockLevel = JDT_NOT_BGT_BLOCK;
	}

	_STR_strcpy (monSymbol, bizEnv.GetMainCurrency ());

	//Loop threw the records and see witch accounts has faild US !!!
	DAG_GetCount (dagRES, &recCount);
	for (ii = 0 ; ii < recCount ; ii++)
	{
		dagRES->GetColStr (acctCode, 0,ii);

		dagRES->GetColStr (tmpStr, 1,ii);
		DoAlert = tmpStr[0];
	
		dagRES->GetColStr (tmpStr, 2,ii);
		AlrType = tmpStr[0];
	
		dagRES->GetColMoney (&BgtMonthOver, 3, ii, DBM_NOT_ARRAY);
		dagRES->GetColMoney (&BgtYearOver, 4, ii, DBM_NOT_ARRAY);

		if (DoAlert == *VAL_YES)
		{
			transTotal.SetToZero();
			for (rec=0; rec<numOfRecs; rec++)
			{
				dagJDT1->GetColStr (acctKey, JDT1_ACCT_NUM, rec);
				if (_STR_stricmp (acctKey, acctCode) == 0)
				{
					dagJDT1->GetColMoney (&debAmount, JDT1_DEBIT, rec, DBM_NOT_ARRAY);
					dagJDT1->GetColMoney (&credAmount, JDT1_CREDIT, rec, DBM_NOT_ARRAY);
					MONEY_Add (&transTotal, &debAmount);
					MONEY_Sub (&transTotal, &credAmount);
				}
			}
			if (bizEnv.GetBudgetWarningFrequency() == VAL_MONTHLY[0])
			{
				if ((BgtMonthOver.IsPositive() && transTotal.IsPositive()) ||
					(BgtMonthOver.IsNegative() && transTotal.IsNegative()))
				{
					bgtDebitSize	= TRUE;
				}
				else
				{
					bgtDebitSize	= FALSE;
				}
			}
			else
			{
				if ((BgtYearOver.IsPositive() && transTotal.IsPositive()) ||
					(BgtYearOver.IsNegative() && transTotal.IsNegative()))
				{
					bgtDebitSize	= TRUE;
				}
				else
				{
					bgtDebitSize	= FALSE;
				}
			}
		}
		else
		{
		   bgtDebitSize	= FALSE;
		}

		 	//set the blocking of budget
		if (blockLevel > JDT_NOT_BGT_BLOCK  && bgtDebitSize)
		{
			budgetAllYes = IsExCommand( ooDontUpdateBudget) ;

			//the temp flag  used for ImportExportTrans
			fromImport = IsExCommand( ooImportData);

			//MONEY_Multiply (&BgtMonthOver, -1, &BgtMonthOver);

			MONEY_ToText (&BgtMonthOver, moneyMonthStr, RC_SUM, monSymbol, bizEnv);   
			
			MONEY_ToText (&BgtYearOver, moneyYearStr, RC_SUM, monSymbol, bizEnv);   	

			if (bizEnv.GetBudgetWarningFrequency() == VAL_MONTHLY[0])
			{
				GetBudgBlockErrorMessage(moneyMonthStr, moneyYearStr, acctCode, MONTH_ALERT_MESSAGE, msgStr1);
			}
			else
			{
				GetBudgBlockErrorMessage(moneyMonthStr, moneyYearStr, acctCode, YEAR_ALERT_MESSAGE, msgStr1);
			}
		
			switch (blockLevel)
			{
				case JDT_BGT_BLOCK:
					if (typeBlockLevel == JDT_TYPE_ACCOUNTING_BLOCK)
					{
						if (bizEnv.GetBudgetWarningFrequency() == VAL_MONTHLY[0])
						{
						GetBudgBlockErrorMessage (moneyMonthStr, moneyYearStr, acctCode, BLOCK_ONE_MESSAGE, msgStr1);
						_STR_strcat (msgStr1, _T(" , "));
						_STR_strcat (msgStr1,EMPTY_STR );
						Message (-1, -1, msgStr1, OO_ERROR);
						}
						else
						{
								CMessagesManager::GetHandle()->Message(
														_1_APP_MSG_FIN_BGT0_CHECK_YEAR_TOTAL_STR, 
														EMPTY_STR, 
														this,
														acctCode, 
														moneyYearStr);
						}
						
						return ooInvalidObject;
					}
				break;

				case JDT_WARNING_BLOCK:
				////the Message not to bee bring for ImportExportTrans
				if (fromImport|| GetDataSource () == *VAL_OBSERVER_SOURCE)
					{
						_STR_strcat (msgStr1, _T(" , "));
						_STR_strcat (msgStr1,EMPTY_STR );
						Message (-1, -1, msgStr1, OO_ERROR);
					}

					if (budgetAllYes == FALSE)
					{
#ifndef	MNHL_SERVER_MODE
						TCHAR	ContinueStr[50];

						_STR_GetStringResource (ContinueStr, BGT0_FORM_NUM, BGT0_CONTINUE_STR);
						retBtn = FORM_GEN_Message (msgStr1, ContinueStr, CANCEL_STR(*OOGetEnv(NULL)), YES_TO_ALL_STR(*OOGetEnv(NULL)), 2);
#else
						retBtn = 2;
#endif
						switch (retBtn)
						{
							case 1://formOKReturn
							case 3://formOKReturn
								budgetAllYes = (retBtn == 3 ? TRUE:FALSE);
								if (budgetAllYes)
								{
									SetExCommand ( ooDontUpdateBudget, fa_Set );
								}

								if (GetEnv ().GetPermission (PRM_ID_BUDGET_BLOCK) != OO_PRM_FULL)
								{
									DisplayError (fuNoPermission);
									return ooErrNoMsg;//fuNoPermission;
								}
								//return ooNoErr;
							break;

							case 2:
								return ooErrNoMsg;
							break;

						}
					}
				break;
			}//switch of levelBlock
		}//End Of For Looping
	}//blocking	

	if (transType == JDT && bizEnv.IsComputeBudget ())
	{
		Boolean					alertSent;
		CSystemAlertParams		systemAlertsParams;

		systemAlertsParams.m_fromUser = bizEnv.GetUserSignature ();
		systemAlertsParams.m_object = JDT;
		systemAlertsParams.m_params = this;
		systemAlertsParams.m_primaryKey.Format(_T("%d"), transAbs);
		systemAlertsParams.m_secondaryKey = systemAlertsParams.m_primaryKey;

		systemAlertsParams.m_alertID = ALR_BUDGET_ALERT;
		systemAlertsParams.m_flags = 0;
		ALRSendSystemAlert (&systemAlertsParams, &alertSent);
	}

	return ooErr;	
}
/*************************************************************/

long CTransactionJournalObject::RettypeBlockLevel(CBizEnv &bizEnv, long id)
{
        _TRACER("RettypeBlockLevel");
	switch (id)
	{
		case POR:
			if(bizEnv.IsApplyBudget (bl_Orders))
			{
				return JDT_TYPE_DOCS_BLOCK;
			}
		break;

		case PDN:
			if (bizEnv.IsApplyBudget (bl_Deliveries))
			{
				return JDT_TYPE_DOCS_BLOCK;
			}
		break;
		case PRQ:
			if (bizEnv.IsApplyBudget (bl_PurchaseRequest))
			{
				return JDT_TYPE_DOCS_BLOCK;
			}
		break;

		default:
			if (bizEnv.IsApplyBudget (bl_Accounting))
			{
				return JDT_TYPE_ACCOUNTING_BLOCK;
			}
		break;
	}
	return 	JDT_NOT_TYPE_DOCS_BLOCK;
}

//****************************************************************************

long CTransactionJournalObject::RetBlockLevel(CBizEnv& bizEnv)
{
        _TRACER("RetBlockLevel");
	if (bizEnv.GetBudgetBlockLevel () == VAL_BLOCK[0])
	{
		return JDT_BGT_BLOCK;
	}
	else if(bizEnv.GetBudgetBlockLevel () == VAL_NO[0])
	{
		return JDT_NOT_BGT_BLOCK;
	}
	else if (bizEnv.GetBudgetBlockLevel () == VAL_WARNING[0])
	{
		return JDT_WARNING_BLOCK;
	}
	return JDT_NOT_BGT_BLOCK;
}


/*************************************************************/
//	OnInitData:	Set journal data defaults.
/*************************************************************/
SBOErr	CTransactionJournalObject::OnInitData()
{
        _TRACER("OnInitData");
	SBOErr	ooErr;	
	TCHAR	dateString[10];
	PDAG	dagJDT = GetDAG ();
	
	ooErr = CSystemBusinessObject::OnInitData ();
	if (ooErr)
	{
		return ooErr;
	}

	DBM_DATE_Get (dateString,this->GetEnv());
	GetDAG()->SetColStr (dateString, OJDT_REF_DATE, 0);

	// VF_Model340_EnabledInOADM
	ooErr = InitDataReport340 (dagJDT);
	if (ooErr)
	{
		return ooErr;
	}

	return (ooErr);

} /* end of OJDClearObj () */




/************************************************************************************/
//S
/************************************************************************************/
SBOErr	CTransactionJournalObject::IsCurValid (TCHAR *crnCode, PDAG dagCRN) 
{
        _TRACER("IsCurValid");
	Boolean	exist;
	SBOErr	ooErr;
	CBizEnv	&bizEnv = GetEnv ();
	
	ooErr = GNCheckCurrencyCode (bizEnv, crnCode, &exist);
	_STR_LRTrim (crnCode);
	if (ooErr)
		return ooErr;
	if (!exist)
	{
		return dbmNoDataFound;
	}

	return noErr;
}


/************************************************************************************
/// IsPaymentBlockValid - Payment Block Validation Check.
************************************************************************************/
SBOErr  CTransactionJournalObject::IsPaymentBlockValid (PDAG dagJDT1, long rec)
{
    _TRACER("IsPaymentBlockValid");

    SBOString acctCode, shortName, objType;
    TCHAR   strPaymentBlocked[JDT1_PAYMENT_BLOCK_LEN+1] = {0}, strBlockReason[JDT1_PAYMENT_BLOCK_REF_LEN+1] = {0};
    bool    isAcctLine = false, isBlockReasonDfltValue = false;

    dagJDT1->GetColStr (acctCode, JDT1_ACCT_NUM, rec);
    dagJDT1->GetColStr (shortName, JDT1_SHORT_NAME, rec);
    acctCode.Trim ();
    shortName.Trim ();
    isAcctLine = (acctCode == shortName);

    dagJDT1->GetColStr (strPaymentBlocked, JDT1_PAYMENT_BLOCK, rec);
    dagJDT1->GetColStr (strBlockReason, JDT1_PAYMENT_BLOCK_REF, rec);
    _STR_LRTrim (strPaymentBlocked);
    _STR_LRTrim (strBlockReason);
    isBlockReasonDfltValue = (((SBOString)NONE_CHOICE == strBlockReason) 
                                || _STR_IsSpacesStr (strBlockReason)
                                || dagJDT1->IsNullCol (JDT1_PAYMENT_BLOCK_REF, rec));

    // 1. It is NOT a manual JE, but try to customize the payment block fields.
    dagJDT1->GetColStr (objType, JDT1_TRANS_TYPE, rec);
    objType.Trim ();
    SBOString strAllTransactionType("-1");
    if ((JDT != objType.strtol ())    // Manual JE.
        && (strAllTransactionType != objType))  // All Transactions.
    {
        if ((VAL_YES[0] == strPaymentBlocked[0]) || !isBlockReasonDfltValue)
        {
            SetErrorLine (rec+1);
            SetErrorField (JDT1_PAYMENT_BLOCK);
            SetArrNum (ao_Arr1);
            Message (JTE_JDT_FORM_NUM, JTE_PAYBLOCK_ALLOWED_IN_MANUAL_JE_STR, NULL, OO_ERROR);
            return ooInvalidObject;
        }
    }

    // 2. It is an account line, but try to customize the payment block fields.
    if (isAcctLine)
    {
        if ((VAL_YES[0] == strPaymentBlocked[0]) || !isBlockReasonDfltValue)
        {
            SetErrorLine (rec+1);
            SetErrorField (JDT1_PAYMENT_BLOCK);
            SetArrNum (ao_Arr1);
            Message (JTE_JDT_FORM_NUM, JTE_PAYBLOCK_ALLOWED_IN_BP_ACCOUNT_STR, NULL, OO_ERROR);
            return ooInvalidObject;
        }
    }

    // 3. PayBlock field is 'N' or un-touched, but PayBlckRef has values.
    if ((VAL_NO[0] == strPaymentBlocked[0]) || dagJDT1->IsNullCol (JDT1_PAYMENT_BLOCK, rec))
    {
        if (!isBlockReasonDfltValue)
        {
            SetErrorLine (rec+1);
            SetErrorField (JDT1_PAYMENT_BLOCK_REF);
            SetArrNum (ao_Arr1);
            Message (JTE_JDT_FORM_NUM, JTE_BLOCK_REASON_ALLOWED_ERROR_STR, NULL, OO_ERROR);
            return ooInvalidObject;
        }
    }

    // 4. Value of PayBlckRef field is NOT in the valid values.
    if (!isBlockReasonDfltValue)
    {
        SBOErr ooErr = ValidateRelations (ao_Arr1, rec, JDT1_PAYMENT_BLOCK_REF, PYB);
        if (ooErr)
        {
            return ooErr;
        }
    }

    return noErr;
}


/************************************************************************************
	GetYearAndMonthEntry	- Returns the accumulator enty to update in OACT or OCRD or OPRC

		PDAG dagJDT		- The OJDT/JDT1 PDAG.
		TCHAR isArray	- is TRUE case JDT1 (lines) PDAG, is FALSE if PDAG is OJDT
		long rec		- Record num of OJDT/JDT1.
************************************************************************************/
void CTransactionJournalObject::GetYearAndMonthEntry (PDAG dagJDT, Boolean byRef, long rec, long *month, long *year) 
{
        _TRACER("GetYearAndMonthEntry");
	TCHAR date[JDT1_DUE_DATE_LEN+1];
	
	if (byRef)
	{
		dagJDT->GetColStr (date, JDT1_REF_DATE, rec);
	}
	else
	{
		dagJDT->GetColStr (date, JDT1_DUE_DATE, rec);
	}
	
	GetYearAndMonthEntryByDate (date, month, year);
	
	return;
}

/*************************************************************************************************************/
//
/*************************************************************************************************************/
void CTransactionJournalObject::GetYearAndMonthEntryByDate (TCHAR *dateStr, long *month, long *year)
{
        _TRACER("GetYearAndMonthEntryByDate");
	TCHAR date[JDT1_DUE_DATE_LEN+1];

	if (!dateStr || !month || !year)
	{
		return;
	}

	*month = *year = 0L;

	_STR_strcpy (date, dateStr);

	date[6] = 0;
	*month = _STR_atol(date+4);

	date[4] = 0;
	*year = _STR_atol(date);

	return;
}


/*************************************************************************************************************/

/*--*@*---*@*---*@*---*@*---*@*---*@*---*@*---*@*---*@*---*@*---*@*---*@*---*@*--*/
/*
	OJDRecordJDT	-	Call this function to record a JDT. It takes care of all links.
						For example, see PARCR2.c and POCHO.c.
						
			paramStructPtr->objectType		-	Must be JDT
			paramStructPtr->dagTable[JDT]	-	The JDT PDAG to write			
			
			paramStructPtr->dagTable[NNM]	-	All these related object DAGs must
			paramStructPtr->dagTable[ACT]		also be opened
			paramStructPtr->dagTable[NTL]
			paramStructPtr->dagTable[CRD]
			etc.
*/
/*--*@*---*@*---*@*---*@*---*@*---*@*---*@*---*@*---*@*---*@*---*@*---*@*---*@*--*/
SBOErr CTransactionJournalObject::RecordJDT (CBizEnv &env, PDAG dagJDT, PDAG dagJDT1, bool reconcileBPLines)
{
        _TRACER("RecordJDT");
	SBOErr	ooErr;
	CTransactionJournalObject *obj	= (CTransactionJournalObject *)env.CreateBusinessObject (SBOString (JDT));

	PDAG dagLocalJDT = obj->GetDAG(JDT,ao_Main);
	PDAG dagLocalJDT1= obj->GetDAG(JDT,ao_Arr1);

	dagLocalJDT->Copy (dagJDT, dbmDataBuffer);
	dagLocalJDT1->Copy (dagJDT1, dbmDataBuffer);

	obj->m_reconcileBPLines = reconcileBPLines;

	ooErr=obj->OnCreate();
	//insert transaction number into the dag 
	dagJDT->CopyColumn (dagLocalJDT, OJDT_JDT_NUM, 0, OJDT_JDT_NUM, 0);
	obj->Destroy();
	return ooErr;
}

/*--*@*---*@*---*@*---*@*---*@*---*@*---*@*---*@*---*@*---*@*---*@*---*@*---*@*--*/
/*
	OJDIsValidObj	- Check that the JDT PDAG is OK to write to disk:
					  1> Transaction is balanced
					  2> Accounts and cards exist
					  3> Dates are in company defined range
					  4> If in foreign currency, all FC codes must be the same and
					     must correspond with the account currency for every line
					  5> Account must be postable
					  6> Must be a valid FC code
					  7> Can't have a transaction with no sums at all
*/
/*--*@*---*@*---*@*---*@*---*@*---*@*---*@*---*@*---*@*---*@*---*@*---*@*---*@*--*/
SBOErr CTransactionJournalObject::OnIsValid()
{
        _TRACER("OnIsValid");
	SBOErr				ooErr;
	PDAG				dagACT, dagCRD, dagJDT1, dagJDT2, dag=GetDAG(), dagNNM3, dagCRD3;
	
	long				dateNum, rec, numOfRecs, transNum, canceledTrans, transType;
	long				buttons[3], tmpNum, series;

	MONEY				creditSumTotal, debitSumTotal;
	MONEY				fCreditSumTotal, fDebitSumTotal;
	MONEY				sCreditSumTotal, sDebitSumTotal;
	MONEY				creditSum, debitSum, fCreditSum, fDebitSum, sCreditSum, sDebitSum;
	MONEY				creditBalDue, debitBalDue, fCreditBalDue, fDebitBalDue, sCreditBalDue, sDebitBalDue;
	MONEY				tmpM;

	Date				dateStr, reverseDate;

	Currency			transCurr, actCurr, lineCurr;
	Currency			tmpCurr, Curr, mainCurr;

	Boolean				fromBatch = FALSE, msgHandled = FALSE, fromImport = FALSE, fromEoy = FALSE;
	Boolean				multyFcDetected;
	
	TCHAR				code[OACT_FORMAT_CODE_LEN+1];
	TCHAR				autoStorno[OJDT_AUTO_STORNO_LEN+1];
	TCHAR				AutoVat[OJDT_AUTO_VAT_LEN+1];
	TCHAR				nonZero, tmpStr[256], allowFcNotBalanced, allowFcMulty;
	TCHAR				actNum[JDT1_ACCT_NUM_LEN+1], shortName[JDT1_SHORT_NAME_LEN+1];
	TCHAR				cardType[OCRD_CARD_TYPE_LEN +1];
	TCHAR				msgStr[256]={0};
	TCHAR				formatStr[128]={0};
	CBizEnv				&bizEnv = GetEnv ();
	DBD_CondStruct		cond[2];

#ifndef	MNHL_SERVER_MODE
	long				retVal;
#endif

	dagJDT1 = GetDAG (JDT, ao_Arr1);
	dagJDT2 = GetDAG (JDT, ao_Arr2);

	DAG_GetCount (dagJDT1, &numOfRecs);
	nonZero = allowFcNotBalanced = allowFcMulty = multyFcDetected = FALSE;
	_STR_GetStringResource (formatStr, HASH_FORM_NUM, HASH_TRANS_NUM_STR, &GetEnv());

	if (IsExCommand(ooExInternalAutoMode) &&
		GetExDtCommand() == ooDoNotCheckDates)
	{
		fromEoy = TRUE;
	}

	dag->GetColLong (&transNum, OJDT_JDT_NUM, 0);
	if (transNum < 0)
	{
		transNum = 0;
	}

	dag->GetColLong (&series, OJDT_SERIES, 0);
	if (series)
	{
		DBD_CondStruct	condStruct[3];

		dagNNM3 = GetDAG(NNM, ao_Arr3);
		condStruct[0].colNum = NNM3_OBJ_CODE;
		condStruct[0].condVal =  JDT;
		condStruct[0].operation = DBD_EQ;
		condStruct[0].relationship = DBD_AND;

		condStruct[1].colNum = NNM3_DOC_SUB_TYPE;
		condStruct[1].condVal =  SUB_TYPE_NONE;
		condStruct[1].operation = DBD_EQ;
		condStruct[1].relationship = DBD_AND;

		condStruct[2].colNum = NNM3_SERIES;
		condStruct[2].condVal =  series;
		condStruct[2].operation = DBD_EQ;

		DBD_SetDAGCond (dagNNM3, condStruct, 3);

		if (DBD_Count (dagNNM3, TRUE) == 0)
		{
			Message (JTE_JDT_FORM_NUM, JTE_SERIES_NOT_DEFINE_STR, NULL, OO_ERROR);
			return ooInvalidObject;
		}

		bool isSeriesForCncl = false;
		ooErr = CNextNumbersObject::IsSeriesForCancellation(bizEnv, series, 
			isSeriesForCncl);
		IF_ERROR_RETURN(ooErr);

		if (isSeriesForCncl)
		{
			CMessagesManager::GetHandle()->Message(
				_147_APP_MSG_AP_AR_CANNOT_USE_CANCELLATION_SERIES, EMPTY_STR, this);
			return ooInvalidObject;
		}
	}

	dag->GetColLong (&canceledTrans, OJDT_STORNO_TO_TRANS, 0);
	if (canceledTrans > 0)
	{
		DBD_CondStruct	condStruct[2] ;

		// checking if cancelling a reversed transaction
		condStruct[0].colNum = OJDT_JDT_NUM;
		condStruct[0].condVal = canceledTrans;
		condStruct[0].operation = DBD_EQ;
		condStruct[0].relationship = DBD_AND;

		condStruct[1].colNum = OJDT_STORNO_TO_TRANS;
		_STR_strcpy (condStruct[1].condVal, STR_0);
		condStruct[1].operation = DBD_GT;

		DBD_SetDAGCond (dag, condStruct, 2);

		if (DBD_Count (dag, TRUE) > 0)
		{
			Message (GO_OBJ_ERROR_MSGS(JDT),JDT_STORNO_ERROR, NULL, OO_ERROR);
			return ooInvalidObject;
		}

		if (GetCurrentBusinessFlow () == bf_Create)
		{
			// checking if tran was reversed by another user/from another window
			condStruct[0].colNum = OJDT_STORNO_TO_TRANS;
			condStruct[0].condVal = canceledTrans;
			condStruct[0].operation = DBD_EQ;
			condStruct[0].relationship = 0;

			DBD_SetDAGCond (dag, condStruct, 1);

			if (DBD_Count (dag, TRUE) > 0)
			{
					CMessagesManager::GetHandle()->Message(
															_1_APP_MSG_FIN_JDT_CANCELED_ERROR4, 
															EMPTY_STR, 
															this,
															canceledTrans);
				return ooInvalidObject;
			}

			// checking if trans set to Auto Storno by another user/from another window
			condStruct[0].colNum = OJDT_JDT_NUM;
			condStruct[0].condVal = canceledTrans;
			condStruct[0].operation = DBD_EQ;
			condStruct[0].relationship = DBD_AND;
			
			condStruct[1].colNum = OJDT_AUTO_STORNO;
			_STR_strcpy (condStruct[1].condVal, VAL_YES);
			condStruct[1].operation = DBD_EQ;

			DBD_SetDAGCond (dag, condStruct, 2);

			if (DBD_Count (dag, TRUE) > 0)
			{
				Message (JTE_JDT_FORM_NUM, JTE_CANT_CANCEL_ERROR_STR, NULL, OO_ERROR);
				return ooErrNoMsg;
			}
		}
	}

	// MultipleOpenPeriods
	ooErr = IsValidUserPermissions ();
	IF_ERROR_RETURN (ooErr);

	ooErr = ValidateRelations (ao_Main, 0, OJDT_TRANS_CODE, TRC);
	if (ooErr)
	{
		return ooErr;
	}
	ooErr = ValidateRelations ( ao_Main, 0, OJDT_PROJECT, PRJ);
	if (ooErr)
	{
		return ooErr;
	}
	ooErr = ValidateRelations ( ao_Main, 0, OJDT_INDICATOR, IDC);
	if (ooErr)
	{
		return ooErr;
	}
	ooErr = ValidateRelations ( ao_Main, 0, OJDT_DOC_TYPE, JET);
	if (ooErr)
	{
		return ooErr;
	}
	
	//Supplementary Code OnIsValid, PreCheck whether SupplCode is valid
	if(VF_SupplCode(GetEnv ()) && GetCurrentBusinessFlow () == bf_None && 
		(IsExCommand(ooExCloseBatch) || IsExCommand(ooExAddBatchClose)))
	{
		PDAG dagJDT = GetDAG (JDT, ao_Main);
		SBOString strBatchNum;
		dagJDT->GetColStr(strBatchNum, OJDT_BATCH_NUM);

		if(!strBatchNum.IsNull() && !strBatchNum.IsEmpty())
		{
			CSupplCodeManager* pManager = bizEnv.GetSupplCodeManager();
			Date PostDate;
			dagJDT->GetColStr(PostDate, OJDT_REF_DATE);
			ooErr = pManager->LoadDfltCodeToDag(*this, PostDate);
			IF_ERROR_RETURN (ooErr);
			ooErr = pManager->CheckCode(*this);
			if(ooErr)
			{
				CMessagesManager::GetHandle()->Message(_54_APP_MSG_CORE_SUPPL_CODE_CODE_EXIST, EMPTY_STR, this);
				return ooErrNoMsg;
			}
		}
	}
	
	ooErr = ValidateReportEU();
	if (ooErr)
	{
		return ooErr;
	}
	
	ooErr = ValidateReport347();
	if (ooErr)
	{
		return ooErr;
	}

	// VF_Model340_EnabledInOADM
	ooErr = ValidateReport340 ();
	if (ooErr)
	{
		return ooErr;
	}

    if(VF_JEWHT(bizEnv))
    {
        SBOString tmpStr;
        dag->GetColStr(tmpStr, OJDT_AUTO_WT);
        tmpStr.Trim();
        if(tmpStr == VAL_YES)
        {
            dag->GetColStr(tmpStr, OJDT_AUTO_VAT);
            tmpStr.Trim();
            if(tmpStr != VAL_YES)
            {
                Message (JTE_JDT2_FORM_NUM, JTE_WT_CANNOT_SET_YES, NULL, OO_ERROR);
                return ooInvalidObject;
            }
        }
        if(CheckWTValid())
        {
            Message(JTE_JDT2_FORM_NUM, JTE_WT_BP_SIDE_ERR, NULL, OO_ERROR);
            return ooInvalidObject;   
        } 
        if(CheckMultiBP())  
        {
            SetErrorField(JDT1_SHORT_NAME);
            SetArrNum(ao_Arr1);
            Message(JTE_JDT2_FORM_NUM, JTE_MULTI_BP_WARNING_STR2, NULL, OO_ERROR);
            return ooInvalidObject;
        }

		//if there is a BP, we validate JDT2
		// validate BP's allowed WHT code, WHT amount and so on.
		if((tmpStr == VAL_YES) && (dagJDT2->GetRealSize (dbmDataBuffer) > 0))
		{
			ooErr = m_WithholdingTaxMng.ODOCValidateDOC5 (*this, dag, dagJDT2, NULL);						
			if (ooErr)
			{
				return ooErr;
			}
		}
    }

	if(VF_MultipleRegistrationNumber(bizEnv))
	{
		ooErr = ValidateHeaderLocation();
		if(ooErr)
		{
			return ooErr;
		}
	}
	dag->GetColStr (autoStorno, OJDT_AUTO_STORNO, 0);
	

	if (autoStorno[0] == VAL_YES[0])
	{
		dag->GetColStr (reverseDate, OJDT_STORNO_DATE, 0);
		dag->GetColStr (dateStr, OJDT_REF_DATE, 0);
		if (_STR_atol (reverseDate) <= _STR_atol (dateStr))
		{
			Message (GO_OBJ_ERROR_MSGS(JDT),JDT_REVERSE_DATE_ERROR, NULL, OO_ERROR);
			return ooInvalidObject;
		}
		
        bool useNegativeAmount = bizEnv.GetUseNegativeAmount ();
        SBOString autoWt;
        dag->GetColStr (autoWt, OJDT_AUTO_WT, 0);
        if (useNegativeAmount && autoWt== VAL_YES && VF_JEWHT(bizEnv))
        {
            CMessagesManager::GetHandle()->Message (_1_APP_MSG_FIN_JDT_NOT_REVERSE_NEG_WT, EMPTY_STR, this);
            return ooInvalidObject;
        }

		// 1. For journal entries - these check are relevant only when updating because before it was
		//    created is not possible that it was cancelled / reversed another trans
		// 2. These checks are not relevant in journal voucher (ooExAddBatchNoClose flag is set)
		//	  since journal vouchers cannot be cancelled
		if (GetCurrentBusinessFlow () == bf_Update && !IsExCommand(ooExAddBatchNoClose))
		{	
			DBD_CondStruct	condStruct[2] ;
			
			dag->GetColLong (&canceledTrans, OJDT_JDT_NUM, 0);
			
			// checking if cancelling a reversed transaction
			condStruct[0].colNum = OJDT_JDT_NUM;
			condStruct[0].condVal = canceledTrans;
			condStruct[0].operation = DBD_EQ;
			condStruct[0].relationship = DBD_AND;
			
			condStruct[1].colNum = OJDT_STORNO_TO_TRANS;
			_STR_strcpy (condStruct[1].condVal, STR_0);
			condStruct[1].operation = DBD_GT;
			
			DBD_SetDAGCond (dag, condStruct, 2);
			
			if (DBD_Count (dag, TRUE) > 0)
			{
				Message (GO_OBJ_ERROR_MSGS(JDT),JDT_STORNO_ERROR, NULL, OO_ERROR);
				return ooInvalidObject;
			}
			
			// checking if tran was reversed by another user/from another window
			condStruct[0].colNum = OJDT_STORNO_TO_TRANS;
			condStruct[0].condVal = canceledTrans;
			condStruct[0].operation = DBD_EQ;
			condStruct[0].relationship = 0;
			
			DBD_SetDAGCond (dag, condStruct, 1);
			
			if (DBD_Count (dag, TRUE) > 0)
			{
					CMessagesManager::GetHandle()->Message(
															_1_APP_MSG_FIN_JDT_CANCELED_ERROR3, 
															EMPTY_STR, 
															this,
															canceledTrans);
				return ooInvalidObject;
			}
		}
	}

	//Check that the reference date is in the defined range
	dag->GetColStr (dateStr, OJDT_REF_DATE, 0);
	DBM_DATE_ToLong (&dateNum, dateStr);

	// ************************** MultipleOpenPeriods *************************
	CPeriodCache* periodManager = bizEnv.GetPeriodCache();

	if (_STR_IsSpacesStr (dateStr))
		DBM_DATE_Get (dateStr, bizEnv);

	long periodID = periodManager->GetPeriodId (bizEnv, dateStr.GetString());
	if (coreNoCurrPeriodErr == bizEnv.CheckCompanyPeriodByDate (dateStr.GetString()))
	// ************************************************************************
	{
		SetErrorField( OJDT_REF_DATE);
		return (ooInvalidObject);
	}	

	dag->GetColLong (&transType, OJDT_TRANS_TYPE, 0);
	if (bizEnv.IsBlockRefDateEdit () 
		&& ((transType > OPEN_BLNC_TYPE) || (MANUAL_BANK_TRANS_TYPE == transType)))
	{
		for (rec=0; rec<numOfRecs; rec++)
		{
			dagJDT1->GetColStr (dateStr, JDT1_REF_DATE, rec);
			DBM_DATE_ToLong (&tmpNum, dateStr);
			if (dateNum != tmpNum)
			{
				Message (GO_OBJ_ERROR_MSGS(JDT), JDT_BLOCK_REFDATE_ERROR, NULL, OO_ERROR);
				return ooInvalidObject;
			}
		}
	}

	dag->GetColStr (dateStr, OJDT_TAX_DATE, 0);
	DBM_DATE_ToLong (&dateNum, dateStr);
	if (dateNum <= 0)
	{
		dag->CopyColumn (dag, OJDT_TAX_DATE, 0, OJDT_REF_DATE, 0);
		dag->GetColStr (dateStr, OJDT_TAX_DATE, 0);
	}

	// ************************** MultipleOpenPeriods *************************
	if (!fromEoy && !periodManager->CheckDate (periodID, dateStr.GetString(), wdTaxDate))
	// ************************************************************************
	{
		SetErrorField(OJDT_TAX_DATE);
		Message (OBJ_MGR_ERROR_MSG, GO_DATE_OUT_OF_LIMIT, NULL, OO_ERROR);
		return (ooInvalidObject);
	}	

	dag->GetColStr (dateStr, OJDT_DUE_DATE, 0);
	DBM_DATE_ToLong (&dateNum, dateStr);
	if (dateNum <= 0)
	{
		dag->CopyColumn (dag, OJDT_DUE_DATE, 0, OJDT_REF_DATE, 0);
		dag->GetColStr (dateStr, OJDT_DUE_DATE, 0);
	}

	// ************************** MultipleOpenPeriods *************************
	if (!fromEoy && !periodManager->CheckDate (periodID, dateStr.GetString(), wdDueDate))
	// ************************************************************************
	{
		SetErrorField(OJDT_DUE_DATE);
		Message (OBJ_MGR_ERROR_MSG, GO_DATE_OUT_OF_LIMIT, NULL, OO_ERROR);
		return (ooInvalidObject);
	}	

	if (VF_HideAutoVAT(bizEnv))
	{
		if (GetDataSource () == *VAL_OBSERVER_SOURCE)
		{
			PDAG dag = GetDAG ();
			SBOString isAutoVat;

			dag->GetColStr (isAutoVat, OJDT_AUTO_VAT, 0);
			if(isAutoVat == VAL_YES)
			{
				SetErrorField (OJDT_AUTO_VAT);
				return ooInvalidObject;
			}
		}
	}

	if (VF_GBInterface (bizEnv) && bizEnv.IsGBInterfaceSupport())
	{
		SBOString	docType;

		dag->GetColStr (docType, OJDT_DOC_TYPE, 0);
		docType.Trim ();
		if	(docType.IsEmpty ())
		{
			//_STR_GetStringResource (docType, GB_INTERFACE_WIZARD_FORM_NUM, GW_ACCOUNTING_VOUCHER_DOC_TYPE, coreChineseCN, &GetEnv());
			//dag->SetColStr (docType, OJDT_DOC_TYPE, 0);
			docType =  bizEnv.GetDefaultJEType();
			dag->SetColStr (docType, OJDT_DOC_TYPE, 0);
		}
	}

	if (IsExCommand(ooExAddBatchNoClose))
	{
		fromBatch = TRUE;
	}

	if (IsExCommand(ooImportData))//the temp flag  used for ImportExportTrans
	{
		fromImport = TRUE;
	}

	// check update of block dunning letter field
	if (GetCurrentBusinessFlow () == bf_Create)
	{
		SBOString blockDunningLetter;
		dag->GetColStr (blockDunningLetter, OJDT_BLOCK_DUNNING_LETTER);
		if (blockDunningLetter == VAL_YES && !IsBlockDunningLetterUpdateable ())
		{
			SetErrorField (OJDT_BLOCK_DUNNING_LETTER);
			return dbmColumnNotUpdatable;
		}
	}


	dagACT = GetDAG(ACT);
	dagCRD = GetDAG(CRD);
	dagCRD3 = GetDAG(CRD, ao_Arr3);

	transCurr[0] = 0;
	dag->GetColStr (AutoVat, OJDT_AUTO_VAT, 0);

	_STR_strcpy (mainCurr, bizEnv.GetMainCurrency ());
	for (rec=0; rec<numOfRecs; rec++)
	{
		dagJDT1->GetColLong (&transNum, JDT1_TRANS_ABS, rec);
		if (transNum < 0)
		{
			transNum = 0;
		}

		if (bizEnv.IsVatPerLine () || bizEnv.IsVatPerCard ())
		{
			dagJDT1->GetColStr (tmpStr, bizEnv.IsVatPerLine () ? JDT1_VAT_GROUP : JDT1_TAX_CODE, rec);
			if (_STR_IsSpacesStr (tmpStr))
			{
				dagJDT1->GetColMoney (&tmpM, JDT1_BASE_SUM, rec, DBM_NOT_ARRAY);
				if (!tmpM.IsZero())
				{
					SetErrorLine(rec + 1);
					SetErrorField(JDT1_BASE_SUM);
					SetArrNum(ao_Arr1);
					Message (GO_OBJ_ERROR_MSGS(JDT), JDT_BASE_SUM_WITHOUT_VAT, NULL, OO_ERROR);
					return (ooInvalidObject);
				}
			}
			else if (bizEnv.IsVatPerCard ())
			{
				if (AutoVat[0] == VAL_NO[0])
				{
					SetErrorLine(rec + 1);
					SetErrorField(JDT1_TAX_CODE);
					SetArrNum(ao_Arr1);
					Message (JTE_JDT_FORM_NUM, JTE_EDIT_VAT_ERROR_STR, NULL, OO_ERROR);
					return (ooInvalidObject);
				}
				if (VF_InactiveTaxSTC (bizEnv))
				{
					ooErr = nsDocument::CheckTaxCodeInactive (bizEnv, tmpStr);
					if (ooErr)
					{
						SetArrNum (ao_Arr1);
						SetErrorField (JDT1_TAX_CODE);
						SetErrorLine (rec + 1);
						return ooErr;
					}
				}
			}
			else if (bizEnv.IsVatPerLine ())
			{
				if (VF_InactiveTaxVTG (bizEnv))
				{
					ooErr = nsDocument::CheckVatGroupInactive (bizEnv, tmpStr);
					if (ooErr)
					{
						SetArrNum (ao_Arr1);
						SetErrorField (JDT1_VAT_GROUP);
						SetErrorLine (rec + 1);
						return ooErr;
					}
				}
			}
		}

		if ((bizEnv.IsVatPerLine () || bizEnv.IsVatPerCard ()) && GetDataSource () == *VAL_OBSERVER_SOURCE && 
			GetCurrentBusinessFlow () == bf_Create && AutoVat[0] == VAL_NO[0])
		{
			dagJDT1->GetColMoney (&tmpM, JDT1_VAT_AMOUNT, rec, DBM_NOT_ARRAY);
			if (!tmpM.IsZero())
			{
				SetErrorLine(rec + 1);
				SetErrorField(JDT1_VAT_AMOUNT);
				SetArrNum(ao_Arr1);
				Message (JTE_JDT_FORM_NUM, JTE_EDIT_VAT_ERROR_STR, NULL, OO_ERROR);
				return (ooInvalidObject);
			}
			dagJDT1->GetColMoney (&tmpM, JDT1_SYS_VAT_AMOUNT, rec, DBM_NOT_ARRAY);
			if (!tmpM.IsZero())
			{
				SetErrorLine(rec + 1);
				SetErrorField(JDT1_SYS_VAT_AMOUNT);
				SetArrNum(ao_Arr1);
				Message (JTE_JDT_FORM_NUM, JTE_EDIT_VAT_ERROR_STR, NULL, OO_ERROR);
				return (ooInvalidObject);
			}
			dagJDT1->GetColMoney (&tmpM, JDT1_GROSS_VALUE, rec, DBM_NOT_ARRAY);
			if (!tmpM.IsZero())
			{
				SetErrorLine(rec + 1);
				SetErrorField(JDT1_GROSS_VALUE);
				SetArrNum(ao_Arr1);
				Message (JTE_JDT_FORM_NUM, JTE_EDIT_VAT_ERROR_STR, NULL, OO_ERROR);
				return (ooInvalidObject);
			}
			dagJDT1->GetColMoney (&tmpM, JDT1_GROSS_VALUE_FC, rec, DBM_NOT_ARRAY);
			if (!tmpM.IsZero())
			{
				SetErrorLine(rec + 1);
				SetErrorField(JDT1_GROSS_VALUE_FC);
				SetArrNum(ao_Arr1);
				Message (JTE_JDT_FORM_NUM, JTE_EDIT_VAT_ERROR_STR, NULL, OO_ERROR);
				return (ooInvalidObject);
			}
			dagJDT1->GetColStr (tmpStr, JDT1_TAX_POSTING_ACCOUNT, rec);
			if (tmpStr[0] != VAL_NO[0])
			{
				SetErrorLine(rec + 1);
				SetErrorField(JDT1_TAX_POSTING_ACCOUNT);
				SetArrNum(ao_Arr1);
				Message (JTE_JDT_FORM_NUM, JTE_EDIT_VAT_ERROR_STR, NULL, OO_ERROR);
				return (ooInvalidObject);
			}
		}

		ooErr = ValidateRelations (ao_Arr1, rec, JDT1_PROJECT, PRJ);
		if (ooErr)
		{
			return ooErr;
		}
		
		if(VF_MultipleRegistrationNumber(bizEnv))
		{
			ooErr = ValidateRowLocation(rec);
			if(ooErr)
			{
				return ooErr;
			}
		}

        // Payment Block Validation Check - only for DI.
        if (GetDataSource () == *VAL_OBSERVER_SOURCE)
        {
            ooErr = IsPaymentBlockValid (dagJDT1, rec);
            if (ooErr)
            {
                return ooErr;
            }
        }

		if (GetCurrentBusinessFlow () == bf_Create)
		{
			if (bizEnv.IsVatPerLine ())
			{
				// tax group does need to have tax account defined in JE (amount differences posting)
				if (!(VF_AmountDifferences (m_env) && (GetExCommand2() & ooEx2IgnoreVatAccount)))
				{
					ooErr = ValidateRelations (ao_Arr1, rec, JDT1_VAT_GROUP, VTG);
				}
			}
			else
			{
				ooErr = ValidateRelations (ao_Arr1, rec, JDT1_TAX_CODE, STC);
			}
			if (ooErr)
			{
				return ooErr;
			}
		}

		dagJDT1->GetColStr (dateStr, JDT1_DUE_DATE, rec);
		if (!fromEoy)
		{
			// ************************** MultipleOpenPeriods *************************
			if (!periodManager->CheckDate (periodID, dateStr.GetString(), wdDueDate))
			// ************************************************************************
			{
				SetErrorLine( rec + 1);
				SetErrorField( JDT1_DUE_DATE);
				SetArrNum(ao_Arr1);
				Message (OBJ_MGR_ERROR_MSG, GO_DATE_OUT_OF_LIMIT, NULL, OO_ERROR);
				return (ooInvalidObject);
			}	
			
			dagJDT1->GetColStr (dateStr, JDT1_REF_DATE, rec);
			// ************************** MultipleOpenPeriods *************************
			if (!periodManager->CheckDate (periodID, dateStr.GetString(), wdRefDate))
			// ************************************************************************
			{
				SetErrorLine (rec + 1);
				SetErrorField (JDT1_REF_DATE);
				SetArrNum (ao_Arr1);
				Message (OBJ_MGR_ERROR_MSG, GO_DATE_OUT_OF_LIMIT, NULL, OO_ERROR);
				return ooInvalidObject;
			}	

			dagJDT1->GetColStr (dateStr, JDT1_TAX_DATE, rec);
			DBM_DATE_ToLong (&dateNum, dateStr);
			if (dateNum <= 0)
			{
				dagJDT1->CopyColumn (dagJDT1, JDT1_TAX_DATE, rec, JDT1_REF_DATE, rec);
				dagJDT1->GetColStr (dateStr, JDT1_TAX_DATE, rec);				
			}

			// ************************** MultipleOpenPeriods *************************
			if (!periodManager->CheckDate (periodID, dateStr.GetString(), wdTaxDate))
			// ************************************************************************
			{
				SetErrorLine (rec+1);
				SetErrorField (JDT1_TAX_DATE);
				SetArrNum (ao_Arr1);
				Message (OBJ_MGR_ERROR_MSG, GO_DATE_OUT_OF_LIMIT, NULL, OO_ERROR);
				return ooInvalidObject;
			}	
		}
		
		dagJDT1->GetColMoney (&creditSum, JDT1_CREDIT, rec, DBM_NOT_ARRAY);
		dagJDT1->GetColMoney (&debitSum, JDT1_DEBIT, rec, DBM_NOT_ARRAY);
		dagJDT1->GetColMoney (&fCreditSum, JDT1_FC_CREDIT, rec, DBM_NOT_ARRAY);
		dagJDT1->GetColMoney (&fDebitSum, JDT1_FC_DEBIT, rec, DBM_NOT_ARRAY);
		dagJDT1->GetColMoney (&sCreditSum, JDT1_SYS_CREDIT, rec, DBM_NOT_ARRAY);
		dagJDT1->GetColMoney (&sDebitSum, JDT1_SYS_DEBIT, rec, DBM_NOT_ARRAY);
		dagJDT1->GetColMoney (&creditBalDue, JDT1_BALANCE_DUE_CREDIT, rec, DBM_NOT_ARRAY);
		dagJDT1->GetColMoney (&debitBalDue, JDT1_BALANCE_DUE_DEBIT, rec, DBM_NOT_ARRAY);
		dagJDT1->GetColMoney (&fCreditBalDue, JDT1_BALANCE_DUE_FC_CRED, rec, DBM_NOT_ARRAY);
		dagJDT1->GetColMoney (&fDebitBalDue, JDT1_BALANCE_DUE_FC_DEB, rec, DBM_NOT_ARRAY);
		dagJDT1->GetColMoney (&sCreditBalDue, JDT1_BALANCE_DUE_SC_CRED, rec, DBM_NOT_ARRAY);
		dagJDT1->GetColMoney (&sDebitBalDue, JDT1_BALANCE_DUE_SC_DEB, rec, DBM_NOT_ARRAY);

		if (!creditSum.IsZero() && !debitSum.IsZero())
		{
			SetErrorLine (rec + 1);
			SetErrorField (JDT1_DEBIT);
			SetArrNum (ao_Arr1);
			Message (GO_OBJ_ERROR_MSGS (JDT), JDT_BOTH_SIDE_ERROR, NULL, OO_ERROR);
			return ooInvalidObject;
		}
		if (!sCreditSum.IsZero() && !sDebitSum.IsZero())
		{
			SetErrorLine (rec + 1);
			SetErrorField (JDT1_SYS_CREDIT);
			SetArrNum (ao_Arr1);
			Message (GO_OBJ_ERROR_MSGS (JDT), JDT_BOTH_SIDE_ERROR, NULL, OO_ERROR);
			return ooInvalidObject;
		}

		if (!creditSum.IsZero() || !debitSum.IsZero() ||
			!fCreditSum.IsZero() || !fDebitSum.IsZero() ||
			!sCreditSum.IsZero() || !sDebitSum.IsZero() || 
			!creditBalDue.IsZero() || !debitBalDue.IsZero() ||
			!fCreditBalDue.IsZero() || !fDebitBalDue.IsZero() ||
			!sCreditBalDue.IsZero() || !sDebitBalDue.IsZero())
		{
			nonZero = TRUE;
		}
		
		MONEY_Add (&creditSumTotal, &creditSum);
		MONEY_Add (&debitSumTotal, &debitSum);
		MONEY_Add (&fCreditSumTotal, &fCreditSum);
		MONEY_Add (&fDebitSumTotal, &fDebitSum);
		MONEY_Add (&sCreditSumTotal, &sCreditSum);
		MONEY_Add (&sDebitSumTotal, &sDebitSum);

		// Check account and card //
		dagJDT1->GetColStr (actNum, JDT1_ACCT_NUM, rec);
		if (_STR_IsSpacesStr (actNum))
		{
			SetErrorLine (rec+1);
			SetErrorField (JDT1_ACCT_NUM);
			SetArrNum (ao_Arr1);
			return ooInvalidAcctCode;
		}
		//Must make sure the account is postable (not a headline)
		ooErr = bizEnv.GetByOneKey (dagACT, OACT_KEYNUM_PRIMARY, actNum, true);
		if (ooErr)
		{
			SetErrorLine (rec+1);
			SetErrorField (JDT1_ACCT_NUM);
			SetArrNum (ao_Arr1);
			if (ooErr == dbmNoDataFound)
			{
				return ooInvalidAcctCode;
			}
		
			else
			{
				return ooErr;
			}
		}

		if (bizEnv.IsLocalSettingsFlag (lsf_EnableSegmentAcct))
		{
			dagACT->GetColStr (code, OACT_FORMAT_CODE, 0);
			GetEnv().AddSegmentSeperator (code);
		}
		else
		{
			dagACT->GetColStr (code, OACT_ACCOUNT_CODE, 0);
		}
		dagACT->GetColStr (tmpStr, OACT_POSTABLE, 0);
		if (_STR_strcmp (tmpStr, VAL_YES)!=0)
		{
			SetErrorLine (rec+1);
			SetErrorField (JDT1_ACCT_NUM);
			SetArrNum (ao_Arr1);

			//The account is cannot be posted
			Message (OBJ_MGR_ERROR_MSG,GO_NON_POSTABLE_ACT_IN_TRANS_MSG, code, OO_ERROR);
			return ooInvalidObject;
		}

		// Transaction currency must equal the account currency
		dagACT->GetColStr (tmpCurr, OACT_ACT_CURR, 0);
		dagJDT1->GetColStr (Curr, JDT1_FC_CURRENCY, rec);
		if (GNCoinCmp (tmpCurr, BAD_CURRENCY_STR) != 0)
		{
			if (!_STR_SpacesString (Curr, _STR_strlen (Curr)))
			{
				if (GNCoinCmp (tmpCurr, Curr) != 0)
				{
					Message (OBJ_MGR_ERROR_MSG,GO_ACT_COIN_DIFFERS, code, OO_ERROR);
					return ooInvalidObject;
				}

			}
		}
			
		dagJDT1->GetColStr (shortName, JDT1_SHORT_NAME, rec);

		if (_STR_stricmp (actNum, shortName) == 0)
		{
			//The entity in the grid is an ACCOUNT
			
			dagACT->GetColStr (tmpStr, OACT_LOC_MAN_TRAN, 0);
			if (tmpStr[0] ==VAL_YES[0])
			{
				SetErrorLine (rec+1);
				SetErrorField (JDT1_ACCT_NUM);
				SetArrNum (ao_Arr1);

				//The account is controling account
				Message (OBJ_MGR_ERROR_MSG,GO_CONTROLING_ACT_IN_TRANS_MSG, code, OO_ERROR);
				return ooInvalidObject;
			}

			SetErrorLine (rec+1);
			SetErrorField (JDT1_ACCT_NUM);
			SetArrNum (ao_Arr1);
			SBOString checkDate;
			dagJDT1->GetColStr (checkDate, JDT1_REF_DATE, rec);
			ooErr = OOCheckObjectActive (*this, dagACT, -1, actNum, &checkDate);
			if (ooErr)
			{
				return ooErr;
			}

			SetErrorLine (-1);
			SetErrorField (-1);

			dagACT->GetColStr (actCurr, OACT_ACT_CURR, 0);
			_STR_LRTrim (actCurr);
		}
		else
		{
			//The entity in the grid is a CARD
			ooErr = bizEnv.GetByOneKey (dagCRD, OCRD_KEYNUM_PRIMARY, shortName, true);
			if (ooErr)
			{
				SetErrorLine (rec+1);
				SetErrorField (JDT1_SHORT_NAME);
				SetArrNum (ao_Arr1);

				if (ooErr == dbmNoDataFound)
				{
					Message(OBJ_MGR_ERROR_MSG, GO_CRD_NAME_MISSING, shortName, OO_ERROR);
					return ooInvalidObject;
				}
			
				else
				{
					return ooErr;
				}
			}
			
			dagCRD->GetColStr (cardType, OCRD_CARD_TYPE, 0);

			if (_STR_strcmp (cardType, VAL_LEAD) == 0)
			{
				SetErrorLine (rec+1);
				SetErrorField (JDT1_SHORT_NAME);
				SetArrNum (ao_Arr1);
				Message (OBJ_MGR_ERROR_MSG, JDT_LEAD_CODE_ERROR, shortName, OO_ERROR);
				return ooInvalidObject;
			}
			
			dagACT->GetColStr (tmpStr, OACT_LOC_MAN_TRAN, 0);
			if (tmpStr[0] ==VAL_NO[0])
			{
				SetErrorLine (rec+1);
				SetArrNum (ao_Arr1);
				SetErrorField (JDT1_ACCT_NUM);

				//The account is not controling account
				Message (OBJ_MGR_ERROR_MSG,GO_CONTROLING_ACT_IN_TRANS_MSG, code, OO_ERROR);
				return ooInvalidObject;
			}
			
			dagCRD->GetColStr (tmpStr, OCRD_DEB_PAY_ACCOUNT, 0);
			if (_STR_IsSpacesStr (tmpStr))
			{
				SetErrorLine (rec + 1);
				SetErrorField (JDT1_ACCT_NUM);
				SetArrNum (ao_Arr1);
				Message (OBJ_MGR_ERROR_MSG, GO_ILLEGAL_CODE, code, OO_ERROR);
				return ooInvalidObject;
			}

			dagCRD->GetColStr (actCurr, OCRD_CRD_CURR, 0);
			_STR_LRTrim (actCurr);

			SetErrorLine( rec+1);
			SetErrorField( JDT1_SHORT_NAME);
			SetArrNum(ao_Arr1);
			if(!fromEoy && !bizEnv.IsDuringUpgradeProcess ())
			{
				SBOString checkDate;
				dagJDT1->GetColStr (checkDate, JDT1_REF_DATE, rec);
				ooErr = OOCheckObjectActive (*this, dagCRD, -1, shortName, &checkDate);
				if (ooErr)
				{
					return ooErr;
				}
				// control account must be also active
				ooErr = OOCheckObjectActive (*this, dagACT, -1, actNum, &checkDate);
				if (ooErr)
				{
					return ooErr;
				}
			}
			SetErrorLine( -1);
			SetErrorField( -1);
		}

		//Check coins
		lineCurr[0] = 0;
		if (!fCreditSum.IsZero())
		{
			dagJDT1->GetColStr (lineCurr, JDT1_FC_CURRENCY, rec);
			if (IsCurValid (lineCurr, NULL) != noErr)
			{
				SetErrorLine( rec+1);

				Message (OBJ_MGR_ERROR_MSG, GO_INVALID_COIN, lineCurr, OO_ERROR);
				return (ooInvalidObject);
			}
		}

		if (!fDebitSum.IsZero())
		{
			dagJDT1->GetColStr (lineCurr, JDT1_FC_CURRENCY, rec);
			if (IsCurValid (lineCurr, NULL) != noErr)
			{
				SetErrorLine( rec+1);
				Message (OBJ_MGR_ERROR_MSG, GO_INVALID_COIN, lineCurr, OO_ERROR);
				return (ooInvalidObject);
			}
		}

		_STR_LRTrim (lineCurr);
		allowFcMulty = TRUE;
		if (bizEnv.GetMultiCurrencyWarningLevel () == *VAL_BLOCK)
		{
			allowFcMulty = FALSE;
		}

		if(IsExCommand( ooDontValidateData2))
		{
			allowFcMulty = TRUE;
		}

		//Don't check balanse case of JDT's form is in update mode
		if(IsExCommand( ooExTempData1))
		{
			allowFcMulty = TRUE;
		}

		// Transaction currency must equal the account currency
		if (lineCurr[0] && GNCoinCmp (actCurr, BAD_CURRENCY_STR)!=0 && GNCoinCmp (lineCurr, actCurr)!=0 && GNCoinCmp (actCurr, mainCurr)!=0)
		{
			SetErrorLine( rec+1);
			if (fromImport)
			{
				_STR_GetStringResource (msgStr, OBJ_MGR_ERROR_MSG, GO_HASH_TRANSACTION_NOT_BALANCED, &GetEnv());
				_STR_sprintf (tmpStr, msgStr, transNum, GetErrorLine());
				_STR_sprintf (tmpStr, _T("%s , %s"), tmpStr, shortName);
				Message (OBJ_MGR_ERROR_MSG, GO_ACT_COIN_DIFFERS, tmpStr, OO_ERROR);
			}
			else
			{
				Message (OBJ_MGR_ERROR_MSG, GO_ACT_COIN_DIFFERS, NULL, OO_ERROR);
				return (ooInvalidObject);
			}
		}
		
		if (transCurr[0] && lineCurr[0] && GNCoinCmp (lineCurr, transCurr)!=0)
		{
			if (!allowFcMulty)
			{
				SetErrorLine( rec+1);
				if (fromImport && !msgHandled)
				{
					msgHandled = TRUE;
					_STR_GetStringResource (msgStr, OBJ_MGR_ERROR_MSG, GO_HASH_TRANSACTION_NOT_BALANCED, &GetEnv());
					_STR_sprintf (tmpStr, msgStr, transNum, GetErrorLine());
					Message (OBJ_MGR_ERROR_MSG, GO_DIFFERENT_COIN, tmpStr, OO_ERROR);
				}
				else if (!fromImport)
				{
					Message (OBJ_MGR_ERROR_MSG, GO_DIFFERENT_COIN, NULL, OO_ERROR);
				}

				if (!fromImport && !fromBatch)
				{
					return (ooInvalidObject);
				}
			}

			multyFcDetected = TRUE;
		}
		
		if (!transCurr[0])
		{
			_STR_strcpy (transCurr, lineCurr);
		}
	} // Check JDT1 records


	for (rec=0; rec<numOfRecs; rec++)
	{
		long	i;
		Boolean	exist;

		dagJDT1->GetColStr (tmpStr, JDT1_CONTRA_ACT, rec);
		_STR_LRTrim(tmpStr);
		if (tmpStr[0])
		{
			exist = FALSE;
			for (i=0; i<numOfRecs; i++)
			{
				dagJDT1->GetColStr (shortName, JDT1_SHORT_NAME, i);
				_STR_LRTrim(shortName);
				if (_STR_stricmp (tmpStr, shortName) == 0)
				{
					exist = TRUE;
					break;
				}
			}
			if (!exist)
			{
				long transType;
				dag->GetColLong (&transType, OJDT_TRANS_TYPE, 0);
				// because I don't know why DI and UI should be different here, to reduce the risk, add these conditions
				if (GetDataSource () == *VAL_OBSERVER_SOURCE 
					&& !((transType == VPM && numOfRecs == 2) || (transType == RCT && numOfRecs == 2)) )
				{
					SetErrorLine( rec + 1);
					SetErrorField( JDT1_CONTRA_ACT);
					SetArrNum(ao_Arr1);
					Message (OBJ_MGR_ERROR_MSG, GO_ILLEGAL_CODE, tmpStr, OO_ERROR);
					return ooErrNoMsg;
				}
				else
				{
					dagJDT1->SetColStr (EMPTY_STR, JDT1_CONTRA_ACT, rec);
				}
			}
		}
	}	

	ooErr = ValidateCostAccountingStatus ();
	IF_ERROR_RETURN (ooErr);

// Check Cash Flow Assignment Transaction before updating Journal Entry.
// Distinguish the flow from SBO client and SDK. Since Cash Flow is not exposed in SDK, it is necessary to bypass the mandatory check for SDK.
#ifndef MNHL_SERVER_MODE	
	if(VF_CashflowReport(bizEnv))
	{
		PDAG	dagCFT;
		MONEY	locMoney, sysMoney, fcMoney, jdt1LocMoney , jdt1SysMoney, jdt1FcMoney ;
		long	tmpTransNum;
		SBOString	objCFTId(CFT);

		dagCFT = GetDAGNoOpen(objCFTId);
		if(dagCFT)
		{
			CCashFlowTransactionObject	*bo = static_cast<CCashFlowTransactionObject*>(CreateBusinessObject(CFT));
			// Final assemble dagCFT, before validation.
			dag->GetColStr (dateStr, OJDT_REF_DATE, 0);
			bo->OCFTAssmInDag (dagCFT, dateStr);

			dag->GetColLong (&tmpTransNum, OJDT_JDT_NUM, 0);
			if (tmpTransNum == 0)
				tmpTransNum = -1;


			//    2004.08.27  Qin, Li (i025860)	      add         consider the case 'all accounts are cash flow relevant'
			bool isAllCashRelevant = true;
			for (rec=0; rec<numOfRecs; rec++)
			{
				bool	isCashFlowRelevant;

				dagJDT1->GetColStr (actNum, JDT1_SHORT_NAME, rec);

				CChartOfAccounts	*boCOA = static_cast<CChartOfAccounts*>(CreateBusinessObject(ACT));
				boCOA->IsCFWRelevant (actNum, &isCashFlowRelevant);
				boCOA->Destroy ();
				if (!isCashFlowRelevant)
				{
					isAllCashRelevant = FALSE;
					break;
				}
			}		
			// Check Journal Entry line by line.
			for (rec=0; rec<numOfRecs; rec++)
			{
				bool	isCashFlowRelevant;
				Boolean isDebit, existCFT;

				dagJDT1->GetColStr (actNum, JDT1_SHORT_NAME, rec);

				CChartOfAccounts	*boCOA = static_cast<CChartOfAccounts*>(CreateBusinessObject(ACT));
				boCOA->IsCFWRelevant (actNum, &isCashFlowRelevant);
				boCOA->Destroy ();

				// Only Cash Flow relevant account need to be checked.
				if (isCashFlowRelevant)
				{
					dagJDT1->GetColMoney (&jdt1LocMoney, JDT1_CREDIT, rec, DBM_NOT_ARRAY);
					dagJDT1->GetColMoney (&jdt1FcMoney, JDT1_FC_CREDIT, rec, DBM_NOT_ARRAY);
					dagJDT1->GetColMoney (&jdt1SysMoney, JDT1_SYS_CREDIT, rec, DBM_NOT_ARRAY);
					isDebit = FALSE;
					if (jdt1LocMoney.IsZero() == TRUE)
					{
						dagJDT1->GetColMoney (&jdt1LocMoney, JDT1_DEBIT, rec, DBM_NOT_ARRAY);
						dagJDT1->GetColMoney (&jdt1FcMoney, JDT1_FC_DEBIT, rec, DBM_NOT_ARRAY);
						dagJDT1->GetColMoney (&jdt1SysMoney, JDT1_SYS_DEBIT, rec, DBM_NOT_ARRAY);
						isDebit = TRUE;
					}

					bo->OCFTLineExistInDag (dagCFT, tmpTransNum, rec, &existCFT);
					if (existCFT == FALSE)
					{
						//					if (GetEnv().IsCFWAssignMandatory() == TRUE) // Check Mandatory
						//Li,Qin(i025860): comments 
						if (GetEnv().IsCFWAssignMandatory() == TRUE && !isAllCashRelevant) // Check Mandatory
						{
							bo->Destroy ();
							OOMessage (this, GO_OBJ_ERROR_MSGS(CFT), CFT_MANDATORY_ERROR, NULL, OO_ERROR);
							return (ooErrNoMsg);
						}
						else
							continue;
					}

					bo->OCFTGetSumInDag (dagCFT, tmpTransNum, rec, isDebit, &locMoney, &sysMoney, &fcMoney);
					if (MONEY_Cmp(&locMoney, &jdt1LocMoney) != 0 || MONEY_Cmp(&fcMoney, &jdt1FcMoney) != 0 || MONEY_Cmp(&sysMoney, &jdt1SysMoney) != 0) // Check Balance
					{
						if (bo->OCFTAutoBalanceInDag (dagCFT, tmpTransNum, rec, isDebit, &jdt1LocMoney, &jdt1SysMoney, &jdt1FcMoney) != ooNoErr)
						{
							MONEY	jdt1DebLocMoney , jdt1DebSysMoney, jdt1DebFcMoney ;

							dagJDT1->GetColMoney (&jdt1DebLocMoney, JDT1_CREDIT, rec, DBM_NOT_ARRAY);
							dagJDT1->GetColMoney (&jdt1DebFcMoney, JDT1_FC_CREDIT, rec, DBM_NOT_ARRAY);
							dagJDT1->GetColMoney (&jdt1DebSysMoney, JDT1_SYS_CREDIT, rec, DBM_NOT_ARRAY);

							MONEY	jdt1CredLocMoney , jdt1CredSysMoney, jdt1CredFcMoney ;
							dagJDT1->GetColMoney (&jdt1CredLocMoney, JDT1_DEBIT, rec, DBM_NOT_ARRAY);
							dagJDT1->GetColMoney (&jdt1CredFcMoney, JDT1_FC_DEBIT, rec, DBM_NOT_ARRAY);
							dagJDT1->GetColMoney (&jdt1CredSysMoney, JDT1_SYS_DEBIT, rec, DBM_NOT_ARRAY);

							MONEY	debLocMoney, debSysMoney, debFcMoney;
							bo->OCFTGetSumInDag (dagCFT, tmpTransNum, rec, true, &debLocMoney, &debSysMoney, &debFcMoney);
							MONEY	credLocMoney, credSysMoney, credFcMoney;
							bo->OCFTGetSumInDag (dagCFT, tmpTransNum, rec, false, &credLocMoney, &credSysMoney, &credFcMoney);


							if (jdt1DebLocMoney - debLocMoney != jdt1CredLocMoney - credLocMoney ||
								jdt1DebSysMoney - debSysMoney != jdt1CredSysMoney - credSysMoney ||
								jdt1DebFcMoney - debFcMoney != jdt1CredFcMoney - credFcMoney)
							{
								// If failed to auto balance, then show error message.
								bo->Destroy ();
								OOMessage (this, GO_OBJ_ERROR_MSGS(CFT), CFT_UNBALANCED_TRANS_ERROR, NULL, OO_ERROR);
								return (ooInvalidObject);
							}
						}
					}
				}
			}

			bo->Destroy();
		}
	}
#endif
// End of VF_CashflowReport	
//Don't check balanse case of JDT's form is in update mode
	if(IsExCommand( ooExTempData1))
	{
		SetExDtCommand(ooDoAsUpgrade, fa_SetSolo);
	}

	if (!IsExDtCommand (ooDoAsUpgrade))
	{
		// Check that transaction is balanced //
		if (MONEY_Cmp (&creditSumTotal, &debitSumTotal) || MONEY_Cmp (&sCreditSumTotal, &sDebitSumTotal))
		{	
			if (fromBatch)
			{
				buttons [0] = FU_DIALOG_SUSPEND_STR;
				buttons [1] = FU_DIALOG_CONTINUE_STR;
				buttons [2] = FU_DIALOG_EMPTY_STR;

				msgHandled = TRUE;
#ifndef	MNHL_SERVER_MODE
				retVal = FUEnhDialogBox (NULL, ERROR_MESSAGES_STR, OO_TRANSACTION_NOT_BALANCED,
										FU_DIALOG_ALERT_ICON, buttons, 2, formOKReturn);
				if (retVal == formOKReturn)
				{
					return (ooTransNotBalanced);
				}
#else
				_STR_sprintf (tmpStr, formatStr, transNum);
				Message (ERROR_MESSAGES_STR,OO_TRANSACTION_NOT_BALANCED, tmpStr, OO_ERROR);
#endif
			}
			else
			{
				_STR_sprintf (tmpStr, formatStr, transNum);
				if (fromImport)
				{
					if (!msgHandled)
					{
						msgHandled = TRUE;
						Message(ERROR_MESSAGES_STR,OO_TRANSACTION_NOT_BALANCED, tmpStr, OO_ERROR);
					}
				}
				else
				{
					Message(ERROR_MESSAGES_STR,OO_TRANSACTION_NOT_BALANCED, tmpStr, OO_ERROR);
					return (ooTransNotBalanced);
				}
			}
		}

		allowFcNotBalanced = TRUE;
		if (bizEnv.GetFCBalanceWarningLevel () == *VAL_BLOCK)
		{
			allowFcNotBalanced = FALSE;
		}

		if(IsExCommand( ooDontValidateData1))
		{
			allowFcNotBalanced = TRUE;
		}

		if (MONEY_Cmp (&fCreditSumTotal, &fDebitSumTotal))
		{
			if (allowFcMulty && multyFcDetected)
			{
				allowFcNotBalanced = TRUE;
			}

			if (!allowFcNotBalanced)
			{
				if (fromBatch && !msgHandled)
				{
					if (!multyFcDetected)
					{
						buttons [0] = FU_DIALOG_SUSPEND_STR;
						buttons [1] = FU_DIALOG_CONTINUE_STR;
						buttons [2] = FU_DIALOG_EMPTY_STR;

						msgHandled = TRUE;
#ifndef	MNHL_SERVER_MODE
						retVal = FUEnhDialogBox (NULL, ERROR_MESSAGES_STR, OO_TRANSACTION_NOT_BALANCED,
												FU_DIALOG_ALERT_ICON, buttons, 2, formOKReturn);
						if (retVal == formOKReturn)
						{
							return (ooTransNotBalanced);
						}
#else
					_STR_sprintf (tmpStr, formatStr, transNum);
					Message (ERROR_MESSAGES_STR,OO_TRANSACTION_NOT_BALANCED, tmpStr, OO_ERROR);
#endif
					}
				}
				else if (!msgHandled)
				{
					_STR_sprintf (tmpStr, formatStr, transNum);

					Message (ERROR_MESSAGES_STR,OO_TRANSACTION_NOT_BALANCED, tmpStr, OO_ERROR);
					if (fromImport)
					{
						msgHandled = TRUE;
					}
					else
					{
						return (ooTransNotBalanced);
					}
				}
			}
		}
	}

	if (!transCurr[0])
	{
		_STR_strcpy (transCurr, bizEnv.GetMainCurrency ());
	}
	else if (multyFcDetected)
	{
		_STR_strcpy (transCurr, BAD_CURRENCY_STR);
	}
	else
	{
		_STR_strcpy(lineCurr, transCurr);
	}

	dag->SetColStr (lineCurr, OJDT_TRANS_CURR, 0);

	if (VF_MultiBranch_EnabledInOADM (bizEnv))
	{
		ooErr = ValidateBPL ();
		IF_ERROR_RETURN (ooErr);
	}

	if(IsExCommand( ooDontCheckTranses))
	{
		return ooNoErr;
	}

	if (nonZero == FALSE)
	{
		if (transType != IPF && !(transType == IQR && GetEnv().IsContInventory()))
		{
			/* No sum other then zero was found */
			dag->SetErrorTable (GetEnv ().ObjectToTable (JDT));
			Message (ERROR_MESSAGES_STR, OO_ZERO_TRANSACTION, NULL, OO_ERROR);
			return (ooErrNoMsg);
		}
	}

	//@ABMerge ADD I035300 [ExciseInvoice]
	if (VF_ExciseInvoice(bizEnv))
	{
		SBOString plaAct = bizEnv.GetGLAccountManager()->GetAccountByDate(EMPTY_STR, mat_plaAct);

		plaAct.TrimRight();
		long numOfRec = dagJDT1->GetRecordCount();
		long mat_type,cenvat;
		SBOString strFlag;
		dag->GetColStr(strFlag, OJDT_GEN_REG_NO, 0);

		strFlag.Trim();

		for (long rec = 0; rec < numOfRec; rec++)
		{
			SBOString tgtAct;
			dagJDT1->GetColStr(tgtAct,JDT1_ACCT_NUM,rec);
			tgtAct.TrimRight();
			if (tgtAct == plaAct)
			{
				continue; //ignore the pair check for pla account. requested by SM team.
			}
			dagJDT1->GetColLong(&mat_type,JDT1_MATERIAL_TYPE,rec);
			dagJDT1->GetColLong(&cenvat,JDT1_CENVAT_COM,rec);
			if (!isValidCENVAT(cenvat) && !isValidMatType(mat_type))
			{
				continue;
			}
			else if(isValidCENVAT(cenvat) && isValidMatType(mat_type))
			{
				long mattypeOJDT = 0L;

				if(strFlag == VAL_YES)
				{
					dag->GetColLong(&mattypeOJDT, OJDT_MAT_TYPE, 0);
					if(mat_type != mattypeOJDT)
					{
						Message (ERROR_MESSAGES_STR, OO_MATTYPE_ROW_HEAD_UNMATCHED, NULL, OO_ERROR);
						return ooInvalidObject;						
					}
				}				
			}
			else
			{
				Message (ERROR_MESSAGES_STR,OO_MATTYPE_CENVAT_UNPAIRED, NULL, OO_ERROR);
				return ooInvalidObject;
			}
		}
	}
	//@ABMerge END I035300
	if (VF_MultipleRegistrationNumber (bizEnv))
	{
		SBOString	genRegNumFlag;
		PDAG		dagJDT = GetDAG ();
		dagJDT->GetColStr(genRegNumFlag, OJDT_GEN_REG_NO, 0);
		genRegNumFlag.Trim ();
		if(genRegNumFlag == VAL_YES)
		{
			long matType;
			long location;
			long result;
			dagJDT->GetColLong (&matType, OJDT_MAT_TYPE, 0);
			dagJDT->GetColLong (&location, OJDT_LOCATION, 0);
			PDAG dagERX = OpenDAG (ERX);
			DBD_CondStruct	condStruct[1];
			condStruct[0].colNum = OERX_LOC_ID;
			condStruct[0].operation = DBD_EQ; 
			condStruct[0].condVal = location;

			DBD_SetDAGCond(dagERX, condStruct, 1);
			result = DBD_Count (dagERX, TRUE);
			dagERX->Close ();
			if (!result)
			{
				Message (EXCISE_NUMBER_STR_LIST, EXCISE_NUMBER_NOT_DEF_ERR, NULL, OO_ERROR);
				return ooInvalidObject;
			}
			
		}

	}

	// check CIG/CUP codes (header + rows)
	if (VF_PaymentTraceability (bizEnv))
	{
		PDAG		dagJDT = GetDAG ();
		SBOString cigId, cupId, desc;
		
		dagJDT->GetColStr (cigId, OJDT_CIG);
		dagJDT->GetColStr (cupId, OJDT_CUP);
		cigId.Trim ();
		cupId.Trim ();
		if (CCigObject::GetDescription (bizEnv, cigId, desc) != noErr)
		{
			dag->SetErrorTable (GetEnv ().ObjectToTable (JDT));
			SetErrorField (OJDT_CIG);
			CMessagesManager::GetHandle ()->Message (_54_APP_MSG_FIN_CIG_DOES_NOT_EXIST, EMPTY_STR, this);
			return errNoMsg;
		}
		if (CCupObject::GetDescription (bizEnv, cupId, desc) != noErr)
		{
			dag->SetErrorTable (GetEnv ().ObjectToTable (JDT));
			SetErrorField (OJDT_CUP);
			CMessagesManager::GetHandle ()->Message (_54_APP_MSG_FIN_CUP_DOES_NOT_EXIST, EMPTY_STR, this);
			return errNoMsg;
		}

		// check JDT1 rows
		long numOfRec = dagJDT1->GetRecordCount ();
		for (long rec = 0; rec < numOfRec; rec++)
		{
			dagJDT1->GetColStr (cigId, JDT1_CIG, rec);
			dagJDT1->GetColStr (cupId, JDT1_CUP, rec);
			
			if (CCigObject::GetDescription (bizEnv, cigId, desc) != noErr)
			{
				SetErrorLine( rec + 1);
				SetErrorField( JDT1_CIG);
				SetArrNum(ao_Arr1);
				CMessagesManager::GetHandle ()->Message (_54_APP_MSG_FIN_CIG_DOES_NOT_EXIST, EMPTY_STR, this);
				return errNoMsg;
			}
			if (CCupObject::GetDescription (bizEnv, cupId, desc) != noErr)
			{
				SetErrorLine( rec + 1);
				SetErrorField( JDT1_CUP);
				SetArrNum(ao_Arr1);
				CMessagesManager::GetHandle ()->Message (_54_APP_MSG_FIN_CUP_DOES_NOT_EXIST, EMPTY_STR, this);
				return errNoMsg;
			}
		}
	}

	if (JDT == transType)
	{
		CEarlierPostingDateValidator	validator (this, false,
			_1_APP_MSG_BANK_BLOCK_DOC_WITH_EARLIER_POSTING_DATE);
		ooErr = validator.CheckBlockDocFromEarlierPostingDate();
		IF_ERROR_RETURN (ooErr);
	}

	if (GetDataSource () == *VAL_OBSERVER_SOURCE && VF_DeferredTaxInJE (bizEnv))
	{
		if (!CJDTDeferredTaxUtil (this).IsValid ())
		{
			return errNoMsg; 
		}
	}

	return ooNoErr;
} // OJDIsValidObj //

/*************************************************************************************************************/
/*************************************************************************************************************/
SBOErr	CTransactionJournalObject::OnUpdate()
{
        _TRACER("OnUpdate");
	SBOErr			ooErr;
	PDAG			dagJDT , dagJDT1, dagJDT2;
	long			rec, numOfRecs;
	CBizEnv			&bizEnv = GetEnv ();	
	PeriodMode		periodMode;

	periodMode = bizEnv.GetPeriodMode ();
	if (periodMode == ooPeriodLockedMode)
	{
		return (ooLockedPeriodErr);
	}

	dagJDT1 = GetDAG(JDT, ao_Arr1);
	// Update Cash Flow Assignment Transaction before updating Journal Entry.
	if(VF_CashflowReport(bizEnv))
	{
		SBOString	objCFTId(CFT);
		PDAG dagCFT = GetDAGNoOpen(objCFTId);

		if (dagCFT) 
		{
			CCashFlowTransactionObject	*bo = static_cast<CCashFlowTransactionObject*>(CreateBusinessObject(CFT));

			bo->SetDataSource(GetDataSource());
			bo->m_isInParentUpdateFlow = (GetCurrentBusinessFlow() == bf_Update);
			ooErr = bo->OCFTModifyByJDT (GetDAG(CFT));
			bo->Destroy();
			if (ooErr != ooNoErr)
			{
				return (ooErr);
			}
		}
	}

	dagJDT = GetDAG (JDT);
	dagJDT2 = GetDAG(JDT, ao_Arr2);

	DAG_GetCount (dagJDT1, &numOfRecs);
	for (rec = 0; rec < numOfRecs; rec++)
	{
		dagJDT1->CopyColumn (dagJDT, JDT1_TRANS_CODE, rec, OJDT_TRANS_CODE, 0);

		// set valid from for profit code
		SBOString	ocrCode, postDate, validFrom;
		dagJDT1->GetColStr (ocrCode, JDT1_OCR_CODE, rec);
		dagJDT1->GetColStr (postDate, JDT1_REF_DATE, rec);
		ooErr = COverheadCostRateObject::GetValidFrom (bizEnv, ocrCode, postDate, validFrom);
		if (ooErr)
		{
			return ooErr;
		}
		
		dagJDT1->SetColStr (validFrom, JDT1_VALID_FROM, rec);
	}
	
	bool isOrdered = this->IsPaymentOrdered ();
	long transId = -1;
	dagJDT->GetColLong (&transId, OJDT_JDT_NUM);
	bool isOrderedInDB = false;
	ooErr = CTransactionJournalObject::IsPaymentOrdered (bizEnv, transId, isOrderedInDB);
	IF_ERROR_RETURN (ooErr);
	if (isOrdered != isOrderedInDB)
	{
		bizEnv.SetErrorTable (dagJDT1->GetTableName ());
		return dbmDataWasChanged;
	}

	//fix IM:4294579 2008.
	//when the WtAmount of payment category JE is changed, update JDT1 Bp Line's WtAmount
	if (VF_JEWHT(bizEnv))
	{
		SBOString isAutoWt;
		isAutoWt.Trim ();
		dagJDT->GetColStr(isAutoWt, OJDT_AUTO_WT);

		long recCount = dagJDT2->GetRealSize (dbmDataBuffer);
		SBOString sCategory;
		if (recCount > 0)
		{
			dagJDT2->GetColStr(sCategory, JDT2_CATEGORY);
			sCategory.Trim();
		}
		if ((isAutoWt == VAL_YES) && (sCategory == VAL_CATEGORY_PAYMENT))
		{
			ooErr = UpdateWTInfo ();
		}
		if (ooErr)
		{
			return ooErr;
		}
	}

	PDAG dagOLD1 = OpenDAG (JDT, ao_Arr1);
	AutoCleanerDAG acDagOLD (dagOLD1);

	SBOString key;
	dagJDT->GetColStr (key, OJDT_JDT_NUM, 0);
	ooErr = dagOLD1->GetByKey (key);
	IF_ERROR_RETURN (ooErr);

	for (long i = 0; i < dagJDT1->GetRealSize (dbmDataBuffer); i++)
	{
		//BP reference number can not be updated 
		SBOString oldFederalTaxId, newFederalTaxId;
		dagOLD1->GetColStr (oldFederalTaxId, JDT1_TAX_ID_NUMBER, i);
		dagJDT1->GetColStr (newFederalTaxId, JDT1_TAX_ID_NUMBER, i);
		if (oldFederalTaxId.Trim () != newFederalTaxId.Trim ())
		{
			SBOString acctCode, shrtCode;
			dagJDT1->GetColStr (acctCode, JDT1_ACCT_NUM, i);
			dagJDT1->GetColStr (shrtCode, JDT1_SHORT_NAME, i);

			// field is editable on BP lines only, equivalent to form JTE_IS_CARD_COL
			// when code and name are not equal, it is a BP line
			if (acctCode.Trim () == shrtCode.Trim ())
			{
				SetErrorField (JDT1_TAX_ID_NUMBER);
				return dbmColumnNotUpdatable;
			}

			// not editable in US loc.
			if (bizEnv.IsCurrentLocalSettings (USA_SETTINGS))
			{
				SetErrorField (JDT1_TAX_ID_NUMBER);
				return dbmColumnNotUpdatable;
			}

			//editable on manual JE
			SBOString transType;
			dagJDT->GetColStr (transType, OJDT_TRANS_TYPE);

			//only JDT and NONE_CHOICE lines can be updated
			long objectId = transType.Trim ().strtol ();
			if (objectId != JDT && objectId != NONE_CHOICE)
			{
				SetErrorField (JDT1_TAX_ID_NUMBER);
				return dbmColumnNotUpdatable;
			}

			//for JDT and NONE_CHOICE lines, i.e. manual journal entries, check also portugal certification
			long series = 0;
			dagJDT->GetColLong (&series, OJDT_SERIES);
			if (VF_PTCertification (bizEnv)
				&& CDigitalSignatureBase::IsDigitalSignatureAllowed (this, series))
			{
				SetErrorField (JDT1_TAX_ID_NUMBER);
				return dbmColumnNotUpdatable;
			}
		}
	}

	bool isScAdj = false;
	ooErr = IsScAdjustment(isScAdj);
	if (isScAdj || ooErr)
	{
		SetErrorLine (-1);
		SetErrorField (OJDT_AUTO_STORNO);
		CMessagesManager::GetHandle ()->Message (_147_APP_MSG_FIN_JE_FOR_CONV_DIFF_ADJ_CANNOT_BE_REVERSED, EMPTY_STR, this);
		return ooInvalidObject;
	}

	ooErr = ValidateBPLNumberingSeries ();
	IF_ERROR_RETURN (ooErr);

	ooErr = IsBalancedByBPL ();
	IF_ERROR_RETURN (ooErr);

	ooErr = CSystemBusinessObject::OnUpdate();

	return	(ooErr);
} /* end of OJDUpdateObj () */

/*************************************************************************************************************/
/*************************************************************************************************************/
SBOErr	CTransactionJournalObject::OnAutoComplete ()
{
        _TRACER("OnAutoComplete");
	SBOErr		ooErr = noErr;
	long		rec, numOfRecs;

	Currency	sysCurr={0};
	Currency	localCurr ={0};
	Currency	tempCurr={0};

	TCHAR		lineCurr[256]={0};
	TCHAR		dateStr[JDT1_DUE_DATE_LEN+1]={0};
	TCHAR		batchNum[OJDT_BATCH_NUM_LEN+1]={0};
	TCHAR		indicator[OJDT_INDICATOR_LEN+1]={0};
	TCHAR		tmpStr[256];
	TCHAR		actNum[JDT1_ACCT_NUM_LEN+1], shortName[JDT1_SHORT_NAME_LEN+1];
	TCHAR		method[OVTG_CALCULATION_METHOD_LEN + 1];			
	TCHAR		stampTax[OJDT_STAMP_TAX_LEN + 1];

	Boolean		sysFound =FALSE, needBaseSum;

	MONEY		money, debMoneyFC, credMoneyFC, zeroM, vatPrcnt, equVatPrcnt, baseSum;
	MONEY		minAmount, fixedAmount, tmpM;
	PDAG		dagJDT = NULL, dagJDT1 = NULL, dagACT = NULL, dagCRD = NULL;
	CBizEnv		&bizEnv = GetEnv ();
    StdMap<SBOString, FCRoundingStruct, False, False> currencyRoundingMap;
	FCRoundingStruct  roundingStruct; 

	dagJDT = GetDAG (JDT);
	dagJDT1 = GetDAG(JDT, ao_Arr1);
	dagACT = GetDAG (ACT);
	dagCRD = GetDAG(CRD);

	//replace related table keys to the keys saved in the related dags - in order to keep data consistent
	ooErr = CompleteKeys ();
	if (ooErr)
	{
		if(ooErr == dbmRecordLocked)
		{
			Message (ERROR_MESSAGES_STR, OO_RECORD_LOCKED_BY_ANOTHER_TRAN_STR, NULL, OO_ERROR);
		}
		return ooErr;
	}

	_STR_strcpy (sysCurr, bizEnv.GetSystemCurrency ());
	_STR_strcpy (localCurr, bizEnv.GetMainCurrency ());

	zeroM.SetToZero();

	SetDebitCreditField();

	if (IsExDtCommand (ooDoAsUpgrade))
	{
		dagJDT->GetColLong (&rec, OJDT_JDT_NUM, 0);
		SetInternalKey(rec);
	}
	else
	{
		ooErr = CompleteTrans ();
		if (ooErr)
		{
			return ooErr;
		}
	}

	dagJDT->GetColStr (tmpStr, OJDT_TAX_DATE, 0);
	if (_STR_atol (tmpStr) <= 0)
	{
		dagJDT->CopyColumn (dagJDT, OJDT_TAX_DATE, 0, OJDT_REF_DATE, 0);
	}

	DAG_GetCount (dagJDT1, &numOfRecs);
	ooErr = CompleteJdtLine ();
	
	if (GetDataSource () == *VAL_OBSERVER_SOURCE && !IsExDtCommand(ooOBServerUpdate))
	{
		// Vat Line already released with R/W on this property
		for (rec=0; rec<numOfRecs; rec++)
		{
			dagJDT1->SetColStr (VAL_NO, JDT1_VAT_LINE, rec);
		}
		if (bizEnv.IsVatPerLine () || bizEnv.IsVatPerCard())
		{
			dagJDT->GetColStr (tmpStr, OJDT_AUTO_VAT, 0);
			if (tmpStr[0] == VAL_NO[0])
			{
				for (rec=0; rec<numOfRecs; rec++)
				{
					dagJDT1->GetColStr (tmpStr, bizEnv.IsVatPerLine () ? JDT1_VAT_GROUP : JDT1_TAX_CODE, rec);
					if (!_STR_IsSpacesStr (tmpStr))
					{
						dagJDT1->SetColStr (VAL_YES, JDT1_VAT_LINE, rec);
					}
				}
			}
		}
	}

	dagJDT->GetColStr (lineCurr, OJDT_TRANS_CURR, 0);
	_STR_LRTrim (lineCurr);
	_STR_strcpy (tempCurr, lineCurr);

	if (!tempCurr[0])
	{
		for (rec=0; rec<numOfRecs; rec++)
		{
			dagJDT1->GetColStr (lineCurr, JDT1_FC_CURRENCY, rec);
			_STR_LRTrim (lineCurr);
			if (lineCurr[0])
			{
				break;
			}
		}
		dagJDT->SetColStr (lineCurr, OJDT_TRANS_CURR, 0);
	}

	dagJDT->GetColStr (batchNum, OJDT_BATCH_NUM, 0);
	_STR_LRTrim (batchNum);
	dagJDT->GetColStr (indicator, OJDT_INDICATOR, 0);

	dagJDT->GetColStr (tmpStr, OJDT_MEMO, 0);
	_STR_CleanExtendedEditMarks (tmpStr, ' ');
	_STR_LRTrim (tmpStr);
	dagJDT->SetColStr (tmpStr, OJDT_MEMO, 0);

	if (IsExDtCommand(ooOBServerUpdate) && !IsExCommand(ooExAddBatchNoClose))
	{
		for (rec=0; rec<numOfRecs; rec++)
		{
			dagJDT1->GetColStr (tmpStr, JDT1_LINE_MEMO, rec);
			_STR_CleanExtendedEditMarks (tmpStr, ' ');
			_STR_LRTrim (tmpStr);
			dagJDT1->SetColStr (tmpStr, JDT1_LINE_MEMO, rec);

			dagJDT1->SetColStr (batchNum, JDT1_BATCH_NUM, rec);
			dagJDT1->SetColStr (indicator, JDT1_INDICATOR, rec);
		}
		return ooErr;
	}
	dagJDT->GetColStr (stampTax, OJDT_STAMP_TAX, 0);

	for (rec=0; rec<numOfRecs; rec++)
	{
		// Set block reason default value under the condition:
        // 1. Payment block is set to be 'Y';
        // 2. Block reason is un-touched.
        dagJDT1->GetColStr (tmpStr, JDT1_PAYMENT_BLOCK, rec);
        if (VAL_YES[0] == tmpStr[0])
        {
            dagJDT1->GetColStr (tmpStr, JDT1_PAYMENT_BLOCK_REF, rec);
            if (dagJDT1->IsNullCol (JDT1_PAYMENT_BLOCK_REF, rec) || _STR_IsSpacesStr (tmpStr))
            {
                dagJDT1->SetColStr ((SBOString)NONE_CHOICE, JDT1_PAYMENT_BLOCK_REF, rec);
            }
        }

		dagJDT1->GetColStr (tmpStr, JDT1_LINE_MEMO, rec);
		_STR_CleanExtendedEditMarks (tmpStr, ' ');
		_STR_LRTrim (tmpStr);
		dagJDT1->SetColStr (tmpStr, JDT1_LINE_MEMO, rec);

		dagJDT1->SetColStr (batchNum, JDT1_BATCH_NUM, rec);
		dagJDT1->SetColStr (indicator, JDT1_INDICATOR, rec);

		//Get operation date
		dagJDT1->GetColStr (dateStr, JDT1_REF_DATE, rec);

		dagJDT1->GetColMoney (&debMoneyFC, JDT1_FC_DEBIT, rec, DBM_NOT_ARRAY);
		dagJDT1->GetColMoney (&credMoneyFC, JDT1_FC_CREDIT, rec, DBM_NOT_ARRAY);

		if (bizEnv.IsVatPerLine ())
		{
			dagJDT1->GetColStr (tmpStr, JDT1_VAT_LINE, rec);
			if (tmpStr[0] == VAL_YES[0])
			{
				if (stampTax[0] == VAL_NO[0])
				{
					dagJDT1->GetColStr (tmpStr, JDT1_VAT_GROUP, rec);
					ooErr = bizEnv.GetVatPercent (tmpStr, bizEnv.GetDateForTaxRateDetermination (dagJDT1, rec), &vatPrcnt, &equVatPrcnt);
					if (ooErr)
					{
						return ooErr;
					}
					dagJDT1->SetColMoney (&vatPrcnt, JDT1_VAT_PERCENT, rec, DBM_NOT_ARRAY);
					dagJDT1->SetColMoney (&equVatPrcnt, JDT1_EQU_VAT_PERCENT, rec);

					if (dagJDT1->IsNullCol (JDT1_BASE_SUM, rec))
					{
						needBaseSum = TRUE;
					}
					else
					{
						needBaseSum = FALSE;
					}
				}
				else
				{
					dagJDT1->GetColStr (tmpStr, JDT1_VAT_GROUP, rec);
					TZGetStampValue (dagJDT, tmpStr, dateStr, &vatPrcnt, &minAmount, method, &fixedAmount);
					if (method[0] == VAL_RATE[0])
					{
						dagJDT1->SetColMoney (&vatPrcnt, JDT1_VAT_PERCENT, rec, DBM_NOT_ARRAY);
					}
					else
					{
						dagJDT1->NullifyCol (JDT1_VAT_PERCENT, rec);
					}
				}
			}
			else
			{
				dagJDT1->SetColMoney (&zeroM, JDT1_BASE_SUM, rec, DBM_NOT_ARRAY);
				dagJDT1->SetColMoney (&zeroM, JDT1_VAT_PERCENT, rec, DBM_NOT_ARRAY);
				vatPrcnt = zeroM;
				needBaseSum = FALSE;
			}
		}
		else
		{
			dagJDT1->NullifyCol (JDT1_VAT_GROUP, rec);
			vatPrcnt = zeroM;
			needBaseSum = FALSE;
		}
		
		baseSum.SetToZero();

		if (credMoneyFC.IsZero() && debMoneyFC.IsZero())
		{
			dagJDT1->GetColMoney (&money, JDT1_DEBIT, rec, DBM_NOT_ARRAY);
			if (needBaseSum && !money.IsZero())
			{
				baseSum = money;
			}
			dagJDT1->GetColMoney (&money, JDT1_CREDIT, rec, DBM_NOT_ARRAY);
			if (needBaseSum && baseSum.IsZero())
			{
				baseSum = money;
			}
		}
		else
		{
           /* dagJDT1->GetColStr (tmpStr, JDT1_WT_LIABLE, rec);
            if(tmpStr[0] == VAL_YES[0])
            {
                needSetFCToLCRound = false;
            }
            dagJDT1->GetColStr (tmpStr, bizEnv.IsVatPerLine () ? JDT1_VAT_GROUP : JDT1_TAX_CODE, rec);
            if (!_STR_IsSpacesStr (tmpStr))
            {
                needSetFCToLCRound = false;
            }*/

			dagJDT1->GetColStr (lineCurr, JDT1_FC_CURRENCY, rec);
			if (_STR_SpacesString (lineCurr, _STR_strlen (lineCurr)))
			{
				dagJDT1->GetColStr (actNum, JDT1_ACCT_NUM, rec);
				dagJDT1->GetColStr (shortName, JDT1_SHORT_NAME, rec);
				if (_STR_strcmp (actNum, shortName) == 0)
				{
					ooErr = bizEnv.GetByOneKey (dagACT, OACT_KEYNUM_PRIMARY, actNum, true);
					if (!ooErr)
					{
						dagACT->GetColStr (lineCurr, OACT_ACT_CURR, 0);
						if (GNCoinCmp (lineCurr, BAD_CURRENCY_STR) && GNCoinCmp (lineCurr, localCurr))
						{
							dagJDT1->SetColStr (lineCurr, JDT1_FC_CURRENCY, rec);
						}
						else if (GNCoinCmp (lineCurr, BAD_CURRENCY_STR) == 0)
						{
							long	i;

							lineCurr[0] = 0;
							for (i = rec -1; i > 0; i--)
							{
								dagJDT1->GetColStr (lineCurr, JDT1_FC_CURRENCY, i);
								if (!_STR_SpacesString (lineCurr, _STR_strlen (lineCurr)))
								{
									dagJDT1->SetColStr (lineCurr, JDT1_FC_CURRENCY, rec);
									break;
								}
							}
						}
						else
						{
							lineCurr[0] = 0;
						}
					}
				}
				else
				{
					ooErr = bizEnv.GetByOneKey (dagCRD, OCRD_KEYNUM_PRIMARY, shortName, true);
					if (!ooErr)
					{
						dagCRD->GetColStr (lineCurr, OCRD_CRD_CURR, 0);
						if (GNCoinCmp (lineCurr, BAD_CURRENCY_STR) && GNCoinCmp (lineCurr, localCurr))
						{
							dagJDT1->SetColStr (lineCurr, JDT1_FC_CURRENCY, rec);
						}
						else if (GNCoinCmp (lineCurr, BAD_CURRENCY_STR) == 0)
						{
							long	i;

							lineCurr[0] = 0;
							for (i = rec -1; i > 0; i--)
							{
								dagJDT1->GetColStr (lineCurr, JDT1_FC_CURRENCY, i);
								if (!_STR_SpacesString (lineCurr, _STR_strlen (lineCurr)))
								{
									dagJDT1->SetColStr (lineCurr, JDT1_FC_CURRENCY, rec);
									break;
								}
							}
						}
						else
						{
							lineCurr[0] = 0;
						}
					}
				}
			}
			//Translate to local
            if (!debMoneyFC.IsZero ()) 
    		{
                if (dagJDT1->IsNullCol (JDT1_DEBIT, rec))
                {
                    ooErr = GNForeignToLocalRate (&debMoneyFC, lineCurr, dateStr, 0.0, &money,GetEnv());
                    if (ooErr)
                    {
                        if (IsExCommand(ooExAutoMode)) 
                        { 
                            if (ooErr == ooUndefinedCurrency)
                            {
                                CMessagesManager::GetHandle()->Message(
                                    _1_APP_MSG_FIN_OO_UNDEFINED_CURRENCY, 
                                    EMPTY_STR, 
                                    this);
                            }
                            else
                            {
                                CMessagesManager::GetHandle()->Message(
                                    _1_APP_MSG_AP_AR_REPOSTING_SYSTEM_RATE_NOT_DEFINED, 
                                    EMPTY_STR, 
                                    this);
                            }
                        }
                        return ooErr;
                    }
                    money.Round(RC_SUM, localCurr, bizEnv);
                    dagJDT1->SetColMoney (&money, JDT1_DEBIT, rec, DBM_NOT_ARRAY);

					currencyRoundingMap.Lookup(SBOString(lineCurr).Trim(), roundingStruct);
					roundingStruct.needRounding = true;
					currencyRoundingMap[SBOString(lineCurr).Trim()] = roundingStruct;
                }
			}

            if (!credMoneyFC.IsZero ())
            {
                if (dagJDT1->IsNullCol (JDT1_CREDIT, rec))
                {
                    ooErr = GNForeignToLocalRate (&credMoneyFC, lineCurr, dateStr, 0.0, &money,GetEnv());
				    if (ooErr)
				    {
					    if (IsExCommand(ooExAutoMode)) 
					    { 
						    if (ooErr == ooUndefinedCurrency)
						    {
                                CMessagesManager::GetHandle()->Message(
                                    _1_APP_MSG_FIN_OO_UNDEFINED_CURRENCY, 
                                    EMPTY_STR, 
                                    this);
						    }
						    else
						    {
                                CMessagesManager::GetHandle()->Message(
                                    _1_APP_MSG_AP_AR_REPOSTING_SYSTEM_RATE_NOT_DEFINED, 
                                    EMPTY_STR, 
                                    this);
						    }
					    }
					    return ooErr;
				    }
                    money.Round(RC_SUM, localCurr, bizEnv);
				    dagJDT1->SetColMoney (&money, JDT1_CREDIT, rec, DBM_NOT_ARRAY);

					currencyRoundingMap.Lookup(SBOString(lineCurr).Trim(), roundingStruct);
					roundingStruct.needRounding = true;
					currencyRoundingMap[SBOString(lineCurr).Trim()] = roundingStruct;
                }
   			}

			if (!tmpM.IsZero() && dagJDT1->IsNullCol (JDT1_GROSS_VALUE, rec))
			{
				ooErr = GNForeignToLocalRate (&tmpM, lineCurr, dateStr, 0.0, &money,GetEnv());
				if (ooErr)
				{
					if (ooErr == ooUndefinedCurrency)
					{
						Message (ERROR_MESSAGES_STR, OO_UNDEFINED_CURRENCY, NULL, OO_ERROR);
					}
					else
					{
						Message (ERROR_MESSAGES_STR, OO_RATE_MISSING, NULL, OO_ERROR);
					}
					return ooErr;
				}
				MONEY_Round (&money, RC_SUM, localCurr, bizEnv);
				dagJDT1->SetColMoney (&money, JDT1_GROSS_VALUE, rec, DBM_NOT_ARRAY);
			}

			if (needBaseSum)
			{
				if (!debMoneyFC.IsZero())
				{
					ooErr = GNForeignToLocalRate (&debMoneyFC, lineCurr, dateStr, 0.0, &baseSum,GetEnv());
				}
				else
				{
					ooErr = GNForeignToLocalRate (&credMoneyFC, lineCurr, dateStr, 0.0, &baseSum,GetEnv());
				}

				if (ooErr)
				{
					if (IsExCommand(ooExAutoMode)) 
					{ 
						if (ooErr == ooUndefinedCurrency)
						{
							Message (ERROR_MESSAGES_STR, OO_UNDEFINED_CURRENCY, NULL, OO_ERROR);
						}
						else
						{
							Message (ERROR_MESSAGES_STR, OO_RATE_MISSING, NULL, OO_ERROR);
						}
					}
					return ooErr;
				}
			}
		}

		if (needBaseSum)
		{
			MONEY_MulMLAndDivMM (&baseSum, 100 * MONEY_PERCISION_MUL, &vatPrcnt, &baseSum, FALSE, bizEnv);
			MONEY_Round (&baseSum, RC_SUM, localCurr, bizEnv);
			dagJDT1->SetColMoney (&baseSum, JDT1_BASE_SUM, rec, DBM_NOT_ARRAY);
		}

		if (dagJDT1->IsNullCol (JDT1_PROJECT, rec))
		{
			dagJDT1->GetColStr (actNum, JDT1_ACCT_NUM, rec);
			dagJDT1->GetColStr (shortName, JDT1_SHORT_NAME, rec);
			if (_STR_strcmp (actNum, shortName) == 0)
			{
				ooErr = bizEnv.GetByOneKey (dagACT, OACT_KEYNUM_PRIMARY, actNum, true);
				if (!ooErr)
				{
					dagJDT1->CopyColumn (dagACT, JDT1_PROJECT, rec, OACT_PROJECT, 0);
				}
			}
		}
	}

	long transType;
	dagJDT->GetColLong (&transType, OJDT_TRANS_TYPE, 0);
	if (GetDataSource () != *VAL_OBSERVER_SOURCE && transType == JDT)
	{
		//balance JDT1 only if per-currency sum in FC is balanced (checked in HandleFCExchangeRounding)
		HandleFCExchangeRounding (dagJDT1, currencyRoundingMap);
	}

	if ((!IsExDtCommand (ooOBServerUpdate) || IsExCommand (ooExAddBatchNoClose)) 
        && !IsExDtCommand (ooBSPExchangeRateDiff) // If bit ooBSPExchangeRateDiff is set, 
                                                  // do not update the SC amount here.
        && (transType != ITR) && !OOIsFixedAssetsObject(transType))
	{
		ooErr = CalculationSystAmmountOfTrans();
		if (ooErr)
		{
			return ooErr;
		}
	}

	if (GetDataSource () == *VAL_OBSERVER_SOURCE && !IsExDtCommand(ooOBServerUpdate))
	{
		ooErr = CompleteForeignAmount();
		if (ooErr)
		{
			return ooErr;
		}
		ooErr = CompleteVatLine();
		if (ooErr)
		{
			return ooErr;
		}
		if (VF_JEWHT(bizEnv))
		{
			ooErr = CompleteWTLine ();
			if (ooErr)
			{
				return ooErr;
			}
		}

		// Call to the functions again to complete the dates in added vat lines
		ooErr = CompleteTrans ();
		if (ooErr)
		{
			return ooErr;
		}
		ooErr = CompleteJdtLine();

		if (transType == JDT)
		{
			//balance JDT1 only if per-currency sum in FC is balanced (checked in HandleFCExchangeRounding)
			HandleFCExchangeRounding (dagJDT1, currencyRoundingMap);
		}
	}

	// fill transaction code (FRENCH localization only), if some G/L account is linked to trans. code
	// (first such G/L account is taken)
	if (bizEnv.IsCurrentLocalSettings(FRANCE_SETTINGS))
	{
		SBOString	transCode, glAcct;
		long		jdtLine;

		ooErr = dagJDT->GetColStr(transCode, OJDT_TRANS_CODE, 0);
		transCode.Trim();

		if (!ooErr && transCode.IsEmpty())
		{
			ooErr = CJournalManager::GetDefaultTransCode(this, dagJDT, dagJDT1, glAcct, transCode, jdtLine);
			if (!ooErr && jdtLine >= 0)
				ooErr = dagJDT->SetColStr(transCode, OJDT_TRANS_CODE, 0);
		}
	}
	if (GetDataSource () == *VAL_OBSERVER_SOURCE && VF_FIReleaseProc (bizEnv))     //when creating a manual JE
  	{
   		TCHAR  creatorName[OJDT_CREATOR_NAME_LEN + 1];
  		_MEM_Set(creatorName, 0, OJDT_CREATOR_NAME_LEN + 1);
  		SBOString creator; 
  		CEmployeeObject::HEMGetEmployeeNameByUsrCode(creator, bizEnv, bizEnv.GetUserCode(), true);
  		creator.ToBuffer(creatorName, OJDT_CREATOR_NAME_LEN);
		dagJDT->GetColStr (batchNum, OJDT_BATCH_NUM, 0);
  		_STR_LRTrim (batchNum);
  		if(batchNum[0] == '\0' && transType == JDT)
  		{
			if (VF_OD_SFA(bizEnv)) 
			{
				SBOString tmpStr;
				dagJDT->GetColStr (tmpStr, OJDT_CREATOR_NAME, 0);
				if (tmpStr.IsSpacesStr ())
				{
					dagJDT->SetColStr(creatorName, OJDT_CREATOR_NAME, 0);
				}

				dagJDT->GetColStr (tmpStr, OJDT_APPROVER_NAME, 0);
				if (tmpStr.IsSpacesStr ())
				{
					dagJDT->SetColStr(creatorName, OJDT_APPROVER_NAME, 0);
				}
			}
			else 
			{
				dagJDT->SetColStr(creatorName, OJDT_CREATOR_NAME, 0);
				dagJDT->SetColStr(creatorName, OJDT_APPROVER_NAME, 0);
			}
 		}
   	}

	if(VF_MultipleRegistrationNumber(bizEnv))
	{
		CompleteLocations();
	}

	// VF_Model340_EnabledInOADM
	ooErr = CompleteReport340 (dagJDT, dagJDT1);
	if (ooErr)
	{
		return ooErr;
	}
	
	return ooErr;
}
/*************************************************************************************************************/
/*************************************************************************************************************/
//************************************
// Method:    CalculationFrnAmmounts
// FullName:  CTransactionJournalObject::CalculationFrnAmmounts
// Access:    private 
// Returns:   SBOErr
// Qualifier:
// Parameter: PDAG dagACT
// Parameter: PDAG dagCRD
// Parameter: bool & found
//************************************
SBOErr CTransactionJournalObject::CalculationFrnAmmounts(PDAG dagACT, PDAG dagCRD, bool& found)
{
	SBOErr		ooErr = noErr;
	PDAG		dagJDT = NULL, dagJDT1 = NULL;
	Currency	mainCurr = {0}, frnCurr = {0};
	MONEY		money, frnAmnt;
	long		rec, numOfRecs, colIndex, transCode;
	SBOString	lineCurr, tLineCurr, oldLineCurr, bpCurr, actCurr;
	SBOString	accName, shortName, gCurr, uLineCurr;
	TCHAR		dateStr[JDT1_REF_DATE_LEN+1]={0};
	bool		needFC = false, bpFC = false;
	CBizEnv&	bizEnv = GetEnv ();

	StdMap<long, SBOString, False, False>	currencies;

	dagJDT = GetDAG ();

	ooErr = dagJDT->GetColLong(&transCode, OJDT_TRANS_TYPE, 0);
	IF_ERROR_RETURN (ooErr);

	//fill FC Amounts only for manual JE and DI API
	if (*VAL_OBSERVER_SOURCE != GetDataSource () || JDT != transCode) {
		return ooErr;
	}

	dagJDT1 = GetDAG (JDT, ao_Arr1);

	_STR_strcpy (mainCurr, bizEnv.GetMainCurrency ());
	_STR_LTrim (mainCurr);

	DAG_GetCount (dagJDT1, &numOfRecs);

	// find FC Currency
	for (rec = 0; rec < numOfRecs; ++rec)
	{
		dagJDT1->GetColStr (tLineCurr, JDT1_FC_CURRENCY, rec);
		tLineCurr.Trim ();
		bpFC = false;

		if (!tLineCurr.GetLength())
		{
			// check if FC is required
			dagJDT1->GetColStr (accName, JDT1_ACCT_NUM, rec);
			dagJDT1->GetColStr (shortName, JDT1_SHORT_NAME, rec);

			if ( accName.Compare( shortName ) )
			{
				// business partner
				dagCRD = GetDAG (CRD);
				ooErr = dagCRD->GetByKey (shortName);

				ooErr = (dbmNoDataFound == ooErr) ? ooInvalidCardCode : ooErr;
				IF_ERROR_RETURN (ooErr);

				dagCRD->GetColStr (bpCurr, OCRD_CRD_CURR, 0);
				bpCurr.Trim ();
				bpFC = GNCoinCmp (bpCurr, BAD_CURRENCY_STR) ? true : false;
			}

			//account
			bool multiACT = false;

			dagACT = GetDAG (ACT);
			ooErr = dagACT->GetByKey (accName);

			ooErr = (dbmNoDataFound == ooErr) ? ooInvalidAcctCode : ooErr;
			IF_ERROR_RETURN (ooErr);

			dagACT->GetColStr (actCurr, OACT_ACT_CURR, 0);
			actCurr.Trim ();
			multiACT = !GNCoinCmp (actCurr, BAD_CURRENCY_STR);

			if (bpFC)
			{
				// check account & business partner currency 
				if (multiACT || !GNCoinCmp (actCurr, bpCurr))
				{
					tLineCurr = bpCurr;
					currencies.SetAt (rec, bpCurr);
				}
				else
				{
					currencies.SetAt (rec, actCurr);
				}
			}
			else
			{
				currencies.SetAt (rec, actCurr);

				// check account currency
				// as default multi currency use main currency
				tLineCurr = multiACT ? mainCurr : actCurr;
			}
		}

		if (GNCoinCmp (tLineCurr, mainCurr) && tLineCurr.GetLength())
		{
			// we found FC currency for transaction
			if (!lineCurr.GetLength())
			{
				lineCurr = tLineCurr;
			}
		}
		// else : this line is multi currency, but next could be FC
	}

	if (!GNCoinCmp (lineCurr, mainCurr) || !lineCurr.GetLength ())
	{
		return ooErr;
	}

	// fill FC credit or debit
	for (rec = 0; rec < numOfRecs; rec++)
	{
		// check row currency - fill values only when FC is not set
		if (dagJDT1->IsNullCol (JDT1_FC_CURRENCY, rec))
		{
			if (currencies.Lookup (rec, gCurr))
			{
				// do not write FC amounts when are already inserted by user
				if (dagJDT1->IsNullCol (JDT1_FC_CREDIT, rec) && dagJDT1->IsNullCol (JDT1_FC_DEBIT, rec))
				{
					// check line currency
					if (GNCoinCmp (gCurr, mainCurr))
					{
						uLineCurr = gCurr;

						if (!GNCoinCmp (uLineCurr, BAD_CURRENCY_STR))
						{
							uLineCurr = lineCurr;
						}

						uLineCurr.ToBuffer (frnCurr);

						dagJDT1->GetColMoney (&money, JDT1_CREDIT, rec);
						colIndex = JDT1_FC_CREDIT;

						if (money.IsZero ())
						{
							colIndex = JDT1_FC_DEBIT;
							dagJDT1->GetColMoney (&money, JDT1_DEBIT, rec);
						}

						if (!money.IsZero ())
						{
							dagJDT1->SetColStr (uLineCurr, JDT1_FC_CURRENCY, rec);
							dagJDT1->GetColStr (dateStr, JDT1_REF_DATE, rec);

							ooErr = GNLocalToForeignRate (&money, frnCurr, dateStr, 0.0, &frnAmnt, bizEnv);
							IF_ERROR_RETURN (ooErr);

							frnAmnt.Round(RC_SUM, lineCurr, bizEnv);
							dagJDT1->SetColMoney (&frnAmnt, colIndex, rec);
							found = true;
						}
					}
					//else - local currency, do nothing
				}
				else
				{
					dagJDT1->GetColMoney (&money, JDT1_FC_CREDIT, rec);

					if (money.IsZero())
					{
						dagJDT1->GetColMoney (&money, JDT1_FC_DEBIT, rec);
					}

					if (gCurr.GetLength() > 0 && GNCoinCmp (gCurr, BAD_CURRENCY_STR) && !money.IsZero())
					{
						if (GNCoinCmp (gCurr, mainCurr))
						{
							dagJDT1->SetColStr (gCurr, JDT1_FC_CURRENCY, rec);
						}
					}	
					// else - no automatic currency for multi-currency acct/bp, or no currency for zero amount
				}
			}
			// else - no currency for given row found
		}
		else
		{
			//check if currency exists
			Boolean	exist = 0;
			Currency currLine;

			dagJDT1->GetColStr (oldLineCurr, JDT1_FC_CURRENCY, rec);
			oldLineCurr.ToBuffer (currLine);

			ooErr = GNCheckCurrencyCode (bizEnv, currLine, &exist);
			IF_ERROR_RETURN (ooErr);

			if (!exist)
			{
				return ooUndefinedCurrency;
			}

			Boolean crNull = dagJDT1->IsNullCol (JDT1_FC_CREDIT, rec);
			Boolean dbNull = dagJDT1->IsNullCol (JDT1_FC_DEBIT, rec);
			Boolean oneValue = false, remFC = false;

			if (crNull && !dbNull)
			{
				oneValue = true;
				dagJDT1->GetColMoney (&money, JDT1_FC_DEBIT, rec);
			}

			if (!crNull && dbNull)
			{
				oneValue = true;
				dagJDT1->GetColMoney (&money, JDT1_FC_CREDIT, rec);
			}

			if (oneValue)
			{
				remFC = money.IsZero ();
			}
			else
			{
				dagJDT1->GetColMoney (&money, JDT1_FC_CREDIT, rec);

				if (money.IsZero ())
				{
					dagJDT1->GetColMoney (&money, JDT1_FC_DEBIT, rec);
				}

				remFC = money.IsZero ();
			}

			if (remFC)
			{
				// null FC currency, because FC amount is zero
				dagJDT1->NullifyCol (JDT1_FC_CURRENCY, rec);
			}
		}
	}

	return ooErr;
}

/*************************************************************************************************************/
/*************************************************************************************************************/
SBOErr	CTransactionJournalObject::CalculationSystAmmountOfTrans ()
{
        _TRACER("CalculationSystAmmountOfTrans");
	SBOErr		ooErr = ooNoErr;
	PDAG		dagJDT = NULL, dagJDT1 = NULL;
	long		rec, numOfRecs;
	bool		sideOfDebit, forceBalance = true;

	Date		refDate;
	bool		multiFrgCurr, hasOneFrgCurr, frgCurr; 
	bool		notTranslateToSys, getOnlyFromLocal;

	MONEY		tmpMoney, systMoney, rateLine, opMoney, credit, debit;
	MONEY		systCredTotal, systDebTotal, credFTotal, debFTotal;

	Currency	mainCurr, lineCurr, systCurr, currStr, prevCurr = {0};
	TCHAR		tmpStr[256];
	CBizEnv		&bizEnv = GetEnv ();

	dagJDT = GetDAG();
	dagJDT1 = GetDAG(JDT, ao_Arr1);

	multiFrgCurr= false;
	frgCurr= false;
	getOnlyFromLocal= false;
	notTranslateToSys = false;
	hasOneFrgCurr = false;

	_STR_strcpy (mainCurr, bizEnv.GetMainCurrency ());
	_STR_strcpy (systCurr, bizEnv.GetSystemCurrency ());

	DAG_GetCount (dagJDT1, &numOfRecs);

 	tmpMoney.SetToZero();
	systMoney.SetToZero();
	rateLine.SetToZero();
	systDebTotal.SetToZero();
 	systCredTotal.SetToZero();
  	credFTotal.SetToZero();
 	debFTotal.SetToZero();
 	credit.SetToZero();
 	debit.SetToZero();

	dagJDT->GetColStr (refDate, OJDT_REF_DATE, 0);

	for (rec = 0; rec < numOfRecs; rec++)
	{
		dagJDT1->GetColMoney (&tmpMoney, JDT1_FC_CREDIT, rec, DBM_NOT_ARRAY);
		MONEY_Add (&credFTotal, &tmpMoney);
		dagJDT1->GetColMoney (&tmpMoney, JDT1_FC_DEBIT, rec, DBM_NOT_ARRAY);
		MONEY_Add (&debFTotal, &tmpMoney);
	}

	if (!GNCoinCmp (mainCurr, systCurr))
	{
		notTranslateToSys = true;
		getOnlyFromLocal = true;
	}

	if (MONEY_Cmp (&credFTotal, &debFTotal))
	{
		if (!getOnlyFromLocal)
		{
			dagJDT->GetColStr (tmpStr, OJDT_AUTO_VAT, 0);
			if (tmpStr[0] == VAL_NO[0])
			{
				getOnlyFromLocal = true;
			}
			else
			{
				bool	vatFound = false;
				for (rec = 0; rec < numOfRecs; rec++)
				{
					dagJDT1->GetColStr (tmpStr, bizEnv.IsVatPerLine () ? JDT1_VAT_GROUP : JDT1_TAX_CODE, rec);
					if (!_STR_IsSpacesStr (tmpStr))
					{
						vatFound = true;
						break;
					}
				}
				if (!vatFound)
				{
					getOnlyFromLocal = true;
				}
				else
				{
					forceBalance = false;
				}
			}
		}
	}
	
	tmpMoney.SetToZero();
	credFTotal.SetToZero();
 	debFTotal.SetToZero();

	if (!getOnlyFromLocal)
	{
		for (rec = 0; rec < numOfRecs; rec++)
		{
			dagJDT1->GetColStr (lineCurr, JDT1_FC_CURRENCY, rec);	
			_STR_LRTrim (lineCurr);
			if (lineCurr[0] && prevCurr[0] && GNCoinCmp (prevCurr, lineCurr))
			{
				multiFrgCurr = true;
				getOnlyFromLocal = true;
			}
			if (lineCurr[0])
			{
				_STR_strcpy (prevCurr, lineCurr);
			}
		}
	}

	if (!getOnlyFromLocal)
	{
		for (rec = 0; rec < numOfRecs; rec++)
		{
			dagJDT1->GetColStr (lineCurr, JDT1_FC_CURRENCY, rec);	
			_STR_LRTrim (lineCurr);
			if (lineCurr[0])
			{
				dagJDT1->GetColMoney (&tmpMoney, JDT1_FC_CREDIT, rec, DBM_NOT_ARRAY);
				if (tmpMoney.IsZero())
				{
					dagJDT1->GetColMoney (&tmpMoney, JDT1_FC_DEBIT, rec, DBM_NOT_ARRAY);
					if (tmpMoney.IsZero())
					{
						getOnlyFromLocal = true;
						break;
					}
				}
			}
		}
	}

	if (GetDataSource () == *VAL_OBSERVER_SOURCE)
	{
		for (rec = 0; rec < numOfRecs; rec++)
		{
			if (!dagJDT1->IsNullCol (JDT1_SYS_CREDIT, rec) || !dagJDT1->IsNullCol (JDT1_SYS_DEBIT, rec))
			{
				if (bizEnv.IsBlockSystemCurrency())
				{
					SetErrorLine(rec + 1);
					SetErrorField(JDT1_SYS_CREDIT);
					SetArrNum(ao_Arr1);
					Message (JTE_JDT_FORM_NUM, JTE_EDIT_SYSTEM_ERROR_STR, NULL, OO_ERROR);
					return (ooInvalidObject);
				}
				forceBalance = false;
			}
		}		
	}

	if (forceBalance)
	{
		for (rec = 0; rec < numOfRecs; rec++)
		{
			dagJDT1->GetColMoney (&tmpMoney, JDT1_CREDIT, rec, DBM_NOT_ARRAY);
			MONEY_Add (&credit, &tmpMoney);
			dagJDT1->GetColMoney (&tmpMoney, JDT1_DEBIT, rec, DBM_NOT_ARRAY);
			MONEY_Add (&debit, &tmpMoney);
		}
		if (MONEY_Cmp (&credit, &debit))
		{
			forceBalance = false;
		}
	}

	for (rec = 0; rec < numOfRecs; rec++)
	{
		sideOfDebit = true;

		_STR_strcpy (currStr, mainCurr);
		tmpMoney.SetToZero();
		systMoney.SetToZero();

		if (!getOnlyFromLocal)
		{
			frgCurr = false;

			dagJDT1->GetColStr (lineCurr, JDT1_FC_CURRENCY, rec);	
			_STR_LRTrim (lineCurr);
			if (GNCoinCmp (mainCurr, lineCurr) && lineCurr[0])
			{
				frgCurr = true;
			}
			else
			{
				_STR_strcpy (lineCurr, mainCurr);
			}
			
			if (frgCurr)
			{
				_STR_strcpy (currStr, lineCurr);
			}
			else
			{
				_STR_strcpy (lineCurr, mainCurr);
			}
		}

		dagJDT1->GetColMoney (&tmpMoney, (frgCurr) ? JDT1_FC_DEBIT:JDT1_DEBIT, rec, DBM_NOT_ARRAY);
		if (tmpMoney.IsZero())
		{
			sideOfDebit = false;
			dagJDT1->GetColMoney (&tmpMoney, (frgCurr) ? JDT1_FC_CREDIT:JDT1_CREDIT, rec, DBM_NOT_ARRAY);
		}

		if (tmpMoney.IsZero() )
		{
			continue;
		}

		if (!forceBalance && !dagJDT1->IsNullCol (sideOfDebit ? JDT1_SYS_DEBIT : JDT1_SYS_CREDIT, rec))
		{
			dagJDT1->GetColMoney (&opMoney, sideOfDebit ? JDT1_SYS_CREDIT : JDT1_SYS_DEBIT, rec, DBM_NOT_ARRAY);
			if (!opMoney.IsZero() )
			{
				SetErrorLine(rec + 1);
				SetErrorField(JDT1_SYS_CREDIT);
				SetArrNum(ao_Arr1);
				Message (GO_OBJ_ERROR_MSGS(JDT), JDT_BOTH_SIDE_ERROR, NULL, OO_ERROR);
				return (ooInvalidObject);
			}
			if (GetDataSource () == *VAL_OBSERVER_SOURCE)
			{
				continue;
			}
		}

		if ((!GNCoinCmp (lineCurr, systCurr) && !getOnlyFromLocal) || notTranslateToSys)
		{
			systMoney = tmpMoney;
		}
		else
		{
			ooErr = GNTranslateToSysAmmount (&tmpMoney, currStr, refDate, &systMoney,GetEnv());
			if(ooErr || systMoney.IsZero())
			{
				if (IsExCommand(ooExAutoMode)) 
				{ 
					if (ooErr == ooUndefinedCurrency)
					{
						Message (ERROR_MESSAGES_STR, OO_UNDEFINED_CURRENCY, NULL, OO_ERROR);
					}
					else
					{
						Message (ERROR_MESSAGES_STR, OO_RATE_MISSING, NULL, OO_ERROR);
					}
				}
				return ooErr;
			}
		}

		MONEY_Round (&systMoney, RC_SUM, systCurr, bizEnv);
   	
		if (sideOfDebit)
		{
			MONEY_Add (&systDebTotal, &systMoney);
			MONEY_Add (&debFTotal, &tmpMoney);
		}
		else
		{
			MONEY_Add (&systCredTotal, &systMoney);
			MONEY_Add (&credFTotal, &tmpMoney);
		}

		if (sideOfDebit && !systMoney.IsZero())
		{
			dagJDT1->SetColMoney (&systMoney, JDT1_SYS_DEBIT, rec, DBM_NOT_ARRAY);
		}
		else if (!sideOfDebit && !systMoney.IsZero())
		{
			dagJDT1->SetColMoney (&systMoney, JDT1_SYS_CREDIT, rec, DBM_NOT_ARRAY);
		}
		if (frgCurr && !hasOneFrgCurr)
		{
			hasOneFrgCurr = true;
		}
	}

	if (!forceBalance)
	{
		return ooNoErr;
	}
	
	dagJDT->GetColMoney (&tmpMoney, (frgCurr) ? OJDT_FC_TOTAL:OJDT_LOC_TOTAL, 0, DBM_NOT_ARRAY);
	ooErr = GNTranslateToSysAmmount (&tmpMoney, currStr, refDate, &systMoney, bizEnv);

	if (!ooErr )
	{
		MONEY_Round (&systMoney, RC_SUM, systCurr, bizEnv);
		dagJDT->SetColMoney (&systMoney, OJDT_SYS_TOTAL, 0, DBM_NOT_ARRAY);

		MONEY_Add (&tmpMoney, &debFTotal);
		MONEY_Sub (&tmpMoney, &credFTotal);

		MONEY_Sub (&systDebTotal, &systCredTotal);
		tmpMoney.SetToZero();
		if (!systDebTotal.IsZero() )
		{	
			rec--;
			if (systDebTotal.IsPositive())
			{
				if(sideOfDebit)
				{
					dagJDT1->GetColMoney (&tmpMoney, JDT1_SYS_DEBIT, rec, DBM_NOT_ARRAY);
					MONEY_Sub (&tmpMoney, &systDebTotal);
					dagJDT1->SetColMoney (&tmpMoney, JDT1_SYS_DEBIT, rec, DBM_NOT_ARRAY);
				}
				else
				{
					dagJDT1->GetColMoney (&tmpMoney, JDT1_SYS_CREDIT, rec, DBM_NOT_ARRAY);
					MONEY_Add (&tmpMoney, &systDebTotal);
  					dagJDT1->SetColMoney (&tmpMoney, JDT1_SYS_CREDIT, rec, DBM_NOT_ARRAY);
				}
			}
			else
			{
				if(sideOfDebit)
				{
					dagJDT1->GetColMoney (&tmpMoney, JDT1_SYS_DEBIT, rec, DBM_NOT_ARRAY);
					MONEY_Sub (&tmpMoney, &systDebTotal);
					dagJDT1->SetColMoney (&tmpMoney, JDT1_SYS_DEBIT, rec, DBM_NOT_ARRAY);
				}
				else
				{
					dagJDT1->GetColMoney (&tmpMoney, JDT1_SYS_CREDIT, rec, DBM_NOT_ARRAY);
					MONEY_Add (&tmpMoney, &systDebTotal);
  					dagJDT1->SetColMoney (&tmpMoney, JDT1_SYS_CREDIT, rec, DBM_NOT_ARRAY);
				}
			}
		}
	}

	return ooNoErr;
}

/*************************************************************************************************************/
/*************************************************************************************************************/
SBOErr	CTransactionJournalObject::CompleteForeignAmount ()
{
	_TRACER("CompleteForeignAmount");
	SBOErr		ooErr = ooNoErr;
	PDAG		dagJDT, dagJDT1;
	PDAG		dagACT, dagCRD;
	long		rec, numOfRecs;
	TCHAR		tmpStr[256];
	Currency	lineCurr, prevCurr = {0};
	bool		found = false;
	MONEY		tmpMoney, frnAmnt, money;
	MONEY		debit, credit, delta;

	Date		refDate;
	Currency	mainCurr;
	CBizEnv		&bizEnv = GetEnv ();

	dagJDT = GetDAG();
	dagJDT1 = GetDAG(JDT, ao_Arr1);
	dagACT = GetDAG (ACT);
	dagCRD = GetDAG(CRD);

	ooErr = CalculationFrnAmmounts (dagACT, dagCRD, found);

	switch (ooErr)
	{
	case ooUndefinedCurrency:
		Message (ERROR_MESSAGES_STR, OO_UNDEFINED_CURRENCY, NULL, OO_ERROR);
		break;

	case ooNoRateErr:
		Message (ERROR_MESSAGES_STR, OO_RATE_MISSING, NULL, OO_ERROR);
		break;

	case ooInvalidCardCode:
		Message (OBJ_MGR_ERROR_MSG, GO_CRD_NAME_MISSING, NULL, OO_ERROR);
		break;
	}

	if (ooErr)
	{
		return ooErr;
	}

	_STR_strcpy (mainCurr, bizEnv.GetMainCurrency ());
	dagJDT->GetColStr(refDate, OJDT_REF_DATE, 0);

	DAG_GetCount (dagJDT1, &numOfRecs);

	if (!found)
	{
		return ooNoErr;
	}

	// Enforce balance in FC

	for (rec = 0; rec < numOfRecs; rec++)
	{
		dagJDT1->GetColStr (lineCurr, JDT1_FC_CURRENCY, rec);
		_STR_LRTrim (lineCurr);
		if (lineCurr[0] && prevCurr[0] && GNCoinCmp (prevCurr, lineCurr))
		{
			return ooNoErr;
		}
		if (lineCurr[0])
		{
			_STR_strcpy (prevCurr, lineCurr);
		}
	}

	debit.SetToZero();
	credit.SetToZero();
	for (rec=0; rec<numOfRecs; rec++)
	{
		dagJDT1->GetColMoney (&money, JDT1_DEBIT, rec, DBM_NOT_ARRAY);
		MONEY_Add(&debit, &money);
		dagJDT1->GetColMoney (&money, JDT1_CREDIT, rec, DBM_NOT_ARRAY);
		MONEY_Add(&credit, &money);
	}
	if (MONEY_Cmp (&debit, &credit) == 0)
	{
		debit.SetToZero();
		credit.SetToZero();
		for (rec=0; rec<numOfRecs; rec++)
		{
			dagJDT1->GetColMoney (&money, JDT1_FC_DEBIT, rec, DBM_NOT_ARRAY);
			MONEY_Add(&debit, &money);
			dagJDT1->GetColMoney (&money, JDT1_FC_CREDIT, rec, DBM_NOT_ARRAY);
			MONEY_Add(&credit, &money);
		}
		if (MONEY_Cmp (&debit, &credit))
		{
			MONEY_Sub (&debit, &credit);
			MONEY_FromLong (0.02 * MONEY_PERCISION_MUL, &delta);
			if (debit.IsNegative())
			{
				MONEY_Multiply (&delta, -1, &delta);
				if (debit < delta)
				{
					return ooNoErr;
				}
			}
			else
			{
				if (debit > delta)
				{
					return ooNoErr;
				}
			}

			dagJDT1->GetColStr (tmpStr, JDT1_DEBIT_CREDIT, rec);
			if (tmpStr[0] == VAL_DEBIT[0])
			{
				dagJDT1->GetColMoney (&money, JDT1_FC_DEBIT, numOfRecs-1, DBM_NOT_ARRAY);
				if (!money.IsZero())
				{
					MONEY_Sub (&money, &debit);
					dagJDT1->SetColMoney (&money, JDT1_FC_DEBIT, numOfRecs-1, DBM_NOT_ARRAY);
				}
			}
			else
			{
				dagJDT1->GetColMoney (&money, JDT1_FC_CREDIT, numOfRecs-1, DBM_NOT_ARRAY);
				if (!money.IsZero())
				{
					MONEY_Add (&money, &debit);
					dagJDT1->SetColMoney (&money, JDT1_FC_CREDIT, numOfRecs-1, DBM_NOT_ARRAY);
				}
			}
		}
	}

	return ooNoErr;
}

/*************************************************************************************************************/
/************************************************************************************/
SBOErr	CTransactionJournalObject::UpdateAccumulators (CBusinessObject *bizObject,long rec, Boolean isCard)
{
        _TRACER("UpdateAccumulators");
	SBOErr			ooErr = noErr;
	PDAG			dagBGT=NULL, dagBGT1=NULL;
	long			blockLevel=0, typeBlockLevel=0, transType;

	TCHAR			formatStr[256]={0};
	TCHAR			transTypeStr[JDT1_TRANS_TYPE_LEN+1]={0};
	TCHAR			bgtStr[OACT_BUDGET_LEN+1]={0};
	TCHAR			acctCode[OACT_ACCOUNT_CODE_LEN+1]={0};
	TCHAR			finYear[OBGT_FINANCIAL_YEAR_LEN+1]={0};
	TCHAR			tmpStr[256]={0}; 

	Boolean			bgtDebitSize = FALSE;
	Boolean			jdtDebitSize= FALSE;
	Boolean			localDags;
	Boolean			budgetAllYes =FALSE;

	MONEY			debBudgMoney, credBudgMoney;
	MONEY			debBudgSysMoney, credBudgSysMoney;
	MONEY			testMoney, testYearMoney;
	MONEY			budgMoney, tmpM, testTmpM, testYearTmpM;
	CBizEnv			&bizEnv = bizObject->GetEnv ();

	if (isCard)
	{
		return	(ooNoErr);
	}

	if (bizEnv.IsComputeBudget () == FALSE)
	{
		return	(ooNoErr);
	}

	tmpM.SetToZero();
	budgMoney.SetToZero();
	testMoney.SetToZero();
	testYearMoney.SetToZero();
	testTmpM.SetToZero();
	testYearTmpM.SetToZero();

	
	bizObject->GetDAG(ACT)->GetColStr (bgtStr, OACT_BUDGET, 0);
   	_STR_LRTrim (bgtStr);
	if (!_STR_strcmp (bgtStr, VAL_NO))
	{
		return ooNoErr;
	}

	localDags = FALSE;
	if (!DAG_IsValid (bizObject->GetDAG(BGT)))
	{
		dagBGT = bizObject->OpenDAG(BGT,ao_Main);
		_STR_strcpy (tmpStr, bizEnv.ObjectToTable (BGT, ao_Arr1));
		dagBGT1 = bizObject->OpenDAG(BGT,ao_Arr1);
		localDags = TRUE;
		_MEM_MYRPT0 (_T("BGT Table not _STR_open"));
	}
	else
	{
		dagBGT	= bizObject->GetDAG(BGT);
		dagBGT1 = bizObject->GetDAG(BGT, ao_Arr1);
	}

	//Get budget record from the respond tables (both year and month records)
	bizObject->GetDAG(ACT)->GetColStr (acctCode, OACT_ACCOUNT_CODE, 0);
   	_STR_LRTrim (acctCode);
	bizObject->GetDAG(JDT, ao_Arr1)->GetColStr (tmpStr, JDT1_REF_DATE, rec);

	bizEnv.GetCompanyDateRange (finYear, NULL);
	ooErr = CBudgetGeneralObject::GetBudgetRecords (dagBGT, dagBGT1, NULL, NULL, acctCode, finYear, -1, tmpStr, TRUE, true);
	if(ooErr)
	{
		if (localDags)
		{
			dagBGT->Close();
			dagBGT1->Close();
		}
		if (ooErr != dbmNoDataFound)
		{
			return ooErr;
		}
		if (ooErr == dbmNoDataFound)
		{
			return ooNoErr;
		}
	}


	//Add amount as in JDT1 line (both year and month records)
	transType		=bizObject->GetID().strtol ();
	blockLevel	   = RetBlockLevel(bizEnv);
	typeBlockLevel = RettypeBlockLevel(bizEnv, transType);

	//get Debit
	bizObject->GetDAG(JDT, ao_Arr1)->GetColMoney (&debBudgMoney , JDT1_DEBIT, rec, DBM_NOT_ARRAY);
	if (!debBudgMoney.IsZero())
	{
		jdtDebitSize = TRUE;
	}

	//get Credit
	bizObject->GetDAG(JDT, ao_Arr1)->GetColMoney (&credBudgMoney, JDT1_CREDIT, rec, DBM_NOT_ARRAY);
	//get system Debit
	bizObject->GetDAG(JDT, ao_Arr1)->GetColMoney (&debBudgSysMoney, JDT1_SYS_DEBIT, rec, DBM_NOT_ARRAY);
	// get system Credit
	bizObject->GetDAG(JDT, ao_Arr1)->GetColMoney (&credBudgSysMoney, JDT1_SYS_CREDIT, rec, DBM_NOT_ARRAY);


	if(bizObject->IsExCommand( ooDontCheckTranses )
		&& blockLevel>=JDT_WARNING_BLOCK && typeBlockLevel == JDT_TYPE_ACCOUNTING_BLOCK && 
		(OOIsSaleObject (transType) || OOIsPurchaseObject (transType)))
	{
		//dont given alert
		blockLevel = JDT_NOT_BGT_BLOCK;
	}
	//check debitSide of budget
	dagBGT->GetColMoney (&testYearMoney, OBGT_DEB_TOTAL, 0, DBM_NOT_ARRAY);
	if (!testYearMoney.IsZero())
	{
		bgtDebitSize =TRUE;
	}
	if (bizEnv.GetBudgetWarningFrequency()== VAL_MONTHLY[0])
	{
		dagBGT1->GetColMoney (&testMoney, BGT1_DEB_TOTAL, 0, DBM_NOT_ARRAY);
	}
	else
	{
		dagBGT->GetColMoney (&testMoney, OBGT_DEB_TOTAL, 0, DBM_NOT_ARRAY);
	}
	//set the blocking of budget
	if (blockLevel > JDT_NOT_BGT_BLOCK /*&& typeBlockLevel>=JDT_TYPE_ACCOUNTING_BLOCK*/ && bgtDebitSize)
	{
		if (bizEnv.GetBudgetWarningFrequency ()==  VAL_YEARLY[0])
		{
			dagBGT->GetColMoney (&budgMoney, OBGT_DEB_REAL_TOTAL, 0, DBM_NOT_ARRAY);
			MONEY_Add (&testTmpM, &budgMoney);
			dagBGT->GetColMoney (&budgMoney, OBGT_CRED_REAL_TOTAL, 0, DBM_NOT_ARRAY);
			MONEY_Sub (&testTmpM, &budgMoney);
		}
		if (bizEnv.GetBudgetWarningFrequency ()==  VAL_MONTHLY[0])
		{
			dagBGT1->GetColMoney (&budgMoney, BGT1_DEB_REAL_TOTAL, 0, DBM_NOT_ARRAY);
			MONEY_Add (&testTmpM, &budgMoney);
			dagBGT1->GetColMoney (&budgMoney, BGT1_CRED_REAL_TOTAL, 0, DBM_NOT_ARRAY);
			MONEY_Sub (&testTmpM, &budgMoney);

			dagBGT->GetColMoney (&budgMoney, OBGT_DEB_REAL_TOTAL, 0, DBM_NOT_ARRAY);
			MONEY_Add (&testYearTmpM, &budgMoney);
			dagBGT->GetColMoney (&budgMoney, OBGT_CRED_REAL_TOTAL, 0, DBM_NOT_ARRAY);
			MONEY_Sub (&testYearTmpM, &budgMoney);

		}
		if (jdtDebitSize)
		{
			MONEY_Add (&testTmpM, &debBudgMoney);
			MONEY_Add (&testYearTmpM, &debBudgMoney);
		}
		else
		{
			MONEY_Sub (&testTmpM, &credBudgMoney);
			MONEY_Sub (&testYearTmpM, &credBudgMoney);
		}
		//sum = debReal - credReal +/- debTrans/credTrans;
		//sum - debTotal;
		ooErr = SetBudgetBlock (bizObject, blockLevel, &testMoney, &testYearMoney, &testTmpM, &testYearTmpM);
		if(ooErr)
		{
			if (localDags)
			{
				dagBGT->Close();
				dagBGT1->Close();
			}
			return ooErr;
		}
	}//blocking

	//set month debit
	dagBGT1->GetColMoney (&budgMoney, BGT1_DEB_REAL_TOTAL, 0, DBM_NOT_ARRAY);
	MONEY_Add (&budgMoney, &debBudgMoney);
	dagBGT1->SetColMoney (&budgMoney, BGT1_DEB_REAL_TOTAL, 0, DBM_NOT_ARRAY);
	//set month credit
	dagBGT1->GetColMoney (&budgMoney, BGT1_CRED_REAL_TOTAL, 0, DBM_NOT_ARRAY);
	MONEY_Add (&budgMoney, &credBudgMoney);
	dagBGT1->SetColMoney (&budgMoney, BGT1_CRED_REAL_TOTAL, 0, DBM_NOT_ARRAY);

	//set month system debit
	dagBGT1->GetColMoney (&budgMoney, BGT1_DEB_REAL_SYS_TOTAL, 0, DBM_NOT_ARRAY);
	MONEY_Add (&budgMoney, &debBudgSysMoney);
	dagBGT1->SetColMoney (&budgMoney, BGT1_DEB_REAL_SYS_TOTAL, 0, DBM_NOT_ARRAY);

	//set month system credit
	dagBGT1->GetColMoney (&budgMoney, BGT1_CRED_REAL_SYS_TOTAL, 0, DBM_NOT_ARRAY);
	MONEY_Add (&budgMoney, &credBudgSysMoney);
	dagBGT1->SetColMoney (&budgMoney, BGT1_CRED_REAL_SYS_TOTAL, 0, DBM_NOT_ARRAY);
		
	//set year debit
   	dagBGT->GetColMoney (&budgMoney, OBGT_DEB_REAL_TOTAL, 0, DBM_NOT_ARRAY);
	MONEY_Add (&budgMoney, &debBudgMoney);
   	dagBGT->SetColMoney (&budgMoney, OBGT_DEB_REAL_TOTAL, 0, DBM_NOT_ARRAY);
	
	//set year credit
	dagBGT->GetColMoney (&budgMoney, OBGT_CRED_REAL_TOTAL, 0, DBM_NOT_ARRAY);
 	MONEY_Add (&budgMoney, &credBudgMoney);
	dagBGT->SetColMoney (&budgMoney, OBGT_CRED_REAL_TOTAL, 0, DBM_NOT_ARRAY);

	//set year system budget
 	dagBGT->GetColMoney (&budgMoney, OBGT_DEB_REAL_SYS_TOTAL, 0, DBM_NOT_ARRAY);
 	MONEY_Add (&budgMoney, &debBudgSysMoney);
 	dagBGT->SetColMoney (&budgMoney, OBGT_DEB_REAL_SYS_TOTAL, 0, DBM_NOT_ARRAY);

	//set year system credit
 	dagBGT->GetColMoney (&budgMoney, OBGT_CRED_REAL_SYS_TOTAL, 0, DBM_NOT_ARRAY);
 	MONEY_Add (&budgMoney, &credBudgSysMoney);
 	dagBGT->SetColMoney (&budgMoney, OBGT_CRED_REAL_SYS_TOTAL, 0, DBM_NOT_ARRAY);

	ooErr = GOUpdateProc (*bizObject, dagBGT);
	if (localDags)
	{
		dagBGT->Close();
		dagBGT1->Close();
	}

	return	(ooErr);

}//end of OJDUpdateAccumulators
/************************************************************************************/
/************************************************************************************/
SBOErr	CTransactionJournalObject::SetBudgetBlock (CBusinessObject *bizObject,
											long blockLevel, 
										    MONEY *testMoney, 
										    MONEY * testYearMoney, 
										    MONEY *testTmpM,
											MONEY *testYearTmpM,
											bool  workWithUI)
{
        _TRACER("SetBudgetBlock");
	SBOErr		ooErr =noErr;
	PDAG		dagWDD;
	Currency	monSymbol={0};
	
	TCHAR		msgStr1[256]={0}, msgStr2[256]={0};	
	TCHAR		moneyStr[256]={0}, moneyMonthStr[256]={0}, moneyYearStr[256]={0}; 
	TCHAR		*condVal;
	SBOString   strKeyTmp;	

	long		retBtn, numTemplatesApplied=0;	
	Boolean		budgetAllYes=FALSE, fromImport=FALSE, doTemlates=FALSE; 
	long		ObjType = bizObject->GetID().strtol ();
	CBizEnv		&bizEnv = bizObject->GetEnv ();	

	dagWDD = bizObject->GetDAG(WDD);
	numTemplatesApplied = dagWDD->GetRealSize(dbmDataBuffer);

	doTemlates = (Boolean) ((OOIsSaleObject (ObjType) || 
							OOIsPurchaseObject (ObjType)) &&
							bizEnv.IsWorkFlow ());

	if (blockLevel <= JDT_NOT_BGT_BLOCK)
	{
		return ooNoErr;
	}

	budgetAllYes = bizObject->IsExCommand( ooDontUpdateBudget) ;

	//the temp flag  used for ImportExportTrans
	fromImport = bizObject->IsExCommand( ooImportData);

	if (fromImport)
	{
		doTemlates  = FALSE;
	}

	_STR_strcpy (monSymbol, bizEnv.GetMainCurrency ());

	strKeyTmp = bizObject->GetKeyStr();
	strKeyTmp.Trim();
	bizObject->SetKeyStr(strKeyTmp);

	MONEY_Sub (testMoney, testTmpM);
	if (testMoney->IsPositive() || testMoney->IsZero())
	{
		return ooNoErr;
	}

	MONEY_Multiply (testMoney, -1, testMoney);
	MONEY_ToText (testMoney, moneyMonthStr, RC_SUM, monSymbol, bizEnv);   
		
	MONEY_Sub (testYearMoney, testYearTmpM);
	MONEY_Multiply (testYearMoney, -1, testYearMoney);
	MONEY_ToText (testYearMoney, moneyYearStr, RC_SUM, monSymbol, bizEnv);   

	if (doTemlates)
	{
		condVal = (bizEnv.GetBudgetWarningFrequency ()== VAL_MONTHLY[0] ? moneyMonthStr:moneyYearStr);

		//@APA CHG 2006/03/16_19:52:58 i031022 [ApprProcEnh] Merge Back: From 2005B to 2006 core
		//@		ooErr = ((CDocumentObject *) bizObject)->ODOCGetTemplatesByCond ( WDD_COND_VAL_BUDGET, condVal);
		ooErr = ((CDocumentObject *) bizObject)->ODOCGetTemplatesByCond ( WDD_COND_VAL_BUDGET, condVal, false);
		//@APA END 2006/03/16_19:52:58 i031022
		if (ooErr)
		{
			if (ooErr == ooAuthorizRequiered)
			{
				numTemplatesApplied ++;
			}
			else
			{
				return ooErr;
			}
		}
	}

	// Aim to suppress error when called from DI CheckApprovalProcedures
	// the flag may be replaced by something other than DataSource
	bool isFromDI = (bizObject->GetDataSource() == VAL_OBSERVER_SOURCE[0]);

	if (!workWithUI && !isFromDI)
	{
	
		if (bizEnv.GetBudgetWarningFrequency()== VAL_MONTHLY[0])
		{
			((CTransactionJournalObject*)bizObject)->GetBudgBlockErrorMessage (moneyMonthStr, moneyYearStr, bizObject->GetKeyStr(), MONTH_ALERT_MESSAGE, msgStr1);
		}
		else
		{
			((CTransactionJournalObject*)bizObject)->GetBudgBlockErrorMessage  (moneyYearStr, moneyMonthStr, bizObject->GetKeyStr(), YEAR_ALERT_MESSAGE, msgStr1);
		}

		// in authorizatin module - don't block, just alert
		if (numTemplatesApplied!=0 && doTemlates)
		{
			blockLevel = JDT_WARNING_BLOCK;
		}
		
		CDocumentObject *docObj = dynamic_cast<CDocumentObject *>(bizObject);
		if (blockLevel == JDT_WARNING_BLOCK &&docObj && docObj->IsRecurringInstance() &&
			nsRecurringTransaction::eConfirm != docObj->GetRecurringExecuteOption())
		{
			blockLevel = JDT_BGT_BLOCK;
		}

		switch (blockLevel)
		{
			case JDT_BGT_BLOCK:
				if (bizEnv.GetBudgetWarningFrequency ()== VAL_MONTHLY[0])
				{
					((CTransactionJournalObject*)bizObject)->GetBudgBlockErrorMessage (moneyMonthStr, moneyYearStr, bizObject->GetKeyStr(), BLOCK_ONE_MESSAGE, msgStr1);
					_STR_strcat (msgStr1, _T(" , "));
					_STR_strcat (msgStr1,EMPTY_STR );
					bizObject->Message (-1, -1, msgStr1, OO_ERROR);
				}
				else
				{
						SBOString	strKey;
						TCHAR		accountFormat[256];
						strKey = bizObject->GetKeyStr();
						strKey.Trim();
						_STR_strcpy(accountFormat, strKey.GetBuffer());
						bizEnv.GetAccountSegmentsByCode (accountFormat, accountFormat, TRUE);
						CMessagesManager::GetHandle()->Message(
														_1_APP_MSG_FIN_BGT0_CHECK_YEAR_TOTAL_STR1, 
														EMPTY_STR, 
														&bizEnv,
														accountFormat, 
														moneyYearStr);
				}

				return ooInvalidObject;
			break;

			case JDT_WARNING_BLOCK:
				////the Message not to bee bring for ImportExportTrans
				if (fromImport)
				{
					_STR_strcat (msgStr1, _T(" , "));
					_STR_strcat (msgStr1, EMPTY_STR);
					bizObject->Message (-1, -1, msgStr1, OO_ERROR);
				}

				if (budgetAllYes == FALSE)
				{
#ifndef	MNHL_SERVER_MODE
					TCHAR	ContinueStr[50];

					_STR_GetStringResource (ContinueStr, BGT0_FORM_NUM, BGT0_CONTINUE_STR);
					retBtn = FORM_GEN_Message (msgStr1, ContinueStr, CANCEL_STR(*OOGetEnv(NULL)), YES_TO_ALL_STR(*OOGetEnv(NULL)), 2);
#else
					retBtn = 2;
#endif
					switch (retBtn)
					{
						case 1://formOKReturn
						case 3://formOKReturn
							budgetAllYes = (retBtn == 3 ? TRUE:FALSE);
							if (budgetAllYes)
							{
								bizObject->SetExCommand ( ooDontUpdateBudget, fa_Set );
							}

							if (bizObject->GetEnv ().GetPermission (PRM_ID_BUDGET_BLOCK) != OO_PRM_FULL)
							{
								OODisplayError (bizObject, fuNoPermission);
								return ooErrNoMsg;//fuNoPermission;
							}
							return ooNoErr;
						break;

						case 2:
							return ooErrNoMsg;
						break;

					}
				}
			break;
		}//switch of levelBlock

	}

	return ooNoErr;
}//OJDSetBudgetBlock

/************************************************************************************/
/************************************************************************************/
SBOErr	CTransactionJournalObject::GetBudgBlockErrorMessage (TCHAR *MonthmoneyStr, TCHAR *YearmoneyStr, const SBOString& acctKey, long messgNumber, TCHAR*retMsgErr)
{
        _TRACER("GetBudgBlockErrorMessage");
	Boolean		yearWarning = FALSE;

	TCHAR		MformatStr[512]={0};
	TCHAR		YformatStr[512]={0};
	TCHAR		tmpStr[256]={0};
	TCHAR		accountFormat[256];

	SBOString	strKey;

	Currency	monSymbol={0};
	MONEY		tmpMoney;
	CBizEnv		&bizEnv = GetEnv ();

	strKey = acctKey;
	strKey.Trim();
	_STR_strcpy(accountFormat, strKey.GetBuffer());
	bizEnv.GetAccountSegmentsByCode (accountFormat, accountFormat, TRUE);

	_STR_strcpy (retMsgErr, _T(""));

	if (bizEnv.GetBudgetWarningFrequency ()== VAL_MONTHLY[0])
	{
		_STR_GetStringResource (MformatStr, BGT0_FORM_NUM, BGT0_CHECK_MONTH_TOTAL_STR, &GetEnv());
		MONEY_FromText (&tmpMoney, YearmoneyStr, RC_SUM, monSymbol, bizEnv);
		if (tmpMoney.IsPositive())
		{			
			_STR_GetStringResource (YformatStr, BGT0_FORM_NUM, BGT0_CHECK_YEAR_TOTAL_STR, &GetEnv());
		}
		else
		{	 
			MONEY_Multiply (&tmpMoney, -1L, &tmpMoney);
			MONEY_ToText (&tmpMoney, YearmoneyStr, RC_SUM, monSymbol, bizEnv);
			_STR_GetStringResource (YformatStr, BGT0_FORM_NUM, BGT0_BLNS_YEAR_TOTAL_STR, &GetEnv());
		}
	}

	else //VAL_YEARLY = Annual
	{
		yearWarning = TRUE;
		_STR_GetStringResource (YformatStr, BGT0_FORM_NUM, BGT0_CHECK_YEAR_TOTAL_STR, &GetEnv());
	}

	if (messgNumber == MONTH_ALERT_MESSAGE)//this for month message
	{	
		_STR_strcat (MformatStr, _T("\n"));
		_STR_strcat (MformatStr, YformatStr);
		_STR_sprintf (retMsgErr, MformatStr, accountFormat, MonthmoneyStr, accountFormat, YearmoneyStr);
	}

	if (messgNumber == YEAR_ALERT_MESSAGE)//the for month message
	{
		_STR_sprintf (retMsgErr, YformatStr, accountFormat, YearmoneyStr);	
	}

	if (messgNumber == BLOCK_ONE_MESSAGE)//the for month message
	{
		if (yearWarning)
		{
			_STR_sprintf (retMsgErr,  YformatStr, accountFormat, YearmoneyStr);
		}
		else
		{
			_STR_sprintf (retMsgErr, MformatStr, accountFormat, MonthmoneyStr);
		}
	}	
	return ooNoErr;
}


/*************************************************************************************************************/
//S
/*************************************************************************************************************/
SBOErr	CTransactionJournalObject::DocBudgetRestriction (CBusinessObject *bizObject, const TCHAR *acctCode, MONEY *Sum, 
								 TCHAR *refDate, Boolean *budgetAllYes, bool isWorkWithUI)
{
        _TRACER("DocBudgetRestriction");
	SBOErr			ooErr = ooNoErr;
	PDAG			dagBGT, dagBGT1;

	long			acctNum=0, objType = bizObject->GetID().strtol ();
	long			blockLevel=0, typeBlockLevel;
	long			openInvField, openInvSysField;
	long			openInvYearField,openInvYearSysField;

	TCHAR			tmpStr[256]={0};
	TCHAR			bgtStr[OACT_BUDGET_LEN+1]={0};
	TCHAR			finYear[OBGT_FINANCIAL_YEAR_LEN+1]={0};

	Boolean			bgtDebitSide = FALSE;

	MONEY			budgMoney, testTmpM, testYearTmpM;
	MONEY			testMoney, testYearMoney;
	MONEY			openInvMoney, openInvYearMoney;
	MONEY			currentMoney;
	CBizEnv			&bizEnv = bizObject->GetEnv();

	if (bizEnv.IsComputeBudget () == FALSE) 
	{
		bizObject->SetExCommand ( ooDontUpdateBudget, fa_Set );
		return	(ooNoErr);
	}

	blockLevel = RetBlockLevel(bizEnv);
	CDocumentObject *pDocObject = dynamic_cast<CDocumentObject *>(bizObject);
	bool bIsCancelDoc = pDocObject && pDocObject->IsCancelDoc();
	if(objType == QUT || ((objType == RPC  || objType == RPD) && !bIsCancelDoc) || ((objType == PDN || objType == PCH)&& bIsCancelDoc))
	{
			return ooNoErr;
	}

	// If adding doc with negative line total we don't need to give a budget warning 
	// or a block since the budget are reduced.
	if (Sum->IsNegative())
	{
		return ooNoErr;
	}

	typeBlockLevel = RettypeBlockLevel(bizEnv, objType);

    //Task id:10928
    if (blockLevel>=JDT_BGT_BLOCK && typeBlockLevel == JDT_TYPE_ACCOUNTING_BLOCK && objType == RDR)
    {
        //dont given alert
        blockLevel = JDT_NOT_BGT_BLOCK;
    }

	if(blockLevel <= JDT_NOT_BGT_BLOCK || typeBlockLevel<=JDT_NOT_TYPE_DOCS_BLOCK)
	{
		bizObject->SetExCommand ( ooDontUpdateBudget, fa_Set ); //budgYeaAll
		return ooNoErr;
	}

	budgMoney.SetToZero();
	testTmpM.SetToZero();
	testMoney.SetToZero();
	testYearMoney.SetToZero();
	openInvMoney.SetToZero();
	openInvYearMoney.SetToZero();
	testYearTmpM.SetToZero();
	currentMoney.SetToZero();

	ooErr = ooNoErr;

	dagBGT	= bizObject->GetDAG ( BGT );
	dagBGT1 = bizObject->GetDAG ( BGT, ao_Arr1 );


	//get the all budget
	bizEnv.GetCompanyDateRange (finYear, NULL);
	ooErr = CBudgetGeneralObject::GetBudgetRecords (dagBGT, dagBGT1, NULL, NULL, (TCHAR*)acctCode, finYear, -1, refDate, TRUE);
	if (ooErr && ooErr != dbmNoDataFound)
	{
		return ooErr;
	}

	if (ooErr == dbmNoDataFound)
	{
		return ooNoErr;
	}

	dagBGT->GetColMoney (&testYearMoney, OBGT_DEB_TOTAL, 0, DBM_NOT_ARRAY);
	if (!testYearMoney.IsZero())
	{
		bgtDebitSide = TRUE;
	}

	if (!bgtDebitSide)
	{
		return ooNoErr;
	}

	openInvField = openInvSysField = -1;
	openInvYearField =openInvYearSysField =-1;
	switch (objType)
	{
		case POR:
		case PDN:
		case RPD:
		case RPC:
		case PRQ:
			openInvYearField	= OBGT_FUTR_OUT_D_R_SUM;	
			openInvYearSysField = OBGT_FUTR_OUT_D_R_SYS_SUM;	
			//the debit budget  side
			if (bizEnv.GetBudgetWarningFrequency()==  VAL_YEARLY[0])
			{
				openInvField	= OBGT_FUTR_OUT_D_R_SUM;	
				openInvSysField = OBGT_FUTR_OUT_D_R_SYS_SUM;	
			}
			else
			{
				openInvField	= BGT1_FUTR_OUT_D_R_SUM;	
				openInvSysField = BGT1_FUTR_OUT_D_R_SYS_SUM;	
			}
		break;
	}

	dagBGT->GetColMoney (&testMoney, OBGT_DEB_TOTAL, 0, DBM_NOT_ARRAY);
	if (bizEnv.GetBudgetWarningFrequency ()== VAL_MONTHLY[0])
	{
		dagBGT1->GetColMoney (&testMoney, BGT1_DEB_TOTAL, 0, DBM_NOT_ARRAY);
	}

	if (bizEnv.GetBudgetWarningFrequency ()==  VAL_YEARLY[0])
	{
		dagBGT->GetColMoney (&budgMoney, OBGT_DEB_REAL_TOTAL, 0, DBM_NOT_ARRAY);
		MONEY_Add (&testTmpM, &budgMoney);
		dagBGT->GetColMoney (&budgMoney, OBGT_CRED_REAL_TOTAL, 0, DBM_NOT_ARRAY);
		MONEY_Sub (&testTmpM, &budgMoney);
		testYearTmpM = testTmpM;
	}

	if (bizEnv.GetBudgetWarningFrequency ()==  VAL_MONTHLY[0])
	{
		dagBGT1->GetColMoney (&budgMoney, BGT1_DEB_REAL_TOTAL, 0, DBM_NOT_ARRAY);
		MONEY_Add (&testTmpM, &budgMoney);
		dagBGT1->GetColMoney (&budgMoney, BGT1_CRED_REAL_TOTAL, 0, DBM_NOT_ARRAY);
		MONEY_Sub (&testTmpM, &budgMoney);

		dagBGT->GetColMoney (&budgMoney, OBGT_DEB_REAL_TOTAL, 0, DBM_NOT_ARRAY);
		MONEY_Add (&testYearTmpM, &budgMoney);
		dagBGT->GetColMoney (&budgMoney, OBGT_CRED_REAL_TOTAL, 0, DBM_NOT_ARRAY);
		MONEY_Sub (&testYearTmpM, &budgMoney);
	}

	if (openInvField>0)
	{
		if (bizEnv.GetBudgetWarningFrequency ()==  VAL_YEARLY[0])
		{
			dagBGT->GetColMoney (&openInvMoney, openInvField, 0, DBM_NOT_ARRAY);
		}
		else
		{
			dagBGT1->GetColMoney (&openInvMoney, openInvField, 0, DBM_NOT_ARRAY);
		}
		dagBGT->GetColMoney (&openInvYearMoney, openInvYearField, 0, DBM_NOT_ARRAY);
	}

	MONEY_Add (&testTmpM, Sum);
	MONEY_Add (&testTmpM, &openInvMoney);

	MONEY_Add (&testYearTmpM, Sum);
	MONEY_Add (&testYearTmpM, &openInvYearMoney);

	//on update mode , substract the current sum in DB
	DocBudgetCurrentSum( bizObject, &currentMoney , acctCode);
	MONEY_Sub ( &testTmpM, &currentMoney);
	testYearTmpM -= currentMoney;

	//sum = debReal - credReal +/- debTrans/credTrans;
	//sum - debTotal;
	_STR_strcpy (tmpStr, bizObject->GetKeyStr ());
	bizObject->SetKeyStr(acctCode);

	ooErr = SetBudgetBlock (bizObject,blockLevel, &testMoney, &testYearMoney, &testTmpM, &testYearTmpM, isWorkWithUI);
	
	bizObject->SetKeyStr ( tmpStr );
	
	return ooErr;
}//OJDDocBudgetRestriction


/*************************************************************************************************************/
//UpdateDocBudget	- update the field of Open Inv's
/*************************************************************************************************************/
SBOErr	CTransactionJournalObject::UpdateDocBudget(CBusinessObject *bizObject, AcctGroupRecordBudgetPtr updateBgtPtr, CPDAG dagDOC1, long rec)
{
        _TRACER("UpdateDocBudget");
	SBOErr			ooErr = ooNoErr;
	PDAG			dagBGT =NULL, dagBGT1=NULL;
	PDAG			dagAct = NULL;

	TCHAR			tmpStr[256]={0};
	TCHAR			finYear[OBGT_FINANCIAL_YEAR_LEN+1]={0};

	Boolean			localDags = FALSE;
	Boolean			bgtDebitSide = FALSE, subMoneyOper = FALSE;

	long			openInvField, openInvSysField;
	long			openInvFieldArr, openInvSysFieldArr;
	long			acctNum=0;

	MONEY			budgMoney;
	MONEY			tmpM, tmpSysM;
	CBizEnv			&bizEnv = bizObject->GetEnv ();

	if (!DAG::IsValid (dagDOC1))
	{
		return dbmBadDAG;
	}

	if (bizEnv.IsComputeBudget () == FALSE )
	{
		return	(ooNoErr);
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

	if ((bizEnv.IsContInventory () ||
		(bizEnv.IsCurrentLocalSettings (ITALY_SETTINGS) && bizEnv.IsPurchaseAccounting ()))
		&& (updateBgtPtr->objType == PDN || updateBgtPtr->objType == RPD))
	{
		SBOString itemCode;
		bool result;
		dagDOC1->GetColStr (itemCode, INV1_ITEM_CODE, rec);
		ooErr = CItemMasterData::IsInventoryItemEx (bizEnv,
			bizObject->GetDAGNoOpen (SBOString (ITM)),
			itemCode, result);
		if (ooErr)
		{
			if (ooErr == dbmNoDataFound)
			{
				// if given item code is not in DB then leave the flow as it was
				ooErr = ooNoErr;
			}
			else
			{
				// if some critical error occurred, return it
				return ooErr;
			}
		}
		else
		{
			if (result == true)
			{
				// In this case were JDT postings to inventory account already
				// done. Do not count them to future budget
				return ooNoErr;
			}
		}
	}

	DagWrapper dagActWrp = bizEnv.GetDagPool().Get(make_pair(ACT, ao_Main));
	dagAct = dagActWrp.GetPtr();
	dagBGT	= bizObject->GetDAG(BGT);
	dagBGT1 = bizObject->GetDAG(BGT, ao_Arr1);

	for (acctNum=0; acctNum<updateBgtPtr->numOfAcct; acctNum++)
	{
   		_STR_LRTrim (updateBgtPtr->acctBgtRecords[acctNum].acctCode);		
		if (_STR_IsSpacesStr (updateBgtPtr->acctBgtRecords[acctNum].acctCode))  
		{
			continue;
		}
		
		if (!updateBgtPtr->acctBgtRecords[acctNum].acctCode[0] && updateBgtPtr->objType == RDR)
		{
			continue;
		}
		
		ooErr = bizEnv.GetByOneKey (dagAct, 1, updateBgtPtr->acctBgtRecords[acctNum].acctCode);
		if (ooErr)
		{
			if (ooErr != dbmNoDataFound)
			{
				return ooErr;
			}

			ooErr =ooNoErr;
			continue;	
		}

		dagAct->GetColStr (tmpStr, OACT_BUDGET, 0);
   		_STR_LRTrim (tmpStr);
		if (tmpStr[0] == VAL_NO[0])
		{
			continue;
		}

		//Get budget record from the respond tables (both year and month records)
		SBOString docDate;
		dagDOC1->GetColStr (docDate, INV1_DATE, rec);
		bizEnv.GetCompanyDateRangeByDate (docDate, finYear, NULL);
		ooErr = CBudgetGeneralObject::GetBudgetRecords (dagBGT, dagBGT1, NULL, NULL,
										updateBgtPtr->acctBgtRecords[acctNum].acctCode, finYear, -1,
										updateBgtPtr->acctBgtRecords[acctNum].date, TRUE, true);
		
		if (ooErr && ooErr != dbmNoDataFound)
		{
			return ooErr;
		}
		if (ooErr == dbmNoDataFound)
		{
			ooErr =ooNoErr;
			continue;
		}

		dagBGT->GetColMoney (&tmpM, OBGT_DEB_TOTAL, 0, DBM_NOT_ARRAY);
		if (!tmpM.IsZero())
		{
			bgtDebitSide = TRUE;
		}

		switch (updateBgtPtr->objType)
		{
			case POR:
			case PDN:
			case RPD:
			case PRQ:
		//the debit budget  side
				openInvField		= OBGT_FUTR_OUT_D_R_SUM;	
				openInvSysField		= OBGT_FUTR_OUT_D_R_SYS_SUM;
				
				openInvFieldArr		= BGT1_FUTR_OUT_D_R_SUM;	
				openInvSysFieldArr	= BGT1_FUTR_OUT_D_R_SYS_SUM;
			break;
			
			case RDR:
			case DLN:
			case RDN:
			//the credit budget  side
			//				openInvField		= OBGT_FUTR_IN_D_R_SUM;
				openInvField		= OBGT_FUTR_IN_C_R_SUM;	
				openInvSysField		= OBGT_FUTR_IN_C_R_SYS_SUM;

				openInvFieldArr		= BGT1_FUTR_IN_C_R_SUM;	
				openInvSysFieldArr	= BGT1_FUTR_IN_C_R_SYS_SUM;
			break;
		}

		tmpM.SetToZero();
		tmpSysM.SetToZero();
		budgMoney.SetToZero();
		
		tmpM	= updateBgtPtr->acctBgtRecords[acctNum].sum;
		tmpSysM = updateBgtPtr->acctBgtRecords[acctNum].sysSum;
		if (subMoneyOper)
		{
			MONEY_Multiply (&tmpM, -1, &tmpM);
			MONEY_Multiply (&tmpSysM, -1, &tmpSysM);
		}
		//set month are opened Inv's
		dagBGT1->GetColMoney (&budgMoney, openInvFieldArr, 0, DBM_NOT_ARRAY);
		MONEY_Add (&budgMoney, &tmpM);
		dagBGT1->SetColMoney (&budgMoney, openInvFieldArr, 0, DBM_NOT_ARRAY);

		//set year are opened Inv's
		dagBGT->GetColMoney (&budgMoney, openInvField, 0, DBM_NOT_ARRAY);
		MONEY_Add (&budgMoney, &tmpM);
		dagBGT->SetColMoney (&budgMoney, openInvField, 0, DBM_NOT_ARRAY);

		//set month system are opened Inv's
		dagBGT1->GetColMoney (&budgMoney, openInvSysFieldArr, 0, DBM_NOT_ARRAY);
 		MONEY_Add (&budgMoney, &tmpSysM);
 		dagBGT1->SetColMoney (&budgMoney, openInvSysFieldArr, 0, DBM_NOT_ARRAY);

		//set year system are opened Inv's
		dagBGT->GetColMoney (&budgMoney, openInvSysField, 0, DBM_NOT_ARRAY);
 		MONEY_Add (&budgMoney, &tmpSysM);
 		dagBGT->SetColMoney (&budgMoney, openInvSysField, 0, DBM_NOT_ARRAY);

		ooErr = GOUpdateProc (*bizObject, dagBGT, true);
		if(ooErr)
		{
			return ooErr;
		}
	}//for of acctCode

	return	(ooErr);
}//OJDUpdateDocBudget
/*************************************************************************************************************/
/*************************************************************************************************************/
/*************************************************************************************************************/

long	CTransactionJournalObject::GetSRObjectBudgetAcc (long object)
{
        _TRACER("GetSRObjectBudgetAcc");
	switch (object)
	{
		case QUT:
		case PQT:
			return baccNone;
		break;

		case RDR:
		case DLN:
			return baccFutureIncomeInAcc;
		break;

		case RDN:
			return baccFutureIncomeOutAcc;
		break;

		case POR:
		case PDN:
			return baccFutureExpenseInAcc;
		break;

		case RPD:
			return baccFutureExpenseOutAcc;
		break;
		
		case INV:
		case CIN:
		case RPC:
		case DPI:
			return baccJdtInAcc;
		break;

		case RIN:
		case PCH:
		case DPO:
			return baccJdtOutAcc;
		break;
	}

	return -1;
}

/*************************************************************************************************************/
/*************************************************************************************************************/
void	CTransactionJournalObject::SetContraAccounts (PDAG dagJdt1, long firstRec, long maxRec, TCHAR *contraDebKey, TCHAR *contraCredKey, long contraDebLines, long contraCredLines)
{
        _TRACER("SetContraAccounts");
	TCHAR	tempStr[256];
	long	rec, numOfRecs;
	MONEY	debAmount, fDebAmount, sDebAmount;
	MONEY	credAmount, fCredAmount, sCredAmount;
	CBizEnv	&env = GetEnv ();

	DAG_GetCount (dagJdt1, &numOfRecs);
	if (maxRec > numOfRecs)
	{
		maxRec = numOfRecs;
	}

	if (VF_EnableCorrAct (env))
	{
		if (contraCredLines == 1 && contraDebLines > 1)
		{
			// Multiline
			contraDebKey[0] = _T ('\0');
		}
		else if (contraDebLines == 1 && contraCredLines > 1)
		{
			// Multiline
			contraCredKey[0] = _T ('\0');
		}
		else if (contraDebLines > 1 && contraCredLines > 1)
		{
			// Not supported situation
			contraDebKey[0] = contraCredKey[0] = _T ('\0');

			// NOTE: This is warning only
			SetErrorField(JDT1_CONTRA_ACT);
			SetErrorLine(1);	
			Message(OBJ_MGR_ERROR_MSG, GO_CONTRA_ACNT_MISSING, NULL, OO_WARNING);
		}

	}

	for (rec=firstRec; rec<maxRec; rec++)
	{
		dagJdt1->GetColStr (tempStr, JDT1_CONTRA_ACT, rec);
		_STR_LRTrim (tempStr);
		if (tempStr[0])
		{
			continue;
		}

		dagJdt1->GetColMoney (&debAmount, JDT1_DEBIT, rec, DBM_NOT_ARRAY);
		dagJdt1->GetColMoney (&credAmount, JDT1_CREDIT, rec, DBM_NOT_ARRAY);
		
		dagJdt1->GetColMoney (&fDebAmount, JDT1_FC_DEBIT, rec, DBM_NOT_ARRAY);
		dagJdt1->GetColMoney (&fCredAmount, JDT1_FC_CREDIT, rec, DBM_NOT_ARRAY);

		dagJdt1->GetColMoney (&sDebAmount, JDT1_SYS_DEBIT, rec, DBM_NOT_ARRAY);
		dagJdt1->GetColMoney (&sCredAmount, JDT1_SYS_CREDIT, rec, DBM_NOT_ARRAY);

		if (debAmount.IsPositive()  ||
			fDebAmount.IsPositive() ||
			sDebAmount.IsPositive() ||
			credAmount.IsNegative() ||
			fCredAmount.IsNegative()||
			sCredAmount.IsNegative())
		{
			dagJdt1->SetColStr (contraCredKey, JDT1_CONTRA_ACT, rec);
		}
		else if (credAmount.IsPositive() ||
				 fCredAmount.IsPositive()||
				 sCredAmount.IsPositive()||
				 debAmount.IsNegative()  ||
				 fDebAmount.IsNegative() ||
				 sDebAmount.IsNegative())
		{
			dagJdt1->SetColStr (contraDebKey, JDT1_CONTRA_ACT, rec);
		}
	}
}

/*************************************************************************************************************/
/*************************************************************************************************************/
SBOErr	CTransactionJournalObject::ValidateRelations (ArrayOffset ArrOffset, long rec, long field, long object, bool showError)
{
	_TRACER("ValidateRelations");
	DBD_CondStruct	condStruct[9];
	DBD_Tables		tableStruct[1];
	PDAG			dag  =	GetDAG(JDT,ArrOffset);
	CBizEnv			&bizEnv = GetEnv ();
	Boolean			isVat = FALSE;
	TCHAR			tmpStr[256]={0};
	SBOString		accountNum, vatGroup, shortName;
	long			condNum = 1;	

	dag->GetColStr (condStruct[0].condVal, field, rec);
	_STR_LRTrim (condStruct[0].condVal);
	condStruct[0].operation = DBD_EQ;
	if (object == VTG)
	{
		dag->GetColStr (tmpStr, JDT1_VAT_LINE, rec);
		if (tmpStr[0] == VAL_YES[0])
		{
			dag->GetColStr(accountNum, JDT1_ACCT_NUM, rec);

			if(accountNum.IsSpacesStr() )
			{
				dag->GetColStr(vatGroup, JDT1_VAT_GROUP, rec);
				_STR_LRTrim(vatGroup);

				CMessagesManager::GetHandle()->Message (_1_APP_MSG_FIN_TE_TAX_ACCOUNT_MISSING1,
					EMPTY_STR, &bizEnv, vatGroup.GetBuffer());

				return ooInvalidObject;
			}

			dag->GetColStr (shortName, JDT1_SHORT_NAME, rec);
			shortName.Trim ();

			isVat = TRUE;
			condStruct[0].relationship = DBD_AND;

			// additional conditions - condNum starts from 1
			condStruct[condNum].bracketOpen = 1;
			condStruct[condNum].colNum = OVTG_ACCOUNT;
			condStruct[condNum].condVal = shortName;
			condStruct[condNum].operation = DBD_EQ;
			condStruct[condNum++].relationship = DBD_OR;

			condStruct[condNum].colNum = OVTG_EQU_VAT_ACCOUNT;
			condStruct[condNum].condVal = shortName;
			condStruct[condNum].operation = DBD_EQ;
			condStruct[condNum++].relationship = DBD_OR;

			condStruct[condNum].colNum = OVTG_DEFERRED_ACC;
			condStruct[condNum].condVal = shortName;
			condStruct[condNum].operation = DBD_EQ;
			condStruct[condNum++].relationship = DBD_OR;

			condStruct[condNum].colNum = OVTG_ACQSITION_TAX;
			condStruct[condNum].condVal = shortName;
			condStruct[condNum].operation = DBD_EQ;
			condStruct[condNum++].relationship = DBD_OR;

			condStruct[condNum].colNum = OVTG_NON_DEDUCT_ACC;
			condStruct[condNum].condVal = shortName;
			condStruct[condNum].operation = DBD_EQ;
			condStruct[condNum++].relationship = DBD_OR;

			condStruct[condNum].bracketOpen = 1;
			condStruct[condNum].colNum = OVTG_NON_DEDUCTIBLE;
			condStruct[condNum].operation	= DBD_NE;
			_STR_strcpy (condStruct[condNum].condVal, STR_0);
			condStruct[condNum++].relationship = DBD_AND;

			condStruct[condNum].bracketOpen = 1;
			condStruct[condNum].colNum = OVTG_NON_DEDUCT_ACC;
			condStruct[condNum].operation	= DBD_EQ;
			condStruct[condNum++].relationship = DBD_OR;

			condStruct[condNum].colNum = OVTG_NON_DEDUCT_ACC;
			condStruct[condNum].operation	= DBD_IS_NULL;
			condStruct[condNum].bracketClose	= 3;
			condStruct[condNum++].relationship = 0;
		}
	}

	if (!condStruct[0].condVal.IsEmpty ())
	{
		_STR_strcpy (tableStruct[0].tableCode, bizEnv.ObjectToTable (SBOString(object), ao_Main));

		if (object == VTG && isVat)
		{
			DBD_SetDAGCond (dag, condStruct, condNum);
		}
		else
		{
			DBD_SetDAGCond (dag, condStruct, 1);
		}
		DBD_SetTablesList (dag, tableStruct, 1);
		long count = DBD_Count (dag, TRUE);

		if (count <= 0)
			{
			if (showError)
				{			
				SetErrorField( field);
				SBOString tableDesc;
				GetEnv().GetTableDescription (tableStruct[0].tableCode, tableDesc);
				CMessagesManager::GetHandle()->Message(_1_APP_MSG_FIN_ITM_RELATED_ERR_FORMAT, 
					EMPTY_STR, 
					this,
					condStruct[0].condVal.GetBuffer (), 
					tableDesc.GetBuffer ());
				}
			return ooInvalidObject;
			}
	}

	return ooNoErr;
}

/************************************************************************************/
/************************************************************************************/
SBOErr	CTransactionJournalObject::OnCanUpdate()
{
        _TRACER("OnCanUpdate");
	long		i;
	Boolean		editableInUpdate;
	Boolean		isHeader;
	const TCHAR	*fCodePtr;
	DBM_OUP*	oopp = GetOnUpdateParams ();
	PDAG		dag  = oopp->pDag;
	
	CBizEnv& bizEnv = GetEnv ();

	editableInUpdate = (Boolean)(bizEnv.GetPermission (PRM_ID_UPDATE_POSTING) == OO_PRM_FULL);
	fCodePtr = DAG_GetAlias (dag);
	isHeader = _STR_stricmp (fCodePtr, bizEnv.ObjectToTable (JDT)) == 0;
    if(VF_JEWHT(bizEnv))
    {   
        SBOString tmp = bizEnv.ObjectToTable(JDT, ao_Arr2);
        if(tmp == fCodePtr)   
        {
            return OnCanJDT2Update();
        }
    }
	if (isHeader)
	{
		for (i=0; i < oopp->colsList.GetSize(); i++)
		{
			switch (oopp->colsList[i]->GetColNum())
			{
				case OJDT_REF_DATE:
					SetErrorField( oopp->colsList[i]->GetColNum ());
					SetErrorLine( -1);
					return dbmColumnNotUpdatable;
				break;

				case OJDT_TAX_DATE:
					if (bizEnv.IsBlockTaxDateEdit ())
					{
						if (!oopp->colsList[i]->GetBackupValue().IsEmpty ())
						{
							SetErrorLine( -1);
							SetErrorField( oopp->colsList[i]->GetColNum ());
							return dbmColumnNotUpdatable;
						}
					}
				break;

				case OJDT_REF1:
				case OJDT_REF2:
				case OJDT_REF3:
				case OJDT_TRANS_CODE:
				case OJDT_INDICATOR:
				case OJDT_ADJ_TRAN:
				case OJDT_PROJECT:
				case OJDT_ORIGN_CURRENCY:
				case OJDT_TRANS_RATE:
					if (!editableInUpdate)
					{
						SetErrorLine( -1);
						SetErrorField( oopp->colsList[i]->GetColNum ());
						return dbmColumnNotUpdatable;
					}
				break;

				case OJDT_REPORT_347:
				case OJDT_REPORT_EU:
				{
					if(bizEnv.IsCurrentLocalSettings(SPAIN_SETTINGS))
					{	
						//check if the journal entry was reported in vat report
						if(oopp->colsList[i]->GetBackupValue().Compare(VAL_YES) == 0)
						{
							bool isReported;
							long objAbs;
							dag->GetColLong(&objAbs, OJDT_JDT_NUM);
							
							if(oopp->colsList[i]->GetColNum() == OJDT_REPORT_347)
							{
								CRFLObject::IsTransactionAlreadyReported(isReported, RT_347, bizEnv, JDT, objAbs);
							}
							else
							{
								CRFLObject::IsTransactionAlreadyReported(isReported ,RT_349, bizEnv, JDT, objAbs);
							}

							if(isReported)
							{
								SetErrorLine( -1);
								SetErrorField( oopp->colsList[i]->GetColNum ());
								return dbmColumnNotUpdatable;
							}
						}
					}

				}
				break;

				case OJDT_BLOCK_DUNNING_LETTER:
				{
					if (!IsBlockDunningLetterUpdateable ())
					{
						SetErrorLine (-1);
						SetErrorField (OJDT_BLOCK_DUNNING_LETTER);
						return dbmColumnNotUpdatable;
					}
				}
				break;

				case OJDT_DUE_DATE:
				{
					if (this->IsPaymentOrdered ())	
					{
						SetErrorLine (-1);
						SetErrorField (OJDT_DUE_DATE);
						return dbmColumnNotUpdatable;
					}
				}
				break;

				case OJDT_DEFERRED_TAX:
				{					
					SetErrorLine (-1);
					SetErrorField (OJDT_DUE_DATE);
					return dbmColumnNotUpdatable;					
				}
				break;
			}
		}
	}
	else
	{
		for (i=0; i<oopp->colsList.GetSize(); i++)
		{
			switch (oopp->colsList[i]->GetColNum ())
			{
				case JDT1_SHORT_NAME:
				case JDT1_REF_DATE:
				case JDT1_ACCT_NUM:
				case JDT1_FC_CURRENCY:
					SetErrorField( oopp->colsList[i]->GetColNum ());
					return dbmColumnNotUpdatable;
				break;

				case JDT1_DEBIT:
				case JDT1_CREDIT:
				case JDT1_SYS_CREDIT:
				case JDT1_SYS_DEBIT:
				case JDT1_FC_DEBIT:
				case JDT1_FC_CREDIT:
				case JDT1_VAT_AMOUNT:
				case JDT1_SYS_VAT_AMOUNT:
				case JDT1_GROSS_VALUE:
				case JDT1_GROSS_VALUE_FC:
					if (GetDataSource () == *VAL_OBSERVER_SOURCE)
					{
						SetErrorField( oopp->colsList[i]->GetColNum ());
						return dbmColumnNotUpdatable;
					}
					else
					{
						oopp->colsList[i]->SetIngnoreUpdate (TRUE);
					}
				break;

				case JDT1_TAX_DATE:
					if (bizEnv.IsBlockTaxDateEdit())
					{
						SetErrorField( oopp->colsList[i]->GetColNum ());
						return dbmColumnNotUpdatable;
					}
				break;

				case JDT1_REF1:
				case JDT1_REF2:
				case JDT1_TRANS_CODE:
				case JDT1_INDICATOR:
				case JDT1_ADJ_TRAN_PERIOD_13:
				case JDT1_PROJECT:
					if (!editableInUpdate)
					{
						SetErrorField( oopp->colsList[i]->GetColNum ());
						return dbmColumnNotUpdatable;
					}
				break;

				case JDT1_DUE_DATE:
				case JDT1_PAYMENT_BLOCK:
				case JDT1_PAYMENT_BLOCK_REF:
					{
						SBOString ordered = VAL_NO;
						dag->GetColStr (ordered, JDT1_ORDERED, oopp->recOffset);
						if (ordered == VAL_YES)
						{
							SetErrorLine (oopp->colsList[i]->GetColNum ());
							return dbmColumnNotUpdatable;
						}
					}
					break;
				case JDT1_TAX_ID_NUMBER:
					if (!editableInUpdate)
					{
						SetErrorField (JDT1_TAX_ID_NUMBER);
						return dbmColumnNotUpdatable;
					}
				break;

				case JDT1_BPL_ID:
					if (VF_MultiBranch_EnabledInOADM (bizEnv) && GetCurrentBusinessFlow() == bf_Update)
					{
						SetErrorField (JDT1_BPL_ID);
						return dbmColumnNotUpdatable;
					}
				break;
			}
		}
	}
	return ooNoErr;
}


/************************************************************************************/
/************************************************************************************/
SBOErr	CTransactionJournalObject::DocBudgetCurrentSum (	CBusinessObject *	bizObject,
													PMONEY currentMoney, const TCHAR *acctCode)
{
	// select INV1_TOTAL from inv1 where   INV1_ABS_ENTRY = bizObject.GetKeyStr () and  INV1_LINE_NUM = lineNum
        _TRACER("DocBudgetCurrentSum");
	SBOErr			sboErr	= ooNoErr;
	DBD_CondStruct	condStruct[2];
	DBD_ResStruct	resStruct[1] ;
	PDAG			dagRES , dagObj, dagDOC = bizObject->GetDAG();
	MONEY			docDiscount, tmpM, sumRow(0);
	
	dagObj = bizObject->GetDAG ( bizObject->GetID() ,ao_Arr1);
	if (!DAG::IsValid (dagObj))
	{
		return dbmBadDAG;
	}

	dagDOC->GetColMoney(&docDiscount, OINV_DISC_PERCENT);
	currentMoney->SetToZero();

	//Res
	resStruct[0].colNum = INV1_TOTAL;	 

	DBD_SetDAGRes (dagObj, resStruct, 1);

	//Conds
	condStruct[0].colNum	= INV1_ABS_ENTRY;
	condStruct[0].operation	= DBD_EQ;
	condStruct[0].condVal = bizObject->GetKeyStr ();
	condStruct[0].relationship = DBD_AND;
	
	condStruct[1].colNum	= INV1_ACCOUNT_CODE;
	condStruct[1].operation	= DBD_EQ;
	condStruct[1].condVal = acctCode;

	DBD_SetDAGCond (dagObj, condStruct, 2);

	sboErr = DBD_GetInNewFormat(dagObj, &dagRES);
	if (!sboErr )
	{
		for (long rec=0; rec<dagRES->GetRealSize(dbmDataBuffer); rec++)
		{
			// Get Row Total
			dagRES->GetColMoney(&sumRow, 0, rec);

			// Calculate Row With Discount
			if (!docDiscount.IsZero())
			{
				tmpM = sumRow * docDiscount;
				sumRow -= tmpM;
			}
			(*currentMoney) += sumRow;
		}
	}
	
	return sboErr;
}

/************************************************************************************/
/************************************************************************************/
SBOErr	CTransactionJournalObject::OnUpgrade ()
{
        _TRACER("OnUpgrade");
	SBOErr			ooErr = ooNoErr;
	PDAG			dagJDT, dagRES;
	PDAG			dagJDT1, dagBTF;
	DBD_CondStruct	condStruct[8];
	DBD_Tables		tableStruct[2];
	DBD_CondStruct	joinCondStruct[1];
	DBD_ResStruct	resStruct[4];
	DBD_UpdStruct	updStruct [3];
	long			numOfRecs, rec;
	CBizEnv			&bizEnv = GetEnv ();
	MONEY			vatPrcnt, sysM, tmpM;

	if (UpgradeVersionCheck (OJDT_UPG_DUE_DATE_VER))
	{
		ObjectUpgradeErrorLogger upgradeBlock(_T("Due Date"));
		dagJDT = OpenDAG (JDT, ao_Main);
		_STR_strcpy (tableStruct[0].tableCode, bizEnv.ObjectToTable (JDT, ao_Main));
		_STR_strcpy (tableStruct[1].tableCode, bizEnv.ObjectToTable (JDT, ao_Arr1));

		tableStruct[1].doJoin = TRUE;
		tableStruct[1].joinedToTable = 0;

		tableStruct[1].numOfConds = 1;
		tableStruct[1].joinConds = joinCondStruct;

		joinCondStruct[0].compareCols = TRUE;
		joinCondStruct[0].compTableIndex = 0;
		joinCondStruct[0].compColNum = OJDT_JDT_NUM;
		joinCondStruct[0].tableIndex = 1;
		joinCondStruct[0].colNum = JDT1_TRANS_ABS;
		joinCondStruct[0].operation = DBD_EQ;

		condStruct[0].colNum = OJDT_DUE_DATE;
		condStruct[0].operation = DBD_IS_NULL;
		condStruct[0].relationship = DBD_AND;

		condStruct[1].tableIndex = 1;
		condStruct[1].colNum = JDT1_LINE_ID;
		_STR_strcpy (condStruct[1].condVal, STR_0); 
		condStruct[1].operation = DBD_EQ;

		resStruct[0].colNum = OJDT_JDT_NUM;
		resStruct[1].tableIndex = 1;
		resStruct[1].colNum = JDT1_DUE_DATE;

		DBD_SetTablesList (dagJDT, tableStruct, 2);
		DBD_SetDAGCond (dagJDT, condStruct, 2);
		DBD_SetDAGRes (dagJDT, resStruct, 2);

		ooErr = DBD_GetInNewFormat (dagJDT, &dagRES);
		if (!ooErr)
		{
			DAG_GetCount (dagRES, &numOfRecs);
			for (rec=0; rec < numOfRecs; rec++)
			{
				updStruct[0].colNum = OJDT_DUE_DATE;
				dagRES->GetColStr(updStruct[0].updateVal, 1, rec);

				condStruct[0].colNum = OJDT_JDT_NUM;
				condStruct[0].operation = DBD_EQ;
				dagRES->GetColStr(condStruct[0].condVal, 0, rec);
				condStruct[0].relationship = 0;

				DBD_SetDAGCond (dagJDT, condStruct, 1);
				DBD_SetDAGUpd (dagJDT, updStruct, 1);
				ooErr = DBD_UpdateCols (dagJDT);
			}
		}

		DAG_Close (dagJDT);

		upgradeBlock.MarkSuccess();
	}

	if (bizEnv.IsVatPerLine () && UpgradeVersionCheck (OJDT_UPG_AUTO_VAT_VER))
	{
		ObjectUpgradeErrorLogger upgradeBlock(_T("Auto VAT"));
		dagJDT1 = OpenDAG (JDT, ao_Arr1);

		_MEM_Clear(condStruct, 2);
		condStruct[0].colNum = JDT1_VAT_GROUP;
		condStruct[0].operation = DBD_NOT_NULL;
		condStruct[0].relationship = DBD_AND;

		condStruct[1].colNum = JDT1_VAT_GROUP;
		condStruct[1].operation = DBD_NE;
		condStruct[1].relationship = 0;

		DBD_SetDAGCond (dagJDT1, condStruct, 2);

		updStruct[0].colNum = JDT1_VAT_LINE;
		_STR_strcpy (updStruct[0].updateVal, VAL_YES);
		
		DBD_SetDAGUpd (dagJDT1, updStruct, 1);
		ooErr = DBD_UpdateCols (dagJDT1);

		DAG_Close (dagJDT1);

		upgradeBlock.MarkSuccess();
	}

	// Fix CSN #2854173 2006:
	// In 2007 OJDT_UPG_SRC_LINE_VER was changed to point to VERSION_2007_MR (instead of VERSION_65_40)
	// since DBs were found in which JDT1_SRC_LINE wasn't changed to '1' (for some unknown reason)
	// and this caused an error in the new reconciliation feature introduced in 2007
	if (UpgradeVersionCheck (OJDT_UPG_SRC_LINE_VER))
	{
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("Source Line Version"));

		dagJDT1 = OpenDAG (JDT, ao_Arr1);
		
		_MEM_Clear(condStruct, 8);
		condStruct[0].bracketOpen = 1;
			condStruct[0].colNum = JDT1_TRANS_TYPE;
			condStruct[0].operation = DBD_EQ;
			condStruct[0].condVal = INV;
			condStruct[0].relationship = DBD_OR;

			condStruct[1].colNum = JDT1_TRANS_TYPE;
			condStruct[1].operation = DBD_EQ;
			condStruct[1].condVal = RIN;
			condStruct[1].relationship = DBD_OR;

			condStruct[2].colNum = JDT1_TRANS_TYPE;
			condStruct[2].operation = DBD_EQ;
			condStruct[2].condVal = PCH;
			condStruct[2].relationship = DBD_OR;

			condStruct[3].colNum = JDT1_TRANS_TYPE;
			condStruct[3].operation = DBD_EQ;
			condStruct[3].condVal = RPC;
		condStruct[3].bracketClose = 1;
			
		condStruct[3].relationship = DBD_AND;

		condStruct[4].compareCols = TRUE;
		condStruct[4].colNum = JDT1_SHORT_NAME;
		condStruct[4].operation = DBD_NE;
		condStruct[4].compColNum = JDT1_ACCT_NUM;
		condStruct[4].relationship = DBD_AND;


		condStruct[5].bracketOpen = 1;
			condStruct[5].colNum = JDT1_SRC_LINE;
			condStruct[5].operation = DBD_EQ;
			_STR_strcpy (condStruct[5].condVal, EMPTY_STR);
			condStruct[5].relationship = DBD_OR;

			condStruct[6].colNum = JDT1_SRC_LINE;
			condStruct[6].operation = DBD_IS_NULL;
			condStruct[6].relationship = DBD_OR;

			condStruct[7].colNum = JDT1_SRC_LINE;
			condStruct[7].operation = DBD_EQ;
			condStruct[7].condVal = (long)0;
		condStruct[7].bracketClose = 1;

		DBD_SetDAGCond (dagJDT1, condStruct, 8);

		_MEM_Clear (updStruct, 1);
		updStruct[0].colNum = JDT1_SRC_LINE;
		updStruct[0].updateVal = (long)1;
		DBD_SetDAGUpd (dagJDT1, updStruct, 1);

		DBD_UpdateCols (dagJDT1);

		DAG_Close (dagJDT1);

		upgradeBlock.MarkSuccess();
	}

	if (UpgradeVersionCheck (OJDT_SYS_BASE_SUM_VER) && bizEnv.IsVatPerLine())
	{
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("System Base Sum Version"));

		dagJDT1 = OpenDAG (JDT, ao_Arr1);
		
		_MEM_Clear(condStruct, 3);

		condStruct[0].colNum = JDT1_BASE_SUM;
		condStruct[0].operation = DBD_NE;
		_STR_strcpy (condStruct[0].condVal, STR_0); 
		condStruct[0].relationship = DBD_AND;

		condStruct[1].colNum = JDT1_DEBIT;
		condStruct[1].operation = DBD_NE;
		_STR_strcpy (condStruct[1].condVal, STR_0); 
		condStruct[1].relationship = DBD_AND;

		condStruct[2].colNum = JDT1_SYS_DEBIT;
		condStruct[2].operation = DBD_NE;
		_STR_strcpy (condStruct[2].condVal, STR_0); 

		DBD_SetDAGCond (dagJDT1, condStruct, 3);

 		_MEM_Clear(updStruct, 1);
		updStruct[0].colNum = JDT1_SYS_BASE_SUM;
		updStruct[0].SetUpdateColSource (DBD_UpdStruct::ucs_UseRes);
		updStruct[0].GetResObject().agreg_type = DBD_ROUND;
		updStruct[0].GetResObject().colConstVal = OO_SUM_DECIMALS (GetEnv ());
		
		DBD_ResColumns* pResCol = updStruct[0].GetResObject().AddResCol ();
		pResCol->SetTableIndex (0);
		pResCol->SetColNum (JDT1_BASE_SUM);
		pResCol->SetOperation (DBD_MUL);

		pResCol = updStruct[0].GetResObject().AddResCol ();
		pResCol->OpenBracket (1);
		pResCol->SetTableIndex (0);
		pResCol->SetColNum (JDT1_SYS_DEBIT);
		pResCol->SetOperation (DBD_DIV);

		pResCol = updStruct[0].GetResObject().AddResCol ();
		pResCol->CloseBracket (1);
		pResCol->SetTableIndex (0);
		pResCol->SetColNum (JDT1_DEBIT);

		DBD_SetDAGUpd (dagJDT1, updStruct, 1);
		ooErr = DBD_UpdateCols (dagJDT1);

		condStruct[1].colNum = JDT1_CREDIT;
		condStruct[2].colNum = JDT1_SYS_CREDIT;
		DBD_SetDAGCond (dagJDT1, condStruct, 3);

		updStruct[0].GetResObject().Clear ();
		updStruct[0].GetResObject().agreg_type = DBD_ROUND;
		updStruct[0].GetResObject().colConstVal = OO_SUM_DECIMALS (GetEnv ());

		pResCol = updStruct[0].GetResObject().AddResCol ();
		pResCol->SetTableIndex (0);
		pResCol->SetColNum (JDT1_BASE_SUM);
		pResCol->SetOperation (DBD_MUL);

		pResCol = updStruct[0].GetResObject().AddResCol ();
		pResCol->OpenBracket (1);
		pResCol->SetTableIndex (0);
		pResCol->SetColNum (JDT1_SYS_CREDIT);
		pResCol->SetOperation (DBD_DIV);

		pResCol = updStruct[0].GetResObject().AddResCol ();
		pResCol->CloseBracket (1);
		pResCol->SetTableIndex (0);
		pResCol->SetColNum (JDT1_CREDIT);

		DBD_SetDAGUpd (dagJDT1, updStruct, 1);
		ooErr = DBD_UpdateCols (dagJDT1);
		_MEM_Clear(updStruct, 1);
		DAG_Close (dagJDT1);

		upgradeBlock.MarkSuccess();
	}

	if (UpgradeVersionCheck (OJDT_PAID_JDT_VER))
	{
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("Paid JDT"));

		dagJDT1 = OpenDAG (JDT, ao_Arr1);

		_MEM_Clear(condStruct, 1);

		condStruct[0].colNum = JDT1_INTR_MATCH;
		condStruct[0].operation = DBD_NE;
		condStruct[0].condVal = (long)0;
		condStruct[0].relationship = 0;

		DBD_SetDAGCond (dagJDT1, condStruct, 1);

		updStruct[0].colNum = JDT1_CLOSED;
		_STR_strcpy (updStruct[0].updateVal, VAL_YES);
		
		DBD_SetDAGUpd (dagJDT1, updStruct, 1);
		ooErr = DBD_UpdateCols (dagJDT1);

		DAG_Close (dagJDT1);

		upgradeBlock.MarkSuccess();
	}

	if (UpgradeVersionCheck (OJDT_BOE_CONTROL_ACTS_VER))
	{
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("BOE Control Account"));

		ooErr = UpgradeBoeActs();
		if (ooErr) 
		{
			return ooErr;
		}

		upgradeBlock.MarkSuccess();
	}

	MajorReleaseVersionMappingMap vmPeriodInd;
	vmPeriodInd.SetAt (b1mr_2004A, OJDT_UPG_PERIOD_IND_VER_67);
	if (UpgradeVersionCheck (OJDT_UPG_PERIOD_IND_VER, true, true, &vmPeriodInd))
	{
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("Period Indicator"));

		ooErr = UpgradePeriodIndic();
		if (ooErr) 
		{
			return ooErr;
		}

		upgradeBlock.MarkSuccess();
	}
	if (UpgradeVersionCheck (OACT_UPG_SERIAL_VER))
	{
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("Account Serial"));

		dagJDT = OpenDAG (JDT);

		if(!(bizEnv.IsLocalSettingsFlag (lsf_IsDocNumMethod)))
		{
			updStruct[0].colNum = OJDT_SERIES;
			// ************************** MultipleOpenPeriods *************************
			SBOString sysDate;
			DBM_DATE_Get (sysDate, bizEnv);
			// VF_MultiBranch_EnabledInOADM
			updStruct[0].updateVal = bizEnv.GetDefaultSeriesByDate (GetBPLId (), GetID(), sysDate);
			// ************************************************************************
				
			DBD_SetDAGUpd (dagJDT, updStruct, 1);
				
			ooErr = DBD_UpdateCols (dagJDT);
			if(ooErr)
			{
				dagJDT->Close ();
				return ooErr;
			}
			dagBTF = OpenDAG (BTF);

			DBD_SetDAGUpd (dagBTF, updStruct, 1);
			ooErr = DBD_UpdateCols (dagBTF);
			dagBTF->Close ();
			if(ooErr)
			{
				dagJDT->Close ();
				return ooErr;
			}
		}

		updStruct[0].colNum = OJDT_NUMBER;
		updStruct[0].SetUpdateColSource(DBD_UpdStruct::ucs_SrcCol);
		updStruct[0].srcColNum = OJDT_JDT_NUM;
		DBD_SetDAGUpd (dagJDT, updStruct, 1);
		ooErr = DBD_UpdateCols (dagJDT);
		if(ooErr)
		{
			dagJDT->Close ();
			return ooErr;
		}

		dagJDT->Close ();

		upgradeBlock.MarkSuccess();
	}

	if (UpgradeVersionCheck (OJDT_UPG_ZERO_TAX_VER) && bizEnv.IsVatPerLine())
	{
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("Zero Tax"));

		dagJDT1 = OpenDAG (JDT, ao_Arr1);
		
		_MEM_Clear(condStruct, 7);

		condStruct[0].colNum = JDT1_TRANS_TYPE;
		condStruct[0].operation = DBD_EQ;
		condStruct[0].condVal = JDT; 
		condStruct[0].relationship = DBD_AND;

		condStruct[1].colNum = JDT1_VAT_GROUP;
		condStruct[1].operation = DBD_NOT_NULL;
		condStruct[1].relationship = DBD_AND;

		condStruct[2].colNum = JDT1_VAT_GROUP;
		condStruct[2].operation = DBD_NE;
		condStruct[2].relationship = DBD_AND;

		condStruct[3].colNum = JDT1_DEBIT;
		condStruct[3].operation = DBD_EQ;
		_STR_strcpy (condStruct[3].condVal, STR_0); 
		condStruct[3].relationship = DBD_AND;

		condStruct[4].colNum = JDT1_CREDIT;
		condStruct[4].operation = DBD_EQ;
		_STR_strcpy (condStruct[4].condVal, STR_0); 
		condStruct[4].relationship = DBD_AND;

		condStruct[5].colNum = JDT1_SYS_DEBIT;
		condStruct[5].operation = DBD_EQ;
		_STR_strcpy (condStruct[5].condVal, STR_0); 
		condStruct[5].relationship = DBD_AND;

		condStruct[6].colNum = JDT1_SYS_CREDIT;
		condStruct[6].operation = DBD_EQ;
		_STR_strcpy (condStruct[6].condVal, STR_0);
		
		DBD_SetDAGCond (dagJDT1, condStruct, 7);

		ooErr = DBD_Get (dagJDT1);
		if (!ooErr)
		{
			long			jdtNum, lineId;
			Boolean			DebitSide, CreditSide;

			_MEM_Clear(resStruct, 4);
			resStruct[0].colNum = JDT1_DEBIT;
			resStruct[1].colNum = JDT1_CREDIT;
			resStruct[2].colNum = JDT1_SYS_DEBIT;
			resStruct[3].colNum = JDT1_SYS_CREDIT;

			DAG_GetCount (dagJDT1, &numOfRecs);
			for (rec=0; rec < numOfRecs; rec++)
			{
				dagJDT1->GetColLong (&jdtNum, JDT1_TRANS_ABS, rec);
				dagJDT1->GetColLong (&lineId, JDT1_LINE_ID, rec);

				_MEM_Clear(condStruct, 2);

				condStruct[0].colNum = JDT1_TRANS_ABS;
				condStruct[0].operation = DBD_EQ;
				condStruct[0].condVal = jdtNum; 
				condStruct[0].relationship = DBD_AND;

				condStruct[1].compareCols = TRUE;
				condStruct[1].colNum = JDT1_SHORT_NAME;
				condStruct[1].operation = DBD_NE;
				condStruct[1].compColNum = JDT1_ACCT_NUM;

				DBD_SetDAGCond (dagJDT1, condStruct, 2);
				DBD_SetDAGRes (dagJDT1, resStruct, 4);

				ooErr = DBD_GetInNewFormat (dagJDT1, &dagRES);
				if (!ooErr)
				{
					DebitSide = CreditSide = FALSE;

					dagRES->GetColMoney (&tmpM, 0, 0, DBM_NOT_ARRAY);
					if (!tmpM.IsZero())
					{
						CreditSide = TRUE;
					}
					dagRES->GetColMoney (&tmpM, 1, 0, DBM_NOT_ARRAY);
					if (!tmpM.IsZero())
					{
						DebitSide = TRUE;
					}
					dagRES->GetColMoney (&tmpM, 2, 0, DBM_NOT_ARRAY);
					if (!tmpM.IsZero())
					{
						CreditSide = TRUE;
					}
					dagRES->GetColMoney (&tmpM, 3, 0, DBM_NOT_ARRAY);
					if (!tmpM.IsZero())
					{
						DebitSide = TRUE;
					}
					if (DebitSide)
					{
						_MEM_Clear(condStruct, 2);

						condStruct[0].colNum = JDT1_TRANS_ABS;
						condStruct[0].operation = DBD_EQ;
						condStruct[0].condVal = jdtNum; 
						condStruct[0].relationship = DBD_AND;

						condStruct[1].colNum = JDT1_LINE_ID;
						condStruct[1].operation = DBD_EQ;
						condStruct[1].condVal = lineId; 

						DBD_SetDAGCond (dagJDT1, condStruct, 2);

						_MEM_Clear(updStruct, 2);
						updStruct[0].colNum = JDT1_CREDIT;
						updStruct[1].colNum = JDT1_SYS_CREDIT;

						DBD_SetDAGUpd (dagJDT1, updStruct, 2);
						ooErr = DBD_UpdateCols (dagJDT1);
						if (ooErr)
						{
							DAG_Close (dagJDT1);
							return ooErr;
						}
					}
					else if (CreditSide)
					{
						_MEM_Clear(condStruct, 2);

						condStruct[0].colNum = JDT1_TRANS_ABS;
						condStruct[0].operation = DBD_EQ;
						condStruct[0].condVal = jdtNum; 
						condStruct[0].relationship = DBD_AND;

						condStruct[1].colNum = JDT1_LINE_ID;
						condStruct[1].operation = DBD_EQ;
						condStruct[1].condVal = lineId; 

						DBD_SetDAGCond (dagJDT1, condStruct, 2);

						_MEM_Clear(updStruct, 2);
						updStruct[0].colNum = JDT1_DEBIT;
						updStruct[1].colNum = JDT1_SYS_DEBIT;

						DBD_SetDAGUpd (dagJDT1, updStruct, 2);
						ooErr = DBD_UpdateCols (dagJDT1);
						if (ooErr)
						{
							DAG_Close (dagJDT1);
							return ooErr;
						}
					}
				}
			}
		}
		DAG_Close (dagJDT1);

		upgradeBlock.MarkSuccess();
	}

	if (UpgradeVersionCheck (OJDT_UPG_FIN_REP_VER))
	{
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("Financial Report"));

		PDAG	dagCPRF = OpenDAG (PRF);

		_MEM_Clear(condStruct, 1);

		condStruct[0].condVal = (long)363;   
		condStruct[0].colNum = CPRF_FORM;
		condStruct[0].operation = DBD_EQ;
		condStruct[0].relationship = 0;

		DBD_SetDAGCond(dagCPRF, condStruct, 1);
		DBD_RemoveRecords(dagCPRF);

		condStruct[0].condVal = (long)365;   
		DBD_SetDAGCond(dagCPRF, condStruct, 1);
		DBD_RemoveRecords(dagCPRF);
		DAG_Close (dagCPRF);

		upgradeBlock.MarkSuccess();
	}

	if (UpgradeVersionCheck (OJDT_GIUL_CRD_CODE_VER))
	{
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("Card Code"));

		PDAG	dagCPRF = OpenDAG (PRF);

		_MEM_Clear(condStruct, 1);

		condStruct[0].condVal = (long)964;   
		condStruct[0].colNum = CPRF_FORM;
		condStruct[0].operation = DBD_EQ;
		condStruct[0].relationship = 0;

		DBD_SetDAGCond(dagCPRF, condStruct, 1);
		DBD_RemoveRecords(dagCPRF);

		condStruct[0].condVal = (long)965;   
		DBD_SetDAGCond(dagCPRF, condStruct, 1);
		DBD_RemoveRecords(dagCPRF);
		DAG_Close (dagCPRF);

		upgradeBlock.MarkSuccess();
	}

// VF_EP2_OtherAuditFeatures
	MajorReleaseVersionMappingMap vmTrialBalance;
	vmTrialBalance.SetAt (b1mr_2007A, VERSION_2007_60);
	if (UpgradeVersionCheck (VERSION_2005_320, true, true, &vmTrialBalance))
	{
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("CPRF"));

		PDAG	dagCPRF = OpenDAG (PRF);

		_MEM_Clear (condStruct, 1);

		condStruct[0].condVal = (long)167; // Trial Balance
		condStruct[0].colNum = CPRF_FORM;
		condStruct[0].operation = DBD_EQ;
		condStruct[0].relationship = 0;
		
		DBD_SetDAGCond (dagCPRF, condStruct, 1);
		DBD_RemoveRecords (dagCPRF);

		DAG_Close (dagCPRF);

		upgradeBlock.MarkSuccess();
	}

	if (UpgradeVersionCheck(OJDT_UPG_BASE_REF_VER))
	{
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("Base Reference"));

		dagJDT = OpenDAG (JDT);

		_MEM_Clear(condStruct, 2);

		condStruct[0].colNum = OJDT_TRANS_TYPE;
		condStruct[0].operation = DBD_EQ;
		condStruct[0].condVal = JDT; 
		condStruct[0].relationship = DBD_AND;

		condStruct[1].colNum = OJDT_BASE_REF;
		condStruct[1].operation = DBD_NE;
		condStruct[1].compareCols = TRUE;
		condStruct[1].compColNum = OJDT_NUMBER;

		DBD_SetDAGCond (dagJDT, condStruct, 2);

		_MEM_Clear(resStruct, 2);
		resStruct[0].colNum = OJDT_JDT_NUM;
		resStruct[1].colNum = OJDT_NUMBER;

		DBD_SetDAGRes (dagJDT, resStruct, 2);

		ooErr = DBD_GetInNewFormat (dagJDT, &dagRES);
		if (!ooErr)
		{
			dagJDT1 = OpenDAG (JDT, ao_Arr1);
			DAG_GetCount (dagRES, &numOfRecs);
			for (rec=0; rec < numOfRecs; rec++)
			{
				updStruct[0].colNum = JDT1_BASE_REF;
				dagRES->GetColStr(updStruct[0].updateVal, 1, rec);

				condStruct[0].colNum = JDT1_TRANS_ABS;
				condStruct[0].operation = DBD_EQ;
				dagRES->GetColStr(condStruct[0].condVal, 0, rec);
				condStruct[0].relationship = 0;

				DBD_SetDAGCond (dagJDT1, condStruct, 1);
				DBD_SetDAGUpd (dagJDT1, updStruct, 1);
				ooErr = DBD_UpdateCols (dagJDT1);
				if(ooErr)
				{
					dagJDT->Close ();
					dagJDT1->Close ();
					return ooErr;
				}
			}
			dagJDT1->Close ();

			condStruct[0].colNum = OJDT_TRANS_TYPE;
			condStruct[0].operation = DBD_EQ;
			condStruct[0].condVal = JDT; 
			condStruct[0].relationship = DBD_AND;

			condStruct[1].colNum = OJDT_BASE_REF;
			condStruct[1].operation = DBD_NE;
			condStruct[1].compareCols = TRUE;
			condStruct[1].compColNum = OJDT_NUMBER;

			DBD_SetDAGCond (dagJDT, condStruct, 2);

			updStruct[0].colNum = OJDT_BASE_REF;
			updStruct[0].SetUpdateColSource(DBD_UpdStruct::ucs_SrcCol);
			updStruct[0].srcColNum = OJDT_NUMBER;
			DBD_SetDAGUpd (dagJDT, updStruct, 1);
			ooErr = DBD_UpdateCols (dagJDT);
			if(ooErr)
			{
				dagJDT->Close ();
				return ooErr;
			}
		}

		dagJDT->Close ();

		upgradeBlock.MarkSuccess();
	}

	if (bizEnv.IsVatPerLine() && UpgradeVersionCheck (VERSION_2005_113))
	{
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("VAT Infromation") + VERSION_2005_113);

		dagJDT1 = OpenDAG (JDT, ao_Arr1);
		
		_MEM_Clear(condStruct, 5);

		condStruct[0].colNum = JDT1_TRANS_TYPE;
		condStruct[0].operation = DBD_EQ;
		condStruct[0].condVal = JDT; 
		condStruct[0].relationship = DBD_AND;

		condStruct[1].colNum = JDT1_VAT_GROUP;
		condStruct[1].operation = DBD_NOT_NULL;
		condStruct[1].relationship = DBD_AND;

		condStruct[2].colNum = JDT1_VAT_GROUP;
		condStruct[2].operation = DBD_NE;
		condStruct[2].relationship = DBD_AND;

		condStruct[3].colNum = JDT1_DEBIT;
		condStruct[3].operation = DBD_NE;
		_STR_strcpy (condStruct[3].condVal, STR_0); 
		condStruct[3].relationship = DBD_AND;

		condStruct[4].colNum = JDT1_CREDIT;
		condStruct[4].operation = DBD_IS_NULL;

		DBD_SetDAGCond (dagJDT1, condStruct, 5);

		_MEM_Clear(updStruct, 2);
		updStruct[0].colNum = JDT1_CREDIT;
		_STR_strcpy(updStruct[0].updateVal, STR_0);
		updStruct[1].colNum = JDT1_SYS_CREDIT;
		_STR_strcpy(updStruct[1].updateVal, STR_0);

		DBD_SetDAGUpd (dagJDT1, updStruct, 2);
		ooErr = DBD_UpdateCols (dagJDT1);
		if (ooErr)
		{
			DAG_Close (dagJDT1);
			return ooErr;
		}
		condStruct[3].colNum = JDT1_CREDIT;
		condStruct[4].colNum = JDT1_DEBIT;

		DBD_SetDAGCond (dagJDT1, condStruct, 5);

		updStruct[0].colNum = JDT1_DEBIT;
		updStruct[1].colNum = JDT1_SYS_DEBIT;
		
		DBD_SetDAGUpd (dagJDT1, updStruct, 2);
		ooErr = DBD_UpdateCols (dagJDT1);
		if (ooErr)
		{
			DAG_Close (dagJDT1);
			return ooErr;
		}
		DAG_Close (dagJDT1);

		upgradeBlock.MarkSuccess();
	}
	
	if (UpgradeVersionCheck (OJDT_DOC_SERIES_VER))
	{
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("Doc Series"));


		PDAG			dagSeries, dagTransList;
		long			numInList, *listOfFlds, transType;
		long			series, numOfSeries, i, j, listNum, transNum;
		DBD_CondStruct	condStruct1[1];
		long			conid = bizEnv.GetCompanyConnectionID();
		DBM_ServerTypes ServerType = DBMCconnManager::GetHandle()->GetConnectionType (conid);

		dagJDT = OpenDAG (JDT);
		
		_MEM_Clear(resStruct, 1);
		resStruct[0].colNum = OJDT_TRANS_TYPE;
		resStruct[0].group_by = TRUE;
		DBD_SetDAGRes (dagJDT, resStruct, 1);

		ooErr = DBD_GetInNewFormat (dagJDT, &dagRES);
		if (ooErr)
		{
			DAG_Close (dagJDT);
			return ooNoErr;
		}

		dagRES->Detach();

		PDAG	dagTMP = OpenDAG (JDT);

		DAG_GetCount (dagRES, &numOfRecs);
		for (rec=0; rec < numOfRecs; rec++)
		{
			dagRES->GetColLong (&transType, 0, rec);
			if (transType < 0 || transType == JDT || !bizEnv.IsSerieObject(SBOString (transType)))
			{
				_MEM_Clear(condStruct, 1);
				condStruct[0].colNum = OJDT_TRANS_TYPE;
				condStruct[0].operation = DBD_EQ;
				condStruct[0].condVal = transType;
				DBD_SetDAGCond (dagJDT, condStruct, 1);
				
				_MEM_Clear(updStruct, 1);
				updStruct[0].colNum = OJDT_DOC_SERIES;
				updStruct[0].SetUpdateColSource(DBD_UpdStruct::ucs_SrcCol);
				updStruct[0].srcColNum = OJDT_SERIES;
				DBD_SetDAGUpd (dagJDT, updStruct, 1);
				ooErr = DBD_UpdateCols (dagJDT);
				if(ooErr)
				{
					dagJDT->Close ();
					dagRES->Close ();
					dagTMP->Close ();
					return ooErr;
				}
			}
			else
			{
				_STR_strcpy (tableStruct[0].tableCode, bizEnv.ObjectToTable (JDT, ao_Main));
				_STR_strcpy (tableStruct[1].tableCode, bizEnv.ObjectToTable (transType, ao_Main));

				tableStruct[1].doJoin = TRUE;
				tableStruct[1].joinedToTable = 0;

				tableStruct[1].numOfConds = 1;
				tableStruct[1].joinConds = joinCondStruct;

				bizEnv.GetTypeColList (tableStruct[1].tableCode, ABSOLUTE_ENT_FLD, &numInList, &listOfFlds);
				joinCondStruct[0].compareCols = TRUE;
				joinCondStruct[0].compTableIndex = 0;
				joinCondStruct[0].compColNum = OJDT_CREATED_BY;
				joinCondStruct[0].tableIndex = 1;
				joinCondStruct[0].colNum = listOfFlds[0];
				joinCondStruct[0].operation = DBD_EQ;
				bizEnv.DisposeColList (listOfFlds);

				_MEM_Clear(condStruct, 1);
				condStruct[0].colNum = OJDT_TRANS_TYPE;
				condStruct[0].operation = DBD_EQ;
				condStruct[0].condVal = transType;
				DBD_SetDAGCond (dagJDT, condStruct, 1);

				_MEM_Clear(resStruct, 1);
				bizEnv.GetTypeColList (tableStruct[1].tableCode, SERIES_FLD, &numInList, &listOfFlds);
				resStruct[0].colNum = listOfFlds[0];
				resStruct[0].tableIndex = 1;
				resStruct[0].group_by = TRUE;
				bizEnv.DisposeColList (listOfFlds);

				DBD_SetTablesList (dagJDT, tableStruct, 2);
				DBD_SetDAGCond (dagJDT, condStruct, 1);
				DBD_SetDAGRes (dagJDT, resStruct, 1);

				ooErr = DBD_GetInNewFormat (dagJDT, &dagSeries);
				if (ooErr)
				{
					continue;
				}
				DAG_GetCount (dagSeries, &numOfSeries);
				if (numOfSeries == 1)
				{
					dagSeries->GetColLong(&series, 0, 0);

					_MEM_Clear(condStruct, 1);
					condStruct[0].colNum = OJDT_TRANS_TYPE;
					condStruct[0].operation = DBD_EQ;
					condStruct[0].condVal = transType;
					DBD_SetDAGCond (dagJDT, condStruct, 1);
					
					_MEM_Clear(updStruct, 1);
					updStruct[0].colNum = OJDT_DOC_SERIES;
					updStruct[0].updateVal = series;
					DBD_SetDAGUpd (dagJDT, updStruct, 1);
					ooErr = DBD_UpdateCols (dagJDT);
					if(ooErr)
					{
						dagJDT->Close ();
						dagRES->Close ();
						dagTMP->Close ();
						return ooErr;
					}
				}
				else if (ServerType == st_MSSQL)
				{
					_MEM_Clear(condStruct, 2);
					condStruct[0].colNum = OJDT_TRANS_TYPE;
					condStruct[0].operation = DBD_EQ;
					condStruct[0].condVal = transType;
					condStruct[0].relationship = DBD_AND;
					
					bizEnv.GetTypeColList (tableStruct[1].tableCode, SERIES_FLD, &numInList, &listOfFlds);
					condStruct[1].colNum = listOfFlds[0];
					condStruct[1].tableIndex = 1;
					condStruct[1].operation = DBD_EQ;
					bizEnv.DisposeColList (listOfFlds);

					_MEM_Clear(updStruct, 1);
					updStruct[0].colNum = OJDT_DOC_SERIES;
					for (i = 0; i < numOfSeries; i++)
					{
						dagSeries->GetColLong(&series, 0, i);
						condStruct[1].condVal = series;
						updStruct[0].updateVal = series;

						DBD_SetTablesList (dagJDT, tableStruct, 2);
						DBD_SetDAGCond (dagJDT, condStruct, 2);
						DBD_SetDAGUpd (dagJDT, updStruct, 1);
						ooErr = DBD_UpdateCols (dagJDT);
						if(ooErr)
						{
							dagJDT->Close ();
							dagRES->Close ();
							dagTMP->Close ();
							return ooErr;
						}
					}
				}
				else
				{
					_MEM_Clear(condStruct, 2);
					condStruct[0].colNum = OJDT_TRANS_TYPE;
					condStruct[0].operation = DBD_EQ;
					condStruct[0].condVal = transType;
					condStruct[0].relationship = DBD_AND;
					
					bizEnv.GetTypeColList (tableStruct[1].tableCode, SERIES_FLD, &numInList, &listOfFlds);
					condStruct[1].colNum = listOfFlds[0];
					condStruct[1].tableIndex = 1;
					condStruct[1].operation = DBD_EQ;
					bizEnv.DisposeColList (listOfFlds);

					_MEM_Clear(resStruct, 1);
					resStruct[0].colNum = OJDT_JDT_NUM;

					_MEM_Clear(updStruct, 1);
					updStruct[0].colNum = OJDT_DOC_SERIES;
					for (i = 0; i < numOfSeries; i++)
					{
						dagSeries->GetColLong(&series, 0, i);
						condStruct[1].condVal = series;
						updStruct[0].updateVal = series;

						DBD_SetTablesList (dagTMP, tableStruct, 2);
						DBD_SetDAGCond (dagTMP, condStruct, 2);
						DBD_SetDAGRes (dagTMP, resStruct, 1);
						
						ooErr = DBD_GetInNewFormat (dagTMP, &dagTransList);
						if (ooErr)
						{
							continue;
						}
						DAG_GetCount (dagTransList, &listNum);
						for (j = 0; j < listNum; j++)
						{
							dagTransList->GetColLong(&transNum, 0, j);
							condStruct1[0].colNum = OJDT_JDT_NUM;
							condStruct1[0].operation = DBD_EQ;
							condStruct1[0].condVal = transNum;

							DBD_SetDAGCond (dagJDT, condStruct1, 1);
							DBD_SetDAGUpd (dagJDT, updStruct, 1);
							ooErr = DBD_UpdateCols (dagJDT);
							if(ooErr)
							{
								dagJDT->Close ();
								dagRES->Close ();
								dagTMP->Close ();
								return ooErr;
							}
						}
					}
				}
			}
		}
		dagJDT->Close ();
		dagRES->Close ();
		dagTMP->Close ();

		upgradeBlock.MarkSuccess();
	}
	
	if (UpgradeVersionCheck (OJDT_CTRL_ACT_COL_VER))
	{
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("Control Account Col"));

		PDAG	dagCPRF = OpenDAG (PRF);
		long	formNum[] = {390, 391, 392, 393, 809, 501, -1}, i;

		_MEM_Clear(condStruct, 1);

		condStruct[0].colNum = CPRF_FORM;
		condStruct[0].operation = DBD_EQ;
		condStruct[0].relationship = 0;

		for (i = 0; formNum[i] > 0; i++)
		{
			condStruct[0].condVal = formNum[i];   
			DBD_SetDAGCond(dagCPRF, condStruct, 1);
			DBD_RemoveRecords(dagCPRF);
		}

		DAG_Close (dagCPRF);

		upgradeBlock.MarkSuccess();
	}
	
	/************************************************************************/
	/* Upgrade the new LineType field in jdt1 for the down payment request lines*/
	/************************************************************************/
	if (UpgradeVersionCheck (VERSION_2007_MR))
	{
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("DPM lines"));

		ooErr = SetToZeroNullLineTypeCols ();
		if (ooErr)
		{
			return ooErr;
		}

		ooErr = SetToZeroOldLineTypeCols ();
		if (ooErr) 
		{
			return ooErr;
		}

		long kk = 0, objArr [] = {RCT, VPM, -1};

		while (objArr [kk] != -1) 
		{
			ooErr = UpgradeDpmLineTypeUsingJDT1 (objArr[kk]);
			if (ooErr) 
			{
				return ooErr;
			}

			ooErr = UpgradeDpmLineTypeUsingRCT2 (objArr[kk]);
			if (ooErr) 
			{
				return ooErr;
			}			

			kk++;
		}

		upgradeBlock.MarkSuccess();
	}

	if (UpgradeVersionCheck (OJDT_DEBIT_CREDIT_VER))
	{
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("Debit Credit"));

		dagJDT1 = OpenDAG (JDT, ao_Arr1);

		_MEM_Clear(condStruct, 2);
		_MEM_Clear(updStruct, 1);

		condStruct[0].colNum = JDT1_DEBIT_CREDIT;
		condStruct[0].operation = DBD_IS_NULL;
		condStruct[0].relationship = DBD_AND;

		condStruct[1].colNum = JDT1_DEBIT;
		condStruct[1].operation = DBD_NE;
		condStruct[1].condVal = (long)0;   

		DBD_SetDAGCond (dagJDT1, condStruct, 2);

		updStruct[0].colNum = JDT1_DEBIT_CREDIT;
		_STR_strcpy (updStruct[0].updateVal, VAL_DEBIT);

		DBD_SetDAGUpd (dagJDT1, updStruct, 1);
		ooErr = DBD_UpdateCols (dagJDT1);

		condStruct[1].colNum = JDT1_CREDIT;
		DBD_SetDAGCond (dagJDT1, condStruct, 2);
		_STR_strcpy (updStruct[0].updateVal, VAL_CREDIT);

		DBD_SetDAGUpd (dagJDT1, updStruct, 1);
		ooErr = DBD_UpdateCols (dagJDT1);

		condStruct[1].colNum = JDT1_SYS_DEBIT;
		DBD_SetDAGCond (dagJDT1, condStruct, 2);
		_STR_strcpy (updStruct[0].updateVal, VAL_DEBIT);

		DBD_SetDAGUpd (dagJDT1, updStruct, 1);
		ooErr = DBD_UpdateCols (dagJDT1);

		condStruct[1].colNum = JDT1_SYS_CREDIT;
		DBD_SetDAGCond (dagJDT1, condStruct, 2);
		_STR_strcpy (updStruct[0].updateVal, VAL_CREDIT);

		DBD_SetDAGUpd (dagJDT1, updStruct, 1);
		ooErr = DBD_UpdateCols (dagJDT1);

		condStruct[1].colNum = JDT1_FC_DEBIT;
		DBD_SetDAGCond (dagJDT1, condStruct, 2);
		_STR_strcpy (updStruct[0].updateVal, VAL_DEBIT);

		DBD_SetDAGUpd (dagJDT1, updStruct, 1);
		ooErr = DBD_UpdateCols (dagJDT1);

		condStruct[1].colNum = JDT1_FC_CREDIT;
		DBD_SetDAGCond (dagJDT1, condStruct, 2);
		_STR_strcpy (updStruct[0].updateVal, VAL_CREDIT);

		DBD_SetDAGUpd (dagJDT1, updStruct, 1);
		ooErr = DBD_UpdateCols (dagJDT1);

		// Handles lines with NULL in debit and 0 in credit
		_MEM_Clear(condStruct, 3);

		condStruct[0].colNum = JDT1_DEBIT_CREDIT;
		condStruct[0].operation = DBD_IS_NULL;
		condStruct[0].relationship = DBD_AND;

		condStruct[1].colNum = JDT1_DEBIT;
		condStruct[1].operation = DBD_IS_NULL;
		condStruct[1].relationship = DBD_AND;

		condStruct[2].colNum = JDT1_CREDIT;
		condStruct[2].operation = DBD_EQ;
		condStruct[2].condVal = (long)0;

		DBD_SetDAGCond (dagJDT1, condStruct, 3);

		updStruct[0].colNum = JDT1_DEBIT_CREDIT;
		_STR_strcpy (updStruct[0].updateVal, VAL_CREDIT);

		DBD_SetDAGUpd (dagJDT1, updStruct, 1);
		ooErr = DBD_UpdateCols (dagJDT1);

		// Handles lines with NULL in credit and 0 in debit
		condStruct[1].colNum = JDT1_CREDIT;
		condStruct[1].operation = DBD_IS_NULL;
		condStruct[1].relationship = DBD_AND;

		condStruct[2].colNum = JDT1_DEBIT;
		condStruct[2].operation = DBD_EQ;
		condStruct[2].condVal = (long)0;

		DBD_SetDAGCond (dagJDT1, condStruct, 3);

		updStruct[0].colNum = JDT1_DEBIT_CREDIT;
		_STR_strcpy (updStruct[0].updateVal, VAL_DEBIT);

		DBD_SetDAGUpd (dagJDT1, updStruct, 1);
		ooErr = DBD_UpdateCols (dagJDT1);

		// Handles lines with wrong value in the DebitCredit field
		_MEM_Clear(condStruct, 2);
		_MEM_Clear(updStruct, 1);

		condStruct[0].colNum = JDT1_DEBIT_CREDIT;
		condStruct[0].operation = DBD_EQ;
		_STR_strcpy (condStruct[0].condVal, VAL_CREDIT); 
		condStruct[0].relationship = DBD_AND;

		condStruct[1].colNum = JDT1_DEBIT;
		condStruct[1].operation = DBD_NE;
		condStruct[1].condVal = (long)0; 

		DBD_SetDAGCond (dagJDT1, condStruct, 2);

		updStruct[0].colNum = JDT1_DEBIT_CREDIT;
		_STR_strcpy (updStruct[0].updateVal, VAL_DEBIT);

		DBD_SetDAGUpd (dagJDT1, updStruct, 1);
		ooErr = DBD_UpdateCols (dagJDT1);

		condStruct[1].colNum = JDT1_SYS_DEBIT;
		DBD_SetDAGCond (dagJDT1, condStruct, 2);
		DBD_SetDAGUpd (dagJDT1, updStruct, 1);
		ooErr = DBD_UpdateCols (dagJDT1);

		condStruct[1].colNum = JDT1_FC_DEBIT;
		DBD_SetDAGCond (dagJDT1, condStruct, 2);
		DBD_SetDAGUpd (dagJDT1, updStruct, 1);
		ooErr = DBD_UpdateCols (dagJDT1);

		_STR_strcpy (condStruct[0].condVal, VAL_DEBIT); 
		condStruct[1].colNum = JDT1_CREDIT;
		DBD_SetDAGCond (dagJDT1, condStruct, 2);

		updStruct[0].colNum = JDT1_DEBIT_CREDIT;
		_STR_strcpy (updStruct[0].updateVal, VAL_CREDIT);

		DBD_SetDAGUpd (dagJDT1, updStruct, 1);
		ooErr = DBD_UpdateCols (dagJDT1);

		condStruct[1].colNum = JDT1_SYS_CREDIT;
		DBD_SetDAGCond (dagJDT1, condStruct, 2);
		DBD_SetDAGUpd (dagJDT1, updStruct, 1);
		ooErr = DBD_UpdateCols (dagJDT1);

		condStruct[1].colNum = JDT1_FC_CREDIT;
		DBD_SetDAGCond (dagJDT1, condStruct, 2);
		DBD_SetDAGUpd (dagJDT1, updStruct, 1);
		ooErr = DBD_UpdateCols (dagJDT1);

		DAG_Close (dagJDT1);

		upgradeBlock.MarkSuccess();
	}

	//DO NOT MOVE THIS PART - its important that reconciliation upgrade will be after debit-credit field is update.
	
	/************************** RECONCILIATION UPGRADE - START **************************/

	CReconUpgMgr *reconUpgMgr = new CReconUpgMgr (bizEnv, *this);
	
	// Here we upgrade certain fields of payment tables (VPM2, RCT2)
	// this upgrade should be BEFORE the Recon. upgrade and to DBs that already had the
	// Recon. upgrade and upgrading to this patch - the purpose of this upgrade
	// Is to make the IRU queries faster by saving the TRans number in the payment tables
	if (UpgradeVersionCheck (VERSION_2007_58))
	{
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("UpgradeRCT2"));

		ooErr = reconUpgMgr->UpgradeRCT2TransFields ();
		if (ooErr)
		{
			return ooErr;
		}

		upgradeBlock.MarkSuccess();
	}


	// Here we upgrade certain fields of payment tables (RCT2, VPM2)
	// this upgrade should be BEFORE the Recon. upgrade and to DBs that 
	// are upgrading to this patch - the purpose of this upgrade is
	// to correct fields in payment tables which have negative sums 
	// that should be positive
	if (UpgradeVersionCheck (VERSION_2007_60))
	{
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("UpgradeRCT2 Negative Part"));

		ooErr = reconUpgMgr->UpgradeRCT2NegativeFields ();
		if (ooErr)
		{
			return ooErr;
		}

		upgradeBlock.MarkSuccess();
	}

		//we need these views for general reconciliation upgrade and/or partial reconciliation upgrade
	if (UpgradeVersionCheck (VERSION_2007_MR) || UpgradeVersionCheck (VERSION_2007_53) ||
		UpgradeVersionRangeCheck (VERSION_2007_53, VERSION_2007B_38, true, true))
	{
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("Build Views For Bad Payments"));

		ooErr = reconUpgMgr->BuildViewsForBadPayments ();
		if (ooErr)
		{
			reconUpgMgr->ClearViewsForBadPayments ();
			delete reconUpgMgr;
			return ooErr;
		}

		upgradeBlock.MarkSuccess();
	}

	// 1. General reconciliation upgrade
	if (UpgradeVersionCheck (VERSION_2007_MR))
	{
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("Clear Views For Bad Payments"));

		ooErr = reconUpgMgr->Upgrade ();
		if (ooErr)
		{
			reconUpgMgr->ClearViewsForBadPayments ();
			delete reconUpgMgr;
			return ooErr;
		}

		upgradeBlock.MarkSuccess();
    }

	MajorReleaseVersionMappingMap vmLinkedInv;
	vmLinkedInv.SetAt (b1mr_2007B, VERSION_2007B_39);
	if (UpgradeVersionCheck (VERSION_2007_81, false, true, &vmLinkedInv))
	{
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("Fix Linked Invoice Reconciliation"));

		ooErr = reconUpgMgr->FixLinkedInvoiceReconciliation();
		if (ooErr)
		{
			reconUpgMgr->ClearViewsForBadPayments ();
			delete reconUpgMgr;
			return ooErr;
		}

		upgradeBlock.MarkSuccess();
	}

	// 2. Partial reconciliations upgrade (from the middle of version 2007 ramp-up)
	if (UpgradeVersionCheck (VERSION_2007_53))
	{
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("Upgrade Partial Reconciliation History"));

		ooErr = reconUpgMgr->UpgradePartialReconciliationHistory ();
		if (ooErr)
		{
			reconUpgMgr->ClearViewsForBadPayments ();
			delete reconUpgMgr;
			return ooErr;
		}

		upgradeBlock.MarkSuccess();
	}

	// 2b. Partial reconciliations upgrade - fixes wrongly reconciled data
	//if (upgDataPtr->fromVersion >=  VERSION_2007_53 && upgDataPtr->fromVersion <=  VERSION_2007B_38 &&
	//	upgDataPtr->toVersion > VERSION_2007B_38)
	if (UpgradeVersionRangeCheck (VERSION_2007B_MR, VERSION_2007B_38, true, true))
	{
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("Upgrade Partial ReconHist Replace WrongRecon"));

		ooErr = reconUpgMgr->UpgradePartialReconHistReplaceWrongRecon ();
		if (ooErr)
		{
			reconUpgMgr->ClearViewsForBadPayments ();
			delete reconUpgMgr;
			return ooErr;
		}

		upgradeBlock.MarkSuccess();
	}


	reconUpgMgr->ClearViewsForBadPayments ();
	delete reconUpgMgr;

	// 3. Upgrade of the IRU audit-trail (during version 2007 ramp-up)
	if (UpgradeVersionRangeCheck (VERSION_2007_MR, VERSION_2007_50))
	{
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("Upgrade Audit Trail JE Total"));

		ooErr = CReconUpgMgr::UpgradeAuditTrailJETotal (bizEnv);
		IF_ERROR_RETURN (ooErr);

		upgradeBlock.MarkSuccess();
	}

	// 4. Upgrade for jdt1 FC currency field
	// the following upgrade will perform only for non-db2 customers since there is
	// join in the update query of this upgrade
	long  connID = m_env.GetCompanyConnectionID ();
	DBM_ServerTypes   ServerType = DBMCconnManager::GetHandle()->GetConnectionType (connID);
	if (UpgradeVersionRangeCheck (VERSION_2007_MR, VERSION_2007_53) && (ServerType != st_DB2))
	{
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("Nullify FCCurrency Field In JDT1"));

		ooErr = CReconUpgMgr::NullifyFCCurrencyFieldInJDT1 (bizEnv);
		IF_ERROR_RETURN (ooErr);

		upgradeBlock.MarkSuccess();
	}


	/************************** RECONCILIATION UPGRADE - END **************************/

	if (UpgradeVersionCheck (VERSION_8_8_MR))
	{
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("Upgrade Documents VatPaid For Fully Based Credit Memos"));

		long objIDs[] = {RIN, RPC, -1};
		for(long i = 0; objIDs[i] >=0; i++)
		{
			ooErr = UpgradeODOCVatPaidForFullyBasedCreditMemos(objIDs[i]);
			IF_ERROR_RETURN(ooErr);
			ooErr = UpgradeDOC6VatPaidForFullyBasedCreditMemos(objIDs[i]);
			IF_ERROR_RETURN(ooErr);
		}

		upgradeBlock.MarkSuccess();
	}

	bool isAPA = bizEnv.IsFormerApaLocalSettings ();
	if ((isAPA && UpgradeVersionCheck (VERSION_2005B_242)) ||
		(!isAPA && UpgradeVersionCheck (VERSION_2007_22)))
	{
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("Upgrade OJDT Created By For WOR"));

		ooErr = UpgradeOJDTCreatedByForWOR ();
		if (ooErr)
		{
			return ooErr;
		}

		upgradeBlock.MarkSuccess();
	}

	if((bizEnv.IsChileFolio() || bizEnv.IsMexicoFolio()) && UpgradeVersionCheck (VERSION_2007_MR))
	{
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("Upgrade OJDT With Folio"));

		ooErr = UpgradeOJDTWithFolio();

		if (ooErr)
		{
			return ooErr;
		}

		upgradeBlock.MarkSuccess();
	}

	if (bizEnv.OADMGetColStr (OADM_CONT_INVENTORY).Compare (VAL_YES) == 0 
		&& UpgradeVersionCheck (VERSION_2007_37))
	{
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("Upgrade JDT Create Date"));

		ooErr = UpgradeJDTCreateDate ();
		if (ooErr)
		{
			return ooErr;
		}

		upgradeBlock.MarkSuccess();
	}

	if (UpgradeVersionCheck (VERSION_2007_37))
	{
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("Upgrade JDT Canceled Deposit"));

		ooErr = UpgradeJDTCanceledDeposit ();
		if (ooErr)
		{
			return ooErr;
		}

		upgradeBlock.MarkSuccess();
	}
	
	if ((ServerType != st_DB2) && UpgradeVersionCheck (VERSION_2005_319))
	{
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("Upgrade Work Order & Landed Cost"));


		ooErr = UpgradeWorkOrderErr ();
		if (ooErr)
		{
			return	ooErr;
		}
		ooErr = UpgradeLandedCosErr ();
		if (ooErr)
		{
			return	ooErr;
		}

		upgradeBlock.MarkSuccess();
	}

	if (UpgradeVersionCheck (VERSION_2007_53))
	{
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("Upgrade Year Transfer"));

		ooErr = UpgradeYearTransfer ();
		if (ooErr)
		{
			return ooErr;
		}

		upgradeBlock.MarkSuccess();
	}

	if (UpgradeVersionCheck (OJDT_RESET_CPRF_AGING_REP))
	{
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("Remove PRF records"));

		PDAG	dagCPRF = OpenDAG (PRF);

		_MEM_Clear(condStruct, 1);

		condStruct[0].condVal = (long)964;   
		condStruct[0].colNum = CPRF_FORM;
		condStruct[0].operation = DBD_EQ;
		condStruct[0].relationship = 0;

		DBD_SetDAGCond(dagCPRF, condStruct, 1);
		DBD_RemoveRecords(dagCPRF);

		condStruct[0].condVal = (long)965;   
		DBD_SetDAGCond(dagCPRF, condStruct, 1);
		DBD_RemoveRecords(dagCPRF);
		DAG_Close (dagCPRF);

		upgradeBlock.MarkSuccess();
	}

	if (UpgradeVersionCheck (OJDT_UPGRADE_VAT_LINE_TO_NO_VER))
	{	
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("Upgrade JDT1 VatLine To No"));

		ooErr = UpgradeJDT1VatLineToNo ();
		if (ooErr)
		{
			return ooErr;
		}

		upgradeBlock.MarkSuccess();
	}
	if (bizEnv.IsCurrentLocalSettings (INDIA_SETTINGS) && UpgradeVersionCheck (VERSION_2007B_38))
	{
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("Upgrade JDT Indian AutoVat"));

		ooErr = UpgradeJDTIndianAutoVat ();
		if (ooErr)
		{
			return ooErr;
		}

		upgradeBlock.MarkSuccess();
	}

	/**
	if (VF_GBInterface (bizEnv) && UpgradeVersionCheck(VERSION_2005B_248))
	{
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("Upgrade OJDT Update Doc Type"));

		ooErr = UpgradeOJDTUpdateDocType ();
		if (ooErr)
		{
			return ooErr;
 		}

		upgradeBlock.MarkSuccess();
	}
	**/
	if (UpgradeVersionCheck (VERSION_2007_54))
	{
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("Upgrade JDT1 Balance related from version")
			+ VERSION_2007_54);

		dagJDT1 = OpenDAG (JDT, ao_Arr1);

		_MEM_Clear(condStruct, 1);

		condStruct[0].colNum = JDT1_BALANCE_DUE_CREDIT;
		condStruct[0].operation = DBD_IS_NULL;

		DBD_SetDAGCond (dagJDT1, condStruct, 1);

		_MEM_Clear(updStruct, 3);
		updStruct[0].colNum = JDT1_BALANCE_DUE_CREDIT;
		_STR_strcpy(updStruct[0].updateVal, STR_0);
		updStruct[1].colNum = JDT1_BALANCE_DUE_SC_CRED;
		_STR_strcpy(updStruct[1].updateVal, STR_0);
		updStruct[2].colNum = JDT1_BALANCE_DUE_FC_CRED;
		_STR_strcpy(updStruct[2].updateVal, STR_0);

		DBD_SetDAGUpd (dagJDT1, updStruct, 3);
		ooErr = DBD_UpdateCols (dagJDT1);
		if (ooErr)
		{
			DAG_Close (dagJDT1);
			return ooErr;
		}

		condStruct[0].colNum = JDT1_BALANCE_DUE_DEBIT;

		DBD_SetDAGCond (dagJDT1, condStruct, 1);

		updStruct[0].colNum = JDT1_BALANCE_DUE_DEBIT;
		updStruct[1].colNum = JDT1_BALANCE_DUE_SC_DEB;
		updStruct[2].colNum = JDT1_BALANCE_DUE_FC_DEB;

		DBD_SetDAGUpd (dagJDT1, updStruct, 3);
		ooErr = DBD_UpdateCols (dagJDT1);
		if (ooErr)
		{
			DAG_Close (dagJDT1);
			return ooErr;
		}
		DAG_Close (dagJDT1);

		upgradeBlock.MarkSuccess();
	}

	if (UpgradeVersionCheck (VERSION_2007_55))
	{
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("Upgrade JDT1 Balance related from version")
			+ VERSION_2007_55);

		dagJDT1 = OpenDAG (JDT, ao_Arr1);

		_MEM_Clear(condStruct, 2);
		_MEM_Clear(updStruct, 1);

		condStruct[0].colNum = JDT1_DEBIT_CREDIT;
		condStruct[0].operation = DBD_IS_NULL;
		condStruct[0].relationship = DBD_AND;

		condStruct[1].colNum = JDT1_BALANCE_DUE_DEBIT;
		condStruct[1].operation = DBD_NE;
		condStruct[1].condVal = (long)0;

		DBD_SetDAGCond (dagJDT1, condStruct, 2);

		updStruct[0].colNum = JDT1_DEBIT_CREDIT;
		_STR_strcpy (updStruct[0].updateVal, VAL_DEBIT);

		DBD_SetDAGUpd (dagJDT1, updStruct, 1);
		ooErr = DBD_UpdateCols (dagJDT1);

		condStruct[1].colNum = JDT1_BALANCE_DUE_CREDIT;
		DBD_SetDAGCond (dagJDT1, condStruct, 2);
		_STR_strcpy (updStruct[0].updateVal, VAL_CREDIT);

		DBD_SetDAGUpd (dagJDT1, updStruct, 1);
		ooErr = DBD_UpdateCols (dagJDT1);

		condStruct[1].colNum = JDT1_BALANCE_DUE_SC_DEB;
		DBD_SetDAGCond (dagJDT1, condStruct, 2);
		_STR_strcpy (updStruct[0].updateVal, VAL_DEBIT);

		DBD_SetDAGUpd (dagJDT1, updStruct, 1);
		ooErr = DBD_UpdateCols (dagJDT1);

		condStruct[1].colNum = JDT1_BALANCE_DUE_SC_CRED;
		DBD_SetDAGCond (dagJDT1, condStruct, 2);
		_STR_strcpy (updStruct[0].updateVal, VAL_CREDIT);

		DBD_SetDAGUpd (dagJDT1, updStruct, 1);
		ooErr = DBD_UpdateCols (dagJDT1);

		condStruct[1].colNum = JDT1_BALANCE_DUE_FC_DEB;
		DBD_SetDAGCond (dagJDT1, condStruct, 2);
		_STR_strcpy (updStruct[0].updateVal, VAL_DEBIT);

		DBD_SetDAGUpd (dagJDT1, updStruct, 1);
		ooErr = DBD_UpdateCols (dagJDT1);

		condStruct[1].colNum = JDT1_BALANCE_DUE_FC_CRED;
		DBD_SetDAGCond (dagJDT1, condStruct, 2);
		_STR_strcpy (updStruct[0].updateVal, VAL_CREDIT);

		DBD_SetDAGUpd (dagJDT1, updStruct, 1);
		ooErr = DBD_UpdateCols (dagJDT1);

		DAG_Close (dagJDT1);

		upgradeBlock.MarkSuccess();
	}

	if (UpgradeVersionCheck (VERSION_2007_MR))
	{
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("Repair Tax Table"));

		ooErr = RepairTaxTable();
		if (ooErr)
		{
			return ooErr;
		}

		upgradeBlock.MarkSuccess();
	}

	//VF_EnableDunningEnhancements
	//update fields added in enhancement pack 2
	MajorReleaseVersionMappingMap vmDunningDate;
	vmDunningDate.SetAt (b1mr_2007A, VERSION_2007_60);
	if (UpgradeVersionCheck (VERSION_2005_320, true, true, &vmDunningDate)) //Note: not merge to 05B yet
	{	
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("Upgrade Dunning date"));

		DBD_UpdStruct updStruct[1];

		//new field JDT1.LvlUpdateDate must be set to JDT1.DunDate
		//update JDT1 set LvlUpdateDate = DunDate
		dagJDT1 = OpenDAG (JDT, ao_Arr1);
		
		updStruct[0].srcColNum	= JDT1_LAST_DUNNING_DATE;
		updStruct[0].colNum		= JDT1_LEVEL_UPDATE_DATE;
		updStruct[0].SetUpdateColSource (DBD_UpdStruct::ucs_SrcCol);

		DBD_SetDAGUpd (dagJDT1, updStruct, 1);
		ooErr = DBD_UpdateCols (dagJDT1);
		DAG_Close (dagJDT1);

		IF_ERROR_RETURN(ooErr);

		upgradeBlock.MarkSuccess();
	}

	if (VF_ERDPostingPerDoc (GetEnv ()) && UpgradeVersionCheck (VERSION_2007_79))
	{
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("Upgrade ERD Base Trans"));

		ooErr = UpgradeERDBaseTrans ();
		if (ooErr)
		{
			return ooErr;
		}

		upgradeBlock.MarkSuccess();
	}

	// upgrade new columns in JDT1: EQ tax rate, EQ tax amount, Total tax.
	if (bizEnv.IsLocalSettingsFlag (lsf_EnableEqualizationVat) 
		&& UpgradeVersionCheck (VERSION_2007_SP1))
	{
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("upgrade new columns in JDT1: EQ tax rate, EQ tax amount, Total tax"));

		DBD_UpdStruct updateStruct[5];

		dagJDT1 = OpenDAG (JDT, ao_Arr1);

		updateStruct[0].colNum		= JDT1_EQU_VAT_PERCENT;
		updateStruct[0].updateVal   = STR_0;

		updateStruct[1].colNum		= JDT1_EQU_VAT_AMOUNT;
		updateStruct[1].updateVal   = STR_0;

		updateStruct[2].colNum		= JDT1_SYS_EQU_VAT_AMOUNT;
		updateStruct[2].updateVal   = STR_0;

		updateStruct[3].srcColNum	= JDT1_VAT_AMOUNT;
		updateStruct[3].colNum		= JDT1_TOTAL_TAX;
		updateStruct[3].SetUpdateColSource(DBD_UpdStruct::ucs_SrcCol);

		updateStruct[4].srcColNum	= JDT1_SYS_VAT_AMOUNT;
		updateStruct[4].colNum		= JDT1_SYS_TOTAL_TAX;
		updateStruct[4].SetUpdateColSource(DBD_UpdStruct::ucs_SrcCol);

		DBD_SetDAGUpd (dagJDT1, updateStruct, 5);
		ooErr = DBD_UpdateCols (dagJDT1);
		dagJDT1->Close ();

		IF_ERROR_RETURN(ooErr);

		upgradeBlock.MarkSuccess();
	}

	MajorReleaseVersionMappingMap vmCEEPerioEndRecon;
	vmCEEPerioEndRecon.SetAt (b1mr_88, VERSION_8_8_221);
	if (UpgradeVersionCheck (VERSION_2007_82, true, true, &vmCEEPerioEndRecon))
	{
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("Upgrade JDT CE EPerio End Reconcilations"));

		if (VF_EndclosingOpeningAndClosingAcct (bizEnv))
		{
			ooErr = UpgradeJDTCEEPerioEndReconcilations ();
			if (ooErr)
			{
				return ooErr;
			}
		}

		upgradeBlock.MarkSuccess();
	}

	if (bizEnv.IsLocalSettingsFlag (lsf_EnableEqualizationVat) &&
		UpgradeVersionRangeCheck(VERSION_2007_226, VERSION_2007_228))
	{
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("Repair Equ Vat Rate Of JDT1"));

		ooErr = RepairEquVatRateOfJDT1 ();
		IF_ERROR_RETURN (ooErr);

		upgradeBlock.MarkSuccess();
	}

	// Update the columns from null to zero in the following scenarios:
	// 1. exchange rate difference
	// 2. manual JE with foreign currency
	if (UpgradeVersionCheck (VERSION_8_8_223))
	{
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("Update [Exchange rate difference] -and- [manual JE with foreign currency]"));

		long cols[12] = {JDT1_DEBIT, JDT1_CREDIT,
						JDT1_FC_DEBIT, JDT1_FC_CREDIT,
						JDT1_SYS_DEBIT, JDT1_SYS_CREDIT,
						JDT1_BALANCE_DUE_DEBIT, JDT1_BALANCE_DUE_CREDIT, 
						JDT1_BALANCE_DUE_FC_DEB, JDT1_BALANCE_DUE_FC_CRED,
						JDT1_BALANCE_DUE_SC_DEB, JDT1_BALANCE_DUE_SC_CRED};

		dagJDT1 = OpenDAG (JDT, ao_Arr1);

		for (long i = 0; i < 12; i++)
		{
			_MEM_Clear (condStruct, 1);
			condStruct[0].colNum = cols[i];
			condStruct[0].operation = DBD_IS_NULL;
			condStruct[0].relationship = 0;

			DBD_SetDAGCond (dagJDT1, condStruct, 1);

			_MEM_Clear (updStruct, 1);
			updStruct[0].colNum = cols[i];
			_STR_strcpy (updStruct[0].updateVal, STR_0);

			DBD_SetDAGUpd (dagJDT1, updStruct, 1);
			ooErr = dagJDT1->UpdateCols ();
			if (ooErr)
			{
				dagJDT1->Close ();
				return ooErr;
			}
		}

		dagJDT1->Close ();

		upgradeBlock.MarkSuccess();
    }

	// VF_FederalTaxIdOnJERow
	if (UpgradeVersionCheck (VERSION_8_8_233))
	{
		ObjectUpgradeErrorLogger upgradeBlock(
			_T("Federal Tax ID On JE Row"));

		ooErr = UpgradeFederalTaxIdOnJERow ();
		IF_ERROR_RETURN (ooErr);

		upgradeBlock.MarkSuccess();
	}

	//If the DB to upgrade is between version [8.81PL06, 8.82PL05), there is possible DPR payment JDT data 
	//created between version [8.81PL06, 8.82PL00) which need upgrade JDT1.DprId.
	if(UpgradeVersionRangeCheck (VERSION_8_8_314, VERSION_8_8_2_67, true, false))
	{
		ObjectUpgradeErrorLogger upgradeBlock(_T("Upgrade DprId On JE Row"));

		//Only upgrade JDT1.DprId from those DPR payment JDT data created between version [8.81PL06, 8.82PL00). 
		ooErr = UpgradeDprId(true,  VERSION_8_8_314, VERSION_8_8_2_MR);
		IF_ERROR_RETURN (ooErr);

		ooErr = UpgradeDprId(false, VERSION_8_8_314, VERSION_8_8_2_MR);
		IF_ERROR_RETURN (ooErr);

		upgradeBlock.MarkSuccess();
	}

	//If the DB to upgrade is before version 8.82PL11, there is possible simple DPR payment(one payment pays one dpr) JDT data
	//created before version 8.81PL06 which need upgrade JDT1.DprId.
	if (UpgradeVersionCheck (VERSION_8_8_2_74))  
	{
		ObjectUpgradeErrorLogger upgradeBlock(_T("Upgrade DprId On JE Row for simple DPR payment"));

        //Only upgrade data before version 8.81PL06
		ooErr = UpgradeDprIdForOneDprPayment(true, VERSION_8_8_314);
		IF_ERROR_RETURN (ooErr);

        //Only upgrade data before version 8.81PL06
		ooErr = UpgradeDprIdForOneDprPayment(false, VERSION_8_8_314);
		IF_ERROR_RETURN (ooErr);

		upgradeBlock.MarkSuccess();
	}

	return ooNoErr;
}


/************************************************************************************/
/************************************************************************************/

SBOErr	CTransactionJournalObject::SetToZeroNullLineTypeCols ()
{
	_TRACER ("SetToZeroNullLineTypeCols");
	SBOErr	ooErr = noErr;
	PDAG	dagJDT1;
	long	updateZeroColNum [] = {JDT1_LINE_TYPE};
	dagJDT1 = GetDAG (JDT, ao_Arr1);

	ooErr = GNUpdateNullColumnsToZero (dagJDT1, updateZeroColNum, 1);
	if (ooErr)
	{
		return ooErr;
	}

	return ooErr;
}

/************************************************************************************
Function Name	: SetToZeroOldLineTypeCols
Description		: Sets the JDT1.LineType value to zero if equals 1 or 2 and its a payment
The query		: UPDATE T0 SET T0.[LineType] = 0   
				  FROM [dbo].[JDT1] T0 
				  WHERE (T0.[TransType] = (N'24' )  OR  T0.[TransType] = (N'46' ) ) AND   
				  NOT EXISTS (SELECT T0.*  FROM  [dbo].[JDT1] U0  
				  WHERE T0.[TransId] = U0.[TransId]  AND  U0.[ShortName] <> U0.[Account]  AND  U0.[LineType] <> (1 )  
				  AND  U0.[LineType] <> (2 )  )  
				 
/************************************************************************************/
SBOErr	CTransactionJournalObject::SetToZeroOldLineTypeCols ()
{
	_TRACER ("SetToZeroOldLineTypeCols");
	SBOErr			ooErr = noErr;

	PDAG			dagJDT1 = GetDAG (JDT, ao_Arr1);

	DBD_Conditions	*conditions = &(dagJDT1->GetDBDParams ()->GetConditions ());
	PDBD_Cond		condPtr;

	conditions->Clear ();

	// (T0.[TransType] = (24)  OR
	condPtr = &conditions->AddCondition ();
	condPtr->bracketOpen	= 1;
	condPtr->colNum			= JDT1_TRANS_TYPE;
	condPtr->operation		= DBD_EQ;
	condPtr->condVal		= RCT;
	condPtr->relationship	= DBD_OR;

	// T0.[TransType] = (46)) AND
	condPtr = &conditions->AddCondition ();
	condPtr->colNum			= JDT1_TRANS_TYPE;
	condPtr->operation		= DBD_EQ;
	condPtr->condVal		= VPM;
	condPtr->bracketClose	= 1;
	condPtr->relationship	= DBD_AND;

	// NOT EXISTS (JEs with LineType = 1 or 2) AND
	condPtr = &(conditions->AddCondition ());
	DBD_Params	subParams;
	condPtr->operation = DBD_NOT_EXISTS;
	condPtr->SetSubQueryParams (&subParams);
	condPtr->tableIndex = DBD_NO_TABLE;
	condPtr->relationship = 0;

	// -------------------------------------------------------------------- 
	// sub query
	// Sub-Tables
	CBizEnv		&bizEnv = GetEnv ();
	DBD_CondTables *subTables = &(subParams.GetCondTables ());	
	DBD_TablesList tablePtr = &subTables->AddTable ();
	tablePtr->tableCode = bizEnv.ObjectToTable (JDT, ao_Arr1);

	// Sub-ResStruct
	DBD_ResStruct subResStruct [1];
	subResStruct[0].tableIndex	= 0;
	subResStruct[0].colNum		= JDT1_TRANS_ABS;

	// Sub-Conditions
	DBD_Conditions *subConditions = &(subParams.GetConditions ());

	//  JDT1.[TransId] = JDT1.[TransId] AND 
	condPtr = &(subConditions->AddCondition ());
	condPtr->origTableIndex = 0; 
	condPtr->origTableLevel	= 1; // '1' means the main (not sub) query level
	condPtr->colNum = JDT1_TRANS_ABS;
	condPtr->operation = DBD_EQ;
	condPtr->compareCols = true;
	condPtr->compTableIndex = 0;
	condPtr->compColNum = JDT1_TRANS_ABS;
	condPtr->relationship = DBD_AND;

	// JDT1.[ShortName] <> JDT1.[Account] AND
	condPtr = &(subConditions->AddCondition ());
	condPtr->tableIndex = 0; 
	condPtr->colNum = JDT1_SHORT_NAME;
	condPtr->operation = DBD_NE;
	condPtr->compareCols = true;
	condPtr->compTableIndex = 0;
	condPtr->compColNum = JDT1_ACCT_NUM;
	condPtr->relationship = DBD_AND;

	// JDT1.[LineType] = 1 AND
	condPtr = &(subConditions->AddCondition ());
	condPtr->tableIndex = 0; 
	condPtr->colNum = JDT1_LINE_TYPE;
	condPtr->operation = DBD_NE;
	condPtr->condVal = (long)ooCtrlAct_DPRequestType;
	condPtr->relationship = DBD_AND;

	// (T0.[LineType] = 1  OR  
	condPtr = &(subConditions->AddCondition ());
	condPtr->tableIndex = 0; 
	condPtr->colNum = JDT1_LINE_TYPE;
	condPtr->operation = DBD_NE;
	condPtr->condVal = (long)ooCtrlAct_PaidDPRequestType;
	condPtr->relationship = 0;

	DBD_UpdStruct	updateStruct [1];
	updateStruct [0].colNum = JDT1_LINE_TYPE;
	updateStruct [0].updateVal = 0L;

	ooErr = DBD_SetDAGUpd (dagJDT1, updateStruct, 1);
	if (ooErr)
	{
		return ooErr;
	}

	// update data in database
	ooErr = DBD_UpdateCols (dagJDT1);
	if (ooErr)
	{
		return ooErr;
	}

	return ooErr;
}

/************************************************************************************/
/************************************************************************************/
SBOErr	CTransactionJournalObject::CompleteTrans ()
{
        _TRACER("CompleteTrans");
	SBOErr		dbErr;
	PDAG		dagJDT,	dagJDT1, dagCRD;
	long		numOfRecs, rec, transType;
	Date		curDate;
	Currency	mainCurrency;
	TCHAR		shortName[JDT1_SHORT_NAME_LEN+1];
	CBizEnv		&bizEnv = GetEnv ();

	_STR_strcpy (mainCurrency,bizEnv.GetMainCurrency ());
	dagJDT = GetDAG (JDT);
	dagJDT1 = GetDAG (JDT, ao_Arr1);
	dagCRD = GetDAG (CRD);

	DAG_GetCount (dagJDT, &numOfRecs);

	if (!numOfRecs)
	{
		DAG_SetSize (dagJDT, 1, dbmDropData);
	}

	if (dagJDT->IsNullCol (OJDT_REF_DATE, 0))
	{
		if (dagJDT1->IsNullCol (JDT1_DUE_DATE, 0))
		{
			DBM_DATE_Get (curDate, GetEnv ());
		}
		else
		{
			dagJDT1->GetColStr (curDate, JDT1_DUE_DATE, 0);
		}

		dagJDT->SetColStr (curDate, OJDT_REF_DATE, 0);
	}
	else
	{
		dagJDT->GetColStr (curDate, OJDT_REF_DATE, 0);
	}
	
	dagJDT->GetColLong (&transType, OJDT_TRANS_TYPE, 0);
	if (transType == -1)
	{
		dagJDT->SetColLong (JDT, OJDT_TRANS_TYPE, 0);
	}
	
	if (dagJDT->IsNullCol (OJDT_DUE_DATE, 0))
	{
		dagJDT->CopyColumn (dagJDT, OJDT_DUE_DATE, 0, OJDT_REF_DATE, 0);
	}
	else
	{
		dagJDT->GetColStr (curDate, OJDT_DUE_DATE, 0);
	}

	if (dagJDT->IsNullCol (OJDT_TAX_DATE, 0))
	{
		dagJDT->CopyColumn (dagJDT, OJDT_TAX_DATE, 0, OJDT_REF_DATE, 0);
	}

	DAG_GetCount (dagJDT1, &numOfRecs);
	if (numOfRecs <= 0)
	{
		Message (OBJ_MGR_ERROR_MSG, GO_NO_TOTAL_IN_DOC_LINES, NULL, OO_ERROR);
		return ooInvalidObject;
	}

	for (rec=0; rec<numOfRecs; rec++)
	{
		if (dagJDT1->IsNullCol (JDT1_DUE_DATE, rec))
		{
			dagJDT1->SetColStr (curDate, JDT1_DUE_DATE, rec);
		}

		if (dagJDT1->IsNullCol (JDT1_SHORT_NAME, rec))
		{
			dagJDT1->CopyColumn (dagJDT1, JDT1_SHORT_NAME, rec, JDT1_ACCT_NUM, rec);
		}
		else
		if (dagJDT1->IsNullCol (JDT1_ACCT_NUM, rec) &&
			!dagJDT1->IsNullCol (JDT1_SHORT_NAME, rec))
		{
			dagJDT1->GetColStr (shortName, JDT1_SHORT_NAME, rec);
			if (!_STR_IsSpacesStr(shortName))
			{
				dbErr = bizEnv.GetByOneKey (dagCRD, OCRD_KEYNUM_PRIMARY, shortName, true);
				if (dbErr)
				{
					dagJDT1->CopyColumn (dagJDT1, JDT1_ACCT_NUM, rec, JDT1_SHORT_NAME, rec);
				}
				else
				{
					dagJDT1->CopyColumn (dagCRD, JDT1_ACCT_NUM, rec, OCRD_DEB_PAY_ACCOUNT, 0);
				}
			}
		}
		if (dagJDT1->IsNullCol (JDT1_ACCT_NUM, rec) &&
			dagJDT1->IsNullCol (JDT1_SHORT_NAME, rec) &&
			bizEnv.IsVatPerLine () && !dagJDT1->IsNullCol (JDT1_VAT_GROUP, rec))
		{
			PDAG				dagRES;
			DBD_Tables		tableStruct[1] ;
			DBD_CondStruct	condStruct[1] ;
			DBD_ResStruct	resStruct[1] ;

			_STR_strcpy (tableStruct[0].tableCode, bizEnv.ObjectToTable (SBOString(VTG), ao_Main));

			resStruct[0].colNum = OVTG_ACCOUNT;

			condStruct[0].colNum = OVTG_GROUP_CODE;
			condStruct[0].operation = DBD_EQ;
			dagJDT1->GetColStr (condStruct[0].condVal, JDT1_VAT_GROUP, rec);
			_STR_LRTrim (condStruct[0].condVal);
			if (!condStruct[0].condVal.IsEmpty ())
			{
				DBD_SetTablesList (dagCRD, tableStruct, 1);
				DBD_SetDAGCond (dagCRD, condStruct, 1);
				DBD_SetDAGRes (dagCRD, resStruct, 1);

				dbErr = DBD_GetInNewFormat (dagCRD, &dagRES);
				if (!dbErr)
				{
					dagJDT1->CopyColumn (dagRES, JDT1_ACCT_NUM, rec, 0, 0);
					dagJDT1->CopyColumn (dagRES, JDT1_SHORT_NAME, rec, 0, 0);
				}
			}
		}
	}

	return ooNoErr;
}

//**********************************************************************************
//**********************************************************************************
SBOErr	CTransactionJournalObject::CompleteJdtLine ()
{
        _TRACER("CompleteJdtLine");
	SBOErr	ooErr = noErr;
	PDAG	dagJDT1 , dagJDT;
	long	rec, numOfRecs;
	long	lTmp;
	CBizEnv	&bizEnv = GetEnv ();
	bool	mbEnabled = false, isAutoCompleteBPLFromUD = false;
	CBusinessPlaceObject::BPLInfo bplInfo;
	
	dagJDT = GetDAG ();
	dagJDT1 = GetDAG ( JDT, ao_Arr1);

	DAG_GetCount (dagJDT1, &numOfRecs);

	mbEnabled = VF_MultiBranch_EnabledInOADM (bizEnv);
	isAutoCompleteBPLFromUD = mbEnabled && 
							  GetDataSource () == *VAL_OBSERVER_SOURCE &&
							  CBusinessPlaceObject::IsAutoCompleteBPLFromUserDefaults (GetID ().strtol ());
	for (rec=0; rec<numOfRecs; rec++)
	{
		// BPLname & VatRegNum completion
		if (mbEnabled)
		{
			// auto-complete BPLID to journal entry lines from user defaults if not set via DI API
			if (isAutoCompleteBPLFromUD && 
				!IsColumnChangedByDI (dagJDT1, rec, JDT1_BPL_ID) &&
				!CBusinessPlaceObject::IsValidBPLId (dagJDT1->GetColStr (JDT1_BPL_ID, rec, coreSystemDefault).strtol ()))
			{
				lTmp = bizEnv.GetUserDefaultBranch ();
				if (CBusinessPlaceObject::IsValidBPLId (lTmp))
				{
					dagJDT1->SetColLong (lTmp, JDT1_BPL_ID, rec);
					SetBPLId (lTmp);
				}
			}
			dagJDT1->GetColLong (&lTmp, JDT1_BPL_ID, rec);
			CBusinessPlaceObject::GetBPLInfo (bizEnv, lTmp, bplInfo);

			dagJDT1->SetColStr (bplInfo.GetBPLName (), JDT1_BPL_NAME, rec);
			dagJDT1->SetColStr (bplInfo.GetVatRegNum (), JDT1_VAT_REG_NUM, rec);
		}

		//Set line memo if is empty
		if (dagJDT1->IsNullCol (JDT1_LINE_MEMO, rec))
		{
			dagJDT1->CopyColumn (dagJDT, JDT1_LINE_MEMO, rec, OJDT_MEMO, 0);
		}

		//Set REF2/Ref's date
		if (dagJDT1->IsNullCol (JDT1_REF_DATE, rec))
		{
			dagJDT1->CopyColumn (dagJDT, JDT1_REF_DATE, rec, OJDT_REF_DATE, 0);

			// update valid from for ocr code
			SBOString	ocrCode, postDate;
			dagJDT1->GetColStr (ocrCode, JDT1_OCR_CODE, rec);
			dagJDT1->GetColStr (postDate, JDT1_REF_DATE, rec);
			
			SBOString	validFrom;
			COverheadCostRateObject::GetValidFrom (GetEnv (), ocrCode, postDate, validFrom);
			
			dagJDT1->SetColStr (validFrom, JDT1_VALID_FROM, rec);
		}

		//Set VAT date
		if ( VF_EnableVATDate (GetEnv ()) )
		{
			if (dagJDT1->IsNullCol (JDT1_VAT_DATE, rec))
			{
				dagJDT1->CopyColumn (dagJDT, JDT1_VAT_DATE, rec, OJDT_VAT_DATE, 0);
			}
		}

		//Set TAX date
		if (dagJDT1->IsNullCol (JDT1_TAX_DATE, rec))
		{
			dagJDT1->CopyColumn (dagJDT, JDT1_TAX_DATE, rec, OJDT_TAX_DATE, 0);
		}

		//Set REF2 if empty
		if (dagJDT1->IsNullCol (JDT1_REF2, rec))
		{
			dagJDT1->CopyColumn (dagJDT, JDT1_REF2, rec, OJDT_REF2, 0);
		}

		//Set REF1/REF3 if empty
		if (dagJDT1->IsNullCol (JDT1_REF1, rec))
		{
			dagJDT1->CopyColumn (dagJDT, JDT1_REF1, rec, OJDT_REF1, 0);
		}

		//Set Project Code if empty

		if (dagJDT1->IsNullCol (JDT1_PROJECT, rec))
		{
			SBOString projectCode;
			dagJDT->GetColStr (projectCode, OJDT_PROJECT,0);
			if (projectCode.IsEmpty ())
			{
				// load default account project code
				SBOString acctCode;
				CBizEnv		&bizEnv = GetEnv ();
				APCompanyDAG	dagACT;

				OpenDAG (dagACT, ACT);

				dagJDT1->GetColStr (acctCode, JDT1_ACCT_NUM, rec);
				ooErr = bizEnv.GetByOneKey (dagACT, OACT_KEYNUM_PRIMARY, acctCode);
				IF_ERROR_RETURN (ooErr);

				dagJDT1->CopyColumn (dagACT, JDT1_PROJECT, rec, OACT_PROJECT, 0);

			} else
			{
				dagJDT1->SetColStr (projectCode, JDT1_PROJECT, rec);
			}
		}

		//Set creator's data
		dagJDT1->CopyColumn (dagJDT, JDT1_TRANS_TYPE, rec, OJDT_TRANS_TYPE, 0);
		dagJDT1->CopyColumn (dagJDT, JDT1_BASE_REF, rec, OJDT_BASE_REF, 0);
		dagJDT1->CopyColumn (dagJDT, JDT1_CREATED_BY, rec, OJDT_CREATED_BY, 0);
	}

	return	ooErr;
}
/************************************************************************************/
/*
	SetJDTLineSrc: .
					 line			-	record offset in JDT lines DAG
					 absEntry		-
					 srcLine		-
*/
/************************************************************************************/

SBOErr	CTransactionJournalObject::SetJDTLineSrc (long line, long absEntry, long srcLine)
{
        _TRACER("SetJDTLineSrc");
	SBOErr	ooErr = noErr;
	PDAG	dagJDT1;

	dagJDT1 = GetDAG(JDT, ao_Arr1);
	if (!DAG_IsValid (dagJDT1))
	{
		return	(dbmBadDAG);
	}

	dagJDT1->SetColLong (absEntry, JDT1_SRC_ABS_ID, line);
	dagJDT1->SetColLong (srcLine, JDT1_SRC_LINE, line);

	return	ooErr;
}

/************************************************************************************/
SBOErr	CTransactionJournalObject::DoSingleStorno (bool checkDate /* = true */)
{
        _TRACER("DoSingleStorno");
	SBOErr			ooErr = noErr;
	long			fld1List[] = {JDT1_DEBIT, JDT1_CREDIT, JDT1_FC_CREDIT,
								  JDT1_FC_DEBIT, JDT1_SYS_CREDIT, JDT1_SYS_DEBIT,
								  JDT1_BASE_SUM, JDT1_SYS_BASE_SUM,
								  JDT1_VAT_AMOUNT, JDT1_SYS_VAT_AMOUNT,
								  JDT1_EQU_VAT_AMOUNT, JDT1_SYS_EQU_VAT_AMOUNT,
								  JDT1_TOTAL_TAX, JDT1_SYS_TOTAL_TAX,
								  JDT1_GROSS_VALUE, JDT1_GROSS_VALUE_FC, -1};
	long			fldList[] =  {OJDT_LOC_TOTAL, OJDT_FC_TOTAL, OJDT_SYS_TOTAL, -1};
	long			rec, count, ii, transType;
	long			transNum;

	TCHAR			keyStr[256];
	TCHAR			tmpStr[256], tmpStr2[128];
	TCHAR			msgStr[256]={0};

	Date			refDate, dueDate, taxDate;

	MONEY			money, zeroM;
	DBD_CondStruct	condStruct[2] ;
	DBD_UpdStruct	upd[2];
	DBM_CL			colsList;
	CBizEnv			&bizEnv = GetEnv ();

	PDAG dagJDT  = GetDAG ();
	PDAG dagJDT1 = GetDAG (JDT, ao_Arr1);

	dagJDT->GetColStr (keyStr, OJDT_JDT_NUM, 0);
	_STR_LRTrim (keyStr);

	// checking if tran was reversed by another user/from another window
	dagJDT->GetColLong (&transNum, OJDT_JDT_NUM, 0);
	condStruct[0].colNum = OJDT_STORNO_TO_TRANS;
	condStruct[0].condVal = transNum;
	condStruct[0].operation = DBD_EQ;
	condStruct[0].relationship = 0;

	DBD_SetDAGCond (dagJDT, condStruct, 1);

	if (DBD_Count (dagJDT, TRUE) > 0)
	{
		CMessagesManager::GetHandle()->Message(_1_APP_MSG_FIN_JDT_CANCELED_ERROR2, 
														  EMPTY_STR, 
														  this,
														  transNum);
		return ooInvalidObject;
	}
	
	// ************************** MultipleOpenPeriods *************************
	CPeriodCache* periodManager = bizEnv.GetPeriodCache();
	// ************************************************************************

	if (GetDataSource () != *VAL_OBSERVER_SOURCE)
	{
		dagJDT->GetColStr (refDate, OJDT_STORNO_DATE, 0);
		// ************************** MultipleOpenPeriods *************************
		if (checkDate && (coreNoCurrPeriodErr == bizEnv.CheckCompanyPeriodByDate (refDate)))
		// ************************************************************************
		{
			SetErrorLine( -1);
			SetErrorField(OJDT_REF_DATE);
			return (ooInvalidObject);
		}	
		dagJDT->SetColStr (refDate, OJDT_REF_DATE, 0);
		dagJDT->SetColStr (refDate, OJDT_TAX_DATE, 0);
		DAG_GetCount (dagJDT1, &count);
		for (rec = 0; rec < count; rec++)
		{
			dagJDT1->SetColStr (refDate, JDT1_REF_DATE, rec);

			// set valid from for profit code
			SBOString	ocrCode;
			dagJDT1->GetColStr (ocrCode, JDT1_OCR_CODE, rec);
			SBOString	validFrom;
			COverheadCostRateObject::GetValidFrom (bizEnv, ocrCode, refDate.GetString (), validFrom);
			
			dagJDT1->SetColStr (validFrom, JDT1_VALID_FROM, rec);
			
			dagJDT1->SetColStr (refDate, JDT1_TAX_DATE, rec);
		}
	}
	dagJDT->SetColStr (EMPTY_STR, OJDT_STORNO_DATE, 0);
	dagJDT->SetColStr (VAL_NO, OJDT_AUTO_STORNO, 0);
	dagJDT->SetColLong (0, OJDT_NUMBER, 0);

	if (GetDataSource () == *VAL_OBSERVER_SOURCE)
	{
		ooErr = dagJDT->GetChangesList (0, colsList);
		if (ooErr)
		{
			return ooErr;
		}

		// ************************** MultipleOpenPeriods *************************
		SBOString keyDate;
		dagJDT->GetColStr (keyDate, OJDT_REF_DATE);
		if (keyDate.Trim().IsEmpty())
			DBM_DATE_Get (keyDate, bizEnv);
		long periodID = periodManager->GetPeriodId (bizEnv, keyDate);
		// ************************************************************************

		DAG_GetCount (dagJDT1, &count);
		for (ii=0; ii<colsList.GetSize() ;ii++)
		{
			switch (colsList[ii]->GetColNum ()) 
			{
				case OJDT_REF_DATE:
					dagJDT->GetColStr (refDate, OJDT_REF_DATE, 0);
					// ************************** MultipleOpenPeriods *************************
					if (coreNoCurrPeriodErr == bizEnv.CheckCompanyPeriodByDate (refDate))
					// ************************************************************************
					{
						SetErrorLine( -1);
						SetErrorField(OJDT_REF_DATE);
						Message (OBJ_MGR_ERROR_MSG, GO_DATE_OUT_OF_LIMIT, NULL, OO_ERROR);
						return (ooInvalidObject);
					}	
					for (rec = 0; rec < count; rec++)
					{
						dagJDT1->CopyColumn (dagJDT, JDT1_REF_DATE, rec, OJDT_REF_DATE, 0);

						// set valid from for profit code
						SBOString	ocrCode;
						dagJDT1->GetColStr (ocrCode, JDT1_OCR_CODE, rec);
						SBOString	validFrom;
						COverheadCostRateObject::GetValidFrom (bizEnv, ocrCode, refDate.GetString (), validFrom);
						
						dagJDT1->SetColStr (validFrom, JDT1_VALID_FROM, rec);
					}
				break;				

				case OJDT_DUE_DATE:
					dagJDT->GetColStr (dueDate, OJDT_DUE_DATE, 0);
					// ************************** MultipleOpenPeriods *************************
					if (!periodManager->CheckDate (periodID, dueDate.GetString(), wdDueDate))
					// ************************************************************************
					{
						SetErrorLine( -1);
						SetErrorField(OJDT_DUE_DATE);
						Message (OBJ_MGR_ERROR_MSG, GO_DATE_OUT_OF_LIMIT, NULL, OO_ERROR);
						return (ooInvalidObject);
					}	
					for (rec = 0; rec < count; rec++)
					{
						dagJDT1->CopyColumn (dagJDT, JDT1_DUE_DATE, rec, OJDT_DUE_DATE, 0);
					}
				break;				

				case OJDT_TAX_DATE:
					dagJDT->GetColStr (taxDate, OJDT_TAX_DATE, 0);
					// ************************** MultipleOpenPeriods *************************
					if (!periodManager->CheckDate (periodID, taxDate.GetString(), wdTaxDate))
					// ************************************************************************
					{
						SetErrorLine( -1);
						SetErrorField(OJDT_TAX_DATE);
						Message (OBJ_MGR_ERROR_MSG, GO_DATE_OUT_OF_LIMIT, NULL, OO_ERROR);
						return (ooInvalidObject);
					}	
					for (rec = 0; rec < count; rec++)
					{
						dagJDT1->CopyColumn (dagJDT, JDT1_TAX_DATE, rec, OJDT_TAX_DATE, 0);
					}
				break;				

				case OJDT_REF1:
					for (rec = 0; rec < count; rec++)
					{
						dagJDT1->CopyColumn (dagJDT, JDT1_REF1, rec, OJDT_REF1, 0);
					}
				break;
				
				case OJDT_REF2:
					for (rec = 0; rec < count; rec++)
					{
						dagJDT1->CopyColumn (dagJDT, JDT1_REF2, rec, OJDT_REF2, 0);
					}
				break;				

				case OJDT_PROJECT:
					ooErr = ValidateRelations (ao_Main, 0, OJDT_PROJECT, PRJ);
					if (ooErr)
					{
						return ooErr;
					}
					for (rec = 0; rec < count; rec++)
					{
						dagJDT1->CopyColumn (dagJDT, JDT1_PROJECT, rec, OJDT_PROJECT, 0);
					}
				break;				

				case OJDT_INDICATOR:
					ooErr = ValidateRelations ( ao_Main, 0, OJDT_INDICATOR, IDC);
					if (ooErr)
					{
						return ooErr;
					}
					for (rec = 0; rec < count; rec++)
					{
						dagJDT1->CopyColumn (dagJDT, JDT1_INDICATOR, rec, OJDT_INDICATOR, 0);
					}
				break;				

				case OJDT_TRANS_CODE:
					ooErr = ValidateRelations (ao_Main, 0, OJDT_TRANS_CODE, TRC);
					if (ooErr)
					{
						return ooErr;
					}
					for (rec = 0; rec < count; rec++)
					{
						dagJDT1->CopyColumn (dagJDT, JDT1_TRANS_CODE, rec, OJDT_TRANS_CODE, 0);
					}
				break;

				case OJDT_MEMO:
					dagJDT1->GetColStr (tmpStr, OJDT_MEMO, 0);
					_STR_CleanExtendedEditMarks (tmpStr, ' ');
					_STR_LRTrim (tmpStr);
					dagJDT1->SetColStr (tmpStr, OJDT_MEMO, 0);
					for (rec = 0; rec < count; rec++)
					{				
						dagJDT1->CopyColumn (dagJDT, JDT1_LINE_MEMO, rec, OJDT_MEMO, 0);
					}
				break;
			}
		}
	}

    		
    
	if (bizEnv.GetUseNegativeAmount ())
	{
	//Revert totals
		for (ii=0; fldList[ii] >= 0; ii++)
		{
			dagJDT->GetColMoney (&money, fldList[ii], 0, DBM_NOT_ARRAY);
			MONEY_Multiply (&money, -1, &money);
			dagJDT->SetColMoney (&money, fldList[ii], 0, DBM_NOT_ARRAY);
		}

	//Revert line amounts
		DAG_GetCount (dagJDT1, &count);
		for (rec = 0; rec < count; rec++)
		{
			for (ii=0; fld1List[ii] >= 0; ii++)
			{
				dagJDT1->GetColMoney (&money, fld1List[ii], rec, DBM_NOT_ARRAY);
				MONEY_Multiply (&money, -1, &money);
				dagJDT1->SetColMoney (&money, fld1List[ii], rec, DBM_NOT_ARRAY);
			}
		}
	}
	else
	{
	//Revert line amounts
		DAG_GetCount (dagJDT1, &count);
		for (rec = 0; rec < count; rec++)
		{
			dagJDT1->GetColMoney (&money, JDT1_DEBIT, rec, DBM_NOT_ARRAY);
			if (!money.IsZero())
			{
				dagJDT1->SetColMoney (&money, JDT1_CREDIT, rec, DBM_NOT_ARRAY);
				dagJDT1->SetColMoney (&zeroM, JDT1_DEBIT, rec, DBM_NOT_ARRAY);
				dagJDT1->SetColStr(VAL_CREDIT, JDT1_DEBIT_CREDIT, rec);
			}
			else
			{
				dagJDT1->GetColMoney (&money, JDT1_CREDIT, rec, DBM_NOT_ARRAY);
				if (!money.IsZero())
				{
					dagJDT1->SetColMoney (&money, JDT1_DEBIT, rec, DBM_NOT_ARRAY);
					dagJDT1->SetColMoney (&zeroM, JDT1_CREDIT, rec, DBM_NOT_ARRAY);
					dagJDT1->SetColStr(VAL_DEBIT, JDT1_DEBIT_CREDIT, rec);
				}
			}

			dagJDT1->GetColMoney (&money, JDT1_FC_DEBIT, rec, DBM_NOT_ARRAY);
			if (!money.IsZero())
			{
				dagJDT1->SetColMoney (&money, JDT1_FC_CREDIT, rec, DBM_NOT_ARRAY);
				dagJDT1->SetColMoney (&zeroM, JDT1_FC_DEBIT, rec, DBM_NOT_ARRAY);
				dagJDT1->SetColStr(VAL_CREDIT, JDT1_DEBIT_CREDIT, rec);
			}
			else
			{
				dagJDT1->GetColMoney (&money, JDT1_FC_CREDIT, rec, DBM_NOT_ARRAY);
				if (!money.IsZero())
				{
					dagJDT1->SetColMoney (&money, JDT1_FC_DEBIT, rec, DBM_NOT_ARRAY);
					dagJDT1->SetColMoney (&zeroM, JDT1_FC_CREDIT, rec, DBM_NOT_ARRAY);
					dagJDT1->SetColStr(VAL_DEBIT, JDT1_DEBIT_CREDIT, rec);
				}
			}

			dagJDT1->GetColMoney (&money, JDT1_SYS_DEBIT, rec, DBM_NOT_ARRAY);
			if (!money.IsZero())
			{
				dagJDT1->SetColMoney (&money, JDT1_SYS_CREDIT, rec, DBM_NOT_ARRAY);
				dagJDT1->SetColMoney (&zeroM, JDT1_SYS_DEBIT, rec, DBM_NOT_ARRAY);
				dagJDT1->SetColStr(VAL_CREDIT, JDT1_DEBIT_CREDIT, rec);
			}
			else
			{
				dagJDT1->GetColMoney (&money, JDT1_SYS_CREDIT, rec, DBM_NOT_ARRAY);
				if (!money.IsZero())
				{
					dagJDT1->SetColMoney (&money, JDT1_SYS_DEBIT, rec, DBM_NOT_ARRAY);
					dagJDT1->SetColMoney (&zeroM, JDT1_SYS_CREDIT, rec, DBM_NOT_ARRAY);
					dagJDT1->SetColStr(VAL_DEBIT, JDT1_DEBIT_CREDIT, rec);
				}
			}

		}
	}

	// clear external reconciliation references (was in OnCreate prior to 2007A SP00 PL44)
	for (rec = 0; rec < count; rec++)
	{
		dagJDT1->SetColLong(0, JDT1_EXTR_MATCH, rec);
	}

	//Add comments
	dagJDT->GetColLong (&transNum, OJDT_JDT_NUM, 0);
	dagJDT->SetColLong (transNum, OJDT_STORNO_TO_TRANS, 0);
	dagJDT->GetColStr (tmpStr, OJDT_MEMO, 0);
	_STR_LRTrim (tmpStr);
	_STR_GetStringResource (tmpStr2, JTE_JDT_FORM_NUM, JTE_STORNO_STR, &GetEnv());
	_STR_strcat (tmpStr, tmpStr2);

	_STR_LRTrim (tmpStr);
	_STR_ltoa (transNum, tmpStr2);
	_STR_strcat (tmpStr, _T(" - "));
	_STR_strcat (tmpStr, tmpStr2);
	dagJDT->SetColStr (tmpStr, OJDT_MEMO, 0);

	_STR_GetStringResource (tmpStr2, JTE_JDT_FORM_NUM, JTE_STORNO_STR, &GetEnv());
	_STR_LRTrim (tmpStr2);
	_STR_ltoa (transNum, tmpStr);
	_STR_strcat (tmpStr2, _T(" - "));
	_STR_strcat (tmpStr2, tmpStr);

	for (rec = 0; rec < count; rec++)
	{
		dagJDT1->GetColStr (tmpStr, JDT1_LINE_MEMO, rec);
		_STR_LRTrim (tmpStr);
		_STR_strcat (tmpStr, tmpStr2);
		_STR_LRTrim (tmpStr);
		dagJDT1->SetColStr (tmpStr, JDT1_LINE_MEMO, rec);
		dagJDT1->SetColStr (VAL_NO, JDT1_ORDERED, rec);
	}

// [CostAcctingEnh] Duplicate manual distribution rule when reverse the JE
	if(VF_CostAcctingEnh(GetEnv()))
	{
		SBOString	mdr(MDR);
		CManualDistributionRuleObject *mdrObj = static_cast<CManualDistributionRuleObject*>(GetEnv().CreateBusinessObject(mdr));

		SBOString	dim(DIM);
		DimensionInfo	dimInfo[DIMENSION_MAX];
		CCostAccountingDimension *dimObj = static_cast<CCostAccountingDimension*>(GetEnv().CreateBusinessObject(dim));
		dimObj->DIMGetAllDimensionsInfo(dimInfo);

		TCHAR	mdrCodeSrc[OOCR_OCR_CODE_LEN+1], mdrCodeDst[OOCR_OCR_CODE_LEN+1];	
		long	cols[DIMENSION_MAX] = {JDT1_OCR_CODE, JDT1_OCR_CODE2, JDT1_OCR_CODE3, JDT1_OCR_CODE4, JDT1_OCR_CODE5};
		long	recCount = dagJDT1->GetRecordCount();
		for	(long j = 0; j< recCount; j++)
		{
			for(int i = 0; i< DIMENSION_MAX; i++)
			{
				if (dimInfo[i].DimActive)
				{
					dagJDT1->GetColStr(mdrCodeSrc, cols[i], j);
					if(mdrObj->RuleIsManual(mdrCodeSrc))
					{
						mdrObj->DuplicateManualRule (mdrCodeSrc, mdrCodeDst, TRUE);
						dagJDT1->SetColStr(mdrCodeDst, cols[i], j);
					}
				}
			}
		}
// SBO_APA_DEV_SUP	Joe Li(I032514)	2005/12/7	Fix bug: 4512226: B1 crashed when post 4000 journal vouchers to JE
		dimObj->Destroy();
// SBO_APA_DEV_SUP	End
		
		mdrObj->Destroy();
	}
	
	long servicePostingSourceId;
	dagJDT->GetColLong (&servicePostingSourceId, OJDT_SERV_POST_SRC_ID);
	dagJDT->GetColLong(&transType, OJDT_TRANS_TYPE);
	if (transType == JDT || (transType == WTR && VF_ExciseInvoice (bizEnv) && this->m_isVatJournalEntry)
		|| (transType == DLN && VF_ServiceTax_EnabledInOADM (bizEnv) && servicePostingSourceId > 0))
	{
		ooErr = LoadTax();
		if (ooErr)
		{
			return ooErr;
		}
		GetTaxAdaptor()->Revert(bizEnv.GetUseNegativeAmount ());
	}

	if (m_stornoExtraInfoCreator)
	{
		ooErr = m_stornoExtraInfoCreator->Execute();
		if (ooErr)
		{
			return	ooErr;
		}		
	}
	
	SetCompanyPeriodByDate (); // MultipleOpenPeriods

	ooErr = OnIsValid();
	if (ooErr)
	{
		ResetCompanyPeriod (); // MultipleOpenPeriods
		return ooErr;
	}
	// Make reversal Cash Flow Transaction.
	if(VF_CashflowReport(bizEnv))
	{
		PDAG		dagCFT, dagReversalCFT;
		SBOString	objCFTId(CFT);

		dagCFT = GetDAG (CFT);
		dagJDT->GetColLong (&transNum, OJDT_JDT_NUM, 0);
		CCashFlowTransactionObject	*bo = static_cast<CCashFlowTransactionObject*>(CreateBusinessObject(CFT));
		bo->OCFTLookupByJDT (-1, transNum, -1, JDT, dagCFT);
		dagCFT->Duplicate (&dagReversalCFT, dbmKeepData);
		bo->OCFTCreateReversal (dagReversalCFT, dagCFT);
		DAG_Close(dagReversalCFT);
		bo->Destroy();
	}

	// Set approver to be current user, IM: 178724 2008
	if (VF_FIReleaseProc (bizEnv))
	{
		SBOString approver;
		CEmployeeObject::HEMGetEmployeeNameByUsrCode(approver, bizEnv, bizEnv.GetUserCode(), true);
		dagJDT->SetColStr(approver, OJDT_APPROVER_NAME, 0);
	}
	// IM: 178724 2008

	ooErr = OnCreate();
	if (ooErr)
	{
		ResetCompanyPeriod (); // MultipleOpenPeriods
		return ooErr;
	}
	ooErr = OnCheckIntegrityOnCreate();
	ResetCompanyPeriod (); // MultipleOpenPeriods

	IF_ERROR_RETURN (ooErr);	
	
	_STR_strcpy (condStruct[0].condVal, keyStr);
	_STR_LRTrim (condStruct[0].condVal);

	condStruct[0].colNum = OJDT_JDT_NUM;
	condStruct[0].operation = DBD_EQ;

	upd[0].colNum = OJDT_STORNO_DATE;
	upd[1].colNum = OJDT_AUTO_STORNO;
	_STR_strcpy (upd[1].updateVal, VAL_NO);

	DBD_SetDAGCond (dagJDT, condStruct, 1);
	DBD_SetDAGUpd (dagJDT, upd, 2);

	DBD_UpdateCols (dagJDT);

	return (ooErr);
}

//******************************************************************
//******************************************************************
SBOErr	CTransactionJournalObject::ReconcileCertainLines()
{
        _TRACER("ReconcileCertainLines");
	SBOErr			ooErr = noErr;
	PDAG			dagJdt1, dagJdt;
	PDAG			dagDupJdt1, dagRES;
	SBOString		shortName, BPOrACTCode;
	TCHAR			keyStr[256];
	long			transNum, newTransNum;
	long			numOfConds = 0;
	long			rec, numOfRecs;
	long			BPOrACT_rec, numOfBPOrACTs;
	Date			date;
	CBizEnv			&bizEnv = GetEnv ();
	DBD_CondStruct	condStruct[3];
	DBD_ResStruct	resStruct[1];
	CSystemMatchManager *pMM = NULL;	
	bool			shouldAddLine2Match = true;
	bool			shouldCancelRecons = true;

	dagJdt = GetDAG();
	dagJdt1 = GetDAG(JDT, ao_Arr1);

	dagJdt->GetColStr (date, OJDT_REF_DATE, 0);
	dagJdt->GetColLong (&transNum, OJDT_STORNO_TO_TRANS, 0);
	dagJdt->GetColLong (&newTransNum, OJDT_JDT_NUM, 0);

	condStruct[numOfConds].colNum = JDT1_TRANS_ABS;
	condStruct[numOfConds].operation = DBD_EQ;
	condStruct[numOfConds].condVal = transNum;
	condStruct[numOfConds++].relationship = DBD_AND;

	condStruct[numOfConds].colNum = JDT1_ACCT_NUM;
	condStruct[numOfConds].operation = DBD_NE;
	condStruct[numOfConds].compareCols = TRUE;
	condStruct[numOfConds].compColNum = JDT1_SHORT_NAME;
	condStruct[numOfConds++].relationship = 0;

	DBD_SetDAGCond (dagJdt1, condStruct, numOfConds);

	resStruct[0].colNum = JDT1_SHORT_NAME;
	resStruct[0].group_by = true;

	DBD_SetDAGRes (dagJdt1, resStruct, 1);

	ooErr = DBD_GetInNewFormat (dagJdt1, &dagRES);
	if (m_isInCancellingAcctRecon)
	{
		dagRES->SetSize (m_reconAcctSet.size (), dbmDropData);
		std::set<SBOString>::iterator itr = m_reconAcctSet.begin ();
		for (long rec = 0; itr != m_reconAcctSet.end (); ++itr)
		{
			dagRES->SetColStr (*itr, 0, rec);
			rec++;
		}
	}
	else if (ooErr)
	{
		return ooNoErr;
	}
	DAG_GetCount (dagRES, &numOfBPOrACTs);

	ooErr = dagJdt1->Duplicate (&dagDupJdt1, dbmDropData);
	if (ooErr)
	{
		return ooErr;
	}
	DAG_SetSize (dagDupJdt1, 1, dbmDropData);
	dagJdt->GetColStr (keyStr, OJDT_STORNO_TO_TRANS, 0);
	_STR_LRTrim (keyStr);

	ooErr = DBD_GetKeyGroup (dagDupJdt1, JDT1_KEYNUM_PRIMARY, keyStr, TRUE);
	if (ooErr)
	{
		DAG_Close (dagDupJdt1);
		return (ooErr);
	}

	DAG_GetCount (dagRES, &numOfBPOrACTs);
	for (BPOrACT_rec = 0; BPOrACT_rec < numOfBPOrACTs; BPOrACT_rec++)
	{
		pMM = new CSystemMatchManager(bizEnv, m_isInCancellingAcctRecon == false, date.GetString (), JDT, transNum, rt_Reversal);
		dagRES->GetColStr (BPOrACTCode, 0, BPOrACT_rec);
		BPOrACTCode.Trim();

		DAG_GetCount (dagJdt1, &numOfRecs);
		for (rec = 0; rec < numOfRecs; rec++)
		{
			shouldAddLine2Match = true;
			dagJdt1->GetColStr (shortName, JDT1_SHORT_NAME, rec);
			shortName.Trim();

			if (shortName == BPOrACTCode)
			{
				if (m_stornoExtraInfoCreator)
				{
					shouldAddLine2Match = m_stornoExtraInfoCreator->IsNeedToAddLineToReconciliation(dagJdt1, rec, false);
				}
				if (shouldAddLine2Match)
				{
					pMM->AddMatchDataLine (newTransNum, rec);
				}
			}
		}
		DAG_GetCount (dagDupJdt1, &numOfRecs);
		for (rec = 0; rec < numOfRecs; rec++)
		{
			shouldAddLine2Match = true;
			shouldCancelRecons = true;
			dagDupJdt1->GetColStr (shortName, JDT1_SHORT_NAME, rec);
			shortName.Trim();
			if (shortName == BPOrACTCode)
			{
				if (m_stornoExtraInfoCreator)
				{
					if (!m_stornoExtraInfoCreator->IsNeedToCancelReconForThisLine(dagDupJdt1, rec))
					{
						shouldCancelRecons = false;
					}
				}
				if (shouldCancelRecons)
				{
					ooErr = CManualMatchManager::CancelAllReconsOfJournalLine(bizEnv, transNum, rec);
					if (ooErr)
					{
						DAG_Close (dagDupJdt1);
						delete pMM;
						return (ooErr);
					}
				}
				if (m_stornoExtraInfoCreator)
				{
					shouldAddLine2Match = m_stornoExtraInfoCreator->IsNeedToAddLineToReconciliation(dagDupJdt1, rec, true);
				}
				if (shouldAddLine2Match)
				{
					pMM->AddMatchDataLine (transNum, rec);
				}
			}
		}
		ooErr =  pMM->Reconcile ();
		delete pMM;
		if (ooErr)
		{
			DAG_Close (dagDupJdt1);
			return ooErr;
		}
	}

	DAG_Close (dagDupJdt1);

	return ooErr;
}


/*******************************************************************
 Function name		: UpgradeBoeActs
 Description	    : Change all Boe account lines of the specific type
					  set their short name like account and get new 
					  internal match num
 Return type		: SBOErr  
 Argument			: none
********************************************************************/
SBOErr	 CTransactionJournalObject::UpgradeBoeActs()
{
        _TRACER("UpgradeBoeActs");
	SBOErr			ooErr;
	PDAG			dagCRD, dagACT, dagJDT1, dagRES=NULL, dagRES2=NULL, dagAnswer= NULL;
	DBD_CondStruct	*updateCardBalanceCond, *updateActBalanceCond, *cond, condStruct[13];
	DBD_Tables		tableStruct[4];
	DBD_CondStruct	joinCondStruct[1], joinCondStructForOtherObj[2], joinCondStructBoe[2];
	DBD_ResStruct	resStruct[RES_NUM_OF_RES];
	DBD_UpdStruct	updStruct [2];
	long			tmpL, numOfCardConds=0, numOfActsConds=0, numOfConds=0, numOfRecs, rec, ii;
	Boolean			firstAct ,firstErr = FALSE;
	long			intrnMatch, matchNum, columns[] = {RES_ACCT_NUM, RES_SHORT_NAME, RES_INTR_MATCH};
	Boolean			orders[] = {FALSE, FALSE, TRUE};
	TCHAR			savedShortName[JDT1_SHORT_NAME_LEN+1],shortName[JDT1_SHORT_NAME_LEN+1], savedAcc[JDT1_ACCT_NUM_LEN+1], tmpStr[256];
	CBizEnv			&bizEnv = GetEnv ();
	long			iterationType[]={JDT_BOT_TYPE, JDT_RCT_TYPE, JDT_DPS_TYPE};
	long			totalNumOfIterations =0, numOfIterations=0, numOfTables=0;

	if (!bizEnv.IsLocalSettingsFlag(lsf_EnableBOE)) 
	{
		return ooNoErr;
	}
	
	if (UpgradeVersionCheck (OJDT_BOE_CONTROL_ACTS_VEND_VER))
	{
		ooErr = FixVendorsAndSpainBoeBalance();
		if (ooErr)
		{
			return ooErr;
		}	
	}
	/************************************************************************/
	/* No need to fix the lines (short name) of the spanish customers.      */
	/************************************************************************/
	if (VF_BOEAsInSpain (bizEnv))
	{
		return ooNoErr;
	}

	_STR_strcpy (tableStruct[0].tableCode, bizEnv.ObjectToTable (JDT, ao_Arr1));
	dagJDT1 = OpenDAG (JDT, ao_Arr1);

	if (bizEnv.IsCurrentLocalSettings (FRANCE_SETTINGS) ||
		VF_OpenFRBoE(bizEnv))
	{
		totalNumOfIterations = 3;
	}
	else
	{
		totalNumOfIterations = 2;
	}

	for (ii=0; ii < NUM_OF_BOE_ITERATIONS ; ii++)
	{
		if (!(bizEnv.IsCurrentLocalSettings (FRANCE_SETTINGS) ||
			VF_OpenFRBoE(bizEnv)) && iterationType[ii] == JDT_RCT_TYPE) 
		{
			continue;
		}
		
		_STR_strcpy (tableStruct[0].tableCode, bizEnv.ObjectToTable (JDT, ao_Arr1));
		numOfTables = 1;
		
		BuildRelatedBoeQuery(tableStruct, &numOfConds, iterationType[ii], &numOfTables, condStruct,	joinCondStructForOtherObj, joinCondStructBoe);
		
		// CRD3
		_STR_strcpy (tableStruct[numOfTables++].tableCode, bizEnv.ObjectToTable (CRD, ao_Arr3));
		
		tableStruct[numOfTables-1].doJoin = TRUE;
		tableStruct[numOfTables-1].joinedToTable = 0;
		tableStruct[numOfTables-1].numOfConds = 1;
		tableStruct[numOfTables-1].joinConds = joinCondStruct;
		
			joinCondStruct[0].compareCols = TRUE;
			joinCondStruct[0].compTableIndex = 0;
			joinCondStruct[0].compColNum = JDT1_ACCT_NUM;
			joinCondStruct[0].tableIndex = numOfTables-1;
			joinCondStruct[0].colNum = CRD3_ACCOUNT_CODE;
			joinCondStruct[0].operation = DBD_EQ;		
		
		condStruct[numOfConds].compareCols = TRUE;
		condStruct[numOfConds].colNum = JDT1_SHORT_NAME;
		condStruct[numOfConds].operation = DBD_NE;
		condStruct[numOfConds].compColNum = JDT1_ACCT_NUM;
		condStruct[numOfConds].tableIndex = 0;
		condStruct[numOfConds++].relationship = DBD_AND;
		
		condStruct[numOfConds].compareCols = TRUE;
		condStruct[numOfConds].colNum = JDT1_SHORT_NAME;
		condStruct[numOfConds].operation = DBD_EQ;
		condStruct[numOfConds].compColNum = CRD3_CARD_CODE;
		condStruct[numOfConds].tableIndex = 0;
		condStruct[numOfConds].compTableIndex = numOfTables-1;
		condStruct[numOfConds++].relationship = DBD_AND;
	
		// first bring the account from the card
		if (bizEnv.IsCurrentLocalSettings (ITALY_SETTINGS))
		{		
			condStruct[numOfConds].tableIndex = numOfTables-1;
			condStruct[numOfConds].colNum = CRD3_ACCOUNT_TYPE;
			_STR_strcpy (condStruct[numOfConds].condVal, ARP_TYPE_BoE_PRESENTATION); 
			condStruct[numOfConds].operation = DBD_EQ;
			condStruct[numOfConds++].relationship = 0;
			
		}
		else if (bizEnv.IsCurrentLocalSettings (FRANCE_SETTINGS) ||
				VF_OpenFRBoE(bizEnv))
		{
			condStruct[numOfConds].bracketOpen = 1;
			condStruct[numOfConds].tableIndex = numOfTables-1;
			condStruct[numOfConds].colNum = CRD3_ACCOUNT_TYPE;
			_STR_strcpy (condStruct[numOfConds].condVal, ARP_TYPE_BoE_ON_COLLECTION); 
			condStruct[numOfConds].operation = DBD_EQ;
			condStruct[numOfConds++].relationship = DBD_OR;
			
			condStruct[numOfConds].tableIndex = numOfTables-1;
			condStruct[numOfConds].colNum = CRD3_ACCOUNT_TYPE;
			_STR_strcpy (condStruct[numOfConds].condVal, ARP_TYPE_BoE_DISCOUNTED); 
			condStruct[numOfConds].operation = DBD_EQ;
			condStruct[numOfConds++].relationship = DBD_OR;
			
			condStruct[numOfConds].tableIndex = numOfTables-1;
			condStruct[numOfConds].colNum = CRD3_ACCOUNT_TYPE;
			_STR_strcpy (condStruct[numOfConds].condVal, ARP_TYPE_UNPAID_BoE); 
			condStruct[numOfConds].operation = DBD_EQ;
			condStruct[numOfConds].bracketClose = 1;
			condStruct[numOfConds++].relationship = 0;
		}
		else if (bizEnv.IsCurrentLocalSettings (PORTUGAL_SETTINGS) ||
				VF_Boleto(bizEnv))
		{
			condStruct[numOfConds].bracketOpen = 1;
			condStruct[numOfConds].tableIndex = numOfTables-1;
			condStruct[numOfConds].colNum = CRD3_ACCOUNT_TYPE;
			_STR_strcpy (condStruct[numOfConds].condVal, ARP_TYPE_BoE_PRESENTATION); 
			condStruct[numOfConds].operation = DBD_EQ;
			condStruct[numOfConds++].relationship = DBD_OR;
			
			condStruct[numOfConds].tableIndex = numOfTables-1;
			condStruct[numOfConds].colNum = CRD3_ACCOUNT_TYPE;
			_STR_strcpy (condStruct[numOfConds].condVal, ARP_TYPE_BoE_DISCOUNTED); 
			condStruct[numOfConds].operation = DBD_EQ;
			condStruct[numOfConds].bracketClose = 1;
			condStruct[numOfConds++].relationship = 0;
		}
		
		condStruct[numOfConds-1].relationship = 0;
		
		resStruct[RES_TRANS_ABS].colNum = JDT1_TRANS_ABS;
		resStruct[RES_TRANS_ABS].tableIndex = 0;
		resStruct[RES_LINE_ID].colNum = JDT1_LINE_ID;
		resStruct[RES_LINE_ID].tableIndex = 0;
		resStruct[RES_ACCT_NUM].colNum = JDT1_ACCT_NUM;
		resStruct[RES_ACCT_NUM].tableIndex = 0;
		resStruct[RES_INTR_MATCH].colNum = JDT1_INTR_MATCH;
		resStruct[RES_INTR_MATCH].tableIndex = 0;
		resStruct[RES_SHORT_NAME].colNum = JDT1_SHORT_NAME;
		resStruct[RES_SHORT_NAME].tableIndex = 0;
		
		DBD_SetDAGCond (dagJDT1, condStruct, numOfConds);
		DBD_SetDAGRes (dagJDT1, resStruct, RES_NUM_OF_RES);
		DBD_SetTablesList (dagJDT1, tableStruct, numOfTables);
		
		ooErr = DBD_GetInNewFormat (dagJDT1, &dagAnswer);
		dagAnswer->Detach();
		
		if (!ooErr && numOfConds > 1)
		{
			if (NULL != dagRES) 
			{
				dagRES->Concat (dagAnswer, dbmDataBuffer);
			}
			else
			{
				dagAnswer->Duplicate (&dagRES, dbmKeepData);
			}
			DAG_Close(dagAnswer);
			dagAnswer = NULL;
		}
		else if (ooErr == dbmNoDataFound) 
		{
			numOfIterations++;
			if (numOfIterations == totalNumOfIterations) 
			{
				// in the last iteration - create the dagRES in the right format for further query
				dagAnswer->Duplicate (&dagRES, dbmKeepData);
				DAG_SetSize(dagRES, 0, dbmDropData);
			}
			DAG_Close(dagAnswer);
			dagAnswer = NULL;
		}
		else if (ooErr)
		{
			DAG_Close(dagAnswer);
			if (dagRES) 
			{
				DAG_Close(dagRES);
			}
			DAG_Close (dagJDT1);
			return ooErr;
		}
		
		// now get the accounts from OADM	
		_MEM_Clear(condStruct, numOfConds);
		_MEM_Clear(tableStruct, numOfTables);
		numOfConds = 0;
		numOfTables = 0;
	}
	
	
	for (ii=0; ii < NUM_OF_BOE_ITERATIONS ; ii++)
	{
		if (!(bizEnv.IsCurrentLocalSettings (FRANCE_SETTINGS) ||
			VF_OpenFRBoE(bizEnv)) && iterationType[ii] == JDT_RCT_TYPE) 
		{
			continue;
		}
		_MEM_Clear(condStruct, numOfConds);
		_MEM_Clear(tableStruct, numOfTables);
		numOfConds = 0;
		numOfTables = 0;
		
		_STR_strcpy (tableStruct[numOfTables++].tableCode, bizEnv.ObjectToTable (JDT, ao_Arr1));
		
		condStruct[numOfConds].compareCols = TRUE;
		condStruct[numOfConds].colNum = JDT1_SHORT_NAME;
		condStruct[numOfConds].operation = DBD_NE;
		condStruct[numOfConds].compColNum = JDT1_ACCT_NUM;
		condStruct[numOfConds].tableIndex = 0;
		condStruct[numOfConds++].relationship = DBD_AND;
		
		BuildRelatedBoeQuery(tableStruct, &numOfConds, iterationType[ii], &numOfTables, condStruct,	joinCondStructForOtherObj, joinCondStructBoe);
		
		
		if (bizEnv.IsCurrentLocalSettings (ITALY_SETTINGS))
		{		
			ooErr = ARP_GetAccountByType (GetEnv(), NULL, ARP_TYPE_BoE_PRESENTATION, tmpStr, TRUE, VAL_CUSTOMER);
			if (!ooErr && !_STR_IsSpacesStr(tmpStr)) 
			{
				_STR_strcpy (condStruct[numOfConds].condVal, tmpStr);
				condStruct[numOfConds].tableIndex = 0;
				condStruct[numOfConds].colNum = JDT1_ACCT_NUM;
				condStruct[numOfConds].operation = DBD_EQ;
				condStruct[numOfConds++].relationship = 0;
			}
		}
		else if (bizEnv.IsCurrentLocalSettings (FRANCE_SETTINGS) ||
				VF_OpenFRBoE(bizEnv))
		{
			//--[FixCoreBugBySelf]--Start----------------------------
			long cmpNumOfConds = 0;
			cmpNumOfConds = numOfConds;
			//--[ FixCoreBugBySelf]--End------------------------------

			condStruct[numOfConds].bracketOpen = 1;
			ooErr = ARP_GetAccountByType (GetEnv(), NULL, ARP_TYPE_BoE_ON_COLLECTION, tmpStr, TRUE, VAL_CUSTOMER);
			if (!ooErr && !_STR_IsSpacesStr(tmpStr)) 
			{
				_STR_strcpy (condStruct[numOfConds].condVal, tmpStr);
				condStruct[numOfConds].tableIndex = 0;
				condStruct[numOfConds].colNum = JDT1_ACCT_NUM;
				condStruct[numOfConds].operation = DBD_EQ;
				condStruct[numOfConds].relationship = DBD_OR;
				numOfConds++;
			}
			ooErr = ARP_GetAccountByType (GetEnv(), NULL, ARP_TYPE_UNPAID_BoE, tmpStr, TRUE, VAL_CUSTOMER);
			if (!ooErr && !_STR_IsSpacesStr(tmpStr)) 
			{
				_STR_strcpy (condStruct[numOfConds].condVal, tmpStr);
				condStruct[numOfConds].tableIndex = 0;
				condStruct[numOfConds].colNum = JDT1_ACCT_NUM;
				condStruct[numOfConds].operation = DBD_EQ;
				condStruct[numOfConds].relationship = DBD_OR;
				numOfConds++;
			}
			ooErr = ARP_GetAccountByType (GetEnv(), NULL, ARP_TYPE_BoE_DISCOUNTED, tmpStr, TRUE, VAL_CUSTOMER);
			if (!ooErr && !_STR_IsSpacesStr(tmpStr)) 
			{
				_STR_strcpy (condStruct[numOfConds].condVal, tmpStr);
				condStruct[numOfConds].tableIndex = 0;
				condStruct[numOfConds].colNum = JDT1_ACCT_NUM;
				condStruct[numOfConds].operation = DBD_EQ;
				condStruct[numOfConds].relationship = 0;
				numOfConds++;
			}
			//--[FixCoreBugBySelf]--Start----------------------------
			//@ condStruct[numOfConds-1].bracketClose = 1;
			if (cmpNumOfConds < numOfConds)
			condStruct[numOfConds-1].bracketClose = 1;
			else
				condStruct[cmpNumOfConds].bracketClose = 1;
			//--[ FixCoreBugBySelf]--End------------------------------
		}
		else if (bizEnv.IsCurrentLocalSettings (PORTUGAL_SETTINGS) || VF_Boleto(bizEnv))
		{
			condStruct[numOfConds].bracketOpen = 1;
			ooErr = ARP_GetAccountByType (GetEnv(), NULL, ARP_TYPE_BoE_PRESENTATION, tmpStr, TRUE, VAL_CUSTOMER);
			if (!ooErr && !_STR_IsSpacesStr(tmpStr)) 
			{
				_STR_strcpy (condStruct[numOfConds].condVal, tmpStr);
				condStruct[numOfConds].tableIndex = 0;
				condStruct[numOfConds].colNum = JDT1_ACCT_NUM;
				condStruct[numOfConds].operation = DBD_EQ;
				condStruct[numOfConds].relationship = DBD_OR;
				numOfConds++;
			}
			ooErr = ARP_GetAccountByType (GetEnv(), NULL, ARP_TYPE_BoE_DISCOUNTED, tmpStr, TRUE, VAL_CUSTOMER);
			if (!ooErr && !_STR_IsSpacesStr(tmpStr)) 
			{
				_STR_strcpy (condStruct[numOfConds].condVal, tmpStr);
				condStruct[numOfConds].tableIndex = 0;
				condStruct[numOfConds].colNum = JDT1_ACCT_NUM;
				condStruct[numOfConds].operation = DBD_EQ;
				condStruct[numOfConds].relationship = 0;
				numOfConds++;
			}
			condStruct[numOfConds-1].bracketClose = 1;
		}
		// only if there accounts
		if (numOfConds > 1) 
		{
			condStruct[numOfConds].bracketClose = 1;
			
			condStruct[numOfConds-1].relationship = 0;
			DBD_SetDAGCond (dagJDT1, condStruct, numOfConds);
			DBD_SetDAGRes (dagJDT1, resStruct, RES_NUM_OF_RES);
			DBD_SetTablesList (dagJDT1, tableStruct, numOfTables);
			
			ooErr = DBD_GetInNewFormat (dagJDT1, &dagAnswer);
			dagAnswer->Detach();
		}
		
		if (!ooErr && numOfConds > 1)
		{
			dagRES->Concat (dagAnswer, dbmDataBuffer);
			DAG_Close(dagAnswer);
			dagAnswer = NULL;
		}
		else if (ooErr == dbmNoDataFound) 
		{
			DAG_Close(dagAnswer);
			dagAnswer = NULL;
			
		}
		else if (ooErr)
		{
			DAG_Close(dagAnswer);
			DAG_Close(dagRES);
			DAG_Close (dagJDT1);
			return ooErr;
		}
	}

	DAG_GetCount(dagRES, &numOfRecs);
	if (!numOfRecs) 
	{
		DAG_Close (dagJDT1);
		DAG_Close(dagRES);
		return ooNoErr;
	}
	dagRES->SortByCols (columns, orders, 3, FALSE, FALSE);
	_MEM_Clear(condStruct, numOfConds);

	cond = new DBD_CondStruct[2* numOfRecs];

	updateActBalanceCond = new DBD_CondStruct[numOfRecs];
	updateCardBalanceCond = new DBD_CondStruct[numOfRecs];

	/************************************************************************/
	/* First gather all BP whose balance will be affected- for later update */
	/************************************************************************/
	for (rec=0; rec < numOfRecs; rec++) 
	{
		dagRES->GetColStr (tmpStr, RES_SHORT_NAME, rec);
		if (!IsCardAlreadyThere(updateCardBalanceCond, tmpStr, 0, numOfCardConds)) 
		{
			// save the account for later updating the account's balance
			updateCardBalanceCond[numOfCardConds].colNum = OCRD_CARD_CODE;
			updateCardBalanceCond[numOfCardConds].operation = DBD_EQ;
			_STR_strcpy (updateCardBalanceCond[numOfCardConds].condVal, tmpStr);
			updateCardBalanceCond[numOfCardConds++].relationship = DBD_OR;	
		}

	}
	updateCardBalanceCond[numOfCardConds-1].relationship = 0;	

	rec =0;
	numOfConds = 0;
	firstAct = TRUE;

	while ( rec < numOfRecs) 
	{
		dagRES->GetColStr (savedAcc, RES_ACCT_NUM, rec);
		_STR_LRTrim(savedAcc);
		dagRES->GetColLong (&intrnMatch, RES_INTR_MATCH, rec);
		dagRES->GetColStr (savedShortName, RES_SHORT_NAME, rec);
		// loop over the lines with the same account and match num
		while(rec < numOfRecs)
		{
			dagRES->GetColStr (tmpStr, RES_ACCT_NUM, rec);
			_STR_LRTrim(tmpStr);
			dagRES->GetColLong (&tmpL, RES_INTR_MATCH, rec);
			dagRES->GetColStr (shortName, RES_SHORT_NAME, rec);
			if (_STR_strcmp(tmpStr, savedAcc) || tmpL != intrnMatch || _STR_strcmp(shortName, savedShortName)) 
			{
				break;
			}
			// trans abs
			cond[numOfConds].bracketOpen = 1;

			cond[numOfConds].colNum = JDT1_TRANS_ABS;
			cond[numOfConds].operation = DBD_EQ;
			dagRES->GetColStr (tmpStr, RES_TRANS_ABS, rec);
			_STR_strcpy (cond[numOfConds].condVal, tmpStr);
			cond[numOfConds++].relationship = DBD_AND;
			// line id
			cond[numOfConds].colNum = JDT1_LINE_ID;
			cond[numOfConds].operation = DBD_EQ;
			dagRES->GetColStr (tmpStr, RES_LINE_ID, rec);
			_STR_strcpy (cond[numOfConds].condVal, tmpStr);
			cond[numOfConds++].relationship = DBD_OR;			
			cond[numOfConds-1].bracketClose = 1;

			rec++;
		}
		cond[numOfConds-1].relationship = 0;	

		if (intrnMatch < 0) 
		{
			// get next match num only if the line was originally matched
			GOGetNextSystemMatch (GetEnv(), savedAcc, &matchNum, FALSE);
			intrnMatch = matchNum;
		}

		/************************************************************************/
		/*   now update the relevant records                                    */
		/************************************************************************/

		// shortName = Account
		updStruct[0].colNum = JDT1_SHORT_NAME;
		updStruct[0].SetUpdateColSource (DBD_UpdStruct::ucs_SrcCol);
		updStruct[0].srcColNum = JDT1_ACCT_NUM;

		// new internal match
		updStruct[1].colNum = JDT1_INTR_MATCH;
		_STR_sprintf (tmpStr, LONG_FORMAT, intrnMatch);
		_STR_strcpy (updStruct[1].updateVal, tmpStr);

		DBD_SetDAGCond (dagJDT1, cond, numOfConds);
		DBD_SetDAGUpd (dagJDT1, updStruct, 2);
		ooErr = DBD_UpdateCols (dagJDT1);
		if (ooErr) 
		{
			delete [] cond;
			delete [] updateCardBalanceCond;
			delete [] updateActBalanceCond;
			DAG_Close (dagJDT1);
			DAG_Close(dagRES);
			return ooErr;
		}
		
		if (_STR_strcmp(tmpStr, savedAcc) || firstAct) 
		{
			// save the account for later updating the account's balance
			updateActBalanceCond[numOfActsConds].colNum = OACT_ACCOUNT_CODE;
			updateActBalanceCond[numOfActsConds].operation = DBD_EQ;
			_STR_strcpy(updateActBalanceCond[numOfActsConds].condVal, savedAcc);
			updateActBalanceCond[numOfActsConds++].relationship = DBD_OR;	
		}
		firstAct = FALSE;				
		if (rec >= numOfRecs) 
		{
			break;
		}
		numOfConds = 0;
	}
	DAG_Close(dagRES);
	DAG_Close (dagJDT1);
	
	/************************************************************************/
	/*   Update the Affected Account's and BP's Balance                     */
	/************************************************************************/

	// get dagACT
	updateActBalanceCond[numOfActsConds-1].relationship = 0;	
	dagACT = OpenDAG (ACT, ao_Main);
	DBD_SetDAGCond (dagACT, updateActBalanceCond, numOfActsConds);
	ooErr = DBD_Get(dagACT);
	if (ooErr)
	{
		delete [] cond;
		delete [] updateCardBalanceCond;
		delete [] updateActBalanceCond;
		DAG_Close(dagACT);
		return ooErr;
	}
	// get dagCRD
	dagCRD = OpenDAG (CRD, ao_Main);
	DBD_SetDAGCond (dagCRD, updateCardBalanceCond, numOfCardConds);
	ooErr = DBD_Get(dagCRD);
	if (ooErr)
	{
		delete [] cond;
		delete [] updateCardBalanceCond;
		delete [] updateActBalanceCond;
		DAG_Close(dagCRD);
		DAG_Close(dagACT);
		return ooErr;
	}
#ifndef MNHL_SERVER_MODE
	RBARebuildAccountsAndCardsInternal (dagACT, dagCRD, FALSE);
#endif
	
	delete [] cond;
	delete [] updateCardBalanceCond;
	delete [] updateActBalanceCond;
	DAG_Close(dagCRD);
	DAG_Close(dagACT);
	return ooNoErr;

}

/*******************************************************************
 Function name		: OJDTFixVendorsAndSpainBoeBalance
 Description	    : Fix balance for all of the vendors with BOE
					  and for all of the customers in Spain with BOE
 Return type		: SBOErr  
 Argument			: none
********************************************************************/
SBOErr  CTransactionJournalObject::FixVendorsAndSpainBoeBalance()
{
        _TRACER("FixVendorsAndSpainBoeBalance");
	SBOErr			ooErr;
	PDAG			dagCRD, dagJDT1, dagRES, dagRES2;
	DBD_CondStruct	*updateCardBalanceCond, condStruct[4];
	DBD_Tables		tableStruct[2];
	DBD_CondStruct	joinCondStruct[1];
	DBD_ResStruct	resStruct[1];
	long			numOfCardConds=0, numOfActsConds=0, numOfConds=0, numOfRecs, rec;
	Boolean			firstErr = FALSE;
	TCHAR			tmpStr[256];
	CBizEnv			&bizEnv = GetEnv ();

	
	_STR_strcpy (tableStruct[0].tableCode, bizEnv.ObjectToTable (JDT, ao_Arr1));
	dagJDT1 = OpenDAG (JDT, ao_Arr1);
	/************************************************************************/
	/*  First bring the account from the card                               */
	/************************************************************************/
	_STR_strcpy (tableStruct[1].tableCode, bizEnv.ObjectToTable (CRD, ao_Arr3));

	tableStruct[1].doJoin = TRUE;
	tableStruct[1].joinedToTable = 0;

	tableStruct[1].numOfConds = 1;
	tableStruct[1].joinConds = joinCondStruct;

	joinCondStruct[0].compareCols = TRUE;
	joinCondStruct[0].compTableIndex = 0;
	joinCondStruct[0].compColNum = JDT1_ACCT_NUM;
	joinCondStruct[0].tableIndex = 1;
	joinCondStruct[0].colNum = CRD3_ACCOUNT_CODE;
	joinCondStruct[0].operation = DBD_EQ;		
	
	condStruct[numOfConds].compareCols = TRUE;
	condStruct[numOfConds].colNum = JDT1_SHORT_NAME;
	condStruct[numOfConds].operation = DBD_EQ;
	condStruct[numOfConds].compColNum = CRD3_CARD_CODE;
	condStruct[numOfConds].tableIndex = 0;
	condStruct[numOfConds].compTableIndex = 1;
	condStruct[numOfConds++].relationship = DBD_AND;
	

	/************************************************************************/
	/*  Only in spain get the customers also                                */
	/************************************************************************/
	if (VF_BOEAsInSpain (bizEnv))
	{	
		condStruct[numOfConds].bracketOpen = 1;
		// take the customers that has lines with BOE Receivable 
		condStruct[numOfConds].tableIndex = 1;
		condStruct[numOfConds].colNum = CRD3_ACCOUNT_TYPE;
		_STR_strcpy (condStruct[numOfConds].condVal, ARP_TYPE_BoE_RECEIVABLE); 
		condStruct[numOfConds].operation = DBD_EQ;
		condStruct[numOfConds++].relationship = DBD_OR;
	}
	/************************************************************************/
	/*  Get the vendors						                                */
	/************************************************************************/
	// take the customers that has lines with BOE Payable 
	condStruct[numOfConds].tableIndex = 1;
	condStruct[numOfConds].colNum = CRD3_ACCOUNT_TYPE;
	_STR_strcpy (condStruct[numOfConds].condVal, ARP_TYPE_BoE_PAYABLE); 
	condStruct[numOfConds].operation = DBD_EQ;
	condStruct[numOfConds++].relationship = 0;

	if (VF_BOEAsInSpain (bizEnv))
	{	
		condStruct[numOfConds-1].bracketClose = 1;
	}

	resStruct[0].colNum = JDT1_SHORT_NAME;
	resStruct[0].tableIndex = 0;
	resStruct[0].group_by = TRUE;

	DBD_SetDAGCond (dagJDT1, condStruct, numOfConds);
	DBD_SetDAGRes (dagJDT1, resStruct, 1);
	DBD_SetTablesList (dagJDT1, tableStruct, 2);

	ooErr = DBD_GetInNewFormat (dagJDT1, &dagRES);

	if (ooErr && ooErr != dbmNoDataFound)
	{
		DAG_Close (dagJDT1);
		return ooErr;
	}
	else if (ooErr) 
	{
		firstErr = TRUE;
		DAG_SetSize(dagRES, 0, dbmDropData);
	}

	dagRES->Detach();

	/************************************************************************/
	/*  Now get the accounts from OADM		                                */
	/************************************************************************/
	_MEM_Clear(condStruct, numOfConds);
	_MEM_Clear(tableStruct, 2);

	_STR_strcpy (tableStruct[0].tableCode, bizEnv.ObjectToTable (JDT, ao_Arr1));
	numOfConds = 0;

	if (VF_BOEAsInSpain (bizEnv))
	{		
		ooErr = ARP_GetAccountByType (GetEnv(), NULL, ARP_TYPE_BoE_RECEIVABLE, tmpStr, TRUE, VAL_CUSTOMER);
		if (!ooErr && !_STR_IsSpacesStr(tmpStr)) 
		{
			_STR_strcpy (condStruct[numOfConds].condVal, tmpStr);
			condStruct[numOfConds].tableIndex = 0;
			condStruct[numOfConds].colNum = JDT1_ACCT_NUM;
			condStruct[numOfConds].operation = DBD_EQ;
			condStruct[numOfConds++].relationship = DBD_OR;
		}
	}

	ooErr = ARP_GetAccountByType (GetEnv(), NULL, ARP_TYPE_BoE_PAYABLE, tmpStr, TRUE, VAL_VENDOR);
	if (!ooErr && !_STR_IsSpacesStr(tmpStr)) 
	{
		_STR_strcpy (condStruct[numOfConds].condVal, tmpStr);
		condStruct[numOfConds].tableIndex = 0;
		condStruct[numOfConds].colNum = JDT1_ACCT_NUM;
		condStruct[numOfConds].operation = DBD_EQ;
		condStruct[numOfConds++].relationship = 0;
	}

	// only if there are accounts
	if (numOfConds) 
	{
		DBD_SetDAGCond (dagJDT1, condStruct, numOfConds);
		DBD_SetDAGRes (dagJDT1, resStruct, 1);
		DBD_SetTablesList (dagJDT1, tableStruct, 1);

		ooErr = DBD_GetInNewFormat (dagJDT1, &dagRES2);
		dagRES2->Detach();
	}

	if (!ooErr && numOfConds)
	{
		dagRES->Concat (dagRES2, dbmDataBuffer);
		DAG_Close(dagRES2);
	}
	else if (ooErr == dbmNoDataFound) 
	{
		DAG_Close(dagRES2);
		if (firstErr) 
		{
			DAG_Close(dagRES);
			DAG_Close (dagJDT1);
			return ooNoErr;
		}
	}
	else if (ooErr)
	{
		DAG_Close(dagRES2);
		DAG_Close(dagRES);
		DAG_Close (dagJDT1);
		return ooErr;
	}

	DAG_GetCount(dagRES, &numOfRecs);
	if (!numOfRecs) 
	{
		DAG_Close(dagRES);
		return ooNoErr;
	}

	/************************************************************************/
	/* Get all cards from DB in order to  fix their balance					*/
	/************************************************************************/
	updateCardBalanceCond = new DBD_CondStruct[numOfRecs];

	for (rec=0; rec < numOfRecs; rec++) 
	{
		// save the account for later updating the account's balance
		updateCardBalanceCond[numOfCardConds].colNum = OCRD_CARD_CODE;
		updateCardBalanceCond[numOfCardConds].operation = DBD_EQ;
		dagRES->GetColStr (tmpStr, 0, rec);
		_STR_strcpy(updateCardBalanceCond[numOfCardConds].condVal, tmpStr);
		updateCardBalanceCond[numOfCardConds++].relationship = DBD_OR;	
	}
	updateCardBalanceCond[numOfCardConds-1].relationship = 0;	

	// get dagCRD
	dagCRD = OpenDAG (CRD, ao_Main);
	DBD_SetDAGCond (dagCRD, updateCardBalanceCond, numOfCardConds);
	ooErr = DBD_Get(dagCRD);
	if (ooErr)
	{
		delete [] updateCardBalanceCond;
		DAG_Close(dagCRD);
		return ooNoErr;
	}

	/************************************************************************/
	/* Not from DI															*/
	/************************************************************************/
#ifndef MNHL_SERVER_MODE
	RBARebuildAccountsAndCardsInternal (NULL, dagCRD, FALSE);
#endif
	
	delete [] updateCardBalanceCond;
	DAG_Close(dagCRD);
	return ooNoErr;
}



/*****************************************************************/
/*	    IsCardAlreadyThere										 */	
/*                   Desc:  Check if the card code is allready in*/
/*							the conds list.						 */
/*****************************************************************/
Boolean CTransactionJournalObject::IsCardAlreadyThere(PDBD_Cond updateCardBalanceCond, TCHAR  *cardCode, long startingRec, long numOfCardConds)
{
        _TRACER("IsCardAlreadyThere");
	long ii;

	for (ii=startingRec; ii < numOfCardConds; ii++) 
	{
		if (!_STR_strcmp(updateCardBalanceCond[ii].condVal, cardCode)) 
		{
			return TRUE;
		}
	}

	return FALSE;
}

/*******************************************************************
 Function name		: UpgradePeriodIndic
 Description	    : Change column "JDT1_SRC_ABS_ID" by according to 
					  to changes made in ORCT, OVPM DocEntry	
 Return type		: SBOErr  
 Argument			: none
********************************************************************/
SBOErr CTransactionJournalObject::UpgradePeriodIndic()
{
        _TRACER("UpgradePeriodIndic");
	DBD_CondStruct	condStruct[2];
	DBD_UpdStruct	UpdateStruct[1];
	PDAG			dagJDT1;
	SBOErr			sboErr = ooNoErr;
	
	dagJDT1 = OpenDAG (JDT, ao_Arr1);

	//Conds (WHERE)
	condStruct[0].colNum	= JDT1_TRANS_TYPE;
	condStruct[0].operation	= DBD_EQ;
	condStruct[0].condVal = RCT;
	condStruct[0].relationship = DBD_OR;
	
	condStruct[1].colNum	= JDT1_TRANS_TYPE;
	condStruct[1].operation	= DBD_EQ;
	condStruct[1].condVal = VPM;
	
	DBD_SetDAGCond (dagJDT1, condStruct, 2);

	//Update (JDT1)
	UpdateStruct[0].colNum = JDT1_SRC_ABS_ID;
	UpdateStruct[0].srcColNum = JDT1_CREATED_BY;
	UpdateStruct[0].SetUpdateColSource (DBD_UpdStruct::ucs_SrcCol);

	DBD_SetDAGUpd (dagJDT1, UpdateStruct, 1);
	sboErr = DBD_UpdateCols(dagJDT1);
	DAG_Close (dagJDT1);

	return sboErr;
}

//***************************************************************/
//***************************************************************/
SBOErr	CTransactionJournalObject::OnCheckIntegrityOnCreate()
{
        _TRACER("OnCheckIntegrityOnCreate");
	SBOErr	ooErr;

	ooErr = OJDTCheckIntegrityOfJournalEntry (this, false);
	if(ooErr)
	{
		return ooErr;
	}
	
	return noErr;
}

//***************************************************************/
//***************************************************************/
SBOErr	CTransactionJournalObject::OnCheckIntegrityOnUpdate()
{
        _TRACER("OnCheckIntegrityOnUpdate");
	SBOErr	ooErr;

	ooErr = OJDTCheckIntegrityOfJournalEntry (this, false);
	if(ooErr)
	{
		return ooErr;
	}
	
	return noErr;
}

//***************************************************************/
/*	OJDTCheckIntegrityOfJournalEntry							*/	
/*                   Desc:  makes some validations on JDT1:		*/
/*					1. unbalanced transaction					*/	 
/*					2. JDT1 is not Empty						*/
/*					3. local card cannot have FC amounts		*/
/*					4. Cost Account Assignment           		*/
//***************************************************************/
SBOErr	CTransactionJournalObject::OJDTCheckIntegrityOfJournalEntry (CBusinessObject *bizObject, Boolean checkForgn)
{
        _TRACER("OJDTCheckIntegrityOfJournalEntry");
	SBOErr	ooErr;
	
	/************************************************************************/
	/*    Checking if the header is empty then dont do any checks           */
	/************************************************************************/
	
	PDAG	dagJDT = bizObject->GetDAGNoOpen(SBOString(JDT));
	if (!dagJDT)
	{
		_MEM_ASSERT(0);
		return ooNoErr;
	}

	long numOfRecs = dagJDT->GetRecordCount();
	if(numOfRecs == 1)
	{
		SBOString tmpStr;
		
		dagJDT->GetColStr(tmpStr, OJDT_JDT_NUM);
		tmpStr.Trim();

		if(tmpStr.IsSpacesStr())
		{
			numOfRecs = 0;
		}
	}

	if(numOfRecs == 0)
	{
		return ooNoErr;
	}

	/************************************************************************/
	/* Preform Checks                                                       */
	/************************************************************************/

	ooErr = OJDTCheckJDT1IsNotEmpty (bizObject);
	IF_ERROR_RETURN(ooErr);

	ooErr = OJDTValidateJDTOfLocalCard (bizObject);
	IF_ERROR_RETURN(ooErr);

	ooErr = OJDTValidateJDT1Accounts (bizObject);
	IF_ERROR_RETURN(ooErr);

	ooErr = OJDTCheckBalnaceTransection(bizObject, checkForgn);
	IF_ERROR_RETURN(ooErr);

	ooErr = CostAccountingAssignmentCheck(bizObject);
	IF_ERROR_RETURN(ooErr);
	
	return ooNoErr;
}

//**********************************************************************************
//**********************************************************************************
SBOErr	CTransactionJournalObject::OJDTCheckJDT1IsNotEmpty (CBusinessObject *bizObject)
{
        _TRACER("OJDTCheckJDT1IsNotEmpty");
	long		numOfRecs;
	SBOString	keyCol1, keyCol2;
	PDAG		dagJDT1, dagJDT;

	dagJDT = bizObject->GetDAGNoOpen(SBOString(JDT));
	if (!dagJDT)
	{
		_MEM_ASSERT(0);
		return ooNoErr;
	}

	dagJDT1 = bizObject->GetDAG(SBOString(JDT),ao_Arr1);
		
	numOfRecs = dagJDT1->GetRecordCount();
	if (numOfRecs<=0)
	{
		bizObject->Message (GO_OBJ_ERROR_MSGS(JDT), JDT_WITH_NO_LINES_ERR, NULL, OO_ERROR);
		return ooInvalidObject;
	}

	if (numOfRecs==1)
	{
		dagJDT1->GetColStr(keyCol1, JDT1_TRANS_ABS);	
		dagJDT1->GetColStr(keyCol2, JDT1_LINE_ID);	
		if(keyCol1.IsSpacesStr() || keyCol2.IsSpacesStr())
		{
			bizObject->Message (GO_OBJ_ERROR_MSGS(JDT), JDT_WITH_NO_LINES_ERR, NULL, OO_ERROR);
			return ooInvalidObject;
		}
	}

	return ooNoErr;
}

///**********************************************************************************
//* This function checks if the accounts are valid in JDT1
//**********************************************************************************
SBOErr	CTransactionJournalObject::OJDTValidateJDT1Accounts(CBusinessObject *bizObject)
{
	long		numOfRecs, jj;
	PDAG		dagJDT1, dagACT;
	TCHAR		actNum [JDT1_ACCT_NUM_LEN+1], code [OACT_FORMAT_CODE_LEN+1];
	SBOString	tmpStr;
	SBOErr		ooErr;
	Currency	tmpCurr, Curr;
	CBizEnv		&bizEnv = bizObject->GetEnv ();

	dagACT = bizObject->GetDAG(ACT, ao_Main);
	dagJDT1 = bizObject->GetDAG(JDT, ao_Arr1);
	numOfRecs = dagJDT1->GetRealSize(dbmDataBuffer);

    bool lock = !(bizObject->IsUpdateNum() || bizObject->IsExCommand3(ooEx3DontTouchNextNum));

	// Loop over the records and check all the account
	for (jj = 0; jj < numOfRecs; jj++)
	{		
		dagJDT1->GetColStr(actNum, JDT1_ACCT_NUM, jj);
		if (_STR_IsSpacesStr (actNum))
		{			
			return (ooInvalidAcctCode);
		}
		//Must make sure the account is postable (not a headline)		
		ooErr = bizEnv.GetByOneKey(dagACT, OACT_KEYNUM_PRIMARY, actNum, lock);
		if (ooErr)
		{	
			if (ooErr == dbmNoDataFound)
			{
				return (ooInvalidAcctCode);
			}
		
			else
			{
				return ooErr;
			}
		}

		dagACT->GetColStr(tmpStr, OACT_POSTABLE, 0);
		if (_STR_strcmp (tmpStr, VAL_YES) != 0)
		{	
			//The account is NOT postable			
			dagACT->GetColStr(code, OACT_ACCOUNT_CODE);
			bizObject->Message (OBJ_MGR_ERROR_MSG, GO_NON_POSTABLE_ACT_IN_TRANS_MSG, code, OO_ERROR);
			return (ooInvalidObject);
		}
		// Transaction currency must equal the account currency
		dagACT->GetColStr (tmpCurr, OACT_ACT_CURR, 0);
		dagJDT1->GetColStr (Curr, JDT1_FC_CURRENCY, jj);
		if (GNCoinCmp (tmpCurr, BAD_CURRENCY_STR) != 0)
		{
			if (!_STR_SpacesString (Curr, _STR_strlen (Curr)))
			{
				if (GNCoinCmp (tmpCurr, Curr) != 0)
				{
					dagACT->GetColStr(tmpStr, OACT_ACCOUNT_CODE);
					ooErr = bizEnv.GetAccountSegmentsByCode (tmpStr, code, true);
					IF_ERROR_RETURN (ooErr);
					bizObject->Message (OBJ_MGR_ERROR_MSG,GO_ACT_COIN_DIFFERS, code, OO_ERROR);
					return (ooInvalidObject);
				}
			}
		}
	}
	return ooNoErr;
}


//****************************************************************/
/*	OJDTValidateJDTOfLocalCard									 */	
/*                   Desc:  Check that if card is local then	 */
/*							there is not foreign amounts in		 */
/*							Journal Entry						 */
//****************************************************************/
SBOErr	CTransactionJournalObject::OJDTValidateJDTOfLocalCard (CBusinessObject *bizObject)
{
        _TRACER("OJDTValidateJDTOfLocalCard");
	SBOErr		ooErr;
	long		rec, numOfRecs;
	SBOString	shortName, actCode;
	PDAG		dagJDT, dagJDT1, dagCRD;
	Currency	currency, localCurr;
	bool		isLocalCard = false;
	MONEY		tmpM;
	CBizEnv		&bizEnv = bizObject->GetEnv ();

	_STR_strcpy (localCurr, bizEnv.GetMainCurrency ());

	dagJDT1 = bizObject->GetDAGNoOpen(SBOString(JDT),ao_Arr1);
	if (!dagJDT1)
	{
		_MEM_ASSERT(0);
		return ooNoErr;
	}

	dagJDT = bizObject->GetDAGNoOpen(SBOString(JDT));
	if (!dagJDT)
	{
		_MEM_ASSERT(0);
		return ooNoErr;
	}
	
	numOfRecs = dagJDT1->GetRecordCount();
	for (rec=0; rec<numOfRecs; rec++)
	{
		dagJDT1->GetColStr (actCode, JDT1_ACCT_NUM, rec);
		dagJDT1->GetColStr (shortName, JDT1_SHORT_NAME, rec);
		if (actCode.Compare(shortName)!=0)
		{
			dagCRD = bizObject->OpenDAG (CRD);
			ooErr = bizEnv.GetByOneKey(dagCRD, OCRD_KEYNUM_PRIMARY, shortName, true);
			if (ooErr)
			{
				dagCRD->Close ();
				return ooNoErr;
			}

			dagCRD->GetColStr (currency, OCRD_CRD_CURR);
			if (GNCoinCmp(localCurr, currency) != 0)
			{
				dagCRD->Close ();
				continue; //foreign card
			}
			else
			{
				ooErr = OJDTCheckFcInLocalCard(bizObject,dagJDT1, rec);
				if(ooErr)
				{
					dagCRD->Close ();
					return ooErr; // local card with foreign currency
				}
					
			}
			dagCRD->Close ();
		}				
	}

	
	return ooNoErr;	
}

/*****************************************************************/
/*	OJDTCheckFcInLocalCard										 */	
/*                   Desc:  Check if local card has a value in	 */
/*							the FC column And return error		 */
/*																 */
/*****************************************************************/
SBOErr CTransactionJournalObject::OJDTCheckFcInLocalCard(CBusinessObject *bizObject, PDAG dagJDT1, long rec)
{
        _TRACER("OJDTCheckFcInLocalCard");
	MONEY		tmpM;	

	dagJDT1->GetColMoney (&tmpM, JDT1_FC_CREDIT, rec);
	if (tmpM != 0)
	{
		bizObject->Message (GO_OBJ_ERROR_MSGS(JDT), JDT_LOCAL_BP_WITH_FC_AMOUNTS_ERR, NULL, OO_ERROR);
		return ooInvalidObject;
	}
	dagJDT1->GetColMoney (&tmpM, JDT1_FC_DEBIT, rec);
	if (tmpM != 0)
	{
		bizObject->Message (GO_OBJ_ERROR_MSGS(JDT), JDT_LOCAL_BP_WITH_FC_AMOUNTS_ERR, NULL, OO_ERROR);
		return ooInvalidObject;
	}

	return ooNoErr;
	
	
}
/*****************************************************************/
/*	OJDTCheckBalnaceTransection									 */	
/*                   Desc:  Check if transection is balanced	 */
/*							If not write transection to log file */
/*							And return error					 */
/*****************************************************************/
SBOErr  CTransactionJournalObject::OJDTCheckBalnaceTransection (CBusinessObject *bizObject, Boolean checkForgn)
{
        _TRACER("OJDTCheckBalnaceTransection");
	PDAG	dagJDT1 = NULL;
	MONEY	credit, debit, creditS, 
			debitS, creditF, debitF , tmpM;
	long    rec, records;
	SBOErr  ooErr;


	dagJDT1 = bizObject->GetDAGNoOpen(SBOString(JDT),ao_Arr1);
	if (!dagJDT1)
	{
		_MEM_ASSERT(0);
		return ooNoErr;
	}

	DAG_GetCount (dagJDT1, &records);
	
	for (rec = 0; rec < records; rec++)
	{
		//--------------------------Local--------------------------
		dagJDT1->GetColMoney (&tmpM, JDT1_CREDIT, rec, DBM_NOT_ARRAY);
		ooErr = MONEY_Add (&credit, &tmpM);
		if(ooErr)
		{
			return ooErr;
		}

		dagJDT1->GetColMoney (&tmpM, JDT1_DEBIT, rec, DBM_NOT_ARRAY);
		ooErr = MONEY_Add (&debit, &tmpM);
		if(ooErr)
		{
			return ooErr;
		}

		//--------------------------System-------------------------
		dagJDT1->GetColMoney (&tmpM, JDT1_SYS_CREDIT, rec, DBM_NOT_ARRAY);
		ooErr = MONEY_Add (&creditS, &tmpM);
		if(ooErr)
		{
			return ooErr;
		}


		dagJDT1->GetColMoney (&tmpM, JDT1_SYS_DEBIT, rec, DBM_NOT_ARRAY);
		ooErr = MONEY_Add (&debitS, &tmpM);
		if(ooErr)
		{
			return ooErr;
		}

		//--------------------------Forgn--------------------------
		
		dagJDT1->GetColMoney (&tmpM, JDT1_FC_CREDIT, rec, DBM_NOT_ARRAY);
		ooErr = MONEY_Add (&creditF, &tmpM);
		if(ooErr)
		{
			return ooErr;
		}

		dagJDT1->GetColMoney (&tmpM, JDT1_FC_DEBIT, rec, DBM_NOT_ARRAY);
		ooErr = MONEY_Add (&debitF, &tmpM);
		if(ooErr)
		{
			return ooErr;
		}
	}

	//-----------------------Check If Balanced-----------------
	if ( (MONEY_Cmp (&credit, &debit)   !=0) ||
		 (MONEY_Cmp (&creditS, &debitS) !=0) )
	{
		return OJDTWriteErrorMessage (bizObject);
	}

	if (checkForgn)
	{
		if ( (MONEY_Cmp (&creditF, &debitF)   !=0) )
		{
				return OJDTWriteErrorMessage (bizObject);
		}
	}

	return ooNoErr;
}

/*****************************************************************/
/*	OJDTWriteErrorMessage										 */	
/*                   Desc: 	write transaction  to log file		 */
/*							and return Error message			 */
/*****************************************************************/
SBOErr OJDTWriteErrorMessage (CBusinessObject *bizObject)
{
        _TRACER("OJDTWriteErrorMessage");
	PDAG	dagJDT1		 = NULL;
	DBM_CA	fldInfo;
	MONEY	sum;
	TCHAR	*buffer;
	TCHAR	tmpStr [256] = {0};
	TCHAR	path [_FILE_PATH_MAX+1] = {0};
	TCHAR	msg [512] = {0};
	long    rec, records, i;
	long    colArr [] = {JDT1_ACCT_NUM, JDT1_CREDIT, JDT1_DEBIT, JDT1_SYS_CREDIT, JDT1_SYS_DEBIT, 
						 JDT1_FC_CREDIT, JDT1_FC_DEBIT, -1};

	//---------------------Write to Log---------------
	dagJDT1 = bizObject->GetDAGNoOpen(SBOString(JDT),ao_Arr1);
	DAG_GetCount (dagJDT1, &records);
	
	buffer = new TCHAR[RECORD_LEN];

	for (i = 0; colArr[i] != -1; i++)
	{
		dagJDT1->GetColAttributes (colArr[i], &fldInfo, FALSE);
		_STR_strcpy (tmpStr, fldInfo.alias);
		_STR_LRTrim (tmpStr);
		_STR_strcat (buffer, tmpStr);
		_STR_strcat (buffer, FILE_TAB);
	}

	_STR_strcat (buffer,FILE_NEW_LINE);

	_MEM_renew_raw(buffer, TCHAR, _STR_strlen (buffer) + RECORD_LEN, RECORD_LEN);

	for (rec = 0; rec < records; rec++)
	{
		for (i = 0; colArr[i] != -1; i++)
		{
			if (i == 0)
			{
				dagJDT1->GetColStr (tmpStr, colArr[i], rec);
			}
			else
			{
				dagJDT1->GetColMoney (&sum, colArr[i], rec, DBM_NOT_ARRAY);
				if (sum.IsZero())
				{
					tmpStr[0] = '\0';
				}
				else
				{
					MONEY_ToText (&sum, tmpStr, RC_SUM, SPACE_STR, bizObject->GetEnv());
				}
			}

			_STR_LRTrim (tmpStr);
			
			_STR_strcat (buffer, tmpStr);
			_STR_strcat (buffer, FILE_TAB);
		}
		
		_STR_strcat (buffer, FILE_NEW_LINE);

		_MEM_renew_raw(buffer, TCHAR, _STR_strlen(buffer) + RECORD_LEN, _STR_strlen (buffer) + 1);
	}

	_STR_LRTrim (buffer);

	_FILE_GetLocalTempPath (_FILE_PATH_MAX, path);
	_STR_strcat (path, FILE_NAME);
	_FILE_BufferToFile(path ,buffer, TRUE);

	delete []buffer;
	CMessagesManager::GetHandle()->Message(_1_APP_MSG_FIN_OO_TRANSACTION_NOT_BALANCED,
		EMPTY_STR, bizObject);
	
	return ooTransNotBalanced;
}

//**********************************************************************************
//**********************************************************************************
SBOErr	CTransactionJournalObject::CompleteVatLine ()
{
        _TRACER("CompleteVatLine");
	SBOErr			ooErr = noErr;
	long			rec, numOfRecs, rec2;
	TCHAR			tmpStr[256], formatStr[256];
	TCHAR			stampTax[OJDT_STAMP_TAX_LEN + 1];
	TCHAR			actNum[JDT1_ACCT_NUM_LEN+1];
	TCHAR			shortName[JDT1_SHORT_NAME_LEN+1];
	TCHAR			defaultVat[OACT_DFLT_VAT_GROUP_LEN+1];
	TCHAR			VatGroup[JDT1_VAT_GROUP_LEN + 1];
	TCHAR			taxPostAcct[JDT1_TAX_POSTING_ACCOUNT_LEN+1];
	TCHAR			dateStr[JDT1_DUE_DATE_LEN+1]={0};
	MONEY			money, delta, tmpM, debit, credit;			
	PDAG			dagJDT, dagJDT1, dagVTG;
	PDAG			dagACT, dagRES;
	CBizEnv			&bizEnv = GetEnv ();
	Boolean			debitSide, creditSide, found;
	DBD_CondStruct	condStruct[2];
	DBD_ResStruct	resStruct[1];
	Currency		localCurr, sysCurr;

	dagJDT = GetDAG (JDT);
	dagJDT1 = GetDAG(JDT, ao_Arr1);
	dagACT = GetDAG (ACT);
	dagVTG = GetDAG(VTG);

	dagJDT->GetColStr (stampTax, OJDT_STAMP_TAX, 0);
	if (stampTax[0] == VAL_YES[0])
	{
		if (bizEnv.IsVatPerLine ())
		{
			if (GetDataSource () == *VAL_OBSERVER_SOURCE)
			{
				return ComplateStampLine();
			}
			else
			{
				return ooNoErr;
			}
		}
		else
		{
			return ooErrNoMsg;
		}
	}

	_STR_strcpy (localCurr, bizEnv.GetMainCurrency ());
	_STR_strcpy (sysCurr, bizEnv.GetSystemCurrency ());

	DAG_GetCount (dagJDT1, &numOfRecs);	
	if (bizEnv.IsVatPerLine () || bizEnv.IsVatPerCard())
	{
		dagJDT->GetColStr (tmpStr, OJDT_AUTO_VAT, 0);
		if (tmpStr[0] == VAL_YES[0])
		{
			if (GetDataSource () == *VAL_OBSERVER_SOURCE)
			{
				for (rec=0; rec<numOfRecs; rec++)
				{
					dagJDT1->GetColStr (actNum, JDT1_ACCT_NUM, rec);
					dagJDT1->GetColStr (shortName, JDT1_SHORT_NAME, rec);
					if (_STR_strcmp (actNum, shortName) == 0)
					{
						if (bizEnv.IsVatPerLine ())
						{
							condStruct[0].colNum = OVTG_ACCOUNT;
							condStruct[0].operation	= DBD_EQ;
							_STR_strcpy (condStruct[0].condVal, shortName);
							condStruct[0].relationship =  0;
							DBD_SetDAGCond (dagVTG, condStruct, 1);
							if (DBD_Count (dagVTG, TRUE) > 0)
							{
								Message (JTE_JDT_FORM_NUM, JTE_VAT_LINE_ERROR_STR, NULL, OO_ERROR);
								return ooErrNoMsg;
							}
						}
						ooErr = bizEnv.GetByOneKey (dagACT, OACT_KEYNUM_PRIMARY, actNum, true);
						if (!ooErr)
						{
							if (bizEnv.IsVatPerLine ())
							{
								dagACT->GetColStr (defaultVat, OACT_DFLT_VAT_GROUP, 0);
								dagJDT1->GetColStr (VatGroup, JDT1_VAT_GROUP, rec);
								if (!_STR_IsSpacesStr (VatGroup))
								{
									dagACT->GetColStr (tmpStr, OACT_ALLOW_VAT_CHANGE, 0);
									if (tmpStr[0] == VAL_NO[0])
									{
										if (_STR_strcmp (VatGroup, defaultVat) != 0)
										{
											Message (JTE_JDT_FORM_NUM, JTE_VAT_GROUP_CHANGE_ERR_STR, NULL, OO_ERROR);
											return ooErrNoMsg;
										}
									}
								}
								else
								{
									dagJDT1->SetColStr (defaultVat, JDT1_VAT_GROUP, rec);
								}
							}
							else
							{
								dagACT->GetColStr (defaultVat, OACT_DFLT_TAX_CODE, 0);
								dagJDT1->GetColStr (VatGroup, JDT1_TAX_CODE, rec);
								if (!_STR_IsSpacesStr (VatGroup))
								{
									dagJDT1->GetColStr (tmpStr, JDT1_TAX_POSTING_ACCOUNT, rec);
									if (tmpStr[0] == VAL_NO[0])
									{
										Message (JTE_JDT_FORM_NUM, JTE_TAX_POST_ACC_MISSING_STR, NULL, OO_ERROR);
										return ooErrNoMsg;
									}
									dagACT->GetColStr (tmpStr, OACT_ALLOW_VAT_CHANGE, 0);
									if (tmpStr[0] == VAL_NO[0])
									{
										if (_STR_strcmp (VatGroup, defaultVat) != 0)
										{
											Message (JTE_JDT_FORM_NUM, JTE_TAX_CODE_CHANGE_ERR_STR, NULL, OO_ERROR);
											return ooErrNoMsg;
										}
										dagJDT1->GetColStr (taxPostAcct, JDT1_TAX_POSTING_ACCOUNT, rec);
										dagACT->GetColStr (tmpStr, OACT_DFLT_POST_ACCT, 0);
										if (taxPostAcct[0] != tmpStr[0])
										{
											Message (JTE_JDT_FORM_NUM, JTE_TAX_POST_ACC_CHANGE_ERR_STR, NULL, OO_ERROR);
											return ooErrNoMsg;
										}
									}
								}
								else
								{
									dagJDT1->SetColStr (defaultVat, JDT1_TAX_CODE, rec);
									dagJDT1->CopyColumn (dagACT, JDT1_TAX_POSTING_ACCOUNT, rec, OACT_DFLT_POST_ACCT, 0);
								}
							}
							dagJDT1->GetColStr (VatGroup, bizEnv.IsVatPerLine () ? JDT1_VAT_GROUP : JDT1_TAX_CODE, rec);
							if (!_STR_IsSpacesStr (VatGroup))
							{
								if (dagJDT1->IsNullCol (JDT1_GROSS_VALUE, rec) && dagJDT1->IsNullCol ( JDT1_GROSS_VALUE_FC, rec))
								{
									dagJDT1->SetColStr (VAL_YES, JDT1_IS_NET, rec);
									if (!dagJDT1->IsNullCol (JDT1_VAT_AMOUNT, rec))
									{
										if (bizEnv.IsVatPerLine())
										{
											condStruct[0].colNum = OVTG_GROUP_CODE;
											condStruct[0].operation	= DBD_EQ;
											_STR_strcpy (condStruct[0].condVal, VatGroup);
											DBD_SetDAGCond (dagVTG, condStruct, 1);

											resStruct[0].colNum = OVTG_CATEGORY;
											DBD_SetDAGRes (dagVTG, resStruct, 1);

											DBD_GetInNewFormat (dagVTG, &dagRES);
											dagRES->GetColStr (tmpStr, 0, 0);
											if (tmpStr[0] == VAL_OUTPUT[0])
											{
												SetErrorLine(rec + 1);
												SetErrorField(JDT1_VAT_AMOUNT);
												SetArrNum(ao_Arr1);
												Message (JTE_JDT_FORM_NUM, JTE_CAN_NOT_EDIT_VAT_SUM_STR, NULL, OO_ERROR);
												return (ooInvalidObject);
											}
											// need manual update
											dagJDT1->SetColStr (VAL_MANUAL_UPDATE, JDT1_IS_NET, rec);
											if (dagJDT1->IsNullCol (JDT1_SYS_VAT_AMOUNT, rec))
											{
												dagJDT1->GetColMoney (&money, JDT1_VAT_AMOUNT, rec, DBM_NOT_ARRAY);
												if (!money.IsZero())
												{
													MONEY	sysMoney;
													dagJDT1->GetColStr (dateStr, JDT1_REF_DATE, rec);
													GNTranslateToSysAmmount (&money, localCurr, dateStr, &sysMoney, bizEnv);
													MONEY_Round (&sysMoney, RC_TAX, sysCurr, bizEnv);
													dagJDT1->SetColMoney (&sysMoney, JDT1_SYS_VAT_AMOUNT, rec, DBM_NOT_ARRAY);
												}
											}
										}
										else
										{
											SetErrorLine(rec + 1);
											SetErrorField(JDT1_VAT_AMOUNT);
											SetArrNum(ao_Arr1);
											Message (JTE_JDT_FORM_NUM, JTE_CAN_NOT_EDIT_VAT_SUM_STR, NULL, OO_ERROR);
											return (ooInvalidObject);
										}
									}
								}
								else
								{
									// By Gross value
									dagJDT1->SetColStr (VAL_NO, JDT1_IS_NET, rec);
									if (dagJDT1->IsNullCol (JDT1_DEBIT_CREDIT, rec))
									{
										if (bizEnv.IsVatPerLine ())
										{
											condStruct[0].colNum = OVTG_GROUP_CODE;
											condStruct[0].operation	= DBD_EQ;
											_STR_strcpy (condStruct[0].condVal, VatGroup);
											DBD_SetDAGCond (dagVTG, condStruct, 1);

											resStruct[0].colNum = OVTG_CATEGORY;
											DBD_SetDAGRes (dagVTG, resStruct, 1);

											DBD_GetInNewFormat (dagVTG, &dagRES);
											dagRES->GetColStr (tmpStr, 0, 0);
											if (tmpStr[0] != VAL_OUTPUT[0])
											{
												debitSide = TRUE;
											}
											else
											{
												debitSide = FALSE;
											}
										}
										else
										{
											dagJDT1->GetColStr (tmpStr, JDT1_TAX_POSTING_ACCOUNT, rec);
											if (tmpStr[0] == JTE_VAL_AR[0])
											{
												debitSide = FALSE;
											}
											else
											{
												debitSide = TRUE;
											}
										}

										if (debitSide)
										{
											dagJDT1->SetColStr(VAL_DEBIT, JDT1_DEBIT_CREDIT, rec);
										}
										else
										{
											dagJDT1->SetColStr(VAL_CREDIT, JDT1_DEBIT_CREDIT, rec);
										}
									}
								}
							}
						}
					}
					else
					{
						dagJDT1->GetColStr (VatGroup, bizEnv.IsVatPerLine () ? JDT1_VAT_GROUP : JDT1_TAX_CODE, rec);
						if (!_STR_IsSpacesStr (VatGroup))
						{
							Message (JTE_JDT_FORM_NUM, JTE_TAX_CODE_IN_BP_LINE_STR, NULL, OO_ERROR);
							return ooErrNoMsg;
						}
					}
				}
			}

			ooErr = GetTaxAdaptor()->CalcTaxWithManualUpdate();
			if (ooErr)
			{
				return ooErr;
			}

			// Enforce balance in LC
			debit.SetToZero();
			credit.SetToZero();
			DAG_GetCount (dagJDT1, &numOfRecs);
			for (rec=0; rec<numOfRecs; rec++)
			{
				dagJDT1->GetColMoney (&money, JDT1_DEBIT, rec, DBM_NOT_ARRAY);
				MONEY_Add(&debit, &money);
				dagJDT1->GetColMoney (&money, JDT1_CREDIT, rec, DBM_NOT_ARRAY);
				MONEY_Add(&credit, &money);
			}
			if (MONEY_Cmp (&debit, &credit))
			{
				MONEY_FromLong (0.02 * MONEY_PERCISION_MUL, &delta);
				dagJDT1->GetColStr (tmpStr, JDT1_VAT_LINE, numOfRecs-1);
				if (tmpStr[0] == VAL_YES[0])
				{
					bool	EnforceBalance = false;	
					MONEY_Sub (&debit, &credit);
					if (debit.IsNegative())
					{
						MONEY_Multiply (&delta, -1, &delta);
						if (debit > delta)
						{
							EnforceBalance = true;
						}
					}
					else
					{
						if (debit < delta)
						{
							EnforceBalance = true;
						}
					}
					if (EnforceBalance)
					{
						for (rec = numOfRecs-1; rec >= 0; rec--)
						{
							dagJDT1->GetColStr (VatGroup, bizEnv.IsVatPerLine () ? JDT1_VAT_GROUP : JDT1_TAX_CODE, rec);
							if (_STR_IsSpacesStr (VatGroup))
							{
								dagJDT1->GetColStr (tmpStr, JDT1_DEBIT_CREDIT, rec);
								if (tmpStr[0] == VAL_DEBIT[0])
								{
									dagJDT1->GetColMoney (&money, JDT1_DEBIT, rec, DBM_NOT_ARRAY);
									if (!money.IsZero())
									{
										MONEY_Sub (&money, &debit);
										dagJDT1->SetColMoney (&money, JDT1_DEBIT, rec, DBM_NOT_ARRAY);
										break;
									}
								}
								else
								{
									dagJDT1->GetColMoney (&money, JDT1_CREDIT, rec, DBM_NOT_ARRAY);
									if (!money.IsZero())
									{
										MONEY_Add (&money, &debit);
										dagJDT1->SetColMoney (&money, JDT1_CREDIT, rec, DBM_NOT_ARRAY);
										break;
									}
								}
							}
						}
					}
				}
			}
			// Enforce balance in SC
			debit.SetToZero();
			credit.SetToZero();
			for (rec=0; rec<numOfRecs; rec++)
			{
				dagJDT1->GetColMoney (&money, JDT1_DEBIT, rec, DBM_NOT_ARRAY);
				MONEY_Add(&debit, &money);
				dagJDT1->GetColMoney (&money, JDT1_CREDIT, rec, DBM_NOT_ARRAY);
				MONEY_Add(&credit, &money);
			}
			if (MONEY_Cmp (&debit, &credit) == 0)
			{
				debit.SetToZero();
				credit.SetToZero();
				for (rec=0; rec<numOfRecs; rec++)
				{
					dagJDT1->GetColMoney (&money, JDT1_SYS_DEBIT, rec, DBM_NOT_ARRAY);
					MONEY_Add(&debit, &money);
					dagJDT1->GetColMoney (&money, JDT1_SYS_CREDIT, rec, DBM_NOT_ARRAY);
					MONEY_Add(&credit, &money);
				}
				if (MONEY_Cmp (&debit, &credit))
				{
					dagJDT1->GetColStr (tmpStr, JDT1_VAT_LINE, numOfRecs-1);
					if (tmpStr[0] == VAL_YES[0] || GetDataSource () != *VAL_OBSERVER_SOURCE)
					{
						found = false;
						MONEY_Sub (&debit, &credit);
						for (rec = numOfRecs-1; rec >= 0; rec--)
						{
							dagJDT1->GetColStr (VatGroup, bizEnv.IsVatPerLine () ? JDT1_VAT_GROUP : JDT1_TAX_CODE, rec);
							if (_STR_IsSpacesStr (VatGroup))
							{
								dagJDT1->GetColStr (tmpStr, JDT1_DEBIT_CREDIT, rec);
								if (tmpStr[0] == VAL_DEBIT[0])
								{
									dagJDT1->GetColMoney (&money, JDT1_SYS_DEBIT, rec, DBM_NOT_ARRAY);
									if (!money.IsZero())
									{
										MONEY_Sub (&money, &debit);
										dagJDT1->SetColMoney (&money, JDT1_SYS_DEBIT, rec, DBM_NOT_ARRAY);
										found = true;
										break;
									}
								}
								else
								{
									dagJDT1->GetColMoney (&money, JDT1_SYS_CREDIT, rec, DBM_NOT_ARRAY);
									if (!money.IsZero())
									{
										MONEY_Add (&money, &debit);
										dagJDT1->SetColMoney (&money, JDT1_SYS_CREDIT, rec, DBM_NOT_ARRAY);
										found = true;
										break;
									}
								}
							}
						}
						if (!found)
						{
							for (rec = numOfRecs-1; rec >= 0; rec--)
							{
								dagJDT1->GetColStr (VatGroup, bizEnv.IsVatPerLine () ? JDT1_VAT_GROUP : JDT1_TAX_CODE, rec);
								dagJDT1->GetColStr (tmpStr, JDT1_VAT_LINE, rec);
								if (!_STR_IsSpacesStr (VatGroup) && tmpStr[0] != VAL_YES[0])
								{
									dagJDT1->GetColStr (tmpStr, JDT1_DEBIT_CREDIT, rec);
									if (tmpStr[0] == VAL_DEBIT[0])
									{
										dagJDT1->GetColMoney (&money, JDT1_SYS_DEBIT, rec, DBM_NOT_ARRAY);
										if (!money.IsZero())
										{
											MONEY_Sub (&money, &debit);
											dagJDT1->SetColMoney (&money, JDT1_SYS_DEBIT, rec, DBM_NOT_ARRAY);
											found = true;
											break;
										}
									}
									else
									{
										dagJDT1->GetColMoney (&money, JDT1_SYS_CREDIT, rec, DBM_NOT_ARRAY);
										if (!money.IsZero())
										{
											MONEY_Add (&money, &debit);
											dagJDT1->SetColMoney (&money, JDT1_SYS_CREDIT, rec, DBM_NOT_ARRAY);
											found = true;
											break;
					}
				}
			}
		}
						}
					}
				}
			}
		}
		else
		{
			for (rec=0; rec<numOfRecs; rec++)
			{
				dagJDT1->GetColStr (tmpStr, JDT1_VAT_GROUP, rec);
				if (!_STR_IsSpacesStr (tmpStr))
				{
					if (dagJDT1->IsNullCol (JDT1_DEBIT_CREDIT, rec))
					{
						if ((dagJDT1->IsNullCol (JDT1_DEBIT, rec) && !dagJDT1->IsNullCol ( JDT1_CREDIT, rec)) ||
								 (dagJDT1->IsNullCol (JDT1_SYS_DEBIT, rec) && !dagJDT1->IsNullCol ( JDT1_SYS_CREDIT, rec)))
						{
							dagJDT1->SetColStr(VAL_CREDIT, JDT1_DEBIT_CREDIT, rec);
						}
						else if ((!dagJDT1->IsNullCol (JDT1_DEBIT, rec) && dagJDT1->IsNullCol (JDT1_CREDIT, rec)) ||
								 (!dagJDT1->IsNullCol (JDT1_SYS_DEBIT, rec) && dagJDT1->IsNullCol ( JDT1_SYS_CREDIT, rec)))
						{
							dagJDT1->SetColStr(VAL_DEBIT, JDT1_DEBIT_CREDIT, rec);
						}
						else
						{
							debitSide = creditSide = FALSE;

							for (rec2=0; rec2<numOfRecs; rec2++)
							{
								if (rec2 != rec)
								{
									dagJDT1->GetColStr (actNum, JDT1_ACCT_NUM, rec2);
									dagJDT1->GetColStr (shortName, JDT1_SHORT_NAME, rec2);
									_STR_LRTrim (actNum);
									_STR_LRTrim (shortName);
									if (_STR_stricmp (shortName, actNum))
									{//it's a card
										dagJDT1->GetColStr (tmpStr, JDT1_DEBIT_CREDIT, rec2);
										if (tmpStr[0] == VAL_DEBIT[0])
										{
											creditSide = TRUE;
											break;
										}
										if (tmpStr[0] == VAL_CREDIT[0])
										{
											debitSide = TRUE;
											break;
										}
									}
								}
							}
							if (debitSide)
							{
								dagJDT1->SetColStr(VAL_DEBIT, JDT1_DEBIT_CREDIT, rec);
							}
							else if (creditSide)
							{
								dagJDT1->SetColStr(VAL_CREDIT, JDT1_DEBIT_CREDIT, rec);
							}
							else
							{
								_STR_GetStringResource (formatStr, JTE_JDT_FORM_NUM, JTE_APPROVE_SIDE_STR, &GetEnv());
								_STR_sprintf (tmpStr, formatStr, rec + 1);
								Message (-1, -1, tmpStr, OO_ERROR);
								return ooErrNoMsg;
							}
						}					
					}
				}
			}
			ooErr = GetTaxAdaptor()->ConvertJDTDagToTaxData();
			if (ooErr)
			{
				return ooErr;
			}
		}
	}

	return ooNoErr;
}

//**********************************************************************************
//**********************************************************************************
SBOErr	CTransactionJournalObject::ComplateStampLine ()
{
        _TRACER("ComplateStampLine");
	SBOErr			ooErr = noErr;
	long			rec, numOfRecs;
	long			rec2, numOfRecs2;
	TCHAR			tmpStr[256], formatStr[256];
	Currency		sysCurr={0};
	Currency		localCurr ={0};
	Currency		currency = {0};
	TCHAR			dateStr[JDT1_DUE_DATE_LEN+1]={0};
	TCHAR			stampTax[OJDT_STAMP_TAX_LEN + 1];
	TCHAR			actNum[JDT1_ACCT_NUM_LEN+1], shortName[JDT1_SHORT_NAME_LEN+1];
	TCHAR			method[OVTG_CALCULATION_METHOD_LEN + 1];
	TCHAR			VatGroup[JDT1_VAT_GROUP_LEN + 1];
	MONEY			tmpM, tmpM2, money, vatPrcnt;
	MONEY			minAmount, fixedAmount, frnAmnt, hundP, delta;
	MONEY			debit, credit, baseDebit, baseCredit, zeroM;
	MONEY			baseDebitSC, baseCreditSC, debitSC, creditSC;
	MONEY			debMoneyFC, credMoneyFC;
	PDAG			dagJDT, dagJDT1, dagVTG;
	PDAG			dagACT, dagRES;
	CBizEnv			&bizEnv = GetEnv ();
	Boolean			found, multiCurr;
	Boolean			debitSide, creditSide;
	DBD_CondStruct	condStruct[2];
	DBD_ResStruct	resStruct[1];

	dagJDT = GetDAG (JDT);
	dagJDT1 = GetDAG(JDT, ao_Arr1);
	dagACT = GetDAG (ACT);
	dagVTG = GetDAG(VTG);

	dagJDT->GetColStr (stampTax, OJDT_STAMP_TAX, 0);
	DAG_GetCount (dagJDT1, &numOfRecs);

	if (bizEnv.IsVatPerLine ())
	{
		dagJDT->GetColStr (tmpStr, OJDT_AUTO_VAT, 0);
		if (tmpStr[0] == VAL_YES[0])
		{
			for (rec=0; rec<numOfRecs; rec++)
			{
				dagJDT1->GetColStr (actNum, JDT1_ACCT_NUM, rec);
				dagJDT1->GetColStr (shortName, JDT1_SHORT_NAME, rec);
				if (_STR_strcmp (actNum, shortName) == 0)
				{
					condStruct[0].colNum = OVTG_ACCOUNT;
					condStruct[0].operation	= DBD_EQ;
					_STR_strcpy (condStruct[0].condVal, shortName);
					condStruct[0].relationship =  0;
					DBD_SetDAGCond (dagVTG, condStruct, 1);
					if (DBD_Count (dagVTG, TRUE) > 0)
					{
						Message (JTE_JDT_FORM_NUM, JTE_VAT_LINE_ERROR_STR, NULL, OO_ERROR);
						return ooErrNoMsg;
					}

					dagJDT1->GetColStr (VatGroup, JDT1_VAT_GROUP, rec);
					if (!_STR_IsSpacesStr (VatGroup))
					{
						dagJDT1->GetColMoney (&tmpM, JDT1_GROSS_VALUE, rec, DBM_NOT_ARRAY);
						if (tmpM.IsZero())
						{
							if (dagJDT1->IsNullCol (JDT1_VAT_AMOUNT, rec))
							{
								dagJDT1->GetColMoney (&money, JDT1_DEBIT, rec, DBM_NOT_ARRAY);
								if (money.IsZero())
								{
									dagJDT1->GetColMoney (&money, JDT1_CREDIT, rec, DBM_NOT_ARRAY);
								}
								if (!money.IsZero())
								{
									dagJDT1->GetColStr (dateStr, JDT1_REF_DATE, rec);
									TZGetStampValue (dagJDT, VatGroup, dateStr, &vatPrcnt, &minAmount, method, &fixedAmount);
									if (method[0] == VAL_RATE[0])
									{
										MONEY_MulMMAndDivML (&money, &vatPrcnt, 100 * MONEY_PERCISION_MUL, &money, FALSE, bizEnv);
										CBizRoundingData tmpRoundingData(*this);
										MONEY_Round (&money, RC_TAX, localCurr, bizEnv, &tmpRoundingData);
										if (!minAmount.IsZero())
										{
											if (MONEY_Cmp (&money, &minAmount) < 0)
											{
												money = minAmount;
											}
										}
									}
									else
									{
										money = fixedAmount;
									}
									dagJDT1->SetColMoney (&money, JDT1_VAT_AMOUNT, rec, DBM_NOT_ARRAY);
								}
							}
							if (dagJDT1->IsNullCol (JDT1_SYS_VAT_AMOUNT, rec))
							{
								dagJDT1->GetColMoney (&money, JDT1_VAT_AMOUNT, rec, DBM_NOT_ARRAY);
								if (!money.IsZero())
								{
									MONEY	sysMoney;
									dagJDT1->GetColStr (dateStr, JDT1_REF_DATE, rec);
									GNTranslateToSysAmmount (&money, localCurr, dateStr, &sysMoney, bizEnv);
									CBizRoundingData tmpRoundingData(*this);
									MONEY_Round (&sysMoney, RC_TAX, sysCurr, bizEnv, &tmpRoundingData);
									dagJDT1->SetColMoney (&sysMoney, JDT1_SYS_VAT_AMOUNT, rec, DBM_NOT_ARRAY);
								}
							}
							dagJDT1->GetColMoney (&money, JDT1_DEBIT, rec, DBM_NOT_ARRAY);
							if (money.IsZero())
							{
								dagJDT1->GetColMoney (&money, JDT1_CREDIT, rec, DBM_NOT_ARRAY);
							}
							dagJDT1->GetColMoney (&tmpM, JDT1_VAT_AMOUNT, rec, DBM_NOT_ARRAY);
							MONEY_Add (&money, &tmpM);
							MONEY_Round (&money, RC_SUM, localCurr, bizEnv);
							dagJDT1->SetColMoney (&money, JDT1_GROSS_VALUE, rec, DBM_NOT_ARRAY);
						}
						else
						{
							// By Gross value
							debitSide = found = FALSE;

							dagJDT1->GetColMoney (&tmpM, JDT1_DEBIT, rec, DBM_NOT_ARRAY);
							if (tmpM.IsZero())
							{
								dagJDT1->GetColMoney (&tmpM, JDT1_CREDIT, rec, DBM_NOT_ARRAY);
								if (!tmpM.IsZero())
								{
									found = TRUE;
									debitSide = FALSE;
								}
							}
							else
							{
								found = TRUE;
								debitSide = TRUE;
							}
							if (!found)
							{
								condStruct[0].colNum = OVTG_GROUP_CODE;
								condStruct[0].operation	= DBD_EQ;
								_STR_strcpy (condStruct[0].condVal, VatGroup);
								DBD_SetDAGCond (dagVTG, condStruct, 1);

								resStruct[0].colNum = OVTG_CATEGORY;
								DBD_SetDAGRes (dagACT, resStruct, 1);

								DBD_GetInNewFormat (dagACT, &dagRES);
								dagRES->GetColStr (tmpStr, 0, 0);
								if (tmpStr[0] != VAL_OUTPUT[0])
								{
									debitSide = TRUE;
								}
								else
								{
									debitSide = FALSE;
								}
							}

							dagJDT1->GetColMoney (&tmpM, JDT1_GROSS_VALUE, rec, DBM_NOT_ARRAY);
							if (!tmpM.IsZero())
							{
								dagJDT1->GetColStr (dateStr, JDT1_REF_DATE, rec);
								TZGetStampValue (dagJDT, VatGroup, dateStr, &vatPrcnt, &minAmount, method, &fixedAmount);
								if (method[0] == VAL_RATE[0])
								{
									if (MONEY_Cmp (&tmpM, &minAmount) > 0)
									{
										MONEY_FromLong (100 * MONEY_PERCISION_MUL, &hundP);
										MONEY_Add (&hundP, &vatPrcnt);
										MONEY_MulMLAndDivMM (&tmpM, 100 * MONEY_PERCISION_MUL, &hundP, &tmpM, FALSE, bizEnv);
										MONEY_Round (&tmpM, RC_PRICE, currency, bizEnv);
										if (debitSide)
										{
											dagJDT1->SetColMoney (&tmpM, JDT1_DEBIT, rec, DBM_NOT_ARRAY);
										}
										else
										{
											dagJDT1->SetColMoney (&tmpM, JDT1_CREDIT, rec, DBM_NOT_ARRAY);
										}
										tmpM2 = tmpM;
										dagJDT1->GetColMoney (&tmpM, JDT1_GROSS_VALUE, rec, DBM_NOT_ARRAY);
										MONEY_Sub (&tmpM, &tmpM2);
										dagJDT1->SetColMoney (&tmpM, JDT1_VAT_AMOUNT, rec, DBM_NOT_ARRAY);
										if (GNCoinCmp (localCurr, sysCurr) != 0)
										{
											MONEY	sysMoney;
											dagJDT1->GetColStr (dateStr, JDT1_REF_DATE, rec);
											GNTranslateToSysAmmount (&tmpM, localCurr, dateStr, &sysMoney, bizEnv);
											CBizRoundingData tmpRoundingData(*this);
											MONEY_Round (&sysMoney, RC_TAX, sysCurr, bizEnv, &tmpRoundingData);
											dagJDT1->SetColMoney (&sysMoney, JDT1_SYS_VAT_AMOUNT, rec, DBM_NOT_ARRAY);
										}
										else
										{
											dagJDT1->SetColMoney (&tmpM, JDT1_SYS_VAT_AMOUNT, rec, DBM_NOT_ARRAY);
										}
									}
									else
									{
										if (debitSide)
										{
											dagJDT1->SetColMoney (&zeroM, JDT1_DEBIT, rec, DBM_NOT_ARRAY);
										}
										else
										{
											dagJDT1->SetColMoney (&zeroM, JDT1_CREDIT, rec, DBM_NOT_ARRAY);
										}
										dagJDT1->SetColMoney (&zeroM, JDT1_VAT_AMOUNT, rec, DBM_NOT_ARRAY);
										dagJDT1->SetColMoney (&zeroM, JDT1_SYS_VAT_AMOUNT, rec, DBM_NOT_ARRAY);
									}
								}
								else
								{
									if (MONEY_Cmp (&tmpM, &fixedAmount) > 0)
									{
										MONEY_Sub (&tmpM, &fixedAmount);
										MONEY_Round (&tmpM, RC_PRICE, currency, bizEnv);
										if (debitSide)
										{
											dagJDT1->SetColMoney (&tmpM, JDT1_DEBIT, rec, DBM_NOT_ARRAY);
										}
										else
										{
											dagJDT1->SetColMoney (&tmpM, JDT1_CREDIT, rec, DBM_NOT_ARRAY);
										}
										tmpM2 = tmpM;
										dagJDT1->GetColMoney (&tmpM, JDT1_GROSS_VALUE, rec, DBM_NOT_ARRAY);
										MONEY_Sub (&tmpM, &tmpM2);
										dagJDT1->SetColMoney (&tmpM, JDT1_VAT_AMOUNT, rec, DBM_NOT_ARRAY);
										if (GNCoinCmp (localCurr, sysCurr) != 0)
										{
											MONEY	sysMoney;
											dagJDT1->GetColStr (dateStr, JDT1_REF_DATE, rec);
											GNTranslateToSysAmmount (&tmpM, localCurr, dateStr, &sysMoney, bizEnv);
											CBizRoundingData tmpRoundingData(*this);
											MONEY_Round (&sysMoney, RC_TAX, sysCurr, bizEnv, &tmpRoundingData);
											dagJDT1->SetColMoney (&sysMoney, JDT1_SYS_VAT_AMOUNT, rec, DBM_NOT_ARRAY);
										}
										else
										{
											dagJDT1->SetColMoney (&tmpM, JDT1_SYS_VAT_AMOUNT, rec, DBM_NOT_ARRAY);
										}
									}
									else
									{
										if (debitSide)
										{
											dagJDT1->SetColMoney (&zeroM, JDT1_DEBIT, rec, DBM_NOT_ARRAY);
										}
										else
										{
											dagJDT1->SetColMoney (&zeroM, JDT1_CREDIT, rec, DBM_NOT_ARRAY);
										}
										dagJDT1->SetColMoney (&zeroM, JDT1_VAT_AMOUNT, rec, DBM_NOT_ARRAY);
										dagJDT1->SetColMoney (&zeroM, JDT1_SYS_VAT_AMOUNT, rec, DBM_NOT_ARRAY);
									}
								}
							}
						}
					}
				}
				else
				{
					dagJDT1->GetColStr (VatGroup, JDT1_VAT_GROUP, rec);
					if (!_STR_IsSpacesStr (VatGroup))
					{
						Message (JTE_JDT_FORM_NUM, JTE_TAX_CODE_IN_BP_LINE_STR, NULL, OO_ERROR);
						return ooErrNoMsg;
					}
				}
			}
			// Add Vat lines
			dagJDT->GetColStr (dateStr, OJDT_REF_DATE, 0);
			for (rec=0; rec<numOfRecs; rec++)
			{
				dagJDT1->GetColStr (VatGroup, JDT1_VAT_GROUP, rec);
				if (!_STR_IsSpacesStr (VatGroup))
				{
					dagJDT1->GetColStr (tmpStr, JDT1_VAT_LINE, rec);
					if (tmpStr[0] == VAL_NO[0])
					{
						found = FALSE;
						DAG_GetCount (dagJDT1, &numOfRecs2);
						for (rec2=0; rec2<numOfRecs2; rec2++)
						{
							dagJDT1->GetColStr (tmpStr, JDT1_VAT_LINE, rec2);
							if (tmpStr[0] == VAL_YES[0])
							{
								dagJDT1->GetColStr (tmpStr, JDT1_VAT_GROUP, rec2);
								if (_STR_strcmp (tmpStr, VatGroup)==0)
								{
									found = TRUE;
								}
							}
						}
						if (!found)
						{
							ooErr = DAG_SetSize (dagJDT1, numOfRecs2 + 1, dbmKeepData);
							if (ooErr)
							{
								return ooErr;
							}
							dagJDT1->SetColStr (VAL_YES, JDT1_VAT_LINE, numOfRecs2);
							dagJDT1->SetColStr (VatGroup, JDT1_VAT_GROUP, numOfRecs2);

							condStruct[0].colNum = OVTG_GROUP_CODE;
							condStruct[0].operation	= DBD_EQ;
							_STR_strcpy (condStruct[0].condVal, VatGroup);
							condStruct[0].relationship =  0;
							DBD_SetDAGCond (dagVTG, condStruct, 1);

							resStruct[0].colNum = OVTG_ACCOUNT;
							DBD_SetDAGRes (dagVTG, resStruct, 1);

							ooErr = DBD_GetInNewFormat (dagVTG, &dagRES);
							if (ooErr)
							{
								return ooErr;
							}
							dagJDT1->CopyColumn (dagRES, JDT1_SHORT_NAME, numOfRecs2, 0, 0);
							dagJDT1->CopyColumn (dagRES, JDT1_ACCT_NUM, numOfRecs2, 0, 0);
						}
					}
				}
			}
			// Init Vat lines sums
			DAG_GetCount (dagJDT1, &numOfRecs);
			for (rec=0; rec<numOfRecs; rec++)
			{
				dagJDT1->GetColStr (tmpStr, JDT1_VAT_LINE, rec);
				if (tmpStr[0] == VAL_YES[0])
				{
					baseDebit.SetToZero();
					baseCredit.SetToZero();
					debit.SetToZero();
					credit.SetToZero();
					debMoneyFC.SetToZero();
					credMoneyFC.SetToZero();
					baseDebitSC.SetToZero();
					baseCreditSC.SetToZero();
					debitSC.SetToZero();
					creditSC.SetToZero();
					currency[0] = 0;
					multiCurr = FALSE;
					dagJDT1->GetColStr (VatGroup, JDT1_VAT_GROUP, rec);
					for (rec2=0; rec2<numOfRecs; rec2++)
					{
						dagJDT1->GetColStr (tmpStr, JDT1_VAT_LINE, rec2);
						if (tmpStr[0] == VAL_NO[0])
						{
							dagJDT1->GetColStr (tmpStr, JDT1_VAT_GROUP, rec2);
							if (_STR_strcmp (tmpStr, VatGroup)==0)
							{
								dagJDT1->GetColMoney (&money, JDT1_DEBIT, rec2, DBM_NOT_ARRAY);
								if (!money.IsZero())
								{
									MONEY_Add(&baseDebit ,&money);
									dagJDT1->GetColMoney (&money, JDT1_VAT_AMOUNT, rec2, DBM_NOT_ARRAY);
									MONEY_Add(&debit, &money);

									dagJDT1->GetColMoney (&money, JDT1_SYS_DEBIT, rec2, DBM_NOT_ARRAY);
									MONEY_Add(&baseDebitSC ,&money);
									dagJDT1->GetColMoney (&money, JDT1_SYS_VAT_AMOUNT, rec2, DBM_NOT_ARRAY);
									MONEY_Add(&debitSC, &money);

									dagJDT1->GetColMoney (&money, JDT1_FC_DEBIT, rec2, DBM_NOT_ARRAY);
									if (!money.IsZero())
									{
										dagJDT1->GetColStr (dateStr, JDT1_REF_DATE, rec2);
										bizEnv.GetVatPercent (VatGroup, bizEnv.GetDateForTaxRateDetermination (dagJDT1, rec2), &vatPrcnt); // NOTE - we should use TZGetStampValue!!!
										MONEY_MulMMAndDivML (&money, &vatPrcnt, 100 * MONEY_PERCISION_MUL, &money, FALSE, bizEnv);
										CBizRoundingData tmpRoundingData(*this);
										MONEY_Round (&money, RC_TAX, localCurr, bizEnv, &tmpRoundingData);
										MONEY_Add(&debMoneyFC, &money);
										dagJDT1->GetColStr (tmpStr, JDT1_FC_CURRENCY, rec2);
										_STR_LRTrim (tmpStr);
										if (!currency[0])
										{
											_STR_strcpy (currency, tmpStr);
										}
										else
										{
											if (GNCoinCmp (currency, tmpStr))
											{
												multiCurr = TRUE;
											}
										}
									}
								}
								else
								{
									dagJDT1->GetColMoney (&money, JDT1_CREDIT, rec2, DBM_NOT_ARRAY);
									if (!money.IsZero())
									{
										MONEY_Add(&baseCredit ,&money);
										dagJDT1->GetColMoney (&money, JDT1_VAT_AMOUNT, rec2, DBM_NOT_ARRAY);
										MONEY_Add(&credit, &money);

										dagJDT1->GetColMoney (&money, JDT1_SYS_CREDIT, rec2, DBM_NOT_ARRAY);
										MONEY_Add(&baseCreditSC ,&money);
										dagJDT1->GetColMoney (&money, JDT1_SYS_VAT_AMOUNT, rec2, DBM_NOT_ARRAY);
										MONEY_Add(&creditSC, &money);
									}
									dagJDT1->GetColMoney (&money, JDT1_FC_CREDIT, rec2, DBM_NOT_ARRAY);
									if (!money.IsZero())
									{
										dagJDT1->GetColStr (dateStr, JDT1_REF_DATE, rec2);
										bizEnv.GetVatPercent (VatGroup, bizEnv.GetDateForTaxRateDetermination (dagJDT1, rec2), &vatPrcnt); // NOTE - we should use TZGetStampValue!!!
										MONEY_MulMMAndDivML (&money, &vatPrcnt, 100 * MONEY_PERCISION_MUL, &money, FALSE, bizEnv);
										CBizRoundingData tmpRoundingData(*this);
										MONEY_Round (&money, RC_TAX, localCurr, bizEnv, &tmpRoundingData);
										MONEY_Add(&credMoneyFC, &money);
										dagJDT1->GetColStr (tmpStr, JDT1_FC_CURRENCY, rec2);
										_STR_LRTrim (tmpStr);
										if (!currency[0])
										{
											_STR_strcpy (currency, tmpStr);
										}
										else
										{
											if (GNCoinCmp (currency, tmpStr))
											{
												multiCurr = TRUE;
											}
										}
									}
								}
							}
						}
					}
					MONEY_Round (&debit, RC_SUM, localCurr, bizEnv);
					MONEY_Round (&credit, RC_SUM, localCurr, bizEnv);
					MONEY_Round (&debitSC, RC_SUM, sysCurr, bizEnv);
					MONEY_Round (&creditSC, RC_SUM, sysCurr, bizEnv);
					MONEY_Round (&debMoneyFC, RC_SUM, currency, bizEnv);
					MONEY_Round (&credMoneyFC, RC_SUM, currency, bizEnv);
					if (!debit.IsZero() || !baseDebit.IsZero())
					{
						if (credit.IsZero() && baseCredit.IsZero())
						{
							dagJDT1->SetColStr(VAL_DEBIT, JDT1_DEBIT_CREDIT, rec);
							dagJDT1->SetColMoney (&debit, JDT1_DEBIT, rec, DBM_NOT_ARRAY);
							dagJDT1->SetColMoney (&baseDebit, JDT1_BASE_SUM, rec, DBM_NOT_ARRAY);
							dagJDT1->SetColMoney (&debitSC, JDT1_SYS_DEBIT, rec, DBM_NOT_ARRAY);
							dagJDT1->SetColMoney (&baseDebitSC, JDT1_SYS_BASE_SUM, rec, DBM_NOT_ARRAY);
							if (currency[0] && !multiCurr)
							{
								dagJDT1->SetColMoney (&debMoneyFC, JDT1_FC_DEBIT, rec, DBM_NOT_ARRAY);
								dagJDT1->SetColStr (currency, JDT1_FC_CURRENCY, rec);
							}
						}
						else
						{
							if (MONEY_Cmp (&debit, &credit) > 0)
							{
								dagJDT1->SetColStr(VAL_DEBIT, JDT1_DEBIT_CREDIT, rec);
								money = debit;
								MONEY_Sub(&money, &credit);
								dagJDT1->SetColMoney (&money, JDT1_DEBIT, rec, DBM_NOT_ARRAY);
								money = baseDebit;
								MONEY_Sub(&money, &baseCredit);
								dagJDT1->SetColMoney (&money, JDT1_BASE_SUM, rec, DBM_NOT_ARRAY);

								money = debitSC;
								MONEY_Sub(&money, &creditSC);
								dagJDT1->SetColMoney (&money, JDT1_SYS_DEBIT, rec, DBM_NOT_ARRAY);
								money = baseDebitSC;
								MONEY_Sub(&money, &baseCreditSC);
								dagJDT1->SetColMoney (&money, JDT1_SYS_BASE_SUM, rec, DBM_NOT_ARRAY);

								if (currency[0] && !multiCurr)
								{
									money = debit;
									MONEY_Sub(&money, &credit);
									ooErr = GNLocalToForeignRate (&money, currency, dateStr, 0.0, &frnAmnt, GetEnv ());
									if (ooErr)
									{
										return	(ooErr);	
									}
									dagJDT1->SetColMoney (&frnAmnt, JDT1_FC_DEBIT, rec, DBM_NOT_ARRAY);
									dagJDT1->SetColStr (currency, JDT1_FC_CURRENCY, rec);
								}
							}
							else
							{
								dagJDT1->SetColStr(VAL_CREDIT, JDT1_DEBIT_CREDIT, rec);
								money = credit;
								MONEY_Sub(&money, &debit);
								dagJDT1->SetColMoney (&money, JDT1_CREDIT, rec, DBM_NOT_ARRAY);
								money = baseCredit;
								MONEY_Sub(&money, &baseDebit);
								dagJDT1->SetColMoney (&money, JDT1_BASE_SUM, rec, DBM_NOT_ARRAY);

								money = creditSC;
								MONEY_Sub(&money, &debitSC);
								dagJDT1->SetColMoney (&money, JDT1_SYS_CREDIT, rec, DBM_NOT_ARRAY);
								money = baseCreditSC;
								MONEY_Sub(&money, &baseDebitSC);
								dagJDT1->SetColMoney (&money, JDT1_SYS_BASE_SUM, rec, DBM_NOT_ARRAY);

								if (currency[0] && !multiCurr)
								{
									money = credit;
									MONEY_Sub(&money, &debit);
									ooErr = GNLocalToForeignRate (&money, currency, dateStr, 0.0, &frnAmnt, GetEnv ());
									if (ooErr)
									{
										return	(ooErr);	
									}
									dagJDT1->SetColMoney (&frnAmnt, JDT1_FC_CREDIT, rec, DBM_NOT_ARRAY);
									dagJDT1->SetColStr (currency, JDT1_FC_CURRENCY, rec);
								}
							}
						}
					}
					else if (!credit.IsZero() || !baseCredit.IsZero())
					{
						dagJDT1->SetColStr(VAL_CREDIT, JDT1_DEBIT_CREDIT, rec);
						dagJDT1->SetColMoney (&credit, JDT1_CREDIT, rec, DBM_NOT_ARRAY);
						dagJDT1->SetColMoney (&baseCredit, JDT1_BASE_SUM, rec, DBM_NOT_ARRAY);
						dagJDT1->SetColMoney (&creditSC, JDT1_SYS_CREDIT, rec, DBM_NOT_ARRAY);
						dagJDT1->SetColMoney (&baseCreditSC, JDT1_SYS_BASE_SUM, rec, DBM_NOT_ARRAY);
						if (currency[0] && !multiCurr)
						{
							dagJDT1->SetColMoney (&credMoneyFC, JDT1_FC_CREDIT, rec, DBM_NOT_ARRAY);
							dagJDT1->SetColStr (currency, JDT1_FC_CURRENCY, rec);
						}
					}
				}
			}
			// Enforce balance in LC
			debit.SetToZero();
			credit.SetToZero();
			for (rec=0; rec<numOfRecs; rec++)
			{
				dagJDT1->GetColMoney (&money, JDT1_DEBIT, rec, DBM_NOT_ARRAY);
				MONEY_Add(&debit, &money);
				dagJDT1->GetColMoney (&money, JDT1_CREDIT, rec, DBM_NOT_ARRAY);
				MONEY_Add(&credit, &money);
			}
			if (MONEY_Cmp (&debit, &credit))
			{
				MONEY_FromLong (0.02 * MONEY_PERCISION_MUL, &delta);
				dagJDT1->GetColStr (tmpStr, JDT1_VAT_LINE, numOfRecs-1);
				if (tmpStr[0] == VAL_YES[0])
				{
					bool	EnforceBalance = false;	
					MONEY_Sub (&debit, &credit);
					if (debit.IsNegative())
					{
						MONEY_Multiply (&delta, -1, &delta);
						if (debit > delta)
						{
							EnforceBalance = true;
						}
					}
					else
					{
						if (debit < delta)
						{
							EnforceBalance = true;
						}
					}
					if (EnforceBalance)
					{
						for (rec = numOfRecs-1; rec >= 0; rec--)
						{
							dagJDT1->GetColStr (VatGroup, JDT1_VAT_GROUP, rec);
							if (_STR_IsSpacesStr (VatGroup))
							{
								dagJDT1->GetColStr (tmpStr, JDT1_DEBIT_CREDIT, rec);
								if (tmpStr[0] == VAL_DEBIT[0])
								{
									dagJDT1->GetColMoney (&money, JDT1_DEBIT, rec, DBM_NOT_ARRAY);
									if (!money.IsZero())
									{
										MONEY_Sub (&money, &debit);
										dagJDT1->SetColMoney (&money, JDT1_DEBIT, rec, DBM_NOT_ARRAY);
										break;
									}
								}
								else
								{
									dagJDT1->GetColMoney (&money, JDT1_CREDIT, rec, DBM_NOT_ARRAY);
									if (!money.IsZero())
									{
										MONEY_Add (&money, &debit);
										dagJDT1->SetColMoney (&money, JDT1_CREDIT, rec, DBM_NOT_ARRAY);
										break;
									}
								}
							}
						}
					}
				}
			}
			// Enforce balance in SC
			debit.SetToZero();
			credit.SetToZero();
			for (rec=0; rec<numOfRecs; rec++)
			{
				dagJDT1->GetColMoney (&money, JDT1_DEBIT, rec, DBM_NOT_ARRAY);
				MONEY_Add(&debit, &money);
				dagJDT1->GetColMoney (&money, JDT1_CREDIT, rec, DBM_NOT_ARRAY);
				MONEY_Add(&credit, &money);
			}
			if (MONEY_Cmp (&debit, &credit) == 0)
			{
				debit.SetToZero();
				credit.SetToZero();
				for (rec=0; rec<numOfRecs; rec++)
				{
					dagJDT1->GetColMoney (&money, JDT1_SYS_DEBIT, rec, DBM_NOT_ARRAY);
					MONEY_Add(&debit, &money);
					dagJDT1->GetColMoney (&money, JDT1_SYS_CREDIT, rec, DBM_NOT_ARRAY);
					MONEY_Add(&credit, &money);
				}
				if (MONEY_Cmp (&debit, &credit))
				{
					dagJDT1->GetColStr (tmpStr, JDT1_VAT_LINE, numOfRecs-1);
					if (tmpStr[0] == VAL_YES[0])
					{
						MONEY_Sub (&debit, &credit);
						for (rec = numOfRecs-1; rec >= 0; rec--)
						{
							dagJDT1->GetColStr (VatGroup, JDT1_VAT_GROUP, rec);
							if (_STR_IsSpacesStr (VatGroup))
							{
								dagJDT1->GetColStr (tmpStr, JDT1_DEBIT_CREDIT, rec);
								if (tmpStr[0] == VAL_DEBIT[0])
								{
									dagJDT1->GetColMoney (&money, JDT1_SYS_DEBIT, rec, DBM_NOT_ARRAY);
									if (!money.IsZero())
									{
										MONEY_Sub (&money, &debit);
										dagJDT1->SetColMoney (&money, JDT1_SYS_DEBIT, rec, DBM_NOT_ARRAY);
										break;
									}
								}
								else
								{
									dagJDT1->GetColMoney (&money, JDT1_SYS_CREDIT, rec, DBM_NOT_ARRAY);
									if (!money.IsZero())
									{
										MONEY_Add (&money, &debit);
										dagJDT1->SetColMoney (&money, JDT1_SYS_CREDIT, rec, DBM_NOT_ARRAY);
										break;
									}
								}
							}
						}
					}
				}
			}
		}
		else
		{
			for (rec=0; rec<numOfRecs; rec++)
			{
				dagJDT1->GetColStr (tmpStr, JDT1_VAT_GROUP, rec);
				if (!_STR_IsSpacesStr (tmpStr))
				{
					if (dagJDT1->IsNullCol (JDT1_DEBIT_CREDIT, rec))
					{
						dagJDT1->SetColStr (VAL_YES, JDT1_VAT_LINE, rec);
						if ((dagJDT1->IsNullCol (JDT1_DEBIT, rec) && !dagJDT1->IsNullCol (JDT1_CREDIT, rec)) ||
							(dagJDT1->IsNullCol (JDT1_SYS_DEBIT, rec) && !dagJDT1->IsNullCol ( JDT1_SYS_CREDIT, rec)))
						{
							dagJDT1->SetColStr(VAL_CREDIT, JDT1_DEBIT_CREDIT, rec);
						}
						else if ((!dagJDT1->IsNullCol (JDT1_DEBIT, rec) && dagJDT1->IsNullCol (JDT1_CREDIT, rec)) ||
							(!dagJDT1->IsNullCol (JDT1_SYS_DEBIT, rec) && dagJDT1->IsNullCol (JDT1_SYS_CREDIT, rec)))
						{
							dagJDT1->SetColStr(VAL_DEBIT, JDT1_DEBIT_CREDIT, rec);
						}
						else
						{
							debitSide = creditSide = FALSE;

							for (rec2=0; rec2<numOfRecs; rec2++)
							{
								if (rec2 != rec)
								{
									dagJDT1->GetColStr (actNum, JDT1_ACCT_NUM, rec2);
									dagJDT1->GetColStr (shortName, JDT1_SHORT_NAME, rec2);
									_STR_LRTrim (actNum);
									_STR_LRTrim (shortName);
									if (_STR_stricmp (shortName, actNum))
									{//it's a card
										dagJDT1->GetColStr (tmpStr, JDT1_DEBIT_CREDIT, rec2);
										if (tmpStr[0] == VAL_DEBIT[0])
										{
											creditSide = TRUE;
											break;
										}
										if (tmpStr[0] == VAL_CREDIT[0])
										{
											debitSide = TRUE;
											break;
										}
									}
								}
							}
							if (debitSide)
							{
								dagJDT1->SetColStr(VAL_DEBIT, JDT1_DEBIT_CREDIT, rec);
							}
							else if (creditSide)
							{
								dagJDT1->SetColStr(VAL_CREDIT, JDT1_DEBIT_CREDIT, rec);
							}
							else
							{
								_STR_GetStringResource (formatStr, JTE_JDT_FORM_NUM, JTE_APPROVE_SIDE_STR, &GetEnv());
								_STR_sprintf (tmpStr, formatStr, rec + 1);
								Message (-1, -1, tmpStr, OO_ERROR);
								return ooErrNoMsg;
							}
						}
					}
				}
			}
		}
	}

	return ooNoErr;
}

/************************************************************************/
/************************************************************************/
void	CTransactionJournalObject::CopyNoType (const CBusinessService& other)
{
        _TRACER("CopyNoType");
	CSystemBusinessObject::CopyNoType (other);
	if (other.GetID() == JDT)
	{
		CTransactionJournalObject	*bizObject = (CTransactionJournalObject*) &other;
		m_jrnlKeys = bizObject->GetJournalKeys ();
		m_stornoExtraInfoCreator = ((CTransactionJournalObject&)other).m_stornoExtraInfoCreator;

		m_isPostingPreviewMode = bizObject->m_isPostingPreviewMode;
	}
}

//**********************************************************************************
//**********************************************************************************
SBOErr	CTransactionJournalObject::RecordHist (CBusinessObject& bizObject, PDAG dag)
{
        _TRACER("RecordHist");
	SBOErr		sboErr;
	long		num = 0, series, seqCode;
	long		transType, createdBy, baseRef;
	TCHAR		baseRefStr[OJDT_BASE_REF_LEN+1];
	
	CBizEnv&	bizEnv = bizObject.GetEnv ();
	PDAG		dagOBJ = bizObject.GetDAG ();
	long		bizObjId = bizObject.GetID().strtol();

	sboErr = IsValidUserPermissions();
	IF_ERROR_RETURN(sboErr);

	dag->GetColLong(&series, OJDT_SERIES);

	if( !(bizObjId != JDT && bizObject.IsUpdateNum()) )
	{
		if (!series)
		{
			// ************************** MultipleOpenPeriods *************************
			SBOString refDate;
			dag->GetColStr (refDate, OJDT_REF_DATE);
			if (refDate.Trim().IsSpacesStr())
				DBM_DATE_Get (refDate, bizEnv);

			// VF_MultiBranch_EnabledInOADM
			series = bizEnv.GetDefaultSeriesByDate (bizObject.GetBPLId (), SBOString (JDT), refDate);
			// ************************************************************************
			dag->SetColLong (series, OJDT_SERIES, 0);
		}
	}

	//Sequence
	if (VF_MultipleRegistrationNumber (bizEnv))
	{
		dag->GetColLong (&seqCode, OJDT_SEQ_CODE);
		if (seqCode == 0 || seqCode == -1)
		{
			CSequenceManager* seqManager = GetEnv ().GetSequenceManager ();
			sboErr = seqManager->LoadDfltSeq (*this);
			if (!sboErr)
			{
				sboErr = seqManager->FillDAGBySeq (*this);
				if (!sboErr)
				{
					sboErr = seqManager->HandleSerial (*this);
					IF_ERROR_RETURN (sboErr);
				}
			}
		}
	}

	//Supplementary Code OnCreate
	if(VF_SupplCode(GetEnv ()))
	{
		CSupplCodeManager* pManager = bizEnv.GetSupplCodeManager();
		SBOString strNum;
		dag->GetColStr(strNum, OJDT_SUPPL_CODE);
		if(strNum.IsNull() || strNum.IsEmpty())
		{
			Date PostDate;
			dag->GetColStr(PostDate, OJDT_REF_DATE);
			sboErr = pManager->CodeChange(*this, PostDate);
			IF_ERROR_RETURN (sboErr);
			sboErr = pManager->CheckCode(*this);
			if(sboErr)
			{
				CMessagesManager::GetHandle()->Message(_54_APP_MSG_CORE_SUPPL_CODE_CODE_EXIST, EMPTY_STR, this);
				return ooInvalidObject;
			}
		}
	}

	dag->GetColLong(&transType, OJDT_TRANS_TYPE);
	if (bizEnv.IsLocalSettingsFlag(lsf_IsDocNumMethod))
	{
		if (transType != OPEN_BLNC_TYPE && transType != CLOSE_BLNC_TYPE && transType != MANUAL_BANK_TRANS_TYPE)
		{
			dag->GetColLong(&num, OJDT_NUMBER);
		}
		dag->SetColLong (series, OJDT_DOC_SERIES, 0);
	}
	else
	{
		if (transType < 0 || transType == JDT || !bizEnv.IsSerieObject(SBOString (transType)))
		{
			dag->SetColLong (series, OJDT_DOC_SERIES, 0);
		}
		else
		{
			//nothing to do
			//it should be filled by operation object
		}
	}
	SetSeries(series);
	if (!num)
	{
		sboErr = GetNextSerial (TRUE);
	}
	else
	{
		sboErr = GetNextAutoKey (TRUE);
	}
	if (sboErr)
	{
		return (sboErr);
	}

	long theKey = GetInternalKey ();
	if (!num)
	{
		num = GetNextNum();
	}

	dag->SetLongByColType (theKey, ABSOLUTE_ENT_FLD, 0);
	dag->SetColLong (num, OJDT_NUMBER, 0);

	if (_STR_atol (bizObject.GetID ()) != JDT)
	{
		dagOBJ->GetLongByColType (&theKey, ABSOLUTE_ENT_FLD, 0);
	}
	else
	{
		dag->GetColLong(&createdBy, OJDT_CREATED_BY);
		if ((transType == DPS || transType == DPT || transType == RCT || transType == VPM || transType == MRV || 
			 transType == IPF || transType == ITR || transType == CHO || transType == JST || transType == IQR ||
			 transType == IQI || transType == IWZ || transType == ACQ || transType == ACD || transType == DRN || 
			 transType == MDP || transType == FTR || transType == FAR || transType == RTI) && createdBy != 0)
		{
			theKey = createdBy;
		}
		if (VF_ExciseInvoice(bizEnv) && transType == WTR && createdBy > 0)
		{
			theKey = createdBy;
	}
	}
	dag->SetColLong (theKey, OJDT_CREATED_BY, 0);

	dag->GetColLong(&baseRef, OJDT_BASE_REF);
	if (_STR_atol (bizObject.GetID()) == JDT && 
		(transType == DPS || transType == DPT || transType == RCT || transType == VPM ||  transType == MRV || 
		 transType == IPF || transType == ITR || transType == CHO || transType == JST || transType == IQR  || 
		 transType == IQI || transType == IWZ || transType == ACQ || transType == ACD || transType == DRN || 
		 transType == MDP || transType == FTR || transType == FAR || transType == RTI) && baseRef != 0)
	{
		theKey = baseRef;
	}
	else
	{
		dagOBJ->GetLongByColType (&theKey, SERIAL_NUM_FLD, 0);
	}
	if (VF_ExciseInvoice(bizEnv) && transType == WTR && baseRef > 0)
	{
		theKey = baseRef;
	}
	_STR_ltoa (theKey, baseRefStr);
	dag->SetColStr (baseRefStr, OJDT_BASE_REF, 0);

	if ( !(bizObject.IsUpdateNum()||bizObject.IsExCommand3(ooEx3DontTouchNextNum) ))
	{
	    bizObject.SetInternalKey (theKey);
	}

	return sboErr;
}

//**********************************************************************************
//**********************************************************************************

bool CTransactionJournalObject::OnCanCancel ()
{
	CBizEnv	&bizEnv = GetEnv();
	SBOErr	ooErr = noErr;
	bool canCancelJE = false;

	if (IsPaymentOrdered())
	{
		return false;
	}

	PDAG dagJDT = GetDAG ();
	PDAG dagJDT1 = GetDAG (JDT, ao_Arr1);
	long sourceDoc = 0;
	dagJDT->GetColLong (&sourceDoc, OJDT_TRANS_TYPE, 0);

	
	if (sourceDoc == JDT || 
		sourceDoc == OPEN_BLNC_TYPE || sourceDoc == CLOSE_BLNC_TYPE ||
		sourceDoc == MANUAL_BANK_TRANS_TYPE ||
		(sourceDoc == WTR && VF_ExciseInvoice (bizEnv) && this->m_isVatJournalEntry))
	{
		canCancelJE = true;

		SBOString autoStrorno;
		long canceledTrans = 0;
		dagJDT->GetColStrAndTrim (autoStrorno, OJDT_AUTO_STORNO, 0);
		if (autoStrorno == VAL_YES)
		{
			canCancelJE = false;
		}
		dagJDT->GetColLong (&canceledTrans, OJDT_STORNO_TO_TRANS, 0);
		if (canceledTrans > 0)
		{
			canCancelJE = false;
		}
	}

	if (VF_MultiBranch_EnabledInOADM (bizEnv) && (sourceDoc == RCT || sourceDoc == VPM))
	{
		PDAG dagORCT = GetDAG (sourceDoc);
		if (dagORCT != NULL)
		{
			SBOString isCentralizedPayment = dagORCT->GetColStrAndTrim (ORCT_BPL_CENT_PMT, 0, coreSystemDefault);
			long pmntTransId = dagORCT->GetColStrAndTrim (ORCT_TRANS_NUM, 0, coreSystemDefault).strtol ();
			long currTransId = dagJDT->GetColStrAndTrim (OJDT_JDT_NUM, 0, coreSystemDefault).strtol ();
			long createdBy = dagJDT->GetColStrAndTrim (OJDT_CREATED_BY, 0, coreSystemDefault).strtol ();
			long pmtAbsEntry = dagORCT->GetColStrAndTrim (ORCT_ABS_ENTRY, 0, coreSystemDefault).strtol ();
			if (isCentralizedPayment == VAL_YES
				&& pmntTransId != currTransId
				&& createdBy == pmtAbsEntry
				)
			{
				canCancelJE = true;
			}
		}
	}

	long canceledTrans = 0;
	dagJDT->GetColLong (&canceledTrans, OJDT_JDT_NUM, 0);
	try
	{
		DBQRetrieveStatement stmt (bizEnv);
		DBQTable tOJDT = stmt.From (bizEnv.ObjectToTable (JDT, ao_Main));

		stmt.Select ().Count ().Col (tOJDT, OJDT_JDT_NUM);
		stmt.Where ().Col (tOJDT, OJDT_STORNO_TO_TRANS).EQ ().Val (canceledTrans);

		APCompanyDAG pResDag;
		stmt.Execute (pResDag);
		long cancelNum = 0;
		pResDag->GetColLong (&cancelNum, 0);
		if (cancelNum > 0)
		{
			canCancelJE = false;
		}
	}
	catch (DBMException &e)
	{
		ooErr = e.GetCode ();
	}

	return canCancelJE;
}

SBOErr	CTransactionJournalObject::OnCancel ()
{
        _TRACER("OnCancel");
	SBOErr			sboErr;
	DBD_CondStruct	condStruct[2] ;
	long			sourceDoc, canceledTrans, series;
	Date			dateStr;
	TCHAR			msgStr[256], tmpStr[256];
	CBizEnv			&bizEnv = GetEnv();
	PDAG dagJDT = GetDAG ();
	PDAG dagJDT1 = GetDAG (JDT, ao_Arr1);

	if (!OnCanCancel())
	{
		Message (JTE_JDT_FORM_NUM, JTE_CANT_CANCEL_ERROR_STR, NULL, OO_ERROR);
		return ooErrNoMsg;
	}

	dagJDT->GetColLong (&sourceDoc, OJDT_TRANS_TYPE, 0);
	dagJDT->GetColStr (dateStr, OJDT_REF_DATE, 0);
	dagJDT->GetColLong (&canceledTrans, OJDT_JDT_NUM);

	condStruct[0].colNum = OJDT_JDT_NUM;
	condStruct[0].condVal = canceledTrans;
	condStruct[0].operation = DBD_EQ;
	condStruct[0].relationship = DBD_AND;

	condStruct[1].colNum = OJDT_REF_DATE;
	_STR_strcpy (condStruct[1].condVal, dateStr);
	condStruct[1].operation = DBD_GT;

	DBD_SetDAGCond (dagJDT, condStruct, 2);

	if (DBD_Count (dagJDT, TRUE) > 0)
	{
		Message (GO_OBJ_ERROR_MSGS(JDT),JDT_REVERSE_DATE_ERROR, NULL, OO_ERROR);
		return ooErrNoMsg;
	}

	condStruct[1].colNum = OJDT_AUTO_STORNO;
	_STR_strcpy (condStruct[1].condVal, VAL_YES);
	condStruct[1].operation = DBD_EQ;

	DBD_SetDAGCond (dagJDT, condStruct, 2);

	if (DBD_Count (dagJDT, TRUE) > 0)
	{
		Message (JTE_JDT_FORM_NUM, JTE_CANT_CANCEL_ERROR_STR, NULL, OO_ERROR);
		return ooErrNoMsg;
	}

	// checking if cancelling a reversed transaction
	condStruct[0].colNum = OJDT_JDT_NUM;
	condStruct[0].condVal = canceledTrans;
	condStruct[0].operation = DBD_EQ;
	condStruct[0].relationship = DBD_AND;

	condStruct[1].colNum = OJDT_STORNO_TO_TRANS;
	_STR_strcpy (condStruct[1].condVal, STR_0);
	condStruct[1].operation = DBD_GT;

	DBD_SetDAGCond (dagJDT, condStruct, 2);

	if (DBD_Count (dagJDT, TRUE) > 0)
	{
		Message (GO_OBJ_ERROR_MSGS(JDT),JDT_STORNO_ERROR, NULL, OO_ERROR);
		return ooErrNoMsg;
	}

	// checking if tran was reversed by another user/from another window
	condStruct[0].colNum = OJDT_STORNO_TO_TRANS;
	condStruct[0].condVal = canceledTrans;
	condStruct[0].operation = DBD_EQ;
	condStruct[0].relationship = 0;

	DBD_SetDAGCond (dagJDT, condStruct, 1);

	if (DBD_Count (dagJDT, TRUE) > 0)
	{
		_STR_GetStringResource (msgStr, GO_OBJ_ERROR_MSGS(JDT), JDT_CANCELED_ERROR, &GetEnv());
		_STR_sprintf (tmpStr, msgStr, canceledTrans);
		Message (-1, -1, tmpStr, OO_ERROR);
		return ooErrNoMsg;
	}

	if (sourceDoc != OPEN_BLNC_TYPE && sourceDoc != CLOSE_BLNC_TYPE && sourceDoc != MANUAL_BANK_TRANS_TYPE
		&& !(sourceDoc == WTR && VF_ExciseInvoice(bizEnv) && this->m_isVatJournalEntry) )
	{
		dagJDT->SetColLong (JDT, OJDT_TRANS_TYPE, 0);
	}
	
	//Retrieve lines according to orig. JDT
	sboErr = DBD_GetKeyGroup (dagJDT1, JDT1_KEYNUM_PRIMARY, SBOString(canceledTrans), TRUE);
	if (sboErr)
	{
		return (sboErr);
	}

	series = GetEnv().GetDefaultSeries(SBOString(JDT));
	dagJDT->SetColLong(series, OJDT_SERIES);

	// make the storno
	sboErr = DoSingleStorno ();
	if (sboErr)
	{
		return sboErr;
	}

	return ooNoErr;
}

//**********************************************************************************
//**********************************************************************************
Boolean	CTransactionJournalObject::IsPeriodIndicCondNeeded ()
{
        _TRACER("IsPeriodIndicCondNeeded");
	return GetEnv().IsLocalSettingsFlag (lsf_IsDocNumMethod);
}
//**********************************************************************************
//**********************************************************************************
void	CTransactionJournalObject::BuildRelatedBoeQuery (DBD_Tables *tableStruct, long *numOfConds, long iterationType, long *numOfTables, DBD_CondStruct *condStruct, DBD_CondStruct *joinCondStructForOtherObj, DBD_CondStruct *joinCondStructBoe)
{
        _TRACER("BuildRelatedBoeQuery");
	long jdt1JoinField, absJoinField, objJoinField;
	CBizEnv			&bizEnv = GetEnv ();

	/************************************************************************/
	/* create the join for the third object (RCT/DPS/BOT)                   */
	/************************************************************************/
	if (iterationType == JDT_BOT_TYPE) 
	{
		_STR_strcpy (tableStruct[(*numOfTables)++].tableCode, bizEnv.ObjectToTable (BOT, ao_Main));
		absJoinField = OBOT_ABS_ENTRY;
		jdt1JoinField = JDT1_SRC_ABS_ID;
		objJoinField = BOT;	
	}
	else if (iterationType == JDT_RCT_TYPE) 
	{
		_STR_strcpy (tableStruct[(*numOfTables)++].tableCode, bizEnv.ObjectToTable (RCT, ao_Main));
		absJoinField = ORCT_NUM;
		_STR_strcpy (tableStruct[(*numOfTables)++].tableCode, bizEnv.ObjectToTable (BOE, ao_Main));
		objJoinField = RCT;	
		jdt1JoinField = JDT1_CREATED_BY;
	}
	else
	{
		_STR_strcpy (tableStruct[(*numOfTables)++].tableCode, bizEnv.ObjectToTable (DPS, ao_Main));
		absJoinField = ODPS_ABS_ENT;
		objJoinField = DPS;	
		jdt1JoinField = JDT1_SRC_ABS_ID;
	}
	// INNER  JOIN BOT / RCT / DPS t1 on  T1.DeposId = T0.SourceID   
	tableStruct[1].doJoin = TRUE;
	tableStruct[1].joinedToTable = 0;
	tableStruct[1].numOfConds = 2;
	tableStruct[1].joinConds = joinCondStructForOtherObj;
	
	joinCondStructForOtherObj[0].compareCols = TRUE;
	joinCondStructForOtherObj[0].compTableIndex = 0;
	joinCondStructForOtherObj[0].compColNum = jdt1JoinField;
	joinCondStructForOtherObj[0].tableIndex = 1;
	joinCondStructForOtherObj[0].colNum = absJoinField;
	joinCondStructForOtherObj[0].operation = DBD_EQ;		
	joinCondStructForOtherObj[0].relationship = DBD_AND;		
	
	joinCondStructForOtherObj[1].tableIndex = 0;
	joinCondStructForOtherObj[1].colNum = JDT1_TRANS_TYPE;
	joinCondStructForOtherObj[1].condVal = objJoinField;
	joinCondStructForOtherObj[1].operation = DBD_EQ;		

	if (iterationType == JDT_BOT_TYPE) 
	{
		condStruct[*numOfConds].bracketOpen = 1;
		
		// if deposited to paid take the first line
		condStruct[*numOfConds].colNum = OBOT_STATUS_FROM;
		condStruct[*numOfConds].operation = DBD_EQ;
		condStruct[*numOfConds].tableIndex = 1;
		_STR_strcpy (condStruct[*numOfConds].condVal, VAL_BOE_DEPOSITED); 
		condStruct[(*numOfConds)++].relationship = DBD_AND;
		
		condStruct[*numOfConds].colNum = JDT1_LINE_ID;
		condStruct[*numOfConds].operation = DBD_EQ;
		condStruct[*numOfConds].tableIndex = 0;
		condStruct[*numOfConds].condVal = 1L; 
		condStruct[(*numOfConds)++].relationship = DBD_OR;
		
		// if paid to deposited take the second line
		condStruct[*numOfConds].colNum = OBOT_STATUS_FROM;
		condStruct[*numOfConds].operation = DBD_EQ;
		condStruct[*numOfConds].tableIndex = 1;
		_STR_strcpy (condStruct[*numOfConds].condVal, VAL_BOE_PAID); 
		condStruct[(*numOfConds)++].relationship = DBD_AND;
		
		condStruct[*numOfConds].colNum = JDT1_LINE_ID;
		condStruct[*numOfConds].operation = DBD_EQ;
		condStruct[*numOfConds].tableIndex = 0;
		condStruct[*numOfConds].condVal = 0L; 
		condStruct[(*numOfConds)++].relationship = DBD_AND;
		
		condStruct[(*numOfConds)-1].bracketClose = 1;
		
	}
	else if (iterationType == JDT_RCT_TYPE) 
	{
		tableStruct[2].doJoin = TRUE;
		tableStruct[2].joinedToTable = 2;
		tableStruct[2].numOfConds = 2;
		tableStruct[2].joinConds = joinCondStructBoe;
		
		joinCondStructBoe[0].compareCols = TRUE;
		joinCondStructBoe[0].compTableIndex = 1;
		joinCondStructBoe[0].compColNum = ORCT_BOE_NUM;
		joinCondStructBoe[0].tableIndex = 2;
		joinCondStructBoe[0].colNum = OBOE_BOE_NUM;
		joinCondStructBoe[0].operation = DBD_EQ;		
		joinCondStructBoe[0].relationship = DBD_AND;		
		
		joinCondStructBoe[1].tableIndex = 2;
		joinCondStructBoe[1].colNum = OBOE_TYPE;
		_STR_strcpy(joinCondStructBoe[1].condVal, VAL_INPUT);
		joinCondStructBoe[1].operation = DBD_EQ;
		
			condStruct[*numOfConds].colNum = ORCT_CANCELED;
			condStruct[*numOfConds].operation = DBD_EQ;
			condStruct[*numOfConds].tableIndex = 1;
			_STR_strcpy (condStruct[*numOfConds].condVal, VAL_YES); 
			condStruct[(*numOfConds)++].relationship = DBD_AND;
			
			condStruct[*numOfConds].colNum = OBOE_STATUS;
			condStruct[*numOfConds].operation = DBD_EQ;
			condStruct[*numOfConds].tableIndex = 2;
			_STR_strcpy (condStruct[*numOfConds].condVal, VAL_BOE_FAILED); 
			condStruct[(*numOfConds)++].relationship = DBD_AND;
			
			condStruct[*numOfConds].colNum = JDT1_SRC_LINE;
			condStruct[*numOfConds].operation = DBD_EQ;
			condStruct[*numOfConds].tableIndex = 0;
			condStruct[*numOfConds].condVal = PMN_VAL_BOE; 
			condStruct[(*numOfConds)++].relationship = DBD_AND;
		
			// not to take the transaction of the creation of the receipt
			condStruct[*numOfConds].colNum = JDT1_DEBIT;
			condStruct[*numOfConds].operation = DBD_LE;
			condStruct[*numOfConds].tableIndex = 0;
			condStruct[*numOfConds].condVal= 0L; 
			condStruct[(*numOfConds)++].relationship = DBD_AND;
	}
	else
	{
		// if deposit - check that it was of BOE
		condStruct[*numOfConds].colNum = ODPS_DEPOS_TYPE;
		condStruct[*numOfConds].operation = DBD_EQ;
		condStruct[*numOfConds].tableIndex = 1;
		_STR_strcpy (condStruct[*numOfConds].condVal, VAL_BOE); 
		condStruct[(*numOfConds)++].relationship = DBD_AND;
	}
}

//[CostAcctingEnh] The definitions for new methods
//A private function to check if amount has been changed since the MDR was assigned
Boolean CTransactionJournalObject::AmountChangedSinceMDRAssigned_APA(CManualDistributionRuleObject *mdrObj, PDAG dagJDT1, long rec, long *changedDim)
{
	Boolean 	changed = false;
	MONEY 		amount;
	TCHAR 		ocrCode[OOCR_OCR_CODE_LEN+1];
	TCHAR		formatStr[256];
	SBOString 	tmpStr;

	dagJDT1->GetColMoney(&amount, JDT1_FC_DEBIT, rec);
	if(amount.IsZero())
	{
		dagJDT1->GetColMoney(&amount, JDT1_FC_CREDIT, rec);
		if(amount.IsZero())
		{
			dagJDT1->GetColMoney(&amount, JDT1_DEBIT, rec);
			if(amount.IsZero())
			{
				dagJDT1->GetColMoney(&amount, JDT1_CREDIT, rec);
			}
		}
	}

	DimensionInfo			 dimInfo[DIMENSION_MAX];
	SBOString	dim(DIM);
	CCostAccountingDimension *dimObj = static_cast<CCostAccountingDimension*>(GetEnv().CreateBusinessObject(dim));
	dimObj->DIMGetAllDimensionsInfo(dimInfo);

	long	flds[] = {JDT1_OCR_CODE, JDT1_OCR_CODE2, JDT1_OCR_CODE3, JDT1_OCR_CODE4, JDT1_OCR_CODE5};
	// the active ocr codes
	for (long dimIdx = 0; dimIdx < DIMENSION_MAX; dimIdx++)
	{
		if(dimInfo[dimIdx].DimActive)
		{
			dagJDT1->GetColStr(ocrCode, flds[dimIdx], rec);
			_STR_LRTrim(ocrCode);

			if (mdrObj->RuleIsManual(ocrCode))
			{
				mdrObj->AmountIsChangedForManualRule(ocrCode, &amount, &changed);
				if (changed)
				{
					_STR_GetStringResource (formatStr, MDR_ASSIGN_STR_NUM, ROW_DIMENSION_LOCATION, coreSystemDefault, &GetEnv ());
					tmpStr.Format(formatStr, rec+1, dimIdx+1);

					Message (MDR_ASSIGN_STR_NUM, AMOUNT_CHANGED_INDEX, tmpStr, OO_ERROR);
					*changedDim = dimIdx + 1;

					break;
				}
			}
		}
	} // for (dimIdx)
// SBO_APA_DEV_SUP	Joe Li(I032514)	2005/12/7	Fix bug: 4512226: B1 crashed when post 4000 journal vouchers to JE
	dimObj->Destroy();
// SBO_APA_DEV_SUP	End

	return changed;
}
//@APA END 2005/11/07_17:09:49 I028160

/*******************************************************************
 Function name		: UpgradeDpmLineTypeUsingJDT1
 Description	    : Put the DPM line type in the Down payment lines 
					  that were created by the payment (RCT and VPM)
					  take only lines that are DPM's for sure.
					  The case when in a transaction there were line of DPM and of INV
					  and both control account were the same - will not be upgraded!
 Return type		: SBOErr  
 Argument			: Versions
 Query				: 
					 SELECT T0.[TransId], T0.[Line_ID], MIN(T0.[Credit]), MIN(T0.[Debit]) 
					 FROM  [dbo].[JDT1] T0  
					 INNER  JOIN [dbo].[VPM2/RCT2] T1  ON  T1.[DocNum] = T0.[CreatedBy]  AND  T0.[TransType] = N'46'/'24'  
					 INNER  JOIN [dbo].[OCRD] T2  ON  T2.[CardCode] = T0.[ShortName]    
					 LEFT OUTER  JOIN [dbo].[CRD3] T3  ON  T3.[CardCode] = T2.[CardCode]  
					 AND  T3.[AcctType] = N'D'  
					 WHERE T0.[ShortName] <> T0.[Account]  
					 AND  (T0.[Account] = T3.[AcctCode]  OR  (T3.[AcctType] IS NULL  
					 AND  T0.[Account] = (ARP_TYPE_DOWN_PAYMENT))
					 AND  T1.[InvType] = (N'204'/'203' )  AND  T1.[DpmPosted] = (N'N' ) 
					 AND  ((T1.[PaidDpm] = (N'N' )  AND  T0.[Debit] > (0 ) )
					 OR  (T1.[PaidDpm] = (N'Y' )  AND  T0.[Credit] > (0 ) )) 
					 AND  T0.[Account] <> T2.[DebPayAcct]   

					 GROUP BY T0.[TransId], T0.[Line_ID]
********************************************************************/
SBOErr	 CTransactionJournalObject::UpgradeDpmLineTypeUsingJDT1(long paymentObj)
{
        _TRACER("UpgradeDpmLineTypeUsingJDT1");
	SBOErr   ooErr = noErr;
	PDAG			dagJDT1, dagRES=NULL;
	DBD_CondStruct	condStruct[13];
	DBD_Tables  tableStruct[7];
	DBD_CondStruct joinCondStruct[8];
	DBD_UpdStruct	updStruct[1];
	DBD_ResStruct	resStruct[4];
	long			numOfConds=0, numOfRecs;
	TCHAR			tmpStr[256];
	CBizEnv			&bizEnv = GetEnv ();
	AccountCode		dpAccount;
	bool			isIncoming = (paymentObj == RCT) ? true : false;

	ooErr = ARP_GetAccountByType (bizEnv, NULL, ARP_TYPE_DOWN_PAYMENT, dpAccount, true, (TCHAR*)(isIncoming?VAL_CUSTOMER:VAL_VENDOR));	
	dagJDT1 = OpenDAG (JDT, ao_Arr1);
	// JDT1
	_STR_strcpy (tableStruct[0].tableCode, bizEnv.ObjectToTable (JDT, ao_Arr1));
		
	// RCT2
	_STR_strcpy (tableStruct[1].tableCode, bizEnv.ObjectToTable (paymentObj, ao_Arr2));

	// OCRD
	_STR_strcpy (tableStruct[2].tableCode, bizEnv.ObjectToTable (CRD));

	// CRD3
	_STR_strcpy (tableStruct[3].tableCode, bizEnv.ObjectToTable (CRD, ao_Arr3));

	// OJDT
	_STR_strcpy (tableStruct[4].tableCode, bizEnv.ObjectToTable (JDT));

	// OFPR
	_STR_strcpy (tableStruct[5].tableCode, bizEnv.ObjectToTable (FPR));

	// OACP
	_STR_strcpy (tableStruct[6].tableCode, bizEnv.ObjectToTable (ACP));


	// INNER  JOIN [dbo].[vpm2] T1  ON  T1.[DocNum] = T0.[CreatedBy]  AND  T0.[TransType] = N'46'
	tableStruct[1].doJoin = TRUE;
	tableStruct[1].joinedToTable = 0;
	tableStruct[1].numOfConds = 2;
	tableStruct[1].joinConds = &joinCondStruct[0];
	
	joinCondStruct[0].compareCols = TRUE;
	joinCondStruct[0].compTableIndex = 0;
	joinCondStruct[0].compColNum = JDT1_CREATED_BY;
	joinCondStruct[0].tableIndex = 1;
	joinCondStruct[0].colNum = RCT2_DOC_KEY;
	joinCondStruct[0].operation = DBD_EQ;		
	joinCondStruct[0].relationship = DBD_AND;		

	joinCondStruct[1].tableIndex = 0;
	joinCondStruct[1].colNum = JDT1_TRANS_TYPE;
	joinCondStruct[1].operation = DBD_EQ;		
	joinCondStruct[1].condVal = paymentObj;	
	
	//INNER  JOIN [dbo].[OCRD] T2  ON  T2.[CardCode] = T0.[ShortName]
	tableStruct[2].doJoin = TRUE;
	tableStruct[2].joinedToTable = 0;
	tableStruct[2].numOfConds = 1;
	tableStruct[2].joinConds = &joinCondStruct[2];
	
	joinCondStruct[2].compareCols = TRUE;
	joinCondStruct[2].compTableIndex = 0;
	joinCondStruct[2].compColNum = JDT1_SHORT_NAME;
	joinCondStruct[2].tableIndex = 2;
	joinCondStruct[2].colNum = OCRD_CARD_CODE;
	joinCondStruct[2].operation = DBD_EQ;		

		
	//LEFT OUTER  JOIN [dbo].[CRD3] T3  ON  T3.[CardCode] = T2.[CardCode]  AND  T3.[AcctType] = N'D'
	tableStruct[3].doJoin = TRUE;
	tableStruct[3].joinedToTable = 2;
	tableStruct[3].numOfConds = 2;
	tableStruct[3].outerJoin = true;
	tableStruct[3].joinConds = &joinCondStruct[3];
		
	joinCondStruct[3].compareCols = TRUE;
	joinCondStruct[3].compTableIndex = 2;
	joinCondStruct[3].compColNum = OCRD_CARD_CODE;
	joinCondStruct[3].tableIndex = 3;
	joinCondStruct[3].colNum = CRD3_CARD_CODE;
	joinCondStruct[3].operation = DBD_EQ;		
	joinCondStruct[3].relationship = DBD_AND;		
		
	joinCondStruct[4].tableIndex = 3;
	joinCondStruct[4].colNum = CRD3_ACCOUNT_TYPE;
	joinCondStruct[4].operation = DBD_EQ;		
	joinCondStruct[4].condVal = ARP_TYPE_DOWN_PAYMENT;	

	// INNER  JOIN [dbo].[Ojdt] T4  ON  T4.[TransId] = T0.[TransId]
	tableStruct[4].doJoin = TRUE;
	tableStruct[4].joinedToTable = 0;
	tableStruct[4].numOfConds = 1;
	tableStruct[4].joinConds = &joinCondStruct[5];

	joinCondStruct[5].compareCols = TRUE;
	joinCondStruct[5].compTableIndex = 0;
	joinCondStruct[5].compColNum = JDT1_TRANS_ABS;
	joinCondStruct[5].tableIndex = 4;
	joinCondStruct[5].colNum = OJDT_JDT_NUM;
	joinCondStruct[5].operation = DBD_EQ;

	// inner join OFPR t5 on t4.FinncPriod = t5.AbsEntry
	tableStruct[5].doJoin = TRUE;
	tableStruct[5].joinedToTable = 0;
	tableStruct[5].numOfConds = 1;
	tableStruct[5].joinConds = &joinCondStruct[6];

	joinCondStruct[6].compareCols = TRUE;
	joinCondStruct[6].compTableIndex = 4;
	joinCondStruct[6].compColNum = OJDT_FINANCE_PERIOD;
	joinCondStruct[6].tableIndex = 5;
	joinCondStruct[6].colNum = OFPR_ABS_ENTRY;
	joinCondStruct[6].operation = DBD_EQ;
	//  inner join OACP t6 on t5.Category = t6.PeriodCat
	tableStruct[6].doJoin = TRUE;
	tableStruct[6].joinedToTable = 0;
	tableStruct[6].numOfConds = 1;
	tableStruct[6].outerJoin = true;
	tableStruct[6].joinConds = &joinCondStruct[7];

	joinCondStruct[7].compareCols = TRUE;
	joinCondStruct[7].compTableIndex = 5;
	joinCondStruct[7].compColNum = OFPR_CATEGORY;
	joinCondStruct[7].tableIndex = 6;
	joinCondStruct[7].colNum = OACP_PERIOD_CAT_ID;
	joinCondStruct[7].operation = DBD_EQ;


	//conditions
	condStruct[numOfConds].compareCols = TRUE;
	condStruct[numOfConds].colNum = JDT1_SHORT_NAME;
	condStruct[numOfConds].operation = DBD_NE;
	condStruct[numOfConds].compColNum = JDT1_ACCT_NUM;
	condStruct[numOfConds].tableIndex = 0;
	condStruct[numOfConds++].relationship = DBD_AND;
	
	condStruct[numOfConds].bracketOpen = 1;

	condStruct[numOfConds].compareCols = TRUE;
	condStruct[numOfConds].colNum = JDT1_ACCT_NUM;
	condStruct[numOfConds].operation = DBD_EQ;
	condStruct[numOfConds].compColNum = CRD3_ACCOUNT_CODE;
	condStruct[numOfConds].tableIndex = 0;
	condStruct[numOfConds].compTableIndex = 3;
	condStruct[numOfConds++].relationship = DBD_OR;

	condStruct[numOfConds].bracketOpen = 1;

	condStruct[numOfConds].colNum = CRD3_ACCOUNT_TYPE;
	condStruct[numOfConds].operation = DBD_IS_NULL;
	condStruct[numOfConds].tableIndex = 3;
	condStruct[numOfConds++].relationship = DBD_AND;
	
	condStruct[numOfConds].compareCols = true;
	condStruct[numOfConds].colNum = JDT1_ACCT_NUM;
	condStruct[numOfConds].tableIndex = 0;
	condStruct[numOfConds].compColNum = isIncoming ? OACP_ARP_C_DOWN_PAYME : OACP_ARP_V_DOWN_PAYME;
	condStruct[numOfConds].compTableIndex = 6;
	condStruct[numOfConds].operation = DBD_EQ;
	condStruct[numOfConds++].relationship = DBD_AND;

	condStruct[numOfConds-1].bracketClose = 2;
	
	condStruct[numOfConds].colNum = RCT2_INVOICE_TYPE;
	condStruct[numOfConds].operation = DBD_EQ;
	condStruct[numOfConds].tableIndex = 1;
	condStruct[numOfConds].condVal = isIncoming ? DPI : DPO;
	condStruct[numOfConds++].relationship = DBD_AND;

	condStruct[numOfConds].colNum = RCT2_DPM_POSTED;
	condStruct[numOfConds].operation = DBD_EQ;
	condStruct[numOfConds].tableIndex = 1;
	condStruct[numOfConds].condVal = VAL_NO;
	condStruct[numOfConds++].relationship = DBD_AND;
	
	condStruct[numOfConds].bracketOpen = 2;

	// PaidDPM = 'N'
	condStruct[numOfConds].colNum = RCT2_PAID_DPM;
	condStruct[numOfConds].operation = DBD_EQ;
	condStruct[numOfConds].tableIndex = 1;
	condStruct[numOfConds].condVal = VAL_NO;	
	condStruct[numOfConds++].relationship = DBD_AND;		

	//And JDT1.[Credit] > 0 
	condStruct[numOfConds].colNum = isIncoming ? JDT1_CREDIT : JDT1_DEBIT;
	condStruct[numOfConds].operation = DBD_GT;
	condStruct[numOfConds].tableIndex = 0;
	condStruct[numOfConds].condVal = 0L;
	condStruct[numOfConds].bracketClose = 1;
	condStruct[numOfConds++].relationship = DBD_OR;

	// PaidDPM = 'Y'
	condStruct[numOfConds].bracketOpen = 1;
	condStruct[numOfConds].colNum = RCT2_PAID_DPM;
	condStruct[numOfConds].operation = DBD_EQ;
	condStruct[numOfConds].tableIndex = 1;
	condStruct[numOfConds].condVal = VAL_YES;	
	condStruct[numOfConds++].relationship = DBD_AND;		

	//And JDT1.[Debit] > 0 
	condStruct[numOfConds].colNum = isIncoming ? JDT1_DEBIT : JDT1_CREDIT;
	condStruct[numOfConds].operation = DBD_GT;
	condStruct[numOfConds].tableIndex = 0;
	condStruct[numOfConds].condVal = 0L;
	condStruct[numOfConds].bracketClose = 2;
	condStruct[numOfConds++].relationship = DBD_AND;

	condStruct[numOfConds].compareCols = TRUE;
	condStruct[numOfConds].colNum = JDT1_ACCT_NUM;
	condStruct[numOfConds].operation = DBD_NE;
	condStruct[numOfConds].compColNum = OCRD_DEB_PAY_ACCOUNT;
	condStruct[numOfConds].tableIndex = 0;
	condStruct[numOfConds++].compTableIndex = 2;


	resStruct[0].colNum = JDT1_TRANS_ABS;
	resStruct[0].tableIndex = 0;
	resStruct[0].group_by = true;
	resStruct[1].colNum = JDT1_LINE_ID;
	resStruct[1].tableIndex = 0;
	resStruct[1].group_by = true;
	resStruct[2].colNum = JDT1_CREDIT;
	resStruct[2].tableIndex = 0;
	resStruct[2].agreg_type = DBD_MIN;
	resStruct[3].colNum = JDT1_DEBIT;
	resStruct[3].tableIndex = 0;
	resStruct[3].agreg_type = DBD_MIN;
		

	DBD_SetDAGCond (dagJDT1, condStruct, numOfConds);
	DBD_SetDAGRes (dagJDT1, resStruct, 4);
	DBD_SetTablesList (dagJDT1, tableStruct, 7);
		
	ooErr = DBD_GetInNewFormat (dagJDT1, &dagRES);
	dagRES->Detach();
		
	if (ooErr == dbmNoDataFound)
	{
		DAG_Close(dagRES);
		DAG_Close(dagJDT1);
		return noErr;
	}
	else if (ooErr) 
	{
		DAG_Close(dagRES);
		DAG_Close(dagJDT1);
		return ooErr;
	}

	DAG_GetCount(dagRES, &numOfRecs);

	DBD_CondStruct*	condStruct2= new DBD_CondStruct[NUM_OF_MAX_ITERATIONS*2];
	AutoCleanerArrayHandler<DBD_CondStruct*> acCondStruct2(condStruct2);

	DBD_Tables		tableStruct2[1];
	long			jj, rec, val, ii;
	MONEY			tmpM;
	
	// JDT1
	_STR_strcpy (tableStruct2[0].tableCode, bizEnv.ObjectToTable (JDT, ao_Arr1));

	updStruct[0].colNum = JDT1_LINE_TYPE;

	long resSumField;
	if (paymentObj == RCT)
	{
		resSumField = 2;
	}
	else
	{
		resSumField = 3;
	}
	/************************************************************************/
	/* loop of 2 for DPM request - one for the paid ones and the second for the non-paid */
	/************************************************************************/
	for (jj=0; jj < 2 ;jj++) 
	{
		rec = 0;
		while (rec < numOfRecs) 
		{
			if (rec || jj == 1) 
			{
				_MEM_Clear(condStruct2, numOfConds);
			}
			numOfConds = 0;
			for (ii=0; ii < NUM_OF_MAX_ITERATIONS && rec < numOfRecs; ii++, rec++) 
			{
				/************************************************************************/
				/* check if we reached the lines of the dpm paid dpm request where the amount
				   is in the DEBIT side of in MINUS in the credit side					*/
				/************************************************************************/
				dagRES->GetColMoney (&tmpM, resSumField, rec);
				if (tmpM == 0)
				{
					dagRES->GetColMoney (&tmpM, resSumField == 2 ? 3 : 2, rec);
					tmpM *= -1;
				}

				if (!tmpM.IsPositive()) 
				{
					if (jj == 1) 
					{
						// lineType = DPM type
						val = ooCtrlAct_PaidDPRequestType;
						updStruct[0].updateVal = val;
					}
					else
					{
						continue;
					}
				}
				else if (tmpM.IsPositive())
				{
					if (jj == 0) 
					{
						// lineType = DPM type
						val = ooCtrlAct_DPRequestType;
						updStruct[0].updateVal = val;
					}
					else
					{
						continue;
					}
				}
				condStruct2[numOfConds].bracketOpen = 1;

				dagRES->GetColStr (tmpStr, 0, rec);
				condStruct2[numOfConds].condVal = tmpStr;
				condStruct2[numOfConds].tableIndex = 0;
				condStruct2[numOfConds].colNum = JDT1_TRANS_ABS;
				condStruct2[numOfConds].operation = DBD_EQ;
				condStruct2[numOfConds++].relationship = DBD_AND;
				
				dagRES->GetColStr (tmpStr, 1, rec);
				condStruct2[numOfConds].condVal = tmpStr;
				condStruct2[numOfConds].tableIndex = 0;
				condStruct2[numOfConds].colNum = JDT1_LINE_ID;
				condStruct2[numOfConds].operation = DBD_EQ;
				condStruct2[numOfConds++].relationship = DBD_OR;
				
				condStruct2[numOfConds-1].bracketClose = 1;
			}
			if(numOfConds == 0)
			{
				continue;
			}
			condStruct2[numOfConds-1].relationship = 0;

			DBD_SetDAGCond	  (dagJDT1, condStruct2, numOfConds);
			DBD_SetTablesList (dagJDT1, tableStruct2, 1);
			DBD_SetDAGUpd	  (dagJDT1, updStruct, 1);
			
			ooErr = DBD_UpdateCols (dagJDT1);
			if (ooErr) 
			{
				DAG_Close(dagRES);
				DAG_Close(dagJDT1);
				return ooErr;
			}
		}
	}

	DAG_Close(dagRES);
	DAG_Close (dagJDT1);
	
	return ooNoErr;
}

/************************************************************************
Function name : UpgradeDpmLineTypeUsingRCT2
Description   : Updates the JDT1.LineType field of payments that paid only 
				DPM Request (from a specific stage (first OR second), without other documents 
				and without payment on account) to be "ooCtrlAct_DPRequestType" or 
				"ooCtrlAct_PaidDPRequestType", if it is wrong.

Return type   : SBOErr  
/************************************************************************/
SBOErr	CTransactionJournalObject::UpgradeDpmLineTypeUsingRCT2 (long object)
{
	_TRACER ("UpgradeDpmLineTypeUsingRCT2");

	SBOErr			ooErr = noErr;
	PDAG			dagRes = NULL;
	PDAG			dagQuery = GetDAG ();
	
	long			dpmStageArr [3] = {	(long) ooCtrlAct_DPRequestType, 
										(long) ooCtrlAct_PaidDPRequestType, 
										NOB};
	
	for (long stage = 0; dpmStageArr[stage] != NOB; ++stage)
	{
		ooErr = UpgradeDpmLineTypeExecuteQuery (dagQuery, &dagRes, object, dpmStageArr[stage] == (long) ooCtrlAct_DPRequestType);
		if (ooErr == dbmNoDataFound)
		{
			ooErr = noErr;
			continue;
		}
		else if (ooErr)
		{
			return ooErr;
		}

		// update fields with correct data							
		ooErr = UpgradeDpmLineTypeUpdate (dagRes, object, dpmStageArr[stage] == (long) ooCtrlAct_DPRequestType);
		if (ooErr)
		{
			return ooErr;
		}
	}
	
	return ooErr;
}

/************************************************************************
Function name : UpgradeDpmLineTypeExecuteQuery

Description   : Builds and executes the query that finds payments that paid only DPM Request 
				(from a specific stage (first OR second), without other documents and 
				without payment on account) 
				which do not have the right value of JDT1.LineType in their journal entry.

The query:
				SELECT T0.[DocEntry] 
				FROM  [dbo].[ORCT] T0  
				WHERE	T0.[Canceled] = (N'N' )  AND 
						T0.[DocType] <> 'A' AND
						NOT EXISTS 
						(
							SELECT U0.[TransId] 
							FROM  [dbo].[JDT1] U0  
							WHERE	T0.[DocEntry] = U0.[CreatedBy]  AND  
									T0.[ObjType] = U0.[TransType]  AND  
									U0.[ShortName] <> U0.[Account]  AND  
									(U0.[SourceLine] <> (-6 )  OR  U0.[SourceLine] IS NULL  ) AND  
									U0.[LineType] = (1 )  
						)  

						AND   

						NOT EXISTS 
						(
							SELECT U0.[DocNum] 
							FROM  [dbo].[RCT2] U0  
							WHERE	T0.[DocEntry] = U0.[DocNum]  AND  
									(
										U0.[InvType] <> (N'203' )  OR  
										U0.[DpmPosted] <> (N'N' )  OR  
										U0.[PaidDpm] <> (N'N' ) 
									) 
						)  

						AND  
						
						T0.[PayNoDoc] <> (N'Y' )  AND  
						T0.[NoDocSum] = (0 ) AND
						T0.[NoDocSumFC] = (0 )
		
Return type   : SBOErr  
/************************************************************************/
SBOErr	CTransactionJournalObject::UpgradeDpmLineTypeExecuteQuery (PDAG dagQuery, PDAG *dagRes, long object, bool isFirst)
{
	_TRACER ("UpgradeDpmLineTypeExecuteQuery");

	SBOErr		ooErr = noErr;
	CBizEnv		&bizEnv = GetEnv ();

	const long pmtMainTableNum = 0;				// first table in main query
	const long pmtJDT1TableNum = 0;				// first table in "line type" sub-query
	const long pmtArr2TableNum = 0;				// first table in "no other docs" sub-query

	// -------------------------------------------------------------------- 
	// res struct	

	DBD_ResStruct resStruct [UPG_LINE_TYPE_RES_SIZE];	 

	// T0.DocEntry
	resStruct [UPG_LINE_TYPE_ORCT_ABS_ENTRY_RES].tableIndex = pmtMainTableNum;
	resStruct [UPG_LINE_TYPE_ORCT_ABS_ENTRY_RES].colNum = ORCT_ABS_ENTRY;
	
	dagQuery->GetDBDParams ()->dbdResPtr = resStruct;
	dagQuery->GetDBDParams ()->numOfResCols = UPG_LINE_TYPE_RES_SIZE;

	// -------------------------------------------------------------------- 

	// tables
	DBD_TablesList	tablePtr;
	DBD_CondTables  *tables = &(dagQuery->GetDBDParams ()->GetCondTables ());
	// ORCT T0
	tablePtr = &tables->AddTable ();
	tablePtr->tableCode = bizEnv.ObjectToTable (object, ao_Main);

	// -------------------------------------------------------------------- */

	// Conditions
	PDBD_Cond condPtr;
	DBD_Conditions *conditions = &(dagQuery->GetDBDParams ()->GetConditions ());

	// T0.[Canceled] = N'N'
	condPtr = &(conditions->AddCondition ());
	condPtr->tableIndex = pmtMainTableNum;
	condPtr->colNum = ORCT_CANCELED;
	condPtr->operation = DBD_EQ;
	condPtr->condVal = VAL_NO;
	condPtr->relationship = DBD_AND;	

	// T0.[DocType] <> 'A'
	condPtr = &(conditions->AddCondition ());
	condPtr->tableIndex = pmtMainTableNum;
	condPtr->colNum = ORCT_TYPE;
	condPtr->operation = DBD_NE;
	condPtr->condVal = VAL_ACCOUNT;
	condPtr->relationship = DBD_AND;

	// NOT EXISTS (JEs with LineType = 1 or 2) AND
	condPtr = &(conditions->AddCondition ());
	DBD_Params	subParams;
	condPtr->operation = DBD_NOT_EXISTS;
	condPtr->SetSubQueryParams (&subParams);
	condPtr->tableIndex = DBD_NO_TABLE;
	condPtr->relationship = DBD_AND;

		// -------------------------------------------------------------------- 
		// sub query
		// Sub-Tables
		DBD_CondTables *subTables = &(subParams.GetCondTables ());	
		tablePtr = &subTables->AddTable ();
		tablePtr->tableCode = bizEnv.ObjectToTable (JDT, ao_Arr1);

		// Sub-ResStruct
		DBD_ResStruct subResStruct [1];
		subResStruct[0].tableIndex	= 0;
		subResStruct[0].colNum		= JDT1_TRANS_ABS;

		// Sub-Conditions
		DBD_Conditions *subConditions = &(subParams.GetConditions ());

		//  JDT1.[CreatedBy] = ORCT.[DocEntry] AND 
		condPtr = &(subConditions->AddCondition ());
		condPtr->origTableIndex = pmtMainTableNum; 
		condPtr->origTableLevel	= 1; // '1' means the main (not sub) query level
		condPtr->colNum = ORCT_ABS_ENTRY;
		condPtr->operation = DBD_EQ;
		condPtr->compareCols = true;
		condPtr->compTableIndex = pmtJDT1TableNum;
		condPtr->compColNum = JDT1_CREATED_BY;
		condPtr->relationship = DBD_AND;

		// JDT1.[TransType] = ORCT.[ObjType] AND
		condPtr = &(subConditions->AddCondition ());
		condPtr->origTableIndex = pmtMainTableNum; 
		condPtr->origTableLevel	= 1; // '1' means the main (not sub) query level
		condPtr->colNum = ORCT_OBJECT;
		condPtr->operation = DBD_EQ;
		condPtr->compareCols = true;
		condPtr->compTableIndex = pmtJDT1TableNum;
		condPtr->compColNum = JDT1_TRANS_TYPE;
		condPtr->relationship = DBD_AND;

		// JDT1.[ShortName] <> JDT1.[Account] AND
		condPtr = &(subConditions->AddCondition ());
		condPtr->tableIndex = pmtJDT1TableNum; 
		condPtr->colNum = JDT1_SHORT_NAME;
		condPtr->operation = DBD_NE;
		condPtr->compareCols = true;
		condPtr->compTableIndex = pmtJDT1TableNum;
		condPtr->compColNum = JDT1_ACCT_NUM;
		condPtr->relationship = DBD_AND;

		// (JDT1.[SourceLine] <> -6 OR
		condPtr = &(subConditions->AddCondition ());
		condPtr->bracketOpen = 1;
		condPtr->tableIndex = pmtJDT1TableNum;		
		condPtr->colNum = JDT1_SRC_LINE;
		condPtr->operation = DBD_NE;	
		condPtr->condVal = PMN_VAL_BOE;		
		condPtr->relationship = DBD_OR;

		// JDT1.[SourceLine] IS NULL) AND
		condPtr = &(subConditions->AddCondition ());
		condPtr->tableIndex = pmtJDT1TableNum;
		condPtr->colNum = JDT1_SRC_LINE;
		condPtr->operation = DBD_IS_NULL;
		condPtr->bracketClose = 1;
		condPtr->relationship = DBD_AND;

		// JDT1.[LineType] = 1 / 2
		condPtr = &(subConditions->AddCondition ());
		condPtr->tableIndex = pmtJDT1TableNum; 
		condPtr->colNum = JDT1_LINE_TYPE;
		condPtr->operation = DBD_EQ;
		condPtr->condVal = (isFirst) ? (long) ooCtrlAct_DPRequestType : (long) ooCtrlAct_PaidDPRequestType;
		condPtr->relationship = 0;

		ooErr = DBD_SetRes (&subParams, subResStruct, 1);
		if (ooErr)
		{
			return ooErr;
		}

		// -------------------------------------------------------------------- 

	
	// NOT EXISTS (other paid documents except DPMs) AND
	condPtr = &(conditions->AddCondition ());
	DBD_Params	subParamsNoOtherDocs;
	condPtr->operation = DBD_NOT_EXISTS;
	condPtr->SetSubQueryParams (&subParamsNoOtherDocs);
	condPtr->tableIndex = DBD_NO_TABLE;
	condPtr->relationship = DBD_AND;


		// -------------------------------------------------------------------- 
		// sub query			

		// Sub-Tables
		subTables = &(subParamsNoOtherDocs.GetCondTables ());	
		tablePtr = &subTables->AddTable ();
		tablePtr->tableCode = bizEnv.ObjectToTable (object, ao_Arr2);

		// Sub-ResStruct
		DBD_ResStruct subResStructNoOtherDocs [1];
		subResStructNoOtherDocs[0].tableIndex	= 0;
		subResStructNoOtherDocs[0].colNum		= RCT2_DOC_KEY;

		// Sub-Conditions
		subConditions = &(subParamsNoOtherDocs.GetConditions ());
			
		//  RCT2.[DocNum] = ORCT.[DocEntry] AND
		condPtr = &(subConditions->AddCondition ());
		condPtr->origTableIndex = pmtMainTableNum; 
		condPtr->origTableLevel	= 1; // '1' means the main (not sub) query level
		condPtr->colNum = ORCT_ABS_ENTRY;
		condPtr->operation = DBD_EQ;
		condPtr->compareCols = true;
		condPtr->compTableIndex = pmtArr2TableNum;
		condPtr->compColNum = RCT2_DOC_KEY;
		condPtr->relationship = DBD_AND;

		// ( RCT2.[InvType] <> 203/204
		condPtr = &(subConditions->AddCondition ());	
		condPtr->bracketOpen = 1;
		condPtr->tableIndex = pmtArr2TableNum;		
		condPtr->colNum = RCT2_INVOICE_TYPE;
		condPtr->operation = DBD_NE;	
		condPtr->condVal = (object == RCT) ? DPI : DPO;		
		condPtr->relationship = DBD_OR;
		
		// RCT2.[DpmPosted] <> 'N'  OR
		condPtr = &(subConditions->AddCondition ());
		condPtr->tableIndex = pmtArr2TableNum;
		condPtr->colNum = RCT2_DPM_POSTED;
		condPtr->operation = DBD_NE;	
		condPtr->condVal = VAL_NO;
		condPtr->relationship = DBD_OR;

		//RCT2.[PaidDpm] <> 'N'/'Y')	
		condPtr = &(subConditions->AddCondition ());	
		condPtr->tableIndex = pmtArr2TableNum;
		condPtr->colNum = RCT2_PAID_DPM;
		condPtr->operation = DBD_NE;	
		condPtr->condVal = isFirst ? VAL_NO : VAL_YES;
		condPtr->relationship = 0;
		condPtr->bracketClose = 1;

		ooErr = DBD_SetRes (&subParamsNoOtherDocs, subResStructNoOtherDocs, 1);
		if (ooErr)
		{
			return ooErr;
		}

		// -------------------------------------------------------------------- 
	
	// ORCT.[PayNoDoc] <> 'Y'	
	condPtr = &(conditions->AddCondition ());
	condPtr->tableIndex = pmtMainTableNum;
	condPtr->colNum = ORCT_NO_DOC;
	condPtr->operation = DBD_NE;	
	condPtr->condVal = VAL_YES;
	condPtr->relationship = DBD_AND;

	// ORCT.[NoDocSum] = 0 AND
	condPtr = &(conditions->AddCondition ());
	condPtr->tableIndex = pmtMainTableNum;
	condPtr->colNum = ORCT_NO_DOC_SUM;
	condPtr->operation = DBD_EQ;	
	condPtr->condVal = 0L;
	condPtr->relationship = DBD_AND;

	// ORCT.[NoDocSumFC] = 0
	condPtr = &(conditions->AddCondition ());
	condPtr->tableIndex = pmtMainTableNum;
	condPtr->colNum = ORCT_NO_DOC_FRGN;
	condPtr->operation = DBD_EQ;	
	condPtr->condVal = 0L;
	condPtr->relationship = 0;

	ooErr = DBD_GetInNewFormat (dagQuery, dagRes);
	
	return ooErr;
}

/*******************************************************************
Function name	: UpgradeDpmLineTypeUpdate
Description	    : Builds and executes the query that updates the JDT1.LineType field 
				  to be to be "ooCtrlAct_DPRequestType" or ooCtrlAct_PaidDPRequestType".
				  The updated JE lines are of payments that paid only DPM Request 
				  (from a specific stage (first OR second), without other documents 
				  and without payment on account).
				  
Return type		: SBOErr  
********************************************************************/
SBOErr	CTransactionJournalObject::UpgradeDpmLineTypeUpdate (PDAG dagRes, long object, bool isFirst)
{
	_TRACER ("UpgradeDpmLineTypeUpdate");

	SBOErr			ooErr = noErr;
	PDAG			dagJDT1 = GetDAG (JDT, ao_Arr1);	
	DBD_Params		params;
	DBD_UpdStruct	JDT1UpdateStruct [1];
	DBD_Conditions	*conditions = &(params.GetConditions ());
	PDBD_Cond		condPtr;

	JDT1UpdateStruct [0].colNum = JDT1_LINE_TYPE;
	JDT1UpdateStruct [0].updateVal = isFirst ? (long) ooCtrlAct_DPRequestType : ooCtrlAct_PaidDPRequestType;
	
	params.dbdUpdPtr = JDT1UpdateStruct;
	params.numOfUpdCols = 1;

	// JDT1.[TransType] = ORCT.[ObjType] AND
	condPtr = &(conditions->AddCondition ());
	condPtr->tableIndex = 0; 
	condPtr->colNum = JDT1_TRANS_TYPE;
	condPtr->operation = DBD_EQ;		
	condPtr->condVal = object;
	condPtr->relationship = DBD_AND;

	// JDT1.[ShortName] <> JDT1.[Account] AND
	condPtr = &(conditions->AddCondition ());
	condPtr->tableIndex = 0;
	condPtr->colNum = JDT1_SHORT_NAME;
	condPtr->operation = DBD_NE;
	condPtr->compareCols = true;
	condPtr->compTableIndex = 0;
	condPtr->compColNum = JDT1_ACCT_NUM;
	condPtr->relationship = DBD_AND;

	// (JDT1.[SourceLine] <> -6 OR
	condPtr = &(conditions->AddCondition ());
	condPtr->bracketOpen = 1;
	condPtr->tableIndex = 0;		
	condPtr->colNum = JDT1_SRC_LINE;
	condPtr->operation = DBD_NE;	
	condPtr->condVal = PMN_VAL_BOE;		
	condPtr->relationship = DBD_OR;

	// JDT1.[SourceLine] IS NULL) AND
	condPtr = &(conditions->AddCondition ());
	condPtr->tableIndex = 0;
	condPtr->colNum = JDT1_SRC_LINE;
	condPtr->operation = DBD_IS_NULL;
	condPtr->bracketClose = 1;
	condPtr->relationship = DBD_AND;

	// IMPORTANT NOTE - This is the last condition, and should remain last since the condVal is set in the "for" loop
	//  JDT1.[CreatedBy] = ORCT.[DocEntry]  
	condPtr = &(conditions->AddCondition ());
	condPtr->tableIndex = 0; 
	condPtr->colNum = JDT1_CREATED_BY;
	condPtr->operation = DBD_EQ;
	// condPtr->condVal = will be set in the "for" loop
	condPtr->relationship = 0;	

	//long numOfConditions = conditions->GetCount (); 

	long dagResSize = dagRes->GetRealSize (dbmDataBuffer);
	for (long rec = 0; rec < dagResSize; ++rec)
	{
		// Set the condVal for the last condition
		dagRes->GetColStr (condPtr->condVal, UPG_LINE_TYPE_ORCT_ABS_ENTRY_RES, rec);
		
		dagJDT1->SetDBDParms (&params);

		// update data in database
		ooErr = DBD_UpdateCols (dagJDT1);
		if (ooErr)
		{
			params.Clear ();
			return ooErr;
		}
	}

	params.Clear ();
	return ooErr;
}

/*******************************************************************
 Function name		: ValidateReportEU
 Description	    : check if transaction can be reported for EU report
 Return type		: SBOErr  
********************************************************************/
SBOErr	CTransactionJournalObject::ValidateReportEU ()
{
        _TRACER("ValidateReportEU");
	CBizEnv	&bizEnv = GetEnv ();
	
	if(!bizEnv.IsLocalSettingsFlag (lsf_IsEC))
	{
		return ooNoErr;
	}

	
	PDAG	dagJDT = GetDAG ();
	SBOErr	sboErr	= ooNoErr;
	SBOString reportEUStr;

	dagJDT->GetColStr (reportEUStr, OJDT_REPORT_EU);
	if(reportEUStr.Compare (VAL_YES))
	{
		return ooNoErr;
	}
	//only manual jdt
	sboErr = ValidateVatReportTransType ();
	
	if (sboErr == noErr)
	{
		long numOfBPfound = 0;
		bool validateFedTaxId = bizEnv.IsVatPerLine (); // VF_FederalTaxIdOnJERow

		sboErr = GetNumOfBPRecords (numOfBPfound, validateFedTaxId);
		IF_ERROR_RETURN (sboErr);

		if (numOfBPfound != 1)	// only 1 BP
		{
			Message (GO_OBJ_ERROR_MSGS (JDT), JDT_EU_REPORT_DIFFER_ONE_BP_ERR, NULL, OO_ERROR);
			sboErr = errNoMsg;
		}
	}
		
	if (sboErr != noErr)
	{
		SetErrorField( -1);
		SetErrorField( OJDT_REPORT_EU);
	}

	return sboErr;
}

/*******************************************************************
 Function name		: ValidateReport347
 Description	    : check if transaction can be reported for 347 report
 Return type		: SBOErr  
********************************************************************/
SBOErr	CTransactionJournalObject::ValidateReport347()
{
        _TRACER("ValidateReport347");
	CBizEnv	&bizEnv = GetEnv ();

	// relevant to Spain only
	if(!bizEnv.IsCurrentLocalSettings (SPAIN_SETTINGS))
	{
		return ooNoErr;
	}

	PDAG	dagJDT = GetDAG ();
	SBOErr	sboErr	= ooNoErr;
	SBOString report347Str;

	dagJDT->GetColStr(report347Str, OJDT_REPORT_347);
	if(report347Str.Compare(VAL_YES))
	{
		return ooNoErr;
	}
	
	// only manual JDT
	sboErr = ValidateVatReportTransType();
	
	if (sboErr == noErr)
	{
		long numOfBPfound = 0;

		sboErr = GetNumOfBPRecords (numOfBPfound, false);
		IF_ERROR_RETURN (sboErr);

		if (numOfBPfound != 1)	// only one BP
		{
			Message (GO_OBJ_ERROR_MSGS(JDT), JDT_347_REPORT_DIFFER_ONE_BP_ERR, NULL, OO_ERROR);
			sboErr =  errNoMsg;
		}
	}

	if (sboErr != noErr)
	{
		SetErrorField (-1);
		SetErrorField (OJDT_REPORT_347);
	}

	return sboErr;
}

/*******************************************************************
 Function name		: ValidateVatReportTransType
 Description	    : check if the journal entry is manual will report
						an error if not
 Return type		: SBOErr  
********************************************************************/
SBOErr	CTransactionJournalObject::ValidateVatReportTransType ()
{
        _TRACER("ValidateVatReportTransType");
	SBOErr	sboErr	= ooNoErr;
	PDAG	dagJDT = GetDAG ();
	
	if (IsManualJE (dagJDT) == false)
	{
		Message (GO_OBJ_ERROR_MSGS(JDT), JDT_REPORT_MANUAL_TRANS_ONLY_ERR, NULL, OO_ERROR);
		sboErr = errNoMsg;
	}

	return sboErr;
}

// VF_MultiBranch_EnabledInOADM
SBOErr	CTransactionJournalObject::ValidateBPLEx (CBusinessObject* bizObject)
{
	SBOErr ooErr = noErr;
	CBizEnv &env = bizObject->GetEnv ();
	CTransactionJournalObject *boJDT = static_cast<CTransactionJournalObject*> (env.CreateBusinessObject (SBOString (JDT)));
	AutoCleanBOHandler acBo ((CBusinessObject*&)boJDT);

	boJDT->SetDAG (bizObject->GetDAG (JDT, ao_Main), false, JDT, ao_Main);
	boJDT->SetDAG (bizObject->GetDAG (JDT, ao_Arr1), false, JDT, ao_Arr1);
	boJDT->SetDAG (bizObject->GetDAG (JDT, ao_Arr2), false, JDT, ao_Arr2);

	ooErr = boJDT->ValidateBPL (bizObject->GetID () != SBOString (JDT) ? true : false);
	IF_ERROR_RETURN (ooErr);

	return ooErr;
}

// VF_MultiBranch_EnabledInOADM
/*******************************************************************
 Function name		: ValidateBPL
 Description	    : validates BPLIds from various objects assigned to this object (Accounts, User, Numbering, etc ...)
 Return type		: SBOErr  
********************************************************************/
SBOErr	CTransactionJournalObject::ValidateBPL (const bool bValidateSameBPLIDOnLines /* =false */)
{
	SBOErr ooErr = noErr;
	CBizEnv &env = GetEnv ();

	if (!VF_MultiBranch_EnabledInOADM (env))
	{
		return noErr;
	}

	PDAG dagJDT = GetDAG (JDT, ao_Main);
	if (!DAG::IsValid (dagJDT))
	{
		return noErr;
	}
	
	SBOLongSet BPLIds;
	// match Accounts BPLs
	PDAG dagJDT1 = GetDAG (JDT, ao_Arr1);
	if (!DAG::IsValid (dagJDT1))
	{
		return noErr;
	}

	long dag1Size = dagJDT1->GetRealSize (dbmDataBuffer);
	for (long dag1Row = 0; dag1Row < dag1Size; dag1Row++)
	{
		SBOString BPLName = dagJDT1->GetColStrAndTrim (JDT1_BPL_NAME, dag1Row, coreSystemDefault);
		long BPLId = dagJDT1->GetColStr (JDT1_BPL_ID, dag1Row, coreSystemDefault).strtol ();
		BPLIds.insert (BPLId);

		if (!CBusinessPlaceObject::IsBPLIdValidForObject (BPLId, JDT, env))
		{
			SetArrNum (ao_Arr1);
			SetErrorLine (dag1Row + 1);
			SetErrorField (JDT1_BPL_ID);
			Message (CBusinessPlaceObject::ERROR_STRING_LIST_ID, CBusinessPlaceObject::ERRMSG_CANNOT_SELECT_DISABLED_BPL_STR, BPLName, OO_ERROR);
			return ooInvalidObject;
		}

		// match User BPLs
		SBOString tmpUserCode(env.GetUserCode ());
		if (!CBusinessPlaceObject::IsBPLIdAssignedToObject (env, BPLId, USR, tmpUserCode))
		{
			SetArrNum (ao_Arr1);
			SetErrorLine (dag1Row + 1);
			SetErrorField (JDT1_BPL_ID);
			//Message (CBusinessPlaceObject::ERROR_STRING_LIST_ID, CBusinessPlaceObject::ERRMSG_USER_NOT_ASSIGNED_BPL_STR, NULL, OO_ERROR);
			SBOString BPLName = dagJDT1->GetColStr (JDT1_BPL_NAME, dag1Row, coreSystemDefault).Trim ();
			CMessagesManager::GetHandle ()->Message (_132_APP_MSG_AP_AR_USER_NOT_ASSINED_BPL, EMPTY_STR, this, (const TCHAR*)BPLName);
			return ooInvalidObject;
		}

        SBOString actCode = dagJDT1->GetColStr (JDT1_ACCT_NUM, dag1Row, coreSystemDefault).Trim ();
        SBOString shortName = dagJDT1->GetColStr (JDT1_SHORT_NAME, dag1Row, coreSystemDefault).Trim ();
		if (actCode != shortName)	//it's a bp line
		{
			// match Card BPLs
			if (!CBusinessPlaceObject::IsBPLIdAssignedToObject (env, BPLId, CRD, shortName))
			{
				SetArrNum (ao_Arr1);
				SetErrorLine (dag1Row + 1);
				SetErrorField (JDT1_SHORT_NAME);
				//Message (CBusinessPlaceObject::ERROR_STRING_LIST_ID, CBusinessPlaceObject::ERRMSG_CRD_NOT_ASSIGNED_BPL_STR, NULL, OO_ERROR);
				SBOString BPLName = dagJDT1->GetColStr (JDT1_BPL_NAME, dag1Row, coreSystemDefault).Trim ();
				CMessagesManager::GetHandle ()->Message (_132_APP_MSG_AP_AR_BP_NOT_ASSIGNED_SELECTED_BPL, shortName, this, (const TCHAR*)BPLName);
				return ooInvalidObject;
			}
		}   

		long accountCols[] = {JDT1_ACCT_NUM, /*JDT1_SHORT_NAME, JDT1_CONTRA_ACT, */ //mixed with BP code, anyway checked on later rows
							JDT1_STORNO_ACC, -1};

		for (long i=0; accountCols[i] != -1; i++)
		{
			SBOString accountCode = dagJDT1->GetColStr (accountCols[i], dag1Row, coreSystemDefault).Trim ();
			if (!CBusinessPlaceObject::IsBPLIdAssignedToObject (env, BPLId, ACT, accountCode))
			{
				SetArrNum (ao_Arr1);
				SetErrorLine (dag1Row + 1);
				SetErrorField (accountCols[i]);
				Message (CBusinessPlaceObject::ERROR_STRING_LIST_ID, CBusinessPlaceObject::ERRMSG_ACT_BPL_DIFFER_FROM_JE_LINE_BPL_STR, accountCode, OO_ERROR);
				return ooInvalidObject;
			}
		}

		// if we should validate that BPLIds on JDT1 lines are same and they are not, show error
		if (bValidateSameBPLIDOnLines && BPLIds.size () > 1)
		{
			SetArrNum (ao_Arr1);
			SetErrorLine (BPLId != GetBPLId () ? dag1Row + 1 : 1);
			SetErrorField (JDT1_BPL_ID);
			Message (CBusinessPlaceObject::ERROR_STRING_LIST_ID, CBusinessPlaceObject::ERRMSG_JDT1_BPL_DIFFER_FROM_DOCUMENT_BPL_STR, EMPTY_STR, OO_ERROR);
			return ooInvalidObject;
		}
	}

	// match Numbering BPLs
	// moved to ValidateBPLNumberingSeries () since there are cases when the series is filled just within OnCreate ()

	PDAG dagJDT2 = GetDAG (JDT, ao_Arr2);
	if (!DAG::IsValid (dagJDT2))
	{
		return noErr;
	}
	long dag2Size = dagJDT2->GetRealSize (dbmDataBuffer);
	for (long dag2Row = 0; dag2Row < dag2Size; dag2Row++)
	{
		SBOString wtaxCode = dagJDT2->GetColStr (JDT2_WT_CODE, dag2Row, coreSystemDefault).Trim ();
		long dag1Row = -1;
		dagJDT1->FindColStr (wtaxCode, JDT1_WTAX_CODE, 0, &dag1Row);

		if (dag1Row < 0) continue;

		long BPLId = dagJDT1->GetColStr (JDT1_BPL_ID, dag1Row, coreSystemDefault).strtol ();
		long accountCols[] = {JDT2_ACCOUNT, JDT2_TDS_ACCOUNT, JDT2_SUR_ACCOUNT, JDT2_CESS_ACCOUNT, JDT2_HSC_ACCOUNT, -1};

		for (long i=0; accountCols[i] < 0; i++)
		{
			SBOString accountCode = dagJDT2->GetColStr (accountCols[i], dag2Row, coreSystemDefault).Trim ();
			if (!CBusinessPlaceObject::IsBPLIdAssignedToObject (env, BPLId, ACT, accountCode))
			{
				SetArrNum (ao_Arr1);
				SetErrorLine (dag1Row + 1);
				SetErrorField (JDT1_WTAX_CODE);
				Message (CBusinessPlaceObject::ERROR_STRING_LIST_ID, CBusinessPlaceObject::ERRMSG_ACT_BPL_DIFFER_FROM_JE_LINE_BPL_STR, accountCode, OO_ERROR);
				return ooInvalidObject;
			}
		}
	}

	ooErr = IsBalancedByBPL ();
	IF_ERROR_RETURN (ooErr);

	return noErr;
}

/*******************************************************************
 Function name		: ValidateBPLNumberingSeries
 Description	    : check if the BPL used is valid for Journal Entry series
 Return type		: SBOErr  
********************************************************************/
SBOErr	CTransactionJournalObject::ValidateBPLNumberingSeries ()
{
	CBizEnv &env = GetEnv ();

	if (!VF_MultiBranch_EnabledInOADM (env))
	{
		return noErr;
	}

	long series = GetSeries ();
	if (series <= 0)
	{
		GetDAG ()->GetColLong (&series, OJDT_SERIES);
	}

	SBOLongSet BPLIds;
	PDAG dagJDT1 = GetArrayDAG (ao_Arr1);
	long dag1Size = dagJDT1->GetRealSize (dbmDataBuffer);
	for (long dag1Row = 0; dag1Row < dag1Size; dag1Row++)
	{
		long BPLId = dagJDT1->GetColStr (JDT1_BPL_ID, dag1Row, coreSystemDefault).strtol ();
		BPLIds.insert (BPLId);
	}

	// match Numbering BPLs
	for (SBOLongSet::iterator it = BPLIds.begin (); it != BPLIds.end (); it++)
	{
		SBOString tmpNum = SBOString (series) + SBOString (SUB_TYPE_NONE);
		if (!CBusinessPlaceObject::IsBPLIdAssignedToObject (env, *it, NNM, tmpNum))
		{
			SetArrNum (ao_Main);
			SetErrorLine (-1);
			SetErrorField (OJDT_SERIES);
			APCompanyDAG dagOBJ;
			SBOString strObjCode;
			OpenDAG (dagOBJ, NNM, ao_Arr1);
			if ((PDAG)dagOBJ)
			{
				dagOBJ->GetByKey (SBOString (series));
			}
			if ((PDAG)dagOBJ && dagOBJ->GetRealSize (dbmDataBuffer) > 0)
			{
				strObjCode = dagOBJ->GetColStrAndTrim (NNM1_NAME, 0, coreSystemDefault);
			}
			Message (CBusinessPlaceObject::ERROR_STRING_LIST_ID, CBusinessPlaceObject::ERRMSG_BPL_NOT_ASSIGNED_TO_SERIES_STR, strObjCode, OO_ERROR);
			return ooInvalidObject;
		}
	}
	
	return noErr;
}

/*******************************************************************
 Function name		: IsBalancedByBPL
 Description	    : check if the balance is equal per each BPLId used
 Return type		: SBOErr  
********************************************************************/
SBOErr	CTransactionJournalObject::IsBalancedByBPL ()
{
	CBizEnv &env = GetEnv ();
	if (!VF_MultiBranch_EnabledInOADM (env))
	{
		return noErr;
	}

/*	PDAG dagJDT = GetDAG (JDT, ao_Main);
	long transType = -1;
	dagJDT->GetColLong (&transType, OJDT_TRANS_TYPE);
	if (transType != JDT)
	{
		return noErr;
	}
*/
	typedef std::map <long, CAllCurrencySums> SUMMED_BALANCE;

	SUMMED_BALANCE debits, credits;
	PDAG dagJDT1 = GetArrayDAG (ao_Arr1);
	long dag1Size = dagJDT1->GetRealSize (dbmDataBuffer);

	for (long rec = 0; rec < dag1Size; rec++)
	{
		long BPLId = -1;
		CAllCurrencySums amount;
		dagJDT1->GetColLong (&BPLId, JDT1_BPL_ID, rec);

		if (debits.find (BPLId) == debits.end ())
		{
			debits [BPLId] = CAllCurrencySums ();
		}
		if (credits.find (BPLId) == credits.end ())
		{
			credits [BPLId] = CAllCurrencySums ();
		}

		amount.FromDAG (dagJDT1, rec, JDT1_DEBIT, JDT1_FC_DEBIT, JDT1_SYS_DEBIT);
		debits [BPLId] += amount;
		amount.FromDAG (dagJDT1, rec, JDT1_CREDIT, JDT1_FC_CREDIT, JDT1_SYS_CREDIT);
		credits [BPLId] += amount;
	}

	for (SUMMED_BALANCE::iterator itDeb = debits.begin (); itDeb != debits.end (); itDeb++)
	{
		SUMMED_BALANCE::iterator itCred = credits.find (itDeb->first);
		if (itCred == credits.end ())
		{
			CMessagesManager::GetHandle()->Message (_132_APP_MSG_FIN_UNBALANCED_TRANS_FOR_BRANCH, EMPTY_STR, this);
			return ooInvalidObject;
		}

		if (itCred->second != itDeb->second)
		{
			CMessagesManager::GetHandle()->Message (_132_APP_MSG_FIN_UNBALANCED_TRANS_FOR_BRANCH, EMPTY_STR, this);
			return ooInvalidObject;
		}
	}

	return noErr;
}

/*******************************************************************
 Function name		: GetNumOfBPRecords
 Description	    : return the number of BP records in JDT1
 Return type		: SBOErr  
********************************************************************/
SBOErr	CTransactionJournalObject::GetNumOfBPRecords (long& numOfBPfound, bool validateFedTaxId /* = false*/)
{
        _TRACER("GetNumOfBPRecords");
	PDAG	dagJDT1 = GetDAG (JDT, ao_Arr1);
	long	recCount = dagJDT1->GetRecordCount ();
	SBOString	actCode, shortName, fedTaxId, taxGroup;
	long	indexOfMissingTaxId = -1;
	bool	foundECTax = false;
	CBizEnv	&bizEnv = GetEnv ();

	numOfBPfound = 0;

	for(long ii = 0; ii < recCount; ii++)
	{
		dagJDT1->GetColStr (actCode, JDT1_ACCT_NUM, ii);
		dagJDT1->GetColStr (shortName, JDT1_SHORT_NAME, ii);
		if (actCode.Compare(shortName) != 0) // if BP line
		{
			numOfBPfound++;
#ifndef MNHL_SERVER_MODE	
			if (validateFedTaxId && indexOfMissingTaxId < 0) // VF_FederalTaxIdOnJERow
			{
				dagJDT1->GetColStr (fedTaxId, JDT1_TAX_ID_NUMBER, ii);
				if (fedTaxId.IsSpacesStr ())
				{
					indexOfMissingTaxId = ii;
				}
			}
#endif
		}
#ifndef MNHL_SERVER_MODE	
		if (validateFedTaxId && !foundECTax) // VF_FederalTaxIdOnJERow
		{
			dagJDT1->GetColStr (taxGroup, JDT1_VAT_GROUP, ii);
			taxGroup.Trim ();
			if (!taxGroup.IsSpacesStr () && bizEnv.GetTaxGroupCache ()->IsEC (bizEnv, taxGroup))
			{
				foundECTax = true;
			}
		}
#endif
	}

#ifndef MNHL_SERVER_MODE	
	if (validateFedTaxId && foundECTax && indexOfMissingTaxId >= 0) // VF_FederalTaxIdOnJERow
	{
		if (CMessagesManager::GetHandle ()->DisplayMessage (_48_APP_MSG_FIN_JDT_MISSING_FEDERAL_TAX_ID) != DIALOG_YES_BTN)
		{
			return errNoMsg;
		}		
	}
#endif

	return noErr;
}
/*
UPDATE T1
SET CreatedBy=T0.OrderNum,BaseRef = T0.SerialNum
FROM OJDT T1
INNER JOIN OWKO T0 ON T1.TransType = 68 AND T1.Ref1 = CAST (T0.SerialNum AS nvarchar (20))
WHERE T1.CreatedBy <> T0.OrderNum AND 
(SELECT count ('A') FROM OWKO T2  WHERE T2.SerialNum = T0.SerialNum) = 1 AND 
(SELECT count ('A') FROM OJDT T3  WHERE T3.TransType = 68 AND T3.Ref1 = T1.Ref1) = 1
*/
SBOErr CTransactionJournalObject::UpgradeWorkOrderStep1 ()
{
	SBOErr			ooErr=ooNoErr;
	DBD_CondStruct	cond[4], join[2];
	DBD_UpdStruct	updateStruct[2];
	DBD_Tables		tables[2];
	PDAG			dagJDT;
	DBD_Params		subQueryParams[1], subQueryParams2[1];
	DBD_CondStruct	subcond1[4], subcond2[4];
	DBD_ResStruct	subres1[1], subres2[1];
	DBD_Tables		subtables1[1], subtables2[1];


	dagJDT	=	GetDAG	();

	tables[0].tableCode	=	this->GetEnv().ObjectToTable(JDT);
	tables[1].tableCode	=	this->GetEnv().ObjectToTable(WKO);
	
	join[0].colNum			=	OJDT_REF1;
	join[0].tableIndex		=	0;
	join[0].compareCols		=	true;
	join[0].compColNum		=	OWKO_SERIAL_NUM;
	join[0].compTableIndex	=	1;
	join[0].operation		=	DBD_EQ;
	join[0].relationship	=	DBD_AND;

	join[1].colNum			=	OJDT_TRANS_TYPE;
	join[1].tableIndex		=	0;
	join[1].compareCols		=	false;
	join[1].condVal			=	68L;
	join[1].operation		=	DBD_EQ;
	join[1].relationship	=	0;
	
	tables[1].joinConds		=	&join[0];
	tables[1].doJoin		=	true;
	tables[1].joinedToTable	=	0;
	tables[1].numOfConds	=	2;
	tables[1].outerJoin		=	false;

	updateStruct[0].colNum		=	OJDT_CREATED_BY;
	updateStruct[0].srcColNum	=	OWKO_ORDER_NUM;
	updateStruct[0].SetUpdateColSource(DBD_UpdStruct::ucs_UseRes);

	DBD_ResColumns* pResCol = updateStruct[0].GetResObject().AddResCol ();	
	pResCol->SetTableIndex (1);
	pResCol->SetColNum (OWKO_ORDER_NUM);

	updateStruct[1].colNum		=	OJDT_BASE_REF;
	updateStruct[1].srcColNum	=	OWKO_SERIAL_NUM;
	updateStruct[1].SetUpdateColSource(DBD_UpdStruct::ucs_UseRes);

	pResCol = updateStruct[1].GetResObject().AddResCol ();	
	pResCol->SetTableIndex (1);
	pResCol->SetColNum (OWKO_SERIAL_NUM);

	cond[0].colNum			=	OJDT_CREATED_BY;
	cond[0].tableIndex		=	0;
	cond[0].compareCols		=	true;
	cond[0].operation		=	DBD_NE;
	cond[0].compColNum		=	OWKO_ORDER_NUM;
	cond[0].compTableIndex	=	1;
	cond[0].relationship	=	DBD_AND;
	
	cond[1].bracketOpen		=	1;
	cond[1].SetSubQueryParams(subQueryParams);
	cond[1].tableIndex		=	DBD_NO_TABLE;
	cond[1].operation		=	DBD_EQ;
	_STR_strcpy (cond[1].condVal, STR_1);
	cond[1].bracketClose	=	1;
	cond[1].relationship	=	DBD_AND;

	cond[2].bracketOpen		=	1;
	cond[2].SetSubQueryParams(subQueryParams2);
	cond[2].tableIndex		=	DBD_NO_TABLE;
	cond[2].operation		=	DBD_EQ;
	_STR_strcpy (cond[2].condVal, STR_1);
	cond[2].bracketClose	=	1;
	cond[2].relationship	=	0;

	subtables1[0].tableCode		=	this->GetEnv().ObjectToTable(WKO);

	subres1[0].colNum			=	OWKO_SERIAL_NUM;
	subres1[0].tableIndex		=	0;
	subres1[0].agreg_type		=	DBD_COUNT;

	subcond1[0].colNum			=	OWKO_SERIAL_NUM;
	subcond1[0].tableIndex		=	0;
	subcond1[0].compareCols		=	true;
	subcond1[0].operation		=	DBD_EQ;
	subcond1[0].compColNum		=	OWKO_SERIAL_NUM;
	subcond1[0].origTableIndex	=	1;
	subcond1[0].origTableLevel	=	1;
	subcond1[0].relationship	=	0;

	DBD_SetCond(subQueryParams, subcond1, 1);
	DBD_SetRes(subQueryParams, subres1, 1);
	DBD_SetParamTablesList (subQueryParams, subtables1, 1);
	
	subtables2[0].tableCode		=	this->GetEnv().ObjectToTable(JDT);

	subres2[0].colNum			=	OJDT_TRANS_TYPE;
	subres2[0].tableIndex		=	0;
	subres2[0].agreg_type		=	DBD_COUNT;

	subcond2[0].colNum			=	OJDT_REF1;
	subcond2[0].tableIndex		=	0;
	subcond2[0].compareCols		=	true;
	subcond2[0].operation		=	DBD_EQ;
	subcond2[0].compColNum		=	OJDT_REF1;
	subcond2[0].origTableIndex	=	0;
	subcond2[0].origTableLevel	=	1;
	subcond2[0].relationship	=	DBD_AND;

	subcond2[1].colNum			=	OJDT_TRANS_TYPE;
	subcond2[1].tableIndex		=	0;
	subcond2[1].compareCols		=	false;
	subcond2[1].operation		=	DBD_EQ;
	subcond2[1].condVal			=	68L;
	subcond2[1].relationship	=	0;

	DBD_SetCond(subQueryParams2, subcond2, 2);
	DBD_SetRes(subQueryParams2, subres2, 1);
	DBD_SetParamTablesList (subQueryParams2, subtables2, 1);

	DBD_SetDAGCond		(dagJDT, cond, 3);
	DBD_SetDAGUpd		(dagJDT, updateStruct, 2);
	DBD_SetTablesList	(dagJDT, tables, 2);

	ooErr	=	DBD_UpdateCols(dagJDT);
	return ooErr;
}

/*
UPDATE T1                                      
SET CreatedBy = T0.CreatedBy                     
FROM OJDT T0
INNER JOIN JDT1 T1  ON  T0.TransID = T1.TransID                
WHERE T0.TransType = 68  AND T1.CreatedBy <> T0.CreatedBy 
*/
SBOErr CTransactionJournalObject::UpgradeWorkOrderStep2 ()
{
	SBOErr			ooErr=ooNoErr;
	DBD_CondStruct	cond[2], join[1];
	DBD_UpdStruct	updateStruct[1];
	DBD_Tables		tables[2];
	PDAG			dagJDT1;

	dagJDT1	=	GetDAG	(JDT, ao_Arr1);

	tables[0].tableCode	=	this->GetEnv().ObjectToTable(JDT, ao_Arr1);
	tables[1].tableCode	=	this->GetEnv().ObjectToTable(JDT);
	
	join[0].colNum			=	JDT1_TRANS_ABS;
	join[0].tableIndex		=	0;
	join[0].compareCols		=	true;
	join[0].compColNum		=	OJDT_JDT_NUM;
	join[0].compTableIndex	=	1;
	join[0].operation		=	DBD_EQ;
	join[0].relationship	=	0;
	
	tables[1].joinConds		=	&join[0];
	tables[1].doJoin		=	true;
	tables[1].joinedToTable	=	0;
	tables[1].numOfConds	=	1;
	tables[1].outerJoin		=	false;

	updateStruct[0].colNum		=	JDT1_CREATED_BY;
	updateStruct[0].srcColNum	=	OJDT_CREATED_BY;
	updateStruct[0].SetUpdateColSource(DBD_UpdStruct::ucs_UseRes);

	DBD_ResColumns* pResCol = updateStruct[0].GetResObject().AddResCol ();	
	pResCol->SetTableIndex (1);
	pResCol->SetColNum (OJDT_CREATED_BY);
	
	cond[0].colNum			=	OJDT_CREATED_BY;
	cond[0].tableIndex		=	1;
	cond[0].compareCols		=	true;
	cond[0].operation		=	DBD_NE;
	cond[0].compColNum		=	JDT1_CREATED_BY;
	cond[0].compTableIndex	=	0;
	cond[0].relationship	=	DBD_AND;

	cond[1].colNum			=	OJDT_TRANS_TYPE;
	cond[1].tableIndex		=	1;
	cond[1].compareCols		=	false;
	cond[1].operation		=	DBD_EQ;
	cond[1].condVal			=	68L;
	cond[1].relationship	=	0;

	DBD_SetDAGCond			(dagJDT1, cond, 2);
	DBD_SetDAGUpd			(dagJDT1, updateStruct, 1);
	DBD_SetTablesList		(dagJDT1, tables, 2);

	ooErr	=	DBD_UpdateCols(dagJDT1);
	return	ooErr;
}
/*
UPDATE T1
SET CreateDate = T0.CreateDate
FROM OINM T0 INNER JOIN OJDT T1
ON T1.TransType = 68 AND T0.TransType = 68 AND T0.CreatedBy = T1.CreatedBy 
WHERE T1.CreateDate IS NULL AND 
T0.TransSeq = (SELECT MIN (TransSeq) FROM OINM T2 WHERE T2.TransType = T0.TransType 
AND T2.CreatedBy = T0.CreatedBy)
*/
SBOErr CTransactionJournalObject::UpgradeWorkOrderStep3 ()
{
	SBOErr			ooErr=ooNoErr;
	DBD_CondStruct	cond[2], join[3];
	DBD_UpdStruct	updateStruct[1];
	DBD_Tables		tables[2];
	PDAG			dagJDT;
	DBD_Params		subQueryParams[1];
	DBD_CondStruct	subcond1[2];
	DBD_ResStruct	subres1[1];
	DBD_Tables		subtables1[1];


	dagJDT	=	GetDAG	();

	tables[0].tableCode	=	this->GetEnv().ObjectToTable(JDT);
	tables[1].tableCode	=	this->GetEnv().ObjectToTable(INM);
	
	join[0].colNum			=	OJDT_CREATED_BY;
	join[0].tableIndex		=	0;
	join[0].compareCols		=	true;
	join[0].compColNum		=	OINM_CREATED_BY;
	join[0].compTableIndex	=	1;
	join[0].operation		=	DBD_EQ;
	join[0].relationship	=	DBD_AND;

	join[1].colNum			=	OJDT_TRANS_TYPE;
	join[1].tableIndex		=	0;
	join[1].compareCols		=	false;
	join[1].condVal			=	68L;
	join[1].operation		=	DBD_EQ;
	join[1].relationship	=	DBD_AND;

	join[2].colNum			=	OINM_TYPE;
	join[2].tableIndex		=	1;
	join[2].compareCols		=	false;
	join[2].condVal			=	68L;
	join[2].operation		=	DBD_EQ;
	join[2].relationship	=	0;
	
	tables[1].joinConds		=	&join[0];
	tables[1].doJoin		=	true;
	tables[1].joinedToTable	=	0;
	tables[1].numOfConds	=	3;
	tables[1].outerJoin		=	false;

	updateStruct[0].colNum		=	OJDT_CREATE_DATE;
	updateStruct[0].srcColNum	=	OINM_CREATE_DATE;
	updateStruct[0].SetUpdateColSource(DBD_UpdStruct::ucs_UseRes);

	DBD_ResColumns* pResCol = updateStruct[0].GetResObject().AddResCol ();	
	pResCol->SetTableIndex (1);
	pResCol->SetColNum (OINM_CREATE_DATE);

	cond[0].colNum			=	OJDT_CREATE_DATE;
	cond[0].tableIndex		=	0;
	cond[0].compareCols		=	false;
	cond[0].operation		=	DBD_IS_NULL;
	cond[0].relationship	=	DBD_AND;
	
	cond[1].bracketOpen		=	1;
	cond[1].SetSubQueryParams(subQueryParams);
	cond[1].tableIndex		=	DBD_NO_TABLE;
	cond[1].operation		=	DBD_EQ;
	cond[1].compareCols		=	true;
	cond[1].compColNum		=	OINM_TRANS_SEQUENCE;
	cond[1].compTableIndex	=	1;
	cond[1].bracketClose	=	1;
	cond[1].relationship	=	0;

	subtables1[0].tableCode		=	this->GetEnv().ObjectToTable(INM);

	subres1[0].colNum			=	OINM_TRANS_SEQUENCE;
	subres1[0].tableIndex		=	0;
	subres1[0].agreg_type		=	DBD_MIN;

	subcond1[0].colNum			=	OINM_TYPE;
	subcond1[0].tableIndex		=	0;
	subcond1[0].compareCols		=	true;
	subcond1[0].operation		=	DBD_EQ;
	subcond1[0].compColNum		=	OINM_TYPE;
	subcond1[0].origTableIndex	=	1;
	subcond1[0].origTableLevel	=	1;
	subcond1[0].relationship	=	DBD_AND;

	subcond1[1].colNum			=	OINM_CREATED_BY;
	subcond1[1].tableIndex		=	0;
	subcond1[1].compareCols		=	true;
	subcond1[1].operation		=	DBD_EQ;
	subcond1[1].compColNum		=	OINM_CREATED_BY;
	subcond1[1].origTableIndex	=	1;
	subcond1[1].origTableLevel	=	1;
	subcond1[1].relationship	=	0;

	DBD_SetCond(subQueryParams, subcond1, 2);
	DBD_SetRes(subQueryParams, subres1, 1);
	DBD_SetParamTablesList (subQueryParams, subtables1, 1);

	DBD_SetDAGCond				(dagJDT, cond, 2);
	DBD_SetDAGUpd				(dagJDT, updateStruct, 1);
	DBD_SetTablesList			(dagJDT, tables, 2);

	ooErr	=	DBD_UpdateCols(dagJDT);
	return	ooErr;
}
/*
UPDATE T0
SET CreateDate = T1.CreateDate
FROM OINM T0 INNER JOIN OJDT T1
ON T1.TransType = 68 AND T0.TransType = 68 AND T0.CreatedBy = T1.CreatedBy 
WHERE T0.CreateDate IS NULL 
*/
SBOErr CTransactionJournalObject::UpgradeWorkOrderStep4 ()
{
	SBOErr			ooErr=ooNoErr;
	DBD_CondStruct	cond[1], join[3];
	DBD_UpdStruct	updateStruct[1];
	DBD_Tables		tables[2];
	PDAG			dagINM;

	dagINM	=	GetDAG	(INM);

	tables[0].tableCode	=	this->GetEnv().ObjectToTable(INM);
	tables[1].tableCode	=	this->GetEnv().ObjectToTable(JDT);
	
	join[0].colNum			=	OINM_CREATED_BY;
	join[0].tableIndex		=	0;
	join[0].compareCols		=	true;
	join[0].compColNum		=	OJDT_CREATED_BY;
	join[0].compTableIndex	=	1;
	join[0].operation		=	DBD_EQ;
	join[0].relationship	=	DBD_AND;

	join[1].colNum			=	OJDT_TRANS_TYPE;
	join[1].tableIndex		=	1;
	join[1].compareCols		=	false;
	join[1].condVal			=	68L;
	join[1].operation		=	DBD_EQ;
	join[1].relationship	=	DBD_AND;

	join[2].colNum			=	OINM_TYPE;
	join[2].tableIndex		=	0;
	join[2].compareCols		=	false;
	join[2].condVal			=	68L;
	join[2].operation		=	DBD_EQ;
	join[2].relationship	=	0;
	
	tables[1].joinConds		=	&join[0];
	tables[1].doJoin		=	true;
	tables[1].joinedToTable	=	0;
	tables[1].numOfConds	=	3;
	tables[1].outerJoin		=	false;

	updateStruct[0].colNum		=	OINM_CREATE_DATE;
	updateStruct[0].srcColNum	=	OJDT_CREATE_DATE;
	updateStruct[0].SetUpdateColSource(DBD_UpdStruct::ucs_UseRes);

	DBD_ResColumns* pResCol = updateStruct[0].GetResObject().AddResCol ();	
	pResCol->SetTableIndex (1);
	pResCol->SetColNum (OJDT_CREATE_DATE);
	
	cond[0].colNum			=	OINM_CREATE_DATE;
	cond[0].tableIndex		=	0;
	cond[0].compareCols		=	false;
	cond[0].operation		=	DBD_IS_NULL;
	cond[0].relationship	=	0;

	DBD_SetDAGCond			(dagINM, cond, 1);
	DBD_SetDAGUpd			(dagINM, updateStruct, 1);
	DBD_SetTablesList		(dagINM, tables, 2);

	ooErr	=	DBD_UpdateCols(dagINM);
	return	ooErr;
}
/*
UPDATE T2
SET CreateDate = T0.CreateDate
FROM OINM T0
INNER JOIN  OIPF T1 ON T0.TransType = 69 AND T0.CreatedBy = T1.DocEntry
INNER JOIN OJDT T2 ON T2.TransType = 69 AND T2.CreatedBy = T0.CreatedBy AND T2.TransId = T1.JdtNum
WHERE T2.CreateDate IS NULL
*/
SBOErr CTransactionJournalObject::UpgradeLandedCosErr ()
{
	SBOErr			ooErr=ooNoErr;
	DBD_CondStruct	cond[1], cond2[1], joinCondition1[2], joinCondition2[3];
	DBD_UpdStruct	updateStruct[1];
	DBD_Tables		tables[3],tables2[1];
	PDAG			dagJDT, dagRes;
	DBD_ResStruct	Res[4];
	long			numOfRecords;

	dagJDT	=	GetDAG();

	tables[0].tableCode	=	this->GetEnv().ObjectToTable(INM);
	tables[1].tableCode	=	this->GetEnv().ObjectToTable(IPF);
	tables[2].tableCode	=	this->GetEnv().ObjectToTable(JDT);
	
	joinCondition1[0].colNum			=	OINM_TYPE;
	joinCondition1[0].tableIndex		=	0;
	joinCondition1[0].compareCols		=	false;
	joinCondition1[0].condVal			=	69L;
	joinCondition1[0].operation			=	DBD_EQ;
	joinCondition1[0].relationship		=	DBD_AND;

	joinCondition1[1].colNum			=	OINM_CREATED_BY;
	joinCondition1[1].tableIndex		=	0;
	joinCondition1[1].compareCols		=	true;
	joinCondition1[1].compColNum		=	OIPF_ABS_ENTRY;
	joinCondition1[1].compTableIndex	=	1;
	joinCondition1[1].operation			=	DBD_EQ;
	joinCondition1[1].relationship		=	0;

	tables[1].joinConds		=	joinCondition1;
	tables[1].doJoin		=	true;
	tables[1].joinedToTable	=	0;
	tables[1].numOfConds	=	2;
	tables[1].outerJoin		=	false;

	joinCondition2[0].colNum			=	OJDT_TRANS_TYPE;
	joinCondition2[0].tableIndex		=	2;
	joinCondition2[0].compareCols		=	false;
	joinCondition2[0].condVal			=	69L;
	joinCondition2[0].operation			=	DBD_EQ;
	joinCondition2[0].relationship		=	DBD_AND;

	joinCondition2[1].colNum			=	OINM_CREATED_BY;
	joinCondition2[1].tableIndex		=	0;
	joinCondition2[1].compareCols		=	true;
	joinCondition2[1].compColNum		=	OJDT_CREATED_BY;
	joinCondition2[1].compTableIndex	=	2;
	joinCondition2[1].operation			=	DBD_EQ;
	joinCondition2[1].relationship		=	DBD_AND;

	joinCondition2[2].colNum			=	OJDT_JDT_NUM;
	joinCondition2[2].tableIndex		=	2;
	joinCondition2[2].compareCols		=	true;
	joinCondition2[2].compColNum		=	OIPF_JDT_NUM;
	joinCondition2[2].compTableIndex	=	1;
	joinCondition2[2].operation			=	DBD_EQ;
	joinCondition2[2].relationship		=	0;

	tables[2].joinConds		=	joinCondition2;
	tables[2].doJoin		=	true;
	tables[2].joinedToTable	=	0;
	tables[2].numOfConds	=	3;
	tables[2].outerJoin		=	false;

	Res[0].colNum			=	OJDT_CREATE_DATE;
	Res[0].tableIndex		=	2;
	Res[1].colNum			=	OINM_CREATE_DATE;
	Res[1].tableIndex		=	0;
	Res[2].colNum			=	OJDT_JDT_NUM;
	Res[2].tableIndex		=	2;
	Res[3].colNum			=	OINM_NUM;
	Res[3].tableIndex		=	0;

	cond[0].colNum			=	OJDT_CREATE_DATE;
	cond[0].tableIndex		=	2;
	cond[0].compareCols		=	false;
	cond[0].operation		=	DBD_IS_NULL;
	cond[0].relationship	=	0;
	DBD_SetDAGCond			(dagJDT, cond, 1);
	DBD_SetDAGRes			(dagJDT, Res, 4);
	DBD_SetTablesList		(dagJDT, tables, 3);

	ooErr	=	DBD_GetInNewFormat(dagJDT, &dagRes);
	if(ooErr)
	{
		if(ooErr==dbmNoDataFound)
			return	ooNoErr;
		else
			return	ooErr;
	}
	
	numOfRecords = dagRes->GetRecordCount();
	tables2[0].tableCode			=	this->GetEnv().ObjectToTable(JDT);
	for (int i=0;i<numOfRecords;i++)
	{
		updateStruct[0].colNum		=	OJDT_CREATE_DATE;
		dagRes->GetColStr(updateStruct[0].updateVal, 1, i);
		cond2[0].colNum				=	OJDT_JDT_NUM;
		cond2[0].tableIndex			=	0;
		cond2[0].compareCols			=	false;
		cond2[0].operation			=	DBD_EQ;
		dagRes->GetColStr(cond2[0].condVal, 2, i);
		cond2[0].relationship		=	0;
		
		DBD_SetDAGUpd(dagJDT, updateStruct,1);
		DBD_SetTablesList(dagJDT, tables2, 1);
		DBD_SetDAGCond(dagJDT, cond2, 1);
		ooErr	=	DBD_UpdateCols(dagJDT);
		if(ooErr)
			return ooErr;
	}
	return	ooNoErr;		
}

SBOErr CTransactionJournalObject::UpgradeWorkOrderErr ()
{
	SBOErr			ooErr=ooNoErr;
	ooErr	=	UpgradeWorkOrderStep1();
	if(ooErr)	return ooErr;
	ooErr	=	UpgradeWorkOrderStep2();
	if(ooErr)	return ooErr;
	ooErr	=	UpgradeWorkOrderStep3();
	if(ooErr)	return ooErr;
	ooErr	=	UpgradeWorkOrderStep4();
	if(ooErr)	return ooErr;

	return ooErr;
}

/************************************************************************/
/**
* OJDTFillJDT1FromAccounts: 
* Supply an option to create a JDT1 from the AccountsArray of the CJournalManager.
* The method makes no completions and no updates to the DB.
* Inserting the populated DAG following the use of this method must be done via
* CTransactionJournalObject->Create (true) // 'true' in order to invoke AutoComplete()
*
* @param:	CBizEnv& bizEnv
*			PDAG dagJDT1 - a valid DAG JDT1 to be populated. Old contents of DAG is destroyed if lines are added.
* 
* @return:	SBOErr
*
* NOTE:the function may (and should) change actsList according what is written to JDT1 in order that the actsList will reflect the real JE. (see debCred for example)
*/
/************************************************************************/

SBOErr	CTransactionJournalObject::OJDTFillJDT1FromAccounts (const AccountsConstArray& accountsArrayFrom, AccountsArrayRef accountsArrayRes, CBusinessObject* srcObject)
{
        _TRACER("OJDTFillJDT1FromAccounts");
	
	long			numOfAccts, jdtLine;
	bool			isNegative, linesAdded = false;
	MONEY			zeroSum;
	PDAG			dagJDT1 = GetArrayDAG(ao_Arr1);
	PDAG			dagJDT = GetDAG();
	CBizEnv			&bizEnv = GetEnv();

	if (!DAG_IsValid (dagJDT1))
	{
		return	(dbmBadDAG);
	}

	numOfAccts = accountsArrayFrom.GetSize ();
	if (numOfAccts <= 0)
	{
		return ooNoErr;
	}


	//////////////////////////////////////////////////////////////////////////
	// Populate JDT1 from the AccountsArray of the CJournalManager.
	// Fields are updated according to order of fields in SActsList
	for (long ii = 0 ; ii < numOfAccts ; ++ii)
	{
		//Create JDT line only if sum is not zero 
		if (!accountsArrayFrom[ii]->allowZeros)
		{
			if (accountsArrayFrom[ii]->sum == 0 && accountsArrayFrom[ii]->sysSum == 0 &&
				accountsArrayFrom[ii]->frgnSum == 0)
			{
				continue;
			}
		}

		linesAdded = true;

		accountsArrayRes.Add((accountsArrayFrom[ii]->Clone()));
		jdtLine = accountsArrayRes.GetSize()-1;
		if (jdtLine == 0L)
		{
			DAG_SetSize (dagJDT1, 1, dbmDropData);
			dagJDT1->SetBackupSize (1, dbmDropData);
		}
		else
		{
			DAG_SetSize (dagJDT1, jdtLine+1, dbmKeepData);
		}

		// Note - if actCode is missing it will be completed according to shortName by
		// CTransactionJournalObject.CompleteTrans()
		// the value is taken from OCRD_DEB_PAY_ACCOUNT for cards

		if (!_STR_IsSpacesStr (accountsArrayRes[jdtLine]->actCode))
		{
			dagJDT1->SetColStr (accountsArrayRes[jdtLine]->actCode, JDT1_ACCT_NUM, jdtLine);
		}

		if (!_STR_IsSpacesStr (accountsArrayRes[jdtLine]->shortName))
		{
			dagJDT1->SetColStr (accountsArrayRes[jdtLine]->shortName, JDT1_SHORT_NAME, jdtLine);
		}

		if (!_STR_IsSpacesStr (accountsArrayRes[jdtLine]->contraAct))
		{
			dagJDT1->SetColStr (accountsArrayRes[jdtLine]->contraAct, JDT1_CONTRA_ACT, jdtLine);
		}

		long nDimCount = 1;
		if(VF_CostAcctingEnh(GetEnv()))
		{
			nDimCount = DIMENSION_MAX;
		}

			SBOString	postDate;
			dagJDT1->GetColStr (postDate, JDT1_REF_DATE, jdtLine);
		for(long dim=0; dim<nDimCount; dim++)
		{
			if (!_STR_IsSpacesStr (accountsArrayRes[jdtLine]->ocrCode[dim]))
			{
				dagJDT1->SetColStr (accountsArrayRes[jdtLine]->ocrCode[dim], GetOcrCodeCol(dim), jdtLine);

				// update valid from for ocr code				
			SBOString	validFrom;
				COverheadCostRateObject::GetValidFrom (bizEnv, accountsArrayRes[jdtLine]->ocrCode[dim], postDate, validFrom);

				dagJDT1->SetColStr (validFrom, GetValidFromCol(dim), jdtLine);
			}
		}

		if (!_STR_IsSpacesStr (accountsArrayRes[jdtLine]->prjCode))
		{
			dagJDT1->SetColStr (accountsArrayRes[jdtLine]->prjCode, JDT1_PROJECT, jdtLine);
		}

		if (VF_PaymentTraceability (bizEnv))
		{
			if (accountsArrayRes[jdtLine]->cig != 0)
			{
				dagJDT1->SetColLong (accountsArrayRes[jdtLine]->cig, JDT1_CIG, jdtLine);
			}

			if (accountsArrayRes[jdtLine]->cup != 0)
			{
				dagJDT1->SetColLong (accountsArrayRes[jdtLine]->cup, JDT1_CUP, jdtLine);
			}
		}

		// Set SUM Fields
		isNegative = accountsArrayRes[jdtLine]->sum.IsNegative() || accountsArrayRes[jdtLine]->sysSum.IsNegative() || accountsArrayRes[jdtLine]->frgnSum.IsNegative();

		bool useNegativeAmount = bizEnv.GetUseNegativeAmount();

		long	transType;
		dagJDT->GetColLong(&transType, OJDT_TRANS_TYPE);
		if (transType == RCT || transType == VPM) 
		{
			// there are several places in payment docs that the assumption is that the amounts will
			// always be on a certain side - that is why this restriction
			useNegativeAmount = true;
		}

		if (isNegative && !useNegativeAmount)
		{
			accountsArrayRes[jdtLine]->sum *= -1L;
			accountsArrayRes[jdtLine]->sysSum *= -1L;
			accountsArrayRes[jdtLine]->frgnSum *= -1L;

			if (accountsArrayRes[jdtLine]->debCred == DEBIT)
			{
				accountsArrayRes[jdtLine]->debCred = CREDIT;
			}
			else
			{
				accountsArrayRes[jdtLine]->debCred = DEBIT;
			}
		}

		if (accountsArrayRes[jdtLine]->debCred == DEBIT)
		{
			dagJDT1->SetColMoney (&accountsArrayRes[jdtLine]->sum, JDT1_DEBIT, jdtLine);
			dagJDT1->SetColMoney (&accountsArrayRes[jdtLine]->sysSum, JDT1_SYS_DEBIT, jdtLine);
			dagJDT1->SetColMoney (&accountsArrayRes[jdtLine]->frgnSum, JDT1_FC_DEBIT, jdtLine);

			if (accountsArrayRes[jdtLine]->nullifyOppsSumCols)
			{
				dagJDT1->NullifyCol (JDT1_CREDIT, jdtLine);
				dagJDT1->NullifyCol (JDT1_SYS_CREDIT, jdtLine);
				dagJDT1->NullifyCol (JDT1_FC_CREDIT, jdtLine);
			}
			else
			{
				dagJDT1->SetColMoney (&zeroSum, JDT1_CREDIT, jdtLine);
				dagJDT1->SetColMoney (&zeroSum, JDT1_SYS_CREDIT, jdtLine);
				dagJDT1->SetColMoney (&zeroSum, JDT1_FC_CREDIT, jdtLine);
			}
		}
		else
		{
			dagJDT1->SetColMoney (&accountsArrayRes[jdtLine]->sum, JDT1_CREDIT, jdtLine);
			dagJDT1->SetColMoney (&accountsArrayRes[jdtLine]->sysSum, JDT1_SYS_CREDIT, jdtLine);
			dagJDT1->SetColMoney (&accountsArrayRes[jdtLine]->frgnSum, JDT1_FC_CREDIT, jdtLine);

			if (accountsArrayRes[jdtLine]->nullifyOppsSumCols)
			{
				dagJDT1->NullifyCol (JDT1_DEBIT, jdtLine);
				dagJDT1->NullifyCol (JDT1_SYS_DEBIT, jdtLine);
				dagJDT1->NullifyCol (JDT1_FC_DEBIT, jdtLine);
			}
			else
			{
				dagJDT1->SetColMoney (&zeroSum, JDT1_DEBIT, jdtLine);
				dagJDT1->SetColMoney (&zeroSum, JDT1_SYS_DEBIT, jdtLine);
				dagJDT1->SetColMoney (&zeroSum, JDT1_FC_DEBIT, jdtLine);
			}
		}


		// Set vat info
		if (!_STR_IsSpacesStr (accountsArrayRes[jdtLine]->vatGroup))
		{
			dagJDT1->SetColStr (accountsArrayRes[jdtLine]->vatGroup, JDT1_VAT_GROUP, jdtLine);
			dagJDT1->SetColMoney (&accountsArrayRes[jdtLine]->vatPrcnt, JDT1_VAT_PERCENT, jdtLine);
			dagJDT1->SetColMoney (&accountsArrayRes[jdtLine]->equVatPrcnt, JDT1_EQU_VAT_PERCENT, jdtLine);
			dagJDT1->SetColMoney (&accountsArrayRes[jdtLine]->vatBaseSum, JDT1_BASE_SUM, jdtLine);
			dagJDT1->SetColMoney (&accountsArrayRes[jdtLine]->vatBaseSC, JDT1_SYS_BASE_SUM, jdtLine);
			dagJDT1->SetColStr (VAL_YES, JDT1_VAT_LINE, jdtLine);
		}

		dagJDT1->SetColLong (accountsArrayRes[jdtLine]->lineType, JDT1_LINE_TYPE, jdtLine);

		if (!accountsArrayRes[jdtLine]->frgnSum.IsZero () && !_STR_IsSpacesStr (accountsArrayRes[jdtLine]->curCurrency))
		{
			dagJDT1->SetColStr (accountsArrayRes[jdtLine]->curCurrency, JDT1_FC_CURRENCY, jdtLine);
		}


		if (!_STR_IsSpacesStr (accountsArrayRes[jdtLine]->dueDate))
		{
			dagJDT1->SetColStr (accountsArrayRes[jdtLine]->dueDate, JDT1_DUE_DATE, jdtLine);
		}

		if (!_STR_IsSpacesStr (accountsArrayRes[jdtLine]->taxDate))
		{
			dagJDT1->SetColStr (accountsArrayRes[jdtLine]->taxDate, JDT1_TAX_DATE, jdtLine);
		}



		//////////////////////////////////////////////////////////////////////////
		// Populate additional fields of JDT1 (not appearing in SActsList)
		if(accountsArrayRes[jdtLine]->debCred == DEBIT)
		{
			dagJDT1->SetColStr (VAL_DEBIT, JDT1_DEBIT_CREDIT, jdtLine);
		}
		else
		{
			dagJDT1->SetColStr (VAL_CREDIT, JDT1_DEBIT_CREDIT, jdtLine);
		}

		if (!_STR_IsSpacesStr(accountsArrayRes[jdtLine]->refDate))
		{
			dagJDT1->SetColStr(accountsArrayRes[jdtLine]->refDate, JDT1_REF_DATE, jdtLine);

			// update valid from for ocr code
			SBOString	ocrCode;
			dagJDT1->GetColStr (ocrCode, JDT1_OCR_CODE, jdtLine);

			SBOString	validFrom;
			COverheadCostRateObject::GetValidFrom (bizEnv, ocrCode, accountsArrayRes[jdtLine]->refDate.GetString (), validFrom);

			dagJDT1->SetColStr (validFrom, JDT1_VALID_FROM, jdtLine);
		}
		if (!_STR_IsSpacesStr(accountsArrayRes[jdtLine]->vatDate))
		{
			dagJDT1->SetColStr(accountsArrayRes[jdtLine]->vatDate, JDT1_VAT_DATE, jdtLine);
		}
		if (!_STR_IsSpacesStr(accountsArrayRes[jdtLine]->ref1))
		{
			dagJDT1->SetColStr(accountsArrayRes[jdtLine]->ref1, JDT1_REF1, jdtLine);
		}
		if (!_STR_IsSpacesStr(accountsArrayRes[jdtLine]->ref2))
		{
			dagJDT1->SetColStr(accountsArrayRes[jdtLine]->ref2, JDT1_REF2, jdtLine);
		}
		if (!_STR_IsSpacesStr(accountsArrayRes[jdtLine]->refLine))
		{
			dagJDT1->SetColStr(accountsArrayRes[jdtLine]->refLine, JDT1_REF3_LINE, jdtLine);
		}
		if (!_STR_IsSpacesStr(accountsArrayRes[jdtLine]->indicator))
		{
			dagJDT1->SetColStr(accountsArrayRes[jdtLine]->indicator, JDT1_INDICATOR, jdtLine);
		}
		if (!_STR_IsSpacesStr(accountsArrayRes[jdtLine]->paymentRef))
		{
			dagJDT1->SetColStr(accountsArrayRes[jdtLine]->paymentRef, JDT1_PAYMENT_REF, jdtLine);
		}
	
		if (!_STR_IsSpacesStr(accountsArrayRes[jdtLine]->srcAbsId))
		{
			dagJDT1->SetColStr(accountsArrayRes[jdtLine]->srcAbsId, JDT1_SRC_ABS_ID, jdtLine);
		}
		if (!_STR_IsSpacesStr(accountsArrayRes[jdtLine]->srcLine))
		{
			dagJDT1->SetColStr(accountsArrayRes[jdtLine]->srcLine, JDT1_SRC_LINE, jdtLine);	
		}
		if (!_STR_IsSpacesStr(accountsArrayRes[jdtLine]->checkAbs))
		{
			dagJDT1->SetColStr(accountsArrayRes[jdtLine]->checkAbs, JDT1_CHECK_ABS, jdtLine);
		}		

		if (!_STR_IsSpacesStr(accountsArrayRes[jdtLine]->relType))
		{
			dagJDT1->SetColStr(accountsArrayRes[jdtLine]->relType, JDT1_REL_TYPE, jdtLine);
		}

		if (!_STR_IsSpacesStr(accountsArrayRes[jdtLine]->lineMemo))
		{
			dagJDT1->SetColStr(accountsArrayRes[jdtLine]->lineMemo, JDT1_LINE_MEMO, jdtLine);
		}

		if (VF_TaxPayment(bizEnv))
		{
			dagJDT1->SetColLong(accountsArrayRes[jdtLine]->com_vat, JDT1_CENVAT_COM, jdtLine);
			dagJDT1->SetColLong(accountsArrayRes[jdtLine]->mat_type, JDT1_MATERIAL_TYPE, jdtLine);
		}

		if (VF_MultipleRegistrationNumber(bizEnv) && accountsArrayRes[jdtLine]->location != 0)
		{
			dagJDT1->SetColLong(accountsArrayRes[jdtLine]->location, JDT1_LOCATION, jdtLine);
		}

		if (VF_WTaxAccumulateControl(bizEnv) && !_STR_IsSpacesStr(accountsArrayRes[jdtLine]->m_WTCode))
		{
			dagJDT1->SetColStr(accountsArrayRes[jdtLine]->m_WTCode, JDT1_WTAX_CODE, jdtLine);
		}

		if (NULL != srcObject)
		{
			bool referenceLinksBPtarget = ((_STR_strcmp (accountsArrayRes[jdtLine]->actCode, accountsArrayRes[jdtLine]->shortName) != 0)
				&& (! _STR_IsSpacesStr (accountsArrayRes[jdtLine]->shortName)));
			SBOErr ooErr = CRefLinksDef::ExecuteRefLinks (srcObject, this, (referenceLinksBPtarget) ? RLD_TYPE_BP_LINE_VAL : RLD_TYPE_LINE_VAL, jdtLine);
			if (ooErr)
			{
				return (ooErr);
			}
		}

		//Set down payment request AbsEntry.
		long dprAbsId = accountsArrayRes[jdtLine]->dprAbsId;
		if (-1 != dprAbsId)
		{
			//We only post when its value is valid, otherwise it should be NULL as default.
			dagJDT1->SetColLong (dprAbsId, JDT1_DPR_ABS_ID, jdtLine);
		}

		dagJDT1->SetColLong (accountsArrayRes[jdtLine]->interimAcctType, JDT1_INTERIM_ACCT_TYPE, jdtLine);

		if (VF_MultiBranch_EnabledInOADM (bizEnv) && 
			(
				CBusinessPlaceObject::IsValidBPLId (accountsArrayRes[jdtLine]->m_BPLId) || 
				CBusinessPlaceObject::IsValidBPLId (GetBPLId ())
			)
			)
		{
			long BPLId = CBusinessPlaceObject::IsValidBPLId (accountsArrayRes[jdtLine]->m_BPLId) ? accountsArrayRes[jdtLine]->m_BPLId : GetBPLId ();
			CBusinessPlaceObject::BPLInfo bplInfo;
			SBOErr ooErr = CBusinessPlaceObject::GetBPLInfo (bizEnv, BPLId, bplInfo);
			IF_ERROR_RETURN (ooErr);
			dagJDT1->SetColLong (bplInfo.GetBPLId (), JDT1_BPL_ID, jdtLine);
			dagJDT1->SetColStr (bplInfo.GetBPLName (), JDT1_BPL_NAME, jdtLine);
			dagJDT1->SetColStr (bplInfo.GetVatRegNum (), JDT1_VAT_REG_NUM, jdtLine);
		}
		else
		{
			dagJDT1->NullifyCol (JDT1_BPL_ID, jdtLine);
			dagJDT1->NullifyCol (JDT1_BPL_NAME, jdtLine);
			dagJDT1->NullifyCol (JDT1_VAT_REG_NUM, jdtLine);
		}

	} // for

	// Set default transaction code (FRANCE only), according to first line containing G/L account with trans. code
	if (bizEnv.IsCurrentLocalSettings(FRANCE_SETTINGS))
	{
		SBOString	glAcct, transCode1, transCode2;
		long		numOfRecs, rec, jdtLine;

		CJournalManager::GetDefaultTransCode(this, dagJDT, dagJDT1, glAcct, transCode1, jdtLine);

		if (jdtLine >= 0 && !glAcct.IsEmpty() && !transCode1.IsEmpty())
		{
			dagJDT->GetColStr (transCode2, OJDT_TRANS_CODE, 0);
			if (transCode2.IsEmpty ())
			{
				dagJDT->SetColStr (transCode1, OJDT_TRANS_CODE, 0);
				numOfRecs = dagJDT1->GetRecordCount();
				for(rec = 0 ; rec <= numOfRecs ; rec++)
				{
					dagJDT1->SetColStr (transCode1, JDT1_TRANS_CODE, rec);
				}
			}
			else
			{
				dagJDT1->SetColStr (transCode2, JDT1_TRANS_CODE, jdtLine);
			}
		}
	}

	if (!linesAdded)
	{
		return dbmNoDataFound;
	}

	return ooNoErr;
}

/************************************************************************/
/************************************************************************/
SBOErr	CTransactionJournalObject::OJDTFillAccountsFromJDT1RES (PDAG dag, long *resDagFields, AccountsArray* accountsArrayRes)
{
        _TRACER("OJDTFillAccountsFromJDT1RES");
	long				rec, numOfRecs;
	SBOString			tmpStr;
	SPaymentActsData	actStruct;
	
	numOfRecs = dag->GetRecordCount();
	for (rec=0; rec<numOfRecs; rec++)
	{
		dag->GetColStr (actStruct.actCode, resDagFields[JDT_PAYMENT_UPG_DOC_ACT_CODE], rec);
		dag->GetColStr (actStruct.shortName, resDagFields[JDT_PAYMENT_UPG_DOC_SHRT_NAME], rec);
		dag->GetColLong (&actStruct.lineType, resDagFields[JDT_PAYMENT_UPG_DOC_LINE_TYPE], rec);
		dag->GetColStr (actStruct.srcLine, resDagFields[JDT_PAYMENT_UPG_DOC_SRC_LINE], rec);
		dag->GetColStr (tmpStr, resDagFields[JDT_PAYMENT_UPG_DOC_DEBIT_CREDIT], rec);
		//Get down payment request AbsEntry only when it has valid value.
		if (!dag->IsNullCol(JDT1_DPR_ABS_ID, rec))
		{
			dag->GetColLong (&actStruct.dprAbsId, JDT1_DPR_ABS_ID, rec);
		}

		if (tmpStr == VAL_CREDIT)
		{
			actStruct.debCred = CREDIT;
			dag->GetColMoney(&actStruct.sum, resDagFields[JDT_PAYMENT_UPG_DOC_CREDIT], rec);
			dag->GetColMoney(&actStruct.frgnSum, resDagFields[JDT_PAYMENT_UPG_DOC_FC_CREDIT], rec);
			dag->GetColMoney(&actStruct.sysSum, resDagFields[JDT_PAYMENT_UPG_DOC_SYS_CREDIT], rec);
		}
		else
		{
			actStruct.debCred = DEBIT;
			dag->GetColMoney(&actStruct.sum, resDagFields[JDT_PAYMENT_UPG_DOC_DEBIT], rec);
			dag->GetColMoney(&actStruct.frgnSum, resDagFields[JDT_PAYMENT_UPG_DOC_FC_DEBIT], rec);
			dag->GetColMoney(&actStruct.sysSum, resDagFields[JDT_PAYMENT_UPG_DOC_SYS_DEBIT], rec);
		}
			
		accountsArrayRes->Add(actStruct.Clone());
	}	
	return	ooNoErr;
}

/************************************************************************/
/************************************************************************/

/************************************************************************/
/************************************************************************/
void CTransactionJournalObject::SetVatJournalEntryFlag ()						// VF_ExciseInvoice
{
	_TRACER("SetVatJournalEntryFlag");
	m_isVatJournalEntry = true;
}
/************************************************************************/
/************************************************************************/
CTaxAdaptorJournalEntry* CTransactionJournalObject::OnGetTaxAdaptor()
{
        _TRACER("OnGetTaxAdaptor");
	if(!m_taxAdaptor)
	{
		m_taxAdaptor = new CTaxAdaptorJournalEntry(this);		
	}
	return m_taxAdaptor;
}
/************************************************************************/
/************************************************************************/
SBOErr CTransactionJournalObject::CreateTax()
{
        _TRACER("CreateTax");
	CTaxAdaptorJournalEntry *taxAdaptor =  OnGetTaxAdaptor();
	if (!taxAdaptor)
	{
		return ooNoErr;
	}

	SBOErr ooErr = ooNoErr;

	if (VF_DeferredTaxInJE(GetEnv()))
	{
		ooErr = taxAdaptor->SetJEDeferredTax();
		if (ooErr)
		{
			return ooErr;
		}
	}

	PDAG dagJDT = GetDAG();
	long transId;
	dagJDT->GetColLong (&transId, OJDT_JDT_NUM);

	return taxAdaptor->Create(transId);
}
/************************************************************************/
/************************************************************************/
SBOErr CTransactionJournalObject::UpdateTax()
{
        _TRACER("UpdateTax");
	CTaxAdaptorJournalEntry *taxAdaptor =  OnGetTaxAdaptor();
	if (!taxAdaptor )
	{
		return ooNoErr;
	}
	PDAG dagJDT = GetDAG();
	long transId;
	dagJDT->GetColLong (&transId, OJDT_JDT_NUM);

	return taxAdaptor ->Update(transId);
}
/************************************************************************/
/************************************************************************/
SBOErr CTransactionJournalObject::LoadTax()
{
        _TRACER("LoadTax");
	CTaxAdaptorJournalEntry *taxAdaptor =  OnGetTaxAdaptor();
	if (!taxAdaptor)
	{
		return ooNoErr;
	}
	PDAG dagJDT = GetDAG();
	long transId;
	dagJDT->GetColLong (&transId, OJDT_JDT_NUM);

	SBOErr ooErr;	
	ooErr  = taxAdaptor->Load(transId);
	if (ooErr == dbmNoDataFound)
	{
		ooErr = ooNoErr;
	}

	return ooErr;
}

/************************************************************************/
/************************************************************************/
CJDTStornoExtraInfoCreator & CJDTStornoExtraInfoCreator::operator=(const CJDTStornoExtraInfoCreator & other)
{
	if(this == &other){
		return *this;
	}

	m_jdtBusinessObject = other.m_jdtBusinessObject;
	
	return *this;
}



/************************************************************************
Function name : OJDTSetPaymentJdtOpenBalanceSums
Description   : 
Note		  :	Enter here when coming from payment cancellation
Return type   : SBOErr  
Arguments	  : 
/************************************************************************/
SBOErr  CTransactionJournalObject::OJDTSetPaymentJdtOpenBalanceSums (CPaymentDoc *paymentObject, 
																	 PDAG dagJDT1, 
																	 long *resDagFields, 
																	 long fromOffset,
																	 bool foundCaseK)
{
        _TRACER("OJDTSetPaymentJdtOpenBalanceSums");
	PaymentAccountsArray	actsArray;
	SBOErr					sboErr = noErr;
	MONEY					tmpSC, tmpFC, tmpM;

	sboErr = CTransactionJournalObject::OJDTFillAccountsFromJDT1RES (dagJDT1, resDagFields, (AccountsArray*)&actsArray);
	if(sboErr)
	{
		return	sboErr;
	}

	//Calculate match sums of payment
	sboErr = paymentObject->CalculateSplitLinesMatchSums (&actsArray, false);
	if (sboErr)
	{
		return	sboErr;
	}

	//Set balance due of JDT to be total line - calculated match sum
	long	actsArraySize = actsArray.GetSize ();	
	long		internalMatch;
	long		multMatch;
	SBOString	closed;
	for (long ii = 0; ii < actsArraySize; ii++)
	{
		dagJDT1->GetColLong (&internalMatch, resDagFields[JDT_PAYMENT_UPG_DOC_INTR_MATCH], fromOffset+ii);
		dagJDT1->GetColLong (&multMatch, resDagFields[JDT_PAYMENT_UPG_DOC_MULT_MATCH], fromOffset+ii);
		dagJDT1->GetColStr (closed, resDagFields[JDT_PAYMENT_UPG_DOC_CLOSED], fromOffset+ii);
		
		// we don't want to update the balance due of reconciled/closed lines
		if (((internalMatch != 0) && (!foundCaseK)) || (multMatch != 0) || (closed == VAL_YES))
		{
			continue;
		}

		if (actsArray[ii]->GetMatchTotalLineFlag ())
		{
			tmpM = actsArray[ii]->sum;
			tmpFC = actsArray[ii]->frgnSum;
			tmpSC = actsArray[ii]->sysSum;
		}			
		else
		{
			if (actsArray[ii]->debCred == CREDIT)
			{
				dagJDT1->GetColMoney (&tmpM,  resDagFields[JDT_PAYMENT_UPG_DOC_BALANCE_DUE_CREDIT], fromOffset+ii);
				dagJDT1->GetColMoney (&tmpFC, resDagFields[JDT_PAYMENT_UPG_DOC_BALANCE_DUE_FC_CRED], fromOffset+ii);
				dagJDT1->GetColMoney (&tmpSC, resDagFields[JDT_PAYMENT_UPG_DOC_BALANCE_DUE_SC_CRED], fromOffset+ii);
			}
			else
			{
				dagJDT1->GetColMoney (&tmpM, resDagFields[JDT_PAYMENT_UPG_DOC_BALANCE_DUE_DEBIT], fromOffset+ii);
				dagJDT1->GetColMoney (&tmpFC, resDagFields[JDT_PAYMENT_UPG_DOC_BALANCE_DUE_FC_DEB], fromOffset+ii);
				dagJDT1->GetColMoney (&tmpSC, resDagFields[JDT_PAYMENT_UPG_DOC_BALANCE_DUE_SC_DEB], fromOffset+ii);
			}
		}

		tmpM += actsArray[ii]->GetMatchSum ();
		tmpFC += actsArray[ii]->GetMatchSumFC ();
		tmpSC += actsArray[ii]->GetMatchSumSC ();
		
		if (actsArray[ii]->debCred == CREDIT)
		{
			dagJDT1->SetColMoney (&tmpM,  resDagFields[JDT_PAYMENT_UPG_DOC_BALANCE_DUE_CREDIT], fromOffset+ii);
			dagJDT1->SetColMoney (&tmpFC, resDagFields[JDT_PAYMENT_UPG_DOC_BALANCE_DUE_FC_CRED], fromOffset+ii);
			dagJDT1->SetColMoney (&tmpSC, resDagFields[JDT_PAYMENT_UPG_DOC_BALANCE_DUE_SC_CRED], fromOffset+ii);
		}
		else
		{
			dagJDT1->SetColMoney (&tmpM, resDagFields[JDT_PAYMENT_UPG_DOC_BALANCE_DUE_DEBIT], fromOffset+ii);
			dagJDT1->SetColMoney (&tmpFC, resDagFields[JDT_PAYMENT_UPG_DOC_BALANCE_DUE_FC_DEB], fromOffset+ii);
			dagJDT1->SetColMoney (&tmpSC, resDagFields[JDT_PAYMENT_UPG_DOC_BALANCE_DUE_SC_DEB], fromOffset+ii);
		}
	}

	return noErr;
}

/************************************************************************/
/************************************************************************/
SBOErr	CTransactionJournalObject::UpgradeOJDTCreatedByForWOR ()
{
        _TRACER("UpgradeOJDTCreatedByForWOR");
	SBOErr			sboErr = noErr;
	CBizEnv			&bizEnv = GetEnv ();
	PDAG			dagRes, dagJDT	= GetDAG(), dagQuery = GetDAG(CRD);
	DBD_CondStruct	join[2];
	DBD_ResStruct	resStruct[2];
	DBD_SortStruct	sortStruct[1];

	dagQuery->GetDBDParams()->Clear ();

	// Select
	resStruct[0].tableIndex	= 0;
	resStruct[0].colNum = OWOR_NUM;
	resStruct[0].group_by = true;

	resStruct[1].tableIndex	= 0;
	resStruct[1].colNum = OWOR_ABS_ENTRY;
	resStruct[1].agreg_type = DBD_MAX;

	// Tables
	DBD_TablesList	tablePtr;
	DBD_CondTables &tables = dagQuery->GetDBDParams ()->GetCondTables();

	tablePtr = &tables.AddTable ();
	tablePtr->tableCode = bizEnv.ObjectToTable(WOR);
	tablePtr = &tables.AddTable ();
	tablePtr->tableCode = bizEnv.ObjectToTable(JDT);

	//*** Join
	tablePtr->doJoin	 = true;
	tablePtr->joinedToTable = 0;
	tablePtr->numOfConds	= 2;
	tablePtr->joinConds = join;

	join[0].compareCols		= true;
	join[0].compColNum		= OWOR_NUM;
	join[0].compTableIndex	= 0;
	join[0].colNum			= OJDT_CREATED_BY;
	join[0].tableIndex		= 1;
	join[0].operation		= DBD_EQ;
	join[0].relationship	= DBD_AND;

	join[1].compareCols		= false;
	join[1].colNum			= OJDT_TRANS_TYPE;
	join[1].tableIndex		= 1;
	join[1].operation		= DBD_EQ;
	join[1].condVal			= WOR;
	join[1].relationship	= 0;

	DBD_SetDAGRes (dagQuery, resStruct, 2);

	sortStruct[0].colNum = OWOR_NUM;
	DBD_SetDAGSort (dagQuery, sortStruct, 1);

	sboErr = DBD_GetInNewFormat (dagQuery, &dagRes);
	if (sboErr)
	{
		return (sboErr == dbmNoDataFound) ? ooNoErr : sboErr;
	}

	DBD_Conditions &conds = dagJDT->GetDBDParams ()->GetConditions ();
	PDBD_Cond		cond;

	cond = &conds.AddCondition ();
	cond->colNum		= OJDT_TRANS_TYPE;
	cond->operation		= DBD_EQ;
	cond->condVal		= WOR;
	cond->relationship	= 0;

	sboErr = dagJDT->GetFirstChunk(UPG_OJDT_CREATED_BY_CHUNK_SIZE);
	if (sboErr)
	{
		return sboErr;
	}

	while(sboErr == noErr)
	{
		long oldBaseNum, newBaseNum, numOfDoc1Recs = dagJDT->GetRecordCount ();
		for (long rec=0 ; rec < numOfDoc1Recs ; rec++)
		{
			dagJDT->GetColLong (&oldBaseNum, OJDT_CREATED_BY, rec);
			newBaseNum = GetBaseEntry (dagRes, oldBaseNum);
			if (newBaseNum < 0)
			{
				continue;
			}
			dagJDT->SetColLong (newBaseNum, OJDT_CREATED_BY, rec);
		}

		sboErr = dagJDT->UpdateAll ();
		if (sboErr)
		{
			break;
		}

		sboErr = dagJDT->GetNextChunk(UPG_OJDT_CREATED_BY_CHUNK_SIZE);
	}

	if(sboErr == dbmNoDataFound)
	{
		sboErr = noErr;
	}

	return sboErr;
}

/************************************************************************/
/************************************************************************/
long	CTransactionJournalObject::GetBaseEntry (PDAG dagRes, long docNum)
{
        _TRACER("GetBaseEntry");
	long	start, end, mid, result, numOfRecs;
	long	DagDocNum;

	start = 0;
	DAG_GetCount (dagRes, &numOfRecs);
	if (!numOfRecs)
	{
		return -1;
	}
	end = numOfRecs - 1;

	do
	{
		mid = (start + end + 1) / 2;
		dagRes->GetColLong (&DagDocNum, 0, mid);
		if (docNum == DagDocNum)
		{
			dagRes->GetColLong (&result, 1, mid);
			return result;
		}
		else if (docNum > DagDocNum)
	{
			start = mid + 1;
		}
		else
		{
			end = mid - 1;
		}
	}
	while (start <= end);

	return -1;
}
/************************************************************************/
/************************************************************************/
SBOErr	CTransactionJournalObject::SetDebitCreditField ()
{
        _TRACER("SetDebitCreditField");
	PDAG	dagJDT1;
	long	rec, numOfRecs;
	MONEY	debAmount, credAmount;

	dagJDT1 = GetDAG(JDT,ao_Arr1);

	DAG_GetCount (dagJDT1, &numOfRecs);
	for (rec = 0; rec < numOfRecs; rec++)
	{
		if (dagJDT1->IsNullCol (JDT1_DEBIT_CREDIT, rec))
		{
			dagJDT1->GetColMoney (&debAmount, JDT1_DEBIT, rec, DBM_NOT_ARRAY);
			if (!debAmount.IsZero())
			{
				dagJDT1->SetColStr(VAL_DEBIT, JDT1_DEBIT_CREDIT, rec);
				continue;
			}
			dagJDT1->GetColMoney (&credAmount, JDT1_CREDIT, rec, DBM_NOT_ARRAY);
			if (!credAmount.IsZero())
			{
				dagJDT1->SetColStr(VAL_CREDIT, JDT1_DEBIT_CREDIT, rec);
				continue;
			}

			dagJDT1->GetColMoney (&debAmount, JDT1_SYS_DEBIT, rec, DBM_NOT_ARRAY);
			if (!debAmount.IsZero())
			{
				dagJDT1->SetColStr(VAL_DEBIT, JDT1_DEBIT_CREDIT, rec);
				continue;
			}
			dagJDT1->GetColMoney (&credAmount, JDT1_SYS_CREDIT, rec, DBM_NOT_ARRAY);
			if (!credAmount.IsZero())
			{
				dagJDT1->SetColStr(VAL_CREDIT, JDT1_DEBIT_CREDIT, rec);
				continue;
			}

			dagJDT1->GetColMoney (&debAmount, JDT1_FC_DEBIT, rec, DBM_NOT_ARRAY);
			if (!debAmount.IsZero())
			{
				dagJDT1->SetColStr(VAL_DEBIT, JDT1_DEBIT_CREDIT, rec);
				continue;
			}
			dagJDT1->GetColMoney (&credAmount, JDT1_FC_CREDIT, rec, DBM_NOT_ARRAY);
			if (!credAmount.IsZero())
			{
				dagJDT1->SetColStr(VAL_CREDIT, JDT1_DEBIT_CREDIT, rec);
				continue;
			}

			dagJDT1->GetColMoney (&debAmount, JDT1_BALANCE_DUE_DEBIT, rec, DBM_NOT_ARRAY);
			if (!debAmount.IsZero())
			{
				dagJDT1->SetColStr(VAL_DEBIT, JDT1_DEBIT_CREDIT, rec);
				continue;
			}

			dagJDT1->GetColMoney (&credAmount, JDT1_BALANCE_DUE_CREDIT, rec, DBM_NOT_ARRAY);
			if (!credAmount.IsZero())
			{
				dagJDT1->SetColStr(VAL_CREDIT, JDT1_DEBIT_CREDIT, rec);
				continue;
			}

			dagJDT1->GetColMoney (&debAmount, JDT1_BALANCE_DUE_FC_DEB, rec, DBM_NOT_ARRAY);
			if (!debAmount.IsZero())
			{
				dagJDT1->SetColStr(VAL_DEBIT, JDT1_DEBIT_CREDIT, rec);
				continue;
			}

			dagJDT1->GetColMoney (&credAmount, JDT1_BALANCE_DUE_FC_CRED, rec, DBM_NOT_ARRAY);
			if (!credAmount.IsZero())
			{
				dagJDT1->SetColStr(VAL_CREDIT, JDT1_DEBIT_CREDIT, rec);
				continue;
			}

			dagJDT1->GetColMoney (&debAmount, JDT1_BALANCE_DUE_SC_DEB, rec, DBM_NOT_ARRAY);
			if (!debAmount.IsZero())
			{
				dagJDT1->SetColStr(VAL_DEBIT, JDT1_DEBIT_CREDIT, rec);
				continue;
			}

			dagJDT1->GetColMoney (&credAmount, JDT1_BALANCE_DUE_SC_CRED, rec, DBM_NOT_ARRAY);
			if (!credAmount.IsZero())
			{
				dagJDT1->SetColStr(VAL_CREDIT, JDT1_DEBIT_CREDIT, rec);
				continue;
			}
		}
	}

	return ooNoErr;
}

/************************************************************************/
/************************************************************************/
SBOErr	CTransactionJournalObject::UpgradeOJDTWithFolio()
{
        _TRACER("UpgradeOJDTWithFolio");
	PDAG			dagJDT = NULL, dagJDT1 = NULL, dagFolioRes;	
	PDBD_Cond		cond;
	DBD_TablesList	table;	
	DBD_ResStruct	folioResStruct[2];
	long			folioCol, prefCol, numOfRecs, rec, curTransType, curCreatedBy, curTransId;
	SBOString		curFolioNum, curPrefix;
	SBOErr			ooErr = noErr;
	CBizEnv&		bizEnv = GetEnv();

	dagJDT1 = GetArrayDAG (ao_Arr1);
	dagJDT = GetDAG ();

	// get OJDT records in chunks and update the folio number where needed

	ooErr = dagJDT->GetFirstChunk (UPG_OJDT_FOLIO_CHUNK_SIZE);

	while(ooErr == noErr)
	{
		numOfRecs = dagJDT->GetRealSize(dbmDataBuffer);
		for(rec = 0; rec < numOfRecs; rec++)
		{
			dagJDT->GetColLong (&curTransId, OJDT_JDT_NUM, rec);
			dagJDT->GetColLong (&curTransType, OJDT_TRANS_TYPE, rec);
			dagJDT->GetColLong (&curCreatedBy, OJDT_CREATED_BY, rec);

			// get folio number only for transactions related to relevant documents 
			switch(curTransType)
			{
			case DLN:
			case RDN:
			case INV:
			case RIN:
			case DPI:
			case DPO:
			case PDN:
			case RPD:
			case PCH:
			case RPC:
			case IGN:
			case IGE:
			case WTR:
				prefCol = OINV_FOLIO_PREFIX;
				folioCol = OINV_FOLIO_NUMBER;
				break;
			case BOE:
				prefCol = OBOE_FOLIO_PREFIX;
				folioCol = OBOE_FOLIO_NUMBER;
				break;
			default:
				continue;
			}

			// build folio number query: select FOLIO_NUMBER, FOLIO_PREFIX from 'current trans type' where ABS_ENTRY = 'current base ref'		

			folioResStruct[0].tableIndex = 0;
			folioResStruct[0].colNum = prefCol;

			folioResStruct[1].tableIndex = 0;
			folioResStruct[1].colNum = folioCol;

			DBD_CondTables &tables = dagJDT1->GetDBDParams ()->GetCondTables ();
			tables.Clear();
			table = &tables.AddTable ();
			table->tableCode = bizEnv.ObjectToTable (curTransType);

			DBD_Conditions	&conditions = dagJDT1->GetDBDParams ()->GetConditions();
			conditions.Clear();
			cond = &conditions.AddCondition();
			cond->colNum = OINV_ABS_ENTRY; //== OBOE_BOE_ABS
			cond->tableIndex = 0;
			cond->operation = DBD_EQ;
			cond->condVal = curCreatedBy;

			DBD_SetDAGRes (dagJDT1, folioResStruct, 2);
			ooErr = DBD_GetInNewFormat (dagJDT1, &dagFolioRes);
			if(ooErr)
			{
				if (ooErr == dbmNoDataFound)
				{
					ooErr = noErr;
					continue;
				}

				return ooErr;
			}

			// update folio number in current transaction			
			dagFolioRes->GetColStr (curPrefix, 0);
			dagFolioRes->GetColStr (curFolioNum, 1);
			dagJDT->SetColStr (curPrefix, OJDT_FOLIO_PREFIX, rec);
			dagJDT->SetColStr (curFolioNum, OJDT_FOLIO_NUMBER, rec);
		}
		// update all records in current chunk with folio number
		ooErr = dagJDT->UpdateAll();
		if(ooErr)
		{
			return ooErr;
		}

		ooErr = dagJDT->GetNextChunk(UPG_OJDT_FOLIO_CHUNK_SIZE);
	}

	if(ooErr == dbmNoDataFound)
	{
		ooErr = noErr;
	}

	return ooErr;
}

/************************************************************************************/
/************************************************************************************/
SBOErr	CTransactionJournalObject::OnInitFlow ()
{
        _TRACER("OnInitFlow");
	CBizEnv &bizEnv = GetEnv ();

	bizEnv.AddCache (ACT);
	bizEnv.AddCache (CRD);

	return ooNoErr;
}
/************************************************************************************/
/************************************************************************************/
SBOErr	CTransactionJournalObject::CancelJournalEntryInObject (SBOString& objectId, SBOString postingDate/*=EMPTY_STR*/, SBOString taxDate/*=EMPTY_STR*/, SBOString dueDate/*=EMPTY_STR*/)
{
        _TRACER("CancelJournalEntryInObject");
	SBOString		cancelDate, sysDate, jdtNum;
	SBOErr			ooErr;

	PDAG dagOBJ = GetDAG (objectId.GetBuffer ());

	long colNum = dagOBJ->GetColumnByType (CREATED_JDT_NUM_FLD);
	if (colNum < 0)
	{
		colNum = dagOBJ->GetColumnByType (TRANS_ABS_ENT_FLD);
	}
	dagOBJ->GetColStr (jdtNum, colNum);	
	
	ooErr = GetByKey (jdtNum, OJDT_KEYNUM_PRIMARY);
	if (ooErr && ooErr!=dbmNoDataFound && ooErr!= dbmArrayRecordNotFound)
	{
		return	ooErr;
	}

	PDAG	dagJDT = GetDAG ();
	PDAG	dagJDT1 = GetArrayDAG (ao_Arr1);

	//Retrieve lines according to orig. JDT
	ooErr = DBD_GetKeyGroup (dagJDT1, JDT1_KEYNUM_PRIMARY, jdtNum, TRUE);
	if (ooErr)
	{
		return (ooErr);
	}

	CBizEnv&	bizEnv = GetEnv();
	DBM_DATE_Get (sysDate, bizEnv);

	//Get posting date
	long dateColNum = dagOBJ->GetColumnByType (DATE_FLD);
	if (postingDate.IsSpacesStr())
	{
		if (dateColNum > 0)
		{
			dagOBJ->GetColStr (postingDate, dateColNum, 0);

			//Set JE cancel date to be Creation date. it will be run over later if necessary.
			dagJDT->SetColStr (postingDate, OJDT_STORNO_DATE);
		}
		else
		{
			// shouldn't get here - but if we did take the system date
			postingDate = sysDate;
		}
	}

	long cancelMode = JE_CANCEL_DATE_FUTURE;

	if (postingDate.strtol() < sysDate.strtol())
	{
		if (GetExCommand2 () & ooEx2SetCurrentRefDate)
		{
			cancelMode = JE_CANCEL_DATE_SYSTEM;
		}
		else
		{
			cancelMode = JE_CANCEL_DATE_ORIGINAL;
		}
	}

	if (GetExCommand2 () & ooEx2SetCurrentRefDate)
	{
		// Set canceled date as System Date
		cancelDate = sysDate;
	}
	else
	{
		// Set canceled date as Posting Date
		cancelDate = postingDate;
	}

	if (sysDate.strtol() < postingDate.strtol())
	{		
		cancelDate = postingDate;
	}
	if (taxDate.IsSpacesStr())
	{
		taxDate = cancelDate;
	}

	//If future posting date - make the reference date same as the posting date
	SetJECancelDate (bizEnv, cancelDate, dagOBJ, dagJDT, dagJDT1, taxDate, dueDate, cancelMode, sysDate);

	//set default series by date
	// VF_MultiBranch_EnabledInOADM
	long series = bizEnv.GetDefaultSeriesByDate (dagJDT1->GetColStr (JDT1_BPL_ID, 0, coreSystemDefault).strtol (), SBOString (JDT), cancelDate);
	dagJDT->SetColLong (series, OJDT_SERIES);

	ooErr = DoSingleStorno ();

	return ooErr;
}
//*******************************************************************
// SetJECancelDate
//*******************************************************************
void CTransactionJournalObject::SetJECancelDate (CBizEnv& bizEnv, const SBOString& sCancelDate, PDAG dagOBJ, PDAG dagJDT, PDAG dagJDT1, const SBOString& taxDate, 
												 const SBOString& dueDate, long cancelMode, const SBOString& sysDate)

{
	//Set cancel date for JDT and JDT1
	_TRACER("SetJECancelDate");
	long objType;
	dagJDT->GetColLong (&objType, OJDT_TRANS_TYPE);

	bool isPayment = RCT == objType || VPM == objType;
	bool useFutureCancelMode = !isPayment;

	dagJDT->SetColStr (sCancelDate, OJDT_REF_DATE);
	dagJDT->SetColStr (taxDate, OJDT_TAX_DATE);
	if (useFutureCancelMode)
	{
		if (dueDate.IsSpacesStr())
		{
			dagJDT->SetColStr (sCancelDate, OJDT_DUE_DATE);
		}
		else
		{
			dagJDT->SetColStr (dueDate, OJDT_DUE_DATE);
		}
	}
	else
	{
		if (JE_CANCEL_DATE_SYSTEM == cancelMode)
		{
			dagJDT->SetColStr (sysDate, OJDT_DUE_DATE);
		}
	}
	dagJDT->SetColStr (sCancelDate, OJDT_STORNO_DATE);

	long jdt1RecCount = dagJDT1->GetRecordCount();
	for (long row = 0; row < jdt1RecCount; row++)
	{
		// set valid from for profit code
		SBOString	ocrCode;
		dagJDT1->GetColStr (ocrCode, JDT1_OCR_CODE, row);

		SBOString	validFrom;
		COverheadCostRateObject::GetValidFrom (bizEnv, ocrCode, sCancelDate, validFrom);
		dagJDT1->SetColStr (validFrom, JDT1_VALID_FROM, row);

		if (useFutureCancelMode)
		{
			dagJDT1->SetColStr (taxDate, JDT1_TAX_DATE, row);
			dagJDT1->SetColStr (sCancelDate, JDT1_REF_DATE, row);

			if (dueDate.IsSpacesStr())
			{
				dagJDT1->SetColStr (sCancelDate, JDT1_DUE_DATE, row);
			}
			else
			{
				dagJDT1->SetColStr (dueDate, JDT1_DUE_DATE, row);
			}
		}
		else
		{
			if (JE_CANCEL_DATE_SYSTEM == cancelMode)
			{
				dagJDT1->SetColStr (sysDate, JDT1_DUE_DATE, row);
				dagJDT1->SetColStr (sysDate, JDT1_REF_DATE, row);
				dagJDT1->SetColStr (sysDate, JDT1_TAX_DATE, row);
			}
			// else keep the original dates
		}
	}

	dagOBJ->SetStrByColType (sCancelDate, CANCELLATION_DATE_FLD);
}


/************************************************************************************/
// If OJDT.CreateDate is NULL and (TransType = 20 or TransType = 21) then set CreateDate 
// of the nearest transaction.
/************************************************************************************/
SBOErr CTransactionJournalObject::UpgradeJDTCreateDate ()
{
        _TRACER("UpgradeJDTCreateDate");
	SBOErr			ooErr;
	PDAG			dagRES1, dagRES2, dagJDT;
	DBD_ResStruct	resStruct[2];
	DBD_Conditions	*conditions;
	PDBD_Cond		cond;
	DBD_Params		subParamsPDN, subParamsRPD;	
	DBD_ResStruct	subResStructPDN[1], subResStructRPD[1];
	DBD_Tables		subTableStructPDN[1], subTableStructRPD[1];
	DBD_CondStruct	subCondPDN[1], subCondRPD[1];
	DBD_SortStruct	sort[1];

	dagJDT = GetDAG ();

	//	First query finds all records with TransType = (20 or 21) and CreateDate = NULL.
	//	The sub queries make sure the transaction is an outcome of closing a document and not creating one.

	resStruct[0].colNum = OJDT_JDT_NUM;
	resStruct[0].agreg_type = 0;
	DBD_SetDAGRes (dagJDT, resStruct, 1);

	conditions = &dagJDT->GetDBDParams ()->GetConditions ();
	cond = &conditions->AddCondition ();
	cond->colNum		= OJDT_CREATE_DATE;
	cond->operation		= DBD_IS_NULL;
	cond->relationship	= DBD_AND;

	cond = &conditions->AddCondition ();
	cond->bracketOpen	= 2;
	cond->colNum		= OJDT_TRANS_TYPE;
	cond->operation		= DBD_EQ;
	cond->condVal		= PDN;
	cond->relationship	= DBD_AND;

	cond = &conditions->AddCondition ();
	UpgradeCreateDateSubQuery (&subParamsPDN, subResStructPDN, subTableStructPDN, subCondPDN, PDN);
	cond->SetSubQueryParams (&subParamsPDN);
	cond->tableIndex	= DBD_NO_TABLE;
	cond->operation		= DBD_NOT_EXISTS;
	cond->bracketClose	= 1;
	cond->relationship	= DBD_OR;

	cond = &conditions->AddCondition ();
	cond->bracketOpen	= 1;
	cond->colNum		= OJDT_TRANS_TYPE;
	cond->operation		= DBD_EQ;
	cond->condVal		= RPD;
	cond->relationship	= DBD_AND;

	cond = &conditions->AddCondition ();
	UpgradeCreateDateSubQuery (&subParamsRPD, subResStructRPD, subTableStructRPD, subCondRPD, RPD);
	cond->SetSubQueryParams (&subParamsRPD);
	cond->tableIndex	= DBD_NO_TABLE;
	cond->operation		= DBD_NOT_EXISTS;
	cond->bracketClose	= 2;
	cond->relationship	= 0;

	sort[0].colNum = OJDT_JDT_NUM;
	DBD_SetDAGSort (dagJDT, sort, 1);
	/*
	SELECT T0.[TransId] 
	FROM [dbo].[OJDT] T0 
	WHERE T0.[CreateDate] IS NULL AND  
	((T0.[TransType] = (N'20') AND NOT EXISTS (SELECT U0.[DocEntry] FROM [dbo].[OPDN] U0 WHERE T0.[TransId] = U0.[TransId])) OR
	(T0.[TransType] = (N'21') AND NOT EXISTS (SELECT U0.[DocEntry] FROM [dbo].[ORPD] U0  WHERE T0.[TransId] = U0.[TransId])))
	ORDER BY T0.[TransId]
	*/
	ooErr = DBD_GetInNewFormat (dagJDT, &dagRES1);
	if (ooErr)
	{
		if (ooErr == dbmNoDataFound)
		{
			ooErr = noErr;
		}
		return ooErr;
	}

	dagRES1->Detach();

	//	Second query gets the maximum TransId for each date in OJDT.

	resStruct[0].colNum = OJDT_JDT_NUM;
	resStruct[0].agreg_type = DBD_MAX;
	resStruct[1].colNum = OJDT_CREATE_DATE;
	resStruct[1].group_by = true;
	DBD_SetDAGRes (dagJDT, resStruct, 2);

	conditions = &dagJDT->GetDBDParams ()->GetConditions ();
	cond = &conditions->AddCondition ();
	cond->colNum		= OJDT_CREATE_DATE;
	cond->operation		= DBD_NOT_NULL;
	cond->relationship	= 0;
	/*
	SELECT MAX(T0.[TransId]), T0.[CreateDate] 
	FROM [dbo].[OJDT] T0 
	WHERE T0.[CreateDate] IS NOT NULL    
	GROUP BY T0.[CreateDate]
	*/
	ooErr = DBD_GetInNewFormat (dagJDT, &dagRES2);
	if (ooErr)
	{
		dagRES1->Close ();
		if (ooErr == dbmNoDataFound)
		{
			ooErr = noErr;
		}
		return ooErr;
	}

	// sort the DAG by the column "MAX(TransID)"
	long cols[1]	= {0};
	bool oreder[1]	= {false};
	dagRES2->SortByCols (cols, oreder, 1, false, false);

	//	For each TransID in RES1 find the minimum TransID in RES2 which is larger than the TransID in RES1.
	//	Take the Create date related to the TransID found in RES2 and set it to the record of the TransID form RES1.

	long			numOfRecsRES1, numOfRecsRES2, updateTransNum, transOfNewDateInRES2, jj=0;
	DBD_UpdStruct	updStruct[1];

	updStruct[0].colNum = OJDT_CREATE_DATE;

	numOfRecsRES1 = dagRES1->GetRecordCount ();
	numOfRecsRES2 = dagRES2->GetRecordCount ();

	for (long ii = 0; ii < numOfRecsRES1; ii++)
	{
		dagRES1->GetColLong (&updateTransNum, RES1_TRANS_ABS, ii);

		while (jj < numOfRecsRES2)
		{
			dagRES2->GetColLong (&transOfNewDateInRES2, RES2_TRANS_ABS, jj);
			if (updateTransNum < transOfNewDateInRES2)
			{
				conditions = &dagJDT->GetDBDParams ()->GetConditions ();
				cond = &conditions->AddCondition ();
				cond->colNum		= OJDT_JDT_NUM;
				cond->operation		= DBD_EQ;
				cond->condVal		= SBOString (updateTransNum);
				cond->relationship	= 0;

				dagRES2->GetColStr (updStruct[0].updateVal, RES2_CREATEDATE, jj);

				DBD_SetDAGUpd (dagJDT, updStruct, 1);

				ooErr = DBD_UpdateCols (dagJDT);
				if (ooErr)
				{
					dagRES1->Close ();
					return ooErr;
				}
				break;
			}

			jj++;
		}
	}

	dagRES1->Close ();
	return noErr;
}

/************************************************************************************/
/************************************************************************************/
// The query is : (SELECT U0.[DocEntry] FROM [dbo].[OPDN] U0 WHERE T0.[TransId] = U0.[TransId]))
void CTransactionJournalObject::UpgradeCreateDateSubQuery (PDBD_Params subParams, PDBD_Res subResStruct, 
							DBD_Tables *subTableStruct, PDBD_Cond subCond, long objectID)
{
        _TRACER("UpgradeCreateDateSubQuery");
	CBizEnv	&bizEnv = GetEnv ();
	bool	isPDN = (objectID == PDN);

	_STR_strcpy (subTableStruct[0].tableCode, bizEnv.ObjectToTable (isPDN ? PDN : RPD));

	subResStruct[0].colNum = isPDN ? OPDN_ABS_ENTRY : ORPD_ABS_ENTRY;
	subResStruct[0].tableIndex = 0;

	subCond[0].compareCols = TRUE;
	subCond[0].tableIndex = 0;
	subCond[0].colNum = OJDT_JDT_NUM;
	subCond[0].compColNum = isPDN ? OPDN_TRANS_NUM : ORPD_TRANS_NUM;
	subCond[0].operation = DBD_EQ;
	subCond[0].origTableIndex = 0;
	subCond[0].origTableLevel = 1; 
	subCond[0].relationship = 0;

	DBD_SetParamTablesList (subParams, subTableStruct, 1);
	DBD_SetCond (subParams, subCond, 1);
	DBD_SetRes (subParams, subResStruct, 1);
}

/************************************************************************************/
/************************************************************************************/
/* If a Deposit was canceled from Journal Entry window (old bug), then do:
1. TransType is changed from DPS to JDT.
2. CreatedBy gets TransID of the transaction itself.
3. BaseRef gets Number of the transaction itself. */
SBOErr CTransactionJournalObject::UpgradeJDTCanceledDeposit ()
{
        _TRACER("UpgradeJDTCanceledDeposit");
	SBOErr			ooErr;
	DBD_ResStruct	resStruct[2];
	DBD_Conditions	*conditions;
	PDBD_Cond		cond;
	DBD_Params		subParams;	
	DBD_ResStruct	subResStruct[1];
	DBD_Tables		subTableStruct[1];
	DBD_CondStruct	subCond[1];
	PDAG			dagJDT, dagJDT1, dagRES;

	dagJDT = GetDAG ();
	dagJDT1 = GetDAG (JDT, ao_Arr1);

	resStruct[0].colNum = OJDT_JDT_NUM;
	resStruct[1].colNum = OJDT_NUMBER;
	DBD_SetDAGRes (dagJDT, resStruct, 2);

	conditions = &dagJDT->GetDBDParams ()->GetConditions ();

	cond = &conditions->AddCondition ();
	cond->colNum		= OJDT_TRANS_TYPE;
	cond->operation		= DBD_EQ;
	cond->condVal		= SBOString (DPS);
	cond->relationship	= DBD_AND;

	// subQuery
	_STR_strcpy (subTableStruct[0].tableCode, GetEnv ().ObjectToTable (DPS));

	subResStruct[0].colNum = ODPS_ABS_ENT;
	subResStruct[0].tableIndex = 0;

	subCond[0].compareCols = TRUE;
	subCond[0].tableIndex = 0;
	subCond[0].colNum = OJDT_JDT_NUM;
	subCond[0].compColNum = ODPS_TRANS_ABS;
	subCond[0].operation = DBD_EQ;
	subCond[0].origTableIndex = 0;
	subCond[0].origTableLevel = 1; 
	subCond[0].relationship = 0;

	DBD_SetParamTablesList (&subParams, subTableStruct, 1);
	DBD_SetCond (&subParams, subCond, 1);
	DBD_SetRes (&subParams, subResStruct, 1);

	cond = &conditions->AddCondition ();
	cond->SetSubQueryParams (&subParams);
	cond->tableIndex	= DBD_NO_TABLE;
	cond->operation		= DBD_NOT_EXISTS;
	cond->relationship	= 0;

	/*	SELECT T0.[TransId], T0.[Number] FROM [dbo].[OJDT] T0 WHERE T0.[TransType] = (N'25')
	AND NOT EXISTS (SELECT U0.[DeposId] FROM [dbo].[ODPS] U0 WHERE T0.[TransId] = U0.[TransAbs])*/
	ooErr = DBD_GetInNewFormat (dagJDT, &dagRES);
	if (ooErr)
	{
		if (ooErr == dbmNoDataFound)
		{
			ooErr = noErr;
		}
		return ooErr;
	}

	// Update
	DBD_UpdStruct	updStructJDT[3], updStructJDT1[3];

	updStructJDT[0].colNum = OJDT_TRANS_TYPE;
	updStructJDT[1].colNum = OJDT_CREATED_BY;
	updStructJDT[2].colNum = OJDT_BASE_REF;

	updStructJDT1[0].colNum = JDT1_TRANS_TYPE;
	updStructJDT1[1].colNum = JDT1_CREATED_BY;
	updStructJDT1[2].colNum = JDT1_BASE_REF;

	updStructJDT[0].updateVal = SBOString (JDT);
	updStructJDT1[0].updateVal = SBOString (JDT);

	long numOfRecs = dagRES->GetRecordCount ();

	for (long ii=0; ii<numOfRecs; ii++)
	{
		conditions = &dagJDT->GetDBDParams ()->GetConditions ();
		cond = &conditions->AddCondition ();
		cond->colNum		= OJDT_JDT_NUM;
		cond->operation		= DBD_EQ;
		dagRES->GetColStr	(cond->condVal, RES_TRANS_ABS_UPGRADE_DPS, ii);
		cond->relationship	= 0;

		dagRES->GetColStr (updStructJDT[1].updateVal, RES_TRANS_ABS_UPGRADE_DPS, ii);
		dagRES->GetColStr (updStructJDT[2].updateVal, RES_NUMBER_UPGRADE_DPS, ii);

		DBD_SetDAGUpd (dagJDT, updStructJDT, 3);

		ooErr = DBD_UpdateCols (dagJDT);
		if (ooErr)
		{
			return ooErr;
		}

		conditions = &dagJDT1->GetDBDParams ()->GetConditions ();
		cond = &conditions->AddCondition ();
		cond->colNum		= JDT1_TRANS_ABS;
		cond->operation		= DBD_EQ;
		dagRES->GetColStr	(cond->condVal, RES_TRANS_ABS_UPGRADE_DPS, ii);
		cond->relationship	= 0;

		dagRES->GetColStr (updStructJDT1[1].updateVal, RES_TRANS_ABS_UPGRADE_DPS, ii);
		dagRES->GetColStr (updStructJDT1[2].updateVal, RES_NUMBER_UPGRADE_DPS, ii);

		DBD_SetDAGUpd (dagJDT1, updStructJDT1, 3);

		ooErr = DBD_UpdateCols (dagJDT1);
		if (ooErr)
		{
			return ooErr;
		}
	}

	return noErr;
}

/************************************************************************************/
/************************************************************************************/
/*	Upgrade JDT1.VatLine to 'N' for JDT1s which are auto vat manual JEs that
	have VatLine = Y although no VatGroup is defined:

	UPDATE T1 SET T1.[VatLine] = 'N'
	FROM JDT1 T1
	WHERE T1.[VatLine] = 'Y' AND (T1.[VatGroup] Is Null OR T1.[VatGroup] = '')
	AND
	EXISTS	(
	SELECT U0.TransId
	FROM OJDT U0
	WHERE U0.TransId = T1.TransId AND U0.[AutoVAT] = 'N' AND (U0.[TransType] = '-4' OR U0.[TransType] = '30')
)
*/
SBOErr CTransactionJournalObject::UpgradeJDT1VatLineToNo ()
{
	SBOErr			sboErr = noErr;
	CBizEnv			&bizEnv = GetEnv ();
	DBD_Params		subQueryParams[1];
	DBD_ResStruct	subQueryRES[1];
	DBD_Tables		tableStruct[1], subQueryTableStruct[1];
	DBD_CondStruct	mainConds[4], subConds[4];
	DBD_UpdStruct	updStruct[1];
	PDAG			queryDag = GetDAG ();

	//////////////////////////////////////
	// ----- Initialize sub-query ----- //
	//////////////////////////////////////
	_STR_strcpy (subQueryTableStruct[0].tableCode,bizEnv.ObjectToTable (JDT, ao_Main));
	DBD_SetParamTablesList (subQueryParams, subQueryTableStruct, 1);

	subQueryRES[0].tableIndex = 0;
	subQueryRES[0].colNum = OJDT_JDT_NUM;
	DBD_SetRes (subQueryParams, subQueryRES, 1);

	subConds[0].compareCols = true;
	subConds[0].origTableLevel	= 1; // In the base query
	subConds[0].origTableIndex	= 0; // JDT1
	subConds[0].colNum = JDT1_TRANS_ABS;
	subConds[0].operation = DBD_EQ;
	subConds[0].compTableIndex = 0; // OJDT (in sub query)
	subConds[0].compColNum = OJDT_JDT_NUM;
	subConds[0].relationship = DBD_AND; 

	subConds[1].colNum = OJDT_AUTO_VAT;
	subConds[1].operation = DBD_EQ;
	subConds[1].condVal = VAL_NO;
	subConds[1].relationship = DBD_AND; 

	subConds[2].bracketOpen = 1;
	subConds[2].colNum = OJDT_TRANS_TYPE;
	subConds[2].operation = DBD_EQ;
	subConds[2].condVal = MANUAL_BANK_TRANS_TYPE;
	subConds[2].relationship = DBD_OR; 

	subConds[3].colNum = OJDT_TRANS_TYPE;
	subConds[3].operation = DBD_EQ;
	subConds[3].condVal = JDT;
	subConds[3].bracketClose = 1;
	subConds[3].relationship = 0; 

	DBD_SetCond (subQueryParams, subConds, 4);

	///////////////////////////////////////
	// ----- Initialize main query ----- //
	///////////////////////////////////////
	updStruct[0].colNum = JDT1_VAT_LINE;
	updStruct[0].updateVal = VAL_NO;

	DBD_SetDAGUpd (queryDag, updStruct, 1);

	_STR_strcpy (tableStruct[0].tableCode, bizEnv.ObjectToTable (JDT, ao_Arr1));
	DBD_SetTablesList (queryDag, tableStruct, 1);

	// WHERE T1.[VatLine] = (N'Y' ) AND (T1.[VatGroup] IS NULL OR T1.[VatGroup] = '') AND EXISTS (....)
	mainConds[0].colNum = JDT1_VAT_LINE;
	mainConds[0].operation = DBD_EQ;
	mainConds[0].condVal = VAL_YES;
	mainConds[0].relationship = DBD_AND;

	mainConds[1].bracketOpen = 1;
	mainConds[1].colNum = JDT1_VAT_GROUP;
	mainConds[1].operation = DBD_IS_NULL;
	mainConds[1].relationship = DBD_OR;

	mainConds[2].colNum = JDT1_VAT_GROUP;
	mainConds[2].operation = DBD_EQ;
	mainConds[2].condVal = EMPTY_STR;
	mainConds[2].bracketClose = 1;
	mainConds[2].relationship = DBD_AND;

	mainConds[3].tableIndex = -1;
	mainConds[3].operation = DBD_EXISTS;
	mainConds[3].SetSubQueryParams (subQueryParams);
	mainConds[3].relationship = 0;

	DBD_SetDAGCond (queryDag, mainConds, 4);

	sboErr = DBD_UpdateCols (queryDag);

	if (sboErr && sboErr != dbmNoDataFound)
	{
		return sboErr;
	}	

	return noErr;
}

// Update dataSource = 'T' for open balance transactions which were year transferred.
// There's one problem with this upgrade. Because of a bug there's no way to distinguish
// these transactions from transaction which are caused by Data Import of an open balance transaction.
// Starting 2007 version, The transType of Data Import is different.
/************************************************************************************/
SBOErr CTransactionJournalObject::UpgradeYearTransfer ()
{
	DBD_Conditions	*conditions;
	PDBD_Cond		cond;
	DBD_UpdStruct	updStructJDT[1];
	PDAG			dagJDT;

	dagJDT = GetDAG ();
	conditions = &dagJDT->GetDBDParams ()->GetConditions ();

	cond = &conditions->AddCondition ();
	cond->colNum		= OJDT_TRANS_TYPE;
	cond->operation		= DBD_EQ;
	cond->condVal		= OPEN_BLNC_TYPE;
	cond->relationship	= DBD_AND;

	cond = &conditions->AddCondition ();
	cond->colNum		= OJDT_BATCH_NUM;
	cond->operation		= DBD_NOT_NULL;
	cond->relationship	= DBD_AND;

	cond = &conditions->AddCondition ();
	cond->colNum		= OJDT_BATCH_NUM;
	cond->operation		= DBD_NE;
	cond->condVal		= STR_0;
	cond->relationship	= DBD_AND;

	cond = &conditions->AddCondition ();
	cond->colNum		= OJDT_DATA_SOURCE;
	cond->operation		= DBD_EQ;
	cond->condVal		= VAL_UNKNOWN_SOURCE;
	cond->relationship	= 0;

	updStructJDT[0].colNum = OJDT_DATA_SOURCE;
	updStructJDT[0].updateVal = VAL_YEAR_TRANSFER_SOURCE;

	DBD_SetDAGUpd (dagJDT, updStructJDT, 1);

	/*UPDATE T0 SET T0.[DataSource] = N'T' FROM	[dbo].[OJDT] T0 WHERE T0.[TransType] = (N'-2')
	AND  T0.[BatchNum] IS NOT NULL AND  T0.[BatchNum] <> (0) AND T0.[DataSource] = (N'N')*/

	return DBD_UpdateCols (dagJDT);
}

/************************************************************************************/
/************************************************************************************/
SBOErr CTransactionJournalObject::AddRowByParent (PDAG pParentDAG, long lParentRow, PDAG pChildDAG)
{
	// Add new row
	long lDagSize = pChildDAG->GetSize (dbmDataBuffer);
	SBOErr sboErr = pChildDAG->SetSize (lDagSize + 1, dbmKeepData);
	if (sboErr != noErr)
		return sboErr;

	if (pChildDAG->GetTableName () == m_env.ObjectToTable (JDT, ao_Arr1) 
		&& NULL != pParentDAG)
	{
		pChildDAG->CopyColumn (pParentDAG, JDT1_TRANS_ABS, lDagSize, OJDT_JDT_NUM, lParentRow);
		pChildDAG->SetColLong(lDagSize, JDT1_LINE_ID, lDagSize);
	}
	
	//OCFT.
	if (pChildDAG->GetTableName () == m_env.ObjectToTable (CFT, ao_Main) && NULL != pParentDAG)
	{
		pChildDAG->CopyColumn (pParentDAG, OCFT_JDT_ID, lDagSize, JDT1_TRANS_ABS, lParentRow);
		pChildDAG->CopyColumn (pParentDAG, OCFT_JDT_LINE_ID, lDagSize, JDT1_LINE_ID, lParentRow);
	}

	return noErr;
}

/************************************************************************************/
/************************************************************************************/
long CTransactionJournalObject::GetFirstRowByParent (PDAG pParentDAG, long lParentRow, PDAG pChildDAG)
{
	if (pChildDAG->GetTableName () == m_env.ObjectToTable (CFT, ao_Main) && NULL != pParentDAG)	//OCFT
	{
		long lDagSize = pChildDAG->GetSize (dbmDataBuffer);
		if (lDagSize == 0)
		{
			return -1;
		}

		long transId;
		long lineId;
		pParentDAG->GetColLong (&transId,  JDT1_TRANS_ABS, lParentRow);
		pParentDAG->GetColLong (&lineId,  JDT1_LINE_ID, lParentRow);

		for (long ii = 0; ii < lDagSize; ii++)
		{
			long jeAbsID;
			long jeLineId;
			pChildDAG->GetColLong (&jeAbsID, OCFT_JDT_ID, ii);
			pChildDAG->GetColLong (&jeLineId, OCFT_JDT_LINE_ID, ii);
			if (jeAbsID == transId && jeLineId == lineId)
			{
				return ii;
			}
		}
	}
	
	if (pChildDAG->GetTableName () == m_env.ObjectToTable (JDT, ao_Arr1))
	{
		long lDagSize = pChildDAG->GetSize (dbmDataBuffer);
		if (lDagSize == 0)
		{
			return -1;
		}

		long transId;
		pParentDAG->GetColLong (&transId,  OJDT_JDT_NUM, lParentRow);

		for (long ii = 0; ii < lDagSize; ii++)
		{
			long transAbs;
			pChildDAG->GetColLong (&transAbs, JDT1_TRANS_ABS, ii);
			if (transAbs == transId)
			{
				return ii;
			}
		}	
	}
	else
	{
		if(VF_JEWHT(m_env) && pChildDAG->GetTableName () == m_env.ObjectToTable (JDT, ao_Arr2))
		{
            long lDagSize = pChildDAG->GetSize (dbmDataBuffer);
            if (lDagSize == 0)
            {
                return -1;
            }

            long transId;
            pParentDAG->GetColLong (&transId,  OJDT_JDT_NUM, lParentRow);

            for (long ii = 0; ii < lDagSize; ii++)
            {
                long transAbs;
                pChildDAG->GetColLong (&transAbs, JDT2_ABS_ENTRY, ii);
                if (transAbs == transId)
                {
                    return ii;
                }
            }                
		}else{
		    return CSystemBusinessObject::GetFirstRowByParent (pParentDAG, lParentRow, pChildDAG);
		}		
	}

	return -1;
}

long CTransactionJournalObject::GetNextRow (PDAG pParentDAG, PDAG pDAG, long lRow, bool bNext)
{
	if (pDAG->GetTableName () == m_env.ObjectToTable (CFT, ao_Main) && NULL != pParentDAG)	//OCFT
	{
		// Check of valid rows
		long lDagSize = pDAG->GetSize (dbmDataBuffer);
		if (lRow < 0 || lRow >= lDagSize)
		{
			return -1;
		}
		// Delta between rows. 1 for next row, -1 for previous row
		long delta = bNext ? 1 : -1;

		long transAbs;
		long lineID;
		pDAG->GetColLong (&transAbs, OCFT_JDT_ID, lRow);
		pDAG->GetColLong (&lineID, OCFT_JDT_LINE_ID, lRow);

		// Find next or previous row with the same copied key
		for (long rec = lRow + delta; bNext ? rec < lDagSize : rec >= 0; rec += delta)
		{
			long tmpAbs;
			long tmpLineId;
			pDAG->GetColLong (&tmpAbs, OCFT_JDT_ID, rec);
			pDAG->GetColLong (&tmpLineId, OCFT_JDT_LINE_ID, rec);
			if (tmpAbs == transAbs && tmpLineId == lineID)
			{
				return rec;
			}
		}
	}
	
	if (pDAG->GetTableName () == m_env.ObjectToTable (JDT, ao_Arr1))// BTF1
	{
		// Check of valid rows
		long lDagSize = pDAG->GetSize (dbmDataBuffer);
		if (lRow < 0 || lRow >= lDagSize)
		{
			return -1;
		}
		// Delta between rows. 1 for next row, -1 for previous row
		long delta = bNext ? 1 : -1;

		long transAbs;
		pDAG->GetColLong (&transAbs, JDT1_TRANS_ABS, lRow);

		// Find next or previous row with the same copied key
		for (long rec = lRow + delta; bNext ? rec < lDagSize : rec >= 0; rec += delta)
		{
			long tmpAbs;
			pDAG->GetColLong (&tmpAbs, JDT1_TRANS_ABS, rec);
			if (tmpAbs == transAbs)
			{
				return rec;
			}
		}
	}
	else
	{
		if(VF_JEWHT(m_env) && pDAG->GetTableName () == m_env.ObjectToTable (JDT, ao_Arr2))
		{
		     // Check of valid rows
		    long lDagSize = pDAG->GetSize (dbmDataBuffer);
		    if (lRow < 0 || lRow >= lDagSize)
		    {
			    return -1;
		    }
		    // Delta between rows. 1 for next row, -1 for previous row
		    long delta = bNext ? 1 : -1;

		    long transAbs;
		    pDAG->GetColLong (&transAbs, JDT2_ABS_ENTRY, lRow);

		    // Find next or previous row with the same copied key
		    for (long rec = lRow + delta; bNext ? rec < lDagSize : rec >= 0; rec += delta)
		    {
			    long tmpAbs;
			    pDAG->GetColLong (&tmpAbs, JDT2_ABS_ENTRY, rec);
			    if (tmpAbs == transAbs)
			    {
				    return rec;
			    }
		    }
		}else{
		    return CSystemBusinessObject::GetNextRow (pParentDAG, pDAG, lRow, bNext);
		} 		
	}

	return -1;
}

/************************************************************************************/
/************************************************************************************/
long CTransactionJournalObject::GetLogicRowCount(PDAG pParentDAG, long lParentRow, PDAG pDAG)
{
	_TRACER("GetLogicRowCount");

	// JournalEntry_Lines
	if (pDAG->GetTableName () == m_env.ObjectToTable (JDT, ao_Arr1))
	{
		return pDAG->GetRealSize(dbmDataBuffer);
	}
	else
	{
		return CBusinessService::GetLogicRowCount(pParentDAG, lParentRow, pDAG);
	}
}

/************************************************************************************/
/************************************************************************************/
SBOErr CTransactionJournalObject::RepairTaxTable ()
{
	SBOErr			sboErr = 0;
	CBizEnv			&bizEnv = GetEnv ();
	DBD_Params		subQueryParams[1];
	DBD_ResStruct	subQueryRES[1];
	DBD_Tables		tableStruct[1], subQueryTableStruct[3];
	DBD_CondStruct	joinToTAX1[1], joinToOTAX[3];
	DBD_CondStruct	mainConds[1], subConds[3];
	DBD_Params		subQuery2Params[1];
	DBD_Tables		subQuery2TableStruct[3];
	PDAG			queryDag = GetDAG (TAX, ao_Main);

	/*
	Delete from otax
	Where absentry IN
	(
	select t1.absentry  from tax1 t0 inner join otax t1 on t0.absentry = t1.absentry
	inner join jdt1 t2 on t1.srcobjtype='30' and t1.srcobjabs =t2.transid
	and t0.srclinenum=t2.line_id
	where t2.VatGroup is null or t2.VatGroup = ''
	)
	*/

	if (!bizEnv.IsVatPerLine())
	{
		return noErr;
	}

	_STR_strcpy (subQueryTableStruct[0].tableCode,bizEnv.ObjectToTable (TAX, ao_Arr1));
	_STR_strcpy (subQueryTableStruct[1].tableCode,bizEnv.ObjectToTable (TAX, ao_Main));
	_STR_strcpy (subQueryTableStruct[2].tableCode,bizEnv.ObjectToTable (JDT, ao_Arr1));

	subQueryTableStruct[1].doJoin		 = TRUE;
	subQueryTableStruct[1].joinedToTable = 0;
	subQueryTableStruct[1].numOfConds	 = 1;
	subQueryTableStruct[1].joinConds     = joinToTAX1;

	subQueryTableStruct[2].doJoin		 = TRUE;
	subQueryTableStruct[2].joinedToTable = 1;
	subQueryTableStruct[2].numOfConds	 = 3;
	subQueryTableStruct[2].joinConds     = joinToOTAX;

	joinToTAX1[0].compareCols  = TRUE;
	joinToTAX1[0].compColNum	   = TAX1_ABS_ENTRY;
	joinToTAX1[0].compTableIndex = 1;
	joinToTAX1[0].colNum		   = OTAX_ABS_ENTRY;
	joinToTAX1[0].tableIndex	   = 0;
	joinToTAX1[0].operation	   = DBD_EQ;

	joinToOTAX[0].compareCols  = TRUE;
	joinToOTAX[0].compColNum	   = OTAX_SOURCE_OBJ_ABS_ENTRY;
	joinToOTAX[0].compTableIndex = 1;
	joinToOTAX[0].colNum		   = JDT1_TRANS_ABS;
	joinToOTAX[0].tableIndex	   = 2;
	joinToOTAX[0].operation	   = DBD_EQ;
	joinToOTAX[0].relationship		= DBD_AND;

	joinToOTAX[1].compareCols  = TRUE;
	joinToOTAX[1].compColNum	   = TAX1_SRC_LINE_NUM;
	joinToOTAX[1].compTableIndex = 0;
	joinToOTAX[1].colNum		   = JDT1_LINE_ID;
	joinToOTAX[1].tableIndex	   = 2;
	joinToOTAX[1].operation	   = DBD_EQ;
	joinToOTAX[1].relationship		= DBD_AND;

	joinToOTAX[2].colNum		   = OTAX_SOURCE_OBJ_TYPE;
	joinToOTAX[2].tableIndex	   = 1;
	joinToOTAX[2].operation	   = DBD_EQ;
	joinToOTAX[2].condVal = JDT;

	DBD_SetParamTablesList (subQueryParams, subQueryTableStruct, 3);

	subQueryRES[0].tableIndex = 0;
	subQueryRES[0].colNum = TAX1_ABS_ENTRY;
	DBD_SetRes (subQueryParams, subQueryRES, 1);

	subConds[0].tableIndex	= 2;
	subConds[0].colNum = JDT1_VAT_GROUP;
	subConds[0].operation = DBD_IS_NULL;
	subConds[0].relationship = DBD_OR;

	subConds[1].tableIndex	= 2;
	subConds[1].colNum = JDT1_VAT_GROUP;
	subConds[1].operation = DBD_EQ;
	subConds[1].condVal = EMPTY_STR;

	DBD_SetCond (subQueryParams, subConds, 2);

	mainConds[0].colNum = OTAX_ABS_ENTRY;
	mainConds[0].operation = DBD_IN;
	mainConds[0].SetSubQueryParams (subQueryParams);
	mainConds[0].relationship = 0;

	DBD_SetDAGCond (queryDag, mainConds, 1);

	DBD_RemoveRecords (queryDag);

	/*
	delete from  tax1
	where absEntry NOT IN
	(
	select absEntry from OTAX
	)
	*/
	_STR_strcpy (subQuery2TableStruct[0].tableCode,bizEnv.ObjectToTable (TAX, ao_Main));

	DBD_SetParamTablesList (subQuery2Params, subQuery2TableStruct, 1);

	subQueryRES[0].colNum = OTAX_ABS_ENTRY;
	DBD_SetRes (subQuery2Params, subQueryRES, 1);

	_STR_strcpy (tableStruct[0].tableCode, bizEnv.ObjectToTable (TAX, ao_Arr1));
	DBD_SetTablesList (queryDag, tableStruct, 1);

	_MEM_Clear(mainConds, 1);
	mainConds[0].colNum = TAX1_ABS_ENTRY;
	mainConds[0].operation = DBD_NOT_IN;
	mainConds[0].SetSubQueryParams (subQuery2Params);
	mainConds[0].relationship = 0;

	DBD_SetDAGCond (queryDag, mainConds, 1);

	DBD_RemoveRecords (queryDag);

	return noErr;
}

/************************************************************************************/
/************************************************************************************/
bool CTransactionJournalObject::IsBlockDunningLetterUpdateable ()
{
	SBOString transType = GetID ();
	return (transType == JDT || transType == NOB || transType == OPEN_BLNC_TYPE || transType == CLOSE_BLNC_TYPE);
}

/************************************************************************/
/************************************************************************/
SBOErr CTransactionJournalObject::UpgradeJDTIndianAutoVat ()
{
	_TRACER("UpgradeJDTIndianAutoVat");

	SBOErr	sboErr = noErr;
	PDAG	dagRes;
	CBizEnv	&bizEnv = GetEnv ();

	DBD_Conditions	*conditions;
	DBD_CondStruct	condition[3];
	PDBD_Cond		cond;
	DBD_ResStruct	resStruct[2];
	DBD_SortStruct	sortStruct[2];
	DBD_Tables		tables[2];
	DBD_CondStruct	join[1];

	PDAG dagJDT = GetDAG ();

	dagJDT->ClearQueryParams();

	tables[0].tableCode = bizEnv.ObjectToTable(JDT, ao_Main);
	tables[1].tableCode = bizEnv.ObjectToTable(JDT, ao_Arr1);

	tables[1].doJoin		= true;
	tables[1].joinedToTable = 0;
	tables[1].numOfConds	= 1;
	tables[1].joinConds		= &join[0];

	// Join Condition
	join[0].compareCols		= true;
	join[0].compTableIndex	= 1;
	join[0].compColNum		= JDT1_TRANS_ABS;
	join[0].operation		= DBD_EQ;
	join[0].tableIndex		= 0;
	join[0].colNum			= OJDT_JDT_NUM;

	condition[0].tableIndex		= 0;
	condition[0].colNum			= OJDT_AUTO_VAT;
	condition[0].operation		= DBD_EQ;
	condition[0].condVal		= VAL_YES;
	condition[0].relationship	= DBD_AND;

	condition[1].tableIndex		= 1;
	condition[1].colNum			= JDT1_VAT_LINE;
	condition[1].operation		= DBD_EQ;
	condition[1].condVal		= VAL_YES;
	condition[1].relationship	= DBD_AND;

	condition[2].tableIndex		= 1;
	condition[2].colNum			= JDT1_VAT_GROUP;
	condition[2].operation		= DBD_NOT_NULL;
	condition[2].relationship	= 0;

	resStruct[0].tableIndex = 0;
	resStruct[0].colNum		= OJDT_JDT_NUM;
	resStruct[0].group_by	= true;

	DBD_SetTablesList (dagJDT, tables, 2);
	DBD_SetDAGCond (dagJDT, condition, 3);
	DBD_SetDAGRes (dagJDT, resStruct, 1);

	sboErr = DBD_GetInNewFormat (dagJDT, &dagRes);
	if (sboErr)
	{
		if (sboErr == dbmNoDataFound)
		{
			sboErr = noErr;
		}
		return sboErr;
	}

	PDAG dagJDT1 = GetDAG (JDT, ao_Arr1);
	sortStruct[0].colNum = JDT1_TRANS_ABS;
	sortStruct[1].colNum = JDT1_LINE_ID;

	long numOfTrans = dagRes->GetRecordCount ();
	//In order not to comsume all the memory at one time, we process 1000 trans each time
	long workLoad = 1000;
	long step = numOfTrans / workLoad;
	SBOCollection_SBOString	transValues;

	for (long i = 0; i <= step; ++i)
	{
		long begin, end;
		if (i < step)
		{
			begin = i * workLoad;
			end = (i + 1) * workLoad;
		}
		else
		{
			begin = i * workLoad;
			end = numOfTrans;
			if (begin >= end)
			{
				break;
			}
		}
		transValues.Clear();
		for (long j = begin; j < end; ++j)
		{
			long transID;
			dagRes->GetColLong(&transID, 0, j);
			transValues.Add(transID);
		}

		dagJDT1->ClearQueryParams();
		conditions = &dagJDT1->GetDBDParams ()->GetConditions ();
		cond = &conditions->AddCondition();
		cond->colNum = JDT1_TRANS_ABS;
		cond->operation = DBD_IN;
		cond->SetValuesArray(transValues);
		DBD_SetDAGSort (dagJDT1, sortStruct, 2);
		DBD_Get(dagJDT1);
		sboErr = UpgradeJDTIndianAutoVatInt (dagJDT1);
		if (sboErr)
		{
			return sboErr;
		}
	}

	return sboErr;
}

/**
*
*/
/**
* check whether col has been changed 
* 
*/
bool CTransactionJournalObject::CheckColChanged (const PDAG dag, const long col,
												 const long rec /* = 0L */)
{
	if (!_DBM_DataAccessGate::IsValid (dag))
	{
		return false;
	}

	DBM_CL	colList;
	SBOErr	ooErr;
	
	ooErr = dag->GetChangesList (rec, colList);
	IF_ERROR_RETURN_VALUE (ooErr, false);

	long	colCount, currCol;

	colCount = colList.GetSize ();
	for (long colIndex = 0; colIndex < colCount; ++colIndex)
	{
		currCol = colList[colIndex]->GetColNum ();
		if (currCol == col)
		{
			return true;
		}
	}

	return false;
}

/************************************************************************************/
/************************************************************************************/
SBOErr	CTransactionJournalObject::UpgradeJDTIndianAutoVatInt (PDAG dagJDT1)
{
	bool isVatLine = false;
	long currentTransID = -1;
	long currentTaxType = 0;
	long totalLines = dagJDT1->GetRecordCount();
	long tmpL;
	SBOString tmpStr;

	for (long i = 0; i < totalLines; ++i)
	{
		//Update posting account
		dagJDT1->GetColStr(tmpStr, JDT1_DEBIT_CREDIT, i);
		if (tmpStr.Compare(VAL_DEBIT))
		{
			dagJDT1->SetColStr(JTE_VAL_AP, JDT1_TAX_POSTING_ACCOUNT, i);
		}
		else
		{
			dagJDT1->SetColStr(JTE_VAL_AR, JDT1_TAX_POSTING_ACCOUNT, i);
		}

		//update vatGroup & taxCode column: copy vat group to tax code
		dagJDT1->GetColStr(tmpStr, JDT1_VAT_GROUP, i);
		dagJDT1->NullifyCol(JDT1_VAT_GROUP, i);
		dagJDT1->SetColStr(tmpStr, JDT1_TAX_CODE, i);

		//Update isNet column
		dagJDT1->SetColStr(VAL_YES, JDT1_IS_NET, i);

		//Update tax type column
		dagJDT1->GetColLong(&tmpL, JDT1_TRANS_ABS, i);
		if (tmpL != currentTransID)
		{
			currentTransID = tmpL;
			currentTaxType = 0;
			isVatLine = false;
			continue;
		}
		dagJDT1->GetColStr(tmpStr, JDT1_VAT_LINE, i);
		if (tmpStr.Compare(VAL_YES))
		{
			currentTaxType = 0;
			isVatLine = false;
			continue;
		}
		else
		{
			if (!isVatLine)
			{
				currentTaxType = 0;
				isVatLine = true;
			}
			else
			{
				++currentTaxType;
			}
		}
		dagJDT1->SetColLong (currentTaxType, JDT1_TAX_TYPE, i);
	}

	return dagJDT1->UpdateAll();
}

/************************************************************************/
/************************************************************************/
SBOErr	CTransactionJournalObject::UpgradeOJDTUpdateDocType ()
{
	SBOErr			sboErr = ooNoErr;
	CBizEnv			&bizEnv = GetEnv ();
	PDAG			dagJDT = bizEnv.OpenDAG (JDT); 
	DBD_CondStruct	condStruct[2];
	DBD_UpdStruct	updStruct[1];
	SBOString		srcStr;
	   
	//_STR_GetStringResource (srcStr, MSG_STR_LIST, JTE_ACCOUNTING_VOUCHER_DOC_TYPE, coreChineseCN, &bizEnv);
	srcStr = bizEnv.GetDefaultJEType();
	srcStr.Trim ();
	
	condStruct[0].colNum = OJDT_DOC_TYPE;
	condStruct[0].operation = DBD_IS_NULL;
	condStruct[0].relationship = DBD_OR;
	condStruct[1].colNum = OJDT_DOC_TYPE;
	condStruct[1].operation = DBD_EQ;
	_STR_strcpy (condStruct[1].condVal, _T(""));
	condStruct[1].relationship = 0;
	
	sboErr = DBD_SetDAGCond (dagJDT, condStruct, 2);
	if	(sboErr)
	{
		dagJDT->Close ();
		return sboErr;
	}
	
	updStruct[0].colNum = OJDT_DOC_TYPE;
	_STR_strcpy (updStruct[0].updateVal, srcStr);
		
	sboErr = DBD_SetDAGUpd (dagJDT, updStruct, 1);
	if	(sboErr)
	{
		dagJDT->Close ();
		return sboErr;
	}
	
	sboErr = DBD_UpdateCols (dagJDT);
	dagJDT->Close ();
	
	return sboErr;
}

CSequenceParameter* CTransactionJournalObject::GetSeqParam()
{
	if (m_pSequenceParameter == NULL)
	{
		m_pSequenceParameter = new CSequenceParameter(OJDT_SEQ_CODE, OJDT_SERIAL);
	}
	return m_pSequenceParameter;
}
SBOErr  CTransactionJournalObject::ValidateHeaderLocation()
{
	_TRACER("ValidateHeaderLocation");
	
	PDAG dagJDT = GetDAG();
	SBOString autoVat, regNo;
	dagJDT->GetColStr(autoVat, OJDT_AUTO_VAT);
	dagJDT->GetColStr(regNo, OJDT_GEN_REG_NO);
	if(autoVat == VAL_YES || regNo == VAL_YES)
	{
		long location;
		dagJDT->GetColLong(&location, OJDT_LOCATION);
		if(!location)
		{
			SetErrorField(OJDT_LOCATION);
			Message (GO_OBJ_ERROR_MSGS(JDT), JDT_NEED_LOCATION_ERR, NULL, OO_ERROR);
			return (ooInvalidObject);
		}
	}
	return ooNoErr;
}
SBOErr CTransactionJournalObject::ValidateRowLocation(long rec)
{
	_TRACER("ValidateRowLocation");

	PDAG dagJDT1 = GetDAG (JDT, ao_Arr1);
	SBOString vatLine;
	dagJDT1->GetColStr(vatLine, JDT1_VAT_LINE, rec);
	if(vatLine == VAL_YES)
	{	
		SBOString taxCode;
		dagJDT1->GetColStr(taxCode, JDT1_TAX_CODE, rec);
		if(!taxCode.IsEmpty())
		{
			long location;
			dagJDT1->GetColLong(&location, JDT1_LOCATION, rec);
			if(!location)
			{
				SetArrNum(ao_Arr1);
				SetErrorField(OJDT_LOCATION);
				SetErrorLine(rec + 1);
				Message (GO_OBJ_ERROR_MSGS(JDT), JDT_NEED_LOCATION_ERR, NULL, OO_ERROR);
				return (ooInvalidObject);
			}
		}
	}
	PDAG dagJDT = GetDAG(JDT, ao_Main);
	long objType ;
	dagJDT->GetColLong(&objType, OJDT_TRANS_TYPE);
	if(objType == JDT || objType == -1) //manual JE
	{
		long maType, cenvatCon;
		dagJDT1->GetColLong(&maType, JDT1_MATERIAL_TYPE, rec);
		dagJDT1->GetColLong(&cenvatCon, JDT1_CENVAT_COM, rec);
		if (isValidCENVAT(cenvatCon) || isValidMatType(maType))
		{
			long location;
			dagJDT1->GetColLong(&location, JDT1_LOCATION, rec);
			if(!location)		
			{
				SetArrNum(ao_Arr1);
				SetErrorField(OJDT_LOCATION);
				SetErrorLine(rec + 1);
				Message (GO_OBJ_ERROR_MSGS(JDT), JDT_NEED_LOCATION_ERR, NULL, OO_ERROR);
				return (ooInvalidObject);
			}
		}
	}
	return ooNoErr;
}

SBOErr CTransactionJournalObject::CompleteLocations()
{
	PDAG dagJDT = GetDAG();
	PDAG dagJDT1 = GetDAG(ao_Arr1);
	SBOString autoVat, regNo;
	dagJDT->GetColStr(autoVat, OJDT_AUTO_VAT);
	dagJDT->GetColStr(regNo, OJDT_GEN_REG_NO);
	if(autoVat == VAL_YES || regNo == VAL_YES)
	{
		long location = 0;
		dagJDT->GetColLong(&location, OJDT_LOCATION);
		if(!location)	
		{
			long seq = 0;
			dagJDT->GetColLong(&seq, OJDT_SEQ_CODE);
			if(seq)
			{
				location = GetEnv().GetSequenceManager()->GetLocation(*this, seq);
				dagJDT->SetColLong(location, OJDT_LOCATION);
			}
		}	
		dagJDT->GetColLong(&location, OJDT_LOCATION);
		if(location)
		{
			long recCount = dagJDT1->GetRecordCount();
			SBOString taxCode;
			for(long rec = 0; rec < recCount; rec++)
			{
				dagJDT1->GetColStr(taxCode, JDT1_TAX_CODE, rec);
				if(!taxCode.IsEmpty())
				{
					dagJDT1->GetColLong(&location, JDT1_LOCATION, rec);
					if(!location)
					{
						dagJDT1->CopyColumn (dagJDT, JDT1_LOCATION, rec, OJDT_LOCATION, 0);
					}
				}
			}
		}
	}
	
	return	ooNoErr;	
}

/**
* On Can Archive- Add Where.
*
* Adds a "WHERE" clause to the main "on can archive" function.
* "WHERE OJDT.RefDate <= @ArchiveDate AND <There are no BP lines that are not fully reconciled>"
* @param canArchiveStmt - the main statement of "onCanArchive".
* @param archiveDate - the archiving date.
* @param tObjectTable - the "O" table of the object, for use in the query.
* @return noErr on success, SBOErr otherwise.
*/
SBOErr	CTransactionJournalObject::CanArchiveAddWhere (	CBizEnv&				bizEnv,
														DBQRetrieveStatement&	canArchiveStmt,
														const Date&				archiveDate, 
														DBQTable&				tObjectTable)
{
	//Build the sub-query: <There are no BP lines that are not fully reconciled>
	/*
	AND NOT EXISTS
	(
		SELECT T1.transId FROM JDT1 T1
		WHERE T1.transId = T0.transId AND T1.ShortName <> T1.account
		AND (T1.BalDueCred <> 0 OR T1.BalFcCred <> 0 OR T1.BalDueDeb  <> 0 OR T1.BalFcDeb <> 0)
	)
	*/

	DBQRetrieveStatement	&subQ_unReconciledBPlines = *canArchiveStmt.CreateSubquery();
	DBQTable				tJDT1 = subQ_unReconciledBPlines.From("JDT1");

	subQ_unReconciledBPlines.Select().Col(tJDT1, JDT1_TRANS_ABS);
	subQ_unReconciledBPlines.Where().
		Col(tJDT1, JDT1_TRANS_ABS).EQ().Col(tObjectTable, OJDT_JDT_NUM).
		And().OpenBracket();
		if (bizEnv.IsLocalSettingsFlag (lsf_EnableCardClosingPeriod))
		{
			subQ_unReconciledBPlines.Where().OpenBracket();
		}
		subQ_unReconciledBPlines.Where().Col(tJDT1, JDT1_SHORT_NAME).NE().Col(tJDT1, JDT1_ACCT_NUM).
		And().OpenBracket().
			Col (tJDT1, JDT1_BALANCE_DUE_CREDIT).NE().Val(0).
			Or().
			Col (tJDT1, JDT1_BALANCE_DUE_FC_CRED).NE().Val(0).
			Or().
			Col (tJDT1, JDT1_BALANCE_DUE_DEBIT).NE().Val(0).
			Or().
			Col (tJDT1, JDT1_BALANCE_DUE_FC_DEB).NE().Val(0).
		CloseBracket().CloseBracket();
	if (bizEnv.IsLocalSettingsFlag (lsf_EnableCardClosingPeriod))
	{
		subQ_unReconciledBPlines.Where().Or().Col(tJDT1, JDT1_SRC_LINE).EQ().Val(PMN_VAL_CLOSE_PER).
		CloseBracket();
	}

	// Main "Where" (includes sub-query)
	Date temp = archiveDate;
	SBOString dateStr;
	temp.ToStr (dateStr, bizEnv);
	if (!dateStr.IsEmpty ())
	{
		canArchiveStmt.Where().
			Col (tObjectTable, OJDT_REF_DATE).LE().Val (temp).And();
	}


	canArchiveStmt.Where ().Col (tObjectTable, OJDT_TRANS_TYPE).NE().Val(CLOSE_BLNC_TYPE).
		And().NotExists().OpenBracket().Subquery(subQ_unReconciledBPlines).CloseBracket();

	return noErr;
}


/*****************************************************************************************/
//Function name: GetArchiveDocNumCol
// This function will override the default behavior of the base function, that gets the Doc
// Number by type - SERIAL_NUM_FLD (2).
//Returns: output in  outArcDocNumCol: we want to display the abs entry  of this document
//										(TransId) as the Doc number, even though there is 
//										a field with type SERIAL_NUM_FLD (2).
//											Approved by PDef Ari Schapira and Shula Ben Dosa
//  								  
/*****************************************************************************************/
SBOErr	CTransactionJournalObject::GetArchiveDocNumCol (long& outArcDocNumCol)
{
	outArcDocNumCol = OJDT_JDT_NUM;

	return noErr;
}

SBOErr	CTransactionJournalObject::CompleteDataForArchivingLog ()
{		
	SBOErr sboErr = CBusinessObjectBase::CompleteDataForArchivingLog ();
	IF_ERROR_RETURN (sboErr);

	CBizEnv&				bizEnv = GetEnv ();

	SBOString selectedBPTempTbl = GetArchiveSelectedBPTblName ();
	//Archive by BP
	if (!selectedBPTempTbl.IsEmpty () && 
		bizEnv.GetCompanyConnection ()->DBisTableExists (selectedBPTempTbl, &bizEnv))
	{
		PDAG	dagTMP_ARC = GetDAG (TMP);
		SBOString	tempArcTableName = dagTMP_ARC->GetTableName ();

		/*
		PDATE T0 
		SET T0.[CardCode] = N'--' 
		FROM [dbo].[##TDAR_5492] T0 
		WHERE T0.[DocType] = (N'30') 
		  AND T0.[DocAbs] IN((SELECT DISTINCT U0.[DocAbs] 
		FROM [dbo].[##TDAR_5492] U0 INNER JOIN [dbo].[OJDT] U1 
		  ON U1.[TransId] = U0.[DocAbs] 
		  AND U0.[DocType] = N'30' INNER JOIN [dbo].[JDT1] U2 
		  ON U2.[TransId] = U1.[TransId] INNER JOIN [dbo].[##TSEL_BP_5492] U3 
		  ON U3.[CardCode] = U2.[ShortName] 
		WHERE U1.[TransType] = (N'30') 
		AND U2.[Account] <> U2.[ShortName] )) 
		*/
		try
		{
			DBQUpdateStatement updStmt (bizEnv);
			DBQTable updTbl = updStmt.Update (tempArcTableName);

			DBQRetrieveStatement	&stmt = *updStmt.CreateSubquery();
			DBQTable tTDAR = stmt.From (tempArcTableName);

			DBQTable tOJDT = stmt.Join (bizEnv.ObjectToTable (JDT), tTDAR);
			stmt.On (tOJDT).Col (tOJDT, OJDT_JDT_NUM).EQ ().Col (tTDAR, TDAR_DOC_ABS).And ().
				Col (tTDAR, TDAR_DOC_TYPE).EQ ().Val (JDT);

			DBQTable tJDT1 = stmt.Join (bizEnv.ObjectToTable (JDT, ao_Arr1), tOJDT);
			stmt.On (tJDT1).Col (tJDT1, JDT1_TRANS_ABS).EQ ().Col (tOJDT, OJDT_JDT_NUM);

			DBQTable tSelBPs = stmt.Join (selectedBPTempTbl, tJDT1);
			stmt.On (tSelBPs).Col (tSelBPs, TSEL_BP_CARD_CODE_COL).EQ ().Col (tJDT1, JDT1_SHORT_NAME);

			stmt.Where ().Col (tOJDT, OJDT_TRANS_TYPE).EQ ().Val (JDT).And ().
				Col (tJDT1, JDT1_ACCT_NUM).NE ().Col (tJDT1, JDT1_SHORT_NAME);

			stmt.Select ().Col (tTDAR, TDAR_DOC_ABS);
			stmt.Distinct ();

			updStmt.Set (TDAR_CARD_CODE).Val (_T("--"));
			updStmt.Where ().Col (updTbl, TDAR_DOC_TYPE).EQ ().Val (JDT).And ().
				Col (updTbl, TDAR_DOC_ABS).In ().Subquery (stmt);

			updStmt.Execute ();
		}
		catch (DBMException& e)
		{
			return e.GetCode ();
		}

		/*
		UPDATE T0 
		SET T0.[CanArcObj] = N'D' 
		FROM [dbo].[##TDAR_5492] T0 
		WHERE T0.[DocType] = (N'30') 
		  AND T0.[DocAbs] IN((SELECT DISTINCT U0.[DocAbs] 
		FROM [dbo].[##TDAR_5492] U0 INNER JOIN [dbo].[OJDT] U1 
		  ON U1.[TransId] = U0.[DocAbs] 
		  AND U0.[DocType] = N'30' INNER JOIN [dbo].[JDT1] U2 
		  ON U2.[TransId] = U1.[TransId] LEFT OUTER JOIN [dbo].[##TSEL_BP_5492] U3 
		  ON U3.[CardCode] = U2.[ShortName] 
		WHERE U1.[TransType] = (N'30') 
		  AND U2.[Account] <> U2.[ShortName] 
		  AND U3.[CardCode] IS NULL )) 
		*/
		try
		{
			DBQUpdateStatement updStmt (bizEnv);

			DBQRetrieveStatement	&stmt = *updStmt.CreateSubquery();

			DBQTable tTDAR = stmt.From (tempArcTableName);

			DBQTable tOJDT = stmt.Join (bizEnv.ObjectToTable (JDT), tTDAR);
			stmt.On (tOJDT).Col (tOJDT, OJDT_JDT_NUM).EQ ().Col (tTDAR, TDAR_DOC_ABS).And ().
				Col (tTDAR, TDAR_DOC_TYPE).EQ ().Val (JDT);

			DBQTable tJDT1 = stmt.Join (bizEnv.ObjectToTable (JDT, ao_Arr1), tOJDT);
			stmt.On (tJDT1).Col (tJDT1, JDT1_TRANS_ABS).EQ ().Col (tOJDT, OJDT_JDT_NUM);

			DBQTable tSelBPs = stmt.Join (selectedBPTempTbl, tJDT1, DBQ_JT_LEFT_OUTER_JOIN);
			stmt.On (tSelBPs).Col (tSelBPs, TSEL_BP_CARD_CODE_COL).EQ ().Col (tJDT1, JDT1_SHORT_NAME);

			stmt.Where ().Col (tOJDT, OJDT_TRANS_TYPE).EQ ().Val (JDT).And ().
				Col (tJDT1, JDT1_ACCT_NUM).NE ().Col (tJDT1, JDT1_SHORT_NAME).And ().
				Col (tSelBPs, 0).IsNull ();

			stmt.Select ().Col (tTDAR, TDAR_DOC_ABS);
			stmt.Distinct ();

			DBQTable updTbl = updStmt.Update (tempArcTableName);

			updStmt.Set (TDAR_CAN_ARC_OBJ).Val (VAL_DOCUMENT_FROM_DIFF_BP_FAIL);
			updStmt.Where ().Col (updTbl, TDAR_DOC_TYPE).EQ ().Val (JDT).And ().
				Col (updTbl, TDAR_DOC_ABS).In ().Subquery (stmt);

			updStmt.Execute ();
		}
		catch (DBMException& e)
		{
			return e.GetCode ();
		}
	}
	return noErr;
}


/**
 * Query transID from table  OJDT 
 *
 * Retrieve transID from table OJDT according to the transtype and createdby 
 * @param[in] bizEnv 
 * @param[out] transId 
 * @param[in] transtype 
 * @param[in] createdby 
 * @param[in] returnMinTransId 
 * @return SBOErr 
*/
SBOErr CTransactionJournalObject::GetTransIdByDoc (CBizEnv& bizEnv, 
												   long &transId, 
												   long transtype, 
												   long createdby, 
												   bool returnMinTransId /* = true */)
{
	SBOErr sboErr = noErr;
	try
	{
		APCompanyDAG dagRes;
		DBQRetrieveStatement stmt (bizEnv);

		DBQTable tJDT = stmt.From (bizEnv.ObjectToTable (JDT, ao_Main));

		stmt.Top(1);
		stmt.Select ().Col (tJDT, OJDT_JDT_NUM);
		stmt.Where ().Col (tJDT, OJDT_TRANS_TYPE).EQ ().Val (transtype).And ()
			.Col (tJDT, OJDT_CREATED_BY).EQ ().Val (createdby);
		
		if(returnMinTransId)
			stmt.OrderBy(tJDT, OJDT_JDT_NUM, false);
		else
			stmt.OrderBy(tJDT, OJDT_JDT_NUM, true);

		if (stmt.Execute (dagRes) > 0L)
		{
			dagRes->GetColLong (&transId, 0L);
		}
		else
		{
			sboErr = dbmNoDataFound;
		}
	}
	catch (DBMException& e)
	{
		sboErr = e.GetCode ();
	}
	return sboErr;
}

/************************************************************************/
/************************************************************************/
SBOErr	CTransactionJournalObject::BeforeDeleteArchivedObject (ArcDeletePrefs& arcDelPref)
{
	SBOErr					sboErr = noErr;				
#ifndef MNHL_SERVER_MODE
	JECompressionPrefStruct JEPref;
	PDAG					dagDAR = GetDAG (DAR);
	SBOString				tempStr;

	dagDAR->GetColLong(&JEPref.arc_entry, ODAR_ABS_ENTRY);
	dagDAR->GetColStr(tempStr, ODAR_JE_BY_PROJ);
	JEPref.byProject = tempStr[0] == VAL_YES[0];
	dagDAR->GetColStr(tempStr, ODAR_JE_BY_PROF);
	JEPref.byProfitCenter = tempStr[0] == VAL_YES[0];

	dagDAR->GetColStr(tempStr, ODAR_JE_BY_DIM2);
	JEPref.byDimension2 = (tempStr == VAL_YES);

	dagDAR->GetColStr(tempStr, ODAR_JE_BY_DIM3);
	JEPref.byDimension3 = (tempStr == VAL_YES);

	dagDAR->GetColStr(tempStr, ODAR_JE_BY_DIM4);
	JEPref.byDimension4 = (tempStr == VAL_YES);

	dagDAR->GetColStr(tempStr, ODAR_JE_BY_DIM5);
	JEPref.byDimension5 = (tempStr == VAL_YES);


	dagDAR->GetColStr(tempStr, ODAR_JE_BY_CURR);
	JEPref.byCurrency = tempStr[0] == VAL_YES[0];
	dagDAR->GetColStr(JEPref.periodLen, ODAR_JE_PERIOD_LEN);
	dagDAR->GetColStr(JEPref.ref1, ODAR_JE_REF1);
	dagDAR->GetColStr(JEPref.ref2, ODAR_JE_REF2);
	dagDAR->GetColStr(JEPref.memo, ODAR_JE_MEMO);
	dagDAR->GetColStr(JEPref.toDate, ODAR_PERIOD_DATE);

	try
	{
		_LOGMSG(logDebugComponent, logNoteSeverity, 
			_T("In CTransactionJournalObject::BeforeDeleteArchivedObject - starting JEComp.execute()"))
		CJECompression	JEComp(GetEnv(), &JEPref);
		sboErr = JEComp.execute();
		if (sboErr)
		{
			_LOGMSG(logDebugComponent, logErrorSeverity, 
				_T("Error in CTransactionJournalObject::BeforeDeleteArchivedObject - error in JEComp.execute()"))
			return sboErr;
		}
		_LOGMSG(logDebugComponent, logNoteSeverity, 
			_T("In CTransactionJournalObject::BeforeDeleteArchivedObject - JEComp.execute() ended successfully"))
	}
	catch (nsDataArchive::CDataArchiveException& e)
	{
		_LOGMSG(logDebugComponent, logErrorSeverity, 
			_T("Error in CTransactionJournalObject::BeforeDeleteArchivedObject - exception was thrown in the Constructor of CJECompression"))
		return e.GetSBOErr();
	}
	
#endif

	return sboErr;
}

/************************************************************************/
/************************************************************************/
SBOErr	CTransactionJournalObject::AfterDeleteArchivedObject (ArcDeletePrefs& arcDelPref)
{
	SBOErr					sboErr = noErr;				
#ifndef MNHL_SERVER_MODE

	try
	{
		PDAG					dagACT = NULL;
		PDAG					dagCRD = NULL;

		sboErr = GLFillActListDAG (&dagACT, GetEnv ());
		if(sboErr)
		{
			_LOGMSG(logDebugComponent, logErrorSeverity, 
				_T("Error in CTransactionJournalObject::AfterDeleteArchivedObject - GLFillActListDAG"))
			return sboErr;
		}

		DBQRetrieveStatement	stmt (GetEnv ());

		DBQTable tCRD = stmt.From (GetEnv().ObjectToTable (CRD));

		stmt.Select ().Col (tCRD, OCRD_CARD_CODE);
		stmt.Select ().Col (tCRD, OCRD_CARD_NAME);
		stmt.Select ().Col (tCRD, OCRD_CARD_TYPE);

		long numOfReturnedRecs = stmt.Execute (&dagCRD);

		_LOGMSG(logDebugComponent, logNoteSeverity, 
			_T("In CTransactionJournalObject::AfterDeleteArchivedObject - starting RBARebuildAccountsAndCardsInternal (dagACT, dagCRD, FALSE)"))
		sboErr = RBARebuildAccountsAndCardsInternal (dagACT, dagCRD, FALSE);
		DAG_Close(dagCRD);
		DAG_Close(dagACT);
		if(sboErr)
		{
			_LOGMSG(logDebugComponent, logErrorSeverity, 
				_T("Error in CTransactionJournalObject::AfterDeleteArchivedObject - RBARebuildAccountsAndCardsInternal"))
			return sboErr;
		}
		_LOGMSG(logDebugComponent, logNoteSeverity, 
			_T("In CTransactionJournalObject::AfterDeleteArchivedObject - RBARebuildAccountsAndCardsInternal (dagACT, dagCRD, FALSE) ended successfully"))
	}
	catch (DBMException& e)
	{
		_LOGMSG(logDebugComponent, logErrorSeverity, 
			_T("Error in CTransactionJournalObject::AfterDeleteArchivedObject - Exception was thrown"))
		return e.GetCode ();
	}
	
#endif

	return sboErr;
}

long CTransactionJournalObject::GetWtSumField(long currSource)
{
    long cols[]={OJDT_WT_SUM, OJDT_WT_SUM_SC, OJDT_WT_SUM_FC};
    return cols[currSource-1];
}

/**************************************************************************************************
FunctionName: UpdateWTInfo
Parameters:
Return:
Remarks: Copy WT information from JDT2 To OJDT and JDT1        
**************************************************************************************************/
SBOErr  CTransactionJournalObject::UpdateWTInfo ()
{
    SBOErr ooErr = ooNoErr;
    CBizEnv& bizEnv = GetEnv();
    PDAG dagJDT = GetDAG(JDT);
    PDAG dagJDT1 = GetDAG(JDT, ao_Arr1);
    MONEY wtSum, wtSumSC, wtSumFC;
    MONEY sum, bpLineWt;
    MONEY debit, credit;
    
    long recCountJDT1 = dagJDT1->GetRecordCount();
    SBOString shortName, account;
    bool isCard;
    LongArray cardRec;
    StdArray<MONEY, False> cardSum;
    StdArray<SBOString, False> cardSide;
    
    SBOString wtSide;
    GetWTCredDebt (wtSide);

    SBOString mainCurr, sysCurr, fcCurr;
    mainCurr = bizEnv.GetMainCurrency();
    sysCurr = bizEnv.GetSystemCurrency();
    dagJDT->GetColStr(fcCurr, OJDT_TRANS_CURR);
    
    for(long rec = 0; rec < recCountJDT1; rec++)
    {
        dagJDT1->GetColStr(shortName, JDT1_SHORT_NAME, rec);
        shortName.Trim();
        dagJDT1->GetColStr(account, JDT1_ACCT_NUM, rec);
        account.Trim();
        isCard = shortName != account;
        if(isCard)    
        {
           cardRec.Add(rec);
           dagJDT1->GetColMoney(&debit, JDT1_DEBIT, rec);
           dagJDT1->GetColMoney(&credit, JDT1_CREDIT, rec);
           bpLineWt = debit == 0 ? credit : debit;         
           if (credit == 0)
           {
               cardSide.Add (VAL_DEBIT);
           }
           else
           {
               cardSide.Add (VAL_CREDIT);
           }
           cardSum.Add(bpLineWt);

           sum += (debit - credit);
        }
    }
    //for calculating percentage
    sum.Abs ();

    // get total wtsum
    dagJDT->GetColMoney(&wtSum, OJDT_WT_SUM);
    dagJDT->GetColMoney(&wtSumSC, OJDT_WT_SUM_SC);
    dagJDT->GetColMoney(&wtSumFC, OJDT_WT_SUM_FC);
    
    long numBP = cardRec.GetSize();
    MONEY sumTmpD , sumTmpSCD, sumTmpFCD;//debit
    MONEY sumTmpC , sumTmpSCC, sumTmpFCC;//credit

    if (numBP <= 0)
    {
        return ooErr;
    }

    long i = 0;
    for(; i < numBP - 1; i++)
    {
        long rec = cardRec[i];

        MONEY precent = cardSum[i].MulAndDiv(100, sum);
        bpLineWt = wtSum.MulAndDiv(precent, 100);
        bpLineWt.Round(RC_SUM, mainCurr, bizEnv);
        dagJDT1->SetColMoney(&bpLineWt, JDT1_WT_SUM, rec);
        if (cardSide[i] == VAL_DEBIT)
        {
            sumTmpD += bpLineWt;
        }
        else
        {
            sumTmpC += bpLineWt;
        }
        
        
        bpLineWt = wtSumSC.MulAndDiv(precent, 100);
        bpLineWt.Round(RC_SUM, sysCurr, bizEnv);
        dagJDT1->SetColMoney(&bpLineWt, JDT1_WT_SUM_SC, rec);
        if (cardSide[i] == VAL_DEBIT)
        {
            sumTmpSCD += bpLineWt;
        }
        else
        {
            sumTmpSCC += bpLineWt;
        }
        
        bpLineWt = wtSumFC.MulAndDiv(precent, 100);
        bpLineWt.Round(RC_SUM, fcCurr, bizEnv);
        dagJDT1->SetColMoney(&bpLineWt, JDT1_WT_SUM_FC, rec);
        if (cardSide[i] == VAL_DEBIT)
        {
            sumTmpFCD += bpLineWt;
        }
        else
        {
            sumTmpFCC += bpLineWt;
        }

    }//end of for

    
    //for the last one. we don't use precent, //rounding 
    //we conside the side of JE Wtax and the last BP line's side.
    MONEY bpLineWtSC, bpLineWtFC;
    if (wtSide == VAL_DEBIT)
    {
        bpLineWt = wtSum - (sumTmpD - sumTmpC);
        bpLineWtSC = wtSumSC - (sumTmpSCD - sumTmpSCC);
        bpLineWtFC = wtSumFC - (sumTmpFCD - sumTmpFCC);
    }
    else
    {
        bpLineWt = wtSum + (sumTmpD - sumTmpC);
        bpLineWtSC = wtSumSC + (sumTmpSCD - sumTmpSCC);
        bpLineWtFC = wtSumFC + (sumTmpFCD - sumTmpFCC);
    }
    if (wtSide != cardSide[i])
    {
        bpLineWt *= -1 ;
        bpLineWtSC *= -1 ;
        bpLineWtFC *= -1 ;
    }
    dagJDT1->SetColMoney(&bpLineWt, JDT1_WT_SUM, cardRec[i]);
    dagJDT1->SetColMoney(&bpLineWtSC, JDT1_WT_SUM_SC, cardRec[i]);
    dagJDT1->SetColMoney(&bpLineWtFC, JDT1_WT_SUM_FC, cardRec[i]);

    return ooErr;
}
/**************************************************************************************************
FunctionName: GetWithHoldingTax
Parameters: installment - transaction row id
Return: WithHoldingTaxSet
Remarks: Get WT Info from JDT2/INV5 to WithHoldingTaxSet        
**************************************************************************************************/
WithHoldingTaxSet	CTransactionJournalObject::GetWithHoldingTax (bool onlyPaymentCateg, long row)
{
    PDAG dagJDT2 = GetArrayDAG (ao_Arr2);
	PDAG dagJDT1 = GetArrayDAG (ao_Arr1);

	// JE total
	CAllCurrencySums docTotal, deb, cred;
	deb.FromDAG (dagJDT1, row, JDT1_DEBIT, JDT1_FC_DEBIT, JDT1_SYS_DEBIT);
	cred.FromDAG (dagJDT1, row, JDT1_CREDIT, JDT1_FC_CREDIT, JDT1_SYS_CREDIT);
	docTotal = deb - cred;
	docTotal.Abs (); // WTax on JE has always positive sign

    return CDocumentObject::GetWTTaxSet (dagJDT2, docTotal, onlyPaymentCateg, row);
}

//////////////////////////////////////////////////////////////////////////
// implementation of IWithholdingAble interface
SBOErr CTransactionJournalObject::LoadObjInfoFromDags (ObjectWTaxInfo &objInfo, PDAG dagObj, PDAG dagWTaxs, PDAG dagObjRows)
{
	SBOErr				sboErr = noErr;
	CAllCurrencySums	deb, cred;

	deb.FromDAG (dagObjRows, objInfo.m_ObjectRow, JDT1_DEBIT, JDT1_FC_DEBIT, JDT1_SYS_DEBIT);
	cred.FromDAG (dagObjRows, objInfo.m_ObjectRow, JDT1_CREDIT, JDT1_FC_CREDIT, JDT1_SYS_CREDIT);
	objInfo.m_DocTotal = deb - cred;
	objInfo.m_DocTotal.Abs ();
	WithHoldingTaxSet tmpWTTaxSet = CDocumentObject::GetWTTaxSet(dagWTaxs, objInfo.m_DocTotal, true);
	objInfo.SetDocWTaxArray (tmpWTTaxSet);

	deb.FromDAG (dagObjRows, objInfo.m_ObjectRow, JDT1_BALANCE_DUE_DEBIT, JDT1_BALANCE_DUE_FC_DEB, JDT1_BALANCE_DUE_SC_DEB);
	cred.FromDAG (dagObjRows, objInfo.m_ObjectRow, JDT1_BALANCE_DUE_CREDIT, JDT1_BALANCE_DUE_FC_CRED, JDT1_BALANCE_DUE_SC_CRED);
	deb -= cred;
	objInfo.m_DocApplied = objInfo.m_DocTotal - deb.AbsVal ();

	dagObj->GetColStr (objInfo.m_DocCurrency, OJDT_TRANS_CURR);
	if (objInfo.m_DocCurrency.IsEmpty ())
	{
		objInfo.m_DocCurrency = objInfo.m_bizEnv.GetMainCurrency ();
	}

	return sboErr;
}

//////////////////////////////////////////////////////////////////////////
// implementing IWithholdingAble
SBOErr CTransactionJournalObject::GetWTaxReconDags (PDAG &dagOBJ, PDAG &dagObjWTax, PDAG &dagObjRows)
{
	dagOBJ = GetDAG ();
	dagObjWTax = GetArrayDAG (ao_Arr2);
	dagObjRows = GetArrayDAG (ao_Arr1);

	return noErr;
}

//////////////////////////////////////////////////////////////////////////
// implementing IWithholdingAble
SBOErr CTransactionJournalObject::CreateDocInfoQry (DBQRetrieveStatement &docInfoQry)
{
	CBizEnv &bizEnv = GetEnv ();
	long	objType = GetID ().strtol ();

	DBQTable tableObj = docInfoQry.From (bizEnv.ObjectToTable (objType, ao_Main));

	// join OJDT -> JDT1
	DBQTable tableObjRow = docInfoQry.Join (bizEnv.ObjectToTable (objType, ao_Arr1), tableObj);
	docInfoQry.On (tableObjRow).Col (tableObj, OJDT_JDT_NUM).EQ ().Col (tableObjRow, JDT1_TRANS_ABS);

	// join OJDT -> JDT2
	DBQTable tableObjWtax = docInfoQry.Join (bizEnv.ObjectToTable (objType, ao_Arr2), tableObj);
	docInfoQry.On (tableObjWtax).Col (tableObj, OJDT_JDT_NUM).EQ ().Col (tableObjWtax, JDT2_ABS_ENTRY)
		.And ().Col (tableObjWtax, JDT2_CATEGORY).EQ ().Val (VAL_CATEGORY_PAYMENT);

	// WTReconPARAM_DOC_ABS_ENT_COL
	docInfoQry.Select().Col (tableObjRow, JDT1_TRANS_ABS);

	// WTReconPARAM_DOC_ROW_ID_COL
	docInfoQry.Select().Col (tableObjRow, JDT1_LINE_ID);

	// WTReconPARAM_DOC_CURRENCY_COL
	docInfoQry.Select ().Max ().Col (tableObj, OJDT_TRANS_CURR).As (OJDT_TRANS_CURR_ALIAS);

	// WTReconPARAM_DOC_TOTAL_LC_COL,
	// WTReconPARAM_DOC_TOTAL_FC_COL,
	// WTReconPARAM_DOC_TOTAL_SC_COL,
	docInfoQry.Select ().Max ().Col (tableObjRow, JDT1_CREDIT).Sub ().Max ().Col (tableObjRow, JDT1_DEBIT).As (JDT1_CREDIT_ALIAS);
	docInfoQry.Select ().Max ().Col (tableObjRow, JDT1_FC_CREDIT).Sub ().Max ().Col (tableObjRow, JDT1_FC_DEBIT).As (JDT1_FC_CREDIT_ALIAS);
	docInfoQry.Select ().Max ().Col (tableObjRow, JDT1_SYS_CREDIT).Sub ().Max ().Col (tableObjRow, JDT1_SYS_DEBIT).As (JDT1_SYS_CREDIT_ALIAS);

	// WTReconPARAM_DOC_APPLIED_LC_COL
	// WTReconPARAM_DOC_APPLIED_FC_COL
	// WTReconPARAM_DOC_APPLIED_SC_COL
	// JDT does not store applied amount but open amount
	docInfoQry.Select ().Max ().Col (tableObjRow, JDT1_CREDIT).Sub ().Max ().Col (tableObjRow, JDT1_DEBIT).Sub ().Max ().Col (tableObjRow, JDT1_BALANCE_DUE_CREDIT).Add ().Max ().Col (tableObjRow, JDT1_BALANCE_DUE_DEBIT).As (JDT1_BALANCE_DUE_CREDIT_ALIAS);
	docInfoQry.Select ().Max ().Col (tableObjRow, JDT1_FC_CREDIT).Sub ().Max ().Col (tableObjRow, JDT1_FC_DEBIT).Sub ().Max ().Col (tableObjRow, JDT1_BALANCE_DUE_FC_CRED).Add ().Max ().Col (tableObjRow, JDT1_BALANCE_DUE_FC_DEB).As (JDT1_BALANCE_DUE_FC_CRED_ALIAS);
	docInfoQry.Select ().Max ().Col (tableObjRow, JDT1_SYS_CREDIT).Sub ().Max ().Col (tableObjRow, JDT1_SYS_DEBIT).Sub ().Max ().Col (tableObjRow, JDT1_BALANCE_DUE_SC_CRED).Add ().Max ().Col (tableObjRow, JDT1_BALANCE_DUE_SC_DEB).As (JDT1_BALANCE_DUE_SC_CRED_ALIAS);

	// WTReconPARAM_WTAX_AMOUNT_LC_COL
	// WTReconPARAM_WTAX_AMOUNT_FC_COL
	// WTReconPARAM_WTAX_AMOUNT_SC_COL
	docInfoQry.Select ().Sum ().Col (tableObjWtax, JDT2_WT_AMOUNT).As (JDT2_WT_AMOUNT_ALIAS);
	docInfoQry.Select ().Sum ().Col (tableObjWtax, JDT2_WT_AMOUNT_FC).As (JDT2_WT_AMOUNT_FC_ALIAS);
	docInfoQry.Select ().Sum ().Col (tableObjWtax, JDT2_WT_AMOUNT_SC).As (JDT2_WT_AMOUNT_SC_ALIAS);

	// WTReconPARAM_WTAX_APPLIED_LC_COL
	// WTReconPARAM_WTAX_APPLIED_FC_COL
	// WTReconPARAM_WTAX_APPLIED_SC_COL
	docInfoQry.Select ().Sum ().Col (tableObjWtax, JDT2_WT_APPLIED_AMOUNT).As (JDT2_WT_APPLIED_AMOUNT_ALIAS);
	docInfoQry.Select ().Sum ().Col (tableObjWtax, JDT2_WT_APPLIED_AMOUNT_FC).As (JDT2_WT_APPLIED_AMOUNT_FC_ALIAS);
	docInfoQry.Select ().Sum ().Col (tableObjWtax, JDT2_WT_APPLIED_AMOUNT_SC).As (JDT2_WT_APPLIED_AMOUNT_SC_ALIAS);

	// unused
	// WTReconPARAM_DOC_TOTAL_OLD_RECON_LC_COL
	// WTReconPARAM_DOC_TOTAL_OLD_RECON_FC_COL
	// WTReconPARAM_DOC_TOTAL_OLD_RECON_SC_COL
	docInfoQry.Select (tableObj, OJDT_LOC_TOTAL).Val (0L).As (_T("DummyCol2"));
	docInfoQry.Select (tableObj, OJDT_FC_TOTAL).Val (0L).As (_T("DummyCol3"));
	docInfoQry.Select (tableObj, OJDT_SYS_TOTAL).Val (0L).As (_T("DummyCol4"));

	docInfoQry.GroupBy (tableObjRow, JDT1_TRANS_ABS);
	docInfoQry.GroupBy (tableObjRow, JDT1_LINE_ID);

	return noErr;
}

/**************************************************************************************************
FunctionName: YouHaveBeenReconciled
Parameters:   CMatchData
Return: 
Remarks:      Override IReconcilable::YouHaveBeenReconciled  
              Update Wt Information when have been reconciled. 
              Similar as CDocumentObject's same function      
**************************************************************************************************/
SBOErr	CTransactionJournalObject::YouHaveBeenReconciled (CMatchData& yourMatchData)
{
    SBOErr ooErr = ooNoErr;
    
    if(VF_JEWHT(GetEnv()))
    {
        ooErr = UpdateWTOnRecon(yourMatchData);
    }    
    
    return ooErr;
}
/**************************************************************************************************
FunctionName: YouHaveUnBeenReconciled
Parameters:   CMatchData
Return: 
Remarks:      Override IReconcilable::UnYouHaveBeenReconciled  
              Update Wt Information when have been unreconciled. 
              Similar as CDocumentObject's same function      
**************************************************************************************************/
SBOErr	CTransactionJournalObject::YouHaveBeenUnReconciled (const CMatchData& yourMatchData)
{
    SBOErr ooErr = ooNoErr;

    if(VF_JEWHT(GetEnv()))
    {
        ooErr = UpdateWTOnCancelRecon(yourMatchData);
    }    

    return ooErr;
}
/**************************************************************************************************
FunctionName: UpdateWTOnRecon
Parameters:   CMatchData
Return: 
Remarks:      same as CDocumentObject::UpdateWTOnRecon    
**************************************************************************************************/
SBOErr	CTransactionJournalObject::UpdateWTOnRecon (CMatchData& yourMatchData)
{
    SBOErr ooErr = ooNoErr;
    CBizEnv& env = GetEnv ();
    
    WithHoldingTaxSet	withholdingCodeSet = GetWithHoldingTax (true); // payment category WHT
    if (withholdingCodeSet.size () == 0)
    {
        // We have no records in JDT2 or they're all of Invoice Category WT
        return ooNoErr;
    }

    PDAG dagJDT2 = GetArrayDAG (ao_Arr2);
    long numOfRecsJDT2 = dagJDT2->GetRealSize (dbmDataBuffer);
    if ((numOfRecsJDT2 > 1 && !VF_AllowMixedWHTCategories (env)) || (withholdingCodeSet.size () > 1))
    {
        // Since we allow reconciliation of invoices with only 1 type of WT code,
        // we should have no more than one record in INV5
        _MEM_MYRPT0 (_T("CDocumentObject::UpdateWTOnRecon - \
                     JDT2 should contain 1 rec at the most for reconciliation!"));
        BOOM;
        return ooInvalidAction;
    }

    MONEY		tmpApplied, paidWT, paidFrgnWT, paidSysWT;
    SBOString	status;

    PDAG	dagJDT1 = GetArrayDAG (ao_Arr1);
    long	offset = yourMatchData.transRowId;

    PDAG dagJDT = GetDAG ();
    
    status = GetJDTReconStatus ();

	long paymCtgWhtRec = 0;
	// find payment category record in INV5 - should be only one, validation does not allow more than 1 payment category
	if (VF_AllowMixedWHTCategories (env))
	{
		SBOString whtCategory;
		for (paymCtgWhtRec=0; paymCtgWhtRec<numOfRecsJDT2; paymCtgWhtRec++)
		{
			dagJDT2->GetColStr (whtCategory, JDT2_CATEGORY, paymCtgWhtRec);
			whtCategory.Trim ();
			if (whtCategory == VAL_CATEGORY_PAYMENT)
			{
				break;
			}
		}
	}

    if (status == VAL_CLOSE)
    {
        // We need the WT paid sums in order to set the paid amounts in the MatchData:
        dagJDT2->GetColMoney (&paidWT, INV5_WT_AMOUNT, paymCtgWhtRec);
        dagJDT2->GetColMoney (&tmpApplied, INV5_WT_APPLIED_AMOUNT, paymCtgWhtRec);
        dagJDT2->SetColMoney (&paidWT, INV5_WT_APPLIED_AMOUNT, paymCtgWhtRec);
        paidWT -= tmpApplied;

        dagJDT2->GetColMoney (&paidFrgnWT, INV5_WT_AMOUNT_FC, paymCtgWhtRec);
        dagJDT2->GetColMoney (&tmpApplied, INV5_WT_APPLIED_AMOUNT_FC, paymCtgWhtRec);
        dagJDT2->SetColMoney (&paidFrgnWT, INV5_WT_APPLIED_AMOUNT_FC, paymCtgWhtRec);
        paidFrgnWT -= tmpApplied;

        dagJDT2->GetColMoney (&paidSysWT, INV5_WT_AMOUNT_SC, paymCtgWhtRec);
        dagJDT2->GetColMoney (&tmpApplied, INV5_WT_APPLIED_AMOUNT_SC, paymCtgWhtRec);
        dagJDT2->SetColMoney (&paidSysWT, INV5_WT_APPLIED_AMOUNT_SC, paymCtgWhtRec);
        paidSysWT -= tmpApplied;


        dagJDT1->CopyColumn (dagJDT1, JDT1_WT_APPLIED, offset, JDT1_WT_SUM, offset);
        dagJDT1->CopyColumn (dagJDT1, JDT1_WT_APPLIED_FC, offset, JDT1_WT_SUM_FC, offset);
        dagJDT1->CopyColumn (dagJDT1, JDT1_WT_APPLIED_SC, offset, JDT1_WT_APPLIED_SC, offset);
       
        dagJDT->CopyColumn (dagJDT, OJDT_WT_APPLIED, 0, OJDT_WT_SUM, 0);
        dagJDT->CopyColumn (dagJDT, OJDT_WT_SUM_SC, 0, OJDT_WT_SUM_SC, 0);
        dagJDT->CopyColumn (dagJDT, OJDT_WT_SUM_FC, 0, OJDT_WT_SUM_FC, 0); 
    } 
    else
    {

        Currency mainCurrency, sysCurrency, docCurrency;
        _STR_strcpy (mainCurrency, env.GetMainCurrency ());
        _STR_strcpy (sysCurrency , env.GetSystemCurrency());
        
        dagJDT->GetColStr (docCurrency, OJDT_TRANS_CURR);
        if (_STR_IsSpacesStr (docCurrency))
        {
            _STR_strcpy (docCurrency, mainCurrency);
        }

        //LC WT 
        dagJDT2->GetColMoney (&tmpApplied, INV5_WT_APPLIED_AMOUNT, paymCtgWhtRec);
        paidWT = yourMatchData.WTSum;
        tmpApplied += paidWT;
        dagJDT2->SetColMoney (&tmpApplied, INV5_WT_APPLIED_AMOUNT, paymCtgWhtRec);

        //FC WT
        dagJDT2->GetColMoney (&tmpApplied, INV5_WT_APPLIED_AMOUNT_FC, paymCtgWhtRec);
        paidFrgnWT = yourMatchData.WTSumFC;
        tmpApplied += paidFrgnWT;
        dagJDT2->SetColMoney (&tmpApplied, INV5_WT_APPLIED_AMOUNT_FC, paymCtgWhtRec);

        //SC WT
        dagJDT2->GetColMoney (&tmpApplied, INV5_WT_APPLIED_AMOUNT_SC, paymCtgWhtRec);
        paidSysWT = yourMatchData.WTSumSC;
        tmpApplied += paidSysWT;
        dagJDT2->SetColMoney (&tmpApplied, INV5_WT_APPLIED_AMOUNT_SC, paymCtgWhtRec);

        // Update the JDT1:
        dagJDT1->GetColMoney (&tmpApplied, JDT1_WT_APPLIED, offset);
        tmpApplied += paidWT;
        dagJDT1->SetColMoney (&tmpApplied, JDT1_WT_APPLIED, offset);

        dagJDT1->GetColMoney (&tmpApplied, JDT1_WT_APPLIED_FC, offset);
        tmpApplied += paidFrgnWT;
        dagJDT1->SetColMoney (&tmpApplied, JDT1_WT_APPLIED_FC, offset);

        dagJDT1->GetColMoney (&tmpApplied, JDT1_WT_APPLIED_SC, offset);
        tmpApplied += paidSysWT;
        dagJDT1->SetColMoney (&tmpApplied, JDT1_WT_APPLIED_SC, offset);
        
        // update OJDT:
        dagJDT->GetColMoney (&tmpApplied, OJDT_WT_APPLIED, offset);
        tmpApplied += paidWT;
        dagJDT->SetColMoney (&tmpApplied, OJDT_WT_APPLIED, offset);

        dagJDT->GetColMoney (&tmpApplied, OJDT_WT_APPLIED_FC, offset);
        tmpApplied += paidFrgnWT;
        dagJDT->SetColMoney (&tmpApplied, OJDT_WT_APPLIED_FC, offset);

        dagJDT->GetColMoney (&tmpApplied, OJDT_WT_APPLIED_SC, offset);
        tmpApplied += paidSysWT;
        dagJDT->SetColMoney (&tmpApplied, OJDT_WT_APPLIED_SC, offset);
    }
    
    ooErr = dagJDT1->Update ();
    IF_ERROR_RETURN (ooErr);
    ooErr = dagJDT1->Update(offset);
    IF_ERROR_RETURN (ooErr);
    ooErr = dagJDT2->Update (paymCtgWhtRec);
    IF_ERROR_RETURN (ooErr);

    return ooNoErr; 
 } 
 /**************************************************************************************************
 FunctionName: GetJDTReconStatus
 Parameters:   CMatchData
 Return: 
 Remarks:      Check whether the JDT were full paid.    
 **************************************************************************************************/
SBOString CTransactionJournalObject::GetJDTReconStatus () 
{
    PDAG dagJDT1 = GetArrayDAG (ao_Arr1);
    long numRec = dagJDT1->GetRecordCount();
    SBOString acctCode, shrtName;
    MONEY mny;
    bool creditSide = false;
    
    for(long rec = 0; rec < numRec; rec++)
    {
        dagJDT1->GetColStr(acctCode, JDT1_ACCT_NUM, rec);
        dagJDT1->GetColStr(shrtName, JDT1_SHORT_NAME, rec);
        if(acctCode == shrtName)
        {
            continue;
        }
        dagJDT1->GetColMoney(&mny, JDT1_DEBIT, rec);
        if(mny.IsZero())
        {
            creditSide = true;
        }
        long balDueCol = creditSide ? JDT1_BALANCE_DUE_CREDIT : JDT1_BALANCE_DUE_DEBIT;
        dagJDT1->GetColMoney(&mny, balDueCol, rec);
        if(!mny.IsZero())
        {
            return VAL_OPEN;
        }
    }     
    return VAL_CLOSE;       
}

/**************************************************************************************************
FunctionName: CalcPaidRatioOfOpenDoc
Parameters:   transRowId - specifies the JDT1 rec being paid
Return: 
Remarks:      same as CDOCument::CalcPaidRatioOfOpenDoc 
**************************************************************************************************/
MONEY	CTransactionJournalObject::CalcPaidRatioOfOpenDoc (CAllCurrencySums paidSum, bool paidSumInLocal, long transRowId, bool calcFromTotal)
{
    PDAG		dagJDT = GetDAG();
	PDAG		dagJDT1 = GetArrayDAG (ao_Arr1);
    CAllCurrencySums		total, tmpMny;
    SBOString	mainCurrency, docCurrency;
    bool		local = true;
        
    dagJDT->GetColStr (docCurrency, OINV_DOC_CURRENCY);
    mainCurrency = GetEnv ().GetMainCurrency ();
   	CCurrency tmpDocCur(docCurrency), tmpMainCur(mainCurrency);
	bool calcFromLocal = IWithHoldingAble::IsInLocalCurrency (paidSumInLocal, tmpDocCur, tmpMainCur);

	if (calcFromTotal)
	{
		total.FromDAG (dagJDT1, transRowId, JDT1_DEBIT, JDT1_FC_DEBIT, JDT1_SYS_DEBIT);
		tmpMny.FromDAG (dagJDT1, transRowId, JDT1_CREDIT, JDT1_FC_CREDIT, JDT1_SYS_CREDIT);
		total -= tmpMny;
		total.Abs ();
	}
	else
	{
		total.FromDAG (dagJDT1, transRowId, JDT1_BALANCE_DUE_DEBIT, JDT1_BALANCE_DUE_FC_DEB, JDT1_BALANCE_DUE_SC_DEB);
		tmpMny.FromDAG (dagJDT1, transRowId, JDT1_BALANCE_DUE_CREDIT, JDT1_BALANCE_DUE_FC_CRED, JDT1_BALANCE_DUE_SC_CRED);
		total -= tmpMny;
		total.Abs ();
	}

	return	IWithHoldingAble::CalcPaidRatioOfOpenDocInt (paidSum, paidSumInLocal, total, calcFromLocal);;
}

/**************************************************************************************************
FunctionName:   OnCanJDT2Update
Parameters:   
Return: 
Remarks:        Check Whether JDT2 can be updated        
**************************************************************************************************/
SBOErr CTransactionJournalObject::OnCanJDT2Update()
{
    SBOErr ooErr = ooNoErr;
    DBM_OUP*	oopp = GetOnUpdateParams (); 
    return ooNoErr;
        
    for (long i=0; i < oopp->colsList.GetSize(); i++)
    {
        switch (oopp->colsList[i]->GetColNum())
        {
            case INV5_WT_APPLIED_AMOUNT:
            case INV5_WT_APPLIED_AMOUNT_SC:
            case INV5_WT_APPLIED_AMOUNT_FC:
                return ooNoErr;
                
            default:
                SetErrorField( oopp->colsList[i]->GetColNum ());
                SetErrorLine( -1);
                return dbmColumnNotUpdatable;        
        }
     }
     
     return ooNoErr;
}


/***********************************************************************************
// UpdateWTOnCancelRecon
// Update the WT applied fields when Canceling a Reconciliation with the amounts we 
kept// in ITR1 (brought by the match data).
// Update is done for Payment Category WT type only.
/***********************************************************************************/
SBOErr	CTransactionJournalObject::UpdateWTOnCancelRecon (const CMatchData& yourMatchData)
{
    _TRACER("UpdateWTOnCancelRecon");
    SBOErr ooErr;

    WithHoldingTaxSet	withholdingCodeSet = GetWithHoldingTax (true); // payment category
    if (withholdingCodeSet.size () == 0)
    {
        // We have no records in INV5 or they're all of Invoice Category WT
        return ooNoErr;
    }

    PDAG dagJDT2 = GetArrayDAG (ao_Arr2);
    long numOfRecsJDT2 = dagJDT2->GetRealSize (dbmDataBuffer);
    if ((numOfRecsJDT2 > 1 && !VF_AllowMixedWHTCategories (GetEnv ())) || (withholdingCodeSet.size () > 1))
    {
        // Since we allow reconciliation of invoices with only 1 type of WT code,
        // we should have no more than one record in INV5
        _MEM_MYRPT0 (_T("CDocumentObject::UpdateWTOnCancelRecon \
                      - DOC5 should contain 1 rec at the most for reconciliation!"));
        BOOM;
        return ooInvalidAction;
    }

	long paymCtgWhtRec = 0;
	// find payment category record in INV5 - should be only one, validation does not allow more than 1 payment category
	if (VF_AllowMixedWHTCategories (GetEnv ()))
	{
		SBOString whtCategory;
		for (paymCtgWhtRec=0; paymCtgWhtRec<numOfRecsJDT2; paymCtgWhtRec++)
		{
			dagJDT2->GetColStr (whtCategory, JDT2_CATEGORY, paymCtgWhtRec);
			whtCategory.Trim ();
			if (whtCategory == VAL_CATEGORY_PAYMENT)
			{
				break;
			}
		}
	}

	MONEY	tmpApplied;
	CAllCurrencySums	wtApplied (yourMatchData.WTSum, yourMatchData.WTSumFC, yourMatchData.WTSumSC);

    dagJDT2->GetColMoney (&tmpApplied, INV5_WT_APPLIED_AMOUNT, paymCtgWhtRec);
    tmpApplied += wtApplied.m_SumLc;
    dagJDT2->SetColMoney (&tmpApplied, INV5_WT_APPLIED_AMOUNT, paymCtgWhtRec);

    dagJDT2->GetColMoney (&tmpApplied, INV5_WT_APPLIED_AMOUNT_FC, paymCtgWhtRec);
    tmpApplied += wtApplied.m_SumFc;
    dagJDT2->SetColMoney (&tmpApplied, INV5_WT_APPLIED_AMOUNT_FC, paymCtgWhtRec);

    dagJDT2->GetColMoney (&tmpApplied, INV5_WT_APPLIED_AMOUNT_SC, paymCtgWhtRec);
    tmpApplied += wtApplied.m_SumSc;
    dagJDT2->SetColMoney (&tmpApplied, INV5_WT_APPLIED_AMOUNT_SC, paymCtgWhtRec);


    // Update JDT rows:
    PDAG	dagJDT1 = GetArrayDAG (ao_Arr1);
    long	offset = yourMatchData.transRowId;

    dagJDT1->GetColMoney (&tmpApplied, JDT1_WT_APPLIED, offset);
    tmpApplied += wtApplied.m_SumLc;
    dagJDT1->SetColMoney (&tmpApplied, JDT1_WT_APPLIED, offset);

    dagJDT1->GetColMoney (&tmpApplied, JDT1_WT_APPLIED_FC, offset);
    tmpApplied += wtApplied.m_SumFc;
    dagJDT1->SetColMoney (&tmpApplied, JDT1_WT_APPLIED_FC, offset);

    dagJDT1->GetColMoney (&tmpApplied, JDT1_WT_APPLIED_SC, offset);
    tmpApplied += wtApplied.m_SumSc;
    dagJDT1->SetColMoney (&tmpApplied, JDT1_WT_APPLIED_SC, offset);

    //update OJDT
    PDAG dagJDT = GetDAG();
    dagJDT->GetColMoney (&tmpApplied, OJDT_WT_APPLIED, offset);
    tmpApplied += wtApplied.m_SumLc;
    dagJDT->SetColMoney (&tmpApplied, OJDT_WT_APPLIED, offset);

    dagJDT->GetColMoney (&tmpApplied, OJDT_WT_APPLIED_FC, offset);
    tmpApplied += wtApplied.m_SumFc;
    dagJDT->SetColMoney (&tmpApplied, OJDT_WT_APPLIED_FC, offset);

    dagJDT->GetColMoney (&tmpApplied, OJDT_WT_APPLIED_SC, offset);
    tmpApplied += wtApplied.m_SumSc;
    dagJDT->SetColMoney (&tmpApplied, OJDT_WT_APPLIED_SC, offset);
    
    ooErr = dagJDT->Update ();
    IF_ERROR_RETURN (ooErr);    
    ooErr = dagJDT1->Update(offset);
    IF_ERROR_RETURN (ooErr);
    ooErr = dagJDT2->Update (paymCtgWhtRec);
    IF_ERROR_RETURN (ooErr);

    return ooNoErr;
}

/**
* CheckWTValid
* 
* Check the WT and BP Side, They should at the same side
* @return ooNoErr on success.
*/
SBOErr CTransactionJournalObject::CheckWTValid()
{
		_TRACER("CheckWTValid");
    SBOErr ooErr = ooNoErr;
    
    PDAG dagJDT = GetDAG(JDT);
    PDAG dagJDT1 = GetDAG(JDT, ao_Arr1);
    PDAG dagJDT2 = GetDAG(JDT, ao_Arr2);
    SBOString tmpStr, acctNum, shortName;
    MONEY tmpMny, mnyBPDebit, mnyBPCred;
    bool isBpCredit, hasBPline = false, hasLiableline = false;
    
    dagJDT->GetColStr(tmpStr, OJDT_AUTO_WT);
    if(tmpStr[0] == VAL_NO[0])
    {
        return ooNoErr;        
    }
    
    long recCount = dagJDT1->GetRealSize(dbmDataBuffer);
    
    for(long rec = 0; rec < recCount; rec++)
    {
        dagJDT1->GetColStr(acctNum, JDT1_ACCT_NUM, rec);
        dagJDT1->GetColStr(shortName, JDT1_SHORT_NAME, rec);
       
        if(acctNum.Trim() != shortName.Trim())
        {
            //is bp line
            hasBPline = true;
            dagJDT1->GetColMoney(&tmpMny, JDT1_DEBIT, rec);
            mnyBPDebit += tmpMny;
            
            dagJDT1->GetColMoney(&tmpMny, JDT1_CREDIT, rec);
            mnyBPCred += tmpMny;         
        }
    }
    
    SBOString bpDebCre; 
    if(mnyBPCred >= mnyBPDebit)
    {
        isBpCredit = true;
        bpDebCre = VAL_CREDIT;
    }
    else
    {
        isBpCredit = false;
        bpDebCre = VAL_DEBIT;
    }
    
    SBOString wtDebCre; 
    GetWTCredDebt (wtDebCre );
    
    MONEY baseAmt;
    dagJDT->GetColMoney(&baseAmt, OJDT_WT_BASE_AMOUNT);
    long numJdt2Rec = dagJDT2->GetRecordCount();
    if(hasBPline && (!baseAmt.IsZero()) && (bpDebCre != wtDebCre) && numJdt2Rec > 0)
    {
        return dbdError;
    }
    return ooErr;
}
/**
* GetWTBaseNetAmountField
* 
* Check the WT and BP Side, They should at the same side
* @return ooNoErr on success.
*/
long CTransactionJournalObject::GetWTBaseNetAmountField(long curr)
{
    long column;
    switch (curr)
    {
    case JDT_WT_LOCAL_CURRENCY:
        column = OJDT_WT_BASE_AMOUNT;    
        break;

    case JDT_WT_SYS_CURRENCY:
        column = OJDT_WT_BASE_AMOUNT_SC; 
        break;

    case JDT_WT_FC_CURRENCY:
        column = OJDT_WT_BASE_AMOUNT_FC; 
        break;
    }

    return column;
}

/**
* GetWTBaseVATAmountField
* 
* Check the WT and BP Side, They should at the same side
* @return ooNoErr on success.
*/
long CTransactionJournalObject::GetWTBaseVATAmountField(long curr)
{
    long column;
    switch (curr)
    {
    case JDT_WT_LOCAL_CURRENCY:
        column = OJDT_WT_BASE_VAT_AMNT;    
        break;

    case JDT_WT_SYS_CURRENCY:
        column = OJDT_WT_BASE_VAT_AMNT_SC; 
        break;

    case JDT_WT_FC_CURRENCY:
        column = OJDT_WT_BASE_VAT_AMNT_FC; 
        break;
    }

    return column;
}

/**
/**************************************************************************************************
/* Check MultiBP
/* 
/* 
/**************************************************************************************************
*/
SBOErr  CTransactionJournalObject::CheckMultiBP()
{
		_TRACER("CheckMultiBP");
    PDAG dagJDT = GetDAG(JDT);
    PDAG dagJDT1 = GetDAG(JDT, ao_Arr1);
    
    SBOString autoWT;
    dagJDT->GetColStr(autoWT, OJDT_AUTO_WT);
    if(autoWT == VAL_YES)
    {
        long recJDT1 = dagJDT1->GetRealSize (dbmDataBuffer);
        SBOString acct, shortname, firstBP;
        
        for(long rec = 0; rec < recJDT1; rec++)
        {
            dagJDT1->GetColStr(acct, JDT1_ACCT_NUM, rec);
            dagJDT1->GetColStr(shortname, JDT1_SHORT_NAME, rec);
            acct.Trim();
            shortname.Trim();
            if(acct != shortname)    
            {
                //a bp line;
                if(!firstBP.IsEmpty())
                {
                    if(firstBP != shortname)
                    {
                        //multi bp
                        return ooInvalidObject; 
                    }
                }else{
                    firstBP = shortname;
                }
            }
        }
    }
    return ooNoErr;
}

/**
/**************************************************************************************************
/* WTGetBPCodeImp
/**************************************************************************************************   
*/
SBOString CTransactionJournalObject::WTGetBPCodeImp(PDAG dagJDT, PDAG dagJDT1)
{
    SBOString autoWT;
	dagJDT->GetColStr (autoWT, OJDT_AUTO_WT);
	autoWT.Trim ();
	if(autoWT == VAL_YES)
	{
		long recJDT1 = dagJDT1->GetRealSize (dbmDataBuffer);
		SBOString acct, shortname;//, firstBP;

		for(long rec = 0; rec < recJDT1; rec++)
		{
			dagJDT1->GetColStr(acct, JDT1_ACCT_NUM, rec);
			dagJDT1->GetColStr(shortname, JDT1_SHORT_NAME, rec);
			acct.Trim();
			shortname.Trim();
			if(acct != shortname)    
			{
				//a bp line;
				return shortname;
			}
		}
	}

	return EMPTY_STR;
}

/**
 * get BP's code (wht in JE)
 * 
 */
SBOString CTransactionJournalObject::WTGetBpCode ()
{
		_TRACER("WTGetBpCode");
	PDAG dagJDT = GetDAG (JDT);
	PDAG dagJDT1 = GetDAG (JDT, ao_Arr1);

	return WTGetBPCodeImp(dagJDT, dagJDT1);
}

/**
/**************************************************************************************************
/* WTGetCurrencyImp
/**************************************************************************************************   
*/
SBOString CTransactionJournalObject::WTGetCurrencyImp(PDAG dagJDT, PDAG dagJDT1)
{
    SBOString autoWT;
    dagJDT->GetColStr (autoWT, OJDT_AUTO_WT);
    autoWT.Trim ();
    if(autoWT == VAL_YES)
    {
        long recJDT1 = dagJDT1->GetRealSize (dbmDataBuffer);
        SBOString acct, shortname, curr;

        for(long rec = 0; rec < recJDT1; rec++)
        {
            dagJDT1->GetColStr (acct, JDT1_ACCT_NUM, rec);
            dagJDT1->GetColStr (shortname, JDT1_SHORT_NAME, rec);
            dagJDT1->GetColStr (curr, JDT1_FC_CURRENCY, rec);
            acct.Trim ();
            shortname.Trim ();
            curr.Trim ();
            if(acct != shortname)    
            {
                //a BP line;
                return curr;
            }
        }
    }

    return EMPTY_STR; 
}
/**
* get BP's Currency (wht in JE)
* 
*/
SBOString  CTransactionJournalObject::WTGetCurrency () 
{
		_TRACER("WTGetBpCode");
		PDAG dagJDT = GetDAG (JDT);
		PDAG dagJDT1 = GetDAG (JDT, ao_Arr1);

		return WTGetCurrencyImp(dagJDT, dagJDT1);
}

/**
/**************************************************************************************************
/* GetDfltWTCodes
/*
/* Similar as  JTE_LoadPrefsFromCard
/**************************************************************************************************   
*/
SBOErr CTransactionJournalObject::GetDfltWTCodes(CJDTWTInfo* wtInfo)
{
    return  CDocumentObject::ODOCLoadWTPrefsFromCard(*this, 
                                                    &wtInfo->cardWTLiable, 
                                                    wtInfo->wtDefaultCode, 
                                                    wtInfo->VATwtDefaultCode,
                                                    wtInfo->ITwtDefaultCode,
                                                    wtInfo->wtBaseType, 
                                                    wtInfo->wtCategory);
    
}

/**
/**************************************************************************************************
/* GetBPCurrencySource
/*
/* 
/**************************************************************************************************   
*/
long CTransactionJournalObject::GetBPCurrencySource()
{
    SBOString currency = WTGetCurrency ();
    SBOString mainCurr = m_env.GetMainCurrency();
    SBOString sysCurr = m_env.GetSystemCurrency();

    if(currency == mainCurr
		|| EMPTY_STR == currency
		|| BAD_CURRENCY_STR == currency)
    {
        return JDT_WT_LOCAL_CURRENCY;
    }
    if(currency == sysCurr)
    {
        return JDT_WT_SYS_CURRENCY;
    }
    
    return JDT_WT_FC_CURRENCY;
}

/**
/**************************************************************************************************
/* GetBPCurrency
/*
/* Similar as  JTE_WTGetCurrency
/**************************************************************************************************   
*/
SBOString   CTransactionJournalObject::GetBPLineCurrency()
{
    PDAG dagJDT1 = GetDAG(JDT, ao_Arr1);
    long recCount = dagJDT1->GetRealSize(dbmDataBuffer);
    SBOString acctCode, shortName, bpCurr;
    SBOString currency = m_env.GetMainCurrency();
    
    for(long rec = 0; rec < recCount; rec++)    
    {
        dagJDT1->GetColStr(acctCode, JDT1_ACCT_NUM, rec);
        acctCode.Trim();
        dagJDT1->GetColStr(shortName, JDT1_SHORT_NAME, rec);
        shortName.Trim();
        
        if(shortName != acctCode)//it's a bp line
        {
            dagJDT1->GetColStr(bpCurr, JDT1_FC_CURRENCY, rec);
            if(bpCurr.Trim() != EMPTY_STR)
            {
                currency = bpCurr;
                break;
            }
        }   
    }
    
    return currency;
}


/**
* Set Currency rate in the OINV dag, 
* OINV_SYSTEM_RATE & OINV_DOC_RATE
* 
* there is no SYSTEM_RATE or DOC_RATE in OJDT, when we 
*/
SBOErr  CTransactionJournalObject::SetCurrRateForDOC (PDAG dagDOC)
{

	SBOErr		ooErr = noErr;
	CBizEnv&	env = GetEnv ();
	//Currency	currency;
	MONEY		rate, rateVal1;
	PDAG		dagJDT = GetDAG (JDT);

	if (!DAG::IsValid(dagDOC))
	{
		return ooErrNoMsg;
	}

	//set BP foreign currency rate
	dagDOC->GetColMoney (&rate, OINV_DOC_RATE);
	if (rate.IsZero ())
	{
		//calculate the rate manually according the amount of BP line
		// in case the fixed rate 
		if (CalcBpCurrRateForDocRate (rate) == ooErr)
		{
			dagDOC->SetColMoney (&rate, OINV_DOC_RATE);
		}
		else
		{
			//nsDocument::ODOCGetAndWaitUntilRateByDag (cardCurrency, dagJDT, &rate, env);
		}
	}

	//set sys rate
	ooErr = SetSysCurrRateForDOC (dagDOC);

	return ooErr;
}
/**
 * Set Currency for AutoCompleteDOC5
 * 
 * 
 */
SBOErr  CTransactionJournalObject::SetCurrForAutoCompleteDOC5 ()
{
	switch (WTGetCurrSource())
	{
	case INV_LOCAL_CURRENCY :
		{
			m_WithholdingTaxMng.m_curSourceForAutoComplete[0] = INV_LOCAL_CURRENCY;
			m_WithholdingTaxMng.m_curSourceForAutoComplete[1] = INV_SYSTEM_CURRENCY;
			m_WithholdingTaxMng.m_curSourceForAutoComplete[2] = INV_CARD_CURRENCY;
			break;
		}
	case INV_SYSTEM_CURRENCY :
		{
			m_WithholdingTaxMng.m_curSourceForAutoComplete[0] = INV_SYSTEM_CURRENCY;
			m_WithholdingTaxMng.m_curSourceForAutoComplete[1] = INV_CARD_CURRENCY;
			m_WithholdingTaxMng.m_curSourceForAutoComplete[2] = INV_LOCAL_CURRENCY;
			break;
		}
	case INV_CARD_CURRENCY :
		{
			m_WithholdingTaxMng.m_curSourceForAutoComplete[0] = INV_CARD_CURRENCY;
			m_WithholdingTaxMng.m_curSourceForAutoComplete[1] = INV_LOCAL_CURRENCY;
			m_WithholdingTaxMng.m_curSourceForAutoComplete[2] = INV_SYSTEM_CURRENCY;
			break;
		}
	}

	return ooNoErr;
}
/**
/**************************************************************************************************
/* PrePareDataForWT
/*
/* Similar as  JTE_PrepareDataForWT
/**************************************************************************************************   
*/
SBOErr CTransactionJournalObject::PrePareDataForWT(CWTAllCurBaseCalcParams* wtAllCurBaseCalcParamsPtr,
                                                    long currSource, PDAG dagDOC, CJDTWTInfo* wtInfo)
{
    SBOErr ooErr = ooNoErr;
    PDAG dagJDT = GetDAG(JDT);
    
    CWTBaseCalcParams* baseCalcParam = wtAllCurBaseCalcParamsPtr->GetWtBaseCalcParams(currSource);
    
    GetCRDDag();
    
    GetDfltWTCodes(wtInfo);

    if(!dagDOC->GetRecordCount())
    {
        dagDOC->SetSize(1, dbmDropData);
    } 
    
    //set currency
    dagDOC->SetColStr(GetBPLineCurrency(), OINV_DOC_CURRENCY);
    //set date
    dagDOC->CopyColumn(dagJDT, OINV_DATE, 0, OJDT_REF_DATE, 0);
    
    if(m_env.IsLocalSettingsFlag(lsf_EnableLA1WHT))
    {
        dagDOC->SetColMoney(&baseCalcParam->m_wtBaseNetAmount, nsDocument::ODOCGetWTBaseNetAmountField(currSource));
        dagDOC->SetColMoney(&baseCalcParam->m_wtBaseVATAmount, nsDocument::ODOCGetWTBaseVatAmountField(currSource));

    }else{
        MONEY wtBaseAmount = baseCalcParam->GetWTBaseAmount(wtInfo->wtBaseType);
        dagDOC->SetColMoney(&wtBaseAmount, nsDocument::ODOCGetWTBaseAmountField(currSource));
    }    
      
	SetCurrRateForDOC (dagDOC);

	//set Currency For Auto COmplete DOC5
	SetCurrForAutoCompleteDOC5 ();

	// set m_dagDOC5BefAutoComplete
	CWTCompleteDOC5Params cplPara;
	ooErr = m_WithholdingTaxMng.ODOCAutoCompleteDOC5 (*this, cplPara);
	if (ooErr)
	{
		Message (cplPara.errNode.strId, cplPara.errNode.index, NULL, OO_ERROR);	
		return ooErr;
	}

    return ooErr;
}

/**
/**************************************************************************************************
/* JDTCalcWTTable
/*
/* Similar as  ODOCCalcWTTable calculate the wt table
/**************************************************************************************************   
*/
SBOErr CTransactionJournalObject::JDTCalcWTTable(CJDTWTInfo* wtInfo, long currSource, PDAG dagDOC,
                                                 CWTAllCurBaseCalcParams *wtAllCurBaseCalcParamsPtr) 
                                                 
{
    SBOErr ooErr = ooNoErr;
    
    CWTBaseCalcParams* wtCurBaseCalcParamsPtr = 
                        wtAllCurBaseCalcParamsPtr->GetWtBaseCalcParams(currSource);
                        
    CWTTableChangeList *wtInParamTableChangeListPtr = NULL;
    MONEY wtTotalAmountM;
                        
    //set default wt code
    CWTTableDefaultCodes wtTableDefaultCodes;				
    if (m_env.IsLocalSettingsFlag(lsf_EnableLA1WHT))
    {					
        wtTableDefaultCodes.SetVATWtDefaultcode(wtInfo->VATwtDefaultCode);
        wtTableDefaultCodes.SetITWtDefaultcode(wtInfo->ITwtDefaultCode);
    }
    else
    {					
        wtTableDefaultCodes.SetWtDefaultcode(wtInfo->wtDefaultCode);
    }

    m_WithholdingTaxMng.ODOCCalcWTTable (*this, wtCurBaseCalcParamsPtr, 
                                        wtInParamTableChangeListPtr, 
                                        wtTableDefaultCodes,
                                        currSource, &wtTotalAmountM, 
										-1,
										dagDOC);
                                        
    return ooErr;                                        
}

/**
/**************************************************************************************************
/* GetJDT1MoneyCol
/*
/* Similar as  JTE_GetMoneyCol
/**************************************************************************************************   
*/
long CTransactionJournalObject::GetJDT1MoneyCol(long currSource, bool isDebit)
{
    long cols[][2] = {{JDT1_DEBIT, JDT1_CREDIT}, {JDT1_SYS_DEBIT, JDT1_SYS_CREDIT}, {JDT1_FC_DEBIT, JDT1_FC_CREDIT}};
    return cols[currSource-1][isDebit ? 0: 1];    
}

/**
/**************************************************************************************************
/* GetVATMoneyCol
/*
/* Similar as  JTE_GetVATMoneyCol
/**************************************************************************************************   
*/
long CTransactionJournalObject::GetVATMoneyCol(long currSource)
{
    long cols[] = {JDT1_TOTAL_TAX, JDT1_SYS_TOTAL_TAX, JDT1_TOTAL_TAX,};
    return cols[currSource-1];    
}

/**
/*****************************************************************************
/* GETWTCredDebt
/*
/* Get the direction of wt line 
/* Similar with  JTE_GetWTCredDebt()
/*****************************************************************************
*/
SBOErr CTransactionJournalObject::GetWTCredDebt (SBOString& debCre )
{
	_TRACER ("GETWTCredDebt");
	SBOErr ooErr = ooNoErr;
	PDAG dagJDT1 = GetDAG(JDT, ao_Arr1);
    PDAG dagJDT2 = GetDAG(JDT, ao_Arr2);
	long recCount = dagJDT1->GetRealSize(dbmDataBuffer);
	SBOString wtLiable;
    MONEY debitSumNet, creditSumNet, debitSumVat, creditSumVat;
    MONEY tmpDebAmt, tmpCreAmt, tmpVatAmt;
    MONEY debitSum, creditSum;

	if (!DAG::IsValid (dagJDT1) )
	{
		return ooErrNoMsg;
	}

	for(long rec = 0; rec < recCount; rec++)
	{
		dagJDT1->GetColStr(wtLiable, JDT1_WT_LIABLE, rec);
		
		if(wtLiable.Trim() == VAL_YES)   
		{
			dagJDT1->GetColMoney(&tmpDebAmt, JDT1_DEBIT, rec);
			debitSumNet += tmpDebAmt;
			dagJDT1->GetColMoney (&tmpCreAmt, JDT1_CREDIT, rec);
			creditSumNet += tmpCreAmt;

            dagJDT1->GetColMoney (&tmpVatAmt, JDT1_TOTAL_TAX, rec);
            if (!tmpDebAmt.IsZero())
            {
                debitSumVat += tmpVatAmt;
            }
            else if (!tmpCreAmt.IsZero())
            {
                creditSumVat += tmpVatAmt;
            }
		}
	}

    if(dagJDT2->GetRecordCount()>0)
	{
		SBOString wtBaseType;
		dagJDT2->GetColStr(wtBaseType, INV5_BASE_TYPE);

		if (VAL_BASETYPE_NET == wtBaseType)
		{
			debitSum = debitSumNet;
			creditSum = creditSumNet;
		}
		else if (VAL_BASETYPE_VAT == wtBaseType) //(bizEnv.IsLocalSettingsFlag(lsf_EnableLA1WHT)
		{
			debitSum = debitSumVat;
			creditSum = creditSumVat;
		}
		else if (VAL_BASETYPE_GROSS == wtBaseType)
		{
			debitSum = debitSumNet + debitSumVat;
			creditSum = creditSumNet + creditSumVat;
		}
	}

	if (debitSum >= creditSum)
	{
		debCre = VAL_CREDIT;
	}
	else
	{
		debCre =  VAL_DEBIT;
	}
	
	return noErr;
}

/**
/**************************************************************************************************
/* GetWTBaseAmount
/*
/* Similar as  ODOCCalcWTTable calculate the wt table
/**************************************************************************************************   
*/
SBOErr CTransactionJournalObject::GetWTBaseAmount(long currSource, CWTBaseCalcParams* baseParam)
{
		_TRACER ("GetWTBaseAmount");
    SBOErr ooErr   = ooNoErr;
	PDAG dagJDT    = GetDAG (JDT);
    PDAG dagJDT1   = GetDAG(JDT, ao_Arr1);
    long recCount  = dagJDT1->GetRealSize(dbmDataBuffer);
	CBizEnv&bizEnv = GetEnv ();

    SBOString wtLiable;
    SBOString amount;
    MONEY sum, mnyTmp, sumVAT;
    bool isDebit;
	
    
    for(long rec = 0; rec < recCount; rec++)
    {
        dagJDT1->GetColStr(wtLiable, JDT1_WT_LIABLE, rec);
        if(wtLiable.Trim() == VAL_YES)   
        {
            isDebit = false;
            dagJDT1->GetColMoney(&mnyTmp, GetJDT1MoneyCol(currSource, true), rec);
            if(!mnyTmp.IsZero())
            {
                isDebit = true;
            }
            sum += mnyTmp;
            
            dagJDT1->GetColMoney(&mnyTmp, GetJDT1MoneyCol(currSource, false), rec);
            sum -= mnyTmp;

			//it's strange that there is no foreign currency column for VAT.in JE (PA/PO)
			//here we calculate VatSumFC by ForeignRate and VatSum.@see: JTE_GetVATMoneyCol()
			//but, if Credit & Debit columns are both empty, no need to calculate the VAT
			//also see:JTE_GetWTBaseAmount()
			if (mnyTmp.IsZero () && (!isDebit))
			{
				continue;
			}

			dagJDT1->GetColMoney(&mnyTmp, GetVATMoneyCol(currSource), rec);
			//calc  FC VAT
			SBOString dubtCurr;
			if (currSource == JDT_WT_FC_CURRENCY)
			{
				SBOString realCurr = WTGetCurrency ();
				realCurr.Trim ();
				dubtCurr.Trim ();
				SBOString mainCurr = bizEnv.GetMainCurrency().Trim ();
				SBOString& frgnCurr = realCurr;
				SBO_ASSERT(dubtCurr.IsEmpty () || dubtCurr == mainCurr);
				SBO_ASSERT(dubtCurr != frgnCurr);

				MONEY frgnAmnt = 1;
				SBOString dateStr;
				dagJDT->GetColStr (dateStr, OJDT_REF_DATE);
				dateStr.Trim ();
				GNLocalToForeignRate(&mnyTmp, frgnCurr.GetBuffer (), dateStr.GetBuffer (),
					0.0, &frgnAmnt, bizEnv);
				mnyTmp = frgnAmnt;
				mnyTmp.Round (RC_SUM, frgnCurr, bizEnv);
			}

            
            if(isDebit)
            {
                sumVAT += mnyTmp;
            }else{
                sumVAT -= mnyTmp;
            }
        }
    }

	if (!baseParam->GetIsBaseAmountsReady ())
	{
		baseParam->Init ();
	}

    MONEY mnySumTmp = sum + sumVAT;
    baseParam->m_wtBaseNetAmount = sum.AbsVal();
    baseParam->m_wtBaseVATAmount = sumVAT.AbsVal();
    baseParam->m_wtBaseAmount = mnySumTmp.AbsVal ();

    return ooErr;
}

/**
/**************************************************************************************************
/* GetCRDDag
/*
/* Construct dagCRD
/**************************************************************************************************   
*/
SBOErr CTransactionJournalObject::GetCRDDag()
{
		_TRACER ("GetCRDDag");
    SBOErr ooErr = ooNoErr;
    PDAG dagCRD = GetDAG(CRD);
    PDAG dagJDT1 = GetDAG(JDT, ao_Arr1);
    long recCount = dagJDT1->GetRealSize(dbmDataBuffer);
    SBOString acctCode, shortName;

    for(long rec = 0; rec < recCount; rec++)    
    {
        dagJDT1->GetColStr(acctCode, JDT1_ACCT_NUM, rec);
        acctCode.Trim();
        dagJDT1->GetColStr(shortName, JDT1_SHORT_NAME, rec);
        shortName.Trim();

        if(shortName != acctCode)//it's a bp line
        {
            DBD_CondStruct cond[1];
            cond[0].colNum = OCRD_CARD_CODE;
            cond[0].operation = DBD_EQ;
            cond[0].condVal = shortName;
            
            DBD_SetDAGCond(dagCRD, cond, 1);
            ooErr = DBD_Get(dagCRD);
            break;
        }   
    }     
    
    return ooErr;
}

/**
 * Similar as  JTE_WTGetCurrSource
 */
long  CTransactionJournalObject::WTGetCurrSource()
{
		_TRACER ("WTGetCurrSource");
	CBizEnv &bizEnv = GetEnv ();

	SBOString currency;
	SBOString mainCurr = bizEnv.GetMainCurrency();
	SBOString sysCurr = bizEnv.GetSystemCurrency();

	currency = GetBPLineCurrency ();
	currency.Trim ();

	if((EMPTY_STR == currency)
		|| (currency == mainCurr) 
		|| (GNCoinCmp (currency, BAD_CURRENCY_STR) == 0))
	{
		return JDT_WT_LOCAL_CURRENCY;
	}
	if(currency == sysCurr)
	{
		return JDT_WT_SYS_CURRENCY;
	}
	return JDT_WT_FC_CURRENCY;
}

/**
 * add a wt line, and fill the fields
 *  
 * @param [in] jdt2CurRec: JDT2's current row.
 */
SBOErr CTransactionJournalObject::WtAutoAddJDT1Line 
	(PDAG dagJDT1, long jdt1RecSize, PDAG dagJDT2, long jdt2CurRec, 
		bool isDebit, const SBOString& wtSide
	) 
{	
	_TRACER ("WtAutoAddJDT1Line");
	SBOErr ooErr = noErr;
	SBOString tmpStr; 
	MONEY mnyAmt;

	long toJDT1fields[] = {JDT1_TAX_DATE, JDT1_DUE_DATE, JDT1_LINE_MEMO,
		JDT1_REF1, JDT1_REF2, JDT1_PROJECT, -1
	};
	long fromJDTfields[] = {OJDT_TAX_DATE,OJDT_DUE_DATE, OJDT_MEMO,
		OJDT_REF1, OJDT_REF2, OJDT_PROJECT, -1
	};

	dagJDT1->SetSize (jdt1RecSize+1, dbmKeepData);

	//local currency
	dagJDT2->GetColMoney (&mnyAmt, INV5_WT_AMOUNT, jdt2CurRec);
	dagJDT1->SetColMoney (&mnyAmt, 
		GetJDT1MoneyCol(JDT_WT_LOCAL_CURRENCY, isDebit), jdt1RecSize);

	//sys currency                                   
	dagJDT2->GetColMoney (&mnyAmt, INV5_WT_AMOUNT_SC, jdt2CurRec);
	dagJDT1->SetColMoney (&mnyAmt, 
		GetJDT1MoneyCol(JDT_WT_SYS_CURRENCY, isDebit), jdt1RecSize);

	//FC  
	if (WTGetCurrSource () == JDT_WT_FC_CURRENCY)
	{
		dagJDT2->GetColMoney (&mnyAmt, INV5_WT_AMOUNT_FC, jdt2CurRec);
		dagJDT1->SetColMoney (&mnyAmt, 
			GetJDT1MoneyCol(JDT_WT_FC_CURRENCY, isDebit), jdt1RecSize);
	}

	dagJDT1->SetColStr (VAL_YES, JDT1_WT_Line, jdt1RecSize);
	dagJDT1->SetColStr (wtSide, JDT1_DEBIT_CREDIT, jdt1RecSize);
	dagJDT1->CopyColumn (dagJDT2, JDT1_ACCT_NUM, jdt1RecSize, INV5_ACCOUNT, jdt2CurRec);
	dagJDT1->CopyColumn (dagJDT2, JDT1_SHORT_NAME, jdt1RecSize, INV5_ACCOUNT, jdt2CurRec);

	dagJDT1->SetColLong (JDT, JDT1_TRANS_TYPE, jdt1RecSize);
	for (long ii = 0; toJDT1fields[ii] >= 0; ii++)
	{
		dagJDT1->GetColStr (tmpStr, toJDT1fields[ii], jdt1RecSize);
		tmpStr.Trim ();
		if (tmpStr == EMPTY_STR)
		{
			dagJDT1->GetColStr (tmpStr, toJDT1fields[ii], jdt1RecSize,
				fromJDTfields[ii], 0);
		}
	}

	if (WTGetCurrSource () == JDT_WT_FC_CURRENCY)
	{
		dagJDT1->SetColStr (GetBPLineCurrency (), JDT1_FC_CURRENCY, jdt1RecSize);
	}

	return ooErr;
}

/**
 * update JDT1's wht amount
 * 
 * there may be more than one wht code in JDT2,  some have the same acount code.  
 * merge  the wht amount in JDT1 line if wht codes have the same account 
 * @param [in]: dagJDT2, jdt1CurRow, jdt2CurRow, wtSide; wtAcctCode is wht code.
 * @param [in,out]: dagJDT1 
 */
SBOErr  CTransactionJournalObject::WtUpdJDT1LineAmt 
	(PDAG dagJDT1, long jdt1CurRow, PDAG dagJDT2, long jdt2CurRow,
	bool isDebit, const SBOString& wtAcctCode, const SBOString& wtSide) 
{
	SBOErr ooErr = ooNoErr;
	MONEY mnyAmt;
	MONEY oldWT, oldWTSC, oldWTFC;

	//long prevRec = 0; 
	//dagJDT2->FindColStr(wtAcctCode, INV5_ACCOUNT, 0, &prevRec);	
	//if(prevRec < jdt2CurRow)
	//{ 
	dagJDT1->GetColMoney (&oldWT,   
		GetJDT1MoneyCol (JDT_WT_LOCAL_CURRENCY, isDebit), jdt1CurRow);
	dagJDT1->GetColMoney (&oldWTSC, 
		GetJDT1MoneyCol (JDT_WT_SYS_CURRENCY, isDebit), jdt1CurRow);
	dagJDT1->GetColMoney (&oldWTFC, 
		GetJDT1MoneyCol (JDT_WT_FC_CURRENCY, isDebit), jdt1CurRow);
	//}

	//local currency
	dagJDT2->GetColMoney (&mnyAmt, INV5_WT_AMOUNT, jdt2CurRow);
	mnyAmt += oldWT;
	dagJDT1->SetColMoney (&mnyAmt, 
		GetJDT1MoneyCol (JDT_WT_LOCAL_CURRENCY, isDebit), jdt1CurRow);

	//sys currency                                   
	dagJDT2->GetColMoney (&mnyAmt, INV5_WT_AMOUNT_SC, jdt2CurRow);
	mnyAmt += oldWTSC;
	dagJDT1->SetColMoney (&mnyAmt, 
		GetJDT1MoneyCol (JDT_WT_SYS_CURRENCY, isDebit), jdt1CurRow);

	//FC  
	dagJDT2->GetColMoney (&mnyAmt, INV5_WT_AMOUNT_FC, jdt2CurRow);
	mnyAmt += oldWTFC;
	dagJDT1->SetColMoney (&mnyAmt, 
		GetJDT1MoneyCol (JDT_WT_FC_CURRENCY, isDebit), jdt1CurRow);

	return ooErr;
}

/**
*
*/
bool	CTransactionJournalObject::OJDTIsDueDateRangeValid ()
{
	_TRACER ("OJDTIsDueDateRangeValid");

	CBizEnv	&env = GetEnv ();

	// Make sure the feature is enabled (phase 1) and this is business partner
	// journal entry.
	if (!VF_PaymentDueDate (env) || !ContainsCardLine ())
	{
		return true;
	}

	SBOErr	ooErr;
	bool	pddEnabled;
	long	maxDaysForDueDate;

	// Make sure that feature is enabled (phase 2) and "max" value is valid.
	ooErr = env.GetPDDData (pddEnabled, maxDaysForDueDate);
	if ((ooErr != ooNoErr) || !pddEnabled || (maxDaysForDueDate <= -1L))
	{
		return true;
	}

	PDAG	dagJDT;

	// Get main DAG.
	dagJDT = GetDAG ();
	if (!DAG_IsValid (dagJDT) || (dagJDT->GetRealSize (dbmDataBuffer) <= 0L))
	{
		return true;
	}

	long	dateField;

	// Get due date field index.
	dateField = dagJDT->GetColumnByType (DUE_DATE_FLD);
	if (dateField < 0L)
	{
		return true;
	}

	SBOString	temp;

	// Retrieve due date.
	ooErr = dagJDT->GetColStr (temp, dateField);
	IF_ERROR_RETURN_VALUE (ooErr, true);

	long	dueDate;

	// Transform it to number.
	ooErr = DBM_DATE_ToLong (&dueDate, temp);
	IF_ERROR_RETURN_VALUE (ooErr, true);

	// Get document date field index.
	dateField = dagJDT->GetColumnByType (TAX_DATE_FLD);
	if (dateField < 0L)
	{
		return true;
	}

	// Retrieve document date.
	ooErr = dagJDT->GetColStr (temp, dateField);
	IF_ERROR_RETURN_VALUE (ooErr, true);

	long	docDate;

	// Transform it to number.
	ooErr = DBM_DATE_ToLong (&docDate, temp);
	IF_ERROR_RETURN_VALUE (ooErr, true);

	// Inform caller if the difference between due date and document date exceeds
	// allowed range.
	return ((dueDate - docDate) <= maxDaysForDueDate);
}

/**
*
*/
bool	CTransactionJournalObject::OJDTIsDocumentOrDueDateChanged ()
{
	_TRACER ("OJDTIsDocumentOrDueDateChanged");

	PDAG	dagJDT;

	dagJDT = GetDAG ();
	return CheckColChanged (dagJDT, OJDT_TAX_DATE) || CheckColChanged (dagJDT, OJDT_DUE_DATE);
}

/**
/**************************************************************************************************
/* CompleteWTInfo
/*
/* Complete WTinformation
/**************************************************************************************************   
*/
SBOErr  CTransactionJournalObject::CompleteWTInfo()
{
    SBOErr ooErr = ooNoErr;
    PDAG dagJDT = GetDAG(JDT);
    SBOString autoWT;
    
    dagJDT->GetColStr(autoWT, OJDT_AUTO_WT);
    autoWT.Trim();
    if(autoWT == VAL_NO)
    {
        return ooErr;
    }   
    CWTAllCurBaseCalcParams *wtAllCurBaseCalcParamsPtr = new CWTAllCurBaseCalcParams();
    long currSource[] = {JDT_WT_LOCAL_CURRENCY, JDT_WT_SYS_CURRENCY, JDT_WT_FC_CURRENCY, 0};
    CJDTWTInfo *wtInfo = new CJDTWTInfo();     
    PDAG dagDOC = m_env.OpenDAG(INV, ao_Main);
    
    PrePareDataForWT(wtAllCurBaseCalcParamsPtr, GetBPCurrencySource(), dagDOC, wtInfo);   
    
	PDAG dagJDT2 = GetDAG(JDT, ao_Arr2);
	long numOfRecs = dagJDT2->GetRecordCount ();

	for(long i = 0; currSource[i]; i++)
	{
		wtAllCurBaseCalcParamsPtr->InitWTBaseCalcParams(currSource[i]);
		GetWTBaseAmount (currSource[i], 
						  wtAllCurBaseCalcParamsPtr->GetWtBaseCalcParams(currSource[i]));

		// > 0, need to auto calculate the amount.
		if (numOfRecs > 0)
		{
			long wtCurrSource = GetBPCurrencySource ();

			//if no foreign currency, do not calculate it.
			if ( (currSource[i] != INV_CARD_CURRENCY) ||
				(currSource[i] == INV_CARD_CURRENCY && wtCurrSource==INV_CARD_CURRENCY) )
			{
				m_WithholdingTaxMng.ODOCAutoCompleteDOC5(*this, currSource[i], 
					wtAllCurBaseCalcParamsPtr->GetWtBaseCalcParams(currSource[i]),
					false, dagDOC);
			}
		}
		else
		{
			JDTCalcWTTable(wtInfo, currSource[i], dagDOC, wtAllCurBaseCalcParamsPtr);
		}
	}

    UpdateWTAmounts(wtAllCurBaseCalcParamsPtr);
    
    //clear resource
    dagDOC->Close();
    delete wtAllCurBaseCalcParamsPtr;
    delete wtInfo;
     
    return ooErr;
}

/**
* auto add WT line
* 
*/
SBOErr	CTransactionJournalObject::CompleteWTLine ()
{
	SBOErr     ooErr = ooNoErr;
	PDAG 	   dagJDT = NULL, dagJDT1 = NULL, dagJDT2 = NULL;
	SBOString  wtCategory, wtSide, autoWT;

	dagJDT = GetDAG (JDT);
	if (!DAG::IsValid (dagJDT))
	{
		return ooErrNoMsg;
	}
	dagJDT->GetColStr (autoWT, OJDT_AUTO_WT);
	autoWT.Trim ();
	if (autoWT != VAL_YES)
	{
		return ooNoErr;
	}

	ooErr = CompleteWTInfo ();
	IF_ERROR_RETURN (ooErr);

	dagJDT1 = GetDAG (JDT, ao_Arr1);
	dagJDT2 = GetDAG (JDT, ao_Arr2);

	dagJDT2->GetColStr (wtCategory, INV5_CATEGORY);
	wtCategory.Trim ();


	//only invoice category add JE line  
	if (wtCategory == VAL_CATEGORY_PAYMENT)
	{
		return ooNoErr;
	}
	
	GetWTCredDebt (wtSide); // 
	bool isDebit = (wtSide == VAL_DEBIT);

	//whether JE line already exist
	bool found = false;
	long jdt1RecSize = 0, jdt2RecSize = 0;
	long row = 0;// JDT1 row index.
	SBOString tmpStr, acctCode;
	MONEY mnyAmt;
	
	jdt1RecSize = dagJDT1->GetRealSize(dbmDataBuffer);
	jdt2RecSize = dagJDT2->GetRealSize(dbmDataBuffer);

	for (long rec = 0; rec < jdt2RecSize; rec++)
	{
		dagJDT2->GetColStr (acctCode, INV5_ACCOUNT, rec);
		acctCode.Trim ();
		found = false;

		for (row = 0; row < jdt1RecSize; row++)
		{
			dagJDT1->GetColStr (tmpStr, JDT1_WT_Line, row);
			if(tmpStr.Trim () != VAL_YES)
			{
				continue;     
			}

			dagJDT1->GetColStr (tmpStr, JDT1_ACCT_NUM, row);
			if (tmpStr.Trim () == acctCode)
			{
				found = true;
				break;
			}
		}

		if (found)
		{
			ooErr = WtUpdJDT1LineAmt (dagJDT1, row, dagJDT2, rec, isDebit, acctCode, wtSide);
		}
		else	//if not found, add a new JDT1 line.
		{
			ooErr = WtAutoAddJDT1Line (dagJDT1, jdt1RecSize, dagJDT2, rec, isDebit, wtSide);

			jdt1RecSize++;
		}
	}//end of  for{}

	return ooErr;
}

/**
/**************************************************************************************************
/* UpdateWTAmount
/*
/* Similar as JTE_UpdateWTSum
/**************************************************************************************************   
*/
SBOErr CTransactionJournalObject::UpdateWTAmounts(CWTAllCurBaseCalcParams *wtAllCurBaseCalcParamsPtr)
{
    SBOErr ooErr = ooNoErr;
    PDAG dagJDT2 = GetDAG(JDT, ao_Arr2); 
    PDAG dagJDT = GetDAG(JDT);
    long recCount = dagJDT2->GetRecordCount();
    MONEY mnyTmp, wtSums[3];
    long currency[] = {JDT_WT_LOCAL_CURRENCY, JDT_WT_SYS_CURRENCY, JDT_WT_FC_CURRENCY, 0};
    
    for(long rec = 0; rec < recCount; rec++)
    {
        for(long i = 0; currency[i]; i++)
        {
            dagJDT2->GetColMoney(&mnyTmp, m_WithholdingTaxMng.ODOC5GetWTTaxAmountField(currency[i]), rec);
            wtSums[i] += mnyTmp;   
        }      
    }    

    SBOString	strRecBaseType;
    dagJDT2->GetColStr(strRecBaseType, INV5_BASE_TYPE, 0);

    for(long i = 0; currency[i]; i++)
    {
        CWTBaseCalcParams*wtCurBaseCalcParamsPtr 
                     = wtAllCurBaseCalcParamsPtr->GetWtBaseCalcParams(currency[i]);
        if (m_env.IsLocalSettingsFlag(lsf_EnableLA1WHT))   
        {
            dagJDT->SetColMoney(&wtCurBaseCalcParamsPtr->m_wtBaseNetAmount, 
                CTransactionJournalObject::GetWTBaseNetAmountField(currency[i]));
            dagJDT->SetColMoney(&wtCurBaseCalcParamsPtr->m_wtBaseVATAmount,
                CTransactionJournalObject::GetWTBaseVATAmountField(currency[i]));             
        }
        else
        {
             if (VAL_BASETYPE_NET == strRecBaseType)
             {
                 dagJDT->SetColMoney(&wtCurBaseCalcParamsPtr->m_wtBaseNetAmount, 
                     CTransactionJournalObject::GetWTBaseNetAmountField(currency[i]));
             }
             else
             {
                dagJDT->SetColMoney(&wtCurBaseCalcParamsPtr->m_wtBaseAmount, 
                    CTransactionJournalObject::GetWTBaseNetAmountField(currency[i]));
            }
        }
        
        dagJDT->SetColMoney(&wtSums[i], CTransactionJournalObject::GetWtSumField(currency[i]));          
    }

    return ooErr;
}


/**
 * calculate the BP currency's rate manually according the amount
 * 
 * 
 * @param [out] rate
 * @see 
 */
SBOErr CTransactionJournalObject::CalcBpCurrRateForDocRate (MONEY& rate )
{
	SBOErr  ooErr = ooNoErr;
	PDAG	dagJDT1 = GetDAG (JDT, ao_Arr1);
	CBizEnv&	env = GetEnv ();

	MONEY mLocal, mFrgn;
	long recJDT1 = dagJDT1->GetRealSize (dbmDataBuffer);
	SBOString acct, shortname, curr;
	bool flag = false;
	for(long rec = 0; rec < recJDT1; rec++)
	{
		dagJDT1->GetColStr (acct, JDT1_ACCT_NUM, rec);
		dagJDT1->GetColStr (shortname, JDT1_SHORT_NAME, rec);

		acct.Trim ();
		shortname.Trim ();
		if(acct != shortname)    
		{
			//a BP line;
			dagJDT1->GetColMoney (&mLocal, JDT1_CREDIT, rec);
			dagJDT1->GetColMoney (&mFrgn,  JDT1_FC_CREDIT, rec);
			if (mLocal.IsPositive() && mFrgn.IsPositive())
			{
				flag = true;
			}
			else
			{
				dagJDT1->GetColMoney (&mLocal, JDT1_DEBIT, rec);
				dagJDT1->GetColMoney (&mFrgn,  JDT1_FC_DEBIT, rec);
				if (mLocal.IsPositive() && mFrgn.IsPositive())
				{
					flag = true;
				}
			}

			//only one BP
			break;
		}
	}

	if (flag)
	{
		if (env.IsDirectRate ())
		{
			rate = mLocal.MulAndDiv (1LL, mFrgn, &env, false);
		}
		else
		{
			rate = mFrgn.MulAndDiv (1L, mLocal, &env, false);
		}
	}
	else
	{
		rate.FromDouble (MONEY_PERCISION_MUL);
		ooErr = errNoMsg;
	}

	return ooErr;
}

/**
 * set system currency rate for dagJDT
 * 
 * we create OINV dag for reusing CDocumentObject's logic.
 * so, we need to set some columns of dagJDT.
 */
SBOErr CTransactionJournalObject::SetSysCurrRateForDOC (PDAG dagDOC )
{
	SBOErr		ooErr = noErr;
	CBizEnv&	env = GetEnv ();
	MONEY		rate, rateVal1;
	PDAG		dagJDT = GetDAG (JDT);

	if (!DAG::IsValid(dagDOC))
	{
		return ooErrNoMsg;
	}

	dagDOC->GetColMoney (&rate, OINV_SYSTEM_RATE);
	if (rate.IsPositive ())
	{
		return ooErr;
	}

	Currency	sysCurrency, mainCurrecny;
	_STR_strcpy (mainCurrecny, env.GetMainCurrency().GetBuffer ());
	_STR_strcpy (sysCurrency, env.GetSystemCurrency().GetBuffer ());

	//set  OINV_SYSTEM_RATE
	rateVal1.FromDouble (MONEY_PERCISION_MUL);
	bool sysCurrAsMain = (bool) !GNCoinCmp (sysCurrency, mainCurrecny);
	

	if (rate.IsZero ())
	{
		rate = 1L;
		if (!sysCurrAsMain)
		{
			ooErr = nsDocument::ODOCGetAndWaitUntilRateByDag (sysCurrency, dagJDT, &rate, env);
		}
		else
		{
			rate = rateVal1;
		}
	}
	else if ( rate.IsNegative () || (sysCurrAsMain && (rate != rateVal1)) )
	{
		ooErr = ooErrNoMsg;
	}
	dagDOC->SetColMoney (&rate, OINV_SYSTEM_RATE);

	if (ooErr)
	{
		Message (ERROR_MESSAGES_STR, OO_ILLEGAL_SUM, sysCurrency, OO_ERROR);
		SetErrorField (OINV_SYSTEM_RATE);
		return ooErrNoMsg;
	}

	return ooErr;
}

/****************************************************************************/

// ERD Base Transaction fix
#define JDT_ERDBASETRANSFIX_BT_NAME _T("ibd_ERDBaseRefBackup")
#define JDT_ERDBASETRANSFIX_BT_COL_TRANS_ID	0
#define JDT_ERDBASETRANSFIX_BT_COL_BASE_REF	1

#define JDT_ERDBASETRANSFIX_REF3_SEPARATOR	_T('/')
#define JDT_ERDBASETRANSFIX_BATCH_SIZE		10000

#define JDT_ERDBASETRANSFIX_JDT1_TABLE_NUM	0
#define JDT_ERDBASETRANSFIX_OJDT_TABLE_NUM	1
	#define JDT_ERDBASETRANSFIX_OJDT_NUM_OF_JOINS 1

#define JDT_ERDBASETRANSFIX_TRANSID_RES		0
#define JDT_ERDBASETRANSFIX_LINEID_RES		1
#define JDT_ERDBASETRANSFIX_ACCOUNT_RES		2
#define JDT_ERDBASETRANSFIX_SHORTNAME_RES	3
#define JDT_ERDBASETRANSFIX_REF3_RES		4
#define JDT_ERDBASETRANSFIX_RES_SIZE		5

/**
 * Upgrade BaseTrans field. This field will be used as replacement of
 * BaseRef field for Exchange Rate Difference enhancement for CEE countries
 *
 * ==Brief problem description==
 * The exchange rate difference enhancement for CEE countries requires
 * reference between ERD JE and it's Base Journal entry.
 * Till v2004C OJDT.BaseRef field was used because for manual JEs BaseRef =
 * = TransId. So it was easy to distinguish between ERD JE and Base JE
 * But since v2005 BaseRef of manual JEs points to Number.
 * Together with this change was introduced upgrade that basicaly does:
 * update OJDT set BaseRef = Number where TransType = 30
 * Because all ERD JEs has TransType same as Manual JE, due to that upgrade
 * all references were lost
 *
 * Following upgrade process tries to reconstruct lost References either from
 * backup table created in 2004C if it exists or from JDT1.Ref3Line field that
 * also contains the reference but in text format.
 *
 * @return  Error in case of DB Error
 */
SBOErr CTransactionJournalObject::UpgradeERDBaseTrans ()
{
	SBOErr ooErr = ooNoErr;

	// If customer executed BaseRef backup query, then we can restore references
	// from the backup table
	ooErr = UpgradeERDBaseTransFromBackup ();
	if (ooErr)
	{
		if (ooErr == dbmTableNotFound)
		{
			ooErr = 0;
		}
		else
		{
			return ooErr;
		}
	}

	ooErr = UpgradeERDBaseTransFromRef3 ();

	return ooErr;
}
/****************************************************************************/

/**
 * Try to Upgrade BaseTrans field from backup table created before upgrade 
 * to v2007A. If it exists it should have 2 columns [TransId] and [BaseRef]
 * and contain all keys to ERD transactions with references to TransId of
 * its base transactions
 *
 * SELECT T0.[TransId], T0.[BaseRef] FROM  [dbo].[ibd_ERDFix_BaseRefBackup] T0
 *
 * @return  dbmTableNotFound if backup table does not exists
 */
#if 0
SBOErr CTransactionJournalObject::UpgradeERDBaseTransFromBackup ()
{
	SBOErr			ooErr = ooNoErr, tmpErr;
	CBizEnv&		bizEnv = GetEnv();
	ColumnInfoList	colList;
	KeyInfoList		keyList;
	DBM_CA			colAttr;
	long			numOfRecs, rec;
	long			transId, baseRef;

	// {{{ Create temporary table definition
	bizEnv.GetColAttributes (bizEnv.ObjectToTable (JDT, ao_Main), OJDT_JDT_NUM, &colAttr, FALSE);
	DBMTableDefs::FormatOneDBField (&colAttr);
	colList.Add (colAttr);
	bizEnv.GetColAttributes (bizEnv.ObjectToTable (JDT, ao_Main), OJDT_BASE_REF, &colAttr, FALSE);
	DBMTableDefs::FormatOneDBField (&colAttr);
	colList.Add (colAttr);

	ooErr = bizEnv.GetTD(dbmFixedTD).CreateFixedDefinition(JDT_ERDBASETRANSFIX_BT_NAME, colList, keyList);
	if (ooErr)
	{
		return ooErr;
	}
	// }}}

	DBD_Params		queryParams;
	queryParams.Clear ();

	DBD_TablesList	tablePtr;

	tablePtr = &(queryParams.GetCondTables ().AddTable ());
	tablePtr->tableCode = JDT_ERDBASETRANSFIX_BT_NAME;

	DBD_ResStruct	resStruct [2];

	resStruct[JDT_ERDBASETRANSFIX_BT_COL_TRANS_ID].tableIndex = 0;
	resStruct[JDT_ERDBASETRANSFIX_BT_COL_TRANS_ID].colNum = JDT_ERDBASETRANSFIX_BT_COL_TRANS_ID;

	resStruct[JDT_ERDBASETRANSFIX_BT_COL_BASE_REF].tableIndex = 0;
	resStruct[JDT_ERDBASETRANSFIX_BT_COL_BASE_REF].colNum = JDT_ERDBASETRANSFIX_BT_COL_BASE_REF;

	queryParams.dbdResPtr = resStruct;
	queryParams.numOfResCols = 2;

	PDAG dagRes = NULL;
	PDAG dagQuery = bizEnv.OpenDAG (JDT, ao_Main);
	dagQuery->SetDBDParms (&queryParams);

	// get data from db
	ooErr = DBD_GetInNewFormat(dagQuery, &dagRes);
	if (ooErr)
	{
		if (ooErr == -1)
		{
			// Unfortunately DB infra does not distinguish between invalid
			// query syntax and missing table in DB, so we consider -1 as 
			// missing backup table
			ooErr = dbmTableNotFound;
			goto leave;
		}
		else if (ooErr == dbmNoDataFound)
		{
			dagRes->SetSize (0, dbmDropData);
			ooErr = noErr;
		}
		else
		{
			goto leave;
		}
	}

	numOfRecs = dagRes->GetRecordCount ();
	for (rec = 0; rec < numOfRecs; ++rec)
	{
		dagRes->GetColLong (&transId, JDT_ERDBASETRANSFIX_BT_COL_TRANS_ID, rec);		
		dagRes->GetColLong (&baseRef, JDT_ERDBASETRANSFIX_BT_COL_BASE_REF, rec);

		ooErr = UpgradeERDBaseTransUpdateOne (transId, baseRef);
		if (ooErr)
		{
			goto leave;
		}
	}

leave:
	dagQuery->Close ();

	// remove the temporary table definition
	tmpErr = bizEnv.GetTD (dbmFixedTD).DisposeDefinition (JDT_ERDBASETRANSFIX_BT_NAME);
	if (!ooErr)
	{
		return tmpErr;
	}

	return ooErr;
}
#endif
/****************************************************************************/

/**
 * Update pointer to Base transaction of specified JE transaction
 *
 * UPDATE T0 SET T0.[BaseTrans] = erdBaseTrans
 * FROM [dbo].[OJDT] T0 WHERE T0.[TransId] = (transId)
 *
 * @param transId  JDT transaction that should be updated
 * @param erdBaseTrans  Transaction id of base JE transaction
 * @return  DB Error or noErr
 */
SBOErr CTransactionJournalObject::UpgradeERDBaseTransUpdateOne (long transId, long erdBaseTrans)
{
	SBOErr			ooErr = ooNoErr;
	CBizEnv&		bizEnv = GetEnv ();
	PDAG			dagJDT = bizEnv.OpenDAG (JDT, ao_Main);
	DBD_UpdStruct	updStruct [1];
	DBD_Conditions	*conditions;
	PDBD_Cond		condPtr;

	conditions = &(dagJDT->GetDBDParams ()->GetConditions ());
	conditions->Clear ();

	condPtr = &conditions->AddCondition ();
	condPtr->colNum			= OJDT_JDT_NUM;
	condPtr->operation		= DBD_EQ;
	condPtr->condVal		= transId;
	condPtr->relationship	= 0;

	updStruct[0].colNum = OJDT_BASE_TRANS_ID;
	updStruct[0].updateVal = erdBaseTrans;

	ooErr = DBD_SetDAGUpd (dagJDT, updStruct, 1);
	if (ooErr)
	{
		dagJDT->Close ();
		return ooErr;
	}

	// update data in database
	ooErr = DBD_UpdateCols (dagJDT);
	dagJDT->Close ();
	return ooErr;
}
/****************************************************************************/

/**
 * Upgrade BaseTrans Field according to Ref3Line value on JE lines
 * 
 * This process is not completely precise because it relies on JDT1.Ref3Line
 * field that can be manualy edited by user.
 * First it loads all ERD Journal entries with Ref3Line field filled with
 * appropriate format. Then it tries to find all possible candidates Ref3Line
 * may refer to (@see UpgradeERDBaseTransFindBaseTrans).
 * If there is zero or more than one candidates then the reference is not
 * upgraded, but if there is exactly one baseTrans candidate then it is 
 * written into the new field
 *
 * The list of transactions that needs fixing is got by following query
 * SELECT TOP 10 T1.[TransId], ...
 * FROM [dbo].[JDT1] T0 INNER JOIN [dbo].[OJDT] T1 
 * ON T1.[TransId] = T0.[TransId] 
 * WHERE T1.[TransType] = (N'30') 
 *   AND T0.[FCCredit] = (0.0)
 *   AND T0.[FCDebit] = (0.0)
 *   AND T0.[FCCurrency] IS NOT NULL 
 *   AND T1.[BaseTrans] IS NULL 
 *   AND T0.[Ref3Line] Like N'%/%/%'
 *
 * @return  In case of DB Error
 */
SBOErr CTransactionJournalObject::UpgradeERDBaseTransFromRef3 ()
{
	SBOErr			ooErr = ooNoErr;
	CBizEnv&		bizEnv = GetEnv ();
	long			condNum, rec, numOfRecs;
	DBD_TablesList	tablePtr;
	DBD_CondStruct	joinCondsOJDT [JDT_ERDBASETRANSFIX_OJDT_NUM_OF_JOINS];
	DBD_Params		queryParams;
	ObjectAbbrevsMap abbrevMap;

	// Initialize list of objects and abbreviations
	UpgradeERDBaseTransPopulateAbbrevMap (abbrevMap);

	queryParams.Clear ();
	// {{{ JDT1 - table 0
	tablePtr = &(queryParams.GetCondTables ().AddTable ());
	tablePtr->tableCode = bizEnv.ObjectToTable (JDT, ao_Arr1);
	// }}}

	// {{{ OJDT - table 1
	tablePtr = &(queryParams.GetCondTables ().AddTable ());
	tablePtr->tableCode = bizEnv.ObjectToTable (JDT, ao_Main);
	tablePtr->doJoin = true;
	tablePtr->joinedToTable = JDT_ERDBASETRANSFIX_JDT1_TABLE_NUM;
	tablePtr->numOfConds = JDT_ERDBASETRANSFIX_OJDT_NUM_OF_JOINS;
	tablePtr->joinConds = joinCondsOJDT;

	// joinCondsOJDT
	condNum = 0;
	joinCondsOJDT[condNum].compareCols = true;
	joinCondsOJDT[condNum].tableIndex = JDT_ERDBASETRANSFIX_OJDT_TABLE_NUM;
	joinCondsOJDT[condNum].colNum = OJDT_JDT_NUM;
	joinCondsOJDT[condNum].compTableIndex = JDT_ERDBASETRANSFIX_JDT1_TABLE_NUM;
	joinCondsOJDT[condNum].compColNum = JDT1_TRANS_ABS;
	joinCondsOJDT[condNum].operation = DBD_EQ;
	joinCondsOJDT[condNum++].relationship = 0;
	// }}}

	DBD_ResStruct	resStruct [JDT_ERDBASETRANSFIX_RES_SIZE];

	resStruct[JDT_ERDBASETRANSFIX_TRANSID_RES].tableIndex = JDT_ERDBASETRANSFIX_OJDT_TABLE_NUM;
	resStruct[JDT_ERDBASETRANSFIX_TRANSID_RES].colNum = OJDT_JDT_NUM;

	resStruct[JDT_ERDBASETRANSFIX_LINEID_RES].tableIndex = JDT_ERDBASETRANSFIX_JDT1_TABLE_NUM;
	resStruct[JDT_ERDBASETRANSFIX_LINEID_RES].colNum = JDT1_LINE_ID;

	resStruct[JDT_ERDBASETRANSFIX_ACCOUNT_RES].tableIndex = JDT_ERDBASETRANSFIX_JDT1_TABLE_NUM;
	resStruct[JDT_ERDBASETRANSFIX_ACCOUNT_RES].colNum = JDT1_ACCT_NUM;

	resStruct[JDT_ERDBASETRANSFIX_SHORTNAME_RES].tableIndex = JDT_ERDBASETRANSFIX_JDT1_TABLE_NUM;
	resStruct[JDT_ERDBASETRANSFIX_SHORTNAME_RES].colNum = JDT1_SHORT_NAME;

	resStruct[JDT_ERDBASETRANSFIX_REF3_RES].tableIndex = JDT_ERDBASETRANSFIX_JDT1_TABLE_NUM;
	resStruct[JDT_ERDBASETRANSFIX_REF3_RES].colNum = JDT1_REF3_LINE;

	queryParams.dbdResPtr = resStruct;
	queryParams.numOfResCols = JDT_ERDBASETRANSFIX_RES_SIZE;

	PDBD_Cond condPtr;

	condPtr = &(queryParams.GetConditions ().AddCondition ());
	condPtr->tableIndex = JDT_ERDBASETRANSFIX_OJDT_TABLE_NUM;
	condPtr->colNum = OJDT_TRANS_TYPE;
	condPtr->operation = DBD_EQ;
	condPtr->condVal = JDT;
	condPtr->relationship = DBD_AND;

	condPtr = &(queryParams.GetConditions ().AddCondition ());
	condPtr->tableIndex = JDT_ERDBASETRANSFIX_JDT1_TABLE_NUM;
	condPtr->colNum = JDT1_FC_CREDIT;
	condPtr->operation = DBD_EQ;
	condPtr->condVal = 0L;
	condPtr->relationship = DBD_AND;

	condPtr = &(queryParams.GetConditions ().AddCondition ());
	condPtr->tableIndex = JDT_ERDBASETRANSFIX_JDT1_TABLE_NUM;
	condPtr->colNum = JDT1_FC_DEBIT;
	condPtr->operation = DBD_EQ;
	condPtr->condVal = 0L;
	condPtr->relationship = DBD_AND;

	condPtr = &(queryParams.GetConditions ().AddCondition ());
	condPtr->tableIndex = JDT_ERDBASETRANSFIX_JDT1_TABLE_NUM;
	condPtr->colNum = JDT1_FC_CURRENCY;
	condPtr->operation = DBD_NOT_NULL;
	condPtr->relationship = DBD_AND;

	condPtr = &(queryParams.GetConditions ().AddCondition ());
	condPtr->tableIndex = JDT_ERDBASETRANSFIX_OJDT_TABLE_NUM;
	condPtr->colNum = OJDT_BASE_TRANS_ID;
	condPtr->operation = DBD_IS_NULL;
	condPtr->relationship = DBD_AND;

	condPtr = &(queryParams.GetConditions ().AddCondition ());
	condPtr->tableIndex = JDT_ERDBASETRANSFIX_JDT1_TABLE_NUM;
	condPtr->colNum = JDT1_REF3_LINE;
	condPtr->operation = DBD_PATTERN;
	condPtr->condVal = _T("*/*/*");
	condPtr->relationship = 0;

	DBM_KA key;
	key.SetSegmentsCount (2);
	key.SetSegmentColumn (0, JDT_ERDBASETRANSFIX_TRANSID_RES);
	key.SetSegmentColumn (1, JDT_ERDBASETRANSFIX_LINEID_RES);

	PDAG dagRes = NULL;
	PDAG dagQuery = bizEnv.OpenDAG(BOT, ao_Arr1);
	dagQuery->SetDBDParms (&queryParams);

	// get first chunk
	ooErr = dagQuery->GetFirstChunk (JDT_ERDBASETRANSFIX_BATCH_SIZE, key, &dagRes);
	if ((ooErr) && (ooErr != dbmNoDataFound))
	{
		dagQuery->Close ();
		return ooErr;
	}

	// loop over other chunks
	while (ooErr != dbmNoDataFound)
	{	
		// process the chunk
		numOfRecs = dagRes->GetRecordCount ();
		for (rec = 0; rec < numOfRecs; ++rec)
		{
			long transId, baseTransCandidate;
			SBOString account, shortName, ref3Line;

			dagRes->GetColLong (&transId, JDT_ERDBASETRANSFIX_TRANSID_RES,rec);
			dagRes->GetColStr (account, JDT_ERDBASETRANSFIX_ACCOUNT_RES, rec);
			dagRes->GetColStr (shortName, JDT_ERDBASETRANSFIX_SHORTNAME_RES, rec);
			dagRes->GetColStr (ref3Line, JDT_ERDBASETRANSFIX_REF3_RES, rec);

			baseTransCandidate = 0;
			ooErr = UpgradeERDBaseTransFindBaseTrans (abbrevMap, account, shortName, ref3Line, &baseTransCandidate);
			if (ooErr)
			{
				if (ooErr != dbmNoDataFound)
				{
					dagQuery->Close ();
					return ooErr;
				}
			}
			else if (baseTransCandidate)
			{
				ooErr = UpgradeERDBaseTransUpdateOne (transId, baseTransCandidate);
				if (ooErr)
				{
					dagQuery->Close ();
					return ooErr;
				}
			}
		}

		// get next chunk
		ooErr = dagQuery->GetNextChunk (JDT_ERDBASETRANSFIX_BATCH_SIZE, key, &dagRes);
		if ((ooErr) && (ooErr != dbmNoDataFound))
		{
			dagQuery->Close ();
			return ooErr;
		}
	}

	dagQuery->Close();
	return ooNoErr;
}
/****************************************************************************/

/**
 * Retrieve BaseTrans candidate according to supplied Ref3Line
 *
 * Ref3Line is in following format <pp>/<abbrev>/<docnum>
 * <pp> - posting period code
 * <abbrev> - document type abbreviation (e.g. 'IN', 'RC', 'JE')
 * <docnum> - number of document to which ERD is posted to
 *
 * To be more precise possible candidates are checked if it have same
 * Account/BP as ERD JE and if they are in foreign currency
 *
 * This is select used for A/R invoices when looking for candidates
 * SELECT T0.[TransId] 
 * FROM [dbo].[OINV] T0 
 * INNER JOIN [dbo].[OFPR] T1 ON T1.[AbsEntry] = T0.[FinncPriod]
 * WHERE T0.[DocNum] = (docNum)
 *   AND T1.[Code] = (periodCode) 
 *   AND (SELECT COUNT(U0.[TransId]) FROM [dbo].[JDT1] U0 
 *        WHERE T0.[TransId] = U0.[TransId] 
 *          AND U0.[Account] = (inAccount) 
 *          AND U0.[ShortName] = (inShortName) 
 *          AND U0.[FCCurrency] <> (@localCurrency) 
 *          AND U0.[FCCurrency] IS NOT NULL ) > 0 
 *
 * @param objectMap  List of possible abbreviations for all relevant objects
 *					 (@see UpgradeERDBaseTransPopulateAbbrevMap)
 * @param inAccount  Account of ERD JE to which possible candidate should also
 *                   have posting
 * @param inShortName  Account/BP of ERD JE
 * @param inRef3Line  Ref3 text that should be parsed
 * @param outBaseTransCandidate  Resulting candidate
 * @return  Error code. dbmNoDataFound when no candidate or when 2 or more
 *          candidates were found
 */
SBOErr CTransactionJournalObject::UpgradeERDBaseTransFindBaseTrans (const ObjectAbbrevsMap& objectMap, const SBOString& inAccount, const SBOString& inShortName, const SBOString& inRef3Line, long *outBaseTransCandidate)
{
	SBOErr			ooErr = ooNoErr;
	CBizEnv&		bizEnv = GetEnv ();
	long			condNum;
	DBD_TablesList	tablePtr;
	DBD_CondStruct	joinCondsOFPR [1];
	DBD_Params		queryParams;
	long			numOfCandidates = 0;

	// {{{ Parse Ref3Line string
	long sep1Pos, sep2Pos;
	SBOString periodCode, docTypeCode, docNum;

	sep1Pos = inRef3Line.Find (JDT_ERDBASETRANSFIX_REF3_SEPARATOR);
	periodCode = inRef3Line.Left (sep1Pos);
	sep2Pos = inRef3Line.Find (JDT_ERDBASETRANSFIX_REF3_SEPARATOR, sep1Pos + 1);
	docTypeCode = inRef3Line.Mid (sep1Pos + 1, sep2Pos - sep1Pos - 1);
	docNum = inRef3Line.Mid (sep2Pos + 1);
	// }}}

	ObjectAbbrevsMapCIt omIt;
	for (omIt = objectMap.begin (); omIt != objectMap.end (); ++omIt)
	{
		if (omIt->second.find (docTypeCode) != omIt->second.end ())
		{
			long objectId = omIt->first;

			queryParams.Clear ();
			// {{{ DOCUMENT HEADER - table 0
			tablePtr = &(queryParams.GetCondTables ().AddTable ());
			tablePtr->tableCode = bizEnv.ObjectToTable (objectId, ao_Main);
			// }}}

			// {{{ OFPR - table 1
			tablePtr = &(queryParams.GetCondTables ().AddTable ());
			tablePtr->tableCode = bizEnv.ObjectToTable (FPR, ao_Main);
			tablePtr->doJoin = true;
			tablePtr->joinedToTable = 0;
			tablePtr->numOfConds = 1;
			tablePtr->joinConds = joinCondsOFPR;

			// joinCondsOFPR
			condNum = 0;
			joinCondsOFPR[condNum].compareCols = true;
			joinCondsOFPR[condNum].tableIndex = 1;
			joinCondsOFPR[condNum].colNum = OFPR_ABS_ENTRY;
			joinCondsOFPR[condNum].compTableIndex = 0;
			joinCondsOFPR[condNum].compColNum = UpgradeERDBaseTransGetFPRCol (objectId);
			joinCondsOFPR[condNum].operation = DBD_EQ;
			joinCondsOFPR[condNum++].relationship = 0;
			// }}}

			DBD_ResStruct	resStruct [1];

			resStruct[0].tableIndex = 0;
			resStruct[0].colNum = UpgradeERDBaseTransGetTransIdCol (objectId);

			queryParams.dbdResPtr = resStruct;
			queryParams.numOfResCols = 1;

			PDBD_Cond condPtr;

			UpgradeERDBaseTransAddDocNumConds (objectId, docNum, queryParams.GetConditions ());

			condPtr = &(queryParams.GetConditions ().AddCondition ());
			condPtr->tableIndex = 1;
			condPtr->colNum = OFPR_CODE;
			condPtr->operation = DBD_EQ;
			condPtr->condVal = periodCode;
			condPtr->relationship = DBD_AND;

			// {{{ Sub-query check
			DBD_Params subQueryParams;
			DBD_ResStruct subResStruct[1];
			{
				condPtr = &(queryParams.GetConditions ().AddCondition ());
				condPtr->SetUseSubQuery(true);

				subQueryParams.GetCondTables ().Clear ();
				tablePtr = &(subQueryParams.GetCondTables ().AddTable ());
				tablePtr->tableCode = bizEnv.ObjectToTable (JDT, ao_Arr1);

				subResStruct[0].agreg_type = DBD_COUNT;
				subResStruct[0].tableIndex = 0;
				subResStruct[0].colNum = JDT1_TRANS_ABS;

				subQueryParams.dbdResPtr = subResStruct;
				subQueryParams.numOfResCols = 1;

				subQueryParams.GetConditions().Clear ();
				PDBD_Cond subCondPtr = &(subQueryParams.GetConditions().AddCondition ());
				subCondPtr->origTableLevel = 1;
				subCondPtr->origTableIndex = 0;
				subCondPtr->compareCols = true;
				subCondPtr->colNum = UpgradeERDBaseTransGetTransIdCol (objectId);
				subCondPtr->operation = DBD_EQ;
				subCondPtr->compTableIndex = 0;
				subCondPtr->compColNum = JDT1_TRANS_ABS;
				subCondPtr->relationship = DBD_AND;

				subCondPtr = &(subQueryParams.GetConditions().AddCondition ());
				subCondPtr->tableIndex = 0;
				subCondPtr->colNum = JDT1_ACCT_NUM;
				subCondPtr->operation = DBD_EQ;
				subCondPtr->condVal = inAccount;
				subCondPtr->relationship = DBD_AND;

				subCondPtr = &(subQueryParams.GetConditions().AddCondition ());
				subCondPtr->tableIndex = 0;
				subCondPtr->colNum = JDT1_SHORT_NAME;
				subCondPtr->operation = DBD_EQ;
				subCondPtr->condVal = inShortName;
				subCondPtr->relationship = DBD_AND;

				subCondPtr = &(subQueryParams.GetConditions().AddCondition ());
				subCondPtr->tableIndex = 0;
				subCondPtr->colNum = JDT1_FC_CURRENCY;
				subCondPtr->operation = DBD_NE;
				subCondPtr->condVal = bizEnv.GetMainCurrency();
				subCondPtr->relationship = DBD_AND;

				subCondPtr = &(subQueryParams.GetConditions().AddCondition ());
				subCondPtr->tableIndex = 0;
				subCondPtr->colNum = JDT1_FC_CURRENCY;
				subCondPtr->operation = DBD_NOT_NULL;
				subCondPtr->relationship = 0;

				condPtr->SetSubQueryParams (&subQueryParams);
				condPtr->tableIndex = DBD_NO_TABLE;
				condPtr->operation = DBD_GT;
				condPtr->condVal = 0L;
				condPtr->relationship = 0;
			}
			// }}}

			PDAG dagRes = NULL;
			PDAG dagQuery = bizEnv.OpenDAG(BOT, ao_Arr1);
			dagQuery->SetDBDParms (&queryParams);

			// get from DB
			ooErr = DBD_GetInNewFormat (dagQuery, &dagRes);
			if (ooErr)
			{
				if (ooErr == dbmNoDataFound)
				{
					dagRes->SetSize (0, dbmDropData);
					ooErr = ooNoErr;
				}
				else
				{
					dagQuery->Close ();
					return ooErr;
				}
			}

			if (dagRes->GetRecordCount () > 0)
			{
				numOfCandidates += dagRes->GetRecordCount ();
				dagRes->GetColLong (outBaseTransCandidate, 0, 0);
			}
			dagQuery->Close();
		}
	}
	if (numOfCandidates == 1)
	{
		// We have exactly one candidate (already in outBaseTransCandidate),
		// so let's return it
		ooErr = ooNoErr;
	}
	else
	{
		// Ref3 does not point to exactly one document, so we cannot use it
		ooErr = dbmNoDataFound;
	}

	return ooErr;
}
/****************************************************************************/

/**
 * Populate conditions that tests document number (used in Ref3Line) for
 * specific objects
 * 
 * @param objectId  Document type
 * @param docNum  Document Number (not AbsEntry)
 * @param conds  Reference to conditions list to append to
 */
void CTransactionJournalObject::UpgradeERDBaseTransAddDocNumConds (long objectId, const SBOString& docNum, DBD_Conditions& conds)
{
	PDBD_Cond condPtr;

	if (objectId == JDT)
	{
		condPtr = &(conds.AddCondition ());
		condPtr->bracketOpen = 1;
		condPtr->tableIndex = 0;
		condPtr->colNum = OJDT_NUMBER;
		condPtr->operation = DBD_EQ;
		condPtr->condVal = docNum;
		condPtr->relationship = DBD_OR;

		condPtr = &(conds.AddCondition ());
		condPtr->tableIndex = 0;
		condPtr->colNum = OJDT_JDT_NUM;
		condPtr->operation = DBD_EQ;
		condPtr->condVal = docNum;
		condPtr->bracketClose = 1;
	}
	else if (objectId == RCT || objectId == VPM)
	{
		condPtr = &(conds.AddCondition ());
		condPtr->tableIndex = 0;
		condPtr->colNum = ORCT_NUM;
		condPtr->operation = DBD_EQ;
		condPtr->condVal = docNum;
		condPtr->relationship = DBD_AND;

		condPtr = &(conds.AddCondition ());
		condPtr->tableIndex = 0;
		condPtr->colNum = ORCT_CANCELED;
		condPtr->operation = DBD_NE;
		condPtr->condVal = VAL_YES;
	}
	else
	{
		condPtr = &(conds.AddCondition ());
		condPtr->tableIndex = 0;
		condPtr->colNum = OINV_NUM;
		condPtr->operation = DBD_EQ;
		condPtr->condVal = docNum;
	}
	condPtr->relationship = DBD_AND;
}
/****************************************************************************/

/**
 * Return the column in document's header table that contains TransId of
 * related JE transaction
 * 
 * @param objectId  Document type
 * @return  Column number
 */
long CTransactionJournalObject::UpgradeERDBaseTransGetTransIdCol (long objectId)
{
	if (objectId == JDT)
	{
		return OJDT_JDT_NUM;
	}
	else if (objectId == RCT || objectId == VPM)
	{
		return ORCT_TRANS_NUM;
	}
	else
	{
		return OINV_TRANS_NUM;
	}
}
/****************************************************************************/

/**
 * Return the column in document's header table that contains key to Financial
 * period
 * 
 * @param objectId  Document type
 * @return  Column number
 */
long CTransactionJournalObject::UpgradeERDBaseTransGetFPRCol (long objectId)
{
	if (objectId == JDT)
	{
		return OJDT_FINANCE_PERIOD;
	}
	else if (objectId == RCT || objectId == VPM)
	{
		return ORCT_FINANCE_PERIOD;
	}
	else
	{
		return OINV_FINANCE_PERIOD;
	}
}
/****************************************************************************/

/**
 * Build list of objects with theirs possible abbreviations used in Ref3Line
 * 
 * @param abbrevMap  Reference to map that will be populated
 */
void CTransactionJournalObject::UpgradeERDBaseTransPopulateAbbrevMap (ObjectAbbrevsMap& abbrevMap)
{
	// INV
	DocAbbrevSet docAbbrevs;
	docAbbrevs.insert (_T("IN")); // EN
	docAbbrevs.insert (_T("FP")); // CZ
	docAbbrevs.insert (_T("VS")); // HU
	docAbbrevs.insert (_T("PF")); // PL
	docAbbrevs.insert (_T("FA")); // SK
	abbrevMap[INV] = docAbbrevs;

	// RIN
	docAbbrevs.clear ();
	docAbbrevs.insert (_T("CN")); // EN
	docAbbrevs.insert (_T("DP")); // CZ
	docAbbrevs.insert (_T("KI")); // HU
	docAbbrevs.insert (_T("ZP")); // PL
	docAbbrevs.insert (_T("KR")); // SK (2004C)
	docAbbrevs.insert (_T("OD")); // SK (2007A)
	abbrevMap[RIN] = docAbbrevs;

	// PCH
	docAbbrevs.clear ();
	docAbbrevs.insert (_T("PU")); // EN
	docAbbrevs.insert (_T("FN")); // CZ
	docAbbrevs.insert (_T("SS")); // HU
	docAbbrevs.insert (_T("FZ")); // PL
	docAbbrevs.insert (_T("FV")); // SK (2004C)
	docAbbrevs.insert (_T("DF")); // SK (2007A)
	abbrevMap[PCH] = docAbbrevs;

	// RPC
	docAbbrevs.clear ();
	docAbbrevs.insert (_T("PC")); // EN
	docAbbrevs.insert (_T("DN")); // CZ
	docAbbrevs.insert (_T("SJ")); // HU
	docAbbrevs.insert (_T("ZK")); // PL
	docAbbrevs.insert (_T("KM")); // SK (2004C)
	docAbbrevs.insert (_T("DN")); // SK (2007A)
	abbrevMap[RPC] = docAbbrevs;

	// CPI 
	docAbbrevs.clear ();
	docAbbrevs.insert (_T("CV")); // EN
	docAbbrevs.insert (_T("CU")); // CZ
	docAbbrevs.insert (_T("OF")); // CZ
	docAbbrevs.insert (_T("BH")); // HU
	docAbbrevs.insert (_T("SV")); // HU
	docAbbrevs.insert (_T("SZ")); // PL
	docAbbrevs.insert (_T("CN")); // SK
	abbrevMap[CPI] = docAbbrevs;

	// CSI
	docAbbrevs.clear ();
	docAbbrevs.insert (_T("CS")); // EN
	docAbbrevs.insert (_T("OF")); // CZ
	docAbbrevs.insert (_T("KH")); // HU
	docAbbrevs.insert (_T("VV")); // HU
	docAbbrevs.insert (_T("SK")); // PL
	docAbbrevs.insert (_T("CP")); // SK
	docAbbrevs.insert (_T("CE")); // SK
	abbrevMap[CSI] = docAbbrevs;

	// RCT
	docAbbrevs.clear ();
	docAbbrevs.insert (_T("RC")); // EN
	docAbbrevs.insert (_T("BP")); // CZ
	docAbbrevs.insert (_T("FB")); // HU
	docAbbrevs.insert (_T("KP")); // PL
	docAbbrevs.insert (_T("DP")); // SK
	abbrevMap[RCT] = docAbbrevs;

	// VPM
	docAbbrevs.clear ();
	docAbbrevs.insert (_T("PS")); // EN
	docAbbrevs.insert (_T("BV")); // CZ
	docAbbrevs.insert (_T("FK")); // HU (2004C)
	docAbbrevs.insert (_T("FZ")); // HU (2007A)
	docAbbrevs.insert (_T("ZD")); // PL
	docAbbrevs.insert (_T("PD")); // SK
	abbrevMap[VPM] = docAbbrevs;

	// JDT
	docAbbrevs.clear ();
	docAbbrevs.insert (_T("JE")); // EN
	docAbbrevs.insert (_T("ZD")); // CZ
	docAbbrevs.insert (_T("NB")); // HU
	docAbbrevs.insert (_T("KS")); // PL
	docAbbrevs.insert (_T("UZ")); // SK
	abbrevMap[JDT] = docAbbrevs;
	// }}}
}

/**
* Update RIN6.VatPaid and RPC6.VatPaid for fully based credit memos
* to fix IM 393374 2009
* 
* UPDATE T0 SET T0.[VatPaid] = T0.[VatSum],T0.[VatPaidSys] = T0.[VatSumSy],T0.[VatPaidFC] = T0.[VatSumFC]  
* FROM  [dbo].[RIN6] T0 ,  [dbo].[ORIN] T1  WHERE T0.[DocEntry] = T1.[DocEntry]  AND  T0.[Status] = (@P1)  
* AND  * T1.[DocStatus] = (@P2)  AND  T0.[VatPaid] = (@P3)
* @P1 char(2),@P2 char(2),@P3 numeric(25, 6)','C ','C ',0
*
* @return SBOErr 
*/
SBOErr  CTransactionJournalObject::UpgradeDOC6VatPaidForFullyBasedCreditMemos(long objID)
{
	SBOErr ooErr = noErr;
	CBizEnv& env = GetEnv();

	DBQUpdateStatement updStmt(env);
	try
	{
		DBQTable tDoc6 = updStmt.Update(env.ObjectToTable (objID, ao_Arr6));
		DBQTable tOdoc = updStmt.Update(env.ObjectToTable (objID, ao_Main));

		updStmt.Set(INV6_VAT_APPLIED).Col(tDoc6, INV6_VAT_SUM);
		updStmt.Set(INV6_VAT_APPLIED_SYS).Col(tDoc6, INV6_VAT_SYS);
		updStmt.Set(INV6_VAT_APPLIED_FRGN).Col(tDoc6, INV6_VAT_FRGN);

		updStmt.Where().Col(tDoc6, INV6_ABS_ENTRY).EQ().Col(tOdoc, OINV_ABS_ENTRY).And().
			Col(tDoc6, INV6_STATUS).EQ().Val(VAL_CLOSE).And().
			Col(tOdoc, OINV_STATUS).EQ().Val(VAL_CLOSE).And().
			Col(tDoc6, INV6_VAT_APPLIED).EQ().Val(0L);

		updStmt.Execute();
	}
	catch (DBMException &e)
	{
		ooErr = e.GetCode();
		return ooErr;
	}

	return ooErr;
}

/**
* Update ORIN.VatPaid and ORPC.VatPaid for fully based credit memos
* to fix IM 393374 2009
* 
* UPDATE T0 SET T0.[VatPaid] = T0.[VatSum],T0.[VatPaidSys] = T0.[VatSumSy],T0.[VatPaidFC] = T0.[VatSumFC]  
* FROM  [dbo].[ORIN] T0  WHERE T0.[VatPaid] = (@P1)  AND  T0.[DocStatus] = (@P2)
* @P1 numeric(25, 6),@P2 char(2)',0,'C '

* @return SBOErr 
*/
SBOErr  CTransactionJournalObject::UpgradeODOCVatPaidForFullyBasedCreditMemos(long objID)
{
	SBOErr ooErr = noErr;
	CBizEnv& env = GetEnv();

	DBQUpdateStatement updStmt(env);
	try
	{
		DBQTable tOdoc = updStmt.Update(env.ObjectToTable (objID, ao_Main));

		updStmt.Set(OINV_VAT_APPLIED).Col(tOdoc, OINV_VAT_SUM);
		updStmt.Set(OINV_VAT_APPLIED_SYS).Col(tOdoc, OINV_VAT_SYS);
		updStmt.Set(OINV_VAT_APPLIED_FRGN).Col(tOdoc, OINV_VAT_FRGN);

		updStmt.Where().Col(tOdoc, OINV_VAT_APPLIED).EQ().Val(0L).And().
						Col(tOdoc, OINV_STATUS).EQ().Val(VAL_CLOSE);

		updStmt.Execute();
	}
	catch (DBMException &e)
	{
		ooErr = e.GetCode();
		return ooErr;
	}

	return ooErr;
}

/**
 * GetCreateDate
 *
 * 
 * @return Date 
*/
Date CTransactionJournalObject::GetCreateDate()
{
	SBOString date = EMPTY_STR;
	PDAG dag = GetDAG ();
	if (dag)
	{
		dag->GetColStr (date, OJDT_CREATE_DATE);
	}
	return Date (date);
}

/***************************************************************************************
Repair the incorrect EquVatRate of JDT1. In the bellowing cases the EquVatRate will be 
incorrect: add an AR Invoice / Credit Memo / AR Down Payment Invoice / Incoming Pay to 
Account with Equalization tax rate; 
****************************************************************************************/ 
SBOErr CTransactionJournalObject::RepairEquVatRateOfJDT1 ()
{
	SBOErr	ooErr = ooNoErr;
	long	objectId[] = {INV, RIN, DPI, RCT, VPM, NOB}; 

	for (long i = 0; objectId[i] != NOB; i++)
	{
		ooErr = RepairEquVatRateOfJDT1ForOneObject (objectId[i]);
		IF_ERROR_RETURN (ooErr);
	}

	return ooErr;
}

/***************************************************************************************
SELECT DISTINCT TOP 10000 T0.[AbsEntry], T0.[TaxCode], T0.[EqPercent], T3.[TransId], T3.[Line_ID] 
FROM  TAX1 T0  
INNER  JOIN OTAX T1  ON  T1.[AbsEntry] = T0.[AbsEntry]   
INNER  JOIN OJDT T2  ON  T2.[TransType] = T1.[SrcObjType]  AND  T2.[BaseRef] = T1.[SrcObjAbs]   
INNER  JOIN JDT1 T3  ON  T3.[TransId] = T2.[TransId]  AND  T3.[VatLine] = N'Y'  
AND  T3.[VatGroup] = T0.[TaxCode]   
INNER  JOIN OINV T4  ON  T4.[DocEntry] = T1.[SrcObjAbs]   
WHERE T0.[EqPercent] <> 0  AND  T1.[SrcObjType] = N'13'  
AND  (T4.[VersionNum] Like N'8.00.226.%'   OR  T4.[VersionNum] Like N'8.00.227.%'  )  
ORDER BY T3.[TransId],T3.[Line_ID]
****************************************************************************************/
SBOErr CTransactionJournalObject::RepairEquVatRateOfJDT1ForOneObject (long objectId)
{
	SBOErr			ooErr = ooNoErr;
	SMU_BQ_Table	tableTAX1, tableOTAX, tableOJDT, tableJDT1, tableOINV;
	SMU_BQ_Context	bq (&GetEnv ());

	// TAX1
	bq.AddTable (TAX, ao_Arr1, &tableTAX1); 

	//OTAX
	bq.AddJoin (TAX, ao_Main, &tableOTAX, tableTAX1, SMU_BQ_INNER_JOIN); 
	bq.ConditionContext_SetToJoin (tableOTAX);
	bq.AddConditions ().
		Col (tableOTAX, OTAX_ABS_ENTRY).EQ ().Col (tableTAX1, TAX1_ABS_ENTRY);

	// OJDT
	bq.AddJoin (JDT, ao_Main, &tableOJDT, tableOTAX, SMU_BQ_INNER_JOIN); 
	bq.ConditionContext_SetToJoin (tableOJDT);
	bq.AddConditions ().
		Col (tableOJDT, OJDT_TRANS_TYPE).EQ ().Col (tableOTAX, OTAX_SOURCE_OBJ_TYPE).AND ().
		Col (tableOJDT, OJDT_BASE_REF).EQ ().Col (tableOTAX, OTAX_SOURCE_OBJ_ABS_ENTRY);

	// JDT1
	bq.AddJoin (JDT, ao_Arr1, &tableJDT1, tableOJDT, SMU_BQ_INNER_JOIN); 
	bq.ConditionContext_SetToJoin (tableJDT1);
	bq.AddConditions ().
		Col (tableJDT1, JDT1_TRANS_ABS).EQ ().Col (tableOJDT, OJDT_JDT_NUM).AND ().
		Col (tableJDT1, JDT1_VAT_LINE).EQ ().Val (VAL_YES).AND ().
		Col (tableJDT1, JDT1_VAT_GROUP).EQ ().Col (tableTAX1, TAX1_TAX_CODE);

	// OINV
	bq.AddJoin (objectId, ao_Main, &tableOINV, tableOTAX, SMU_BQ_INNER_JOIN);
	bq.ConditionContext_SetToJoin (tableOINV);
	bq.AddConditions ().
		Col (tableOINV, INV1_ABS_ENTRY).EQ ().Col (tableOTAX, OTAX_SOURCE_OBJ_ABS_ENTRY);

	// where
	bq.ConditionContext_SetToWherePart ();
	bq.AddConditions ().
		Col (tableTAX1, TAX1_EQ_PERCENT).NE ().Val (STR_0).AND ().
		Col (tableOTAX, OTAX_SOURCE_OBJ_TYPE).EQ ().Val (objectId);

	bq.AddCondition_AND ();
	bq.AddCondition_BracketOpen ();
	for (long version = VERSION_2007_226; version <= VERSION_2007_227; version++)
	{
		SBOString versionStr (version), major, minor, build;
		major = versionStr.Left (1);
		minor = versionStr.Mid (1, 2);
		build = versionStr.Right (3);

		versionStr = major + _T(".") + minor + _T(".") + build + _T(".*");
		bq.AddCondition_CompareColumnWithString (tableOINV, 
			(objectId == RCT || objectId == VPM) ? ORCT_VERSION_NUM: OINV_VERSION_NUM, 
			DBD_PATTERN, versionStr);
		if (version != VERSION_2007_227)
		{
			bq.AddCondition_OR ();
		}
	}
	bq.AddCondition_BracketClose ();

	// result
	bq.AddResultColumn (resTax1AbsEntry, tableTAX1, TAX1_ABS_ENTRY);
	bq.AddResultColumn (resTax1TaxCode, tableTAX1, TAX1_TAX_CODE);
	bq.AddResultColumn (resTax1EqPercent, tableTAX1, TAX1_EQ_PERCENT);
	bq.AddResultColumn (resJdt1TransId, tableJDT1, JDT1_TRANS_ABS);
	bq.AddResultColumn (resJdt1Line_ID, tableJDT1, JDT1_LINE_ID);

	// sort
	bq.AddSortParam (tableJDT1, JDT1_TRANS_ABS, false);
	bq.AddSortParam (tableJDT1, JDT1_LINE_ID, false);

	// add DISTINCT flag
	bq.SetFlag (DBD_FLAG_DISTINCT_DAG, true);

	DBM_KA key;
	key.SetSegmentsCount (2);
	key.SetSegmentColumn (0, resJdt1TransId);
	key.SetSegmentColumn (1, resJdt1Line_ID);

	PDAG dagRes = NULL;
	PDAG dagQuery = GetEnv ().OpenDAG (JDT, ao_Arr1);
	bq.AssignToDAG (dagQuery);

	// get first chunk
	ooErr = dagQuery->GetFirstChunk (UPG_JDT1_EQUVATRATE_CHUNK_SIZE, key, &dagRes);
	if (ooErr && ooErr != dbmNoDataFound)
	{
		dagQuery->Close ();
		return ooErr;
	}

	// loop over chunks
	while (ooErr == ooNoErr)
	{	
		// process the chunk
		ooErr = UpdateIncorrectEquVatRate (dagRes);
		if (ooErr)
		{
			dagQuery->Close ();
			return ooErr;
		}

		// get next chunk
		ooErr = dagQuery->GetNextChunk (UPG_JDT1_EQUVATRATE_CHUNK_SIZE, key, &dagRes);
	}

	if (ooErr == dbmNoDataFound)
	{
		ooErr = ooNoErr;
	}

	dagQuery->Close ();
	return ooErr;
}

/*****************************************************************
In the query results, if two lines have the same absEntry and 
vatGroup, then only update the second line, which is determined
as Equ tax line. Otherwise, update that line, which is determined as
VAT and Equ tax line.
rec	absEntry	vatGroup	EqPercent	Update?
---------------------------------------------------------------
0		1			RE1			0.5			N
1		1			RE1			0.5			Y
2		2			RE2			1			Y
3		3			RE3			4			N
4		3			RE3			4			Y
*****************************************************************/
SBOErr CTransactionJournalObject::UpdateIncorrectEquVatRate (PDAG dagRes)
{
	SBOErr		ooErr = ooNoErr;
	long		absEntry, nextAbsEntry;
	SBOString	vatGroup, nextVatGroup;

	long rec = dagRes->GetRecordCount () - 1;

	for (; rec >= 0; rec--)
	{
		ooErr = UpdateIncorrectEquVatRateOneRec (dagRes, rec);
		IF_ERROR_RETURN (ooErr);

		dagRes->GetColLong (&absEntry, resTax1AbsEntry, rec);
		dagRes->GetColStr (vatGroup, resTax1TaxCode, rec);
		vatGroup.Trim ();

		if (rec - 1 >= 0)
		{
			dagRes->GetColLong (&nextAbsEntry, resTax1AbsEntry, rec - 1);
			dagRes->GetColStr (nextVatGroup, resTax1TaxCode, rec - 1);
			nextVatGroup.Trim ();
		}
		else
		{
			break;
		}

		if (absEntry == nextAbsEntry && vatGroup == nextVatGroup)
		{
			rec--;
		}
	}

	return ooErr;
}

/*****************************************************************
Update the incorrect EquVatRate of JDT1:
UPDATE	T0
SET		T0.[EquVatRate] = equVatRate
FROM	JDT1 T0
WHERE	T0.[TransId] = transId 
AND		T0.[Line_ID] = lineId
*****************************************************************/
SBOErr CTransactionJournalObject::UpdateIncorrectEquVatRateOneRec (PDAG dagRes, long rec)
{
	SBOErr	ooErr = ooNoErr;
	long	transId, lineId;
	MONEY	equVatRate;

	dagRes->GetColLong (&transId, resJdt1TransId, rec);
	dagRes->GetColLong (&lineId, resJdt1Line_ID, rec);
	dagRes->GetColMoney (&equVatRate, resTax1EqPercent, rec);

	DBD_CondStruct	conds[2];
	DBD_UpdStruct	updateStruct[1]; 

	conds[0].colNum = JDT1_TRANS_ABS;
	conds[0].operation = DBD_EQ;
	conds[0].condVal = transId;
	conds[0].relationship = DBD_AND;

	conds[1].colNum = JDT1_LINE_ID;
	conds[1].operation = DBD_EQ;
	conds[1].condVal = lineId;
	conds[1].relationship = 0;

	updateStruct[0].colNum = JDT1_EQU_VAT_PERCENT;
	equVatRate.ToSBOString(updateStruct[0].updateVal);

	PDAG dagJDT1 = GetEnv ().OpenDAG (JDT, ao_Arr1);
	DBD_SetDAGCond (dagJDT1, conds, 2);
	DBD_SetDAGUpd (dagJDT1, updateStruct, 1);

	ooErr = DBD_UpdateCols (dagJDT1);

	dagJDT1->Close ();
	return ooErr;
}

/************************************************************************************/
/*

Error desc:
BP's EndYearClosing, after closing the BP balance both transactions (OB and BC) remain unreconciled. 
System reconciles accounts 70201 and 70101 (closing and opening accounts) which is incorrect.

Fix:
Reopen 70201 and 70101 JE postings
Alter reconciliation data to reconcile the BP's postings
Close related JEs
Note that the sums are correct however the reconciliation is related to the bad JDT1 entry

Affected entities:
JDT1.BalanceDues, OITR.IsCard, ITR1.IsCredit, Account, ShortName, TransRowID

*/
/************************************************************************************/
#define CPE_RES_RECON_NUM		0
#define CPE_RES_LINE_SEQUENCE	1
#define CPE_RES_TRANS_ID		2
#define CPE_RES_TRANS_LINE_ID	3
#define CPE_RES_SRC_OBJ_TYPE	4

SBOErr CTransactionJournalObject::UpgradeJDTCEEPerioEndReconcilations ()
{
	_TRACER("UpgradeJDTCEEPerioEndReconcilations");

	SBOErr			sboErr = noErr;
	PDAG			dagRes;
	CBizEnv			&bizEnv = GetEnv ();

	DBD_Conditions	*conditions;
	PDBD_Cond		cond;
	DBD_Tables		tables[4];
	DBD_CondStruct	join1[1], join2[1], join3[1];
	DBD_ResStruct	resStruct[5];
	DBD_SortStruct	sortStruct[2];

	PDAG dagJDT1 = GetDAG ();

	// get list of reconciliations to fix
	/*	SELECT T2.[ReconNum], T2.[LineSeq], T2.[TransId], T2.[TransRowId], T2.[SrcObjTyp] 
	FROM [dbo].[JDT1] T0 INNER JOIN [dbo].[OJDT] T1 
	ON T1.[TransId] = T0.[TransId] INNER JOIN [dbo].[ITR1] T2 
	ON T2.[TransId] = T0.[TransId] INNER JOIN [dbo].[OITR] T3 
	ON T3.[ReconNum] = T2.[ReconNum] 
	WHERE (T0.[BalDueDeb] <> (0) 
	OR T0.[BalDueCred] <> (0)
	OR T0.[BalFcDeb] <> (0) 
	OR T0.[BalFcCred] <> (0)
	OR T0.[BalScDeb] <> (0) 
	OR T0.[BalScCred] <> (0) ) 
	AND (T1.[TransType] = (N'-2') 
	OR T1.[TransType] = (N'-3') ) 
	AND (T2.[SrcObjTyp] = (N'-2') 
	OR T2.[SrcObjTyp] = (N'-3') ) 
	AND T3.[InitObjTyp] = (N'30') 
	*/
	dagJDT1->ClearQueryParams();

	tables[0].tableCode = bizEnv.ObjectToTable (JDT, ao_Arr1);
	tables[1].tableCode = bizEnv.ObjectToTable (JDT, ao_Main);
	tables[2].tableCode = bizEnv.ObjectToTable (ITR, ao_Arr1);
	tables[3].tableCode = bizEnv.ObjectToTable (ITR, ao_Main);

	// INNER JOIN [dbo].[OJDT] T1 ON T1.[TransId] = T0.[TransId]
	tables[1].doJoin		= true;
	tables[1].joinedToTable	= 0;
	tables[1].numOfConds	= 1;
	tables[1].joinConds		= join1;
	join1[0].compareCols	= true;
	join1[0].compColNum		= JDT1_TRANS_ABS;
	join1[0].compTableIndex	= 0;
	join1[0].colNum			= OJDT_JDT_NUM;
	join1[0].tableIndex		= 1;
	join1[0].operation		= DBD_EQ;

	// INNER JOIN [dbo].[ITR1] T2 ON T2.[TransId] = T0.[TransId]
	tables[2].doJoin		= true;
	tables[2].joinedToTable	= 0;
	tables[2].numOfConds	= 1;
	tables[2].joinConds		= join2;
	join2[0].compareCols	= true;
	join2[0].compColNum		= JDT1_TRANS_ABS;
	join2[0].compTableIndex	= 0;
	join2[0].colNum			= ITR1_TRANS_ID;
	join2[0].tableIndex		= 2;
	join2[0].operation		= DBD_EQ;

	// INNER JOIN [dbo].[OITR] T3 ON T3.[ReconNum] = T2.[ReconNum]
	tables[3].doJoin		= true;
	tables[3].joinedToTable	= 2;
	tables[3].numOfConds	= 1;
	tables[3].joinConds		= join3;
	join3[0].compareCols	= true;
	join3[0].compColNum		= ITR1_RECON_NUM;
	join3[0].compTableIndex	= 2;
	join3[0].colNum			= OITR_RECON_NUM;
	join3[0].tableIndex		= 3;
	join3[0].operation		= DBD_EQ;

	DBD_SetTablesList (dagJDT1, tables, 4);

	resStruct[CPE_RES_RECON_NUM].tableIndex = 2;
	resStruct[CPE_RES_RECON_NUM].colNum = ITR1_RECON_NUM;
	resStruct[CPE_RES_LINE_SEQUENCE].tableIndex = 2;
	resStruct[CPE_RES_LINE_SEQUENCE].colNum = ITR1_LINE_SEQUENCE;
	resStruct[CPE_RES_TRANS_ID].tableIndex = 2;
	resStruct[CPE_RES_TRANS_ID].colNum = ITR1_TRANS_ID;
	resStruct[CPE_RES_TRANS_LINE_ID].tableIndex = 2;
	resStruct[CPE_RES_TRANS_LINE_ID].colNum = ITR1_TRANS_LINE_ID;
	resStruct[CPE_RES_SRC_OBJ_TYPE].tableIndex = 2;
	resStruct[CPE_RES_SRC_OBJ_TYPE].colNum = ITR1_SRC_OBJ_TYPE;
	DBD_SetDAGRes (dagJDT1, resStruct, 5);

	// (T0.[BalDueDeb] <> (0) OR T0.[BalDueCred] <> (0) OR T0.[BalFcDeb] <> (0) OR T0.[BalFcCred] <> (0) OR T0.[BalScDeb] <> (0) OR T0.[BalScCred] <> (0) ) )
	conditions = &dagJDT1->GetDBDParams ()->GetConditions ();
	cond = &conditions->AddCondition();
	cond->bracketOpen = true;
	cond->colNum = JDT1_BALANCE_DUE_DEBIT;
	cond->condVal = _T("0.00");
	cond->operation = DBD_NE;
	cond->relationship = DBD_OR;
	cond = &conditions->AddCondition();
	cond->colNum = JDT1_BALANCE_DUE_CREDIT;
	cond->condVal = _T("0.00");
	cond->operation = DBD_NE;
	cond->relationship = DBD_OR;
	cond = &conditions->AddCondition();
	cond->colNum = JDT1_BALANCE_DUE_FC_DEB;
	cond->condVal = _T("0.00");
	cond->operation = DBD_NE;
	cond->relationship = DBD_OR;
	cond = &conditions->AddCondition();
	cond->colNum = JDT1_BALANCE_DUE_FC_CRED;
	cond->condVal = _T("0.00");
	cond->operation = DBD_NE;
	cond->relationship = DBD_OR;
	cond = &conditions->AddCondition();
	cond->colNum = JDT1_BALANCE_DUE_SC_DEB;
	cond->condVal = _T("0.00");
	cond->operation = DBD_NE;
	cond->relationship = DBD_OR;
	cond = &conditions->AddCondition();
	cond->colNum = JDT1_BALANCE_DUE_SC_CRED;
	cond->condVal = _T("0.00");
	cond->operation = DBD_NE;
	cond->bracketClose = true;
	cond->relationship = DBD_AND;

	// (T1.[TransType] = (N'-2') OR T1.[TransType] = (N'-3') )
	cond = &conditions->AddCondition();
	cond->bracketOpen		= true;
	cond->tableIndex		= 1;
	cond->colNum			= OJDT_TRANS_TYPE;
	cond->condVal			= SBOString(OPEN_BLNC_TYPE);
	cond->operation			= DBD_EQ;
	cond->relationship		= DBD_OR;
	cond = &conditions->AddCondition();
	cond->tableIndex		= 1;
	cond->colNum			= OJDT_TRANS_TYPE;
	cond->condVal			= SBOString(CLOSE_BLNC_TYPE);
	cond->operation			= DBD_EQ;
	cond->bracketClose		= true;
	cond->relationship		= DBD_AND;

	// (T2.[SrcObjTyp] = (N'-2') OR T2.[SrcObjTyp] = (N'-3') )
	cond = &conditions->AddCondition();
	cond->bracketOpen		= true;
	cond->tableIndex		= 2;
	cond->colNum			= ITR1_SRC_OBJ_TYPE;
	cond->condVal			= SBOString(OPEN_BLNC_TYPE);
	cond->operation			= DBD_EQ;
	cond->relationship		= DBD_OR;
	cond = &conditions->AddCondition();
	cond->tableIndex		= 2;
	cond->colNum			= ITR1_SRC_OBJ_TYPE;
	cond->condVal			= SBOString(CLOSE_BLNC_TYPE);
	cond->operation			= DBD_EQ;
	cond->bracketClose		= true;
	cond->relationship		= DBD_AND;

	// T3.[InitObjTyp] = (N'30')
	cond = &conditions->AddCondition();
	cond->tableIndex		= 3;
	cond->condVal			= JDT;
	cond->colNum			= OITR_INIT_OBJ_TYPE;
	cond->operation	 		= DBD_EQ;

	sboErr = DBD_GetInNewFormat (dagJDT1, &dagRes);
	if (sboErr)
	{
		if (sboErr == dbmNoDataFound)
		{
			sboErr = noErr;
		}
		return sboErr;
	}

	PDAG			dagUpdate;
	DBD_UpdStruct	updStruct[6];
	DBD_CondStruct  condStruct[6];
	DBD_ResColumns	*pResCol;
	long			srcObjTyp, i;
	long			numOfRecon = dagRes->GetRecordCount();

	dagUpdate = OpenDAG (JDT, ao_Arr1);

	for (i = 0; i < numOfRecon; i++)
	{
		// open JEs
		/* UPDATE T0 
		SET T0.[BalDueDeb] = T0.[Debit], T0.[BalFcDeb] = T0.[FCDebit]
		  , T0.[BalScDeb] = T0.[SYSDeb], T0.[BalDueCred] = T0.[Credit]
		  , T0.[BalFcCred] = T0.[FCCredit], T0.[BalScCred] = T0.[SYSCred] 
		FROM [dbo].[JDT1] T0 
		WHERE T0.[TransId] = dagRes.CPE_RES_TRANS_ID
		AND T0.[Line_ID] = dagRes.CPE_RES_TRANS_LINE_ID
		*/
		tables[0].tableCode = bizEnv.ObjectToTable (JDT, ao_Arr1);
		DBD_SetTablesList (dagUpdate, tables, 1);	

		updStruct[0].Clear();
		updStruct[0].colNum		= JDT1_BALANCE_DUE_DEBIT;
		updStruct[0].srcColNum	= JDT1_DEBIT;
		updStruct[0].SetUpdateColSource(DBD_UpdStruct::ucs_SrcCol);
		updStruct[1].Clear();
		updStruct[1].colNum		= JDT1_BALANCE_DUE_FC_DEB;
		updStruct[1].srcColNum	= JDT1_FC_DEBIT;
		updStruct[1].SetUpdateColSource(DBD_UpdStruct::ucs_SrcCol);
		updStruct[2].Clear();
		updStruct[2].colNum		= JDT1_BALANCE_DUE_SC_DEB;
		updStruct[2].srcColNum	= JDT1_SYS_DEBIT;
		updStruct[2].SetUpdateColSource(DBD_UpdStruct::ucs_SrcCol);
		updStruct[3].Clear();
		updStruct[3].colNum		= JDT1_BALANCE_DUE_CREDIT;
		updStruct[3].srcColNum	= JDT1_CREDIT;
		updStruct[3].SetUpdateColSource(DBD_UpdStruct::ucs_SrcCol);
		updStruct[4].Clear();
		updStruct[4].colNum		= JDT1_BALANCE_DUE_FC_CRED;
		updStruct[4].srcColNum	= JDT1_FC_CREDIT;
		updStruct[4].SetUpdateColSource(DBD_UpdStruct::ucs_SrcCol);
		updStruct[5].Clear();
		updStruct[5].colNum		= JDT1_BALANCE_DUE_SC_CRED;
		updStruct[5].srcColNum	= JDT1_SYS_CREDIT;
		updStruct[5].SetUpdateColSource(DBD_UpdStruct::ucs_SrcCol);
		DBD_SetDAGUpd (dagUpdate, updStruct, 6);

		condStruct[0].Clear();
		condStruct[0].tableIndex		= 0;
		condStruct[0].colNum			= JDT1_TRANS_ABS;
		dagRes->GetColStr(condStruct[0].condVal, CPE_RES_TRANS_ID, i);
		condStruct[0].operation			= DBD_EQ;
		condStruct[0].relationship		= DBD_AND;
		condStruct[1].Clear();
		condStruct[1].tableIndex		= 0;
		condStruct[1].colNum			= JDT1_LINE_ID;
		dagRes->GetColStr(condStruct[1].condVal, CPE_RES_TRANS_LINE_ID, i);
		condStruct[1].operation			= DBD_EQ;
		DBD_SetDAGCond (dagUpdate, condStruct, 2);

		sboErr = DBD_UpdateCols (dagUpdate);
		if (sboErr && sboErr != dbmNoDataFound)
		{
			return sboErr;
		}

		dagUpdate->ClearQueryParams();
	}

	for (i = 0; i < numOfRecon; i++)
	{
		// fix itr1 table / closing
		/* UPDATE T0 
		SET T0.[TransRowId] = 0, T0.[IsCredit] = T1.[DebCred], T0.[ShortName] = T1.[ShortName]
		  , T0.[Account] = T1.[Account] 
		FROM [dbo].[ITR1] T0 , [dbo].[JDT1] T1 
		WHERE T1.[TransId] = dagRes.CPE_RES_TRANS_ID
		AND T1.[Line_ID] = (0) 
		AND T0.[ReconNum] = dagRes.CPE_RES_RECON_NUM
		AND T0.[LineSeq] = dagRes.CPE_RES_LINE_SEQUENCE
		*/
		dagRes->GetColLong(&srcObjTyp, 4, i);
		if (srcObjTyp == CLOSE_BLNC_TYPE)
		{
			tables[0].tableCode = bizEnv.ObjectToTable (ITR, ao_Arr1);
			tables[1].tableCode = bizEnv.ObjectToTable (JDT, ao_Arr1);
			tables[1].doJoin	= false;
			DBD_SetTablesList (dagUpdate, tables, 2);	

			updStruct[0].Clear();
			updStruct[0].colNum		= ITR1_TRANS_LINE_ID;
			updStruct[0].updateVal	= 0L;
			updStruct[0].SetUpdateColSource(DBD_UpdStruct::ucs_Orig);
			updStruct[1].Clear();
			updStruct[1].colNum		= ITR1_IS_CREDIT;
			updStruct[1].srcColNum	= JDT1_DEBIT_CREDIT;
			updStruct[1].SetUpdateColSource(DBD_UpdStruct::ucs_UseRes);
			pResCol = updStruct[1].GetResObject().AddResCol ();	
			pResCol->SetTableIndex (1);
			pResCol->SetColNum (JDT1_DEBIT_CREDIT);

			updStruct[2].Clear();
			updStruct[2].colNum		= ITR1_SHORT_NAME;
			updStruct[2].srcColNum	= JDT1_SHORT_NAME;
			updStruct[2].SetUpdateColSource(DBD_UpdStruct::ucs_UseRes);
			pResCol = updStruct[2].GetResObject().AddResCol ();	
			pResCol->SetTableIndex (1);
			pResCol->SetColNum (JDT1_SHORT_NAME);

			updStruct[3].Clear();
			updStruct[3].colNum		= ITR1_ACCT_NUM;
			updStruct[3].srcColNum	= JDT1_ACCT_NUM;
			updStruct[3].SetUpdateColSource(DBD_UpdStruct::ucs_UseRes);
			pResCol = updStruct[3].GetResObject().AddResCol ();	
			pResCol->SetTableIndex (1);
			pResCol->SetColNum (JDT1_ACCT_NUM);
			DBD_SetDAGUpd (dagUpdate, updStruct, 4);

			condStruct[0].Clear();
			condStruct[0].tableIndex		= 1;
			condStruct[0].colNum			= JDT1_TRANS_ABS;
			dagRes->GetColStr(condStruct[0].condVal, CPE_RES_TRANS_ID, i);
			condStruct[0].operation			= DBD_EQ;
			condStruct[0].relationship		= DBD_AND;
			condStruct[1].Clear();
			condStruct[1].tableIndex		= 1;
			condStruct[1].colNum			= JDT1_LINE_ID;
			condStruct[1].condVal			= 0L;
			condStruct[1].operation			= DBD_EQ;
			condStruct[1].relationship		= DBD_AND;
			condStruct[2].Clear();
			condStruct[2].tableIndex		= 0;
			condStruct[2].colNum			= ITR1_RECON_NUM;
			dagRes->GetColStr(condStruct[2].condVal, CPE_RES_RECON_NUM, i);
			condStruct[2].operation			= DBD_EQ;
			condStruct[2].relationship		= DBD_AND;
			condStruct[3].Clear();
			condStruct[3].tableIndex		= 0;
			condStruct[3].colNum			= ITR1_LINE_SEQUENCE;
			dagRes->GetColStr(condStruct[3].condVal, CPE_RES_LINE_SEQUENCE, i);
			condStruct[3].operation			= DBD_EQ;
			DBD_SetDAGCond (dagUpdate, condStruct, 4);

			sboErr = DBD_UpdateCols (dagUpdate);
			if (sboErr && sboErr != dbmNoDataFound)
			{
				return sboErr;
			}

			dagUpdate->ClearQueryParams();
		}

	}

	for (i = 0; i < numOfRecon; i++)
	{
		// fix itr1 table / opening
		/* UPDATE T0 
		SET T0.[TransRowId] = 1, T0.[IsCredit] = T1.[DebCred], T0.[ShortName] = T1.[ShortName]
		  , T0.[Account] = T1.[Account] 
		FROM [dbo].[ITR1] T0 , [dbo].[JDT1] T1 
		WHERE T1.[TransId] = dagRes.CPE_RES_TRANS_ID
		AND T1.[Line_ID] = (1) 
		AND T0.[ReconNum] = dagRes.CPE_RES_RECON_NUM
		AND T0.[LineSeq] = dagRes.CPE_RES_LINE_SEQUENCE
		*/
		dagRes->GetColLong(&srcObjTyp, 4, i);
		if (srcObjTyp == OPEN_BLNC_TYPE)
		{
			tables[0].tableCode = bizEnv.ObjectToTable (ITR, ao_Arr1);
			tables[1].tableCode = bizEnv.ObjectToTable (JDT, ao_Arr1);
			tables[1].doJoin	= false;
			DBD_SetTablesList (dagUpdate, tables, 2);	

			updStruct[0].Clear();
			updStruct[0].colNum		= ITR1_TRANS_LINE_ID;
			updStruct[0].updateVal	= 1L;
			updStruct[0].SetUpdateColSource(DBD_UpdStruct::ucs_Orig);
			updStruct[1].Clear();
			updStruct[1].colNum		= ITR1_IS_CREDIT;
			updStruct[1].srcColNum	= JDT1_DEBIT_CREDIT;
			updStruct[1].SetUpdateColSource(DBD_UpdStruct::ucs_UseRes);
			pResCol = updStruct[1].GetResObject().AddResCol ();	
			pResCol->SetTableIndex (1);
			pResCol->SetColNum (JDT1_DEBIT_CREDIT);

			updStruct[2].Clear();
			updStruct[2].colNum		= ITR1_SHORT_NAME;
			updStruct[2].srcColNum	= JDT1_SHORT_NAME;
			updStruct[2].SetUpdateColSource(DBD_UpdStruct::ucs_UseRes);
			pResCol = updStruct[2].GetResObject().AddResCol ();	
			pResCol->SetTableIndex (1);
			pResCol->SetColNum (JDT1_SHORT_NAME);

			updStruct[3].Clear();
			updStruct[3].colNum		= ITR1_ACCT_NUM;
			updStruct[3].srcColNum	= JDT1_ACCT_NUM;
			updStruct[3].SetUpdateColSource(DBD_UpdStruct::ucs_UseRes);
			pResCol = updStruct[3].GetResObject().AddResCol ();	
			pResCol->SetTableIndex (1);
			pResCol->SetColNum (JDT1_ACCT_NUM);
			DBD_SetDAGUpd (dagUpdate, updStruct, 4);

			condStruct[0].Clear();
			condStruct[0].tableIndex		= 1;
			condStruct[0].colNum			= JDT1_TRANS_ABS;
			dagRes->GetColStr(condStruct[0].condVal, CPE_RES_TRANS_ID, i);
			condStruct[0].operation			= DBD_EQ;
			condStruct[0].relationship		= DBD_AND;
			condStruct[1].Clear();
			condStruct[1].tableIndex		= 1;
			condStruct[1].colNum			= JDT1_LINE_ID;
			condStruct[1].condVal			= 1L;
			condStruct[1].operation			= DBD_EQ;
			condStruct[1].relationship		= DBD_AND;
			condStruct[2].Clear();
			condStruct[2].tableIndex		= 0;
			condStruct[2].colNum			= ITR1_RECON_NUM;
			dagRes->GetColStr(condStruct[2].condVal, CPE_RES_RECON_NUM, i);
			condStruct[2].operation			= DBD_EQ;
			condStruct[2].relationship		= DBD_AND;
			condStruct[3].Clear();
			condStruct[3].tableIndex		= 0;
			condStruct[3].colNum			= ITR1_LINE_SEQUENCE;
			dagRes->GetColStr(condStruct[3].condVal, CPE_RES_LINE_SEQUENCE, i);
			condStruct[3].operation			= DBD_EQ;
			DBD_SetDAGCond (dagUpdate, condStruct, 4);

			sboErr = DBD_UpdateCols (dagUpdate);
			if (sboErr && sboErr != dbmNoDataFound)
			{
				return sboErr;
			}

			dagUpdate->ClearQueryParams();
		}

	}

	for (i = 0; i < numOfRecon; i++)
	{
		// fix oitr
		/* UPDATE T0 
		SET T0.[IsCard] = N'C' 
		FROM [dbo].[OITR] T0 , [dbo].[ITR1] T1 , [dbo].[JDT1] T2 
		WHERE T0.[ReconNum] = dagRes.CPE_RES_RECON_NUM 
		AND T0.[ReconNum] = T1.[ReconNum] 
		AND T1.[LineSeq] = (0) 
		AND T1.[TransId] = T2.[TransId] 
		AND T1.[TransRowId] = T2.[Line_ID] 
		AND T2.[ShortName] <> T2.[Account] 
		*/
		tables[0].tableCode = bizEnv.ObjectToTable (ITR, ao_Main);
		tables[1].tableCode = bizEnv.ObjectToTable (ITR, ao_Arr1);
		tables[1].doJoin	= false;
		tables[2].tableCode = bizEnv.ObjectToTable (JDT, ao_Arr1);
		tables[2].doJoin	= false;
		DBD_SetTablesList (dagUpdate, tables, 3);	

		updStruct[0].Clear();
		updStruct[0].colNum		= OITR_IS_CARD;
		updStruct[0].updateVal	= VAL_CARD;
		updStruct[0].SetUpdateColSource(DBD_UpdStruct::ucs_Orig);
		DBD_SetDAGUpd (dagUpdate, updStruct, 1);

		condStruct[0].Clear();
		condStruct[0].tableIndex		= 0;
		condStruct[0].colNum			= OITR_RECON_NUM;
		dagRes->GetColStr(condStruct[0].condVal, CPE_RES_RECON_NUM, i);
		condStruct[0].operation			= DBD_EQ;
		condStruct[0].relationship		= DBD_AND;
		condStruct[1].Clear();
		condStruct[1].tableIndex		= 0;
		condStruct[1].colNum			= OITR_RECON_NUM;
		condStruct[1].compareCols		= true;
		condStruct[1].compTableIndex	= 1;
		condStruct[1].compColNum		= ITR1_RECON_NUM;
		condStruct[1].operation			= DBD_EQ;
		condStruct[1].relationship		= DBD_AND;
		condStruct[2].Clear();
		condStruct[2].tableIndex		= 1;
		condStruct[2].colNum			= ITR1_LINE_SEQUENCE;
		condStruct[2].condVal			= 0L;
		condStruct[2].operation			= DBD_EQ;
		condStruct[2].relationship		= DBD_AND;
		condStruct[3].Clear();
		condStruct[3].tableIndex		= 1;
		condStruct[3].colNum			= ITR1_TRANS_ID;
		condStruct[3].compareCols		= true;
		condStruct[3].compTableIndex	= 2;
		condStruct[3].compColNum		= JDT1_TRANS_ABS;
		condStruct[3].operation			= DBD_EQ;
		condStruct[3].relationship		= DBD_AND;
		condStruct[4].Clear();
		condStruct[4].tableIndex		= 1;
		condStruct[4].colNum			= ITR1_TRANS_LINE_ID;
		condStruct[4].compareCols		= true;
		condStruct[4].compTableIndex	= 2;
		condStruct[4].compColNum		= JDT1_LINE_ID;
		condStruct[4].operation			= DBD_EQ;
		condStruct[4].relationship		= DBD_AND;
		condStruct[5].Clear();
		condStruct[5].tableIndex		= 2;
		condStruct[5].colNum			= JDT1_SHORT_NAME;
		condStruct[5].compareCols		= true;
		condStruct[5].compTableIndex	= 2;
		condStruct[5].compColNum		= JDT1_ACCT_NUM;
		condStruct[5].operation			= DBD_NE;
		DBD_SetDAGCond (dagUpdate, condStruct, 6);

		sboErr = DBD_UpdateCols (dagUpdate);
		if (sboErr && sboErr != dbmNoDataFound)
		{
			return sboErr;
		}

		dagUpdate->ClearQueryParams();
	}

	for (i = 0; i < numOfRecon; i++)
	{
		// fix currency in head
		/* UPDATE T0 
		SET T0.[ReconCurr] = T1.[FrgnCurr], T0.[Total] = T1.[ReconSumFC] 
		FROM [dbo].[OITR] T0 , [dbo].[ITR1] T1 
		WHERE T0.[ReconNum] = dagRes.CPE_RES_RECON_NUM 
		AND T0.[ReconNum] = T1.[ReconNum] 
		AND T1.[LineSeq] = (0) 
		AND T1.[FrgnCurr] IS NOT NULL 
		AND T1.[FrgnCurr] <> (N'')
		*/
		tables[0].tableCode = bizEnv.ObjectToTable (ITR, ao_Main);
		tables[1].tableCode = bizEnv.ObjectToTable (ITR, ao_Arr1);
		tables[1].doJoin	= false;
		DBD_SetTablesList (dagUpdate, tables, 2);	

		updStruct[0].Clear();
		updStruct[0].colNum		= OITR_RECON_CURRENCY;
		updStruct[0].srcColNum	= ITR1_FRGN_CURRENCY;
		updStruct[0].SetUpdateColSource(DBD_UpdStruct::ucs_UseRes);
		pResCol = updStruct[0].GetResObject().AddResCol ();	
		pResCol->SetTableIndex (1);
		pResCol->SetColNum (ITR1_FRGN_CURRENCY);

		updStruct[1].Clear();
		updStruct[1].colNum		= OITR_TOTAL;
		updStruct[1].srcColNum	= ITR1_RECON_SUM_FC;
		updStruct[1].SetUpdateColSource(DBD_UpdStruct::ucs_UseRes);
		pResCol = updStruct[1].GetResObject().AddResCol ();	
		pResCol->SetTableIndex (1);
		pResCol->SetColNum (ITR1_RECON_SUM_FC);
		DBD_SetDAGUpd (dagUpdate, updStruct, 2);

		condStruct[0].Clear();
		condStruct[0].tableIndex		= 0;
		condStruct[0].colNum			= OITR_RECON_NUM;
		dagRes->GetColStr(condStruct[0].condVal, CPE_RES_RECON_NUM, i);
		condStruct[0].operation			= DBD_EQ;
		condStruct[0].relationship		= DBD_AND;
		condStruct[1].Clear();
		condStruct[1].tableIndex		= 0;
		condStruct[1].colNum			= OITR_RECON_NUM;
		condStruct[1].compareCols		= true;
		condStruct[1].compTableIndex	= 1;
		condStruct[1].compColNum		= ITR1_RECON_NUM;
		condStruct[1].operation			= DBD_EQ;
		condStruct[1].relationship		= DBD_AND;
		condStruct[2].Clear();
		condStruct[2].tableIndex		= 1;
		condStruct[2].colNum			= ITR1_LINE_SEQUENCE;
		condStruct[2].condVal			= 0L;
		condStruct[2].operation			= DBD_EQ;
		condStruct[2].relationship		= DBD_AND;
		condStruct[3].Clear();
		condStruct[3].tableIndex		= 1;
		condStruct[3].colNum			= ITR1_FRGN_CURRENCY;
		condStruct[3].operation			= DBD_NOT_NULL;
		condStruct[3].relationship		= DBD_AND;
		condStruct[4].Clear();
		condStruct[4].tableIndex		= 1;
		condStruct[4].colNum			= ITR1_FRGN_CURRENCY;
		condStruct[4].condVal			= EMPTY_STR;
		condStruct[4].operation			= DBD_NE;
		DBD_SetDAGCond (dagUpdate, condStruct, 5);

		sboErr = DBD_UpdateCols (dagUpdate);
		if (sboErr && sboErr != dbmNoDataFound)
		{
			return sboErr;
		}

		dagUpdate->ClearQueryParams();
	}

	for (i = 0; i < numOfRecon; i++)
	{
		// fix currency in rows
		/* UPDATE T0 
		SET T0.[SumMthCurr] = T0.[ReconSumFC] 
		FROM [dbo].[ITR1] T0 
		WHERE T0.[ReconNum] = dagRes.CPE_RES_RECON_NUM 
		AND T0.[FrgnCurr] IS NOT NULL 
		AND T0.[FrgnCurr] <> (N'') 
		*/
		tables[0].tableCode = bizEnv.ObjectToTable (ITR, ao_Arr1);
		DBD_SetTablesList (dagUpdate, tables, 1);	

		updStruct[0].Clear();
		updStruct[0].colNum		= ITR1_SUM_IN_MATCH_CURR;
		updStruct[0].srcColNum	= ITR1_RECON_SUM_FC;
		updStruct[0].SetUpdateColSource(DBD_UpdStruct::ucs_SrcCol);
		DBD_SetDAGUpd (dagUpdate, updStruct, 1);

		condStruct[0].Clear();
		condStruct[0].tableIndex		= 0;
		condStruct[0].colNum			= ITR1_RECON_NUM;
		dagRes->GetColStr(condStruct[0].condVal, CPE_RES_RECON_NUM, i);
		condStruct[0].operation			= DBD_EQ;
		condStruct[0].relationship		= DBD_AND;
		condStruct[1].Clear();
		condStruct[1].tableIndex		= 0;
		condStruct[1].colNum			= ITR1_FRGN_CURRENCY;
		condStruct[1].operation			= DBD_NOT_NULL;
		condStruct[1].relationship		= DBD_AND;
		condStruct[2].Clear();
		condStruct[2].tableIndex		= 0;
		condStruct[2].colNum			= ITR1_FRGN_CURRENCY;
		condStruct[2].condVal			= EMPTY_STR;
		condStruct[2].operation			= DBD_NE;
		DBD_SetDAGCond (dagUpdate, condStruct, 3);

		sboErr = DBD_UpdateCols (dagUpdate);
		if (sboErr && sboErr != dbmNoDataFound)
		{
			return sboErr;
		}

		dagUpdate->ClearQueryParams();
	}

	for (i = 0; i < numOfRecon; i++)
	{
		// close proper JE lines
		/* UPDATE T0 
		SET T0.[BalDueDeb] = 0, T0.[BalFcDeb] = 0, T0.[BalScDeb] = 0
		  , T0.[BalDueCred] = 0, T0.[BalFcCred] = 0, T0.[BalScCred] = 0 
		FROM [dbo].[JDT1] T0 , [dbo].[ITR1] T1 
		WHERE T1.[ReconNum] = dagRes.CPE_RES_RECON_NUM 
		AND T0.[TransId] = T1.[TransId] 
		AND T0.[Line_ID] = T1.[TransRowId] 
		*/
		tables[0].tableCode = bizEnv.ObjectToTable (JDT, ao_Arr1);
		tables[1].tableCode = bizEnv.ObjectToTable (ITR, ao_Arr1);
		tables[1].doJoin	= false;
		DBD_SetTablesList (dagUpdate, tables, 2);	

		updStruct[0].Clear();
		updStruct[0].colNum		= JDT1_BALANCE_DUE_DEBIT;
		updStruct[0].updateVal	= 0L;
		updStruct[1].Clear();
		updStruct[1].colNum		= JDT1_BALANCE_DUE_FC_DEB;
		updStruct[1].updateVal	= 0L;
		updStruct[2].Clear();
		updStruct[2].colNum		= JDT1_BALANCE_DUE_SC_DEB;
		updStruct[2].updateVal	= 0L;
		updStruct[3].Clear();
		updStruct[3].colNum		= JDT1_BALANCE_DUE_CREDIT;
		updStruct[3].updateVal	= 0L;
		updStruct[4].Clear();
		updStruct[4].colNum		= JDT1_BALANCE_DUE_FC_CRED;
		updStruct[4].updateVal	= 0L;
		updStruct[5].Clear();
		updStruct[5].colNum		= JDT1_BALANCE_DUE_SC_CRED;
		updStruct[5].updateVal	= 0L;
		DBD_SetDAGUpd (dagUpdate, updStruct, 6);

		condStruct[0].Clear();
		condStruct[0].tableIndex		= 1;
		condStruct[0].colNum			= ITR1_RECON_NUM;
		dagRes->GetColStr(condStruct[0].condVal, CPE_RES_RECON_NUM, i);
		condStruct[0].operation			= DBD_EQ;
		condStruct[0].relationship		= DBD_AND;
		condStruct[1].Clear();
		condStruct[1].tableIndex		= 0;
		condStruct[1].colNum			= JDT1_TRANS_ABS;
		condStruct[1].compareCols		= true;
		condStruct[1].compTableIndex	= 1;
		condStruct[1].compColNum		= ITR1_TRANS_ID;
		condStruct[1].operation			= DBD_EQ;
		condStruct[1].relationship		= DBD_AND;
		condStruct[2].Clear();
		condStruct[2].tableIndex		= 0;
		condStruct[2].colNum			= JDT1_LINE_ID;
		condStruct[2].compareCols		= true;
		condStruct[2].compTableIndex	= 1;
		condStruct[2].compColNum		= ITR1_TRANS_LINE_ID;
		condStruct[2].operation			= DBD_EQ;
		DBD_SetDAGCond (dagUpdate, condStruct, 3);

		sboErr = DBD_UpdateCols (dagUpdate);
		if (sboErr && sboErr != dbmNoDataFound)
		{
			return sboErr;
		}

		dagUpdate->ClearQueryParams();
	}

	return noErr;
}
/**
 * Check the Cost Accounting assignment when posting
 *
 * 
 * @param bizObject 
 * @return SBOErr 
*/
SBOErr	CTransactionJournalObject::CostAccountingAssignmentCheck (CBusinessObject* bizObject)
{
	SBOErr		sboErr = noErr;
	long		numOfRecs;
	TCHAR		accountFormat[256];
	PDAG		dagJDT1, dagACT;
	SBOString	accountCode, costAccountRelevant, costAccountingField;
	CBizEnv&	bizEnv = bizObject->GetEnv();
	long		costAccountingRelevantFields[] = {OACT_PROJECT_RELEVANT, OACT_DIM1_RELEVANT, 
		OACT_DIM2_RELEVANT, OACT_DIM3_RELEVANT, OACT_DIM4_RELEVANT, OACT_DIM5_RELEVANT};
	long		costAccountingFields[] = {JDT1_PROJECT, JDT1_OCR_CODE, 
		JDT1_OCR_CODE2, JDT1_OCR_CODE3, JDT1_OCR_CODE4, JDT1_OCR_CODE5};

	dagACT = bizObject->GetDAG(ACT, ao_Main);
	dagJDT1 = bizObject->GetDAG(JDT, ao_Arr1);
	numOfRecs = dagJDT1->GetRealSize(dbmDataBuffer);

	for (long i = 0; i < 1 + DIMENSION_MAX; i++)
	{
		if (bizEnv.IsCostAccountingBlocked(i))
		{
			for (long rec = 0; rec < numOfRecs; rec++)
			{
				dagJDT1->GetColStr(accountCode, JDT1_ACCT_NUM, rec);
				sboErr = bizEnv.GetByOneKey(dagACT, OACT_KEYNUM_PRIMARY, accountCode, true);
				if (sboErr)
				{
					if (sboErr == dbmNoDataFound)
					{
						return ooInvalidObject;
					}
				
					else
					{
						return sboErr;
					}
				}
				dagACT->GetColStr(costAccountRelevant, costAccountingRelevantFields[i], 0);
				dagJDT1->GetColStr(costAccountingField, costAccountingFields[i], rec);
				costAccountingField.Trim();
				if (!costAccountRelevant.Compare(VAL_YES) && (costAccountingField.IsEmpty() || costAccountingField.IsNull()))
				{
					sboErr = bizEnv.GetAccountSegmentsByCode (accountCode, accountFormat, true);
					IF_ERROR_RETURN(sboErr);
					if (i)
					{
						CMessagesManager::GetHandle()->Message(_54_APP_MSG_FIN_NEED_DISTRIBUTION_RULE,
							EMPTY_STR, bizObject, accountFormat, i);
					}
					else
					{
						CMessagesManager::GetHandle()->Message(_54_APP_MSG_FIN_NEED_PROJECT_ASSIGNMENT,
							EMPTY_STR, bizObject, accountFormat);
					}
					return ooInvalidObject;
				}
			}
		}
	}
	return sboErr;
}

/**
* 
* To insert the account needs to be reconciled
* @param [in] bool isInCancellingAcctRecon, SBOString& acct
* @param [out] 
* @param [in,out] 
* @return  
* @see 
*/
void	CTransactionJournalObject::SetReconAcct (bool isInCancellingAcctRecon, SBOString& acct) 
{
	m_isInCancellingAcctRecon = isInCancellingAcctRecon;

	if (m_reconAcctSet.find (acct) == m_reconAcctSet.end ())
	{
		m_reconAcctSet.insert (acct);
	}

	return;
}

/**
 * 
 * To log the change of BP accounting balance
 * @param [in] BPBalanceChangeLogDataArr &bpBalanceLogDataArray, CBizEnv &bizEnv
 * @param [out] 
 * @param [in,out] 
 * @return  
 * @see 
 */
void CTransactionJournalObject::LogBPAccountBalance (BPBalanceChangeLogDataArr &bpBalanceLogDataArray,  SBOString & keyNum)
{
    long   size = bpBalanceLogDataArray.size();
    PDAG   dagCRD = GetDAG(CRD);
    SBOErr ooErr = noErr;
    MONEY  tempMoney;

    for (long i = 0; i < size; i ++)
    {
        CBPBalanceChangeLogData & bpBalanceChangeLogData = bpBalanceLogDataArray[i];
        ooErr = GetEnv().GetByOneKey (dagCRD, GO_PRIMARY_KEY_NUM, bpBalanceChangeLogData.GetCode(), true);
        if(ooErr)
        {
            return;
        }
        dagCRD->GetColMoney(&tempMoney, OCRD_CURRENT_BALANCE);
        bpBalanceChangeLogData.SetNewAcctBalanceLC(tempMoney);

        dagCRD->GetColMoney(&tempMoney, OCRD_F_BALANCE);
        bpBalanceChangeLogData.SetNewAcctBalanceFC(tempMoney);

        bpBalanceChangeLogData.SetKeyNum(keyNum);
 
        bpBalanceChangeLogData.Log();
    }
}
/*******************************************************************
Function name	: IsManualJE
Description	    : Returns true if JDT object is manual Journal Entry
Return type		: bool
********************************************************************/
bool CTransactionJournalObject::IsManualJE (PDAG dagJDT)
{
		_TRACER("IsManualJE");
	bool result = false;
	SBOString transType;
	
	dagJDT->GetColStr (transType, OJDT_TRANS_TYPE, 0);
	transType.Trim ();

	return ((transType.CompareNoCase (SBOString (JDT)) == 0) ||
			(transType.CompareNoCase (SBOString (NONE_CHOICE)) == 0))
			? true : false;
}

/**
*
*/
bool CTransactionJournalObject::IsCardLine (const long rec)
{
	PDAG	dagJDT1;

	dagJDT1 = GetArrayDAG (ao_Arr1);
	if (!DAG_IsValid (dagJDT1))
	{
		throw dataTableInvalidDAG;
	}

	long	recCount;

	recCount = dagJDT1->GetRealSize (dbmDataBuffer);
	if (rec < 0L || rec >= recCount)
	{
		throw dataTableInvalidRowIndex;
	}

	SBOErr		ooErr;
	SBOString	accountNumber, shortName;

	ooErr = dagJDT1->GetColStr (accountNumber, JDT1_ACCT_NUM, rec, false, true);
	IF_ERROR_THROW (ooErr);
	ooErr = dagJDT1->GetColStr (shortName, JDT1_SHORT_NAME, rec, false, true);
	IF_ERROR_THROW (ooErr);

	accountNumber.Trim ();
	shortName.Trim ();

	return (accountNumber != shortName && !shortName.IsEmpty ());
}

/**
*
*/
bool CTransactionJournalObject::ContainsCardLine ()
{
	PDAG	dagJDT1;

	dagJDT1 = GetArrayDAG (ao_Arr1);
	if (!DAG_IsValid (dagJDT1))
	{
		throw dataTableInvalidDAG;
	}

	long	recCount;

	recCount = dagJDT1->GetRealSize (dbmDataBuffer);
	for (long rec = 0L; rec < recCount; ++rec)
	{
		if (IsCardLine (rec))
		{
			return true;
		}
	}

	return false;
}

/*******************************************************************
Function name	: InitDataReport340
Description	    : Initializes values for 340 report
Return type		: SBOErr
Virtual flag	: VF_Model340_EnabledInOADM
********************************************************************/
SBOErr CTransactionJournalObject::InitDataReport340 (PDAG dagJDT)
{
		_TRACER("InitDataReport340");
	SBOErr sboErr = ooNoErr;
	CBizEnv	&bizEnv = GetEnv ();

	// OBServer
	if (GetDataSource () == *VAL_OBSERVER_SOURCE)
	{
		// nullify ResidenNum due to CompleteReport340
		dagJDT->NullifyCol (OJDT_RESIDENCE_NUM, 0);
	}

	return sboErr;
}

/*******************************************************************
Function name	: CompleteReport340
Description	    : Completes values for 340 report
Return type		: SBOErr
Virtual flag	: VF_Model340_EnabledInOADM
********************************************************************/
SBOErr CTransactionJournalObject::CompleteReport340 (PDAG dagJDT, PDAG dagJDT1)
{
		_TRACER("CompleteReport340");
	SBOErr sboErr = ooNoErr;
	CBizEnv	&bizEnv = GetEnv ();
	PDAG dagCRD = GetDAG (CRD);
	SBOString residenNum, account, shortName;
	long numOfRecs;
	bool atLeasOneBPFound;

	// OBServer
	if (GetDataSource () == *VAL_OBSERVER_SOURCE)
	{
		// ResidenNum was nullified in InitDataReport340 before AutoComplete call.
		// If nothing else reset ResidenNum (e.g. script using DI API),
		// then we have to set ResidenNum according to the first Business Partner used in JDT1 lines.
		dagJDT->GetColStr (residenNum, OJDT_RESIDENCE_NUM, 0);
		if (residenNum.GetLength () <= 0)
		{
			atLeasOneBPFound = false;
			// complete only in manual Journal Entries
			if (IsManualJE (dagJDT) == true)
			{
				numOfRecs = dagJDT1->GetRealSize (dbmDataBuffer);
				if (numOfRecs > 0)
				{
					// iterate JDT1 lines
					for (long rec = 0; rec < numOfRecs; rec++)
					{
						dagJDT1->GetColStr (account, JDT1_ACCT_NUM, rec);
						dagJDT1->GetColStr (shortName, JDT1_SHORT_NAME, rec);
						// search for the first Business Partner
						if (account.CompareNoCase (shortName) != 0)
						{
							if (bizEnv.GetByOneKey (dagCRD, OCRD_KEYNUM_PRIMARY, shortName, true) == ooNoErr)
							{
								// copy ResidenNum from Business Partner
								dagCRD->GetColStr (residenNum, OCRD_RESIDENCE_NUM, 0);
								dagJDT->SetColStr (residenNum, OJDT_RESIDENCE_NUM, 0);
								dagJDT->SetColStr (residenNum, OJDT_RESIDENCE_NUM, 0, true, true); // backup buffer
								atLeasOneBPFound = true;
								break;
							}
						}
					}
				}
			}
			if (atLeasOneBPFound == false)
			{
				// set ResidenNum with default value
				dagJDT->GetDefaultValue (OJDT_RESIDENCE_NUM, residenNum);
				dagJDT->SetColStr (residenNum, OJDT_RESIDENCE_NUM, 0);
				dagJDT->SetColStr (residenNum, OJDT_RESIDENCE_NUM, 0, true, true); // backup buffer
			}
		}
	}

	return sboErr;
}

/*******************************************************************
 Function name	: ValidateReport340
 Description	: Validates values for 340 report
 Return type	: SBOErr
 Virtual flag	: VF_Model340_EnabledInOADM
********************************************************************/
SBOErr CTransactionJournalObject::ValidateReport340 ()
{
        _TRACER("ValidateReport340");
	SBOErr sboErr = ooNoErr;
	CBizEnv	&bizEnv = GetEnv ();
	PDAG dagJDT = GetDAG ();
	SBOString residenNumOrig, residenNumNew, operatCodeOrig, operatCodeNew;

	if (GetCurrentBusinessFlow() == bf_Create)
	{
		return sboErr;
	}

	// Residence Number can be changed in manual Journal Entries only
	dagJDT->GetColStr (residenNumOrig, OJDT_RESIDENCE_NUM, 0, true, true);
	dagJDT->GetColStr (residenNumNew, OJDT_RESIDENCE_NUM, 0);
	if (residenNumOrig.GetLength () > 0 &&
		residenNumOrig.Compare (residenNumNew) != 0 &&
		IsManualJE (dagJDT) == false)
	{
		SetErrorField (OJDT_RESIDENCE_NUM);
		Message (GO_OBJ_ERROR_MSGS(JDT), JDT_340_REPORT_RESIDENNUM_CHNG_ERR, NULL, OO_ERROR);
		return ooInvalidObject;
	}

	// Operation Code can be changed in manual Journal Entries only
	dagJDT->GetColStr (operatCodeOrig, OJDT_OPERATION_CODE, 0, true, true);
	dagJDT->GetColStr (operatCodeNew, OJDT_OPERATION_CODE, 0);
	if (operatCodeOrig.GetLength () > 0 &&
		operatCodeOrig.Compare (operatCodeNew) != 0 &&
		IsManualJE (dagJDT) == false)
	{
		SetErrorField (OJDT_OPERATION_CODE);
		Message (GO_OBJ_ERROR_MSGS(JDT), JDT_340_REPORT_OPERATCODE_CHNG_ERR, NULL, OO_ERROR);
		return ooInvalidObject;
	}

	return sboErr;
}

void CTransactionJournalObject::OJDTGetRate (CBusinessObject* bizObject, long curSource, MONEY *rate)
{
	Currency	currency;
	Date		postingDate;
	long		transType;
	PDAG dagJDT = bizObject->GetDAG();

	dagJDT->GetColLong(&transType, OJDT_TRANS_TYPE);
	if (transType == TRT || transType == RCR)
	{
		*rate = 1L;
	}
	else
	{
		switch (curSource)
		{
		case JDT_SYSTEM_CURRENCY:
			_STR_strcpy (currency, bizObject->GetEnv ().GetSystemCurrency ());
			break;
		case JDT_CARD_CURRENCY:
			_STR_strcpy (currency, bizObject->GetEnv ().GetMainCurrency ());
			break;

		}
		dagJDT->GetColStr (postingDate, OJDT_REF_DATE);
		TZGetAndWaitUntilRate (currency, postingDate, rate, TRUE, bizObject->GetEnv ());		
	}
}

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

// Check if credit and debit amounts are not balanced due to rounding
SBOErr  CTransactionJournalObject::HandleFCExchangeRounding(PDAG dagJDT1, StdMap<SBOString, FCRoundingStruct, False, False> &currencyMap)
{
	CAllCurrencySums totalDebitMinusCredit, debit, credit;
	MONEY amount;

	long  size, idx, lastNonZeroFCLine(-1);
	SBOString currency, vatLine;
	FCRoundingStruct  roundingStruct;
	

	size = dagJDT1->GetRecordCount();
	//Check whether the LC is balanced
	for (idx = 0; idx < size; idx++)
	{
		debit.FromDAG (dagJDT1, idx, JDT1_DEBIT, JDT1_FC_DEBIT, JDT1_SYS_DEBIT);
		credit.FromDAG (dagJDT1, idx, JDT1_CREDIT, JDT1_FC_CREDIT, JDT1_SYS_CREDIT);
		dagJDT1->GetColStr(currency, JDT1_FC_CURRENCY, idx);
		dagJDT1->GetColStr (vatLine, JDT1_VAT_LINE, idx);
		
		vatLine.Trim();
		currency.Trim();

		if (!currency.IsEmpty() && (debit.GetFcSum() != 0 || credit.GetFcSum() != 0))
		{
			currencyMap.Lookup(currency, roundingStruct);
			
			if (vatLine != VAL_YES)
			{
				roundingStruct.lastNonZeroFCLine = idx;
			}
		
			roundingStruct.totalDebitMinusCredit += (debit - credit);
			currencyMap[currency] = roundingStruct;
		}

	    totalDebitMinusCredit += (debit - credit);
	}

	//if LC is balanced, No rounding issue will be considered
	if (totalDebitMinusCredit.GetLcSum() == 0 && totalDebitMinusCredit.GetScSum() == 0)
	{ 
		return ooNoErr;
	}
    //
	//For each type of currency, we calculate total FC Debit and 
	//LC Credit. For one currency, if the FC is balanced, we calculate
	//the balance of the LC and if there is rounding, the rounding amount will be 
	//put into the last FC JE line. 
	//
    StdMap<SBOString, FCRoundingStruct, False, False>::const_iterator itr = currencyMap.begin();
	for(; itr != currencyMap.end(); ++itr)
	{
		 roundingStruct = itr->second;
		 if (roundingStruct.needRounding && roundingStruct.totalDebitMinusCredit.GetFcSum() == 0
			 && (roundingStruct.totalDebitMinusCredit.GetLcSum() != 0 || roundingStruct.totalDebitMinusCredit.GetScSum() != 0)
			 && roundingStruct.lastNonZeroFCLine != -1)
		 {
			 dagJDT1->GetColMoney (&amount, JDT1_FC_DEBIT, roundingStruct.lastNonZeroFCLine);
			 if (amount != 0)
			 { // Update Debit side
				 dagJDT1->GetColMoney (&amount, JDT1_DEBIT, roundingStruct.lastNonZeroFCLine);
				 amount -= roundingStruct.totalDebitMinusCredit.GetLcSum();
				 dagJDT1->SetColMoney (&amount, JDT1_DEBIT, roundingStruct.lastNonZeroFCLine);

				 dagJDT1->GetColMoney (&amount, JDT1_SYS_DEBIT, roundingStruct.lastNonZeroFCLine);
				 amount -= roundingStruct.totalDebitMinusCredit.GetScSum();
				 dagJDT1->SetColMoney (&amount, JDT1_SYS_DEBIT, roundingStruct.lastNonZeroFCLine);
			 }
			 else
			 { // Update Credit side
				 dagJDT1->GetColMoney (&amount, JDT1_CREDIT, roundingStruct.lastNonZeroFCLine);
				 amount += roundingStruct.totalDebitMinusCredit.GetLcSum();
				 dagJDT1->SetColMoney (&amount, JDT1_CREDIT, roundingStruct.lastNonZeroFCLine);

				 dagJDT1->GetColMoney (&amount, JDT1_SYS_CREDIT, roundingStruct.lastNonZeroFCLine);
				 amount += roundingStruct.totalDebitMinusCredit.GetScSum();
				 dagJDT1->SetColMoney (&amount, JDT1_SYS_CREDIT, roundingStruct.lastNonZeroFCLine);
			 }
		 }
	}
	 
	return ooNoErr;
}

// VF_FederalTaxIdOnJERow
SBOErr CTransactionJournalObject::UpgradeFederalTaxIdOnJERow ()
{
	CBizEnv	&bizEnv = GetEnv ();

	// Upgrade manual JE:
	{
		/*
			-- Get Federal Tax ID from relevant BP's:

			select distinct OCRD.CardCode, OCRD.CardType, OCRD.LicTradNum, CRD1.LicTradNum 
			from JDT1 inner join OCRD on JDT1.ShortName = OCRD.CardCode
			left join CRD1 on OCRD.CardCode = CRD1.CardCode and OCRD.ShipToDef = CRD1.Address
			where Account != ShortName
			and (OCRD.LicTradNum is not null or CRD1.LicTradNum is not null)
			and TransType = JDT
		*/
		DBQRetrieveStatement	stmt (bizEnv);
		APDAG					dagRes;
		long					countRes;
		SBOString				cardCode, cardType, crdTaxID;
		try
		{
			DBQTable tJDT1 = stmt.From (bizEnv.ObjectToTable (JDT, ao_Arr1));

			DBQTable tOCRD = stmt.Join (bizEnv.ObjectToTable (CRD, ao_Main), tJDT1, DBQ_JT_INNER_JOIN);
			stmt.On (tOCRD).Col (tJDT1, JDT1_SHORT_NAME).EQ ().Col (tOCRD, OCRD_CARD_CODE);

			DBQTable tCRD1 = stmt.Join (bizEnv.ObjectToTable (CRD, ao_Arr1), tOCRD, DBQ_JT_LEFT_OUTER_JOIN);
			stmt.On (tCRD1).Col (tOCRD, OCRD_CARD_CODE).EQ ().Col (tCRD1, CRD1_CARD_CODE)
				.And ().Col (tOCRD, OCRD_SHIP_TO_DEFAULT).EQ ().Col (tCRD1, CRD1_ADDRESS_NAME);

			stmt.Select ().Col (tOCRD, OCRD_CARD_CODE);
			stmt.Select ().Col (tOCRD, OCRD_CARD_TYPE);
			stmt.Select ().Col (tOCRD, OCRD_TAX_ID_NUMBER).As (JE_TAX_ID_ON_HEADER_ALIAS);
			stmt.Select ().Col (tCRD1, CRD1_TAX_ID_NUMBER).As (JE_TAX_ID_ON_LINE_ALIAS);
			stmt.Distinct ();

			stmt.Where ().Col (tJDT1, JDT1_ACCT_NUM).NE ().Col (tJDT1, JDT1_SHORT_NAME)	// BP line
				.And ().Col (tJDT1, JDT1_TRANS_TYPE).EQ ().Val (JDT)					// manual JE
				.And ().OpenBracket ().Col (tOCRD, OCRD_TAX_ID_NUMBER).IsNotNull ()
				.Or ().Col (tCRD1, CRD1_TAX_ID_NUMBER).IsNotNull ().CloseBracket ();

			countRes = stmt.Execute (dagRes);
		}
		catch (DBMException &e)
		{
			return e.GetCode ();
		}
		for (long ii = 0; ii < countRes; ii++)
		{
			crdTaxID = EMPTY_STR;

			dagRes->GetColStr (cardCode, dagRes->GetColumnByAlias (OCRD_CARD_CODE_ALIAS), ii);
			dagRes->GetColStr (cardType, dagRes->GetColumnByAlias (OCRD_CARD_TYPE_ALIAS), ii);
			cardCode.Trim ();
			cardType.Trim ();
			if (cardType == VAL_CUSTOMER && !GetEnv ().IsLatinAmericaTaxSystem ())
			{
				dagRes->GetColStr (crdTaxID, dagRes->GetColumnByAlias (JE_TAX_ID_ON_LINE_ALIAS), ii); // get from address
			}
			if (crdTaxID.IsSpacesStr ())
			{
				dagRes->GetColStr (crdTaxID, dagRes->GetColumnByAlias (JE_TAX_ID_ON_HEADER_ALIAS), ii); // get from header
			}
			crdTaxID.Trim ();

			/*
				-- For each BP update relevant lines in JE:

				update JDT1 set LicTradNum = crdTaxID
				where Account != ShortName
				and ShortName = cardCode
				and TransType = JDT
			*/
			DBQUpdateStatement	ustmt (bizEnv);
			try
			{
				DBQTable tJDT1 = ustmt.Update (bizEnv.ObjectToTable (JDT, ao_Arr1));
				ustmt.Set (JDT1_TAX_ID_NUMBER).Val (crdTaxID);
				ustmt.Where ().Col (tJDT1, JDT1_ACCT_NUM).NE ().Col (tJDT1, JDT1_SHORT_NAME)
					   .And ().Col (tJDT1, JDT1_SHORT_NAME).EQ ().Val (cardCode)
					   .And ().Col (tJDT1, JDT1_TRANS_TYPE).EQ ().Val (JDT);

				ustmt.Execute ();
			}
			catch (DBMException &e)
			{
				return e.GetCode ();
			}
		}
	}

	// Upgrade JE behing mktg documents:
	{
		long	objArray[] = {INV, RIN,	// A/R Invoice / Credit Memo
							  PCH, RPC,	// A/P Invoice / Credit Memo
							  CSI, CSV,	// A/R Corr. Invoice / Reversal
							  CPI, CPV,	// A/P Corr. Invoice / Reversal
							  DPI, DPO,	// DPM's
							  NOB};		// must end with NOB

		for (long objNum = 0; objArray[objNum] != NOB; objNum++)
		{
			/*
				update JDT1 set LicTradNum = OINV.LicTradNum
				from OINV where OINV.TransId = JDT1.TransId 
				and JDT1.Account != JDT1.ShortName
				and OINV.CardCode = JDT1.ShortName
			*/
			DBQUpdateStatement	ustmt (bizEnv);
			try
			{
				DBQTable tJDT1 = ustmt.Update (bizEnv.ObjectToTable (JDT, ao_Arr1));
				DBQTable tOINV = ustmt.Update (bizEnv.ObjectToTable (objArray[objNum], ao_Main));

				ustmt.Set (JDT1_TAX_ID_NUMBER).Col (tOINV, OINV_TAX_ID_NUMBER);
				ustmt.Where ().Col (tOINV, OINV_TRANS_NUM).EQ ().Col (tJDT1, JDT1_TRANS_ABS)
					   .And ().Col (tJDT1, JDT1_ACCT_NUM).NE ().Col (tJDT1, JDT1_SHORT_NAME)
					   .And ().Col (tOINV, OINV_CARD_CODE).EQ ().Col (tJDT1, JDT1_SHORT_NAME);

				ustmt.Execute ();
			}
			catch (DBMException &e)
			{
				return e.GetCode ();
			}
		}
	}

	return noErr;
}

/**
 * Upgrade for JDT1.DprId(Fix for incident 28528): 
   Calculate out the Downpayment Request absEntry from JDT1.SourceLine data inputted after 8.81PL06. 
   And then upgrade DprId On BP account posting JE Row.
 *
 * 
 * @param isSalesObject 
   @param introVersion1_Including 
   @param introVersion2 
 * @return SBOErr 
*/
SBOErr CTransactionJournalObject::UpgradeDprId (bool isSalesObject, long introVersion1_Including, long introVersion2)
{
	SBOErr sboErr = ooNoErr;
	CBizEnv	&env = GetEnv ();
	long paymentObjType = isSalesObject ? RCT : VPM;
	long dpmObjType     = isSalesObject ? DPI : DPO;

	//1. Query out all DPR payments lines.	
	APCompanyDAG dagRES;
	long countRes = 0;
	try
	{
		/*
		SELECT	ORCT.VersionNum, ORCT.ObjType,
		RCT2.DocNum, RCT2.InvoiceId, RCT2.DocEntry, 

		FROM ORCT AS ORCT																							
		JOIN RCT2 ON ORCT.Canceled <> 'Y' AND ORCT.DocEntry = RCT2.DocNum  

		WHERE	(ORCT.VersionNum>= introVersion1_Including AND ORCT.VersionNum<introVersion2) AND RCT2.INVTYPE=203 AND RCT2.PAIDDPM='N'
		*/

		DBQRetrieveStatement stmt (env);

		//Tables
		DBQTable tORCT = stmt.From (env.ObjectToTable (paymentObjType, ao_Main));          //Payment doc
		DBQTable tRCT2 = stmt.Join (env.ObjectToTable (paymentObjType, ao_Arr2), tORCT);   //Payment lines
		stmt.On(tRCT2).Col(tRCT2, RCT2_DOC_KEY).EQ().Col(tORCT, ORCT_ABS_ENTRY)            //Payment should not be cancelled ones             
			    .And().Col(tORCT, ORCT_CANCELED).NE().Val(VAL_YES);

		//Select 				
		stmt.Select().Col(tORCT, ORCT_VERSION_NUM);	 //Payment version number
		stmt.Select().Col(tORCT, ORCT_OBJECT);		 //Payment obj type
		stmt.Select().Col(tRCT2, RCT2_DOC_KEY);      //Payment doc entry 
		stmt.Select().Col(tRCT2, RCT2_LINE_ID);      //Payment line id
		stmt.Select().Col(tRCT2, RCT2_INVOICE_KEY);  //Payment line doc absEntry - DPR absEntry

		//Those version numbers from 8.81PL06 to 8.82, we assume there won't be 15 patches.
		SBOCollection_SBOString versionNums;
		for (long i = 0, version = introVersion1_Including; i < 15 && version < introVersion2; i++, version++)
		{	
			SBOString versionStr (version), major, minor, build;
			major = versionStr.Left (1);
			minor = versionStr.Mid (1, 2);
			build = versionStr.Right (3);

			versionStr = major + _T(".") + minor + _T(".") + build;// + _T(".*");
			versionNums.Add(versionStr);
		}

		//Where
		stmt.Where().Col(tRCT2, RCT2_INVOICE_TYPE).EQ().Val(dpmObjType)                //Payment line is DPR type
			  .And().Col(tRCT2, RCT2_PAID_DPM).EQ().Val(VAL_NO);

		//Version range:  introVersion1_Including <= Payment doc versionNum < introVersion2
		stmt.Where().And().OpenBracket();
		for(long j =0; j<versionNums.GetSize(); j++)
		{
			stmt.Where().Col(tORCT, ORCT_VERSION_NUM).StartsWith().Val(versionNums[j]);

			if (j != versionNums.GetSize() -1)
			{
				stmt.Where().Or();
			}			
		}
		stmt.Where().CloseBracket();

		//Execute
		countRes = stmt.Execute (dagRES);
		if (countRes<1)
		{
			//No payments for DPR.
			return sboErr;
		}	
	}
	catch (DBMException& e)
	{
		return e.GetCode ();
	}

	//2. For each DPR payment line, update relevant JE line.
	sboErr = UpdateDprIdOnJERow(paymentObjType, dagRES);

	return sboErr;
}

/**
 * Update JDT1.DprId by dagRES.
 *
 * 
 * @param paymentObjType 
   @param dagRES 
 * @return SBOErr 
*/
SBOErr CTransactionJournalObject::UpdateDprIdOnJERow(long paymentObjType, const APCompanyDAG& dagRES)
{
	SBOErr sboErr = ooNoErr;
	CBizEnv	&env = GetEnv ();
	
	//2. For each DPR payment line, update relevant JE line.
	long countRes = dagRES->GetRealSize(dbmDataBuffer);	
	for (long rec=0; rec<countRes; rec++)
	{		
		long paymentDocEntry;
		long paymentLineId;
		long dprDocEntry;			

		dagRES->GetColLong (&paymentDocEntry, dagRES->GetColumnByAlias (RCT2_DOC_KEY_ALIAS),     rec);
		dagRES->GetColLong (&paymentLineId,   dagRES->GetColumnByAlias (RCT2_LINE_ID_ALIAS),     rec);
		dagRES->GetColLong (&dprDocEntry,     dagRES->GetColumnByAlias (RCT2_INVOICE_KEY_ALIAS), rec);

		try
		{
			/*
			update JDT1 set JDT1.dprId = dprDocEntry

			where JDT1.TransType = [paymentObjType]
			and   JDT1.CreatedBy = [paymentDocEntry]
			and   JDT1.LineType  = ooCtrlAct_DPRequestType
			and   JDT1.DprId     = null
			and   (JDT1.SourceLine = null or JDT1.SourceLine = [paymentLineId] or JDT1.SourceLine < 0)
			*/

			DBQUpdateStatement	ustmt (env);
			DBQTable tJDT1 = ustmt.Update (env.ObjectToTable (JDT, ao_Arr1));

			//Set dprId as dprDocEntry
			ustmt.Set (JDT1_DPR_ABS_ID).Val (dprDocEntry);

			ustmt.Where().Col(tJDT1, JDT1_TRANS_TYPE).EQ ().Val (paymentObjType)              //TransType = paymentObjType
				  .And ().Col(tJDT1, JDT1_CREATED_BY).EQ ().Val (paymentDocEntry)             //Createdby = paymentDocEntry
				  .And ().Col(tJDT1, JDT1_LINE_TYPE).EQ().Val((long)ooCtrlAct_DPRequestType)  //LineType  = DPR controlAccount line, namely the BP posting line for dpr
				  .And ().Col(tJDT1, JDT1_DPR_ABS_ID).IsNull()								  //dprId     = null

				.And ().OpenBracket().		
				// If  SourceLine = null || SourceLine = paymentLineId || SourceLine < 0
				      Col(tJDT1, JDT1_SRC_LINE).IsNull()
				.Or().Col(tJDT1, JDT1_SRC_LINE).EQ().Val(paymentLineId)         
				.Or().Col(tJDT1, JDT1_SRC_LINE).LT().Val(0)				
				.CloseBracket();

			ustmt.Execute ();
		}
		catch (DBMException &e)
		{
			return e.GetCode ();
		}
	}

	return sboErr;
}

/**
   [Fix for SMS Task 23801]
 * If there is possible simple DPR payment(one payment pays one dpr) JDT data 
   created before version 8.81PL06, upgrade JDT1.DprId.
 *
 * 
 * @param isSalesObject 
   @param introVersion 
 * @return SBOErr 
*/
SBOErr CTransactionJournalObject::UpgradeDprIdForOneDprPayment(bool isSalesObject, long introVersion)
{
	SBOErr sboErr = ooNoErr;
	CBizEnv	&env = GetEnv ();
	long paymentObjType = isSalesObject ? RCT : VPM;
	long dpmObjType     = isSalesObject ? DPI : DPO;

	//1. Query out all DPR payments lines.	
	APCompanyDAG dagRES;
	long countRes = 0;
	try
	{
		/*
		SELECT	 MIN(ORCT.VersionNum) as VersionNum, 
		         MIN(ORCT.ObjType) as ObjType,	
				 RCT2.DocNum, 
			     MIN(RCT2.InvoiceId) as InvoiceId, 
				 MIN(RCT2.DocEntry) as DocEntry  
		
		FROM ORCT  JOIN RCT2 ON ORCT.Canceled <> 'Y' AND ORCT.DocEntry = RCT2.DocNum 
		WHERE	(ORCT.VersionNum<introVersion) AND RCT2.INVTYPE=203 AND RCT2.PAIDDPM='N'
		GROUP BY RCT2.DocNum HAVING count(RCT2.DocNum)=1		
		*/

		DBQRetrieveStatement stmt (env);

		//Tables
		DBQTable tORCT = stmt.From (env.ObjectToTable (paymentObjType, ao_Main));          //Payment doc
		DBQTable tRCT2 = stmt.Join (env.ObjectToTable (paymentObjType, ao_Arr2), tORCT);   //Payment lines
		stmt.On(tRCT2).Col(tRCT2, RCT2_DOC_KEY).EQ().Col(tORCT, ORCT_ABS_ENTRY)            //Payment should not be cancelled ones             
			    .And().Col(tORCT, ORCT_CANCELED).NE().Val(VAL_YES);

		//Select 				
		stmt.Select().Min().Col(tORCT, ORCT_VERSION_NUM).As(ORCT_VERSION_NUM_ALIAS);	 //Payment version number
		stmt.Select().Min().Col(tORCT, ORCT_OBJECT).As(ORCT_OBJECT_ALIAS);				 //Payment obj type
		stmt.Select().Col(tRCT2, RCT2_DOC_KEY).As(RCT2_DOC_KEY_ALIAS);					 //Payment doc entry 
		stmt.Select().Min().Col(tRCT2, RCT2_LINE_ID).As(RCT2_LINE_ID_ALIAS);			 //Payment line id
		stmt.Select().Min().Col(tRCT2, RCT2_INVOICE_KEY).As(RCT2_INVOICE_KEY_ALIAS);	 //Payment line doc absEntry - DPR absEntry

		//The version numbers of 8.81PL06.
		SBOString versionStr (introVersion), major, minor, build;
		major = versionStr.Left (1);
		minor = versionStr.Mid (1, 2);
		build = versionStr.Right (3);
		versionStr = major + _T(".") + minor + _T(".") + build;// + _T(".*");

		//Where
		stmt.Where().Col(tRCT2, RCT2_INVOICE_TYPE).EQ().Val(dpmObjType)                //Payment line is DPR type
			  .And().Col(tRCT2, RCT2_PAID_DPM).EQ().Val(VAL_NO)
			  .And().Col(tORCT, ORCT_VERSION_NUM).LT().Val(versionStr);


		//GroupBy
		stmt.GroupBy (tRCT2, RCT2_DOC_KEY);
		stmt.Having().Count().Col(tRCT2, RCT2_DOC_KEY).EQ().Val(1);                    //One DPR payment

		//Execute
		countRes = stmt.Execute (dagRES);
		if (countRes<1)
		{
			//No payments for DPR.
			return sboErr;
		}	
	}
	catch (DBMException& e)
	{
		return e.GetCode ();
	}

	//2. For each DPR payment line, update relevant JE line.
	sboErr = UpdateDprIdOnJERow(paymentObjType, dagRES);

	return sboErr;

}

// OnGetByKey
SBOErr CTransactionJournalObject::OnGetByKey()
{
	SBOErr ooErr = ooNoErr;
	PDAG dagJDT=NULL, dagJDT1=NULL, dagCFT=NULL;
	CBizEnv& bizEnv = GetEnv();

	ooErr = CSystemBusinessObject::OnGetByKey ();
	if (ooErr && ooErr != dbmArrayRecordNotFound)
	{
		return ooErr;
	}

	dagJDT = GetDAG();
	dagJDT1 = GetDAG(JDT, ao_Arr1);
	
	SBOString transID;
	dagJDT->GetColStr(transID, OJDT_JDT_NUM, 0);

	APCompanyDAG dagRes;
	long res = 0;
	try
	{
		if(VF_CashflowReport(bizEnv))
		{
			SBOString objID(CFT);
			dagCFT = GetDAG(objID);
			DBQRetrieveStatement stmtCFT(bizEnv);
			DBQTable tOCFT = stmtCFT.From (bizEnv.ObjectToTable (CFT));

			stmtCFT.Where ().Col (tOCFT, OCFT_JDT_ID).EQ().Val(transID)
								.And().Col(tOCFT, OCFT_STATUS).NE ().Val(CFT_STATUS_CREDSUM);  //VIRTUAL? PA & PO?

			res = stmtCFT.Execute(dagRes);
			dagCFT->Copy(dagRes, dbmBothBuffers);
		}
	}
	catch (DBMException &e)
	{
		return e.GetCode ();
	}

	ooErr = LoadTax();
	if (ooErr)
	{
		return ooErr;
	}

	return ooErr;
}
/**
 * Fill cost accounting field in journal entry
 *
 * 
 * @param costAccountingFieldMap 
 * @return void 
*/
void	CTransactionJournalObject::OnGetCostAccountingFields(CostAccountingFieldMap& costAccountingFieldMap)
{
	CostAccountingField	costAccountingFields;
	LongArray	distrRule;

	// ao_Main
	costAccountingFields.projects.Add (OJDT_PROJECT);
	costAccountingFieldMap[ao_Main] = costAccountingFields;

	// ao_Arr1
	costAccountingFields.projects.RemoveAll ();
	costAccountingFields.projects.Add(JDT1_PROJECT);

	distrRule.Add(JDT1_OCR_CODE);
	distrRule.Add(JDT1_OCR_CODE2);
	distrRule.Add(JDT1_OCR_CODE3);
	distrRule.Add(JDT1_OCR_CODE4);
	distrRule.Add(JDT1_OCR_CODE5);
	costAccountingFields.distributionRules.Add(distrRule);

	costAccountingFieldMap[ao_Arr1] = costAccountingFields;
}
/**
 * Validate cost accounting field when posting journal entry
 *
 * 
 * @param bizObject 
 * @return SBOErr 
*/
SBOErr	CTransactionJournalObject::OJDTValidateCostAcountingStatus (CBusinessObject* bizObject, PDAG dagJDT)
{
	SBOErr		sboErr = noErr;
	PDAG		dagJDT1;

	dagJDT1 = bizObject->GetDAG(JDT, ao_Arr1);

	CTransactionJournalObject*	journalEntry = (CTransactionJournalObject*)bizObject->CreateBusinessObject(JDT);
	AutoCleanBOHandler	jdtCleaner ((CBusinessObject*&)journalEntry);
	journalEntry->SetDAG(dagJDT, false);
	journalEntry->SetDAG(dagJDT1, false, JDT, ao_Arr1);

	return journalEntry->ValidateCostAccountingStatus();
}

/**
* GetLinkMapMetaData
* VF_EnableLinkMap
*/
SBOErr CTransactionJournalObject::GetLinkMapMetaData (LinkMap::ILMVertex& el)
{
	//call parent
	SBOErr ooErr = CBusinessObjectBase::GetLinkMapMetaData (el);
	IF_ERROR_RETURN (ooErr);

	PDAG dagJDT = GetDAG ();

	//visual icon metadata
	ooErr = AddLinkMapIconMetaData (el, dagJDT, OJDT_PRINTED, VAL_YES, LinkMap::ILMVertex::imdPrinted, LINKMAP_ICONSTR_PRINTED);
	IF_ERROR_RETURN (ooErr);

	//textual string/money metadata
	ooErr = AddLinkMapStringMetaData (el, dagJDT, OJDT_NUMBER);
	IF_ERROR_RETURN (ooErr);

	ooErr = AddLinkMapStringMetaData (el, dagJDT, OJDT_REF_DATE);
	IF_ERROR_RETURN (ooErr);

	ooErr = AddLinkMapStringMetaData (el, dagJDT, OJDT_MEMO);
	IF_ERROR_RETURN (ooErr);

	return ooNoErr;
}
SBOErr	CTransactionJournalObject::ReconcileDeferredTaxAcctLines ()
{
	SBOErr				sboErr = ooNoErr;
	CBizEnv&			bizEnv = GetEnv ();
	PDAG				dagJDT = GetDAG ();
	PDAG				dagJDT1 = GetArrayDAG (ao_Arr1);
	Date				date;
	long				transId, lineId;
	SBOString			stornoNum;
	APCompanyDAG		dagStornoJDT1;
	eInterimAcctType	interimType;

	dagJDT->GetColStr (stornoNum, OJDT_STORNO_TO_TRANS);
	if (stornoNum.IsEmpty () || !bizEnv.IsLocalSettingsFlag (lsf_EnableDeferredTax))
	{
		return ooNoErr;
	}

	dagJDT->GetColStr (date, OJDT_REF_DATE);
	bizEnv.OpenDAG (dagStornoJDT1, JDT, ao_Arr1);
	sboErr = bizEnv.GetByOneKey (dagStornoJDT1, JDT1_KEYNUM_PRIMARY, stornoNum);
	IF_ERROR_RETURN (sboErr);

	CSystemMatchManager deferredMM(bizEnv, false, date.GetString (), JDT, stornoNum, rt_Reversal);
	
	long tmpL;
	// add current JDT1 deferred tax lines to match data
	for (long rec = 0; rec < dagJDT1->GetRealSize (dbmDataBuffer); ++rec)
	{
		dagJDT1->GetColLong(&tmpL, JDT1_INTERIM_ACCT_TYPE, rec);
		interimType = (eInterimAcctType)tmpL;
		if (interimType == IAT_DeferTaxInterim_Type)
		{
			dagJDT1->GetColLong (&transId, JDT1_TRANS_ABS, rec);
			dagJDT1->GetColLong (&lineId, JDT1_LINE_ID, rec);
			deferredMM.AddMatchDataLine (transId, lineId);
		}
	}

	// add storno JDT1 deferred tax lines to match data
	for (long rec = 0; rec < dagStornoJDT1->GetRealSize (dbmDataBuffer); ++rec)
	{
		dagStornoJDT1->GetColLong(&tmpL, JDT1_INTERIM_ACCT_TYPE, rec);
		interimType = (eInterimAcctType)tmpL;
		if (interimType == IAT_DeferTaxInterim_Type)
		{
			sboErr = CManualMatchManager::CancelAllReconsOfJournalLine(bizEnv, stornoNum.strtol (), rec, false, date.GetString ());
			IF_ERROR_RETURN (sboErr);

			dagStornoJDT1->GetColLong (&transId, JDT1_TRANS_ABS, rec);
			dagStornoJDT1->GetColLong (&lineId, JDT1_LINE_ID, rec);
			deferredMM.AddMatchDataLine (transId, lineId);
		}
	}

	sboErr = deferredMM.Reconcile ();

	return sboErr;
}

/**
 * IsPaymentOrdered
 *
 * 
 * @return bool 
*/
bool CTransactionJournalObject::IsPaymentOrdered ()
{
	PDAG dagJDT1 = GetArrayDAG (ao_Arr1);
	long numOfRecs = dagJDT1->GetRecordCount ();

	for (long i=0; i<numOfRecs; i++)
	{
		SBOString ordered;
		dagJDT1->GetColStr (ordered, JDT1_ORDERED, i);
		if (ordered == VAL_YES)
		{
			return true;
		}
	}

	return false;
}

/**
 * IsPaymentOrdered
 *
 * 
 * @param bizEnv 
 * @param transId 
 * @param isOrdered 
 * @return SBOErr 
*/
SBOErr CTransactionJournalObject::IsPaymentOrdered (CBizEnv& bizEnv, long transId, bool& isOrdered)
{
	SBOErr ooErr = ooNoErr;
	isOrdered = false;

	try
	{
		DBQRetrieveStatement stmt (bizEnv);

		DBQTable tJDT1 = stmt.From (bizEnv.ObjectToTable (JDT, ao_Arr1));

		stmt.Select ().Count();
		stmt.Where ().Col (tJDT1, JDT1_TRANS_ABS).EQ ().Val (transId)
			.And ().Col (tJDT1, JDT1_ORDERED).EQ ().Val (VAL_YES);

		APCompanyDAG pResDag;
		long numOfRecs = stmt.Execute (pResDag);

		if (numOfRecs >= 1)
		{
			isOrdered = true;
		}
	}
	catch (DBMException &e)
	{
		ooErr = e.GetCode ();
		return ooErr;
	}

	return ooNoErr;
}

/**
 * IsScAdjustment
 *
 * 
 * @param isScAdjustment 
 * @return SBOErr 
*/
SBOErr CTransactionJournalObject::IsScAdjustment (bool &isScAdjustment)
{
	PDAG dagJDT1 = GetArrayDAG (ao_Arr1);
	long numOfRecs = dagJDT1->GetRecordCount ();

	SBOErr ooErr = noErr;
	CBizEnv &bizEnv = GetEnv();

	long transID;
	dagJDT1->GetColLong (&transID, JDT1_TRANS_ABS, 0);
	
	isScAdjustment = false;
	for (long rec = 0; rec < numOfRecs; rec++)
	{
		long lineNum;
		dagJDT1->GetColLong (&lineNum, JDT1_LINE_ID, rec);

		PDAG dagRes = NULL;
		ooErr = CManualMatchManager::GetReconciliationByTransaction (bizEnv, transID, lineNum, &dagRes);
		if (ooErr)
		{
			dagRes->Close ();

			if (ooErr = dbmNoDataFound)
			{
				ooErr = noErr;
				continue;
			}
			else
			{
				return ooErr;
			}
		}

		long sizeOfRes = dagRes->GetRecordCount();
		long reconType;
		for (long i = 0; i < sizeOfRes; i++)
		{
			dagRes->GetColLong (&reconType, REC_RES_RECON_TYPE, i);
			if (reconType == rt_ScAdjument)
			{
				isScAdjustment = true;
				break;
			}
		}

		dagRes->Close ();

		if (isScAdjustment)
		{
			break;
		}		
	}

	return ooNoErr;
}

SBOErr CTransactionJournalObject::OnCommand( long command )
{
	SetExCommand(ooExAutoMode, fa_SetSolo);
	SetExDtCommand(ooOBServerDT, fa_SetSolo);
	//SetAlternativeBF(REGULAR_BUSINESS_FLOW);

	CJdtODHelper odHelper(*this);

	switch (command)
	{	
	case JournalEntryDocumentTypeService_CmdCode_RefDateChange:
		return odHelper.ODRefDateChange ();
		break;
	case JournalEntryDocumentTypeService_CmdCode_MemoChange:
		return odHelper.ODMemoChange ();
		break;
	default:
		return CSystemBusinessObject::OnCommand(command);
	}	

	return noErr;
}

SBOErr CTransactionJournalObject::OnSetDynamicMetaData (long commandCode)
{
	SBOErr ooErr = noErr;
	if (commandCode == BusinessService_CmdCode_GetByParams || commandCode == BusinessService_CmdCode_Add)
	{
		long headerFields[] = {OJDT_REF_DATE, -1};
		for (long i = 0; headerFields[i] > 0; ++i)
		{
			ooErr = SetDynamicMetaData (ao_Main, headerFields[i], false); 
		}

		SetDynamicMetaData (ao_Arr1, JDT1_LINE_MEMO, true, -1);
		long cols[] = {JDT1_DEBIT, JDT1_CREDIT, JDT1_ACCT_NUM, JDT1_SHORT_NAME, -1};
		for (long i = 0; cols[i] > 0; ++i)
		{
			ooErr = SetDynamicMetaData (ao_Arr1, cols[i], false, -1);
		}

	}

	SetBOActionMetaData (BusinessService_CmdCode_Cancel, OnCanCancel());

	return ooErr;
}

SBOErr CJdtODHelper::ODRefDateChange ()
{
	SBOErr ooErr = noErr;
	CBizEnv & bizEnv = m_bo.GetEnv ();
	long objId = m_bo.GetID ().strtol ();
	PDAG dagJDT = m_bo.GetDAG(objId, ao_Main);

	SBOString refDateStr;
	dagJDT->GetColStrAndTrim(refDateStr, OJDT_REF_DATE);
			
	if (refDateStr.Trim().IsSpacesStr())
	{
		Date tmpDate;
		if (tmpDate.SetCurrentDate (bizEnv) == noErr)
		{
			refDateStr = tmpDate.GetString ();
		}
	}

	dagJDT->SetColStr (refDateStr, OJDT_TAX_DATE, 0);

	if (VF_SupplCode(bizEnv))
	{
		CSupplCodeManager*	pManager = bizEnv.GetSupplCodeManager();
		ooErr = pManager->LoadDfltCodeToDag (m_bo, Date(refDateStr.GetBuffer()));
	}

	return ooErr;
}

SBOErr CJdtODHelper::ODMemoChange ()
{
	SBOErr ooErr = noErr;
	CBizEnv & bizEnv = m_bo.GetEnv ();
	long objId = m_bo.GetID ().strtol ();
	PDAG dagJDT = m_bo.GetDAG(objId, ao_Main);
	PDAG dagJDT1 = m_bo.GetDAG(objId, ao_Arr1);

	SBOString headerMemo;
	dagJDT->GetColStrAndTrim (headerMemo, OJDT_MEMO);
	long jdt1Rec = dagJDT1->GetRealSize (dbmDataBuffer);
	for (long i = 0; i < jdt1Rec; ++i)
	{
		dagJDT1->SetColStr (headerMemo, JDT1_LINE_MEMO, i);
	}
	
	return ooErr;
}
/*
*****************************************************************************
*****************************************************************************
*****************************************************************************
*/
CJDTDeferredTaxUtil:: CJDTDeferredTaxUtil (CBusinessObject* bo) : m_bo(bo), m_bpLine(-1), m_dts(dts_None)
{
}

CJDTDeferredTaxUtil:: ~CJDTDeferredTaxUtil ()
{

}

DEFERREDTAXSTATUS CJDTDeferredTaxUtil::InitDeferredTaxStatus ()
{
	PDAG dagJDT = m_bo->GetDAG(JDT);
	SBOString autoVat, deferredTax;
	dagJDT->GetColStr (autoVat, OJDT_AUTO_VAT, 0);
	autoVat.Trim ();
	dagJDT->GetColStr (deferredTax, OJDT_DEFERRED_TAX, 0);
	deferredTax.Trim ();
	if (autoVat == VAL_NO && deferredTax == VAL_YES)
	{
		m_dts = dts_Invalid;
		return m_dts;
	}

	if (autoVat == VAL_NO && deferredTax == VAL_YES)
	{
		m_dts = dts_Invalid;
		return m_dts;
	}

	if (deferredTax == VAL_NO)
	{
		m_dts = dts_Skip;
		return m_dts;
	}	

	m_dts = dts_Deferred;

	return m_dts;
}

DEFERREDTAXSTATUS CJDTDeferredTaxUtil::GetDeferredTaxStatus ()
{
	if (m_dts != dts_None)
	{
		return m_dts;
	}

	return InitDeferredTaxStatus();
}

bool CJDTDeferredTaxUtil::IsValidDeferredTaxStatus ()
{
	return GetDeferredTaxStatus () != dts_Invalid;
}

bool CJDTDeferredTaxUtil::IsValidBPLines()
{
	bool isValidLine = true;
	PDAG dagJDT1 = m_bo->GetDAG(JDT, ao_Arr1);
    long bpLineCount = 0;
    long recJDT1 = dagJDT1->GetRealSize (dbmDataBuffer);
    SBOString acct, shortname;
        
    for(long rec = 0; rec < recJDT1; rec++)
    {
        dagJDT1->GetColStr(acct, JDT1_ACCT_NUM, rec);
        dagJDT1->GetColStr(shortname, JDT1_SHORT_NAME, rec);
        acct.Trim();
        shortname.Trim();
        if(acct != shortname)    
        {
            //a bp line;
            bpLineCount++;
        }
    }

	if (bpLineCount != 1)
	{
		isValidLine = false;
	}
    
	return isValidLine;
}

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
