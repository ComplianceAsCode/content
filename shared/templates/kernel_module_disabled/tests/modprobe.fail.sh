#!/bin/bash
# Only virtual machines can load modules
# skip_test_env = podman-based

modprobe {{{ KERNMODULE | quote }}}

{{{ bash_kernel_module_disable_test(
    KERNMODULE, KERNMODULE_RX,
    t_blacklist="pass",
    t_dracut="pass",
    t_modprobe="pass",
    t_modprobe_d_install="pass",
    t_modules_load_d="pass",
) }}}
