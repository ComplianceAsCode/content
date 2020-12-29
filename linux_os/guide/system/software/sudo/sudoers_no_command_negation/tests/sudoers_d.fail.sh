# platform = multi_platform_all
# packages = sudo
# remediation = none

echo 'nobody ALL=/bin/ls, (!bob alice) /bin/dog, /bin/cat' > /etc/sudoers
echo 'jen		ALL, !SERVERS = ALL' >> /etc/sudoers
echo 'jen !fred		ALL, !SERVERS = /bin/sh' >> /etc/sudoers
echo 'nobody ALL=/bin/ls, (bob !alice) /bin/dog, /bin/cat' > /etc/sudoers.d/foo
# Example from ANSSI R62
echo 'user ALL = ALL ,!/bin/sh' > /etc/sudoers.d/bar
