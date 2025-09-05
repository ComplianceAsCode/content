# platform = multi_platform_ubuntu

flag1=1
flag2=1

for file in /etc/apt/apt.conf.d/*; do
    if [ -e "$file" ]; then
        if grep -qi "Unattended-Upgrade::Remove-Unused-Dependencies" $file; then
            sed -i --follow-symlinks "s/^.*Unattended-Upgrade::Remove-Unused-Dependencies.*/Unattended-Upgrade::Remove-Unused-Dependencies \"true\";/I" $file
            flag1=0
        fi

        if grep -qi "Unattended-Upgrade::Remove-Unused-Kernel-Packages" $file; then
            sed -i --follow-symlinks "s/^.*Unattended-Upgrade::Remove-Unused-Kernel-Packages.*/Unattended-Upgrade::Remove-Unused-Kernel-Packages \"true\";/I" $file
            flag2=0
        fi
    fi
done

if [ $flag1 ] || [ $flag2 ]; then
    echo "Unattended-Upgrade::Remove-Unused-Dependencies \"true\";" >> /etc/apt/apt.conf.d/50unattended-upgrades
    echo "Unattended-Upgrade::Remove-Unused-Kernel-Packages \"true\";" >> /etc/apt/apt.conf.d/50unattended-upgrades
fi
