# packages = audit

cp $SHARED/audit/11-loginuid.rules /etc/audit/rules.d/
echo "some additional text" >> /etc/audit/rules.d/11-loginuid.rules
