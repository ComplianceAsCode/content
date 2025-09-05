#!/bin/bash
#

# verify (-V) all installed (-a) packages digests,
# if digest differs from package metadata, then attribute '5' is printed
result=$(rpm -Va --noconfig | grep -E '^..5')

[ -z "$result" ]
