<!--
    Strip rfc2629.xslt extensions, generating XML input for MTR's xml2rfc

    Copyright (c) 2006-2013, Julian Reschke (julian.reschke@greenbytes.de)
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice,
      this list of conditions and the following disclaimer in the documentation
      and/or other materials provided with the distribution.
    * Neither the name of Julian Reschke nor the names of its contributors
      may be used to endorse or promote products derived from this software
      without specific prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
    AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
    IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
    ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
    LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
    CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
    SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
    INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
    CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
    ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.
-->

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0"
                xmlns:ed="http://greenbytes.de/2002/rfcedit"
                xmlns:grddl="http://www.w3.org/2003/g/data-view#"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:x="http://purl.org/net/xml2rfc/ext"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="ed grddl rdf x xhtml"
>

<!-- re-use some of the default RFC2629.xslt rules -->
<xsl:import href="rfc2629.xslt"/>

<!-- undo strip-space decls -->
<xsl:preserve-space elements="*"/>

<!-- generate DTD-valid output, override all values imported from rfc2629.xslt -->
<xsl:output doctype-system="rfc2629.dtd" doctype-public="" method="xml" version="1.0" encoding="UTF-8" cdata-section-elements="artwork" />

<!-- kick into cleanup mode -->
<xsl:template match="/">
  <xsl:text>&#10;</xsl:text>
  <xsl:comment>
    This XML document is the output of clean-for-DTD.xslt; a tool that strips
    extensions to RFC2629(bis) from documents for processing with xml2rfc.
</xsl:comment>
  <xsl:apply-templates select="/" mode="cleanup"/>
</xsl:template>

<!-- rules for identity transformations -->

<xsl:template match="processing-instruction()" mode="cleanup">
  <xsl:text>&#10;</xsl:text>
  <xsl:copy/>
</xsl:template>

<xsl:template match="comment()|@*" mode="cleanup"><xsl:copy/></xsl:template>

<xsl:template match="text()" mode="cleanup"><xsl:copy/></xsl:template>

<xsl:template match="/" mode="cleanup">
	<xsl:copy><xsl:apply-templates select="node()" mode="cleanup" /></xsl:copy>
</xsl:template>

<xsl:template match="*" mode="cleanup">
  <xsl:element name="{local-name()}">
  	<xsl:apply-templates select="node()|@*" mode="cleanup" />
  </xsl:element>
</xsl:template>


<!-- remove PI extensions -->

<xsl:template match="processing-instruction('rfc-ext')" mode="cleanup"/>
<xsl:template match="processing-instruction('BEGININC')" mode="cleanup"/>
<xsl:template match="processing-instruction('ENDINC')" mode="cleanup"/>

<!-- add issues appendix -->

<xsl:template match="back" mode="cleanup">
  <back>
    <xsl:apply-templates select="node()|@*" mode="cleanup" />
    <xsl:if test="not(/*/@ed:suppress-issue-appendix='yes') and //ed:issue[@status='closed']">
      <section title="Resolved issues (to be removed by RFC Editor before publication)">
        <t>
          Issues that were either rejected or resolved in this version of this
          document.
        </t>
        <xsl:apply-templates select="//ed:issue[@status='closed']" mode="issues" />
      </section>
    </xsl:if>
    <xsl:if test="not(/*/@ed:suppress-issue-appendix='yes') and //ed:issue[@status='open']">
      <section title="Open issues (to be removed by RFC Editor prior to publication)">
        <xsl:apply-templates select="//ed:issue[@status!='closed']" mode="issues" />
      </section>
    </xsl:if>
  </back>
</xsl:template>




<!-- extensions -->

<xsl:template match="x:abnf-char-sequence" mode="cleanup">
  <xsl:choose>
    <xsl:when test="substring(.,1,1) != '&quot;' or substring(.,string-length(.),1) != '&quot;'">
      <xsl:call-template name="error">
        <xsl:with-param name="msg" select="'contents of x:abnf-char-sequence needs to be quoted.'" />
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>%x</xsl:text>
      <xsl:call-template name="to-abnf-char-sequence">
        <xsl:with-param name="chars" select="substring(.,2,string-length(.)-2)"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="x:anchor-alias" mode="cleanup"/>

