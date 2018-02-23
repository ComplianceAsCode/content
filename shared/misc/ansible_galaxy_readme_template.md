@TITLE@
=========

@DESCRIPTION@

Requirements
------------

- Ansible version @MIN_ANSIBLE_VERSION@ or higher

Role Variables
--------------

To customize the role to your liking, check out the [list of variables](vars/main.yml).

Dependencies
------------

N/A

Example Playbook
----------------

Run `ansible-galaxy install Ansible-Security-Compliance.@ROLE_NAME@` to
download and install the role. Then you can use the following playbook snippet.


    - hosts: all
      roles:
         - { role: Ansible-Security-Compliance.@ROLE_NAME@ }


Then first check the playbook using (on the localhost):

    ansible-playbook -i "localhost," -c local --check playbook.yml

To deploy it, use (this may change configuration of your local machine!):

    ansible-playbook -i "localhost," -c local playbook.yml


License
-------

BSD-3-Clause

Author Information
------------------

This Ansible remediation role has been generated from the body of security policies developed by the SCAP Security Guide project. Please see https://github.com/OpenSCAP/scap-security-guide/blob/master/Contributors.md for an updated list of authors and contributors.
