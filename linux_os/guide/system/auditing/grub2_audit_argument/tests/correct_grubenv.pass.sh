#!/bin/bash
# platform = Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9

grub2-editenv - set "$(grub2-editenv - list | grep kernelopts) audit=1"