<xsl:template match="x:bcp14" mode="cleanup">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="x:assign-section-number" mode="cleanup"/>  
<xsl:template match="x:link" mode="cleanup"/>
<xsl:template match="x:source" mode="cleanup"/>
<xsl:template match="x:feedback" mode="cleanup"/>

<xsl:template match="x:parse-xml" mode="cleanup">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="x:prose" mode="cleanup">
  <xsl:variable name="text" select="."/>
  <xsl:comment>Converted from rfc2629.xslt x:prose extension</xsl:comment>
  <xsl:choose>
    <xsl:when test="contains($text,' ')">
      <seriesInfo name="{substring-before($text,' ')}" value="{substring-after($text,' ')}"/>
    </xsl:when>
    <xsl:otherwise>
      <seriesInfo name="" value="{$text}"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="x:ref" mode="cleanup">
  <xsl:variable name="val" select="normalize-space(.)"/>
  <xsl:variable name="target" select="//*[@anchor and (@anchor=$val or x:anchor-alias/@value=$val)][not(ancestor::ed:del)] | //reference/x:source[x:defines=$val]"/>
  <xsl:if test="count($target)>1">
    <xsl:message terminate="yes">FATAL: multiple x:ref targets found for <xsl:value-of select="$val"/>.</xsl:message>
  </xsl:if>
  <xsl:choose>
    <xsl:when test="$target/self::x:source">
      <!-- drop it-->
      <xsl:value-of select="."/>
    </xsl:when>
    <xsl:when test="$target">
      <xsl:variable name="current" select="."/>
      <xsl:for-each select="$target">
        <!-- make it the context -->
        <xsl:choose>
          <xsl:when test="self::preamble">
            <!-- it's not an element we can link to -->
            <xsl:call-template name="warning">
              <xsl:with-param name="inline" select="'no'"/>
              <xsl:with-param name="msg">couldn't create the link as <xsl:value-of select="name()"/> does not support the anchor attribute.</xsl:with-param>
            </xsl:call-template>
            <xsl:value-of select="$current"/>
          </xsl:when>
          <xsl:otherwise>
            <xref target="{$target/@anchor}" format="none"><xsl:value-of select="$current"/></xref>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="warning">
        <xsl:with-param name="inline" select="'no'"/>
        <xsl:with-param name="msg">internal link target for '<xsl:value-of select="$val"/>' does not exist.</xsl:with-param>
      </xsl:call-template>
      <xsl:value-of select="."/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="x:blockquote" mode="cleanup">
  <t><list>
    <xsl:apply-templates mode="cleanup" />
  </list></t>
</xsl:template>

<xsl:template match="x:h" mode="cleanup">
  <xsl:apply-templates mode="cleanup" />
</xsl:template>

<xsl:template match="x:highlight" mode="cleanup">
  <xsl:apply-templates mode="cleanup" />
</xsl:template>

<xsl:template match="x:lt" mode="cleanup">
  <t>
    <xsl:apply-templates select="@hangText|@anchor" mode="cleanup"/>
    <xsl:for-each select="t">
      <xsl:apply-templates mode="cleanup"/>
      <xsl:if test="position()!=last()">
        <vspace blankLines="1"/>
      </xsl:if>
    </xsl:for-each>
  </t>
</xsl:template>

<xsl:template match="x:note" mode="cleanup">
  <t>
    <list>
      <xsl:apply-templates mode="cleanup"/>
    </list>
  </t>
</xsl:template>

<xsl:template match="x:q" mode="cleanup">
  <xsl:text>"</xsl:text>
  <xsl:apply-templates mode="cleanup"/>
  <xsl:text>"</xsl:text>
</xsl:template>

<xsl:template match="x:dfn" mode="cleanup">
  <!-- help xml2rfc to keep dfn and following text on the same page -->
  <!-- removed for now because it broke httpbis-p2 (def of 200 OK in -25)
  <xsl:if test="not(preceding-sibling::x:dfn) and count(following-sibling::list)=1 and normalize-space(../text()='')">
    <xsl:processing-instruction name="rfc">needLines="4"</xsl:processing-instruction>
  </xsl:if>-->
  <xsl:apply-templates mode="cleanup"/>
</xsl:template>

<xsl:template match="x:sup" mode="cleanup">
  <xsl:text>^</xsl:text>
  <xsl:apply-templates mode="cleanup" />
</xsl:template>

