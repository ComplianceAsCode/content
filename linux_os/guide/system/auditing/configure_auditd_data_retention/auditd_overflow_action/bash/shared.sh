# platform = multi_platform_fedora,multi_platform_rhel,multi_platform_ol
# reboot = true
# strategy = restrict
# complexity = low
# disruption = low

{{{set_config_file(path="/etc/audit/auditd.conf",
                  parameter="overflow_action",
                  value="syslog",
                  insensitive=true,
                  separator=" = ",
                  separator_regex="\s*=\s*",
                  prefix_regex="^\s*")}}}
