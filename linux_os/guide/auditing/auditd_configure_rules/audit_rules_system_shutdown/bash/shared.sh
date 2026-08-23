# platform = multi_platform_all

{{{ bash_instantiate_variables("var_audit_failure_mode") }}}

# Traverse all of:
#
# /etc/audit/audit.rules,			(for auditctl case)
# /etc/audit/rules.d/*.rules			(for augenrules case)
find /etc/audit /etc/audit/rules.d -maxdepth 1 -type f -name '*.rules' -exec sed -i '/-f[[:space:]]\+.*/d' {} ';'

for AUDIT_FILE in "/etc/audit/audit.rules" "/etc/audit/rules.d/immutable.rules"
do
	echo '' >> $AUDIT_FILE
	echo '# Set the audit.rules configuration to halt system upon audit failure per security requirements' >> $AUDIT_FILE
	echo "-f $var_audit_failure_mode" >> $AUDIT_FILE
done
