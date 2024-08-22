# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,SUSE Linux Enterprise 15,multi_platform_slmicro
# packages = sudo

touch /etc/sudoers.d/empty
if [ $(grep -Ei '(!runaspw)' /etc/sudoers /etc/sudoers.d/* | grep -v '#' | wc -l) -ne 0 ]
then
     sed -i '/Defaults !runaspw/d' /etc/sudoers /etc/sudoers.d/*
fi
