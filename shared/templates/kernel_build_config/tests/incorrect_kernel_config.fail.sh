#!/bin/bash

for file in /boot/config-* ; do
    if grep -q {{{ CONFIG | upper }}} "$file" ; then
        sed -i "s/{{{ CONFIG | upper }}}.*/{{{ CONFIG | upper }}}=wrong_value/" "$file"
    else
        echo "{{{ CONFIG | upper }}}=wrong_value" >> "$file"
    fi
done

