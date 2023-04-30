#!/bin/bash

{{{ bash_kernel_module_disable_test(
    KERNMODULE, KERNMODULE_RX,
    t_blacklist="pass",
    t_dracut="pass",
    t_dracut_drivers="pass_empty",
    t_modprobe="pass",
    t_modprobe_d_install="pass",
    t_modules_load_d="fail",
) }}}
