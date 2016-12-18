class MomoController < ApplicationController
#  require 'xml/xslt'  not installed
#  require 'xml/libxslt' not installed
  require 'rubygems'
  require 'nkf'

HasRMagic = true
if HasRMagic
  require 'RMagick' # RMagickのライブラリを読み込む。大文字小文字に注意
end
  MAXIMAGEWIDTH = 320.0 # これ以上大きい幅のイメージは縮小される
  MAXIMAGEHIGHT = 400.0 # これ以上大きい高さのイメージは縮小される
  MoMOHOME = "/home/cutiepie/momo"

  C_DS_NORMAL = 0
  C_DS_FILE = 1
  C_DS_JSON = 2
  C_DS_RAW = 3
  C_DS_PRE = 4

  S_ST_NORMAL = 0
  S_ST_FILE = 2
  S_ST_OTHERDB = 1

  before_filter :authenticate, :except => [ :logout, :login, :test, :get, :dispatch]

private

  def authenticate
    @author = params[:author ]
    @page = params[:page ]
    @disp = params[:disp ]
    @checkpass = params[:pass ]
    @checkuser = params[:user ]
    if @checkpass == nil
      @checkpass = session[:pass ]
      @checkuser = session[:user ]
    end

    if @disp=='xsl' then
      return true
    end
    if @author == nil || @page == nil then
#      render :text => "error", :status => "400"
#      return false
      return true
    end

    @sqlxsl = Sqlxsl.find_by_sql("select * from sqlxsls where author='"+@author+"' and page='"+@page+"';")
    if @sqlxsl.size == 0 then
      return true
    end

    if @sqlxsl[0][:showto] == nil || @sqlxsl[0][:showto] == ""
        return true
    end

    if @checkuser.to_s != "" && ! checkUser( @checkuser, @sqlxsl[0][:showto]) then
      render :text => "error", :status => "401"
      return false
    end
    @checkpassword = Password.find_by_sql("select * from passwords where user='" + @checkuser.to_s + "';")
    if @checkpassword.size != 0
      if @checkpass == @checkpassword[0][:pass]
        session[:user] = @checkuser
        session[:pass] = @checkpass
        return true
      end
    end
    render :text => "error", :status => "401"
    return false
  end

  def checkUser( user, liststr )
    if liststr==nil
      return true
    end
    list = liststr.split()
    for i in 0..list.size
      if list[i] == user then
      	return true
      end
    end
    return false
  end

  def insertProfileStr( xmlstr, debugstr )
    sepP = xmlstr.index('</momo>')
    if sepP == nil
    	return xmlstr+debugstr
    end
    xmlhead = xmlstr[0..sepP-1]
    xmlbody = xmlstr[sepP..xmlstr.length]
    return xmlhead + '<prof>' + debugstr + '</prof>' + xmlbody
  end
  
  def binsave(upfile)
      #!todo  ユニークなファイル名の生成にもっといい方法がありそう
      storelocation = MoMOHOME + "/public/images/"
      uniqfilename = DateTime.now.strftime("%Y%m%d%H%M%S-") + upfile.original_filename
      File.open( storelocation + uniqfilename, "wb"){ |f| f.write(upfile.read) }
      @momo[:c_body ] = uniqfilename
      @momo[:c_type ] = upfile.content_type
      @momo[:c_ds ] = C_DS_FILE
      if upfile.content_type.include?('image/') then
        @momo[:c_class ] = '[image]'
      else
        @momo[:c_class ] = '[binary]'
      end
if HasRMagic
      begin
        img = Magick::Image.from_blob( File.read(storelocation + uniqfilename) ).shift
        if img.columns > MAXIMAGEWIDTH || img.rows > MAXIMAGEHIGHT then
          ratio = ( img.rows > img.columns )? MAXIMAGEHIGHT / img.rows : MAXIMAGEWIDTH / img.columns
          new_img = img.resize( ratio ) 
          File.open( storelocation + 't' + uniqfilename, "wb"){ |f| f.write(new_img.to_blob) }
          @momo[:c_body ] = 't' + uniqfilename
        end
      rescue Magick::ImageMagickError, RuntimeError => ex
      end
