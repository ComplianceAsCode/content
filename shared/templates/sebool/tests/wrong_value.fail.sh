#!/bin/bash
{{% if not SEBOOL_BOOL %}}
# variables = var_{{{ SEBOOLID }}}=true
{{% set WRONG_SEBOOL="false" %}}
{{% endif %}}

setsebool -P {{{ SEBOOLID }}} {{{ WRONG_SEBOOL }}}
