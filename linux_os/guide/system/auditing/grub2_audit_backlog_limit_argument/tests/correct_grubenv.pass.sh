#!/bin/bash
# platform = Red Hat Enterprise Linux 8

grub2-editenv - set "$(grub2-editenv - list | grep kernelopts) audit_backlog_limit=8192"
