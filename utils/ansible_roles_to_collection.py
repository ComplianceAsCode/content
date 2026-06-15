#!/usr/bin/python3
"""
Generate an Ansible collection from ComplianceAsCode Ansible roles.

Takes Ansible roles (generated from profile playbooks via ansible_playbook_to_role.py)
and bundles them into an Ansible collection for publishing to Ansible Galaxy.

Modules from community.general and ansible.posix that are used in the roles are
vendored into the collection to eliminate external runtime dependencies.

Usage:
  python3 utils/ansible_roles_to_collection.py \\
      --roles-dir build/ansible_roles \\
      --output-dir /tmp/collection \\
      [--version 0.1.82]  # defaults to the SSG project version from CMakeLists.txt \\
      [--namespace redhatofficial] \\
      [--collection rhel_hardening_roles] \\
      [--community-general community-general-X.Y.Z.tar.gz] \\
      [--ansible-posix ansible-posix-X.Y.Z.tar.gz] \\
      [--build]
"""

import argparse
import json
import os
import shutil
import subprocess
import sys
import tarfile
import tempfile
from urllib.request import urlopen, urlretrieve

try:
    import yaml
except ImportError:
    print("Please install PyYAML: pip install pyyaml", file=sys.stderr)
    raise SystemExit(1) from None

# Import filtering constants from the companion script — single source of truth.
_UTILS_DIR = os.path.dirname(os.path.abspath(__file__))
if _UTILS_DIR not in sys.path:
    sys.path.insert(0, _UTILS_DIR)
from ansible_playbook_to_role import PRODUCT_ALLOWLIST, PROFILE_DENYLIST


SSG_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))


def _get_ssg_version():
    """Read the project version from CMakeLists.txt."""
    cmake_path = os.path.join(SSG_ROOT, "CMakeLists.txt")
    parts = {}
    with open(cmake_path, "r", encoding="utf-8") as f:
        for line in f:
            for key in ("SSG_MAJOR_VERSION", "SSG_MINOR_VERSION", "SSG_PATCH_VERSION"):
                if line.strip().startswith(f"set({key}"):
                    parts[key] = line.split()[-1].rstrip(")")
    return "{SSG_MAJOR_VERSION}.{SSG_MINOR_VERSION}.{SSG_PATCH_VERSION}".format(**parts)


SSG_VERSION = _get_ssg_version()

COLLECTION_NAMESPACE = "redhatofficial"
COLLECTION_NAME = "rhel_hardening_roles"
COLLECTION_AUTHORS = [
    "ComplianceAsCode development team <scap-security-guide@lists.fedorahosted.org>"
]
COLLECTION_DESCRIPTION = (
    "Ansible roles for RHEL system hardening, generated from ComplianceAsCode content."
)
COLLECTION_LICENSE = ["BSD-3-Clause"]
COLLECTION_REPOSITORY = "https://github.com/ComplianceAsCode/content"
COLLECTION_HOMEPAGE = "https://github.com/ComplianceAsCode/content"
COLLECTION_ISSUES = "https://github.com/ComplianceAsCode/content/issues"
COLLECTION_TAGS = [
    "security", "compliance", "hardening", "rhel", "scap", "openscap", "complianceascode"
]

# Ansible Galaxy API endpoint for querying latest versions
GALAXY_VERSIONS_URL = (
    "https://galaxy.ansible.com/api/v3/collections/{namespace}/{name}/versions/?page_size=1"
)
# Direct artifact download URL
GALAXY_ARTIFACT_URL = (
    "https://galaxy.ansible.com/api/v3/plugin/ansible/content/published/collections/artifacts/"
    "{namespace}-{name}-{version}.tar.gz"
)

# Collections whose modules will be vendored when found in the roles.
# Adding a collection here is enough — the script auto-detects which modules
# from it are actually referenced and only downloads those.
COLLECTIONS_TO_VENDOR = [
    "community.general",
    "ansible.posix",
]

