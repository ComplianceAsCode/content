#!/bin/bash
{{% if not SEBOOL_BOOL %}}
# variables = var_{{{ SEBOOLID }}}=true
{{% set SEBOOL_BOOL="true" %}}
{{% endif %}}

setsebool -P {{{ SEBOOLID }}} {{{ SEBOOL_BOOL }}}
