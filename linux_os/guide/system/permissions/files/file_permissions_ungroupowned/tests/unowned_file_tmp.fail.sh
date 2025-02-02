# platform = multi_platform_ubuntu
#!/bin/bash
#
# remediation = none

mount tmpfs /tmp -t tmpfs

touch /tmp/test
chown 9999:9999 /tmp/test
