# platform = Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9

{{% set option = "systemd.debug-shell" -%}}
# Correct BLS option using grubby, which is a thin wrapper around BLS operations
{{{ grub_command("remove", option) }}}

# Ensure new kernels and boot entries retain the boot option
if grep -q '\b{{{ option }}}\b' /etc/kernel/cmdline; then
    sed -Ei 's/^(.*)\s*{{{ option }}}\b\S*(.*)/\1\2/' /etc/kernel/cmdline
fi
