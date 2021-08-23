# platform = multi_platform_rhel,multi_platform_ubuntu
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low
. /usr/share/scap-security-guide/remediation_functions

{{{ bash_package_install("aide") }}}

{{% set configString = "p+i+n+u+g+s+b+acl+xattrs+sha512" %}}
{{% set configFile = "/etc/aide.conf" %}}
{{% for file in (
      "/usr/sbin/auditctl",
      "/usr/sbin/auditd",
      "/usr/sbin/ausearch",
      "/usr/sbin/aureport",
      "/usr/sbin/autrace",
      "/usr/sbin/augenrules" ) %}}

if grep -i '^.*{{{file}}}.*$' {{{ configFile }}}; then
sed -i "s#.*{{{file}}}.*#{{{file}}} {{{ configString }}}#" {{{ configFile }}}
else
echo "{{{ file }}} {{{ configString }}}" >> {{{ configFile }}}
fi
{{% endfor %}}
