#!/bin/bash

( IFS=:
  for p in $PATH; do
    if [ ! -d "$p" ]; then
      rm -f "$p"
      mkdir -p "$p"
    fi
  done
)