<xsl:template match="x:span" mode="cleanup">
  <xsl:apply-templates mode="cleanup" />
</xsl:template>
<xsl:template match="x:span/@anchor" mode="cleanup"/>

<xsl:template match="author/@anchor" mode="cleanup"/>
<xsl:template match="x:include-author" mode="cleanup">
  <t>
    <xsl:value-of select="/*/front/author[@anchor=current()/@target]"/>
  </t>
  <t>
    (see Authors Section)
  </t>
</xsl:template>

<!-- extended reference formatting -->

<xsl:template match="xref[(@x:fmt or @x:sec or @x:rel) and not(node())]" mode="cleanup">
  <xsl:call-template name="insert-iref-for-xref"/>
  <xsl:variable name="node" select="$src//*[@anchor=current()/@target]" />

  <xsl:variable name="sec">
    <xsl:choose>
      <xsl:when test="starts-with(@x:rel,'#') and not(@x:sec) and $node/x:source/@href">
        <xsl:variable name="extdoc" select="document($node/x:source/@href)"/>
        <xsl:for-each select="$extdoc//*[@anchor=substring-after(current()/@x:rel,'#')]">
          <xsl:call-template name="get-section-number"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@x:sec"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="secterm">
    <xsl:choose>
      <!-- starts with letter? -->
      <xsl:when test="translate(substring($sec,1,1),$ucase,'')=''">Appendix</xsl:when>
      <xsl:otherwise>Section</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="fmt">
    <xsl:choose>
      <xsl:when test="@x:fmt!=''"><xsl:value-of select="@x:fmt"/></xsl:when>
      <xsl:when test="ancestor::artwork">,</xsl:when>
      <xsl:otherwise>of</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="$fmt=','">
      <xref>
        <xsl:apply-templates select="@target|@format|@pageno|text()|*" mode="cleanup"/>
      </xref>
      <xsl:text>, </xsl:text>
      <xsl:value-of select="$secterm"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="$sec"/>
    </xsl:when>
    <xsl:when test="$fmt='sec'">
      <xsl:value-of select="$secterm"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="$sec"/>
    </xsl:when>
    <xsl:when test="$fmt='number'">
      <xsl:value-of select="$sec"/>
    </xsl:when>
    <xsl:when test="$fmt='()'">
      <xref>
        <xsl:apply-templates select="@target|@format|@pageno|text()|*" mode="cleanup"/>
      </xref>
      <xsl:text> (</xsl:text>
      <xsl:value-of select="$secterm"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="$sec"/>
      <xsl:text>)</xsl:text>
    </xsl:when>
    <xsl:when test="$fmt='of'">
      <xsl:value-of select="$secterm"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="$sec"/>
      <xsl:text> of </xsl:text>
      <xref>
        <xsl:apply-templates select="@target|@format|@pageno|text()|*" mode="cleanup"/>
      </xref>
    </xsl:when>
    <xsl:when test="$fmt='anchor'">
      <xsl:variable name="val">
        <xsl:call-template name="referencename">
          <xsl:with-param name="node" select="$node" />
        </xsl:call-template>
      </xsl:variable>
      <!-- remove brackets -->
      <xsl:value-of select="substring($val,2,string-length($val)-2)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy>
        <xsl:apply-templates select="node()" mode="cleanup"/>
      </xsl:copy>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="xref[(@x:fmt or @x:sec or @x:rel) and node()]" mode="cleanup">
  <xsl:call-template name="insert-iref-for-xref"/>
  <xsl:choose>
    <xsl:when test="@x:fmt='none'">
      <xsl:apply-templates mode="cleanup"/>
    </xsl:when>
    <xsl:when test="not(@x:fmt)">
      <xref>
        <xsl:copy-of select="@target|@format"/>
        <xsl:apply-templates mode="cleanup"/>
      </xref>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message>Unsupported x:fmt attribute.</xsl:message>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="xref[node() and (@target=//preamble/@anchor or @target=//spanx/@anchor)]" mode="cleanup">
  <!-- remove the link -->
  <xsl:apply-templates select="node()" mode="cleanup"/>
</xsl:template>

<xsl:template match="xref[not(node()) and (@target=//preamble/@anchor or @target=//spanx/@anchor)]" mode="cleanup">
  <!-- fatal -->
  <xsl:message terminate="yes">Broken xref <xsl:value-of select="@target"/> due to target being filtered out.</xsl:message>
