# platform = multi_platform_ubuntu
find /lib/ /lib64/ /usr/lib/ /usr/lib64/ \! -gid -1000 -type f -exec chgrp --no-dereference root '{}' \;
