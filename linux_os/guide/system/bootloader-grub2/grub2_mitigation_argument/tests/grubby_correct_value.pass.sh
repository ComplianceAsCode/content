# platform = Oracle Linux 8
# packages = grubby

sudo grubby --update-kernel=ALL --args="mitigation=on"
