<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:template name="diarybox">
<div class="mobjContainer">
  <xsl:attribute name="id">m<xsl:value-of select="id"/></xsl:attribute>
  <table>
  <tr>

  <td style="vertical-align:top;">
    <div class="mobjhan"><xsl:attribute name="onMouseUp">startMenu(event,'<xsl:value-of select="id"/>');</xsl:attribute>
    <xsl:if test="not(contains(c_class,'[br]'))">■</xsl:if>
    <xsl:if test="contains(c_class,'[br]')">⏎</xsl:if>
    </div><br/>
    <div>
      <xsl:attribute name="onclick">draggableTarget(event,'<xsl:value-of select="id"/>');</xsl:attribute>
      ⇔
    </div>
  </td>

  <td>
  <div class="recdata" style="display:none;"><xsl:copy-of select="."/></div>
  <xsl:call-template  name="casedisp"/>
  </td>
  </tr>
  </table>
</div>
<xsl:if test="contains(c_class,'[br]')">
<br clear="all"/>
</xsl:if>
</xsl:template>

<xsl:template name="casedisp">
  <xsl:choose>
    <xsl:when test="contains( c_class,'[pic]')">
      <div class="[pic]">
      <xsl:attribute name="id">c<xsl:value-of select="id"/></xsl:attribute>
        <img align="left" hspace="4" vspace="4">
          <xsl:attribute name="src">
            <xsl:if test="c_body/src">
              <xsl:if test="contains(c_body/src,'/')">
                <xsl:value-of select="c_body/src"/>
              </xsl:if>
              <xsl:if test="not(contains(c_body/src,'/'))">
                /momo/get/<xsl:value-of select="c_body/src"/>
              </xsl:if>
            </xsl:if>
          </xsl:attribute>
          <xsl:if test="c_body/width">
          <xsl:attribute name="width">
            <xsl:value-of select="c_body/width"/>
          </xsl:attribute>
          </xsl:if>
          <xsl:if test="c_body/height">
          <xsl:attribute name="height">
            <xsl:value-of select="c_body/height"/>
          </xsl:attribute>
          </xsl:if>
        </img><br clear="all"/>
        <span style="text-align:center; font-size:small;"><xsl:value-of select="c_body/cap"/></span>
      </div>
    </xsl:when>

    <xsl:when test="contains( c_class,'[plist]')">
      <div class="[plist]">
      <xsl:attribute name="id">c<xsl:value-of select="id"/></xsl:attribute>
        <blockquote class="plist"><pre><xsl:apply-templates select="c_body/list"/></pre></blockquote>
        <span style="text-align:center; font-size:small;"><xsl:value-of select="c_body/cap"/></span>
      </div>
    </xsl:when>

    <xsl:when test="contains( c_class,'[image]')">
      <div class="[image]">
      <xsl:attribute name="id">c<xsl:value-of select="id"/></xsl:attribute>
        <img align="left" hspace="8" vspace="4">
        <xsl:attribute name="src">
          /momo/get/<xsl:value-of select="id"/>
        </xsl:attribute>
        </img><br/>
      </div>
    </xsl:when>
    
    <xsl:when test="contains( c_class,'[youtube]')">
      <div class="[youtube]">
      <xsl:attribute name="id">c<xsl:value-of select="id"/></xsl:attribute>
      <object width="425" height="344">
        <param name="movie">
          <xsl:attribute name="value">
          http://www.youtube.com/v/<xsl:value-of select="c_body"/>&amp;hl=ja&amp;fs=1
          </xsl:attribute>
        </param>
        <param name="allowFullScreen" value="true"></param>
        <embed type="application/x-shockwave-flash" allowfullscreen="true" width="425" height="344">
          <xsl:attribute name="src">
          http://www.youtube.com/v/<xsl:value-of select="c_body"/>&amp;hl=ja&amp;fs=1
          </xsl:attribute>
        </embed>
      </object>
      </div>
    </xsl:when>

    <xsl:when test="contains( c_class,'[googlemap]')">
      <div class="[googlemap]">
      <xsl:attribute name="id">c<xsl:value-of select="id"/></xsl:attribute>
      <iframe frameborder="0" scrolling="no" marginheight="0" marginwidth="0" style="float:left; margin-right:1em;">
        <xsl:attribute name="width">
          <xsl:value-of select="c_body/iframe/@width"/>
        </xsl:attribute>
        <xsl:attribute name="height">
          <xsl:value-of select="c_body/iframe/@height"/>
        </xsl:attribute>
        <xsl:attribute name="src"><xsl:value-of select="c_body/iframe/@src"/></xsl:attribute>
      </iframe><br clear="all"/>
      </div>
    </xsl:when>

    <xsl:when test="contains( c_class,'[binary]')">
      <div class="[binary]">
      <xsl:attribute name="id">c<xsl:value-of select="id"/></xsl:attribute>
        <b><xsl:value-of select="substring-after(c_tag, '[diary]')"/></b>
        <a align="left" hspace="8" vspace="4">
          <xsl:attribute name="href">
            /momo/get/<xsl:value-of select="id"/>
          </xsl:attribute>
          <xsl:value-of select="c_body" />
        </a>
      </div>
    </xsl:when>

    <xsl:when test="contains( c_class,'[comment]')">
      <div class="mobj_comment">
      <xsl:attribute name="id">c<xsl:value-of select="id"/></xsl:attribute>
        <xsl:value-of select="created_jst"/> &#xa0;
        <xsl:if test="c_body/cb">
          <b><xsl:value-of select="c_body/ct"/></b> <br/>
          <xsl:value-of select="c_body/cb"/>
        </xsl:if>
        <xsl:if test="not(c_body/cb)">
        <xsl:value-of select="c_body"/>
        </xsl:if>
      </div>
    </xsl:when>
    
    <xsl:when test="contains( c_class,'[tb]')">
      <div class="[tb]">
      <xsl:attribute name="id">c<xsl:value-of select="id"/></xsl:attribute>
        trackback <xsl:value-of select="updated_jst"/> <br/>
        <a>
          <xsl:attribute name="href"><xsl:value-of select="c_body/url"/></xsl:attribute> 
          <xsl:value-of select="c_body/title"/>&#xa0;&#xa0;(<xsl:value-of select="c_body/blog_name"/>)
        </a><br/>
        <xsl:value-of select="c_body/excerpt"/>
      </div>
    </xsl:when>

    <xsl:when test="contains( c_class,'[quote]')">
      <div class="[quote]">
      <xsl:attribute name="id">c<xsl:value-of select="id"/></xsl:attribute>
        <blockquote><pre><xsl:apply-templates select="c_body"/></pre></blockquote>
      </div>
    </xsl:when>
    
    <xsl:otherwise>
     <div class="[text]">
     <xsl:attribute name="id">c<xsl:value-of select="id"/></xsl:attribute>
        <xsl:apply-templates select="c_body"/>
      </div>
    </xsl:otherwise>

  </xsl:choose>

