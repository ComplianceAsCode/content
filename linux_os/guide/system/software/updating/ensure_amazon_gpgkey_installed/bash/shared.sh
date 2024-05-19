# platform = multi_platform_al
# The fingerprint below are retrieved from the offical amazon linux 2023 machine
readonly AMAZON_RELEASE_FINGERPRINT="{{{ release_key_fingerprint }}}"

# Location of the key we would like to import (once it's integrity verified)
readonly AMAZON_RELEASE_KEY="/etc/pki/rpm-gpg/RPM-GPG-KEY-amazon-linux-2023"

RPM_GPG_DIR_PERMS=$(stat -c %a "$(dirname "$AMAZON_RELEASE_KEY")")

# Verify /etc/pki/rpm-gpg directory permissions are safe
if [ "${RPM_GPG_DIR_PERMS}" -le "755" ]
then
  # If they are safe, try to obtain fingerprints from the key file
  # (to ensure there won't be e.g. CRC error).
  readarray -t GPG_OUT < <(gpg --show-keys --with-fingerprint --with-colons "$AMAZON_RELEASE_KEY" | grep -A1 "^pub" | grep "^fpr" | cut -d ":" -f 10)
  GPG_RESULT=$?
  # No CRC error, safe to proceed
  if [ "${GPG_RESULT}" -eq "0" ]
  then
    echo "${GPG_OUT[*]}" | grep -vE "${AMAZON_RELEASE_FINGERPRINT}" || {
      # If $AMAZON_RELEASE_KEY file doesn't contain any keys with unknown fingerprint, import it
      rpm --import "${AMAZON_RELEASE_KEY}"
    }
  fi
fi
