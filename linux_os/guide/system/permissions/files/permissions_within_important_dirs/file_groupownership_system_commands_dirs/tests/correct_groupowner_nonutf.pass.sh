#!/bin/bash

{{% if 'ol9' in product %}}
find -P /bin /sbin /usr/bin /usr/sbin /usr/libexec /usr/local/bin /usr/local/sbin \! -group root -type f -exec chgrp --no-dereference root '{}' \; || true
{{% else %}}
find -P /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin \! -group root -type f -exec chgrp --no-dereference root '{}' \; || true
{{% endif %}}
touch /usr/bin/$(printf "evil_filename_\334_non_utf8_character")
