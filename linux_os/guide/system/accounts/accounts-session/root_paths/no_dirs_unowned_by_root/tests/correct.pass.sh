#!/bin/bash

( IFS=:
  for p in $PATH; do
    if [ -d "$p" ]; then
      chown root "$p"
    fi
  done
)
