# platform = multi_platform_all
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

# Comment out the network drivers (network, syslog, tcp, tcp6, udp, udp6) of source
# blocks. Network drivers in destination blocks send messages and are left alone.
# A driver that spans several lines is commented out entirely, and a driver that
# shares its line with other statements is moved to a line of its own first.
read -r -d '' sng_nolisten_awk << 'AWK' || true
function skip_string(pos,    q, d) {
    q = substr(s, pos, 1)
    pos++
    while (pos <= n) {
        d = substr(s, pos, 1)
        if (q == "\"" && d == "\\") { pos += 2; continue }
        if (d == q) return pos
        pos++
    }
    return n
}
function skip_comment(pos) {
    while (pos <= n && substr(s, pos, 1) != "\n") pos++
    return pos - 1
}
function closing_paren(pos,    p, d) {
    p = 0
    while (pos <= n) {
        d = substr(s, pos, 1)
        if (d == "\"" || d == "'") pos = skip_string(pos)
        else if (d == "#") pos = skip_comment(pos)
        else if (d == "(") p++
        else if (d == ")") { p--; if (p == 0) return pos }
        pos++
    }
    return 0
}
{ s = s $0 "\n" }
END {
    n = length(s); out = ""; depth = 0; src = -1; next_is_source = 0; changed = 0
    i = 1
    while (i <= n) {
        c = substr(s, i, 1)
        if (c == "\"" || c == "'") { j = skip_string(i); out = out substr(s, i, j - i + 1); i = j + 1; continue }
        if (c == "#") { j = skip_comment(i); out = out substr(s, i, j - i + 1); i = j + 1; continue }
        if (c == "{") {
            depth++
            if (next_is_source && depth == 1) src = 1
            next_is_source = 0
            out = out c; i++; continue
        }
        if (c == "}") { if (depth == src) src = -1; depth--; out = out c; i++; continue }
        if (c ~ /[A-Za-z0-9_.-]/) {
            j = i
            while (j <= n && substr(s, j, 1) ~ /[A-Za-z0-9_.-]/) j++
            w = substr(s, i, j - i)
            if (depth == 0) next_is_source = (w == "source") || (next_is_source && w != "")
            if (depth == src && w ~ /^(network|syslog|tcp|tcp6|udp|udp6)$/) {
                k = j
                while (k <= n && substr(s, k, 1) ~ /[ \t\n]/) k++
                if (substr(s, k, 1) == "(" && (e = closing_paren(k)) > 0) {
                    k = e + 1
                    while (k <= n && substr(s, k, 1) ~ /[ \t]/) k++
                    if (substr(s, k, 1) == ";") e = k
                    span = substr(s, i, e - i + 1)
                    gsub(/\n/, "\n# ", span)
                    match(out, /[^\n]*$/)
                    if (substr(out, RSTART) ~ /^[ \t]*$/) {
                        out = substr(out, 1, RSTART - 1) "# " substr(out, RSTART) span
                    } else {
                        out = out "\n# " span
                    }
                    k = e + 1
                    while (k <= n && substr(s, k, 1) ~ /[ \t]/) k++
                    if (k <= n && substr(s, k, 1) != "\n") out = out "\n"
                    i = e + 1; changed = 1; continue
                }
            }
            out = out w; i = j; continue
        }
        if (depth == 0 && c !~ /[ \t\n]/) next_is_source = 0
        out = out c; i++
    }
    printf "%s", out
    exit (changed ? 0 : 1)
}
AWK

declare -A sng_nolisten_backup
for target in /etc/syslog-ng/syslog-ng.conf /etc/syslog-ng/conf.d/*.conf; do
    [ -f "$target" ] || continue
    case "$(basename "$target")" in .*) continue ;; esac
    if new_content=$(awk "$sng_nolisten_awk" "$target"); then
        sng_nolisten_backup["$target"]=$(cat "$target"; printf x)
        printf '%s\n' "$new_content" > "$target"
    fi
done

if [ ${#sng_nolisten_backup[@]} -gt 0 ]; then
    if command -v syslog-ng > /dev/null && ! syslog-ng --syntax-only; then
        # Keep the previous, valid configuration if the result does not parse.
        for target in "${!sng_nolisten_backup[@]}"; do
            printf '%s' "${sng_nolisten_backup[$target]%x}" > "$target"
        done
        echo "syslog-ng configuration not valid after commenting out network source drivers; changes reverted" >&2
        exit 1
    fi
    systemctl restart syslog-ng.service
fi
