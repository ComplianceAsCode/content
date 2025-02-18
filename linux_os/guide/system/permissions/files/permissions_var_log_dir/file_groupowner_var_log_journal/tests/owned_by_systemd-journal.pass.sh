#!/bin/bash
# platform = Ubuntu 24.04
# packages = systemd

touch /var/log/test.journal
touch /var/log/test.journal~
chgrp systemd-journal /var/log/test.journal
chgrp systemd-journal /var/log/test.journal~
