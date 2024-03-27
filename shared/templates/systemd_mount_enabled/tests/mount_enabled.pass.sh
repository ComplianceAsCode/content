#!/bin/bash

SYSTEMCTL_EXEC='/usr/bin/systemctl'
"$SYSTEMCTL_EXEC" unmask '{{{ MOUNTNAME }}}.mount'
"$SYSTEMCTL_EXEC" start '{{{ MOUNTNAME }}}.mount'
