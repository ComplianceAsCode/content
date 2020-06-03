# remediation = none

#!/bin/bash

# remove any non-system user
sed -Ei '/^root|nologin$|halt$|sync$|shutdown$/!d' /etc/passwd
