<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!-- This file is used to hold constants used across several transforms. -->
<!-- Constants are called variables in XSLT.  At this point this is not a surprise. -->

<!-- abbreviated as idents in the XCCDF-->
<xsl:variable name="cceuri">https://nvd.nist.gov/cce/index.cfm</xsl:variable>

<!-- abbreviated as references in the XCCDF-->
<xsl:variable name="nist800-53uri">http://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-53r4.pdf</xsl:variable>
<xsl:variable name="nist800-171uri">http://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-171.pdf</xsl:variable>
<xsl:variable name="cjisd-its-uri">https://www.fbi.gov/file-repository/cjis-security-policy-v5_5_20160601-2-1.pdf</xsl:variable>
<xsl:variable name="cnss1253uri">http://www.cnss.gov/Assets/pdf/CNSSI-1253.pdf</xsl:variable>
<xsl:variable name="dcid63uri">not_officially_available</xsl:variable>
<xsl:variable name="disa-cciuri">http://iase.disa.mil/stigs/cci/Pages/index.aspx</xsl:variable>
<xsl:variable name="disa-ossrguri">http://iase.disa.mil/stigs/os/general/Pages/index.aspx</xsl:variable>
<xsl:variable name="disa-appsrguri">http://iase.disa.mil/stigs/app-security/app-servers/Pages/general.aspx</xsl:variable>
<!-- Fix for issue https://github.com/OpenSCAP/scap-security-guide/issues/1035 -->
<xsl:variable name="disa-stigs-os-unix-linux-uri">http://iase.disa.mil/stigs/os/unix-linux/Pages/index.aspx</xsl:variable>
<xsl:variable name="disa-stigs-os-mainframe-uri">http://iase.disa.mil/stigs/os/mainframe/Pages/index.aspx</xsl:variable>
<xsl:variable name="disa-stigs-apps-browers-uri">http://iase.disa.mil/stigs/app-security/browser-guidance/Pages/index.aspx</xsl:variable>
<xsl:variable name="disa-stigs-apps-appserver-uri">http://iase.disa.mil/stigs/app-security/app-servers/Pages/index.aspx</xsl:variable>
<xsl:variable name="disa-stigs-apps-appsecurity-dev-uri">http://iase.disa.mil/stigs/app-security/app-security/Pages/index.aspx</xsl:variable>
<xsl:variable name="disa-stigs-apps-web-server-uri">http://iase.disa.mil/stigs/app-security/web-servers/Pages/index.aspx</xsl:variable>
<xsl:variable name="pcidssuri">https://www.pcisecuritystandards.org/documents/PCI_DSS_v3-1.pdf</xsl:variable>
<xsl:variable name="anssiuri">http://www.ssi.gouv.fr/administration/bonnes-pratiques/</xsl:variable>
<xsl:variable name="ssg-contributors-uri">https://github.com/OpenSCAP/scap-security-guide/wiki/Contributors</xsl:variable>
<xsl:variable name="ssg-project-name">SCAP Security Guide Project</xsl:variable>
<xsl:variable name="ssg-benchmark-latest-uri">https://github.com/OpenSCAP/scap-security-guide/releases/latest</xsl:variable>

<xsl:variable name="ovaluri">http://oval.mitre.org/XMLSchema/oval-definitions-5</xsl:variable>

<xsl:variable name="ociltransitional">ocil-transitional</xsl:variable>
<xsl:variable name="ocil_cs">http://scap.nist.gov/schema/ocil/2</xsl:variable>
<xsl:variable name="ocil_ns">http://scap.nist.gov/schema/ocil/2.0</xsl:variable>
</xsl:stylesheet>
