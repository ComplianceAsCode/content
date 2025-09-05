#!/bin/bash
#
GROUP=ssgttgroup

groupadd ${GROUP}
chgrp ${GROUP} /etc/passwd
