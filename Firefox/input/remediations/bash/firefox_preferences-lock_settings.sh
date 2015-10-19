# platform = Mozilla Firefox
FIREFOX_DIRS="/usr/lib/firefox /usr/lib64/firefox /usr/local/lib/firefox /usr/local/lib64/firefox"
for FIREFOX_DIR in ${FIREFOX_DIRS}; do
	if [ -e "${FIREFOX_DIR}" ]; then
		if [ -e "${FIREFOX_DIR}"/defaults/pref ]; then
			PREFERENCE_DIR="${FIREFOX_DIR}/defaults/pref"
		elif [ -e "${FIREFOX_DIR}"/defaults/preferences ]; then
			PREFERENCE_DIR="${FIREFOX_DIR}/defaults/preferences"
		else
			mkdir -p "${FIREFOX_DIR}"/defaults/preferences
			PREFERENCE_DIR="${FIREFOX_DIR}/defaults/preferences"
		fi
		if [ ! -e "${PREFERENCE_DIR}"/security_settings.js ] || [ "$(grep -c '^pref("general.config.obscure_value", 0);' "${PREFERENCE_DIR}"/security_settings.js 2>/dev/null)" = "0" ]; then
			if [ -e "${PREFERENCE_DIR}"/security_settings.js ] && [ "$(grep -c 'general.config.obscure_value' "${PREFERENCE_DIR}"/security_settings.js 2>/dev/null)" != "0" ]; then
				sed -i '/general.config.obscure_value/d' "${PREFERENCE_DIR}"/security_settings.js
			fi
			echo 'pref("general.config.obscure_value", 0);' >> "${PREFERENCE_DIR}"/security_settings.js
		fi			
		if [ ! -e "${PREFERENCE_DIR}"/security_settings.js ] || [ "$(grep -c 'pref("general.config.filename", "mozilla.cfg");' "${PREFERENCE_DIR}"/security_settings.js 2>/dev/null)" = "0" ]; then
			if [ -e "${PREFERENCE_DIR}"/security_settings.js ] && [ "$(grep -c 'general.config.filename' "${PREFERENCE_DIR}"/security_settings.js 2>/dev/null)" != "0" ]; then
				sed -i '/general.config.filename/d' "${PREFERENCE_DIR}"/security_settings.js
			fi
			echo 'pref("general.config.filename", "mozilla.cfg");' >> "${PREFERENCE_DIR}"/security_settings.js
		fi
	fi
done
