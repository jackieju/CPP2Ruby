require 'test_helper'

class OjdtsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ojdt = ojdts(:one)
  end

  test "should get index" do
    get ojdts_url
    assert_response :success
  end

  test "should get new" do
    get new_ojdt_url
    assert_response :success
  end

  test "should create ojdt" do
    assert_difference('Ojdt.count') do
      post ojdts_url, params: { ojdt: { AdjTran: @ojdt.AdjTran, AgrNo: @ojdt.AgrNo, Approver: @ojdt.Approver, AttNum: @ojdt.AttNum, AutoStorno: @ojdt.AutoStorno, AutoVAT: @ojdt.AutoVAT, AutoWT: @ojdt.AutoWT, BaseAmnt: @ojdt.BaseAmnt, BaseAmntFC: @ojdt.BaseAmntFC, BaseAmntSC: @ojdt.BaseAmntSC, BaseRef: @ojdt.BaseRef, BaseTrans: @ojdt.BaseTrans, BaseVtAt: @ojdt.BaseVtAt, BaseVtAtFC: @ojdt.BaseVtAtFC, BaseVtAtSC: @ojdt.BaseVtAtSC, BatchNum: @ojdt.BatchNum, BlockDunn: @ojdt.BlockDunn, BtfLine: @ojdt.BtfLine, BtfStatus: @ojdt.BtfStatus, CIG: @ojdt.CIG, CUP: @ojdt.CUP, CertifNum: @ojdt.CertifNum, Corisptivi: @ojdt.Corisptivi, CreateDate: @ojdt.CreateDate, CreateTime: @ojdt.CreateTime, CreatedBy: @ojdt.CreatedBy, Creator: @ojdt.Creator, DataSource: @ojdt.DataSource, DeferedTax: @ojdt.DeferedTax, DocSeries: @ojdt.DocSeries, DocType: @ojdt.DocType, DueDate: @ojdt.DueDate, FcTotal: @ojdt.FcTotal, FinncPriod: @ojdt.FinncPriod, FolioNum: @ojdt.FolioNum, FolioPref: @ojdt.FolioPref, GenRegNo: @ojdt.GenRegNo, Indicator: @ojdt.Indicator, KeyVersion: @ojdt.KeyVersion, LocTotal: @ojdt.LocTotal, Location: @ojdt.Location, LogInstanc: @ojdt.LogInstanc, MatType: @ojdt.MatType, Memo: @ojdt.Memo, Number: @ojdt.Number, ObjType: @ojdt.ObjType, OperatCode: @ojdt.OperatCode, OrignCurr: @ojdt.OrignCurr, PCAddition: @ojdt.PCAddition, Printed: @ojdt.Printed, Project: @ojdt.Project, RG23APart2: @ojdt.RG23APart2, RG23CPart2: @ojdt.RG23CPart2, Ref1: @ojdt.Ref1, Ref2: @ojdt.Ref2, Ref3: @ojdt.Ref3, RefDate: @ojdt.RefDate, RefndRprt: @ojdt.RefndRprt, Report347: @ojdt.Report347, ReportEU: @ojdt.ReportEU, ResidenNum: @ojdt.ResidenNum, RevSource: @ojdt.RevSource, SPSrcDLN: @ojdt.SPSrcDLN, SPSrcID: @ojdt.SPSrcID, SPSrcType: @ojdt.SPSrcType, SSIExmpt: @ojdt.SSIExmpt, SeqCode: @ojdt.SeqCode, SeqNum: @ojdt.SeqNum, Serial: @ojdt.Serial, Series: @ojdt.Series, SeriesStr: @ojdt.SeriesStr, SignDigest: @ojdt.SignDigest, SignMsg: @ojdt.SignMsg, StampTax: @ojdt.StampTax, StornoDate: @ojdt.StornoDate, StornoToTr: @ojdt.StornoToTr, SubStr: @ojdt.SubStr, SupplCode: @ojdt.SupplCode, SysTotal: @ojdt.SysTotal, TaxDate: @ojdt.TaxDate, TransCode: @ojdt.TransCode, TransCurr: @ojdt.TransCurr, TransId: @ojdt.TransId, TransRate: @ojdt.TransRate, TransType: @ojdt.TransType, UpdateDate: @ojdt.UpdateDate, UserSign: @ojdt.UserSign, UserSign2: @ojdt.UserSign2, VatDate: @ojdt.VatDate, VersionNum: @ojdt.VersionNum, WTApplied: @ojdt.WTApplied, WTAppliedF: @ojdt.WTAppliedF, WTAppliedS: @ojdt.WTAppliedS, WTSum: @ojdt.WTSum, WTSumFC: @ojdt.WTSumFC, WTSumSC: @ojdt.WTSumSC } }
    end

    assert_redirected_to ojdt_url(Ojdt.last)
  end

  test "should show ojdt" do
    get ojdt_url(@ojdt)
    assert_response :success
  end

  test "should get edit" do
    get edit_ojdt_url(@ojdt)
    assert_response :success
  end

  test "should update ojdt" do
    patch ojdt_url(@ojdt), params: { ojdt: { AdjTran: @ojdt.AdjTran, AgrNo: @ojdt.AgrNo, Approver: @ojdt.Approver, AttNum: @ojdt.AttNum, AutoStorno: @ojdt.AutoStorno, AutoVAT: @ojdt.AutoVAT, AutoWT: @ojdt.AutoWT, BaseAmnt: @ojdt.BaseAmnt, BaseAmntFC: @ojdt.BaseAmntFC, BaseAmntSC: @ojdt.BaseAmntSC, BaseRef: @ojdt.BaseRef, BaseTrans: @ojdt.BaseTrans, BaseVtAt: @ojdt.BaseVtAt, BaseVtAtFC: @ojdt.BaseVtAtFC, BaseVtAtSC: @ojdt.BaseVtAtSC, BatchNum: @ojdt.BatchNum, BlockDunn: @ojdt.BlockDunn, BtfLine: @ojdt.BtfLine, BtfStatus: @ojdt.BtfStatus, CIG: @ojdt.CIG, CUP: @ojdt.CUP, CertifNum: @ojdt.CertifNum, Corisptivi: @ojdt.Corisptivi, CreateDate: @ojdt.CreateDate, CreateTime: @ojdt.CreateTime, CreatedBy: @ojdt.CreatedBy, Creator: @ojdt.Creator, DataSource: @ojdt.DataSource, DeferedTax: @ojdt.DeferedTax, DocSeries: @ojdt.DocSeries, DocType: @ojdt.DocType, DueDate: @ojdt.DueDate, FcTotal: @ojdt.FcTotal, FinncPriod: @ojdt.FinncPriod, FolioNum: @ojdt.FolioNum, FolioPref: @ojdt.FolioPref, GenRegNo: @ojdt.GenRegNo, Indicator: @ojdt.Indicator, KeyVersion: @ojdt.KeyVersion, LocTotal: @ojdt.LocTotal, Location: @ojdt.Location, LogInstanc: @ojdt.LogInstanc, MatType: @ojdt.MatType, Memo: @ojdt.Memo, Number: @ojdt.Number, ObjType: @ojdt.ObjType, OperatCode: @ojdt.OperatCode, OrignCurr: @ojdt.OrignCurr, PCAddition: @ojdt.PCAddition, Printed: @ojdt.Printed, Project: @ojdt.Project, RG23APart2: @ojdt.RG23APart2, RG23CPart2: @ojdt.RG23CPart2, Ref1: @ojdt.Ref1, Ref2: @ojdt.Ref2, Ref3: @ojdt.Ref3, RefDate: @ojdt.RefDate, RefndRprt: @ojdt.RefndRprt, Report347: @ojdt.Report347, ReportEU: @ojdt.ReportEU, ResidenNum: @ojdt.ResidenNum, RevSource: @ojdt.RevSource, SPSrcDLN: @ojdt.SPSrcDLN, SPSrcID: @ojdt.SPSrcID, SPSrcType: @ojdt.SPSrcType, SSIExmpt: @ojdt.SSIExmpt, SeqCode: @ojdt.SeqCode, SeqNum: @ojdt.SeqNum, Serial: @ojdt.Serial, Series: @ojdt.Series, SeriesStr: @ojdt.SeriesStr, SignDigest: @ojdt.SignDigest, SignMsg: @ojdt.SignMsg, StampTax: @ojdt.StampTax, StornoDate: @ojdt.StornoDate, StornoToTr: @ojdt.StornoToTr, SubStr: @ojdt.SubStr, SupplCode: @ojdt.SupplCode, SysTotal: @ojdt.SysTotal, TaxDate: @ojdt.TaxDate, TransCode: @ojdt.TransCode, TransCurr: @ojdt.TransCurr, TransId: @ojdt.TransId, TransRate: @ojdt.TransRate, TransType: @ojdt.TransType, UpdateDate: @ojdt.UpdateDate, UserSign: @ojdt.UserSign, UserSign2: @ojdt.UserSign2, VatDate: @ojdt.VatDate, VersionNum: @ojdt.VersionNum, WTApplied: @ojdt.WTApplied, WTAppliedF: @ojdt.WTAppliedF, WTAppliedS: @ojdt.WTAppliedS, WTSum: @ojdt.WTSum, WTSumFC: @ojdt.WTSumFC, WTSumSC: @ojdt.WTSumSC } }
    assert_redirected_to ojdt_url(@ojdt)
  end

  test "should destroy ojdt" do
    assert_difference('Ojdt.count', -1) do
      delete ojdt_url(@ojdt)
    end

    assert_redirected_to ojdts_url
  end
end
