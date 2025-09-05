# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_sle,multi_platform_ubuntu

useradd user_test

TESTDIR="/usr/lib/"

# The check ignores this symlink and results in pass
ln -s $TESTDIR/missing_test_file $TESTDIR/faulty_symlink
chown -h user_test $TESTDIR/faulty_symlink
