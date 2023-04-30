#!/bin/bash

{{{ bash_kernel_module_disable_test(
    KERNMODULE, KERNMODULE_RX,
    t_blacklist="pass",
    t_dracut="pass_d",
    t_modprobe="fail_commented",
    t_modprobe_d_install="fail_commented",
    t_modules_load_d="pass_commented",
    dir_modprobe_d_install="all",
) }}}
