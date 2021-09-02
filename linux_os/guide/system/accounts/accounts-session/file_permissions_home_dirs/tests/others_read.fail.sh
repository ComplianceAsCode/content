#!/bin/bash
# remediation = none

useradd -m cacusertest
chmod -f g-w,o+r /home/cacusertest