def detect_modules_to_bundle(roles_dir, collections_to_vendor):
    """
    Scan role YAML files and return which modules from each vendored collection
    are actually referenced, so only the needed modules are downloaded and bundled.

    Returns a dict: {"community.general": ["ini_file", ...], "ansible.posix": [...]}
    """
    import re

    fqcn_re = re.compile(
        r"(?:" + "|".join(re.escape(c) for c in collections_to_vendor) + r")\.\w+"
    )

    found = {c: set() for c in collections_to_vendor}

    for root, _dirs, files in os.walk(roles_dir):
        for filename in files:
            if not filename.endswith((".yml", ".yaml")):
                continue
            filepath = os.path.join(root, filename)
            try:
                with open(filepath, "r", encoding="utf-8") as f:
                    content = f.read()
            except (OSError, UnicodeDecodeError):
                continue
            for match in fqcn_re.finditer(content):
                fqcn = match.group(0)
                # split into collection (first two parts) and module name (rest)
                parts = fqcn.split(".")
                collection = ".".join(parts[:2])
                module = ".".join(parts[2:])
                if collection in found:
                    found[collection].add(module)

    detected = {c: sorted(modules) for c, modules in found.items() if modules}
    for collection, modules in detected.items():
        print(f"  Detected {len(modules)} module(s) from {collection}: {', '.join(modules)}")
    return detected


README_TEMPLATE = """\
# {namespace}.{collection_name}

Ansible collection providing hardening roles for Red Hat Enterprise Linux,
generated from [ComplianceAsCode/content](https://github.com/ComplianceAsCode/content).

## Roles

{roles_list}

## Usage

```yaml
- hosts: all
  roles:
    - {namespace}.{collection_name}.rhel9_stig
```

## License

BSD-3-Clause

## Author

ComplianceAsCode development team
"""


def parse_args():
    parser = argparse.ArgumentParser(
        description="Bundle Ansible roles into an Ansible collection for Ansible Galaxy publishing."
    )
    parser.add_argument(
        "--roles-dir", "-r",
        required=True,
        dest="roles_dir",
        help="Directory containing the Ansible roles (output of ansible_playbook_to_role.py)."
    )
    parser.add_argument(
        "--output-dir", "-o",
        required=True,
        dest="output_dir",
        help="Destination directory for the generated collection structure."
    )
    parser.add_argument(
        "--namespace", "-n",
        default=COLLECTION_NAMESPACE,
        help=f"Collection namespace. Defaults to '{COLLECTION_NAMESPACE}'."
    )
    parser.add_argument(
        "--collection", "-c",
        default=COLLECTION_NAME,
        help=f"Collection name. Defaults to '{COLLECTION_NAME}'."
    )
    parser.add_argument(
        "--version", "-v",
        default=SSG_VERSION,
        help=f"Collection version string. Defaults to the SSG project version ({SSG_VERSION})."
    )
    parser.add_argument(
        "--community-general",
        metavar="TARBALL",
        dest="community_general",
        help="Path to a community.general collection tarball. "
             "Downloaded from Ansible Galaxy if not provided."
    )
    parser.add_argument(
        "--ansible-posix",
        metavar="TARBALL",
        dest="ansible_posix",
        help="Path to an ansible.posix collection tarball. "
             "Downloaded from Ansible Galaxy if not provided."
    )
    parser.add_argument(
        "--community-general-version",
        default="latest",
        dest="community_general_version",
        metavar="VERSION",
        help="Version of community.general to download when --community-general is not provided."
    )
    parser.add_argument(
        "--ansible-posix-version",
        default="latest",
        dest="ansible_posix_version",
        metavar="VERSION",
        help="Version of ansible.posix to download when --ansible-posix is not provided."
    )
    parser.add_argument(
        "--build",
        action="store_true",
        help="Build the collection artifact (.tar.gz) after creating the collection structure."
    )
    parser.add_argument(
        "--galaxy-token",
        dest="galaxy_token",
        metavar="TOKEN",
        help="Ansible Galaxy API token. When provided, publishes the collection tarball "
             "to Ansible Galaxy (requires --build)."
    )
    parser.add_argument(
        "--galaxy-server",
        dest="galaxy_server",
        default="https://galaxy.ansible.com/",
        metavar="URL",
        help="Ansible Galaxy server URL. Defaults to https://galaxy.ansible.com/."
    )
    parser.add_argument(
        "--description",
        default=COLLECTION_DESCRIPTION,
        help="Collection description written into galaxy.yml."
    )
    parser.add_argument(
        "--documentation",
        default=None,
        metavar="URL",
        help="Documentation URL written into galaxy.yml."
    )
    parser.add_argument(
        "--homepage",
        default=COLLECTION_HOMEPAGE,
        metavar="URL",
        help=f"Collection homepage URL. Defaults to '{COLLECTION_HOMEPAGE}'."
    )
    parser.add_argument(
        "--issues",
        default=COLLECTION_ISSUES,
        metavar="URL",
        help=f"Issue tracker URL. Defaults to '{COLLECTION_ISSUES}'."
    )
    return parser.parse_args()


