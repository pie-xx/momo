class Scriptbody < ActiveRecord::Base

  public
  def self.gettime
    momo = Momo.find_by_sql( "select * from momos where c_class like '%[video]%' and c_body not like '%<du></du>%';" ); 
    for m in momo do
      body = ""
      if /<du>([^<]+)</ =~ m.c_body then
        url = $1
        expdate = Time.now - 90.days
        cache = Scriptbody.find_by_sql("select * from scriptbodies where o_name like '%"+ url +"%';")
        if cache == nil || cache.length == 0 || cache[0].updated_on < expdate then
          p url
          Net::HTTP.start('www.dohhhup.com',80){|http|
            res = http.get(url)
            s = Scriptbody.new;
            s.o_name = url
            s.o_body = res.body
            s.save
            
            body = res.body
          }
        else
          body = cache[0].o_body
        end

        if /<span class='Movie_Info_Time'>(\d+):(\d+)</ =~ body then
          min = $1
          sec = $2
          ds = min.to_i*60+sec.to_i
          dt = Momo.find( m.id )
          if ! (/<dt>/ =~ dt.c_body) then
            dt.c_body = dt.c_body + '<dt>'+ds.to_s+'</dt>'
            p m.c_index, ds.to_s
          end
          dt.save
        end
      end
    end

#    Net::HTTP.start(host,port){|http|
#      res = http.get(cgi)
#    }
  end
end