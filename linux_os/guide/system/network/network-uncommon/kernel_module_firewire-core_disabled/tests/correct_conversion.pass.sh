#!/bin/bash

kernmodule="firewire_core"
{{{ bash_kernel_module_disable_test(
    'firewire-core', 'firewire[_-]core',
    t_blacklist="pass",
    t_dracut="pass_d",
    t_modprobe="pass",
    t_modprobe_d_install="pass",
    t_modules_load_d="pass",
) }}}
