#!/bin/bash

# Copyright 2016 Red Hat Inc., Durham, North Carolina.
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
#
# Authors:
#      Martin Preisler <mpreisle@redhat.com>

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
