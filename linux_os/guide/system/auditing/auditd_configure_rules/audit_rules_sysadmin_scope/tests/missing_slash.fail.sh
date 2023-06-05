
# packages = audit
echo "-w /etc/sudoers -p wa -k scope" >> /etc/audit/rules.d/actions.rules
echo "-w /etc/sudoers.d -p wa -k scope" >> /etc/audit/rules.d/actions.rules
