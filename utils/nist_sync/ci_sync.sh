#!/usr/bin/env bash
# CI helper script for the CIS-NIST sync workflow.
# Called from .github/workflows/cis-nist-sync.yml with a subcommand.
#
# Usage: ci_sync.sh <subcommand>
# Subcommands: verify, collect-artifacts, summarize, check-changes,
#              show-diff, create-pr, workflow-summary
#
# Required env vars depend on the subcommand; see each function for details.

set -euo pipefail

PRODUCTS="rhel8 rhel9 rhel10"

cmd_verify() {
    echo "✓ Product-Specific Reference files (auto-generated, for comparison):"
    for product in $PRODUCTS; do
        REF_DIR="shared/references/controls/nist_800_53_cis_reference_${product}"
        echo "  $product:"
        echo "    - Metadata: ${REF_DIR}.yml"
        FAMILY_COUNT=$(find "${REF_DIR}" -maxdepth 1 -name "*.yml" 2>/dev/null | wc -l)
        echo "    - Families: ${REF_DIR}/*.yml ($FAMILY_COUNT files)"
    done
    echo ""
    echo "✓ Product-Specific Control files (used in builds):"
    for product in $PRODUCTS; do
        NIST_DIR="products/$product/controls/nist_800_53"
        echo "  $product:"
        echo "    - Metadata: ${NIST_DIR}.yml"
        REAL_COUNT=$(find "${NIST_DIR}" -maxdepth 1 -name "*.yml" 2>/dev/null | wc -l)
        echo "    - Families: ${NIST_DIR}/*.yml ($REAL_COUNT files)"
    done
    echo ""
    echo "Note: Each product has its own NIST 800-53 control files"
    echo "      (NO guards, product-filtered)"
}

cmd_collect_artifacts() {
    mkdir -p artifacts/controls artifacts/profiles artifacts/data artifacts/datastreams

    for product in $PRODUCTS; do
        REF_YML="shared/references/controls/nist_800_53_cis_reference_${product}.yml"
        [ -f "$REF_YML" ] && cp "$REF_YML" "artifacts/controls/"
    done

    cp utils/nist_sync/data/cis_nist_mappings.json artifacts/data/

    for product in $PRODUCTS; do
        if [ -f "products/$product/profiles/cis_nist.profile" ]; then
            mkdir -p "artifacts/profiles/$product"
            cp "products/$product/profiles/cis_nist.profile" "artifacts/profiles/$product/"
        fi
    done

    for product in $PRODUCTS; do
        [ -f "build/ssg-$product-ds.xml" ] && cp "build/ssg-$product-ds.xml" artifacts/datastreams/
    done
}

cmd_summarize() {
    # Requires: GITHUB_STEP_SUMMARY
    {
        echo "# CIS-NIST Sync Report (Product-Specific)"
        echo ""
        echo "## Generated Artifacts"
        echo ""
        echo "### Product-Specific CIS Reference Files (Auto-Generated, NO Guards)"

        for product in $PRODUCTS; do
            REF_DIR="shared/references/controls/nist_800_53_cis_reference_${product}"
            echo "#### $product"
            echo "- Metadata: \`${REF_DIR}.yml\`"
            echo "- Families: \`${REF_DIR}/*.yml\`"
            if [ -d "$REF_DIR" ]; then
                FAMILY_COUNT=$(find "${REF_DIR}" -maxdepth 1 -name "*.yml" 2>/dev/null | wc -l)
                echo "  - Family files: $FAMILY_COUNT"
            fi
            echo ""
        done

        echo "### Product-Specific Control Files (Used for Builds)"
        for product in $PRODUCTS; do
            PDIR="products/$product/controls/nist_800_53"
            echo "- \`${PDIR}.yml\` + \`${PDIR}/*.yml\`"
        done

        echo ""
        echo "### Profiles"
        for product in $PRODUCTS; do
            if [ -f "products/$product/profiles/cis_nist.profile" ]; then
                echo "- \`products/$product/profiles/cis_nist.profile\` (uses \`nist_800_53:all\`)"
            fi
        done

        echo ""
        echo "## Mapping Statistics"
        echo ""

        python3 - <<'PYEOF'
import json
with open('utils/nist_sync/data/cis_nist_mappings.json', 'r') as f:
    data = json.load(f)

print(f"- Rules mapped to NIST: {len(data['rules'])}")
print(f"- Variables mapped to NIST: {len(data['variables'])}")

nist_controls = set()
for nist_list in data['rules'].values():
    nist_controls.update(nist_list)
for nist_list in data['variables'].values():
    nist_controls.update(nist_list)

print(f"- Unique NIST controls referenced: {len(nist_controls)}")
PYEOF

    } >> "$GITHUB_STEP_SUMMARY"
}

