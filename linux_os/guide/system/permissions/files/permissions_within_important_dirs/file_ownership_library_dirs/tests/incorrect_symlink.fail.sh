# platform = multi_platform_sle,multi_platform_rhel,multi_platform_fedora,multi_platform_ubuntu

useradd user_test

TESTDIR="/usr/lib/"

# The remediation performs a 'find' followed by a 'chwon'
# While 'find' doesn't follow symlinks by default, 'chown' does follow,
# so 'chown' will try to change owner of a non existent file while 'find'
# pointed out that the symlink has wrong owner.
ln -s $TESTDIR/mising_test_file $TESTDIR/faulty_symlink
chown -h user_test $TESTDIR/faulty_symlink

# The Check ignores symlink, so we need to put a reason to run the remediations
touch $TESTDIR/test_me
chown user_test $TESTDIR/test_me
