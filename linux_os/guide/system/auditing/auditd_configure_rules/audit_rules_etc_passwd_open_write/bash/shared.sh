# platform = multi_platform_sle

echo '
-w /etc/passwd -p wa -k account_mod' >> /etc/audit/audit.rules
