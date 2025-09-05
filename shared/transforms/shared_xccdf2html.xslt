<?xml version="1.0" encoding="UTF-8" ?>

<!--
  This stylesheet transforms a resolved XCCDF document into a nice
  XHTML document, with table of contents, cross-links, and section
  numbers.  This stylesheet basically assumes that the document is
  compliant with the XCCDF schema, so validation is probably
  advisable.  Note that this stylesheet completely ignores all
  TestResult elements: they do not appear in the generated
  XHTML document.  

  The XCCDF document MUST be resolved before applying this
  stylesheet.  This stylesheet cannot deal with extension/inheritance 
  at all.

  Original version from:
  Author: Neal Ziring (nziring@thecouch.ncsc.mil)
  Version: 0.12.4 (for XCCDF schema version 1.0rc4 - 0.12.4)
  Date: 13 Nov 04
 -->

<!-- 
 THIS SOFTWARE WAS CREATED BY THE U.S. GOVERNMENT.

 SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
 EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
 IN NO EVENT SHALL THE NATIONAL SECURITY AGENCY OR ANY AGENT OR
 REPRESENTATIVE THEREOF BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA OR PROFITS; OR BUSINESS INTERRUPTION), HOWEVER CAUSED, UNDER ANY
 THEORY OF LIABILITY, ARISING IN ANY WAY OUT OF THE USE OF OR INABILITY
 TO MAKE USE OF THIS SOFTWARE.
-->

<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:htm="http://www.w3.org/1999/xhtml"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:cdf="http://checklists.nist.gov/xccdf/1.1" >

<!-- Set output style: XHTML using xml output method. -->
<xsl:output method="xml" encoding="UTF-8" indent="yes"/>

<!-- Set up an id key to match on against all Items -->
<xsl:key name="items" match="cdf:Group | cdf:Rule | cdf:Value" 
         use="@id"/>

<!-- Set up an id key to match on Item clusters: Rule and Group, Value -->
<xsl:key name="clusters-rg" match="cdf:Group | cdf:Rule" 
         use="@cluster-id"/>
<xsl:key name="clusters-v" match="cdf:Value" 
         use="@cluster-id"/>

<!-- Set up an id key to match on all Profiles -->
<xsl:key name="profiles" match="cdf:Profile" use="@id"/>

<!-- TEMPLATE for cdf:Benchmark
  -  This template takes care of the top-level structure of the
  -  generated XHTML document.  It handles the Benchmark element
  -  and all the content of the benchmark.
  -->
<xsl:template match="/cdf:Benchmark">

  <!-- First issue a warning if the Benchmark is not marked resolved. -->
  <xsl:if test="not(@resolved)">
     <xsl:message>
        Warning: benchmark <xsl:value-of select="@id"/> not resolved, formatted 
        output will be incomplete or corrupted.
     </xsl:message>
  </xsl:if>

  <!-- Define variables for section numbers. -->
  <xsl:variable name="introSecNum" select="1"/>
  <xsl:variable name="concSecNum" 
                select="2 + number(count(./cdf:Rule[not(number(@hidden)+number(@abstract))] | ./cdf:Group[not(number(@hidden)+number(@abstract))])!=0) + number(count(//cdf:Value[not(number(@hidden)+number(@abstract))])!=0) + number(count(./cdf:Profile)!=0)"/>
  <xsl:variable name="refSecNum" 
                select="2 + number(count(./cdf:Rule[not(number(@hidden)+number(@abstract))] | ./cdf:Group[not(number(@hidden)+number(@abstract))])!=0) + number(count(//cdf:Value[not(number(@hidden)+number(@abstract))])!=0) + number(count(./cdf:Profile)!=0) + number(count(./cdf:rear-matter)!=0)"/>

