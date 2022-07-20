#!/bin/bash
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -vvv -i $1, labs_setup.yml -k -K -u $2 --ssh-extra-args "-F data/ssh_config"
