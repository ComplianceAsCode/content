# platform = multi_platform_all


rm -f /etc/ssh/ssh_config.d/02-rekey-limit.conf
echo "RekeyLimit 1G 1h" >> /etc/ssh/ssh_config.d/02-rekey-limit.conf
