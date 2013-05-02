<!--
    XSLT transformation from RFC2629 XML format to HTML

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
                version="2.0"
                
                xmlns:date="http://exslt.org/dates-and-times"
                xmlns:ed="http://greenbytes.de/2002/rfcedit"
                xmlns:exslt="http://exslt.org/common"
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                xmlns:myns="mailto:julian.reschke@greenbytes.de?subject=rcf2629.xslt"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:saxon-old="http://icl.com/saxon"
                xmlns:x="http://purl.org/net/xml2rfc/ext"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"

                exclude-result-prefixes="date ed exslt msxsl myns rdf saxon saxon-old x xhtml"
                >

<xsl:strip-space elements="back figure front list middle reference references rfc section"/>                
                
<xsl:output method="html" encoding="iso-8859-1" version="4.0" doctype-public="-//W3C//DTD HTML 4.01//EN" indent="no"/>

<!-- rfc comments PI -->

<xsl:param name="xml2rfc-comments">
  <xsl:call-template name="parse-pis">
    <xsl:with-param name="nodes" select="/processing-instruction('rfc')"/>
    <xsl:with-param name="attr" select="'comments'"/>
    <xsl:with-param name="default" select="'no'"/>
  </xsl:call-template>
</xsl:param>

<!-- rfc compact PI -->

<xsl:param name="xml2rfc-compact">
  <xsl:call-template name="parse-pis">
    <xsl:with-param name="nodes" select="/processing-instruction('rfc')"/>
    <xsl:with-param name="attr" select="'compact'"/>
    <xsl:with-param name="default" select="$xml2rfc-rfcedstyle"/>
  </xsl:call-template>
</xsl:param>

<!-- rfc footer PI -->

<xsl:param name="xml2rfc-footer">
  <xsl:call-template name="parse-pis">
    <xsl:with-param name="nodes" select="/processing-instruction('rfc')"/>
    <xsl:with-param name="attr" select="'footer'"/>
  </xsl:call-template>
</xsl:param>

<!-- rfc header PI -->

<xsl:param name="xml2rfc-header">
  <xsl:call-template name="parse-pis">
    <xsl:with-param name="nodes" select="/processing-instruction('rfc')"/>
    <xsl:with-param name="attr" select="'header'"/>
  </xsl:call-template>
</xsl:param>

<!-- rfc inline PI -->

<xsl:param name="xml2rfc-inline">
  <xsl:call-template name="parse-pis">
    <xsl:with-param name="nodes" select="/processing-instruction('rfc')"/>
    <xsl:with-param name="attr" select="'inline'"/>
    <xsl:with-param name="default" select="'no'"/>
  </xsl:call-template>
</xsl:param>

<!-- include a table of contents if a processing instruction <?rfc?>
     exists with contents toc="yes". Can be overriden by an XSLT parameter -->

<xsl:param name="xml2rfc-toc">
  <xsl:call-template name="parse-pis">
    <xsl:with-param name="nodes" select="/processing-instruction('rfc')"/>
    <xsl:with-param name="attr" select="'toc'"/>
    <xsl:with-param name="default" select="'no'"/>
  </xsl:call-template>
</xsl:param>

<!-- optional tocdepth-->

<xsl:param name="xml2rfc-tocdepth">
  <xsl:call-template name="parse-pis">
    <xsl:with-param name="nodes" select="/processing-instruction('rfc')"/>
    <xsl:with-param name="attr" select="'tocdepth'"/>
    <xsl:with-param name="default" select="'3'"/>
  </xsl:call-template>
</xsl:param>

<xsl:variable name="parsedTocDepth">
  <xsl:choose>
    <xsl:when test="$xml2rfc-tocdepth='1'">1</xsl:when>
    <xsl:when test="$xml2rfc-tocdepth='2'">2</xsl:when>
    <xsl:when test="$xml2rfc-tocdepth='3'">3</xsl:when>
    <xsl:when test="$xml2rfc-tocdepth='4'">4</xsl:when>
    <xsl:when test="$xml2rfc-tocdepth='5'">5</xsl:when>
    <xsl:otherwise>99</xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!-- suppress top block if a processing instruction <?rfc?>
     exists with contents tocblock="no". Can be overriden by an XSLT parameter -->

<xsl:param name="xml2rfc-topblock">
  <xsl:call-template name="parse-pis">
    <xsl:with-param name="nodes" select="/processing-instruction('rfc')"/>
    <xsl:with-param name="attr" select="'topblock'"/>
    <xsl:with-param name="default" select="'yes'"/>
  </xsl:call-template>
</xsl:param>

<!-- Format to the RFC Editor's taste -->

<xsl:param name="xml2rfc-rfcedstyle">
  <xsl:call-template name="parse-pis">
    <xsl:with-param name="nodes" select="/processing-instruction('rfc')"/>
    <xsl:with-param name="attr" select="'rfcedstyle'"/>
    <xsl:with-param name="default" select="'no'"/>
  </xsl:call-template>
</xsl:param>

<!-- the name of an automatically inserted references section -->

<xsl:param name="xml2rfc-refparent">
  <xsl:call-template name="parse-pis">
    <xsl:with-param name="nodes" select="/processing-instruction('rfc')"/>
    <xsl:with-param name="attr" select="'refparent'"/>
    <xsl:with-param name="default" select="'References'"/>
  </xsl:call-template>
</xsl:param>

<!-- use symbolic reference names instead of numeric ones unless a processing instruction <?rfc?>
     exists with contents symrefs="no". Can be overriden by an XSLT parameter -->

<xsl:param name="xml2rfc-symrefs">
  <xsl:call-template name="parse-pis">
    <xsl:with-param name="nodes" select="/processing-instruction('rfc')"/>
    <xsl:with-param name="attr" select="'symrefs'"/>
    <xsl:with-param name="default" select="'yes'"/>
  </xsl:call-template>
</xsl:param>

<!-- sort references if a processing instruction <?rfc?>
     exists with contents sortrefs="yes". Can be overriden by an XSLT parameter -->

<xsl:param name="xml2rfc-sortrefs">
  <xsl:call-template name="parse-pis">
    <xsl:with-param name="nodes" select="/processing-instruction('rfc')"/>
    <xsl:with-param name="attr" select="'sortrefs'"/>
    <xsl:with-param name="default" select="'no'"/>
  </xsl:call-template>
</xsl:param>

<!-- insert editing marks if a processing instruction <?rfc?>
     exists with contents editing="yes". Can be overriden by an XSLT parameter -->

<xsl:param name="xml2rfc-editing">
  <xsl:call-template name="parse-pis">
    <xsl:with-param name="nodes" select="/processing-instruction('rfc')"/>
    <xsl:with-param name="attr" select="'editing'"/>
    <xsl:with-param name="default" select="'no'"/>
  </xsl:call-template>
</xsl:param>

<!-- make it a private paper -->

<xsl:param name="xml2rfc-private">
  <xsl:call-template name="parse-pis">
    <xsl:with-param name="nodes" select="/processing-instruction('rfc')"/>
    <xsl:with-param name="attr" select="'private'"/>
  </xsl:call-template>
</xsl:param>

<!-- background image? -->

<xsl:param name="xml2rfc-background">
  <xsl:call-template name="parse-pis">
    <xsl:with-param name="nodes" select="/processing-instruction('rfc')"/>
    <xsl:with-param name="attr" select="'background'"/>
  </xsl:call-template>
</xsl:param>

<!-- extension for XML parsing in artwork -->

<xsl:param name="xml2rfc-ext-parse-xml-in-artwork">
  <xsl:call-template name="parse-pis">
    <xsl:with-param name="nodes" select="/processing-instruction('rfc-ext')"/>
    <xsl:with-param name="attr" select="'parse-xml-in-artwork'"/>
    <xsl:with-param name="default" select="'no'"/>
  </xsl:call-template>
</xsl:param>

<xsl:param name="xml2rfc-ext-trace-parse-xml">
  <xsl:call-template name="parse-pis">
    <xsl:with-param name="nodes" select="/processing-instruction('rfc-ext')"/>
    <xsl:with-param name="attr" select="'trace-parse-xml'"/>
    <xsl:with-param name="default" select="'no'"/>
  </xsl:call-template>
</xsl:param>

<!-- extension for excluding the index -->

<xsl:param name="xml2rfc-ext-include-index">
  <xsl:call-template name="parse-pis">
    <xsl:with-param name="nodes" select="/processing-instruction('rfc-ext')"/>
    <xsl:with-param name="attr" select="'include-index'"/>
    <xsl:with-param name="default" select="'yes'"/>
  </xsl:call-template>
</xsl:param>

<!-- extension for excluding DCMI properties in meta tag (RFC2731) -->

<xsl:param name="xml2rfc-ext-support-rfc2731">
  <xsl:call-template name="parse-pis">
    <xsl:with-param name="nodes" select="/processing-instruction('rfc-ext')"/>
    <xsl:with-param name="attr" select="'support-rfc2731'"/>
    <xsl:with-param name="default" select="'yes'"/>
  </xsl:call-template>
</xsl:param>

<!-- extension for specifying the value for <vspace> after which it's taken as a page break -->

<xsl:param name="xml2rfc-ext-vspace-pagebreak">
  <xsl:call-template name="parse-pis">
    <xsl:with-param name="nodes" select="/processing-instruction('rfc-ext')"/>
    <xsl:with-param name="attr" select="'vspace-pagebreak'"/>
    <xsl:with-param name="default" select="'100'"/>
  </xsl:call-template>
</xsl:param>

<!-- extension for allowing markup inside artwork -->

<xsl:param name="xml2rfc-ext-allow-markup-in-artwork">
  <xsl:call-template name="parse-pis">
    <xsl:with-param name="nodes" select="/processing-instruction('rfc-ext')"/>
    <xsl:with-param name="attr" select="'allow-markup-in-artwork'"/>
    <xsl:with-param name="default" select="'no'"/>
  </xsl:call-template>
</xsl:param>

<!-- extension for including references into index -->

<xsl:param name="xml2rfc-ext-include-references-in-index">
  <xsl:call-template name="parse-pis">
    <xsl:with-param name="nodes" select="/processing-instruction('rfc-ext')"/>
    <xsl:with-param name="attr" select="'include-references-in-index'"/>
    <xsl:with-param name="default" select="'no'"/>
  </xsl:call-template>
</xsl:param>

<!-- position of author's section -->

<xsl:param name="xml2rfc-ext-authors-section">
  <xsl:call-template name="parse-pis">
    <xsl:with-param name="nodes" select="/processing-instruction('rfc-ext')"/>
    <xsl:with-param name="attr" select="'authors-section'"/>
  </xsl:call-template>
</xsl:param>

<!-- justification? -->

<xsl:param name="xml2rfc-ext-justification">
  <xsl:call-template name="parse-pis">
    <xsl:with-param name="nodes" select="/processing-instruction('rfc-ext')"/>
    <xsl:with-param name="attr" select="'justification'"/>
    <xsl:with-param name="default" select="'no'"/>
  </xsl:call-template>
</xsl:param>

<!-- switch for doublesided layout -->

<xsl:param name="xml2rfc-ext-duplex">
  <xsl:call-template name="parse-pis">
    <xsl:with-param name="nodes" select="/processing-instruction('rfc-ext')"/>
    <xsl:with-param name="attr" select="'duplex'"/>
    <xsl:with-param name="default" select="'no'"/>
  </xsl:call-template>
</xsl:param>

<!-- trailing dots in section numbers -->

<xsl:param name="xml2rfc-ext-sec-no-trailing-dots">
  <xsl:call-template name="parse-pis">
    <xsl:with-param name="nodes" select="/processing-instruction('rfc-ext')"/>
    <xsl:with-param name="attr" select="'sec-no-trailing-dots'"/>
  </xsl:call-template>
</xsl:param>

<!-- check artwork width? -->

<xsl:param name="xml2rfc-ext-check-artwork-width">
  <xsl:call-template name="parse-pis">
    <xsl:with-param name="nodes" select="/processing-instruction('rfc-ext')"/>
    <xsl:with-param name="attr" select="'check-artwork-width'"/>
    <xsl:with-param name="default" select="'yes'"/>
  </xsl:call-template>
</xsl:param>

<!-- choose whether or not to do mailto links --> 
  
<xsl:param name="xml2rfc-linkmailto">
  <xsl:call-template name="parse-pis">
    <xsl:with-param name="nodes" select="/processing-instruction('rfc-ext')"/>
    <xsl:with-param name="attr" select="'linkmailto'"/>
    <xsl:with-param name="default" select="'yes'"/>
  </xsl:call-template>
</xsl:param>

<!-- iprnotified switch --> 
  
<xsl:param name="xml2rfc-iprnotified">
  <xsl:call-template name="parse-pis">
    <xsl:with-param name="nodes" select="/processing-instruction('rfc')"/>
    <xsl:with-param name="attr" select="'iprnotified'"/>
    <xsl:with-param name="default" select="'no'"/>
  </xsl:call-template>
</xsl:param>

<!-- URL templates for RFCs and Internet Drafts. -->

<!-- Reference the authorative ASCII versions
<xsl:param name="rfcUrlPrefix" select="'http://www.ietf.org/rfc/rfc'" />
<xsl:param name="rfcUrlPostfix" select="'.txt'" />
-->
<!-- Reference the marked up versions over on http://tools.ietf.org/html. -->
<xsl:param name="rfcUrlPrefix" select="'http://tools.ietf.org/html/rfc'" />
<xsl:param name="rfcUrlPostfix" select="''" />
<xsl:param name="rfcUrlFragSection" select="'section-'" />
<xsl:param name="rfcUrlFragAppendix" select="'appendix-'" />
<xsl:param name="internetDraftUrlPrefix" select="'http://tools.ietf.org/html/'" />
<xsl:param name="internetDraftUrlPostfix" select="''" />
<xsl:param name="internetDraftUrlFrag" select="'section-'" />

<!-- the format we're producing -->
<xsl:param name="outputExtension" select="'html'"/>

<!-- warning re: absent node-set ext. function -->
<xsl:variable name="node-set-warning">
  This stylesheet requires either an XSLT-1.0 processor with node-set()
  extension function, or an XSLT-2.0 processor. Therefore, parts of the
  document couldn't be displayed.
</xsl:variable>

<!-- character translation tables -->
<xsl:variable name="lcase" select="'abcdefghijklmnopqrstuvwxyz'" />
<xsl:variable name="ucase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />       
<xsl:variable name="digits" select="'0123456789'" />

<!-- build help keys for indices -->
<xsl:key name="index-first-letter"
  match="iref|reference"
    use="translate(substring(concat(@anchor,@item),1,1),'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')" />

<xsl:key name="index-item"
  match="iref"
    use="@item" />

<xsl:key name="index-item-subitem"
  match="iref"
    use="concat(@item,'..',@subitem)" />

<xsl:key name="index-xref-by-sec"
  match="xref[@x:sec]"
    use="concat(@target,'..',@x:sec)" />

<xsl:key name="index-xref-by-anchor"
  match="xref[@x:rel]"
    use="concat(@target,'..',@x:rel)" />

<xsl:key name="anchor-item"
  match="//*[@anchor]"
    use="@anchor"/>

<xsl:key name="xref-item"
  match="//xref"
    use="@target"/>

<xsl:key name="extref-item"
  match="//x:ref"
    use="."/>

<!-- prefix for automatically generated anchors -->
<xsl:variable name="anchor-prefix" select="'rfc'" />

<!-- IPR version switch -->
<xsl:variable name="ipr-rfc3667" select="(
  /rfc/@number &gt; 3708) or
  not(
    (/rfc/@ipr = 'full2026') or
    (/rfc/@ipr = 'noDerivativeWorks2026') or
    (/rfc/@ipr = 'noDerivativeWorksNow') or
    (/rfc/@ipr = 'none') or
    (/rfc/@ipr = '') or
    not(/rfc/@ipr)
  )" />

<xsl:variable name="rfcno" select="/rfc/@number"/>  

<xsl:variable name="submissionType">
  <xsl:choose>
    <xsl:when test="/rfc/@submissionType='IETF' or not(/rfc/@submissionType) or /rfc/submissionType=''">IETF</xsl:when>
    <xsl:when test="/rfc/@submissionType='IAB' or /rfc/@submissionType='IRTF' or /rfc/@submissionType='independent'">
      <xsl:value-of select="/rfc/@submissionType"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="concat('(UNSUPPORTED SUBMISSION TYPE: ',/rfc/@submissionType,')')"/>
      <xsl:call-template name="error">
        <xsl:with-param name="msg" select="concat('Unsupported value for /rfc/@submissionType: ', /rfc/@submissionType)"/>
        <xsl:with-param name="inline" select="'no'"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
  
  <!-- sanity check on @consensus -->
  <xsl:if test="/rfc/@consensus and /rfc/@submissionType='independent'">
    <xsl:call-template name="warning">
      <xsl:with-param name="msg" select="concat('/rfc/@consensus meaningless with a /rfc/@submissionType value of ', /rfc/@submissionType)"/>
    </xsl:call-template>
  </xsl:if>
</xsl:variable>

<xsl:variable name="consensus">
  <xsl:choose>
    <xsl:when test="/rfc/@consensus='yes' or not(/rfc/@consensus)">yes</xsl:when>
    <xsl:when test="/rfc/@consensus='no'">no</xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="concat('(UNSUPPORTED VALUE FOR CONSENSUS: ',/rfc/@consensus,')')"/>
      <xsl:call-template name="error">
        <xsl:with-param name="msg" select="concat('Unsupported value for /rfc/@consensus: ', /rfc/@consensus)"/>
        <xsl:with-param name="inline" select="'no'"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!-- Header format as defined in RFC 5741, and deployed end of Dec 2009 -->
<xsl:variable name="header-format">
  <xsl:choose>
    <xsl:when test="$pub-yearmonth >= 201001 or
      ($rfcno=5741 or $rfcno=5742 or $rfcno=5743)"
      >2010</xsl:when>
    <xsl:otherwise/>
  </xsl:choose>   
</xsl:variable>

<xsl:variable name="rfc-boilerplate">
  <xsl:choose>
    <!-- RFC boilerplate as defined in RFC 5741, and deployed end of Dec 2009 -->
    <xsl:when test="$pub-yearmonth >= 201001 or
      ($rfcno=5741 or $rfcno=5742 or $rfcno=5743)"
      >2010</xsl:when>
    <xsl:otherwise/>
  </xsl:choose>   
</xsl:variable>

<xsl:variable name="id-boilerplate">
  <xsl:choose>
    <!-- ID boilerplate approved by IESG on Jan 14 2010-->
    <xsl:when test="$pub-yearmonth >= 201004"
      >2010</xsl:when>
    <xsl:otherwise/>
  </xsl:choose>   
</xsl:variable>

<xsl:variable name="ipr-rfc4748" select="(
  $ipr-rfc3667 and
    ( $rfcno &gt;= 4715 and ( $rfcno != 4718 and $rfcno != 4735 and $rfcno != 4749 ))
    or
    ( $rfcno=4578 or $rfcno=4582 or $rfcno=4583 or $rfcno=4628 or $rfcno=4629 or $rfcno=4639 or $rfcno=4651 or $rfcno=4682 or $rfcno=4684 or $rfcno=4695 or $rfcno=4696 )
    or
    ( not(/rfc/@number) and $pub-yearmonth >= 200611)
  )" />

<xsl:variable name="ipr-2007-08" select="(
  $ipr-rfc4748 and
    (
      ($rfcno &gt; 5000
        and $rfcno != 5020
        and $rfcno != 5021
        and $rfcno != 5034
        and $rfcno != 5052
        and $rfcno != 5065
        and $rfcno != 5094) or
      ($xml2rfc-ext-pub-year >= 2008) or
      (not(/rfc/@number) and $pub-yearmonth >= 200709)
    )
  )" />

<xsl:variable name="ipr-2008-11" select="(
    /rfc/@number and $pub-yearmonth >= 200811
  )
  or
  (
    /rfc/@ipr = 'trust200811' or
    /rfc/@ipr = 'noModificationTrust200811' or
    /rfc/@ipr = 'noDerivativesTrust200902' or
    /rfc/@ipr = 'trust200902' or
    /rfc/@ipr = 'noModificationTrust200902' or
    /rfc/@ipr = 'noDerivativesTrust200902' or
    /rfc/@ipr = 'pre5378Trust200902'
  )" />

<xsl:variable name="ipr-2009-02" select="(
    $ipr-2008-11 and $pub-yearmonth >= 200902
  )" />

<!-- this makes the Sep 2009 TLP text depend on the publication date to be >= 2009-11 
     for IDs, and around 2009-09 for RFCs-->
<xsl:variable name="ipr-2009-09" select="(
    ( not(/rfc/@number) and $pub-yearmonth >= 200911 )
    or
    (
      /rfc/@number and $pub-yearmonth >= 200909 and
      $rfcno!=5582 and $rfcno!=5621 and $rfcno!=5632 and $rfcno!=5645 and $rfcno!=5646 and $rfcno!=5681 
    )
  )" />

<!-- this makes the Jan 2010 TLP text depend on the publication date to be >= 2010-04
     for IDs, and around 2010-01 for RFCs-->
<xsl:variable name="ipr-2010-01" select="(
    ( not(/rfc/@number) and $pub-yearmonth >= 201004 )
    or
    (
      /rfc/@number and ($pub-yearmonth >= 201001 or
      $rfcno=5741 or $rfcno=5742 or $rfcno=5743) 
    )
  )" />

<!-- see http://mailman.rfc-editor.org/pipermail/rfc-interest/2009-June/001373.html -->
<!-- for IDs, implement the change as 2009-11 -->
<xsl:variable name="abstract-first" select="(
    (/rfc/@number and $pub-yearmonth >= 200907)
    or
    (not(/rfc/@number) and $pub-yearmonth >= 200911)
  )" />

<!-- funding switch -->  
<xsl:variable name="funding0" select="(
  $rfcno &gt; 2499) or
  (not(/rfc/@number) and /rfc/@docName and $xml2rfc-ext-pub-year &gt;= 1999
  )" />
  
<xsl:variable name="funding1" select="(
  $rfcno &gt; 4320) or
  (not(/rfc/@number) and /rfc/@docName and $xml2rfc-ext-pub-year &gt;= 2006
  )" />

<xsl:variable name="no-funding" select="$ipr-2007-08"/>

<xsl:variable name="no-copylong" select="$ipr-2008-11"/>

<!-- will document have an index -->
<xsl:variable name="has-index" select="(//iref or (//xref and $xml2rfc-ext-include-references-in-index='yes')) and $xml2rfc-ext-include-index!='no'" />
          
<!-- does the document contain edits? -->
<xsl:variable name="has-edits" select="//ed:ins | //ed:del | //ed:replace" />
              
<xsl:template match="text()[not(ancestor::artwork)]">
  <xsl:variable name="ws" select="'&#9;&#10;&#13;&#32;'"/>
  <xsl:variable name="starts-with-ws" select="translate(substring(.,1,1),$ws,'')"/>
  <xsl:variable name="ends-with-ws" select="translate(substring(.,string-length(.),1),$ws,'')"/>
  <!--<xsl:message> Orig: "<xsl:value-of select="."/>"</xsl:message>
  <xsl:message>Start: "<xsl:value-of select="$starts-with-ws"/>"</xsl:message>
  <xsl:message>  End: "<xsl:value-of select="$ends-with-ws"/>"</xsl:message> -->
  <xsl:if test="$starts-with-ws='' and preceding-sibling::node() | parent::ed:ins | parent::ed:del">
    <xsl:text> </xsl:text>
  </xsl:if>
  <xsl:value-of select="normalize-space(.)"/>
  <xsl:if test="$ends-with-ws='' and following-sibling::node() | parent::ed:ins | parent::ed:del">
    <xsl:text> </xsl:text>
  </xsl:if>
</xsl:template>
              
              
<xsl:template match="abstract">
  <h1 id="{$anchor-prefix}.abstract"><a href="#{$anchor-prefix}.abstract">Abstract</a></h1>
  <xsl:apply-templates />
</xsl:template>

<msxsl:script language="JScript" implements-prefix="myns">
  function parseXml(str) {
    try {
      var doc = new ActiveXObject("MSXML2.DOMDocument");
      doc.async = false;
      if (doc.loadXML(str)) {
        return "";
      }
      else {
        return doc.parseError.reason + "\n" + doc.parseError.srcText + " (" + doc.parseError.line + "/" + doc.parseError.linepos + ")";
      }
    }
    catch(e) {
      return "";
    }
  }
</msxsl:script>

<xsl:template name="add-artwork-class">
  <xsl:choose>
    <xsl:when test="@type='abnf' or @type='abnf2045' or @type='abnf2616' or @type='application/xml-dtd' or @type='inline' or @type='application/relax-ng-compact-syntax'">
      <xsl:attribute name="class">inline</xsl:attribute>
    </xsl:when>
    <xsl:when test="starts-with(@type,'message/http') and contains(@type,'msgtype=&quot;request&quot;')">
      <xsl:attribute name="class">text2</xsl:attribute>
    </xsl:when>
    <xsl:when test="starts-with(@type,'message/http')">
      <xsl:attribute name="class">text</xsl:attribute>
    </xsl:when>
    <xsl:when test="starts-with(@type,'drawing')">
      <xsl:attribute name="class">drawing</xsl:attribute>
    </xsl:when>
    <xsl:when test="starts-with(@type,'text/plain') or @type='example' or @type='code'">
      <xsl:attribute name="class">text</xsl:attribute>
    </xsl:when>
    <xsl:otherwise/>
  </xsl:choose>
</xsl:template>

<xsl:template name="insert-begin-code">
  <xsl:if test="@x:isCodeComponent='yes'">
    <pre class="ccmarker cct"><span>&lt;CODE BEGINS></span></pre>
  </xsl:if>
</xsl:template>

<xsl:template name="insert-end-code">
  <xsl:if test="@x:isCodeComponent='yes'">
    <pre class="ccmarker ccb"><span>&lt;CODE ENDS></span></pre>
  </xsl:if>
</xsl:template>

<xsl:template match="artwork">
  <xsl:if test="not(ancestor::ed:del) and $xml2rfc-ext-parse-xml-in-artwork='yes' and function-available('myns:parseXml')" use-when="function-available('myns:parseXml')">
    <xsl:if test="contains(.,'&lt;?xml')">
      <xsl:variable name="body" select="substring-after(substring-after(.,'&lt;?xml'),'?>')" /> 
      <xsl:if test="$body!='' and myns:parseXml($body)!=''">
        <table style="background-color: red; border-width: thin; border-style: solid; border-color: black;">
        <tr><td>
        XML PARSE ERROR; parsed the body below:
        <pre>
        <xsl:value-of select="$body"/>
        </pre>
        resulting in:
        <pre>
        <xsl:value-of select="myns:parseXml($body)" />
        </pre>
        </td></tr></table>
      </xsl:if>
    </xsl:if>
    <xsl:if test="@ed:parse-xml-after">
      <xsl:if test="myns:parseXml(string(.))!=''">
        <table style="background-color: red; border-width: thin; border-style: solid; border-color: black;">
        <tr><td>
        XML PARSE ERROR:
        <pre><xsl:value-of select="myns:parseXml(string(.))" /></pre>
        </td></tr></table>
      </xsl:if>
    </xsl:if>
  </xsl:if>
  <xsl:variable name="display">
    <xsl:choose>
      <xsl:when test="$xml2rfc-ext-allow-markup-in-artwork='yes'">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>  
  <xsl:choose>
    <xsl:when test="@align='right'">
      <div style="display:table; margin-left: auto; margin-right: 0em;">
        <xsl:call-template name="insert-begin-code"/>
        <pre style="margin-left: 0em;">
          <xsl:call-template name="add-artwork-class"/>
          <xsl:call-template name="insertInsDelClass"/>
          <xsl:copy-of select="$display"/>
        </pre>          
        <xsl:call-template name="insert-end-code"/>
      </div>
    </xsl:when>
    <xsl:when test="@align='center'">
      <div style="display:table; margin-left: auto; margin-right: auto;">
        <xsl:call-template name="insert-begin-code"/>
        <pre style="margin-left: 0em;">
          <xsl:call-template name="add-artwork-class"/>
          <xsl:call-template name="insertInsDelClass"/>
          <xsl:copy-of select="$display"/>
        </pre>          
        <xsl:call-template name="insert-end-code"/>
      </div>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="insert-begin-code"/>
      <pre>
        <xsl:call-template name="add-artwork-class"/>
        <xsl:call-template name="insertInsDelClass"/>
        <xsl:copy-of select="$display"/>
      </pre>
      <xsl:call-template name="insert-end-code"/>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:call-template name="check-artwork-width">
    <xsl:with-param name="content"><xsl:apply-templates/></xsl:with-param>
    <xsl:with-param name="indent"><xsl:value-of select="string-length(@x:indent-with)"/></xsl:with-param>
  </xsl:call-template>
</xsl:template>

<!-- special case for first text node in artwork -->
<xsl:template match="artwork/text()[1]">
  <xsl:choose>
    <xsl:when test="starts-with(.,'&#10;')">
      <!-- reduce leading whitespace -->
      <xsl:value-of select="substring(.,2)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="."/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template name="check-artwork-width">
  <xsl:param name="content"/>
  <xsl:param name="indent"/>
  <xsl:choose>
    <xsl:when test="$xml2rfc-ext-check-artwork-width='no'">
      <!-- skip check -->
    </xsl:when>
    <xsl:when test="not(contains($content,'&#10;'))">
      <xsl:if test="string-length($content) > 69 + number($indent)">
        <xsl:call-template name="warning">
          <xsl:with-param name="msg">artwork line too long: '<xsl:value-of select="$content"/>' (<xsl:value-of select="string-length($content)"/> characters)</xsl:with-param>
        </xsl:call-template>
      </xsl:if>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="start" select="substring-before($content,'&#10;')"/> 
      <xsl:variable name="end" select="substring-after($content,'&#10;')"/>
      <xsl:variable name="max">
        <xsl:choose>
          <xsl:when test="$indent!=''"><xsl:value-of select="69 + $indent"/></xsl:when>
          <xsl:otherwise>69</xsl:otherwise>
        </xsl:choose>         
      </xsl:variable>
      <xsl:if test="string-length($start) > $max">
        <xsl:call-template name="warning">
          <xsl:with-param name="msg">artwork line too long: '<xsl:value-of select="$start"/>' (<xsl:value-of select="string-length($start)"/> characters)</xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <xsl:call-template name="check-artwork-width">
        <xsl:with-param name="content" select="$end"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="artwork[@src and starts-with(@type,'image/')]">
  <p>
    <xsl:choose>
      <xsl:when test="@align='center'">
        <xsl:attribute name="style">text-align: center</xsl:attribute>
      </xsl:when>
      <xsl:when test="@align='right'">
        <xsl:attribute name="style">text-align: right</xsl:attribute>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="@type='image/svg+xml'">
        <object data="{@src}" type="image/svg+xml">
          <xsl:choose>
            <xsl:when test="@width!='' or @height!=''">
              <xsl:copy-of select="@width|@height"/>
            </xsl:when>
            <xsl:otherwise xmlns:svg="http://www.w3.org/2000/svg">
              <!-- try to find width and height from SVG -->
              <xsl:variable name="svg" select="document(@src)"/>
              <xsl:for-each select="$svg/svg:svg/@width|$svg/svg:svg/@height">
                <!-- strip out the units, cross the fingers pixels are meant -->
                <xsl:attribute name="{local-name()}">
                  <xsl:value-of select="translate(.,concat($ucase,$lcase),'')"/>
                </xsl:attribute>
              </xsl:for-each>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:apply-templates/>
        </object>
      </xsl:when>
      <xsl:otherwise>
        <img src="{@src}" alt="{.}">
          <xsl:if test="@width and @width!=''">
            <xsl:copy-of select="@width"/>
          </xsl:if>
          <xsl:if test="@height and @height!=''">
            <xsl:copy-of select="@height"/>
          </xsl:if>
        </img>
      </xsl:otherwise>
    </xsl:choose>
  </p>
</xsl:template>

