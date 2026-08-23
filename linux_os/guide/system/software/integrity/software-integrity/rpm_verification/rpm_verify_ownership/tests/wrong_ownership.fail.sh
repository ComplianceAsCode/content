#!/bin/bash

{{% if product == "sle15" %}}
chown 1 /etc/hosts
{{% else %}}
chown 1 /etc/shadow
{{% endif %}}
