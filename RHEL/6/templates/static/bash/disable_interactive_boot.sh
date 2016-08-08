# platform = Red Hat Enterprise Linux 6

# Ensure value of PROMPT key in /etc/sysconfig/init is set to 'no'
grep -q ^PROMPT /etc/sysconfig/init && \
  sed -i "s/PROMPT.*/PROMPT=no/g" /etc/sysconfig/init
if ! [ $? -eq 0 ]; then
    echo "PROMPT=no" >> /etc/sysconfig/init
fi

# Ensure 'confirm' kernel boot argument is not present in some of
# kernel lines in /etc/grub.conf
sed -i --follow-symlinks "s/confirm//gI" /etc/grub.conf
