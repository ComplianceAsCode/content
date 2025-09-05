# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,SUSE Linux Enterprise 15
# packages = sudo

if [ $(sudo egrep -i '(!rootpw|!targetpw|!runaspw)' /etc/sudoers /etc/sudoers.d/* | grep -v '#' | wc -l) -ne 0 ]
then
     sed -i '/Defaults !targetpw/{:a;N;/Defaults !runaspw/!ba};/Defaults !rootpw/d' /etc/sudoers
fi
