# platform = multi_platform_all
include ssh_private_key_perms

class ssh_private_key_perms {
  exec { 'sshd_priv_key':
    command => "chmod 0640 /etc/ssh/*_key",
    path    => '/bin:/usr/bin'
  }
}
