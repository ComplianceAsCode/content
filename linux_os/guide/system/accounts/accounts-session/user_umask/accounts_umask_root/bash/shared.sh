# platform = multi_platform_all

for file in /root/.bashrc /root/.profile; do
    if [ -f "$file" ]; then
        sed -i -E -e "s/^([^#]*\bumask)[[:space:]]+[[:digit:]]+/\1 0027/g" "$file"
    fi
done
