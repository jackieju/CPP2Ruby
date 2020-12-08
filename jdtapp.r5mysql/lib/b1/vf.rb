def VF_EnableTaxInv(env)
   return (env.IsCurrentLocalSettingsRUSSIA_SETTINGS||env.IsCurrentLocalSettingsUKRAINE_SETTINGS)&&env.IsLocalSettingsFlag(lsf_EnableTaxInvoice)
end

def VF_EnableInOutVATReports(env)
   return env.IsCurrentLocalSettings(HUNGARY_SETTINGS)||env.IsCurrentLocalSettings(POLAND_SETTINGS)
end

def VF_EnableTAXReportEnh(env)
   return env.IsCurrentLocalSettings(CZECH_SETTINGS)||env.IsCurrentLocalSettings(SLOVAKIA_SETTINGS)
end

def VF_EnableReportsERTable(env)
   return env.IsCurrentLocalSettings(HUNGARY_SETTINGS)
end

def VF_EnableIgnoreAdjustmentSetting(env)
   return (env.IsCurrentLocalSettingsPOLAND_SETTINGS||env.IsCurrentLocalSettingsHUNGARY_SETTINGS)
end

def VF_EnableCorrInv(env)
   return env.IsLocalSettingsFlag(lsf_EnableCorrectionINV)
end

def VF_EnableCorrInv_RoundVatPerGrid(env)
   return (env.IsCurrentLocalSettingsCZECH_SETTINGS||env.IsCurrentLocalSettingsSLOVAKIA_SETTINGS)&&VF_EnableCorrInv(env)
end

def VF_EnableDocumentTypeInReports(env)
   return VF_EnableCorrInv(env)
end

def VF_EnableCorrInv_VendCorrDocNo(env)
   return VF_EnableCorrInv(env)
end

def VF_BanksEnh(env)
   return env.IsCurrentLocalSettings(RUSSIA_SETTINGS)||env.IsCurrentLocalSettings(UKRAINE_SETTINGS)
end

def VF_EnblPaymentMthdOnInvoice(env)
   return env.EnblPaymentMthdOnInvoice()
end

def VF_Enbl_P7_IAR(env)
   return env.IsCurrentLocalSettings(BRAZIL_SETTINGS)
end

def VF_InventoryDifferencesReport(env)
   return (env.IsCurrentLocalSettingsSLOVAKIA_SETTINGS||env.IsCurrentLocalSettingsCZECH_SETTINGS)
end

def VF_EnblGeneralLedgerReportEnhancement(env)
   return env.IsCurrentLocalSettings(POLAND_SETTINGS)
end

def VF_PeriodLocking(env)
   return env.IsCurrentLocalSettings(POLAND_SETTINGS)
end

def VF_IFRS_FinReportTemplates(env)
   return !(env.IsCurrentLocalSettingsCHINA_SETTINGS||env.IsCurrentLocalSettingsJAPAN_SETTINGS||env.IsCurrentLocalSettingsKOREA_SETTINGS||env.IsCurrentLocalSettingsSINGAPORE_SETTINGS||env.IsCurrentLocalSettingsINDIA_SETTINGS)
end

def VF_CompanyDetails_TaxatMth_CEO_CA(env)
   return env.IsCurrentLocalSettings(RUSSIA_SETTINGS)||env.IsCurrentLocalSettings(UKRAINE_SETTINGS)
end

def VF_SimplifiedDownPayments(env)
   return (env.IsCurrentLocalSettingsRUSSIA_SETTINGS||env.IsCurrentLocalSettingsUKRAINE_SETTINGS)&&env.IsLocalSettingsFlag(lsf_EnableDPM)
end

def VF_DownPaymentRequestReconciliation(env)
   return true
end

def VF_PaymentOfOrder(env)
   return env.IsLocalSettingsFlag(lsf_EnableDPM)
end

def VF_DownPaymentGrossOnHeader(env)
   return (env.IsCurrentLocalSettingsRUSSIA_SETTINGS||env.IsCurrentLocalSettingsUKRAINE_SETTINGS)&&env.IsLocalSettingsFlag(lsf_EnableDPM)
end

def VF_DownPaymentLinkedGrossEditable(env)
   return !env.IsCurrentLocalSettings(INDIA_SETTINGS)&&env.IsLocalSettingsFlag(lsf_EnableDPM)
end

def VF_DownPaymentLinkedTaxProportionalCalculation(env)
   return env.IsCurrentLocalSettings(INDIA_SETTINGS)&&env.IsLocalSettingsFlag(lsf_EnableDPM)
end

def VF_MakeVtgEUcolEditable(env)
   return (env.IsCurrentLocalSettingsCZECH_SETTINGS||env.IsCurrentLocalSettingsHUNGARY_SETTINGS||env.IsCurrentLocalSettingsPOLAND_SETTINGS||env.IsCurrentLocalSettingsSLOVAKIA_SETTINGS)&&env.IsLocalSettingsFlag(lsf_IsEC)
end

def VF_AcquisitionReverseVTGsInManualJEs(env)
   return (env.IsCurrentLocalSettingsCZECH_SETTINGS||env.IsCurrentLocalSettingsHUNGARY_SETTINGS||env.IsCurrentLocalSettingsPOLAND_SETTINGS||env.IsCurrentLocalSettingsSLOVAKIA_SETTINGS)&&env.IsLocalSettingsFlag(lsf_IsEC)
end

def VF_VatAnalyticalReport(env)
   return env.IsCurrentLocalSettings(HUNGARY_SETTINGS)||env.IsCurrentLocalSettings(SLOVAKIA_SETTINGS)
end

def VF_VatAnalyticalReport_AdditExchRateTable(env)
   return env.IsCurrentLocalSettings(HUNGARY_SETTINGS)&&VF_VatAnalyticalReport(env)&&VF_EnableReportsERTable(env)
end

def VF_SalesAndPurchaseLedgerReports(env)
   return env.IsCurrentLocalSettings(RUSSIA_SETTINGS)||env.IsCurrentLocalSettings(UKRAINE_SETTINGS)
end

def VF_RoundingOn_AR_MarketingDocuments(env)
   return env.IsCurrentLocalSettings(RUSSIA_SETTINGS)||env.IsCurrentLocalSettings(UKRAINE_SETTINGS)
end

def VF_TaxReportSaving(env)
   return env.IsCurrentLocalSettings(GERMANY_SETTINGS)||env.IsCurrentLocalSettings(UK_SETTINGS)||env.IsCurrentLocalSettings(BELGIAN_SETTINGS)
end

def VF_TaxReportSaving_EnabledInOADM(env)
   return VF_TaxReportSaving(env)&&env.OADMGetColStr(OADM_USE_EXT_REPORTING)==SBOString(VAL_YES)
end

def VF_TaxReportSaving_AdjustedIsDisabled(env)
   return env.IsCurrentLocalSettings(UK_SETTINGS)||env.IsCurrentLocalSettings(NETHERLANDS_SETTINGS)||env.IsCurrentLocalSettings(BELGIAN_SETTINGS)
end

def VF_TaxReportSaving_LiabilityAndClaimIsDisabled(env)
   return env.IsCurrentLocalSettings(NETHERLANDS_SETTINGS)||env.IsCurrentLocalSettings(BELGIAN_SETTINGS)
end

def VF_TaxReportSaving_InterimIsEnabled(env)
   return env.IsCurrentLocalSettings(PORTUGAL_SETTINGS)&&env.OADMGetColStr(OADM_USE_EXT_REPORTING)==SBOString(VAL_YES)
end

def VF_TRS_OpenBalAndNonVatIsEnabled(env)
   return (VF_TaxReportSaving_EnabledInOADMenv||VF_Model340_EnabledInOADMenv||VF_BASReporting_EnabledInOADMenv)
end

def VF_Model340(env)
   return env.IsCurrentLocalSettings(SPAIN_SETTINGS)
end

def VF_Model340_EnabledInOADM(env)
   return VF_Model340(env)&&env.OADMGetColStr(OADM_USE_EXT_REPORTING)==SBOString(VAL_YES)
end

def VF_Model340_EnabledInOADM_2014(env)
   return (VF_Model340_EnabledInOADMenv&&true)
end

def VF_DownPayment_Enh(env)
   return ((env.IsCurrentLocalSettingsHUNGARY_SETTINGS||env.IsCurrentLocalSettingsCZECH_SETTINGS||env.IsCurrentLocalSettingsSLOVAKIA_SETTINGS)&&env.IsLocalSettingsFlaglsf_EnableDPM)
end

def VF_DownPayment_Enh_PL(env)
   return (env.IsCurrentLocalSettingsPOLAND_SETTINGS&&env.IsLocalSettingsFlaglsf_EnableDPM)
end

