require "application_system_test_case"

class OjdtsTest < ApplicationSystemTestCase
  setup do
    @ojdt = ojdts(:one)
  end

  test "visiting the index" do
    visit ojdts_url
    assert_selector "h1", text: "Ojdts"
  end

  test "creating a Ojdt" do
    visit ojdts_url
    click_on "New Ojdt"

    fill_in "Adjtran", with: @ojdt.AdjTran
    fill_in "Agrno", with: @ojdt.AgrNo
    fill_in "Approver", with: @ojdt.Approver
    fill_in "Attnum", with: @ojdt.AttNum
    fill_in "Autostorno", with: @ojdt.AutoStorno
    fill_in "Autovat", with: @ojdt.AutoVAT
    fill_in "Autowt", with: @ojdt.AutoWT
    fill_in "Baseamnt", with: @ojdt.BaseAmnt
    fill_in "Baseamntfc", with: @ojdt.BaseAmntFC
    fill_in "Baseamntsc", with: @ojdt.BaseAmntSC
    fill_in "Baseref", with: @ojdt.BaseRef
    fill_in "Basetrans", with: @ojdt.BaseTrans
    fill_in "Basevtat", with: @ojdt.BaseVtAt
    fill_in "Basevtatfc", with: @ojdt.BaseVtAtFC
    fill_in "Basevtatsc", with: @ojdt.BaseVtAtSC
    fill_in "Batchnum", with: @ojdt.BatchNum
    fill_in "Blockdunn", with: @ojdt.BlockDunn
    fill_in "Btfline", with: @ojdt.BtfLine
    fill_in "Btfstatus", with: @ojdt.BtfStatus
    fill_in "Cig", with: @ojdt.CIG
    fill_in "Cup", with: @ojdt.CUP
    fill_in "Certifnum", with: @ojdt.CertifNum
    fill_in "Corisptivi", with: @ojdt.Corisptivi
    fill_in "Createdate", with: @ojdt.CreateDate
    fill_in "Createtime", with: @ojdt.CreateTime
    fill_in "Createdby", with: @ojdt.CreatedBy
    fill_in "Creator", with: @ojdt.Creator
    fill_in "Datasource", with: @ojdt.DataSource
    fill_in "Deferedtax", with: @ojdt.DeferedTax
    fill_in "Docseries", with: @ojdt.DocSeries
    fill_in "Doctype", with: @ojdt.DocType
    fill_in "Duedate", with: @ojdt.DueDate
    fill_in "Fctotal", with: @ojdt.FcTotal
    fill_in "Finncpriod", with: @ojdt.FinncPriod
    fill_in "Folionum", with: @ojdt.FolioNum
    fill_in "Foliopref", with: @ojdt.FolioPref
    fill_in "Genregno", with: @ojdt.GenRegNo
    fill_in "Indicator", with: @ojdt.Indicator
    fill_in "Keyversion", with: @ojdt.KeyVersion
    fill_in "Loctotal", with: @ojdt.LocTotal
    fill_in "Location", with: @ojdt.Location
    fill_in "Loginstanc", with: @ojdt.LogInstanc
    fill_in "Mattype", with: @ojdt.MatType
    fill_in "Memo", with: @ojdt.Memo
    fill_in "Number", with: @ojdt.Number
    fill_in "Objtype", with: @ojdt.ObjType
    fill_in "Operatcode", with: @ojdt.OperatCode
    fill_in "Origncurr", with: @ojdt.OrignCurr
    fill_in "Pcaddition", with: @ojdt.PCAddition
    fill_in "Printed", with: @ojdt.Printed
    fill_in "Project", with: @ojdt.Project
    fill_in "Rg23apart2", with: @ojdt.RG23APart2
    fill_in "Rg23cpart2", with: @ojdt.RG23CPart2
    fill_in "Ref1", with: @ojdt.Ref1
    fill_in "Ref2", with: @ojdt.Ref2
    fill_in "Ref3", with: @ojdt.Ref3
    fill_in "Refdate", with: @ojdt.RefDate
    fill_in "Refndrprt", with: @ojdt.RefndRprt
    fill_in "Report347", with: @ojdt.Report347
    fill_in "Reporteu", with: @ojdt.ReportEU
    fill_in "Residennum", with: @ojdt.ResidenNum
    fill_in "Revsource", with: @ojdt.RevSource
    fill_in "Spsrcdln", with: @ojdt.SPSrcDLN
    fill_in "Spsrcid", with: @ojdt.SPSrcID
    fill_in "Spsrctype", with: @ojdt.SPSrcType
    fill_in "Ssiexmpt", with: @ojdt.SSIExmpt
    fill_in "Seqcode", with: @ojdt.SeqCode
    fill_in "Seqnum", with: @ojdt.SeqNum
    fill_in "Serial", with: @ojdt.Serial
    fill_in "Series", with: @ojdt.Series
    fill_in "Seriesstr", with: @ojdt.SeriesStr
    fill_in "Signdigest", with: @ojdt.SignDigest
    fill_in "Signmsg", with: @ojdt.SignMsg
    fill_in "Stamptax", with: @ojdt.StampTax
    fill_in "Stornodate", with: @ojdt.StornoDate
    fill_in "Stornototr", with: @ojdt.StornoToTr
    fill_in "Substr", with: @ojdt.SubStr
    fill_in "Supplcode", with: @ojdt.SupplCode
    fill_in "Systotal", with: @ojdt.SysTotal
    fill_in "Taxdate", with: @ojdt.TaxDate
    fill_in "Transcode", with: @ojdt.TransCode
    fill_in "Transcurr", with: @ojdt.TransCurr
    fill_in "Transid", with: @ojdt.TransId
    fill_in "Transrate", with: @ojdt.TransRate
    fill_in "Transtype", with: @ojdt.TransType
    fill_in "Updatedate", with: @ojdt.UpdateDate
    fill_in "Usersign", with: @ojdt.UserSign
    fill_in "Usersign2", with: @ojdt.UserSign2
    fill_in "Vatdate", with: @ojdt.VatDate
    fill_in "Versionnum", with: @ojdt.VersionNum
    fill_in "Wtapplied", with: @ojdt.WTApplied
    fill_in "Wtappliedf", with: @ojdt.WTAppliedF
    fill_in "Wtapplieds", with: @ojdt.WTAppliedS
    fill_in "Wtsum", with: @ojdt.WTSum
    fill_in "Wtsumfc", with: @ojdt.WTSumFC
    fill_in "Wtsumsc", with: @ojdt.WTSumSC
    click_on "Create Ojdt"

    assert_text "Ojdt was successfully created"
    click_on "Back"
  end

  test "updating a Ojdt" do
    visit ojdts_url
    click_on "Edit", match: :first

    fill_in "Adjtran", with: @ojdt.AdjTran
    fill_in "Agrno", with: @ojdt.AgrNo
    fill_in "Approver", with: @ojdt.Approver
    fill_in "Attnum", with: @ojdt.AttNum
    fill_in "Autostorno", with: @ojdt.AutoStorno
    fill_in "Autovat", with: @ojdt.AutoVAT
    fill_in "Autowt", with: @ojdt.AutoWT
    fill_in "Baseamnt", with: @ojdt.BaseAmnt
    fill_in "Baseamntfc", with: @ojdt.BaseAmntFC
    fill_in "Baseamntsc", with: @ojdt.BaseAmntSC
    fill_in "Baseref", with: @ojdt.BaseRef
    fill_in "Basetrans", with: @ojdt.BaseTrans
    fill_in "Basevtat", with: @ojdt.BaseVtAt
    fill_in "Basevtatfc", with: @ojdt.BaseVtAtFC
    fill_in "Basevtatsc", with: @ojdt.BaseVtAtSC
    fill_in "Batchnum", with: @ojdt.BatchNum
    fill_in "Blockdunn", with: @ojdt.BlockDunn
    fill_in "Btfline", with: @ojdt.BtfLine
    fill_in "Btfstatus", with: @ojdt.BtfStatus
    fill_in "Cig", with: @ojdt.CIG
    fill_in "Cup", with: @ojdt.CUP
    fill_in "Certifnum", with: @ojdt.CertifNum
    fill_in "Corisptivi", with: @ojdt.Corisptivi
    fill_in "Createdate", with: @ojdt.CreateDate
    fill_in "Createtime", with: @ojdt.CreateTime
    fill_in "Createdby", with: @ojdt.CreatedBy
    fill_in "Creator", with: @ojdt.Creator
    fill_in "Datasource", with: @ojdt.DataSource
    fill_in "Deferedtax", with: @ojdt.DeferedTax
    fill_in "Docseries", with: @ojdt.DocSeries
    fill_in "Doctype", with: @ojdt.DocType
    fill_in "Duedate", with: @ojdt.DueDate
    fill_in "Fctotal", with: @ojdt.FcTotal
    fill_in "Finncpriod", with: @ojdt.FinncPriod
    fill_in "Folionum", with: @ojdt.FolioNum
    fill_in "Foliopref", with: @ojdt.FolioPref
    fill_in "Genregno", with: @ojdt.GenRegNo
    fill_in "Indicator", with: @ojdt.Indicator
    fill_in "Keyversion", with: @ojdt.KeyVersion
    fill_in "Loctotal", with: @ojdt.LocTotal
    fill_in "Location", with: @ojdt.Location
    fill_in "Loginstanc", with: @ojdt.LogInstanc
    fill_in "Mattype", with: @ojdt.MatType
    fill_in "Memo", with: @ojdt.Memo
    fill_in "Number", with: @ojdt.Number
    fill_in "Objtype", with: @ojdt.ObjType
    fill_in "Operatcode", with: @ojdt.OperatCode
    fill_in "Origncurr", with: @ojdt.OrignCurr
    fill_in "Pcaddition", with: @ojdt.PCAddition
    fill_in "Printed", with: @ojdt.Printed
    fill_in "Project", with: @ojdt.Project
    fill_in "Rg23apart2", with: @ojdt.RG23APart2
    fill_in "Rg23cpart2", with: @ojdt.RG23CPart2
    fill_in "Ref1", with: @ojdt.Ref1
    fill_in "Ref2", with: @ojdt.Ref2
    fill_in "Ref3", with: @ojdt.Ref3
    fill_in "Refdate", with: @ojdt.RefDate
    fill_in "Refndrprt", with: @ojdt.RefndRprt
    fill_in "Report347", with: @ojdt.Report347
    fill_in "Reporteu", with: @ojdt.ReportEU
    fill_in "Residennum", with: @ojdt.ResidenNum
    fill_in "Revsource", with: @ojdt.RevSource
    fill_in "Spsrcdln", with: @ojdt.SPSrcDLN
    fill_in "Spsrcid", with: @ojdt.SPSrcID
    fill_in "Spsrctype", with: @ojdt.SPSrcType
    fill_in "Ssiexmpt", with: @ojdt.SSIExmpt
    fill_in "Seqcode", with: @ojdt.SeqCode
    fill_in "Seqnum", with: @ojdt.SeqNum
    fill_in "Serial", with: @ojdt.Serial
    fill_in "Series", with: @ojdt.Series
    fill_in "Seriesstr", with: @ojdt.SeriesStr
    fill_in "Signdigest", with: @ojdt.SignDigest
    fill_in "Signmsg", with: @ojdt.SignMsg
    fill_in "Stamptax", with: @ojdt.StampTax
    fill_in "Stornodate", with: @ojdt.StornoDate
    fill_in "Stornototr", with: @ojdt.StornoToTr
    fill_in "Substr", with: @ojdt.SubStr
    fill_in "Supplcode", with: @ojdt.SupplCode
    fill_in "Systotal", with: @ojdt.SysTotal
    fill_in "Taxdate", with: @ojdt.TaxDate
    fill_in "Transcode", with: @ojdt.TransCode
    fill_in "Transcurr", with: @ojdt.TransCurr
    fill_in "Transid", with: @ojdt.TransId
    fill_in "Transrate", with: @ojdt.TransRate
    fill_in "Transtype", with: @ojdt.TransType
    fill_in "Updatedate", with: @ojdt.UpdateDate
    fill_in "Usersign", with: @ojdt.UserSign
    fill_in "Usersign2", with: @ojdt.UserSign2
    fill_in "Vatdate", with: @ojdt.VatDate
    fill_in "Versionnum", with: @ojdt.VersionNum
    fill_in "Wtapplied", with: @ojdt.WTApplied
    fill_in "Wtappliedf", with: @ojdt.WTAppliedF
    fill_in "Wtapplieds", with: @ojdt.WTAppliedS
    fill_in "Wtsum", with: @ojdt.WTSum
    fill_in "Wtsumfc", with: @ojdt.WTSumFC
    fill_in "Wtsumsc", with: @ojdt.WTSumSC
    click_on "Update Ojdt"

    assert_text "Ojdt was successfully updated"
    click_on "Back"
  end

  test "destroying a Ojdt" do
    visit ojdts_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Ojdt was successfully destroyed"
  end
end
