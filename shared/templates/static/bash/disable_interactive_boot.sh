# platform = Red Hat Enterprise Linux 7, multi_platform_fedora

# Systemd confirm_spawn regex to search for and delete if found
CONFIRM_SPAWN_REGEX="systemd.confirm_spawn=\(1\|yes\|true\|on\)"

# Modify both the GRUB_CMDLINE_LINUX and GRUB_CMDLINE_LINUX_DEFAULT directives
for grubcmdline in "GRUB_CMDLINE_LINUX" "GRUB_CMDLINE_LINUX_DEFAULT"
do
  # Remove 'systemd.confirm_spawn' argument from /etc/default/grub if found
  if grep -q "^${grubcmdline}=\".*${CONFIRM_SPAWN_REGEX}.*\"" /etc/default/grub
  then
    # Remove all three possible occurrences of CONFIRM_SPAWN_REGEX:
    # At the start
    sed -i "s/\"${CONFIRM_SPAWN_REGEX} /\"/" /etc/default/grub
    # At the end
    sed -i "s/ ${CONFIRM_SPAWN_REGEX}\"$/\"/" /etc/default/grub
    # In the middle
    sed -i "s/ ${CONFIRM_SPAWN_REGEX}//" /etc/default/grub
  fi
done
# Remove 'systemd.confirm_spawn' kernel argument also from runtime settings
/sbin/grubby --update-kernel=ALL --remove-args="systemd.confirm_spawn"
