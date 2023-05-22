#!/usr/bin/python3

import argparse
import os
import shlex
import subprocess
import sys
import time


def path_from_tests(path):
    return os.path.relpath(os.path.join(os.path.dirname(__file__), path))


def parse_args():
    parser = argparse.ArgumentParser(
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )

    parser.add_argument(
        "--libvirt",
        dest="libvirt",
        default="qemu:///session",
        help="What hypervisor should be used when installing VM."
    )
    parser.add_argument(
        "--kickstart",
        dest="kickstart",
        default=path_from_tests("kickstarts/test_suite.cfg"),
        help="Path to a kickstart file for installation of a VM."
    )
    parser.add_argument(
        "--distro",
        dest="distro",
        required=True,
        choices=['fedora', 'rhel7', 'centos7', 'centos8', 'centos9', 'rhel8', 'rhel9'],
        help="What distribution to install."
    )
    parser.add_argument(
        "--domain",
        dest="domain",
        required=True,
        help="What name should the new domain have."
    )
    parser.add_argument(
        "--disk-dir",
        dest="disk_dir",
        default=None,
        help="Location of the VM qcow2 disk file (ignored when --disk is specified)."
    )
    parser.add_argument(
        "--disk-size",
        dest="disk_size",
        default=20,
        help="Size of the VM qcow2 disk, default is 20 GiB (ignored when --disk is specified)."
    )
    parser.add_argument(
        "--disk",
        dest="disk",
        help="Full disk type/spec, ie. pool=MyPool,bus=sata,cache=unsafe."
    )
    parser.add_argument(
        "--ram",
        dest="ram",
        default=3072,
        type=int,
        help="Amount of RAM configured for the VM."
    )
    parser.add_argument(
        "--cpu",
        dest="cpu",
        default=2,
        type=int,
        help="Number of CPU cores configured for the VM."
    )
    parser.add_argument(
        "--network",
        dest="network",
        help="Network type/spec, ie. bridge=br0 or network=name."
    )
    parser.add_argument(
        "--url",
        dest="url",
        default=None,
        help="URL to an installation tree on a remote server."
    )
    parser.add_argument(
        "--extra-repo",
        dest="extra_repo",
        default=None,
        help="URL to an extra repository to be used during installation (e.g. AppStream)."
    )
    parser.add_argument(
        "--dry",
        dest="dry",
        action="store_true",
        help="Print command line instead of triggering command."
    )
    parser.add_argument(
        "--ssh-pubkey",
        dest="ssh_pubkey",
        default=None,
        help="Path to an SSH public key which will be used to access the VM."
    )
    parser.add_argument(
        "--uefi",
        dest="uefi",
        choices=['secureboot', 'normal'],
        help="Perform UEFI based installation, optionally with secure boot support."
    )
    parser.add_argument(
        "--install-gui",
        dest="install_gui",
        action='store_true',
        help="Perform a GUI installation (default is installation without GUI)."
    )
    parser.add_argument(
        "--console",
        dest="console",
        action='store_true',
        help="Connect to a serial console of the VM (to monitor installation progress)."
    )
    parser.add_argument(
        "--disk-unsafe",
        dest="disk_unsafe",
        action='store_true',
        help="Set cache unsafe.",
    )

    return parser.parse_args()


def wait_vm_not_running(domain):
    timeout = 300

    print("Waiting for {0} VM to shutdown (max. {1}s)".format(domain, timeout))
    end_time = time.time() + timeout
    try:
        while True:
            time.sleep(5)
            cmd = ["virsh", "domstate", domain]
            if subprocess.getoutput(cmd).rstrip() != "running":
                return
            if time.time() >= end_time:
                print("Timeout reached: {0} VM failed to shutdown, cancelling wait."
                      .format(domain))
                return
    except KeyboardInterrupt:
        print("Interrupted, cancelling wait.")
        return


def err(rc, msg):
    print(msg, file=sys.stderr)
    sys.exit(rc)


