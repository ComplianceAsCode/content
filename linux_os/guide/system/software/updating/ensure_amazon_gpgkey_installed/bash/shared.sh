# platform = multi_platform_al

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
      rpm --import "${AMAZON_RELEASE_KEY}"
  fi
fi
