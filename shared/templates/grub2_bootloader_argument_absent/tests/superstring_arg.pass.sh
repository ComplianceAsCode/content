# platform = multi_platform_all
{{%- if 'sle15' in product %}}
# packages = grub2,grubby
mkdir -p /boot/grub2
rm -f /boot/grub2/grub.cfg
       {
    echo 'menuentry "SLES Mocked" {'
               echo 'linux   mock'
    echo '}'
       } > /boot/grub2/grub.cfg
{{%- else %}}
# packages = grub2-tools,grubby
{{%- endif %}}


# Ensure the kernel command line for each installed kernel in the bootloader
grubby --update-kernel=ALL --remove-args="{{{ ARG_NAME }}}"

# Add a test boot option that is a superstring of the target argument
grubby --update-kernel=ALL --args="X{{{ ARG_NAME }}}"
