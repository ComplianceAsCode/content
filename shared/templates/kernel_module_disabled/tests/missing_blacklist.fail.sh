#!/bin/bash
# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel

{{{ bash_kernel_module_disable_test(
    KERNMODULE, KERNMODULE_RX,
    t_blacklist="fail",
    t_dracut="pass",
    t_modprobe="pass",
    t_modprobe_d_install="pass",
    t_modules_load_d="pass",
) }}}
