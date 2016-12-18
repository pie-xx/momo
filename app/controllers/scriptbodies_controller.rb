class ScriptbodiesController < ApplicationController
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
  # GET /scriptbodies
  # GET /scriptbodies.xml
  def index
    @scriptbodies = Scriptbody.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @scriptbodies }
    end
  end

  # GET /scriptbodies/1
  # GET /scriptbodies/1.xml
  def show
    @scriptbody = Scriptbody.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @scriptbody }
    end
  end

  # GET /scriptbodies/new
  # GET /scriptbodies/new.xml
  def new
    @scriptbody = Scriptbody.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @scriptbody }
    end
  end

  # GET /scriptbodies/1/edit
  def edit
    @scriptbody = Scriptbody.find(params[:id])
  end

  # POST /scriptbodies
  # POST /scriptbodies.xml
  def create
    @scriptbody = Scriptbody.new(params[:scriptbody])

    respond_to do |format|
      if @scriptbody.save
        flash[:notice] = 'Scriptbody was successfully created.'
        format.html { redirect_to(@scriptbody) }
        format.xml  { render :xml => @scriptbody, :status => :created, :location => @scriptbody }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @scriptbody.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /scriptbodies/1
  # PUT /scriptbodies/1.xml
  def update
    @scriptbody = Scriptbody.find(params[:id])

    respond_to do |format|
      if @scriptbody.update_attributes(params[:scriptbody])
        flash[:notice] = 'Scriptbody was successfully updated.'
        format.html { redirect_to(@scriptbody) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @scriptbody.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /scriptbodies/1
  # DELETE /scriptbodies/1.xml
  def destroy
    @scriptbody = Scriptbody.find(params[:id])
    @scriptbody.destroy

    respond_to do |format|
      format.html { redirect_to(scriptbodies_url) }
      format.xml  { head :ok }
    end
  end
end