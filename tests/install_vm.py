#!/usr/bin/python
import argparse
import os

def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "--distro",
        dest="distro",
        default="fedora",
        choices=("fedora", "centos7"),
        help="What type of distribution to install"
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
        default="/var/lib/libvirt/images/",
        help="Location of the VM qcow file."
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
        "--dry",
        dest="dry",
        action="store_true",
        help="Print command line instead of triggering command."
    )

    return parser.parse_args()

def main():
    data = parse_args()
    data.kickstart = "https://raw.githubusercontent.com/ComplianceAsCode/content/master/tests/kickstarts/rhel_centos_7.cfg"
    data.disk_path = os.path.join(data.disk_dir, data.domain) + ".qcow"

    if data.distro == "fedora":
        data.variant = "fedora27" # this is for support in RHEL7, where fedora28 is not known yet
        data.url = "https://download.fedoraproject.org/pub/fedora/linux/releases/28/Everything/x86_64/os"
    elif data.distro == "centos7":
        data.variant = "centos7"
        data.url = "http://mirror.centos.org/centos/7/os/x86_64"

    command = 'virt-install -n {domain} -r {ram} --vcpus={cpu} --os-variant={variant} --accelerate --disk path={disk_path},size=12 -x "inst.ks={kickstart}" --location {url}'.format(**data.__dict__)
    if data.dry:
        print(command)
    else:
        os.system(command)

if __name__ == '__main__':
    main()
