# platform = multi_platform_slmicro
# reboot = true
# strategy = configure
# complexity = low
# disruption = low

tmp_mount_file="/usr/lib/systemd/system/tmp.mount"

# if already set, skip
if grep -qE '^[\s]*Options=[\s]*.*noexec.*$' ${tmp_mount_file}; then
    echo "noexec option already present, skipping remediation"
    exit 0
fi

# no options set, add it
if ! grep -qE '^[\s]*Options=[\s]*.*$' ${tmp_mount_file}; then
    echo "Options=noexec" >> ${tmp_mount_file}
else
  # collect currently set options
  current_options=$(sed -n 's/^[\s]*Options=[\s]*\(.*\)$/\1/p' ${tmp_mount_file})
  # add noexec to current options and replace
  sed -i "s/^Options=.*/Options=${current_options},noexec/g" ${tmp_mount_file}
fi
