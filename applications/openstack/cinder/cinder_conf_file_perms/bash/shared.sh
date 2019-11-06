<<<<<<< HEAD
# platform = Red Hat OpenStack Platform 10
=======
>>>>>>> 9c329e7d95f2ebe891551fc5e51e82838caf741d
for file in /etc/cinder/cinder.conf \
		/etc/cinder/rootwrap.conf; do
	chown root $file
	chgrp cinder $file
done
<<<<<<< HEAD
=======

>>>>>>> 9c329e7d95f2ebe891551fc5e51e82838caf741d
