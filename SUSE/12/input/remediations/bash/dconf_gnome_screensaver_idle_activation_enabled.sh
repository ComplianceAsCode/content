# platform = Red Hat Enterprise Linux 7

# Define constants to be reused below
ORG_GNOME_DESKTOP_SCREENSAVER="org/gnome/desktop/screensaver"
SSG_DCONF_IDLE_ACTIVATION_FILE="/etc/dconf/db/local.d/10-scap-security-guide"
SCREENSAVER_LOCKS_FILE="/etc/dconf/db/local.d/locks/screensaver"
IDLE_ACTIVATION_DEFINED="FALSE"

# First update '[org/gnome/desktop/screensaver] idle-activation-enabled' settings in
# /etc/dconf/db/local.d/* if already defined
for FILE in /etc/dconf/db/local.d/*
do
	if grep -q -d skip "$ORG_GNOME_DESKTOP_SCREENSAVER" "$FILE"
	then
		if grep 'idle-activation-enabled' "$FILE"
		then
			sed -i "s/idle-activation-enabled=.*/idle-activation-enabled=true/g" "$FILE"
			IDLE_ACTIVATION_DEFINED="TRUE"
		fi
	fi
done

# Then define '[org/gnome/desktop/screensaver] idle-activation-enabled' setting
# if still not defined yet
if [ "$IDLE_ACTIVATION_DEFINED" != "TRUE" ]
then
	echo "" >> $SSG_DCONF_IDLE_ACTIVATION_FILE
	echo "[org/gnome/desktop/screensaver]" >>  $SSG_DCONF_IDLE_ACTIVATION_FILE
	echo "idle-activation-enabled=true" >> $SSG_DCONF_IDLE_ACTIVATION_FILE
fi

# Verify if 'idle-activation-enabled' modification is locked. If not, lock it
if ! grep -q "^/${ORG_GNOME_DESKTOP_SCREENSAVER}/idle-activation-enabled$" /etc/dconf/db/local.d/locks/*
then
	# Check if "$SCREENSAVER_LOCK_FILE" exists. If not, create it.
	if [ ! -f "$SCREENSAVER_LOCKS_FILE" ]
	then
		touch "$SCREENSAVER_LOCKS_FILE"
	fi
	echo "/${ORG_GNOME_DESKTOP_SCREENSAVER}/idle-activation-enabled" >> "$SCREENSAVER_LOCKS_FILE"
fi

