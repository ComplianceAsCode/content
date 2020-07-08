#!/bin/bash

# selinux does not allow unlabeled_t in /dev
# we have to modify the selinux policy to allow that

echo '(allow unlabeled_t device_t (filesystem (associate)))' > /tmp/unlabeled_t.cil
semodule -i /tmp/unlabeled_t.cil

mknod /dev/foo c 1 5
chcon -t unlabeled_t /dev/foo


mknod /dev/foo c 1 5
chcon -t device_t /dev/foo
