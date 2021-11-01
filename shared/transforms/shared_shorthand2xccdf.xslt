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
                 https://github.com/ComplianceAsCode/content/issues/1288 -->
            <xsl:if test="$cisuri != 'empty'">
              <xsl:value-of select="$cisuri" />
            </xsl:if>
          </xsl:if>
          <xsl:if test="$refsource = 'nerc-cip'">
            <xsl:value-of select="$nerc-cipuri" />
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

  <!-- expand reference to OVAL ID inside single complex-check -->
  <xsl:template match="Rule/complex-check/oval">
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

  <!-- expand reference to OVAL ID inside double complex-check (e.g., OCIL + SCE + OVAL) -->
  <xsl:template match="Rule/complex-check/complex-check/oval">
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
