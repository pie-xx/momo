function showPlayer( id, path ){
	document.write("<object>" +
	"<param name=\"movie\" value=\"http://www.dohhhup.com/embed/embed.swf?uid="+id+"&path="+path+"\"></param>"+
	"<param name=\"allowFullScreen\" value=\"true\"></param>"+
	"<embed src=\"http://www.dohhhup.com/embed/embed.swf?uid="+id+"&path="+path+"\" type=\"application/x-shockwave-flash\" allowfullscreen=\"true\" width=\"720\" height=\"680\"></embed>" +
	"</object>");
}