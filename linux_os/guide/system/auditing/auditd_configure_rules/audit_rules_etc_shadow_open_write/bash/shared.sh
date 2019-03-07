# platform = multi_platform_sle

echo '
-w /etc/shadow -p wa -k account_mod' >> /etc/audit/audit.rules
