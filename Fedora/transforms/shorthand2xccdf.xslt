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

<xsl:variable name="ovalfile">unlinked-fedora-oval.xml</xsl:variable>
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
            <xsl:if test="sysctl-check-macro">the correct value is not returned</xsl:if>
            <xsl:if test="fileperms-check-macro or fileowner-check-macro or filegroupowner-check-macro">it does not</xsl:if>
            <xsl:if test="partition-check-macro">no line is returned</xsl:if>
            <xsl:if test="service-disable-check-macro">the service is running</xsl:if>
            <xsl:if test="service-enable-check-macro">the service is not running</xsl:if>
            <xsl:if test="package-check-macro">the package is installed</xsl:if>
            <xsl:if test="module-disable-check-macro">no line is returned</xsl:if>
            <xsl:if test="audit-syscall-check-macro">no line is returned</xsl:if>
            <xsl:if test="sshd-check-macro">the required value is not set</xsl:if>
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
        <xsl:attribute name="href">test_attestation</xsl:attribute>
            <dc:contributor><xsl:value-of select="@by" /></dc:contributor>
            <dc:date><xsl:value-of select="@on" /></dc:date>
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



  <!-- The next set of templates expand convenience macros for XCCDF prose -->
  <xsl:template match="sysctl-desc-macro">
    To set the runtime status of the <xhtml:code><xsl:value-of select="@sysctl"/></xhtml:code> kernel parameter,
    run the following command:
    <xhtml:pre xml:space="preserve"># sysctl -w <xsl:value-of select="@sysctl"/>=<xsl:value-of select="@value"/></xhtml:pre>

	<!-- The following text could also be included conditionally, if the defaultness of the sysctl were indicated. -->
    If this is not the system's default value, add the following line to <xhtml:code>/etc/sysctl.conf</xhtml:code>:
    <xhtml:pre xml:space="preserve"><xsl:value-of select="@sysctl"/> = <xsl:value-of select="@value"/></xhtml:pre>
  </xsl:template>

  <xsl:template match="sysctl-check-macro">
    The status of the <xhtml:code><xsl:value-of select="@sysctl"/></xhtml:code> kernel parameter can be queried
    by running the following command:
    <xhtml:pre xml:space="preserve">$ sysctl <xsl:value-of select="@sysctl"/></xhtml:pre>
    The output of the command should indicate a value of <xhtml:code><xsl:value-of select="@value"/></xhtml:code>.
    If this value is not the default value, investigate how it could have been
    adjusted at runtime, and verify it is not set improperly in
    <xhtml:code>/etc/sysctl.conf</xhtml:code>.
    <!--
	The following text could be conditionally added, for any cases where the default sysctl value
	is not the required one. We could indicate this with an additional attribute
	in the macro.  (Adding default values to sysctl.conf just increases C&A cost with no benefit; it makes default
	systems fail compliance checks when they shouldn't.)

    <xhtml:br />
    To verify persistent configuration of the <xhtml:code><xsl:value-of select="@sysctl"/></xhtml:code> kernel parameter, 
    verify that the following line is present in <xhtml:code>/etc/sysctl.conf</xhtml:code>:
    <xhtml:pre xml:space="preserve">$ sysctl <xsl:value-of select="@sysctl"/></xhtml:pre>    -->
  </xsl:template>

  <xsl:template match="mount-desc-macro">
	Add the <xhtml:code><xsl:value-of select="@option"/></xhtml:code> option to the fourth column of
	<xhtml:code>/etc/fstab</xhtml:code> for the line which controls mounting of
	<xsl:if test="starts-with(@part,'/')">
		<xhtml:code><xsl:value-of select="@part"/></xhtml:code>.
	</xsl:if>
	<xsl:if test="not(starts-with(@part,'/'))">
		<xsl:value-of select="@part"/>.
	</xsl:if>
  </xsl:template>

  <xsl:template match="fileperms-desc-macro">
    To properly set the permissions of <xhtml:code><xsl:value-of select="@file"/></xhtml:code>, run the command:
    <xhtml:pre xml:space="preserve"># chmod <xsl:value-of select="@perms"/> <xsl:value-of select="@file"/></xhtml:pre>
  </xsl:template>

  <xsl:template match="fileowner-desc-macro">
    To properly set the owner of <xhtml:code><xsl:value-of select="@file"/></xhtml:code>, run the command:
    <xhtml:pre xml:space="preserve"># chown <xsl:value-of select="@owner"/> <xsl:value-of select="@file"/> </xhtml:pre>
  </xsl:template>

  <xsl:template match="filegroupowner-desc-macro">
    To properly set the group owner of <xhtml:code><xsl:value-of select="@file"/></xhtml:code>, run the command:
    <xhtml:pre xml:space="preserve"># chgrp <xsl:value-of select="@group"/> <xsl:value-of select="@file"/> </xhtml:pre>
  </xsl:template>

  <xsl:template match="fileperms-check-macro">
    To check the permissions of <xhtml:code><xsl:value-of select="@file"/></xhtml:code>, run the command:
    <xhtml:pre>$ ls -l <xsl:value-of select="@file"/></xhtml:pre>
    If properly configured, the output should indicate the following permissions:
    <xhtml:code><xsl:value-of select="@perms"/></xhtml:code>
  </xsl:template>

  <xsl:template match="fileowner-check-macro">
    To check the ownership of <xhtml:code><xsl:value-of select="@file"/></xhtml:code>, run the command:
    <xhtml:pre>$ ls -lL <xsl:value-of select="@file"/></xhtml:pre>
    If properly configured, the output should indicate the following owner:
    <xhtml:code><xsl:value-of select="@owner"/></xhtml:code>
  </xsl:template>

  <xsl:template match="filegroupowner-check-macro">
    To check the group ownership of <xhtml:code><xsl:value-of select="@file"/></xhtml:code>, run the command:
    <xhtml:pre>$ ls -lL <xsl:value-of select="@file"/></xhtml:pre>
    If properly configured, the output should indicate the following group-owner.
    <xhtml:code><xsl:value-of select="@group"/></xhtml:code>
  </xsl:template>

  <xsl:template match="fileperms-check-macro">
    To check the permissions of <xhtml:code><xsl:value-of select="@file"/></xhtml:code>, run the command:
    <xhtml:pre>$ ls -l <xsl:value-of select="@file"/></xhtml:pre>
    If properly configured, the output should indicate the following permissions:
    <xhtml:code><xsl:value-of select="@perms"/></xhtml:code>
  </xsl:template>

  <xsl:template match="package-install-macro">
    The <xhtml:code><xsl:value-of select="@package"/></xhtml:code> package can be installed with the following command:
    <xhtml:pre># yum install <xsl:value-of select="@package"/></xhtml:pre>
  </xsl:template>

  <xsl:template match="package-remove-macro">
    The <xhtml:code><xsl:value-of select="@package"/></xhtml:code> package can be removed with the following command:
    <xhtml:pre># yum erase <xsl:value-of select="@package"/></xhtml:pre>
  </xsl:template>

  <xsl:template match="partition-check-macro">
    Run the following command to determine if  <xhtml:code><xsl:value-of select="@part"/></xhtml:code>
    is on its own partition or logical volume:

  <xhtml:pre>$ mount | grep "on <xsl:value-of select="@part"/>"</xhtml:pre>
  If <xhtml:code><xsl:value-of select="@part"/></xhtml:code> has its own partition or volume group, a line
  will be returned.
  </xsl:template>

  <xsl:template match="service-disable-macro">
    The <xhtml:code><xsl:value-of select="@service"/></xhtml:code> service can be disabled with the following command:
    <xhtml:pre># systemctl disable <xsl:value-of select="@service"/>.service</xhtml:pre>
  </xsl:template>

  <xsl:template match="service-enable-macro">
    The <xhtml:code><xsl:value-of select="@service"/></xhtml:code> service can be enabled with the following command:
    <xhtml:pre># systemctl enable <xsl:value-of select="@service"/>.service</xhtml:pre>
  </xsl:template>

  <xsl:template match="service-disable-check-macro">
    To check that the <xhtml:code><xsl:value-of select="@service"/></xhtml:code> service is disabled in system boot configuration, run the following command: 
    <xhtml:pre># chkconfig <xhtml:code><xsl:value-of select="@service"/></xhtml:code> --list</xhtml:pre>
    Output should indicate the <xhtml:code><xsl:value-of select="@service"/></xhtml:code> service has either not been installed, 
    or has been disabled at all runlevels, as shown in the example below:
    <xhtml:pre># chkconfig <xhtml:code><xsl:value-of select="@service"/></xhtml:code> --list
<xhtml:code><xsl:value-of select="@service"/></xhtml:code>       0:off   1:off   2:off   3:off   4:off   5:off   6:off</xhtml:pre>

    Run the following command to verify <xhtml:code><xsl:value-of select="@service"/></xhtml:code> is disabled through current runtime configuration:
    <xhtml:pre># service <xsl:value-of select="@service"/> status</xhtml:pre>

    If the service is disabled the command will return the following output:
    <xhtml:pre><xsl:value-of select="@service"/> is stopped</xhtml:pre>
  </xsl:template>

  <xsl:template match="service-enable-check-macro">
    Run the following command to determine the current status of the
<xhtml:code><xsl:value-of select="@service"/></xhtml:code> service:
  <xhtml:pre># service <xsl:value-of select="@service"/> status</xhtml:pre>
    If the service is enabled, it should return the following: <xhtml:pre><xsl:value-of select="@service"/> is running...</xhtml:pre>
  </xsl:template>

  <xsl:template match="package-check-macro">
    Run the following command to determine if the <xhtml:code><xsl:value-of select="@package"/></xhtml:code> package is installed:
    <xhtml:pre># rpm -q <xsl:value-of select="@package"/></xhtml:pre>
  </xsl:template>


  <xsl:template match="module-disable-macro">
To configure the system to prevent the <xhtml:code><xsl:value-of select="@module"/></xhtml:code>
kernel module from being loaded, add the following line to a file in the directory <xhtml:code>/etc/modprobe.d</xhtml:code>:
<xhtml:pre xml:space="preserve">install <xsl:value-of select="@module"/> /bin/false</xhtml:pre>
  </xsl:template>

  <xsl:template match="module-disable-check-macro">
If the system is configured to prevent the loading of the
<xhtml:code><xsl:value-of select="@module"/></xhtml:code> kernel module,
it will contain lines inside any file in <xhtml:code>/etc/modprobe.d</xhtml:code> or the deprecated<xhtml:code>/etc/modprobe.conf</xhtml:code>.
These lines instruct the module loading system to run another program (such as
<xhtml:code>/bin/false</xhtml:code>) upon a module <xhtml:code>install</xhtml:code> event.
Run the following command to search for such lines in all files in <xhtml:code>/etc/modprobe.d</xhtml:code>
and the deprecated <xhtml:code>/etc/modprobe.conf</xhtml:code>:
<xhtml:pre xml:space="preserve">$ grep -r <xsl:value-of select="@module"/> /etc/modprobe.conf /etc/modprobe.d</xhtml:pre>
  </xsl:template>

  <xsl:template match="audit-syscall-check-macro">
To determine if the system is configured to audit calls to
the <xhtml:code><xsl:value-of select="@syscall"/></xhtml:code>
system call, run the following command:
<xhtml:pre xml:space="preserve"># auditctl -l | grep syscall | grep <xsl:value-of select="@syscall"/></xhtml:pre>
If the system is configured to audit this activity, it will return a line.
  </xsl:template>

  <!--Example usage: <iptables-desc-macro allow="true" net="false" proto="tcp" 
       port="80" />  -->
    <!-- allow (boolean): optional attribute which defaults to true, or to 
         allow this traffic through -->
    <!-- net (boolean): optional attribute which determines if -s netwk/mask 
         is put in.  By defaults this is false -->
    <!-- proto (string): protocol in question, typically tcp or udp -->
    <!-- port (integer): port in question -->
  <xsl:template match="iptables-desc-macro">
    <xsl:choose>
      <xsl:when test="@allow = 'false'"> 
      <!-- allow: optional attribute which defaults to true, or to allow this traffic through -->
        To configure <xhtml:code>iptables</xhtml:code> to not allow port 
        <xsl:value-of select="@port"/> traffic one must edit 
        <xhtml:code>/etc/sysconfig/iptables</xhtml:code> and
        <xhtml:code>/etc/sysconfig/ip6tables</xhtml:code> (if IPv6 is in use).
        Remove the following line, ensuring that it does not appear in the INPUT 
        chain:
        <xhtml:pre xml:space="preserve">-A INPUT <xsl:if test="@net = 'true'">-s netwk/mask </xsl:if>-m state --state NEW -p <xsl:value-of select="@proto"/> --dport <xsl:value-of select="@port"/> -j ACCEPT</xhtml:pre>
      </xsl:when>
      <xsl:otherwise>
        To configure <xhtml:code>iptables</xhtml:code> to allow port 
        <xsl:value-of select="@port"/> traffic one must edit 
        <xhtml:code>/etc/sysconfig/iptables</xhtml:code>  and 
        <xhtml:code>/etc/sysconfig/ip6tables</xhtml:code> (if IPv6 is in use).
        Add the following line, ensuring that it appears before the final LOG 
        and DROP lines for the INPUT chain:
        <xhtml:pre xml:space="preserve">-A INPUT <xsl:if test="@net = 'true'">-s netwk/mask </xsl:if>-m state --state NEW -p <xsl:value-of select="@proto"/> --dport <xsl:value-of select="@port"/> -j ACCEPT</xhtml:pre>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="sshd-check-macro">
  <!-- could also do this with sshd -T to test live configuration -->
    To determine how the SSH daemon's
    <xhtml:code><xsl:value-of select="@option"/></xhtml:code>
    option is set, run the following command:
    <xhtml:pre xml:space="preserve"># grep -i <xsl:value-of select="@option"/> /etc/ssh/sshd_config</xhtml:pre>
    <xsl:if test="@default='yes'">
      If no line, a commented line, or a line indicating the value
      <xhtml:code><xsl:value-of select="@value"/></xhtml:code> is returned, then the required value is set.
    </xsl:if>
    <xsl:if test="@default='no' or @default=''">
      If a line indicating <xsl:value-of select="@value"/> is returned, then the required value is set.
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
