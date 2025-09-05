#!/bin/bash
# platform = multi_platform_ubuntu

file=/etc/apt/apt.conf.d/50unattended-upgrades

if grep -qi "Unattended-Upgrade::Remove-Unused-Dependencies" $file; then
    sed -i "s/Unattended-Upgrade::Remove-Unused-Dependencies.*/Unattended-Upgrade::Remove-Unused-Dependencies \"false\";/" $file
else
    echo "Unattended-Upgrade::Remove-Unused-Dependencies \"false\";" >> $file
fi

if grep -qi "Unattended-Upgrade::Remove-Unused-Kernel-Packages" $file; then
    sed -i "s/Unattended-Upgrade::Remove-Unused-Kernel-Packages.*/Unattended-Upgrade::Remove-Unused-Kernel-Packages \"false\";/" $file
else
    echo "Unattended-Upgrade::Remove-Unused-Kernel-Packages \"false\";" >> $file
fi