end
  end

  def getxsl
      sqlxsl = Sqlxsl.find_by_sql("select xsl, st from sqlxsls where author='"+@author+"' and page='"+@page+"';")
      if sqlxsl.size == 0 then
        @answer = "page error"
      else
        case sqlxsl[0][:st] 
        when S_ST_NORMAL then
          @answer = render_to_string :xml => sqlxsl[0][:xsl]
        when S_ST_FILE
          File.open( MoMOHOME+"/public/" + sqlxsl[0][:xsl], "r"){ |f| @answer = f.read() }
        else
          scrbody = Sqlxsl.find_by_sql("select o_body as xsl from scriptbodies where o_name='"+sqlxsl[0][:xsl]+"';")
          if scrbody.size == 0 then
            @answer = "not find sqlxsl[0][:xsl] = " + sqlxsl[0][:xsl]
          else
            @answer = render_to_string :xml => scrbody[0][:xsl]
          end
        end
      end
      return @answer
  end
  
  def getItemXml( content )
    @ansXmlStr = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<momo>\r\n";
    oldIndexTagStr = ""
    for i in 0..content.size-1 do
      newIndexTagStr = content[i][:c_index];
      findDifferentTags( oldIndexTagStr, newIndexTagStr )
      oldIndexTagStr = newIndexTagStr
      @ansXmlStr = @ansXmlStr + @closeTagStr + @openTagStr

      rawflag = 1
     
      recstr = rec2xml( content[i], rawflag )
      @ansXmlStr = @ansXmlStr + recstr + "\r\n"
    end
    findDifferentTags( oldIndexTagStr, "" )
    @ansXmlStr = @ansXmlStr + @closeTagStr + "</momo>"
    return @ansXmlStr
  end

public
  def test
    trackback
#    @contenttype = "text/html"
#    render :text => %x'tail -80 /home/cutiepie/momo/log/development.log'
  end
  
# /momo/proxyhost=xx&port=xx&cgi=xx
# /momo/proxy?uri=http://xxx
  def proxy
    user = session[:user] || ""
    if user == ""
      render :text=> "error"
      return
    end
    
    if params[:uri]!=nil && params[:uri]!=""
      uri = URI.parse( params[:uri] )
      host = uri.host
      port = uri.port
      cgi = uri.path
    else
      host=params[:host]
      port=params[:port]
      cgi=params[:cgi]
    end
    if port.to_i == 0 then
      port= 80
    end
    cgi ||= ""
    if cgi== "" then
      cgi= "/"
    end

    Net::HTTP.start(host,port){|http|
      if request.post?
        entitystr = ""
        params.each {|key, value|
          entitystr = entitystr + key + '=' + URI.encode(value) + '&'
        }
        res = http.post( cgi, entitystr )
        @contenttype = res['content-type']
        render :text => res.body
      else
        res = http.get(cgi)
        @contenttype = res['content-type']
        render :text => res.body
      end
    }
  end
  
#   /momo/tags/c_tag
  def tags
    tagname = params[:id]
    tagdb = Momo.find_by_sql( 'select '+tagname+' from momos;' ); 
    taglist = Hash.new
    @ansXmlStr = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<momo>\r\n";
    for i in 0..tagdb.size-1 do
      if  tagdb[i][tagname] != nil then
        tline = tagdb[i][tagname].split(/[\[\]]/)
        if tline != nil then
        for j in 0..tline.size-1 do
          taglist[ tline[j] ] = taglist[ tline[j] ].to_i + 1
        end
        end
      end
    end
    taglist.each {|k,v|
      @ansXmlStr = @ansXmlStr + "<tag><name>"+k.to_s+"</name><num>"+v.to_s+"</num></tag>\r\n"
    }
    @ansXmlStr = @ansXmlStr + "</momo>"
      
    render :text => @ansXmlStr
  end

  def logout
    reset_session
    @contenttype = "text/html"
    send_file MoMOHOME + "/public/index.html", :type => "text/html", :disposition => 'inline'
  end

  def login
    reset_session
    @checkpass = params[:pass ]
    @checkuser = params[:user ]

    @checkpassword = Password.find_by_sql("select * from passwords where user='" + @checkuser.to_s + "';")
    if @checkpassword.size != 0
      if @checkpass == @checkpassword[0][:pass]
        session[:user] = @checkuser
        session[:pass] = @checkpass
      end
    end

    if params[:redirect] != nil then
      redirect_to( params[:redirect] )
    else
      redirect_to( "/"+@checkuser + "/login?tr=yes"  )
    end
  end
  
  def dispatch
    if request.get?
      get
    elsif request.post?
      create
    elsif request.put?
      update
    elsif request.delete?
      destroy
    end
  end
  
  	def upload
		user = params[:user ]
		page = params[:page ]
	
		upfile = params[:upfile]
		momolines = 'nothing'
		@xmldoc = "ng"
		bookname = upfile.original_filename().split('.')[0]
		if upfile.kind_of?(ActionController::UploadedTempfile) ||
			upfile.kind_of?(ActionController::UploadedStringIO) then
			doc = REXML::Document.new( upfile.read )
			doc.elements.each("doc/rec") { |element|
				momo = Momo.new
				momo[:c_author ] = user
				momo[:c_class ] = element.elements['c_class'].text if element.elements['c_class']
				momo[:c_index ] = bookname+'/'+element.elements['c_index'].text  if element.elements['c_index']
				momo[:c_body ] = element.elements['c_body'].text  if element.elements['c_body']
				momo[:c_tag ] = element.elements['c_tag'].text if element.elements['c_tag']
				momo[:c_ds ] = 0
				momo.save
			}
		@xmldoc = "ok"
		end
		@contenttype = "text/plain"
		render :text => @xmldoc, :status => :created
	end

  def get
    momo = Momo.find( params[:id ] )
    if momo[:c_showto ] != nil then
      if momo[:c_showto ].to_s!='' &&( session[:user].to_s == "" || ! checkUser( session[:user], momo[:c_showto ] )) then
        render :text => "error 401 user["+session[:user].to_s+"], showto["+momo[:c_showto ].to_s+"]", :status => "401"
        return false
      end
    end

    case momo[:c_ds]
    when C_DS_FILE then   # file
      @contenttype = momo[:c_type]
      storelocation = MoMOHOME + "/public/images/"
      send_file storelocation + momo[:c_body], :type => momo[:c_type], :filename => momo[:c_body], :disposition => 'inline'
    else          # text
      @contenttype = momo[:c_type]
      if @contenttype.to_s == '' then
        @contenttype = 'text/html'
      end
      render :text => momo[:c_body]
    end
  end