def VF_DownPaymentRequest_Enh(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return (((countryCode.CompareNoCaseCHINA_SETTINGS==0)||(countryCode.CompareNoCaseJAPAN_SETTINGS==0)||(countryCode.CompareNoCaseKOREA_SETTINGS==0)||false)&&env.IsLocalSettingsFlaglsf_EnableDPM)
end

def VF_DownPayment_Enh_CreditMemo(env)
   return (env.IsLocalSettingsFlaglsf_EnableDPM&&!env.IsCurrentLocalSettingsISRAEL_SETTINGS)
end

def VF_TaxOnIncomingPayment_Enh(env)
   return env.IsCurrentLocalSettings(RUSSIA_SETTINGS)||env.IsCurrentLocalSettings(UKRAINE_SETTINGS)
end

def VF_InvoiceLayoutEnhancement(env)
   return env.IsCurrentLocalSettings(RUSSIA_SETTINGS)||env.IsCurrentLocalSettings(UKRAINE_SETTINGS)
end

def VF_TrialBalEnhPer(env)
   return (env.IsCurrentLocalSettingsPOLAND_SETTINGS||env.IsCurrentLocalSettingsSLOVAKIA_SETTINGS||env.IsCurrentLocalSettingsPORTUGAL_SETTINGS||env.IsCurrentLocalSettingsTURKEY_SETTINGS)
end

def VF_TrialBalEnhPerSplitOCB(env)
   return (env.IsCurrentLocalSettingsPOLAND_SETTINGS||env.IsCurrentLocalSettingsPORTUGAL_SETTINGS||env.IsCurrentLocalSettingsTURKEY_SETTINGS)
end

def VF_TrailBalanceEnhAccumOBAndCB(env)
   return (env.IsCurrentLocalSettingsAUSTRIA_SETTINGS||env.IsCurrentLocalSettingsBELGIAN_SETTINGS||env.IsCurrentLocalSettingsCYPRUS_SETTINGS||env.IsCurrentLocalSettingsCZECH_SETTINGS||env.IsCurrentLocalSettingsDENMARK_SETTINGS||env.IsCurrentLocalSettingsFINLAND_SETTINGS||env.IsCurrentLocalSettingsFRANCE_SETTINGS||env.IsCurrentLocalSettingsGERMANY_SETTINGS||env.IsCurrentLocalSettingsGREECE_SETTINGS||env.IsCurrentLocalSettingsHUNGARY_SETTINGS||env.IsCurrentLocalSettingsITALY_SETTINGS||env.IsCurrentLocalSettingsNETHERLANDS_SETTINGS||env.IsCurrentLocalSettingsPOLAND_SETTINGS||env.IsCurrentLocalSettingsPORTUGAL_SETTINGS||env.IsCurrentLocalSettingsSLOVAKIA_SETTINGS||env.IsCurrentLocalSettingsSPAIN_SETTINGS||env.IsCurrentLocalSettingsSWEDEN_SETTINGS||env.IsCurrentLocalSettingsUK_SETTINGS)
end

def VF_InclCBInPLOB(env)
   return (env.IsCurrentLocalSettingsCZECH_SETTINGS||env.IsCurrentLocalSettingsSLOVAKIA_SETTINGS||env.IsCurrentLocalSettingsHUNGARY_SETTINGS||env.IsCurrentLocalSettingsCHILE_SETTINGS||env.IsCurrentLocalSettingsARGENTINA_SETTINGS||env.IsCurrentLocalSettingsITALY_SETTINGS||env.IsCurrentLocalSettingsSPAIN_SETTINGS||env.IsCurrentLocalSettingsCOSTA_RICA_SETTINGS||env.IsCurrentLocalSettingsGUATEMALA_SETTINGS||env.IsCurrentLocalSettingsAUSTRIA_SETTINGS||env.IsCurrentLocalSettingsBELGIAN_SETTINGS)
end

def VF_BOEAsInSpain(env)
   return (env.IsCurrentLocalSettingsSPAIN_SETTINGS||env.IsCurrentLocalSettingsCHILE_SETTINGS||env.IsCurrentLocalSettingsARGENTINA_SETTINGS)
end

def VF_BOEAsInFrance(env)
   return (env.IsCurrentLocalSettingsFRANCE_SETTINGS||env.IsCurrentLocalSettingsBELGIAN_SETTINGS)
end

def VF_BalHideTotals(env)
   return (env.IsCurrentLocalSettingsCZECH_SETTINGS||env.IsCurrentLocalSettingsSLOVAKIA_SETTINGS)
end

def VF_BalHideTotalsAlways(env)
   return env.IsCurrentLocalSettings(POLAND_SETTINGS)
end

def VF_PaymentNoVATPost(env)
   return (env.IsCurrentLocalSettingsCZECH_SETTINGS||env.IsCurrentLocalSettingsHUNGARY_SETTINGS||env.IsCurrentLocalSettingsSLOVAKIA_SETTINGS)
end

def VF_EnableMeasurementUnit(env)
   return true
end

def VF_DeliveryAndInv(env)
   return env.IsDeliveryAndInvoice()&&env.IsContInventory()
end

def VF_DeliveryAndInvWithoutVATinRA(env)
   return env.IsDeliveryAndInvoice()&&!env.IsCurrentLocalSettings(RUSSIA_SETTINGS)&&!env.IsCurrentLocalSettings(UKRAINE_SETTINGS)&&env.IsContInventory()
end

def VF_ECSalesAquisitionList(env)
   return (env.IsCurrentLocalSettingsPOLAND_SETTINGS||env.IsCurrentLocalSettingsHUNGARY_SETTINGS)
end

def VF_ECSalesListVATDate(env)
   return (env.IsCurrentLocalSettingsSLOVAKIA_SETTINGS||env.IsCurrentLocalSettingsCZECH_SETTINGS)
end

def VF_RoundTaxToTenths(env)
   return env.IsCurrentLocalSettings(SLOVAKIA_SETTINGS)&&env.GetMainCurrency()!=_T("EUR")
end

def VF_RoundTaxToTenths_SK(env)
   return env.IsCurrentLocalSettings(SLOVAKIA_SETTINGS)&&env.GetMainCurrencyISOCode()==_T("SKK")
end

def VF_EndclosingOpeningAndClosingAcct(env)
   return env.IsLocalSettingsFlag(lsf_EnableCardClosingPeriod)&&(env.IsCurrentLocalSettingsSLOVAKIA_SETTINGS||env.IsCurrentLocalSettingsCZECH_SETTINGS||env.IsCurrentLocalSettingsHUNGARY_SETTINGS)
end

def VF_EnableVATDate(env)
   return env.EnblVATDate()
end

def VF_EnableVATDateSpecific(env)
   return (env.IsCurrentLocalSettingsSLOVAKIA_SETTINGS||env.IsCurrentLocalSettingsCZECH_SETTINGS||env.IsCurrentLocalSettingsPOLAND_SETTINGS)
end

def VF_EnableVATDateSpecific_2(env)
   return (env.IsCurrentLocalSettingsSLOVAKIA_SETTINGS||env.IsCurrentLocalSettingsCZECH_SETTINGS||env.IsCurrentLocalSettingsPOLAND_SETTINGS||env.IsCurrentLocalSettingsHUNGARY_SETTINGS)
end

def VF_VATGroupDetails(env)
   return (env.IsCurrentLocalSettingsSLOVAKIA_SETTINGS||env.IsCurrentLocalSettingsCZECH_SETTINGS)
end

def VF_EnableTranJrnlBalances(env)
   return env.IsCurrentLocalSettings(POLAND_SETTINGS)
end

def VF_EnableTranJrnlCurrentUser(env)
   return env.IsCurrentLocalSettings(POLAND_SETTINGS)
end

def VF_EnableIOCashLayouts(env)
   return (env.IsCurrentLocalSettingsRUSSIA_SETTINGS||env.IsCurrentLocalSettingsUKRAINE_SETTINGS)
end

def VF_CashReportAccounts(env)
   return env.IsCurrentLocalSettings(SLOVAKIA_SETTINGS)||env.IsCurrentLocalSettings(CZECH_SETTINGS)||env.IsCurrentLocalSettings(POLAND_SETTINGS)||env.IsCurrentLocalSettings(HUNGARY_SETTINGS)||env.IsCurrentLocalSettings(UKRAINE_SETTINGS)||env.IsCurrentLocalSettings(RUSSIA_SETTINGS)
end

def VF_ERDiffFullPayment(env)
   return env.IsCurrentLocalSettings(RUSSIA_SETTINGS)||env.IsCurrentLocalSettings(UKRAINE_SETTINGS)
end

def VF_EnableAPTaxInLC(env)
   return env.IsCurrentLocalSettings(CZECH_SETTINGS)||env.IsCurrentLocalSettings(SLOVAKIA_SETTINGS)
end

def VF_DisableRoundingChanges(env)
   return env.IsCurrentLocalSettings(CZECH_SETTINGS)||env.IsCurrentLocalSettings(HUNGARY_SETTINGS)||env.IsCurrentLocalSettings(POLAND_SETTINGS)||env.IsCurrentLocalSettings(SLOVAKIA_SETTINGS)
end

def VF_CCDInvoiceEnh(env)
   return env.IsCurrentLocalSettings(RUSSIA_SETTINGS)||env.IsCurrentLocalSettings(UKRAINE_SETTINGS)
end

def VF_CCDTrackingNote(env)
   return env.IsCurrentLocalSettings(RUSSIA_SETTINGS)||env.IsCurrentLocalSettings(UKRAINE_SETTINGS)
end

def VF_CCDEngine(env)
   return env.IsCurrentLocalSettings(RUSSIA_SETTINGS)||env.IsCurrentLocalSettings(UKRAINE_SETTINGS)
end

def VF_InvoiceEnhancement(env)
   return (env.IsCurrentLocalSettingsHUNGARY_SETTINGS)
end

def VF_StockTransferPrintLayout_RU_UA(env)
   return env.IsCurrentLocalSettings(RUSSIA_SETTINGS)||env.IsCurrentLocalSettings(UKRAINE_SETTINGS)
end

def VF_InventoryTrackingPrintLayout_RU_UA(env)
   return env.IsCurrentLocalSettings(RUSSIA_SETTINGS)||env.IsCurrentLocalSettings(UKRAINE_SETTINGS)
end

def VF_EnableDeliveryPrintlayout_RU_UA(env)
   return env.IsCurrentLocalSettings(RUSSIA_SETTINGS)||env.IsCurrentLocalSettings(UKRAINE_SETTINGS)
end

def VF_EnableRealAmountInPayment(env)
   return env.IsCurrentLocalSettings(HUNGARY_SETTINGS)
end

def VF_EnableBruttoCorrColsInGLB(env)
   return env.IsCurrentLocalSettings(CZECH_SETTINGS)||env.IsCurrentLocalSettings(SLOVAKIA_SETTINGS)
end

def VF_EnableCorrAct(env)
   return env.IsCurrentLocalSettings(RUSSIA_SETTINGS)||env.IsCurrentLocalSettings(UKRAINE_SETTINGS)
end

def VF_EnableCorrActInInventoryJournalObject(env)
   return VF_EnableCorrAct(env)
end

def VF_EnableCEEPrintLayouts(env)
   return (env.IsCurrentLocalSettingsHUNGARY_SETTINGS||env.IsCurrentLocalSettingsCZECH_SETTINGS||env.IsCurrentLocalSettingsPOLAND_SETTINGS||env.IsCurrentLocalSettingsUKRAINE_SETTINGS||env.IsCurrentLocalSettingsRUSSIA_SETTINGS||env.IsCurrentLocalSettingsSLOVAKIA_SETTINGS)
end

def VF_EnableCEEPrintLayouts_ZeroVatForPL(env)
   return (env.IsCurrentLocalSettingsPOLAND_SETTINGS)
end

def VF_EnableCEEPrintLayouts_PrintVatInLC(env)
   return (env.IsCurrentLocalSettingsPOLAND_SETTINGS)
end

def VF_CopyNumbering(env)
   return (env.IsCurrentLocalSettingsHUNGARY_SETTINGS)
end

def VF_IncPaymentListAdjustment(env)
   return (env.IsCurrentLocalSettingsHUNGARY_SETTINGS||env.IsCurrentLocalSettingsCZECH_SETTINGS||env.IsCurrentLocalSettingsPOLAND_SETTINGS||env.IsCurrentLocalSettingsUKRAINE_SETTINGS||env.IsCurrentLocalSettingsRUSSIA_SETTINGS||env.IsCurrentLocalSettingsSLOVAKIA_SETTINGS)
end

def VF_EnableControlAccountReposting(env)
   return (env.IsCurrentLocalSettingsHUNGARY_SETTINGS||env.IsCurrentLocalSettingsCZECH_SETTINGS||env.IsCurrentLocalSettingsPOLAND_SETTINGS||env.IsCurrentLocalSettingsUKRAINE_SETTINGS||env.IsCurrentLocalSettingsRUSSIA_SETTINGS||env.IsCurrentLocalSettingsSLOVAKIA_SETTINGS)
end

def VF_EnableCEECorrectionInvoiceReportTypes(env)
   return (env.IsCurrentLocalSettingsPORTUGAL_SETTINGS||env.IsCurrentLocalSettingsUKRAINE_SETTINGS||env.IsCurrentLocalSettingsRUSSIA_SETTINGS||env.IsCurrentLocalSettingsCZECH_SETTINGS||env.IsCurrentLocalSettingsSLOVAKIA_SETTINGS||env.IsCurrentLocalSettingsHUNGARY_SETTINGS||env.IsCurrentLocalSettingsGREECE_SETTINGS)
end

def EVF_EnableCEECorrectionInvoiceReportTypes(env,objId)
   return (VF_EnableCEECorrectionInvoiceReportTypesenv&&(objId==CSI||objId==CSV||objId==CPI||objId==CPV))
end

def VF_EnableCEEOldCorrectionInvoiceReportTypes(env)
   return (env.IsCurrentLocalSettingsPOLAND_SETTINGS)
end

def VF_AmountDifferences(env)
   return (env.IsCurrentLocalSettingsRUSSIA_SETTINGS||env.IsCurrentLocalSettingsUKRAINE_SETTINGS)
end

def VF_CheckDecimalPlacesSettings(env)
   return true
end

def VF_ERDPostingPerDoc(env)
   return (env.IsLocalSettingsFlaglsf_EnableFrgnCurrValuation)
end

def VF_EnableCeePermissionUpgrade(env)
   return env.IsCurrentLocalSettings(CZECH_SETTINGS)||env.IsCurrentLocalSettings(HUNGARY_SETTINGS)||env.IsCurrentLocalSettings(POLAND_SETTINGS)||env.IsCurrentLocalSettings(UKRAINE_SETTINGS)||env.IsCurrentLocalSettings(RUSSIA_SETTINGS)||env.IsCurrentLocalSettings(SLOVAKIA_SETTINGS)
end

def VF_StockAgeingReport(env)
   return env.IsCurrentLocalSettings(CZECH_SETTINGS)||env.IsCurrentLocalSettings(HUNGARY_SETTINGS)||env.IsCurrentLocalSettings(POLAND_SETTINGS)||env.IsCurrentLocalSettings(UKRAINE_SETTINGS)||env.IsCurrentLocalSettings(RUSSIA_SETTINGS)||env.IsCurrentLocalSettings(SLOVAKIA_SETTINGS)
end

def VF_SerialsAndBatchesPrinting(env)
   return true
end

def VF_BPconnection(env)
   return (env.IsCurrentLocalSettingsPOLAND_SETTINGS||env.IsCurrentLocalSettingsUKRAINE_SETTINGS||env.IsCurrentLocalSettingsRUSSIA_SETTINGS||env.IsCurrentLocalSettingsHUNGARY_SETTINGS||env.IsCurrentLocalSettingsCZECH_SETTINGS)
end

def VF_DpmInvoiceWithNoTax(env)
   return (env.IsLocalSettingsFlaglsf_EnableDPM&&(env.IsCurrentLocalSettingsUSA_SETTINGS||env.IsCurrentLocalSettingsCANADA_SETTINGS||env.IsCurrentLocalSettingsBRAZIL_SETTINGS))
end

def VF_CostAccounting(env)
   return true
end

def VF_ShowReconciliationEnh(env)
   return (env.IsCurrentLocalSettingsUKRAINE_SETTINGS||env.IsCurrentLocalSettingsRUSSIA_SETTINGS||env.IsCurrentLocalSettingsCZECH_SETTINGS||env.IsCurrentLocalSettingsSLOVAKIA_SETTINGS||env.IsCurrentLocalSettingsHUNGARY_SETTINGS||env.IsCurrentLocalSettingsGREECE_SETTINGS||env.IsCurrentLocalSettingsPOLAND_SETTINGS)
end

def VF_ShowReconciliationEnh_Add(env)
   return false
end

def VF_ManualJEInTaxReport(env)
   return env.IsCurrentLocalSettings(CANADA_SETTINGS)||env.IsCurrentLocalSettings(CHILE_SETTINGS)||env.IsCurrentLocalSettings(ARGENTINA_SETTINGS)||env.IsCurrentLocalSettings(COSTA_RICA_SETTINGS)||env.IsCurrentLocalSettings(GUATEMALA_SETTINGS)||env.IsCurrentLocalSettings(MEXICO_SETTINGS)||env.IsCurrentLocalSettings(USA_SETTINGS)
end

def VF_DpmRequestLinking(env)
   return (env.IsLocalSettingsFlaglsf_EnableDPM&&(env.IsCurrentLocalSettingsCZECH_SETTINGS||env.IsCurrentLocalSettingsSLOVAKIA_SETTINGS))
end

def VF_RoundTrans_HU(env)
   return (!env.IsCurrencyDecimalsEnabled()&&env.IsCurrentLocalSettingsHUNGARY_SETTINGS)
end

def VF_TaxOnly(env)
   return (!env.IsCurrentLocalSettingsISRAEL_SETTINGS)
end

def VF_ItemClassification(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||(countryCode.CompareNoCaseINDIA_SETTINGS==0)||false)
end

def VF_ItemClassification_BR(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||false)
end

def VF_ItemClassification_IN(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseINDIA_SETTINGS==0)||false)
end

