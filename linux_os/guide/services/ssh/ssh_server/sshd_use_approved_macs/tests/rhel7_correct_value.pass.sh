# platform = Oracle Linux 7,Red Hat Enterprise Linux 7
#
# profiles = xccdf_org.ssgproject.content_profile_cis

{{{ bash_replace_or_append('/etc/ssh/sshd_config', '^MACs', "umac-64-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,hmac-sha1-etm@openssh.com,umac-64@openssh.com,umac-128@openssh.com,hmac-sha2-256,hmac-sha2-512,hmac-sha1,hmac-sha1-etm@openssh.com", '%s %s') }}}
