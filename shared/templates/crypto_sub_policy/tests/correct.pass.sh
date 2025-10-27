#!/bin/bash
cat > /etc/crypto-policies/policies/modules/{{{ MODULE_NAME }}}.pmod << EOF
{{{ KEY }}} = {{{ VALUE }}}
EOF
