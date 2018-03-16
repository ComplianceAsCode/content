# platform = multi_platform_ol
# OL fingerprints below retrieved from "Oracle Linux Unbreakable Linux Network User's Guide"
# https://docs.oracle.com/cd/E37670_01/E39381/html/ol_import_gpg.html
readonly OL_FINGERPRINT="4214 4123 FECF C55B 9086 313D 72F9 7B74 EC55 1F03"
# Location of the key we would like to import (once it's integrity verified)
readonly OL_RELEASE_KEY="/etc/pki/rpm-gpg/RPM-GPG-KEY-oracle"

RPM_GPG_DIR_PERMS=$(stat -c %a "$(dirname "$OL_RELEASE_KEY")")

# Verify /etc/pki/rpm-gpg directory permissions are safe
if [ "${RPM_GPG_DIR_PERMS}" -le "755" ]
then
  # If they are safe, try to obtain fingerprints from the key file
  # (to ensure there won't be e.g. CRC error)
  IFS=$'\n' GPG_OUT=($(gpg --with-fingerprint "${OL_RELEASE_KEY}"))
  GPG_RESULT=$?
  # No CRC error, safe to proceed
  if [ "${GPG_RESULT}" -eq "0" ]
  then
    for ITEM in "${GPG_OUT[@]}"
    do
      # Filter just hexadecimal fingerprints from gpg's output from
      # processing of a key file
      RESULT=$(echo ${ITEM} | sed -n "s/[[:space:]]*Key fingerprint = \(.*\)/\1/p" | tr -s '[:space:]')
      # If fingerprint matches Oracle Linux 6 and 7 key import the key
      if [[ ${RESULT} ]] && [[ ${RESULT} = "${OL_FINGERPRINT}" ]] 
      then
        rpm --import "${OL_RELEASE_KEY}"
      fi
    done
  fi
fi
