# platform = multi_platform_ol,multi_platform_rhel,multi_platform_sle,multi_platform_slmicro,multi_platform_ubuntu
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

{{% if aide_also_checks_audispd == "yes" %}}
{{% set auditfiles = auditfiles + ["/usr/sbin/audispd"] %}}
{{% endif %}}

{{% if aide_also_checks_rsyslog == "yes" %}}
{{% set auditfiles = auditfiles + ["/usr/sbin/rsyslogd"] %}}
{{% endif %}}

{{% for file in auditfiles %}}
if grep -i '^.*{{{file}}}.*$' {{{ aide_conf_path }}}; then
sed -i "s#.*{{{file}}}.*#{{{file}}} {{{ aide_string() }}}#" {{{ aide_conf_path }}}
else
echo "{{{ file }}} {{{ aide_string() }}}" >> {{{ aide_conf_path }}}
fi
{{% endfor %}}
