#!/bin/bash

sed -i "/{{{ PARAM }}}/d" "{{{ PATH }}}"
echo "# {{{ PARAM }}}{{{ SEP }}}{{{ VALUE }}}" >> "{{{ PATH }}}"
