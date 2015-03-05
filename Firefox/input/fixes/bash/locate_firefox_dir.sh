KERNEL=`uname -r`
CERT_DB="/etc/httpd/alias"

if [[ ${KERNEL} = "2.6.9"* ]]; then
	# FIREFOX_DIR=$(ls -d /usr/lib/firefox-*)
	# PREFERENCE_DIR="${FIREFOX_DIR}/defaults/preferences"
	# NOTE: CentOS 4 is no longer supported and the latest version of Firefox does not work.
	exit 0
fi

if [[ ${KERNEL} = "2.6.18"* ]]; then
	if [ -e /usr/local/lib/firefox ]; then
		FIREFOX_DIR="/usr/local/lib/firefox"
	elif [ -e /usr/lib/firefox ]; then
		FIREFOX_DIR="/usr/lib/firefox"
	else
		exit 0
	fi
	if [ -e ${FIREFOX_DIR}/defaults/pref ]; then
		PREFERENCE_DIR="${FIREFOX_DIR}/defaults/pref"
	elif [ -e ${FIREFOX_DIR}/defaults/preferences ]; then
		PREFERENCE_DIR="${FIREFOX_DIR}/defaults/preferences"
	else
		exit 0
	fi
fi
if [[ ${KERNEL} = "2.6.32"* ]]; then
	if [ -e /usr/local/lib/firefox ]; then
		FIREFOX_DIR="/usr/local/lib/firefox"
	elif [ -e /usr/lib/firefox ]; then
		FIREFOX_DIR="/usr/lib/firefox"
	elif [ -e /usr/local/lib64/firefox ]; then
		FIREFOX_DIR="/usr/local/lib64/firefox"
	elif [ -e /usr/lib64/firefox ]; then
		FIREFOX_DIR="/usr/lib64/firefox"
	else
		exit 0
	fi
	if [ -e ${FIREFOX_DIR}/defaults/pref ]; then
		PREFERENCE_DIR="${FIREFOX_DIR}/defaults/pref"
	elif [ -e ${FIREFOX_DIR}/defaults/preferences ]; then
		PREFERENCE_DIR="${FIREFOX_DIR}/defaults/preferences"
	else
		exit 0
	fi
fi




if [ ! -e ${FIREFOX_DIR}/mozilla.cfg ]; then
	echo '//' | tee ${FIREFOX_DIR}/mozilla.cfg &>/dev/null
fi
if [ ! -e ${FIREFOX_DIR}/defaults/profile ]; then
	mkdir -p ${FIREFOX_DIR}/defaults/profile
fi

export CERT_DB
export KERNEL
export FIREFOX_DIR
export PREFERENCE_DIR
