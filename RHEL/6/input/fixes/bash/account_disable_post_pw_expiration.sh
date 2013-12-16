source ./templates/support.sh
populate var_account_disable_post_pw_expiration

grep -q ^INACTIVE /etc/default/useradd && \
  sed -i "s/INACTIVE.*/INACTIVE=$var_account_disable_post_pw_expiration/g" /etc/default/useradd
if ! [ $? -eq 0 ]; then
    echo "INACTIVE=$var_account_disable_post_pw_expiration" >> /etc/default/useradd
fi
