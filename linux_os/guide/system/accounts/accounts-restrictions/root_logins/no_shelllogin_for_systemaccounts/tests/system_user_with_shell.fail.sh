#!/bin/bash
{{% if product in [ 'slmicro6', 'sle15', 'sle16' ] %}}
usermod --shell /bin/bash messagebus
{{% else %}}
# change system user "mail" shell to bash
usermod --shell /bin/bash mail
{{% endif %}}
