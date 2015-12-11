# platform = Mozilla Firefox
. /usr/share/scap-security-guide/remediation_functions
populate var_required_file_types

FIREFOX_DIRS="/usr/lib/firefox /usr/lib64/firefox /usr/local/lib/firefox /usr/local/lib64/firefox"
for FIREFOX_DIR in ${FIREFOX_DIRS}; do
  if [ -d "${FIREFOX_DIR}" ]; then
    grep -q '^lockPref(\"plugin.disable_full_page_plugin_for_types\"' "${FIREFOX_DIR}"/mozilla.cfg && \
    sed -i "s;lockPref(\"plugin.disable_full_page_plugin_for_types\".*;lockPref(\"plugin.disable_full_page_plugin_for_types\", \"${var_required_file_types}\")\;;g" "${FIREFOX_DIR}"/mozilla.cfg
    if ! [ $? -eq 0 ] ; then
      echo "lockPref(\"plugin.disable_full_page_plugin_for_types\", \"${var_required_file_types}\");" >> "${FIREFOX_DIR}"/mozilla.cfg
    fi
  fi
done
