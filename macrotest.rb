def test(testall=false)

s=<<HERE
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
#define ABC 1 //fdafsa
HERE
s=<<HERE
a = 1;
#define AAA 1//f/sdafs
#define AAAa //f/sdafs
#define BBB "fd/*a*/s//fas" //fdasfsd
#define C(a) c(/*fdfasf*/a, "fd/*af*/s") //fdasfsd
HERE
s=<<HERE
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
HERE


s0=<<HERE
#include "b.h"
a = 1;
#ifndef a_h
#define a_h
b = 1;
c=1;
#endif
#ifdef b_h
"b_h defined"
#endif
HERE


s1 =<<HERE
//a = 1;
//#define bbc

//abc=1;

#include "a.h"

//#fdaaslk
//c=1;
//#include "bss.h"
//b =1;
HERE
s2 =<<HERE
#pragma once fdffd \
dfasfd\
fdas
#include "b.h"
HERE





s3=<<HERE
#ifndef ADD
a=32;
#else
a=3;
#endif
#if 1
a=1;
#else
a=2;
#endif
HERE


s4=<<HERE

#define		JDT_WARNING_BLOCK1	3
#ifdef JDT_WARNING_BLOCK1
a = 1;
#else
a = 2;
#endif

HERE
s5=<<HERE
#if 0
a=3;
#else
a =1;
#endif
HERE
s =<<HERE
#define LOG(m, l) log(m, l);\
m++;\
l--
#define A 10
a=A;
LOG("FAFAF", 10);
LOG("B", 3);
LOG(aaa, 3);
HERE


s6=<<HERE
#if 1
a=3;
#else
a =1;
#endif
HERE





s7=<<HERE
#ifndef B
#define B 31
#else
#define A 33
#endif
HERE
s=<<HERE
#ifndef XML_RESOURCE_TOOLS_TABLE_JDT1_H
#define XML_RESOURCE_TOOLS_TABLE_JDT1_H
#define	JDT1_KEYNUM_JDT1CHECKA_LEN							31

#endif

HERE
s8=<<HERE
#include "JDT1.h"
HERE
s9=<<HERE
#include "qa.h"
HERE

s10=<<HERE
#define		FILE_TAB				_T("\\t\\n")
FILE_TAB
HERE
s=<<HERE
printf('-----------1');
#if 1
a=3;
#else
a =1;
#endif
printf('-----------2');
#if 0
a=33;
#else
a =11;
#endif
HERE

s11=<<HERE
try{
    _LOGMSG(logDebugComponent, logNoteSeverity, 
	    _T("In CTransactionJournalObject::BeforeDeleteArchivedObject - starting JEComp.execute()"))
	    CJECompression	JEComp(GetEnv(), &JEPref);
		
}	
    catch (nsDataArchive::CDataArchiveException& e){
    
}
HERE




s12=<<HERE
#ifdef QC_SHELL_ON
		qc = TRUE;
#else
		qc = FALSE;
#endif


HERE
s13=<<HERE
#pragma once
#ifdef POJDT_H
#endif
HERE
s14=<<HERE

		JDT1_CREDIT										=	4,
#define	JDT1_CREDIT_LEN										20
#define	JDT1_CREDIT_ALIAS									L"Credit"

		// System Credit Amount
		JDT1_SYS_CREDIT									=	5,

    	docInfoQry.Select ().Max ().Col (tableObjRow, JDT1_CREDIT).Sub ().Max ().Col (tableObjRow, JDT1_DEBIT).As (JDT1_CREDIT_ALIAS);

HERE
s15=<<HERE
// included from file c_macros.c
#define TRUE true
#define FALSE false
#define NULL nil
#define _LOGMSG(a,b,c)

HERE
s16=<<HERE
#if 0
#define B 31
#else
#define A 33
#endif
A
HERE

