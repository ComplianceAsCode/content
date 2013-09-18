source ./templates/support.sh
populate var_password_min_len

grep -q ^PASS_MIN_LEN /etc/login.defs && \
  sed -i "s/PASS_MIN_LEN.*/PASS_MIN_LEN     $var_password_min_len/g" /etc/login.defs
if ! [ $? -eq 0 ]; then
    echo "PASS_MIN_LEN      $var_password_min_len" >> /etc/login.defs
fi
