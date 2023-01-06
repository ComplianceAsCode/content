#!/bin/bash
BAD_PAS_AGE=-1

USERNAME="testuser_123"
useradd $USERNAME
echo "cac_test_pass" | passwd --stdin $USERNAME

passwd -n $BAD_PAS_AGE $USERNAME
