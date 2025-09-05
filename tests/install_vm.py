#!/usr/bin/env python2

import argparse
import os
import sys
import subprocess


def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "--libvirt",
        dest="libvirt",
        default="qemu:///session",
        help="What hypervisor should be used when installing VM."
    )
    parser.add_argument(
        "--kickstart",
        dest="kickstart",
        default="kickstarts/test_suite.cfg",
        help="Path to a kickstart file for installation of a VM."
    )
    parser.add_argument(
        "--distro",
        dest="distro",
        required=True,
        choices=['fedora', 'rhel7', 'centos7', 'rhel8'],
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
        help="Location of the VM qcow2 file."
    )
    parser.add_argument(
        "--ram",
        dest="ram",
        default=2048,
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
        "--disk",
        dest="disk",
        help="Disk type/spec, ie. pool=MyPool,bus=sata,cache=unsafe."
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

    return parser.parse_args()


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
            data.url = "https://download.fedoraproject.org/pub/fedora/linux/releases/31/Everything/x86_64/os"
        elif data.distro == "centos7":
            data.url = "http://mirror.centos.org/centos/7/os/x86_64"
    if not data.url:
        sys.stderr.write("For the '{}' distro the `--url` option needs to be provided.\n".format(data.distro))
        return 1

    if not data.ssh_pubkey:
        data.ssh_pubkey = home_dir + "/.ssh/id_rsa.pub"
    if not os.path.isfile(data.ssh_pubkey):
        sys.stderr.write("Error: SSH public key not found at {0}\n".format(data.ssh_pubkey))
        sys.stderr.write("You can use the `--ssh-pubkey` to specify which key should be used.\n")
        return 1
    with open(data.ssh_pubkey) as f:
        pub_key = f.readline().rstrip()
    print("Using SSH public key from file: {0}".format(data.ssh_pubkey))
    print("Using hypervisor: {0}".format(data.libvirt))

    if data.disk:
        data.disk_spec = data.disk
    elif data.disk_dir:
        disk_path = os.path.join(data.disk_dir, data.domain) + ".qcow2"
        print("Location of VM disk: {0}".format(disk_path))
        data.disk_spec = "path={0},format=qcow2,size=20".format(disk_path)
    else:
        data.disk_spec = "size=20,format=qcow2"

    data.ks_basename = os.path.basename(data.kickstart)

    tmp_kickstart = "/tmp/" + data.ks_basename
    with open(data.kickstart) as infile, open(tmp_kickstart, "w") as outfile:
        content = infile.read()
        content = content.replace("&&HOST_PUBLIC_KEY&&", pub_key)
        if not data.distro == "fedora":
            content = content.replace("&&YUM_REPO_URL&&", data.url)
        if data.extra_repo:
            # extra repository
            repo_cmd = "repo --name=extra-repository --baseurl={}".format(data.extra_repo)
            content = content.replace("&&YUM_EXTRA_REPO&&", repo_cmd)
            content = content.replace("&&YUM_EXTRA_REPO_URL&&", data.extra_repo)
        else:
            content = content.replace("&&YUM_EXTRA_REPO&&", "")
        if data.uefi:
            content = content.replace(
                "part /boot --fstype=xfs --size=512",
                "part /boot --fstype=xfs --size=312\npart /boot/efi --fstype=efi --size=200"
            )
        outfile.write(content)
    data.kickstart = tmp_kickstart
    print("Using kickstart file: {0}".format(data.kickstart))

    if not data.network:
        if data.libvirt == "qemu:///system":
            data.network = "network=default"
        else:
            data.network = "bridge=virbr0"

    # The kernel option 'net.ifnames=0' is used to disable predictable network
    # interface names, for more details see:
    # https://www.freedesktop.org/wiki/Software/systemd/PredictableNetworkInterfaceNames/
    command = 'virt-install --connect={libvirt} --name={domain} --memory={ram} --vcpus={cpu} --network {network} --disk {disk_spec} --initrd-inject={kickstart} --extra-args="inst.ks=file:/{ks_basename} ksdevice=eth0 net.ifnames=0 console=ttyS0,115200" --serial pty --graphics=none --noautoconsole --rng /dev/random --wait=-1 --location={url}'.format(**data.__dict__)
    if data.uefi == "normal":
        command = command+" --boot uefi"
    if data.uefi == "secureboot":
        command = command + " --boot uefi,loader_secure=yes,\
loader=/usr/share/edk2/ovmf/OVMF_CODE.secboot.fd,\
nvram_template=/usr/share/edk2/ovmf/OVMF_VARS.secboot.fd --features smm=on"

    if data.dry:
        print("\nThe following command would be used for the VM installation:")
        print(command)
    else:
        os.system(command)

    print("\nTo determine the IP address of the {0} VM use:".format(data.domain))
    if data.libvirt == "qemu:///system":
        print("  sudo virsh domifaddr {0}\n".format(data.domain))
    else:
        # command evaluation in fish shell is simply surrounded by
        # parenthesis for example: (echo foo). In other shells you
        # need to prepend the $ symbol as: $(echo foo)
        from os import environ
        print("  arp -n | grep {0}(virsh -q domiflist {1} | awk '{{print $5}}')\n".format('' if 'fish' == environ['SHELL'][-4:] else '$', data.domain))

    print("To connect to the {0} VM use:\n  ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@IP\n".format(data.domain))
    print("To connect to the VM serial console, use:\n  virsh console {0}\n".format(data.domain))
    print("If you have used the `--ssh-pubkey` also add '-o IdentityFile=PATH_TO_PRIVATE_KEY' option to your ssh command and export the SSH_ADDITIONAL_OPTIONS='-o IdentityFile=PATH_TO_PRIVATE_KEY' before running the SSG Test Suite.")

    if data.libvirt == "qemu:///system":
        print("\nIMPORTANT: When running SSG Test Suite use `sudo -E` to make sure that your SSH key is used.")


if __name__ == '__main__':
    main()
