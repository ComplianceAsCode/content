grep -q ^PROMPT /etc/sysconfig/init && \
  sed -i "s/PROMPT.*/PROMPT=no/g" /etc/sysconfig/init
if ! [ $? -eq 0 ]; then
    echo "PROMPT=no" >> /etc/sysconfig/init
fi