# /////////////////////////////////////////////////////////////////// 
  def trackback
    tbTarget = Momo.find(params[:id])
    tbrec = Momo.new()
    tbrec.c_author = tbTarget.c_author
    tbrec.c_index = tbTarget.c_index
    tbrec.c_status = tbTarget.c_status
    tbrec.c_tag = tbTarget.c_tag
    tbrec.c_body = tagstr('url', params[:url])+tagstr('blog_name', params[:blog_name])+tagstr('title', params[:title])+tagstr('excerpt', params[:excerpt])
    tbrec.c_ds = C_DS_RAW
    tbrec.c_class = '[tb]'

    ansXmlStr = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n";
    if tbrec.save
      ansXmlStr = ansXmlStr + tagstr('responce', tagstr('error','0')+tagstr('message','Ping saved successfully.') )
      render :xml => ansXmlStr, :status => :created
    else
      ansXmlStr = ansXmlStr + tagstr('responce', tagstr('error','1')+tagstr('message','Something Bad happened.') )
      render :xml => ansXmlStr, :status => :unprocessable_entity
    end    
  end
# /////////////////////////////////////////////////////////////////// 
  def disp
    if @disp=='xsl' then
      render :xml => getxsl()
    else
      if @sqlxsl.size == 0 then
        render :text => "page error ["+@author+"/"+@page+"]"
      else
        if @sqlxsl[0][:defaultv ] != nil then
          defaultv = ActiveSupport::JSON.decode( @sqlxsl[0][:defaultv ] )
          if defaultv == false || defaultv == nil then
            defaultv = Hash.new
          end
        else
          defaultv = Hash.new
        end
        params.each do |param,val|
          defaultv[ param.to_s ] = val
        end
        defaultv[ 'user' ] = @checkuser.to_s
        defaultv[ 'remote_ip' ] = request.remote_ip() 
        defaultv[ 'referer' ] = request.headers["Referer"]
        defaultv[ 'useragent' ] = request.headers["User-Agent"]

        sql = SqlInsertCondition( @sqlxsl[0][:sql ], defaultv )
        if sql == nil then
          @content = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<momo></momo>\r\n"
        else
          momocontent = Momo.find_by_sql( sql )
          if defaultv[ 'm_subfix' ]=='yes' then
            subindex = 0
            for m in momocontent do
              subindex = subindex + 10
              m.c_subindex = sprintf("%04d", subindex)
              if defaultv[ 'm_status' ]
                m.c_status = defaultv[ 'm_status' ]
              end
              if defaultv[ 'm_index' ]
                m.c_index = defaultv[ 'm_index' ]
              end
              if defaultv[ 'm_tag' ]
                m.c_tag = defaultv[ 'm_tag' ]
              end
              if defaultv[ 'm_subindex' ]
                m.c_subindex= defaultv[ 'm_subindex' ]
              end
              m.save
            end
          end
          @content = getContentXml( momocontent  )
        end

        if @sqlxsl[0][:xsl ] == nil then
          @answer = @content
        else
          @answer = insertXsl( @content, "/"+@author+"/"+@page+".xsl" )
        end

        profstr = ""
        defaultv.each do |para, val|
          if para != 'pass' then
            profstr = profstr + tagstr( para, val )
          end
        end
        
        if defaultv[ 'm_tr' ]=='yes' then
          body = insertProfileStr( @answer, profstr )    
          ENV['TMPDIR'] = MoMOHOME + "/public/"
          tmpfileXml = Tempfile.new('momotempXml')
          tmpfileXml.write( body )
          tmpfileXml.close()
          tmpfileXsl = Tempfile.new('momotempXsl')
          tmpfileXsl.write( getxsl() )
          tmpfileXsl.close()
          @contenttype = @sqlxsl[0]['trc_type']
          render :text => %x'xsltproc #{tmpfileXsl.path} #{tmpfileXml.path}'
        else
          render :text => insertProfileStr( @answer, profstr )           
        end
      end
    end
  end

  def create
    @momo = Momo.new(params[:momo])

    upfile = params[:upfile]
    if upfile.kind_of?(ActionController::UploadedTempfile) || upfile.kind_of?(ActionController::UploadedStringIO)then
      binsave( upfile )
    end
    m_body = params[:m_body]
    if m_body.kind_of?(Hash) then
      @momo.c_body = ""
      m_body.each do |para, val|
        @momo.c_body = @momo.c_body + tagstr(para, val)
      end
      @momo.c_ds = C_DS_RAW
    end

    if @momo.c_body && NKF.guess(@momo.c_body)!=NKF::UTF8 then
      @momo.c_body = NKF.nkf('--utf8', @momo.c_body)
    end
    if @momo.c_index && NKF.guess(@momo.c_index)!=NKF::UTF8 then
      @momo.c_index= NKF.nkf('--utf8', @momo.c_index)
    end

    if @momo.save
      flash[:notice] = 'Momo was successfully created.'
      if params[:redirect] != nil then
        pd = '?';
        if params[:redirect].index('?') then
          pd = '&';
        end
        redirect_to( params[:redirect] + pd + 'id=' + @momo.id.to_s )
      else
        render :xml => @momo, :status => :created, :location => @momo
      end
    else
      render :xml => @momo.errors, :status => :unprocessable_entity
    end
  end

  def update
    if params[:id]==nil || params[:id]=='' then
      @momo = Momo.new(params[:momo])
    else
      @momo = Momo.find(params[:id])
    end
    if ! checkUser( session[:user], @momo[:c_author ] ) then
      render :text => "error 401 user["+session[:user].to_s+"], showto["+@momo[:c_showto ].to_s+"]", :status => "401"
      return false
    end

    @momo.attributes = params[:momo]
    upfile = params[:upfile]
    if upfile.kind_of?(ActionController::UploadedTempfile) || upfile.kind_of?(ActionController::UploadedStringIO)then
      binsave( upfile )
    end

    m_body = params[:m_body]
    if m_body.kind_of?(Hash) then
      @momo.c_body = ""
      m_body.each do |para, val|
        @momo.c_body = @momo.c_body + tagstr(para, val)
      end
      @momo.c_ds = C_DS_RAW
    end

    if @momo.c_body && NKF.guess(@momo.c_body)!=NKF::UTF8 then
      @momo.c_body = NKF.nkf('--utf8', @momo.c_body)
    end
    if @momo.c_index && NKF.guess(@momo.c_index)!=NKF::UTF8 then
      @momo.c_index= NKF.nkf('--utf8', @momo.c_index)
    end

    if @momo.save
      flash[:notice] = 'Momo was successfully updated.'
      if params[:redirect]!=nil
        pd = '?';
        if params[:redirect].index('?') then
          pd = '&';
        end
        redirect_to( params[:redirect] + pd + 'id=' + @momo.id.to_s )
      else
        render :xml => @momo, :status => :created, :location => @momo
      end
    else
      render :xml => @momo.errors, :status => :unprocessable_entity
    end
  end

  def destroy
    momo = Momo.find( params[:id ] )
    if ! checkUser( session[:user], momo[:c_author ] ) then
      render :text => "error 401 user["+session[:user].to_s+"], showto["+momo[:c_showto ].to_s+"]", :status => "401"
      return false
    end
    
    @content = getContentXml( Momo.find_by_sql( "select * from momos where id="+params[:id] ) )
    Momo.delete( params[:id ] )

    case momo[:c_ds]
    when C_DS_FILE then   # file
      @contenttype = momo[:c_type]
      storelocation = MoMOHOME + "/public/images/" + momo[:c_body]
      File.delete( storelocation )
    end
    
    if params['redirect'].to_s != "" then
      redirect_to( params[:redirect] )
    else
      render :xml => @content
    end
  end
end