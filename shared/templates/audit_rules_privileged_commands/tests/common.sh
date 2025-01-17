
{{%- if product in ["fedora", "ol7", "ol8", "ol9", "ol10", "rhel8", "rhel9", "rhel10", "sle12", "sle15", "slmicro5", "ubuntu2004", "ubuntu2204", "ubuntu2404"] %}}
perm_x="-F perm=x"
{{%- endif %}}


rm -f /etc/audit/rules.d/*.rules
truncate -s 0 /etc/audit/audit.rules