def _get_latest_collection_version(namespace, name):
    """Query Ansible Galaxy API for the latest version of a collection."""
    url = GALAXY_VERSIONS_URL.format(namespace=namespace, name=name)
    print(f"Querying Ansible Galaxy for the latest {namespace}.{name} version...")
    try:
        with urlopen(url) as response:
            data = json.loads(response.read())
        version = data["data"][0]["version"]
        print(f"  Latest {namespace}.{name}: {version}")
        return version
    except Exception as e:
        print(f"Failed to query Ansible Galaxy API for {namespace}.{name}: {e}", file=sys.stderr)
        raise SystemExit(1) from e


def download_collection(namespace, name, version, dest_dir):
    """Download a collection tarball from Ansible Galaxy."""
    if version == "latest":
        version = _get_latest_collection_version(namespace, name)
    url = GALAXY_ARTIFACT_URL.format(namespace=namespace, name=name, version=version)
    tarball_name = f"{namespace}-{name}-{version}.tar.gz"
    dest_path = os.path.join(dest_dir, tarball_name)
    print(f"Downloading {namespace}.{name} {version}...")
    try:
        urlretrieve(url, dest_path)
    except Exception as e:
        print(f"Failed to download {namespace}.{name}: {e}", file=sys.stderr)
        raise SystemExit(1) from e
    return dest_path


def extract_modules_from_collection(tarball_path, namespace, name, module_names, dest_dir):
    """
    Extract specific module .py files from a collection tarball.

    Returns a dict mapping module_name -> path to the extracted file.
    """
    extracted = {}
    with tarfile.open(tarball_path, "r:gz") as tar:
        for module_name in module_names:
            member_path = f"plugins/modules/{module_name}.py"
            try:
                member = tar.getmember(member_path)
            except KeyError:
                print(
                    f"  Warning: {member_path} not found in {namespace}.{name} tarball",
                    file=sys.stderr,
                )
                continue
            f = tar.extractfile(member)
            if f is None:
                continue
            dest_path = os.path.join(dest_dir, f"{module_name}.py")
            with open(dest_path, "wb") as out:
                out.write(f.read())
            extracted[module_name] = dest_path
            print(f"  Extracted {namespace}.{name}.{module_name}")
    return extracted


def create_collection_dirs(output_dir, namespace, collection_name):
    """Create the collection directory structure and return the root collection path."""
    collection_dir = os.path.join(
        output_dir, "ansible_collections", namespace, collection_name
    )
    for subdir in ("roles", os.path.join("plugins", "modules")):
        os.makedirs(os.path.join(collection_dir, subdir), exist_ok=True)
    return collection_dir


