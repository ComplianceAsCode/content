
{{%- if product in ["fedora", "ol7", "ol8", "ol9", "ol10", "rhel8", "rhel9", "rhel10", "sle12", "sle15", "slmicro5", "slmicro6", "ubuntu2204", "ubuntu2404"] %}}
perm_x="-F perm=x"
{{%- endif %}}

# Reset the audit rules and set the default augenrules environment.
# Scenarios that test the auditctl case override this with
# 'setup_auditctl_environment' after sourcing this file.
{{{ setup_augenrules_environment() }}}

rm -f /etc/audit/rules.d/*.rules
truncate -s 0 /etc/audit/audit.rules
