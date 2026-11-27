# platform = multi_platform_ubuntu
# reboot = false
# strategy = restrict
# complexity = low
# disruption = high

while IFS= read -r -d '' file; do
    sed -ri '/^[[:space:]]*deb(-src)?[[:space:]]+(\[[^]]*\][[:space:]]+)?http:\/\// s#http://#https://#' "$file"
done < <(find /etc/apt/sources.list.d -maxdepth 1 -type f -name '*.list' -print0 2>/dev/null)

{{{ bash_apt_filter_file() }}}

for file in /etc/apt/sources.list.d/*.sources; do
    [[ -f "$file" && ${file##*/} =~ ^[A-Za-z0-9_-][A-Za-z0-9_.-]*\.sources$ ]] || continue
    apt_filter_file "$file" perl -0777 -pe '
        # Enabled can occur anywhere in a stanza, including after URIs.
        sub fix_stanza {
            my ($stanza) = @_;
            return $stanza if $stanza =~ m{ {{{ apt_deb822_disabled_pattern() }}} }x;
            my @lines = split /^/m, $stanza;
            my $uris;
            for (@lines) {
                next if /^#/;
                $uris = /^(?i:URIs)[^\S\r\n]*:/ unless /^[ \t]/;
                s{(?:^(?i:URIs)[^\S\r\n]*:|[ \t])\Khttp://}{https://}g if $uris;
            }
            return join("", @lines);
        }
        s{^[^\r\n]+(?:\r?\n[^\r\n]+)*}{fix_stanza($&)}gme;
    ' || exit 1
done
