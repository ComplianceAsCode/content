# platform = multi_platform_almalinux
readonly ALMALINUX_RELEASE_FINGERPRINT="{{{ release_key_fingerprint }}}"

# Location of the key we would like to import (once it's integrity verified)
readonly ALMALINUX_RELEASE_KEY="/etc/pki/rpm-gpg/RPM-GPG-KEY-AlmaLinux-9"

RPM_GPG_DIR_PERMS=$(stat -c %a "$(dirname "$ALMALINUX_RELEASE_KEY")")

# Verify /etc/pki/rpm-gpg directory permissions are safe
if [ "${RPM_GPG_DIR_PERMS}" -le "755" ]
then
  # If they are safe, try to obtain fingerprints from the key file
  # (to ensure there won't be e.g. CRC error).
  readarray -t GPG_OUT < <(gpg --show-keys --with-fingerprint --with-colons "$ALMALINUX_RELEASE_KEY" | grep -A1 "^pub" | grep "^fpr" | cut -d ":" -f 10)
  GPG_RESULT=$?
  # No CRC error, safe to proceed
  if [ "${GPG_RESULT}" -eq "0" ]
  then
    echo "${GPG_OUT[*]}" | grep -vE "${ALMALINUX_RELEASE_FINGERPRINT}" || {
      # If $ALMALINUX_RELEASE_KEY file doesn't contain any keys with unknown fingerprint, import it
      rpm --import "${ALMALINUX_RELEASE_KEY}"
    }
  fi
fi