def VF_FiscalIDs(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||(countryCode.CompareNoCaseINDIA_SETTINGS==0)||false)
end

def VF_FiscalIDs_BR(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||false)
end

def VF_FiscalIDs_IN(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseINDIA_SETTINGS==0)||false)
end

def VF_CashflowReport_APA(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseCHINA_SETTINGS==0)||(countryCode.CompareNoCaseJAPAN_SETTINGS==0)||(countryCode.CompareNoCaseKOREA_SETTINGS==0)||false)
end

def VF_CashflowReport(env)
   return true
end

def VF_IRULegacyMultiBP(env)
   return (env.IsCurrentLocalSettingsCZECH_SETTINGS||env.IsCurrentLocalSettingsSLOVAKIA_SETTINGS||env.IsCurrentLocalSettingsHUNGARY_SETTINGS||env.IsCurrentLocalSettingsUKRAINE_SETTINGS||env.IsCurrentLocalSettingsRUSSIA_SETTINGS||env.IsCurrentLocalSettingsPOLAND_SETTINGS)
end

def VF_CustRecvEnh(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseCHINA_SETTINGS==0)||(countryCode.CompareNoCaseJAPAN_SETTINGS==0)||(countryCode.CompareNoCaseKOREA_SETTINGS==0)||(countryCode.CompareNoCaseSINGAPORE_SETTINGS==0)||(countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||(countryCode.CompareNoCaseINDIA_SETTINGS==0)||false)
end

def VF_NotaFiscal(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||false)
end

def VF_Numbering(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseINDIA_SETTINGS==0)||false)
end

def VF_JEPrinting(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseCHINA_SETTINGS==0)||false)
end

def VF_JEPrinting_CN(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseCHINA_SETTINGS==0)||false)
end

def VF_FIReleaseProc(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseCHINA_SETTINGS==0)||(countryCode.CompareNoCaseJAPAN_SETTINGS==0)||(countryCode.CompareNoCaseKOREA_SETTINGS==0)||false)
end

def VF_BankCharge(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseISRAEL_SETTINGS!=0)||false)
end

def VF_BankCharge_Tax(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseJAPAN_SETTINGS==0)||false)
end

def VF_GSTInvoice(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseSINGAPORE_SETTINGS==0)||false)
end

def VF_KRLocalVAT(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseKOREA_SETTINGS==0)||false)
end

def VF_MultiBranch(env)
   return true
end

def VF_MultiBranch_EnabledInOADM(env)
   return VF_MultiBranch(env)&&env.OADMGetColStr(OADM_MULTIPLE_BRANCHES)==SBOString(VAL_YES)
end

def VF_MultiBranchFiltering(env)
   return VF_MultiBranch_EnabledInOADM(env)&&(env.GetCompany().GetDagCINFenv.GetColStr(env,CINF_ENABLE_MB_FILTERING,0)==VAL_YES)
end

def VF_TaxFirstByGrossTotal(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseCHINA_SETTINGS==0)||(countryCode.CompareNoCaseJAPAN_SETTINGS==0)||(countryCode.CompareNoCaseKOREA_SETTINGS==0)||false)
end

def VF_TaxRoundRule(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseJAPAN_SETTINGS==0)||(countryCode.CompareNoCaseKOREA_SETTINGS==0)||false)
end

def VF_WTaxRoundRule(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseJAPAN_SETTINGS==0)||(countryCode.CompareNoCaseKOREA_SETTINGS==0)||false)
end

def VF_TaxRoundingData(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseJAPAN_SETTINGS==0)||(countryCode.CompareNoCaseKOREA_SETTINGS==0)||(countryCode.CompareNoCaseCHINA_SETTINGS==0)||(countryCode.CompareNoCaseINDIA_SETTINGS==0)||(countryCode.CompareNoCaseBRAZIL_SETTINGS==0))
end

def VF_RoundTaxOnRow(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseJAPAN_SETTINGS==0)||(countryCode.CompareNoCaseCHINA_SETTINGS==0)||(countryCode.CompareNoCaseINDIA_SETTINGS==0)||(countryCode.CompareNoCaseBRAZIL_SETTINGS==0))
end

def VF_RoundingStrategy_JP(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return (countryCode.CompareNoCaseJAPAN_SETTINGS==0)
end

def VF_RoundingStrategy_KR(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return (countryCode.CompareNoCaseKOREA_SETTINGS==0)
end

def VF_RoundingStrategy_PosUpNegDown(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return (countryCode.CompareNoCaseCHINA_SETTINGS==0)||(countryCode.CompareNoCaseINDIA_SETTINGS==0)||(countryCode.CompareNoCaseBRAZIL_SETTINGS==0)
end

def VF_NoAcquisitionTax(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseJAPAN_SETTINGS==0)||(countryCode.CompareNoCaseKOREA_SETTINGS==0)||false)
end

def VF_TaxCodeDtm(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||(countryCode.CompareNoCaseINDIA_SETTINGS==0)||false)
end

def VF_WTaxCodeDtm(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||false)
end

def VF_TaxCodeByUsg(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||false)
end

def VF_MIExpTaxCodeDtm(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||false)
end

def VF_SIExpTaxCodeDtm(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return false
end

def VF_SDExpTaxCodeDtm(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return false
end

def VF_ExposeTaxInfoInPLD(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||(countryCode.CompareNoCaseINDIA_SETTINGS==0)||false)
end

def VF_UnitAct4TaxType(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseINDIA_SETTINGS==0)||false)
end

def VF_PatFldChk(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseJAPAN_SETTINGS==0)||(countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||(countryCode.CompareNoCaseINDIA_SETTINGS==0)||false)
end

def VF_IntPrdEndPosting(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseCHINA_SETTINGS==0)||countryCode.CompareNoCaseKOREA_SETTINGS==0||false)
end

def VF_GLRpt(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseCHINA_SETTINGS==0)||false)
end

def VF_SubGLRpt(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseCHINA_SETTINGS==0)||false)
end

def VF_LnWTax(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||false)
end

def VF_APResvInvoice(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return !(countryCode.CompareNoCaseINDIA_SETTINGS==0)
end

def VF_TaxPayment(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseINDIA_SETTINGS==0)||false)
end

def VF_EmpNameChange(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   if countryCode.IsEmpty()
      countryCode=env.GetCompany().GetDagCINF(env).GetColStr(env,CINF_LAWS_SET,0)
   end

   return ((countryCode.CompareNoCaseCHINA_SETTINGS==0)||(countryCode.CompareNoCaseJAPAN_SETTINGS==0)||(countryCode.CompareNoCaseKOREA_SETTINGS==0)||false)
end

def VF_AddrTypeStrtNo(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||false)
end

def VF_CountyByList(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||false)
end

def VF_CNPeriodEnd(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseCHINA_SETTINGS==0)||false)
end

def VF_LocalEra(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseJAPAN_SETTINGS==0)||false)
end

def VF_AddrSplit(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||false)
end

def VF_AddrSeq(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseCHINA_SETTINGS==0)||(countryCode.CompareNoCaseJAPAN_SETTINGS==0)||(countryCode.CompareNoCaseKOREA_SETTINGS==0)||(countryCode.CompareNoCaseSINGAPORE_SETTINGS==0)||(countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||(countryCode.CompareNoCaseINDIA_SETTINGS==0)||false)
end

def VF_GrossPrice_ClearDiscount(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseCHINA_SETTINGS==0)||(countryCode.CompareNoCaseJAPAN_SETTINGS==0)||(countryCode.CompareNoCaseKOREA_SETTINGS==0))
end

def VF_GrossPriceList(env)
   return (VF_GrossPrice_ClearDiscountenv||(!env.IsCurrentLocalSettingsBRAZIL_SETTINGS&&!env.IsCurrentLocalSettingsINDIA_SETTINGS))
end

def VF_SupportGrossPriceMode(env)
   if VF_GrossPriceList(env)&&!env.IsCurrentLocalSettings(ISRAEL_SETTINGS)
      return true
   end

   return false
end

def VF_CashDiscountGross(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseCHINA_SETTINGS==0)||false)
end

def VF_CashDiscountNet(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseKOREA_SETTINGS==0)||false)
end

def VF_CashDiscountVAT(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseJAPAN_SETTINGS==0)||(countryCode.CompareNoCaseSINGAPORE_SETTINGS==0)||false)
end

def VF_InvSummary(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseJAPAN_SETTINGS==0)||false)
end

def VF_CopyTaxAmount(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseJAPAN_SETTINGS==0)||(countryCode.CompareNoCaseKOREA_SETTINGS==0)||(countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||(countryCode.CompareNoCaseINDIA_SETTINGS==0)||false)
end

def VF_ExciseInvoice(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseINDIA_SETTINGS==0)||false)
end

def VF_GST(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseINDIA_SETTINGS==0)||false)
end

def VF_DeflChqTransAcct(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseCHINA_SETTINGS==0)||(countryCode.CompareNoCaseJAPAN_SETTINGS==0)||(countryCode.CompareNoCaseKOREA_SETTINGS==0)||(countryCode.CompareNoCaseSINGAPORE_SETTINGS==0)||(countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||(countryCode.CompareNoCaseINDIA_SETTINGS==0)||false)
end

def VF_InvAudRptEnh(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseCHINA_SETTINGS==0)||false)
end

def VF_StockPostingRptEnh(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseCHINA_SETTINGS==0)||(countryCode.CompareNoCaseJAPAN_SETTINGS==0)||(countryCode.CompareNoCaseKOREA_SETTINGS==0)||(countryCode.CompareNoCaseSINGAPORE_SETTINGS==0)||(countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||(countryCode.CompareNoCaseINDIA_SETTINGS==0)||false)
end

def VF_GBInterface(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseCHINA_SETTINGS==0)||false)
end

def VF_BldAddr(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseCHINA_SETTINGS==0)||(countryCode.CompareNoCaseJAPAN_SETTINGS==0)||(countryCode.CompareNoCaseKOREA_SETTINGS==0)||(countryCode.CompareNoCaseSINGAPORE_SETTINGS==0)||(countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||(countryCode.CompareNoCaseINDIA_SETTINGS==0)||false)
end

def VF_JETaxEnh(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseINDIA_SETTINGS==0)||false)
end

def VF_INLnDistribExp(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseINDIA_SETTINGS==0)||false)
end

def VF_PurchaseAcct(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseINDIA_SETTINGS==0)||false)
end

def VF_APAFIRptTpt(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseCHINA_SETTINGS==0)||(countryCode.CompareNoCaseJAPAN_SETTINGS==0)||(countryCode.CompareNoCaseKOREA_SETTINGS==0)||(countryCode.CompareNoCaseSINGAPORE_SETTINGS==0)||(countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||(countryCode.CompareNoCaseINDIA_SETTINGS==0)||false)
end

def VF_APAFIRpt(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseCHINA_SETTINGS==0)||(countryCode.CompareNoCaseJAPAN_SETTINGS==0)||(countryCode.CompareNoCaseKOREA_SETTINGS==0)||(countryCode.CompareNoCaseSINGAPORE_SETTINGS==0)||(countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||(countryCode.CompareNoCaseINDIA_SETTINGS==0)||false)
end

def VF_Level4FRTLocs(env)
   return env.IsCurrentLocalSettings(USA_SETTINGS)||env.IsCurrentLocalSettings(CANADA_SETTINGS)||env.IsCurrentLocalSettings(SWEDEN_SETTINGS)
end

def VF_CostAcctingEnh(env)
   return env.IsUseMultiDimension()
end

def VF_IFRS(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return (env.IsContInventory()&&(countryCode.CompareNoCaseCHILE_SETTINGS==0||countryCode.CompareNoCaseARGENTINA_SETTINGS==0))
end

def VF_IVSR_BasedOnRecalculation(env)
   return (env.IsContInventory()&&env.IsSimulationReport())
end

def VF_SalesUnitHier(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseCHINA_SETTINGS==0)||(countryCode.CompareNoCaseJAPAN_SETTINGS==0)||(countryCode.CompareNoCaseKOREA_SETTINGS==0)||false)
end

def VF_TransJrnlFilterEnh(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseCHINA_SETTINGS==0)||false)
end

def VF_BoEImprove(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseJAPAN_SETTINGS==0)||false)
end

def VF_CustVendRefNo(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseCHINA_SETTINGS==0)||(countryCode.CompareNoCaseJAPAN_SETTINGS==0)||(countryCode.CompareNoCaseKOREA_SETTINGS==0)||(countryCode.CompareNoCaseSINGAPORE_SETTINGS==0)||(countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||(countryCode.CompareNoCaseINDIA_SETTINGS==0)||false)
end

def VF_ARTaxAdjust(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseCHINA_SETTINGS==0)||(countryCode.CompareNoCaseJAPAN_SETTINGS==0)||(countryCode.CompareNoCaseKOREA_SETTINGS==0)||false)
end

def VF_Boleto(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||false)
end

def VF_AlternativeBOEPostScheme_EnabledInOADM(env)
   return VF_Boleto(env)&&env.OADMGetColStr(OADM_ALTERNATIVE_BOE_POST)==SBOString(VAL_YES)
