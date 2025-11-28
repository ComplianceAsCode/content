#!/usr/bin/env python3
import sys
import subprocess
import json
import base64
import argparse
from typing import Optional, Tuple, NoReturn

from ssg.rule_yaml import find_section_lines


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


def get_section_from_content(content: str, section: str) -> Optional[str]:
    """
    Extracts a section's value from a string containing the file content.
    """
    if not content:
        return None

    lines = content.splitlines()
    found_ranges = find_section_lines(lines, section)

    if found_ranges:
        start, end = found_ranges[0]
        section_content = lines[start: end + 1]
        return '\n'.join(section_content)

    return None


def get_pr_shas(owner: str, repo: str, pr_number: int) -> Tuple[str, str]:
    """
    Fetches the base and head commit SHAs for a PR.
    """
    gh_pr_command = [
        "gh", "pr", "view", str(pr_number),
        "--repo", f"{owner}/{repo}",
        "--json", "baseRefOid,headRefOid"
    ]
    returncode, stdout, stderr = run_command(gh_pr_command)

    if returncode != 0:
        raise RuntimeError(f"Failed to get PR details. GitHub CLI stderr: {stderr.strip()}")

    try:
        shas = json.loads(stdout)
        base_sha = shas['baseRefOid']
        head_sha = shas['headRefOid']
        return base_sha, head_sha
    except (json.JSONDecodeError, KeyError) as e:
        raise ValueError(f"Could not parse commit SHAs from API response. Error: {e}") from e


def get_value_from_commit(
    owner: str,
    repo: str,
    file_path: str,
    key: str,
    sha: str
) -> Optional[str]:
    """
    Fetches a file from a specific commit and extracts the value of a given key.

    Args:
        owner: The repository owner.
        repo: The repository name.
        file_path: The path to the file within the repository.
        key: The section to extract from the file's content.
        sha: The commit SHA from which to retrieve the file.

    Returns:
        The extracted value as a string, or None if the file or key is not found.
    """
    # 1. Fetch the file's content for the given commit SHA.
    content = get_file_content_from_pr(owner, repo, sha, file_path)

    # 2. Parse the content to get the desired value.
    value = get_section_from_content(content, key)

    return value


def compare_value(
    owner: str,
    repo: str,
    pr_number: int,
    file_path: str,
    key: str
) -> NoReturn:
    """
    This function handles the entire process:
    1. Fetches the base and head commit SHAs for the PR.
    2. Retrieves the value of the specified key from the file at both commits.
    3. Compares the two values, prints a report, and exits with a status code.
    """
    # 1. Get the base and head commit SHAs.
    base_sha, head_sha = get_pr_shas(owner, repo, pr_number)

    # 2. Fetch and parse the values from the commits.
    before_value = get_value_from_commit(owner, repo, file_path, key, base_sha)
    after_value = get_value_from_commit(owner, repo, file_path, key, head_sha)

    # 3. Compare the results and print the final output.
    print("\n--- Comparison Result ---")
    print(f"Value in base branch:\n---\n{before_value or 'Not found'}\n---")
    print(f"Value in PR branch:\n---\n{after_value or 'Not found'}\n---")

    if before_value == after_value:
        print("\nNo changes detected for the specified keys.")
        sys.exit(0)
    else:
        print("\nChange detected for one of the specified keys!")
        print("\nCHANGE_FOUND=true")
        sys.exit(1)


def parse_args() -> argparse.Namespace:
    """
    Parses command-line arguments for the script.

    Returns:
        An object containing the parsed command-line arguments.
    """
    parser = argparse.ArgumentParser(
        description="Compare specific keys in a YAML file between a PR's base and head branches."
    )
    # Required arguments
    parser.add_argument("--owner", required=True, help="The owner of the repository.")
    parser.add_argument("--repo", required=True, help="The name of the repository.")
    parser.add_argument("pr_number", type=int, help="The Pull Request number.")
    parser.add_argument("file_path", type=str, help="The file path within the repository.")
    parser.add_argument("key", type=str, help="The key to be checked in the file.")

    return parser.parse_args()


def main() -> None:
    args = parse_args()
    compare_value(
        args.owner,
        args.repo,
        args.pr_number,
        args.file_path,
        args.key
    )


if __name__ == "__main__":
    main()
