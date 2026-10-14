# platform = multi_platform_slmicro
# reboot = true
# strategy = configure
# complexity = low
# disruption = low

tmp_mount_file="/usr/lib/systemd/system/tmp.mount"

# This code runs inside the profile remediation script, so it must not exit:
# that would skip the remediation of every rule after this one.
if grep -qE '^[\s]*Options=[\s]*.*noexec.*$' ${tmp_mount_file}; then
    # already set, skip
    echo "noexec option already present, skipping remediation"
elif ! grep -qE '^[\s]*Options=[\s]*.*$' ${tmp_mount_file}; then
    # no options set, add it
    echo "Options=noexec" >> ${tmp_mount_file}
else
  # collect currently set options
  current_options=$(sed -n 's/^[\s]*Options=[\s]*\(.*\)$/\1/p' ${tmp_mount_file})
  # add noexec to current options and replace
  sed -i "s/^Options=.*/Options=${current_options},noexec/g" ${tmp_mount_file}
fi
