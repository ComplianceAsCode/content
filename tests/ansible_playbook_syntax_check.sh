#!/bin/bash

pushd "$2" > /dev/null
$1 --syntax-check ssg-$3-role-*.yml
ret=$?
popd > /dev/null
exit $ret
