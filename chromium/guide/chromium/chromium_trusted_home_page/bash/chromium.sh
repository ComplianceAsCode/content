# platform = Google Chromium Browser
populate var_trusted_home_page

CHROME_POL_FILE="chrome_stig_policy.json"
CHROME_POL_DIR="/etc/chromium/policies/managed/"
POL_SETTING="HomepageLocation"
POL_SETTING_VAL=$(echo ${var_trusted_home_page} | sed 's/\//\\\/\\/')

grep -q ${POL_SETTING} ${CHROME_POL_DIR}/${CHROME_POL_FILE}

if ! [ $? -eq 0 ] ; then
   sed -i -e '/{/a \  "'${POL_SETTING}'": "'${var_trusted_home_page}'",' ${CHROME_POL_DIR}/${CHROME_POL_FILE}
else
   sed -i -e 's/\"'${POL_SETTING}'\".*/\"'${POL_SETTING}'\": \"'${POL_SETTING_VAL}'\",/g' ${CHROME_POL_DIR}/${CHROME_POL_FILE}
fi
