var origtext;
var origid;

function inPlaceEditor() {
  if( origtext == '' ) {
    var id = $('#MobjId').text();
    origid = id;
    var target = document.getElementById('c'+id);
    var tw = target.clientWidth;
    var th = target.clientHeight + 20;

    origtext = target.innerHTML;
    tclass = target.getAttribute('class');
    if( tclass == '[text]' ){
      iPE_Text( target );
    }else
    if( tclass == '[quote]' ){
      iPE_Quote( target );
    }else
    if( tclass == '[pic]' ){
      iPE_Pic( target );
    }else
    if( tclass == '[image]' ){
      iPE_Image( target );
    }else
    if( tclass == '[youtube]' ){
      iPE_Youtube( target );
    }else{
      origtext = '';
    }
  }
  finishMenu();
}

//--------------------------------------------------------------------
function draggableTarget(e,id){
  $('#MobjId').text( id );
  finishMenu();
  $('#m'+id).draggable({
    revert:true, 
    stop: function(event, ui) { UndraggableTarget(); },
    scroll: true,
    opacity: 0.5
  });
  $('#m'+id).css("border-style","dotted");
  $('#m'+id).css("border-width","1px");
}
function UndraggableTarget(){
  var id = $('#MobjId').text();
  finishMenu();
  $('#m'+id).draggable('destroy');
  $('#m'+id).css("border-style","none");
}
//--------------------------------------------------------------------

function iPE_Image( target ) {
    var srctext = target.getElementsByTagName('img')[0].getAttribute('src');

    target.innerHTML = 
    '<img name="uframe" height="240" src="'+srctext+'"></iframe>'+
    '<br/>'+
    '[pic]に変換します。<br/>'+
      'caption:<input name="cap_value" id="imagecap" size="80" /><br/>'
      +'<button onclick="iPE_ImageOK()">OK</button><button onclick="iPlaceEditorCancel()">Cancel</button>';
}

function iPE_ImageOK() {
  var captext = document.getElementById('imagecap').value;
  
  var mobjid = $('#MobjId').text();
  $.get('/demo/memo-at/'+mobjid,
    {'m_subfix':'yes','m_tr':'no'},
    function( data ){
      $.post('/momo/create',
        'momo[c_index]='+getIdVal( data, mobjid, 'c_index' )+'&'+
         'author=demo&'+
         'page=memo-new&'+
         'momo[c_subindex]='+ getIdVal( data, mobjid, 'c_subindex' )+'&'+
         'momo[c_class]=[pic]&'+
         'momo[c_tag]='+getIdVal( data, mobjid, 'c_tag' )+'&'+
         'momo[c_status]='+getIdVal( data, mobjid, 'c_status' )+'&'+
         'momo[c_ds]=3&'+
         'momo[c_body]=<src>/momo/get/'+mobjid+'</src><cap>'+ captext +'</cap>'
      );
      $.post('/momo/update/'+mobjid, "momo[c_tag]=",
        function(){ location.href = '/demo/memo-at/'+mobjid }
      );
    }
  );
  origtext = "";
}
//--------------------------------------------------------------------

function iPE_Pic( target ) {
    var srctext = target.getElementsByTagName('img')[0].getAttribute('src');
    var captext = target.getElementsByTagName('span')[0].innerHTML;

    target.innerHTML = 
    '<iframe name="uframe" height="240" src="'+srctext+'"></iframe>'+
    '<form method="post" action="/momo/create" enctype="multipart/form-data" target="uframe">'+
    '<input type="hidden" name="redirect" value="/pie/uppic"/>'+
    '<input type="hidden" name="author" value="demo"/>'+
    '<input type="hidden" name="page" value="demo-new"/>'+
    '<input type="file" name="upfile" size="60"/><input type="submit"/>'+
    '</form>'+
    '<br/>'+      'src:<input name="src_value" id="picsrc" size="80" value="'+srctext +'"><br/>'
      +'cap:<input name="cap_value" id="piccap" size="80" value="'+captext +'"><br/>'
      +'<button onclick="iPE_PicOK()">OK</button><button onclick="iPlaceEditorCancel()">Cancel</button>';
}