</xsl:template>

<xsl:template match="xref" mode="cleanup" priority="0">
  <xsl:call-template name="insert-iref-for-xref"/>
  <xref>
    <xsl:copy-of select="@target|@format"/>
    <xsl:apply-templates mode="cleanup"/>
  </xref>
</xsl:template>

<xsl:template name="insert-iref-for-xref">
  <xsl:if test="$xml2rfc-ext-include-references-in-index='yesxxx' and $xml2rfc-ext-include-index='yes'">
    <xsl:if test="@target=/rfc/back//reference/@anchor">
      <iref item="{@target}"/>
      <xsl:if test="@x:sec">
        <xsl:choose>
          <xsl:when test="translate(substring(@x:sec,1,1),$ucase,'')=''">
            <iref item="{@target}" subitem="Appendix {@x:sec}"/>
          </xsl:when>
          <xsl:otherwise>
            <iref item="{@target}" subitem="Section {@x:sec}"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:if>
  </xsl:if>
</xsl:template>

<!-- drop index gen extension -->
<xsl:template match="iref" mode="cleanup">
  <xsl:if test="$xml2rfc-ext-include-index='yes'">
    <iref>
      <xsl:apply-templates select="@*|node()" mode="cleanup"/>
    </iref>
  </xsl:if>
</xsl:template>


<!-- issue tracking extensions -->

<xsl:template match="@xml:lang" mode="cleanup"/>
<xsl:template match="@xml:lang" />

<xsl:template match="ed:*" mode="cleanup"/>
<xsl:template match="ed:*" />

<xsl:template match="@ed:*" mode="cleanup"/>
<xsl:template match="@ed:*" />

<xsl:template match="ed:annotation" mode="cleanup" />

<xsl:template match="ed:replace" mode="cleanup">
  <xsl:apply-templates mode="cleanup" />
</xsl:template>

<xsl:template match="ed:replace">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="ed:ins" mode="cleanup">
  <xsl:apply-templates mode="cleanup"/>
</xsl:template>

<xsl:template match="ed:ins">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="ed:issue" mode="issues">
  <section title="{@name}">
    <xsl:variable name="sec">
      <xsl:call-template name="get-section-number"/>
    </xsl:variable>

    <xsl:if test="$sec!=''">
      <t>
        In Section <xsl:value-of select="$sec"/>:
      </t>
    </xsl:if>
    
    <t>
      Type: <xsl:value-of select="@type" />
    </t>
    <xsl:if test="@href">
      <t>
        <!-- temp. removed because of xml2rfc's handling of erefs when producing TXT-->
        <!--<eref target="{@href}" /> -->
        <xsl:text>&lt;</xsl:text>
        <xsl:value-of select="@href"/>
        <xsl:text>></xsl:text>
        <xsl:if test="@alternate-href">
          <xsl:text>, &lt;</xsl:text>
          <xsl:value-of select="@alternate-href"/>
          <xsl:text>></xsl:text>
        </xsl:if>
      </t>
    </xsl:if>
    <xsl:for-each select="ed:item">
      <t>
        <xsl:if test="@entered-by or @date">
          <xsl:choose>
            <xsl:when test="not(@entered-by)">
              <xsl:value-of select="concat('(',@date,') ')" />
            </xsl:when>
            <xsl:when test="not(@date)">
              <xsl:value-of select="concat(@entered-by,': ')" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat(@entered-by,' (',@date,'): ')" />
            </xsl:otherwise>
          </xsl:choose>      
        </xsl:if>
        <xsl:if test="not(xhtml:p)">
          <xsl:apply-templates select="node()" mode="issues"/>
        </xsl:if>
      </t>
      <xsl:if test="xhtml:p|xhtml:pre">
        <xsl:for-each select="node()">
          <xsl:choose>
            <xsl:when test="self::xhtml:p">
              <t>
                <xsl:apply-templates select="node()" mode="issues"/>
              </t>
            </xsl:when>
            <xsl:when test="self::xhtml:pre">
              <figure>
                <artwork><xsl:apply-templates select="node()" mode="issues"/></artwork>
              </figure>
            </xsl:when>
            <xsl:otherwise>
              <t>
                <xsl:apply-templates select="." mode="issues"/>
              </t>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:if>
    </xsl:for-each> 
    <xsl:if test="ed:resolution">
      <t>
        <xsl:text>Resolution</xsl:text>
        <xsl:if test="ed:resolution/@datetime"> (<xsl:value-of select="ed:resolution/@datetime"/>)</xsl:if>
        <xsl:text>: </xsl:text>
        <xsl:value-of select="ed:resolution" />
      </t>
    </xsl:if>
  </section>
