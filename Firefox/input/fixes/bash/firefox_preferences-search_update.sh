# platform = Mozilla Firefox
FIREFOX_DIRS="/usr/lib/firefox /usr/lib64/firefox /usr/local/lib/firefox /usr/local/lib64/firefox"
for FIREFOX_DIR in ${FIREFOX_DIRS}; do
  if [ -d "${FIREFOX_DIR}" ]; then
    grep -q '^lockPref(\"browser.search.update\", false);' "${FIREFOX_DIR}"/mozilla.cfg && \
    sed -i 's/lockPref(\"browser.search.update\".*/lockPref(\"browser.search.update\", false);/g' "${FIREFOX_DIR}"/mozilla.cfg
    if ! [ $? -eq 0 ] ; then
      echo 'lockPref("browser.search.update", false);' >> "${FIREFOX_DIR}"/mozilla.cfg
    fi
  fi
done
