#!/usr/bin/env bash
# platform = multi_platform_sle,multi_platform_ubuntu
# check-import = stdout

# Check that iptables exist in current path
if ! command -v iptables >/dev/null; then
    exit "$XCCDF_RESULT_FAIL"
fi

# Get current rules
rules=$(iptables -S)

# Check for "-A INPUT -i lo -j ACCEPT"
if [[ ! "$rules" =~ "-A INPUT -i lo -j ACCEPT" ]]; then
    exit "$XCCDF_RESULT_FAIL"
fi

# Check for "-A OUTPUT -o lo -j ACCEPT"
if [[ ! "$rules" =~ "-A OUTPUT -o lo -j ACCEPT" ]]; then
    exit "$XCCDF_RESULT_FAIL"
fi

# Check for "-A INPUT -s 127.0.0.0/8 -j DROP"
if [[ ! "$rules" =~ "-A INPUT -s 127.0.0.0/8 -j DROP" ]]; then
    exit "$XCCDF_RESULT_FAIL"
fi

exit "$XCCDF_RESULT_PASS"