#!/bin/bash
# packages = gdm

{{% set gdm_conf_dir = "/etc/gdm3" if 'ubuntu' in product or 'debian' in product else "/etc/gdm" -%}}
{{% set gdm_conf_path = gdm_conf_dir ~ ("/daemon.conf" if 'debian' in product else "/custom.conf") -%}}
printf '%s\n' "# comment" "[xdmcp]" > {{{ gdm_conf_path }}}