end

def VF_BankTransFile(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseCHINA_SETTINGS==0)||(countryCode.CompareNoCaseJAPAN_SETTINGS==0)||(countryCode.CompareNoCaseKOREA_SETTINGS==0)||(countryCode.CompareNoCaseSINGAPORE_SETTINGS==0)||false)
end

def VF_ChqAcctList(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseCHINA_SETTINGS==0)||(countryCode.CompareNoCaseJAPAN_SETTINGS==0)||false)
end

def VF_GLEnh(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseCHINA_SETTINGS==0)||(countryCode.CompareNoCaseJAPAN_SETTINGS==0)||(countryCode.CompareNoCaseKOREA_SETTINGS==0)||(countryCode.CompareNoCaseSINGAPORE_SETTINGS==0)||(countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||(countryCode.CompareNoCaseINDIA_SETTINGS==0)||false)
end

def VF_OpenFRBoE(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseCHINA_SETTINGS==0)||(countryCode.CompareNoCaseJAPAN_SETTINGS==0)||(countryCode.CompareNoCaseKOREA_SETTINGS==0)||false)
end

def VF_CurrencyPlural(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||false)
end

def VF_OpenDPContrlAcct(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseCHINA_SETTINGS==0)||(countryCode.CompareNoCaseJAPAN_SETTINGS==0)||(countryCode.CompareNoCaseKOREA_SETTINGS==0)||(countryCode.CompareNoCaseSINGAPORE_SETTINGS==0)||(countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||(countryCode.CompareNoCaseINDIA_SETTINGS==0)||false)
end

def VF_OpenAustraliaRecon(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseCHINA_SETTINGS==0)||(countryCode.CompareNoCaseJAPAN_SETTINGS==0)||(countryCode.CompareNoCaseKOREA_SETTINGS==0)||(countryCode.CompareNoCaseSINGAPORE_SETTINGS==0)||(countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||(countryCode.CompareNoCaseINDIA_SETTINGS==0)||false)
end

def VF_EnableFuturePosting(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseSINGAPORE_SETTINGS==0)||false)
end

def VF_BnkLinkPmt(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseJAPAN_SETTINGS==0)||false)
end

def VF_OpeningBalancePayment(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseJAPAN_SETTINGS==0)||(countryCode.CompareNoCaseKOREA_SETTINGS==0)||false)
end

def VF_EnablePurAcctPosting(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||false)
end

def VF_HideAliasNameItem(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||false)
end

def VF_TaxInPrice(env)
   return env.IsCurrentLocalSettings(BRAZIL_SETTINGS)
end

def VF_TaxInGrossRevenue(env)
   return env.IsCurrentLocalSettings(BRAZIL_SETTINGS)
end

def VF_TaxExempt(env)
   return env.IsCurrentLocalSettings(BRAZIL_SETTINGS)
end

def VF_Unencumbered(env)
   return VF_TaxInPrice(env)
end

def VF_TaxOnReserveInvoice(env)
   return VF_TaxInPrice(env)
end

def VF_NDWithoutAccount(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||(countryCode.CompareNoCaseINDIA_SETTINGS==0))
end

def VF_ShowZeroTaxAmount(env)
   return (VF_TaxInPriceenv||VF_TaxExemptenv||VF_DutyStatusOptenv)
end

def VF_NotaFiscalTaxCat(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||(countryCode.CompareNoCaseINDIA_SETTINGS==0))
end

def VF_HideTaxLiable(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||(countryCode.CompareNoCaseINDIA_SETTINGS==0))
end

def VF_HideTaxReport(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||(countryCode.CompareNoCaseINDIA_SETTINGS==0))
end

def VF_HideBPTaxCode(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||(countryCode.CompareNoCaseINDIA_SETTINGS==0))
end

def VF_BlockInputPriceAfterTax(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||(countryCode.CompareNoCaseINDIA_SETTINGS==0))
end

def VF_CMTaxRecalcInDateChgd(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||(countryCode.CompareNoCaseINDIA_SETTINGS==0))
end

def VF_WeightAffectVat(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||(countryCode.CompareNoCaseINDIA_SETTINGS==0))
end

def VF_Intrastat(env)
   return env.IsLocalSettingsFlag(lsf_IsEC)&&env.IsInstallIntrastat()
end

def VF_IntrastatCustomCurrency(env,country)
   return false
end

def VF_IntrastatServiceCodes(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return (countryCode.CompareNoCaseITALY_SETTINGS==0)
end

def VF_IntrastatFreights(env)
   return VF_Intrastat(env)&&env.IsLocalSettingsFlag(lsf_EnableExpenses)
end

def VF_ExpType(env)
   return env.IsLocalSettingsFlag(lsf_EnableExpenses)&&env.IsCurrentLocalSettings(BRAZIL_SETTINGS)
end

def VF_LnExpTaxCode(env)
   return env.IsVatPerCard()&&env.IsLocalSettingsFlag(lsf_EnableExpenses)&&(env.IsCurrentLocalSettingsBRAZIL_SETTINGS||env.IsCurrentLocalSettingsINDIA_SETTINGS||env.IsCurrentLocalSettingsUSA_SETTINGS||env.IsCurrentLocalSettingsCANADA_SETTINGS)
end

def VF_LnDistribExp(env)
   return env.IsLocalSettingsFlag(lsf_EnableExpenses)&&env.IsCurrentLocalSettings(BRAZIL_SETTINGS)
end

def VF_DateFormatEnh(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseCHINA_SETTINGS==0)||(countryCode.CompareNoCaseJAPAN_SETTINGS==0)||(countryCode.CompareNoCaseKOREA_SETTINGS==0)||(countryCode.CompareNoCaseSINGAPORE_SETTINGS==0)||(countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||(countryCode.CompareNoCaseINDIA_SETTINGS==0)||false)
end

def VF_StockPriceAuth(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseCHINA_SETTINGS==0)||(countryCode.CompareNoCaseJAPAN_SETTINGS==0)||(countryCode.CompareNoCaseKOREA_SETTINGS==0)||(countryCode.CompareNoCaseSINGAPORE_SETTINGS==0)||(countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||(countryCode.CompareNoCaseINDIA_SETTINGS==0)||false)
end

def VF_AddrEnh(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||false)
end

def VF_StateSorting(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseCHINA_SETTINGS==0)||(countryCode.CompareNoCaseJAPAN_SETTINGS==0)||(countryCode.CompareNoCaseKOREA_SETTINGS==0)||false)
end

def VF_UnuseWHAddress(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||false)
end

def VF_FldLabelChgAuth(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||(countryCode.CompareNoCaseCHINA_SETTINGS==0)||(countryCode.CompareNoCaseJAPAN_SETTINGS==0)||(countryCode.CompareNoCaseKOREA_SETTINGS==0)||(countryCode.CompareNoCaseINDIA_SETTINGS==0)||(countryCode.CompareNoCaseSINGAPORE_SETTINGS==0)||false)
end

def VF_ChangeAsmBomWhs(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||(countryCode.CompareNoCaseCHINA_SETTINGS==0)||(countryCode.CompareNoCaseJAPAN_SETTINGS==0)||(countryCode.CompareNoCaseKOREA_SETTINGS==0)||(countryCode.CompareNoCaseINDIA_SETTINGS==0)||(countryCode.CompareNoCaseSINGAPORE_SETTINGS==0)||false)
end

def VF_RmvZeroLineFromJE(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseCHINA_SETTINGS==0)||(countryCode.CompareNoCaseJAPAN_SETTINGS==0)||(countryCode.CompareNoCaseKOREA_SETTINGS==0)||(countryCode.CompareNoCaseINDIA_SETTINGS==0)||(countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||false)
end

def VF_OBPayment(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseJAPAN_SETTINGS==0)||(countryCode.CompareNoCaseKOREA_SETTINGS==0)||false)
end

def VF_RevDrawerLE3(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||false)
end

def VF_NegTaxInRows(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseINDIA_SETTINGS==0)||false)
end

def VF_ProgressiveWTax(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseCHINA_SETTINGS==0)||(countryCode.CompareNoCaseJAPAN_SETTINGS==0)||(countryCode.CompareNoCaseKOREA_SETTINGS==0)||(countryCode.CompareNoCaseSINGAPORE_SETTINGS==0)||false)
end

def VF_IndiaVATRpt(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseINDIA_SETTINGS==0)||false)
end

def VF_WTaxValueRange(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseBRAZIL_SETTINGS==0)||false)
end

def VF_WTaxEngine(env)
   return !env.CINFGetColStr(CINF_LAWS_SET).CompareNoCase(ARGENTINA_SETTINGS)
end

def VF_WTaxAddedToInvoiceTotal(env)
   return env.IsCurrentLocalSettings(ARGENTINA_SETTINGS)
end

def VF_WTaxDisableDirectPayment(env)
   return false
end

def VF_CostAcctingEnh_APA(env)
   return VF_CostAcctingEnh(env)
end

def VF_APAChequeLogic(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseCHINA_SETTINGS==0)||(countryCode.CompareNoCaseJAPAN_SETTINGS==0)||false)
end

