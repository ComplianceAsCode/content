<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xccdf="http://checklists.nist.gov/xccdf/1.1"
  xmlns:xhtml="http://www.w3.org/1999/xhtml" 
  xmlns:dc="http://purl.org/dc/elements/1.1/" 
  xmlns:date="http://exslt.org/dates-and-times" extension-element-prefixes="date"
  exclude-result-prefixes="xccdf xhtml dc">

  <!-- This transform takes a "shorthand" variant of XCCDF
       and expands its elements into proper XCCDF elements.
       It also assigns all elements into the proper namespace,
       whether it be xccdf, xhtml, or simply maintained from the
       input. -->

<xsl:include href="constants.xslt"/>

<xsl:param name="ssg_version">unknown</xsl:param>

<xsl:variable name="ovalfile">unlinked-chromium-oval.xml</xsl:variable>
<xsl:variable name="defaultseverity" select="'low'" />

<!-- put elements created in this stylesheet into the xccdf namespace,
     if no namespace explicitly indicated -->
<xsl:namespace-alias result-prefix="xccdf" stylesheet-prefix="#default" />


  <xsl:template match="Benchmark">
    <xsl:element name="{local-name()}" namespace="http://checklists.nist.gov/xccdf/1.1">
        <xsl:apply-templates select="node()|@*"/>
    </xsl:element>
  </xsl:template>


  <!-- insert current date -->
  <xsl:template match="Benchmark/status/@date">
    <xsl:attribute name="date">
       <xsl:value-of select="date:date()"/>
    </xsl:attribute>
  </xsl:template>

  <!-- insert SSG version -->
  <xsl:template match="Benchmark/version">
    <xccdf:version><xsl:value-of select="$ssg_version"/></xccdf:version>
  </xsl:template>

  <!-- hack for OpenSCAP validation quirk: must place reference after description/warning, but prior to others -->
  <xsl:template match="Rule">
    <Rule selected="false">
    <!-- set selected attribute to false, to enable profile-driven evaluation -->
      <xsl:apply-templates select="@*" />
      <!-- also: add severity of "low" to each Rule if otherwise unspecified -->
      <xsl:if test="not(@severity)">
          <xsl:attribute name="severity">
              <xsl:value-of select="$defaultseverity" />
          </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="title"/>
      <xsl:apply-templates select="description"/>
      <xsl:apply-templates select="warning"/> 
      <xsl:apply-templates select="ref"/> 
      <xsl:apply-templates select="tested"/> 
      <xsl:apply-templates select="rationale"/> 
      <xsl:apply-templates select="ident"/> 
      <!-- order oval (shorthand tag) first, to indicate to tools to prefer its automated checks -->
      <xsl:apply-templates select="oval"/> 
      <xsl:apply-templates select="node()[not(self::title|self::description|self::warning|self::ref|self::tested|self::rationale|self::ident|self::oval)]"/>
    </Rule>
  </xsl:template> 


  <xsl:template match="Group">
    <Group>
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates select="title"/>
      <xsl:apply-templates select="description"/>
      <xsl:apply-templates select="warning"/> 
      <xsl:apply-templates select="ref"/> 
      <xsl:apply-templates select="rationale"/> 
      <xsl:apply-templates select="node()[not(self::title|self::description|self::warning|self::ref|self::rationale)]"/>
    </Group>
  </xsl:template> 

  <!-- XHTML, such as tt, is not allowed in titles -->
  <xsl:template match="title/tt">
        <xsl:apply-templates select="@*|node()" />
  </xsl:template>

  <!-- expand reference to ident types -->
  <xsl:template match="Rule/ident">
    <xsl:for-each select="@*">
      <ident>
        <xsl:choose>
          <xsl:when test="name() = 'cce'">
            <xsl:attribute name="system">
              <xsl:value-of select="$cceuri" />
            </xsl:attribute>
            <xsl:choose>
              <xsl:when test="starts-with(translate(., 'ce', 'CE'), 'CCE')">
                <xsl:value-of select="." />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat('CCE-', .)" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="name() = 'stig'">
            <xsl:attribute name="system">
              <xsl:value-of select="$cceuri" />
            </xsl:attribute>
            <xsl:value-of select="concat('DISA FSO ', .)" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="." />
          </xsl:otherwise>
        </xsl:choose>
      </ident>
    </xsl:for-each>
  </xsl:template>

  <!-- expand ref attributes to reference tags, one item per reference -->
  <xsl:template match="ref"> 
    <xsl:for-each select="@*">
       <xsl:call-template name="ref-info" >
          <xsl:with-param name="refsource" select="name()" />
          <xsl:with-param name="refitems" select="." />
       </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <!-- expands individual reference source -->
  <xsl:template name="ref-info">
      <xsl:param name="refsource"/>
      <xsl:param name="refitems"/>
      <xsl:variable name="delim" select="','" />
       <xsl:choose>
           <xsl:when test="$delim and contains($refitems, $delim)">
             <!-- output the reference -->
             <xsl:call-template name="ref-output" >
               <xsl:with-param name="refsource" select="$refsource" />
               <xsl:with-param name="refitem" select="substring-before($refitems, $delim)" />
             </xsl:call-template>
             <!-- recurse for additional refs -->
             <xsl:call-template name="ref-info">
               <xsl:with-param name="refsource" select="$refsource" />
               <xsl:with-param name="refitems" select="substring-after($refitems, $delim)" />
             </xsl:call-template>
           </xsl:when>

           <xsl:otherwise>
             <xsl:call-template name="ref-output" >
               <xsl:with-param name="refsource" select="$refsource" />
               <xsl:with-param name="refitem" select="$refitems" />
             </xsl:call-template>
           </xsl:otherwise>
       </xsl:choose>
  </xsl:template>

  <!-- output individual reference -->
  <xsl:template name="ref-output">
      <xsl:param name="refsource"/>
      <xsl:param name="refitem"/>
      <reference>
        <xsl:attribute name="href">
        <!-- populate the href attribute with a global reference-->
          <xsl:if test="$refsource = 'nist'">
            <xsl:value-of select="$nist800-53uri" />
          </xsl:if>
          <xsl:if test="$refsource = 'cnss'">
            <xsl:value-of select="$cnss1253uri" />
          </xsl:if>
          <xsl:if test="$refsource = 'disa'">
            <xsl:value-of select="$disa-cciuri" />
          </xsl:if>
        </xsl:attribute>
        <xsl:value-of select="normalize-space($refitem)" />
      </reference>
  </xsl:template>

  <!-- expand reference to OVAL ID -->
  <xsl:template match="Rule/oval">
    <check>
      <xsl:attribute name="system">
        <xsl:value-of select="$ovaluri" />
      </xsl:attribute>

      <xsl:if test="@value">
      <check-export>
      <xsl:attribute name="export-name">
        <xsl:value-of select="@value" />
      </xsl:attribute>
      <xsl:attribute name="value-id">
        <xsl:value-of select="@value" />
      </xsl:attribute>
      </check-export>
      </xsl:if> 

      <check-content-ref>
        <xsl:attribute name="href">
          <xsl:value-of select="$ovalfile" />
        </xsl:attribute>
        <xsl:attribute name="name">
          <xsl:value-of select="@id" />
        </xsl:attribute>
      </check-content-ref>
    </check>
  </xsl:template>


  <!-- expand reference to would-be OCIL (inline) -->
  <xsl:template match="Rule/ocil">
      <check>
        <xsl:attribute name="system">ocil-transitional</xsl:attribute>
          <check-export>

          <xsl:attribute name="export-name">
          <!-- add clauses if specific macros are found within -->
          </xsl:attribute>

          <!-- add clause if explicitly specified (and also override any above) -->
          <xsl:if test="@clause">
            <xsl:attribute name="export-name"><xsl:value-of select="@clause" /></xsl:attribute>
          </xsl:if>

          <xsl:attribute name="value-id">conditional_clause</xsl:attribute>
          </check-export>
        <!-- add the actual manual checking text -->
        <check-content>
        <xsl:apply-templates select="node()"/>
        </check-content>
      </check>
   </xsl:template>

   <xsl:template match="tested">
      <reference>
        <xsl:attribute name="href"><xsl:value-of select="$ssg-contributors-uri" /></xsl:attribute>
        <xsl:value-of select="concat('Test attestation on ', @on, ' by ', @by)" />
      </reference>
   </xsl:template>

  <!-- The next set of templates places elements into the correct namespaces,
       so that content authors never have to bother with them. 
       XHTML elements are explicitly identified and the xhtml
       namespace is added.  Any element with an empty namespace
       is assigned to the xccdf namespace. -->

  <!-- put table and list-related xhtml tags into xhtml namespace -->
  <xsl:template match="table | tr | th | td | ul | li | ol" >
    <xsl:element name="{local-name()}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:element>
  </xsl:template>

  <!-- put general formatting xhtml into xhtml namespace -->
  <xsl:template match="p | code | strong | b | em | i | pre | br | hr" >
    <xsl:element name="{local-name()}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:element>
  </xsl:template>

  <!-- convert tt to code, which seems better-supported -->
  <xsl:template match="tt">
    <xhtml:code>
      <xsl:apply-templates select="@*|node()"/>
    </xhtml:code>
  </xsl:template>

  <!-- if no namespace is indicated, put into xccdf namespace-->
  <xsl:template match="*[namespace-uri()='']" priority="-1">
    <xsl:element name="{local-name()}" namespace="http://checklists.nist.gov/xccdf/1.1">
      <xsl:apply-templates select="node()|@*"/>
    </xsl:element>
  </xsl:template>

  <!-- identity transform: pass anything else through -->
  <xsl:template match="@*|node()" priority="-2">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
