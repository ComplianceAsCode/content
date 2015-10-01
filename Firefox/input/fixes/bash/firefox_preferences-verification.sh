# platform = Mozilla Firefox
FIREFOX_DIRS="/usr/lib/firefox /usr/lib64/firefox /usr/local/lib/firefox /usr/local/lib64/firefox"
for FIREFOX_DIR in ${FIREFOX_DIRS}; do
  if [ -d "${FIREFOX_DIR}" ]; then
    grep -q '^lockPref(\"security.default_personal_cert\", \"Ask Every Time\");' "${FIREFOX_DIR}"/mozilla.cfg && \
    sed -i 's/lockPref(\"security.default_personal_cert\".*/lockPref(\"security.default_personal_cert\", \"Ask Every Time\");/g' "${FIREFOX_DIR}"/mozilla.cfg
    if ! [ $? -eq 0 ]; then
      echo 'lockPref("security.default_personal_cert", "Ask Every Time");' >> "${FIREFOX_DIR}"/mozilla.cfg
    fi
  fi
done
