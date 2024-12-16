# platform = multi_platform_ubuntu
#!/bin/bash

{{{ bash_package_install("aide") }}}

systemctl unmask dailyaidecheck.service
systemctl unmask dailyaidecheck.timer
systemctl --now enable dailyaidecheck.timer
