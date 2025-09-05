#! /bin/bash
# platform = multi_platform_ol,multi_platform_rhel
# variables = var_accounts_authorized_local_users_regex=^(root|bin|daemon|adm|lp|sync|shutdown|halt|mail|operator|games|ftp|nobody|pegasus|systemd-bus-proxy|systemd-network|dbus|polkitd|abrt|unbound|tss|libstoragemgmt|rpc|colord|usbmuxd$|pcp|saslauth|geoclue|setroubleshoot|rtkit|chrony|qemu|radvd|rpcuser|nfsnobody|pulse|gdm|gnome-initial-setup|postfix|avahi|ntp|sshd|tcpdump|oprofile|uuidd)$

var_accounts_authorized_local_users_regex="^(root|bin|daemon|adm|lp|sync|shutdown|halt|mail|operator|games|ftp|nobody|pegasus|systemd-bus-proxy|systemd-network|dbus|polkitd|abrt|unbound|tss|libstoragemgmt|rpc|colord|usbmuxd$|pcp|saslauth|geoclue|setroubleshoot|rtkit|chrony|qemu|radvd|rpcuser|nfsnobody|pulse|gdm|gnome-initial-setup|postfix|avahi|ntp|sshd|tcpdump|oprofile|uuidd)$"

# never delete the root user
default_os_user="root"

# delete users that is in /etc/passwd but neither in default_os_user
# nor in var_accounts_authorized_local_users_regex
for username in $( sed 's/:.*//' /etc/passwd ) ; do
	if [[ ! "$username" =~ ($default_os_user|$var_accounts_authorized_local_users_regex) ]];
        then
		userdel $username ;
	fi
done
