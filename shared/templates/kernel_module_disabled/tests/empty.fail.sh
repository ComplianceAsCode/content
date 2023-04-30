#!/bin/bash

{{{ bash_kernel_module_disable_test(
    KERNMODULE, KERNMODULE_RX,
    t_blacklist="fail_empty",
    t_dracut="pass",
    t_dracut_drivers="pass_empty",
    t_modprobe="fail_miss",
    t_modprobe_d_install="fail_empty",
    t_modules_load_d="pass",
) }}}
