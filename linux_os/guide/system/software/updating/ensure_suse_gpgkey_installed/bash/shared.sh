# platform = multi_platform_sle
# The fingerprint below is retrieved from https://www.suse.com/support/security/keys/
readonly SUSE_RELEASE_FINGERPRINT="{{{ release_key_fingerprint }}}"


# Location of the key we would like to import (once it's integrity verified)
readonly SUSE_RELEASE_KEY_PATTERN="/usr/lib/rpm/gnupg/keys/*.asc"

RPM_GPG_DIR_PERMS=$(stat -c %a /usr/lib/rpm/gnupg/keys)

# Verify keys directory permissions are safe
if [ "${RPM_GPG_DIR_PERMS}" -le "755" ]
then

  for KEYFILE in $SUSE_RELEASE_KEY_PATTERN; do
  # If they are safe, try to obtain fingerprints from the key file
  # (to ensure there won't be e.g. CRC error).
      readarray -t GPG_OUT < <(gpg --with-fingerprint --with-colons "$KEYFILE" | grep -A1 "^pub" | grep "^fpr" | cut -d ":" -f 10)
      GPG_RESULT=$?
      # No CRC error, safe to proceed
      if [ "${GPG_RESULT}" -eq "0" ]
      then
          echo "${GPG_OUT[*]}" | grep -vE "${SUSE_RELEASE_FINGERPRINT}" || {
              # In this rule we care on of release build key so we will skip possible keys for backports, etc
              rpm --import "${KEYFILE}"
              break;
          }
      fi
  done
fi
