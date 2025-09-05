# platform = multi_platform_sle,Red Hat Enterprise Linux 8,multi_platform_fedora

find /lib \
/lib64 \
/usr/lib \
/usr/lib64 \
\! -group root -type d -exec chgrp root '{}' \;
