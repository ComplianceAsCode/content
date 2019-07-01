# platform = multi_platform_ol
# OL fingerprints below retrieved from Oracle Linux Yum Server "Frequently Asked Questions"
# https://yum.oracle.com/faq.html#a10
readonly OL_FINGERPRINT="42144123FECFC55B9086313D72F97B74EC551F03"
readonly OL8_FINGERPRINT="76FD3DB13AB67410B89DB10E82562EA9AD986DA3"

# Location of the key we would like to import (once it's integrity verified)
readonly OL_RELEASE_KEY="/etc/pki/rpm-gpg/RPM-GPG-KEY-oracle"

RPM_GPG_DIR_PERMS=$(stat -c %a "$(dirname "$OL_RELEASE_KEY")")

# Verify /etc/pki/rpm-gpg directory permissions are safe
if [ "${RPM_GPG_DIR_PERMS}" -le "755" ]
then
  # If they are safe, try to obtain fingerprints from the key file
  # (to ensure there won't be e.g. CRC error)
  readarray -t GPG_OUT < <(gpg --with-fingerprint --with-colons "$OL_RELEASE_KEY" | grep "^fpr" | cut -d ":" -f 10)
  GPG_RESULT=$?
  # No CRC error, safe to proceed
  if [ "${GPG_RESULT}" -eq "0" ]
  then
    # Filter just hexadecimal fingerprints from gpg's output from
    # processing of a key file
    echo "${GPG_OUT[*]}" | grep -vE "${OL_FINGERPRINT}|${OL8_FINGERPRINT}" || {
      # If $ OL_RELEASE_KEY file doesn't contain any keys with unknown fingerprint, import it
      rpm --import "${OL_RELEASE_KEY}"
    }
  fi
fi
