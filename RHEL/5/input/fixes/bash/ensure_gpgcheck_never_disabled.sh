grep -R gpgcheck /etc/yum.repos.d/* /etc/yum.conf /root/rpmrc /usr/lib/rpm/redhat/rpmrc /usr/lib/rpm/rpmrc /etc/rpmrc 2>/dev/null | grep -v 'gpgcheck=1' | cut -d: -f1 | sort -u | while read YUM_FILE; do
	sed -i 's/gpgcheck=.*/gpgcheck=1/g' ${YUM_FILE}
done
