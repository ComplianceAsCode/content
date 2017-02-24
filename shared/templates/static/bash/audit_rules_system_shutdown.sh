# platform = Red Hat Enterprise Linux 7, multi_platform_fedora

# Traverse all of:
#
# /etc/audit/audit.rules,			(for auditctl case)
# /etc/audit/rules.d/*.rules			(for augenrules case)
#
# files to check if '-f .*' setting is present in that '*.rules' file already.
# If found, delete such occurrence since auditctl(8) manual page instructs the
# '-f 2' rule should be placed as the last rule in the configuration
find /etc/audit /etc/audit/rules.d -maxdepth 1 -type f -name *.rules -exec sed -i '/-e[[:space:]]\+.*/d' {} ';'

# Append '-f 2' requirement at the end of both:
# * /etc/audit/audit.rules file 		(for auditctl case)
# * /etc/audit/rules.d/immutable.rules		(for augenrules case)

for AUDIT_FILE in "/etc/audit/audit.rules" "/etc/audit/rules.d/immutable.rules"
do
	echo '' >> $AUDIT_FILE
	echo '# Set the audit.rules configuration to halt system upon audit failure per security requirements' >> $AUDIT_FILE
	echo '-f 2' >> $AUDIT_FILE
done
