#!/bin/bash
# platform = multi_platform_debian
# remediation = none

find /etc/apt/apt.conf.d/ -type f -exec sed -i '/APT::Install-Recommends/Id;/APT::Install-Suggests/Id' {} \;
