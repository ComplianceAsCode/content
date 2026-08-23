#!/bin/bash
cat > /etc/tmpfiles.d/rootconf.conf << EOF
C /root/.bash_logout   600 root root - /usr/share/rootfiles/.bash_logout
C /root/.bash_profile  600 root root - /usr/share/rootfiles/.bash_profile
C /root/.bashrc        600 root root - /usr/share/rootfiles/.bashrc
C /root/.cshrc         600 root root - /usr/share/rootfiles/.cshrc
C /root/.tcshrc        600 root root - /usr/share/rootfiles/.tcshrc
EOF


cat > /etc/tmpfiles.d/rootconf2.conf << EOF
C /root/.bash_logout   644 root root - /usr/share/rootfiles/.bash_logout
C /root/.bash_profile  644 root root - /usr/share/rootfiles/.bash_profile
C /root/.bashrc        644 root root - /usr/share/rootfiles/.bashrc
C /root/.cshrc         644 root root - /usr/share/rootfiles/.cshrc
C /root/.tcshrc        644 root root - /usr/share/rootfiles/.tcshrc
EOF
