# platform = multi_platform_all
{{% if product == "rhcos4" %}}
{{% set perms_num = "0640" %}}
{{% else %}}
{{% set perms_num = "0600" %}}
{{% endif %}}
include ssh_private_key_perms

class ssh_private_key_perms {
  exec { 'sshd_priv_key':
    command => "chmod {{{ perms_num }}} /etc/ssh/*_key",
    path    => '/bin:/usr/bin'
  }
}
