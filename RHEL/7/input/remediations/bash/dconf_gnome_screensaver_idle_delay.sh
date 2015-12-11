# platform = Red Hat Enterprise Linux 7
. /usr/share/scap-security-guide/remediation_functions
populate inactivity_timeout_value

# Define constants to be reused below
ORG_GNOME_DESKTOP_SESSION="org/gnome/desktop/session"
SSG_DCONF_IDLE_DELAY_FILE="/etc/dconf/db/local.d/10-scap-security-guide"
SESSION_LOCKS_FILE="/etc/dconf/db/local.d/locks/session"
IDLE_DELAY_DEFINED="FALSE"

# First update '[org/gnome/desktop/session] idle-delay' settings in
# /etc/dconf/db/local.d/* if already defined
for FILE in /etc/dconf/db/local.d/*
do
	if grep -q -d skip "$ORG_GNOME_DESKTOP_SESSION" "$FILE"
	then
		if grep 'idle-delay' "$FILE"
		then
			sed -i "s/idle-delay=.*/idle-delay=uint32 ${inactivity_timeout_value}/g" "$FILE"
			IDLE_DELAY_DEFINED="TRUE"
		fi
	fi
done

# Then define '[org/gnome/desktop/session] idle-delay' setting
# if still not defined yet
if [ "$IDLE_DELAY_DEFINED" != "TRUE" ]
then
	echo "" >> $SSG_DCONF_IDLE_DELAY_FILE
	echo "[org/gnome/desktop/session]" >>  $SSG_DCONF_IDLE_DELAY_FILE
	echo "idle-delay=uint32 ${inactivity_timeout_value}" >> $SSG_DCONF_IDLE_DELAY_FILE
fi

# Verify if 'idle-delay' modification is locked. If not, lock it
if ! grep -q "^/${ORG_GNOME_DESKTOP_SESSION}/idle-delay$" /etc/dconf/db/local.d/locks/*
then
	# Check if "$SESSION_LOCK_FILE" exists. If not, create it.
	if [ ! -f "$SESSION_LOCKS_FILE" ]
	then
		touch "$SESSION_LOCKS_FILE"
	fi
	echo "/${ORG_GNOME_DESKTOP_SESSION}/idle-delay" >> "$SESSION_LOCKS_FILE"
fi

