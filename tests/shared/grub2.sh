test -n "$GRUB_CFG_ROOT" || GRUB_CFG_ROOT=/boot/grub2

function set_grub_uefi_root {
	if grep NAME /etc/os-release | grep -iq fedora; then
		GRUB_CFG_ROOT=/boot/efi/EFI/fedora
	else
		GRUB_CFG_ROOT=/boot/efi/EFI/redhat
	fi
}

function make_grub_password {
	mkdir -p "$GRUB_CFG_ROOT"
	set_superusers "root"
	# password is "lala"
	echo 'GRUB2_PASSWORD=grub.pbkdf2.sha512.10000.8F7F0A0D0F30D1924648F26D8A063A72373584C38DF22AEEC7B2C66329A47B04D16B92D73B58B36DB30E0AF85BD461F9AEB22BDE7290A9C212329BE21D2CDDEC.FDFD532D964C7F2EB2230A575C3630757502B2DC7A347987AABF64AE392EEDF3EEA86D6BCFAB8951F3003EA29435446964E54D2CC50AA0AC957C4B94BA8184FE' > "$GRUB_CFG_ROOT/user.cfg"
}


function set_superusers {
	set_superusers_unquoted "\"$1\""
}


function set_superusers_unquoted {
	mkdir -p "$GRUB_CFG_ROOT"
	echo "set superusers=$1" > "$GRUB_CFG_ROOT/grub.cfg"
}


function set_root_unquoted {
	mkdir -p "$GRUB_CFG_ROOT"
	echo "set root=$1" > "$GRUB_CFG_ROOT/grub.cfg"
}
