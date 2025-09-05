# profiles = xccdf_org.ssgproject.content_profile_ospp

cp $SHARED/audit/10-base-config.rules /etc/audit/rules.d/
echo "some additional text" >> /etc/audit/rules.d/10-base-config.rules