</xsl:template>

<xsl:template match="ed:issueref" mode="cleanup">
  <xsl:apply-templates mode="cleanup"/>
</xsl:template>

<xsl:template match="*" mode="issues">
  <xsl:apply-templates mode="issues"/>
</xsl:template>

<xsl:template match="xhtml:q" mode="issues">
  <list><t>
    <xsl:text>"</xsl:text>
    <xsl:apply-templates mode="issues"/>
    <xsl:text>"</xsl:text>
    <xsl:if test="@cite">
      <xsl:text> -- </xsl:text>
      <eref target="{@cite}"><xsl:value-of select="@cite"/></eref>
    </xsl:if>
  </t></list>
</xsl:template>

<xsl:template match="xhtml:br" mode="issues">
  <vspace/>
</xsl:template>

<xsl:template match="xhtml:del" mode="issues">
  <xsl:text>&lt;del></xsl:text>
    <xsl:apply-templates mode="issues"/>
  <xsl:text>&lt;/del></xsl:text>
</xsl:template>

<xsl:template match="xhtml:em" mode="issues">
  <spanx style="emph">
    <xsl:apply-templates mode="issues"/>
  </spanx>
</xsl:template>

<xsl:template match="xhtml:ins" mode="issues">
  <xsl:text>&lt;ins></xsl:text>
    <xsl:apply-templates mode="issues"/>
  <xsl:text>&lt;/ins></xsl:text>
</xsl:template>

<xsl:template match="xhtml:tt" mode="issues">
  <xsl:apply-templates mode="issues"/>
</xsl:template>

<xsl:template match="ed:eref" mode="issues">
  <xsl:text>&lt;</xsl:text>
  <xsl:value-of select="."/>
  <xsl:text>&gt;</xsl:text>
</xsl:template>

<xsl:template match="ed:issueref" mode="issues">
  <xsl:apply-templates mode="issues"/>
</xsl:template>

<xsl:template match="text()" mode="issues">
  <xsl:value-of select="." />
</xsl:template>

<!-- workgroup format -->
<xsl:template match="workgroup" mode="cleanup">
  <workgroup>
    <xsl:variable name="v" select="normalize-space(.)"/>
    <xsl:variable name="h">
      <!-- when a single name, append WG/RG postfix automatically -->
      <xsl:choose>
        <xsl:when test="not(contains($v, ' ')) and starts-with(/rfc/@docName,'draft-ietf-') and $submissionType='IETF'">
          <xsl:value-of select="concat($v, ' Working Group')"/>
        </xsl:when>
        <xsl:when test="not(contains($v, ' ')) and starts-with(/rfc/@docName,'draft-irtf-') and $submissionType='IRTF'">
          <xsl:value-of select="concat($v, ' Research Group')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$v"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="$h"/>
  </workgroup>
</xsl:template>

<!-- markup inside artwork element -->

<xsl:template match="figure[.//artwork//iref | .//artwork//xref]" mode="cleanup">
  <!-- move up iref elements -->
  <xsl:for-each select=".//artwork//xref">
    <xsl:if test="not(ancestor::ed:del)">
      <xsl:call-template name="insert-iref-for-xref"/>
    </xsl:if>
  </xsl:for-each>
  <figure>
    <xsl:apply-templates select="@*" mode="cleanup" />
    <xsl:apply-templates select=".//artwork//iref" mode="cleanup"/>
    <xsl:apply-templates select="iref|preamble|artwork|postamble|ed:replace|ed:ins|ed:del" mode="cleanup" />
  </figure>
</xsl:template>

<xsl:template name="insert-begin-code"/>
<xsl:template name="insert-end-code"/>
<xsl:template match="@x:is-code-component" mode="cleanup"/>

