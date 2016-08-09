grep -q :S: /etc/inittab && \
  sed -i "s/.*:S:.*/~:S:wait:\/sbin\/sulogin/g" /etc/inittab
if ! [ $? -eq 0 ]; then
    echo "~:S:wait:/sbin/sulogin" >> /etc/inittab
fi
