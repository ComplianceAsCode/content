#!/usr/bin/python3

import argparse
import os
import shlex
import subprocess
import sys
import time


KNOWN_DISTROS = [
    "fedora",
    "centos8",
    "centos9",
    "rhel8",
    "rhel9",
]

# put here any unreleased distro in development that needs to be tested
# and any working osinfo known to be used by default when installating it
UNRELEASED_DISTROS_AND_OSINFO = {
    "rhel10": "rhel9-unknown"
}

DISTRO_URL = {
    "fedora":
        "https://download.fedoraproject.org/pub/fedora/linux/releases/41/Everything/x86_64/os",
    "centos8": "http://mirror.centos.org/centos/8-stream/BaseOS/x86_64/os/",
    "centos9": "http://mirror.stream.centos.org/9-stream/BaseOS/x86_64/os/",
}
DISTRO_EXTRA_REPO = {
    "centos8": "http://mirror.centos.org/centos/8-stream/AppStream/x86_64/os/",
    "centos9": "http://mirror.stream.centos.org/9-stream/AppStream/x86_64/os/",
}


def path_from_tests(path):
    return os.path.relpath(os.path.join(os.path.dirname(__file__), path))


def parse_args():
    import textwrap
    osinfo_epilog = textwrap.dedent(r"""
        --osinfo details: 'For unreleased distros, these are the following
        default data used as input {}.
    """.format(UNRELEASED_DISTROS_AND_OSINFO))
    parser = argparse.ArgumentParser(
        formatter_class=argparse.RawTextHelpFormatter,
        epilog=osinfo_epilog,
    )

    parser.add_argument(
        "--libvirt",
        dest="libvirt",
        default="qemu:///session",
        help="What hypervisor should be used when installing VM.",
    )
    parser.add_argument(
        "--kickstart",
        dest="kickstart",
        default=path_from_tests("kickstarts/test_suite.cfg"),
        help="Path to a kickstart file for installation of a VM.",
    )
    parser.add_argument(
        "--distro",
        dest="distro",
        required=True,
        choices=KNOWN_DISTROS + list(UNRELEASED_DISTROS_AND_OSINFO.keys()),
        help="What distribution to install.",
    )
    parser.add_argument(
        "--domain",
        dest="domain",
        required=True,
        help="What name should the new domain have.",
    )
    parser.add_argument(
        "--disk-dir",
        dest="disk_dir",
        default=None,
        help="Location of the VM qcow2 disk file (ignored when --disk is specified).",
    )
    parser.add_argument(
        "--disk-size",
        dest="disk_size",
        default=20,
        help="Size of the VM qcow2 disk, default is 20 GiB (ignored when --disk is specified).",
    )
    parser.add_argument(
        "--disk",
        dest="disk",
        help="Full disk type/spec, ie. pool=MyPool,bus=sata,cache=unsafe.",
    )
    parser.add_argument(
        "--ram",
        dest="ram",
        default=3072,
        type=int,
        help="Amount of RAM configured for the VM.",
    )
    parser.add_argument(
        "--cpu",
        dest="cpu",
        default=2,
        type=int,
        help="Number of CPU cores configured for the VM.",
    )
    parser.add_argument(
        "--network",
        dest="network",
        help="Network type/spec, ie. bridge=br0 or network=name.",
    )
    parser.add_argument(
        "--url",
        dest="url",
        default=None,
        help="URL to an installation tree on a remote server.",
    )
    parser.add_argument(
        "--extra-repo",
        dest="extra_repo",
        default=None,
        help="URL to an extra repository to be used during installation (e.g. AppStream).",
    )
    parser.add_argument(
        "--dry",
        dest="dry",
        action="store_true",
        help="Print command line instead of triggering command.",
    )
    parser.add_argument(
        "--ssh-pubkey",
        dest="ssh_pubkey",
        default=None,
        help="Path to an SSH public key which will be used to access the VM.",
    )
    parser.add_argument(
        "--uefi",
        dest="uefi",
        choices=[
            "secureboot",
            "normal",
        ],
        help="Perform UEFI based installation, optionally with secure boot support.",
    )
    parser.add_argument(
        "--install-gui",
        dest="install_gui",
        action="store_true",
        help="Perform a GUI installation (default is installation without GUI).",
    )
    parser.add_argument(
        "--console",
        dest="console",
        action="store_true",
        help="Connect to a serial console of the VM (to monitor installation progress).",
    )
    parser.add_argument(
        "--disk-unsafe",
        dest="disk_unsafe",
        action="store_true",
        help="Set cache unsafe.",
    )
    parser.add_argument(
        "--osinfo",
        dest="osinfo",
        default=None,
        help="Specify OSInfo for virt-install command.",
    )

    return parser.parse_args()


