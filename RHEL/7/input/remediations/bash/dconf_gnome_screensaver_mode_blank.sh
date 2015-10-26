# platform = Red Hat Enterprise Linux 7

# Define constants to be reused below
ORG_GNOME_DESKTOP_SCREENSAVER="org/gnome/desktop/screensaver"
SSG_DCONF_MODE_BLANK_FILE="/etc/dconf/db/local.d/10-scap-security-guide"
SCREENSAVER_LOCKS_FILE="/etc/dconf/db/local.d/locks/screensaver"
MODE_BLANK_DEFINED="FALSE"

# First update '[org/gnome/desktop/screensaver] picture-uri' settings in
# /etc/dconf/db/local.d/* if already defined
for FILE in /etc/dconf/db/local.d/*
do
	if grep -q -d skip "$ORG_GNOME_DESKTOP_SCREENSAVER" "$FILE"
	then
		if grep 'picture-uri' "$FILE"
		then
			sed -i "s/picture-uri=.*/picture-uri=string ''/g" "$FILE"
			MODE_BLANK_DEFINED="TRUE"
		fi
	fi
done

# Then define '[org/gnome/desktop/screensaver] picture-uri' setting
# if still not defined yet
if [ "$MODE_BLANK_DEFINED" != "TRUE" ]
then
	echo "" >> $SSG_DCONF_MODE_BLANK_FILE
	echo "[org/gnome/desktop/screensaver]" >>  $SSG_DCONF_MODE_BLANK_FILE
	echo "picture-uri=string ''" >> $SSG_DCONF_MODE_BLANK_FILE
fi

# Verify if 'picture-uri' modification is locked. If not, lock it
if ! grep -q "^/${ORG_GNOME_DESKTOP_SCREENSAVER}/picture-uri$" /etc/dconf/db/local.d/locks/*
then
	# Check if "$SCREENSAVER_LOCK_FILE" exists. If not, create it.
	if [ ! -f "$SCREENSAVER_LOCKS_FILE" ]
	then
		touch "$SCREENSAVER_LOCKS_FILE"
	fi
	echo "/${ORG_GNOME_DESKTOP_SCREENSAVER}/picture-uri" >> "$SCREENSAVER_LOCKS_FILE"
fi
