#!/bin/bash

DIRS="/lib /lib64 /usr/lib /usr/lib64"
for dirPath in $DIRS; do
    # Limit the test changes to a subset of file in the directory
    # Remediation the whole library dirs is very time consuming
{{% if 'ol8' in product or 'rhel' in product %}}
    find "$dirPath" -type f -regex ".*\.so" -exec chmod go+w '{}' \;
{{% else %}}
    find "$dirPath" -type f -regex ".*\.txt" -exec chmod go+w '{}' \;
{{% endif %}}
done
