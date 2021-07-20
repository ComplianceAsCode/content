# platform = multi_platform_fedora,multi_platform_rhel
# reboot = true
# strategy = restrict
# complexity = low
# disruption = low

{{{set_config_file(path="/etc/audit/auditd.conf",
                  parameter="overflow_action",
                  value="syslog",
                  separator="=",
                  separator_regex="=",
                  prefix_regex="^\s*")}}}
