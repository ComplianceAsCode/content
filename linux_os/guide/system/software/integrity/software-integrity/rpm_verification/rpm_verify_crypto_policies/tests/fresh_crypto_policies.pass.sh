#!/bin/bash
# packages = crypto-policies

result=$(rpm -V crypto-policies)

if [ -n "$result" ]; then
        {{{ pkg_manager }}} reinstall -y crypto-policies
fi
