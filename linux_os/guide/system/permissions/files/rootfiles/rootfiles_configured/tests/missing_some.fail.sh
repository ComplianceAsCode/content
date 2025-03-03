#!/bin/bash
cat > /etc/tmpfiles.d/rootconf.conf << EOF
C /root/.bash_logout   600 root root - /usr/share/rootfiles/.bash_logout
C /root/.bash_profile  600 root root - /usr/share/rootfiles/.bash_profile
C /root/.tcshrc        600 root root - /usr/share/rootfiles/.tcshrc
EOF
