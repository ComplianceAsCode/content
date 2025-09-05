#!/bin/bash
#

{{% if product in ("ubuntu", "debian") %}}
    {{% set target_group="shadow" %}}
{{% else %}}
    {{% set target_group="root" %}}
{{% endif %}}

touch /etc/gshadow-
chgrp {{{ target_group }}} /etc/gshadow-
