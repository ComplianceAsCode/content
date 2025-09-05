# platform = multi_platform_rhel,multi_platform_rhv
# The two fingerprints below are retrieved from https://access.redhat.com/security/team/key
readonly REDHAT_RELEASE_FINGERPRINT="{{{ release_key_fingerprint }}}"
readonly REDHAT_AUXILIARY_FINGERPRINT="{{{ auxiliary_key_fingerprint }}}"

# Location of the key we would like to import (once it's integrity verified)
readonly REDHAT_RELEASE_KEY="/etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release"

RPM_GPG_DIR_PERMS=$(stat -c %a "$(dirname "$REDHAT_RELEASE_KEY")")

# Verify /etc/pki/rpm-gpg directory permissions are safe
if [ "${RPM_GPG_DIR_PERMS}" -le "755" ]
then
  # If they are safe, try to obtain fingerprints from the key file
  # (to ensure there won't be e.g. CRC error).
{{% if product in ["rhel8", "rhv4"] %}}
  readarray -t GPG_OUT < <(gpg --show-keys --with-fingerprint --with-colons "$REDHAT_RELEASE_KEY" | grep -A1 "^pub" | grep "^fpr" | cut -d ":" -f 10)
{{% else %}}
  readarray -t GPG_OUT < <(gpg --with-fingerprint --with-colons "$REDHAT_RELEASE_KEY" | grep "^fpr" | cut -d ":" -f 10)
{{% endif %}}
  GPG_RESULT=$?
  # No CRC error, safe to proceed
  if [ "${GPG_RESULT}" -eq "0" ]
  then
    echo "${GPG_OUT[*]}" | grep -vE "${REDHAT_RELEASE_FINGERPRINT}|${REDHAT_AUXILIARY_FINGERPRINT}" || {
      # If $REDHAT_RELEASE_KEY file doesn't contain any keys with unknown fingerprint, import it
      rpm --import "${REDHAT_RELEASE_KEY}"
    }
  fi
fi
