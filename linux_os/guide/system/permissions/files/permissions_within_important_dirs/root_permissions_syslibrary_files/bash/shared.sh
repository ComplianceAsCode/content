# platform = multi_platform_sle,Oracle Linux 8,Red Hat Enterprise Linux 8,multi_platform_fedora

find /lib \
/lib64 \
/usr/lib \
/usr/lib64 \
\! -group root -type f -exec chgrp root '{}' \;
