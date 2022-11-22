#require "common.rb"

$ar_classdefs = [
    "T", # for cpp template
    "std",
    "SJournalKeys",
    "CBusinessObject",
    "PDAG",
    "TCHAR",
    "CBizEnv",
    "SBOString",
    "SBOErr",
    "DBD_Tables",
    "CManualDistributionRuleObject",
    "CWTAllCurBaseCalcParams",
    "CJDTWTInfo",
    "AccountsConstArray",
    "ObjectAbbrevsMap",
    "CBusinessService",
    "CJDTStornoExtraInfoCreator",
    "ArcDeletePrefs",
    "CJECompression",
    "ObjectWTaxInfo",
    "DBQRetrieveStatement",
    "CMatchData",
    "MONEY",
    "BPBalanceChangeLogDataArr",
    "FCRoundingStruct",
    "StdMap",
    "CostAccountingFieldMap",
    #"bool",
    "AccountsArray",
    # pojdt.c
    "CPaymentDoc",
    # __DMBC_DAG.cpp
    "CSystemBusinessObject",
    "SBOXmlParser",
    "CDBMEnv",
    "CORE_BYTE",
    "DAG_RecordStatusList",
    "wchar_t",
    "DBM_ChangedColumn",
    "CReconUpgMgr",
    "CSystemMatchManager",
    "CCompanyInfo",
    "CItemMasterData",
    "MONEY_RoundRule",
    "IRoundingData",
    "PDBD_Cond",
    "PDBD_Upd",
    "BGSDataPtr",
    "TotalsPair",
    "CINVLineAgreementInfoMap",
    "Currency",
    "DocSubTypeStruct",
    "DBD_TablesList",
    "DBD_CondTables",
    "DBD_Conditions",
    "PDBD_Sort",
    "PDBD_Group",
    "PDBD_Res",
    "PDBD_Filter",
    "DBMCconnBase",
    "PDBD_Params",
    "DBM_PreparedStatementType",
    "DBMCSqlStatement",
    "DBM_CA",
    "DBM_BindType"
]

$unusableType =[
    "export",
    "__dllexport__",
    
    "typename"
    
]

#files don't include
$exclude_file=[
    "stdio",
    "stdio.h",
    "malloc.h",
    "windows.h",
    "sql.h",
    "sqlext.h",
    "__DBM.*\\.h",
    "__CORE_OS.h",
    "WinCrypt.h",
    "Assert.h",
    "WWMap.h",
    "ScopeGuard.h",
    "TaxFormulaCombinationCache.h",
    "_FU_P_CBusinessFormsMgr.h",
    "_BusinessObjectBase.h"
]
begin
    p "loading '#{Dir.pwd}/user_classdefs.rb'"
  #  $LOAD_PATH<<Dir.pwd
    load "#{Dir.pwd}/user_classdefs.rb"
  #  require "#{Dir.pwd}/user_classdefs.rb"
    
     $ar_classdefs.concat($user_classdefs )
     $unusableType.concat($user_unusableTypes)
     $exclude_file.concat($user_exclude_files)
rescue Exception=>e
    p e.inspect
    p $LOAD_PAHT.inspect
    t=<<END
    $user_classdefs = [
    ]
    $user_unusableTypes=[
    ]
    $user_exclude_files=[
    ]
END
    write_class("user_classdefs.rb", t)
    
end