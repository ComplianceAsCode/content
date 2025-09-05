# packages = audit

cp $SHARED/audit/30-ospp-v42.rules /etc/audit/rules.d/
echo "some additional text" >> /etc/audit/rules.d/30-ospp-v42.rules
