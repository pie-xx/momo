class SqlxslsController < ApplicationController
  before_filter :authenticate, :except => [ :logout ]

private
  def authenticate
    @author = params[:author ]
    @page = params[:page ]
    @checkpass = params[:pass ]
    @checkuser = params[:user ]
    if @checkpass == nil
      @checkpass = session[:pass ]
      @checkuser = session[:user ]
    end

    @checkpassword = Password.find_by_sql("select * from passwords where user='" + @checkuser.to_s + "';")
    if @checkpassword.size != 0 && @checkpassword[0][:roll]=='sqlxsls'
      if @checkpass == @checkpassword[0][:pass]
        session[:user] = @checkuser
        session[:pass] = @checkpass
        return true
      end
    end
    render :text => "error", :status => "401"
    return false
  end
  
public

  # GET /sqlxsls
  # GET /sqlxsls.xml
  def index
    @sqlxsls = Sqlxsl.find(:all, :order=>'author, page')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sqlxsls }
    end
  end

  # GET /sqlxsls/1
  # GET /sqlxsls/1.xml
  def show
    @sqlxsl = Sqlxsl.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @sqlxsl }
    end
  end

  # GET /sqlxsls/new
  # GET /sqlxsls/new.xml
  def new
    @sqlxsl = Sqlxsl.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @sqlxsl }
    end
  end

  # GET /sqlxsls/1/edit
  def edit
    @sqlxsl = Sqlxsl.find(params[:id])
  end

  # GET /sqlxsls/1/copy
  def copy
    @sqlorg = Sqlxsl.find(params[:id])
    @sqlxsl = Sqlxsl.new
    @sqlxsl.attributes=@sqlorg.attributes
  end

  # POST /sqlxsls
  # POST /sqlxsls.xml
  def create
    @sqlxsl = Sqlxsl.new(params[:sqlxsl])

    respond_to do |format|
      if @sqlxsl.save
        flash[:notice] = 'Sqlxsl was successfully created.'
        format.html { redirect_to(@sqlxsl) }
        format.xml  { render :xml => @sqlxsl, :status => :created, :location => @sqlxsl }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @sqlxsl.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /sqlxsls/1
  # PUT /sqlxsls/1.xml
  def update
    @sqlxsl = Sqlxsl.find(params[:id])

    respond_to do |format|
      if @sqlxsl.update_attributes(params[:sqlxsl])
        flash[:notice] = 'Sqlxsl was successfully updated.'
        format.html { redirect_to(@sqlxsl) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @sqlxsl.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /sqlxsls/1
  # DELETE /sqlxsls/1.xml
  def destroy
    @sqlxsl = Sqlxsl.find(params[:id])
    @sqlxsl.destroy

    respond_to do |format|
      format.html { redirect_to(sqlxsls_url) }
      format.xml  { head :ok }
    end
  end
end