#!/bin/bash

for TESTDIR in /bin/test_me /sbin/test_me /usr/bin/test_me /usr/sbin/test_me /usr/local/bin/test_me /usr/local/sbin/test_me
do
   mkdir -p "${TESTDIR}"
   chown nobody.nobody "${TESTDIR}"
done
