<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns:cdf="http://checklists.nist.gov/xccdf/1.1" xmlns:cpe="http://cpe.mitre.org/language/2.0"
    xmlns:cpe-naming="http://cpe.mitre.org/naming/2.0"
    xmlns:xml="http://www.w3.org/XML/1998/namespace"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xhtml="http://www.w3.org/1999/xhtml">
    
    <xsl:output method="html" encoding="utf-8" omit-xml-declaration="yes" indent="no"/>
    <xsl:template match="cdf:Benchmark">
        <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
                <title><xsl:value-of select="/cdf:Benchmark/cdf:title"/></title>
                <style type="text/css">
                    BODY{
                        font-family:Geneva, Arial, Helvetica, sans-serif;
                        font-size:90%;
                    }
                    OL{
                        margin-left:20px;
                        padding-left:5px;
                        color:#000000;
                    }
                    H1{
                        text-align:center;
                        color:#CC0000;
                    }
                    H2{
                        font-size:150%;
                        color:#781F1C;
                    }
                    H3{
                        font-size:125%;
                        color:#781F1C;
                    }
                    A{
                        color:#CC0000;
                    }
                    #TOC{
                        background:#CECECE;
                        padding-left:10px;
                        padding-bottom:5px;
                        border:1px solid #000000;
                    }
                    #TOC P{
                        margin-left:2em;
                        margin-bottom:0.2em;
                        margin-top:0.5em;
                    }
                    .group{
                        font-weight:bold;
                    }
                    .rule{
                        font-style:italic;
                    }
                    .padItem{
                        padding-left:25px;
                    }
                    .item{
                        padding-top:15px;
                    }
                    .subItem{
                        padding:5px;
                        padding-right:5px;
                        border:1px solid #000000;
                        background:#CECECE;
                    }
                    .itemHead{
                        font-weight:bold;
                        font-style:italic;
                        color:#781F1C;
                    }
                    .itemSubHead{
                        font-weight:bold;
                        text-decoration:underline;
                    }
                    .label{
                        font-weight:bold;
                    }
                    pre {
                        white-space: pre-wrap;
                        white-space: -moz-pre-wrap;
                        white-space: -o-pre-wrap;
                        background: #FFE2E0;
                    }
                    code {
                        display: block;
                        padding: 5px;
                        font-family: Courier;
                        border: 1px solid #000000;
                    }
                </style>
            </head>
            <body>
                <!-- Header -->
                <div align="center"><img src="jboss_logo.png" alt="JBoss" border="0"/></div>
                <h1><xsl:value-of select="/cdf:Benchmark/cdf:title"/></h1>
                
                <p></p>
                
                <!-- Status -->
                <hr />
                <p style="text-align: center;"><strong>Status: </strong><xsl:value-of select="/cdf:Benchmark/cdf:status"/><strong> Date: </strong><xsl:value-of select="/cdf:Benchmark/cdf:status/@date"/></p>
                
                <!-- Notice -->
                <hr />
                <h2><a name="SectionNotice">Notice</a></h2><xsl:value-of select="/cdf:Benchmark/cdf:notice"/>
                
                <!-- Table of Contents -->
                <hr/>
                <h2><a name="SectionTOC">Table of Contents</a></h2>
                <div id="TOC">
                    <h3><a href="#SectionNotice">Notice</a></h3>
                    <h3><a href="#SectionFM">Front Matter</a></h3>
                    <h3><a href="#SectionReqs">Requirements</a></h3>
                    <h3><a href="#SectionRunning">Steps to Run</a></h3>
                    <h3><a href="#SectionProfiles">Profiles</a></h3>
                    <ol>
                    <xsl:for-each select="/cdf:Benchmark/cdf:Profile">
                        <li><a href='#profile_{@id}'><xsl:value-of select="cdf:title"/></a></li>
                    </xsl:for-each>
                    </ol>
                    <h3><a href="#Sectionguidance">Guidance</a></h3>
                    <ol>
                    <xsl:for-each select="/cdf:Benchmark/cdf:Group">
                        <xsl:variable name="groupNum" select="position()"/>
                        <li><a href="#group_{@id}"><span class="group"><xsl:value-of select="cdf:title"/></span></a><ol>
                        <xsl:for-each select="cdf:Rule">
                            <li><a href="#rule_{@id}"><span class="rule"><xsl:value-of select="cdf:title"/></span></a></li> 
                        </xsl:for-each>
                        </ol></li>
                    </xsl:for-each>
                    </ol>
                    <h3><a href="#SectionRM">Rear Matter</a></h3>
                </div>
                
                <!-- Front Matter -->
                <h2><a name="SectionFM">Front Matter</a></h2><xsl:apply-templates select="/cdf:Benchmark/cdf:front-matter"/>
                <hr />
                <p><strong>Platform(s): </strong></p>
                <ul>
                <xsl:for-each select="/cdf:Benchmark/cdf:platform">
                    <li><xsl:value-of select="@idref" /></li>
                </xsl:for-each>
                </ul>
                
                <!-- Requirements -->
                <hr />
                <h2><a name="SectionReqs">Requirements</a></h2><xsl:copy-of select="document('requirements.html')/html/body"/>
                
                <!-- Steps to Run -->
                <hr />
                <h2><a name="SectionRunning">Steps to Run</a></h2><xsl:copy-of select="document('steps_to_run.html')/html/body"/>
                
                <!-- Profiles -->
                <hr />     
                <h2><a name="SectionProfiles">Profiles</a></h2>
                <xsl:for-each select="/cdf:Benchmark/cdf:Profile">
                    <div class="padItem">
                        <div class="item"><span class="itemHead"><xsl:value-of select="position()"/>. <a name="profile_{@id}"><xsl:value-of select="cdf:title"/></a></span>
                            <p><xsl:apply-templates select="cdf:description"/></p>
                            <span class="label">Profile Name: </span> <xsl:value-of select="@id"/> <br/>
                        </div>
                    </div>
                </xsl:for-each>

                <!-- Guidance -->
                <hr />
                <h2><a name="Sectionguidance">Guidance</a></h2>
                <xsl:for-each select="/cdf:Benchmark/cdf:Group">
                    <xsl:variable name="groupNum" select="position()"/>
                    <h3><a name="group_{@id}"><xsl:value-of select="cdf:title"/></a></h3>
                    <p><xsl:apply-templates select="cdf:description"/></p>
                    <xsl:for-each select="cdf:Rule">       
                        <div class="padItem">
                            <div class="item"><span class="itemHead"><xsl:value-of select="$groupNum"/>.<xsl:value-of select="position()"/> - <a name="rule_{@id}"><xsl:value-of select="cdf:title"/></a></span>
                                <p><xsl:apply-templates select="cdf:description"/></p>
                                
                                <xsl:if test="boolean(cdf:rationale)">
                                    <div class="subItem"><span class="itemSubHead">Rationale</span><br />
                                        <xsl:apply-templates select="cdf:rationale"/>
                                    </div>
                                    <div style="height: 4px;"></div>
                                </xsl:if>
                                
                                <div class="subItem"><span class="itemSubHead">Additional information</span><br />
                                    <p>
                                        <xsl:if test="boolean(cdf:profile-note[@tag='risk_score'])">
                                            <span class="label">CVSSv2 Risk Assessment: </span><xsl:value-of select="normalize-space(cdf:profile-note[@tag='risk_score'])"/>
                                            <xsl:if test="boolean(cdf:profile-note[@tag='risk_level'])">
                                                / <xsl:value-of select="normalize-space(cdf:profile-note[@tag='risk_level'])"/>
                                            </xsl:if>
                                            <xsl:if test="boolean(cdf:profile-note[@tag='risk_formula'])">
                                                - CVSSv2 Formula: <xsl:value-of select="normalize-space(cdf:profile-note[@tag='risk_formula'])"/>
                                            </xsl:if>
                                            <br/>
                                        </xsl:if>
									</p>
									<p>
										<xsl:if test="boolean(cdf:profile-note[@tag='dod_cat'])">
                                            <span class="label">DoD Risk Category: </span><xsl:value-of select="cdf:profile-note[@tag='dod_cat']"/> <br/>
                                        </xsl:if>
									</p>
									<p>
                                        <xsl:if test="boolean(cdf:profile-note[@tag='nist_mapping'])">
                                            <span class="label">NIST 800.53 Mapping: </span><xsl:value-of select="cdf:profile-note[@tag='nist_mapping']"/> <br/>
                                        </xsl:if>
									</p>
									<p>
                                        <xsl:if test="boolean(cdf:profile-note[@tag='disa_mapping'])">
                                            <span class="label">DoD 8500.2 Mapping: </span><xsl:value-of select="cdf:profile-note[@tag='disa_mapping']"/> <br/>
                                        </xsl:if>
                                    </p>
                                </div>
                                <div style="height: 4px;"></div>
                                
                                <xsl:if test="boolean(cdf:profile-note[@tag='validation_text'])">
                                    <div class="subItem"><span class="itemSubHead">Validation instructions</span><br />
                                        <xsl:apply-templates select="cdf:profile-note[@tag='validation_text']"/>
                                    </div>
                                    <div style="height: 4px;"></div>
                                </xsl:if>
                                
                                <xsl:if test="boolean(cdf:fixtext)">
                                    <div class="subItem"><span class="itemSubHead">Remediation instructions</span><br />
                                        <xsl:apply-templates select="cdf:fixtext"/>
                                    </div>
                                    <div style="height: 4px;"></div>
                                </xsl:if>
                                
                                <xsl:if test="boolean(cdf:reference)">
                                    <div class="subItem"><span class="itemSubHead">References</span>
                                        <p>
                                            <xsl:for-each select="cdf:reference">
                                                <span class="label"><xsl:value-of select="position()"/>. </span><xsl:value-of select="text()"/> <br/>
                                            </xsl:for-each>
                                        </p>
                                    </div>
                                    <div style="height: 4px;"></div>
                                </xsl:if>
                                
                                <xsl:if test="boolean(cdf:check)">
                                    <div class="subItem"><span class="itemSubHead">Check Summary</span>
                                    <xsl:for-each select="cdf:check">
                                        <p><span class="label">System: </span><xsl:value-of select="@system"/> <br/>
                                           <span class="label">Name: </span><xsl:value-of select="cdf:check-content-ref/@name"></xsl:value-of> <br/>
                                           <span class="label">File: </span><a href="..\{cdf:check-content-ref/@href}" target="_blank"><xsl:value-of select="cdf:check-content-ref/@href"/></a>
                                        </p>
                                    </xsl:for-each>
                                    </div>
                                    <div style="height: 4px;"></div>
                                </xsl:if>
                                
                            </div>
                        </div>
                    </xsl:for-each>
                </xsl:for-each>
                
                <!-- Rear Matter -->
                <hr />
                <h2><a name="SectionRM">Rear Matter</a></h2><xsl:apply-templates select="/cdf:Benchmark/cdf:rear-matter"/>
            </body>
        </html>
    </xsl:template>
    
    <xsl:template match="xhtml:*">
        <xsl:element name="{local-name()}">
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>
 
    <xsl:template match="@*|text()|comment()|processing-instruction()">
        <xsl:copy/>
    </xsl:template>
    
</xsl:stylesheet>
