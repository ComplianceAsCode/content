#!/bin/bash

cat > {{{ FILEPATH }}} << EOM
{{{ CONTENTS }}}
EOM

echo "some additional text" >> {{{ FILEPATH }}}
