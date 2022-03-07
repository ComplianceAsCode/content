#!/bin/bash
{{% if product in ['rhel9'] %}}
# variables = var_mount_option_proc_hidepid=invisible
{{% else %}}
# variables = var_mount_option_proc_hidepid=2
{{% endif %}}

sed -i '/^proc/d' /etc/fstab
mount -oremount,hidepid=2 /proc
