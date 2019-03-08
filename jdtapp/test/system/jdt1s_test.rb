require "application_system_test_case"

class Jdt1sTest < ApplicationSystemTestCase
  setup do
    @jdt1 = jdt1s(:one)
  end

  test "visiting the index" do
    visit jdt1s_url
    assert_selector "h1", text: "Jdt1s"
  end

  test "creating a Jdt1" do
    visit jdt1s_url
    click_on "New Jdt1"

    fill_in "Account", with: @jdt1.Account
    fill_in "Adjtran", with: @jdt1.AdjTran
    fill_in "Bplid", with: @jdt1.BPLId
    fill_in "Bplname", with: @jdt1.BPLName
    fill_in "Balduecred", with: @jdt1.BalDueCred
    fill_in "Balduedeb", with: @jdt1.BalDueDeb
    fill_in "Balfccred", with: @jdt1.BalFcCred
    fill_in "Balfcdeb", with: @jdt1.BalFcDeb
    fill_in "Balsccred", with: @jdt1.BalScCred
    fill_in "Balscdeb", with: @jdt1.BalScDeb
    fill_in "Baseref", with: @jdt1.BaseRef
    fill_in "Basesum", with: @jdt1.BaseSum
    fill_in "Batchnum", with: @jdt1.BatchNum
    fill_in "Cig", with: @jdt1.CIG
    fill_in "Cup", with: @jdt1.CUP
    fill_in "Cenvatcom", with: @jdt1.CenVatCom
    fill_in "Checkabs", with: @jdt1.CheckAbs
    fill_in "Closed", with: @jdt1.Closed
    fill_in "Clsintp", with: @jdt1.ClsInTP
    fill_in "Contraact", with: @jdt1.ContraAct
    fill_in "Createdby", with: @jdt1.CreatedBy
    fill_in "Credit", with: @jdt1.Credit
    fill_in "Debcred", with: @jdt1.DebCred
    fill_in "Debit", with: @jdt1.Debit
    fill_in "Dprid", with: @jdt1.DprId
    fill_in "Duedate", with: @jdt1.DueDate
    fill_in "Dundate", with: @jdt1.DunDate
    fill_in "Dunwizblck", with: @jdt1.DunWizBlck
    fill_in "Dunnlevel", with: @jdt1.DunnLevel
    fill_in "Equvatrate", with: @jdt1.EquVatRate
    fill_in "Equvatsum", with: @jdt1.EquVatSum
    fill_in "Extrmatch", with: @jdt1.ExtrMatch
    fill_in "Fccredit", with: @jdt1.FCCredit
    fill_in "Fccurrency", with: @jdt1.FCCurrency
    fill_in "Fcdebit", with: @jdt1.FCDebit
    fill_in "Finncpriod", with: @jdt1.FinncPriod
    fill_in "Grossvalfc", with: @jdt1.GrossValFc
    fill_in "Grossvalue", with: @jdt1.GrossValue
    fill_in "Indicator", with: @jdt1.Indicator
    fill_in "Interimtyp", with: @jdt1.InterimTyp
    fill_in "Intrnmatch", with: @jdt1.IntrnMatch
    fill_in "Isnet", with: @jdt1.IsNet
    fill_in "Lictradnum", with: @jdt1.LicTradNum
    fill_in "Linememo", with: @jdt1.LineMemo
    fill_in "Linetype", with: @jdt1.LineType
    fill_in "Line id", with: @jdt1.Line_ID
    fill_in "Location", with: @jdt1.Location
    fill_in "Loginstanc", with: @jdt1.LogInstanc
    fill_in "Lvlupddate", with: @jdt1.LvlUpdDate
    fill_in "Mientry", with: @jdt1.MIEntry
    fill_in "Miventry", with: @jdt1.MIVEntry
    fill_in "Mattype", with: @jdt1.MatType
    fill_in "Matchref", with: @jdt1.MatchRef
    fill_in "Mthdate", with: @jdt1.MthDate
    fill_in "Multmatch", with: @jdt1.MultMatch
    fill_in "Objtype", with: @jdt1.ObjType
    fill_in "Ocrcode2", with: @jdt1.OcrCode2
    fill_in "Ocrcode3", with: @jdt1.OcrCode3
    fill_in "Ocrcode4", with: @jdt1.OcrCode4
    fill_in "Ocrcode5", with: @jdt1.OcrCode5
    fill_in "Ordered", with: @jdt1.Ordered
    fill_in "Payblckref", with: @jdt1.PayBlckRef
    fill_in "Payblock", with: @jdt1.PayBlock
    fill_in "Paymentref", with: @jdt1.PaymentRef
    fill_in "Profitcode", with: @jdt1.ProfitCode
    fill_in "Project", with: @jdt1.Project
    fill_in "Pstngtype", with: @jdt1.PstngType
    fill_in "Ref1", with: @jdt1.Ref1
    fill_in "Ref2", with: @jdt1.Ref2
    fill_in "Ref2date", with: @jdt1.Ref2Date
    fill_in "Ref3line", with: @jdt1.Ref3Line
    fill_in "Refdate", with: @jdt1.RefDate
    fill_in "Rellineid", with: @jdt1.RelLineID
    fill_in "Reltransid", with: @jdt1.RelTransId
    fill_in "Reltype", with: @jdt1.RelType
    fill_in "Revsource", with: @jdt1.RevSource
    fill_in "Sledgerf", with: @jdt1.SLEDGERF
    fill_in "Sysbasesum", with: @jdt1.SYSBaseSum
    fill_in "Syscred", with: @jdt1.SYSCred
    fill_in "Sysdeb", with: @jdt1.SYSDeb
    fill_in "Sysequsum", with: @jdt1.SYSEquSum
    fill_in "Systvat", with: @jdt1.SYSTVat
    fill_in "Sysvatsum", with: @jdt1.SYSVatSum
    fill_in "Sequencenr", with: @jdt1.SequenceNr
    fill_in "Shortname", with: @jdt1.ShortName
    fill_in "Sourceid", with: @jdt1.SourceID
    fill_in "Sourceline", with: @jdt1.SourceLine
    fill_in "Stacode", with: @jdt1.StaCode
    fill_in "Statype", with: @jdt1.StaType
    fill_in "Stornoacc", with: @jdt1.StornoAcc
    fill_in "Systemrate", with: @jdt1.SystemRate
    fill_in "Taxcode", with: @jdt1.TaxCode
    fill_in "Taxdate", with: @jdt1.TaxDate
    fill_in "Taxpostacc", with: @jdt1.TaxPostAcc
    fill_in "Taxtype", with: @jdt1.TaxType
    fill_in "Tomthsum", with: @jdt1.ToMthSum
    fill_in "Totalvat", with: @jdt1.TotalVat
    fill_in "Transcode", with: @jdt1.TransCode
    fill_in "Transid", with: @jdt1.TransId
    fill_in "Transtype", with: @jdt1.TransType
    fill_in "Usersign", with: @jdt1.UserSign
    fill_in "Validfrom", with: @jdt1.ValidFrom
    fill_in "Validfrom2", with: @jdt1.ValidFrom2
    fill_in "Validfrom3", with: @jdt1.ValidFrom3
    fill_in "Validfrom4", with: @jdt1.ValidFrom4
    fill_in "Validfrom5", with: @jdt1.ValidFrom5
    fill_in "Vatamount", with: @jdt1.VatAmount
    fill_in "Vatdate", with: @jdt1.VatDate
    fill_in "Vatgroup", with: @jdt1.VatGroup
    fill_in "Vatline", with: @jdt1.VatLine
    fill_in "Vatrate", with: @jdt1.VatRate
    fill_in "Vatregnum", with: @jdt1.VatRegNum
    fill_in "Wtapplied", with: @jdt1.WTApplied
    fill_in "Wtappliedf", with: @jdt1.WTAppliedF
    fill_in "Wtapplieds", with: @jdt1.WTAppliedS
    fill_in "Wtliable", with: @jdt1.WTLiable
    fill_in "Wtline", with: @jdt1.WTLine
    fill_in "Wtsum", with: @jdt1.WTSum
    fill_in "Wtsumfc", with: @jdt1.WTSumFC
    fill_in "Wtsumsc", with: @jdt1.WTSumSC
    fill_in "Wtaxcode", with: @jdt1.WTaxCode
    click_on "Create Jdt1"

    assert_text "Jdt1 was successfully created"
    click_on "Back"
  end

  test "updating a Jdt1" do
    visit jdt1s_url
    click_on "Edit", match: :first

    fill_in "Account", with: @jdt1.Account
    fill_in "Adjtran", with: @jdt1.AdjTran
    fill_in "Bplid", with: @jdt1.BPLId
    fill_in "Bplname", with: @jdt1.BPLName
    fill_in "Balduecred", with: @jdt1.BalDueCred
    fill_in "Balduedeb", with: @jdt1.BalDueDeb
    fill_in "Balfccred", with: @jdt1.BalFcCred
    fill_in "Balfcdeb", with: @jdt1.BalFcDeb
    fill_in "Balsccred", with: @jdt1.BalScCred
    fill_in "Balscdeb", with: @jdt1.BalScDeb
    fill_in "Baseref", with: @jdt1.BaseRef
    fill_in "Basesum", with: @jdt1.BaseSum
    fill_in "Batchnum", with: @jdt1.BatchNum
    fill_in "Cig", with: @jdt1.CIG
    fill_in "Cup", with: @jdt1.CUP
    fill_in "Cenvatcom", with: @jdt1.CenVatCom
    fill_in "Checkabs", with: @jdt1.CheckAbs
    fill_in "Closed", with: @jdt1.Closed
    fill_in "Clsintp", with: @jdt1.ClsInTP
    fill_in "Contraact", with: @jdt1.ContraAct
    fill_in "Createdby", with: @jdt1.CreatedBy
    fill_in "Credit", with: @jdt1.Credit
    fill_in "Debcred", with: @jdt1.DebCred
    fill_in "Debit", with: @jdt1.Debit
    fill_in "Dprid", with: @jdt1.DprId
    fill_in "Duedate", with: @jdt1.DueDate
    fill_in "Dundate", with: @jdt1.DunDate
    fill_in "Dunwizblck", with: @jdt1.DunWizBlck
    fill_in "Dunnlevel", with: @jdt1.DunnLevel
    fill_in "Equvatrate", with: @jdt1.EquVatRate
    fill_in "Equvatsum", with: @jdt1.EquVatSum
    fill_in "Extrmatch", with: @jdt1.ExtrMatch
    fill_in "Fccredit", with: @jdt1.FCCredit
    fill_in "Fccurrency", with: @jdt1.FCCurrency
    fill_in "Fcdebit", with: @jdt1.FCDebit
    fill_in "Finncpriod", with: @jdt1.FinncPriod
    fill_in "Grossvalfc", with: @jdt1.GrossValFc
    fill_in "Grossvalue", with: @jdt1.GrossValue
    fill_in "Indicator", with: @jdt1.Indicator
    fill_in "Interimtyp", with: @jdt1.InterimTyp
    fill_in "Intrnmatch", with: @jdt1.IntrnMatch
    fill_in "Isnet", with: @jdt1.IsNet
    fill_in "Lictradnum", with: @jdt1.LicTradNum
    fill_in "Linememo", with: @jdt1.LineMemo
    fill_in "Linetype", with: @jdt1.LineType
    fill_in "Line id", with: @jdt1.Line_ID
    fill_in "Location", with: @jdt1.Location
    fill_in "Loginstanc", with: @jdt1.LogInstanc
    fill_in "Lvlupddate", with: @jdt1.LvlUpdDate
    fill_in "Mientry", with: @jdt1.MIEntry
    fill_in "Miventry", with: @jdt1.MIVEntry
    fill_in "Mattype", with: @jdt1.MatType
    fill_in "Matchref", with: @jdt1.MatchRef
    fill_in "Mthdate", with: @jdt1.MthDate
    fill_in "Multmatch", with: @jdt1.MultMatch
    fill_in "Objtype", with: @jdt1.ObjType
    fill_in "Ocrcode2", with: @jdt1.OcrCode2
    fill_in "Ocrcode3", with: @jdt1.OcrCode3
    fill_in "Ocrcode4", with: @jdt1.OcrCode4
    fill_in "Ocrcode5", with: @jdt1.OcrCode5
    fill_in "Ordered", with: @jdt1.Ordered
    fill_in "Payblckref", with: @jdt1.PayBlckRef
    fill_in "Payblock", with: @jdt1.PayBlock
    fill_in "Paymentref", with: @jdt1.PaymentRef
    fill_in "Profitcode", with: @jdt1.ProfitCode
    fill_in "Project", with: @jdt1.Project
    fill_in "Pstngtype", with: @jdt1.PstngType
    fill_in "Ref1", with: @jdt1.Ref1
    fill_in "Ref2", with: @jdt1.Ref2
    fill_in "Ref2date", with: @jdt1.Ref2Date
    fill_in "Ref3line", with: @jdt1.Ref3Line
    fill_in "Refdate", with: @jdt1.RefDate
    fill_in "Rellineid", with: @jdt1.RelLineID
    fill_in "Reltransid", with: @jdt1.RelTransId
    fill_in "Reltype", with: @jdt1.RelType
    fill_in "Revsource", with: @jdt1.RevSource
    fill_in "Sledgerf", with: @jdt1.SLEDGERF
    fill_in "Sysbasesum", with: @jdt1.SYSBaseSum
    fill_in "Syscred", with: @jdt1.SYSCred
    fill_in "Sysdeb", with: @jdt1.SYSDeb
    fill_in "Sysequsum", with: @jdt1.SYSEquSum
    fill_in "Systvat", with: @jdt1.SYSTVat
    fill_in "Sysvatsum", with: @jdt1.SYSVatSum
    fill_in "Sequencenr", with: @jdt1.SequenceNr
    fill_in "Shortname", with: @jdt1.ShortName
    fill_in "Sourceid", with: @jdt1.SourceID
    fill_in "Sourceline", with: @jdt1.SourceLine
    fill_in "Stacode", with: @jdt1.StaCode
    fill_in "Statype", with: @jdt1.StaType
    fill_in "Stornoacc", with: @jdt1.StornoAcc
    fill_in "Systemrate", with: @jdt1.SystemRate
    fill_in "Taxcode", with: @jdt1.TaxCode
    fill_in "Taxdate", with: @jdt1.TaxDate
    fill_in "Taxpostacc", with: @jdt1.TaxPostAcc
    fill_in "Taxtype", with: @jdt1.TaxType
    fill_in "Tomthsum", with: @jdt1.ToMthSum
    fill_in "Totalvat", with: @jdt1.TotalVat
    fill_in "Transcode", with: @jdt1.TransCode
    fill_in "Transid", with: @jdt1.TransId
    fill_in "Transtype", with: @jdt1.TransType
    fill_in "Usersign", with: @jdt1.UserSign
    fill_in "Validfrom", with: @jdt1.ValidFrom
    fill_in "Validfrom2", with: @jdt1.ValidFrom2
    fill_in "Validfrom3", with: @jdt1.ValidFrom3
    fill_in "Validfrom4", with: @jdt1.ValidFrom4
    fill_in "Validfrom5", with: @jdt1.ValidFrom5
    fill_in "Vatamount", with: @jdt1.VatAmount
    fill_in "Vatdate", with: @jdt1.VatDate
    fill_in "Vatgroup", with: @jdt1.VatGroup
    fill_in "Vatline", with: @jdt1.VatLine
    fill_in "Vatrate", with: @jdt1.VatRate
    fill_in "Vatregnum", with: @jdt1.VatRegNum
    fill_in "Wtapplied", with: @jdt1.WTApplied
    fill_in "Wtappliedf", with: @jdt1.WTAppliedF
    fill_in "Wtapplieds", with: @jdt1.WTAppliedS
    fill_in "Wtliable", with: @jdt1.WTLiable
    fill_in "Wtline", with: @jdt1.WTLine
    fill_in "Wtsum", with: @jdt1.WTSum
    fill_in "Wtsumfc", with: @jdt1.WTSumFC
    fill_in "Wtsumsc", with: @jdt1.WTSumSC
    fill_in "Wtaxcode", with: @jdt1.WTaxCode
    click_on "Update Jdt1"

    assert_text "Jdt1 was successfully updated"
    click_on "Back"
  end

  test "destroying a Jdt1" do
    visit jdt1s_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Jdt1 was successfully destroyed"
  end
end