function iPE_PicOK() {
  var id = origid;
  var content = document.getElementById('c'+id);
  var pictext = document.getElementById('picsrc').value;
  var captext = document.getElementById('piccap').value;

  var cbody="momo[c_body]=<src>" + textEscape( pictext )+"</src><cap>"+ textEscape( captext )+"</cap>";
  $.post('/momo/update/'+id, cbody);

  content.innerHTML = '<div id="c'+id+'" class="[pic]"><image src="'+pictext +'"/><br clear="all"/><span>'+captext+'</span>';
  origtext = "";
}

function insertPicAjax( si ){
  var mobjid = $('#MobjId').text();
  $.get('/demo/memo-at/'+mobjid,
    {'m_subfix':'yes','m_tr':'no'},
    function( data ){
      var subindex = "0000";
      if( si ){
        subindex = getIdVal( data, mobjid, 'c_subindex' ).substr(0,3)+'5';
      }
      $.post('/momo/create',
        'momo[c_index]='+ins_index+'&'+
         'author=pie&'+
         'page=memo-new&'+
         'momo[c_subindex]='+ subindex+'&'+
         'momo[c_class]=[pic]&'+
         'momo[c_tag]='+ins_tag+'&'+
         'momo[c_status]='+ins_status+'&'+
         'momo[c_ds]=3&'+
         'momo[c_body]=<src>http://m-obj.com/images/200611Azuma.jpg</src><cap>Azuma(2006)</cap>'
      );
      location.href = '/demo/memo-at/'+mobjid;
    }
  );
}
function insertPic(){
  insertPicAjax( true );
}
function insertPicTop(){
  insertPicAjax();
}

//--------------------------------------------------------------------

function iPE_Youtube( target ) {
    var srctext = target.getElementsByTagName('embed')[0].getAttribute('src').split('/v/')[1].substr(0,11);
    // embed の src 属性の先頭に空白コードの%エスケープがあると
    // 取消時にうまく表示されないので除去
    var slist = target.getElementsByTagName('embed')[0].getAttribute('src').split('http:');
    target.getElementsByTagName('embed')[0].setAttribute('src','http:'+slist[1]);
    origtext = target.innerHTML;
    
    target.innerHTML = 
            '<embed type="application/x-shockwave-flash" allowfullscreen="true" width="400" height="300" '+
          'src="http://www.youtube.com/v/'+srctext+'&amp;hl=ja&amp;fs=1"></embed><br clear="all"/><br/>'+
      'v:<input name="src_value" id="youtubesrc" size="80" value="'+srctext +'"><br/>'
      +'<button onclick="iPE_YoutubeOK()">OK</button><button onclick="iPlaceEditorCancel()">Cancel</button>';
}

function iPE_YoutubeOK() {
  var id = origid;
  var content = document.getElementById('c'+id);
  var youtubetext = document.getElementById('youtubesrc').value;

  var p = youtubetext.indexOf('v=');
  if( p != -1 ) {
    youtubetext = youtubetext.substr( p+2, 11 );
  }

  var cbody="momo[c_body]=" + textEscape( youtubetext );
  $.post('/momo/update/'+id, cbody);

  content.innerHTML = '<div id="c'+id+'" class="[youtube]">'+
        '<embed type="application/x-shockwave-flash" allowfullscreen="true" width="425" height="344" '+
          'src="http://www.youtube.com/v/'+youtubetext+'&amp;hl=ja&amp;fs=1"></embed><br clear="all"/></div>';
  origtext = "";
}

function insertYoutubeAjax( si ){
  var mobjid = $('#MobjId').text();
  $.get('/demo/memo-at/'+mobjid,
    {'m_subfix':'yes','m_tr':'no'},
    function( data ){
      var subindex = "0000";
      if( si ){
        subindex = getIdVal( data, mobjid, 'c_subindex' ).substr(0,3)+'5';
      }
      $.post('/momo/create',
        'momo[c_index]='+ins_index+'&'+
         'author=demo&'+
         'page=memo-new&'+
         'momo[c_subindex]='+ subindex+'&'+
         'momo[c_class]=[youtube]&'+
         'momo[c_tag]='+ins_tag+'&'+
         'momo[c_status]='+ins_status+'&'+
         'momo[c_ds]=0&'+
         'momo[c_body]=-BMxcuzb0UY'
      );
      location.href = '/demo/memo-at/'+mobjid;
    }
  );
}
function insertYoutube(){
  insertYoutubeAjax( true );
}
function insertYoutubeTop(){
  insertYoutubeAjax();
}

