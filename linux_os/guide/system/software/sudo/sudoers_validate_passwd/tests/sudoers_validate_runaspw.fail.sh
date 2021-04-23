# platform = SUSE Linux Enterprise 15
# packages = sudo

if [ $(sudo egrep -i '(!runaspw)' /etc/sudoers /etc/sudoers.d/* | grep -v '#' | wc -l) -ne 0 ]
then
     sed -i '/Defaults !runaspw/d' /etc/sudoers
fi