cmd_check_changes() {
    # Requires: GITHUB_STEP_SUMMARY, GITHUB_OUTPUT
    HAS_CHANGES=false

    echo "Checking for changes in product-specific CIS reference files..."

    for product in $PRODUCTS; do
        echo ""
        echo "Checking $product..."

        METADATA_FILE="shared/references/controls/nist_800_53_cis_reference_${product}.yml"
        if [ -f "$METADATA_FILE" ]; then
            if git ls-files --error-unmatch "$METADATA_FILE" >/dev/null 2>&1; then
                if ! git diff --quiet HEAD -- "$METADATA_FILE"; then
                    echo "  ✓ Changes in metadata file"
                    HAS_CHANGES=true
                else
                    echo "  - Metadata unchanged"
                fi
            else
                echo "  ✓ Metadata file is new"
                HAS_CHANGES=true
            fi
        fi

        FAMILY_DIR="shared/references/controls/nist_800_53_cis_reference_${product}"
        if [ -d "$FAMILY_DIR" ]; then
            if git ls-files --error-unmatch "$FAMILY_DIR/" >/dev/null 2>&1; then
                if ! git diff --quiet HEAD -- "$FAMILY_DIR/"; then
                    CHANGED_COUNT=$(git diff --name-only HEAD -- "$FAMILY_DIR/" | wc -l)
                    echo "  ✓ Changes in family files ($CHANGED_COUNT files)"
                    HAS_CHANGES=true
                else
                    echo "  - Family files unchanged"
                fi
            else
                echo "  ✓ Family directory is new"
                HAS_CHANGES=true
            fi
        fi
    done

    echo ""
    if [ "$HAS_CHANGES" = "true" ]; then
        echo "has_changes=true" >> "$GITHUB_OUTPUT"
        echo "✅ Changes detected - will create PR"
    else
        echo "has_changes=false" >> "$GITHUB_OUTPUT"
        echo "ℹ️  No changes detected - skipping PR creation"
    fi
}

cmd_show_diff() {
    # Requires: GITHUB_STEP_SUMMARY
    {
        echo "## ℹ️ Changes Detected (PR Creation Pending)"
        echo ""
        echo "Changes were detected. A PR will be created if:"
        echo "- The changes can be staged (files differ from branch)"
        echo "- The commits differ from origin/master"
        echo ""
        echo "## Changes Detected in CIS Reference"
        echo ""
        echo "The CIS→NIST mapping reference files have changed."
        echo ""

        echo "### File Statistics"
        echo '```'
        for product in $PRODUCTS; do
            REF_YML="shared/references/controls/nist_800_53_cis_reference_${product}.yml"
            REF_DIR="shared/references/controls/nist_800_53_cis_reference_${product}/"
            git diff --stat HEAD -- "$REF_YML" "$REF_DIR" 2>/dev/null || true
        done
        echo '```'
        echo ""

        for product in $PRODUCTS; do
            REF_DIR="shared/references/controls/nist_800_53_cis_reference_${product}"
            echo "### $product Changes"
            CHANGED_COUNT=$(git diff --name-only HEAD -- "$REF_DIR" | wc -l)
            if [ "$CHANGED_COUNT" -gt 0 ]; then
                echo "Changed files: $CHANGED_COUNT"
                echo '```'
                git diff --name-only HEAD -- "$REF_DIR" \
                    | xargs -n 1 basename 2>/dev/null || true
                echo '```'
            else
                echo "No changes for $product"
            fi
            echo ""
        done

        echo "### What This Means"
        echo "- CIS reference files show CIS→NIST mappings per product"
        echo "- NO Jinja2 guards - rules are filtered by product"
        echo "- Review the full diff in the PR to see all changes"
        PDIR="\`products/{product}/controls/nist_800_53/\*.yml\`"
        echo "- Manually apply relevant changes to $PDIR"
        echo "- Product control files may have additional human edits"

    } >> "$GITHUB_STEP_SUMMARY"
}

