#!/bin/bash

find / -xdev -type d -perm -0002 -gid +999 -print | xargs -I{} chown root {}