//--------------------------------------------------------------------

function iPE_Quote( target ) {
    var edittext = target.getElementsByTagName('pre')[0].innerHTML.replace(/<br>/g, "");
    target.innerHTML = 
      '<textarea name="inplace_value" id="tarea" rows="10" cols="80">'
      + edittext +'</textarea><br/><button onclick="iPE_QuoteOK()">OK</button><button onclick="iPlaceEditorCancel()">Cancel</button>';
}

function iPE_QuoteOK() {
  var id = origid;
  var content = document.getElementById('c'+id);
  var etext = document.getElementById('tarea').value;

  var cbody="momo[c_body]=" + textEscape( etext );
  $.post('/momo/update/'+id, cbody);

  etext = etext.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
  content.innerHTML = '<blockquote><pre>'+etext +'</pre></blockquote>';
  origtext = "";
}

function insertQuoteAjax( si ){
  var mobjid = $('#MobjId').text();
  $.get('/demo/memo-at/'+mobjid,
    {'m_subfix':'yes','m_tr':'no'},
    function( data ){
      var subindex = "0000";
      if( si ){
        subindex = getIdVal( data, mobjid, 'c_subindex' ).substr(0,3)+'5';
      }
      $.post('/momo/create',
        'momo[c_index]='+ins_index+'&'+
         'author=demo&'+
         'page=memo-new&'+
         'momo[c_subindex]='+ subindex+'&'+
         'momo[c_class]=[quote]&'+
         'momo[c_tag]='+ins_tag+'&'+
         'momo[c_status]='+ins_status+'&'+
         'momo[c_ds]=0&'+
         'momo[c_body]=---'
      );
      location.href = '/demo/memo-at/'+mobjid;
    }
  );
}
//--------------------------------------------------------------------
function iPE_Text( target ) {
    var edittext = target.innerHTML.replace(/<br>/g, "");
    target.innerHTML = 
      '<textarea name="inplace_value" id="tarea" rows="10" cols="80">'
      + edittext +'</textarea><br/><button onclick="iPE_TextOK()">OK</button><button onclick="iPlaceEditorCancel()">Cancel</button>';
}

function iPE_TextOK() {
  var id = origid;
  var content = document.getElementById('c'+id);
  var etext = document.getElementById('tarea').value;

  var cbody="momo[c_body]=" + textEscape( etext );
  $.post('/momo/update/'+id, cbody);

  etext = etext.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
  etext = etext.replace(/\r\n/g, "<br/>\r\n").replace(/(\n|\r)/g, "<br/>\r\n");
  content.innerHTML = etext;
  origtext = "";
}

function insertTextAjax( si ){
  var mobjid = $('#MobjId').text();
  $.get('/demo/memo-at/'+mobjid,
    {'m_subfix':'yes','m_tr':'no'},
    function( data ){
      var subindex = "0000";
      if( si ){
        subindex = getIdVal( data, mobjid, 'c_subindex' ).substr(0,3)+'5';
      }
      $.post('/momo/create',
        'momo[c_index]='+ins_index+'&'+
         'author=demo&'+
         'page=memo-new&'+
         'momo[c_subindex]='+ subindex+'&'+
         'momo[c_tag]='+ins_tag+'&'+
         'momo[c_status]='+ins_status+'&'+
         'momo[c_ds]=0&'+
         'momo[c_body]=---'
      );
      location.href = '/demo/memo-at/'+mobjid;
    }
  );
}

