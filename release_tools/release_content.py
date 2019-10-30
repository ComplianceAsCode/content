import argparse
import re
import yaml
import sys

def load_env(env_path):
    with open(env_path, 'r') as env_stream:
        env = yaml.safe_load(env_stream)
    return env

def validate_env(env, env_path):
    env_ok = True
    mandatory_fields = ['github_token', 'jenkins_user', 'jenkins_token']
    for field in mandatory_fields:
        if field not in env:
            print(f"Add your {field} in {env_path} file. Check the README.md for how to obtain it.")
            env_ok = True
    return env_ok

def parse_version(cmakelists_path):
    regex = re.compile(r'set\(SSG_(.*)_VERSION (\d+)\)')

    with open(cmakelists_path, 'r') as cmakelists_stream:
        cmakelists_content = cmakelists_stream.read()

        matches = re.findall(regex, cmakelists_content)
    version = { v_name.lower():v_value for v_name,v_value in matches }
    return version

def get_version_string(d):
    return f"{d['major']}.{d['minor']}.{d['patch']}"


def create_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument('--env', default='.env.yml', dest='env_path',
                        help="Environment file with GitHub token and Jenkins username and token. "
                             "Check the README.md file to know what to put in the file")
    parser.add_argument("--owner", default="ComplianceAsCode")
    parser.add_argument("--repo", default="content")

    return parser.parse_args()


if __name__ == "__main__":
    parser = create_parser()

    try:
        env = load_env(parser.env_path)
        if not validate_env(env, parser.env_path):
            sys.exit(1)
    except FileNotFoundError as e:
        print("Create a .env.yaml file and populate it. Check the README.md file for details.")
        sys.exit(1)

    version_dict = parse_version('../CMakeLists.txt')
    parser.version = get_version_string(version_dict)
