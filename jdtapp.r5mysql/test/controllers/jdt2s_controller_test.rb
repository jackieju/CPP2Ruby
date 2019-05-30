require 'test_helper'

class Jdt2sControllerTest < ActionDispatch::IntegrationTest
  setup do
    @jdt2 = jdt2s(:one)
  end

  test "should get index" do
    get jdt2s_url
    assert_response :success
  end

  test "should get new" do
    get new_jdt2_url
    assert_response :success
  end

  test "should create jdt2" do
    assert_difference('Jdt2.count') do
      post jdt2s_url, params: { jdt2: { AbsEntry: @jdt2.AbsEntry, Account: @jdt2.Account, ApplAmnt: @jdt2.ApplAmnt, ApplAmntFC: @jdt2.ApplAmntFC, ApplAmntSC: @jdt2.ApplAmntSC, BaseAbsEnt: @jdt2.BaseAbsEnt, BaseLine: @jdt2.BaseLine, BaseNum: @jdt2.BaseNum, BaseRef: @jdt2.BaseRef, BaseType: @jdt2.BaseType, BatchNum: @jdt2.BatchNum, Category: @jdt2.Category, CessAcc: @jdt2.CessAcc, CessAmnt: @jdt2.CessAmnt, CessAmntFC: @jdt2.CessAmntFC, CessAmntSC: @jdt2.CessAmntSC, CessAppl: @jdt2.CessAppl, CessApplFC: @jdt2.CessApplFC, CessApplSC: @jdt2.CessApplSC, CessBAmt: @jdt2.CessBAmt, CessBAmtFC: @jdt2.CessBAmtFC, CessBAmtSC: @jdt2.CessBAmtSC, CessRate: @jdt2.CessRate, Criteria: @jdt2.Criteria, Doc1LineNo: @jdt2.Doc1LineNo, DtblAmount: @jdt2.DtblAmount, DtblCurr: @jdt2.DtblCurr, DtblRate: @jdt2.DtblRate, HscAcc: @jdt2.HscAcc, HscAmnt: @jdt2.HscAmnt, HscAmntFC: @jdt2.HscAmntFC, HscAmntSC: @jdt2.HscAmntSC, HscAppl: @jdt2.HscAppl, HscApplFC: @jdt2.HscApplFC, HscApplSC: @jdt2.HscApplSC, HscBAmt: @jdt2.HscBAmt, HscBAmtFC: @jdt2.HscBAmtFC, HscBAmtSC: @jdt2.HscBAmtSC, HscRate: @jdt2.HscRate, InCSTCode: @jdt2.InCSTCode, LineNum: @jdt2.LineNum, LogInstanc: @jdt2.LogInstanc, ObjType: @jdt2.ObjType, OutCSTCode: @jdt2.OutCSTCode, Rate: @jdt2.Rate, RoundType: @jdt2.RoundType, Status: @jdt2.Status, SurAcc: @jdt2.SurAcc, SurAmnt: @jdt2.SurAmnt, SurAmntFC: @jdt2.SurAmntFC, SurAmntSC: @jdt2.SurAmntSC, SurAppl: @jdt2.SurAppl, SurApplFC: @jdt2.SurApplFC, SurApplSC: @jdt2.SurApplSC, SurBAmt: @jdt2.SurBAmt, SurBAmtFC: @jdt2.SurBAmtFC, SurBAmtSC: @jdt2.SurBAmtSC, SurRate: @jdt2.SurRate, TaxbleAmnt: @jdt2.TaxbleAmnt, TdsAcc: @jdt2.TdsAcc, TdsAmnt: @jdt2.TdsAmnt, TdsAmntFC: @jdt2.TdsAmntFC, TdsAmntSC: @jdt2.TdsAmntSC, TdsAppl: @jdt2.TdsAppl, TdsApplFC: @jdt2.TdsApplFC, TdsApplSC: @jdt2.TdsApplSC, TdsBAmt: @jdt2.TdsBAmt, TdsBAmtFC: @jdt2.TdsBAmtFC, TdsBAmtSC: @jdt2.TdsBAmtSC, TdsRate: @jdt2.TdsRate, TrgAbsEntr: @jdt2.TrgAbsEntr, TrgType: @jdt2.TrgType, TxblAmntFC: @jdt2.TxblAmntFC, TxblAmntSC: @jdt2.TxblAmntSC, TxblCurr: @jdt2.TxblCurr, Type: @jdt2.Type, WTAmnt: @jdt2.WTAmnt, WTAmntFC: @jdt2.WTAmntFC, WTAmntSC: @jdt2.WTAmntSC, WTCode: @jdt2.WTCode, WtLineType: @jdt2.WtLineType, txblRate: @jdt2.txblRate } }
    end

    assert_redirected_to jdt2_url(Jdt2.last)
  end

  test "should show jdt2" do
    get jdt2_url(@jdt2)
    assert_response :success
  end

  test "should get edit" do
    get edit_jdt2_url(@jdt2)
    assert_response :success
  end

  test "should update jdt2" do
    patch jdt2_url(@jdt2), params: { jdt2: { AbsEntry: @jdt2.AbsEntry, Account: @jdt2.Account, ApplAmnt: @jdt2.ApplAmnt, ApplAmntFC: @jdt2.ApplAmntFC, ApplAmntSC: @jdt2.ApplAmntSC, BaseAbsEnt: @jdt2.BaseAbsEnt, BaseLine: @jdt2.BaseLine, BaseNum: @jdt2.BaseNum, BaseRef: @jdt2.BaseRef, BaseType: @jdt2.BaseType, BatchNum: @jdt2.BatchNum, Category: @jdt2.Category, CessAcc: @jdt2.CessAcc, CessAmnt: @jdt2.CessAmnt, CessAmntFC: @jdt2.CessAmntFC, CessAmntSC: @jdt2.CessAmntSC, CessAppl: @jdt2.CessAppl, CessApplFC: @jdt2.CessApplFC, CessApplSC: @jdt2.CessApplSC, CessBAmt: @jdt2.CessBAmt, CessBAmtFC: @jdt2.CessBAmtFC, CessBAmtSC: @jdt2.CessBAmtSC, CessRate: @jdt2.CessRate, Criteria: @jdt2.Criteria, Doc1LineNo: @jdt2.Doc1LineNo, DtblAmount: @jdt2.DtblAmount, DtblCurr: @jdt2.DtblCurr, DtblRate: @jdt2.DtblRate, HscAcc: @jdt2.HscAcc, HscAmnt: @jdt2.HscAmnt, HscAmntFC: @jdt2.HscAmntFC, HscAmntSC: @jdt2.HscAmntSC, HscAppl: @jdt2.HscAppl, HscApplFC: @jdt2.HscApplFC, HscApplSC: @jdt2.HscApplSC, HscBAmt: @jdt2.HscBAmt, HscBAmtFC: @jdt2.HscBAmtFC, HscBAmtSC: @jdt2.HscBAmtSC, HscRate: @jdt2.HscRate, InCSTCode: @jdt2.InCSTCode, LineNum: @jdt2.LineNum, LogInstanc: @jdt2.LogInstanc, ObjType: @jdt2.ObjType, OutCSTCode: @jdt2.OutCSTCode, Rate: @jdt2.Rate, RoundType: @jdt2.RoundType, Status: @jdt2.Status, SurAcc: @jdt2.SurAcc, SurAmnt: @jdt2.SurAmnt, SurAmntFC: @jdt2.SurAmntFC, SurAmntSC: @jdt2.SurAmntSC, SurAppl: @jdt2.SurAppl, SurApplFC: @jdt2.SurApplFC, SurApplSC: @jdt2.SurApplSC, SurBAmt: @jdt2.SurBAmt, SurBAmtFC: @jdt2.SurBAmtFC, SurBAmtSC: @jdt2.SurBAmtSC, SurRate: @jdt2.SurRate, TaxbleAmnt: @jdt2.TaxbleAmnt, TdsAcc: @jdt2.TdsAcc, TdsAmnt: @jdt2.TdsAmnt, TdsAmntFC: @jdt2.TdsAmntFC, TdsAmntSC: @jdt2.TdsAmntSC, TdsAppl: @jdt2.TdsAppl, TdsApplFC: @jdt2.TdsApplFC, TdsApplSC: @jdt2.TdsApplSC, TdsBAmt: @jdt2.TdsBAmt, TdsBAmtFC: @jdt2.TdsBAmtFC, TdsBAmtSC: @jdt2.TdsBAmtSC, TdsRate: @jdt2.TdsRate, TrgAbsEntr: @jdt2.TrgAbsEntr, TrgType: @jdt2.TrgType, TxblAmntFC: @jdt2.TxblAmntFC, TxblAmntSC: @jdt2.TxblAmntSC, TxblCurr: @jdt2.TxblCurr, Type: @jdt2.Type, WTAmnt: @jdt2.WTAmnt, WTAmntFC: @jdt2.WTAmntFC, WTAmntSC: @jdt2.WTAmntSC, WTCode: @jdt2.WTCode, WtLineType: @jdt2.WtLineType, txblRate: @jdt2.txblRate } }
    assert_redirected_to jdt2_url(@jdt2)
  end

  test "should destroy jdt2" do
    assert_difference('Jdt2.count', -1) do
      delete jdt2_url(@jdt2)
    end

    assert_redirected_to jdt2s_url
  end
end
