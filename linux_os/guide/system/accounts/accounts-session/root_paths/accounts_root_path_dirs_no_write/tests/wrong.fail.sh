#!/bin/bash
# remediation = ansible

( IFS=:
  for p in $PATH; do
    if [ -d "$p" ]; then
      chmod go+w $p
    fi
  done
)
