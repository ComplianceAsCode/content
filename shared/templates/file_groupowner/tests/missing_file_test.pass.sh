#!/bin/bash
#

{{% if MISSING_FILE_PASS %}}
    rm -f {{{ FILEPATH }}}
{{% else %}}
    true
{{% endif %}}
