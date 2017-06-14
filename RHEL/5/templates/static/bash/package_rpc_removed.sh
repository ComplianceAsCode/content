# platform = Red Hat Enterprise Linux 5
yum -y remove portmap rpcbind --disablerepo=* 1>/dev/null
