chmod 660 /dev/audio* /dev/snd/*
sed -i '/[audio|snd]/s/MODE="[0-9]*"/MODE="660"/' /etc/udev/rules.d/50-udev.rules