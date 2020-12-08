require "application_system_test_case"

class Jdt2sTest < ApplicationSystemTestCase
  setup do
    @jdt2 = jdt2s(:one)
  end

  test "visiting the index" do
    visit jdt2s_url
    assert_selector "h1", text: "Jdt2s"
  end

  test "creating a Jdt2" do
    visit jdt2s_url
    click_on "New Jdt2"

    fill_in "Absentry", with: @jdt2.AbsEntry
    fill_in "Account", with: @jdt2.Account
    fill_in "Applamnt", with: @jdt2.ApplAmnt
    fill_in "Applamntfc", with: @jdt2.ApplAmntFC
    fill_in "Applamntsc", with: @jdt2.ApplAmntSC
    fill_in "Baseabsent", with: @jdt2.BaseAbsEnt
    fill_in "Baseline", with: @jdt2.BaseLine
    fill_in "Basenum", with: @jdt2.BaseNum
    fill_in "Baseref", with: @jdt2.BaseRef
    fill_in "Basetype", with: @jdt2.BaseType
    fill_in "Batchnum", with: @jdt2.BatchNum
    fill_in "Category", with: @jdt2.Category
    fill_in "Cessacc", with: @jdt2.CessAcc
    fill_in "Cessamnt", with: @jdt2.CessAmnt
    fill_in "Cessamntfc", with: @jdt2.CessAmntFC
    fill_in "Cessamntsc", with: @jdt2.CessAmntSC
    fill_in "Cessappl", with: @jdt2.CessAppl
    fill_in "Cessapplfc", with: @jdt2.CessApplFC
    fill_in "Cessapplsc", with: @jdt2.CessApplSC
    fill_in "Cessbamt", with: @jdt2.CessBAmt
    fill_in "Cessbamtfc", with: @jdt2.CessBAmtFC
    fill_in "Cessbamtsc", with: @jdt2.CessBAmtSC
    fill_in "Cessrate", with: @jdt2.CessRate
    fill_in "Criteria", with: @jdt2.Criteria
    fill_in "Doc1lineno", with: @jdt2.Doc1LineNo
    fill_in "Dtblamount", with: @jdt2.DtblAmount
    fill_in "Dtblcurr", with: @jdt2.DtblCurr
    fill_in "Dtblrate", with: @jdt2.DtblRate
    fill_in "Hscacc", with: @jdt2.HscAcc
    fill_in "Hscamnt", with: @jdt2.HscAmnt
    fill_in "Hscamntfc", with: @jdt2.HscAmntFC
    fill_in "Hscamntsc", with: @jdt2.HscAmntSC
    fill_in "Hscappl", with: @jdt2.HscAppl
    fill_in "Hscapplfc", with: @jdt2.HscApplFC
    fill_in "Hscapplsc", with: @jdt2.HscApplSC
    fill_in "Hscbamt", with: @jdt2.HscBAmt
    fill_in "Hscbamtfc", with: @jdt2.HscBAmtFC
    fill_in "Hscbamtsc", with: @jdt2.HscBAmtSC
    fill_in "Hscrate", with: @jdt2.HscRate
    fill_in "Incstcode", with: @jdt2.InCSTCode
    fill_in "Linenum", with: @jdt2.LineNum
    fill_in "Loginstanc", with: @jdt2.LogInstanc
    fill_in "Objtype", with: @jdt2.ObjType
    fill_in "Outcstcode", with: @jdt2.OutCSTCode
    fill_in "Rate", with: @jdt2.Rate
    fill_in "Roundtype", with: @jdt2.RoundType
    fill_in "Status", with: @jdt2.Status
    fill_in "Suracc", with: @jdt2.SurAcc
    fill_in "Suramnt", with: @jdt2.SurAmnt
    fill_in "Suramntfc", with: @jdt2.SurAmntFC
    fill_in "Suramntsc", with: @jdt2.SurAmntSC
    fill_in "Surappl", with: @jdt2.SurAppl
    fill_in "Surapplfc", with: @jdt2.SurApplFC
    fill_in "Surapplsc", with: @jdt2.SurApplSC
    fill_in "Surbamt", with: @jdt2.SurBAmt
    fill_in "Surbamtfc", with: @jdt2.SurBAmtFC
    fill_in "Surbamtsc", with: @jdt2.SurBAmtSC
    fill_in "Surrate", with: @jdt2.SurRate
    fill_in "Taxbleamnt", with: @jdt2.TaxbleAmnt
    fill_in "Tdsacc", with: @jdt2.TdsAcc
    fill_in "Tdsamnt", with: @jdt2.TdsAmnt
    fill_in "Tdsamntfc", with: @jdt2.TdsAmntFC
    fill_in "Tdsamntsc", with: @jdt2.TdsAmntSC
    fill_in "Tdsappl", with: @jdt2.TdsAppl
    fill_in "Tdsapplfc", with: @jdt2.TdsApplFC
    fill_in "Tdsapplsc", with: @jdt2.TdsApplSC
    fill_in "Tdsbamt", with: @jdt2.TdsBAmt
    fill_in "Tdsbamtfc", with: @jdt2.TdsBAmtFC
    fill_in "Tdsbamtsc", with: @jdt2.TdsBAmtSC
    fill_in "Tdsrate", with: @jdt2.TdsRate
    fill_in "Trgabsentr", with: @jdt2.TrgAbsEntr
    fill_in "Trgtype", with: @jdt2.TrgType
    fill_in "Txblamntfc", with: @jdt2.TxblAmntFC
    fill_in "Txblamntsc", with: @jdt2.TxblAmntSC
    fill_in "Txblcurr", with: @jdt2.TxblCurr
    fill_in "Type", with: @jdt2.Type
    fill_in "Wtamnt", with: @jdt2.WTAmnt
    fill_in "Wtamntfc", with: @jdt2.WTAmntFC
    fill_in "Wtamntsc", with: @jdt2.WTAmntSC
    fill_in "Wtcode", with: @jdt2.WTCode
    fill_in "Wtlinetype", with: @jdt2.WtLineType
    fill_in "Txblrate", with: @jdt2.txblRate
    click_on "Create Jdt2"

    assert_text "Jdt2 was successfully created"
    click_on "Back"
  end

  test "updating a Jdt2" do
    visit jdt2s_url
    click_on "Edit", match: :first

    fill_in "Absentry", with: @jdt2.AbsEntry
    fill_in "Account", with: @jdt2.Account
    fill_in "Applamnt", with: @jdt2.ApplAmnt
    fill_in "Applamntfc", with: @jdt2.ApplAmntFC
    fill_in "Applamntsc", with: @jdt2.ApplAmntSC
    fill_in "Baseabsent", with: @jdt2.BaseAbsEnt
    fill_in "Baseline", with: @jdt2.BaseLine
    fill_in "Basenum", with: @jdt2.BaseNum
    fill_in "Baseref", with: @jdt2.BaseRef
    fill_in "Basetype", with: @jdt2.BaseType
    fill_in "Batchnum", with: @jdt2.BatchNum
    fill_in "Category", with: @jdt2.Category
    fill_in "Cessacc", with: @jdt2.CessAcc
    fill_in "Cessamnt", with: @jdt2.CessAmnt
    fill_in "Cessamntfc", with: @jdt2.CessAmntFC
    fill_in "Cessamntsc", with: @jdt2.CessAmntSC
    fill_in "Cessappl", with: @jdt2.CessAppl
    fill_in "Cessapplfc", with: @jdt2.CessApplFC
    fill_in "Cessapplsc", with: @jdt2.CessApplSC
    fill_in "Cessbamt", with: @jdt2.CessBAmt
    fill_in "Cessbamtfc", with: @jdt2.CessBAmtFC
    fill_in "Cessbamtsc", with: @jdt2.CessBAmtSC
    fill_in "Cessrate", with: @jdt2.CessRate
    fill_in "Criteria", with: @jdt2.Criteria
    fill_in "Doc1lineno", with: @jdt2.Doc1LineNo
    fill_in "Dtblamount", with: @jdt2.DtblAmount
    fill_in "Dtblcurr", with: @jdt2.DtblCurr
    fill_in "Dtblrate", with: @jdt2.DtblRate
    fill_in "Hscacc", with: @jdt2.HscAcc
    fill_in "Hscamnt", with: @jdt2.HscAmnt
    fill_in "Hscamntfc", with: @jdt2.HscAmntFC
    fill_in "Hscamntsc", with: @jdt2.HscAmntSC
    fill_in "Hscappl", with: @jdt2.HscAppl
    fill_in "Hscapplfc", with: @jdt2.HscApplFC
    fill_in "Hscapplsc", with: @jdt2.HscApplSC
    fill_in "Hscbamt", with: @jdt2.HscBAmt
    fill_in "Hscbamtfc", with: @jdt2.HscBAmtFC
    fill_in "Hscbamtsc", with: @jdt2.HscBAmtSC
    fill_in "Hscrate", with: @jdt2.HscRate
    fill_in "Incstcode", with: @jdt2.InCSTCode
    fill_in "Linenum", with: @jdt2.LineNum
    fill_in "Loginstanc", with: @jdt2.LogInstanc
    fill_in "Objtype", with: @jdt2.ObjType
    fill_in "Outcstcode", with: @jdt2.OutCSTCode
    fill_in "Rate", with: @jdt2.Rate
    fill_in "Roundtype", with: @jdt2.RoundType
    fill_in "Status", with: @jdt2.Status
    fill_in "Suracc", with: @jdt2.SurAcc
    fill_in "Suramnt", with: @jdt2.SurAmnt
    fill_in "Suramntfc", with: @jdt2.SurAmntFC
    fill_in "Suramntsc", with: @jdt2.SurAmntSC
    fill_in "Surappl", with: @jdt2.SurAppl
    fill_in "Surapplfc", with: @jdt2.SurApplFC
    fill_in "Surapplsc", with: @jdt2.SurApplSC
    fill_in "Surbamt", with: @jdt2.SurBAmt
    fill_in "Surbamtfc", with: @jdt2.SurBAmtFC
    fill_in "Surbamtsc", with: @jdt2.SurBAmtSC
    fill_in "Surrate", with: @jdt2.SurRate
    fill_in "Taxbleamnt", with: @jdt2.TaxbleAmnt
    fill_in "Tdsacc", with: @jdt2.TdsAcc
    fill_in "Tdsamnt", with: @jdt2.TdsAmnt
    fill_in "Tdsamntfc", with: @jdt2.TdsAmntFC
    fill_in "Tdsamntsc", with: @jdt2.TdsAmntSC
    fill_in "Tdsappl", with: @jdt2.TdsAppl
    fill_in "Tdsapplfc", with: @jdt2.TdsApplFC
    fill_in "Tdsapplsc", with: @jdt2.TdsApplSC
    fill_in "Tdsbamt", with: @jdt2.TdsBAmt
    fill_in "Tdsbamtfc", with: @jdt2.TdsBAmtFC
    fill_in "Tdsbamtsc", with: @jdt2.TdsBAmtSC
    fill_in "Tdsrate", with: @jdt2.TdsRate
    fill_in "Trgabsentr", with: @jdt2.TrgAbsEntr
    fill_in "Trgtype", with: @jdt2.TrgType
    fill_in "Txblamntfc", with: @jdt2.TxblAmntFC
    fill_in "Txblamntsc", with: @jdt2.TxblAmntSC
    fill_in "Txblcurr", with: @jdt2.TxblCurr
    fill_in "Type", with: @jdt2.Type
    fill_in "Wtamnt", with: @jdt2.WTAmnt
    fill_in "Wtamntfc", with: @jdt2.WTAmntFC
    fill_in "Wtamntsc", with: @jdt2.WTAmntSC
    fill_in "Wtcode", with: @jdt2.WTCode
    fill_in "Wtlinetype", with: @jdt2.WtLineType
    fill_in "Txblrate", with: @jdt2.txblRate
    click_on "Update Jdt2"

    assert_text "Jdt2 was successfully updated"
    click_on "Back"
  end

  test "destroying a Jdt2" do
    visit jdt2s_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Jdt2 was successfully destroyed"
  end
end
