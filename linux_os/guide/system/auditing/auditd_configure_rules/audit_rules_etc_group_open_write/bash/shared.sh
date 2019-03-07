# platform = multi_platform_sle

echo '
-w /etc/group -p wa -k account_mod' >> /etc/audit/audit.rules
