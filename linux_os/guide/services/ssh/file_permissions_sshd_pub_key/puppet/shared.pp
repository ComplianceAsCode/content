# platform = multi_platform_all
include ssh_public_key_perms

class ssh_public_key_perms {
  exec { 'sshd_pub_key':
    command => "chmod 0644 /etc/ssh/*.pub",
    path    => '/bin:/usr/bin'
  }
}
