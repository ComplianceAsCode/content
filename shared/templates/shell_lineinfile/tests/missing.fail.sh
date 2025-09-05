#!/bin/bash

if [ -f "{{{ PATH }}}" ]; then
    sed -i "/^\s*{{{ PARAMETER }}}.*/Id" "{{{ PATH }}}"
else
    mkdir -p $(dirname "{{{ PATH }}}")
    touch "{{{ PATH }}}"
fi
