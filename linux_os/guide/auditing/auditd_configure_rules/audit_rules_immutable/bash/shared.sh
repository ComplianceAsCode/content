# platform = Red Hat Virtualization 4,multi_platform_almalinux,multi_platform_debian,multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_sle,multi_platform_slmicro,multi_platform_ubuntu

# Both rule loaders honour only the last '-e' directive they process:
#
# * augenrules(8) concatenates /etc/audit/rules.d/*.rules in version sort order
#   and emits the last '-e' directive it sees as the last line of the generated
#   /etc/audit/audit.rules, so a later file with '-e 0' or '-e 1' overrides
#   an earlier '-e 2'.
# * auditctl(8) -R locks the kernel as soon as '-e 2' is processed and every
#   directive after it fails to load, so '-e 2' must be the last directive in
#   /etc/audit/audit.rules.
#
# Therefore remove every '-e' directive from the other /etc/audit/rules.d/*.rules
# files (augenrules case) and make sure '-e 2' is the one and only '-e'
# directive and the last non-comment line of both:
# * /etc/audit/audit.rules file 		(for auditctl case)
# * /etc/audit/rules.d/immutable.rules		(for augenrules case)

for RULES_FILE in /etc/audit/rules.d/*.rules
do
	[ -f "$RULES_FILE" ] || continue
	[ "$RULES_FILE" = "/etc/audit/rules.d/immutable.rules" ] && continue
	if grep -q '^[[:space:]]*-e[[:space:]]\+' "$RULES_FILE"; then
		sed -i '/^[[:space:]]*-e[[:space:]]\+/d' "$RULES_FILE"
	fi
done

for AUDIT_FILE in "/etc/audit/audit.rules" "/etc/audit/rules.d/immutable.rules"
do
	# Nothing to do when '-e 2' is already the only '-e' directive
	# and no other directive follows it
	if [ -f "$AUDIT_FILE" ] \
		&& [ "$(grep -c '^[[:space:]]*-e[[:space:]]\+' "$AUDIT_FILE")" -eq 1 ] \
		&& grep -v '^[[:space:]]*\(#.*\)\?$' "$AUDIT_FILE" | tail -n 1 | grep -q '^[[:space:]]*-e[[:space:]]\+2[[:space:]]*$'
	then
		continue
	fi
	if [ -f "$AUDIT_FILE" ]; then
		sed -i '/^[[:space:]]*-e[[:space:]]\+/d' "$AUDIT_FILE"
	fi
	echo '' >> $AUDIT_FILE
	echo '# Set the audit.rules configuration immutable per security requirements' >> $AUDIT_FILE
	echo '# Reboot is required to change audit rules once this setting is applied' >> $AUDIT_FILE
	echo '-e 2' >> $AUDIT_FILE
	chmod o-rwx $AUDIT_FILE
	chmod g-rwx $AUDIT_FILE
done
