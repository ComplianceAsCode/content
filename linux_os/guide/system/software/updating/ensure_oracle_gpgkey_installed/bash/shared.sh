# platform = multi_platform_ol
# OL fingerprints below retrieved from: https://linux.oracle.com/security/gpg/#gpg
readonly OL_RELEASE_FINGERPRINT="{{{ release_key_fingerprint }}}"
readonly OL_AUXILIARY_FINGERPRINT="{{{ auxiliary_key_fingerprint }}}"

FINGERPRINTS_REGEX="${OL_RELEASE_FINGERPRINT}"

if [[ -n "$OL_AUXILIARY_FINGERPRINT" ]]; then
    FINGERPRINTS_REGEX+="|${OL_AUXILIARY_FINGERPRINT}"
fi

# Location of the key we would like to import (once it's integrity verified)
readonly OL_RELEASE_KEY="/etc/pki/rpm-gpg/RPM-GPG-KEY-oracle"

RPM_GPG_DIR_PERMS=$(stat -c %a "$(dirname "$OL_RELEASE_KEY")")

# Verify /etc/pki/rpm-gpg directory permissions are safe
if [ "${RPM_GPG_DIR_PERMS}" -le "755" ]
then
  # If they are safe, try to obtain fingerprints from the key file
  # (to ensure there won't be e.g. CRC error)
  {{% if product in ["ol8", "ol9"] %}}
    readarray -t GPG_OUT < <(gpg --show-keys --with-fingerprint --with-colons "$OL_RELEASE_KEY" | grep -A1 "^pub" | grep "^fpr" | cut -d ":" -f 10)
  {{% else %}}
    readarray -t GPG_OUT < <(gpg --with-fingerprint --with-colons "$OL_RELEASE_KEY" | grep "^fpr" | cut -d ":" -f 10)
  {{% endif %}}

  GPG_RESULT=$?
  # No CRC error, safe to proceed
  if [ "${GPG_RESULT}" -eq "0" ]
  then
    # Filter just hexadecimal fingerprints from gpg's output from
    # processing of a key file
    echo "${GPG_OUT[*]}" | grep -vE "$FINGERPRINTS_REGEX" || {
      # If $ OL_RELEASE_KEY file doesn't contain any keys with unknown fingerprint, import it
      rpm --import "${OL_RELEASE_KEY}"
    }
  fi
fi
