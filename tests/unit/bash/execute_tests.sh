#!/bin/bash

PYTHON_EXECUTABLE="$1"
TESTS_ROOT="$2"
TESTDIR="$3"
OUTDIR="$4"

mkdir -p "$OUTDIR"

PYTHONPATH="$TESTS_ROOT/.." ${PYTHON_EXECUTABLE} "$TESTS_ROOT/../build-scripts/expand_jinja.py" --outdir "$OUTDIR" $TESTDIR/*.jinja && bats "$OUTDIR"
