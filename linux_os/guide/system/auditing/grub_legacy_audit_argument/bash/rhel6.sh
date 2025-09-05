# platform = Red Hat Enterprise Linux 6

# Correct the form of kernel command line for each installed kernel
# in the bootloader
/sbin/grubby --update-kernel=ALL --args="audit=1"
