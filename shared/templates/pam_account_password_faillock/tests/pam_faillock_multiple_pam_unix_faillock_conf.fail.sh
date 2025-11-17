#!/bin/bash
# packages = authselect
# platform = multi_platform_fedora,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,Oracle Linux 8
# remediation = none

{{{ tests_init_faillock_vars("correct", prm_name=PRM_NAME, ext_variable=EXT_VARIABLE, variable_lower_bound=VARIABLE_LOWER_BOUND, variable_upper_bound=VARIABLE_UPPER_BOUND) }}}

authselect select sssd --force
authselect enable-feature with-faillock
# Ensure the parameters only in /etc/security/faillock.conf
sed -i --follow-symlinks 's/\(pam_faillock.so \(preauth silent\|authfail\)\).*$/\1/g' /etc/pam.d/system-auth /etc/pam.d/password-auth
> "{{{ pam_faillock_conf_path }}}"
echo "$PRM_NAME = $TEST_VALUE" >> "{{{ pam_faillock_conf_path }}}"
echo "silent" >> "{{{ pam_faillock_conf_path }}}"

# Multiple instances of pam_unix.so in auth section may, intentionally or not, interfere
# in the expected behaviour of pam_faillock.so. Remediation does not solve this automatically
# in order to preserve intentional changes.
echo "auth        sufficient       pam_unix.so" >> /etc/pam.d/password-auth
