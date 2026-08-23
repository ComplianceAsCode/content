# platform = multi_platform_all

cp /usr/share/doc/audit*/rules/10-base-config.rules /etc/audit/rules.d
cp /usr/share/doc/audit*/rules/11-loginuid.rules /etc/audit/rules.d
cp /usr/share/doc/audit*/rules/30-ospp-v42.rules /etc/audit/rules.d
cp /usr/share/doc/audit*/rules/43-module-load.rules /etc/audit/rules.d
chmod 0600 /etc/audit/rules.d/10-base-config.rules
chmod 0600 /etc/audit/rules.d/11-loginuid.rules
chmod 0600 /etc/audit/rules.d/30-ospp-v42.rules
chmod 0600 /etc/audit/rules.d/43-module-load.rules

augenrules --load
