#!/bin/bash
# profiles = profile_not_found
# remediation = bash

yum install -y audit audispd-plugins

sed -i "/^enable_krb5[[:space:]]*=.*$/d" /etc/audisp/audisp-remote.conf
