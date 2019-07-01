# platform = multi_platform_rhel,multi_platform_rhv
# The two fingerprints below are retrieved from https://access.redhat.com/security/team/key
readonly REDHAT_RELEASE_2_FINGERPRINT="567E347AD0044ADE55BA8A5F199E2F91FD431D51"
readonly REDHAT_AUXILIARY_FINGERPRINT="43A6E49C4A38F4BE9ABF2A5345689C882FA658E0"
# Location of the key we would like to import (once it's integrity verified)
readonly REDHAT_RELEASE_KEY="/etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release"

RPM_GPG_DIR_PERMS=$(stat -c %a "$(dirname "$REDHAT_RELEASE_KEY")")

# Verify /etc/pki/rpm-gpg directory permissions are safe
if [ "${RPM_GPG_DIR_PERMS}" -le "755" ]
then
  # If they are safe, try to obtain fingerprints from the key file
  # (to ensure there won't be e.g. CRC error).
{{% if product == "rhel8" %}}
  readarray -t GPG_OUT < <(gpg --show-keys --with-colons "$REDHAT_RELEASE_KEY" | grep "^fpr" | cut -d ":" -f 10)
{{% else %}}
  readarray -t GPG_OUT < <(gpg --with-fingerprint --with-colons "$REDHAT_RELEASE_KEY" | grep "^fpr" | cut -d ":" -f 10)
{{% endif %}}
  GPG_RESULT=$?
  # No CRC error, safe to proceed
  if [ "${GPG_RESULT}" -eq "0" ]
  then
    echo "${GPG_OUT[*]}" | grep -vE "${REDHAT_RELEASE_2_FINGERPRINT}|${REDHAT_AUXILIARY_FINGERPRINT}" || {
      # If $REDHAT_RELEASE_KEY file doesn't contain any keys with unknown fingerprint, import it
      rpm --import "${REDHAT_RELEASE_KEY}"
    }
  fi
fi
