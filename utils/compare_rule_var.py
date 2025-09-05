#!/usr/bin/env python3
import sys
import subprocess
import json
import base64
import argparse
import io
from ruamel.yaml import YAML
from typing import Optional


def run_command(command: list[str]) -> tuple[int, str, str]:
    """Runs a shell command and returns its exit code, stdout, and stderr."""
    res = subprocess.run(command, capture_output=True, text=True, check=False)
    return res.returncode, res.stdout, res.stderr


def get_file_content_from_pr(owner: str, repo: str, sha: str, file_path: str) -> str:
    """Fetches file content for a given commit SHA using the GitHub API.
    The base64 encoding and decoding step is necessary because of how the
    GitHub API is designed to transmit file content.
    """
    api_path = f"/repos/{owner}/{repo}/contents/{file_path}?ref={sha}"
    print(f"-> Fetching file content for '{file_path}' from commit {sha[:7]}...")
    returncode, stdout, stderr = run_command(["gh", "api", api_path])

    if returncode != 0:
        print(f"Exception: Could not fetch file. It may be new or deleted. "
              f"(stderr: {stderr.strip()})")
        return ""

    try:
        content_json = json.loads(stdout)
        encoded_content = content_json.get('content', '')
        if not encoded_content:
            return ""

        return base64.b64decode(encoded_content).decode('utf-8')
    except (json.JSONDecodeError, KeyError, TypeError) as e:
        print(f"Exception: Could not parse or decode content. Error: {e}", file=sys.stderr)
        return ""


def parse_yaml_and_get_keys(content: str, keys_to_find: list[str]) -> Optional[str]:
    """
    Parses a YAML content string, cleans it, and finds the values of ALL
    matching keys from the provided list. Returns a canonical YAML string
    of the found keys and their values for comparison.
    """
    yaml = YAML(typ='safe')
    # The rule.yml has '{{{...}}}' that can't be parsed by YMAL.
    # Pre-process content to remove invalid lines.
    lines = content.splitlines()
    clean_lines = [line for line in lines if not line.strip().startswith('{{{')]
    cleaned_content = "\n".join(clean_lines)

    if not cleaned_content.strip():
        return None

    try:
        data = yaml.load(cleaned_content)
        if not isinstance(data, dict):
            return None
    except Exception as e:
        print(f"Exception: Could not parse YAML content. Error: {e}", file=sys.stderr)
        return None

    # Create a dictionary of all found keys and their values
    found_data = {}
    for key in keys_to_find:
        if key in data:
            found_data[key] = data.get(key)

    if not found_data:
        return None

    # For consistent comparison, convert the found data dict back to a YAML string
    string_stream = io.StringIO()
    yaml.dump(found_data, string_stream)
    return string_stream.getvalue().strip()


def main():
    """Main function to fetch PR files, parse them, and compare keys."""
    parser = argparse.ArgumentParser(
        description="Compare specific keys in a YAML file between a PR's base and head branches."
    )
    parser.add_argument("--owner", required=True, help="The owner of the repository.")
    parser.add_argument("--repo", required=True, help="The name of the repository.")
    parser.add_argument("pr_number", type=int, help="The Pull Request number.")
    parser.add_argument("file_path", type=str, help="The file path within the repository.")
    parser.add_argument(
        "keys",
        nargs='+',
        help="One or more keys to check in order "
             "(e.g., description options)."
    )

    args = parser.parse_args()

    print(f"--- Analyzing '{args.file_path}' in PR #{args.pr_number} for keys: {args.keys} ---")
    print(f"Repository: {args.owner}/{args.repo}")

    # 1. Get the base and head commit SHAs.
    gh_pr_command = [
        "gh", "pr", "view", str(args.pr_number),
        "--repo", f"{args.owner}/{args.repo}",
        "--json", "baseRefOid,headRefOid"
    ]
    returncode, stdout, stderr = run_command(gh_pr_command)

    if returncode != 0:
        print(
            f"\nException: Failed to get PR details. "
            f"gh stderr: {stderr.strip()}",
            file=sys.stderr
        )

        sys.exit(0)
    try:
        shas = json.loads(stdout)
        base_sha = shas['baseRefOid']
        head_sha = shas['headRefOid']
        print(f"Base SHA (Before): {base_sha}")
        print(f"Head SHA (After):  {head_sha}\n")
    except (json.JSONDecodeError, KeyError) as e:
        print(
            f"\nException: Could not parse commit SHAs. "
            f"Error: {e}",
            file=sys.stderr
        )

        sys.exit(0)

    # 2. Fetch file content for both commits.
    before_content = get_file_content_from_pr(
        args.owner, args.repo, base_sha, args.file_path
    )
    after_content = get_file_content_from_pr(
        args.owner, args.repo, head_sha, args.file_path
    )

    # 3. Parse the content in memory to get the desired values.
    before_value = parse_yaml_and_get_keys(before_content, args.keys)
    after_value = parse_yaml_and_get_keys(after_content, args.keys)

    # 4. Compare the results and print the final output.
    print("\n--- Comparison Result ---")
    print(f"Value(s) in base branch:\n---\n{before_value}\n---")
    print(f"Value(s) in PR branch:\n---\n{after_value}\n---")

    if before_value == after_value:
        print("\nNo changes detected for the specified keys.")
        sys.exit(0)
    else:
        print("\nChange detected for one of the specified keys!")
        print("\nCHANGE_FOUND=true")
        sys.exit(1)


if __name__ == "__main__":
    main()
