
listening_ports() {
    protocol=$1

    # list all listending ports
    listening_ports=()
    IFS=' ' read -r -a listening_v4_ports <<< "$(ss -H4${protocol}ln |grep -vP '127.0.0.1' |grep -oP '[\.\d]+\:\d+'|awk -F ":" '{print $NF}')"
    IFS=' ' read -r -a listening_v6_ports <<<"$(ss -H6${protocol}ln |grep -vP '::1' |grep -oP '\[[\:\d]+\]+\:\d+'|awk -F ":" '{print $NF}')"
    listening_ports=(${listening_v6_ports[@]}  ${listening_v4_ports[@]})
    # only unique ports
    listening_ports=($(for port in "${listening_ports[@]}"; do echo $port; done|sort -u))
    echo "${listening_ports[@]}"
}

get_default_firewalld_zone_cfg() {
    zone_name=$(grep -rIn DefaultZone /etc/firewalld/firewalld.conf|awk -F '=' '{print $2}')
    echo "/etc/firewalld/zones/${zone_name}.xml"
}

zone_cfg_begin() {
    echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<zone>
  <short>Public</short>
  <description>For use in public areas. You do not trust the other computers on networks to not harm your computer. Only selected incoming connections are accepted.</description>
"
}

zone_cfg_end() {
    echo "
  <interface name=\"eth0\"/>
  <interface name=\"eth1\"/>
</zone>"
}
