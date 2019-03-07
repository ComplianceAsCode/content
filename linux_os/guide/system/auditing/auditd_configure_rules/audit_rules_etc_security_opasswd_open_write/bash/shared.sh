# platform = multi_platform_sle

echo '
-w /etc/security/opasswd -p wa -k account_mod' >> /etc/audit/audit.rules