def wait_vm_not_running(domain):
    timeout = 300

    print(f'Waiting for {domain} VM to shutdown (max. {timeout}s)')
    end_time = time.time() + timeout
    try:
        while True:
            time.sleep(5)
            cmd = ["virsh", "domstate", domain]
            if subprocess.getoutput(cmd).rstrip() != "running":
                return
            if time.time() < end_time:
                continue
            print(f'Timeout reached: {domain} VM failed to shutdown, cancelling wait.')
            return
    except KeyboardInterrupt:
        print('Interrupted, cancelling wait.')
        return


def err(msg):
    print(msg, file=sys.stderr)
    sys.exit(1)


def try_known_urls(data):
    data.url = DISTRO_URL.get(data.distro, None)
    data.extra_repo = DISTRO_EXTRA_REPO.get(data.distro, None)

    if not data.url:
        err(f'For the "{data.distro}" distro the "--url" option needs to be provided.')


def handle_ssh_pubkey(data):
    data.ssh_pubkey_used = bool(data.ssh_pubkey)
    if not data.ssh_pubkey:
        home_dir = os.path.expanduser('~')
        user_default_key = f'{home_dir}/.ssh/id_rsa.pub'
        if os.path.isfile(user_default_key):
            data.ssh_pubkey = user_default_key
            with open(data.ssh_pubkey) as f:
                data.pub_key_content = f.readline().rstrip()
        else:
            err('SSH public key was not found or informed by "--ssh-pubkey" option.')


def handle_disk(data):
    disk_spec = [
        f'size={data.disk_size}',
        'format=qcow2',
    ]
    if data.disk:
        disk_spec.extend(data.disk.split(","))
    elif data.disk_dir:
        disk_path = os.path.join(data.disk_dir, data.domain) + ".qcow2"
        print(f'Location of VM disk: {disk_path}')
        disk_spec.append(f'path={disk_path}')
    if data.disk_unsafe:
        disk_spec.append('cache=unsafe')
    data.disk_spec = ','.join(disk_spec)


def handle_kickstart(data):
    data.ks_basename = os.path.basename(data.kickstart)

    tmp_kickstart = f'/tmp/{data.ks_basename}'
    with open(data.kickstart) as infile, open(tmp_kickstart, "w") as outfile:
        content = infile.read()
        content = content.replace("&&HOST_PUBLIC_KEY&&", data.pub_key_content)

        if data.distro != "fedora":
            content = content.replace("&&YUM_REPO_URL&&", data.url)

        repo_cmd = ""
        if data.extra_repo:
            repo_cmd = f'repo --name=extra-repository --baseurl={data.extra_repo}'
            content = content.replace("&&YUM_EXTRA_REPO_URL&&", data.extra_repo)

        content = content.replace("&&YUM_EXTRA_REPO&&", repo_cmd)

        if data.uefi:
            content = content.replace(
                "part /boot --fstype=xfs --size=512",
                "part /boot --fstype=xfs --size=312\npart /boot/efi --fstype=efi --size=200",
            ).replace(
                "part biosboot ",
                "# part biosboot ",
            )

        if data.install_gui:
            gui_group = "\n%packages\n@^graphical-server-environment\n"
            if data.distro == "fedora":
                gui_group = "\n%packages\n@^Fedora Workstation\n"
            content = content.replace("\n%packages\n", gui_group)

        outfile.write(content)
    data.kickstart = tmp_kickstart


def handle_rest(data):
    if not data.network:
        if data.libvirt == "qemu:///system":
            data.network = "network=default"
        else:
            data.network = "bridge=virbr0"
    if data.console:
        data.wait_opt = 0
    else:
        data.wait_opt = -1


