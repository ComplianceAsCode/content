#!/bin/bash

{{% if 'ubuntu' in product %}}
for SYSLIBDIRS in /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin
{{% else %}}
for SYSLIBDIRS in /bin /sbin /usr/bin /usr/sbin /usr/local/bin
{{% endif %}}
do
  find -P $SYSLIBDIRS \! -group root -type f -exec chgrp -P root '{}' \;
done