def generate_galaxy_yml(
    collection_dir, namespace, collection_name, version,
    description=COLLECTION_DESCRIPTION, documentation=None,
    homepage=COLLECTION_HOMEPAGE, issues=COLLECTION_ISSUES,
):
    """Write the galaxy.yml manifest for the collection."""
    galaxy_data = {
        "namespace": namespace,
        "name": collection_name,
        "version": version,
        "readme": "README.md",
        "authors": COLLECTION_AUTHORS,
        "description": description,
        "license": COLLECTION_LICENSE,
        "tags": COLLECTION_TAGS,
        "repository": COLLECTION_REPOSITORY,
        "homepage": homepage,
        "issues": issues,
        "build_ignore": [],
    }
    if documentation:
        galaxy_data["documentation"] = documentation
    galaxy_yml_path = os.path.join(collection_dir, "galaxy.yml")
    with open(galaxy_yml_path, "w", encoding="utf-8") as f:
        yaml.dump(galaxy_data, f, default_flow_style=False, allow_unicode=True)
    print("Generated galaxy.yml")


def generate_readme(collection_dir, namespace, collection_name, roles):
    """Write the collection README.md."""
    roles_list = "\n".join(f"- `{namespace}.{collection_name}.{r}`" for r in sorted(roles))
    content = README_TEMPLATE.format(
        namespace=namespace,
        collection_name=collection_name,
        roles_list=roles_list,
    )
    readme_path = os.path.join(collection_dir, "README.md")
    with open(readme_path, "w", encoding="utf-8") as f:
        f.write(content)
    print("Generated README.md")


def _remove_bundled_collection_deps(meta_path, bundled_collections):
    """
    Remove vendored collection names from the 'collections:' key in meta/main.yml
    so that the collection does not declare dependencies that are now self-contained.
    """
    with open(meta_path, "r", encoding="utf-8") as f:
        meta = yaml.safe_load(f) or {}

    deps = meta.get("galaxy_info", {}).get("collections") or meta.get("collections")
    if not deps:
        return

    # Filter out bundled collections
    filtered = [c for c in deps if c not in bundled_collections]
    if len(filtered) == len(deps):
        return

    if "galaxy_info" in meta and "collections" in meta["galaxy_info"]:
        if filtered:
            meta["galaxy_info"]["collections"] = filtered
        else:
            del meta["galaxy_info"]["collections"]
    elif "collections" in meta:
        if filtered:
            meta["collections"] = filtered
        else:
            del meta["collections"]

    with open(meta_path, "w", encoding="utf-8") as f:
        yaml.dump(meta, f, default_flow_style=False, allow_unicode=True)


def copy_roles(roles_dir, collection_dir, bundled_collections):
    """
    Copy Ansible roles into the collection's roles/ directory.

    Also strips collection dependencies that are now vendored from each role's
    meta/main.yml.
    """
    roles_dest = os.path.join(collection_dir, "roles")
    roles_copied = []
    for role_name in sorted(os.listdir(roles_dir)):
        role_src = os.path.join(roles_dir, role_name)
        if not os.path.isdir(role_src):
            continue
        # role names follow the pattern {product}_{profile}
        product = role_name.split("_")[0]
        profile = role_name[len(product) + 1:]
        if product not in PRODUCT_ALLOWLIST or profile in PROFILE_DENYLIST:
            continue
        role_dest = os.path.join(roles_dest, role_name)
        shutil.copytree(role_src, role_dest)
        roles_copied.append(role_name)

        # Remove vendored collection dependencies from role meta
        meta_path = os.path.join(role_dest, "meta", "main.yml")
        if os.path.isfile(meta_path):
            _remove_bundled_collection_deps(meta_path, bundled_collections)

    print(f"Copied {len(roles_copied)} roles into the collection.")
    return roles_copied


