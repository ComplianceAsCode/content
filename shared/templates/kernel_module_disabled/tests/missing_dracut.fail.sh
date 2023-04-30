#!/bin/bash
# platform = Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,multi_platform_fedora
# packages = dracut

{{{ bash_kernel_module_disable_test(
    KERNMODULE, KERNMODULE_RX,
    t_blacklist="pass",
    t_dracut="fail_empty",
    t_modprobe="pass",
    t_modprobe_d_install="pass",
    t_modules_load_d="pass",
) }}}
