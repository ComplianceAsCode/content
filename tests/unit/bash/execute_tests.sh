#!/bin/bash

set -epu

usage() {
    printf "Usage: %s [OPTIONS] PYTHON_EXECUTABLE TESTS_ROOT TESTDIR OUTDIR [bats opts]" "${0##/}"
    printf "       %s [--help]" "${0##/}"
    printf "\nOPTIONS\n"
    printf "    --verbose\n"
    printf "    --quiet\n"
    printf "    --debug\n"
    printf "    --parallel | --no-parallel\n"
    printf "    --\n"
}

OPT_debug=0
OPT_parallel=0
if [[ -x /usr/bin/parallel ]]; then
    OPT_parallel=1
fi

OPT_verbose=1
while (( $# )); do
    case "$1" in
        --verbose) (( OPT_verbose++, 1 )); shift ;;
        --quiet) OPT_verbose=0; shift ;;
        --debug) set -x; OPT_debug=1; shift ;;

        --parallel) OPT_parallel=1; shift ;;
        --no[_-]parallel) OPT_parallel=0; shift ;;

        --help) usage; exit 2 ;;
        --) shift; break ;;

        *) break ;;
    esac
done

PYTHON_EXECUTABLE="$1"; shift
TESTS_ROOT="$1"; shift
TESTDIR="$1"; shift
OUTDIR="$1"; shift

mkdir -p "${OUTDIR}"

bats_opts=()

if (( OPT_parallel )); then
    bats_opts+=(--jobs "$(nproc)")
fi

if (( OPT_verbose > 1 )); then
    bats_opts+=(--verbose-run)
elif (( OPT_verbose == 1 )); then
    bats_opts+=(--print-output-on-failure)
fi

if (( OPT_debug )); then
    bats_opts+=(--no-tempdir-cleanup --trace)
fi

rc=0
PYTHONPATH="${TESTS_ROOT}/.." ${PYTHON_EXECUTABLE} \
"${TESTS_ROOT}/../build-scripts/expand_jinja.py" --outdir "${OUTDIR}" \
    "${TESTDIR}"/*.jinja || rc=$?
if (( rc )); then
    >&2 echo "ERROR: expand_jinja.py could not create bats files"
    exit "${rc}"
fi
bats "${bats_opts[@]}" "$@" "${OUTDIR}"
