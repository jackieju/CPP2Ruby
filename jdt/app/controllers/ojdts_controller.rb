class OjdtsController < ApplicationController
  # GET /ojdts
  # GET /ojdts.xml
  def index
    @ojdts = Ojdt.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @ojdts }
    end
  end

  # GET /ojdts/1
  # GET /ojdts/1.xml
  def show
    @ojdt = Ojdt.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @ojdt }
    end
  end

  # GET /ojdts/new
  # GET /ojdts/new.xml
  def new
    @ojdt = Ojdt.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @ojdt }
    end
  end

  # GET /ojdts/1/edit
  def edit
    @ojdt = Ojdt.find(params[:id])
  end

  # POST /ojdts
  # POST /ojdts.xml
  def create
    @ojdt = Ojdt.new(params[:ojdt])

    respond_to do |format|
      if @ojdt.save
        flash[:notice] = 'Ojdt was successfully created.'
        format.html { redirect_to(@ojdt) }
        format.xml  { render :xml => @ojdt, :status => :created, :location => @ojdt }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @ojdt.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /ojdts/1
  # PUT /ojdts/1.xml
  def update
    @ojdt = Ojdt.find(params[:id])

    respond_to do |format|
      if @ojdt.update_attributes(params[:ojdt])
        flash[:notice] = 'Ojdt was successfully updated.'
        format.html { redirect_to(@ojdt) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @ojdt.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /ojdts/1
  # DELETE /ojdts/1.xml
  def destroy
    @ojdt = Ojdt.find(params[:id])
    @ojdt.destroy

    respond_to do |format|
      format.html { redirect_to(ojdts_url) }
      format.xml  { head :ok }
    end
  end
end
