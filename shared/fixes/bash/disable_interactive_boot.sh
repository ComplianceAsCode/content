# platform = multi_platform_rhel, multi_platform_fedora

{{%- if init_system == "systemd" -%}}
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
{{%- else -%}}
# Ensure value of PROMPT key in /etc/sysconfig/init is set to 'no'
grep -q ^PROMPT /etc/sysconfig/init && \
  sed -i "s/PROMPT.*/PROMPT=no/g" /etc/sysconfig/init
if ! [ $? -eq 0 ]; then
    echo "PROMPT=no" >> /etc/sysconfig/init
fi

# Ensure 'confirm' kernel boot argument is not present in some of
# kernel lines in /etc/grub.conf
sed -i --follow-symlinks "s/confirm//gI" /etc/grub.conf
{{%- endif -%}}
