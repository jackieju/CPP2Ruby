require 'test_helper'

class OjdtaControllerTest < ActionController::TestCase
  setup do
    @ojdtum = ojdta(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ojdta)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ojdtum" do
    assert_difference('Ojdtum.count') do
      post :create, ojdtum: { AdjTran: @ojdtum.AdjTran, AgrNo: @ojdtum.AgrNo, Approver: @ojdtum.Approver, AttNum: @ojdtum.AttNum, AutoStorno: @ojdtum.AutoStorno, AutoVAT: @ojdtum.AutoVAT, AutoWT: @ojdtum.AutoWT, BaseAmnt: @ojdtum.BaseAmnt, BaseAmntFC: @ojdtum.BaseAmntFC, BaseAmntSC: @ojdtum.BaseAmntSC, BaseRef: @ojdtum.BaseRef, BaseTrans: @ojdtum.BaseTrans, BaseVtAt: @ojdtum.BaseVtAt, BaseVtAtFC: @ojdtum.BaseVtAtFC, BaseVtAtSC: @ojdtum.BaseVtAtSC, BatchNum: @ojdtum.BatchNum, BlockDunn: @ojdtum.BlockDunn, BtfLine: @ojdtum.BtfLine, BtfStatus: @ojdtum.BtfStatus, CIG: @ojdtum.CIG, CUP: @ojdtum.CUP, CertifNum: @ojdtum.CertifNum, Corisptivi: @ojdtum.Corisptivi, CreateDate: @ojdtum.CreateDate, CreateTime: @ojdtum.CreateTime, CreatedBy: @ojdtum.CreatedBy, Creator: @ojdtum.Creator, DataSource: @ojdtum.DataSource, DeferedTax: @ojdtum.DeferedTax, DocSeries: @ojdtum.DocSeries, DocType: @ojdtum.DocType, DueDate: @ojdtum.DueDate, FcTotal: @ojdtum.FcTotal, FinncPriod: @ojdtum.FinncPriod, FolioNum: @ojdtum.FolioNum, FolioPref: @ojdtum.FolioPref, GenRegNo: @ojdtum.GenRegNo, Indicator: @ojdtum.Indicator, KeyVersion: @ojdtum.KeyVersion, LocTotal: @ojdtum.LocTotal, Location: @ojdtum.Location, LogInstanc: @ojdtum.LogInstanc, MatType: @ojdtum.MatType, Memo: @ojdtum.Memo, Number: @ojdtum.Number, ObjType: @ojdtum.ObjType, OperatCode: @ojdtum.OperatCode, OrignCurr: @ojdtum.OrignCurr, PCAddition: @ojdtum.PCAddition, Printed: @ojdtum.Printed, Project: @ojdtum.Project, RG23APart2: @ojdtum.RG23APart2, RG23CPart2: @ojdtum.RG23CPart2, Ref1: @ojdtum.Ref1, Ref2: @ojdtum.Ref2, Ref3: @ojdtum.Ref3, RefDate: @ojdtum.RefDate, RefndRprt: @ojdtum.RefndRprt, Report347: @ojdtum.Report347, ReportEU: @ojdtum.ReportEU, ResidenNum: @ojdtum.ResidenNum, RevSource: @ojdtum.RevSource, SPSrcDLN: @ojdtum.SPSrcDLN, SPSrcID: @ojdtum.SPSrcID, SPSrcType: @ojdtum.SPSrcType, SSIExmpt: @ojdtum.SSIExmpt, SeqCode: @ojdtum.SeqCode, SeqNum: @ojdtum.SeqNum, Serial: @ojdtum.Serial, Series: @ojdtum.Series, SeriesStr: @ojdtum.SeriesStr, SignDigest: @ojdtum.SignDigest, SignMsg: @ojdtum.SignMsg, StampTax: @ojdtum.StampTax, StornoDate: @ojdtum.StornoDate, StornoToTr: @ojdtum.StornoToTr, SubStr: @ojdtum.SubStr, SupplCode: @ojdtum.SupplCode, SysTotal: @ojdtum.SysTotal, TaxDate: @ojdtum.TaxDate, TransCode: @ojdtum.TransCode, TransCurr: @ojdtum.TransCurr, TransId: @ojdtum.TransId, TransRate: @ojdtum.TransRate, TransType: @ojdtum.TransType, UpdateDate: @ojdtum.UpdateDate, UserSign2: @ojdtum.UserSign2, UserSign: @ojdtum.UserSign, VatDate: @ojdtum.VatDate, VersionNum: @ojdtum.VersionNum, WTApplied: @ojdtum.WTApplied, WTAppliedF: @ojdtum.WTAppliedF, WTAppliedS: @ojdtum.WTAppliedS, WTSum: @ojdtum.WTSum, WTSumFC: @ojdtum.WTSumFC, WTSumSC: @ojdtum.WTSumSC }
    end

    assert_redirected_to ojdtum_path(assigns(:ojdtum))
  end

  test "should show ojdtum" do
    get :show, id: @ojdtum
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @ojdtum
    assert_response :success
  end

  test "should update ojdtum" do
    patch :update, id: @ojdtum, ojdtum: { AdjTran: @ojdtum.AdjTran, AgrNo: @ojdtum.AgrNo, Approver: @ojdtum.Approver, AttNum: @ojdtum.AttNum, AutoStorno: @ojdtum.AutoStorno, AutoVAT: @ojdtum.AutoVAT, AutoWT: @ojdtum.AutoWT, BaseAmnt: @ojdtum.BaseAmnt, BaseAmntFC: @ojdtum.BaseAmntFC, BaseAmntSC: @ojdtum.BaseAmntSC, BaseRef: @ojdtum.BaseRef, BaseTrans: @ojdtum.BaseTrans, BaseVtAt: @ojdtum.BaseVtAt, BaseVtAtFC: @ojdtum.BaseVtAtFC, BaseVtAtSC: @ojdtum.BaseVtAtSC, BatchNum: @ojdtum.BatchNum, BlockDunn: @ojdtum.BlockDunn, BtfLine: @ojdtum.BtfLine, BtfStatus: @ojdtum.BtfStatus, CIG: @ojdtum.CIG, CUP: @ojdtum.CUP, CertifNum: @ojdtum.CertifNum, Corisptivi: @ojdtum.Corisptivi, CreateDate: @ojdtum.CreateDate, CreateTime: @ojdtum.CreateTime, CreatedBy: @ojdtum.CreatedBy, Creator: @ojdtum.Creator, DataSource: @ojdtum.DataSource, DeferedTax: @ojdtum.DeferedTax, DocSeries: @ojdtum.DocSeries, DocType: @ojdtum.DocType, DueDate: @ojdtum.DueDate, FcTotal: @ojdtum.FcTotal, FinncPriod: @ojdtum.FinncPriod, FolioNum: @ojdtum.FolioNum, FolioPref: @ojdtum.FolioPref, GenRegNo: @ojdtum.GenRegNo, Indicator: @ojdtum.Indicator, KeyVersion: @ojdtum.KeyVersion, LocTotal: @ojdtum.LocTotal, Location: @ojdtum.Location, LogInstanc: @ojdtum.LogInstanc, MatType: @ojdtum.MatType, Memo: @ojdtum.Memo, Number: @ojdtum.Number, ObjType: @ojdtum.ObjType, OperatCode: @ojdtum.OperatCode, OrignCurr: @ojdtum.OrignCurr, PCAddition: @ojdtum.PCAddition, Printed: @ojdtum.Printed, Project: @ojdtum.Project, RG23APart2: @ojdtum.RG23APart2, RG23CPart2: @ojdtum.RG23CPart2, Ref1: @ojdtum.Ref1, Ref2: @ojdtum.Ref2, Ref3: @ojdtum.Ref3, RefDate: @ojdtum.RefDate, RefndRprt: @ojdtum.RefndRprt, Report347: @ojdtum.Report347, ReportEU: @ojdtum.ReportEU, ResidenNum: @ojdtum.ResidenNum, RevSource: @ojdtum.RevSource, SPSrcDLN: @ojdtum.SPSrcDLN, SPSrcID: @ojdtum.SPSrcID, SPSrcType: @ojdtum.SPSrcType, SSIExmpt: @ojdtum.SSIExmpt, SeqCode: @ojdtum.SeqCode, SeqNum: @ojdtum.SeqNum, Serial: @ojdtum.Serial, Series: @ojdtum.Series, SeriesStr: @ojdtum.SeriesStr, SignDigest: @ojdtum.SignDigest, SignMsg: @ojdtum.SignMsg, StampTax: @ojdtum.StampTax, StornoDate: @ojdtum.StornoDate, StornoToTr: @ojdtum.StornoToTr, SubStr: @ojdtum.SubStr, SupplCode: @ojdtum.SupplCode, SysTotal: @ojdtum.SysTotal, TaxDate: @ojdtum.TaxDate, TransCode: @ojdtum.TransCode, TransCurr: @ojdtum.TransCurr, TransId: @ojdtum.TransId, TransRate: @ojdtum.TransRate, TransType: @ojdtum.TransType, UpdateDate: @ojdtum.UpdateDate, UserSign2: @ojdtum.UserSign2, UserSign: @ojdtum.UserSign, VatDate: @ojdtum.VatDate, VersionNum: @ojdtum.VersionNum, WTApplied: @ojdtum.WTApplied, WTAppliedF: @ojdtum.WTAppliedF, WTAppliedS: @ojdtum.WTAppliedS, WTSum: @ojdtum.WTSum, WTSumFC: @ojdtum.WTSumFC, WTSumSC: @ojdtum.WTSumSC }
    assert_redirected_to ojdtum_path(assigns(:ojdtum))
  end

  test "should destroy ojdtum" do
    assert_difference('Ojdtum.count', -1) do
      delete :destroy, id: @ojdtum
    end

    assert_redirected_to ojdta_path
  end
end
