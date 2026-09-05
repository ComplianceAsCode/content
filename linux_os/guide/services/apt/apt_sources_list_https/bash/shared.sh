# platform = multi_platform_ubuntu
# reboot = false
# strategy = restrict
# complexity = low
# disruption = medium

if [[ -f /etc/apt/sources.list ]]; then
    sed -ri '/^[[:space:]]*deb(-src)?[[:space:]]+(\[[^]]*\][[:space:]]+)?http:\/\// s#http://#https://#' /etc/apt/sources.list
fi
