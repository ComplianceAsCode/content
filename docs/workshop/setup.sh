#!/bin/bash
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -vvv -i $1, system_setup.yml labs_setup.yml -k -K -u $2 -e student_name=lab-user --ssh-extra-args "-F data/ssh_config"
