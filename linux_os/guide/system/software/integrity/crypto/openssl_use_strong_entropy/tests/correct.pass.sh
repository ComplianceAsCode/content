#!/bin/bash
# platform = Red Hat Enterprise Linux 8

cat > /etc/profile.d/openssl-rand.sh <<- 'EOM'
# provide a default -rand /dev/random option to openssl commands that
# support it

# written inefficiently for maximum shell compatibility
openssl()
(
  openssl_bin=/usr/bin/openssl

  case "$*" in
    # if user specified -rand, honor it
    *\ -rand\ *|*\ -help*) exec $openssl_bin "$@" ;;
  esac

  cmds=`$openssl_bin list -digest-commands -cipher-commands | tr '\n' ' '`
  for i in `$openssl_bin list -commands`; do
    if $openssl_bin list -options "$i" | grep -q '^rand '; then
      cmds=" $i $cmds"
    fi
  done

  case "$cmds" in
    *\ "$1"\ *)
      cmd="$1"; shift
      exec $openssl_bin "$cmd" -rand /dev/random "$@" ;;
  esac

  exec $openssl_bin "$@"
)
EOM
