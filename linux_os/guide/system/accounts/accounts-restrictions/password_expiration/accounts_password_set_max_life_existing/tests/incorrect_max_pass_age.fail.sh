#!/bin/bash
MAX_PASS_AGE=99999

USERNAME="testuser_123"
useradd $USERNAME
echo "cac_test_pass" | passwd --stdin $USERNAME

chage -M $MAX_PASS_AGE $USERNAME
