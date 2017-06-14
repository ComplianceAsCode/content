# platform = Webmin
. /usr/share/scap-security-guide/remediation_functions
populate var_webmin_sessions_login_banner_text

if [ "$(grep -c '^loginbanner=' /etc/webmin/config)" = "0" ]; then
	echo loginbanner=/etc/webmin/login_banner >> /etc/webmin/config
else
	sed -i 's/^loginbanner=.*/loginbanner=\/etc\/webmin\/login_banner/' /etc/webmin/config
fi
echo $var_webmin_sessions_login_banner_text | sed -e 's/\[\\s\\n\][+|*]/ /g' -e 's/\&amp;/\&/g' -e 's/\\//g' -e 's/ - /\n- /g' >/etc/webmin/login_banner
echo "<a href='LOGINURL'>Click here to login</a>" >> /etc/webmin/login_banner
