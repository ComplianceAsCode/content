# platform = multi_platform_fedora,multi_platform_rhel,multi_platform_ol
# reboot = true
# strategy = restrict
# complexity = low
# disruption = low

{{% if product in ["rhel8", "fedora", "ol8", "rhv4"] %}}
{{% set audisp_conf_file = "/etc/audit/auditd.conf" %}}
{{% else %}}
{{% set audisp_conf_file = "/etc/audisp/audispd.conf" %}}
{{% endif %}}

{{{set_config_file(path=audisp_conf_file,
                  parameter="overflow_action",
                  value="syslog",
                  insensitive=true,
                  separator=" = ",
                  separator_regex="\s*=\s*",
                  prefix_regex="^\s*")}}}
