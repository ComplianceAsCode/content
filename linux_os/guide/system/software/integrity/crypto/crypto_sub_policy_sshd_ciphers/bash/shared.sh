# platform = multi_platform_all
# reboot = true
# strategy = configure
# complexity = low
# disruption = low

{{%- set contents = "cipher@SSH = -3DES-CBC -AES-128-CBC -AES-192-CBC -AES-256-CBC -CHACHA20-POLY1305" -%}}


{{{ bash_file_contents('/etc/crypto-policies/policies/modules/NO-SSHWEAKCIPHERS.pmod', contents) }}}

sudo update-crypto-policies --set DEFAULT:NO-SSHWEAKCIPHERS
