#!/bin/bash

. release-utils.sh
echo == Check repo and project state for release ==

check_for_clean_repo
check_release_is_ok
check_jenkins_jobs
check_rhel_stig_ids
