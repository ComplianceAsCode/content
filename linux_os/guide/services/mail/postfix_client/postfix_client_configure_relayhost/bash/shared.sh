# platform = multi_platform_all
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

{{{ bash_instantiate_variables("var_postfix_relayhost") }}}

{{{ set_config_file(path="/etc/postfix/main.cf", parameter="relayhost", value="$var_postfix_relayhost", create=true, insensitive=false, separator=" = ", separator_regex="\s*=\s*", prefix_regex="^", rule_id=rule_id) }}}
