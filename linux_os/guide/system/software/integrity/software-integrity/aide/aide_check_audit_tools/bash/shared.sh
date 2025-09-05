# platform = multi_platform_rhel,multi_platform_ubuntu,multi_platform_sle
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

{{{ bash_package_install("aide") }}}

{{% set auditfiles = [
      "/usr/sbin/auditctl",
      "/usr/sbin/auditd",
      "/usr/sbin/ausearch",
      "/usr/sbin/aureport",
      "/usr/sbin/autrace",
      "/usr/sbin/augenrules" ] %}}

{{% if 'rhel' not in product %}}
{{% set auditfiles = auditfiles + ["/usr/sbin/audispd"] %}}
{{% endif %}}

{{% set configString = "p+i+n+u+g+s+b+acl+xattrs+sha512" %}}
{{% for file in auditfiles %}}

if grep -i '^.*{{{file}}}.*$' {{{ aide_conf_path }}}; then
sed -i "s#.*{{{file}}}.*#{{{file}}} {{{ configString }}}#" {{{ aide_conf_path }}}
else
echo "{{{ file }}} {{{ configString }}}" >> {{{ aide_conf_path }}}
fi
{{% endfor %}}
