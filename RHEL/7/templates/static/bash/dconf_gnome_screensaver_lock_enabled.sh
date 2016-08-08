# platform = Red Hat Enterprise Linux 7

# Define constants to be reused below
ORG_GNOME_DESKTOP_SCREENSAVER="org/gnome/desktop/screensaver"
SSG_DCONF_LOCK_ENABLED_FILE="/etc/dconf/db/local.d/10-scap-security-guide"
SCREENSAVER_LOCKS_FILE="/etc/dconf/db/local.d/locks/screensaver"
LOCK_ENABLED_DEFINED="FALSE"
LOCK_DELAY_DEFINED="FALSE"

# First update '[org/gnome/desktop/screensaver] lock-enabled' and
# '[org/gnome/desktop/screensaver] lock-delay' settings in
# /etc/dconf/db/local.d/* if already defined
for FILE in /etc/dconf/db/local.d/*
do
	if grep -q -d skip "$ORG_GNOME_DESKTOP_SCREENSAVER" "$FILE"
	then
		if grep 'lock-enabled' "$FILE"
		then
			sed -i "s/lock-enabled=.*/lock-enabled=true/g" "$FILE"
			LOCK_ENABLED_DEFINED="TRUE"
		fi
		if grep 'lock-delay' "$FILE"
		then
			sed -i "s/lock-delay=.*/lock-delay=uint32 0/g" "$FILE"
			LOCK_DELAY_DEFINED="TRUE"
		fi
	fi
done

# Then define '[org/gnome/desktop/screensaver] lock-enabled' setting
# if still not defined yet
if [ "$LOCK_ENABLED_DEFINED" != "TRUE" ] || [ "$LOCK_DELAY_DEFINED" != "TRUE" ]
then
	echo "" >> $SSG_DCONF_LOCK_ENABLED_FILE
	echo "[org/gnome/desktop/screensaver]" >>  $SSG_DCONF_LOCK_ENABLED_FILE
	echo "lock-enabled=true" >> $SSG_DCONF_LOCK_ENABLED_FILE
	echo "lock-delay=uint32 0" >> $SSG_DCONF_LOCK_ENABLED_FILE
fi

# Verify if 'lock-enabled' modification is locked. If not, lock it
if ! grep -q "^/${ORG_GNOME_DESKTOP_SCREENSAVER}/lock-enabled$" /etc/dconf/db/local.d/locks/*
then
	# Check if "$SCREENSAVER_LOCK_FILE" exists. If not, create it.
	if [ ! -f "$SCREENSAVER_LOCKS_FILE" ]
	then
		touch "$SCREENSAVER_LOCKS_FILE"
	fi
	echo "/${ORG_GNOME_DESKTOP_SCREENSAVER}/lock-enabled" >> "$SCREENSAVER_LOCKS_FILE"
fi


# Verify if 'lock-delay' modification is locked. If not, lock it
if ! grep -q "^/${ORG_GNOME_DESKTOP_SCREENSAVER}/lock-delay$" /etc/dconf/db/local.d/locks/*
then
        # Check if "$SCREENSAVER_LOCK_FILE" exists. If not, create it.
        if [ ! -f "$SCREENSAVER_LOCKS_FILE" ]
        then
                touch "$SCREENSAVER_LOCKS_FILE"
        fi
        echo "/${ORG_GNOME_DESKTOP_SCREENSAVER}/lock-delay" >> "$SCREENSAVER_LOCKS_FILE"
fi
