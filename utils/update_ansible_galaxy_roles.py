import os
import subprocess
import sys

# --- CONFIGURATION ---
GITHUB_NAMESPACE = "RedHatOfficial"
RHEL_ROLE_PREFIX = "ansible-role-rhel"
ROLE_PREFIX = "ansible-role-"

# The token must be exported in your terminal session before running the script:
# export GALAXY_TOKEN="your_token_here"
GALAXY_TOKEN = os.getenv("GALAXY_TOKEN")


if not GALAXY_TOKEN:
    print("ERROR: The GALAXY_TOKEN environment variable is not set.")
    print("Please set it (export GALAXY_TOKEN=\"...\") and try again.")
    sys.exit(1)


def get_role_repositories():
    """
    Searches for the list of repositories in the namespace using the GitHub CLI (gh).
    """
    print(f"Searching for repositories in '{GITHUB_NAMESPACE}'")

    # Command 'gh search repos' to search for repositories and extract only the name
    command = [
        "gh", "search", "repos",
        f"org:{GITHUB_NAMESPACE}",
        "--json", "name",
        "--jq", ".[].name",
        "--limit", "1000"
    ]

    try:
        # Execute the command and capture the output
        result = subprocess.run(command, capture_output=True, text=True, check=True)
        repos = result.stdout.strip().split('\n')
        return [repo for repo in repos if repo]

    except subprocess.CalledProcessError as e:
        print("\nERROR running the 'gh' command. Check if GitHub CLI is installed and authenticated.")
        print(f"Error details: {e.stderr}")
        sys.exit(1)
    except FileNotFoundError:
        print("\nERROR: The 'gh' command (GitHub CLI) was not found.")
        print("Ensure that GitHub CLI is installed and accessible in your PATH.")
        sys.exit(1)


def import_role(repo_name):
    """
    Executes the ansible-galaxy role import command for a specific repository.
    The role name in Galaxy is derived by stripping the ROLE_PREFIX from the repo name.
    """
    # ----------------------------------------------------------------------
    # Calculate the destination role name for Ansible Galaxy
    # Example: 'ansible-role-rhel9-cis' -> 'rhel9_cis'
    # ----------------------------------------------------------------------
    galaxy_role_name = repo_name.replace(ROLE_PREFIX, '', 1).replace('-', '_')

    print(f"-> Syncing: GitHub Repo='{repo_name}' -> Galaxy Role='{galaxy_role_name}'")

    # 'ansible-galaxy role import' command
    # Note: The command syntax is 'ansible-galaxy role import <github_user> <github_repo> --role-name <galaxy_name>'
    command = [
        "ansible-galaxy", "role", "import",
        f"--token={GALAXY_TOKEN}", # Pass the token
        GITHUB_NAMESPACE,
        repo_name,
        "--role-name", galaxy_role_name, # Specify the final role name without the prefix
        "--no-wait" # do not wait for the import to finish
    ]

    try:
        # Execute the command and capture output
        process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        stdout, stderr = process.communicate()

        if process.returncode == 0:
            print(f"   [SUCCESS] Import request submitted for https://galaxy.ansible.com/ui/standalone/roles/RedHatOfficial/{galaxy_role_name}.")
            print("-" * 10)
        else:
            print(f"   [FAILURE] Error importing {repo_name}. Code: {process.returncode}")
            print(f"   Ansible Galaxy output: {stderr.strip()}")
            # Print the command if it failed for debugging purposes
            print(f"   Failed Command: {' '.join(command)}")
            print("-" * 10)

    except FileNotFoundError:
        print("\nERROR: The 'ansible-galaxy' command was not found.")
        print("Ensure that Ansible is installed and accessible in your PATH.")
        sys.exit(1)


if __name__ == "__main__":

    # Get the list of repositories
    repos_found = get_role_repositories()

    if not repos_found:
        print(f"No repositories found starting with in '{GITHUB_NAMESPACE}'.")
        sys.exit(0)

    # Iterate over the list and execute the import for each one
    repo_count = 0
    for repo in repos_found:
        if repo.startswith(RHEL_ROLE_PREFIX):
            import_role(repo)
            repo_count += 1

    print(f"Bulk synchronization process complete. A total of {repo_count} repositories were updated.")
