# platform = SUSE Linux Enterprise 15
# packages = sudo

if [ $(sudo egrep -i '(!targetpw)' /etc/sudoers /etc/sudoers.d/* | grep -v '#' | wc -l) -ne 0 ]
then
     sed -i '/Defaults !targetpw/d' /etc/sudoers
fi
