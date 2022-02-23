# platform = multi_platform_all
# packages = grub2-tools,grubby

# Ensure the kernel command line for each installed kernel in the bootloader
grubby --update-kernel=ALL --remove-args="{{{ ARG_NAME }}}"