cmd_create_pr() {
    # Requires: GITHUB_TOKEN, GITHUB_STEP_SUMMARY, GITHUB_OUTPUT
    # Requires: GHA_EVENT_NAME, GHA_RUN_ID, GHA_REPOSITORY

    BRANCH_NAME="auto-update-nist-800-53-$(date +%Y%m%d-%H%M%S)"
    echo "Creating branch: $BRANCH_NAME"
    git checkout -b "$BRANCH_NAME"

    echo "Staging product-specific reference files..."
    for product in $PRODUCTS; do
        REF_BASE="shared/references/controls/nist_800_53_cis_reference_${product}"
        git add "${REF_BASE}.yml" 2>/dev/null || true
        git add "${REF_BASE}/" 2>/dev/null || true
    done

    echo "Checking for staged changes..."
    if git diff --cached --quiet; then
        {
            echo "⚠️  No staged changes detected"
            echo ""
            echo "**Reason:** Files are identical to what's in master."
            echo "- The CIS mappings haven't changed since last sync"
            echo "- The OSCAL catalog is the same version"
            echo "✓ No action needed - everything is in sync!"
        } | tee -a "$GITHUB_STEP_SUMMARY"
        exit 0
    fi

    echo "✓ Found staged changes, proceeding with commit..."
    git diff --cached --stat

    ADDED=$(git diff --cached --numstat | awk '{sum+=$1} END {print sum}')
    REMOVED=$(git diff --cached --numstat | awk '{sum+=$2} END {print sum}')
    CHANGES_SUMMARY="+${ADDED:-0}/-${REMOVED:-0}"

    git commit -m "$(cat <<EOF
Update NIST 800-53 CIS reference from latest mappings

This automated update regenerates the CIS→NIST reference file from
the latest OSCAL catalog and CIS benchmark mappings.

Changes: ${CHANGES_SUMMARY} lines in CIS reference files

⚠️  MANUAL ACTION REQUIRED:
Review the diff and manually update the product control files.

Generated by: Weekly NIST 800-53 Sync Workflow
Co-Authored-By: github-actions[bot] <github-actions[bot]@users.noreply.github.com>
EOF
    )"

    git push origin "$BRANCH_NAME"

    echo "Verifying commits differ from origin/master..."
    COMMITS_AHEAD=$(git rev-list --count origin/master.."$BRANCH_NAME" 2>/dev/null || echo "0")
    if [ "$COMMITS_AHEAD" = "0" ]; then
        {
            echo "⚠️  No commits ahead of origin/master"
            echo ""
            echo "**Branch:** $BRANCH_NAME"
            echo "Skipping PR creation (would fail with 'no commits' error)."
        } | tee -a "$GITHUB_STEP_SUMMARY"
        exit 0
    fi

    echo "✓ Found $COMMITS_AHEAD commit(s) ahead of origin/master"

    echo "Checking for existing open PRs..."
    EXISTING_PR=$(gh pr list \
        --base master --state open \
        --search "NIST 800-53 CIS Reference Update in:title" \
        --json number --jq '.[0].number' \
        2>/dev/null || echo "")

    if [ -n "$EXISTING_PR" ]; then
        EXISTING_PR_URL=$(gh pr view "$EXISTING_PR" --json url --jq '.url')
        TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S UTC')
        RUN_URL="https://github.com/${GHA_REPOSITORY}/actions/runs/${GHA_RUN_ID}"

        gh pr comment "$EXISTING_PR" --body "$(cat <<EOF
🔄 **Workflow Re-run Update**

The CIS-NIST sync workflow ran again at **$TIMESTAMP**.
The reference files are still up to date with the same changes as this PR.

