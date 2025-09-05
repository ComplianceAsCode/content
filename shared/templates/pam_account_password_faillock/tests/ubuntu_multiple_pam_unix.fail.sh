#!/bin/bash
# platform = multi_platform_ubuntu
# remediation = none

{{{ tests_init_faillock_vars("correct") }}}

{{{ bash_enable_pam_faillock_directly_in_pam_files() }}}

# Multiple instances of pam_unix.so in auth section may, intentionally or not, interfere
# in the expected behaviour of pam_faillock.so. Remediation does not solve this automatically
# in order to preserve intentional changes.

sed -i '/# end of pam-auth-update config/i\auth        sufficient       pam_unix.so' /etc/pam.d/common-auth
