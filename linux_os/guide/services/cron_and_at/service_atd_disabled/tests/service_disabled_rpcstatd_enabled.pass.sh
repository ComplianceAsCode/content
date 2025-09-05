#!/bin/bash
# packages = nfs-utils at
#

# this test ensures that only the atd.service is matched, not for example the service rpc-statd

systemctl disable atd.service
systemctl add-wants default.target rpc-statd.service
