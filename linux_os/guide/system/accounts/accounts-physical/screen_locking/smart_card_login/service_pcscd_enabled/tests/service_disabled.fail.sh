#!/bin/bash

# packages = pcsc-lite

SYSTEMCTL_EXEC='/usr/bin/systemctl'
# pcscd uses socket activation; pcscd.socket must also be stopped and disabled
# otherwise the SCE check sees an enabled/active socket and returns pass
"$SYSTEMCTL_EXEC" stop 'pcscd.socket'
"$SYSTEMCTL_EXEC" disable 'pcscd.socket'
"$SYSTEMCTL_EXEC" stop 'pcscd.service'
"$SYSTEMCTL_EXEC" disable 'pcscd.service'
