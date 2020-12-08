class Jdt2sController < ApplicationController
  before_action :set_jdt2, only: [:show, :edit, :update, :destroy]

  # GET /jdt2s
  # GET /jdt2s.json
  def index
    @jdt2s = Jdt2.all
  end

  # GET /jdt2s/1
  # GET /jdt2s/1.json
  def show
  end

  # GET /jdt2s/new
  def new
    @jdt2 = Jdt2.new
  end

  # GET /jdt2s/1/edit
  def edit
  end

  # POST /jdt2s
  # POST /jdt2s.json
  def create
    @jdt2 = Jdt2.new(jdt2_params)

    respond_to do |format|
      if @jdt2.save
        format.html { redirect_to @jdt2, notice: 'Jdt2 was successfully created.' }
        format.json { render :show, status: :created, location: @jdt2 }
      else
        format.html { render :new }
        format.json { render json: @jdt2.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /jdt2s/1
  # PATCH/PUT /jdt2s/1.json
  def update
    respond_to do |format|
      if @jdt2.update(jdt2_params)
        format.html { redirect_to @jdt2, notice: 'Jdt2 was successfully updated.' }
        format.json { render :show, status: :ok, location: @jdt2 }
      else
        format.html { render :edit }
        format.json { render json: @jdt2.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /jdt2s/1
  # DELETE /jdt2s/1.json
  def destroy
    @jdt2.destroy
    respond_to do |format|
      format.html { redirect_to jdt2s_url, notice: 'Jdt2 was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_jdt2
      @jdt2 = Jdt2.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def jdt2_params
      params.require(:jdt2).permit(:AbsEntry, :WTCode, :Rate, :TaxbleAmnt, :TxblAmntSC, :TxblAmntFC, :WTAmnt, :WTAmntSC, :WTAmntFC, :ApplAmnt, :ApplAmntSC, :ApplAmntFC, :Category, :Criteria, :Account, :Type, :RoundType, :BaseType, :BaseAbsEnt, :BaseLine, :BaseNum, :LineNum, :BaseRef, :Status, :TrgType, :TrgAbsEntr, :LogInstanc, :ObjType, :Doc1LineNo, :WtLineType, :TxblCurr, :DtblCurr, :DtblRate, :txblRate, :DtblAmount, :TdsAcc, :SurAcc, :CessAcc, :HscAcc, :TdsRate, :SurRate, :CessRate, :HscRate, :TdsBAmt, :TdsBAmtSC, :TdsBAmtFC, :SurBAmt, :SurBAmtSC, :SurBAmtFC, :CessBAmt, :CessBAmtSC, :CessBAmtFC, :HscBAmt, :HscBAmtSC, :HscBAmtFC, :TdsAmnt, :TdsAmntSC, :TdsAmntFC, :SurAmnt, :SurAmntSC, :SurAmntFC, :CessAmnt, :CessAmntSC, :CessAmntFC, :HscAmnt, :HscAmntSC, :HscAmntFC, :TdsAppl, :TdsApplSC, :TdsApplFC, :SurAppl, :SurApplSC, :SurApplFC, :CessAppl, :CessApplSC, :CessApplFC, :HscAppl, :HscApplSC, :HscApplFC, :BatchNum, :InCSTCode, :OutCSTCode)
    end
end
