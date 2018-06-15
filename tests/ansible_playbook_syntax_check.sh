#!/bin/bash

pushd "$2" > /dev/null
$1 --syntax-check *.yml
ret=$?
popd > /dev/null
exit $ret
