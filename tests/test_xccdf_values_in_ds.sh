#!/bin/bash

DS="$1"
if grep -iq "dangling reference to" "$DS" ; then
    printf "Found dangling reference in %s, ensure correct usage of the xccdf_value Jinja macro!" "$DS" >&2
    exit 1
fi
if grep -iq "xccdf_value" "$DS" ; then
    printf "Found obtrusive xccdf_value in %s, ensure correct usage of the xccdf_value Jinja macro!" "$DS" >&2
    exit 1
fi
