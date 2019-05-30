class TttsController < ApplicationController
  before_action :set_ttt, only: [:show, :edit, :update, :destroy]

  # GET /ttts
  # GET /ttts.json
  def index
    @ttts = Ttt.all
  end

  # GET /ttts/1
  # GET /ttts/1.json
  def show
  end

  # GET /ttts/new
  def new
    @ttt = Ttt.new
  end

  # GET /ttts/1/edit
  def edit
  end

  # POST /ttts
  # POST /ttts.json
  def create
    @ttt = Ttt.new(ttt_params)

    respond_to do |format|
      if @ttt.save
        format.html { redirect_to @ttt, notice: 'Ttt was successfully created.' }
        format.json { render :show, status: :created, location: @ttt }
      else
        format.html { render :new }
        format.json { render json: @ttt.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ttts/1
  # PATCH/PUT /ttts/1.json
  def update
    respond_to do |format|
      if @ttt.update(ttt_params)
        format.html { redirect_to @ttt, notice: 'Ttt was successfully updated.' }
        format.json { render :show, status: :ok, location: @ttt }
      else
        format.html { render :edit }
        format.json { render json: @ttt.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ttts/1
  # DELETE /ttts/1.json
  def destroy
    @ttt.destroy
    respond_to do |format|
      format.html { redirect_to ttts_url, notice: 'Ttt was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ttt
      @ttt = Ttt.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ttt_params
      params.require(:ttt).permit(:name)
    end
end
