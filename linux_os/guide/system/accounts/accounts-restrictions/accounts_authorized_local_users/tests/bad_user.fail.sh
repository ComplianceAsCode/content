#!/bin/bash
{{%- if 'rhel' in product or 'ol' in families or product.startswith('slmicro') %}}
# remediation = none
{{%- endif %}}
adduser testuser
