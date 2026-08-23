#!/bin/bash

groupadd group_test

{{% if 'ol9' in product %}}
find -P /bin/ /sbin/ /usr/bin/ /usr/sbin/ /usr/libexec /usr/local/bin/ /usr/local/sbin/ \! -group root -type f -exec chgrp --no-dereference root {} \; || true
{{% else %}}
find -P /bin/ /sbin/ /usr/bin/ /usr/sbin/ /usr/local/bin/ /usr/local/sbin/ \! -group root -type f -exec chgrp --no-dereference root {} \; || true
{{% endif %}}

ln -s $(mktemp -p /tmp) /usr/bin/test.log.symlink
chgrp -h group_test /usr/bin/test.log.symlink
