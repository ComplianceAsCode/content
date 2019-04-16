<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:cdf="http://checklists.nist.gov/xccdf/1.1" exclude-result-prefixes="cdf"
xmlns:xhtml="http://www.w3.org/1999/xhtml"
xmlns:date="http://exslt.org/dates-and-times" extension-element-prefixes="date" >

<xsl:param name="ssg_version" select="'unknown'"/>

<!-- This transform expects checks with system "ocil-transitional" and that these contain check-content
     that can transformed into OCIL questionnaires.
     -->

  <xsl:template match="/">
  <ocil xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://scap.nist.gov/schema/ocil/2.0" >
   <generator>
     <product_name>xccdf-create-ocil.xslt from SCAP Security Guide</product_name>
     <product_version>ssg: <xsl:value-of select="$ssg_version"/></product_version>
     <schema_version>2.0</schema_version>
     <timestamp><xsl:value-of as="xs:dateTime" select="date:date-time()"/></timestamp>
   </generator>

  <questionnaires>
  <xsl:for-each select=".//cdf:Rule">
  <xsl:if test="cdf:check[@system='ocil-transitional']/cdf:check-content">
    <questionnaire id="{@id}_ocil">
      <title><xsl:value-of select="cdf:title"/></title>
      <actions>
      <test_action_ref><xsl:value-of select="@id"/>_action</test_action_ref>
      </actions>
    </questionnaire>
  </xsl:if>
  </xsl:for-each>
  </questionnaires>

  <test_actions>
  <xsl:for-each select=".//cdf:Rule">
  <xsl:if test="cdf:check[@system='ocil-transitional']/cdf:check-content">
    <boolean_question_test_action id="{@id}_action" question_ref="{@id}_question">
      <when_true>
        <result>PASS</result>
      </when_true>
      <when_false>
        <result>FAIL</result>
      </when_false>
    </boolean_question_test_action>
  </xsl:if>
  </xsl:for-each>
  </test_actions>

  <questions>
  <xsl:for-each select=".//cdf:Rule">
  <xsl:if test="cdf:check[@system='ocil-transitional']/cdf:check-content">
    <boolean_question id="{@id}_question">
      <question_text>
      <xsl:apply-templates select="cdf:check[@system='ocil-transitional']/cdf:check-content"/>
      Is it the case that <xsl:value-of select="cdf:check[@system='ocil-transitional']/cdf:check-export/@export-name"/>?
      </question_text>
    </boolean_question>
  </xsl:if>
  </xsl:for-each>
  </questions>

  </ocil>
  </xsl:template>

    <xsl:template match="xhtml:*">
        <xsl:apply-templates select="node()|@*"/>
    </xsl:template>

  <xsl:template match="cdf:check-content">
  <xsl:apply-templates select="node()"/>
  </xsl:template>

</xsl:stylesheet>
