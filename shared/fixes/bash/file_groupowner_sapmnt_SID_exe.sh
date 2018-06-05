# platform = multi_platform_ol
# reboot = false
# strategy = configure
# complexity = low
# disruption = low
find /sapmnt -regex '^/sapmnt/[A-Z][A-Z0-9][A-Z0-9]/exe$' -exec chgrp sapsys {} \;

