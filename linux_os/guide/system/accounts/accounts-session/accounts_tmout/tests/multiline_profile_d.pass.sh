#!/bin/bash

# platform = multi_platform_sle
# variables = var_accounts_tmout=700

TEST_FILE=/etc/profile.d/tmout.sh

sed -i "/.*TMOUT.*/d" /etc/profile

test -f $TEST_FILE || touch $TEST_FILE

if grep -q "TMOUT" $TEST_FILE; then
	sed -i "s/.*TMOUT.*/TMOUT=700; readonly TMOUT; export TMOUT/" $TEST_FILE
else
	echo "TMOUT=700; readonly TMOUT; export TMOUT" >> $TEST_FILE
fi
