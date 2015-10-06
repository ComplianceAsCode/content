# platform = Mozilla Firefox
FIREFOX_DIRS="/usr/lib/firefox /usr/lib64/firefox /usr/local/lib/firefox /usr/local/lib64/firefox"
for FIREFOX_DIR in ${FIREFOX_DIRS}; do
  if [ -d "${FIREFOX_DIR}" ]; then
    grep -q '^lockPref(\"extensions.update.enabled\", false);' "${FIREFOX_DIR}"/mozilla.cfg && \
    sed -i 's/lockPref(\"extensions.update.enabled\".*/lockPref(\"extensions.update.enabled\", false);/g' "${FIREFOX_DIR}"/mozilla.cfg
    if ! [ $? -eq 0 ] ; then
        echo "lockPref(\"extensions.update.enabled\", false);" >> "${FIREFOX_DIR}"/mozilla.cfg
    fi
  fi
done

