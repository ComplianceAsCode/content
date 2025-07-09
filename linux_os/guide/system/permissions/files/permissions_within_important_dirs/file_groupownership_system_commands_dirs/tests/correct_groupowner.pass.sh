#!/bin/bash

{{% if 'ubuntu' in product %}}
for SYSLIBDIRS in /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin
{{% else %}}
for SYSLIBDIRS in /bin /sbin /usr/bin /usr/sbin /usr/local/bin
{{% endif %}}
do
  find -L  $SYSLIBDIRS \! -group root -type f -exec chgrp root '{}' \;
done
