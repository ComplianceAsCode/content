#!/bin/bash

# This script aims to run the complyscribe CLI, which will sync CaC
# content controls/profiles updates to OSCAL component-definition.

# The requirements are as follows:
# 1. The flag, "true" means the second requirement is policy_id.
# 2. The related policy_id or profile id of the CaC updates.
# 3. The product.
# 4. The oscal-content branch name.
# 5. The GitHub workspace path.
# 6. The mapping file for the specific product.

# Usage:
# sh utils/complyscribe-cli-compd.sh false anssi_bp28_minimal rhel10 branch_name "/User/huiwang" rhel10_map.json
# sh utils/complyscribe-cli-compd.sh true anssi rhel10 branch_name "/User/huiwang" rhel10_map.json

# Get the arguments
flag=$1
policy_or_profile=$2
product=$3
branch_name=$4
workspace_path=$5
product_mapping_file=$6

if [ $# -lt 6 ]; then
    echo "Please provide the necessary inputs."
    exit 1
fi

sed -i "s/'/\"/g" "$product_mapping_file"
while IFS= read -r line; do
  policy_id=$(echo "$line" | jq -r '.policy_id')
  profile=$(echo "$line" | jq -r '.profile_name')
  echo "$line" | jq -r '.levels[]' > levels
  if [ "$flag" = "true" ]; then
    param="$policy_id"
  else
    param="$profile"
  fi
  if [ "$policy_or_profile" = "$param" ]; then
    while IFS= read -r level; do
      oscal_profile=$product-$policy_id-$level
      if echo "$product" | grep -q 'ocp4'; then
        type="service"
      else
        type="software"
      fi
      sed -i "/href/s|\(trestle://\)[^ ]*\(catalogs\)|\1\2|g" "../oscal-content/profiles/$oscal_profile/profile.json"
      poetry run complyscribe sync-cac-content component-definition --repo-path ../oscal-content --committer-email "openscap-ci@gmail.com" --committer-name "openscap-ci" --branch "$branch_name" --cac-content-root "$workspace_path/cac-content" --product "$product" --component-definition-type "$type" --cac-profile "$profile" --oscal-profile "$oscal_profile"
      type="validation"
      poetry run complyscribe sync-cac-content component-definition --repo-path ../oscal-content --committer-email "openscap-ci@gmail.com" --committer-name "openscap-ci" --branch "$branch_name" --cac-content-root "$workspace_path/cac-content" --product "$product" --component-definition-type "$type" --cac-profile "$profile" --oscal-profile "$oscal_profile"
    done < levels
  fi
done < "$product_mapping_file"
