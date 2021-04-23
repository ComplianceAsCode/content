# platform = SUSE Linux Enterprise 15
# packages = sudo

if [ $(sudo egrep -i '(!rootpw)' /etc/sudoers /etc/sudoers.d/* | grep -v '#' | wc -l) -ne 0 ]
then
     sed -i '/Defaults !rootpw/d' /etc/sudoers
fi
