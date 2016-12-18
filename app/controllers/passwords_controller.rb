class PasswordsController < ApplicationController
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
  # GET /passwords
  # GET /passwords.xml
  def index
    @passwords = Password.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @passwords }
    end
  end

  # GET /passwords/1
  # GET /passwords/1.xml
  def show
    @password = Password.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @password }
    end
  end

  # GET /passwords/new
  # GET /passwords/new.xml
  def new
    @password = Password.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @password }
    end
  end

  # GET /passwords/1/edit
  def edit
    @password = Password.find(params[:id])
  end

  # POST /passwords
  # POST /passwords.xml
  def create
    @password = Password.new(params[:password])

    respond_to do |format|
      if @password.save
        flash[:notice] = 'Password was successfully created.'
        format.html { redirect_to(@password) }
        format.xml  { render :xml => @password, :status => :created, :location => @password }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @password.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /passwords/1
  # PUT /passwords/1.xml
  def update
    @password = Password.find(params[:id])

    respond_to do |format|
      if @password.update_attributes(params[:password])
        flash[:notice] = 'Password was successfully updated.'
        format.html { redirect_to(@password) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @password.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /passwords/1
  # DELETE /passwords/1.xml
  def destroy
    @password = Password.find(params[:id])
    @password.destroy

    respond_to do |format|
      format.html { redirect_to(passwords_url) }
      format.xml  { head :ok }
    end
  end
end