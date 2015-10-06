# platform = Mozilla Firefox
FIREFOX_DIRS="/usr/lib/firefox /usr/lib64/firefox /usr/local/lib/firefox /usr/local/lib64/firefox"
for FIREFOX_DIR in ${FIREFOX_DIRS}; do
  if [ -d "${FIREFOX_DIR}" ] ; then
    PREFERENCE_DIR="${FIREFOX_DIR}"/defaults/preferences/
    
    if [ ! -d "${PREFERENCE_DIR}" ]; then
      mkdir -p -m 755 "${PREFERENCE_DIR}"
    fi

    grep -q 'pref(\"general.config.filename\", \"mozilla.cfg\");' "${PREFERENCE_DIR}"/security_settings.js && \
    sed -i 's/pref(\"general.config.filename\".*/pref(\"general.config.filename\", \"mozilla.cfg\");/g' "${PREFERENCE_DIR}"/security_settings.js
    if ! [ $? -eq 0 ] ; then
      echo 'pref("general.config.filename", "mozilla.cfg");' >> "${PREFERENCE_DIR}"/security_settings.js
    fi
  fi
done
