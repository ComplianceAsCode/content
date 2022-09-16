# platform = multi_platform_fedora,multi_platform_rhel,multi_platform_ol
# reboot = true
# strategy = restrict
# complexity = low
# disruption = low

{{%- if product in ["rhel7", "ol7"] %}}
  {{%- set auditd_conf_path=audisp_conf_path + "/audispd.conf" %}}
{{%- else %}}
  {{%- set auditd_conf_path=audisp_conf_path + "/auditd.conf" %}}
{{%- endif %}}

{{{set_config_file(path=auditd_conf_path,
                  parameter="name_format",
                  value="hostname",
                  create=true,
                  insensitive=true,
                  separator=" = ",
                  separator_regex="\s*=\s*",
                  prefix_regex="^\s*")}}}


