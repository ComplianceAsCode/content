#!/bin/bash
# platform = multi_platform_ubuntu

echo 'Acquire::Check-Date "true";' > /etc/apt/apt.conf.d/99-cis-repository-security
echo '#clear Acquire::Check-Date;' >> /etc/apt/apt.conf
