#include "stdafx.h"

#include "POJDT.h"
#include "AppMsg_FIN_Defines.h"


SBOErr  CTransactionJournalObject::SetJournalDocumentNumber(CBizEnv* bizEnv, CBusinessObject *bizObject, PDAG dagJDT)
//Revise based on CTransactionJournalObject::RecordHist
{
		SBOErr		ooErr = noErr;
		long		num = 0, series;
		long		transType;
		PDAG		dagOBJ = bizObject->GetDAG ();

		PDAG		dag = dagJDT;

		bizObject->SetExCommand3(ooEx3DontTouchNextNum, fa_Clear);
		dag->GetColLong(&series, OJDT_SERIES);

		if (!series)
		{
			// ************************** MultipleOpenPeriods *************************
			SBOString refDate;
			dag->GetColStr (refDate, OJDT_REF_DATE);
			if (refDate.Trim().IsSpacesStr())
				DBM_DATE_Get (refDate, *bizEnv);

			// VF_MultiBranch_EnabledInOADM
			series = bizEnv->GetDefaultSeriesByDate (bizObject->GetBPLId (), SBOString (JDT), refDate);
			// ************************************************************************
			dag->SetColLong (series, OJDT_SERIES, 0);
		}

		dag->GetColLong(&transType, OJDT_TRANS_TYPE);
		if (bizEnv->IsLocalSettingsFlag(lsf_IsDocNumMethod))
		{
			if (transType != OPEN_BLNC_TYPE && transType != CLOSE_BLNC_TYPE && transType != MANUAL_BANK_TRANS_TYPE)
			{
				dag->GetColLong(&num, OJDT_NUMBER);
			}
			dag->SetColLong (series, OJDT_DOC_SERIES, 0);
		}
		else
		{
			if (transType < 0 || transType == JDT || !bizEnv->IsSerieObject(SBOString (transType)))
			{
				dag->SetColLong (series, OJDT_DOC_SERIES, 0);
			}
			else
			{
				//nothing to do
				//it should be filled by operation object
			}
		}

		CBusinessObject *bizJDT = bizEnv->CreateBusinessObject(SBOString(JDT));
		bizJDT->SetSeries(series);
		ooErr = bizJDT->GetNextSerial (TRUE);
		if (ooErr)
		{
			return (ooErr);
		}
		num = bizJDT->GetNextNum();
		bizJDT->Destroy();
		bizJDT = NULL;

		dag->SetColLong (num, OJDT_NUMBER, 0);

		return ooErr;
}

SBOErr  CTransactionJournalObject::UpdateAccountBalance(CBizEnv* bizEnv, PDAG dagACT, PDAG dagJDT, PDAG dagJDT1)
{
	SBOErr ooErr = noErr;

	int ct = dagJDT1->GetRecordCount();
	for(int i = 0;i<ct;i++)
	{
		SBOString actKey;
		dagJDT1->GetColStrAndTrim(actKey, JDT1_ACCT_NUM, i);

		long row;
		ooErr = dagACT->FindColStr(actKey, OACT_ACCOUNT_CODE, 0, &row);
		IF_ERROR_RETURN(ooErr);

		MONEY actAmount;
		MONEY fActAmount;
		MONEY sysActAmount;

		dagACT->GetColMoney (&actAmount, OACT_CURRENT_BALANCE, row);
		dagACT->GetColMoney (&fActAmount, OACT_F_BALANCE, row);
		dagACT->GetColMoney (&sysActAmount, OACT_S_BALANCE, row);


		MONEY sum,frgnSum,sysSum;
		MONEY sumDebit,frgnSumDebit,sysSumDebit;

		dagJDT1->GetColMoney(&sum, JDT1_CREDIT,i);
		dagJDT1->GetColMoney(&sysSum, JDT1_SYS_CREDIT,i);
		dagJDT1->GetColMoney(&frgnSum, JDT1_FC_CREDIT,i);

		dagJDT1->GetColMoney(&sumDebit, JDT1_DEBIT,i);
		dagJDT1->GetColMoney(&sysSumDebit, JDT1_SYS_DEBIT,i);
		dagJDT1->GetColMoney(&frgnSumDebit, JDT1_FC_DEBIT,i);

		sum-=sumDebit;
		frgnSum-=frgnSumDebit;
		sysSum-=sysSumDebit;


		bool add = true;
		SBOString credit;
		dagJDT->GetColStr(credit, JDT1_DEBIT_CREDIT, i);
		if (credit == VAL_CREDIT)
		{
			add=!add;
		}
		if (bizEnv->GetBalanceStyle () == balanceTrueStyle)
		{
			add =!add;
		}
		if(add)
		{
			actAmount+=sum;
			fActAmount+=frgnSum;
			sysActAmount+=sysSum;
		}
		else
		{
			actAmount-=sum;
			fActAmount-=frgnSum;
			sysActAmount-=sysSum;
		}

		Currency		currStr = {0};
		dagACT->GetColStr (currStr, OACT_ACT_CURR, row);
		_STR_LRTrim (currStr);
		if (!GNCoinCmp (currStr, BAD_CURRENCY_STR))
		{
			fActAmount.SetToZero();
		}

		dagACT->SetColMoney (&actAmount, OACT_CURRENT_BALANCE, row);
		dagACT->SetColMoney (&sysActAmount, OACT_S_BALANCE, row);
		dagACT->SetColMoney (&fActAmount, OACT_F_BALANCE, row);
	}





	return ooErr;
}
