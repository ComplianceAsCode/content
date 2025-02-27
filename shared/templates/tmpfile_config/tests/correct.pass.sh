#!/bin/bash
mkdir /etc/tmpfiles.d/
echo '{{{ TMP_ACTION }}} {{{ DEST_PATH }}} {{{ MODE }}} {{{ OWNER }}} {{{ GROUP_OWNER }}} - {{{ SOURCE_PATH }}}' >> {{{ REMEDATION_FILE }}}
