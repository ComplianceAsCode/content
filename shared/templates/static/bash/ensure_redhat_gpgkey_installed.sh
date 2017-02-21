# platform = multi_platform_rhel
# The two fingerprints below are retrieved from https://access.redhat.com/security/team/key
readonly REDHAT_RELEASE_2_FINGERPRINT="567E 347A D004 4ADE 55BA 8A5F 199E 2F91 FD43 1D51"
readonly REDHAT_AUXILIARY_FINGERPRINT="43A6 E49C 4A38 F4BE 9ABF 2A53 4568 9C88 2FA6 58E0"
# Location of the key we would like to import (once it's integrity verified)
readonly REDHAT_RELEASE_KEY="/etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release"

RPM_GPG_DIR_PERMS=$(stat -c %a "$(dirname "$REDHAT_RELEASE_KEY")")

# Verify /etc/pki/rpm-gpg directory permissions are safe
if [ "${RPM_GPG_DIR_PERMS}" -le "755" ]
then
  # If they are safe, try to obtain fingerprints from the key file
  # (to ensure there won't be e.g. CRC error).
  IFS=$'\n' GPG_OUT=($(gpg --with-fingerprint "${REDHAT_RELEASE_KEY}" | grep 'Key fingerprint ='))
  GPG_RESULT=$?
  # No CRC error, safe to proceed
  if [ "${GPG_RESULT}" -eq "0" ]
  then
    tr -s ' ' <<< "${GPG_RESULT}" | grep -vE "${REDHAT_RELEASE_2_FINGERPRINT}|${REDHAT_AUXILIARY_FINGERPRINT}" || {
      # If file doesn't contains any keys with unknown fingerprint, import it
      rpm --import "${REDHAT_RELEASE_KEY}"
    }
  fi
fi
