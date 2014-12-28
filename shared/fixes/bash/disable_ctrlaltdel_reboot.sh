# Starting in RHEL6, the behavior to mask ctrl-alt-del
# has changed. Ref:
# RHEL6 Ref: https://access.redhat.com/solutions/449373
# RHEL7 Ref: https://access.redhat.com/solutions/1123873
ln -sf /dev/null /etc/systemd/system/ctrl-alt-del.target