<xsl:template match="artwork" mode="cleanup">
  <xsl:variable name="content2"><xsl:apply-templates select="."/></xsl:variable>
  <xsl:variable name="content" select="translate($content2,'&#160;&#x2500;&#x2502;&#x2508;&#x250c;&#x2510;&#x2514;&#x2518;&#x251c;&#x2524;',' -|+++++++')"/>
  <artwork>
    <xsl:apply-templates select="@*" mode="cleanup" />
    <xsl:if test="@x:is-code-component='yes'">
      <xsl:if test="starts-with(.,'&#10;')">
        <xsl:text>&#10;</xsl:text>
      </xsl:if>
      <xsl:value-of select="@x:indent-with"/>
      <xsl:text>&lt;CODE BEGINS&gt;&#10;</xsl:text>
    </xsl:if>
    <xsl:if test="starts-with(.,'&#10;')">
      <xsl:text>&#10;</xsl:text>
      <xsl:value-of select="@x:indent-with"/>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="@x:indent-with!=''">
        <xsl:call-template name="indent">
          <xsl:with-param name="content" select="$content"/>
          <xsl:with-param name="with" select="@x:indent-with"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$content"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="@x:is-code-component='yes'">&#10;&lt;CODE ENDS&gt;&#10;</xsl:if>
  </artwork>  
</xsl:template>

<xsl:template match="@x:indent-with" mode="cleanup"/>

<xsl:template name="indent">
  <xsl:param name="content"/>
  <xsl:param name="with"/>

  <xsl:value-of select="substring($content,1,1)"/>
  <xsl:if test="substring($content,1,1)='&#10;'">
    <xsl:value-of select="$with"/>
  </xsl:if>
  
  <xsl:choose>
    <xsl:when test="$content=''" />
    <xsl:otherwise>
      <xsl:call-template name="indent">
        <xsl:with-param name="content" select="substring($content,2)"/>
        <xsl:with-param name="with" select="$with"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
  
</xsl:template>

<!-- email repetitions -->
<xsl:template match="email" mode="cleanup">
  <!-- combine in a single element -->
  <xsl:if test="not(preceding-sibling::email)">
    <email>
      <xsl:for-each select="../email">
        <xsl:value-of select="."/>
        <xsl:if test="position()!=last()">
          <xsl:text>, </xsl:text>
        </xsl:if>
      </xsl:for-each>
    </email>
  </xsl:if>
</xsl:template>

<!-- markup inside cref -->
<xsl:template match="cref//eref" mode="cleanup">
  <xsl:text>&lt;</xsl:text>
  <xsl:value-of select="@target"/>
  <xsl:text>&gt;</xsl:text>
</xsl:template>

<xsl:template match="cref//xref" mode="cleanup" priority="9">
  <xsl:variable name="text">
    <xsl:apply-templates select="."/>
  </xsl:variable>
  <xsl:value-of select="$text"/>
</xsl:template>

<!-- annotations -->
<xsl:template match="@x:annotation" mode="cleanup">
  <xsl:comment>
    <xsl:value-of select="."/>
  </xsl:comment>
  <xsl:call-template name="warning">
    <xsl:with-param name="inline" select="'no'"/>
    <xsl:with-param name="msg">Dropping annotation on <xsl:value-of select="local-name(..)"/> element.</xsl:with-param>
  </xsl:call-template>
</xsl:template>

<!-- artwork extensions -->
<xsl:template match="artwork/@x:extraction-note" mode="cleanup"/>

<!-- list formatting -->
<xsl:template match="list/@x:indent" mode="cleanup"/>

<!-- referencing extensions -->
<xsl:template match="iref/@x:for-anchor" mode="cleanup"/>

<!-- section numbering -->
<xsl:template match="section/@x:fixed-section-number" mode="cleanup"/>

<!-- GRRDL info stripped -->
<xsl:template match="@grddl:transformation" mode="cleanup"/>

<!-- maturity level stripped -->
<xsl:template match="@x:maturity-level" mode="cleanup"/>

<!-- normativity stripped -->
<xsl:template match="@x:nrm" mode="cleanup"/>

<!-- title extensions -->
<xsl:template match="title/@x:quotes" mode="cleanup"/>

<!-- RDF info stripped -->
<xsl:template match="rdf:*" mode="cleanup"/>

<!-- cases where xml2rfc does not allow anchors -->
<xsl:template match="c/@anchor" mode="cleanup"/>
<xsl:template match="preamble/@anchor" mode="cleanup"/>
<xsl:template match="spanx/@anchor" mode="cleanup"/>

</xsl:transform>