#!/bin/bash

TESTDIRS=(
    /bin/test_1
    /sbin/test_1
    /usr/bin/test_1
    /usr/sbin/test_1
    /usr/local/bin/test_1
    /usr/local/sbin/test_1
)
mkdir -p "${TESTDIRS[@]}"
chown nobody.nobody "${TESTDIRS[@]}"
