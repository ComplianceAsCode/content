# platform = Red Hat Enterprise Linux 6

readonly AUDIT_RULES='/etc/audit/audit.rules'

# If '-e .*' setting present in audit.rules already, delete it since the
# auditctl(8) manual page instructs it should be the last rule in configuration
sed -i '/-e[[:space:]]\+.*/d' $AUDIT_RULES

# Append '-e 2' requirement at the end of audit.rules
echo '' >> $AUDIT_RULES
echo '# Set the audit.rules configuration immutable per security requirements' >> $AUDIT_RULES
echo '# Reboot is required to change audit rules once this setting is applied' >> $AUDIT_RULES
echo '-e 2' >> $AUDIT_RULES
