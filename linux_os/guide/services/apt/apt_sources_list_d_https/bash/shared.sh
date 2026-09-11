# platform = multi_platform_ubuntu
# reboot = false
# strategy = restrict
# complexity = low
# disruption = high

while IFS= read -r -d '' file; do
    sed -ri '/^[[:space:]]*deb(-src)?[[:space:]]+(\[[^]]*\][[:space:]]+)?http:\/\// s#http://#https://#' "$file"
done < <(find /etc/apt/sources.list.d -maxdepth 1 -type f -name '*.list' -print0 2>/dev/null)

while IFS= read -r -d '' file; do
    sed -ri '/^[[:space:]]*URIs:[[:space:]]/I s#http://#https://#g' "$file"
done < <(find /etc/apt/sources.list.d -maxdepth 1 -type f -name '*.sources' -print0 2>/dev/null)
