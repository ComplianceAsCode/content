#!/bin/bash

( IFS=:
  for p in $PATH; do
    if [ -d "$p" ]; then
      chown nobody "$p"
    fi
  done
)