def main():
    data = parse_args()
    username = ""
    try:
        username = os.environ["SUDO_USER"]
    except KeyError:
        pass
    home_dir = os.path.expanduser('~' + username)

    if not data.url:
        if data.distro == "fedora":
            data.url = "https://download.fedoraproject.org/pub/fedora/linux/releases/38/Everything/x86_64/os"
        elif data.distro == "centos7":
            data.url = "http://mirror.centos.org/centos/7/os/x86_64"
        elif data.distro == "centos8":
            data.url = "http://mirror.centos.org/centos/8-stream/BaseOS/x86_64/os/"
            data.extra_repo = "http://mirror.centos.org/centos/8-stream/AppStream/x86_64/os/"
        elif data.distro == "centos9":
            data.url = "http://mirror.stream.centos.org/9-stream/BaseOS/x86_64/os/"
            data.extra_repo = "http://mirror.stream.centos.org/9-stream/AppStream/x86_64/os/"

    if not data.url:
        err(1, "For the '{0}' distro the `--url` option needs to be provided.".format(data.distro))

    data.ssh_pubkey_used = bool(data.ssh_pubkey)
    if not data.ssh_pubkey:
        data.ssh_pubkey = home_dir + "/.ssh/id_rsa.pub"

    if not os.path.isfile(data.ssh_pubkey):
        err(1, """Error: SSH public key not found at {0}
You can use the `--ssh-pubkey` to specify which key should be used.""".format(data.ssh_pubkey))

    with open(data.ssh_pubkey) as f:
        pub_key = f.readline().rstrip()
    print("Using SSH public key from file: {0}".format(data.ssh_pubkey))
    print("Using hypervisor: {0}".format(data.libvirt))

    disk_spec = [
        "size={0}".format(data.disk_size),
        "format=qcow2"
    ]
    if data.disk:
        disk_spec.extend(data.disk.split(","))
    elif data.disk_dir:
        disk_path = os.path.join(data.disk_dir, data.domain) + ".qcow2"
        print("Location of VM disk: {0}".format(disk_path))
        disk_spec.append("path={0}".format(disk_path))
    if data.disk_unsafe:
        disk_spec.append("cache=unsafe")
    data.disk_spec = ",".join(disk_spec)

    data.ks_basename = os.path.basename(data.kickstart)

    tmp_kickstart = "/tmp/" + data.ks_basename
    with open(data.kickstart) as infile, open(tmp_kickstart, "w") as outfile:
        content = infile.read()
        content = content.replace("&&HOST_PUBLIC_KEY&&", pub_key)
        if not data.distro == "fedora":
            content = content.replace("&&YUM_REPO_URL&&", data.url)
        if data.extra_repo:
            # extra repository
            repo_cmd = "repo --name=extra-repository --baseurl={0}".format(data.extra_repo)
            content = content.replace("&&YUM_EXTRA_REPO&&", repo_cmd)
            content = content.replace("&&YUM_EXTRA_REPO_URL&&", data.extra_repo)
        else:
            content = content.replace("&&YUM_EXTRA_REPO&&", "")
        if data.uefi:
            content = content.replace(
                "part /boot --fstype=xfs --size=512",
                "part /boot --fstype=xfs --size=312\npart /boot/efi --fstype=efi --size=200"
            ).replace(
                "part biosboot ",
                "# part biosboot "
            )

        if data.install_gui:
            gui_group = "\n%packages\n@^graphical-server-environment\n"
            if data.distro == "fedora":
                gui_group = "\n%packages\n@^Fedora Workstation\n"
            content = content.replace("\n%packages\n", gui_group)
            data.graphics_opt = "vnc"
            data.inst_opt = "inst.graphical"
        else:
            data.graphics_opt = "none"
            data.inst_opt = "inst.cmdline"
        outfile.write(content)
    data.kickstart = tmp_kickstart
    print("Using kickstart file: {0}".format(data.kickstart))

    if not data.network:
        if data.libvirt == "qemu:///system":
            data.network = "network=default"
        else:
            data.network = "bridge=virbr0"
    if data.console:
        data.wait_opt = 0
    else:
        data.wait_opt = -1

    command = [
        "virt-install",
        "--connect={0}".format(data.libvirt),
        "--name={0}".format(data.domain),
        "--memory={0}".format(data.ram),
        "--vcpus={0}".format(data.cpu),
        "--network={0}".format(data.network),
        "--disk={0}".format(data.disk_spec),
        "--initrd-inject={0}".format(data.kickstart),
        "--serial=pty",
        "--graphics={0}".format(data.graphics_opt),
        "--noautoconsole",
        "--rng=/dev/random",
        "--wait={0}".format(data.wait_opt),
        "--location={0}".format(data.url),
    ]

    boot_opts = []

    extra_args_opts = [
        "inst.ks=file:/{0}".format(data.ks_basename),
        "{0}".format(data.inst_opt),
        "inst.ks.device=eth0",
        # The kernel option "net.ifnames=0" is used to disable predictable network
        # interface names, for more details see:
        # https://www.freedesktop.org/wiki/Software/systemd/PredictableNetworkInterfaceNames/
        "net.ifnames=0",
        "console=ttyS0,115200",
    ]

    features_opts = []

    if data.uefi:
        boot_opts.append("uefi")
        if data.uefi == "secureboot":
            boot_opts.extend([
                "loader_secure=yes",
                "loader=/usr/share/edk2/ovmf/OVMF_CODE.secboot.fd",
                "nvram_template=/usr/share/edk2/ovmf/OVMF_VARS.secboot.fd"
            ])
            features_opts.append("smm=on")

    if boot_opts:
        command.append("--boot={0}".format(",".join(boot_opts)))
    if extra_args_opts:
        command.append("--extra-args={0}".format(" ".join(extra_args_opts)))
    if features_opts:
        command.append("--features={0}".format(",".join(features_opts)))

    if data.dry:
        print("\nThe following command would be used for the VM installation:")
        print(shlex.join(command))
    else:
        subprocess.call(command)
        if data.console:
            subprocess.call(["unbuffer", "virsh", "console", data.domain])
            wait_vm_not_running(data.domain)
            subprocess.call(["virsh", "start", data.domain])

    if data.libvirt == "qemu:///system":
        ip_cmd = "sudo virsh domifaddr {0}".format(data.domain)
    else:
        # command evaluation in fish shell is simply surrounded by
        # parenthesis for example: (echo foo). In other shells you
        # need to prepend the $ symbol as: $(echo foo)
        from os import environ
        cmd_eval = "" if "fish" == environ["SHELL"][-4:] else "$"

        ip_cmd = "arp -n | grep {0}(virsh -q domiflist {1} | awk '{{print $5}}')".format(
            cmd_eval, data.domain)

    print("""
To determine the IP address of the {domain} VM use:
  {ip_cmd}

To connect to the {domain} VM use:
  ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@IP

To connect to the VM serial console, use:
  virsh console {domain}""".format(** data.__dict__, ip_cmd=ip_cmd))

    if data.ssh_pubkey_used:
        print("""
Add:
  -o IdentityFile={ssh_pubkey}

option to your ssh command and export the:
  export SSH_ADDITIONAL_OPTIONS='-o IdentityFile={ssh_pubkey}'

before running the SSG Test Suite.""".format(** data.__dict__))

        if data.libvirt == "qemu:///system":
            print("""
IMPORTANT: When running SSG Test Suite use:
  sudo -E
to make sure that your SSH key is used.""")


if __name__ == '__main__':
    main()