</xsl:template>

<xsl:template match="c_body">
  <xsl:apply-templates />
</xsl:template>
<xsl:template match="text()">
  <xsl:value-of select="."/>
</xsl:template>
<xsl:template match="br">
  <br/>
</xsl:template>
<xsl:template match="b">
<b><xsl:value-of select="."/></b>
</xsl:template>
<xsl:template match="r">
<font color="red"><xsl:value-of select="."/></font>
</xsl:template>
<xsl:template match="list">
  <blockquote><pre><xsl:apply-templates /></pre></blockquote>
</xsl:template>
<xsl:template match="a">
  <a target="_brank">
  <xsl:attribute name="href">
  <xsl:value-of select="@href"/>
  </xsl:attribute>
  <xsl:apply-templates />
  </a>
</xsl:template>
<xsl:template match="table">
  <table>
  <xsl:if test="@border">
    <xsl:attribute name="border"><xsl:value-of select="@border"/></xsl:attribute>
  </xsl:if>
  <xsl:apply-templates />
  </table>
</xsl:template>
<xsl:template match="tr">
  <tr>
  <xsl:apply-templates />
  </tr>
</xsl:template>
<xsl:template match="th">
  <th><xsl:apply-templates /></th>
</xsl:template>
<xsl:template match="td">
  <td><xsl:apply-templates /></td>
</xsl:template>

<xsl:template match="embed">
<xsl:if test="not( contains( /momo/prof/useragent,'X11'))">
  <xsl:copy-of select="."/>
</xsl:if>
</xsl:template>
<xsl:template match="div">
  <div>
  <xsl:attribute name="style">
  <xsl:value-of select="@style"/>
  </xsl:attribute>
  <xsl:apply-templates />
  </div>
</xsl:template>

<!-- ////////////////////////////////////////////////////////////////////// -->
<xsl:template name="contextmenu">
<div id="contextmenu">
  <div id="MobjId" style="display:none;"/>
  <div style="background-color:lightblue;"><button style="background-color:red; text-align:left;" onClick="finishMenu();">x</button></div>
  <button class="menubutton" onMouseUp="inPlaceEditor();"><img src="/icons/32edit.png"/><br/>edit</button>
  <button class="menubutton" onMouseUp="cutMobj();"><img src="/icons/32px-Crystal_Clear_action_editcut.png"/><br/>cut</button>
  <button class="menubutton" onMouseUp="pasteMobj(true);"><img src="/icons/32px-Crystal_Clear_action_editpaste.png"/><br/>paste</button>
  <button class="menubutton" onMouseUp="deleteMobj();"><img src="/icons/32px-Crystal_Clear_action_editdelete.png"/><br/>delete</button>
  <br/>
  <button class="menubutton" onMouseUp="insertText();"><img src="/icons/32add_text.png"/><br/>+text</button>
  <button class="menubutton" onMouseUp="insertPic();"><img src="/icons/32add_image.png"/><br/>+pic</button>
  <button class="menubutton" onMouseUp="insertBr();"><img src="/icons/32add_br.png"/><br/>+br</button>
  <button class="menubutton" onMouseUp="insertYoutube();"><img src="/icons/32add_youtube.png"/><br/>+video</button>
