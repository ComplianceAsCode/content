# platform =  Webmin

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions
populate var_webmin_sessions_login_banner_text

WEBMIN_CONFIG_FILE="/etc/webmin/config"
WEBMIN_BANNER="/etc/webmin/login_banner"
if [ "$(grep -c '^loginbanner=' $WEBMIN_CONFIG_FILE)" = "0" ]; then
	echo loginbanner=$WEBMIN_BANNER >> $WEBMIN_CONFIG_FILE
else
	sed -i "s;^loginbanner=.*;loginbanner=$WEBMIN_BANNER;" $WEBMIN_CONFIG_FILE
fi
echo $var_webmin_sessions_login_banner_text | sed -e 's/\[\\s\\n\][+|*]/ /g' -e 's/\&amp;/\&/g' -e 's/\\//g' -e 's/ - /\n- /g' >$WEBMIN_BANNER
echo "<a href='LOGINURL'>Click here to login</a>" >> $WEBMIN_BANNER