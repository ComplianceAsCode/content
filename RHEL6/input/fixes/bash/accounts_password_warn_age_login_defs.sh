source ./templates/support.sh
populate var_password_warn_age

grep -q ^PASS_WARN_DAYS /etc/login.defs && \
  sed -i "s/PASS_WARN_DAYS.*/PASS_WARN_DAYS     $var_password_warn_age/g" /etc/login.defs
if ! [ $? -eq 0 ]; then
    echo "PASS_WARN_DAYS      $var_password_warn_age" >> /etc/login.defs
fi
