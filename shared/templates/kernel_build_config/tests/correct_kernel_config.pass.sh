#!/bin/bash

for file in /boot/config-* ; do
    if grep -q {{{ CONFIG | upper }}} "$file" ; then
        sed -i "s/{{{ CONFIG | upper }}}.*/{{{ CONFIG | upper }}}={{{ VALUE }}}/" "$file"
    else
        echo "{{{ CONFIG | upper }}}={{{ VALUE }}}" >> "$file"
    fi
done
