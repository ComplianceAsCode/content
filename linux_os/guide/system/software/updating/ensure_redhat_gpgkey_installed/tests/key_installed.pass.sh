#!/bin/bash
#
# platform = Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,Red Hat Enterprise Linux 10

. /etc/os-release

case "${ID}:${VERSION_ID%%.*}" in
    centos:10)
        key_file=/etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial-SHA256
        ;;
    centos:*)
        key_file=/etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
        ;;
    *)
        key_file=/etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
        ;;
esac

rpm --import "$key_file"
