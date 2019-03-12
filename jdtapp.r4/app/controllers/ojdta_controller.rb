class OjdtaController < ApplicationController
  before_action :set_ojdtum, only: [:show, :edit, :update, :destroy]

  # GET /ojdta
  # GET /ojdta.json
  def index
    @ojdta = Ojdtum.all
  end

  # GET /ojdta/1
  # GET /ojdta/1.json
  def show
  end

  # GET /ojdta/new
  def new
    @ojdtum = Ojdtum.new
  end

  # GET /ojdta/1/edit
  def edit
  end

  # POST /ojdta
  # POST /ojdta.json
  def create
    @ojdtum = Ojdtum.new(ojdtum_params)

    respond_to do |format|
      if @ojdtum.save
        format.html { redirect_to @ojdtum, notice: 'Ojdtum was successfully created.' }
        format.json { render :show, status: :created, location: @ojdtum }
      else
        format.html { render :new }
        format.json { render json: @ojdtum.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ojdta/1
  # PATCH/PUT /ojdta/1.json
  def update
    respond_to do |format|
      if @ojdtum.update(ojdtum_params)
        format.html { redirect_to @ojdtum, notice: 'Ojdtum was successfully updated.' }
        format.json { render :show, status: :ok, location: @ojdtum }
      else
        format.html { render :edit }
        format.json { render json: @ojdtum.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ojdta/1
  # DELETE /ojdta/1.json
  def destroy
    @ojdtum.destroy
    respond_to do |format|
      format.html { redirect_to ojdta_url, notice: 'Ojdtum was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ojdtum
      @ojdtum = Ojdtum.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ojdtum_params
      params.require(:ojdtum).permit(:BatchNum, :TransId, :BtfStatus, :TransType, :BaseRef, :RefDate, :Memo, :Ref1, :Ref2, :CreatedBy, :LocTotal, :FcTotal, :SysTotal, :TransCode, :OrignCurr, :TransRate, :BtfLine, :TransCurr, :Project, :DueDate, :TaxDate, :PCAddition, :FinncPriod, :DataSource, :UpdateDate, :CreateDate, :UserSign, :UserSign2, :RefndRprt, :LogInstanc, :ObjType, :Indicator, :AdjTran, :RevSource, :StornoDate, :StornoToTr, :AutoStorno, :Corisptivi, :VatDate, :StampTax, :Series, :Number, :AutoVAT, :DocSeries, :FolioPref, :FolioNum, :CreateTime, :BlockDunn, :ReportEU, :Report347, :Printed, :DocType, :AttNum, :GenRegNo, :RG23APart2, :RG23CPart2, :MatType, :Creator, :Approver, :Location, :SeqCode, :Serial, :SeriesStr, :SubStr, :AutoWT, :WTSum, :WTSumSC, :WTSumFC, :WTApplied, :WTAppliedS, :WTAppliedF, :BaseAmnt, :BaseAmntSC, :BaseAmntFC, :BaseVtAt, :BaseVtAtSC, :BaseVtAtFC, :VersionNum, :BaseTrans, :ResidenNum, :OperatCode, :Ref3, :SSIExmpt, :SignMsg, :SignDigest, :CertifNum, :KeyVersion, :CUP, :CIG, :SupplCode, :SPSrcType, :SPSrcID, :SPSrcDLN, :DeferedTax, :AgrNo, :SeqNum)
    end
end
