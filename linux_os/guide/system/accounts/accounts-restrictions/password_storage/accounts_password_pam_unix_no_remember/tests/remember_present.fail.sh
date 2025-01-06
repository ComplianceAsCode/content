#!/bin/bash
# platform = multi_platform_ubuntu

for FILE in "/etc/pam.d/common-*"; do
    if ! grep -q "^[^#].*pam_unix\.so.*\bremember=\d+\b" ${FILE}; then
        sed -i 's/\(^[^#].*pam_unix\.so\)/\1 remember=1/g' ${FILE}
    fi
done