def bundle_modules(extracted_modules, collection_dir):
    """Copy extracted module .py files into plugins/modules/ of the collection."""
    modules_dest = os.path.join(collection_dir, "plugins", "modules")
    for module_name, src_path in extracted_modules.items():
        dest_path = os.path.join(modules_dest, f"{module_name}.py")
        shutil.copy2(src_path, dest_path)
    print(f"Bundled {len(extracted_modules)} modules into plugins/modules/.")


def _rewrite_file_fqcns(filepath, fqcn_map):
    """Rewrite FQCN module references in a single file (YAML or Python)."""
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    modified = content
    for old_prefix, new_fqcn in fqcn_map.items():
        # Rewrite FQCN module calls and python ansible_collections import paths
        modified = modified.replace(old_prefix + ".", new_fqcn + ".")
        # Handle Python ansible_collections import paths (dots become underscores in
        # the collection path component: community.general -> community.general)
        old_import = "ansible_collections." + old_prefix
        new_import = "ansible_collections." + new_fqcn
        modified = modified.replace(old_import, new_import)

    if modified != content:
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(modified)


def rewrite_fqcns(collection_dir, fqcn_map):
    """
    Walk all roles in the collection and rewrite external FQCN references to
    point at the vendored modules inside this collection.
    """
    roles_dir = os.path.join(collection_dir, "roles")
    rewritten = 0
    for root, _dirs, files in os.walk(roles_dir):
        for filename in files:
            if not filename.endswith((".yml", ".yaml", ".py")):
                continue
            filepath = os.path.join(root, filename)
            _rewrite_file_fqcns(filepath, fqcn_map)
            rewritten += 1
    print(f"Processed {rewritten} files for FQCN rewriting.")


def publish_to_galaxy(artifact_path, galaxy_token, galaxy_server="https://galaxy.ansible.com/"):
    """
    Publish a collection tarball to Ansible Galaxy via the API.

    This is the correct publishing mechanism for collections — Galaxy does not
    sync collections from GitHub repos (GitHub sync is a legacy feature for roles only).
    """
    from urllib.request import Request
    import urllib.error

    url = galaxy_server.rstrip("/") + "/api/v3/artifacts/collections/"
    print(f"Publishing {os.path.basename(artifact_path)} to {galaxy_server}...")
    with open(artifact_path, "rb") as f:
        content = f.read()

    boundary = "----SSGCollectionBoundary"
    body = (
        f"--{boundary}\r\n"
        f'Content-Disposition: form-data; name="file"; '
        f'filename="{os.path.basename(artifact_path)}"\r\n'
        f"Content-Type: application/gzip\r\n\r\n"
    ).encode() + content + f"\r\n--{boundary}--\r\n".encode()

    req = Request(url, data=body, method="POST")
    req.add_header("Authorization", f"Token {galaxy_token}")
    req.add_header("Content-Type", f"multipart/form-data; boundary={boundary}")

    try:
        with urlopen(req) as response:
            result = json.loads(response.read())
        print(f"Published successfully. Task: {result.get('task', 'N/A')}")
        return result
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", errors="replace")
        print(f"Galaxy publish failed ({e.code}): {body}", file=sys.stderr)
        raise SystemExit(1) from e


