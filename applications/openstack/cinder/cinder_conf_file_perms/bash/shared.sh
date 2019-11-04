for file in /etc/cinder/cinder.conf \
		/etc/cinder/rootwrap.conf; do
	chown root $file
	chgrp cinder $file
done