def VF_HideAutoVAT(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return (countryCode.CompareNoCaseBRAZIL_SETTINGS==0)
end

def VF_TDS(env)
   return env.IsCurrentLocalSettings(INDIA_SETTINGS)
end

def VF_BanksABARoutingNum(env)
   return (env.IsCurrentLocalSettingsUSA_SETTINGS)
end

def VF_BankIBAN(env)
   return true
end

def VF_WTaxAccumulateControl(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return (countryCode.CompareNoCaseBRAZIL_SETTINGS==0)
end

def VF_WTaxAccumulateControlNew(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return (countryCode.CompareNoCaseBRAZIL_SETTINGS==0)
end

def VF_FutureDelivery(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return (countryCode.CompareNoCaseBRAZIL_SETTINGS==0)
end

def VF_NoWTaxForTaxOnly(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return (countryCode.CompareNoCaseBRAZIL_SETTINGS==0)
end

def VF_TrialBalanceSelectionCriteria(env)
   return true
end

def VF_MultipleRegistrationNumber(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return (countryCode.CompareNoCaseINDIA_SETTINGS==0)
end

def VF_UpgradeCeeVariablesOnMarketingDocLayouts(env)
   return env.IsCurrentLocalSettings(CZECH_SETTINGS)||env.IsCurrentLocalSettings(HUNGARY_SETTINGS)||env.IsCurrentLocalSettings(POLAND_SETTINGS)||env.IsCurrentLocalSettings(SLOVAKIA_SETTINGS)
end

def VF_TreatGrossTotalAsTotalInclTax(env)
   return env.IsCurrentLocalSettings(UKRAINE_SETTINGS)||env.IsCurrentLocalSettings(RUSSIA_SETTINGS)||env.IsCurrentLocalSettings(CZECH_SETTINGS)||env.IsCurrentLocalSettings(SLOVAKIA_SETTINGS)||env.IsCurrentLocalSettings(HUNGARY_SETTINGS)||env.IsCurrentLocalSettings(POLAND_SETTINGS)
end

def VF_FederalTaxIdFreeFormat(env)
   return env.IsCurrentLocalSettings(POLAND_SETTINGS)
end

def VF_EnableOpenDebtsModification(env)
   return false
end

def VF_OpenInterfaceDESS(env)
   return env.IsCurrentLocalSettings(ISRAEL_SETTINGS)
end

def VF_DESSClosingBalanceOptions(env)
   return env.IsCurrentLocalSettings(ISRAEL_SETTINGS)
end

def VF_EnableExemptTaxGroup(env)
   return env.IsCurrentLocalSettings(FRANCE_SETTINGS)||env.IsCurrentLocalSettings(ITALY_SETTINGS)
end

def VF_UseDpInterimAcct(env)
   return (env.IsLocalSettingsFlaglsf_EnableDPM&&!env.IsCurrentLocalSettingsCZECH_SETTINGS&&!env.IsCurrentLocalSettingsSLOVAKIA_SETTINGS&&!env.IsCurrentLocalSettingsHUNGARY_SETTINGS&&!env.IsCurrentLocalSettingsPOLAND_SETTINGS&&!env.IsCurrentLocalSettingsUKRAINE_SETTINGS&&!env.IsCurrentLocalSettingsRUSSIA_SETTINGS&&!env.IsCurrentLocalSettingsCHINA_SETTINGS&&!env.IsCurrentLocalSettingsKOREA_SETTINGS&&!env.IsCurrentLocalSettingsJAPAN_SETTINGS&&!env.IsCurrentLocalSettingsUSA_SETTINGS&&!env.IsCurrentLocalSettingsCANADA_SETTINGS&&!env.IsCurrentLocalSettingsISRAEL_SETTINGS)
end

def VF_NoTaxOnDpRequestPayment(env,isPurchase)
   return (VF_DOWNPAYMENT_ENHenv||VF_DownPaymentRequest_Enhenv||(VF_SimplifiedDownPaymentsenv&&isPurchase)||VF_DpmRequestLinkingenv||VF_DownPaymentRequest_Enhenv||VF_DpmProFormaInvoiceILenv)
end

def VF_EnableTaxCodeForFreights(env)
   return !env.IsCurrentLocalSettings(BRAZIL_SETTINGS)&&!env.IsCurrentLocalSettings(INDIA_SETTINGS)
end

def VF_DWZDefaultCheckedDisplayAllOpenItems(env)
   return env.IsCurrentLocalSettings(GERMANY_SETTINGS)
end

def VF_DWZDefaultCheckedAllowNegativeLetter(env)
   return env.IsCurrentLocalSettings(GERMANY_SETTINGS)
end

def VF_DWZDefaultCheckedApplyTemplateByHighestLevel(env)
   return env.IsCurrentLocalSettings(GERMANY_SETTINGS)
end

def VF_OpenItemsListEnh(env)
   return true
end

def VF_OpenItemsListEnh_EnableWor(env)
   return VF_OpenItemsListEnh(env)
end

def VF_OpenItemsListEnh_EnableRinRpc(env)
   return VF_OpenItemsListEnh(env)
end

def VF_POrderClsDateChange(env)
   return true
end

def VF_EnableChangeAsmBoMWhs(env)
   return true
end

def VF_TaxReconciliationReportAdditionalData(env)
   return true
end

def VF_SeparateAmountAndCurrency(env)
   return true
end

def VF_PrintLayout_id008(env)
   return true
end

def VF_PackagingPrintLayout(env)
   return true
end

def VF_ControlAccountBPRepEnh(env)
   return true
end

def VF_JEBatchPrinting(env)
   return true
end

def VF_GLReportEnh(env)
   return true
end

def VF_GLReportEnh_AsInFR(env)
   return (VF_GLReportEnhenv&&env.IsCurrentLocalSettingsFRANCE_SETTINGS)
end

def VF_856AReport(env)
   return env.IsCurrentLocalSettings(ISRAEL_SETTINGS)
end

def VF_ExportToSharoni(env)
   return env.IsCurrentLocalSettings(ISRAEL_SETTINGS)
end

def VF_TaxSummaryReportEnh(env)
   return true
end

def VF_TaxReconciliationReportEnh(env)
   return true
end

def VF_EP2_OtherAuditFeatures(env)
   return true
end

def VF_RECopyLayoutWizard(env)
   return true
end

def VF_BASReporting(env)
   return env.IsCurrentLocalSettings(AUSTRALIA_NZ_SETTINGS)||env.IsCurrentLocalSettings(CZECH_SETTINGS)||env.IsCurrentLocalSettings(PORTUGAL_SETTINGS)||env.IsCurrentLocalSettings(TURKEY_SETTINGS)||env.IsCurrentLocalSettings(SLOVAKIA_SETTINGS)||env.IsCurrentLocalSettings(UKRAINE_SETTINGS)||env.IsCurrentLocalSettings(RUSSIA_SETTINGS)||env.IsCurrentLocalSettings(NETHERLANDS_SETTINGS)||VF_UK_MakeTaxDigital(env)||VF_BASReportingEnh(env)
end

def VF_BASReportingEnh(env)
   return env.IsCurrentLocalSettings(CYPRUS_SETTINGS)||env.IsCurrentLocalSettings(FRANCE_SETTINGS)||env.IsCurrentLocalSettings(ITALY_SETTINGS)||env.IsCurrentLocalSettings(SINGAPORE_SETTINGS)||env.IsCurrentLocalSettings(PANAMA_SETTINGS)||env.IsCurrentLocalSettings(POLAND_SETTINGS)||env.IsCurrentLocalSettings(AUSTRIA_SETTINGS)||env.IsCurrentLocalSettings(SWITZERLAND_SETTINGS)||env.IsCurrentLocalSettings(DENMARK_SETTINGS)||env.IsCurrentLocalSettings(FINLAND_SETTINGS)||env.IsCurrentLocalSettings(NORWAY_SETTINGS)||env.IsCurrentLocalSettings(HUNGARY_SETTINGS)||env.IsCurrentLocalSettings(SWEDEN_SETTINGS)||env.IsCurrentLocalSettings(SOUTH_AFRICA_SETTINGS)||env.IsCurrentLocalSettings(CHINA_SETTINGS)||env.IsCurrentLocalSettings(JAPAN_SETTINGS)||env.IsCurrentLocalSettings(KOREA_SETTINGS)||env.IsCurrentLocalSettings(GREECE_SETTINGS)
end

def VF_BASReporting_EnabledInOADM(env)
   return VF_BASReporting(env)&&env.OADMGetColStr(OADM_USE_EXT_REPORTING)==SBOString(VAL_YES)
end

def VF_BASReportingForPT(env)
   return env.IsCurrentLocalSettings(PORTUGAL_SETTINGS)
end

def VF_BASReportingForNL(env)
   return env.IsCurrentLocalSettings(NETHERLANDS_SETTINGS)
end

def VF_BASReportingForCZ(env)
   return env.IsCurrentLocalSettings(CZECH_SETTINGS)
end

def VF_BASReportingForSK(env)
   return env.IsCurrentLocalSettings(SLOVAKIA_SETTINGS)
end

def VF_BASReportingForPT_EnabledInOADM(env)
   return VF_BASReportingForPT(env)&&env.OADMGetColStr(OADM_USE_EXT_REPORTING)==SBOString(VAL_YES)
end

def VF_MYFReport(env)
   return env.IsCurrentLocalSettings(GREECE_SETTINGS)
end

def VF_IgnorePrinterSize(env)
   return env.IsCurrentLocalSettings(CHINA_SETTINGS)||env.IsCurrentLocalSettings(INDIA_SETTINGS)||env.IsCurrentLocalSettings(JAPAN_SETTINGS)||env.IsCurrentLocalSettings(KOREA_SETTINGS)||env.IsCurrentLocalSettings(SINGAPORE_SETTINGS)||env.IsCurrentLocalSettings(BRAZIL_SETTINGS)
end

def VF_INDefaultLocalSettings(env)
   return env.IsCurrentLocalSettings(INDIA_SETTINGS)
end

def VF_LegalListRemoveFromMenu(env)
   return env.IsCurrentLocalSettings(CHINA_SETTINGS)||env.IsCurrentLocalSettings(JAPAN_SETTINGS)||env.IsCurrentLocalSettings(KOREA_SETTINGS)||env.IsCurrentLocalSettings(BRAZIL_SETTINGS)||env.IsCurrentLocalSettings(INDIA_SETTINGS)||env.IsCurrentLocalSettings(SINGAPORE_SETTINGS)
end

def VF_ServNature(env)
   return env.IsCurrentLocalSettings(INDIA_SETTINGS)
end

def VF_NewCstTax(env)
   return VF_NotaFiscal(env)&&env.IsCurrentLocalSettings(BRAZIL_SETTINGS)
end

def VF_NewMaterialAndFreightType(env)
   return env.IsCurrentLocalSettings(BRAZIL_SETTINGS)
end

def VF_DutyStatusOpt(env)
   return env.IsCurrentLocalSettings(INDIA_SETTINGS)
end

def VF_ReopenInvoice(env)
   return env.IsCurrentLocalSettings(CHINA_SETTINGS)||env.IsCurrentLocalSettings(JAPAN_SETTINGS)||env.IsCurrentLocalSettings(KOREA_SETTINGS)||env.IsCurrentLocalSettings(BRAZIL_SETTINGS)||env.IsCurrentLocalSettings(INDIA_SETTINGS)||env.IsCurrentLocalSettings(SINGAPORE_SETTINGS)
end

def VF_ARBlockZeroQty(env)
   return env.IsCurrentLocalSettings(BRAZIL_SETTINGS)
end

def VF_EnableDualValuation(env)
   return env.IsCurrentLocalSettings(SLOVAKIA_SETTINGS)&&env.GetMainCurrency()==SBOString("SKK")
end

def VF_EnableDualValuationAfterEC(env)
   return env.IsCurrentLocalSettings(SLOVAKIA_SETTINGS)&&env.GetMainCurrency()==SBOString("EUR")
end

def VF_JEWHT(env)
   return (env.IsLocalSettingsFlaglsf_EnableWHT&&(!env.IsCurrentLocalSettingsCHINA_SETTINGS)&&(!env.IsCurrentLocalSettingsJAPAN_SETTINGS)&&(!env.IsCurrentLocalSettingsKOREA_SETTINGS)&&(!env.IsCurrentLocalSettingsINDIA_SETTINGS)&&(!env.IsCurrentLocalSettingsBRAZIL_SETTINGS)&&(!env.IsCurrentLocalSettingsSINGAPORE_SETTINGS)&&(!VF_WTaxEngineenv))
end

def VF_ERV_JAb_XML_Export(env)
   return env.IsCurrentLocalSettings(AUSTRIA_SETTINGS)
end

def VF_FRTDummyTitlesHiding(env)
   return VF_ERV_JAb_XML_Export(env)
end

def VF_ElectRprtTemplateTypes(env)
   return VF_ERV_JAb_XML_Export(env)
end

def VF_ElectRprtTmpltTypesInReports(env)
   return false
end

def VF_BalanceSheetNewStructure(env)
   return env.IsCurrentLocalSettings(GERMANY_SETTINGS)
end

def VF_PerformancePreload()
   return true
end

def VF_USTaxEnhancement(env)
   return env.IsCurrentLocalSettings(CANADA_SETTINGS)||env.IsCurrentLocalSettings(USA_SETTINGS)
end

def VF_USOnlyTaxEnhancement(env)
   return env.IsCurrentLocalSettings(USA_SETTINGS)
end

def VF_GroupByJurisdiction(env)
   return env.CINFGetColStr(CINF_TAX_GROUPING_TYPE)==VAL_TAX_GROUPING_BY_JUR
end

def VF_UpdateGroupByJurisdictionField(env)
   return env.IsCurrentLocalSettings(CANADA_SETTINGS)||env.IsCurrentLocalSettings(CHILE_SETTINGS)||env.IsCurrentLocalSettings(ARGENTINA_SETTINGS)||env.IsCurrentLocalSettings(COSTA_RICA_SETTINGS)||env.IsCurrentLocalSettings(GUATEMALA_SETTINGS)||env.IsCurrentLocalSettings(MEXICO_SETTINGS)||(env.IsCurrentLocalSettingsUSA_SETTINGS)
end

def VF_TaaS(env)
   return env.IsCurrentLocalSettings(USA_SETTINGS)
end

def VF_EUControlAccountEnh(env)
   return (env.IsCurrentLocalSettingsGERMANY_SETTINGS)
end

def VF_ChinaNewCoA(env)
   return env.IsCurrentLocalSettings(CHINA_SETTINGS)
end

def VF_NotaFiscalFieldsEditable(env)
   return env.IsCurrentLocalSettings(BRAZIL_SETTINGS)
end

def VF_TaxReconciliationReport_RemoveAcqTaxRowsFromNonVATSection(env)
   return (env.IsCurrentLocalSettingsGERMANY_SETTINGS)
end

def VF_GeneralManagerCPIEnh(env)
   return env.IsCurrentLocalSettings(GERMANY_SETTINGS)
end

def VF_IsUpdatedTaxFormula(env)
   return (env.CINFGetColStrCINF_UPDATED_TAX_FORMULA==VAL_YES)
end

def VF_EnableDeductAtSrc(env)
   return env.IsLocalSettingsFlag(lsf_EnableDeductAtSrc)
end

def VF_AllowMixedWHTCategories(env)
   return env.IsCurrentLocalSettings(ITALY_SETTINGS)||env.IsCurrentLocalSettings(INDIA_SETTINGS)
end

def VF_NonTaxableTotalWHTReport(env)
   return env.IsCurrentLocalSettings(ITALY_SETTINGS)
end

def VF_IFRS_ReportSelCriteria()
   return true
end

def VF_UseProfitLossAcctInProduction(env)
   return true
end

def VF_SetDefaultLnExpTaxCode(env)
   return (env.IsCurrentLocalSettingsUSA_SETTINGS||env.IsCurrentLocalSettingsCANADA_SETTINGS)
end

def VF_DATEV_HR_INTEGRATION(env)
   return env.IsCurrentLocalSettings(GERMANY_SETTINGS)
end

def VF_TaxCodeDeterminationExt(env)
   return !(env.IsCurrentLocalSettingsBRAZIL_SETTINGS||env.IsCurrentLocalSettingsINDIA_SETTINGS||env.IsCurrentLocalSettingsISRAEL_SETTINGS)
end

def VF_PersonalWorkCenter(env)
   return env.IsUserPWCEnabled()
end

def VF_Dashboard(env)
   return VF_PersonalWorkCenter(env)&&(env.IsDashboardEnabled()||env.IsB1BuzzEnabled())
end

def VF_InactiveTaxVTG(env)
   taxSystem=env.GetTaxSysType()
   return (taxSystem==VAL_PRECONFIG_SINGLE_TAX_SYSTEM||taxSystem==VAL_SINGLE_TAX_SYSTEM)
end

def VF_InactiveTaxWHT(env)
   return env.IsLocalSettingsFlag(lsf_EnableWHT)
end

def VF_InactiveTaxBOX(env)
   taxSystem=env.GetTaxSysType()
   return (taxSystem==VAL_PRECONFIG_SINGLE_TAX_SYSTEM||taxSystem==VAL_SINGLE_TAX_SYSTEM)
end

def VF_DATEV_Fields(env)
   return env.IsCurrentLocalSettings(GERMANY_SETTINGS)
end

def VF_PTCertification(env)
   return (env.IsCurrentLocalSettingsPORTUGAL_SETTINGS&&env.OADMGetColStrOADM_DIGITAL_CERT_PATH!=_T("VHVybiBPZmYgRHVtbXkgUG9ydHVnYWwgQ2VydGlmaWNhdGlvbg=="))
end

def VF_GTS(env)
   return env.IsCurrentLocalSettings(CHINA_SETTINGS)
end

def VF_EnableBlackListCountry(env)
   return env.IsCurrentLocalSettings(ITALY_SETTINGS)
end

def VF_CashDisctBasisDateEnh(env)
   return !(env.IsCurrentLocalSettingsUK_SETTINGS||env.IsCurrentLocalSettingsCYPRUS_SETTINGS||env.IsCurrentLocalSettingsBELGIAN_SETTINGS||env.IsCurrentLocalSettingsGREECE_SETTINGS)
end

def VF_ElectronicReport(env)
   return env.IsCurrentLocalSettings(CZECH_SETTINGS)
end

def VF_ElectronicReportSK(env)
   return env.IsCurrentLocalSettings(SLOVAKIA_SETTINGS)
end

def VF_ElectronicReportHU(env)
   return env.IsCurrentLocalSettings(HUNGARY_SETTINGS)
end

def VF_EU_Sales_ElectronicReport(env)
   return (env.IsCurrentLocalSettingsSLOVAKIA_SETTINGS||env.IsCurrentLocalSettingsCZECH_SETTINGS||env.IsCurrentLocalSettingsPORTUGAL_SETTINGS||env.IsCurrentLocalSettingsNETHERLANDS_SETTINGS)
end

def VF_EU_SalesRpt_DE(env)
   return env.IsCurrentLocalSettings(GERMANY_SETTINGS)
end

def VF_EU_SalesRpt_DownpaymentRequest(env)
   return (env.IsCurrentLocalSettingsGERMANY_SETTINGS||env.IsCurrentLocalSettingsUK_SETTINGS||env.IsCurrentLocalSettingsFRANCE_SETTINGS)&&env.IsLocalSettingsFlag(lsf_IsEC)
end

def VF_TPC_Wizard_EU(env)
   return env.IsVatPerLine()
end

def VF_FederalTaxIdOnJERow(env)
   return !env.IsCurrentLocalSettings(ISRAEL_SETTINGS)
end

def VF_PQ_Enhancements(env)
   return true
end

def VF_EDF_FPA(env)
   return env.IsCurrentLocalSettings(ITALY_SETTINGS)&&VF_EDF(env)
end

def VF_EDF(env)
   if cEnabler.getInstance().IsDisableEDF()
      return false
   else
      if cEnabler.getInstance().IsEnableEDF()
         return true
      end

   end

   case env.GetLocalSettingsAsEnum()

   when cBizEnv::localSettings::czech
   when cBizEnv::localSettings::italy
   when cBizEnv::localSettings::uK
      return true
   end

   return false
end

def VF_ElectronicInvoiceCR(env)
   return env.IsCurrentLocalSettings(COSTA_RICA_SETTINGS)&&env.IsEnableProtectSetting(ps_EnableElectronicInvoiceCR)
end

def VF_ElectronicInvoiceES(env)
   return env.IsCurrentLocalSettings(SPAIN_SETTINGS)
end

def VF_ElectronicInvoiceGT(env)
   return env.IsCurrentLocalSettings(GUATEMALA_SETTINGS)&&env.IsEnableProtectSetting(ps_EnableElectronicInvoiceGT)
end

def VF_ElectronicInvoiceIT(env)
   return env.IsCurrentLocalSettings(ITALY_SETTINGS)
end

def VF_ElectronicInvoiceAR(env)
   return env.IsCurrentLocalSettings(ARGENTINA_SETTINGS)
end

def VF_ElectronicInvoiceMX(env)
   return env.IsCurrentLocalSettings(MEXICO_SETTINGS)
end

def VF_ElectronicInvoiceMX_CFDI(env)
   return (VF_ElectronicInvoiceMXenv)
end

def VF_ElectronicInvoiceMX_EDF(env)
   return VF_ElectronicInvoiceMX_CFDI(env)
end

def VF_ElectronicInvoiceMX_EFM(env)
   return VF_ElectronicInvoiceMX_CFDI(env)
end

def VF_ElectronicInvoiceMX_CFDI_Reconcile(env)
   return VF_ElectronicInvoiceMX_CFDI(env)
end

def VF_ElectronicReportingNL(env)
   return env.IsCurrentLocalSettings(NETHERLANDS_SETTINGS)
end

def VF_ElectronicReportingNL_WithBAPI(env)
   return VF_ElectronicReportingNL(env)&&bAPIDLLLoader.isLoaded()&&false
end

def VF_ElectronicReportingNL_Digipoort(env)
   return VF_ElectronicReportingNL(env)
end

def VF_NotaFiscalElectronica(env)
   return env.IsCurrentLocalSettings(BRAZIL_SETTINGS)
end

def VF_ReferencedDocuments(env)
   return true
end

def VF_NotaFiscalElectronicaFreeOfChargeBP(env)
   return VF_NotaFiscalElectronica(env)
end

def VF_GrossTotalDiscount(env)
   return env.IsCurrentLocalSettings(BRAZIL_SETTINGS)
end

def VF_ElectronicInvoicePA(env)
   return env.IsCurrentLocalSettings(PANAMA_SETTINGS)
end

def VF_ReportLayoutEnhancements(env)
   return env.IsCurrentLocalSettings(ISRAEL_SETTINGS)
end

def VF_BPAccountBalanceReportEnhancement(env)
   return true
end

def VF_DpmManualVatAllocation(env)
   return env.IsLocalSettingsFlag(lsf_EnableDPM)&&env.IsCurrentLocalSettings(POLAND_SETTINGS)&&env.IsEnableProtectSetting(ps_DpmManualVatAllocation)
end

def VF_PCN874(env)
   return env.IsCurrentLocalSettings(ISRAEL_SETTINGS)
end

def VF_PCN874ForNonVATCompanies(env)
   return VF_PCN874(env)&&!env.IsVat()
end

def VF_PCN874ReportTypeSelection(env)
   return env.IsCurrentLocalSettings(ISRAEL_SETTINGS)
end

def VF_IRAS(env)
   return env.IsCurrentLocalSettings(SINGAPORE_SETTINGS)
end

def VF_EmployeeCPF(env)
   return env.IsCurrentLocalSettings(BRAZIL_SETTINGS)
end

def VF_856_2010Report(env)
   return env.IsCurrentLocalSettings(ISRAEL_SETTINGS)
end

def VF_856_2014Report(env)
   return env.IsCurrentLocalSettings(ISRAEL_SETTINGS)
end

def VF_EnableLinkMap(env)
   return true
end

def VF_InactiveTaxSTC(env)
   taxSystem=env.GetTaxSysType()
   return (taxSystem==VAL_PRECONFIG_MULTI_TAX_SYSTEM||taxSystem==VAL_USER_DEF_MULTI_TAX_SYSTEM||taxSystem==VAL_MULTI_TAX_SYSTEM)
end

def VF_EnableEVAT_NL(env)
   return env.IsCurrentLocalSettings(NETHERLANDS_SETTINGS)
end

def VF_DpmRequestControlAccount(env)
   return (env.IsLocalSettingsFlaglsf_EnableDPM&&(env.IsCurrentLocalSettingsHUNGARY_SETTINGS||env.IsCurrentLocalSettingsCZECH_SETTINGS||env.IsCurrentLocalSettingsSLOVAKIA_SETTINGS))
end

def VF_2874(env)
   return !env.CINFGetColStr(CINF_LAWS_SET).CompareNoCase(BRAZIL_SETTINGS)
end

def VF_BudgetByCostCenters(env)
   return true
end

def VF_CFOPCodeEnh(env)
   return env.IsCurrentLocalSettings(BRAZIL_SETTINGS)
end

def VF_EnableChangePWDflSaveOption(env)
   return env.IsCurrentLocalSettings(CZECH_SETTINGS)||env.IsCurrentLocalSettings(SLOVAKIA_SETTINGS)||env.IsCurrentLocalSettings(UKRAINE_SETTINGS)||env.IsCurrentLocalSettings(RUSSIA_SETTINGS)
end

def VF_DpmExemptionLetterEnh(env)
   return (env.IsLocalSettingsFlaglsf_EnableDPM&&env.IsLocalSettingsFlaglsf_EnableTaxExemptionLetter&&env.IsCurrentLocalSettingsITALY_SETTINGS)
end

def VF_BrazilIndexers(env)
   return env.IsCompanyValid()&&!env.CINFGetColStr(CINF_LAWS_SET).CompareNoCase(BRAZIL_SETTINGS)
end

def VF_PaymentTraceability(env)
   return env.IsCurrentLocalSettings(ITALY_SETTINGS)
end

def VF_EnableLandedCostsOnAPInvoice(env)
   return true
end

def VF_EnableLandedCostsOnAPInvoiceBasedOnGRPO(env)
   return true
end

def VF_ServiceCallNumbering(env)
   return true
end

def VF_6111(env)
   return env.IsCurrentLocalSettings(ISRAEL_SETTINGS)
end

def VF_DueDateUpdateForPaymentViaBoE(env)
   return env.IsCurrentLocalSettings(BRAZIL_SETTINGS)
end

def VF_CorrectionInvoiceInBSP(env)
   return (VF_EnableCorrInvenv&&(env.IsCurrentLocalSettingsHUNGARY_SETTINGS||env.IsCurrentLocalSettingsCZECH_SETTINGS||env.IsCurrentLocalSettingsSLOVAKIA_SETTINGS||env.IsCurrentLocalSettingsPOLAND_SETTINGS)||env.IsCurrentLocalSettingsUKRAINE_SETTINGS||env.IsCurrentLocalSettingsRUSSIA_SETTINGS)
end

def VF_DpmAsDiscountDeprecatedAlg(env)
   return env.IsCurrentLocalSettings(ITALY_SETTINGS)||((env.IsCurrentLocalSettingsCHILE_SETTINGS||env.IsCurrentLocalSettingsARGENTINA_SETTINGS)&&env.IsEnableProtectSettingps_DpmAsDiscountAlg)
end

def VF_ManualTaxAmountAdjustmentAR(env)
   return env.IsCurrentLocalSettings(BRAZIL_SETTINGS)
end

def VF_EnhDunningBoE(env)
   return env.IsCurrentLocalSettings(BRAZIL_SETTINGS)
end

def VF_NCMNewFieldsAndValidations(env)
   return (env.IsCurrentLocalSettingsBRAZIL_SETTINGS&&VF_BrazilIndexersenv)
end

def VF_DGW_NotaFiscal(env)
   return VF_NotaFiscal(env)&&env.IsCurrentLocalSettings(BRAZIL_SETTINGS)
end

def VF_AnnualInvoiceDeclReport(env)
   return VF_EnableBlackListCountry(env)
end

def VF_ServiceTax(env)
   return env.IsCurrentLocalSettings(INDIA_SETTINGS)
end

def VF_ServiceTax_EnabledInOADM(env)
   return VF_ServiceTax(env)&&(env.OADMGetColStrOADM_ENABLE_SERVICE_TAX==SBOStringVAL_YES)
end

def VF_MultipleIEs_BR(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseBRAZIL_SETTINGS==0)&&!VF_MultiBranch_EnabledInOADMenv||false)
end

def VF_MultipleIEs_BR_MultiBranch(env)
   countryCode=env.GetLocalSettings()
   countryCode.Trim()
   return ((countryCode.CompareNoCaseBRAZIL_SETTINGS==0)&&VF_MultiBranch_EnabledInOADMenv||false)
end

def VF_EnableDpmOnReserveInvoice(env)
   return env.IsLocalSettingsFlag(lsf_EnableDPM)
end

def VF_Report349Enhance(env)
   return env.IsCurrentLocalSettings(SPAIN_SETTINGS)
end

def VF_SupplCode(env)
   if env.IsCurrentLocalSettings(CHINA_SETTINGS)&&!env.IsLocalSettingsFlag(lsf_IsDocNumMethod)&&(env.OADMGetColStrOADM_ENABLE_SUPPLCODE==SBOStringVAL_YES)
      return true
   else
      return false
   end

end

def VF_EnableCorrInv_PaymentWizard(env)
   return VF_EnableCorrInv(env)
end

def VF_ISOCurrencyNumbers(env)
   return env.IsCurrentLocalSettings(RUSSIA_SETTINGS)||env.IsCurrentLocalSettings(UKRAINE_SETTINGS)
end

def VF_SimplifiedDpmWithDPInvoice(env,isAPSide)
   return VF_SimplifiedDownPayments(env)&&isAPSide
end

def VF_CEEDpmProcess(env,isAPSide)
   return (VF_DownPayment_Enhenv||VF_DownPayment_Enh_PLenv||VF_SimplifiedDpmWithDPInvoice(env,isAPSide))
end

def VF_CorrectionTaxInvoice(env)
   return VF_EnableCorrInv(env)&&(env.IsCurrentLocalSettingsRUSSIA_SETTINGS||env.IsCurrentLocalSettingsUKRAINE_SETTINGS)
end

def VF_BASReporting_OffsetAccounts(env)
   return (env.IsCurrentLocalSettingsRUSSIA_SETTINGS||env.IsCurrentLocalSettingsUKRAINE_SETTINGS)&&VF_BASReporting(env)
end

def VF_BASReporting_RetrievalEditing(env)
   return (env.IsCurrentLocalSettingsRUSSIA_SETTINGS||env.IsCurrentLocalSettingsUKRAINE_SETTINGS)&&VF_BASReporting(env)
end

def VF_BASReporting_ElectronicFile(env)
   return (env.IsCurrentLocalSettingsRUSSIA_SETTINGS||env.IsCurrentLocalSettingsUKRAINE_SETTINGS)&&VF_BASReporting(env)
end

def VF_BASReporting_CreateVoucher(env)
   return (env.IsCurrentLocalSettingsRUSSIA_SETTINGS||env.IsCurrentLocalSettingsUKRAINE_SETTINGS)&&VF_BASReporting(env)
end

def VF_BASReporting_TextInput(env)
   return (env.IsCurrentLocalSettingsRUSSIA_SETTINGS||env.IsCurrentLocalSettingsUKRAINE_SETTINGS)&&VF_BASReporting(env)
end

def VF_BASReporting_JERemarks(env)
   return true
end

def VF_BASReporting_SingleChoiceDefault(env)
   return (env.IsCurrentLocalSettingsRUSSIA_SETTINGS||env.IsCurrentLocalSettingsUKRAINE_SETTINGS)&&VF_BASReporting(env)
end

def VF_Banking_RelatedDocsSelection(env)
   return VF_EnableCorrInv(env)
end

def VF_SalesEmployeeDeactivation(env)
   return true
end

def VF_MultipleBlanketAgreements(env)
   return true
end

def VF_MultipleBlanketAgreements_RU_UA(env)
   return VF_MultipleBlanketAgreements(env)&&(env.IsCurrentLocalSettingsRUSSIA_SETTINGS||env.IsCurrentLocalSettingsUKRAINE_SETTINGS)
end

def VF_DpmHeaderDiscountPercentage(env)
   return env.IsCurrentLocalSettings(SINGAPORE_SETTINGS)&&env.IsLocalSettingsFlag(lsf_EnableDPM)
end

def VF_EnableProcessChecklist(env)
   return true
end

def VF_SPED(env)
   return VF_BrazilIndexers(env)&&env.IsCompanyValid()&&!env.CINFGetColStr(CINF_LAWS_SET).CompareNoCase(BRAZIL_SETTINGS)
end

def VF_DpmProFormaInvoiceIL(env)
   return env.IsCurrentLocalSettings(ISRAEL_SETTINGS)&&env.IsLocalSettingsFlag(lsf_EnableDPM)
end

def VF_VatInRevenueAccount_VTG(env)
   return env.IsCurrentLocalSettings(RUSSIA_SETTINGS)||env.IsCurrentLocalSettings(UKRAINE_SETTINGS)
end

def VF_DpmTaxOffsetAccount_VTG(env)
   return ((env.IsCurrentLocalSettingsRUSSIA_SETTINGS||env.IsCurrentLocalSettingsUKRAINE_SETTINGS)&&env.IsLocalSettingsFlaglsf_EnableDPM)
end

def VF_CashDiscountAccount_VTG(env)
   return (env.IsCurrentLocalSettingsUKRAINE_SETTINGS||env.IsCurrentLocalSettingsRUSSIA_SETTINGS||env.IsCurrentLocalSettingsGERMANY_SETTINGS||env.IsCurrentLocalSettingsFRANCE_SETTINGS||(VF_AutomaticPPDenv&&env.IsEnabledAutomaticPPD()))
end

def VF_PaymentDueDate(env)
   return env.IsCurrentLocalSettings(SPAIN_SETTINGS)
end

def VF_EnablePaymentDraftNumbering(env)
   return true
end

def VF_RU_UA_UOM(env)
   return VF_CorrectionTaxInvoice(env)
end

def VF_EnableInputVATReportEnhancement(env)
   return env.IsCurrentLocalSettings(POLAND_SETTINGS)
end

def VF_LandedCostBasedOnLandedCostNCI(env)
   return !env.IsContInventory()
end

def VF_LandedCostsEnhancement(env)
   return !env.IsContInventory()
end

def VF_LandedCostsEnhancementNonBasedWTR(env)
   return !env.IsContInventory()
end

def VF_LandedCostsCustomsRateEnhancement(env)
   return true
end

def VF_LandedCostsBrokerInvoiceEnhancement(env)
   return env.IsContInventory()&&!env.IsCurrentLocalSettings(ISRAEL_SETTINGS)
end

def VF_SPED_NF(env)
   return VF_SPED(env)&&VF_NotaFiscal(env)&&env.IsCurrentLocalSettings(BRAZIL_SETTINGS)
end

def VF_TaxRateDetermination(env)
   return env.IsCurrentLocalSettings(PORTUGAL_SETTINGS)||env.IsCurrentLocalSettings(ITALY_SETTINGS)||env.IsCurrentLocalSettings(FRANCE_SETTINGS)||env.IsCurrentLocalSettings(AUSTRIA_SETTINGS)||env.IsCurrentLocalSettings(BELGIAN_SETTINGS)||env.IsCurrentLocalSettings(CYPRUS_SETTINGS)||env.IsCurrentLocalSettings(CZECH_SETTINGS)||env.IsCurrentLocalSettings(DENMARK_SETTINGS)||env.IsCurrentLocalSettings(FINLAND_SETTINGS)||env.IsCurrentLocalSettings(GERMANY_SETTINGS)||env.IsCurrentLocalSettings(LUXEMBURG_SETTINGS)||env.IsCurrentLocalSettings(HUNGARY_SETTINGS)||env.IsCurrentLocalSettings(IRELAND_SETTINGS)||env.IsCurrentLocalSettings(NETHERLANDS_SETTINGS)||env.IsCurrentLocalSettings(NORWAY_SETTINGS)||env.IsCurrentLocalSettings(POLAND_SETTINGS)||env.IsCurrentLocalSettings(SLOVAKIA_SETTINGS)||env.IsCurrentLocalSettings(SPAIN_SETTINGS)||env.IsCurrentLocalSettings(SWEDEN_SETTINGS)||env.IsCurrentLocalSettings(SWITZERLAND_SETTINGS)||env.IsCurrentLocalSettings(TURKEY_SETTINGS)||env.IsCurrentLocalSettings(UK_SETTINGS)||env.IsCurrentLocalSettings(GREECE_SETTINGS)||env.IsCurrentLocalSettings(AUSTRALIA_NZ_SETTINGS)||env.IsCurrentLocalSettings(CHINA_SETTINGS)||env.IsCurrentLocalSettings(JAPAN_SETTINGS)||env.IsCurrentLocalSettings(PANAMA_SETTINGS)||env.IsCurrentLocalSettings(SINGAPORE_SETTINGS)||env.IsCurrentLocalSettings(SOUTH_AFRICA_SETTINGS)||env.IsCurrentLocalSettings(UKRAINE_SETTINGS)||env.IsCurrentLocalSettings(RUSSIA_SETTINGS)||env.IsCurrentLocalSettings(KOREA_SETTINGS)
end

def VF_ISRRefNumber_AllowSmallerLength(env)
   return env.IsCurrentLocalSettings(SWITZERLAND_SETTINGS)
end

def VF_ReleaserReceiver(env)
   return env.IsCurrentLocalSettings(RUSSIA_SETTINGS)||env.IsCurrentLocalSettings(UKRAINE_SETTINGS)
end

def VF_Supplier(env)
   return env.IsCurrentLocalSettings(RUSSIA_SETTINGS)||env.IsCurrentLocalSettings(UKRAINE_SETTINGS)
end

def VF_SurplusesAndShortages(env)
   return env.IsCurrentLocalSettings(RUSSIA_SETTINGS)||env.IsCurrentLocalSettings(UKRAINE_SETTINGS)
end

def VF_HANA(env)
   connection=env.GetServerConnection()
   if connection==nullptr
      return false
   end

   connectionParams=connection.GetConnectionParams()
   if connectionParams==nullptr
      return false
   end

   return connectionParams.Get(dbmST_ServerType).GetValue().strtol()==st_HANADB
end

def VF_HANA_TODO(env)
   return VF_HANA(env)
end

def VF_HANA_LimitCFL(env)
   return VF_HANA(env)
end

def VF_HANA_PerfOptimizationUpdateSO(env)
   return VF_HANA(env)&&env.IsDocOptimizationEnabled()
end

def VF_DeferredTaxInJE(env)
   return env.IsLocalSettingsFlag(lsf_EnableDeferredTax)
end

def VF_EnableFixedAssets(env)
   return env.IsEnableFixedAssets()
end

def VF_LowValueAsset(env)
   return env.IsCurrentLocalSettings(GERMANY_SETTINGS)
end

def VF_RU_UA_TaxAccounting(env)
   return (env.IsCurrentLocalSettingsRUSSIA_SETTINGS||env.IsCurrentLocalSettingsUKRAINE_SETTINGS)&&VF_BASReporting_EnabledInOADM(env)
end

def VF_EnablePostingPreviewOnManualReconciliation(env)
   return true
end

def VF_EnablePostingPreviewOnReconciliationCancel(env)
   return true
end

def VF_EnableCoefficientType(env)
   return (env.IsCurrentLocalSettingsCZECH_SETTINGS||env.IsCurrentLocalSettingsSLOVAKIA_SETTINGS)
end

def VF_AssetPayableAccount(env)
   return env.IsCurrentLocalSettings(ISRAEL_SETTINGS)
end

def VF_ActualCosting_IsEnabled(env)
   if !env.IsContInventory()
      return false
   end

   pCFC=env.GetCompany().GetHideFuncCache(env)
   if pCFC.IsFuncHidden(HFE_SERIAL_BATCHES)
      return false
   end

   return true
end

def VF_TaxCreditControl(env)
   return env.IsCurrentLocalSettings(BRAZIL_SETTINGS)
end

def VF_CorrInvWithoutTrans(env)
   return VF_EnableCorrInv(env)&&(env.IsCurrentLocalSettingsRUSSIA_SETTINGS||env.IsCurrentLocalSettingsUKRAINE_SETTINGS)
end

def VF_AlterationTaxInvoice(env)
   return VF_EnableCorrInv(env)&&(env.IsCurrentLocalSettingsRUSSIA_SETTINGS||env.IsCurrentLocalSettingsUKRAINE_SETTINGS)
end

def VF_OthersFinancialReportTemplate(env)
   return env.IsCurrentLocalSettings(RUSSIA_SETTINGS)||env.IsCurrentLocalSettings(UKRAINE_SETTINGS)
end

def VF_AdditionalList(env)
   return env.IsCurrentLocalSettings(RUSSIA_SETTINGS)||env.IsCurrentLocalSettings(UKRAINE_SETTINGS)
end

def VF_VATReposting(env)
   return env.IsCurrentLocalSettings(RUSSIA_SETTINGS)||env.IsCurrentLocalSettings(UKRAINE_SETTINGS)
end

def VF_VATReposting_IsEnabledInADM(env)
   return VF_VATReposting(env)&&env.GetPostInVATinAPInv()==VAL_YES
end

def VF_EnableNumReuse(env)
   return env.IsCurrentLocalSettings(RUSSIA_SETTINGS)||env.IsCurrentLocalSettings(UKRAINE_SETTINGS)
end

def VF_CancelMktgDoc(env)
   return true
end

def VF_ProductSrcCodeMod(env)
   return env.IsCurrentLocalSettings(BRAZIL_SETTINGS)
end

def VF_LegalReportingEnh(env)
   return env.IsCurrentLocalSettings(TURKEY_SETTINGS)
end

def VF_FolioNumberPrefix4characters(env)
   return (env.IsCurrentLocalSettingsCHILE_SETTINGS||env.IsCurrentLocalSettingsARGENTINA_SETTINGS)
end

def VF_FolioNumberPrefix3characters(env)
   return (env.IsCurrentLocalSettingsTURKEY_SETTINGS)
end

def VF_CopyState(env)
   return env.IsCurrentLocalSettings(INDIA_SETTINGS)
end

def VF_ShowDMPAccumulatorsOnBP(env)
   return VF_DpmProFormaInvoiceIL(env)
end

def VF_DirARRevenuePosting(env)
   return env.IsCurrentLocalSettings(RUSSIA_SETTINGS)||env.IsCurrentLocalSettings(UKRAINE_SETTINGS)
end

def VF_GLAccountClosing(env)
   return env.IsCurrentLocalSettings(TURKEY_SETTINGS)
end

def VF_HANA_IgnoreCaseSensitive(env)
   return !env.IsCaseSensitiveEnabled()
end

def VF_EAEnableGoods(env)
   return env.IsCurrentLocalSettings(PORTUGAL_SETTINGS)&&(env.ADM1GetColStrADM1_ENB_EA_TRANS==SBOStringVAL_YES)
end

def VF_EAEnableInvoice(env)
   return env.IsCurrentLocalSettings(PORTUGAL_SETTINGS)&&(env.ADM1GetColStrADM1_ENB_EA_INV==SBOStringVAL_YES)
end

def VF_EnableTaxRptBR(env)
   return env.IsCurrentLocalSettings(BRAZIL_SETTINGS)
end

def VF_EnableCloseToParentItemWipVarianceAccountAbility(env)
   return (env.IsCurrentLocalSettingsSLOVAKIA_SETTINGS||env.IsCurrentLocalSettingsCZECH_SETTINGS||env.IsCurrentLocalSettingsHUNGARY_SETTINGS)
end

def VF_EnableUDFForTaxDet(env)
   return env.IsCurrentLocalSettings(BRAZIL_SETTINGS)||VF_GST(env)
end

def VF_AnnualInvoiceDeclReport2013(env)
   return VF_AnnualInvoiceDeclReport(env)
end

def VF_EnableVATDateIL(env)
   return env.IsCurrentLocalSettings(ISRAEL_SETTINGS)
end

def VF_EnableVATDateBE(env)
   return env.IsCurrentLocalSettings(BELGIAN_SETTINGS)
end

def VF_EnableManufacturing(env)
   return true
end

def VF_EnableWIPMapping(env)
   return VF_EnableManufacturing(env)
end

def VF_EnableBackflushViaAutoIGE(env)
   return VF_EnableManufacturing(env)
end

def VF_EnableByProductOnIGN(env)
   return VF_EnableManufacturing(env)
end

def VF_EnableUserGroupFunctionality()
   return true
end

def VF_EnableNegativePaymentMethod(env)
   return env.IsEnableNegativePaymentMethod()
end

def VF_EnableNegativePaymentMethodForSum(env)
   return env.IsEnableNegativePaymentMethodForSum()
end

def VF_SPED_Enh(env)
   return env.IsCurrentLocalSettings(BRAZIL_SETTINGS)
end

def VF_SPED_Contabil(env)
   return env.IsCurrentLocalSettings(BRAZIL_SETTINGS)&&VF_HANA(env)
end

def VF_SPED_Enh2(env)
   return env.IsCurrentLocalSettings(BRAZIL_SETTINGS)
end

def VF_SPED_Fiscal(env)
   return VF_SPED_Enh2(env)&&VF_HANA(env)&&env.IsCurrentLocalSettings(BRAZIL_SETTINGS)
end

def VF_SEPA(env)
   return env.IsCurrentLocalSettings(AUSTRIA_SETTINGS)||env.IsCurrentLocalSettings(BELGIAN_SETTINGS)||env.IsCurrentLocalSettings(CYPRUS_SETTINGS)||env.IsCurrentLocalSettings(CZECH_SETTINGS)||env.IsCurrentLocalSettings(DENMARK_SETTINGS)||env.IsCurrentLocalSettings(FINLAND_SETTINGS)||env.IsCurrentLocalSettings(FRANCE_SETTINGS)||env.IsCurrentLocalSettings(GERMANY_SETTINGS)||env.IsCurrentLocalSettings(GREECE_SETTINGS)||env.IsCurrentLocalSettings(HUNGARY_SETTINGS)||env.IsCurrentLocalSettings(ITALY_SETTINGS)||env.IsCurrentLocalSettings(NETHERLANDS_SETTINGS)||env.IsCurrentLocalSettings(POLAND_SETTINGS)||env.IsCurrentLocalSettings(PORTUGAL_SETTINGS)||env.IsCurrentLocalSettings(SLOVAKIA_SETTINGS)||env.IsCurrentLocalSettings(SPAIN_SETTINGS)||env.IsCurrentLocalSettings(SWEDEN_SETTINGS)||env.IsCurrentLocalSettings(UK_SETTINGS)||env.IsCurrentLocalSettings(NORWAY_SETTINGS)||env.IsCurrentLocalSettings(SWITZERLAND_SETTINGS)
end

def VF_ApplyIBANValidationToAccountNumber(env)
   return env.IsCurrentLocalSettings(AUSTRIA_SETTINGS)||env.IsCurrentLocalSettings(BELGIAN_SETTINGS)||env.IsCurrentLocalSettings(CYPRUS_SETTINGS)||env.IsCurrentLocalSettings(GERMANY_SETTINGS)||env.IsCurrentLocalSettings(FINLAND_SETTINGS)||env.IsCurrentLocalSettings(FRANCE_SETTINGS)||env.IsCurrentLocalSettings(ITALY_SETTINGS)||env.IsCurrentLocalSettings(NETHERLANDS_SETTINGS)||env.IsCurrentLocalSettings(PORTUGAL_SETTINGS)||env.IsCurrentLocalSettings(SLOVAKIA_SETTINGS)||env.IsCurrentLocalSettings(SPAIN_SETTINGS)||env.IsCurrentLocalSettings(UK_SETTINGS)||env.IsCurrentLocalSettings(IRELAND_SETTINGS)||env.IsCurrentLocalSettings(GREECE_SETTINGS)
end

def VF_Siren(env)
   return env.IsCurrentLocalSettings(FRANCE_SETTINGS)
end

def VF_FinancialTemplateImport(env)
   return true
end

def VF_EBalance(env)
   return env.IsCurrentLocalSettings(GERMANY_SETTINGS)
end

def VF_ThirdPartyWorkbench(env)
   return env.IsCurrentLocalSettings(BRAZIL_SETTINGS)
end

def VF_BPinStockTransactions(env)
   return false
end

def VF_ArgFolioNumbering(env)
   return env.IsCurrentLocalSettings(ARGENTINA_SETTINGS)
end

def VF_EnableEVATforRU(env)
   return (env.IsCurrentLocalSettingsRUSSIA_SETTINGS||env.IsCurrentLocalSettingsUKRAINE_SETTINGS)
end

def VF_EnableEVATforSK(env)
   return env.IsCurrentLocalSettings(SLOVAKIA_SETTINGS)
end

def VF_BPDataOwnership(env)
   return env.IsDOEnabled()&&(env.IsDOManagedByBPOnly()||env.IsDOManagedByBPnDoc())
end

def VF_InterimDocuments(env)
   return env.IsCurrentLocalSettings(ARGENTINA_SETTINGS)
end

def VF_EnhancedReferenceFieldLinks(env)
   return true
end

def VF_SEPA_DunningWizardExtension(env)
   return VF_ApplyIBANValidationToAccountNumber(env)||env.IsCurrentLocalSettings(SWITZERLAND_SETTINGS)||env.IsCurrentLocalSettings(NORWAY_SETTINGS)||env.IsCurrentLocalSettings(TURKEY_SETTINGS)
end

def VF_BypassSLDForInternalTesting()
   return false
end

def VF_BypassLicenseCheckForUT()
   return false
end

def VF_EnableWTHTaxRptIT(env)
   return env.IsCurrentLocalSettings(ITALY_SETTINGS)
end

def VF_3rdPartyChecks(env)
   return !env.IsCurrentLocalSettings(BRAZIL_SETTINGS)
end

def VF_AutomaticPPD(env)
   return env.IsCurrentLocalSettings(UK_SETTINGS)
end

def VF_SplitPayment(env)
   return env.IsCurrentLocalSettings(ITALY_SETTINGS)
end

def VF_ProjectManagement(env)
   return env.IsEnableProjectManagement()
end

def VF_IntrastatEnhancement(env)
   return VF_Intrastat(env)
end

def VF_ReverseCharge(env)
   return env.IsCurrentLocalSettings(ITALY_SETTINGS)
end

def VF_IgnoreZeroPosting(env)
   return true
end

def VF_GrossFreight(env)
   return !(env.IsCurrentLocalSettingsBRAZIL_SETTINGS||env.IsCurrentLocalSettingsINDIA_SETTINGS||env.IsCurrentLocalSettingsISRAEL_SETTINGS)
end

def VF_GlobalCentralizedPaymentForMultibranch(env)
   return VF_MultiBranch_EnabledInOADM(env)&&!env.IsCurrentLocalSettings(BRAZIL_SETTINGS)
end

def VF_GrossFreight_IL(env)
   return env.IsCurrentLocalSettings(ISRAEL_SETTINGS)
end

def VF_EnableExpenseClaimMX(env)
   return env.IsCurrentLocalSettings(MEXICO_SETTINGS)&&env.IsLocalSettingsFlag(lsf_EnableExpenseClaim)
end

def VF_WTaxPanama(env)
   return env.IsCurrentLocalSettings(PANAMA_SETTINGS)
end

def VF_PaymentReferenceCalculationGSCR(env)
   return env.IsCurrentLocalSettings(FINLAND_SETTINGS)
end

def VF_EU_SalesRpt_DownpaymentInvoice(env)
   return env.IsCurrentLocalSettings(UK_SETTINGS)||env.IsCurrentLocalSettings(FRANCE_SETTINGS)||env.IsCurrentLocalSettings(GERMANY_SETTINGS)
end

def VF_ConcurIntegration(env)
   return true
end

def VF_WeightedAverage(env)
   return (!env.IsCurrentLocalSettingsISRAEL_SETTINGS)
end

def VF_EnableExpense(env)
   return env.IsLocalSettingsFlag(lsf_EnableExpenseClaim)
end

def VF_ElectronicRegisterEET(env)
   return env.IsCurrentLocalSettings(CZECH_SETTINGS)
end

def VF_PosCashRegister(env)
   return env.IsCurrentLocalSettings(CZECH_SETTINGS)
end

def VF_EnableResourceHandling()
   return true
end

def VF_EnableResourceDetails()
   return VF_EnableResourceHandling()&&cEnabler.getInstance().IsEnableResourceLink()
end

def VF_EnableGDPR()
   return true
end

def VF_EnableGDPRSearch()
   return VF_EnableGDPR()&&false
end

def VF_EnableGDPRGUI(env)
   return env.IsCompanyValid()&&VF_EnableGDPR()&&env.IsEnabledGDPR()
end

def VF_NewEDFParameters(env)
   return VF_ElectronicRegisterEET(env)||VF_ElectronicInvoiceIT(env)||VF_ElectronicInvoiceGT(env)||VF_ElectronicInvoiceCR(env)||VF_ElectronicInvoiceMX(env)||VF_ElectronicInvoiceAR(env)||VF_ElectronicInvoiceES(env)||VF_ElectronicInvoiceHU(env)
end

def VF_ImmediateInformationSupply(env)
   return env.IsCurrentLocalSettings(SPAIN_SETTINGS)&&(env.ADM1GetColStrADM1_IMMEDIATE_INF_SUPPLY.Trim()==SBOStringVAL_YES)&&VF_ImmediateInformationSupply_FeatureEnabler(env)
end

def VF_ImmediateInformationSupply_FeatureEnabler(env)
   return env.IsCurrentLocalSettings(SPAIN_SETTINGS)
end

def VF_CommissionTrade(env)
   return env.IsCurrentLocalSettings(RUSSIA_SETTINGS)||env.IsCurrentLocalSettings(UKRAINE_SETTINGS)
end

def VF_LandedCostsMultipleBrokerInvoiceEnhancement(env)
   return VF_LandedCostsBrokerInvoiceEnhancement(env)&&env.IsEnabledMultipleBrokerInvoiceForLaC()
end

def VF_LandedCostEnableLegalCosts(env)
   return VF_LandedCostsBrokerInvoiceEnhancement(env)&&(env.IsCurrentLocalSettingsRUSSIA_SETTINGS||env.IsCurrentLocalSettingsUKRAINE_SETTINGS)
end

def VF_SplitJELinesForPayment(env)
   return env.IsCurrentLocalSettings(GERMANY_SETTINGS)||env.IsCurrentLocalSettings(FRANCE_SETTINGS)
end

def VF_ImportQRCode_APInv_CH(env)
   return env.IsCurrentLocalSettings(SWITZERLAND_SETTINGS)
end

def VF_BatchAutomaticCreation(env)
   return VF_RU_DeferredTax(env)
end

def VF_RU_DeferredTax(env)
   return env.IsCurrentLocalSettings(RUSSIA_SETTINGS)
end

def VF_TransportationDocument(env)
   return env.IsCurrentLocalSettings(ARGENTINA_SETTINGS)
end

def VF_ElectronicInvoiceHU(env)
   return env.IsCurrentLocalSettings(HUNGARY_SETTINGS)
end

def VF_SplitPaymentPL(env)
   return env.IsCurrentLocalSettings(POLAND_SETTINGS)
end

def VF_FixedAssetsEReport(env)
   return env.IsCurrentLocalSettings(RUSSIA_SETTINGS)
end

def VF_TaxInFirstInstallment(env)
   return env.IsCurrentLocalSettings(BRAZIL_SETTINGS)
end

def VF_RU_DownPayment_inFC(env)
   return env.IsCurrentLocalSettings(RUSSIA_SETTINGS)
end

def VF_EnableCustomerAccounting(env)
   return env.IsCurrentLocalSettings(SINGAPORE_SETTINGS)
end

def VF_UK_MakeTaxDigital(env)
   return env.IsCurrentLocalSettings(UK_SETTINGS)&&env.OADMGetColStr(OADM_MTD_ENABLED)==SBOString(VAL_YES)
end

def VF_UK_BASReporting(env)
   return env.IsCurrentLocalSettings(UK_SETTINGS)&&env.OADMGetColStr(OADM_USE_EXT_REPORTING)==SBOString(VAL_YES)&&VF_UK_MakeTaxDigital(env)
end

def VF_ElectronicReportingUK(env)
   return VF_UK_MakeTaxDigital(env)
end

def VF_EnablePassportEngine(env)
   return env.OADMGetColStr(OADM_VOLUME_LICENSING)==SBOString(VAL_YES)
end



