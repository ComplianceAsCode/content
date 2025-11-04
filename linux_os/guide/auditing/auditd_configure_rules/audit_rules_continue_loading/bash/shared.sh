# platform = multi_platform_all

# Traverse all of:
#
# /etc/audit/audit.rules,			(for auditctl case)
# /etc/audit/rules.d/*.rules			(for augenrules case)
#
# files to check if '-c' setting is present in that '*.rules' file already.
# If found, delete such occurrence
find /etc/audit /etc/audit/rules.d -maxdepth 1 -type f -name '*.rules' -exec sed -i '/-c[[:space:]]\+.*/d' {} ';'

# Append '-c' requirement at the end of both:
# * /etc/audit/audit.rules file 		(for auditctl case)
# * /etc/audit/rules.d/01-initialize.rules		(for augenrules case)

for AUDIT_FILE in "/etc/audit/audit.rules" "/etc/audit/rules.d/01-initialize.rules"
do
	echo '' >> $AUDIT_FILE
	echo '# Set the audit.rules configuration to continue loading rules in spite of an error' >> $AUDIT_FILE
	echo '-c' >> $AUDIT_FILE
	chmod o-rwx $AUDIT_FILE
	chmod g-rwx $AUDIT_FILE
done
