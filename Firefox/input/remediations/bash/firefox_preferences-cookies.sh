# platform = Mozilla Firefox
FIREFOX_DIRS="/usr/lib/firefox /usr/lib64/firefox /usr/local/lib/firefox /usr/local/lib64/firefox"
for FIREFOX_DIR in ${FIREFOX_DIRS}; do
	if [ -e "${FIREFOX_DIR}" ]; then
		if [ ! -e "${FIREFOX_DIR}"/mozilla.cfg ] || [ "$(grep -c '^lockPref("privacy.sanitize.sanitizeOnShutdown", true);' "${FIREFOX_DIR}"/mozilla.cfg 2>/dev/null)" = "0" ]; then
			if [ ! -e "${FIREFOX_DIR}"/mozilla.cfg ]; then
				echo -e '\nlockPref("privacy.sanitize.sanitizeOnShutdown", true);' >> "${FIREFOX_DIR}"/mozilla.cfg
			elif [ "$(grep -c '\"privacy.sanitize.sanitizeOnShutdown\"' "${FIREFOX_DIR}"/mozilla.cfg 2>/dev/null)" != "0" ]; then
				sed -i '/\"privacy.sanitize.sanitizeOnShutdown\"/d' "${FIREFOX_DIR}"/mozilla.cfg
				echo 'lockPref("privacy.sanitize.sanitizeOnShutdown", true);' >> "${FIREFOX_DIR}"/mozilla.cfg
			else
				echo 'lockPref("privacy.sanitize.sanitizeOnShutdown", true);' >> "${FIREFOX_DIR}"/mozilla.cfg
			fi
		fi
		if [ "$(grep -c '^lockPref("privacy.sanitize.promptOnSanitize", false);' "${FIREFOX_DIR}"/mozilla.cfg 2>/dev/null)" = "0" ]; then
			if [ "$(grep -c '\"privacy.sanitize.promptOnSanitize\"' "${FIREFOX_DIR}"/mozilla.cfg 2>/dev/null)" != "0" ]; then
				sed -i '/\"privacy.sanitize.promptOnSanitize\"/d' "${FIREFOX_DIR}"/mozilla.cfg
				echo 'lockPref("privacy.sanitize.promptOnSanitize", false);' >> "${FIREFOX_DIR}"/mozilla.cfg
			else
				echo 'lockPref("privacy.sanitize.promptOnSanitize", false);' >> "${FIREFOX_DIR}"/mozilla.cfg
			fi
		fi
	fi
done
