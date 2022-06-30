#!/bin/bash

# we are using original macro for the content from rule.yml
# this macro has &, < and > signs HTML escaped because of rendering into HTML guides etc.
# so we convert them back to their original form

cat > {{{ FILEPATH }}} << EOM
{{{ CONTENTS | replace("&amp;", "&") | replace("&gt;", ">") | replace("&lt;", "<")  }}}
EOM
