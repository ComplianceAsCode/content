INCLUDE_SHARED_REMEDIATION_FUNCTIONS
populate system_login_banner_text

echo $system_login_banner_text | sed -e 's/\[\\s\\n\][+|*]/ /g' -e 's/\&amp;/\&/g' -e 's/\\//g' -e 's/ - /\n- /g' >/etc/issue
