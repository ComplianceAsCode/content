{{%- if product in ["fedora", "ol7", "ol8", "ol9", "rhel8", "rhel9", "rhel10", "sle12", "sle15", "ubuntu2004", "ubuntu2204"] %}}
perm_x="-F perm=x"
{{%- endif %}}

rm -f /etc/audit/rules.d/*.rules
truncate -s 0 /etc/audit/audit.rules
