#!/bin/bash
PYTHON_EXECUTABLE="$1"
DATASTREAM="$2"
shift 2
PROFILES=()
while test $# -gt 0; do
    PROFILES+=("$1")
    shift
done

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"
RETURN_CODE=0

function check_missing_references() {
    profile="$1"
    if [[ "$profile" == "stig" ]]; then
        refs_argument="--missing-stig-ids"
    elif [[ "$profile" == "anssi"* ]]; then
        refs_argument="--missing-anssi-refs"
    else
        refs_argument="--missing-$profile-refs"
    fi

    full_profile_id="xccdf_org.ssgproject.content_profile_$profile"
    profile_stats="$("$PYTHON_EXECUTABLE" "$PROJECT_ROOT/build-scripts/profile_tool.py" stats --benchmark "$DATASTREAM" --profile "$full_profile_id" "$refs_argument" --skip-stats)"

    if [ ! -z "$profile_stats" ]; then
        printf '%s\n' "$profile_stats" >&2
        RETURN_CODE=1
    fi
}

for PROFILE in ${PROFILES[@]}; do
    check_missing_references "$PROFILE"
done

exit $RETURN_CODE
