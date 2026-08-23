#!/usr/bin/env python3
"""
Download NIST OSCAL catalog and baseline profiles.
Downloads the official NIST SP 800-53 Rev 5 catalog in JSON format.
"""

import json
import os
import sys
from pathlib import Path
import requests

# NIST OSCAL official repository URLs
OSCAL_CATALOG_URL = "https://raw.githubusercontent.com/usnistgov/oscal-content/main/nist.gov/SP800-53/rev5/json/NIST_SP-800-53_rev5_catalog.json"
OSCAL_LOW_BASELINE_URL = "https://raw.githubusercontent.com/usnistgov/oscal-content/main/nist.gov/SP800-53/rev5/json/NIST_SP-800-53_rev5_LOW-baseline_profile.json"
OSCAL_MODERATE_BASELINE_URL = "https://raw.githubusercontent.com/usnistgov/oscal-content/main/nist.gov/SP800-53/rev5/json/NIST_SP-800-53_rev5_MODERATE-baseline_profile.json"
OSCAL_HIGH_BASELINE_URL = "https://raw.githubusercontent.com/usnistgov/oscal-content/main/nist.gov/SP800-53/rev5/json/NIST_SP-800-53_rev5_HIGH-baseline_profile.json"


def download_file(url: str, output_path: Path) -> bool:
    """Download a file from URL to output path."""
    try:
        print(f"Downloading {url}...")
        response = requests.get(url, timeout=30)
        response.raise_for_status()

        # Validate JSON
        data = response.json()

        # Write to file
        output_path.parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2)

        print(f"  ✓ Saved to {output_path}")
        return True
    except Exception as e:
        print(f"  ✗ Failed: {e}", file=sys.stderr)
        return False


def main():
    """Download all NIST OSCAL files."""
    script_dir = Path(__file__).parent
    data_dir = script_dir / "data"

    downloads = [
        (OSCAL_CATALOG_URL, data_dir / "nist_800_53_rev5_catalog.json"),
        (OSCAL_LOW_BASELINE_URL, data_dir / "nist_800_53_rev5_low_baseline.json"),
        (OSCAL_MODERATE_BASELINE_URL, data_dir / "nist_800_53_rev5_moderate_baseline.json"),
        (OSCAL_HIGH_BASELINE_URL, data_dir / "nist_800_53_rev5_high_baseline.json"),
    ]

    success_count = 0
    for url, path in downloads:
        if download_file(url, path):
            success_count += 1

    print(f"\nDownloaded {success_count}/{len(downloads)} files successfully")

    if success_count == len(downloads):
        print("\n✓ All NIST OSCAL files downloaded successfully!")
        return 0
    else:
        print("\n✗ Some downloads failed. Please check errors above.", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
