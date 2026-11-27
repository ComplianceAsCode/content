# platform = multi_platform_almalinux
# reboot = true
# strategy = configure
# complexity = low
# disruption = high

# Only effective when the TuxCare ESU repository is configured and licensed.
# The previously installed default kernel packages must be removed manually
# after rebooting into the TuxCare kernel.
dnf -y upgrade gnutls nettle nss openssl libgcrypt kernel
