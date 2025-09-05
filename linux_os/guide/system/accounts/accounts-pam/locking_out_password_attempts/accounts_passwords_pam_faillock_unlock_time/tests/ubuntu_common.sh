#!/bin/bash

# Create passing pam.d files based on defaults from a clean installation of Ubuntu 22.04 LTS
# Extra comments and whitespaces were added to test for edge cases

cat >/etc/pam.d/common-auth <<EOF
 ## Leading and trailing whitespaces should be ok
 auth required  pam_faillock.so     preauth 
# here are the per-package modules (the "Primary" block)
auth    [success=2 default=ignore]      pam_unix.so nullok
## Several lines of comments should not
## break faillock remediation logic
## Nor should commented pam_unix
#auth    [success=2 default=ignore]      pam_unix.so nullok

auth    [success=1 default=ignore]      pam_sss.so use_first_pass

 ## Some more user comments
 auth [default=die]  pam_faillock.so authfail 
 ## and some more
 auth sufficient     pam_faillock.so authsucc 

# here's the fallback if no module succeeds
auth    requisite                       pam_deny.so
# prime the stack with a positive return value if there isn't one already;
# this avoids us returning an error just because nothing sets a success code
# since the modules above will each just jump around
auth    required                        pam_permit.so
# and here are more per-package modules (the "Additional" block)
auth    optional                        pam_cap.so 
# end of pam-auth-update config
EOF


cat >/etc/pam.d/common-account <<EOF
# here are the per-package modules (the "Primary" block)
account [success=1 new_authtok_reqd=done default=ignore]        pam_unix.so 
# here's the fallback if no module succeeds
account requisite                       pam_deny.so
# prime the stack with a positive return value if there isn't one already;
# this avoids us returning an error just because nothing sets a success code
# since the modules above will each just jump around
account required                        pam_permit.so
# and here are more per-package modules (the "Additional" block)
account sufficient                      pam_localuser.so 
account [default=bad success=ok user_unknown=ignore]    pam_sss.so 
# end of pam-auth-update config

  account required  pam_faillock.so 
EOF
