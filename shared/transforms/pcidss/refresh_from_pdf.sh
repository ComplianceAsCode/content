#!/bin/bash

function die()
{
    echo "$*" >&2
    exit 1
}

# parent dir of this script
PARENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd "$PARENT_DIR" > /dev/null

[ -f "./PCI_DSS_v3-1.pdf" ] || die "Place 'PCI_DSS_v3-1.pdf' in $PARENT_DIR"
./generate_pcidss_json.py

echo "Don't forget to commit the regenerated PCI_DSS.json file!"

popd > /dev/null
