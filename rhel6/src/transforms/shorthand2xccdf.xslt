<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xccdf="http://checklists.nist.gov/xccdf/1.1"
xmlns:xhtml="http://www.w3.org/1999/xhtml"
exclude-result-prefixes="xccdf xhtml">

<xsl:include href="constants.xslt"/>

<xsl:variable name="ovalpath">oval:org.scap-security-guide.rhel:def:</xsl:variable>
<xsl:variable name="ovalfile">rhel6-oval.xml</xsl:variable>

<xsl:variable name="defaultseverity" select="'low'" />

  <!-- Content:template -->
  <xsl:template match="Benchmark">
    <xsl:copy>
      <xsl:attribute name="xmlns">
        <xsl:text>http://checklists.nist.gov/xccdf/1.1</xsl:text>
      </xsl:attribute>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <!-- hack for OpenSCAP validation quirk: must place reference after description/warning, but prior to others -->
  <xsl:template match="Rule">
    <xsl:copy>
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
      <xsl:apply-templates select="node()[not(self::title|self::description|self::warning|self::ref)]"/>
    </xsl:copy>
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
          <xsl:otherwise>
            <xsl:value-of select="." />
          </xsl:otherwise>
        </xsl:choose>
      </ident>
    </xsl:for-each>
  </xsl:template>

  <!-- expand ref attributes to reference tags, one item per reference -->
  <xsl:template match="Rule/ref"> 
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
          <xsl:if test="$refsource = 'dcid'">
            <xsl:value-of select="$dcid63uri" />
          </xsl:if>
          <xsl:if test="$refsource = 'disa'">
            <xsl:value-of select="$disa-cciuri" />
          </xsl:if>
        </xsl:attribute>
        <xsl:value-of select="$refitem" />
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

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <!-- CORRECTING TERRIBLE ABUSE OF NAMESPACES BELOW -->
  <!-- (expanding xhtml tags back into the xhtml namespace) -->
  <xsl:template match="br">
    <xhtml:br />
  </xsl:template>

  <xsl:template match="ul">
    <xhtml:ul>
        <xsl:apply-templates select="@*|node()" />
    </xhtml:ul>
  </xsl:template>

  <xsl:template match="li">
    <xhtml:li>
        <xsl:apply-templates select="@*|node()" />
    </xhtml:li>
  </xsl:template>

  <xsl:template match="tt">
    <xhtml:code>
        <xsl:apply-templates select="@*|node()" />
    </xhtml:code>
  </xsl:template>


  <!-- remove use of tt in titles; xhtml in titles is not allowed -->
  <xsl:template match="title/tt">
        <xsl:apply-templates select="@*|node()" />
  </xsl:template>

  <xsl:template match="code">
    <xhtml:code>
        <xsl:apply-templates select="@*|node()" />
    </xhtml:code>
  </xsl:template>

  <xsl:template match="strong">
    <xhtml:strong>
        <xsl:apply-templates select="@*|node()" />
    </xhtml:strong>
  </xsl:template>

  <xsl:template match="b">
    <xhtml:b>
        <xsl:apply-templates select="@*|node()" />
    </xhtml:b>
  </xsl:template>

  <xsl:template match="em">
    <xhtml:em>
        <xsl:apply-templates select="@*|node()" />
    </xhtml:em>
  </xsl:template>

  <xsl:template match="i">
    <xhtml:i>
        <xsl:apply-templates select="@*|node()" />
    </xhtml:i>
  </xsl:template>

  <xsl:template match="ol">
    <xhtml:ol>
        <xsl:apply-templates select="@*|node()" />
    </xhtml:ol>
  </xsl:template>

  <xsl:template match="pre">
    <xhtml:pre>
        <xsl:apply-templates select="@*|node()" />
    </xhtml:pre>
  </xsl:template>
</xsl:stylesheet>
