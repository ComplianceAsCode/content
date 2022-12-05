#!/bin/bash
# packages = dracut-fips dracut-fips-aesni


if grep -q '^GRUB_CMDLINE_LINUX=.*fips=.*"'  /etc/default/grub; then
	sed -i 's/\(^GRUB_CMDLINE_LINUX=".*\)fips=[^[:space:]]*\(.*"\)/\1 \2/'  /etc/default/grub
fi
