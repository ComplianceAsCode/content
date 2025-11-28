#!/bin/bash
{{%- if 'rhel' in product or 'ol' in families or 'slmicro5' in product %}}
# remediation = none
{{%- endif %}}
adduser testuser