def build_collection_artifact(collection_dir, output_dir, namespace, collection_name, version):
    """Build the collection .tar.gz artifact using ansible-galaxy collection build.

    This produces a Galaxy-compatible tarball that includes the required
    MANIFEST.json and FILES.json entries, unlike a raw tarfile archive.
    """
    artifact_name = f"{namespace}-{collection_name}-{version}.tar.gz"
    artifact_path = os.path.join(output_dir, artifact_name)
    print(f"Building collection artifact: {artifact_name}")
    result = subprocess.run(
        [
            "ansible-galaxy", "collection", "build",
            "--output-path", output_dir,
            "--force",
            collection_dir,
        ],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        print(result.stdout)
        print(result.stderr, file=sys.stderr)
        raise SystemExit(1)
    print(f"Collection artifact: {artifact_path}")
    return artifact_path


def main():
    args = parse_args()

    if not os.path.isdir(args.roles_dir):
        print(f"Error: roles directory '{args.roles_dir}' does not exist.", file=sys.stderr)
        raise SystemExit(1)

    os.makedirs(args.output_dir, exist_ok=True)

    with tempfile.TemporaryDirectory() as tmpdir:
        # Auto-detect which modules from vendored collections are used in the roles
        print("Scanning roles for external module references...")
        modules_to_bundle = detect_modules_to_bundle(args.roles_dir, COLLECTIONS_TO_VENDOR)

        if not modules_to_bundle:
            print("No external modules detected — skipping vendoring step.")

        # Map collection FQCN to (namespace, name) for downloading
        collection_coords = {
            "community.general": ("community", "general"),
            "ansible.posix": ("ansible", "posix"),
        }

        # Resolve or download only the collection tarballs we actually need
        collection_tarballs = {}
        tarball_overrides = {
            "community.general": args.community_general,
            "ansible.posix": args.ansible_posix,
        }
        tarball_versions = {
            "community.general": args.community_general_version,
            "ansible.posix": args.ansible_posix_version,
        }
        for collection_fqcn in modules_to_bundle:
            ns, name = collection_coords[collection_fqcn]
            collection_tarballs[collection_fqcn] = (
                tarball_overrides.get(collection_fqcn)
                or download_collection(ns, name, tarball_versions.get(collection_fqcn, "latest"), tmpdir)
            )

        # Extract only the detected modules from each collection tarball
        print("Extracting modules to bundle...")
        extracted_modules = {}
        for collection_fqcn, module_names in modules_to_bundle.items():
            ns, name = collection_coords[collection_fqcn]
            extracted = extract_modules_from_collection(
                collection_tarballs[collection_fqcn], ns, name, module_names, tmpdir,
            )
            extracted_modules.update(extracted)

        # Create the collection directory structure
        print(
            f"\nCreating collection: {args.namespace}.{args.collection} v{args.version}"
        )
        collection_dir = create_collection_dirs(
            args.output_dir, args.namespace, args.collection
        )

        # Copy roles (also strips vendored deps from meta)
        roles = copy_roles(args.roles_dir, collection_dir, list(modules_to_bundle.keys()))

        # Copy vendored modules into plugins/modules/
        bundle_modules(extracted_modules, collection_dir)

        # Build the FQCN rewrite map: old prefix -> new FQCN for this collection
        new_fqcn = f"{args.namespace}.{args.collection}"
        fqcn_map = {source: new_fqcn for source in modules_to_bundle}
        rewrite_fqcns(collection_dir, fqcn_map)

        # Generate collection metadata
        generate_galaxy_yml(
            collection_dir, args.namespace, args.collection, args.version,
            description=args.description,
            documentation=args.documentation,
            homepage=args.homepage,
            issues=args.issues,
        )
        generate_readme(collection_dir, args.namespace, args.collection, roles)

    artifact_path = None
    if args.build or args.galaxy_token:
        artifact_path = build_collection_artifact(
            collection_dir, args.output_dir, args.namespace, args.collection, args.version
        )

    if args.galaxy_token:
        if artifact_path is None:
            print("Error: --galaxy-token requires --build to produce the artifact first.",
                  file=sys.stderr)
            raise SystemExit(1)
        publish_to_galaxy(artifact_path, args.galaxy_token, args.galaxy_server)

    print(f"\nCollection ready at: {collection_dir}")
    if artifact_path:
        print(f"Artifact: {artifact_path}")
    if args.galaxy_token:
        print(f"Galaxy:   {args.galaxy_server.rstrip('/')}/"
              f"{args.namespace}/{args.collection}/")


if __name__ == "__main__":
    main()
