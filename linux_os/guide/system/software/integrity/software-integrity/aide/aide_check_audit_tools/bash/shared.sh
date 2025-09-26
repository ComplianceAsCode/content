# platform = multi_platform_ol,multi_platform_rhel,multi_platform_sle,multi_platform_slmicro,multi_platform_ubuntu,multi_platform_almalinux,multi_platform_debian,multi_platform_fedora
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

{{{ bash_package_install("aide") }}}

{{% set auditfiles = [
      "auditctl",
      "auditd",
      "ausearch",
      "aureport",
      "autrace",
      "augenrules" ] %}}

{{% if aide_also_checks_audispd == "yes" %}}
{{% set auditfiles = auditfiles + ["audispd"] %}}
{{% endif %}}

{{% if aide_also_checks_rsyslog == "yes" %}}
{{% set auditfiles = auditfiles + ["rsyslogd"] %}}
{{% endif %}}

{{% for file in auditfiles %}}
if grep -i -E '^.*(/usr)?/sbin/{{{file}}}.*$' {{{ aide_conf_path }}}; then
sed -i -r "s#.*(/usr)?/sbin/{{{file}}}.*#/usr/sbin/{{{file}}} {{{ aide_string() }}}#" {{{ aide_conf_path }}}
else
echo "/usr/sbin/{{{ file }}} {{{ aide_string() }}}" >> {{{ aide_conf_path }}}
fi
{{% endfor %}}
