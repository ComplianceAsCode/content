# platform = multi_platform_all
# remediation = none
# packages = sudo

# The val1\,val2 is the first argument of the /bin/dog command that contains a comma.
# Our check tends to interpret the comma as commad delimiter, so the dog arg is val1\
# and val2 is another command in the user spec.
echo 'nobody ALL=/bin/ls "", (!bob,alice) /bin/dog val1\,val2, /bin/cat ""' > /etc/sudoers

