#!/bin/bash
# platform = Red Hat Enterprise Linux 8, Red Hat Enterprise Linux 10, multi_platform_fedora, multi_platform_debian, multi_platform_ol, multi_platform_sle

{{{ bash_package_install("bind") }}}
{{{ bash_package_remove("bind") }}}
