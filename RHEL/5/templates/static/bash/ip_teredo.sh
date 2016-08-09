ps ax | grep -i miredo | grep -v grep | awk ' { print $1 }' | xargs kill
