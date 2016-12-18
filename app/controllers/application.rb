# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
##  protect_from_forgery # :secret => '86cec923c8da9aacdf9d1ad7456995f2'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  after_filter :set_charset
public
  C_DS_NORMAL = 0
  C_DS_FILE = 1
  C_DS_JSON = 2
  C_DS_RAW = 3
  C_DS_PRE = 4

protected
  
  def set_charset
    if @contenttype == nil then
      @contenttype = "text/xml"
    end
    response.headers["Content-Type"] = @contenttype
  end
  
public

  def insertXsl( xmlstr, xslurl )
    sepP = xmlstr.index('>')
    xmlhead = xmlstr[0..sepP]
    xmlbody = xmlstr[sepP+1..xmlstr.length]
    return xmlhead + '<?xml-stylesheet type="text/xsl" href="'+xslurl+'"?>'+xmlbody
  end

  def getContentXml( content )
    @ansXmlStr = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<momo>\r\n";
    oldIndexTagStr = ""
    for i in 0..content.size-1 do
      newIndexTagStr = content[i][:c_index];
      findDifferentTags( oldIndexTagStr, newIndexTagStr )
      oldIndexTagStr = newIndexTagStr
      @ansXmlStr = @ansXmlStr + @closeTagStr + @openTagStr

      rawflag = 0
      case content[i]['c_ds']
      when C_DS_JSON then
        c_body_json = ActiveSupport::JSON.decode( content[i]['c_body'] )
        bodystr = ""
        c_body_json.each do |param,val|
          bodystr = bodystr + tagstr( param.to_s, val )
        end
        content[i]['c_body'] = bodystr
        rawflag = 1
      when C_DS_RAW then
        rawflag = 1
      when C_DS_PRE then
        rawflag = 2
      end
      
      recstr = rec2xml( content[i], rawflag )
      @ansXmlStr = @ansXmlStr + recstr + "\r\n"
    end
    findDifferentTags( oldIndexTagStr, "" )
    @ansXmlStr = @ansXmlStr + @closeTagStr + "</momo>"
    return @ansXmlStr
  end

  def rec2xml(rec, rawflag)
    rstr = ""
    rec.attribute_names.each { |column|
      colstr = ""
      if column == 'c_body' then
        case rawflag
        when 1 then
          colstr =  '<'+ column +'>'+ rec[column] +'</'+column+'>'
        when 2 then
          colstr =  '<'+ column +'>'+ ERB::Util.h(rec[column]) +'</'+column+'>'
        else
          colstr = tagstr( column, rec[column])
        end
      elsif column == 'updated_on' || column == 'created_on'
        colstr = '<'+ column +'>'+ rec[column].strftime('%Y-%m-%dT%H:%M:%SZ') +'</'+column+'>'
      else
        colstr = tagstr( column, rec[column])
      end
    
      rstr = rstr + colstr
    }

    recstr = "<rec>"+ rstr + "</rec>"
  end

  def findDifferentTags( oldStr, newStr )
    if( oldStr == nil || oldStr == "" )
      @oldIndexTagS = Array.new(0)
    else
      @oldIndexTagS = oldStr.split( '/' )
    end
    if( newStr == nil || newStr == "" )
      @newIndexTagS = Array.new(0)
    else
      @newIndexTagS = newStr.split( '/' )
    end

    for i in 0..@oldIndexTagS.size do
      if( @oldIndexTagS[i] != @newIndexTagS[i])
        break
      end
    end
    closeTagS = @oldIndexTagS[ i..@oldIndexTagS.size ]
    @closeTagStr = ""
    for j in 0..closeTagS.size-1 do
      @closeTagStr = "</item"+ (i+j).to_s + ">\r\n" + @closeTagStr
    end
    openTagS = @newIndexTagS[ i..@newIndexTagS.size ]
    @openTagStr = ""
    for k in 0..openTagS.size-1 do
      @openTagStr = @openTagStr + "<item"+ (i+k).to_s + " class=\"" + ERB::Util.h(openTagS[k].to_s) + "\">\r\n"
    end
  end

  def hbr(str)
    str = ERB::Util.h(str)
    str = str.gsub(/\r\n|\r|\n/, "<br/>\r\n")
    return str
  end

  def tagstr( tag, value )
    return "<"+tag.to_s+">"+hbr(value.to_s)+"</"+tag.to_s+">"
  end

  # sql に変数を埋め込んで絞込み検索 
  def SqlInsertCondition( sqlstr, defaultv )
    if sqlstr == nil || sqlstr == "" then
      return nil
    end
    sqlptnS = sqlstr.split('$')
    anssql = sqlptnS[0]
    for i in 1..sqlptnS.size-1 do
      if sqlptnS[ i - 1 ] == "" then
        anssql = anssql + '$' + sqlptnS[ i ]
      else
        /(\w+)(.*)/ =~ sqlptnS[ i ]
        if defaultv[$1] == nil then
          anssql = anssql + $2
        else
          anssql = anssql + removeSqlInjection( defaultv[$1] ) + $2
        end
      end
    end
    return anssql
  end

  def removeSqlInjection(insertStr)
    while insertStr["'"] != nil 
      insertStr["'"] = "_"
    end
    while insertStr[";"] != nil 
      insertStr[";"] = "_"
    end
    while insertStr['"'] != nil 
      insertStr['"'] = "_"
    end
    return insertStr
  end

end