_Automated comment from [workflow run ${GHA_RUN_ID}]($RUN_URL)_
EOF
        )"

        git push origin --delete "$BRANCH_NAME" 2>/dev/null || true

        {
            echo "⚠️  Found existing open PR #$EXISTING_PR"
            echo "✅ Updated existing PR with timestamp comment"
            echo "  at $EXISTING_PR_URL"
        } >> "$GITHUB_STEP_SUMMARY"
        exit 0
    fi

    if [ "$GHA_EVENT_NAME" = "schedule" ]; then
        TRIGGER="Weekly scheduled workflow"
    else
        TRIGGER="Manual workflow dispatch"
    fi

    PR_URL=$(gh pr create \
        --title "🔄 NIST 800-53 CIS Reference Update ($(date +%Y-%m-%d))" \
        --body "$(cat <<EOF
## Summary
This automated PR updates the **CIS reference file** showing the
latest CIS→NIST mappings.

## ⚠️  MANUAL ACTION REQUIRED

Review changes and update product control files accordingly:

1. **Review the diff** to see what changed in CIS mappings
2. **Apply** changes to \`products/{p}/controls/nist_800_53/*.yml\`
3. **Preserve** human-added rules or notes in the real files
4. **Commit** manual updates to the real control files in this PR

## Changes
- ${CHANGES_SUMMARY} lines modified in CIS reference files
- Reference files in \`shared/references/controls/\`

## File Roles

| File | Purpose | By |
|------|---------|-----|
| \`shared/references/.../{p}.yml\` | Ref metadata | 🤖 |
| \`shared/references/.../{p}/*.yml\` | Ref families | 🤖 |
| \`products/{p}/controls/nist_800_53.yml\` | Product metadata | 👤 |
| \`products/{p}/controls/nist_800_53/*.yml\` | Product families | 👤 |

## Details
- **Triggered by**: $TRIGGER
- **Date**: $(date '+%Y-%m-%d %H:%M:%S UTC')
- **OSCAL**: NIST SP 800-53 Revision 5

🤖 Generated by weekly sync workflow
EOF
        )" \
        --base master \
        --head "$BRANCH_NAME")

    REF_BASE="shared/references/controls/nist_800_53_cis_reference"
    CHANGED_FAMILIES=$(git diff --name-only \
        origin/master...HEAD -- "${REF_BASE}*/" \
        | xargs -n 1 basename 2>/dev/null | sort || echo "None")

    FAMILIES_DIFF=$(git diff origin/master...HEAD -- "${REF_BASE}*/" | head -1000)
    TRUNC_MSG=""
    FULL_LINES=$(git diff origin/master...HEAD -- "${REF_BASE}*/" | wc -l)
    [ "$FULL_LINES" -gt 1000 ] && \
        TRUNC_MSG="_Diff truncated to 1000 lines. View full diff in Files Changed._"

    gh pr comment "$PR_URL" --body "$(cat <<EOF
## Detailed Changes in CIS Reference Files

### Changed Family Files
\`\`\`
$CHANGED_FAMILIES
\`\`\`

<details>
<summary>📁 Family files diff</summary>

\`\`\`diff
$FAMILIES_DIFF
\`\`\`

$TRUNC_MSG

</details>

**Tip:** Family files (ac.yml, au.yml, cm.yml, etc.) make it
easier to review changes by control area.
EOF
    )"

    {
        echo "✅ Pull request created: $PR_URL"
        echo "Branch: \`$BRANCH_NAME\`"
    } >> "$GITHUB_STEP_SUMMARY"
}

cmd_workflow_summary() {
    # Requires: GITHUB_STEP_SUMMARY, GHA_EVENT_NAME, HAS_CHANGES
    {
        echo "## 📊 CIS-NIST Sync Workflow Summary"
        echo ""
        echo "**Event:** ${GHA_EVENT_NAME}"
        echo "**Run ID:** ${GHA_RUN_ID}"
        echo ""

        if [ "${HAS_CHANGES}" = "true" ]; then
            if [ "$GHA_EVENT_NAME" = "schedule" ] || [ "$GHA_EVENT_NAME" = "workflow_dispatch" ]; then
                echo "**Outcome:** Changes detected, attempted PR creation"
                echo ""
                echo "See the 'Create Pull Request' step for PR creation status."
            else
                echo "**Outcome:** Changes detected"
                echo "(PR creation only runs on schedule/manual trigger)"
            fi
        else
            echo "**Outcome:** ✅ No changes - reference files are up to date"
            echo ""
            echo "CIS mappings and OSCAL catalog have not changed since last sync."
        fi
    } >> "$GITHUB_STEP_SUMMARY"
}

case "${1:-}" in
    verify)            cmd_verify ;;
    collect-artifacts) cmd_collect_artifacts ;;
    summarize)         cmd_summarize ;;
    check-changes)     cmd_check_changes ;;
    show-diff)         cmd_show_diff ;;
    create-pr)         cmd_create_pr ;;
    workflow-summary)  cmd_workflow_summary ;;
    *)
        echo "Usage: $0 {verify|collect-artifacts|summarize|check-changes|show-diff|create-pr|workflow-summary}" >&2
        exit 1
        ;;
esac