<!-- Begin the HTML/XHTML body -->
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <title>XCCDF Benchmark: <xsl:value-of select="./cdf:title/text()"/></title>
  <meta name="identifier" content="{@id}"/>
  <script type="text/javascript">
	function toggle(divID, imgID) {
		var item = document.getElementById(divID);
		var img = document.getElementById(imgID);
		if (item) {
			item.className = (item.className=='hiddencheck') ? 'check':'hiddencheck';
		}
		if (img) {
			var currimage = img.src.substring(img.src.lastIndexOf('/')+1);
			img.src=(currimage=='collapsed.png')?'images/expanded.png':'images/collapsed.png';
			}
	}
  </script>

  <style type="text/css">
      /*    { background-color: #FFFFFF; } */
      body  { margin-left: 8%; margin-right: 8%; foreground: black; }
      h1    { text-align: center; font-size: 200%;
              margin-top: 2em; margin-bottom: 1.0em;
              font-family: verdana, arial, helvetica, sans-serif; 
              background-color: black; color: white; }
      h2    { margin-left: 0%; font-size: 125%; 
              /*border-bottom: solid 1px gray; margin-bottom: 1.0em; */
              margin-top: 2em; margin-bottom: 0.75em;
              padding: 2px;
              font-family: verdana, arial, helvetica, sans-serif; }
      h2    { color: black; background-color: #ccc; }
      h2.toplevel { color: white; background-color: black; font-size: 175%; text-align: center; }
      h3    { margin-left: 6%; font-size: 110%; margin-bottom: 0.25em; 
              font-family: verdana, arial, helvetica, sans-serif; }
      h4    { margin-left: 10%; font-size: 100%; margin-bottom: 0.75em; 
              font-family: verdana, arial, helvetica, sans-serif; }
      h5,h6 { margin-left: 10%; font-size: 90%; margin-bottom: 0.5em;  
              font-family: verdana, arial, helvetica, sans-serif; }
      p     { margin-bottom: 0.2em; margin-top: 0.2em; }
      pre   { margin-bottom: 0.5em; margin-top: 0.25em; margin-left: 3%;
              font-family: monospace; font-size: 90%; }
      ul    { margin-bottom: 0.5em; margin-top: 0.25em; }
      td    { vertical-align: top; }

      *.simpleText     { margin-left: 10%; }
      *.propertyText   { margin-left: 10%; margin-top: 0.2em; margin-bottom: 0.2em }
      *.toc	           { background: #FFFFFF; }
      *.toc2           { background: #FFFFFF; }
      div              { margin-top: 1em; margin-bottom: 1em; }
      div.rule	       { margin-left: 10%; border: 1px solid; background: #ccc; padding: 10px 10px 10px 10px; margin-top: 1em; margin-bottom: 1em; }
      div.hiddencheck  { margin-left: 10%; border: 1px solid; background: #ccc; padding: 10px 10px 10px 10px; margin-top: 1em; margin-bottom: 1em; display: none; }
      div.check	       { margin-left: 10%; border: 1px solid; background: #ccc; padding: 10px 10px 10px 10px; margin-top: 1em; margin-bottom: 1em; display: block; }
      div.legal        { margin-left: 10%; margin-top: 0.2em; margin-bottom: 0.2em}
      
      div.toc          { margin-left: 6%; margin-bottom: 4em;
                         padding-bottom: 0.75em; padding-top: 1em; 
                         padding-left: 2em; padding-right: 2em; 
                       }
      h2.toc           { border-bottom: none; margin-left: 0%; margin-top: 0em; }
      p.toc            { margin-left: 2em; margin-bottom: 0.2em; margin-top: 0.5em; }
      p.toc2           { margin-left: 5em; margin-bottom: 0.1em; margin-top: 0.1em; }
      ul.smallList     { margin-bottom: 0.1em; margin-top: 0.1em; font-size: 85%; }
      /* table.propertyTable { margin-left: 14%; width: 90%; margin-top: 0.5em; margin-bottom: 0.25em; }
      th.propertyTableHead { font-size: 80%; background-color: #CCCCCC; } */
      table            { border-collapse:collapse; /*border: 1px solid black;*/ }
      table,th,td      { text-align: left; padding: 8px 8px; }
      table tr:nth-child(2n+2) { background-color: #F4F4F4; }
      th               { border-bottom: 3px solid gray; }
      table#references { border-collapse: collapse; border-top: 1px #ccc solid; width:90%;
                         margin-left:10%; margin-top: 0.75em; margin-bottom: 0.75em;
                         font-family: verdana, arial, helvetica, sans-serif; }
      td.ident         { width: 30%; font-size: 90%; }
      td.ref           { width: 70%; font-size: 90%; }
      .expandstyle a         { color: black; text-decoration: none; }
      .expandstyle a:link    { color: black; text-decoration: none; }
      .expandstyle a:visited { color: black; text-decoration: none; }
      .expandstyle a:hover   { color: black; text-decoration: none; }
      .expandstyle a:active  { color: black; text-decoration: none; }
  </style>
</head>
<body>
  <xsl:comment>Benchmark id = <xsl:value-of select="./@id"/></xsl:comment>
  <xsl:comment>
     This XHTML output file
     generated using the 
     <xsl:value-of select="system-property('xsl:vendor')"/>
     XSLT processor.
  </xsl:comment>

  <!-- BEGINNING OF BODY -->
  <h1><xsl:value-of select="./cdf:title"/></h1>

  <xsl:if test="./cdf:status | ./cdf:version | ./cdf:platform">
    <div class="simpleText">
      <p>Status: <b><xsl:value-of select="./cdf:status/text()"/></b>
	  <xsl:if test="./cdf:status/@date">
	     (as of <xsl:value-of select="./cdf:status/@date"/>)
	  </xsl:if>
      </p>
      <xsl:if test="./cdf:version">
	<p>Version: <xsl:value-of select="./cdf:version/text()"/></p>
      </xsl:if>
      <xsl:if test="./cdf:platform">
	<p>Applies to:<ul>
        <xsl:for-each select="./cdf:platform">
          <li><xsl:value-of select="@idref"/></li>
        </xsl:for-each>
	</ul></p>
      </xsl:if>
    </div>
  </xsl:if>

  <!-- 1. Build the introduction -->
  <!--<h2><a name="section-intro"></a>front-matter</h2> -->
  <xsl:if test="./cdf:front-matter">
     <xsl:for-each select="./cdf:front-matter">
       <div class="propertyText">
          <xsl:copy-of select="./text() | ./* | node()" />
       </div>
     </xsl:for-each>
  </xsl:if>
  <xsl:if test="./cdf:description">
     <h3>Description</h3>
     <xsl:for-each select="./cdf:description">
       <div class="propertyText"><p><xsl:copy-of select="./text() | ./* | node()" /></p></div>
     </xsl:for-each>
  </xsl:if>
  <xsl:if test="./cdf:notice">
      <xsl:for-each select="./cdf:notice">
        <h3>Notice</h3>       
          <div class="legal"><p><xsl:value-of select="text()"/></p></div>
      </xsl:for-each>
  </xsl:if>

  <br />

  <!-- Build the Table of Contents -->
  <h3 class="toc">Contents</h3>
  <div class="toc">
     <!-- rules and groups TOC -->
     <xsl:if test="./cdf:Group[not(number(@hidden)+number(@abstract))] | ./cdf:Rule[not(number(@hidden)+number(@abstract))]">
	<xsl:apply-templates mode="toc"
         select="./cdf:Group[not(number(@hidden)+number(@abstract))] | ./cdf:Rule[not(number(@hidden)+number(@abstract))]">
	  <xsl:with-param name="section-prefix" />
	</xsl:apply-templates>
     </xsl:if>
	 
     <!-- rear-matter TOC -->
     <xsl:if test="./cdf:rear-matter">
       <p class="toc">
         <xsl:value-of select="$concSecNum"/>.
         <a class="toc" href="#section---conc">Conclusions</a>
       </p>
     </xsl:if>

     <!-- references TOC -->
     <xsl:if test="./cdf:reference">
       <p class="toc">
         <xsl:value-of select="$refSecNum"/>. <a class="toc" href="#section---references">References</a>
       </p>
     </xsl:if>
  </div>

  <!-- Begin the main page content in the HTML body -->


  <!-- Build the rules section (rules and groups) -->
  <xsl:if test="./cdf:Group[not(number(@hidden)+number(@abstract))] | ./cdf:Rule[not(number(@hidden)+number(@abstract))]">
     <xsl:apply-templates select="./cdf:Group[not(number(@hidden)+number(@abstract))] | ./cdf:Rule[not(number(@hidden)+number(@abstract))]" mode="body">
	  <xsl:with-param name="section-prefix" />
     </xsl:apply-templates>
  </xsl:if>


  <!-- Build the conclusions section using Benchmark/rear-matter -->
  <xsl:if test="./cdf:rear-matter">
     <h2><a name="section---conc"></a>
         <xsl:value-of select="$concSecNum"/>. Conclusions
     </h2>
     <xsl:for-each select="./cdf:rear-matter">
       <div class="propertyText">
          <xsl:apply-templates select="./text() | ./*" mode="text"/>
       </div>
     </xsl:for-each>
  </xsl:if>

  <!-- Build the references section using Benchmark/reference -->
  <xsl:if test="./cdf:reference">
     <h2><a name="section---references"></a>
        <xsl:value-of select="$refSecNum"/>. References
     </h2>
     <ol xmlns="http://www.w3.org/1999/xhtml" class="propertyText">
	<xsl:for-each select="./cdf:reference">
	  <li><xsl:value-of select="text()"/>
	    <xsl:if test="@href">
	      [<a href="{@href}">link</a>]
            </xsl:if>
	  </li>
	</xsl:for-each>
     </ol>
  </xsl:if>

  <!-- All done, close out the HTML -->
  </body>
</html>

</xsl:template>


<!-- Additional templates for a Value element;
  -  For TOC, we present a line with number, for body
  -  we present a numbered section with title, and then
  -  the fields of the Value with a dl list.
  -->
<xsl:template match="cdf:Value" mode="toc">
  <xsl:param name="section-prefix"/>
  <xsl:param name="section-num" select="position()"/>

  <!-- <xsl:message>In toc template for Value, id=<xsl:value-of select="@id"/>.</xsl:message> -->
  <p xmlns="http://www.w3.org/1999/xhtml" class="toc2">
     <xsl:value-of select="$section-prefix"/>
     <xsl:value-of select="$section-num"/>
     <xsl:text>. </xsl:text>
     <a class="toc" href="#{@id}"><xsl:value-of select="./cdf:title/text()"/></a>
  </p>
</xsl:template>

<!-- Significant code for displaying Value text is in 
     the original version of this file, at
     http://nvd.nist.gov/scap/xccdf/docs/xccdf2xhtml-1.0.xsl -->

<!-- Template for toc entries for both rules and groups -->
<xsl:template match="cdf:Group | cdf:Rule" mode="toc">
  <xsl:param name="section-prefix"/>
  <xsl:param name="section-num" select="position()"/>

  <!-- <xsl:message>In toc template for Group|Rule, id=<xsl:value-of select="@id"/>.</xsl:message> -->
  <p xmlns="http://www.w3.org/1999/xhtml" class="toc2">
     <xsl:value-of select="$section-prefix"/>
     <xsl:value-of select="$section-num"/>
     <xsl:text>. </xsl:text>
     <a class="toc" href="#{@id}"><xsl:value-of select="./cdf:title/text()"/></a>
  </p>
  <xsl:if test="./cdf:Group | ./cdf:Rule">
	<xsl:apply-templates mode="toc"
         select="./cdf:Group[not(number(@hidden)+number(@abstract))] | ./cdf:Rule[not(number(@hidden)+number(@abstract))]">
	    <xsl:with-param name="section-prefix" 
             select="concat($section-prefix,$section-num,'.')"/>
	</xsl:apply-templates>
  </xsl:if>
</xsl:template>


<!-- Template for toc entries for Profiles -->
<xsl:template match="cdf:Profile" mode="toc">
  <xsl:param name="section-prefix"/>
  <xsl:param name="section-num" select="position()"/>

  <!-- <xsl:message>In toc template for Profile, id=<xsl:value-of select="@id"/>.</xsl:message> -->
  <p xmlns="http://www.w3.org/1999/xhtml" class="toc2">
     <xsl:value-of select="$section-prefix"/>
     <xsl:value-of select="$section-num"/>
     <xsl:text>. </xsl:text>
     <a class="toc" href="#profile-{@id}"><xsl:value-of select="./cdf:title/text()"/></a>
  </p>

</xsl:template>

<!-- template for body elements for Profiles -->
<xsl:template match="cdf:Profile" mode="body">
  <xsl:param name="section-prefix"/>
  <xsl:param name="section-num" select="position()"/>

  <!-- <xsl:message>In body template for Profile, id=<xsl:value-of select="@id"/>.</xsl:message> -->
  <xsl:comment>Profile id = <xsl:value-of select="./@id"/></xsl:comment>
  <div xmlns="http://www.w3.org/1999/xhtml">
  <h3><a name="profile-{@id}"></a>
     <xsl:value-of select="$section-prefix"/>
     <xsl:value-of select="$section-num"/>
     <xsl:text>. Profile: </xsl:text>
     <i><xsl:value-of select="./cdf:title/text()"/></i>
  </h3>

  <div class="simpleText">
    <xsl:if test="@extends">
      <p>Extends: 
          <xsl:apply-templates select="key('profiles',@extends)" mode="prof-ref"/>
      </p>
    </xsl:if>
    <xsl:if test="./cdf:status">
      <p>Status: <xsl:value-of select="./cdf:status/text()"/>
        <xsl:if test="./cdf:status/@date">
	   (as of <xsl:value-of select="./cdf:status/@date"/>)
	</xsl:if>
      </p>
    </xsl:if>
    <xsl:if test="./cdf:platform">
      <p>Applies only to:<ul>
        <xsl:for-each select="./cdf:platform">
          <li><xsl:value-of select="@idref"/></li>
        </xsl:for-each>
      </ul></p>
    </xsl:if>
  </div>

  <xsl:if test="./cdf:description">
     <h4>Description</h4>
     <xsl:for-each select="./cdf:description">
       <div class="propertyText">
          <xsl:apply-templates select="./text() | ./*" mode="text"/>
       </div>
     </xsl:for-each>
  </xsl:if>

  <xsl:if test="./cdf:select">
   <h4>Item Selections</h4>
   <div class="propertyText">
    <p>Rules and Groups explicitly selected and deselected for this profile.</p>
       <ul>
         <xsl:apply-templates select="." mode="sel-list"/>
       </ul>
   </div>
  </xsl:if>

  <xsl:if test="./cdf:set-value | ./cdf:refine-value">
   <h4>Value Settings</h4>
   <div class="propertyText">
    <p>Tailoring value adjustments explicitly set for this profile:</p>
       <ul>
         <xsl:apply-templates select="." mode="set-list"/>
       </ul>
   </div>
  </xsl:if>

  <!-- Top level reference -->
  <xsl:if test="./cdf:reference">
    <h4 class="references">References: 
	<xsl:for-each select="./cdf:reference">
	    <xsl:if test="@href">
	      <xsl:choose>
	        <xsl:when test='. != ""'>
	          <a href="{@href}"><xsl:value-of select="text()"/></a>
	        </xsl:when>
	        <xsl:otherwise>
	          <a href="{@href}"><xsl:value-of select="./@href"/></a>
	        </xsl:otherwise>
	      </xsl:choose>
        </xsl:if>
	</xsl:for-each>
    </h4>
  </xsl:if>
  </div>
</xsl:template>

<xsl:template match="cdf:Profile" mode="sel-list">
   <xsl:apply-templates select="./cdf:select" mode="sel-list"/>
</xsl:template>

<xsl:template match="cdf:Profile" mode="set-list">
   <xsl:apply-templates select="./cdf:set-value" mode="set-list"/>
   <xsl:apply-templates select="./cdf:refine-value" mode="set-list"/>
</xsl:template>

<xsl:template match="cdf:select" mode="sel-list">
   <li xmlns="http://www.w3.org/1999/xhtml">
       <xsl:if test="number(./@selected)">Included: </xsl:if>
       <xsl:if test="not(number(./@selected))">Excluded: </xsl:if>
       <xsl:if test="count(key('items',@idref))">
            <a href="#{@idref}">
                <xsl:value-of select="key('items', @idref)/cdf:title/text()"/>
            </a>
       </xsl:if>
       <xsl:if test="not(count(key('items',@idref)))">
            (cluster) 
            <xsl:for-each select="key('clusters-rg',@idref)">
              <a href="#{./@id}">
                <xsl:value-of select="./cdf:title/text()"/>
              </a> 
            </xsl:for-each>
       </xsl:if>
   </li>
</xsl:template>

<xsl:template match="cdf:set-value" mode="set-list">
   <li xmlns="http://www.w3.org/1999/xhtml">
     <a href="#{@idref}"><xsl:value-of select="key('items', @idref)/cdf:title/text()"/></a><br/><xsl:text> set to value: </xsl:text><b><xsl:value-of select="./text()"/></b>
   </li>
</xsl:template>

<xsl:template match="cdf:refine-value" mode="set-list">
   <li xmlns="http://www.w3.org/1999/xhtml">
     <a href="#{@idref}"><xsl:value-of select="key('items', @idref)/cdf:title/text()"/></a><br/><xsl:text> refinement selector: </xsl:text><b><xsl:value-of select="./@selector"/></b>
   </li>
</xsl:template>

<xsl:template match="cdf:Profile" mode="prof-ref">
   <a href="#profile-{@id}"><xsl:value-of select="./cdf:title/text()"/></a>
</xsl:template>


<!-- Additional template for a Group element;
  -  we present a numbered section with title, and then
  -  the fields of the Group with a dl list, then the
  -  enclosed items as subsections.
  -->
<xsl:template match="cdf:Group" mode="body">
  <xsl:param name="section-prefix"/>
  <xsl:param name="section-num" select="position()"/>

  <!--<xsl:message>In body template for Group, id=<xsl:value-of select="@id"/>.</xsl:message>-->
  <xsl:comment>Group id = <xsl:value-of select="./@id"/></xsl:comment>
  <div  xmlns="http://www.w3.org/1999/xhtml">

  <!--<h1><xsl:value-of select="$section-prefix" />meh<br /><xsl:value-of select="$section-num" />meh</h1>-->

  <xsl:choose>
    <xsl:when test="$section-prefix">
      <h2><a name="{@id}"></a>
         <xsl:value-of select="$section-prefix"/>
         <xsl:value-of select="$section-num"/>
         <xsl:value-of select="concat(' ', ./cdf:title/text())"/>
      </h2>
    </xsl:when>
    <xsl:otherwise>
      <h2 class="toplevel"><a name="{@id}"></a>
         <xsl:value-of select="$section-prefix"/>
         <xsl:value-of select="$section-num"/>
         <xsl:value-of select="concat('. ', ./cdf:title/text())"/>
      </h2>
    </xsl:otherwise>
  </xsl:choose>

  <xsl:if test="./cdf:description">
     <xsl:for-each select="./cdf:description">
       <div class="propertyText">
          <xsl:apply-templates select="node()"/>
       </div>
     </xsl:for-each>
  </xsl:if>

  <xsl:if test="./cdf:rationale">
     <xsl:for-each select="./cdf:rationale">
       <div class="propertyText">
          <xsl:apply-templates select="node()"/>
       </div>
     </xsl:for-each>
  </xsl:if>

  <xsl:if test="./cdf:warning">
     <h4>Warning</h4>
     <xsl:for-each select="./cdf:warning">
       <div class="propertyText">
          <xsl:apply-templates select="node()"/>
       </div>
     </xsl:for-each>
  </xsl:if>

  <!-- Group level reference -->
  <xsl:if test="./cdf:ident or ./cdf:reference">
    <table id="references">
      <tr valign="top">
        <td class="ident">
          <strong>Security Identifiers: </strong>
          <xsl:if test="not(./cdf:ident)">none<br /></xsl:if>
          <xsl:for-each select='./cdf:ident'><xsl:value-of select='.' /><xsl:if test='not(position()=last())'>, </xsl:if></xsl:for-each>
        </td>
        <td class="ref">
          <strong>References: </strong>
          <xsl:if test="not(./cdf:reference)">none<br /></xsl:if>
          <xsl:for-each select='./cdf:reference'>
            <xsl:if test="@href">
              <xsl:choose>
                <xsl:when test='. != ""'>
                  <xsl:choose>
                    <xsl:when test='./@href = "https://public.cyber.mil/stigs/cci/"'>
                      <a href="{@href}">DISA <xsl:value-of select="text()"/></a>
                    </xsl:when>
                    <xsl:when test='./@href = "http://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-53r4.pdf"'>
                      <a href="{@href}">NIST <xsl:value-of select="text()"/></a>
                    </xsl:when>
                    <xsl:otherwise>
                      <a href="{@href}"><xsl:value-of select="text()"/></a>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                  <a href="{@href}"><xsl:value-of select="./@href"/></a>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:if test="not(position()=last())">, </xsl:if>
            </xsl:if>
          </xsl:for-each>
        </td>
      </tr>
    </table>
  </xsl:if>

  <xsl:if test="./cdf:Group | ./cdf:Rule">
      <xsl:apply-templates mode="body" select="./cdf:Group[not(number(@hidden)+number(@abstract))] | ./cdf:Rule[not(number(@hidden)+number(@abstract))]">
         <xsl:with-param name="section-prefix" 
                         select="concat($section-prefix,$section-num,'.')"/>
      </xsl:apply-templates>
  </xsl:if>
  </div>
</xsl:template>

<!-- Additional template for a Rule element in body;
  -  we present a numbered section with title, and then
  -  the fields of the Rule with a dl list.
  -->
<xsl:template match="cdf:Rule" mode="body">
  <xsl:param name="section-prefix"/>
  <xsl:param name="section-num" select="position()"/>

  <!-- <xsl:message>In body template for Rule, id=<xsl:value-of select="@id"/>.</xsl:message> -->
  <xsl:comment>Rule id = <xsl:value-of select="./@id"/></xsl:comment>
  <div xmlns="http://www.w3.org/1999/xhtml">
  <h3>
     <a name="{@id}"></a>
     <xsl:value-of select="$section-prefix"/>
     <xsl:value-of select="$section-num"/>
     <i><xsl:value-of select="concat(' ', ./cdf:title/text())"/></i>
  </h3>

  
  <xsl:if test="./cdf:description">
     <!-- <h4>Description</h4> -->
     <xsl:for-each select="./cdf:description">
       <div class="rule">
      <xsl:apply-templates select="node()" />
       </div>
     </xsl:for-each>
  </xsl:if>

  <xsl:if test="./cdf:rationale">
     <xsl:for-each select="./cdf:rationale">
       <div class="propertyText">
      <xsl:apply-templates select="node()" />
       </div>
     </xsl:for-each>
  </xsl:if>

  <xsl:if test="./cdf:warning">
     <h4>Warning</h4>
     <xsl:for-each select="./cdf:warning">
       <div class="propertyText">
      <xsl:apply-templates select="node()" />
       </div>
     </xsl:for-each>
  </xsl:if>

  <xsl:if test="./cdf:check[@system='ocil-transitional']">
  <xsl:variable name="manualcheck" select="concat('manualcheck-', @id)"/>
    <xsl:for-each select="./cdf:check[@system='ocil-transitional']/cdf:check-content">
      <h4 class="expandstyle">
        <a href="javascript:toggle('{$manualcheck}', 'link-{$manualcheck}');" style="height:25px; line-height: 25px">
      	<span style="display:inline-block; vertical-align:middle"><img id="link-{$manualcheck}" src="images/collapsed.png" height="15" width="15" style="vertical-align: middle"/> Check Procedure</span>
      	</a>
      </h4>
      <div id="{$manualcheck}" class="hiddencheck">
      <xsl:apply-templates select="node()" />
      </div>
    </xsl:for-each>
  </xsl:if>

  <!-- Rule level reference -->
  <xsl:if test="./cdf:ident or ./cdf:reference">
    <table id="references">
      <tr valign="top">
        <td class="ident">
          <strong>Security Identifiers: </strong>
          <xsl:if test="not(./cdf:ident)">none<br /></xsl:if>
          <xsl:for-each select='./cdf:ident'><xsl:value-of select='.' /><xsl:if test='not(position()=last())'>, </xsl:if></xsl:for-each>
        </td>
        <td class="ref">
          <strong>References: </strong>
          <xsl:if test="not(./cdf:reference)">none<br /></xsl:if>
          <xsl:for-each select='./cdf:reference'>
            <xsl:if test="@href">
              <xsl:choose>
                <xsl:when test='. != ""'>
                  <xsl:choose>
                    <xsl:when test='./@href = "https://public.cyber.mil/stigs/cci/"'>
                      <a href="{@href}">DISA <xsl:value-of select="text()"/></a>
                    </xsl:when>
                    <xsl:when test='./@href = "http://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-53r4.pdf"'>
                      <a href="{@href}">NIST <xsl:value-of select="text()"/></a>
                    </xsl:when>
                    <xsl:otherwise>
                      <a href="{@href}"><xsl:value-of select="text()"/></a>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                  <a href="{@href}"><xsl:value-of select="./@href"/></a>
                </xsl:otherwise>

              </xsl:choose>
              <xsl:if test="not(position()=last())">, </xsl:if>
            </xsl:if>
          </xsl:for-each>
        </td>
      </tr>
    </table>
  </xsl:if>

  </div>
</xsl:template>

<!-- templates in mode "text", for processing text with 
     markup and substitutions.  -->

  <!-- getting rid of XHTML namespace -->
    <xsl:template match="xhtml:*">
        <xsl:element name="{local-name()}">
            <xsl:apply-templates select="node()|@*"/>
        </xsl:element>
    </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
