#!/bin/bash

sed -i "/{{{ PARAM }}}/d" "{{{ PATH }}}"
echo "{{{ PARAM }}}{{{ SEP }}}{{{ VALUE }}}" >> "{{{ PATH }}}"
echo "{{{ PARAM }}}{{{ SEP }}}wrong_value" >> "{{{ PATH }}}"
