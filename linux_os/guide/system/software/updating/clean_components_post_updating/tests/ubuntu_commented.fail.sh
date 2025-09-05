#!/bin/bash
# platform = multi_platform_ubuntu

file=/etc/apt/apt.conf.d/50unattended-upgrades

if grep -qi "Unattended-Upgrade::Remove-Unused-Dependencies" $file; then
    sed -i "s/Unattended-Upgrade::Remove-Unused-Dependencies.*/\/\/ Unattended-Upgrade::Remove-Unused-Dependencies.*/I" $file
else
    echo "// Unattended-Upgrade::Remove-Unused-Dependencies \"true\";" >> $file
fi

if grep -qi "Unattended-upgrade::remove-unused-kernel-packages" $file; then
    sed -i "s/Unattended-upgrade::remove-unused-kernel-packages.*/\/\/ Unattended-upgrade::remove-unused-kernel-packages.*/I" $file
else
    echo "// Unattended-Upgrade::Remove-Unused-Kernel-Packages \"true\";" >> $file
fi
