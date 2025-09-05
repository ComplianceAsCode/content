#!/bin/bash

{{% if NO_QUOTES %}}

if [ -f "{{{ PATH }}}" ]; then
    sed -i "/^\s*{{{ PARAMETER }}}.*/Id" "{{{ PATH }}}"
else
    mkdir -p $(dirname "{{{ PATH }}}")
    touch "{{{ PATH }}}"
fi
echo "{{{ PARAMETER }}}=\"{{{ VALUE }}}\"" > "{{{ PATH }}}"

{{% else %}}

{{{ bash_shell_file_set(path=PATH, parameter=PARAMETER, value="badval", no_quotes=NO_QUOTES) }}}

{{% endif %}}