function insertText(){
  insertTextAjax( true );
}
function insertTextTop(){
  insertTextAjax();
}
//--------------------------------------------------------------------
function insertBr(){
  var si = true;
  var mobjid = $('#MobjId').text();
  $.get('/demo/memo-at/'+mobjid,
    {'m_subfix':'yes','m_tr':'no'},
    function( data ){
      var subindex = "0000";
      if( si ){
        subindex = getIdVal( data, mobjid, 'c_subindex' ).substr(0,3)+'5';
      }
      $.post('/momo/create',
        'momo[c_index]='+ins_index+'&'+
         'author=demo&'+
         'page=memo-new&'+
         'momo[c_subindex]='+ subindex+'&'+
         'momo[c_tag]='+ins_tag+'&'+
         'momo[c_status]='+ins_status+'&'+
         'momo[c_ds]=0&'+
         'momo[c_class]=[br]'
      );
      location.href = '/demo/memo-at/'+mobjid;
    }
  );
}

/////////////////////////////////////////////////////////////////

function startMenu( e,id ){
  if( $('#contextmenu').css('display')!='block' ){
    if( document.all )
        e = event;
    var scrollTop  = document.body.scrollTop  || document.documentElement.scrollTop;
    var x = e.clientX;
    var y = e.clientY + scrollTop - 40;
    $('#contextmenu').css('top',y );
    $('#contextmenu').css('left',x);
    $('#contextmenu').css('z-index','10000' );
    $('#MobjId').text( id );

    $('#contextmenu').css('display','block');
    $('#contextmenu').draggable();
  }else{
    finishMenu();
  }
}

function startInsMenu( e,id ){
  if( $('#Inscontextmenu').css('display')!='block' ){
    if( document.all )
        e = event;
    var scrollTop  = document.body.scrollTop  || document.documentElement.scrollTop;
    var x = e.clientX;
    var y = e.clientY + scrollTop - 40;
    $('#Inscontextmenu').css('top',y );
    $('#Inscontextmenu').css('left',x);
    $('#Inscontextmenu').css('z-index','10000' );
    $('#MobjId').text( id );

    $('#Inscontextmenu').css('display','block');
    $('#Inscontextmenu').draggable();

  }else{
    finishMenu();
  }
}

function finishMenu(){
  $('#contextmenu').css('display','none');
  $('#Inscontextmenu').css('display','none');
}

function iPlaceEditorCancel() {
  var id = origid;
  var target = document.getElementById('c'+id);
  target.innerHTML = origtext;
  origtext = "";
}

//////////////////////////////////////////////////////////////////////
function editTitle(){
  finishMenu();
  $('#dtitle').css("display","none");
  $('#dipe').css("display","block");
}
function editTitleCancel() {
  $('#dipe').css("display","none");
  $('#dtitle').css("display","block");
}

function editMobj(){
 location.href='/demo/memo-edit/'+$('#MobjId').text()
}

function insertMobj(){
 location.href='/demo/memo-insert/'+$('#MobjId').text()
}

function deleteMobj( fromall ){
  finishMenu();
  var mobjid = $('#MobjId').text();
  if( confirm('Are you sure? ['+mobjid+']') ) {
    $.get('/momo/destroy/'+mobjid ,{},
      function( data ){
        if( fromall ) {
          location.href = '/demo/memo';
        }else{
          location.href = '/demo/memo-at/'+top_id;
        }
      }
    );
  }
}

/////////////////////////////////////////////////////////////////

function textEscape(str){
  return encodeURIComponent( str );
}

function getInsertNumberOld( mid ) {
  var mobjid = mid ;
  var sis = document.getElementById('m'+mobjid).getAttribute('si');
  var si = ('0000'+(parseInt( sis, 10 ) + 5).toString(10)).substr(-4);
  return si;
}

function getval( elem, name ) {
  var val = elem.getElementsByTagName( name )[0].textContent;
  if( val == null ) {
    val = elem.getElementsByTagName( name )[0].text;
  }
  return val;
}

function getIdVal( doc, id, name ){
  var dlist = doc.getElementsByTagName('rec');
  for( var n = 0; n < dlist.length; ++n ){
    if(getval(dlist[n],'id')== id ){
      return getval( dlist[n], name );
    }
  }
}

//////////////////////////////////////////////////////////////////////