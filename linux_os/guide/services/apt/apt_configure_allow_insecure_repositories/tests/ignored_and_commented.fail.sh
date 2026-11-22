#!/bin/bash
# platform = multi_platform_ubuntu

echo 'Acquire::AllowInsecureRepositories "0";' > /etc/apt/apt.conf.d/.99-hidden.conf
echo 'Acquire::AllowInsecureRepositories "0";' > /etc/apt/apt.conf.d/99-review.conf.bak
cat >> /etc/apt/apt.conf <<'EOF'
/*
Acquire::AllowInsecureRepositories "0";
*/
Unrelated {
    AllowInsecureRepositories "0";
};
EOF
