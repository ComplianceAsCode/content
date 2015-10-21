# platform = Red Hat Enterprise Linux 7
# The process to disable ctrl+alt+del has changed in RHEL7. 
# Reference: https://access.redhat.com/solutions/1123873
ln -sf /dev/null /etc/systemd/system/ctrl-alt-del.target
