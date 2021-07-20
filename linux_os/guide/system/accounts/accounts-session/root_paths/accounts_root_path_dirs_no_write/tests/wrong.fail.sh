#!/bin/bash

( IFS=:
  for p in $PATH; do
    chmod go+w $p
  done
)
