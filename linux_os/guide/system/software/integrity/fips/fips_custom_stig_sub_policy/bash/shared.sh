# platform = multi_platform_all
# reboot = true
# strategy = configure
# complexity = low
# disruption = low

{{%- set contents = "cipher@SSH=AES-256-GCM AES-256-CTR AES-128-GCM AES-128-CTR\nmac@SSH=HMAC-SHA2-512 HMAC-SHA2-256" -%}}


{{{ bash_file_contents('/etc/crypto-policies/policies/modules/STIG.pmod', contents) }}}

sudo update-crypto-policies --set FIPS:STIG