</div>
<div id="Inscontextmenu">
  <div id="MobjId" style="display:none;"/>
  <div style="background-color:lightblue;"><button style="background-color:red; text-align:left;" onClick="finishMenu();">x</button></div>
  <button class="menubutton" onMouseUp="editTitle();"><img src="/icons/32edit.png"/><br/>edit</button>
  <button class="menubutton" onMouseUp="pasteMobj();"><img src="/icons/32px-Crystal_Clear_action_editpaste.png"/><br/>paste</button>
  <button class="menubutton" onMouseUp="insertTextAjax();"><img src="/icons/32add_text.png"/><br/>+text</button>
  <button class="menubutton" onMouseUp="insertPicAjax();"><img src="/icons/32add_image.png"/><br/>+pic</button>
  <button class="menubutton" onMouseUp="insertYoutubeAjax();"><img src="/icons/32add_youtube.png"/><br/>+video</button>
</div>
</xsl:template>

<!-- ////////////////////////////////////////////////////////////////////// -->
<xsl:template name="paginate">
<xsl:param name="tr"/>
<xsl:param name="tag"/>
<table width="100%">
<tr>
  <td align="left" width="30">
  <a>
  <xsl:if test="number(/momo/prof/offset - /momo/prof/limit)>=0">
  <xsl:attribute name="href">
    /<xsl:value-of select="/momo/prof/author"/>/<xsl:value-of select="/momo/prof/page"/>?limit=<xsl:value-of select="/momo/prof/limit"/>&amp;offset=<xsl:value-of select="number(/momo/prof/offset - /momo/prof/limit)"/>
    <xsl:if test="string-length($tr)!=0">&amp;tr=<xsl:value-of select="$tr"/></xsl:if>
    <xsl:if test="string-length($tag)!=0">&amp;tag=<xsl:value-of select="$tag"/></xsl:if>
  </xsl:attribute>
  </xsl:if>
  Prev
  </a>
  </td>

  <td>
  <a>
  <xsl:attribute name="href">
    /<xsl:value-of select="/momo/prof/author"/>/<xsl:value-of select="/momo/prof/page"/>?limit=<xsl:value-of select="/momo/prof/limit"/>&amp;offset=0
    <xsl:if test="string-length($tr)!=0">&amp;tr=<xsl:value-of select="$tr"/></xsl:if>
    <xsl:if test="string-length($tag)!=0">&amp;tag=<xsl:value-of select="$tag"/></xsl:if>
  </xsl:attribute>
  Latest</a>
  </td>

  <td align="right"><a rel="next">
  <xsl:attribute name="href">
    /<xsl:value-of select="/momo/prof/author"/>/<xsl:value-of select="/momo/prof/page"/>?limit=<xsl:value-of select="/momo/prof/limit"/>&amp;offset=<xsl:value-of select="number(/momo/prof/offset + /momo/prof/limit)"/>
    <xsl:if test="string-length($tr)!=0">&amp;m_tr=<xsl:value-of select="$tr"/></xsl:if>
    <xsl:if test="string-length($tag)!=0">&amp;tag=<xsl:value-of select="$tag"/></xsl:if>
  </xsl:attribute>
  Next
  </a>
  </td>

</tr>
</table>
</xsl:template>

<!-- ////////////////////////////////////////////////////////////////////// -->
<xsl:template name="DiaryCommentForm">
  <xsl:param name="vindex"/>

<form method="POST" action="/momo/create" enctype="multipart/form-data">
  <input type="hidden" name="redirect">
  <xsl:attribute name="value">/<xsl:value-of select="/momo/prof/author"/>/<xsl:value-of select="/momo/prof/page"/>/<xsl:value-of select="/momo/prof/id"/></xsl:attribute>
  </input>
  <input type="hidden" name="author">
  <xsl:attribute name="value"><xsl:value-of select="/momo/prof/author"/></xsl:attribute>
  </input>
  <input type="hidden" name="page" value="diary-comment"/>
  <input type="hidden" name="momo[c_author]">
  <xsl:attribute name="value"><xsl:value-of select="/momo/prof/author"/></xsl:attribute>
  </input>
  <input type="hidden" name="momo[c_index]" size="60">
  <xsl:attribute name="value"><xsl:value-of select="$vindex"/></xsl:attribute>
  </input>
  <input type="hidden" name="momo[c_tag]">
  <xsl:attribute name="value">[diary]</xsl:attribute>
  </input>
  <input type="hidden" name="momo[c_class]">
  <xsl:attribute name="value">[comment]</xsl:attribute>
  </input>
  <input type="hidden" name="momo[c_status]">
  <xsl:attribute name="value">[public]</xsl:attribute>
  </input>
  diary comment  <br/>
  <input type="text" name="m_body[ct]"/><br/>
  <textarea cols="80" rows="5" name="m_body[cb]" wrap="hard"></textarea>
  <br/>
  <input type="submit"/>

</form>
trackback  - http://m-obj.com/momo/trackback/<xsl:value-of select="/momo/prof/id"/><br/>
</xsl:template>

</xsl:stylesheet>