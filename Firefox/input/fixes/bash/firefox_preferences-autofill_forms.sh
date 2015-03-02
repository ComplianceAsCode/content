FIREFOX_DIRs="/usr/lib/firefox /usr/lib64/firefox /usr/local/lib/firefox /usr/local/lib64/firefox"
for FIREFOX_DIR in ${FIREFOX_DIRs}; do
	if [ -e ${FIREFOX_DIR} ]; then
		if [ ! -e ${FIREFOX_DIR}/mozilla.cfg ] || [ "$(grep -c '^lockPref("browser.formfill.enable", false);' ${FIREFOX_DIR}/mozilla.cfg 2>/dev/null)" = "0" ]; then
			if [ ! -e ${FIREFOX_DIR}/mozilla.cfg ]; then
				echo -e '\nlockPref("browser.formfill.enable", false);' >> ${FIREFOX_DIR}/mozilla.cfg
			elif [ "$(grep -c '\"browser.formfill.enable\"' ${FIREFOX_DIR}/mozilla.cfg 2>/dev/null)" != "0" ]; then
				sed -i '/\"browser.formfill.enable\"/d' ${FIREFOX_DIR}/mozilla.cfg
				echo 'lockPref("browser.formfill.enable", false);' >> ${FIREFOX_DIR}/mozilla.cfg
			else
				echo 'lockPref("browser.formfill.enable", false);' >> ${FIREFOX_DIR}/mozilla.cfg
			fi
		fi
	fi
done
