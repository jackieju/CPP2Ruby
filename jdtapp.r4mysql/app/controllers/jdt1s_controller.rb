class Jdt1sController < ApplicationController
  before_action :set_jdt1, only: [:show, :edit, :update, :destroy]

  # GET /jdt1s
  # GET /jdt1s.json
  def index
    @jdt1s = Jdt1.all
  end

  # GET /jdt1s/1
  # GET /jdt1s/1.json
  def show
  end

  # GET /jdt1s/new
  def new
    @jdt1 = Jdt1.new
  end

  # GET /jdt1s/1/edit
  def edit
  end

  # POST /jdt1s
  # POST /jdt1s.json
  def create
    @jdt1 = Jdt1.new(jdt1_params)

    respond_to do |format|
      if @jdt1.save
        format.html { redirect_to @jdt1, notice: 'Jdt1 was successfully created.' }
        format.json { render :show, status: :created, location: @jdt1 }
      else
        format.html { render :new }
        format.json { render json: @jdt1.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /jdt1s/1
  # PATCH/PUT /jdt1s/1.json
  def update
    respond_to do |format|
      if @jdt1.update(jdt1_params)
        format.html { redirect_to @jdt1, notice: 'Jdt1 was successfully updated.' }
        format.json { render :show, status: :ok, location: @jdt1 }
      else
        format.html { render :edit }
        format.json { render json: @jdt1.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /jdt1s/1
  # DELETE /jdt1s/1.json
  def destroy
    @jdt1.destroy
    respond_to do |format|
      format.html { redirect_to jdt1s_url, notice: 'Jdt1 was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_jdt1
      @jdt1 = Jdt1.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def jdt1_params
      params.require(:jdt1).permit(:TransId, :Line_ID, :Account, :Debit, :Credit, :SYSCred, :SYSDeb, :FCDebit, :FCCredit, :FCCurrency, :DueDate, :SourceID, :SourceLine, :ShortName, :IntrnMatch, :ExtrMatch, :ContraAct, :LineMemo, :Ref3Line, :TransType, :RefDate, :Ref2Date, :Ref1, :Ref2, :CreatedBy, :BaseRef, :Project, :TransCode, :ProfitCode, :TaxDate, :SystemRate, :MthDate, :ToMthSum, :UserSign, :BatchNum, :FinncPriod, :RelTransId, :RelLineID, :RelType, :LogInstanc, :VatGroup, :BaseSum, :VatRate, :Indicator, :AdjTran, :RevSource, :ObjType, :VatDate, :PaymentRef, :SYSBaseSum, :MultMatch, :VatLine, :VatAmount, :SYSVatSum, :Closed, :GrossValue, :CheckAbs, :LineType, :DebCred, :SequenceNr, :StornoAcc, :BalDueDeb, :BalDueCred, :BalFcDeb, :BalFcCred, :BalScDeb, :BalScCred, :IsNet, :DunWizBlck, :DunnLevel, :DunDate, :TaxType, :TaxPostAcc, :StaCode, :StaType, :TaxCode, :ValidFrom, :GrossValFc, :LvlUpdDate, :OcrCode2, :OcrCode3, :OcrCode4, :OcrCode5, :MIEntry, :MIVEntry, :ClsInTP, :CenVatCom, :MatType, :PstngType, :ValidFrom2, :ValidFrom3, :ValidFrom4, :ValidFrom5, :Location, :WTaxCode, :EquVatRate, :EquVatSum, :SYSEquSum, :TotalVat, :SYSTVat, :WTLiable, :WTLine, :WTApplied, :WTAppliedS, :WTAppliedF, :WTSum, :WTSumFC, :WTSumSC, :PayBlock, :PayBlckRef, :LicTradNum, :InterimTyp, :DprId, :MatchRef, :Ordered, :CUP, :CIG, :BPLId, :BPLName, :VatRegNum, :SLEDGERF)
    end
end