def join_extented_opt(opt_name, delim, opts):
    if opts:
        return [f'{opt_name}={delim.join(opts)}']
    return []


def get_virt_install_command(data):
    command = [
        'virt-install',
        f'--connect={data.libvirt}',
        f'--name={data.domain}',
        f'--memory={data.ram}',
        f'--vcpus={data.cpu}',
        f'--network={data.network}',
        f'--disk={data.disk_spec}',
        f'--initrd-inject={data.kickstart}',
        '--serial=pty',
        '--noautoconsole',
        '--rng=/dev/random',
        f'--wait={data.wait_opt}',
        f'--location={data.url}',
    ]

    boot_opts = []

    extra_args_opts = [
        f'inst.ks=file:/{data.ks_basename}',
        'inst.ks.device=eth0',
        # The kernel option "net.ifnames=0" is used to disable predictable network interface
        # names. For more details see:
        # https://www.freedesktop.org/wiki/Software/systemd/PredictableNetworkInterfaceNames/
        'net.ifnames=0',
        'console=ttyS0,115200',
    ]

    features_opts = []

    if data.install_gui:
        command.append("--graphics=vnc")
        extra_args_opts.append("inst.graphical")
    else:
        command.append("--graphics=none")
        extra_args_opts.append("inst.cmdline")

    if data.uefi:
        boot_opts.append("uefi")
        if data.uefi == "secureboot":
            boot_opts.extend([
                "loader.secure=yes",
            ])
            features_opts.append("smm=on")
        else:
            boot_opts.append("loader.secure=no")

    if data.osinfo:
        command.append(f'--osinfo={data.osinfo}')
    else:
        if data.distro in UNRELEASED_DISTROS_AND_OSINFO.keys():
            command.append("--osinfo={}".format(
                UNRELEASED_DISTROS_AND_OSINFO.get(data.distro, "rhel9-unknown")))

    command.extend(join_extented_opt("--boot", ",", boot_opts))
    command.extend(join_extented_opt("--extra-args", " ", extra_args_opts))
    command.extend(join_extented_opt("--features", ",", features_opts))

    return command


def run_virt_install(data, command):
    print("\nThis is the resulting command for the VM installation:")
    print(shlex.join(command))

    if data.dry:
        return

    subprocess.call(command)
    if data.console:
        subprocess.call(["unbuffer", "virsh", "console", data.domain])
        wait_vm_not_running(data.domain)
        subprocess.call(["virsh", "start", data.domain])

    give_info(data)


def give_info(data):
    if data.libvirt == "qemu:///system":
        ip_cmd = f'sudo virsh domifaddr {data.domain}'
    else:
        # command evaluation in fish shell is simply surrounded by
        # parenthesis for example: (echo foo). In other shells you
        # need to prepend the $ symbol as: $(echo foo)
        from os import environ

        cmd_eval = "" if environ["SHELL"][-4:] == "fish" else "$"

        ip_cmd = f"arp -n | grep {cmd_eval}(virsh -q domiflist {data.domain} | awk '{{print $5}}')"

    print(f"""
To determine the IP address of the {data.domain} VM use:
  {ip_cmd}

To connect to the {data.domain} VM use:
  ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@IP

To connect to the VM serial console, use:
  virsh console {data.domain}""")

    if data.ssh_pubkey_used:
        print(f"""
Add:
  -o IdentityFile={data.ssh_pubkey}

option to your ssh command and export the:
  export SSH_ADDITIONAL_OPTIONS='-o IdentityFile={data.ssh_pubkey}'

before running the Automatus.""")

        if data.libvirt == "qemu:///system":
            print("""
IMPORTANT: When running Automatus use:
  sudo -E
to make sure that your SSH key is used.""")


def main():
    data = parse_args()

    if not data.url or not data.extra_repo:
        try_known_urls(data)

    handle_ssh_pubkey(data)
    handle_disk(data)
    handle_kickstart(data)

    print(f'Using SSH public key from file: {data.ssh_pubkey}')
    print(f'Using hypervisor: {data.libvirt}')
    print(f'Using kickstart file: {data.kickstart}')

    handle_rest(data)
    command = get_virt_install_command(data)
    run_virt_install(data, command)


if __name__ == "__main__":
    main()
