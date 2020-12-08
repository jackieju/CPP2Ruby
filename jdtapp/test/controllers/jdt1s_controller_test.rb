require 'test_helper'

class Jdt1sControllerTest < ActionDispatch::IntegrationTest
  setup do
    @jdt1 = jdt1s(:one)
  end

  test "should get index" do
    get jdt1s_url
    assert_response :success
  end

  test "should get new" do
    get new_jdt1_url
    assert_response :success
  end

  test "should create jdt1" do
    assert_difference('Jdt1.count') do
      post jdt1s_url, params: { jdt1: { Account: @jdt1.Account, AdjTran: @jdt1.AdjTran, BPLId: @jdt1.BPLId, BPLName: @jdt1.BPLName, BalDueCred: @jdt1.BalDueCred, BalDueDeb: @jdt1.BalDueDeb, BalFcCred: @jdt1.BalFcCred, BalFcDeb: @jdt1.BalFcDeb, BalScCred: @jdt1.BalScCred, BalScDeb: @jdt1.BalScDeb, BaseRef: @jdt1.BaseRef, BaseSum: @jdt1.BaseSum, BatchNum: @jdt1.BatchNum, CIG: @jdt1.CIG, CUP: @jdt1.CUP, CenVatCom: @jdt1.CenVatCom, CheckAbs: @jdt1.CheckAbs, Closed: @jdt1.Closed, ClsInTP: @jdt1.ClsInTP, ContraAct: @jdt1.ContraAct, CreatedBy: @jdt1.CreatedBy, Credit: @jdt1.Credit, DebCred: @jdt1.DebCred, Debit: @jdt1.Debit, DprId: @jdt1.DprId, DueDate: @jdt1.DueDate, DunDate: @jdt1.DunDate, DunWizBlck: @jdt1.DunWizBlck, DunnLevel: @jdt1.DunnLevel, EquVatRate: @jdt1.EquVatRate, EquVatSum: @jdt1.EquVatSum, ExtrMatch: @jdt1.ExtrMatch, FCCredit: @jdt1.FCCredit, FCCurrency: @jdt1.FCCurrency, FCDebit: @jdt1.FCDebit, FinncPriod: @jdt1.FinncPriod, GrossValFc: @jdt1.GrossValFc, GrossValue: @jdt1.GrossValue, Indicator: @jdt1.Indicator, InterimTyp: @jdt1.InterimTyp, IntrnMatch: @jdt1.IntrnMatch, IsNet: @jdt1.IsNet, LicTradNum: @jdt1.LicTradNum, LineMemo: @jdt1.LineMemo, LineType: @jdt1.LineType, Line_ID: @jdt1.Line_ID, Location: @jdt1.Location, LogInstanc: @jdt1.LogInstanc, LvlUpdDate: @jdt1.LvlUpdDate, MIEntry: @jdt1.MIEntry, MIVEntry: @jdt1.MIVEntry, MatType: @jdt1.MatType, MatchRef: @jdt1.MatchRef, MthDate: @jdt1.MthDate, MultMatch: @jdt1.MultMatch, ObjType: @jdt1.ObjType, OcrCode2: @jdt1.OcrCode2, OcrCode3: @jdt1.OcrCode3, OcrCode4: @jdt1.OcrCode4, OcrCode5: @jdt1.OcrCode5, Ordered: @jdt1.Ordered, PayBlckRef: @jdt1.PayBlckRef, PayBlock: @jdt1.PayBlock, PaymentRef: @jdt1.PaymentRef, ProfitCode: @jdt1.ProfitCode, Project: @jdt1.Project, PstngType: @jdt1.PstngType, Ref1: @jdt1.Ref1, Ref2: @jdt1.Ref2, Ref2Date: @jdt1.Ref2Date, Ref3Line: @jdt1.Ref3Line, RefDate: @jdt1.RefDate, RelLineID: @jdt1.RelLineID, RelTransId: @jdt1.RelTransId, RelType: @jdt1.RelType, RevSource: @jdt1.RevSource, SLEDGERF: @jdt1.SLEDGERF, SYSBaseSum: @jdt1.SYSBaseSum, SYSCred: @jdt1.SYSCred, SYSDeb: @jdt1.SYSDeb, SYSEquSum: @jdt1.SYSEquSum, SYSTVat: @jdt1.SYSTVat, SYSVatSum: @jdt1.SYSVatSum, SequenceNr: @jdt1.SequenceNr, ShortName: @jdt1.ShortName, SourceID: @jdt1.SourceID, SourceLine: @jdt1.SourceLine, StaCode: @jdt1.StaCode, StaType: @jdt1.StaType, StornoAcc: @jdt1.StornoAcc, SystemRate: @jdt1.SystemRate, TaxCode: @jdt1.TaxCode, TaxDate: @jdt1.TaxDate, TaxPostAcc: @jdt1.TaxPostAcc, TaxType: @jdt1.TaxType, ToMthSum: @jdt1.ToMthSum, TotalVat: @jdt1.TotalVat, TransCode: @jdt1.TransCode, TransId: @jdt1.TransId, TransType: @jdt1.TransType, UserSign: @jdt1.UserSign, ValidFrom: @jdt1.ValidFrom, ValidFrom2: @jdt1.ValidFrom2, ValidFrom3: @jdt1.ValidFrom3, ValidFrom4: @jdt1.ValidFrom4, ValidFrom5: @jdt1.ValidFrom5, VatAmount: @jdt1.VatAmount, VatDate: @jdt1.VatDate, VatGroup: @jdt1.VatGroup, VatLine: @jdt1.VatLine, VatRate: @jdt1.VatRate, VatRegNum: @jdt1.VatRegNum, WTApplied: @jdt1.WTApplied, WTAppliedF: @jdt1.WTAppliedF, WTAppliedS: @jdt1.WTAppliedS, WTLiable: @jdt1.WTLiable, WTLine: @jdt1.WTLine, WTSum: @jdt1.WTSum, WTSumFC: @jdt1.WTSumFC, WTSumSC: @jdt1.WTSumSC, WTaxCode: @jdt1.WTaxCode } }
    end

    assert_redirected_to jdt1_url(Jdt1.last)
  end

  test "should show jdt1" do
    get jdt1_url(@jdt1)
    assert_response :success
  end

  test "should get edit" do
    get edit_jdt1_url(@jdt1)
    assert_response :success
  end

  test "should update jdt1" do
    patch jdt1_url(@jdt1), params: { jdt1: { Account: @jdt1.Account, AdjTran: @jdt1.AdjTran, BPLId: @jdt1.BPLId, BPLName: @jdt1.BPLName, BalDueCred: @jdt1.BalDueCred, BalDueDeb: @jdt1.BalDueDeb, BalFcCred: @jdt1.BalFcCred, BalFcDeb: @jdt1.BalFcDeb, BalScCred: @jdt1.BalScCred, BalScDeb: @jdt1.BalScDeb, BaseRef: @jdt1.BaseRef, BaseSum: @jdt1.BaseSum, BatchNum: @jdt1.BatchNum, CIG: @jdt1.CIG, CUP: @jdt1.CUP, CenVatCom: @jdt1.CenVatCom, CheckAbs: @jdt1.CheckAbs, Closed: @jdt1.Closed, ClsInTP: @jdt1.ClsInTP, ContraAct: @jdt1.ContraAct, CreatedBy: @jdt1.CreatedBy, Credit: @jdt1.Credit, DebCred: @jdt1.DebCred, Debit: @jdt1.Debit, DprId: @jdt1.DprId, DueDate: @jdt1.DueDate, DunDate: @jdt1.DunDate, DunWizBlck: @jdt1.DunWizBlck, DunnLevel: @jdt1.DunnLevel, EquVatRate: @jdt1.EquVatRate, EquVatSum: @jdt1.EquVatSum, ExtrMatch: @jdt1.ExtrMatch, FCCredit: @jdt1.FCCredit, FCCurrency: @jdt1.FCCurrency, FCDebit: @jdt1.FCDebit, FinncPriod: @jdt1.FinncPriod, GrossValFc: @jdt1.GrossValFc, GrossValue: @jdt1.GrossValue, Indicator: @jdt1.Indicator, InterimTyp: @jdt1.InterimTyp, IntrnMatch: @jdt1.IntrnMatch, IsNet: @jdt1.IsNet, LicTradNum: @jdt1.LicTradNum, LineMemo: @jdt1.LineMemo, LineType: @jdt1.LineType, Line_ID: @jdt1.Line_ID, Location: @jdt1.Location, LogInstanc: @jdt1.LogInstanc, LvlUpdDate: @jdt1.LvlUpdDate, MIEntry: @jdt1.MIEntry, MIVEntry: @jdt1.MIVEntry, MatType: @jdt1.MatType, MatchRef: @jdt1.MatchRef, MthDate: @jdt1.MthDate, MultMatch: @jdt1.MultMatch, ObjType: @jdt1.ObjType, OcrCode2: @jdt1.OcrCode2, OcrCode3: @jdt1.OcrCode3, OcrCode4: @jdt1.OcrCode4, OcrCode5: @jdt1.OcrCode5, Ordered: @jdt1.Ordered, PayBlckRef: @jdt1.PayBlckRef, PayBlock: @jdt1.PayBlock, PaymentRef: @jdt1.PaymentRef, ProfitCode: @jdt1.ProfitCode, Project: @jdt1.Project, PstngType: @jdt1.PstngType, Ref1: @jdt1.Ref1, Ref2: @jdt1.Ref2, Ref2Date: @jdt1.Ref2Date, Ref3Line: @jdt1.Ref3Line, RefDate: @jdt1.RefDate, RelLineID: @jdt1.RelLineID, RelTransId: @jdt1.RelTransId, RelType: @jdt1.RelType, RevSource: @jdt1.RevSource, SLEDGERF: @jdt1.SLEDGERF, SYSBaseSum: @jdt1.SYSBaseSum, SYSCred: @jdt1.SYSCred, SYSDeb: @jdt1.SYSDeb, SYSEquSum: @jdt1.SYSEquSum, SYSTVat: @jdt1.SYSTVat, SYSVatSum: @jdt1.SYSVatSum, SequenceNr: @jdt1.SequenceNr, ShortName: @jdt1.ShortName, SourceID: @jdt1.SourceID, SourceLine: @jdt1.SourceLine, StaCode: @jdt1.StaCode, StaType: @jdt1.StaType, StornoAcc: @jdt1.StornoAcc, SystemRate: @jdt1.SystemRate, TaxCode: @jdt1.TaxCode, TaxDate: @jdt1.TaxDate, TaxPostAcc: @jdt1.TaxPostAcc, TaxType: @jdt1.TaxType, ToMthSum: @jdt1.ToMthSum, TotalVat: @jdt1.TotalVat, TransCode: @jdt1.TransCode, TransId: @jdt1.TransId, TransType: @jdt1.TransType, UserSign: @jdt1.UserSign, ValidFrom: @jdt1.ValidFrom, ValidFrom2: @jdt1.ValidFrom2, ValidFrom3: @jdt1.ValidFrom3, ValidFrom4: @jdt1.ValidFrom4, ValidFrom5: @jdt1.ValidFrom5, VatAmount: @jdt1.VatAmount, VatDate: @jdt1.VatDate, VatGroup: @jdt1.VatGroup, VatLine: @jdt1.VatLine, VatRate: @jdt1.VatRate, VatRegNum: @jdt1.VatRegNum, WTApplied: @jdt1.WTApplied, WTAppliedF: @jdt1.WTAppliedF, WTAppliedS: @jdt1.WTAppliedS, WTLiable: @jdt1.WTLiable, WTLine: @jdt1.WTLine, WTSum: @jdt1.WTSum, WTSumFC: @jdt1.WTSumFC, WTSumSC: @jdt1.WTSumSC, WTaxCode: @jdt1.WTaxCode } }
    assert_redirected_to jdt1_url(@jdt1)
  end

  test "should destroy jdt1" do
    assert_difference('Jdt1.count', -1) do
      delete jdt1_url(@jdt1)
    end

    assert_redirected_to jdt1s_url
  end
end
