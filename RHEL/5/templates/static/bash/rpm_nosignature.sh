grep nosignature /etc/rpmrc /usr/lib/rpm/rpmrc /usr/lib/rpm/redhat/rpmrc ~root/.rpmrc 2>/dev/null | cut -d: -f1 | sort -u | while read RPM_FILE; do
	sed -i 's/nosignature//g' ${RPM_FILE}
done
