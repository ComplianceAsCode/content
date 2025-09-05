#!/bin/bash
# remediation = none

useradd -m cacusertest
chmod -f g-w+s,o=t /home/cacusertest
