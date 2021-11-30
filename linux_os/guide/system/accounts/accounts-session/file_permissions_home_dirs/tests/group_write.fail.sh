#!/bin/bash
# remediation = none

useradd -m cacusertest
chmod -f g+w,o=- /home/cacusertest
