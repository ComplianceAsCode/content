#!/bin/bash

SYSTEMCTL_EXEC='/usr/bin/systemctl'
"$SYSTEMCTL_EXEC" stop '{{{ MOUNTNAME }}}.mount'
"$SYSTEMCTL_EXEC" mask '{{{ MOUNTNAME }}}.mount'
