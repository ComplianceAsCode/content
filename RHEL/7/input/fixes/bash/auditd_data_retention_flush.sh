source ./templates/support.sh
populate var_auditd_flush

# if flush is present, flush param edited to var_auditd_flush
# else flush param is defined by var_auditd_flush
#
# the freq param is disabled if var_auditd_flush isn't incremental

grep -q ^flush /etc/audit/auditd.conf && \
  sed -i 's/^flush.*/flush = '"$var_auditd_flush"'/g' /etc/audit/auditd.conf
if ! [ $? -eq 0 ]; then
  echo "flush = $var_auditd_flush" >> /etc/audit/auditd.conf
fi

if ! [ "$var_auditd_flush" == "incremental" ]; then
  sed -i 's/^freq/##freq/g' /etc/audit/auditd.conf
fi
