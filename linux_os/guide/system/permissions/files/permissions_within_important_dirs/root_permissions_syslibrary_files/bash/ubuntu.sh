# platform = multi_platform_ubuntu
find /lib/ /lib64/ /usr/lib/ /usr/lib64/ \! -gid -{{{ gid_min }}} -type f -exec chgrp --no-dereference root '{}' \;
