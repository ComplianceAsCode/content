source ./templates/support.sh
populate var_password_min_age

grep -q ^PASS_MIN_AGE /etc/login.defs && \
  sed -i "s/PASS_MIN_AGE.*/PASS_MIN_AGE     $var_password_min_age/g" /etc/login.defs
if ! [ $? -eq 0 ]; then
    echo "PASS_MIN_AGE      $var_password_min_age"
fi
