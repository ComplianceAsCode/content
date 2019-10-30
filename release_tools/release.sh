#!/bin/bash

. release-utils.sh
echo == Create Release ==

move_on_to_next_milestone
download_release_assets
create_new_release