<xsl:template match="author">

    <address class="vcard">
      <span class="vcardline">
        <span class="fn">
          <xsl:value-of select="@fullname" />
        </span>
        <xsl:if test="@role">
          (<xsl:value-of select="@role" />)
        </xsl:if>
        <!-- annotation support for Martin "uuml" Duerst -->
        <xsl:if test="@x:annotation">
          <xsl:text> </xsl:text> 
          <i><xsl:value-of select="@x:annotation"/></i>
        </xsl:if>
        <!-- components of name (hidden from display -->
        <span class="n hidden">
          <span class="family-name"><xsl:value-of select="@surname"/></span>
          <!-- given-name family-name -->
          <xsl:if test="@surname=substring(@fullname,1 + string-length(@fullname) - string-length(@surname))">
            <span class="given-name"><xsl:value-of select="normalize-space(substring(@fullname,1,string-length(@fullname) - string-length(@surname)))"/></span>
          </xsl:if>
          <!-- family-name given-name -->
          <xsl:if test="starts-with(@fullname,@surname)">
            <span class="given-name"><xsl:value-of select="normalize-space(substring-after(@fullname,@surname))"/></span>
          </xsl:if>
        </span>
      </span>
      <xsl:if test="normalize-space(organization) != ''">
        <span class="org vcardline">
          <xsl:value-of select="organization" />
        </span>
      </xsl:if>
      <xsl:if test="address/postal">
        <span class="adr">
          <xsl:if test="address/postal/street">
            <xsl:for-each select="address/postal/street">
              <xsl:variable name="street">
                <xsl:call-template name="extract-normalized">
                  <xsl:with-param name="node" select="."/>
                  <xsl:with-param name="name" select="'street'"/>
                </xsl:call-template>
              </xsl:variable>
              <xsl:if test="$street!=''">
                <span class="street-address vcardline">
                  <xsl:value-of select="$street"/>
                </span>
              </xsl:if>
            </xsl:for-each>
          </xsl:if>
          <xsl:if test="address/postal/city|address/postal/region|address/postal/code">
            <span class="vcardline">
              <xsl:if test="address/postal/city">
                <xsl:variable name="city">
                  <xsl:call-template name="extract-normalized">
                    <xsl:with-param name="node" select="address/postal/city"/>
                    <xsl:with-param name="name" select="'address/postal/city'"/>
                  </xsl:call-template>
                </xsl:variable>
                <xsl:if test="$city!=''">
                  <span class="locality">
                    <xsl:value-of select="$city"/>
                  </span>
                  <xsl:text>, </xsl:text>
                </xsl:if>
              </xsl:if>
              <xsl:if test="address/postal/region">
                <xsl:variable name="region">
                  <xsl:call-template name="extract-normalized">
                    <xsl:with-param name="node" select="address/postal/region"/>
                    <xsl:with-param name="name" select="'address/postal/region'"/>
                  </xsl:call-template>
                </xsl:variable>
                <xsl:if test="$region!=''">
                  <span class="region">
                    <xsl:value-of select="$region"/>
                  </span>
                  <xsl:text>&#160;</xsl:text>
                </xsl:if>
              </xsl:if>
              <xsl:if test="address/postal/code">
                <xsl:variable name="code">
                  <xsl:call-template name="extract-normalized">
                    <xsl:with-param name="node" select="address/postal/code"/>
                    <xsl:with-param name="name" select="'address/postal/code'"/>
                  </xsl:call-template>
                </xsl:variable>
                <xsl:if test="$code!=''">
                  <span class="postal-code">
                    <xsl:value-of select="$code"/>
                  </span>
                </xsl:if>
              </xsl:if>
            </span>
          </xsl:if>
          <xsl:if test="address/postal/country">
            <xsl:variable name="country">
              <xsl:call-template name="extract-normalized">
                <xsl:with-param name="node" select="address/postal/country"/>
                <xsl:with-param name="name" select="'address/postal/country'"/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:if test="$country!=''">
              <span class="country-name vcardline">
                <xsl:value-of select="$country"/>
              </span>
            </xsl:if>
          </xsl:if>
        </span>
      </xsl:if>
      <xsl:if test="address/phone">
        <xsl:variable name="phone">
          <xsl:call-template name="extract-normalized">
            <xsl:with-param name="node" select="address/phone"/>
            <xsl:with-param name="name" select="'address/phone'"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:if test="$phone!=''">
          <span class="vcardline tel">
            <xsl:text>Phone: </xsl:text>
            <a href="tel:{translate($phone,' ','')}"><span class="value"><xsl:value-of select="$phone" /></span></a>
          </span>
        </xsl:if>
      </xsl:if>
      <xsl:if test="address/facsimile">
        <xsl:variable name="facsimile">
          <xsl:call-template name="extract-normalized">
            <xsl:with-param name="node" select="address/facsimile"/>
            <xsl:with-param name="name" select="'address/facsimile'"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:if test="$facsimile!=''">
          <span class="vcardline tel">
            <span class="type">Fax</span><xsl:text>: </xsl:text>
            <a href="fax:{translate($facsimile,' ','')}"><span class="value"><xsl:value-of select="$facsimile" /></span></a>
          </span>
        </xsl:if>
      </xsl:if>
      <xsl:for-each select="address/email">
        <xsl:variable name="email">
          <xsl:call-template name="extract-email"/>
        </xsl:variable>
        
        <span class="vcardline">
          <xsl:choose>
            <xsl:when test="$xml2rfc-rfcedstyle='yes'">Email: </xsl:when>
            <xsl:otherwise>EMail: </xsl:otherwise>
          </xsl:choose>
          <a>
            <xsl:if test="$xml2rfc-linkmailto!='no'">
              <xsl:attribute name="href">mailto:<xsl:value-of select="$email" /></xsl:attribute>
            </xsl:if>
            <span class="email"><xsl:value-of select="$email" /></span>
          </a>
        </span>
      </xsl:for-each>
      <xsl:for-each select="address/uri">
        <xsl:variable name="uri">
          <xsl:call-template name="extract-uri"/>
        </xsl:variable>
        <xsl:if test="$uri!=''">
          <span class="vcardline">
            <xsl:text>URI: </xsl:text>
            <a href="{$uri}" class="url"><xsl:value-of select="$uri" /></a>
            <xsl:if test="@x:annotation">
              <xsl:text> </xsl:text> 
              <i><xsl:value-of select="@x:annotation"/></i>
            </xsl:if>
          </span>
        </xsl:if>
      </xsl:for-each>
    </address>

</xsl:template>

<!-- this is a named template because <back> may be absent -->
<xsl:template name="back">
  <xsl:call-template name="check-no-text-content"/>

  <!-- add editorial comments -->
  <xsl:if test="//cref and $xml2rfc-comments='yes' and $xml2rfc-inline!='yes'">
    <xsl:call-template name="insertComments" />
  </xsl:if>
  
  <!-- next, add information about the document's authors -->
  <xsl:if test="$xml2rfc-ext-authors-section!='end'">
    <xsl:call-template name="insertAuthors" />
  </xsl:if>
     
  <!-- add all other top-level sections under <back> -->
  <xsl:apply-templates select="back/*[not(self::references) and not(self::ed:replace and .//references)]" />

  <!-- insert the index if index entries exist -->
  <!-- note it always comes before the authors section -->
  <xsl:if test="$has-index">
    <xsl:call-template name="insertIndex" />
  </xsl:if>

  <!-- Authors section is the absolute last thing, except for copyright stuff -->
  <xsl:if test="$xml2rfc-ext-authors-section='end'">
    <xsl:call-template name="insertAuthors" />
  </xsl:if>

  <xsl:if test="$xml2rfc-private=''">
    <!-- copyright statements -->
    <xsl:variable name="copyright"><xsl:call-template name="insertCopyright" /></xsl:variable>
  
    <!-- emit it -->
    <xsl:choose>
      <xsl:when test="function-available('exslt:node-set')">
        <xsl:apply-templates select="exslt:node-set($copyright)" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="error">
          <xsl:with-param name="msg" select="$node-set-warning"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
  
</xsl:template>

<xsl:template match="eref[node()]">
  <a href="{@target}"><xsl:apply-templates /></a>
</xsl:template>
               
<xsl:template match="eref[not(node())]">
  <xsl:text>&lt;</xsl:text>
  <a href="{@target}"><xsl:value-of select="@target" /></a>
  <xsl:text>&gt;</xsl:text>
</xsl:template>

<xsl:template match="figure">
  <xsl:call-template name="check-no-text-content"/>
  <xsl:if test="@anchor!=''">
    <xsl:call-template name="check-anchor"/>
    <div id="{@anchor}"/>
  </xsl:if>
  <xsl:variable name="anch">
    <xsl:call-template name="get-figure-anchor"/>
  </xsl:variable>
  <div id="{$anch}" />
  <xsl:apply-templates />
  <xsl:if test="(@title!='' or @anchor!='') and not(@suppress-title='true')">
    <xsl:variable name="n"><xsl:number level="any" count="figure[(@title!='' or @anchor!='') and not(@suppress-title='true')]" /></xsl:variable>
    <p class="figure">Figure <xsl:value-of select="$n"/><xsl:if test="@title!=''">: <xsl:value-of select="@title" /></xsl:if></p>
  </xsl:if>
</xsl:template>

<xsl:template match="front">
  <xsl:call-template name="check-no-text-content"/>
  <xsl:if test="$xml2rfc-topblock!='no'">
    <!-- collect information for left column -->
      
    <xsl:variable name="leftColumn">
      <xsl:call-template name="collectLeftHeaderColumn" />    
    </xsl:variable>
  
    <!-- collect information for right column -->
      
    <xsl:variable name="rightColumn">
      <xsl:call-template name="collectRightHeaderColumn" />    
    </xsl:variable>
      
    <!-- insert the collected information -->
    <table class="header">
      <xsl:choose>
        <xsl:when test="function-available('exslt:node-set')">
          <xsl:call-template name="emitheader">
            <xsl:with-param name="lc" select="exslt:node-set($leftColumn)" />    
            <xsl:with-param name="rc" select="exslt:node-set($rightColumn)" />    
          </xsl:call-template>
        </xsl:when>    
        <xsl:otherwise>
          <xsl:call-template name="error">
            <xsl:with-param name="msg" select="$node-set-warning"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </table>
  </xsl:if>
    
  <p class="title">
    <!-- main title -->

    <xsl:apply-templates select="title"/>
    <xsl:if test="/rfc/@docName">
      <xsl:variable name="docname" select="/rfc/@docName"/>

      <br/>
      <span class="filename"><xsl:value-of select="$docname"/></span>
      
      <xsl:variable name="docname-noext">
        <xsl:choose>
          <xsl:when test="contains($docname,'.')">
            <xsl:call-template name="warning">
              <xsl:with-param name="msg">The @docName attribute '<xsl:value-of select="$docname"/>' should contain the base name, not the filename (thus no file extension).</xsl:with-param>
            </xsl:call-template>
            <xsl:value-of select="substring-before($docname,'.')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$docname"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      
      <!-- more name checks -->
      <xsl:variable name="offending" select="translate($docname,concat($lcase,$digits,'-.'),'')"/>
      <xsl:if test="$offending != ''">
        <xsl:call-template name="warning">
          <xsl:with-param name="msg">The @docName attribute '<xsl:value-of select="$docname"/>' should not contain the character '<xsl:value-of select="substring($offending,1,1)"/>'.</xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      
      
      <xsl:if test="contains($docname,'--')">
        <xsl:call-template name="warning">
          <xsl:with-param name="msg">The @docName attribute '<xsl:value-of select="$docname"/>' should not contain the character sequence '--'.</xsl:with-param>
        </xsl:call-template>
      </xsl:if>

      <xsl:if test="not(starts-with($docname,'draft-'))">
        <xsl:call-template name="warning">
          <xsl:with-param name="msg">The @docName attribute '<xsl:value-of select="$docname"/>' should start with 'draft-'.</xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      
      <!-- sequence number -->
      <xsl:variable name="seq">
        <xsl:choose>
          <xsl:when test="substring($docname-noext,string-length($docname-noext) + 1 - string-length('-latest'))='-latest'">latest</xsl:when>
          <xsl:when test="substring($docname-noext,string-length($docname-noext) - 2, 1)='-'"><xsl:value-of select="substring($docname-noext,string-length($docname-noext)-1)"/></xsl:when>
          <xsl:otherwise/>
        </xsl:choose>
      </xsl:variable>

      <xsl:if test="$seq='' or ($seq!='latest' and translate($seq,$digits,'')!='')">
        <xsl:call-template name="warning">
          <xsl:with-param name="msg">The @docName attribute '<xsl:value-of select="$docname"/>' should end with a two-digit sequence number or 'latest'.</xsl:with-param>
        </xsl:call-template>
      </xsl:if>

      <xsl:if test="string-length($docname)-string-length($seq) > 50">
        <xsl:call-template name="warning">
          <xsl:with-param name="msg">The @docName attribute '<xsl:value-of select="$docname"/>', excluding sequence number, should have less than 50 characters.</xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      
    </xsl:if>  
  </p>
  
  <!-- insert notice about update -->
  <xsl:variable name="published-as" select="/*/x:link[@rel='Alternate' and starts-with(@title,'RFC')]"/>
  <xsl:if test="$published-as">
    <p style="color: green; text-align: center; font-size: 14pt; background-color: yellow;">
      <b>Note:</b> a later version of this document has been published as <a href="{$published-as/@href}"><xsl:value-of select="$published-as/@title"/></a>.
    </p>
  </xsl:if>
    
  <!-- check for conforming ipr attribute -->
  <xsl:choose>
    <xsl:when test="not(/rfc/@ipr)" />
    <xsl:when test="/rfc/@ipr = 'full2026'" />
    <xsl:when test="/rfc/@ipr = 'noDerivativeWorks'" />
    <xsl:when test="/rfc/@ipr = 'noDerivativeWorksNow'" />
    <xsl:when test="/rfc/@ipr = 'none'" />
    <xsl:when test="/rfc/@ipr = 'full3667'" />
    <xsl:when test="/rfc/@ipr = 'noModification3667'" />
    <xsl:when test="/rfc/@ipr = 'noDerivatives3667'" />
    <xsl:when test="/rfc/@ipr = 'full3978'" />
    <xsl:when test="/rfc/@ipr = 'noModification3978'" />
    <xsl:when test="/rfc/@ipr = 'noDerivatives3978'" />
    <xsl:when test="/rfc/@ipr = 'trust200811'" />
    <xsl:when test="/rfc/@ipr = 'noModificationTrust200811'" />
    <xsl:when test="/rfc/@ipr = 'noDerivativesTrust200811'" />
    <xsl:when test="/rfc/@ipr = 'trust200902'" />
    <xsl:when test="/rfc/@ipr = 'noModificationTrust200902'" />
    <xsl:when test="/rfc/@ipr = 'noDerivativesTrust200902'" />
    <xsl:when test="/rfc/@ipr = 'pre5378Trust200902'" />
    <xsl:otherwise>
      <xsl:call-template name="error">
        <xsl:with-param name="msg" select="concat('Unknown value for /rfc/@ipr: ', /rfc/@ipr)"/>
      </xsl:call-template>
    </xsl:otherwise>        
  </xsl:choose>            

  <xsl:if test="$xml2rfc-private='' and not($abstract-first)">
    <xsl:call-template name="emit-ietf-preamble"/>
  </xsl:if>
 
  <xsl:apply-templates select="x:boilerplate"/>
  <xsl:apply-templates select="abstract" />
  
  <!-- Notes except IESG Notes -->
  <xsl:apply-templates select="note[@title!='IESG Note' or $xml2rfc-private!='']" />
  <!-- show notes inside change tracking as well -->
  <xsl:apply-templates select="ed:replace[.//note[@title!='IESG Note' or $xml2rfc-private!='']]" />
    
  <xsl:if test="$xml2rfc-private='' and $abstract-first">
    <xsl:call-template name="emit-ietf-preamble"/>
  </xsl:if>

  <xsl:if test="$xml2rfc-toc='yes'">
    <xsl:apply-templates select="/" mode="toc" />
    <xsl:call-template name="insertTocAppendix" />
  </xsl:if>

</xsl:template>

<xsl:template name="emit-ietf-preamble">
  <!-- Get status info formatted as per RFC2629-->
  <xsl:variable name="preamble">
    <xsl:call-template name="insertPreamble" />
  </xsl:variable>
  
  <!-- emit it -->
  <xsl:choose>
    <xsl:when test="function-available('exslt:node-set')">
      <xsl:apply-templates select="exslt:node-set($preamble)" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="error">
        <xsl:with-param name="msg" select="$node-set-warning"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="iref">
  <xsl:variable name="anchor"><xsl:call-template name="compute-iref-anchor"/></xsl:variable>
  <xsl:choose>
    <xsl:when test="parent::figure">
      <div id="{$anchor}"/>
    </xsl:when>
    <xsl:when test="ancestor::t or ancestor::artwork or ancestor::preamble or ancestor::postamble">
      <span id="{$anchor}"/>
    </xsl:when>
    <xsl:otherwise>
      <div id="{$anchor}"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="compute-iref-anchor">
  <xsl:variable name="first" select="translate(substring(@item,1,1),$ucase,$lcase)"/>
  <xsl:variable name="nkey" select="translate($first,$lcase,'')"/>
  <xsl:choose>
    <xsl:when test="$nkey=''">
      <xsl:value-of select="$anchor-prefix"/>.iref.<xsl:value-of select="$first"/>.<xsl:number level="any" count="iref[starts-with(translate(@item,$ucase,$lcase),$first)]"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$anchor-prefix"/>.iref.<xsl:number level="any" count="iref[translate(substring(@item,1,1),concat($lcase,$ucase),'')='']"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="compute-extref-anchor">
  <xsl:variable name="first" select="translate(substring(.,1,1),$ucase,$lcase)"/>
  <xsl:variable name="nkey" select="translate($first,$lcase,'')"/>
  <xsl:choose>
    <xsl:when test="$nkey=''">
      <xsl:value-of select="$anchor-prefix"/>.extref.<xsl:value-of select="$first"/>.<xsl:number level="any" count="x:ref[starts-with(translate(.,$ucase,$lcase),$first)]"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$anchor-prefix"/>.extref.<xsl:number level="any" count="x:ref[translate(substring(.,1,1),concat($lcase,$ucase),'')='']"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- list templates depend on the list style -->

<xsl:template match="list[@style='empty' or not(@style)]">
  <xsl:call-template name="check-no-text-content"/>
  <ul class="empty">
    <xsl:call-template name="insertInsDelClass"/>
    <xsl:apply-templates />
  </ul>
</xsl:template>

<xsl:template match="list[starts-with(@style,'format ')]">
  <xsl:call-template name="check-no-text-content"/>
  <dl>
    <xsl:call-template name="insertInsDelClass"/>
    <xsl:apply-templates />
  </dl>
</xsl:template>

<xsl:template match="list[@style='hanging']">
  <xsl:call-template name="check-no-text-content"/>
  <dl>
    <xsl:call-template name="insertInsDelClass"/>
    <xsl:apply-templates />
  </dl>
</xsl:template>

<xsl:template match="list[@style='numbers']">
  <xsl:call-template name="check-no-text-content"/>
  <ol>
    <xsl:call-template name="insertInsDelClass"/>
    <xsl:apply-templates />
  </ol>
</xsl:template>

<!-- numbered list inside numbered list -->
<xsl:template match="list[@style='numbers']/t/list[@style='numbers']" priority="9">
  <xsl:call-template name="check-no-text-content"/>
  <ol class="la">
    <xsl:call-template name="insertInsDelClass"/>
    <xsl:apply-templates />
  </ol>
</xsl:template>

<xsl:template match="list[@style='letters']">
  <xsl:call-template name="check-no-text-content"/>
  <ol class="la">
    <xsl:call-template name="insertInsDelClass"/>
    <xsl:apply-templates />
  </ol>
</xsl:template>

<!-- nested lettered list uses uppercase -->
<xsl:template match="list//t//list[@style='letters']" priority="9">
  <ol class="ua">
    <xsl:call-template name="insertInsDelClass"/>
    <xsl:apply-templates />
  </ol>
</xsl:template>
   
<xsl:template match="list[@style='symbols']">
  <xsl:call-template name="check-no-text-content"/>
  <ul>
    <xsl:call-template name="insertInsDelClass"/>
    <xsl:apply-templates />
  </ul>
</xsl:template>


<!-- same for t(ext) elements -->

<xsl:template match="list[@style='empty' or not(@style)]/t | list[@style='empty' or not(@style)]/ed:replace/ed:*/t">
  <xsl:if test="@hangText">
    <xsl:call-template name="warning">
      <xsl:with-param name="msg" select="'t/@hangText used on unstyled list'"/>
    </xsl:call-template>
  </xsl:if>
  <li>
    <xsl:call-template name="copy-anchor"/>
    <xsl:call-template name="insertInsDelClass"/>
    <xsl:apply-templates />
  </li>
</xsl:template>

<xsl:template match="list[@style='numbers' or @style='symbols' or @style='letters']/x:lt">
  <li>
    <xsl:call-template name="copy-anchor"/>
    <xsl:apply-templates select="t" />
  </li>
</xsl:template>

<xsl:template match="list[@style='numbers' or @style='symbols' or @style='letters']/t | list[@style='numbers' or @style='symbols' or @style='letters']/ed:replace/ed:*/t">
  <xsl:if test="@hangText">
    <xsl:call-template name="warning">
      <xsl:with-param name="msg" select="'t/@hangText used on non-hanging list'"/>
    </xsl:call-template>
  </xsl:if>
  <li>
    <xsl:call-template name="copy-anchor"/>
    <xsl:call-template name="insertInsDelClass"/>
    <xsl:for-each select="../..">
      <xsl:call-template name="insert-issue-pointer"/>
    </xsl:for-each>
    <xsl:apply-templates />
  </li>
</xsl:template>

<xsl:template match="list[@style='hanging']/x:lt">
  <xsl:if test="@hangText!=''">
    <dt>
      <xsl:call-template name="copy-anchor"/>
      <xsl:call-template name="insertInsDelClass"/>
      <xsl:variable name="del-node" select="ancestor::ed:del"/>
      <xsl:variable name="rep-node" select="ancestor::ed:replace"/>
      <xsl:variable name="deleted" select="$del-node and ($rep-node/ed:ins)"/>
      <xsl:for-each select="../..">
        <xsl:call-template name="insert-issue-pointer">
          <xsl:with-param name="deleted-anchor" select="$deleted"/>
        </xsl:call-template>
      </xsl:for-each>
      <xsl:value-of select="@hangText" />
    </dt>
  </xsl:if>
  <dd>
    <xsl:call-template name="insertInsDelClass"/>
    <!-- if hangIndent present, use 0.7 of the specified value (1em is the width of the "m" character -->
    <xsl:if test="../@hangIndent and ../@hangIndent!='0'">
      <xsl:attribute name="style">margin-left: <xsl:value-of select="../@hangIndent * 0.7"/>em</xsl:attribute>
    </xsl:if>
    <xsl:apply-templates select="t" />
  </dd>
</xsl:template>

<xsl:template match="list[@style='hanging']/t | list[@style='hanging']/ed:replace/ed:*/t">
  <xsl:if test="@hangText!=''">
    <dt>
      <xsl:call-template name="copy-anchor"/>
      <xsl:call-template name="insertInsDelClass"/>
      <xsl:if test="count(preceding-sibling::t)=0">
        <xsl:variable name="del-node" select="ancestor::ed:del"/>
        <xsl:variable name="rep-node" select="ancestor::ed:replace"/>
        <xsl:variable name="deleted" select="$del-node and ($rep-node/ed:ins)"/>
        <xsl:for-each select="../..">
          <xsl:call-template name="insert-issue-pointer">
            <xsl:with-param name="deleted-anchor" select="$deleted"/>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:if>
      <xsl:value-of select="@hangText" />
    </dt>
  </xsl:if>

  <xsl:variable name="dd-content">
    <xsl:apply-templates/>
  </xsl:variable>

  <xsl:if test="$dd-content!=''">
    <dd>
      <xsl:call-template name="insertInsDelClass"/>
      <!-- if hangIndent present, use 0.7 of the specified value (1em is the width of the "m" character -->
      <xsl:if test="../@hangIndent and ../@hangIndent!='0'">
        <xsl:attribute name="style">margin-left: <xsl:value-of select="../@hangIndent * 0.7"/>em</xsl:attribute>
      </xsl:if>
      <xsl:apply-templates />
    </dd>
  </xsl:if>
</xsl:template>

<xsl:template match="list[starts-with(@style,'format ') and (contains(@style,'%c') or contains(@style,'%d'))]/t">
  <xsl:variable name="list" select=".." />
  <xsl:variable name="format" select="substring-after(../@style,'format ')" />
  <xsl:variable name="pos">
    <xsl:choose>
      <xsl:when test="$list/@counter">
        <xsl:number level="any" count="list[@counter=$list/@counter or (not(@counter) and @style=concat('format ',$list/@counter))]/t" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:number level="any" count="list[concat('format ',@counter)=$list/@style or (not(@counter) and @style=$list/@style)]/t" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <dt>
    <xsl:call-template name="copy-anchor"/>
    <xsl:choose>
      <xsl:when test="contains($format,'%c')">
        <xsl:value-of select="substring-before($format,'%c')"/><xsl:number value="$pos" format="a" /><xsl:value-of select="substring-after($format,'%c')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="substring-before($format,'%d')"/><xsl:number value="$pos" format="1" /><xsl:value-of select="substring-after($format,'%d')"/>
      </xsl:otherwise>
    </xsl:choose>
  </dt>
  <dd>
    <xsl:apply-templates />
  </dd>
</xsl:template>

<xsl:template match="middle">
  <xsl:apply-templates />
  <xsl:apply-templates select="../back//references"/>
</xsl:template>

<xsl:template match="note">
  <xsl:variable name="num"><xsl:number/></xsl:variable>
    <h1 id="{$anchor-prefix}.note.{$num}">
      <xsl:call-template name="insertInsDelClass"/>
      <a href="#{$anchor-prefix}.note.{$num}">
        <xsl:value-of select="@title" />
      </a>
    </h1>
  <xsl:apply-templates />
</xsl:template>

<xsl:template match="postamble">
  <xsl:if test="normalize-space(.) != ''">
    <p>
      <xsl:call-template name="insertInsDelClass"/>
      <xsl:call-template name="editingMark" />
      <xsl:apply-templates />
    </p>
  </xsl:if>
</xsl:template>

<xsl:template match="preamble">
  <xsl:if test="normalize-space(.) != ''">
    <p>
      <xsl:call-template name="copy-anchor"/>
      <xsl:call-template name="insertInsDelClass"/>
      <xsl:call-template name="editingMark" />
      <xsl:apply-templates />
    </p>
  </xsl:if>
</xsl:template>

<xsl:template name="computed-auto-target">
  <xsl:param name="bib"/>
  <xsl:param name="ref"/>

  <xsl:choose>
    <xsl:when test="$ref and $bib/x:source/@href and $bib/x:source/@basename and $ref/@x:rel">
      <xsl:value-of select="concat($bib/x:source/@basename,'.',$outputExtension,$ref/@x:rel)" />
    </xsl:when>
    <xsl:when test="$ref and $bib/x:source/@href and $bib/x:source/@basename and $ref/@anchor">
      <xsl:value-of select="concat($bib/x:source/@basename,'.',$outputExtension,'#',$ref/@anchor)" />
    </xsl:when>
    <!-- tools.ietf.org won't have the "-latest" draft -->
    <xsl:when test="$bib/seriesInfo/@name='Internet-Draft' and $bib/x:source/@href and $bib/x:source/@basename and substring($bib/x:source/@basename, (string-length($bib/x:source/@basename) - string-length('-latest')) + 1)='-latest'">
      <xsl:value-of select="concat($bib/x:source/@basename,'.',$outputExtension)" />
    </xsl:when>
    <!-- TODO: this should handle the case where there's one BCP entry but
    multiple RFC entries in a more useful way-->
    <xsl:when test="$bib/seriesInfo/@name='RFC'">
      <xsl:variable name="rfcEntries" select="$bib/seriesInfo[@name='RFC']"/>
      <xsl:if test="count($rfcEntries)!=1">
        <xsl:call-template name="warning">
          <xsl:with-param name="msg" select="concat('seriesInfo/@name=RFC encountered multiple times for reference ',$bib/@anchor,', will generate link to first entry only')"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:variable name="sec">
        <xsl:choose>
          <xsl:when test="$ref and starts-with($ref/@x:rel,'#') and not($ref/@x:sec)">
            <xsl:variable name="extdoc" select="document($bib/x:source/@href)"/>
            <xsl:for-each select="$extdoc//*[@anchor=substring-after($ref/@x:rel,'#')]">
              <xsl:call-template name="get-section-number"/>
            </xsl:for-each>
          </xsl:when>
          <xsl:when test="$ref">
            <xsl:value-of select="$ref/@x:sec"/>
          </xsl:when>
          <xsl:otherwise/>
        </xsl:choose>
      </xsl:variable>
      <xsl:value-of select="concat($rfcUrlPrefix,$rfcEntries[1]/@value,$rfcUrlPostfix)" />
      <xsl:if test="$ref and $sec!='' and $rfcUrlFragSection and $rfcUrlFragAppendix">
        <xsl:choose>
          <xsl:when test="translate(substring($sec,1,1),$ucase,'')=''">
            <xsl:value-of select="concat('#',$rfcUrlFragAppendix,$sec)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat('#',$rfcUrlFragSection,$sec)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:when>
    <xsl:when test="$bib/seriesInfo/@name='Internet-Draft'">
      <xsl:value-of select="concat($internetDraftUrlPrefix,$bib/seriesInfo[@name='Internet-Draft']/@value,$internetDraftUrlPostfix)" />
      <xsl:if test="$ref and $ref/@x:sec and $internetDraftUrlFrag">
        <xsl:value-of select="concat('#',$internetDraftUrlFrag,$ref/@x:sec)"/>
      </xsl:if>
    </xsl:when>
    <xsl:otherwise />
  </xsl:choose>  
  
</xsl:template>

<xsl:template name="computed-target">
  <xsl:param name="bib"/>
  <xsl:param name="ref"/>

  <xsl:choose>
    <xsl:when test="$bib/@target">
      <xsl:if test="$ref and $ref/@x:sec and $ref/@x:rel">
        <xsl:value-of select="concat($bib/@target,$ref/@x:rel)"/>
      </xsl:if>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="computed-auto-target">
        <xsl:with-param name="bib" select="$bib"/>
        <xsl:with-param name="ref" select="$ref"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>  
  
</xsl:template>

<xsl:template match="reference">
  <xsl:call-template name="check-no-text-content"/>

  <!-- check for reference to reference -->
  <xsl:variable name="anchor" select="@anchor"/>
  <xsl:if test="not(ancestor::ed:del) and not(key('xref-item',$anchor))">
    <xsl:call-template name="warning">
      <xsl:with-param name="msg">unused reference '<xsl:value-of select="@anchor"/>'</xsl:with-param>
    </xsl:call-template>
  </xsl:if>

  <!-- check normative/informative -->
  <xsl:variable name="t-r-is-normative" select="ancestor-or-self::*[@x:nrm][1]"/>
  <xsl:variable name="r-is-normative" select="$t-r-is-normative/@x:nrm='true'"/>
  <xsl:if test="$r-is-normative and not(ancestor::ed:del)">
    <xsl:variable name="tst">
      <xsl:for-each select="key('xref-item',$anchor)">
        <xsl:variable name="t-is-normative" select="ancestor-or-self::*[@x:nrm][1]"/>
        <xsl:variable name="is-normative" select="$t-is-normative/@x:nrm='true'"/>
        <xsl:if test="$is-normative">OK</xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:if test="$tst=''">
      <xsl:call-template name="warning">
        <xsl:with-param name="msg">all references to the normative reference '<xsl:value-of select="@anchor"/>' appear to be informative</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:if>

  <xsl:call-template name="check-anchor"/>

  <xsl:variable name="target">
    <xsl:choose>
      <xsl:when test="@target">
        <xsl:if test="string-length(normalize-space(@target)) = 0">
          <xsl:call-template name="warning">
            <xsl:with-param name="msg">invalid (empty) target attribute in reference '<xsl:value-of select="@anchor"/>'</xsl:with-param>
          </xsl:call-template>
        </xsl:if>
        <xsl:value-of select="normalize-space(@target)" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="computed-auto-target">
          <xsl:with-param name="bib" select="."/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <tr>
    <td class="reference">
      <xsl:call-template name="insertInsDelClass"/>
      <xsl:variable name="del-node" select="ancestor::ed:del"/>
      <xsl:variable name="rep-node" select="ancestor::ed:replace"/>
      <xsl:variable name="deleted" select="$del-node and ($rep-node/ed:ins)"/>
      <xsl:for-each select="../..">
        <xsl:call-template name="insert-issue-pointer">
          <xsl:with-param name="deleted-anchor" select="$deleted"/>
        </xsl:call-template>
      </xsl:for-each>
      <b id="{@anchor}">
        <xsl:call-template name="referencename">
          <xsl:with-param name="node" select="." />
        </xsl:call-template>
      </b>
    </td>
    
    <td class="top">
      <xsl:call-template name="insertInsDelClass"/>
      <xsl:for-each select="front/author">
        <xsl:variable name="initials">
          <xsl:call-template name="format-initials"/>
        </xsl:variable>
        <xsl:variable name="truncated-initials" select="concat(substring-before($initials,'.'),'.')"/>
      
        <xsl:choose>
          <xsl:when test="@surname and @surname!=''">
            <xsl:variable name="displayname">
              <!-- surname/initials is reversed for last author except when it's the only one -->
              <xsl:choose>
                <xsl:when test="position()=last() and position()!=1">
                  <xsl:value-of select="concat($truncated-initials,' ',@surname)" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="concat(@surname,', ',$truncated-initials)" />
                </xsl:otherwise>
              </xsl:choose>
              <xsl:if test="@role='editor'">
                <xsl:text>, Ed.</xsl:text>
              </xsl:if>
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="address/email">
                <a>
                  <xsl:if test="$xml2rfc-linkmailto!='no'">
                    <xsl:attribute name="href">mailto:<xsl:value-of select="address/email" /></xsl:attribute>
                  </xsl:if>
                  <xsl:if test="organization/text()">
                    <xsl:attribute name="title"><xsl:value-of select="organization/text()"/></xsl:attribute>
                  </xsl:if>
                  <xsl:value-of select="$displayname" />
                </a>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$displayname" />
              </xsl:otherwise>
            </xsl:choose>
            
            <xsl:choose>
              <xsl:when test="position()=last() - 1">
                <xsl:if test="last() &gt; 2">,</xsl:if>
                <xsl:text> and </xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>, </xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="organization/text()">
            <xsl:choose>
              <xsl:when test="address/uri">
                <a href="{address/uri}"><xsl:value-of select="organization" /></a>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="organization" />
              </xsl:otherwise>
            </xsl:choose>
            
            <xsl:choose>
              <xsl:when test="position()=last() - 1">
                <xsl:if test="last() &gt; 2">,</xsl:if>
                <xsl:text> and </xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>, </xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise />
        </xsl:choose>
      </xsl:for-each>
         
      <xsl:if test="not(front/title/@x:quotes='false')">&#8220;</xsl:if>
      <xsl:choose>
        <xsl:when test="string-length($target) &gt; 0">
          <a href="{$target}"><xsl:value-of select="normalize-space(front/title)" /></a>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="normalize-space(front/title)" />
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="not(front/title/@x:quotes='false')">&#8221;</xsl:if>
      
      <xsl:variable name="rfcs" select="count(seriesInfo[@name='RFC'])"/>
            
      <xsl:for-each select="seriesInfo">
        <xsl:text>, </xsl:text>
        <xsl:choose>
          <xsl:when test="not(@name) and not(@value) and ./text()"><xsl:value-of select="." /></xsl:when>
          <xsl:when test="@name='RFC' and $rfcs > 1">
            <a href="{concat($rfcUrlPrefix,@value,$rfcUrlPostfix)}">
              <xsl:value-of select="@name" />
              <xsl:if test="@value!=''">&#0160;<xsl:value-of select="@value" /></xsl:if>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@name" />
            <xsl:if test="@value!=''">&#0160;<xsl:value-of select="@value" /></xsl:if>
            <xsl:if test="translate(@name,$ucase,$lcase)='internet-draft'"> (work in progress)</xsl:if>
          </xsl:otherwise>
        </xsl:choose>
        
        <!-- check that BCP FYI STD RFC are in the right order -->
        <xsl:if test="(@name='BCP' or @name='FYI' or @name='STD') and preceding-sibling::seriesInfo[@name='RFC']">
          <xsl:call-template name="warning">
            <xsl:with-param name="msg">RFC number preceding <xsl:value-of select="@name"/> number in reference '<xsl:value-of select="../@anchor"/>'</xsl:with-param>
          </xsl:call-template>
        </xsl:if>
        
      </xsl:for-each>
      
      <!-- avoid hacks using seriesInfo when it's not really series information -->
      <xsl:for-each select="x:prose">
        <xsl:text>, </xsl:text>
        <xsl:value-of select="."/>
      </xsl:for-each>

      <xsl:if test="not(front/date)">
        <xsl:call-template name="warning">
          <xsl:with-param name="msg">&lt;date&gt; missing in reference '<xsl:value-of select="@anchor"/>' (note that it can be empty)</xsl:with-param>
        </xsl:call-template>
      </xsl:if>

      <xsl:if test="front/date/@year != ''">
        <xsl:if test="string(number(front/date/@year)) = 'NaN'">
          <xsl:call-template name="warning">
            <xsl:with-param name="msg">date/@year should be a number: '<xsl:value-of select="front/date/@year"/>' in reference '<xsl:value-of select="@anchor"/>'</xsl:with-param>
          </xsl:call-template>
        </xsl:if>
        <xsl:text>, </xsl:text>
        <xsl:if test="front/date/@month!=''"><xsl:value-of select="front/date/@month" />&#0160;</xsl:if>
        <xsl:value-of select="front/date/@year" />
      </xsl:if>
      
      <xsl:if test="string-length(normalize-space(@target)) &gt; 0">
        <xsl:text>, &lt;</xsl:text>
        <a href="{normalize-space(@target)}"><xsl:value-of select="normalize-space(@target)"/></a>
        <xsl:text>&gt;</xsl:text>
      </xsl:if>
      
      <xsl:text>.</xsl:text>

      <xsl:for-each select="annotation">
        <br />
        <xsl:apply-templates />
      </xsl:for-each>

    </td>
  </tr>
  
  
</xsl:template>


<xsl:template match="references">
  <xsl:call-template name="check-no-text-content"/>

  <xsl:variable name="name">
    <xsl:if test="ancestor::ed:del">
      <xsl:text>del-</xsl:text>
    </xsl:if>
    <xsl:number level="any"/>      
  </xsl:variable>
  
  <xsl:variable name="refseccount" select="count(/rfc/back/references)+count(/rfc/back/ed:replace/ed:ins/references)"/>

  <!-- insert pseudo section when needed -->
  <xsl:if test="not(preceding::references) and $refseccount!=1">
    <xsl:call-template name="insert-conditional-hrule"/>
    <h1 id="{$anchor-prefix}.references">
      <xsl:call-template name="insert-conditional-pagebreak"/>
      <xsl:variable name="sectionNumber">
        <xsl:call-template name="get-references-section-number"/>
      </xsl:variable>
      <a id="{$anchor-prefix}.section.{$sectionNumber}" href="#{$anchor-prefix}.section.{$sectionNumber}">
        <xsl:call-template name="emit-section-number">
          <xsl:with-param name="no" select="$sectionNumber"/>
        </xsl:call-template>
      </a>
      <xsl:text> </xsl:text>
      <xsl:value-of select="$xml2rfc-refparent"/>
    </h1>
  </xsl:if>
  
  <xsl:variable name="elemtype">
    <xsl:choose>
      <xsl:when test="$refseccount!=1">h2</xsl:when>
      <xsl:otherwise>h1</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:variable name="title">
    <xsl:choose>
      <xsl:when test="not(@title) or @title=''"><xsl:value-of select="$xml2rfc-refparent"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="@title"/></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:element name="{$elemtype}"> 
    <xsl:if test="$name='1'">
      <xsl:call-template name="insert-conditional-pagebreak"/>
    </xsl:if>
    <xsl:variable name="sectionNumber">
      <xsl:call-template name="get-section-number"/>
    </xsl:variable>
    <xsl:variable name="anchorpref">
      <xsl:choose>
        <xsl:when test="$elemtype='h1'"></xsl:when>
        <xsl:otherwise>.<xsl:value-of select="$name"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:attribute name="id"><xsl:value-of select="concat($anchor-prefix,'.references',$anchorpref)"/></xsl:attribute>
    <a href="#{$anchor-prefix}.section.{$sectionNumber}" id="{$anchor-prefix}.section.{$sectionNumber}">
      <xsl:call-template name="emit-section-number">
        <xsl:with-param name="no" select="$sectionNumber"/>
      </xsl:call-template>
    </a>
    <xsl:text> </xsl:text>
    <xsl:value-of select="$title"/>
  </xsl:element>
 
  <table>
    <xsl:choose>
      <xsl:when test="$xml2rfc-sortrefs='yes' and $xml2rfc-symrefs!='no'">
        <xsl:apply-templates>
          <xsl:sort select="@anchor|.//ed:ins//reference/@anchor" />
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates />
      </xsl:otherwise>
    </xsl:choose>
  </table>

</xsl:template>

<xsl:template match="rfc">
  <xsl:call-template name="check-no-text-content"/>
  <xsl:variable name="ignored">
    <xsl:call-template name="parse-pis">
      <xsl:with-param name="nodes" select="//processing-instruction('rfc-ext')"/>
      <xsl:with-param name="attr" select="'SANITYCHECK'"/>
    </xsl:call-template>
    <xsl:call-template name="parse-pis">
      <xsl:with-param name="nodes" select="//processing-instruction('rfc')"/>
      <xsl:with-param name="attr" select="'SANITYCHECK'"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="lang">
    <xsl:call-template name="get-lang" />
  </xsl:variable>

  <html lang="{$lang}">
    <head>
      <xsl:attribute name="profile">
        <xsl:text>http://www.w3.org/2006/03/hcard</xsl:text>
        <xsl:if test="$xml2rfc-ext-support-rfc2731!='no'">
          <xsl:text> </xsl:text>
          <xsl:text>http://dublincore.org/documents/2008/08/04/dc-html/</xsl:text>
        </xsl:if>
      </xsl:attribute>
      <title>
        <xsl:apply-templates select="front/title" mode="get-text-content" />
      </title>
      <xsl:call-template name="insertScript" />
      <xsl:call-template name="insertCss" />
      <!-- <link rel="alternate stylesheet" type="text/css" media="screen" title="Plain (typewriter)" href="rfc2629tty.css" /> -->
            
      <!-- link elements -->
      <xsl:if test="$xml2rfc-toc='yes'">
        <link rel="Contents" href="#{$anchor-prefix}.toc" />
      </xsl:if>
      <link rel="Author" href="#{$anchor-prefix}.authors" />
      <xsl:if test="$xml2rfc-private=''">
        <xsl:choose>
          <xsl:when test="$no-copylong">
            <link rel="Copyright" href="#{$anchor-prefix}.copyrightnotice" />
          </xsl:when>
          <xsl:otherwise>
            <link rel="Copyright" href="#{$anchor-prefix}.copyright" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <xsl:if test="$has-index">
        <link rel="Index" href="#{$anchor-prefix}.index" />
      </xsl:if>
      <xsl:apply-templates select="/" mode="links" />
      <xsl:for-each select="x:link">
        <link>
          <xsl:choose>
            <xsl:when test="@basename">
              <xsl:attribute name="href">
                <xsl:value-of select="concat(@basename,'.',$outputExtension)"/>
              </xsl:attribute>
              <xsl:copy-of select="@rel|@title" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:copy-of select="@*" />
            </xsl:otherwise>
          </xsl:choose>
        </link>
      </xsl:for-each>
      <xsl:if test="@number">
        <link rel="Alternate" title="Authorative ASCII Version" href="http://www.ietf.org/rfc/rfc{@number}.txt" />
        <link rel="Help" title="RFC-Editor's Status Page" href="http://www.rfc-editor.org/info/rfc{@number}" />
        <link rel="Help" title="Additional Information on tools.ietf.org" href="http://tools.ietf.org/html/rfc{@number}" />
      </xsl:if>

      <!-- generator -->
      <xsl:variable name="gen">
        <xsl:call-template name="get-generator" />
      </xsl:variable>
      <meta name="generator" content="{$gen}" />
      
      <!-- keywords -->
      <xsl:if test="front/keyword">
        <xsl:variable name="keyw">
          <xsl:call-template name="get-keywords" />
        </xsl:variable>
        <meta name="keywords" content="{$keyw}" />
      </xsl:if>

      <xsl:if test="$xml2rfc-ext-support-rfc2731!='no'">
        <!-- Dublin Core Metadata -->
        <link rel="schema.dct" href="http://purl.org/dc/terms/" />
              
        <!-- DC creator, see RFC2731 -->
        <xsl:for-each select="front/author">
          <xsl:variable name="initials">
            <xsl:call-template name="format-initials"/>
          </xsl:variable>
          <meta name="dct.creator" content="{concat(@surname,', ',$initials)}" />
        </xsl:for-each>
        
        <xsl:if test="$xml2rfc-private=''">
          <xsl:choose>
            <xsl:when test="@number">
              <meta name="dct.identifier" content="urn:ietf:rfc:{@number}" />
            </xsl:when>
            <xsl:when test="@docName">
              <meta name="dct.identifier" content="urn:ietf:id:{@docName}" />
            </xsl:when>
            <xsl:otherwise/>
          </xsl:choose>
          <meta name="dct.issued" scheme="ISO8601">
            <xsl:attribute name="content">
              <xsl:value-of select="concat($xml2rfc-ext-pub-year,'-',$pub-month-numeric)"/>
              <xsl:if test="$xml2rfc-ext-pub-day != '' and not(@number)">
                <xsl:value-of select="concat('-',format-number($xml2rfc-ext-pub-day,'00'))"/>
              </xsl:if>
            </xsl:attribute>
          </meta>
  
          <xsl:if test="@obsoletes!=''">
            <xsl:call-template name="rfclist-for-dcmeta">
              <xsl:with-param name="list" select="@obsoletes"/>
            </xsl:call-template>
          </xsl:if>
        </xsl:if>
  
        <xsl:if test="front/abstract">
          <meta name="dct.abstract" content="{normalize-space(front/abstract)}" />
        </xsl:if>      

        <xsl:if test="@number">
          <meta name="dct.isPartOf" content="urn:issn:2070-1721" />
        </xsl:if>      

      </xsl:if>
      
      <!-- this replicates dct.abstract, but is used by Google & friends -->
      <xsl:if test="front/abstract">
        <meta name="description" content="{normalize-space(front/abstract)}" />
      </xsl:if>
      
    </head>
    <body>
      <xsl:if test="/rfc/x:feedback">
        <xsl:attribute name="onload">init();</xsl:attribute>
      </xsl:if>
    
      <!-- insert diagnostics -->
      <xsl:call-template name="insert-diagnostics"/>

      <xsl:apply-templates select="front" />
      <xsl:apply-templates select="middle" />
      <xsl:call-template name="back" />
    </body>
  </html>
</xsl:template>               


<xsl:template match="t">
  <xsl:if test="preceding-sibling::section or preceding-sibling::appendix">
    <xsl:call-template name="inline-warning">
      <xsl:with-param name="msg">The paragraph below is misplaced; maybe a section is closed in the wrong place: </xsl:with-param>
      <xsl:with-param name="msg2"><xsl:value-of select="."/></xsl:with-param>
    </xsl:call-template>
  </xsl:if>
  <xsl:choose>
    <xsl:when test="@anchor">
      <div id="{@anchor}"><xsl:apply-templates mode="t-content" select="node()[1]" /></div>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates mode="t-content" select="node()[1]" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- for t-content, dispatch to default templates if it's block-level content -->
<xsl:template mode="t-content" match="list|figure|texttable">
  <!-- <xsl:comment>t-content block-level</xsl:comment>  -->
  <xsl:apply-templates select="." />
  <xsl:apply-templates select="following-sibling::node()[1]" mode="t-content" />
</xsl:template>               
               
<!-- ... otherwise group into p elements -->
<xsl:template mode="t-content" match="*|node()">
  <xsl:variable name="p">
    <xsl:call-template name="get-paragraph-number" />
  </xsl:variable>

  <!-- do not open a new p element if this is a whitespace-only text node and no siblings follow -->  
  <xsl:if test="not(self::text() and normalize-space(.)='' and not(following-sibling::node()))">
    <p>
      <xsl:if test="$p!='' and not(ancestor::ed:del) and not(ancestor::ed:ins) and not(ancestor::x:lt) and count(preceding-sibling::node())=0">
        <xsl:attribute name="id"><xsl:value-of select="$anchor-prefix"/>.section.<xsl:value-of select="$p"/></xsl:attribute>
      </xsl:if>
      <xsl:call-template name="insertInsDelClass"/>
      <xsl:call-template name="editingMark" />
      <xsl:apply-templates mode="t-content2" select="." />
    </p>
  </xsl:if>
  <xsl:apply-templates mode="t-content" select="following-sibling::*[self::list or self::figure or self::texttable][1]" />
</xsl:template>               
               
<xsl:template mode="t-content2" match="*">
  <xsl:apply-templates select="." />
  <xsl:if test="not(following-sibling::node()[1] [self::list or self::figure or self::texttable])">
    <xsl:apply-templates select="following-sibling::node()[1]" mode="t-content2" />
  </xsl:if>
</xsl:template>       

<xsl:template mode="t-content2" match="text()">
  <xsl:apply-templates select="." />
  <xsl:if test="not(following-sibling::node()[1] [self::list or self::figure or self::texttable])">
    <xsl:apply-templates select="following-sibling::node()[1]" mode="t-content2" />
  </xsl:if>
</xsl:template>               

<xsl:template mode="t-content2" match="comment()|processing-instruction()">
  <xsl:apply-templates select="." />
  <xsl:if test="not(following-sibling::node()[1] [self::list or self::figure or self::texttable])">
    <xsl:apply-templates select="following-sibling::node()[1]" mode="t-content2" />
  </xsl:if>
</xsl:template>               

<xsl:template match="title">
  <xsl:if test="@abbrev and string-length(@abbrev) > 40">
    <xsl:call-template name="warning">
      <xsl:with-param name="msg">title/@abbrev too long (max 40 characters)</xsl:with-param>
    </xsl:call-template>
  </xsl:if>

  <xsl:if test="string-length(.) > 40 and (not(@abbrev) or @abbrev='')">
    <xsl:call-template name="warning">
      <xsl:with-param name="msg">title too long, should supply title/@abbrev attribute with less than 40 characters</xsl:with-param>
    </xsl:call-template>
  </xsl:if>

  <xsl:apply-templates />
</xsl:template>

<xsl:template name="insertTitle">
  <xsl:choose>
    <xsl:when test="@ed:old-title">
      <del>
        <xsl:if test="ancestor-or-self::*[@ed:entered-by] and @ed:datetime">
          <xsl:attribute name="title"><xsl:value-of select="concat(@ed:datetime,', ',ancestor-or-self::*[@ed:entered-by][1]/@ed:entered-by)"/></xsl:attribute>
        </xsl:if>
        <xsl:value-of select="@ed:old-title"/>
      </del>
      <ins>
        <xsl:if test="ancestor-or-self::*[@ed:entered-by] and @ed:datetime">
          <xsl:attribute name="title"><xsl:value-of select="concat(@ed:datetime,', ',ancestor-or-self::*[@ed:entered-by][1]/@ed:entered-by)"/></xsl:attribute>
        </xsl:if>
        <xsl:value-of select="@title"/>
      </ins>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="@title"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="section|appendix">
  <xsl:call-template name="check-no-text-content"/>

  <xsl:if test="self::appendix">
    <xsl:call-template name="warning">
      <xsl:with-param name="msg">The "appendix" element is deprecated, use "section" inside "back" instead.</xsl:with-param>
    </xsl:call-template>
  </xsl:if>

  <xsl:variable name="sectionNumber">
    <xsl:choose>
      <xsl:when test="@myns:unnumbered"></xsl:when>
      <xsl:when test="ancestor::x:boilerplate"></xsl:when>
      <xsl:otherwise><xsl:call-template name="get-section-number" /></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
    
  <xsl:if test="not(ancestor::section) and not(ancestor::x:boilerplate) and not(@myns:notoclink)">
    <xsl:call-template name="insert-conditional-hrule"/>
  </xsl:if>
  
  <xsl:variable name="elemtype">
    <xsl:choose>
      <xsl:when test="count(ancestor::section) &lt;= 4">h<xsl:value-of select="1 + count(ancestor::section)"/></xsl:when>
      <xsl:otherwise>h6</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <!-- process irefs immediately following the section so that their anchor
  actually is the section heading -->
  <xsl:apply-templates select="iref[count(preceding-sibling::*[not(self::iref)])=0]"/>

  <xsl:element name="{$elemtype}">
    <xsl:if test="$sectionNumber!=''">
      <xsl:attribute name="id"><xsl:value-of select="$anchor-prefix"/>.section.<xsl:value-of select="$sectionNumber"/></xsl:attribute>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="$sectionNumber='1' or $sectionNumber='A'">
        <!-- pagebreak, this the first section -->
        <xsl:attribute name="class">np</xsl:attribute>
      </xsl:when>
      <xsl:when test="not(ancestor::section) and not(@myns:notoclink)">
        <xsl:call-template name="insert-conditional-pagebreak"/>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
    
    <xsl:call-template name="insertInsDelClass" />
        
    <xsl:if test="$sectionNumber!='' and not(contains($sectionNumber,'unnumbered-'))">
      <a href="#{$anchor-prefix}.section.{$sectionNumber}">
        <xsl:call-template name="emit-section-number">
          <xsl:with-param name="no" select="$sectionNumber"/>
        </xsl:call-template>
      </a>
      <xsl:text>&#0160;</xsl:text>
    </xsl:if>
    
    <!-- issue tracking? -->
    <xsl:if test="@ed:resolves">
      <xsl:call-template name="insert-issue-pointer"/>
    </xsl:if>
    
    <xsl:choose>
      <xsl:when test="@anchor">
        <xsl:call-template name="check-anchor"/>
        <a id="{@anchor}" href="#{@anchor}"><xsl:call-template name="insertTitle"/></a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="insertTitle"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:element>
  <!-- continue with all child elements but the irefs processed above -->
  <xsl:apply-templates select="*[not(self::iref)]|iref[count(preceding-sibling::*[not(self::iref)])!=0]" />
</xsl:template>

<xsl:template match="spanx[@style='emph' or not(@style)]">
  <em>
    <xsl:call-template name="copy-anchor"/>
    <xsl:apply-templates />
  </em>
</xsl:template>

<xsl:template match="spanx[@style='verb' or @style='vbare']">
  <samp>
    <xsl:call-template name="copy-anchor"/>
    <xsl:apply-templates />
  </samp>
</xsl:template>

<xsl:template match="spanx[@style='strong']">
  <strong>
    <xsl:call-template name="copy-anchor"/>
    <xsl:apply-templates />
  </strong>
</xsl:template>

<xsl:template name="insert-blank-lines">
  <xsl:param name="no"/>
  <xsl:choose>
    <xsl:when test="$no >= $xml2rfc-ext-vspace-pagebreak">
      <br/>
      <!-- done; this probably was an attempt to generate a pagebreak -->
    </xsl:when>
    <xsl:when test="$no &lt;= 0">
      <br/>
      <!-- done -->
    </xsl:when>
    <xsl:otherwise>
      <br/>
      <xsl:call-template name="insert-blank-lines">
        <xsl:with-param name="no" select="$no - 1"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="vspace[not(@blankLines)]">
  <br />
</xsl:template>

<xsl:template match="vspace">
  <xsl:call-template name="insert-blank-lines">
    <xsl:with-param name="no" select="@blankLines"/>
  </xsl:call-template>
</xsl:template>

<!-- keep the root for the case when we process XSLT-inline markup -->
<xsl:variable name="src" select="/" />

<xsl:template name="render-section-ref">
  <xsl:param name="from" />
  <xsl:param name="to" />

  <xsl:variable name="refname">
    <xsl:for-each select="$to">
      <xsl:call-template name="get-section-type">
        <xsl:with-param name="prec" select="$from/preceding-sibling::node()[1]" />
      </xsl:call-template>
    </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="refnum">
    <xsl:for-each select="$to">
      <xsl:call-template name="get-section-number" />
    </xsl:for-each>
  </xsl:variable>
  <xsl:attribute name="title">
    <xsl:value-of select="$to/@title" />
  </xsl:attribute>
  <xsl:choose>
    <xsl:when test="$from/@format='counter'">
      <xsl:value-of select="$refnum"/>
    </xsl:when>
    <xsl:when test="$from/@format='title'">
      <xsl:value-of select="$to/@title"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="normalize-space(concat($refname,'&#160;',$refnum))"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="xref[node()]">

  <xsl:variable name="target" select="@target" />
  <xsl:variable name="node" select="key('anchor-item',$target)" />
  <xsl:variable name="anchor"><xsl:value-of select="$anchor-prefix"/>.xref.<xsl:value-of select="@target"/>.<xsl:number level="any" count="xref[@target=$target]"/></xsl:variable>

  <xsl:choose>

    <!-- x:fmt='none': do not generate any links -->
    <xsl:when test="@x:fmt='none'">
      <xsl:choose>
        <xsl:when test="$node/self::reference">
          <cite title="{normalize-space($node/front/title)}">
            <xsl:if test="$xml2rfc-ext-include-references-in-index='yes'">
              <xsl:attribute name="id"><xsl:value-of select="$anchor"/></xsl:attribute>
            </xsl:if>
            <!-- insert id when a backlink to this xref is needed in the index -->
            <xsl:if test="//iref[@x:for-anchor=$target] | //iref[@x:for-anchor='' and ../@anchor=$target]">
              <xsl:attribute name="id"><xsl:value-of select="$anchor"/></xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
          </cite>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
  
    <!-- Other x:fmt values than "none": unsupported -->
    <xsl:when test="@x:fmt and @x:fmt!='none'">
      <xsl:call-template name="error">
        <xsl:with-param name="msg" select="concat('unknown xref/@x:fmt extension: ',@x:fmt)"/>
      </xsl:call-template>
    </xsl:when>
    
    <!-- Section links -->
    <xsl:when test="$node/self::section or $node/self::appendix">
      <xsl:choose>
        <xsl:when test="@format='none'">
          <a href="#{@target}">
            <!-- insert id when a backlink to this xref is needed in the index -->
            <xsl:if test="//iref[@x:for-anchor=$target] | //iref[@x:for-anchor='' and ../@anchor=$target]">
              <xsl:attribute name="id"><xsl:value-of select="$anchor"/></xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
          </a>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
          <xsl:text> (</xsl:text>
          <a href="#{@target}">
            <!-- insert id when a backlink to this xref is needed in the index -->
            <xsl:if test="//iref[@x:for-anchor=$target] | //iref[@x:for-anchor='' and ../@anchor=$target]">
              <xsl:attribute name="id"><xsl:value-of select="$anchor"/></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="render-section-ref">
              <xsl:with-param name="from" select="."/>
              <xsl:with-param name="to" select="$node"/>
            </xsl:call-template>
          </a>
          <xsl:text>)</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>

    <xsl:otherwise>
      <!-- check normative/informative -->
      <xsl:variable name="t-is-normative" select="ancestor-or-self::*[@x:nrm][1]"/>
      <xsl:variable name="is-normative" select="$t-is-normative/@x:nrm='true'"/>
      <xsl:if test="count($node)=1 and $is-normative">
        <xsl:variable name="t-r-is-normative" select="$node/ancestor-or-self::*[@x:nrm][1]"/>
        <xsl:variable name="r-is-normative" select="$t-r-is-normative/@x:nrm='true'"/>
        <xsl:if test="not($r-is-normative)">
          <xsl:call-template name="warning">
            <xsl:with-param name="msg" select="concat('Potentially normative reference to ',@target,' not referenced normatively')"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:if>
      
      <a href="#{$target}">
        <xsl:if test="@format='none'">
          <xsl:if test="$xml2rfc-ext-include-references-in-index='yes'">
            <xsl:attribute name="id"><xsl:value-of select="$anchor"/></xsl:attribute>
          </xsl:if>
        </xsl:if>
        <xsl:apply-templates />
      </a>
      <xsl:if test="not(@format='none')">
        <xsl:for-each select="$src/rfc/back/references//reference[@anchor=$target]">
          <xsl:text> </xsl:text>
          <cite title="{normalize-space(front/title)}">
            <xsl:if test="$xml2rfc-ext-include-references-in-index='yes'">
              <xsl:attribute name="id"><xsl:value-of select="$anchor"/></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="referencename">
               <xsl:with-param name="node" select="." />
            </xsl:call-template>
          </cite>
        </xsl:for-each>
      </xsl:if>
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>
               
<xsl:key name="iref-xanch" match="iref[@x:for-anchor]" use="@x:for-anchor"/>            
               
<xsl:template match="xref[not(node())]">

  <xsl:variable name="xref" select="."/>
  <xsl:variable name="anchor"><xsl:value-of select="$anchor-prefix"/>.xref.<xsl:value-of select="$xref/@target"/>.<xsl:number level="any" count="xref[@target=$xref/@target]"/></xsl:variable>

  <!-- ensure we have the right context, this <xref> may be processed from within the boilerplate -->
  <xsl:for-each select="$src">

    <xsl:variable name="node" select="key('anchor-item',$xref/@target)" />
    <xsl:if test="count($node)=0 and not($node/ancestor::ed:del)">
      <xsl:for-each select="$xref">
        <xsl:call-template name="error">
          <xsl:with-param name="msg" select="concat('Undefined target: ',$xref/@target)"/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:if>

    <xsl:choose>
    
      <!-- Section links -->
      <xsl:when test="$node/self::section or $node/self::appendix">
        <a href="#{$xref/@target}">
          <!-- insert id when a backlink to this xref is needed in the index -->
          <xsl:if test="key('iref-xanch',$xref/@target) | key('iref-xanch','')[../@anchor=$xref/@target]">
            <xsl:attribute name="id"><xsl:value-of select="$anchor"/></xsl:attribute>
          </xsl:if>
          <xsl:call-template name="render-section-ref">
            <xsl:with-param name="from" select="$xref"/>
            <xsl:with-param name="to" select="$node"/>
          </xsl:call-template>
        </a>
      </xsl:when>
  
      <!-- Figure links -->
      <xsl:when test="$node/self::figure">
        <a href="#{$xref/@target}">
          <xsl:variable name="figcnt">
            <xsl:for-each select="$node">
              <xsl:number level="any" count="figure[(@title!='' or @anchor!='') and not(@suppress-title='true')]" />
            </xsl:for-each>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="$xref/@format='counter'">
              <xsl:value-of select="$figcnt" />
            </xsl:when>
            <xsl:when test="$xref/@format='title'">
              <xsl:value-of select="$node/@title" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="normalize-space(concat('Figure&#160;',$figcnt))"/>
            </xsl:otherwise>
          </xsl:choose>
        </a>
      </xsl:when>
      
      <!-- Table links -->
      <xsl:when test="$node/self::texttable">
        <a href="#{$xref/@target}">
          <xsl:variable name="tabcnt">
            <xsl:for-each select="$node">
              <xsl:number level="any" count="texttable[(@title!='' or @anchor!='') and not(@suppress-title='true')]" />
            </xsl:for-each>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="$xref/@format='counter'">
              <xsl:value-of select="$tabcnt" />
            </xsl:when>
            <xsl:when test="$xref/@format='title'">
              <xsl:value-of select="$node/@title" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="normalize-space(concat('Table&#160;',$tabcnt))"/>
            </xsl:otherwise>
          </xsl:choose>
        </a>
      </xsl:when>
      
      <!-- Paragraph links -->
      <xsl:when test="$node/self::t">
        <a href="#{$xref/@target}">
          <xsl:variable name="tcnt">
            <xsl:for-each select="$node">
              <xsl:call-template name="get-paragraph-number" />
            </xsl:for-each>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="$xref/@format='counter'">
              <xsl:value-of select="$tcnt" />
            </xsl:when>
            <xsl:when test="$xref/@format='title'">
              <xsl:value-of select="$node/@title" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="normalize-space(concat('Paragraph&#160;',substring-after($tcnt,'p.')))"/>
            </xsl:otherwise>
          </xsl:choose>
        </a>
      </xsl:when>
  
      <!-- Comment links -->
      <xsl:when test="$node/self::cref">
        <a href="#{$xref/@target}">
          <xsl:variable name="name">
            <xsl:for-each select="$node">
              <xsl:call-template name="get-comment-name" />
            </xsl:for-each>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="$xref/@format='counter'">
              <xsl:value-of select="$name" />
            </xsl:when>
            <xsl:when test="$xref/@format='title'">
              <xsl:value-of select="$node/@title" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="normalize-space(concat('Comment&#160;',$name))"/>
            </xsl:otherwise>
          </xsl:choose>
        </a>
      </xsl:when>
  
      <!-- Reference links -->
      <xsl:when test="$node/self::reference">
  
        <!-- check normative/informative -->
        <xsl:variable name="t-is-normative" select="$xref/ancestor-or-self::*[@x:nrm][1]"/>
        <xsl:variable name="is-normative" select="$t-is-normative/@x:nrm='true'"/>
        <xsl:if test="count($node)=1 and $is-normative">
          <xsl:variable name="t-r-is-normative" select="$node/ancestor-or-self::*[@x:nrm][1]"/>
          <xsl:variable name="r-is-normative" select="$t-r-is-normative/@x:nrm='true'"/>
          <xsl:if test="not($r-is-normative)">
            <xsl:for-each select="$xref">
              <xsl:call-template name="warning">
                <xsl:with-param name="msg" select="concat('Potentially normative reference to ',$xref/@target,' not referenced normatively')"/>
              </xsl:call-template>
            </xsl:for-each>
          </xsl:if>
        </xsl:if>
      
        <xsl:variable name="href">
          <xsl:call-template name="computed-target">
            <xsl:with-param name="bib" select="$node"/>
            <xsl:with-param name="ref" select="$xref"/>
          </xsl:call-template>
        </xsl:variable>
        
        <xsl:variable name="sec">
          <xsl:choose>
            <xsl:when test="starts-with($xref/@x:rel,'#') and not($xref/@x:sec)">
              <xsl:variable name="extdoc" select="document($node/x:source/@href)"/>
              <xsl:variable name="nodes" select="$extdoc//*[@anchor=substring-after($xref/@x:rel,'#')]"/>
              <xsl:if test="not($nodes)">
                <xsl:call-template name="error">
                  <xsl:with-param name="msg">Anchor '<xsl:value-of select="substring-after($xref/@x:rel,'#')"/>' in <xsl:value-of select="$node/@anchor"/> not found in source file '<xsl:value-of select="$node/x:source/@href"/>'.</xsl:with-param>
                </xsl:call-template>
              </xsl:if>
              <xsl:for-each select="$nodes">
                <xsl:call-template name="get-section-number"/>
              </xsl:for-each>
            </xsl:when>
            <xsl:when test="$xref/@x:rel and not(starts-with($xref/@x:rel,'#')) and not($xref/@x:sec)">
              <xsl:call-template name="error">
                <xsl:with-param name="msg">x:rel attribute '<xsl:value-of select="$xref/@x:rel"/>' in reference to <xsl:value-of select="$node/@anchor"/> is expected to start with '#'.</xsl:with-param>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$xref/@x:sec"/>
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
            <xsl:when test="$xref/@x:fmt!=''"><xsl:value-of select="$xref/@x:fmt"/></xsl:when>
            <xsl:when test="$xref/ancestor::artwork">,</xsl:when>
            <xsl:otherwise>of</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
  
        <xsl:variable name="title">
          <xsl:choose>
            <xsl:when test="starts-with($xref/@x:rel,'#') and not($xref/@x:sec) and $node/x:source/@href">
              <xsl:variable name="extdoc" select="document($node/x:source/@href)"/>
              <xsl:variable name="nodes" select="$extdoc//*[@anchor=substring-after($xref//@x:rel,'#')]"/>
              <xsl:if test="not($nodes)">
                <xsl:call-template name="error">
                  <xsl:with-param name="msg">Anchor '<xsl:value-of select="substring-after($xref//@x:rel,'#')"/>' not found in <xsl:value-of select="$node/x:source/@href"/>.</xsl:with-param>
                </xsl:call-template>
              </xsl:if>
              <xsl:for-each select="$nodes">
                <xsl:value-of select="@title"/>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise />
          </xsl:choose>
        </xsl:variable>
  
        <!--
        Formats:
        
          ()      [XXXX] (Section SS)
          ,       [XXXX], Section SS
          of      Section SS of [XXXX]
          sec     Section SS
          number  SS
        -->
        
        <xsl:if test="$fmt and not($fmt='()' or $fmt=',' or $fmt='of' or $fmt='sec' or $fmt='anchor' or $fmt='number')">
          <xsl:call-template name="error">
            <xsl:with-param name="msg" select="concat('unknown xref/@x:fmt extension: ',$fmt)"/>
          </xsl:call-template>
        </xsl:if>
  
        <xsl:if test="$sec!=''">
                
          <xsl:choose>
            <xsl:when test="$fmt='of' or $fmt='sec'">
              <xsl:choose>
                <xsl:when test="$href!=''">
                  <a href="{$href}">
                    <xsl:if test="$title!=''">
                      <xsl:attribute name="title"><xsl:value-of select="$title"/></xsl:attribute>
                    </xsl:if>
                    <xsl:if test="$fmt='sec' and $xml2rfc-ext-include-references-in-index='yes'">
                      <xsl:attribute name="id"><xsl:value-of select="$anchor"/></xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="$secterm"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="$sec"/>
                  </a>
                </xsl:when>
                <xsl:otherwise><xsl:value-of select="$secterm"/><xsl:text> </xsl:text><xsl:value-of select="$sec"/></xsl:otherwise>
              </xsl:choose>
              <xsl:if test="$fmt='of'">
                <xsl:text> of </xsl:text>
              </xsl:if>
            </xsl:when>
            <xsl:when test="$fmt='number'">
              <xsl:choose>
                <xsl:when test="$href!=''">
                  <a href="{$href}">
                    <xsl:if test="$title!=''">
                      <xsl:attribute name="title"><xsl:value-of select="$title"/></xsl:attribute>
                    </xsl:if>
                    <xsl:if test="$xml2rfc-ext-include-references-in-index='yes'">
                      <xsl:attribute name="id"><xsl:value-of select="$anchor"/></xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="$sec"/>
                  </a>
                </xsl:when>
                <xsl:otherwise><xsl:value-of select="$sec"/></xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise />
          </xsl:choose>
        </xsl:if>
  
        <xsl:if test="$sec='' or ($fmt!='sec' and $fmt!='number')">
          <a href="#{$xref/@target}">
            <xsl:if test="$xml2rfc-ext-include-references-in-index='yes'">
              <xsl:attribute name="id"><xsl:value-of select="$anchor"/></xsl:attribute>
            </xsl:if>
            <cite title="{normalize-space($node/front/title)}">
              <xsl:variable name="val">
                <xsl:call-template name="referencename">
                  <xsl:with-param name="node" select="$node" />
                </xsl:call-template>
              </xsl:variable>
              <xsl:choose>
                <xsl:when test="$fmt='anchor'">
                  <!-- remove brackets -->
                  <xsl:value-of select="substring($val,2,string-length($val)-2)"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$val"/>
                </xsl:otherwise>
              </xsl:choose>
            </cite>
          </a>
        </xsl:if>
        
        <xsl:if test="$sec!=''">
          <xsl:choose>
            <xsl:when test="$fmt='()'">
              <xsl:text> (</xsl:text>
              <xsl:choose>
                <xsl:when test="$href!=''">
                  <a href="{$href}"><xsl:value-of select="$secterm"/><xsl:text> </xsl:text><xsl:value-of select="$sec"/></a>
                </xsl:when>
                <xsl:otherwise><xsl:value-of select="$secterm"/><xsl:text> </xsl:text><xsl:value-of select="$sec"/></xsl:otherwise>
              </xsl:choose>
              <xsl:text>)</xsl:text>
            </xsl:when>
            <xsl:when test="$fmt=','">
              <xsl:text>, </xsl:text>
              <xsl:choose>
                <xsl:when test="$href!=''">
                  <a href="{$href}">
                    <xsl:if test="$title!=''">
                      <xsl:attribute name="title"><xsl:value-of select="$title"/></xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="$secterm"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="$sec"/>
                  </a>
                </xsl:when>
                <xsl:otherwise><xsl:value-of select="$secterm"/><xsl:text> </xsl:text><xsl:value-of select="$sec"/></xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise/>
          </xsl:choose>
        </xsl:if>
      </xsl:when>
      
      <xsl:otherwise>
        <xsl:if test="$node">
          <xsl:call-template name="error">
            <xsl:with-param name="msg" select="concat('xref to unknown element: ',name($node))"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</xsl:template>


<!-- mark unmatched elements red -->

<xsl:template match="*">
  <xsl:call-template name="error">
    <xsl:with-param name="inline" select="'no'"/>
    <xsl:with-param name="msg">no XSLT template for element '<xsl:value-of select="name()"/>'</xsl:with-param>
  </xsl:call-template>
  <tt class="error">&lt;<xsl:value-of select="name()" />&gt;</tt>
  <xsl:copy><xsl:apply-templates select="node()|@*" /></xsl:copy>
  <tt class="error">&lt;/<xsl:value-of select="name()" />&gt;</tt>
</xsl:template>

<xsl:template match="/">
  <xsl:apply-templates select="*" mode="validate"/>
  <xsl:apply-templates select="*" />
</xsl:template>

<!-- utility templates -->

<xsl:template name="collectLeftHeaderColumn">
  <!-- default case -->
  <xsl:if test="$xml2rfc-private=''">
    <xsl:choose>
      <xsl:when test="/rfc/@number and $header-format='2010' and $submissionType='independent'">
        <myns:item>Independent Submission</myns:item>
      </xsl:when>
      <xsl:when test="/rfc/@number and $header-format='2010' and $submissionType='IETF'">
        <myns:item>Internet Engineering Task Force (IETF)</myns:item>
      </xsl:when>
      <xsl:when test="/rfc/@number and $header-format='2010' and $submissionType='IRTF'">
        <myns:item>Internet Research Task Force (IRTF)</myns:item>
      </xsl:when>
      <xsl:when test="/rfc/@number and $header-format='2010' and $submissionType='IAB'">
        <myns:item>Internet Architecture Board (IAB)</myns:item>
      </xsl:when>
      <xsl:when test="/rfc/front/workgroup and (not(/rfc/@number) or /rfc/@number='')">
        <xsl:if test="not(starts-with(/rfc/@docName,'draft-ietf-')) and $submissionType='IETF'">
          <xsl:call-template name="info">
            <xsl:with-param name="inline" select="'no'"/>
            <xsl:with-param name="msg">The /rfc/front/workgroup should only be used for Working Group drafts</xsl:with-param>
          </xsl:call-template>
        </xsl:if>
        <xsl:for-each select="/rfc/front/workgroup">
          <myns:item><xsl:value-of select="."/></myns:item>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="starts-with(/rfc/@docName,'draft-ietf-') and not(/rfc/front/workgroup)">
          <xsl:call-template name="info">
            <xsl:with-param name="inline" select="'no'"/>
            <xsl:with-param name="msg">WG submissions should include a /rfc/front/workgroup element</xsl:with-param>
          </xsl:call-template>
        </xsl:if>
        <myns:item>Network Working Group</myns:item>
      </xsl:otherwise>
    </xsl:choose>
    <myns:item>
       <xsl:choose>
        <xsl:when test="/rfc/@ipr and not(/rfc/@number)">Internet-Draft</xsl:when>
        <xsl:otherwise>Request for Comments: <xsl:value-of select="/rfc/@number"/></xsl:otherwise>
      </xsl:choose>
    </myns:item>
    <xsl:if test="/rfc/@obsoletes!=''">
      <myns:item>
        <xsl:text>Obsoletes: </xsl:text>
        <xsl:call-template name="rfclist">
          <xsl:with-param name="list" select="normalize-space(/rfc/@obsoletes)" />
        </xsl:call-template>
        <xsl:if test="not(/rfc/@number)"> (if approved)</xsl:if>
      </myns:item>
    </xsl:if>
    <xsl:if test="/rfc/@seriesNo">
       <myns:item>
        <xsl:choose>
          <xsl:when test="/rfc/@category='bcp'">BCP: <xsl:value-of select="/rfc/@seriesNo" /></xsl:when>
          <xsl:when test="/rfc/@category='info'">FYI: <xsl:value-of select="/rfc/@seriesNo" /></xsl:when>
          <xsl:when test="/rfc/@category='std'">STD: <xsl:value-of select="/rfc/@seriesNo" /></xsl:when>
          <xsl:otherwise><xsl:value-of select="concat(/rfc/@category,': ',/rfc/@seriesNo)" /></xsl:otherwise>
        </xsl:choose>
      </myns:item>
    </xsl:if>
    <xsl:if test="/rfc/@updates!=''">
      <myns:item>
        <xsl:text>Updates: </xsl:text>
          <xsl:call-template name="rfclist">
             <xsl:with-param name="list" select="normalize-space(/rfc/@updates)" />
          </xsl:call-template>
          <xsl:if test="not(/rfc/@number)"> (if approved)</xsl:if>
      </myns:item>
    </xsl:if>
    <myns:item>
      <xsl:choose>
        <xsl:when test="/rfc/@number">
          <xsl:text>Category: </xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>Intended status: </xsl:text>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:call-template name="get-category-long" />
    </myns:item>
    <xsl:if test="/rfc/@ipr and not(/rfc/@number)">
       <myns:item>Expires: <xsl:call-template name="expirydate" /></myns:item>
    </xsl:if>
  </xsl:if>
    
  <!-- private case -->
  <xsl:if test="$xml2rfc-private!=''">
    <myns:item><xsl:value-of select="$xml2rfc-private" /></myns:item>
  </xsl:if>
  
  <xsl:if test="$header-format='2010' and /rfc/@number">
    <myns:item>ISSN: 2070-1721</myns:item>
  </xsl:if>
</xsl:template>

<xsl:template name="collectRightHeaderColumn">
  <xsl:for-each select="author">
    <xsl:variable name="initials">
      <xsl:call-template name="format-initials"/>
    </xsl:variable>
    <xsl:variable name="truncated-initials" select="concat(substring-before($initials,'.'),'.')"/>
    <xsl:if test="@surname">
      <myns:item>
        <xsl:value-of select="concat($truncated-initials,' ',@surname)" />
        <xsl:if test="@role">
          <xsl:choose>
            <xsl:when test="@role='editor'">
              <xsl:text>, Editor</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>, </xsl:text><xsl:value-of select="@role" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </myns:item>
    </xsl:if>
    <xsl:variable name="org">
      <xsl:choose>
        <xsl:when test="organization/@abbrev"><xsl:value-of select="organization/@abbrev" /></xsl:when>
        <xsl:otherwise><xsl:value-of select="organization" /></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="orgOfFollowing">
      <xsl:choose>
        <xsl:when test="following-sibling::*[1]/organization/@abbrev"><xsl:value-of select="following-sibling::*[1]/organization/@abbrev" /></xsl:when>
        <xsl:otherwise><xsl:value-of select="following-sibling::*/organization" /></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$org != $orgOfFollowing and $org != ''">
      <myns:item><xsl:value-of select="$org" /></myns:item>
    </xsl:if>
  </xsl:for-each>
  <myns:item>
    <xsl:if test="$xml2rfc-ext-pub-month!=''">
      <xsl:value-of select="$xml2rfc-ext-pub-month" />
      <xsl:if test="$xml2rfc-ext-pub-day!='' and /rfc/@ipr and not(/rfc/@number)">
        <xsl:text> </xsl:text>
        <xsl:value-of select="number($xml2rfc-ext-pub-day)" />
        <xsl:text>,</xsl:text>
      </xsl:if>
    </xsl:if>
    <xsl:if test="$xml2rfc-ext-pub-day='' and /rfc/@docName and not(substring(/rfc/@docName, string-length(/rfc/@docName) - string-length('-latest') + 1) = '-latest')">
      <xsl:call-template name="warning">
        <xsl:with-param name="msg" select="concat('/rfc/front/date/@day appears to be missing for a historic draft dated ', $pub-yearmonth)"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:value-of select="concat(' ',$xml2rfc-ext-pub-year)" />
  </myns:item>
</xsl:template>


<xsl:template name="emitheader">
  <xsl:param name="lc" />
  <xsl:param name="rc" />

  <tbody>
    <xsl:for-each select="$lc/myns:item | $rc/myns:item">
      <xsl:variable name="pos" select="position()" />
      <xsl:if test="$pos &lt; count($lc/myns:item) + 1 or $pos &lt; count($rc/myns:item) + 1"> 
        <tr>
          <td class="left"><xsl:call-template name="copynodes"><xsl:with-param name="nodes" select="$lc/myns:item[$pos]/node()" /></xsl:call-template></td>
          <td class="right"><xsl:call-template name="copynodes"><xsl:with-param name="nodes" select="$rc/myns:item[$pos]/node()" /></xsl:call-template></td>
        </tr>
      </xsl:if>
    </xsl:for-each>
  </tbody>
</xsl:template>

<!-- convenience template that avoids copying namespace nodes we don't want -->
<xsl:template name="copynodes">
  <xsl:param name="nodes" />
  <xsl:for-each select="$nodes">
    <xsl:choose>
      <xsl:when test="namespace-uri()='http://www.w3.org/1999/xhtml'">
        <xsl:element name="{name()}" namespace="{namespace-uri()}">
          <xsl:copy-of select="@*|node()" />
        </xsl:element>
      </xsl:when>
      <xsl:when test="self::*">
        <xsl:element name="{name()}">
          <xsl:copy-of select="@*|node()" />
        </xsl:element>
      </xsl:when>
      <!-- workaround for opera, remove when Opera > 9.0.x comes out -->
      <xsl:when test="self::text()">
        <xsl:value-of select="."/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="." />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</xsl:template>


<xsl:template name="expirydate">
  <xsl:param name="in-prose"/>
  <xsl:choose>
    <xsl:when test="number($xml2rfc-ext-pub-day) >= 1">
      <xsl:if test="$in-prose">
        <xsl:text>on </xsl:text>
      </xsl:if>
      <xsl:call-template name="normalize-date">
        <xsl:with-param name="year" select="$xml2rfc-ext-pub-year"/>
        <xsl:with-param name="month" select="$pub-month-numeric"/>
        <xsl:with-param name="day" select="$xml2rfc-ext-pub-day + 185"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:if test="$in-prose">
        <xsl:text>in </xsl:text>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="$xml2rfc-ext-pub-month='January'">July <xsl:value-of select="$xml2rfc-ext-pub-year" /></xsl:when>
        <xsl:when test="$xml2rfc-ext-pub-month='February'">August <xsl:value-of select="$xml2rfc-ext-pub-year" /></xsl:when>
        <xsl:when test="$xml2rfc-ext-pub-month='March'">September <xsl:value-of select="$xml2rfc-ext-pub-year" /></xsl:when>
        <xsl:when test="$xml2rfc-ext-pub-month='April'">October <xsl:value-of select="$xml2rfc-ext-pub-year" /></xsl:when>
        <xsl:when test="$xml2rfc-ext-pub-month='May'">November <xsl:value-of select="$xml2rfc-ext-pub-year" /></xsl:when>
        <xsl:when test="$xml2rfc-ext-pub-month='June'">December <xsl:value-of select="$xml2rfc-ext-pub-year" /></xsl:when>
        <xsl:when test="$xml2rfc-ext-pub-month='July'">January <xsl:value-of select="$xml2rfc-ext-pub-year + 1" /></xsl:when>
        <xsl:when test="$xml2rfc-ext-pub-month='August'">February <xsl:value-of select="$xml2rfc-ext-pub-year + 1" /></xsl:when>
        <xsl:when test="$xml2rfc-ext-pub-month='September'">March <xsl:value-of select="$xml2rfc-ext-pub-year + 1" /></xsl:when>
        <xsl:when test="$xml2rfc-ext-pub-month='October'">April <xsl:value-of select="$xml2rfc-ext-pub-year + 1" /></xsl:when>
        <xsl:when test="$xml2rfc-ext-pub-month='November'">May <xsl:value-of select="$xml2rfc-ext-pub-year + 1" /></xsl:when>
        <xsl:when test="$xml2rfc-ext-pub-month='December'">June <xsl:value-of select="$xml2rfc-ext-pub-year + 1" /></xsl:when>
        <xsl:otherwise>WRONG SYNTAX FOR MONTH</xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="normalize-date">
  <xsl:param name="year"/>
  <xsl:param name="month"/>
  <xsl:param name="day"/>

  <xsl:variable name="isleap" select="(($year mod 4) = 0 and ($year mod 100 != 0)) or ($year mod 400) = 0" />

  <!--<xsl:message>
    <xsl:value-of select="concat($year,' ',$month,' ',$day)"/>
  </xsl:message>-->
  
  <xsl:variable name="dim">
    <xsl:choose>
      <xsl:when test="$month=1 or $month=3 or $month=5 or $month=7 or $month=8 or $month=10 or $month=12">31</xsl:when>
      <xsl:when test="$month=2 and $isleap">29</xsl:when>
      <xsl:when test="$month=2 and not($isleap)">28</xsl:when>
      <xsl:otherwise>30</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:choose>
    <xsl:when test="$day > $dim and $month=12">
      <xsl:call-template name="normalize-date">
        <xsl:with-param name="year" select="$year + 1"/>
        <xsl:with-param name="month" select="1"/>
        <xsl:with-param name="day" select="$day - $dim"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="$day > $dim">
      <xsl:call-template name="normalize-date">
        <xsl:with-param name="year" select="$year"/>
        <xsl:with-param name="month" select="$month + 1"/>
        <xsl:with-param name="day" select="$day - $dim"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="get-month-as-name">
        <xsl:with-param name="month" select="$month"/>
      </xsl:call-template>
      <xsl:value-of select="concat(' ',$day,', ',$year)"/>
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>
  
<xsl:template name="get-month-as-num">
  <xsl:param name="month" />
  <xsl:choose>
    <xsl:when test="$month='January'">01</xsl:when>
    <xsl:when test="$month='February'">02</xsl:when>
    <xsl:when test="$month='March'">03</xsl:when>
    <xsl:when test="$month='April'">04</xsl:when>
    <xsl:when test="$month='May'">05</xsl:when>
    <xsl:when test="$month='June'">06</xsl:when>
    <xsl:when test="$month='July'">07</xsl:when>
    <xsl:when test="$month='August'">08</xsl:when>
    <xsl:when test="$month='September'">09</xsl:when>
    <xsl:when test="$month='October'">10</xsl:when>
    <xsl:when test="$month='November'">11</xsl:when>
    <xsl:when test="$month='December'">12</xsl:when>
    <xsl:otherwise>WRONG SYNTAX FOR MONTH</xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="get-month-as-name">
  <xsl:param name="month"/>
  <xsl:choose>
    <xsl:when test="$month=1">January</xsl:when>
    <xsl:when test="$month=2">February</xsl:when>
    <xsl:when test="$month=3">March</xsl:when>
    <xsl:when test="$month=4">April</xsl:when>
    <xsl:when test="$month=5">May</xsl:when>
    <xsl:when test="$month=6">June</xsl:when>
    <xsl:when test="$month=7">July</xsl:when>
    <xsl:when test="$month=8">August</xsl:when>
    <xsl:when test="$month=9">September</xsl:when>
    <xsl:when test="$month=10">October</xsl:when>
    <xsl:when test="$month=11">November</xsl:when>
    <xsl:when test="$month=12">December</xsl:when>
    <xsl:otherwise>WRONG SYNTAX FOR MONTH</xsl:otherwise>
   </xsl:choose>
</xsl:template>

<!-- produce back section with author information -->
<xsl:template name="get-authors-section-title">
  <xsl:choose>
    <xsl:when test="count(/rfc/front/author)=1">Author's Address</xsl:when>
    <xsl:otherwise>Authors' Addresses</xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="get-authors-section-number">
  <xsl:if test="/*/x:assign-section-number[@builtin-target='authors']">
    <xsl:value-of select="/*/x:assign-section-number[@builtin-target='authors']/@number"/>
  </xsl:if>
</xsl:template>

<xsl:template name="insertAuthors">

  <xsl:variable name="number">
    <xsl:call-template name="get-authors-section-number"/>
  </xsl:variable>
    
  <xsl:if test="$number!='suppress'">
    <xsl:call-template name="insert-conditional-hrule"/>
    
    <div class="avoidbreak">
      <h1 id="{$anchor-prefix}.authors">
        <xsl:call-template name="insert-conditional-pagebreak"/>
        <xsl:if test="$number != ''">
          <a href="#{$anchor-prefix}.section.{$number}" id="{$anchor-prefix}.section.{$number}"><xsl:value-of select="$number"/>.</a>
          <xsl:text> </xsl:text>
        </xsl:if>
        <a href="#{$anchor-prefix}.authors"><xsl:call-template name="get-authors-section-title"/></a>
      </h1>
    
      <xsl:apply-templates select="/rfc/front/author" />
    </div>
  </xsl:if>
</xsl:template>



<!-- insert copyright statement -->

<xsl:template name="insertCopyright" myns:namespaceless-elements="xml2rfc">

  <xsl:if test="not($no-copylong)">
    <section title="Full Copyright Statement" anchor="{$anchor-prefix}.copyright" myns:unnumbered="unnumbered" myns:notoclink="notoclink">
      <xsl:choose>
        <xsl:when test="$ipr-rfc3667">
          <t>
            <xsl:choose>
              <xsl:when test="$ipr-rfc4748">
                Copyright &#169; The IETF Trust (<xsl:value-of select="$xml2rfc-ext-pub-year" />).
              </xsl:when>
              <xsl:otherwise>
                Copyright &#169; The Internet Society (<xsl:value-of select="$xml2rfc-ext-pub-year" />).
              </xsl:otherwise>
            </xsl:choose>
          </t>
          <t>
            This document is subject to the rights, licenses and restrictions
            contained in BCP 78<xsl:if test="$submissionType='independent'"> and at <eref target="http://www.rfc-editor.org/copyright.html">http://www.rfc-editor.org/copyright.html</eref></xsl:if>, and except as set forth therein, the authors
            retain all their rights.
          </t>
          <t>
            This document and the information contained herein are provided
            on an &#8220;AS IS&#8221; basis and THE CONTRIBUTOR,
            THE ORGANIZATION HE/SHE REPRESENTS OR IS SPONSORED BY (IF ANY),
            THE INTERNET SOCIETY<xsl:if test="$ipr-rfc4748">, THE IETF TRUST</xsl:if>
            AND THE INTERNET ENGINEERING TASK FORCE DISCLAIM ALL WARRANTIES,
            EXPRESS OR IMPLIED,
            INCLUDING BUT NOT LIMITED TO ANY WARRANTY THAT THE USE OF THE
            INFORMATION HEREIN WILL NOT INFRINGE ANY RIGHTS OR ANY IMPLIED
            WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.
          </t>
        </xsl:when>
        <xsl:otherwise>
          <!-- <http://tools.ietf.org/html/rfc2026#section-10.4> -->
          <t>
            Copyright &#169; The Internet Society (<xsl:value-of select="$xml2rfc-ext-pub-year" />). All Rights Reserved.
          </t>
          <t>
            This document and translations of it may be copied and furnished to
            others, and derivative works that comment on or otherwise explain it
            or assist in its implementation may be prepared, copied, published and
            distributed, in whole or in part, without restriction of any kind,
            provided that the above copyright notice and this paragraph are
            included on all such copies and derivative works. However, this
            document itself may not be modified in any way, such as by removing
            the copyright notice or references to the Internet Society or other
            Internet organizations, except as needed for the purpose of
            developing Internet standards in which case the procedures for
            copyrights defined in the Internet Standards process must be
            followed, or as required to translate it into languages other than
            English.
          </t>
          <t>
            The limited permissions granted above are perpetual and will not be
            revoked by the Internet Society or its successors or assigns.
          </t>
          <t>
            This document and the information contained herein is provided on an
            &#8220;AS IS&#8221; basis and THE INTERNET SOCIETY AND THE INTERNET ENGINEERING
            TASK FORCE DISCLAIMS ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING
            BUT NOT LIMITED TO ANY WARRANTY THAT THE USE OF THE INFORMATION
            HEREIN WILL NOT INFRINGE ANY RIGHTS OR ANY IMPLIED WARRANTIES OF
            MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.
          </t>
        </xsl:otherwise>
      </xsl:choose>
    </section>
    
    <section title="Intellectual Property" anchor="{$anchor-prefix}.ipr" myns:unnumbered="unnumbered">
      <xsl:choose>
        <xsl:when test="$ipr-rfc3667">
          <t>
            The IETF takes no position regarding the validity or scope of any
            Intellectual Property Rights or other rights that might be claimed to
            pertain to the implementation or use of the technology described in
            this document or the extent to which any license under such rights
            might or might not be available; nor does it represent that it has
            made any independent effort to identify any such rights.  Information
            on the procedures with respect to rights in RFC documents
            can be found in BCP 78 and BCP 79.
          </t>       
          <t>
            Copies of IPR disclosures made to the IETF Secretariat and any
            assurances of licenses to be made available, or the result of an
            attempt made to obtain a general license or permission for the use
            of such proprietary rights by implementers or users of this
            specification can be obtained from the IETF on-line IPR repository 
            at <eref target="http://www.ietf.org/ipr">http://www.ietf.org/ipr</eref>.
          </t>       
          <t>
            The IETF invites any interested party to bring to its attention any
            copyrights, patents or patent applications, or other proprietary
            rights that may cover technology that may be required to implement
            this standard. Please address the information to the IETF at
            <eref target="mailto:ietf-ipr@ietf.org">ietf-ipr@ietf.org</eref>.
          </t>       
        </xsl:when>
        <xsl:otherwise>
          <t>
            The IETF takes no position regarding the validity or scope of
            any intellectual property or other rights that might be claimed
            to  pertain to the implementation or use of the technology
            described in this document or the extent to which any license
            under such rights might or might not be available; neither does
            it represent that it has made any effort to identify any such
            rights. Information on the IETF's procedures with respect to
            rights in standards-track and standards-related documentation
            can be found in BCP-11. Copies of claims of rights made
            available for publication and any assurances of licenses to
            be made available, or the result of an attempt made
            to obtain a general license or permission for the use of such
            proprietary rights by implementors or users of this
            specification can be obtained from the IETF Secretariat.
          </t>
          <t>
            The IETF invites any interested party to bring to its
            attention any copyrights, patents or patent applications, or
            other proprietary rights which may cover technology that may be
            required to practice this standard. Please address the
            information to the IETF Executive Director.
          </t>
          <xsl:if test="$xml2rfc-iprnotified='yes'">
            <t>
              The IETF has been notified of intellectual property rights
              claimed in regard to some or all of the specification contained
              in this document. For more information consult the online list
              of claimed rights.
            </t>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </section>
    
    <xsl:choose>
      <xsl:when test="$no-funding"/>
      <xsl:when test="$funding1 and /rfc/@number">
        <section myns:unnumbered="unnumbered" myns:notoclink="notoclink">
          <xsl:attribute name="title">
            <xsl:choose>
              <xsl:when test="$xml2rfc-rfcedstyle='yes'">Acknowledgement</xsl:when>
              <xsl:otherwise>Acknowledgment</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <t>
            Funding for the RFC Editor function is provided by the IETF
            Administrative Support Activity (IASA).
          </t>
        </section>
      </xsl:when>
      <xsl:when test="$funding0 and /rfc/@number">
        <section myns:unnumbered="unnumbered" myns:notoclink="notoclink">
          <xsl:attribute name="title">
            <xsl:choose>
              <xsl:when test="$xml2rfc-rfcedstyle='yes'">Acknowledgement</xsl:when>
              <xsl:otherwise>Acknowledgment</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <t>
            Funding for the RFC Editor function is currently provided by
            the Internet Society.
          </t>
        </section>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:if>

</xsl:template>

<!-- optional scripts -->
<xsl:template name="insertScript">
<xsl:if test="/rfc/x:feedback">
<script>
var buttonsAdded = false;

function init() {
  var fb = document.createElement("div");
  fb.className = "feedback noprint";
  fb.setAttribute("onclick", "feedback();");
  fb.appendChild(document.createTextNode("feedback"));

  var bodyl = document.getElementsByTagName("body");
  bodyl.item(0).appendChild(fb);
}

function feedback() {
  toggleButtonsToElementsByName("h1");
  toggleButtonsToElementsByName("h2");
  toggleButtonsToElementsByName("h3");
  toggleButtonsToElementsByName("h4");
  
  buttonsAdded = !buttonsAdded;
}

function toggleButtonsToElementsByName(name) {
  var list = document.getElementsByTagName(name);
  for (var i = 0; i &lt; list.length; i++) {
    toggleButton(list.item(i));
  }
}

function toggleButton(node) {
  if (! buttonsAdded) {
  
    // docname
    var template = "<xsl:call-template name="replace-substring">
  <xsl:with-param name="string" select="/rfc/x:feedback/@template"/>
  <xsl:with-param name="replace">"</xsl:with-param>
  <xsl:with-param name="by">\"</xsl:with-param>
</xsl:call-template>";

    var id = node.getAttribute("id");
    // better id available?
    var titlelinks = node.getElementsByTagName("a");
    for (var i = 0; i &lt; titlelinks.length; i++) {
      var tl = titlelinks.item(i);
      if (tl.getAttribute("id")) {
        id = tl.getAttribute("id");
      }
    }

    // ref
    var ref = window.location.toString();
    var hash = ref.indexOf("#");
    if (hash != -1) {
      ref = ref.substring(0, hash);
    }
    if (id != "") {
      ref += "#" + id;
    }
    
    // docname
    var docname = "<xsl:value-of select="/rfc/@docName"/>";

    // section
    var section = node.textContent;
    section = section.replace("\u00a0", " ");
    
    // build URI from template
    var uri = template.replace("{docname}", encodeURIComponent(docname));
    uri = uri.replace("{section}", encodeURIComponent(section));
    uri = uri.replace("{ref}", encodeURIComponent(ref));
  
    var button = document.createElement("a");
    button.className = "fbbutton noprint";
    button.setAttribute("href", uri);
    button.appendChild(document.createTextNode("send feedback"));
    node.appendChild(button);
  }
  else {
    var buttons = node.getElementsByTagName("a");
    for (var i = 0; i &lt; buttons.length; i++) {
      var b = buttons.item(i);
      if (b.className == "fbbutton noprint") {
        node.removeChild(b);
      }
    }
  }
}</script>
</xsl:if>
</xsl:template>

<!-- insert CSS style info -->

<xsl:template name="insertCss">
<style type="text/css" title="Xml2Rfc (sans serif)">
a {
  text-decoration: none;
}
a.smpl {
  color: black;
}
a:hover {
  text-decoration: underline;
}
a:active {
  text-decoration: underline;
}
address {
  margin-top: 1em;
  margin-left: 2em;
  font-style: normal;
}<xsl:if test="//x:blockquote">
blockquote {
  border-style: solid;
  border-color: gray;
  border-width: 0 0 0 .25em;
  font-style: italic;
  padding-left: 0.5em;
}</xsl:if>
body {<xsl:if test="$xml2rfc-background!=''">
  background: url(<xsl:value-of select="$xml2rfc-background" />) #ffffff left top;</xsl:if>
  color: black;
  font-family: verdana, helvetica, arial, sans-serif;
  font-size: 10pt;
  margin-right: 2em;
}<xsl:if test="//xhtml:p">
br.p {
  line-height: 150%;
}</xsl:if>
cite {
  font-style: normal;
}<xsl:if test="//x:note">
div.note {
  margin-left: 2em;
}</xsl:if>
dl {
  margin-left: 2em;
}
ul.empty {<!-- spacing between two entries in definition lists -->
  list-style-type: none;
}
ul.empty li {
  margin-top: .5em;
}
dl p {
  margin-left: 0em;
}
dt {
  margin-top: .5em;
}
h1 {
  font-size: 14pt;
  line-height: 21pt;
  page-break-after: avoid;
}
h1.np {
  page-break-before: always;
}
h1 a {
  color: #333333;
}
h2 {
  font-size: 12pt;
  line-height: 15pt;
  page-break-after: avoid;
}
h3, h4, h5, h6 {
  font-size: 10pt;
  page-break-after: avoid;
}
h2 a, h3 a, h4 a, h5 a, h6 a {
  color: black;
}
img {
  margin-left: 3em;
}
li {
  margin-left: 2em;
}
ol {
  margin-left: 2em;
}
ol.la {
  list-style-type: lower-alpha;
}
ol.ua {
  list-style-type: upper-alpha;
}
ol p {
  margin-left: 0em;
}<xsl:if test="//xhtml:q">
q {
  font-style: italic;
}</xsl:if>
p {
  margin-left: 2em;
}
pre {
  margin-left: 3em;
  background-color: lightyellow;
  padding: .25em;
  page-break-inside: avoid;
}<xsl:if test="//artwork[@x:isCodeComponent='yes']"><!-- support "<CODE BEGINS>" and "<CODE ENDS>" markers-->
pre.ccmarker {
  background-color: white;
  color: gray;
}
pre.ccmarker > span {
  font-size: small;
}
pre.cct {
  margin-bottom: -1em;
}
pre.ccb {
  margin-top: -1em;
}</xsl:if>
pre.text2 {
  border-style: dotted;
  border-width: 1px;
  background-color: #f0f0f0;
  width: 69em;
}
pre.inline {
  background-color: white;
  padding: 0em;
}
pre.text {
  border-style: dotted;
  border-width: 1px;
  background-color: #f8f8f8;
  width: 69em;
}
pre.drawing {
  border-style: solid;
  border-width: 1px;
  background-color: #f8f8f8;
  padding: 2em;
}<xsl:if test="//x:q">
q {
  font-style: italic;
}</xsl:if>
<xsl:if test="//x:sup">
sup {
  font-size: 60%;
}</xsl:if>
table {
  margin-left: 2em;
}<xsl:if test="//texttable">
table.tt {
  vertical-align: top;
}
table.full {
  border-style: outset;
  border-width: 1px;
}
table.headers {
  border-style: outset;
  border-width: 1px;
}
table.tt td {
  vertical-align: top;
}
table.full td {
  border-style: inset;
  border-width: 1px;
}
table.tt th {
  vertical-align: top;
}
table.full th {
  border-style: inset;
  border-width: 1px;
}
table.headers th {
  border-style: none none inset none;
  border-width: 1px;
}
table.left {
  margin-right: auto;
}
table.right {
  margin-left: auto;
}
table.center {
  margin-left: auto;
  margin-right: auto;
}
caption {
  caption-side: bottom;
  font-weight: bold;
  font-size: 9pt;
  margin-top: .5em;
}
</xsl:if>
table.header {
  border-spacing: 1px;
  width: 95%;
  font-size: 10pt;
  color: white;
}
td.top {
  vertical-align: top;
}
td.topnowrap {
  vertical-align: top;
  white-space: nowrap; 
}
table.header td {
  background-color: gray;
  width: 50%;
}<xsl:if test="/rfc/@obsoletes | /rfc/@updates">
table.header a {
  color: white;
}</xsl:if>
td.reference {
  vertical-align: top;
  white-space: nowrap;
  padding-right: 1em;
}
thead {
  display:table-header-group;
}
ul.toc, ul.toc ul {
  list-style: none;
  margin-left: 1.5em;
  padding-left: 0em;
}
ul.toc li {
  line-height: 150%;
  font-weight: bold;
  font-size: 10pt;
  margin-left: 0em;
}
ul.toc li li {
  line-height: normal;
  font-weight: normal;
  font-size: 9pt;
  margin-left: 0em;
}
li.excluded {
  font-size: 0pt;
}
ul p {
  margin-left: 0em;
}
<xsl:if test="$has-index">ul.ind, ul.ind ul {
  list-style: none;
  margin-left: 1.5em;
  padding-left: 0em;
  page-break-before: avoid;
}
ul.ind li {
  font-weight: bold;
  line-height: 200%;
  margin-left: 0em;
}
ul.ind li li {
  font-weight: normal;
  line-height: 150%;
  margin-left: 0em;
}
.avoidbreak {
  page-break-inside: avoid;
}
</xsl:if><xsl:if test="//x:bcp14">.bcp14 {
  font-style: normal;
  text-transform: lowercase;
  font-variant: small-caps;
}</xsl:if><xsl:if test="//x:blockquote">
blockquote > * .bcp14 {
  font-style: italic;
}</xsl:if>
.comment {
  background-color: yellow;
}<xsl:if test="$xml2rfc-editing='yes'">
.editingmark {
  background-color: khaki;
}</xsl:if>
.center {
  text-align: center;
}
.error {
  color: red;
  font-style: italic;
  font-weight: bold;
}
.figure {
  font-weight: bold;
  text-align: center;
  font-size: 9pt;
}
.filename {
  color: #333333;
  font-weight: bold;
  font-size: 12pt;
  line-height: 21pt;
  text-align: center;
}
.fn {
  font-weight: bold;
}
.hidden {
  display: none;
}
.left {
  text-align: left;
}
.right {
  text-align: right;
}
.title {
  color: #990000;
  font-size: 18pt;
  line-height: 18pt;
  font-weight: bold;
  text-align: center;
  margin-top: 36pt;
}
.vcardline {
  display: block;
}
.warning {
  font-size: 14pt;
  background-color: yellow;
}
<xsl:if test="$has-edits">del {
  color: red;
  text-decoration: line-through;
}
.del {
  color: red;
  text-decoration: line-through;
}
ins {
  color: green;
  text-decoration: underline;
}
.ins {
  color: green;
  text-decoration: underline;
}
div.issuepointer {
  float: left;
}</xsl:if><xsl:if test="//ed:issue">
table.openissue {
  background-color: khaki;
  border-width: thin;
  border-style: solid;
  border-color: black;
}
table.closedissue {
  background-color: white;
  border-width: thin;
  border-style: solid;
  border-color: gray;
  color: gray; 
}
thead th {
  text-align: left;
}
.bg-issue {
  border: solid;
  border-width: 1px;
  font-size: 7pt;
}
.closed-issue {
  border: solid;
  border-width: thin;
  background-color: lime;
  font-size: smaller;
  font-weight: bold;
}
.open-issue {
  border: solid;
  border-width: thin;
  background-color: red;
  font-size: smaller;
  font-weight: bold;
}
.editor-issue {
  border: solid;
  border-width: thin;
  background-color: yellow;
  font-size: smaller;
  font-weight: bold;
}</xsl:if><xsl:if test="/rfc/x:feedback">.feedback {
  position: fixed;
  bottom: 1%;
  right: 1%;
  padding: 3px 5px;
  color: white;
  border-radius: 5px;
  background: #a00000;
  border: 1px solid silver;
}
.fbbutton {
  margin-left: 1em;
  color: #303030;
  font-size: small;
  font-weight: normal;
  background: #d0d000;
  padding: 1px 4px;
  border: 1px solid silver;
  border-radius: 5px;
}</xsl:if><xsl:if test="$xml2rfc-ext-justification='always'">
dd, li, p {
  text-align: justify;
}</xsl:if>

@media print {
  .noprint {
    display: none;
  }
  
  a {
    color: black;
    text-decoration: none;
  }

  table.header {
    width: 90%;
  }

  td.header {
    width: 50%;
    color: black;
    background-color: white;
    vertical-align: top;
    font-size: 12pt;
  }

  ul.toc a:nth-child(2)::after {
    content: leader('.') target-counter(attr(href), page);
  }
  
  ul.ind li li a {<!-- links in the leaf nodes of the index should go to page numbers -->
    content: target-counter(attr(href), page);
  }
  
  .print2col {
    column-count: 2;
    -moz-column-count: 2;<!-- for Firefox -->
    column-fill: auto;<!-- for PrinceXML -->
  }
<xsl:if test="$xml2rfc-ext-justification='print'">
  dd, li, p {
    text-align: justify;
  }
</xsl:if>}
<xsl:choose><xsl:when test="$xml2rfc-ext-duplex='yes'">
@page:right {
  @top-left {
       content: "<xsl:call-template name="get-header-left"/>"; 
  } 
  @top-right {
       content: "<xsl:call-template name="get-header-right"/>"; 
  } 
  @top-center {
       content: "<xsl:call-template name="get-header-center"/>"; 
  } 
  @bottom-left {
       content: "<xsl:call-template name="get-author-summary"/>"; 
  } 
  @bottom-center {
       content: "<xsl:call-template name="get-bottom-center"/>"; 
  } 
  @bottom-right {
       content: "[Page " counter(page) "]"; 
  } 
}
@page:left {
  @top-left {
       content: "<xsl:call-template name="get-header-right"/>"; 
  } 
  @top-right {
       content: "<xsl:call-template name="get-header-left"/>"; 
  } 
  @top-center {
       content: "<xsl:call-template name="get-header-center"/>"; 
  } 
  @bottom-left {
       content: "[Page " counter(page) "]"; 
  } 
  @bottom-center {
       content: "<xsl:call-template name="get-bottom-center"/>"; 
  } 
  @bottom-right {
       content: "<xsl:call-template name="get-author-summary"/>"; 
  } 
}
</xsl:when><xsl:otherwise>
@page {
  @top-left {
       content: "<xsl:call-template name="get-header-left"/>"; 
  } 
  @top-right {
       content: "<xsl:call-template name="get-header-right"/>"; 
  } 
  @top-center {
       content: "<xsl:call-template name="get-header-center"/>"; 
  } 
  @bottom-left {
       content: "<xsl:call-template name="get-author-summary"/>"; 
  } 
  @bottom-center {
       content: "<xsl:call-template name="get-bottom-center"/>"; 
  } 
  @bottom-right {
       content: "[Page " counter(page) "]"; 
  } 
}
</xsl:otherwise></xsl:choose>
@page:first { 
    @top-left {
      content: normal;
    }
    @top-right {
      content: normal;
    }
    @top-center {
      content: normal;
    }
}
</style>
</xsl:template>


<!-- generate the index section -->

<xsl:template name="insertSingleIref">
  <xsl:choose>
    <xsl:when test="@ed:xref">
      <!-- special index generator mode -->
      <xsl:text>[</xsl:text>
      <a href="#{@ed:xref}"><xsl:value-of select="@ed:xref"/></a>
      <xsl:text>, </xsl:text>
      <a>
        <xsl:variable name="htmluri" select="//reference[@anchor=current()/@ed:xref]/format[@type='HTML']/@target"/>
        <xsl:if test="$htmluri">
          <xsl:attribute name="href"><xsl:value-of select="concat($htmluri,'#',@ed:frag)"/></xsl:attribute>
        </xsl:if>       
        <xsl:choose>
          <xsl:when test="@primary='true'"><b><xsl:value-of select="@ed:label" /></b></xsl:when>
          <xsl:otherwise><xsl:value-of select="@ed:label" /></xsl:otherwise>
        </xsl:choose>
      </a>
      <xsl:text>]</xsl:text>
      <xsl:if test="position()!=last()">, </xsl:if>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="_n">
        <xsl:call-template name="get-section-number" />
      </xsl:variable>
      <xsl:variable name="n">
        <xsl:choose>
          <xsl:when test="$_n!=''">
            <xsl:value-of select="$_n"/>
          </xsl:when>
          <xsl:otherwise>&#167;</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="backlink">
        <xsl:choose>
          <xsl:when test="self::xref">
            <xsl:variable name="target" select="@target"/>
            <xsl:comment>workaround for Saxon 9.1 bug; force evalutation of: <xsl:value-of select="$target"/></xsl:comment>
            <xsl:variable name="no"><xsl:number level="any" count="xref[@target=$target]"/></xsl:variable>
            <xsl:text>#</xsl:text>
            <xsl:value-of select="$anchor-prefix"/>
            <xsl:text>.xref.</xsl:text>
            <xsl:value-of select="@target"/>
            <xsl:text>.</xsl:text>
            <xsl:value-of select="$no"/>
          </xsl:when>
          <xsl:when test="self::iref">
            <xsl:text>#</xsl:text>
            <xsl:call-template name="compute-iref-anchor"/>
          </xsl:when>
          <xsl:when test="self::x:ref">
            <xsl:text>#</xsl:text>
            <xsl:call-template name="compute-extref-anchor"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message>Unsupported element type for insertSingleIref</xsl:message>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <a href="{$backlink}">
        <xsl:call-template name="insertInsDelClass"/>
        <xsl:choose>
          <xsl:when test="@primary='true'"><b><xsl:value-of select="$n"/></b></xsl:when>
          <xsl:otherwise><xsl:value-of select="$n"/></xsl:otherwise>
        </xsl:choose>
      </a>
      <xsl:if test="position()!=last()">, </xsl:if>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="insertSingleXref">
  <xsl:variable name="_n">
    <xsl:call-template name="get-section-number" />
  </xsl:variable>
  <xsl:variable name="n">
    <xsl:choose>
      <xsl:when test="$_n!=''">
        <xsl:value-of select="$_n"/>
      </xsl:when>
      <xsl:otherwise>&#167;</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="self::reference">
      <a href="#{@anchor}">
        <xsl:call-template name="insertInsDelClass"/>
        <b><xsl:value-of select="$n"/></b>
      </a>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="target" select="@target"/>
      <xsl:variable name="backlink">#<xsl:value-of select="$anchor-prefix"/>.xref.<xsl:value-of select="$target"/>.<xsl:number level="any" count="xref[@target=$target]"/></xsl:variable>
      <a href="{$backlink}">
        <xsl:call-template name="insertInsDelClass"/>
        <xsl:value-of select="$n"/>
      </a>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:if test="position()!=last()">, </xsl:if>
</xsl:template>

<xsl:template name="insertIndex">

  <xsl:call-template name="insert-conditional-hrule"/>

  <h1 id="{$anchor-prefix}.index">
    <xsl:call-template name="insert-conditional-pagebreak"/>
    <a href="#{$anchor-prefix}.index">Index</a>
  </h1>
  
  <!-- generate navigation links to index subsections -->
  <p class="noprint">
    <xsl:variable name="irefs" select="//iref[generate-id(.) = generate-id(key('index-first-letter',translate(substring(@item,1,1),$lcase,$ucase))[1])]"/>
    <xsl:variable name="xrefs" select="//reference[not(starts-with(@anchor,'deleted-'))][generate-id(.) = generate-id(key('index-first-letter',translate(substring(@anchor,1,1),$lcase,$ucase))[1])]"/>
  
    <xsl:for-each select="$irefs | $xrefs">
    
      <xsl:sort select="translate(concat(@item,@anchor),$lcase,$ucase)" />
          
      <xsl:variable name="letter" select="translate(substring(concat(@item,@anchor),1,1),$lcase,$ucase)"/>

      <!-- character? -->
      <xsl:if test="translate($letter,concat($lcase,$ucase,'0123456789'),'')=''">
      
        <xsl:variable name="showit" select="$xml2rfc-ext-include-references-in-index='yes' or $irefs[starts-with(translate(@item,$lcase,$ucase),$letter)]"/>
        
        <xsl:if test="$showit">
          <a href="#{$anchor-prefix}.index.{$letter}">
            <xsl:value-of select="$letter" />
          </a>
          <xsl:text> </xsl:text>
        </xsl:if>
      
      </xsl:if>

    </xsl:for-each>
  </p>

  <!-- for each index subsection -->
  <div class="print2col">
  <ul class="ind">
    <xsl:variable name="irefs2" select="//iref[generate-id(.) = generate-id(key('index-first-letter',translate(substring(@item,1,1),$lcase,$ucase))[1])]"/>
    <xsl:variable name="xrefs2" select="//reference[not(starts-with(@anchor,'deleted-'))][generate-id(.) = generate-id(key('index-first-letter',translate(substring(@anchor,1,1),$lcase,$ucase))[1])]"/>
  
    <xsl:for-each select="$irefs2 | $xrefs2">
      <xsl:sort select="translate(concat(@item,@anchor),$lcase,$ucase)" />
      <xsl:variable name="letter" select="translate(substring(concat(@item,@anchor),1,1),$lcase,$ucase)"/>
            
      <xsl:variable name="showit" select="$xml2rfc-ext-include-references-in-index='yes' or $irefs2[starts-with(translate(@item,$lcase,$ucase),$letter)]"/>

      <xsl:if test="$showit">
        <li>
          
          <!-- make letters and digits stand out -->
          <xsl:choose>
            <xsl:when test="translate($letter,concat($lcase,$ucase,'0123456789'),'')=''">
              <a id="{$anchor-prefix}.index.{$letter}" href="#{$anchor-prefix}.index.{$letter}">
                <b><xsl:value-of select="$letter" /></b>
              </a>
            </xsl:when>
            <xsl:otherwise>
              <b><xsl:value-of select="$letter" /></b>
            </xsl:otherwise>
          </xsl:choose>
        
          <ul>  
            <xsl:for-each select="key('index-first-letter',translate(substring(concat(@item,@anchor),1,1),$lcase,$ucase))">
        
              <xsl:sort select="translate(concat(@item,@anchor),$lcase,$ucase)" />
              
                <xsl:choose>
                  <xsl:when test="self::reference">
                    <xsl:if test="$xml2rfc-ext-include-references-in-index='yes' and not(starts-with(@anchor,'deleted-'))">
                      <li>
                        <em>
                          <xsl:value-of select="@anchor"/>
                        </em>
                        <xsl:text>&#160;&#160;</xsl:text>
                        
                        <xsl:variable name="rs" select="key('xref-item',current()/@anchor) | . | key('anchor-item',concat('deleted-',current()/@anchor))"/>
                        
                        <xsl:for-each select="$rs">
                          <xsl:call-template name="insertSingleXref" />
                        </xsl:for-each>

                        <xsl:variable name="rs2" select="$rs[@x:sec]"/>

                        <xsl:if test="$rs2">
                          <ul>  
                            <xsl:for-each select="$rs2">
                              <xsl:sort select="substring-before(concat(@x:sec,'.'),'.')" data-type="number"/>
                              <xsl:sort select="substring(@x:sec,2+string-length(substring-before(@x:sec,'.')))" data-type="number"/>
                              <xsl:if test="generate-id(.) = generate-id(key('index-xref-by-sec',concat(@target,'..',@x:sec))[1])">
                                <li>
                                  <em>
                                    <xsl:choose>
                                      <xsl:when test="translate(substring(@x:sec,1,1),$ucase,'')=''">
                                        <xsl:text>Appendix </xsl:text>
                                      </xsl:when>
                                      <xsl:otherwise>
                                        <xsl:text>Section </xsl:text>
                                      </xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:value-of select="@x:sec"/>
                                  </em>
                                  <xsl:text>&#160;&#160;</xsl:text>
                                  <xsl:for-each select="key('index-xref-by-sec',concat(@target,'..',@x:sec))">
                                    <xsl:call-template name="insertSingleXref" />
                                  </xsl:for-each>
                                </li>
                              </xsl:if>
                            </xsl:for-each>
                          </ul>
                        </xsl:if>

                        <xsl:if test="current()/x:source/@href">
                          <xsl:variable name="rs3" select="$rs[not(@x:sec) and @x:rel]"/>
                          <xsl:variable name="doc" select="document(current()/x:source/@href)"/>
                          <xsl:if test="$rs3">
                            <ul>  
                              <xsl:for-each select="$rs3">
                                <xsl:sort select="count($doc//*[@anchor and following::*/@anchor=substring-after(current()/@x:rel,'#')])" order="ascending" data-type="number"/>
                                <xsl:if test="generate-id(.) = generate-id(key('index-xref-by-anchor',concat(@target,'..',@x:rel))[1])">
                                  <li>
                                    <em>
                                      <xsl:variable name="sec">
                                        <xsl:for-each select="$doc//*[@anchor=substring-after(current()/@x:rel,'#')]">
                                          <xsl:call-template name="get-section-number"/>
                                        </xsl:for-each>
                                      </xsl:variable>
                                      <xsl:choose>
                                        <xsl:when test="translate(substring($sec,1,1),$ucase,'')=''">
                                          <xsl:text>Appendix </xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                          <xsl:text>Section </xsl:text>
                                        </xsl:otherwise>
                                      </xsl:choose>
                                      <xsl:value-of select="$sec"/>
                                    </em>
                                    <xsl:text>&#160;&#160;</xsl:text>
                                    <xsl:for-each select="key('index-xref-by-anchor',concat(@target,'..',@x:rel))">
                                      <xsl:call-template name="insertSingleXref" />
                                    </xsl:for-each>
                                  </li>
                                </xsl:if>
                              </xsl:for-each>
                            </ul>
                          </xsl:if>
                        </xsl:if>
                      </li>
                    </xsl:if>
                  </xsl:when>
                  <xsl:otherwise>
                    <!-- regular iref -->
                    <xsl:if test="generate-id(.) = generate-id(key('index-item',concat(@item,@anchor))[1])">
                      <xsl:variable name="item" select="@item"/>
                      <xsl:variable name="in-artwork" select="key('index-item',$item)[@primary='true' and ancestor::artwork]"/>
                          
                      <li>
                        <xsl:choose>
                          <xsl:when test="$in-artwork">
                            <tt><xsl:value-of select="@item" /></tt>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:value-of select="@item" />
                          </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text>&#160;&#160;</xsl:text>
                        
                        <xsl:variable name="irefs3" select="key('index-item',@item)[not(@subitem) or @subitem='']"/>
                        <xsl:variable name="xrefs3" select="key('xref-item',$irefs3[@x:for-anchor='']/../@anchor) | key('xref-item',$irefs3/@x:for-anchor)"/>
                        <xsl:variable name="extrefs3" select="key('extref-item',$irefs3[@x:for-anchor='']/../@anchor) | key('extref-item',$irefs3/@x:for-anchor)"/>

                        <xsl:for-each select="$irefs3|$xrefs3|$extrefs3">
                          <!-- <xsl:sort select="translate(@item,$lcase,$ucase)" />  -->
                          <xsl:call-template name="insertSingleIref" />
                        </xsl:for-each>
          
                        <xsl:variable name="s2" select="key('index-item',@item)[@subitem and @subitem!='']"/>
                        <xsl:if test="$s2">
                          <ul>  
                            <xsl:for-each select="$s2">
                              <xsl:sort select="translate(@subitem,$lcase,$ucase)" />
                              
                              <xsl:if test="generate-id(.) = generate-id(key('index-item-subitem',concat(@item,'..',@subitem))[1])">
                  
                                <xsl:variable name="in-artwork2" select="key('index-item-subitem',concat(@item,'..',@subitem))[@primary='true' and ancestor::artwork]" />
                  
                                <li>
              
                                  <xsl:choose>
                                    <xsl:when test="$in-artwork2">
                                      <tt><xsl:value-of select="@subitem" /></tt>
                                    </xsl:when>
                                    <xsl:otherwise>
                                      <xsl:value-of select="@subitem" />
                                    </xsl:otherwise>
                                  </xsl:choose>
                                  <xsl:text>&#160;&#160;</xsl:text>
                                    
                                  <xsl:variable name="irefs4" select="key('index-item-subitem',concat(@item,'..',@subitem))"/>
                                  <xsl:variable name="xrefs4" select="key('xref-item',$irefs4[@x:for-anchor='']/../@anchor) | key('xref-item',$irefs4/@x:for-anchor)"/>
                                  <xsl:variable name="extrefs4" select="key('extref-item',$irefs4[@x:for-anchor='']/../@anchor) | key('extref-item',$irefs4/@x:for-anchor)"/>

                                  <xsl:for-each select="$irefs4|$xrefs4|$extrefs4">
                                    <!--<xsl:sort select="translate(@item,$lcase,$ucase)" />-->                    
                                    <xsl:call-template name="insertSingleIref" />
                                  </xsl:for-each>
                
                                </li>
                              </xsl:if>
                            </xsl:for-each>
                          </ul>
                        </xsl:if>
                      </li>
                    </xsl:if>
                  </xsl:otherwise>
                </xsl:choose>
              
                      
            </xsl:for-each>            
          </ul>
        </li>
      </xsl:if>
      
    </xsl:for-each>
  </ul>
  </div>
  
</xsl:template>

<xsl:template name="insertPreamble" myns:namespaceless-elements="xml2rfc">

  <!-- TLP4, Section 6.c.iii -->
  <xsl:variable name="pre5378EscapeClause">
    This document may contain material from IETF Documents or IETF Contributions published or
    made publicly available before November 10, 2008. The person(s) controlling the copyright in
    some of this material may not have granted the IETF Trust the right to allow modifications of such
    material outside the IETF Standards Process. Without obtaining an adequate license from the
    person(s) controlling the copyright in such materials, this document may not be modified outside
    the IETF Standards Process, and derivative works of it may not be created outside the IETF
    Standards Process, except to format it for publication as an RFC or to translate it into languages
    other than English.
  </xsl:variable>
  
  <!-- TLP1, Section 6.c.i -->
  <xsl:variable name="noModificationTrust200811Clause">
    This document may not be modified, and derivative works of it may not be
    created, except to format it for publication as an RFC and to translate it
    into languages other than English.
  </xsl:variable>

  <!-- TLP2..4, Section 6.c.i -->
  <xsl:variable name="noModificationTrust200902Clause">
    This document may not be modified, and derivative works of it may not be
    created, except to format it for publication as an RFC or to translate it
    into languages other than English.<!-- "and" changes to "or" -->
  </xsl:variable>

  <!-- TLP1..4, Section 6.c.ii -->
  <xsl:variable name="noDerivativesTrust200___Clause">
    This document may not be modified, and derivative works of it may not be
    created, and it may not be published except as an Internet-Draft.
  </xsl:variable>

  <section myns:unnumbered="unnumbered" myns:notoclink="notoclink" anchor="{$anchor-prefix}.status">
  <xsl:attribute name="title">
    <xsl:choose>
      <xsl:when test="$xml2rfc-rfcedstyle='yes'">Status of This Memo</xsl:when>
      <xsl:otherwise>Status of this Memo</xsl:otherwise>
    </xsl:choose>
  </xsl:attribute>

  <xsl:choose>
    <xsl:when test="/rfc/@ipr and not(/rfc/@number)">
      <t>
        <xsl:choose>
          
          <!-- RFC2026 -->
          <xsl:when test="/rfc/@ipr = 'full2026'">
            This document is an Internet-Draft and is 
            in full conformance with all provisions of Section 10 of RFC2026.    
          </xsl:when>
          <xsl:when test="/rfc/@ipr = 'noDerivativeWorks2026'">
            This document is an Internet-Draft and is 
            in full conformance with all provisions of Section 10 of RFC2026
            except that the right to produce derivative works is not granted.   
          </xsl:when>
          <xsl:when test="/rfc/@ipr = 'noDerivativeWorksNow'">
            This document is an Internet-Draft and is 
            in full conformance with all provisions of Section 10 of RFC2026
            except that the right to produce derivative works is not granted.
            (If this document becomes part of an IETF working group activity,
            then it will be brought into full compliance with Section 10 of RFC2026.)  
          </xsl:when>
          <xsl:when test="/rfc/@ipr = 'none'">
            This document is an Internet-Draft and is 
            NOT offered in accordance with Section 10 of RFC2026,
            and the author does not provide the IETF with any rights other
            than to publish as an Internet-Draft.
          </xsl:when>
          
          <!-- RFC3667 -->
          <xsl:when test="/rfc/@ipr = 'full3667'">
            This document is an Internet-Draft and is subject to all provisions
            of section 3 of RFC 3667.  By submitting this Internet-Draft, each
            author represents that any applicable patent or other IPR claims of
            which he or she is aware have been or will be disclosed, and any of
            which he or she become aware will be disclosed, in accordance with
            RFC 3668.
          </xsl:when>
          <xsl:when test="/rfc/@ipr = 'noModification3667'">
            This document is an Internet-Draft and is subject to all provisions
            of section 3 of RFC 3667.  By submitting this Internet-Draft, each
            author represents that any applicable patent or other IPR claims of
            which he or she is aware have been or will be disclosed, and any of
            which he or she become aware will be disclosed, in accordance with
            RFC 3668.  This document may not be modified, and derivative works of
            it may not be created, except to publish it as an RFC and to
            translate it into languages other than English<xsl:if test="/rfc/@iprExtract">,
            other than to extract <xref target="{/rfc/@iprExtract}"/> as-is
            for separate use</xsl:if>.
          </xsl:when>
          <xsl:when test="/rfc/@ipr = 'noDerivatives3667'">
            This document is an Internet-Draft and is subject to all provisions
            of section 3 of RFC 3667 except for the right to produce derivative
            works.  By submitting this Internet-Draft, each author represents 
            that any applicable patent or other IPR claims of which he or she
            is aware have been or will be disclosed, and any of which he or she
            become aware will be disclosed, in accordance with RFC 3668.  This
            document may not be modified, and derivative works of it may
            not be created<xsl:if test="/rfc/@iprExtract">, other than to extract
            <xref target="{/rfc/@iprExtract}"/> as-is for separate use</xsl:if>.
          </xsl:when>
          
          <!-- RFC3978 -->
          <xsl:when test="/rfc/@ipr = 'full3978'">
            By submitting this Internet-Draft, each
            author represents that any applicable patent or other IPR claims of
            which he or she is aware have been or will be disclosed, and any of
            which he or she becomes aware will be disclosed, in accordance with
            Section 6 of BCP 79.
          </xsl:when>
          <xsl:when test="/rfc/@ipr = 'noModification3978'">
            By submitting this Internet-Draft, each
            author represents that any applicable patent or other IPR claims of
            which he or she is aware have been or will be disclosed, and any of
            which he or she becomes aware will be disclosed, in accordance with
            Section 6 of BCP 79.  This document may not be modified, and derivative works of
            it may not be created, except to publish it as an RFC and to
            translate it into languages other than English<xsl:if test="/rfc/@iprExtract">,
            other than to extract <xref target="{/rfc/@iprExtract}"/> as-is
            for separate use</xsl:if>.
          </xsl:when>
          <xsl:when test="/rfc/@ipr = 'noDerivatives3978'">
            By submitting this Internet-Draft, each author represents 
            that any applicable patent or other IPR claims of which he or she
            is aware have been or will be disclosed, and any of which he or she
            becomes aware will be disclosed, in accordance with Section 6 of BCP 79.  This
            document may not be modified, and derivative works of it may
            not be created<xsl:if test="/rfc/@iprExtract">, other than to extract
            <xref target="{/rfc/@iprExtract}"/> as-is for separate use</xsl:if>.
          </xsl:when>
  
          <!-- as of Jan 2010, TLP 4.0 -->
          <xsl:when test="$ipr-2010-01 and (/rfc/@ipr = 'trust200902'
                          or /rfc/@ipr = 'noModificationTrust200902'
                          or /rfc/@ipr = 'noDerivativesTrust200902'
                          or /rfc/@ipr = 'pre5378Trust200902')">
            This Internet-Draft is submitted in full conformance with
            the provisions of BCP 78 and BCP 79.
          </xsl:when>
  
          <!-- as of Nov 2008, Feb 2009 and Sep 2009 -->
          <xsl:when test="/rfc/@ipr = 'trust200811'
                          or /rfc/@ipr = 'noModificationTrust200811'
                          or /rfc/@ipr = 'noDerivativesTrust200811'
                          or /rfc/@ipr = 'trust200902'
                          or /rfc/@ipr = 'noModificationTrust200902'
                          or /rfc/@ipr = 'noDerivativesTrust200902'
                          or /rfc/@ipr = 'pre5378Trust200902'">
            This Internet-Draft is submitted to IETF in full conformance with
            the provisions of BCP 78 and BCP 79.
          </xsl:when>
          <xsl:otherwise>
            CONFORMANCE UNDEFINED.
          </xsl:otherwise>
        </xsl:choose>
        
        <!-- warn about iprExtract without effect -->
        <xsl:if test="/rfc/@iprExtract and (/rfc/@ipr != 'noModification3667' and /rfc/@ipr != 'noDerivatives3667' and /rfc/@ipr != 'noModification3978' and /rfc/@ipr != 'noDerivatives3978')">
          <xsl:call-template name="warning">
            <xsl:with-param name="msg" select="concat('/rfc/@iprExtract does not have any effect for /rfc/@ipr=',/rfc/@ipr)"/>
          </xsl:call-template>
        </xsl:if>
        
        <!-- restrictions -->
        <xsl:choose>
          <xsl:when test="/rfc/@ipr = 'noModificationTrust200811'">
            <xsl:value-of select="$noModificationTrust200811Clause"/>
          </xsl:when>
          <xsl:when test="/rfc/@ipr = 'noDerivativesTrust200811'">
            <xsl:value-of select="$noDerivativesTrust200___Clause"/>
          </xsl:when>
          <xsl:when test="/rfc/@ipr = 'noModificationTrust200902'">
            <xsl:value-of select="$noModificationTrust200902Clause"/>
          </xsl:when>
          <xsl:when test="/rfc/@ipr = 'noDerivativesTrust200902'">
            <xsl:value-of select="$noDerivativesTrust200___Clause"/>
          </xsl:when>
          <!-- escape clause moved to Copyright Notice as of 2009-11 -->
          <xsl:when test="/rfc/@ipr = 'pre5378Trust200902' and $pub-yearmonth &lt; 200911">
            <xsl:value-of select="$pre5378EscapeClause"/>
          </xsl:when>

          <xsl:otherwise />
        </xsl:choose>
      </t>
      <xsl:choose>
        <xsl:when test="$id-boilerplate='2010'">
          <t>
            Internet-Drafts are working documents of the Internet Engineering
            Task Force (IETF). Note that other groups may also distribute
            working documents as Internet-Drafts. The list of current
            Internet-Drafts is at <eref target='http://datatracker.ietf.org/drafts/current/'>http://datatracker.ietf.org/drafts/current/</eref>.
          </t>
        </xsl:when>
        <xsl:otherwise>
          <t>
            Internet-Drafts are working documents of the Internet Engineering
            Task Force (IETF), its areas, and its working groups.
            Note that other groups may also distribute working documents as
            Internet-Drafts.
          </t>
        </xsl:otherwise>
      </xsl:choose>
      <t>
        Internet-Drafts are draft documents valid for a maximum of six months
        and may be updated, replaced, or obsoleted by other documents at any time.
        It is inappropriate to use Internet-Drafts as reference material or to cite
        them other than as &#8220;work in progress&#8221;.
      </t>
      <xsl:if test="$id-boilerplate=''">
        <t>
          The list of current Internet-Drafts can be accessed at
          <eref target='http://www.ietf.org/ietf/1id-abstracts.txt'>http://www.ietf.org/ietf/1id-abstracts.txt</eref>.
        </t>
        <t>
          The list of Internet-Draft Shadow Directories can be accessed at
          <eref target='http://www.ietf.org/shadow.html'>http://www.ietf.org/shadow.html</eref>.
        </t>
      </xsl:if>
      <t>
        This Internet-Draft will expire <xsl:call-template name="expirydate"><xsl:with-param name="in-prose" select="true()"/></xsl:call-template>.
      </t>
    </xsl:when>

    <xsl:when test="/rfc/@category='bcp' and $rfc-boilerplate='2010'">
      <t>
        This memo documents an Internet Best Current Practice.
      </t>
    </xsl:when>
    <xsl:when test="/rfc/@category='bcp'">
      <t>
        This document specifies an Internet Best Current Practices for the Internet
        Community, and requests discussion and suggestions for improvements.
        Distribution of this memo is unlimited.
      </t>
    </xsl:when>
    <xsl:when test="/rfc/@category='exp' and $rfc-boilerplate='2010'">
      <t>
        This document is not an Internet Standards Track specification; it is
        published for examination, experimental implementation, and evaluation.
      </t>
    </xsl:when>
    <xsl:when test="/rfc/@category='exp'">
      <t>
        This memo defines an Experimental Protocol for the Internet community.
        It does not specify an Internet standard of any kind.
        Discussion and suggestions for improvement are requested.
        Distribution of this memo is unlimited.
      </t>
    </xsl:when>
    <xsl:when test="/rfc/@category='historic' and $rfc-boilerplate='2010'">
      <t>
        This document is not an Internet Standards Track specification; it is
        published for the historical record.
      </t>
    </xsl:when>
    <xsl:when test="/rfc/@category='historic'">
      <t>
        This memo describes a historic protocol for the Internet community.
        It does not specify an Internet standard of any kind.
        Distribution of this memo is unlimited.
      </t>
    </xsl:when>
    <xsl:when test="/rfc/@category='std' and $rfc-boilerplate='2010'">
      <t>
        This is an Internet Standards Track document.
      </t>
    </xsl:when>
    <xsl:when test="/rfc/@category='std'">
      <t>
        This document specifies an Internet standards track protocol for the Internet
        community, and requests discussion and suggestions for improvements.
        Please refer to the current edition of the &#8220;Internet Official Protocol
        Standards&#8221; (STD 1) for the standardization state and status of this
        protocol. Distribution of this memo is unlimited.
      </t>
    </xsl:when>
    <xsl:when test="(/rfc/@category='info' or not(/rfc/@category)) and $rfc-boilerplate='2010'">
      <t>
        This document is not an Internet Standards Track specification; it is
        published for informational purposes.
      </t>
    </xsl:when>
    <xsl:when test="/rfc/@category='info' or not(/rfc/@category)">
      <t>
        This memo provides information for the Internet community.
        It does not specify an Internet standard of any kind.
        Distribution of this memo is unlimited.
      </t>
    </xsl:when>
    <xsl:otherwise>
      <t>
        UNSUPPORTED CATEGORY.
      </t>
      <xsl:call-template name="error">
        <xsl:with-param name="msg" select="concat('Unsupported value for /rfc/@category: ', /rfc/@category)"/>
        <xsl:with-param name="inline" select="'no'"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
    
  <!-- 2nd and 3rd paragraph -->
  <xsl:if test="$rfc-boilerplate='2010' and /rfc/@number">
    <t>
      <xsl:if test="/rfc/@category='exp'">
        This document defines an Experimental Protocol for the Internet
        community.
      </xsl:if>
      <xsl:if test="/rfc/@category='historic'">
        This document defines a Historic Document for the Internet community.
      </xsl:if>
      <xsl:choose>
        <xsl:when test="$submissionType='IETF'">
          This document is a product of the Internet Engineering Task Force
          (IETF).
          <xsl:choose>
            <xsl:when test="$consensus='yes'">
              It represents the consensus of the IETF community.  It has
              received public review and has been approved for publication by
              the Internet Engineering Steering Group (IESG).
            </xsl:when>
            <xsl:otherwise>
              It has been approved for publication by the Internet Engineering
              Steering Group (IESG).
              <!-- sanity check of $consensus -->
              <xsl:if test="/rfc/@category='std' or /rfc/@category='bcp'">
                <xsl:call-template name="error">
                  <xsl:with-param name="msg" select="'IETF BCPs and Standards Track documents require IETF consensus, check values of @category and @consensus!'"/>
                  <xsl:with-param name="inline" select="'no'"/>
                </xsl:call-template>
              </xsl:if>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$submissionType='IAB'">
          This document is a product of the Internet Architecture Board (IAB)
          and represents information that the IAB has deemed valuable to
          provide for permanent record.
          <xsl:if test="$consensus='yes'">
            It represents the consensus of the Internet Architecture Board (IAB).
          </xsl:if>
        </xsl:when>
        <xsl:when test="$submissionType='IRTF'">
          This document is a product of the Internet Research Task Force (IRTF).
          The IRTF publishes the results of Internet-related research and
          development activities.  These results might not be suitable for
          deployment.
          <xsl:choose>
            <xsl:when test="$consensus='yes' and /rfc/front/workgroup!=''">
              This RFC represents the consensus of the
              <xsl:value-of select="/rfc/front/workgroup"/> Research Group of the Internet
              Research Task Force (IRTF).
            </xsl:when>
            <xsl:when test="$consensus='no' and /rfc/front/workgroup!=''">
              This RFC represents the individual opinion(s) of one or more
              members of the <xsl:value-of select="/rfc/front/workgroup"/> Research Group of the
              Internet Research Task Force (IRTF).
            </xsl:when>
            <xsl:otherwise>
              <!-- no research group -->
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$submissionType='independent'">
          This is a contribution to the RFC Series, independently of any other
          RFC stream.  The RFC Editor has chosen to publish this document at
          its discretion and makes no statement about its value for
          implementation or deployment.
        </xsl:when>
        <xsl:otherwise>
          <!-- will contain error message already -->
          <xsl:value-of select="$submissionType"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="$submissionType='IETF'">
          <xsl:choose>
            <xsl:when test="/rfc/@category='bcp'">
              Further information on BCPs is available in Section 2 of RFC 5741.
            </xsl:when>
            <xsl:when test="/rfc/@category='std'">
              Further information on Internet Standards is available in Section
              2 of RFC 5741.
            </xsl:when>
            <xsl:otherwise>
              Not all documents approved by the IESG are a candidate for any 
              level of Internet Standard; see Section 2 of RFC 5741.
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="approver">
            <xsl:choose>
              <xsl:when test="$submissionType='IAB'">IAB</xsl:when>
              <xsl:when test="$submissionType='IRTF'">IRSG</xsl:when>
              <xsl:otherwise>RFC Editor</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
        
          Documents approved for publication by the
          <xsl:value-of select="$approver"/> are not a candidate for any level
          of Internet Standard; see Section 2 of RFC 5741.
        </xsl:otherwise>
      </xsl:choose>
    </t>
    <t>
      Information about the current status of this document, any errata, and
      how to provide feedback on it may be obtained at
      <eref target="http://www.rfc-editor.org/info/rfc{/rfc/@number}">http://www.rfc-editor.org/info/rfc<xsl:value-of select="/rfc/@number"/></eref>.
    </t>
  </xsl:if>
    
  </section>
  
  <!-- IESG Note goes here; see http://www.rfc-editor.org/rfc-style-guide/rfc-style -->
  <xsl:copy-of select="/rfc/front/note[@title='IESG Note']"/>
  
  <xsl:choose>
    <xsl:when test="$ipr-2008-11">
      <section title="Copyright Notice" myns:unnumbered="unnumbered" myns:notoclink="notoclink" anchor="{$anchor-prefix}.copyrightnotice">
        <t>
          Copyright &#169; <xsl:value-of select="$xml2rfc-ext-pub-year" /> IETF Trust and the persons identified
          as the document authors.  All rights reserved.
        </t>
        <xsl:choose>
          <xsl:when test="$ipr-2010-01">
            <t>
              This document is subject to BCP 78 and the IETF Trust's Legal
              Provisions Relating to IETF Documents (<eref target="http://trustee.ietf.org/license-info">http://trustee.ietf.org/license-info</eref>)
              in effect on the date of publication of this document. Please
              review these documents carefully, as they describe your rights
              and restrictions with respect to this document.
              <xsl:if test="$submissionType='IETF'">
                Code Components extracted from this document must include
                Simplified BSD License text as described in Section 4.e of the
                Trust Legal Provisions and are provided without warranty as
                described in the Simplified BSD License.
              </xsl:if>
            </t>
          </xsl:when>
          <xsl:when test="$ipr-2009-09">
            <t>
              This document is subject to BCP 78 and the IETF Trust's Legal
              Provisions Relating to IETF Documents (<eref target="http://trustee.ietf.org/license-info">http://trustee.ietf.org/license-info</eref>)
              in effect on the date of publication of this document. Please
              review these documents carefully, as they describe your rights
              and restrictions with respect to this document. Code Components
              extracted from this document must include Simplified BSD License
              text as described in Section 4.e of the Trust Legal Provisions
              and are provided without warranty as described in the BSD License.
            </t>
          </xsl:when>
          <xsl:when test="$ipr-2009-02">
            <t>
              This document is subject to BCP 78 and the IETF Trust's Legal
              Provisions Relating to IETF Documents in effect on the date of
              publication of this document
              (<eref target="http://trustee.ietf.org/license-info">http://trustee.ietf.org/license-info</eref>).
              Please review these documents carefully, as they describe your rights and restrictions with
              respect to this document.
            </t>
          </xsl:when>
          <xsl:otherwise>
            <t>
              This document is subject to BCP 78 and the IETF Trust's Legal
              Provisions Relating to IETF Documents
              (<eref target="http://trustee.ietf.org/license-info">http://trustee.ietf.org/license-info</eref>) in effect on the date of
              publication of this document.  Please review these documents
              carefully, as they describe your rights and restrictions with respect
              to this document.
            </t>
          </xsl:otherwise>
        </xsl:choose>
        
        <!-- add warning for incpmpatible IPR attribute on RFCs -->
        <xsl:variable name="stds-rfc-compatible-ipr"
                      select="/rfc/@ipr='pre5378Trust200902' or /rfc/@ipr='trust200902' or /rfc/@ipr='trust200811' or /rfc/@ipr='full3978' or /rfc/@ipr='full3667' or /rfc/@ipr='full2026'"/>
        
        <xsl:variable name="rfc-compatible-ipr"
                      select="$stds-rfc-compatible-ipr or /rfc/@ipr='noModificationTrust200902' or /rfc/@ipr='noDerivativesTrust200902' or /rfc/@ipr='noModificationTrust200811' or /rfc/@ipr='noDerivativesTrust200811'"/>
                      <!-- TODO: may want to add more historic variants -->
                      
        <xsl:variable name="is-stds-track"
                      select="$submissionType='IETF' and /rfc/@category='std'"/>
        
        <xsl:variable name="status-diags">
          <xsl:choose>
            <xsl:when test="$is-stds-track and /rfc/@number and /rfc/@ipr and not($stds-rfc-compatible-ipr)">
              <xsl:value-of select="concat('The /rfc/@ipr attribute value of ',/rfc/@ipr,' is not allowed on standards-track RFCs.')"/>
            </xsl:when>
            <xsl:when test="/rfc/@number and /rfc/@ipr and not($rfc-compatible-ipr)">
              <xsl:value-of select="concat('The /rfc/@ipr attribute value of ',/rfc/@ipr,' is not allowed on RFCs.')"/>
            </xsl:when>
            <xsl:otherwise/>
          </xsl:choose>
        </xsl:variable>

        <xsl:choose>
          <xsl:when test="$status-diags!=''">
            <t>
              <spanx><xsl:value-of select="$status-diags"/></spanx>
            </t>
            <xsl:call-template name="error">
              <xsl:with-param name="msg" select="$status-diags"/>
              <xsl:with-param name="inline" select="'no'"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="(/rfc/@number or $pub-yearmonth >= 200911) and /rfc/@ipr = 'pre5378Trust200902'">
          <!-- special case: RFC5378 escape applies to RFCs as well -->
          <!-- for IDs historically in Status Of This Memo, over here starting 2009-11 -->
            <t>
              <xsl:value-of select="$pre5378EscapeClause"/>
            </t>
          </xsl:when>
          <xsl:when test="not(/rfc/@number)">
            <!-- not an RFC, handled elsewhere -->
          </xsl:when>
          <xsl:when test="not(/rfc/@ipr)">
            <!-- no IPR value; done -->
          </xsl:when>
          <xsl:when test="/rfc/@ipr='trust200902' or /rfc/@ipr='trust200811' or /rfc/@ipr='full3978' or /rfc/@ipr='full3667' or /rfc/@ipr='full2026'">
            <!-- default IPR, allowed here -->
          </xsl:when>
          <xsl:when test="/rfc/@ipr='noModificationTrust200811'">
            <t>
              <xsl:value-of select="$noModificationTrust200811Clause"/>
            </t>
          </xsl:when>
          <xsl:when test="/rfc/@ipr='noModificationTrust200902'">
            <t>
              <xsl:value-of select="$noModificationTrust200902Clause"/>
            </t>
          </xsl:when>
          <xsl:when test="/rfc/@ipr='noDerivativesTrust200902' or /rfc/@ipr='noDerivativesTrust200811'">
            <t>
              <xsl:value-of select="$noDerivativesTrust200___Clause"/>
            </t>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="msg" select="concat('unexpected value of /rfc/@ipr for this type of document: ',/rfc/@ipr)"/>
            <t>
              <spanx><xsl:value-of select="$msg"/></spanx>
            </t>
            <xsl:call-template name="error">
              <xsl:with-param name="msg" select="$msg"/>
              <xsl:with-param name="inline" select="'no'"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
        
      </section>
    </xsl:when>
    <xsl:when test="$ipr-2007-08">
      <!-- no copyright notice -->
    </xsl:when>
    <xsl:when test="$ipr-rfc4748">
      <section title="Copyright Notice" myns:unnumbered="unnumbered" myns:notoclink="notoclink" anchor="{$anchor-prefix}.copyrightnotice">
        <t>
          Copyright &#169; The IETF Trust (<xsl:value-of select="$xml2rfc-ext-pub-year" />).  All Rights Reserved.
        </t>
      </section>
    </xsl:when>
    <xsl:otherwise>
      <section title="Copyright Notice" myns:unnumbered="unnumbered" myns:notoclink="notoclink" anchor="{$anchor-prefix}.copyrightnotice">
        <t>
          Copyright &#169; The Internet Society (<xsl:value-of select="$xml2rfc-ext-pub-year" />).  All Rights Reserved.
        </t>
      </section>
    </xsl:otherwise>
  </xsl:choose>
  
</xsl:template>

<!-- TOC generation -->

<xsl:template match="/" mode="toc">
  <hr class="noprint"/>

  <h1 class="np" id="{$anchor-prefix}.toc"> <!-- this pagebreak occurs always -->
    <a href="#{$anchor-prefix}.toc">Table of Contents</a>
  </h1>

  <ul class="toc">
    <xsl:apply-templates mode="toc" />
  </ul>
</xsl:template>

<xsl:template name="insert-toc-line">
  <xsl:param name="number" />
  <xsl:param name="target" />
  <xsl:param name="title" />
  <xsl:param name="tocparam" />
  <xsl:param name="oldtitle" />
  <xsl:param name="waschanged" />

  <!-- handle tocdepth parameter -->
  <xsl:choose>
    <xsl:when test="($tocparam='' or $tocparam='default') and string-length(translate($number,'.ABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890&#167;','.')) &gt;= $parsedTocDepth">
      <!-- dropped entry because excluded -->
      <xsl:attribute name="class">excluded</xsl:attribute>
    </xsl:when>
    <xsl:when test="$tocparam='exclude'">
      <!-- dropped entry because excluded -->
      <xsl:attribute name="class">excluded</xsl:attribute>
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
        <xsl:when test="starts-with($number,'del-')">
          <del>
            <xsl:value-of select="$number" />
            <a href="#{$target}"><xsl:value-of select="$title"/></a>
          </del>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="$number != '' and not(contains($number,'unnumbered-'))">
            <a href="#{$anchor-prefix}.section.{$number}">
              <xsl:call-template name="emit-section-number">
                <xsl:with-param name="no" select="$number"/>
              </xsl:call-template>
            </a>
            <xsl:text>&#160;&#160;&#160;</xsl:text>
          </xsl:if>
          <a href="#{$target}">
            <xsl:choose>
              <xsl:when test="$waschanged!=''">
                <ins><xsl:value-of select="$title"/></ins>
                <del><xsl:value-of select="$oldtitle"/></del>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$title"/>
              </xsl:otherwise>
            </xsl:choose>
          </a>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="back-toc">

  <xsl:if test="//cref and $xml2rfc-comments='yes' and $xml2rfc-inline!='yes'">
    <li>
      <xsl:call-template name="insert-toc-line">
        <xsl:with-param name="target" select="concat($anchor-prefix,'.comments')"/>
        <xsl:with-param name="title" select="'Editorial Comments'"/>
      </xsl:call-template>
    </li>
  </xsl:if>

  <xsl:if test="$xml2rfc-ext-authors-section!='end'">
    <xsl:apply-templates select="/rfc/front" mode="toc" />
  </xsl:if>
  <xsl:apply-templates select="back/*[not(self::references)]" mode="toc" />

  <!-- insert the index if index entries exist -->
  <xsl:if test="$has-index">
    <li>
      <xsl:call-template name="insert-toc-line">
        <xsl:with-param name="target" select="concat($anchor-prefix,'.index')"/>
        <xsl:with-param name="title" select="'Index'"/>
      </xsl:call-template>
    </li>
  </xsl:if>

  <xsl:if test="$xml2rfc-ext-authors-section='end'">
    <xsl:apply-templates select="/rfc/front" mode="toc" />
  </xsl:if>

  <!-- copyright statements -->
  <xsl:if test="$xml2rfc-private='' and not($no-copylong)">
    <li>
      <xsl:call-template name="insert-toc-line">
        <xsl:with-param name="target" select="concat($anchor-prefix,'.ipr')"/>
        <xsl:with-param name="title" select="'Intellectual Property and Copyright Statements'"/>
      </xsl:call-template>
    </li>
  </xsl:if>
  
</xsl:template>

<xsl:template match="front" mode="toc">
  
  <xsl:variable name="authors-title">
    <xsl:call-template name="get-authors-section-title"/>
  </xsl:variable>
  <xsl:variable name="authors-number">
    <xsl:call-template name="get-authors-section-number"/>
  </xsl:variable>

  <xsl:if test="$authors-number!='suppress'">
    <li>
      <xsl:call-template name="insert-toc-line">
        <xsl:with-param name="target" select="concat($anchor-prefix,'.authors')"/>
        <xsl:with-param name="title" select="$authors-title"/>
        <xsl:with-param name="number" select="$authors-number"/>
      </xsl:call-template>
    </li>
  </xsl:if>

</xsl:template>

<xsl:template name="references-toc">

  <!-- distinguish two cases: (a) single references element (process
  as toplevel section; (b) multiple references sections (add one toplevel
  container with subsection) -->

  <xsl:variable name="refsecs" select="/rfc/back/references|/rfc/back/ed:replace/ed:ins/references"/>
   
  <xsl:choose>
    <xsl:when test="count($refsecs) = 0">
      <!-- nop -->
    </xsl:when>
    <xsl:when test="count($refsecs) = 1">
      <xsl:for-each select="$refsecs">
        <xsl:variable name="title">
          <xsl:choose>
            <xsl:when test="@title!=''"><xsl:value-of select="@title" /></xsl:when>
            <xsl:otherwise><xsl:value-of select="$xml2rfc-refparent"/></xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
      
        <li>
          <xsl:call-template name="insert-toc-line">
            <xsl:with-param name="number">
              <xsl:call-template name="get-references-section-number"/>
            </xsl:with-param>
            <xsl:with-param name="target" select="concat($anchor-prefix,'.references')"/>
            <xsl:with-param name="title" select="$title"/>
          </xsl:call-template>
        </li>
      </xsl:for-each>
    </xsl:when>
    <xsl:otherwise>
      <li>
        <!-- insert pseudo container -->    
        <xsl:call-template name="insert-toc-line">
          <xsl:with-param name="number">
            <xsl:call-template name="get-references-section-number"/>
          </xsl:with-param>
          <xsl:with-param name="target" select="concat($anchor-prefix,'.references')"/>
          <xsl:with-param name="title" select="$xml2rfc-refparent"/>
        </xsl:call-template>
  
        <ul>
          <!-- ...with subsections... -->    
          <xsl:for-each select="$refsecs">
            <xsl:variable name="title">
              <xsl:choose>
                <xsl:when test="@title!=''"><xsl:value-of select="@title" /></xsl:when>
                <xsl:otherwise><xsl:value-of select="$xml2rfc-refparent"/></xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
          
            <xsl:variable name="sectionNumber">
              <xsl:call-template name="get-section-number" />
            </xsl:variable>
    
            <xsl:variable name="num">
              <xsl:number level="any"/>
            </xsl:variable>
    
            <li>
              <xsl:call-template name="insert-toc-line">
                <xsl:with-param name="number" select="$sectionNumber"/>
                <xsl:with-param name="target" select="concat($anchor-prefix,'.references','.',$num)"/>
                <xsl:with-param name="title" select="$title"/>
              </xsl:call-template>
            </li>
          </xsl:for-each>
        </ul>
      </li>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="section|appendix" mode="toc">
  <xsl:variable name="sectionNumber">
    <xsl:call-template name="get-section-number" />
  </xsl:variable>

  <xsl:variable name="target">
    <xsl:choose>
      <xsl:when test="@anchor"><xsl:value-of select="@anchor" /></xsl:when>
       <xsl:otherwise><xsl:value-of select="$anchor-prefix"/>.section.<xsl:value-of select="$sectionNumber" /></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- obtain content, just to check whether we need to recurse at all -->
  <xsl:variable name="content">
    <li>
      <xsl:call-template name="insert-toc-line">
        <xsl:with-param name="number" select="$sectionNumber"/>
        <xsl:with-param name="target" select="$target"/>
        <xsl:with-param name="title" select="@title"/>
        <xsl:with-param name="tocparam" select="@toc"/>
        <xsl:with-param name="oldtitle" select="@ed:old-title"/>
        <xsl:with-param name="waschanged" select="@ed:resolves"/>
      </xsl:call-template>
    
      <ul>
        <xsl:apply-templates mode="toc" />
      </ul>
    </li>
  </xsl:variable>
  
  <xsl:if test="$content!=''">
    <li>
      <xsl:call-template name="insert-toc-line">
        <xsl:with-param name="number" select="$sectionNumber"/>
        <xsl:with-param name="target" select="$target"/>
        <xsl:with-param name="title" select="@title"/>
        <xsl:with-param name="tocparam" select="@toc"/>
        <xsl:with-param name="oldtitle" select="@ed:old-title"/>
        <xsl:with-param name="waschanged" select="@ed:resolves"/>
      </xsl:call-template>
    
      <!-- obtain nested content, just to check whether we need to recurse at all -->
      <xsl:variable name="nested-content">
        <ul>
          <xsl:apply-templates mode="toc" />
        </ul>
      </xsl:variable>
      
      <!-- only recurse if we need to (do not produce useless list container) -->      
      <xsl:if test="$nested-content!=''">
        <ul>
          <xsl:apply-templates mode="toc" />
        </ul>
      </xsl:if>
    </li>
  </xsl:if>
</xsl:template>

<xsl:template match="middle" mode="toc">
  <xsl:apply-templates mode="toc" />
  <xsl:call-template name="references-toc" />
</xsl:template>

<xsl:template match="rfc" mode="toc">
  <xsl:apply-templates select="middle" mode="toc" />
  <xsl:call-template name="back-toc" />
</xsl:template>

<xsl:template match="ed:del|ed:ins|ed:replace" mode="toc">
  <xsl:apply-templates mode="toc" />
</xsl:template>

<xsl:template match="*|text()" mode="toc" />


<xsl:template name="insertTocAppendix">
  
  <xsl:if test="//figure[@title!='' or @anchor!='']">
    <ul class="toc">
      <li>Figures
        <ul>
          <xsl:for-each select="//figure[@title!='' or @anchor!='']">
            <xsl:variable name="title">Figure <xsl:value-of select="position()"/><xsl:if test="@title">: <xsl:value-of select="@title"/></xsl:if>
            </xsl:variable>
            <li>
              <xsl:call-template name="insert-toc-line">
                <xsl:with-param name="target" select="concat($anchor-prefix,'.figure.',position())" />
                <xsl:with-param name="title" select="$title" />
              </xsl:call-template>
            </li>
          </xsl:for-each>
        </ul>
      </li>
    </ul>
  </xsl:if>
  
  <!-- experimental -->
  <xsl:if test="//ed:issue">
    <xsl:call-template name="insertIssuesList" />
  </xsl:if>

</xsl:template>

<xsl:template name="referencename">
  <xsl:param name="node" />
  
  <xsl:for-each select="$node">
    <xsl:choose>
      <xsl:when test="$xml2rfc-symrefs!='no' and ancestor::ed:del">
        <xsl:variable name="unprefixed" select="substring-after(@anchor,'deleted-')"/>
        <xsl:choose>
          <xsl:when test="$unprefixed!=''">
            <xsl:value-of select="concat('[',$unprefixed,']')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:if test="count(//reference[@anchor=current()/@anchor])!=1">
              <xsl:message>Deleted duplicate anchors should have the prefix "deleted-": <xsl:value-of select="@anchor"/></xsl:message>
            </xsl:if>
            <xsl:value-of select="concat('[',@anchor,']')"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$xml2rfc-symrefs!='no'">[<xsl:value-of select="@anchor" />]</xsl:when>
      <xsl:when test="ancestor::ed:del">
        <xsl:text>[del]</xsl:text>
      </xsl:when>
      <xsl:otherwise>[<xsl:number level="any" count="reference[not(ancestor::ed:del)]"/>]</xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>  
</xsl:template>



<xsl:template name="replace-substring">
  <xsl:param name="string" />
  <xsl:param name="replace" />
  <xsl:param name="by" />

  <xsl:choose>
    <xsl:when test="contains($string,$replace)">
      <xsl:value-of select="concat(substring-before($string, $replace),$by)" />
      <xsl:call-template name="replace-substring">
        <xsl:with-param name="string" select="substring-after($string,$replace)" />
        <xsl:with-param name="replace" select="$replace" />
        <xsl:with-param name="by" select="$by" />
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise><xsl:value-of select="$string" /></xsl:otherwise>
  </xsl:choose>

</xsl:template>

<xsl:template name="rfc-or-id-link">
  <xsl:param name="name" />
  
  <xsl:choose>
    <xsl:when test="starts-with($name,'draft-')">
      <a href="{concat($internetDraftUrlPrefix,$name,$internetDraftUrlPostfix)}"><xsl:value-of select="$name"/></a>
      <xsl:call-template name="check-front-matter-ref">
        <xsl:with-param name="name" select="$name"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="string(number($name))=$name">
      <a href="{concat($rfcUrlPrefix,$name,$rfcUrlPostfix)}"><xsl:value-of select="$name"/></a>
      <xsl:call-template name="check-front-matter-ref">
        <xsl:with-param name="name" select="$name"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$name"/>
      <xsl:call-template name="warning">
        <xsl:with-param name="msg" select="concat('In metadata obsoletes/updates, RFC number of draft name is expected - found: ',$name)"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="rfclist">
  <xsl:param name="list" />
  <xsl:choose>
    <xsl:when test="contains($list,',')">
      <xsl:variable name="rfcNo" select="substring-before($list,',')" />
      <xsl:call-template name="rfc-or-id-link">
        <xsl:with-param name="name" select="$rfcNo"/>
      </xsl:call-template>
      <xsl:text>, </xsl:text>
      <xsl:call-template name="rfclist">
        <xsl:with-param name="list" select="normalize-space(substring-after($list,','))" />
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="rfcNo" select="$list" />
      <xsl:call-template name="rfc-or-id-link">
        <xsl:with-param name="name" select="$rfcNo"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="check-front-matter-ref">
  <xsl:param name="name"/>
  <xsl:choose>
    <xsl:when test="starts-with($name,'draft-')">
      <xsl:if test="not(//references//reference/seriesInfo[@name='Internet-Draft' and @value=$name])">
        <xsl:call-template name="warning">
          <xsl:with-param name="msg" select="concat('front matter mentions I-D ',$name,' for which there is no reference element')"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:when>
    <xsl:otherwise>
      <xsl:if test="not(//references//reference/seriesInfo[@name='RFC' and @value=$name])">
        <xsl:call-template name="warning">
          <xsl:with-param name="msg" select="concat('front matter mentions RFC ',$name,' for which there is no reference element')"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="check-anchor">
  <xsl:if test="@anchor and @anchor!=''">
    <!-- check validity of anchor name -->
    <xsl:variable name="t" select="@anchor"/>
    <xsl:variable name="tstart" select="substring($t,1,1)"/>

    <!-- we only check for disallowed ASCII characters for now -->
    <xsl:variable name="not-namestartchars">&#9;&#10;&#13;&#32;!"#$%&amp;'()*+,-./0123456789;&lt;=&gt;?@[\]^`[|}~</xsl:variable>

    <xsl:if test="$tstart!=translate($tstart,$not-namestartchars,'')">
      <xsl:call-template name="error">
        <xsl:with-param name="msg" select="concat('anchor &quot;',$t,'&quot; can not start with character &quot;',$tstart,'&quot;')"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:call-template name="check-anchor-non-start">
      <xsl:with-param name="f" select="$t"/>
      <xsl:with-param name="t" select="$t"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<xsl:template name="check-anchor-non-start">
  <xsl:param name="f"/>
  <xsl:param name="t"/>

  <xsl:variable name="not-namechars">&#9;&#10;&#13;&#32;!"#$%&amp;'()*+,/;&lt;=&gt;?@[\]^`[|}~</xsl:variable>

  <xsl:choose>
    <xsl:when test="$t=''">
      <!-- Done -->
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="s" select="substring($t,1,1)"/>
      <xsl:choose>
        <xsl:when test="$s!=translate($s,$not-namechars,'')">
          <xsl:call-template name="error">
            <xsl:with-param name="msg" select="concat('anchor &quot;',$f,'&quot; contains invalid character &quot;',$s,'&quot; at position ',string-length($f) - string-length($t))"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="check-anchor-non-start">
            <xsl:with-param name="f" select="$f"/>
            <xsl:with-param name="t" select="substring($t,2)"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="copy-anchor">
  <xsl:call-template name="check-anchor"/>
  <xsl:if test="@anchor and @anchor!=''">
    <xsl:attribute name="id"><xsl:value-of select="@anchor"/></xsl:attribute>
  </xsl:if>
</xsl:template>

<xsl:template name="rfclist-for-dcmeta">
  <xsl:param name="list" />
  <xsl:choose>
    <xsl:when test="contains($list,',')">
      <xsl:variable name="rfcNo" select="substring-before($list,',')" />
      <meta name="dct.replaces" content="urn:ietf:rfc:{$rfcNo}" />
      <xsl:call-template name="rfclist-for-dcmeta">
        <xsl:with-param name="list" select="normalize-space(substring-after($list,','))" />
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="rfcNo" select="$list" />
      <meta name="dct.replaces" content="urn:ietf:rfc:{$rfcNo}" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="get-paragraph-number">
  <!-- get section number of ancestor section element, then add t or figure number -->
  <xsl:if test="ancestor::section and not(ancestor::section[@myns:unnumbered='unnumbered']) and not(ancestor::x:blockquote) and not(ancestor::x:note)">
    <xsl:for-each select="ancestor::section[1]"><xsl:call-template name="get-section-number" />.p.</xsl:for-each><xsl:number count="t|figure|x:blockquote|x:note" />
  </xsl:if>
</xsl:template>

<xsl:template name="editingMark">
  <xsl:if test="$xml2rfc-editing='yes' and ancestor::rfc">
    <sup class="editingmark"><span><xsl:number level="any" count="postamble|preamble|t"/></span>&#0160;</sup>
  </xsl:if>
</xsl:template>

<!-- internal ref support -->
<xsl:key name="anchor-item-alias" match="//*[@anchor and (x:anchor-alias/@value or ed:replace/ed:ins/x:anchor-alias)]" use="x:anchor-alias/@value | ed:replace/ed:ins/x:anchor-alias/@value"/>

<xsl:template match="x:ref">
  <xsl:variable name="val" select="normalize-space(.)"/>
  <xsl:variable name="target" select="key('anchor-item',$val) | key('anchor-item-alias',$val) | //reference/x:source[x:defines=$val]"/>
  <xsl:variable name="irefs" select="//iref[@x:for-anchor=$val]"/>
  <xsl:if test="count($target)>1">
    <xsl:call-template name="warning">
      <xsl:with-param name="msg">internal link target for '<xsl:value-of select="."/>' is ambiguous; picking first.</xsl:with-param>
    </xsl:call-template>
  </xsl:if>
  <xsl:choose>
    <xsl:when test="$target[1]/@anchor">
      <a href="#{$target[1]/@anchor}" class="smpl">
        <xsl:call-template name="copy-anchor"/>
        <!-- to be indexed? -->
        <xsl:if test="$irefs">
          <xsl:attribute name="id"><xsl:call-template name="compute-extref-anchor"/></xsl:attribute>
        </xsl:if>
        <xsl:value-of select="."/>
      </a>
    </xsl:when>
    <xsl:when test="$target[1]/self::x:source">
      <xsl:variable name="extdoc" select="document($target[1]/@href)"/>
      <xsl:variable name="nodes" select="$extdoc//*[@anchor and (x:anchor-alias/@value=$val)]"/>
      <xsl:if test="not($nodes)">
        <xsl:call-template name="error">
          <xsl:with-param name="msg">Anchor '<xsl:value-of select="$val"/>' not found in source file '<xsl:value-of select="$target[1]/@href"/>'.</xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <xsl:variable name="t">
        <xsl:call-template name="computed-auto-target">
          <xsl:with-param name="bib" select="$target[1]/.."/>
          <xsl:with-param name="ref" select="$nodes[1]"/>
        </xsl:call-template>
      </xsl:variable>
      <a href="{$t}" class="smpl">
        <xsl:value-of select="."/>
      </a>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="warning">
        <xsl:with-param name="msg">internal link target for '<xsl:value-of select="."/>' does not exist.</xsl:with-param>
      </xsl:call-template>
      <xsl:value-of select="."/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Nothing to do here -->
<xsl:template match="x:anchor-alias" />

<!-- Quotes -->
<xsl:template match="x:q">
  <q>
    <xsl:copy-of select="@cite"/>
    <xsl:apply-templates/>
  </q>
</xsl:template>

<!-- Notes -->
<xsl:template match="x:note">
  <xsl:variable name="p">
    <xsl:call-template name="get-paragraph-number" />
  </xsl:variable>

  <div class="note">
    <xsl:if test="$p!='' and not(ancestor::ed:del) and not(ancestor::ed:ins)">
      <xsl:attribute name="id"><xsl:value-of select="$anchor-prefix"/>.section.<xsl:value-of select="$p"/></xsl:attribute>
    </xsl:if>
    <xsl:apply-templates/>
  </div>
</xsl:template>

<xsl:template match="x:bcp14">
  <!-- check valid BCP14 keywords, then emphasize them -->
  <xsl:variable name="c" select="normalize-space(.)"/>
  <xsl:choose>
    <xsl:when test="$c='MUST' or $c='REQUIRED' or $c='SHALL'">
      <em class="bcp14"><xsl:value-of select="."/></em>
    </xsl:when>
    <xsl:when test="$c='MUST NOT' or $c='SHALL NOT'">
      <em class="bcp14"><xsl:value-of select="."/></em>
    </xsl:when>
    <xsl:when test="$c='SHOULD' or $c='RECOMMENDED'">
      <em class="bcp14"><xsl:value-of select="."/></em>
    </xsl:when>
    <xsl:when test="$c='SHOULD NOT' or $c='NOT RECOMMENDED'">
      <em class="bcp14"><xsl:value-of select="."/></em>
    </xsl:when>
    <xsl:when test="$c='MAY' or $c='OPTIONAL'">
      <em class="bcp14"><xsl:value-of select="."/></em>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="."/>
      <xsl:message>ERROR: unknown BCP14 keyword: <xsl:value-of select="."/></xsl:message>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="x:blockquote">
  <xsl:variable name="p">
    <xsl:call-template name="get-paragraph-number" />
  </xsl:variable>

  <blockquote>
    <xsl:if test="string-length($p) &gt; 0 and not(ancestor::ed:del) and not(ancestor::ed:ins)">
      <xsl:attribute name="id"><xsl:value-of select="$anchor-prefix"/>.section.<xsl:value-of select="$p"/></xsl:attribute>
    </xsl:if>
    <xsl:call-template name="insertInsDelClass"/>
    <xsl:call-template name="editingMark" />
    <xsl:copy-of select="@cite"/>
    <xsl:apply-templates/>
  </blockquote>
</xsl:template>

<!-- Definitions -->
<xsl:template match="x:dfn">
  <dfn>
    <xsl:call-template name="copy-anchor"/>
    <xsl:apply-templates/>
  </dfn>
</xsl:template>

<!-- headings -->
<xsl:template match="x:h">
  <b>
    <xsl:call-template name="copy-anchor"/>
    <xsl:apply-templates/>
  </b>
</xsl:template>

<!-- superscripts -->
<xsl:template match="x:sup">
  <sup>
    <xsl:apply-templates/>
  </sup>
</xsl:template>

<!-- bold -->
<xsl:template match="x:highlight">
  <b>
    <xsl:call-template name="copy-anchor"/>
    <xsl:apply-templates/>
  </b>
</xsl:template>

<!-- measuring lengths -->
<xsl:template match="x:length-of">
  <xsl:variable name="target" select="//*[@anchor=current()/@target]"/>
  <xsl:if test="count($target)!=1">
    <xsl:call-template name="error">
      <xsl:with-param name="msg" select="concat('@target ',@target,' defined ',count($target),' times.')"/>
    </xsl:call-template>
  </xsl:if>
  <xsl:variable name="content">
    <xsl:apply-templates select="$target"/>
  </xsl:variable>
  <xsl:variable name="lineends" select="string-length($content) - string-length(translate($content,'&#10;',''))"/>
  <xsl:variable name="indents">
    <xsl:choose>
      <xsl:when test="@indented">
        <xsl:value-of select="number(@indented) * $lineends"/>
      </xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:value-of select="string-length($content) + $lineends - $indents"/>
</xsl:template>

<!-- Nop -->
<xsl:template match="x:span">
  <span>
    <xsl:call-template name="copy-anchor"/>
    <xsl:apply-templates/>
  </span>
</xsl:template>

<xsl:template match="x:parse-xml">
  <xsl:apply-templates/>

  <xsl:if test="function-available('exslt:node-set')">
    <xsl:variable name="cleaned">
      <xsl:apply-templates mode="cleanup-edits"/>
    </xsl:variable>
    <xsl:if test="$xml2rfc-ext-trace-parse-xml='yes'">
      <xsl:call-template name="trace">
        <xsl:with-param name="msg" select="concat('Parsing XML: ', $cleaned)"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="function-available('myns:parseXml')" use-when="function-available('myns:parseXml')">
        <xsl:if test="myns:parseXml(concat($cleaned,''))!=''">
          <xsl:call-template name="error">
            <xsl:with-param name="msg" select="concat('Parse error in XML: ', myns:parseXml(concat($cleaned,'')))"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:when>
      <xsl:when test="function-available('saxon:parse')" use-when="function-available('saxon:parse')">
        <xsl:variable name="parsed" select="saxon:parse(concat($cleaned,''))"/>
        <xsl:if test="$parsed='foo'">
          <xsl:comment>should not get here</xsl:comment>
        </xsl:if>
      </xsl:when>
      <xsl:when test="false()"></xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
  </xsl:if>
</xsl:template>

<!-- inlined RDF support -->
<xsl:template match="rdf:Description">
  <!-- ignore -->
</xsl:template>

<!-- cleanup for ins/del -->

<xsl:template match="comment()|@*" mode="cleanup-edits"><xsl:copy/></xsl:template>

<xsl:template match="text()" mode="cleanup-edits"><xsl:copy/></xsl:template>

<xsl:template match="/" mode="cleanup-edits">
  <xsl:copy><xsl:apply-templates select="node()" mode="cleanup-edits" /></xsl:copy>
</xsl:template>

<xsl:template match="ed:del" mode="cleanup-edits"/>

<xsl:template match="ed:replace" mode="cleanup-edits">
  <xsl:apply-templates mode="cleanup-edits"/>
</xsl:template>

<xsl:template match="ed:ins" mode="cleanup-edits">
  <xsl:apply-templates mode="cleanup-edits"/>
</xsl:template>


<!-- ABNF support -->
<xsl:template name="to-abnf-char-sequence">
  <xsl:param name="chars"/>
  
  <xsl:variable name="c" select="substring($chars,1,1)"/>
  <xsl:variable name="r" select="substring($chars,2)"/>
    
  <xsl:choose>
    <xsl:when test="$c='-'">2D</xsl:when>
    <xsl:when test="$c='/'">2F</xsl:when>
    <xsl:when test="$c='0'">30</xsl:when>
    <xsl:when test="$c='1'">31</xsl:when>
    <xsl:when test="$c='2'">32</xsl:when>
    <xsl:when test="$c='3'">33</xsl:when>
    <xsl:when test="$c='4'">34</xsl:when>
    <xsl:when test="$c='5'">35</xsl:when>
    <xsl:when test="$c='6'">36</xsl:when>
    <xsl:when test="$c='7'">37</xsl:when>
    <xsl:when test="$c='8'">38</xsl:when>
    <xsl:when test="$c='9'">39</xsl:when>
    <xsl:when test="$c='A'">41</xsl:when>
    <xsl:when test="$c='B'">42</xsl:when>
    <xsl:when test="$c='C'">43</xsl:when>
    <xsl:when test="$c='D'">44</xsl:when>
    <xsl:when test="$c='E'">45</xsl:when>
    <xsl:when test="$c='F'">46</xsl:when>
    <xsl:when test="$c='G'">47</xsl:when>
    <xsl:when test="$c='H'">48</xsl:when>
    <xsl:when test="$c='I'">49</xsl:when>
    <xsl:when test="$c='J'">4A</xsl:when>
    <xsl:when test="$c='K'">4B</xsl:when>
    <xsl:when test="$c='L'">4C</xsl:when>
    <xsl:when test="$c='M'">4D</xsl:when>
    <xsl:when test="$c='N'">4E</xsl:when>
    <xsl:when test="$c='O'">4F</xsl:when>
    <xsl:when test="$c='P'">50</xsl:when>
    <xsl:when test="$c='Q'">51</xsl:when>
    <xsl:when test="$c='R'">52</xsl:when>
    <xsl:when test="$c='S'">53</xsl:when>
    <xsl:when test="$c='T'">54</xsl:when>
    <xsl:when test="$c='U'">55</xsl:when>
    <xsl:when test="$c='V'">56</xsl:when>
    <xsl:when test="$c='W'">57</xsl:when>
    <xsl:when test="$c='X'">58</xsl:when>
    <xsl:when test="$c='Y'">59</xsl:when>
    <xsl:when test="$c='Z'">5A</xsl:when>
    <xsl:when test="$c='a'">61</xsl:when>
    <xsl:when test="$c='b'">62</xsl:when>
    <xsl:when test="$c='c'">63</xsl:when>
    <xsl:when test="$c='d'">64</xsl:when>
    <xsl:when test="$c='e'">65</xsl:when>
    <xsl:when test="$c='f'">66</xsl:when>
    <xsl:when test="$c='g'">67</xsl:when>
    <xsl:when test="$c='h'">68</xsl:when>
    <xsl:when test="$c='i'">69</xsl:when>
    <xsl:when test="$c='j'">6A</xsl:when>
    <xsl:when test="$c='k'">6B</xsl:when>
    <xsl:when test="$c='l'">6C</xsl:when>
    <xsl:when test="$c='m'">6D</xsl:when>
    <xsl:when test="$c='n'">6E</xsl:when>
    <xsl:when test="$c='o'">6F</xsl:when>
    <xsl:when test="$c='p'">70</xsl:when>
    <xsl:when test="$c='q'">71</xsl:when>
    <xsl:when test="$c='r'">72</xsl:when>
    <xsl:when test="$c='s'">73</xsl:when>
    <xsl:when test="$c='t'">74</xsl:when>
    <xsl:when test="$c='u'">75</xsl:when>
    <xsl:when test="$c='v'">76</xsl:when>
    <xsl:when test="$c='w'">77</xsl:when>
    <xsl:when test="$c='x'">78</xsl:when>
    <xsl:when test="$c='y'">79</xsl:when>
    <xsl:when test="$c='z'">7A</xsl:when>
    <xsl:otherwise>
      <xsl:text>??</xsl:text>
      <xsl:call-template name="error">
        <xsl:with-param name="msg" select="concat('unexpected character in ABNF char sequence: ',substring($chars,1,1))" />
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>

  <xsl:if test="$r!=''">
    <xsl:text>.</xsl:text>
    <xsl:call-template name="to-abnf-char-sequence">
      <xsl:with-param name="chars" select="$r"/>
    </xsl:call-template>
  </xsl:if>
  
</xsl:template>

<xsl:template match="x:abnf-char-sequence">
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

<!-- box drawing -->

<!-- nop for alignment -->
<xsl:template match="x:x"/>

<!-- box (top) -->
<xsl:template match="x:bt">
  <xsl:text>&#x250c;</xsl:text>
  <xsl:value-of select="translate(substring(.,2,string-length(.)-2),'-','&#x2500;')"/>
  <xsl:text>&#x2510;</xsl:text>
</xsl:template>

<!-- box (center) -->
<xsl:template match="x:bc">
  <xsl:variable name="first" select="substring(.,1)"/>
  <xsl:variable name="content" select="substring(.,2,string-length(.)-2)"/>
  <xsl:variable name="is-delimiter" select="translate($content,'-','')=''"/>
  
  <xsl:choose>
    <xsl:when test="$is-delimiter">
      <xsl:text>&#x251c;</xsl:text>
      <xsl:value-of select="translate($content,'-','&#x2500;')"/>
      <xsl:text>&#x2524;</xsl:text>
    </xsl:when>
    <xsl:when test="*">
      <xsl:for-each select="node()">
        <xsl:choose>
          <xsl:when test="position()=1">
            <xsl:text>&#x2502;</xsl:text>
            <xsl:value-of select="substring(.,2)"/>
          </xsl:when>
          <xsl:when test="position()=last()">
            <xsl:value-of select="substring(.,1,string-length(.)-1)"/>
            <xsl:text>&#x2502;</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>&#x2502;</xsl:text>
      <xsl:value-of select="$content"/>
      <xsl:text>&#x2502;</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
  
</xsl:template>

<!-- box (bottom) -->
<xsl:template match="x:bb">
  <xsl:text>&#x2514;</xsl:text>
  <xsl:value-of select="translate(substring(.,2,string-length(.)-2),'-','&#x2500;')"/>
  <xsl:text>&#x2518;</xsl:text>
</xsl:template>

<!-- author handling extensions -->
<xsl:template match="x:include-author">
  <xsl:for-each select="/*/front/author[@anchor=current()/@target]">
    <xsl:apply-templates select="."/>
  </xsl:for-each>
</xsl:template>

<!-- boilerplate -->
<xsl:template match="x:boilerplate">
  <xsl:apply-templates/>
</xsl:template>

<!-- experimental annotation support -->

<xsl:template match="ed:issueref">
  <xsl:choose>
    <xsl:when test=".=//ed:issue/@name">
      <a href="#{$anchor-prefix}.issue.{.}">
        <xsl:apply-templates/>
      </a>
    </xsl:when>
    <xsl:when test="@href">
      <a href="{@href}" id="{$anchor-prefix}.issue.{.}">
        <xsl:apply-templates/>
      </a>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="warning">
        <xsl:with-param name="msg">Dangling ed:issueref: <xsl:value-of select="."/></xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="ed:issue">
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="@status='closed'">closedissue</xsl:when>
      <xsl:otherwise>openissue</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <table class="{$class}">
    <tr>
      <td colspan="3">
        <a id="{$anchor-prefix}.issue.{@name}">
          <xsl:choose>
            <xsl:when test="@status='closed'">
              <xsl:attribute name="class">closed-issue</xsl:attribute>
            </xsl:when>
            <xsl:when test="@status='editor'">
              <xsl:attribute name="class">editor-issue</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="class">open-issue</xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:text>&#160;I&#160;</xsl:text>
        </a>
        <xsl:text>&#160;</xsl:text>
        <xsl:choose>
          <xsl:when test="@href">
            <em><a href="{@href}"><xsl:value-of select="@name" /></a></em>
          </xsl:when>
          <xsl:when test="@alternate-href">
            <em>[<a href="{@alternate-href}">alternate link</a>]</em>
          </xsl:when>
          <xsl:otherwise>
            <em><xsl:value-of select="@name" /></em>
          </xsl:otherwise>
        </xsl:choose>
        &#0160;
        (type: <xsl:value-of select="@type"/>, status: <xsl:value-of select="@status"/>)
      </td>
    </tr>

    <xsl:apply-templates select="ed:item"/>
    <xsl:apply-templates select="ed:resolution"/>

    <xsl:variable name="changes" select="//*[@ed:resolves=current()/@name or ed:resolves=current()/@name]" />
    <xsl:if test="$changes">
      <tr>
        <td class="top" colspan="3">
          Associated changes in this document:
          <xsl:variable name="issue" select="@name"/>
          <xsl:for-each select="$changes">
            <a href="#{$anchor-prefix}.change.{$issue}.{position()}">
              <xsl:variable name="label">
                <xsl:call-template name="get-section-number"/>
              </xsl:variable>
              <xsl:choose>
                <xsl:when test="$label!=''"><xsl:value-of select="$label"/></xsl:when>
                <xsl:otherwise>&lt;<xsl:value-of select="concat('#',$anchor-prefix,'.change.',$issue,'.',position())"/>&gt;</xsl:otherwise>
              </xsl:choose>
            </a>
            <xsl:if test="position()!=last()">, </xsl:if>
          </xsl:for-each>
          <xsl:text>.</xsl:text>
        </td>
      </tr>
    </xsl:if>
  </table>
    
</xsl:template>

<xsl:template match="ed:item">
  <tr>
    <td class="top">
      <xsl:if test="@entered-by">
        <a href="mailto:{@entered-by}?subject={/rfc/@docName},%20{../@name}">
          <i><xsl:value-of select="@entered-by"/></i>
        </a>
      </xsl:if>
    </td>
    <td class="topnowrap">
      <xsl:value-of select="@date"/>
    </td>
    <td class="top">
      <xsl:apply-templates select="node()" mode="issuehtml"/>
    </td>
  </tr>
</xsl:template>

<xsl:template match="ed:resolution">
  <tr>
    <td class="top">
      <xsl:if test="@entered-by">
        <a href="mailto:{@entered-by}?subject={/rfc/@docName},%20{../@name}"><i><xsl:value-of select="@entered-by"/></i></a>
      </xsl:if>
    </td>
    <td class="topnowrap">
      <xsl:value-of select="@datetime"/>
    </td>
    <td class="top">
      <em>Resolution:</em>
      <xsl:apply-templates select="node()" mode="issuehtml"/>
    </td>
  </tr>
</xsl:template>

<xsl:template match="ed:annotation">
  <em>
    <xsl:apply-templates/>
  </em>
</xsl:template>

<!-- special templates for handling XHTML in issues -->
<xsl:template match="text()" mode="issuehtml">
  <xsl:value-of select="."/>
</xsl:template>

<xsl:template match="*|@*" mode="issuehtml">
  <xsl:message terminate="yes">Unexpected node in issue HTML: <xsl:value-of select="name(.)"/></xsl:message>
</xsl:template>

<xsl:template match="xhtml:a|xhtml:b|xhtml:br|xhtml:cite|xhtml:del|xhtml:em|xhtml:i|xhtml:ins|xhtml:q|xhtml:pre|xhtml:tt" mode="issuehtml">
  <xsl:element name="{local-name()}">
    <xsl:apply-templates select="@*|node()" mode="issuehtml"/>
  </xsl:element>
</xsl:template>

<xsl:template match="xhtml:p" mode="issuehtml">
  <xsl:apply-templates select="node()" mode="issuehtml"/>
  <br class="p"/>
</xsl:template>

<xsl:template match="xhtml:a/@href|xhtml:q/@cite" mode="issuehtml">
  <xsl:attribute name="{local-name(.)}">
    <xsl:value-of select="."/>
  </xsl:attribute>
</xsl:template>

<xsl:template match="ed:issueref" mode="issuehtml">
  <xsl:apply-templates select="."/>
</xsl:template>

<xsl:template match="ed:eref" mode="issuehtml">
  <xsl:text>&lt;</xsl:text>
  <a href="{.}"><xsl:value-of select="."/></a>
  <xsl:text>&gt;</xsl:text>
</xsl:template>

<xsl:template name="insertIssuesList">

  <h2 id="{$anchor-prefix}.issues-list" ><a href="#{$anchor-prefix}.issues-list">Issues list</a></h2>
  <table>
    <thead>
      <tr>
        <th>Id</th>
        <th>Type</th>
        <th>Status</th>
        <th>Date</th>
        <th>Raised By</th>
      </tr>
    </thead>
    <tbody>
      <xsl:for-each select="//ed:issue">
        <xsl:sort select="@status" />
        <xsl:sort select="@name" />
        <tr>
          <td><a href="#{$anchor-prefix}.issue.{@name}"><xsl:value-of select="@name" /></a></td>
          <td><xsl:value-of select="@type" /></td>
          <td><xsl:value-of select="@status" /></td>
          <td><xsl:value-of select="ed:item[1]/@date" /></td>
          <td><a href="mailto:{ed:item[1]/@entered-by}?subject={/rfc/@docName},%20{@name}"><xsl:value-of select="ed:item[1]/@entered-by" /></a></td>
        </tr>
      </xsl:for-each>
    </tbody>
  </table>
  
</xsl:template>

<xsl:template name="insert-diagnostics">
  
  <!-- check anchor names -->
  <xsl:variable name="badAnchors"
    select="//*[starts-with(@anchor,concat($anchor-prefix,'.'))][@anchor!=concat($anchor-prefix,'.authors') and /*/x:assign-section-number[@number='suppress' and @builtin-target='authors']]" />
  
  <xsl:if test="$badAnchors">
    <xsl:variable name="text">
      The following anchor names may collide with internally generated anchors because of their prefix "<xsl:value-of select="$anchor-prefix" />":
      <xsl:for-each select="$badAnchors">
        <xsl:value-of select="@anchor"/><xsl:if test="position()!=last()">, </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:call-template name="warning">
      <xsl:with-param name="msg"><xsl:value-of select="$text"/></xsl:with-param>
    </xsl:call-template>
  </xsl:if>
  
  <!-- check ABNF syntax references -->
  <xsl:if test="//artwork[@type='abnf2616']">
    <xsl:if test="not(//reference/seriesInfo[@name='RFC' and (@value='2068' or @value='2616')])">
      <xsl:call-template name="warning">
        <xsl:with-param name="msg">document uses HTTP-style ABNF syntax, but doesn't reference RFC 2068 or 2616.</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:if>
  <xsl:if test="//artwork[@type='abnf']">
    <xsl:if test="not(//reference/seriesInfo[@name='RFC' and (@value='2234' or @value='4234' or @value='5234')])">
      <xsl:call-template name="warning">
        <xsl:with-param name="msg">document uses ABNF syntax, but doesn't reference RFC 2234, 4234 or 5234.</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:if>
  
  <!-- check IDs -->
  <xsl:variable name="badTargets" select="//xref[not(@target=//@anchor) and not(ancestor::ed:del)]" />
  <xsl:if test="$badTargets">
    <xsl:variable name="text">
      <xsl:text>The following target names do not exist: </xsl:text>
      <xsl:for-each select="$badTargets">
        <xsl:value-of select="@target"/>
        <xsl:if test="not(@target)">(@target attribute missing)</xsl:if>
        <xsl:call-template name="lineno"/>
        <xsl:if test="position()!=last()">
          <xsl:text>, </xsl:text>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:call-template name="warning">
      <xsl:with-param name="msg"><xsl:value-of select="$text"/></xsl:with-param>
    </xsl:call-template>
  </xsl:if>
 
  
</xsl:template>

<!-- special change mark support, not supported by RFC2629 yet -->

<xsl:template match="@ed:*" />

<xsl:template match="ed:del">
  <xsl:call-template name="insert-issue-pointer"/>
  <del>
    <xsl:copy-of select="@*[namespace-uri()='']"/>
    <xsl:if test="not(@title) and ancestor-or-self::*[@ed:entered-by] and @datetime">
      <xsl:attribute name="title"><xsl:value-of select="concat(@datetime,', ',ancestor-or-self::*[@ed:entered-by][1]/@ed:entered-by)"/></xsl:attribute>
    </xsl:if>
    <xsl:apply-templates />
  </del>
</xsl:template>

<xsl:template match="ed:ins">
  <xsl:call-template name="insert-issue-pointer"/>
  <ins>
    <xsl:copy-of select="@*[namespace-uri()='']"/>
    <xsl:if test="not(@title) and ancestor-or-self::*[@ed:entered-by] and @datetime">
      <xsl:attribute name="title"><xsl:value-of select="concat(@datetime,', ',ancestor-or-self::*[@ed:entered-by][1]/@ed:entered-by)"/></xsl:attribute>
    </xsl:if>
    <xsl:apply-templates />
  </ins>
</xsl:template>

<xsl:template name="insert-issue-pointer">
  <xsl:param name="deleted-anchor"/>
  <xsl:variable name="change" select="."/>
  <xsl:for-each select="@ed:resolves|ed:resolves">
    <xsl:variable name="resolves" select="."/>
    <!-- need the right context node for proper numbering -->
    <xsl:variable name="count"><xsl:for-each select=".."><xsl:number level="any" count="*[@ed:resolves=$resolves or ed:resolves=$resolves]" /></xsl:for-each></xsl:variable>
    <xsl:variable name="total" select="count(//*[@ed:resolves=$resolves or ed:resolves=$resolves])" />
    <xsl:variable name="id">
      <xsl:value-of select="$anchor-prefix"/>.change.<xsl:value-of select="$resolves"/>.<xsl:value-of select="$count" />
    </xsl:variable>
    <xsl:choose>
      <!-- block level? -->
      <xsl:when test="not(ancestor::t) and not(ancestor::title) and not(ancestor::figure) and not($change/@ed:old-title)">
        <div class="issuepointer noprint">
          <xsl:if test="not($deleted-anchor)">
            <xsl:attribute name="id"><xsl:value-of select="$id"/></xsl:attribute>
          </xsl:if>
          <xsl:if test="$count > 1">
            <a class="bg-issue" title="previous change for {$resolves}" href="#{$anchor-prefix}.change.{$resolves}.{$count - 1}">&#x2191;</a>
          </xsl:if>
          <a class="open-issue" href="#{$anchor-prefix}.issue.{$resolves}" title="resolves: {$resolves}">
            <xsl:choose>
              <xsl:when test="//ed:issue[@name=$resolves and @status='closed']">
                <xsl:attribute name="class">closed-issue</xsl:attribute>
              </xsl:when>
              <xsl:when test="//ed:issue[@name=$resolves and @status='editor']">
                <xsl:attribute name="class">editor-issue</xsl:attribute>
              </xsl:when>
              <xsl:otherwise>
                <xsl:attribute name="class">open-issue</xsl:attribute>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:text>&#160;I&#160;</xsl:text>
          </a>
          <xsl:if test="$count &lt; $total">
            <a class="bg-issue" title="next change for {$resolves}" href="#{$anchor-prefix}.change.{$resolves}.{$count + 1}">&#x2193;</a>
          </xsl:if>
          <xsl:text>&#160;</xsl:text>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="$count > 1">
          <a class="bg-issue" title="previous change for {$resolves}" href="#{$anchor-prefix}.change.{$resolves}.{$count - 1}">&#x2191;</a>
        </xsl:if>
        <a title="resolves: {$resolves}" href="#{$anchor-prefix}.issue.{$resolves}">
          <xsl:if test="not($deleted-anchor)">
            <xsl:attribute name="id"><xsl:value-of select="$id"/></xsl:attribute>
          </xsl:if>
          <xsl:choose>
            <xsl:when test="//ed:issue[@name=$resolves and @status='closed']">
              <xsl:attribute name="class">closed-issue noprint</xsl:attribute>
            </xsl:when>
            <xsl:when test="//ed:issue[@name=$resolves and @status='editor']">
              <xsl:attribute name="class">editor-issue noprint</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="class">open-issue noprint</xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:text>&#160;I&#160;</xsl:text>
        </a>
        <xsl:if test="$count &lt; $total">
          <a class="bg-issue" title="next change for {$resolves}" href="#{$anchor-prefix}.change.{$resolves}.{$count + 1}">&#x2193;</a>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</xsl:template>

<xsl:template match="ed:replace">
  <!-- we need to special-case things like lists and tables -->
  <xsl:choose>
    <xsl:when test="parent::list">
      <xsl:apply-templates select="ed:del/node()" />
      <xsl:apply-templates select="ed:ins/node()" />
    </xsl:when>
    <xsl:when test="parent::references">
      <xsl:apply-templates select="ed:del/node()" />
      <xsl:apply-templates select="ed:ins/node()" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:if test="@cite">
        <a class="editor-issue" href="{@cite}" target="_blank" title="see {@cite}">
          <xsl:text>&#160;i&#160;</xsl:text>
        </a>
      </xsl:if>
      <xsl:call-template name="insert-issue-pointer"/>
      <xsl:if test="ed:del">
        <del>
          <xsl:copy-of select="@*[namespace-uri()='']"/>
          <xsl:if test="not(@title) and ancestor-or-self::xsl:template[@ed:entered-by] and @datetime">
            <xsl:attribute name="title"><xsl:value-of select="concat(@datetime,', ',ancestor-or-self::*[@ed:entered-by][1]/@ed:entered-by)"/></xsl:attribute>
          </xsl:if>
          <xsl:apply-templates select="ed:del/node()" />
        </del>
      </xsl:if>
      <xsl:if test="ed:ins">
        <ins>
          <xsl:copy-of select="@*[namespace-uri()='']"/>
          <xsl:if test="not(@title) and ancestor-or-self::*[@ed:entered-by] and @datetime">
            <xsl:attribute name="title"><xsl:value-of select="concat(@datetime,', ',ancestor-or-self::*[@ed:entered-by][1]/@ed:entered-by)"/></xsl:attribute>
          </xsl:if>
          <xsl:apply-templates select="ed:ins/node()" />
        </ins>
      </xsl:if>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- convenience template for helping Mozilla (pre/ins inheritance problem) -->
<xsl:template name="insertInsDelClass">
  <xsl:if test="ancestor::ed:del">
    <xsl:attribute name="class">del</xsl:attribute>
  </xsl:if>
  <xsl:if test="ancestor::ed:ins">
    <xsl:attribute name="class">ins</xsl:attribute>
  </xsl:if>
</xsl:template>


<xsl:template name="sectionnumberAndEdits">
  <xsl:choose>
    <xsl:when test="ancestor::ed:del">
      <xsl:text>del-</xsl:text>
      <xsl:number count="ed:del//section" level="any"/>
    </xsl:when>
    <xsl:when test="@x:fixed-section-number and @x:fixed-section-number!=''">
      <xsl:value-of select="@x:fixed-section-number"/>
    </xsl:when>
    <xsl:when test="@x:fixed-section-number and @x:fixed-section-number=''">
      <xsl:text>unnumbered-</xsl:text>
      <xsl:number count="section[@x:fixed-section-number='']" level="any"/>
    </xsl:when>
    <xsl:when test="self::section and parent::ed:ins and local-name(../..)='replace'">
      <xsl:for-each select="../.."><xsl:call-template name="sectionnumberAndEdits" /></xsl:for-each>
      <xsl:for-each select="..">
        <xsl:if test="parent::ed:replace">
          <xsl:for-each select="..">
            <xsl:if test="parent::section">.</xsl:if>
            <xsl:variable name="cnt" select="1+count(preceding-sibling::section|preceding-sibling::ed:ins/section|preceding-sibling::ed:replace/ed:ins/section)" />
            <xsl:choose>
              <xsl:when test="ancestor::back and not(ancestor::section)"><xsl:number format="A" value="$cnt"/></xsl:when>
              <xsl:otherwise><xsl:value-of select="$cnt"/></xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </xsl:if>
      </xsl:for-each>
    </xsl:when>
    <xsl:when test="self::section[parent::ed:ins]">
      <xsl:for-each select="../.."><xsl:call-template name="sectionnumberAndEdits" /></xsl:for-each>
      <xsl:for-each select="..">
        <xsl:if test="parent::section">.</xsl:if><xsl:value-of select="1+count(preceding-sibling::section|preceding-sibling::ed:ins/section|preceding-sibling::ed:replace/ed:ins/section)" />
      </xsl:for-each>
    </xsl:when>
    <xsl:when test="self::section">
      <xsl:for-each select=".."><xsl:call-template name="sectionnumberAndEdits" /></xsl:for-each>
      <xsl:if test="parent::section">.</xsl:if>
      <xsl:choose>
        <xsl:when test="parent::back">
          <xsl:number format="A" value="1+count(preceding-sibling::section|preceding-sibling::ed:ins/section|preceding-sibling::ed:replace/ed:ins/section)" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:number value="1+count(preceding-sibling::section|preceding-sibling::ed:ins/section|preceding-sibling::ed:replace/ed:ins/section)" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="self::references">
      <xsl:choose>
        <xsl:when test="count(/*/back/references)+count(/*/back/ed:replace/ed:ins/references)=1"><xsl:call-template name="get-references-section-number"/></xsl:when>
        <xsl:otherwise><xsl:call-template name="get-references-section-number"/>.<xsl:number level="any"/></xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="self::middle or self::back"><!-- done --></xsl:when>
    <xsl:otherwise>
      <!-- go up one level -->
      <xsl:for-each select=".."><xsl:call-template name="sectionnumberAndEdits" /></xsl:for-each>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- utilities for warnings -->

<xsl:template name="trace">
  <xsl:param name="msg"/>
  <xsl:param name="msg2"/>
  <xsl:param name="inline"/>
  <xsl:call-template name="emit-message">
    <xsl:with-param name="level">TRACE</xsl:with-param>
    <xsl:with-param name="msg" select="$msg"/>
    <xsl:with-param name="msg2" select="$msg2"/>
    <xsl:with-param name="inline" select="$inline"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="inline-warning">
  <xsl:param name="msg"/>
  <xsl:param name="msg2"/>
  <xsl:call-template name="emit-message">
    <xsl:with-param name="level">WARNING</xsl:with-param>
    <xsl:with-param name="msg" select="$msg"/>
    <xsl:with-param name="msg2" select="$msg2"/>
    <xsl:with-param name="inline" select="'yes'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="warning">
  <xsl:param name="msg"/>
  <xsl:param name="msg2"/>
  <xsl:param name="inline"/>
  <xsl:call-template name="emit-message">
    <xsl:with-param name="level">WARNING</xsl:with-param>
    <xsl:with-param name="msg" select="$msg"/>
    <xsl:with-param name="msg2" select="$msg2"/>
    <xsl:with-param name="inline" select="'no'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="info">
  <xsl:param name="msg"/>
  <xsl:param name="msg2"/>
  <xsl:param name="inline"/>
  <xsl:call-template name="emit-message">
    <xsl:with-param name="level">INFO</xsl:with-param>
    <xsl:with-param name="msg" select="$msg"/>
    <xsl:with-param name="msg2" select="$msg2"/>
    <xsl:with-param name="inline" select="$inline"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="error">
  <xsl:param name="msg"/>
  <xsl:param name="msg2"/>
  <xsl:param name="inline"/>
  <xsl:call-template name="emit-message">
    <xsl:with-param name="level">ERROR</xsl:with-param>
    <xsl:with-param name="msg" select="$msg"/>
    <xsl:with-param name="msg2" select="$msg2"/>
    <xsl:with-param name="inline" select="$inline"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="emit-message">
  <xsl:param name="level"/>
  <xsl:param name="msg"/>
  <xsl:param name="msg2"/>
  <xsl:param name="inline"/>
  <xsl:variable name="message"><xsl:value-of select="$level"/>: <xsl:value-of select="$msg"/><xsl:value-of select="$msg2"/><xsl:call-template name="lineno"/></xsl:variable>
  <xsl:choose>
    <xsl:when test="$inline!='no'">
      <div class="error"><xsl:value-of select="$message"/></div>
    </xsl:when>
    <xsl:otherwise>
      <!-- this fails when the message contains characters not encodable in the output encoding -->
      <!-- <xsl:comment><xsl:value-of select="$message"/></xsl:comment> -->
    </xsl:otherwise>
  </xsl:choose>
  <xsl:message><xsl:value-of select="$message"/></xsl:message>
</xsl:template>

<!-- table formatting -->

<xsl:template match="texttable">

  <xsl:variable name="anch">
    <xsl:call-template name="get-table-anchor"/>
  </xsl:variable>

  <div id="{$anch}">

    <xsl:if test="@anchor!=''">
      <div id="{@anchor}"/>
    </xsl:if>
    <xsl:apply-templates select="preamble" />
    <xsl:variable name="style">
      <xsl:text>tt </xsl:text>
      <xsl:choose>
        <xsl:when test="@style!=''">
          <xsl:value-of select="@style"/>
        </xsl:when>
        <xsl:otherwise>full</xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="@align='left'"> left</xsl:when>
        <xsl:when test="@align='right'"> right</xsl:when>
        <xsl:when test="@align='center' or not(@align) or @align=''"> center</xsl:when>
        <xsl:otherwise/>
      </xsl:choose>

    </xsl:variable>

    <table class="{$style}" cellpadding="3" cellspacing="0">
      <xsl:if test="(@title!='' or @anchor!='') and not(@suppress-title='true')">
        <xsl:variable name="n"><xsl:number level="any" count="texttable[(@title!='' or @anchor!='') and not(@suppress-title='true')]" /></xsl:variable>
        <caption>Table <xsl:value-of select="$n"/><xsl:if test="@title!=''">: <xsl:value-of select="@title" /></xsl:if></caption>
      </xsl:if>

      <xsl:if test="ttcol!=''">
        <!-- skip header when all column titles are empty -->
        <thead>
          <tr>
            <xsl:apply-templates select="ttcol" />
          </tr>
        </thead>
      </xsl:if>
      <tbody>
        <xsl:variable name="columns" select="count(ttcol)" />
        <xsl:variable name="fields" select="c | ed:replace/ed:ins/c | ed:replace/ed:del/c" />
        <xsl:for-each select="$fields[$columns=1 or (position() mod $columns) = 1]">
          <tr>
            <xsl:for-each select=". | following-sibling::c[position() &lt; $columns]">
              <td>
                <xsl:if test="@anchor">
                  <xsl:call-template name="check-anchor"/>
                  <xsl:attribute name="id">
                    <xsl:value-of select="@anchor"/>
                  </xsl:attribute>
                </xsl:if>
                <xsl:call-template name="insertInsDelClass"/>
                <xsl:variable name="pos" select="position()" />
                <xsl:variable name="col" select="../ttcol[position() = $pos]" />
                <xsl:choose>
                  <xsl:when test="$col/@align='right' or $col/@align='center'">
                    <xsl:attribute name="class"><xsl:value-of select="$col/@align"/></xsl:attribute>
                  </xsl:when>
                  <xsl:when test="$col/@align='left' or not($col/@align)">
                    <xsl:attribute name="class">left</xsl:attribute>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:call-template name="warning">
                      <xsl:with-param name="msg">Unknown align attribute on ttcol: <xsl:value-of select="$col/@align"/></xsl:with-param>                      
                    </xsl:call-template>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates select="node()" />
              </td>
            </xsl:for-each>
          </tr>
        </xsl:for-each>
      </tbody>
    </table>
    <xsl:apply-templates select="postamble" />
  </div>
  
</xsl:template>

<xsl:template match="ttcol">
  <th>
    
    <xsl:choose>
      <xsl:when test="@align='right' or @align='center' or @align='left'">
        <xsl:attribute name="class"><xsl:value-of select="@align"/></xsl:attribute>
      </xsl:when>
      <xsl:when test="not(@align)">
        <!-- that's the default, nothing to do here -->
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>Unknown align attribute on ttcol: <xsl:value-of select="@align"/></xsl:message>
      </xsl:otherwise>
    </xsl:choose>
    
    <xsl:if test="@width">
      <xsl:attribute name="style">width: <xsl:value-of select="@width" />;</xsl:attribute>
    </xsl:if>

    <xsl:apply-templates />
  </th>
</xsl:template>

<!-- cref support -->

<xsl:template name="get-comment-name">
  <xsl:choose>
    <xsl:when test="@anchor">
      <xsl:value-of select="@anchor"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$anchor-prefix"/>
      <xsl:text>.comment.</xsl:text>
      <xsl:number count="cref[not(@anchor)]" level="any"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="cref">
  <xsl:if test="$xml2rfc-comments!='no'">
    <xsl:variable name="cid">
      <xsl:call-template name="get-comment-name"/>
    </xsl:variable>
    
    <span class="comment">
      <xsl:choose>
        <xsl:when test="$xml2rfc-inline='yes'">
          <xsl:attribute name="id">
            <xsl:value-of select="$cid"/>
          </xsl:attribute>
          <xsl:text>[</xsl:text>
          <a href="#{$cid}" class="smpl">
            <xsl:value-of select="$cid"/>
          </a>
          <xsl:text>: </xsl:text>
          <xsl:apply-templates select="text()|eref|xref"/>
          <xsl:if test="@source"> --<xsl:value-of select="@source"/></xsl:if>
          <xsl:text>]</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="title">
            <xsl:if test="@source"><xsl:value-of select="@source"/>: </xsl:if>
            <xsl:variable name="content">
              <xsl:apply-templates select="text()|eref|xref"/>
            </xsl:variable>
            <xsl:value-of select="$content"/>
          </xsl:attribute>
          <xsl:text>[</xsl:text>
          <a href="#{$cid}">
            <xsl:value-of select="$cid"/>
          </a>
          <xsl:text>]</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </span>
  </xsl:if>
</xsl:template>

<xsl:template name="insertComments">

  <xsl:call-template name="insert-conditional-hrule"/>
    
  <h1>
    <xsl:call-template name="insert-conditional-pagebreak"/>
    <a id="{$anchor-prefix}.comments" href="#{$anchor-prefix}.comments">Editorial Comments</a>
  </h1>

  <dl>
    <xsl:for-each select="//cref">
      <xsl:variable name="cid">
        <xsl:choose>
          <xsl:when test="@anchor">
            <xsl:value-of select="@anchor"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$anchor-prefix"/>
            <xsl:text>.comment.</xsl:text>
            <xsl:number count="cref[not(@anchor)]" level="any"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <dt id="{$cid}">
        [<xsl:value-of select="$cid"/>]
      </dt>
      <dd>
        <xsl:apply-templates select="node()"/>
        <xsl:if test="@source"> --<xsl:value-of select="@source"/></xsl:if>
      </dd>
    </xsl:for-each>
  </dl>
</xsl:template>


<!-- Chapter Link Generation -->

<xsl:template match="*" mode="links"><xsl:apply-templates mode="links"/></xsl:template>
<xsl:template match="text()" mode="links" />

<xsl:template match="/*/middle//section[not(myns:unnumbered) and not(ancestor::section)]" mode="links">
  <xsl:variable name="sectionNumber"><xsl:call-template name="get-section-number" /></xsl:variable>
  <xsl:variable name="title">
    <xsl:if test="$sectionNumber!='' and not(contains($sectionNumber,'unnumbered-'))">
      <xsl:value-of select="$sectionNumber"/>
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:value-of select="@title"/>
  </xsl:variable>
  <link rel="Chapter" title="{$title}" href="#{$anchor-prefix}.section.{$sectionNumber}"/>
  <xsl:apply-templates mode="links" />
</xsl:template>

<xsl:template match="/*/back//section[not(myns:unnumbered) and not(ancestor::section)]" mode="links">
  <xsl:variable name="sectionNumber"><xsl:call-template name="get-section-number" /></xsl:variable>
  <xsl:variable name="title">
    <xsl:if test="$sectionNumber!='' and not(contains($sectionNumber,'unnumbered-'))">
      <xsl:value-of select="$sectionNumber"/>
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:value-of select="@title"/>
  </xsl:variable>
  <link rel="Appendix" title="{$title}" href="#{$anchor-prefix}.section.{$sectionNumber}"/>
  <xsl:apply-templates mode="links" />
</xsl:template>

<xsl:template match="/*/back/references[position()=1]" mode="links">
  <xsl:variable name="sectionNumber"><xsl:call-template name="get-references-section-number" /></xsl:variable>
  <link rel="Chapter" href="#{$anchor-prefix}.section.{$sectionNumber}">
    <xsl:choose>
      <xsl:when test="@title and count(/*/back/references)=1">
        <xsl:attribute name="title">
          <xsl:call-template name="get-references-section-number"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="@title"/>
        </xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="title">
          <xsl:call-template name="get-references-section-number"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="$xml2rfc-refparent"/>
        </xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
  </link>
</xsl:template>

<!-- convenience templates -->

<xsl:template name="get-author-summary">
  <xsl:choose>
    <xsl:when test="count(/rfc/front/author)=1">
      <xsl:value-of select="/rfc/front/author[1]/@surname" />
    </xsl:when>
    <xsl:when test="count(/rfc/front/author)=2">
      <xsl:value-of select="concat(/rfc/front/author[1]/@surname,' &amp; ',/rfc/front/author[2]/@surname)" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="concat(/rfc/front/author[1]/@surname,', et al.')" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="get-bottom-center">
  <xsl:choose>
    <xsl:when test="/rfc/@docName">
      <!-- for IDs, use the expiry date -->
      <xsl:text>Expires </xsl:text><xsl:call-template name="expirydate" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="get-category-long"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="get-category-long">
  <xsl:choose>
    <xsl:when test="$xml2rfc-footer!=''"><xsl:value-of select="$xml2rfc-footer" /></xsl:when>
    <xsl:when test="$xml2rfc-private!=''"/> <!-- private draft, footer not set -->
    <xsl:when test="/rfc/@category='bcp'">Best Current Practice</xsl:when>
    <xsl:when test="/rfc/@category='historic'">Historic</xsl:when>
    <xsl:when test="/rfc/@category='info' or not(/rfc/@category)">Informational</xsl:when>
    <xsl:when test="/rfc/@category='std'">Standards Track</xsl:when>
    <xsl:when test="/rfc/@category='exp'">Experimental</xsl:when>
    <xsl:otherwise>(category unknown)</xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="get-header-center">
  <xsl:choose>
    <xsl:when test="string-length(/rfc/front/title/@abbrev) &gt; 0">
      <xsl:value-of select="/rfc/front/title/@abbrev" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="/rfc/front/title" mode="get-text-content" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="get-header-left">
  <xsl:choose>
    <xsl:when test="$xml2rfc-header!=''"><xsl:value-of select="$xml2rfc-header" /></xsl:when>
    <xsl:when test="$xml2rfc-private!=''"/> <!-- private draft, header not set -->
    <xsl:when test="/rfc/@ipr and not(/rfc/@number)">Internet-Draft</xsl:when>
    <xsl:otherwise>RFC <xsl:value-of select="/rfc/@number"/></xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="get-generator">
  <xsl:variable name="gen">
    <xsl:text>http://greenbytes.de/tech/webdav/rfc2629.xslt, </xsl:text>
    <!-- when RCS keyword substitution in place, add version info -->
    <xsl:if test="contains('$Revision: 1.594 $',':')">
      <xsl:value-of select="concat('Revision ',normalize-space(translate(substring-after('$Revision: 1.594 $', 'Revision: '),'$','')),', ')" />
    </xsl:if>
    <xsl:if test="contains('$Date: 2013/04/30 16:11:28 $',':')">
      <xsl:value-of select="concat(normalize-space(translate(substring-after('$Date: 2013/04/30 16:11:28 $', 'Date: '),'$','')),', ')" />
    </xsl:if>
    <xsl:value-of select="concat('XSLT vendor: ',system-property('xsl:vendor'),' ',system-property('xsl:vendor-url'))" />
  </xsl:variable>
  <xsl:value-of select="$gen" />
</xsl:template>

<xsl:template name="get-header-right">
  <xsl:value-of select="concat($xml2rfc-ext-pub-month, ' ', $xml2rfc-ext-pub-year)" />
</xsl:template>

<xsl:template name="get-keywords">
  <xsl:for-each select="/rfc/front/keyword">
    <xsl:if test="contains(.,',')">
      <xsl:call-template name="warning">
        <xsl:with-param name="msg">keyword element appears to contain a comma-separated list, split into multiple elements instead.</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:value-of select="normalize-space(.)" />
    <xsl:if test="position()!=last()">, </xsl:if>
  </xsl:for-each>
</xsl:template>

<!-- get language from context node. nearest ancestor or return the default of "en" -->
<xsl:template name="get-lang">
  <xsl:choose>
    <xsl:when test="ancestor-or-self::*[@xml:lang]"><xsl:value-of select="ancestor-or-self::*/@xml:lang" /></xsl:when>
    <xsl:otherwise>en</xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="get-section-number">
  <xsl:variable name="anchor" select="@anchor"/>
  <xsl:choose>
    <xsl:when test="@x:fixed-section-number and @x:fixed-section-number!=''">
      <xsl:value-of select="@x:fixed-section-number"/>
    </xsl:when>
    <xsl:when test="@x:fixed-section-number and @x:fixed-section-number=''">
      <xsl:text>unnumbered-</xsl:text>
      <xsl:number count="section[@x:fixed-section-number='']" level="any"/>
    </xsl:when>
    <xsl:when test="$has-edits or ancestor::*/@x:fixed-section-number">
      <xsl:call-template name="sectionnumberAndEdits" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
        <xsl:when test="self::references">
          <xsl:choose>
            <xsl:when test="count(/*/back/references)=1">
              <xsl:call-template name="get-references-section-number"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="get-references-section-number"/>.<xsl:number count="references"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="self::reference">
          <xsl:for-each select="parent::references">
            <xsl:choose>
              <xsl:when test="count(/*/back/references)=1">
                <xsl:call-template name="get-references-section-number"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="get-references-section-number"/>.<xsl:number count="references"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="ancestor::reference">
          <xsl:for-each select="ancestor::reference">
            <xsl:call-template name="get-section-number"/>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="ancestor::back"><xsl:number count="section|appendix" level="multiple" format="A.1.1.1.1.1.1.1" /></xsl:when>
        <xsl:when test="self::appendix"><xsl:number count="appendix" level="multiple" format="A.1.1.1.1.1.1.1" /></xsl:when>
        <xsl:otherwise><xsl:number count="section" level="multiple"/></xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- get the section number for the references section -->
<xsl:template name="get-references-section-number">
  <xsl:value-of select="count(/rfc/middle/section) + count(/rfc/middle/ed:replace/ed:ins/section) + 1"/>
</xsl:template>

<xsl:template name="emit-section-number">
  <xsl:param name="no"/>
  <xsl:value-of select="$no"/><xsl:if test="not(contains($no,'.')) or $xml2rfc-ext-sec-no-trailing-dots='yes'">.</xsl:if>
</xsl:template>

<xsl:template name="get-section-type">
  <xsl:param name="prec" /> <!-- TODO: check this, it's unused -->
  <xsl:choose>
    <xsl:when test="ancestor::back">Appendix</xsl:when>
    <xsl:otherwise>Section</xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="get-table-anchor">
  <xsl:value-of select="$anchor-prefix"/>
  <xsl:text>.table.</xsl:text>
  <xsl:choose>
    <xsl:when test="@title!='' or @anchor!=''">
      <xsl:number level="any" count="texttable[@title!='' or @anchor!='']" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>u.</xsl:text>
      <xsl:number level="any" count="texttable[not(@title!='' or @anchor!='')]" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="get-figure-anchor">
  <xsl:value-of select="$anchor-prefix"/>
  <xsl:text>.figure.</xsl:text>
  <xsl:choose>
    <xsl:when test="@title!='' or @anchor!=''">
      <xsl:number level="any" count="figure[@title!='' or @anchor!='']" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>u.</xsl:text>
      <xsl:number level="any" count="figure[not(@title!='' or @anchor!='')]" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- reformat contents of author/@initials -->
<xsl:template name="format-initials">
  <xsl:variable name="r">
    <xsl:call-template name="t-format-initials">
      <xsl:with-param name="remainder" select="normalize-space(@initials)"/>
    </xsl:call-template>
  </xsl:variable>
  
  <xsl:if test="$r!=@initials">
    <xsl:call-template name="warning">
      <xsl:with-param name="msg">@initials '<xsl:value-of select="@initials"/>': did you mean '<xsl:value-of select="$r"/>'?</xsl:with-param>
    </xsl:call-template>
  </xsl:if>
  
  <xsl:value-of select="$r"/>
</xsl:template>

<xsl:template name="t-format-initials">
  <xsl:param name="have"/>
  <xsl:param name="remainder"/>
  
  <xsl:variable name="first" select="substring($remainder,1,1)"/>
  <xsl:variable name="prev" select="substring($have,string-length($have))"/>

<!--<xsl:message>
have: <xsl:value-of select="$have"/>
remainder: <xsl:value-of select="$remainder"/>
first: <xsl:value-of select="$first"/>
prev: <xsl:value-of select="$prev"/>
</xsl:message>-->

  <xsl:choose>
    <xsl:when test="$remainder='' and $prev!='.'">
      <xsl:value-of select="concat($have,'.')"/>
    </xsl:when>
    <xsl:when test="$remainder=''">
      <xsl:value-of select="$have"/>
    </xsl:when>
    <xsl:when test="$prev='.' and $first='.'">
      <!-- repeating dots -->
      <xsl:call-template name="t-format-initials">
        <xsl:with-param name="have" select="$have"/>
        <xsl:with-param name="remainder" select="substring($remainder,2)"/>
      </xsl:call-template>
    </xsl:when>
    <!-- missing dot before '-' -->
<!--    <xsl:when test="$prev!='.' and $first='-'">
      <xsl:call-template name="t-format-initials">
        <xsl:with-param name="have" select="concat($have,'.-')"/>
        <xsl:with-param name="remainder" select="substring($remainder,2)"/>
      </xsl:call-template>
    </xsl:when>-->
    <!-- missing space after '.' -->
<!--    <xsl:when test="$prev='.' and $first!=' '">
      <xsl:call-template name="t-format-initials">
        <xsl:with-param name="have" select="concat($have,' ',$first)"/>
        <xsl:with-param name="remainder" select="substring($remainder,2)"/>
      </xsl:call-template>
    </xsl:when>-->
    <xsl:otherwise>
      <xsl:call-template name="t-format-initials">
        <xsl:with-param name="have" select="concat($have,$first)"/>
        <xsl:with-param name="remainder" select="substring($remainder,2)"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
  
</xsl:template>

<xsl:template name="extract-normalized">
  <xsl:param name="node"/>
  <xsl:param name="name"/>
  <xsl:variable name="text" select="normalize-space($node)"/>
  <xsl:if test="string-length($node) != string-length($text)">
    <xsl:call-template name="warning">
      <xsl:with-param name="msg">excessive whitespace in <xsl:value-of select="$name"/>: '<xsl:value-of select="$node"/>'</xsl:with-param>
    </xsl:call-template>
  </xsl:if>
  <xsl:if test="$text=''">
    <xsl:call-template name="warning">
      <xsl:with-param name="msg">missing text in <xsl:value-of select="$name"/></xsl:with-param>
    </xsl:call-template>
  </xsl:if>
  <xsl:value-of select="$text"/>
</xsl:template>

<!-- checking for email element -->
<xsl:template name="extract-email">
  <xsl:variable name="email" select="normalize-space(.)"/>
  <xsl:if test="string-length(.) != string-length($email) or contains($email,' ')">
    <xsl:call-template name="warning">
      <xsl:with-param name="msg">excessive whitespace in email address: '<xsl:value-of select="."/>'</xsl:with-param>
    </xsl:call-template>
  </xsl:if>
  
  <xsl:variable name="email2">
    <xsl:choose>
      <xsl:when test="starts-with($email,'mailto:')">
        <xsl:call-template name="warning">
          <xsl:with-param name="msg">email should not include URI scheme: '<xsl:value-of select="."/>'</xsl:with-param>
        </xsl:call-template>
        <xsl:value-of select="substring($email, 1 + string-length('mailto:'))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$email"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:value-of select="$email2"/>
</xsl:template>

<!-- checking for uri element -->
<xsl:template name="extract-uri">
  <xsl:variable name="uri" select="normalize-space(.)"/>
  <xsl:if test="string-length(.) != string-length($uri) or contains($uri,' ')">
    <xsl:call-template name="warning">
      <xsl:with-param name="msg">excessive whitespace in URI: '<xsl:value-of select="."/>'</xsl:with-param>
    </xsl:call-template>
  </xsl:if>
  <xsl:if test="$uri=''">
    <xsl:call-template name="warning">
      <xsl:with-param name="msg">URI is empty</xsl:with-param>
    </xsl:call-template>
  </xsl:if>
  
  <xsl:value-of select="$uri"/>
</xsl:template>

<xsl:template name="insert-conditional-pagebreak">
  <xsl:if test="$xml2rfc-compact!='yes'">
    <xsl:attribute name="class">np</xsl:attribute>
  </xsl:if>
</xsl:template>

<xsl:template name="insert-conditional-hrule">
  <xsl:if test="$xml2rfc-compact!='yes'">
    <hr class="noprint" />
  </xsl:if>
</xsl:template>

<!-- get text content from marked-up text -->

<xsl:template match="text()" mode="get-text-content">
  <xsl:value-of select="."/>
</xsl:template>

<xsl:template match="*" mode="get-text-content">
  <xsl:apply-templates mode="get-text-content"/>
</xsl:template>

<xsl:template match="ed:del" mode="get-text-content">
</xsl:template>

<!-- parsing of processing instructions -->
<xsl:template name="parse-pis">
  <xsl:param name="nodes"/>
  <xsl:param name="attr"/>
  <xsl:param name="sep"/>
  <xsl:param name="ret"/>
  <xsl:param name="default"/>
  
  <xsl:choose>
    <xsl:when test="count($nodes)=0">
      <xsl:choose>
        <xsl:when test="$ret!=''">
          <xsl:value-of select="$ret"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$default"/>
        </xsl:otherwise>    
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="ret2">
        <xsl:for-each select="$nodes[1]">
          <xsl:call-template name="parse-one-pi">
            <xsl:with-param name="str" select="."/>
            <xsl:with-param name="attr" select="$attr"/>
            <xsl:with-param name="sep" select="$sep"/>
            <xsl:with-param name="ret" select="$ret"/>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:variable>
      
      <xsl:call-template name="parse-pis">
        <xsl:with-param name="nodes" select="$nodes[position()!=1]"/>
        <xsl:with-param name="attr" select="$attr"/>
        <xsl:with-param name="sep" select="$sep"/>
        <xsl:with-param name="ret" select="$ret2"/>
        <xsl:with-param name="default" select="$default"/>
      </xsl:call-template>
      
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>

<xsl:template name="parse-one-pi">
  <xsl:param name="str"/>
  <xsl:param name="attr"/>
  <xsl:param name="sep"/>
  <xsl:param name="ret"/>

  <xsl:variable name="str2">
    <xsl:call-template name="eat-leading-whitespace">
      <xsl:with-param name="str" select="$str"/>
    </xsl:call-template>
  </xsl:variable>
  
  <xsl:choose>
    <xsl:when test="$str2=''">
      <!-- done -->
      <xsl:value-of select="$ret"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="attrname" select="substring-before($str2,'=')"/>
      
      <xsl:choose>
        <xsl:when test="$attrname=''">
          <xsl:call-template name="warning">
            <xsl:with-param name="msg">bad PI syntax: <xsl:value-of select="$str2"/></xsl:with-param>
          </xsl:call-template>
          <xsl:value-of select="$ret"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="remainder" select="substring($str2,2+string-length($attrname))"/>
          <xsl:choose>
            <xsl:when test="string-length($remainder) &lt; 2">
              <xsl:call-template name="warning">
                <xsl:with-param name="msg">bad PI value syntax: <xsl:value-of select="$remainder"/></xsl:with-param>
              </xsl:call-template>
              <xsl:value-of select="$ret"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:variable name="rem">
                <xsl:call-template name="eat-leading-whitespace">
                  <xsl:with-param name="str" select="$remainder"/>
                </xsl:call-template>
              </xsl:variable>
              <xsl:variable name="qchars">&apos;&quot;</xsl:variable>
              <xsl:variable name="qchar" select="substring($rem,1,1)"/>
              <xsl:variable name="rem2" select="substring($rem,2)"/>
              <xsl:choose>
                <xsl:when test="not(contains($qchars,$qchar))">
                  <xsl:call-template name="warning">
                    <xsl:with-param name="msg">pseudo-attribute value needs to be quoted: <xsl:value-of select="$rem"/></xsl:with-param>
                  </xsl:call-template>
                  <xsl:value-of select="$ret"/>
                </xsl:when>
                <xsl:when test="not(contains($rem2,$qchar))">
                  <xsl:call-template name="warning">
                    <xsl:with-param name="msg">unmatched quote in: <xsl:value-of select="$rem2"/></xsl:with-param>
                  </xsl:call-template>
                  <xsl:value-of select="$ret"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:variable name="value" select="substring-before($rem2,$qchar)"/>

                  <!-- check pseudo-attribute names -->
                  <xsl:if test="name()='rfc-ext' and $attr='SANITYCHECK'">
                    <xsl:choose>
                      <xsl:when test="$attrname='allow-markup-in-artwork'"/>
                      <xsl:when test="$attrname='authors-section'"/>
                      <xsl:when test="$attrname='check-artwork-width'"/>
                      <xsl:when test="$attrname='duplex'"/>
                      <xsl:when test="$attrname='include-index'"/>
                      <xsl:when test="$attrname='include-references-in-index'"/>
                      <xsl:when test="$attrname='justification'"/>
                      <xsl:when test="$attrname='parse-xml-in-artwork'"/>
                      <xsl:when test="$attrname='sec-no-trailing-dots'"/>
                      <xsl:when test="$attrname='trace-parse-xml'"/>
                      <xsl:when test="$attrname='vspace-pagebreak'"/>
                      <xsl:otherwise>
                        <xsl:call-template name="warning">
                          <xsl:with-param name="msg">unsupported rfc-ext pseudo-attribute '<xsl:value-of select="$attrname"/>'</xsl:with-param>
                        </xsl:call-template>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:if>
                  
                  <xsl:if test="name()='rfc' and $attr='SANITYCHECK'">
                    <xsl:choose>
                      <xsl:when test="$attrname='include'">
                        <xsl:call-template name="warning">
                          <xsl:with-param name="msg">the rfc include pseudo-attribute is not supported by this processor, see http://greenbytes.de/tech/webdav/rfc2629xslt/rfc2629xslt.html#examples.internalsubset for help.</xsl:with-param>
                        </xsl:call-template>
                      </xsl:when>
                      <xsl:otherwise/>
                    </xsl:choose>
                  </xsl:if>

                  <xsl:choose>
                    <xsl:when test="$attrname != $attr">
                      <!-- pseudo-attr does not match, continue -->
                      <xsl:call-template name="parse-one-pi">
                        <xsl:with-param name="str" select="substring($rem2, 2 + string-length($value))"/>
                        <xsl:with-param name="attr" select="$attr"/>
                        <xsl:with-param name="sep" select="$sep"/>
                        <xsl:with-param name="ret" select="$ret"/>
                      </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$sep='' and $ret!=''">
                      <!-- pseudo-attr does match, but we only want one value -->
                      <xsl:if test="$ret != $value">
                        <xsl:call-template name="warning">
                          <xsl:with-param name="msg">duplicate pseudo-attribute <xsl:value-of select="$attr"/>, overwriting value <xsl:value-of select="$ret"/></xsl:with-param>
                        </xsl:call-template>
                      </xsl:if>
                      <xsl:call-template name="parse-one-pi">
                        <xsl:with-param name="str" select="substring($rem2, 2 + string-length($value))"/>
                        <xsl:with-param name="attr" select="$attr"/>
                        <xsl:with-param name="sep" select="$sep"/>
                        <xsl:with-param name="ret" select="$value"/>
                      </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                      <!-- pseudo-attr does match -->
                      <xsl:call-template name="parse-one-pi">
                        <xsl:with-param name="str" select="substring($rem2, 2 + string-length($value))"/>
                        <xsl:with-param name="attr" select="$attr"/>
                        <xsl:with-param name="sep" select="$sep"/>
                        <xsl:with-param name="ret">
                          <xsl:choose>  
                            <xsl:when test="$ret!=''">
                              <xsl:value-of select="concat($ret,$sep,$value)"/>
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:value-of select="$value"/>
                            </xsl:otherwise>
                          </xsl:choose>
                        </xsl:with-param>
                      </xsl:call-template>
                    </xsl:otherwise>                  
                  
                  </xsl:choose>
                  
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
  
</xsl:template>

<xsl:template name="eat-leading-whitespace">
  <xsl:param name="str"/>

  <xsl:choose>
    <xsl:when test="$str=''">
    </xsl:when>
    <xsl:when test="translate(substring($str,1,1),' &#10;&#13;&#9;',' ')=' '">
      <xsl:call-template name="eat-leading-whitespace">
        <xsl:with-param name="str" select="substring($str,2)"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$str"/>
    </xsl:otherwise>
  </xsl:choose>
  
</xsl:template>

<!-- diag support -->
<xsl:template name="lineno">
  <xsl:if test="function-available('saxon-old:line-number')" use-when="function-available('saxon-old:line-number')">
    <xsl:if test="saxon-old:line-number() > 0">
      <xsl:text> (at line </xsl:text>
      <xsl:value-of select="saxon-old:line-number()"/>
      <xsl:if test="function-available('saxon-old:systemId')">
        <xsl:variable name="rootsys">
          <xsl:for-each select="/*">
            <xsl:value-of select="saxon-old:systemId()"/>
          </xsl:for-each>
        </xsl:variable>
        <xsl:if test="$rootsys != saxon-old:systemId()">
          <xsl:text> of </xsl:text>
          <xsl:value-of select="saxon-old:systemId()"/>
        </xsl:if>
      </xsl:if>
      <xsl:text>)</xsl:text>
    </xsl:if>
  </xsl:if>
  <xsl:if test="function-available('saxon:line-number')" use-when="function-available('saxon:line-number')">
    <xsl:if test="saxon:line-number() > 0">
      <xsl:text> (at line </xsl:text>
      <xsl:value-of select="saxon:line-number()"/>
      <xsl:if test="function-available('saxon:systemId')">
        <xsl:variable name="rootsys">
          <xsl:for-each select="/*">
            <xsl:value-of select="saxon:systemId()"/>
          </xsl:for-each>
        </xsl:variable>
        <xsl:if test="$rootsys != saxon:systemId()">
          <xsl:text> of </xsl:text>
          <xsl:value-of select="saxon:systemId()"/>
        </xsl:if>
      </xsl:if>
      <xsl:text>)</xsl:text>
    </xsl:if>
  </xsl:if>
</xsl:template>

<!-- define exslt:node-set for msxml -->       
<msxsl:script language="JScript" implements-prefix="exslt">
  this['node-set'] = function (x) {
    return x;
  }
</msxsl:script>

<!-- date handling -->

<msxsl:script language="JScript" implements-prefix="date">
  function twodigits(s) {
    return s &lt; 10 ? "0" + s : s;
  }

  this['date-time'] = function (x) {
    var now = new Date();
    var offs = now.getTimezoneOffset();
    return now.getFullYear() + "-"
      + twodigits(1 + now.getMonth()) + "-"
      + twodigits(now.getDate()) + "T"
      + twodigits(now.getHours()) + ":"
      + twodigits(now.getMinutes()) + ":"
      + twodigits(now.getSeconds())
      + (offs >= 0 ? "-" : "+")
      + twodigits(Math.abs(offs) / 60) + ":"
      + twodigits(Math.abs(offs) % 60);
  }
</msxsl:script>

<xsl:variable name="current-year">
  <xsl:choose>
    <xsl:when test="function-available('date:date-time')" use-when="function-available('date:date-time')">
      <xsl:value-of select="substring-before(date:date-time(),'-')"/>
    </xsl:when>
    <xsl:when test="function-available('current-date')">
      <xsl:value-of select="substring-before(string(current-date()),'-')"/>
    </xsl:when>
    <xsl:otherwise/>
  </xsl:choose>
</xsl:variable>

<xsl:variable name="current-month">
  <xsl:choose>
    <xsl:when test="function-available('date:date-time')" use-when="function-available('date:date-time')">
      <xsl:value-of select="substring-before(substring-after(date:date-time(),'-'),'-')"/>
    </xsl:when>
    <xsl:when test="function-available('current-date')">
      <xsl:value-of select="substring-before(substring-after(string(current-date()),'-'),'-')"/>
    </xsl:when>
    <xsl:otherwise/>
  </xsl:choose>
</xsl:variable>

<xsl:variable name="current-day">
  <xsl:choose>
    <xsl:when test="function-available('date:date-time')" use-when="function-available('date:date-time')">
      <xsl:value-of select="substring-after(substring-after(substring-before(date:date-time(),'T'),'-'),'-')"/>
    </xsl:when>
    <xsl:when test="function-available('current-dateTime')">
      <xsl:value-of select="substring-after(substring-after(substring-before(string(current-dateTime()),'T'),'-'),'-')"/>
    </xsl:when>
    <xsl:otherwise/>
  </xsl:choose>
</xsl:variable>

<xsl:variable name="may-default-dates">
  <xsl:choose>
    <xsl:when test="$current-year!='' and $current-month!='' and $current-day!=''">
      <xsl:variable name="year-specified" select="/rfc/front/date/@year and /rfc/front/date/@year!=''"/>
      <xsl:variable name="month-specified" select="/rfc/front/date/@month and /rfc/front/date/@month!=''"/>
      <xsl:variable name="day-specified" select="/rfc/front/date/@day and /rfc/front/date/@day!=''"/>
      <xsl:variable name="system-month">
        <xsl:call-template name="get-month-as-name">
          <xsl:with-param name="month" select="$current-month"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="$year-specified and /rfc/front/date/@year!=$current-year">Specified year <xsl:value-of select="/rfc/front/date/@year"/> does not match system date (<xsl:value-of select="$current-year"/>)</xsl:when>
        <xsl:when test="$month-specified and /rfc/front/date/@month!=$system-month">Specified month <xsl:value-of select="/rfc/front/date/@month"/> does not match system date (<xsl:value-of select="$system-month"/>)</xsl:when>
        <xsl:when test="$day-specified and /rfc/front/date/@day!=$current-day">Specified day does not match system date</xsl:when>
        <xsl:when test="not($year-specified) and ($month-specified or $day-specified)">Can't default year when month or day is specified</xsl:when>
        <xsl:when test="not($month-specified) and $day-specified">Can't default month when day is specified</xsl:when>
        <xsl:otherwise>yes</xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <!-- may, but won't -->
    <xsl:otherwise>yes</xsl:otherwise> 
  </xsl:choose>
</xsl:variable>

<xsl:param name="xml2rfc-ext-pub-year">
  <xsl:choose>
    <xsl:when test="/rfc/front/date/@year and /rfc/front/date/@year!=''">
      <xsl:value-of select="/rfc/front/date/@year"/>
    </xsl:when>
    <xsl:when test="$current-year!='' and $may-default-dates='yes'">
      <xsl:value-of select="$current-year"/>
    </xsl:when>
    <xsl:when test="$current-year!='' and $may-default-dates!='yes'">
      <xsl:call-template name="warning">
        <xsl:with-param name="msg" select="$may-default-dates"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="error">
        <xsl:with-param name="msg" select="'/rfc/front/date/@year missing (and XSLT processor cannot compute the system date)'"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:param>

<xsl:param name="xml2rfc-ext-pub-month">
  <xsl:choose>
    <xsl:when test="/rfc/front/date/@month and /rfc/front/date/@month!=''">
      <xsl:value-of select="/rfc/front/date/@month"/>
    </xsl:when>
    <xsl:when test="$current-month!='' and $may-default-dates='yes'">
      <xsl:call-template name="get-month-as-name">
        <xsl:with-param name="month" select="$current-month"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="$current-month!='' and $may-default-dates!='yes'">
      <xsl:call-template name="warning">
        <xsl:with-param name="msg" select="$may-default-dates"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="error">
        <xsl:with-param name="msg" select="'/rfc/front/date/@month missing (and XSLT processor cannot compute the system date)'"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:param>

<xsl:param name="pub-month-numeric">
  <xsl:call-template name="get-month-as-num">
    <xsl:with-param name="month" select="$xml2rfc-ext-pub-month" />
  </xsl:call-template>
</xsl:param>

<xsl:param name="xml2rfc-ext-pub-day">
  <xsl:choose>
    <xsl:when test="/rfc/front/date/@day and /rfc/front/date/@day!=''">
      <xsl:value-of select="/rfc/front/date/@day"/>
    </xsl:when>
    <xsl:when test="$current-day!='' and $may-default-dates='yes'">
      <xsl:value-of select="$current-day"/>
    </xsl:when>
    <xsl:otherwise /> <!-- harmless, we just don't have it -->
  </xsl:choose>
</xsl:param>

<xsl:param name="pub-yearmonth">
  <!-- year or 0000 -->
  <xsl:choose>
    <xsl:when test="$xml2rfc-ext-pub-year!=''">
      <xsl:value-of select="format-number($xml2rfc-ext-pub-year,'0000')"/>
    </xsl:when>
    <xsl:otherwise>0000</xsl:otherwise>
  </xsl:choose>
  <!-- month or 00 -->
  <xsl:choose>
    <xsl:when test="$pub-month-numeric &gt; 0">
      <xsl:value-of select="format-number($pub-month-numeric,'00')"/>
    </xsl:when>
    <xsl:otherwise>00</xsl:otherwise>
  </xsl:choose>
</xsl:param>

<!-- simple validation support -->

<xsl:template match="*" mode="validate">
  <xsl:apply-templates select="@*|*" mode="validate"/>
</xsl:template>
<xsl:template match="@*" mode="validate"/>

<xsl:template name="warninvalid">
  <xsl:variable name="pname">
    <xsl:if test="namespace-uri(..)!=''">
      <xsl:value-of select="concat('{',namespace-uri(..),'}')"/>
    </xsl:if>
    <xsl:value-of select="local-name(..)"/>
  </xsl:variable>
  <xsl:variable name="cname">
    <xsl:if test="namespace-uri(.)!=''">
      <xsl:value-of select="concat('{',namespace-uri(.),'}')"/>
    </xsl:if>
    <xsl:value-of select="local-name(.)"/>
  </xsl:variable>
  <xsl:call-template name="warning">
    <xsl:with-param name="msg" select="concat($cname,' not allowed inside ',$pname)"/>
  </xsl:call-template>
</xsl:template>

<!-- figure element -->
<xsl:template match="figure/artwork | figure/ed:replace/ed:*/artwork" mode="validate" priority="9">
  <xsl:apply-templates select="@*|*" mode="validate"/>
</xsl:template>
<xsl:template match="artwork" mode="validate">
  <xsl:call-template name="warninvalid"/>
  <xsl:apply-templates select="@*|*" mode="validate"/>
</xsl:template>

<!-- list element -->
<xsl:template match="t/list | t/ed:replace/ed:*/list" mode="validate" priority="9">
  <xsl:apply-templates select="@*|*" mode="validate"/>
</xsl:template>
<xsl:template match="list" mode="validate">
  <xsl:call-template name="warninvalid"/>
  <xsl:apply-templates select="@*|*" mode="validate"/>
</xsl:template>

<!-- t element -->
<xsl:template match="abstract/t | abstract/ed:replace/ed:*/t |
                     list/t | list/ed:replace/ed:*/t |
                     note/t | note/ed:replace/ed:*/t |
                     section/t | section/ed:replace/ed:*/t |
                     x:blockquote/t | x:blockquote/ed:replace/ed:*/t |
                     x:note/t | x:note/ed:replace/ed:*/t |
                     x:lt/t | x:lt/ed:replace/ed:*/t" mode="validate" priority="9">
  <xsl:apply-templates select="@*|*" mode="validate"/>
</xsl:template>
<xsl:template match="t" mode="validate">
  <xsl:call-template name="warninvalid"/>
  <xsl:apply-templates select="@*|*" mode="validate"/>
</xsl:template>

<xsl:template name="check-no-text-content">
  <xsl:if test="text()!=''">
    <xsl:call-template name="warning">
      <xsl:with-param name="msg">No text content allowed inside &lt;<xsl:value-of select="name(.)"/>&gt;, but found: <xsl:value-of select="text()"/></xsl:with-param>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<!-- disabled for now because of https://bugzilla.gnome.org/show_bug.cgi?id=677901
<xsl:function name="exslt:node-set">
  <xsl:param name="node"/>
  <xsl:copy-of select="$node"/>
</xsl:function>-->

</xsl:transform>
