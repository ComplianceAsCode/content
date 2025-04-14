# platform = multi_platform_ubuntu

{{{ bash_pam_unix_enable() }}}
PAM_FILE_PATH=/usr/share/pam-configs/cac_unix

# Ensure only the correct hashing algorithm option is used.
declare -a HASHING_ALGORITHMS_OPTIONS=("sha512" "yescrypt" "gost_yescrypt" "blowfish" "sha256" "md5" "bigcrypt")

for hash_option in "${HASHING_ALGORITHMS_OPTIONS[@]}"; do
  sed -i -E '/^Password:/,/^[^[:space:]]/ {
    /pam_unix\.so/ {
      s/\s*\b'"$hash_option"'\b//g
    }
}' "$PAM_FILE_PATH"
  sed -i -E '/^Password-Initial:/,/^[^[:space:]]/ {
    /pam_unix\.so/ {
      s/\s*\b'"$hash_option"'\b//g
    }
}' "$PAM_FILE_PATH"
done

if ! grep -qzP "Password:\s*\n\s+.*\s+pam_unix.so\s+.*\bsha512\b" "$PAM_FILE_PATH"; then
  sed -i -E '/^Password:/,/^[^[:space:]]/ {
    /pam_unix\.so/ {
        s/$/ sha512/g
    }
}' "$PAM_FILE_PATH"
fi

if ! grep -qzP "Password-Initial:\s*\n\s+.*\s+pam_unix.so\s+.*\bsha512\b" "$PAM_FILE_PATH"; then
  sed -i -E '/^Password-Initial:/,/^[^[:space:]]/ {
    /pam_unix\.so/ {
        s/$/ sha512/g
    }
}' "$PAM_FILE_PATH"
fi

DEBIAN_FRONTEND=noninteractive pam-auth-update
