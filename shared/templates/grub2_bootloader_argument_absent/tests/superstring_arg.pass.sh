# platform = multi_platform_all

# Ensure the kernel command line for each installed kernel in the bootloader
grubby --update-kernel=ALL --remove-args="{{{ ARG_NAME }}}"

# Add a test boot option that is a superstring of the target argument
grubby --update-kernel=ALL --args="X{{{ ARG_NAME }}}"