s17=<<HERE
#define _DEBUG 
#ifdef _DEBUG
b=1;
#ifdef _WINDOWS
b=2;
#else
#endif
#endif
a=1;
HERE

s18=<<HERE
#define _DEBUG 
#ifndef _DEBUG
b=1;
#ifdef _WINDOWS
b=2;
#define _DEBUG1 1

#else
#endif
#endif
a=1;
HERE
s=<<HERE
#define DAG_DEF_ELEMENT_SIZE	20480
#define MAX_COND_SIZE			600

#define __DAG_WORM_WRITE_LOCK__	//SBOLockGuard lockGuard (m_lock.get ())
#define __DAG_WORM_READ_LOCK__	//SBOLockGuard lockGuard (m_lock.get ())
#define __DAG_SET_STATIC_LOCK__	SBOCriticalSection CsGuard (GetStaticData ().m_dagSetLock)


////////////////////////////////////////////////////////////////////////////////////////////////////

class DagCleaner;


////////////////////////////////////////////////////////////////////////////////////////////////////

#ifdef _DEBUG

#include <unordered_map>


typedef std::unordered_map<PDAG, DagStackInfo> DagStackSnapMap;

#endif // _DEBUG

////////////////////////////////////////////////////////////////////////////////////////////////////

class CDagException : public CException
{
public:
	CDagException (long sboErr, const SBOString& tableAlias, const SBOString& message)
		: CException (sboErr, L"DAG error", message + " (table " + tableAlias + ")") {}
};
HERE

s19=<<HERE
inline ArrayOffset  SubObjectToArrayOffSet(IN long subObject);
HERE

s20=<<HERE
#	define UTB_API 11

int a = UTB_API;

HERE

s21=<<HERE
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
	const SensitiveFieldList* GetSensitiveFieldList(){return sfHolder.GetSensitiveFields();}
    
    DECLARE_SENSITIVE_FIELD

HERE

s22=<<HERE
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

s23=<<HERE
#define NUM_OF_CURRENCY 3
#define CACHE_OBJECT_ADM1					d(ADM*10000 + ao_Arr1)
CACHE_OBJECT_ADM1

#define AA(a,b) a*a+b

#define B int a;
int b = AA(3, 5);
B
#define trace1(m)  a(m)

trace1("ff");
_TRACER(1);
MONEY		sums[NUM_OF_CURRENCY];
IF_ERROR_RETURN(ef);
HERE
s24=<<HERE
#if !defined(__cplusplus) || defined(_M_CEE_PURE) || defined(_CRT_GETPUTWCHAR_NOINLINE)
#define getwchar()      fgetwc(stdin)
#define putwchar(_c)    fputwc((_c),stdout)
#else   /* __cplusplus */
inline wint_t __CRTDECL getwchar()
        {return (fputwc(stdin)); }   /* stdin */
inline wint_t __CRTDECL putwchar(wchar_t _C)
        {return (fputwc(_C, stdout)); }       /* stdout */
#endif  /* __cplusplus */
#define _VER -1
#if _VER > 900
a()
#endif
#if _VER > _FF
b()
#endif
#define UNUSED_UNLESS_ASSERT_ON(...) (void)(__VA_ARGS__)
UNUSED_UNLESS_ASSERT_ON(3, "fdsaf")
HERE

s25=<<HERE
#ifdef MAX
#	undef MAX
#endif

namespace CMONEY
{
	class CBigIntException{};
	class CDivZeroException: public CBigIntException{};
	class COverflowException: public CBigIntException{};
	class CValidationException: public CBigIntException{};
	/**
	CBigInt is an array of size N
	*/
	class B1_ENGINE_API CBigInt
	{

#ifndef _LP64
		operator unsigned long () const;
#endif

B1_OBSERVER_API void a(){}

HERE

s26=<<HERE
#includestackpop ddd
int a = 1;
#undef CreateProcess
int b=1;

#define CDF 333
#define AA CDF*bcd
int c = AA;
fn(c);


HERE
s27=<<HERE

#define BUILD_INTERFACE_RUNTIME
#define __hpux
#define sun
#if defined(_WIN32)
    #define SQL_API  __stdcall
#else
    a=1;
    b=1;
#ifdef BUILD_INTERFACE_RUNTIME
        /* RTE_VISIBILITY_CHECK: Symbol visibility support for Unix */
        "defined BUILD_INTERFACE_RUNTIME"
        
