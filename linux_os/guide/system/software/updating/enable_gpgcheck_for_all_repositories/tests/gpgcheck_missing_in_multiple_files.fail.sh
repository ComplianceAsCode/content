#!/bin/bash
rm -rf /etc/yum.repos.d/
mkdir -p /etc/yum.repos.d/

cat > /etc/yum.repos.d/fedora.repo <<EOF
[fedora]
name=Fedora 41 - x86_64
metalink=https://mirrors.fedoraproject.org/metalink?repo=fedora-41&arch=x86_64
enabled=1
countme=1
metadata_expire=7d
repo_gpgcheck=0
type=rpm
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-41-x86_64
skip_if_unavailable=False
EOF

cat > /etc/yum.repos.d/fedora_debug.repo <<EOF
[fedora-debuginfo]
name=Fedora 41 - x86_64 - Debug
metalink=https://mirrors.fedoraproject.org/metalink?repo=fedora-debug-41&arch=x86_64
enabled=1
metadata_expire=7d
repo_gpgcheck=0
type=rpm
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-41-x86_64
skip_if_unavailable=False
EOF

cat > /etc/yum.repos.d/fedora_source.repo <<EOF
[fedora-source]
name=Fedora 41 - Source
metalink=https://mirrors.fedoraproject.org/metalink?repo=fedora-source-41&arch=x86_64
enabled=1
metadata_expire=7d
repo_gpgcheck=0
type=rpm
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-41-x86_64
skip_if_unavailable=False
EOF
