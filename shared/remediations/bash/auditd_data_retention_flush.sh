# platform = multi_platform_rhel
. /usr/share/scap-security-guide/remediation_functions
populate var_auditd_flush

AUDITCONFIG=/etc/audit/auditd.conf

# if flush is present, flush param edited to var_auditd_flush
# else flush param is defined by var_auditd_flush
#
# the freq param is only used value 'incremental' and will be
# commented out if flush != incremental
#
# if flush == incremental && freq param is not defined, it 
# will be defined as the package-default value of 20

grep -q ^flush $AUDITCONFIG && \
  sed -i 's/^flush.*/flush = '"$var_auditd_flush"'/g' $AUDITCONFIG
if ! [ $? -eq 0 ]; then
  echo "flush = $var_auditd_flush" >> $AUDITCONFIG
fi

if ! [ "$var_auditd_flush" == "incremental" ]; then
  sed -i 's/^freq/##freq/g' $AUDITCONFIG
elif [ "$var_auditd_flush" == "incremental" ]; then
  grep -q freq $AUDITCONFIG && \
    sed -i 's/^#\+freq/freq/g' $AUDITCONFIG
  if ! [ $? -eq 0 ]; then
    echo "freq = 20" >> $AUDITCONFIG
  fi
fi
