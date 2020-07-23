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
    <xccdf:version update="{$ssg-benchmark-latest-uri}"><xsl:value-of select="$ssg_version"/></xccdf:version>
  </xsl:template>

  <!-- Expand <metadata> element with required information about benchmark's
              publisher, creator, contributor(s), and source -->
  <xsl:template match="Benchmark/metadata">
    <xccdf:metadata>
      <!-- Insert benchmark publisher -->
      <dc:publisher><xsl:value-of select="$ssg-project-name"/></dc:publisher>
      <!-- Insert benchmark creator -->
      <dc:creator><xsl:value-of select="$ssg-project-name"/></dc:creator>
      <!-- Insert list of individual contributors for benchmark -->
      <xsl:for-each select="document('../../Contributors.xml')/text/contributor">
        <dc:contributor><xsl:value-of select="current()" /></dc:contributor>
      </xsl:for-each>
      <!-- Insert benchmark source -->
      <dc:source><xsl:value-of select="$ssg-benchmark-latest-uri"/></dc:source>
    </xccdf:metadata>
  </xsl:template>

  <!-- hack for OpenSCAP validation quirk: must place reference after description/warning, but prior to others -->
  <!-- Another hack for OpenSCAP validation quirk: must place platform after reference/rationale, but prior to others -->
  <xsl:template match="Rule">
    <xsl:choose>
      <xsl:when test="contains(@prodtype, $prod_type) or @prodtype = 'all'">
        <Rule selected="false">
          <!-- set selected attribute to false, to enable profile-driven evaluation -->
          <xsl:apply-templates select="@*" />
          <!-- also: add severity of "low" to each Rule if otherwise unspecified -->
          <xsl:if test="not(@severity)">
            <xsl:attribute name="severity">
              <xsl:value-of select="$defaultseverity" />
            </xsl:attribute>
          </xsl:if>
          <xsl:apply-templates select="title[contains(@prodtype, $prod_type) or not(@prodtype)]"/>
          <xsl:apply-templates select="description[contains(@prodtype, $prod_type) or not(@prodtype)]"/>
          <xsl:apply-templates select="warning[contains(@prodtype, $prod_type) or not(@prodtype)]"/>
          <xsl:apply-templates select="ref[contains(@prodtype, $prod_type) or not(@prodtype)]"/>
          <xsl:apply-templates select="rationale[contains(@prodtype, $prod_type) or not(@prodtype)]"/>
          <xsl:apply-templates select="platform[contains(@prodtype, $prod_type) or not(@prodtype)]"/>
          <xsl:apply-templates select="requires[contains(@prodtype, $prod_type) or not(@prodtype)]"/>
          <xsl:apply-templates select="conflicts[contains(@prodtype, $prod_type) or not(@prodtype)]"/>
          <xsl:apply-templates select="ident[contains(@prodtype, $prod_type) or not(@prodtype)]"/>
          <!-- order oval (shorthand tag) first, to indicate to tools to prefer its automated checks -->
          <xsl:apply-templates select="oval[contains(@prodtype, $prod_type) or not(@prodtype)]"/>
          <xsl:apply-templates select="node()[not(self::title|self::description|self::warning|self::ref|self::rationale|self::requires|self::conflicts|self::platform|self::ident|self::oval|self::prodtype)]"/>
        </Rule>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- Remove this template when prodtype is implemented in all Rule elements -->
  <xsl:template match="Rule[not(@prodtype)]">
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
      <xsl:apply-templates select="rationale"/>
      <xsl:apply-templates select="platform"/>
      <xsl:apply-templates select="requires"/>
      <xsl:apply-templates select="conflicts"/>
      <xsl:apply-templates select="ident"/>
      <!-- order oval (shorthand tag) first, to indicate to tools to prefer its automated checks -->
      <xsl:apply-templates select="oval"/>
      <xsl:apply-templates select="node()[not(self::title|self::description|self::warning|self::ref|self::rationale|self::requires|self::conflicts|self::platform|self::ident|self::oval)]"/>
    </Rule>
  </xsl:template>


  <xsl:template match="Group">
    <xsl:choose>
      <xsl:when test="contains(@prodtype, $prod_type) or @prodtype = 'all'">
        <Group>
          <xsl:apply-templates select="@*" />
          <xsl:apply-templates select="title[contains(@prodtype, $prod_type) or not(@prodtype)]"/>
          <xsl:apply-templates select="description[contains(@prodtype, $prod_type) or not(@prodtype)]"/>
          <xsl:apply-templates select="warning[contains(@prodtype, $prod_type) or not(@prodtype)]"/>
          <xsl:apply-templates select="ref[contains(@prodtype, $prod_type) or not(@prodtype)]"/>
          <xsl:apply-templates select="rationale[contains(@prodtype, $prod_type) or not(@prodtype)]"/>
          <xsl:apply-templates select="platform[contains(@prodtype, $prod_type) or not(@prodtype)]"/>
          <xsl:apply-templates select="requires[contains(@prodtype, $prod_type) or not(@prodtype)]"/>
          <xsl:apply-templates select="conflicts[contains(@prodtype, $prod_type) or not(@prodtype)]"/>
          <xsl:apply-templates select="node()[not(self::title|self::description|self::warning|self::ref|self::rationale|self::requires|self::conflicts|self::platform|self::prodtype)]"/>
        </Group>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- Remove this template when prodtype is implemented in all Group elements -->
  <xsl:template match="Group[not(@prodtype)]">
    <Group>
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates select="title"/>
      <xsl:apply-templates select="description"/>
      <xsl:apply-templates select="warning"/>
      <xsl:apply-templates select="ref"/>
      <xsl:apply-templates select="rationale"/>
      <xsl:apply-templates select="platform"/>
      <xsl:apply-templates select="requires"/>
      <xsl:apply-templates select="conflicts"/>
      <xsl:apply-templates select="node()[not(self::title|self::description|self::warning|self::ref|self::rationale|self::requires|self::conflicts|self::platform)]"/>
    </Group>
  </xsl:template>

  <!-- XHTML, such as tt, is not allowed in titles -->
  <xsl:template match="title/tt">
        <xsl:apply-templates select="@*|node()" />
  </xsl:template>

  <!-- expand reference to ident types -->
  <xsl:template match="Rule/ident">
    <xsl:choose>
      <xsl:when test="contains(@prodtype, $prod_type) or not(@prodtype)">
        <xsl:for-each select="@*[name()!='prodtype']">
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
                    <xsl:value-of select="." />
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:when test="name() = 'stig'">
                <xsl:attribute name="system">
                  <xsl:value-of select="$disa-stigs-uri" />
                </xsl:attribute>
                <xsl:value-of select="." />
              </xsl:when>
              <xsl:when test="name() = 'custom-cce'">
                <xsl:attribute name="system">
                  <xsl:value-of select="$custom-cce-uri" />
                </xsl:attribute>
                <xsl:value-of select="." />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="." />
              </xsl:otherwise>
            </xsl:choose>
          </ident>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="requires">
    <xsl:choose>
      <xsl:when test="contains(@prodtype, $prod_type) or not(@prodtype)"> 
        <requires>
          <xsl:attribute name="idref">
            <xsl:value-of select="@id" />
          </xsl:attribute>
        </requires>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="conflicts">
    <xsl:choose>
      <xsl:when test="contains(@prodtype, $prod_type) or not(@prodtype)">
        <conflicts>
          <xsl:attribute name="idref">
            <xsl:value-of select="@id" />
          </xsl:attribute>
        </conflicts>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- expand ref attributes to reference tags, one item per reference -->
  <xsl:template match="ref">
    <xsl:choose>
      <xsl:when test="contains(@prodtype, $prod_type) or not(@prodtype)">
        <xsl:for-each select="@*[name()!='prodtype']">
          <xsl:call-template name="ref-info" >
            <xsl:with-param name="refsource" select="name()" />
            <xsl:with-param name="refitems" select="." />
          </xsl:call-template>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
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
    <xsl:if test="$refitem != ''">
      <reference>
        <xsl:attribute name="href">
        <!-- populate the href attribute with a global reference-->
          <xsl:if test="$refsource = 'nist'">
            <xsl:value-of select="$nist800-53uri" />
          </xsl:if>
          <xsl:if test="$refsource = 'nist-csf'">
            <xsl:value-of select="$nistcsfuri" />
          </xsl:if>
          <xsl:if test="$refsource = 'isa-62443-2013'">
            <xsl:value-of select="$isa-62443-2013uri" />
          </xsl:if>
          <xsl:if test="$refsource = 'isa-62443-2009'">
            <xsl:value-of select="$isa-62443-2009uri" />
          </xsl:if>
          <xsl:if test="$refsource = 'cobit5'">
            <xsl:value-of select="$cobit5uri" />
          </xsl:if>
          <xsl:if test="$refsource = 'cis-csc'">
            <xsl:value-of select="$cis-cscuri" />
          </xsl:if>
          <xsl:if test="$refsource = 'cjis'">
            <xsl:value-of select="$cjisd-its-uri" />
          </xsl:if>
          <xsl:if test="$refsource = 'cui'">
            <xsl:value-of select="$nist800-171uri" />
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
          <xsl:if test="$refsource = 'pcidss'">
            <xsl:value-of select="$pcidssuri" />
          </xsl:if>
          <xsl:if test="$refsource = 'anssi'">
            <xsl:value-of select="$anssiuri" />
          </xsl:if>

          <xsl:if test="$refsource = 'ospp'">
	          <xsl:value-of select="$osppuri" />
          </xsl:if>
        
          <xsl:if test="$refsource = 'hipaa'">
            <xsl:value-of select="$hipaauri" />
          </xsl:if>
          <xsl:if test="$refsource = 'iso27001-2013'">
            <xsl:value-of select="$iso27001-2013uri" />
          </xsl:if>
          <xsl:if test="$refsource = 'cis'">
            <!-- Precaution for repeated occurrence of issue:
                 https://github.com/OpenSCAP/scap-security-guide/issues/1288 -->
            <xsl:if test="$cisuri != 'empty'">
              <xsl:value-of select="$cisuri" />
            </xsl:if>
          </xsl:if>
          <xsl:if test="$refsource = 'srg'">
            <xsl:if test="starts-with($refitem, 'SRG-OS-')">
              <xsl:value-of select="$disa-ossrguri" />
            </xsl:if>
            <xsl:if test="starts-with($refitem, 'SRG-APP-')">
              <xsl:value-of select="$disa-appsrguri" />
            </xsl:if>
          </xsl:if>
          <xsl:if test="$refsource = 'stigid'">
            <xsl:value-of select="$disa-stigs-uri" />
          </xsl:if>
          <xsl:if test="$refsource = 'custom-ref'">
            <xsl:value-of select="$custom-ref-uri" />
          </xsl:if>
        </xsl:attribute>
        <xsl:choose>
          <xsl:when test="name() = 'disa'">
            <xsl:value-of select='$refitem' />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="normalize-space($refitem)" />
          </xsl:otherwise>
        </xsl:choose>
      </reference>
    </xsl:if>
  </xsl:template>

  <!-- expand reference to OVAL ID -->
  <xsl:template match="Rule/oval">
    <xsl:choose>
      <xsl:when test="contains(@prodtype, $prod_type) or @prodtype = 'all' or not(@prodtype)">
        <check>
          <xsl:attribute name="system">
            <xsl:value-of select="$ovaluri" />
          </xsl:attribute>

          <xsl:for-each select="@*">
          <xsl:choose>
          <xsl:when test="contains(name(),'value')">
            <check-export>
              <xsl:attribute name="export-name">
                <xsl:value-of select="." />
              </xsl:attribute>
              <xsl:attribute name="value-id">
                <xsl:value-of select="." />
              </xsl:attribute>
            </check-export>
          </xsl:when>
          </xsl:choose>
          </xsl:for-each>

          <check-content-ref>
            <xsl:attribute name="href">
              <xsl:value-of select="'oval-unlinked.xml'" />
            </xsl:attribute>
            <xsl:attribute name="name">
              <xsl:value-of select="@id" />
            </xsl:attribute>
          </check-content-ref>
        </check>
      </xsl:when>
    </xsl:choose>
  </xsl:template>


  <!-- expand reference to would-be OCIL (inline) -->
  <xsl:template match="Rule/ocil">
    <xsl:choose>
      <xsl:when test="contains(@prodtype, $prod_type) or @prodtype = 'all' or not(@prodtype)">
        <check>
          <xsl:attribute name="system">ocil-transitional</xsl:attribute>
          <check-export>
            <xsl:attribute name="export-name"><xsl:value-of select="@clause" /></xsl:attribute>
            <xsl:attribute name="value-id">conditional_clause</xsl:attribute>
          </check-export>
          <!-- add the actual manual checking text -->
          <check-content>
            <xsl:apply-templates select="node()"/>
          </check-content>
        </check>
      </xsl:when>
    </xsl:choose>
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
  <xsl:template match="p | code | strong | b | em | i | pre | br | hr | small" >
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

  <xsl:template match="Benchmark/@id">
    <xsl:attribute name="id">
      <xsl:value-of select="$product_guide_id_name"/>
    </xsl:attribute>
  </xsl:template>

  <!-- Removes prodtype from Elements as it is not a part of the XCCDF specification -->
  <xsl:template match="@prodtype"/>

</xsl:stylesheet>
