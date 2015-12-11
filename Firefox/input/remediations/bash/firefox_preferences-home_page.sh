# platform = Mozilla Firefox
. /usr/share/scap-security-guide/remediation_functions
populate var_default_home_page

FIREFOX_DIRS="/usr/lib/firefox /usr/lib64/firefox /usr/local/lib/firefox /usr/local/lib64/firefox"
for FIREFOX_DIR in ${FIREFOX_DIRS}; do
  if [ -d "${FIREFOX_DIR}" ]; then
    grep -q '^lockPref(\"browser.startup.homepage\"' "${FIREFOX_DIR}"/mozilla.cfg && \
    sed -i "s;lockPref(\"browser.startup.homepage\".*;lockPref(\"browser.startup.homepage\", \"${var_default_home_page}\")\;;g" "${FIREFOX_DIR}"/mozilla.cfg
    if ! [ $? -eq 0 ] ; then
      echo "lockPref(\"browser.startup.homepage\", \"${var_default_home_page}\");" >> "${FIREFOX_DIR}"/mozilla.cfg
    fi
  fi
done