        #if (defined(__linux__) || defined(__APPLE__))
            "defined linux"
            #if __GNUC__ >= 4
                #define SQL_API __attribute__ ((visibility("default")))
            #else
                #define SQL_API
            #endif
        #elif (defined(sun) || defined(__sun))
            #define SQL_API __symbolic
            "defined sun"
        #elif (defined(__hpux))
            #define SQL_API __declspec(dllexport)
            "defined __hpux"
        #elif (defined(_AIX))
            #define SQL_API
        #else
        p("error");
            #error Unknown platform
        #endif
#else
        "BUILD_INTERFACE_RUNTIME not defined"
        #define SQL_API
#endif
#endif
HERE

s28=<<HERE
/*
#ifdef AA
"aa"
#else
"AA"
#endif
#ifdef AA
"aa"
#elif defined(BB)
#elif defined(CC)
"AA"
#else
"jha"
#endif //2

#if defined(B1_OBSERVER_MODULE) || defined(B1_INTERNAL_FIELDS_MODULE)
	#define B1_OBSERVER_API __declspec(dllexport)
#elif defined(B1_DI_CORE_MODULE) || defined(B1_TESTS_MODULE)
	#define B1_OBSERVER_API
#elif defined(B1_LiCENSE_SERVER) || defined(B1_LiCENSE_SERVER_DEBUG)
	#define B1_OBSERVER_API
#else
	#define B1_OBSERVER_API __declspec(dllimport)
    "fff"
#endif
*/
#if defined (_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif //fff

/*  If defined, the following flags inhibit definition
 *     of the indicated items.
 *  NOMCX             - Modem Configuration Extensions
 */
HERE
s29=<<HERE

#ifndef B1_SERVER_MANAGER
#pragma comment(linker, \\
    "/manifestdependency:\\\"type='win32' " \\
    "name='Microsoft.Windows.Common-Controls' " \\
    "version='6.0.0.0' " \\
    "processorArchitecture='*' " \\
    "publicKeyToken='6595b64144ccf1df' " \\
    "language='*'\\\"")
#endif

#define AA a+b \
c()

AA

#define BB(c) c+1

class C{

	operator unsigned long () const;
	operator bool() const;
	operator int32_t() const;
	operator int64_t() const;
	operator uint32_t () const;
	operator uint64_t () const;
	operator double () const ;

}
B1_OBSERVER_API void fn();
HERE
if !testall
   
    s = s29

else

    r = ""
    for i in 0..100
        begin
            si = eval("s#{i}")
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
#$g_options = {
#    :include_dirs=>[]
#}
    p "======>#{s}"
    $g_search_dirs=["."]
    fname = "./"
    search_dirs = [File.dirname(__FILE__)]
    search_dirs.insert(0, File.dirname(fname))
    $g_search_dirs.insert(0, File.dirname(fname))

    # TODO seems not used
    $g_options = {
        :include_dirs=>search_dirs
    }
 
    scanner = CScanner.new(s, false)
    error = MyError.new("whaterver", scanner)
    parser = Preprocessor.new(scanner, error)
    # parser.Get
    p "preprocess content:#{scanner.buffer}"
    content = parser.Preprocess(true)
    p "====== result ======"
    p content
    p "====== content end ======"
    
    p "Preprocessor current line #{scanner.currLine}/#{scanner.currSym.line}"
    
    parser.show_macros
    
    error.PrintListing
end
test()
