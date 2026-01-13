import os
import subprocess
import sys

try:
    from github import Github
except ImportError:
    print("Please install PyGithub, you need a specific version of pygithub, "
          "install it through $ pip install \"PyGithub>=1.58.2,<2.0\"",
          file=sys.stderr)
    sys.exit(1)

# --- CONFIGURATION ---
GITHUB_NAMESPACE = "RedHatOfficial"
RHEL_ROLE_PREFIX = "ansible-role-rhel"
ROLE_PREFIX = "ansible-role-"

# The tokens must be exported in your terminal session before running the script:
# export GALAXY_TOKEN="your_galaxy_token_here"
# export GITHUB_TOKEN="your_github_token_here"
GALAXY_TOKEN = os.getenv("GALAXY_TOKEN")
GITHUB_TOKEN = os.getenv("GITHUB_TOKEN")


if not GALAXY_TOKEN:
    print("ERROR: The GALAXY_TOKEN environment variable is not set.")
    print("Please set it (export GALAXY_TOKEN=\"...\") and try again.")
    sys.exit(1)

if not GITHUB_TOKEN:
    print("ERROR: The GITHUB_TOKEN environment variable is not set.")
    print("Please set it (export GITHUB_TOKEN=\"...\") and try again.")
    sys.exit(1)


def get_role_repositories():
    """
    Retrieves the list of repositories in the namespace using PyGithub.
    """
    print(f"Searching for repositories in '{GITHUB_NAMESPACE}'")

    github = Github(GITHUB_TOKEN)

    try:
        github_org = github.get_organization(GITHUB_NAMESPACE)
        repos = [repo.name for repo in github_org.get_repos()]
        return repos

    except Exception as e:
        print(f"\nERROR accessing GitHub API: {e}")
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
