WWWSTARTFILE=$( for FILE in `egrep -r "/" /etc/rc.* /etc/init.d|awk '/^.*[^\/][0-9A-Za-z_\/]*/{print $2}'|egrep "^/"|sort|uniq`; do if [ -e $FILE ]; then stat -L -c '%a:%n' $FILE | egrep "^[0-7]{2,3}[2367]:" | cut -d ":" -f 2 ; fi; done )

#Start-Lockdown

for file in $WWWSTARTFILE; do
    chmod o-w $file
done
