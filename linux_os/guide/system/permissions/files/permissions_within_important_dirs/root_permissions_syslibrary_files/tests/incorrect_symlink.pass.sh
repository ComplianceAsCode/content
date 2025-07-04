#!/bin/bash
# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_sle,multi_platform_ubuntu,multi_platform_almalinux

groupadd group_test

TESTDIR="/usr/lib64"

mkdir -p "$TESTDIR"

# The check ignores this symlink and results in pass
ln -s $TESTDIR/missing_test_file $TESTDIR/faulty_symlink
chgrp -h group_test $TESTDIR/faulty_symlink
