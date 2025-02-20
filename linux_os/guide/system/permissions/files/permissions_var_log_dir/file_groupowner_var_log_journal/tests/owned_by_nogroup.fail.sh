#!/bin/bash
# platform = Ubuntu 24.04
# packages = systemd


touch /var/log/test.journal
touch /var/log/test.journal~
chgrp nogroup /var/log/test.journal
chgrp nogroup /var/log/test.journal~

