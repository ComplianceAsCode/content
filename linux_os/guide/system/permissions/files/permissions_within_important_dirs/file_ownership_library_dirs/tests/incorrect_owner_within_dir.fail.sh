# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_sle,multi_platform_ubuntu,multi_platform_almalinux

useradd user_test

TESTDIR="/usr/lib/dir/"

mkdir -p "${TESTDIR}"
touch "${TESTDIR}"/test_me
chown user_test "${TESTDIR}"/test_me
