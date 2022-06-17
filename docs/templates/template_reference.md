### Available Templates

#### accounts_password
-   Checks if PAM enforces password quality requirements. Checks the
    configuration in `/etc/security/pwquality.conf`.

-   Parameters:

    -   **variable** - PAM `pam_pwquality` password quality
        requirement, eg. `ucredit`, `ocredit`

    -   **operation** - OVAL operation, eg. `less than or equal`

    -   **zero_comparison_operation** - (optional) OVAL operation, eg. `greater than`.
        When set, it will test if the **variable** value matches the OVAL operation
        when compared to zero.

-   Languages: Ansible, Bash, OVAL

#### auditd_lineinfile
-   Checks configuration options of the Audit Daemon in
    `/etc/audit/auditd.conf`.

-   Parameters:

    -   **parameter** - auditd configuration item

    -   **value** - the value of configuration item specified by
        parameter

    -   **missing_parameter_pass** - effective only in OVAL checks, if
        set to `"false"` and the parameter is not present in the
        configuration file, the OVAL check will return false (default value: `"false"`).

-   Languages: Ansible, Bash, OVAL

#### audit_rules_dac_modification
-   Checks Audit Discretionary Access Control rules

-   Parameters:

    -   **attr** - value of `-S` argument in Audit rule, eg. `chmod`

-   Languages: Ansible, Bash, OVAL, Kubernetes

#### audit_rules_file_deletion_events
-   Ensure auditd Collects file deletion events

-   Parameters:

    -   **name** - value of `-S` argument in Audit rule, eg. `unlink`

-   Languages: Ansible, Bash, OVAL

#### audit_rules_login_events
-   Checks if there are Audit rules that record attempts to alter logon
    and logout events.

-   Parameters:

    -   **path** - value of `-w` in the Audit rule, eg.
        `/var/run/faillock`

-   Languages: Ansible, Bash, OVAL, Kubernetes

#### audit_rules_path_syscall
-   Check if there are Audit rules to record events that modify
    user/group information via a syscall on a specific file.

-   Parameters:

    -   **path** - path of the protected file, eg `/etc/shadow`

    -   **pos** - position of argument, eg. `a2`

    -   **syscall** - name of the system call, eg. `openat`

-   Languages: Ansible, Bash, OVAL

#### audit_rules_privileged_commands
-   Ensure Auditd collects information on the use of specified
    privileged command.

-   Parameters:

    -   **path** - the path of the privileged command - eg.
        `/usr/bin/mount`

-   Languages: Ansible, Bash, OVAL, Kubernetes

#### audit_rules_syscall_events
-   Ensure there is an audit rule to record for all uses of 
    specified system call

-   Parameters:

    -   **attr** - the name of the system call - eg.
        `unlinkat`

-   Languages: Ansible, Bash, OVAL, Kubernetes

#### audit_file_contents
-   Ensure that audit `.rules` file specified by parameter `filepath`
    contains the contents specified in parameter `contents`.

-   Parameters:

    -   **filepath** - path to audit rules file, e.g.:
        `/etc/audit/rules.d/10-base-config.rules`

    -   **contents** - expected contents of the file

-   Languages: Ansible, Bash, OVAL

#### audit_rules_unsuccessful_file_modification
-   Ensure there is an Audit rule to record unsuccessful attempts to
    access files

-   Parameters:

    -   **name** - name of the unsuccessful system call, eg. `creat`

-   Languages: Ansible, Bash, OVAL

#### audit_rules_unsuccessful_file_modification_o_creat
-   Ensure there is an Audit rule to record unsuccessful attempts to
    access files when O_CREAT flag is specified.

-   Parameters:

    -   **syscall** - name of the unsuccessful system call, eg. `openat`

    -   **pos** - position of the O_CREAT argument in the syscall, as
        specified by `-F` audit rule argument, eg. `a2`

-   Languages: OVAL

#### audit_rules_unsuccessful_file_modification_o_trunc_write
-   Ensure there is an Audit rule to record unsuccessful attempts to
    access files when O_TRUNC_WRITE flag is specified.

-   Parameters:

    -   **syscall** - name of the unsuccessful system call, eg. `openat`

    -   **pos** - position of the O_TRUNC_WRITE argument in the
        syscall, as specified by `-F` audit rule argument, eg. `a2`

-   Languages: OVAL

#### audit_rules_unsuccessful_file_modification_rule_order
-   Ensure that Audit rules for unauthorized attempts to use a specific
    system call are ordered correctly.

-   Parameters:

    -   **syscall** - name of the unsuccessful system call, eg. `openat`

    -   **pos** - position of the flag parameter in the syscall, as
        specified by `-F` audit rule argument, eg. `a2`

-   Languages: OVAL

#### audit_rules_usergroup_modification
-   Check if Audit is configured to record events that modify account
    changes.

-   Parameters:

    -   **path** - path that should be part of the audit rule as a value
        of `-w` argument, eg. `/etc/group`.

-   Languages: Ansible, Bash, OVAL

#### argument_value_in_line
-   Checks that `argument=value` pair is present in (optionally) the
    line started with line_prefix (and, optionally, ending with
    line_suffix) in the file(s) defined by filepath.

-   Parameters:

    -   **filepath** - File(s) to be checked. The value would be treated
        as a regular expression pattern.

    -   **arg_name** - Argument name, eg. `audit`

    -   **arg_value** - Argument value, eg. `'1'`

    -   **line_prefix** - The prefix of the line in which
        argument-value pair should be present, optional.

    -   **line_suffix** - The suffix of the line in which
        argument-value pair should be present, optional.

-   Languages: OVAL

#### coreos_kernel_option
-   Checks that `argument=value` pair is present in the kernel arguments.
    Note that this applies to Red Hat CoreOS.

-   Parameters:

    -   **arg_name** - Argument name, eg. `audit`

    -   **arg_value** - Argument value, eg. `'1'`. This parameter is optional,
        and if omitted, this template will only use **arg_name**.

    -   **arg_negate** - negates the check, which then ensures that
        `argument=value` is not present in the kernel arguments.

    -   **arg_is_regex** - Specifies that the given `arg_name` and `arg_value`
        are regexes.

-   Languages: OVAL, Kubernetes

#### dconf_ini_file
-   Checks for `dconf` configuration. Additionally checks if the
    configuration is locked so it cannot be overriden by the user.
    The `locks` directory is always the **path** appended by `locks/`.

-   Parameters:

    -   **path** - dconf configuration files directory. All files within this directory
        will be check for the configuration presence.  eg. `/etc/dconf/db/local.d/`.

    -   **section** - name of the `dconf` configuration section, eg. `"org/gnome/desktop/lockdown"`

    -   **parameter** - name of the `dconf` configuration option, eg.
        `user-administration-disabled`

    -   **value** - value of the `dconf` configuration option specified by
        **parameter**, eg. `"true"`.

-   Languages: Ansible, Bash, OVAL

-   Example:

        template:
            name: dconf_ini_file
            vars:
                path: /etc/dconf/db/local.d/
                section: "org/gnome/desktop/lockdown"
                parameter: user-administration-disabled
                value: "true"

#### file_existence
- Check if a file exists or doesn't exist.

- Parameters:
    - **filepath** - File path to be checked.
    - **exists** - If set to `true` the check will fail if the file doesn't exist and vice versa for `false`.

- Languages: Ansible, Bash, OVAL

#### file_groupowner
-   Check group that owns the given file.

-   Parameters:

    -   **filepath** - File path to be checked. If the file path ends
        with `/` it describes a directory. Can also be a list of paths.
        If **file_regex** is not specified, the rule will only check
        and remediate directories.

    -   **filepath_is_regex** - If set to `"true"` the OVAL will
        consider the value of **filepath** as a regular expression.

    -   **missing_file_pass** - If set to `"true"` the OVAL check will
        pass when file is absent. Default value is `"false"`.

    -   **file_regex** - Regular expression that matches file names in
        a directory specified by **filepath**. Can be set only if
        **filepath** parameter specifies a directory. Note: Applies to
        base name of files, so if a file `/foo/bar/file.txt` is
        processed, only `file.txt` is tested against **file_regex**. Can
        be a list of regexes.

    -   **recursive** - If set to `"true"` the OVAL will consider the
        subdirectories under the directory specified by **filepath**. Default
        value is `"false"`.

    -   **filegid** - group ID (GID)

-   Languages: Ansible, Bash, OVAL

Note that the interaction between **filepath** and **file_regex** is as such:
if **filepath** is a string, **file_regex** must also be a string; if **filepath**
is a **list** and **file_regex** is a string, it gets extended to be the same regex
for each path; if **filepath** and **file_regex** are both present and are lists,
they must be of the same length.

#### file_owner
-   Check user that owns the given file.

-   Parameters:

    -   **filepath** - File path to be checked. If the file path ends
        with `/` it describes a directory. Can also be a list of paths.
        If **file_regex** is not specified, the rule will only check
        and remediate directories.

    -   **filepath_is_regex** - If set to `"true"` the OVAL will
        consider the value of **filepath** as a regular expression.

    -   **missing_file_pass** - If set to `"true"` the OVAL check will
        pass when file is absent. Default value is `"false"`.

    -   **file_regex** - Regular expression that matches file names in
        a directory specified by **filepath**. Can be set only if
        **filepath** parameter specifies a directory. Note: Applies to
        base name of files, so if a file `/foo/bar/file.txt` is
        processed, only `file.txt` is tested against **file_regex**. Can
        be a list of regexes.

    -   **recursive** - If set to `"true"` the OVAL will consider the
        subdirectories under the directory specified by **filepath**. Default
        value is `"false"`.

    -   **fileuid** - user ID (UID)

-   Languages: Ansible, Bash, OVAL

Note that the interaction between **filepath** and **file_regex** is as such:
if **filepath** is a string, **file_regex** must also be a string; if **filepath**
is a **list** and **file_regex** is a string, it gets extended to be the same regex
for each path; if **filepath** and **file_regex** are both present and are lists,
they must be of the same length.

#### file_permissions
-   Checks permissions (mode) on a given file.

-   Parameters:

    -   **filepath** - File path to be checked. If the file path ends
        with `/` it describes a directory. Can also be a list of paths.
        If **file_regex** is not specified, the rule will only check
        and remediate directories.

    -   **filepath_is_regex** - If set to `"true"` the OVAL will
        consider the value of **filepath** as a regular expression.

    -   **missing_file_pass** - If set to `"true"` the OVAL check will
        pass when file is absent. Default value is `"false"`.

    -   **file_regex** - Regular expression that matches file names in
        a directory specified by **filepath**. Can be set only if
        **filepath** parameter specifies a directory. Note: Applies to
        base name of files, so if a file `/foo/bar/file.txt` is
        processed, only `file.txt` is tested against **file_regex**. Can
        be a list of regexes.

    -   **recursive** - If set to `"true"` the OVAL will consider the
        subdirectories under the directory specified by **filepath**. Default
        value is `"false"`.

    -   **filemode** - File permissions in a hexadecimal format, eg.
        `'0640'`.

    -   **allow_stricter_permissions** - If set to `"true"` the OVAL
        will also consider permissions stricter than **filemode** as compliant.
        Default value is `"true"`.

-   Languages: Ansible, Bash, OVAL

Note that the interaction between **filepath** and **file_regex** is as such:
if **filepath** is a string, **file_regex** must also be a string; if **filepath**
is a **list** and **file_regex** is a string, it gets extended to be the same regex
for each path; if **filepath** and **file_regex** are both present and are lists,
they must be of the same length.

#### firefox_lockpreference
-   Checks that a given Mozilla Firefox configuration item is locked and set.

-   Parameters
    -   **parameter** - Name of Mozilla Firefox configuration item to be checked/set.
    -   **value** - Literal value to be set in the Mozilla Firefox default configuration.

-   Languages: Bash, OVAL

#### grub2_bootloader_argument
-   Ensures that a kernel command line argument is present in GRUB 2 configuration.

-   Parameters:

    -   **arg_name** - argument name, eg. `audit`

    -   **arg_value** - argument value, eg. `'1'`

    -   **arg_variable** - the variable used as the value for the argument, eg. `'var_slub_debug_options'`
        This parameter is mutually exclusive with **arg_value**.

-   Languages: Ansible, Bash, OVAL, Blueprint

#### grub2_bootloader_argument_absent
-   Ensures that a kernel command line argument is absent in GRUB 2 configuration.
    The template can also remove arguments with a value assigned, eg. audit=1

-   Parameters:

    -   **arg_name** - argument name, eg. `audit`, `nosmep`

-   Languages: Ansible, Bash, OVAL

Example:
```
template:
  name: grub2_bootloader_argument_absent
  vars:
    arg_name: audit
```

#### kernel_build_config
This template checks the configuration used to build the kernel by checking the `/boot/config-*` files.
The only way to remediate is to recompile and reinstall the kernel, so no remediation should be expected.

- Parameters:

    - **config** - The kernel configuration to check
    - **value** - The value the configuration should have
      When **value** is `"n"`, the check will pass when the config is absent, commented out or has the
      value `n` in the `/boot/config-*` files.
    - **variable** - The variable to get the value from.
      This parameter is mutually exclusive with **value**.

- Languages: OVAL

#### kernel_module_disabled
-   Checks if the given Linux kernel module is disabled.
    The default method is to check the `install` keyword.
    On OL and RHEL products the `blacklist` keyword is also checked.
    The SLE products only check for  the `blacklist` keyword.

-   Parameters:

    -   **kernmodule** - name of the Linux kernel module, eg. `cramfs`

-   Languages: Ansible, Bash, Kubernetes, OVAL

#### lineinfile
-   Checks that the given text is present in a file.
    This template doesn't work with a concept of keys and values - it is meant
    only for simple statements.

-   Parameters:

    -   **escape_text** - if set to true the given text is escaped to treat it as regex,
        when set to false the text is taken directly as it is.

    -   **path** - path to the file to check.

    -   **text** - the line that should be present in the file.

    -   **oval_extend_definitions** - optional, list of additional OVAL
        definitions that have to pass along the generated check.

        **sed_path_separator** - optional, default is `/`, sets the sed path separator. Set this
        to a character like `#` if `/` is in use in your text.

-   Languages: Ansible, Bash, OVAL


#### mount
-   Checks that a given mount point is located on a separate partition.

-   Parameters:

    -   **mountpoint** - path to the mount point, eg. `/var/tmp`

    -   **min_size** - the minimum recommended partition size, in bytes

-   Languages: Anaconda, OVAL, Blueprint

#### mount_option
-   Checks if a given partition is mounted with a specific option such
    as "nosuid". It is also possible to use options with arguments, such as "logdev=device". Finally, for options which expect an argument, like "hidepid=2", a variable can be informed for this argument.

-   Parameters:

    -   **mountpoint** - mount point on the filesystem eg. `/dev/shm`

    -   **mountoption** - mount option, eg. `nosuid`, `logdev=device` or `hidepid`

    -   **mountoption_arg_var** - variable which holds the argument for mount option, eg. `var_mount_option_proc_hidepid`

    -   **filesystem** - filesystem in `/etc/fstab`, eg. `tmpfs`. Used
        only in Bash remediation.

    -   **type** - filesystem type. Used only in Bash remediation.

    -   **mount_has_to_exist** - Specifies if the **mountpoint**
        entry has to exist in `/etc/fstab` before the remediation is
        executed. If set to `yes` and the **mountpoint** entry is not
        present in `/etc/fstab` the Bash remediation terminates. If set
        to `no` the **mountpoint** entry will be created in
        `/etc/fstab`.

-   Languages: Anaconda, Ansible, Bash, OVAL

#### mount_option_remote_filesystems
-   Checks if all remote filesystems (NFS mounts in `/etc/fstab`) are
    mounted with a specific option.

-   Parameters:

    -   **mountpoint** - always set to `remote_filesystems`

    -   **mountoption** - mount option, eg. `nodev`

    -   **filesystem** - filesystem of new mount point (used when adding
        new entry in `/etc/fstab`), eg. `tmpfs`. Used only in Bash
        remediation.

    -   **mount_has_to_exist** - Used only in Bash remediation.
        Specifies if the **mountpoint** entry has to exist in
        `/etc/fstab` before the remediation is executed. If set to `yes`
        and the **mountpoint** entry is not present in `/etc/fstab` the
        Bash remediation terminates. If set to `no` the **mountpoint**
        entry will be created in `/etc/fstab`.

-   Languages: Ansible, Bash, OVAL

#### mount_option_removable_partitions
-   Checks if all removable media mounts are mounted with a specific
    option. Unlike other mount option templates, this template doesn’t
    use the mount point, but the block device. The block device path
    (eg. `/dev/cdrom`) is always set to `var_removable_partition`. This
    is an XCCDF Value, defined in
    [var_removable_partition.var](https://github.com/ComplianceAsCode/content/tree/master/linux_os/guide/system/permissions/partitions/var_removable_partition.var)

-   Parameters:

    -   **mountoption** - mount option, eg. `nodev`

-   Languages: Anaconda, Ansible, Bash, OVAL

#### package_installed
-   Checks if a given package is installed. Optionally, it can also
    check whether a specific version or newer is installed.

-   Parameters:

    -   **pkgname** - name of the RPM or DEB package, eg. `tmux`

    -   **evr** - Optional parameter. It can be used to check if the
        package is of a specific version or newer. Provide epoch,
        version, release in `epoch:version-release` format, eg.
        `0:2.17-55.0.4.el7_0.3`. Used only in OVAL checks. The OVAL
        state uses operation "greater than or equal" to compare the
        collected package version with the version in the OVAL state.

-   Languages: Anaconda, Ansible, Bash, OVAL, Puppet, Blueprint

#### package_removed
-   Checks if the given package is not installed.

-   Parameters:

    -   **pkgname** - name of the RPM or DEB package, eg. `tmux`

-   Languages: Anaconda, Ansible, Bash, OVAL, Puppet

#### pam_options
-   Checks if the parameters or arguments of a given Linux-PAM (Pluggable
    Authentication Modules) module in a given PAM configuration file
    are correctly specified. This template is using regular expression to match
    the module parameters, and their respective values if any. A parameter
    can be added if absent, modified when it's value doesn't match the expected
    value, or removed when present. There are two ways to specify a PAM module
    parameter, either using XCCDF variable or argument value matching.
    Use XCCDF variable in a situation where the parameter value is expected
    to be configurable/selectable by the user.
    eg, `ucredit=<var_pam_password_ucredit.var>`. Otherwise, use argument value
    matching is advised.

-   Parameters:

    -   **path** - the complete path to the PAM configuration file, eg.
        `/etc/pam.d/common-password`
    -   **type** - (required) PAM type, eg. `password`
    -   **control_flag** - (required) PAM control flag, eg. `requisite`
    -   **module** - (required) PAM module, eg. `pam_cracklib.so`
    -   **arguments** - (optional) parameters or arguments for the PAM module.
        These are optional. A PAM module can have multiple arguments, specified
        as a list of dictionaries. Following are acceptable parameters for
        each argument.

        -  **variable** - (optional) PAM module argument/parameter name,
           eg. `ucredit`, `ocredit`. Use this parameter in a situation where
           the PAM module argument is configurable/selectable by the user.
           `var_password_pam_<variable name>.var` XCCDF variable must be
           defined when using this parameter. This parameter must be used
           in conjunction with the **operation** parameter. Also, this
           parameter is mutually exclusive with the **argument** parameter.
        -  **operation** - (optional) OVAL operation,
           eg. `less than or equal`. This parameter must be used in
           conjunction with the **variable** parameter.
        -  **argument** - (optional) the name of the PAM module argument,
           eg. `dcredit`. It is mutually exclusive with the **variable**
           parameter. Therefore, it must be absent when **variable** is
           present.
        -  **argument_match** - (optional) the regular expression to match the
           argument value. It is optional when the argument has no value, or
           when the argument is to be removed. In these cases the parameter
           is not required and will be ignored if present. It is required when
           a value argument needs to be added or modified.
        -  **argument_value** - (optional) the expected argument value for a
           value argument to be added or modifed, when the **argument_match**
           regular expression failed to yield a match. The argument's existing
           value will be replaced by **argument_value**. When the argument has
           no value, or when the argument is to be removed, this parameter is
           not required and will be ignored. It is required when a value
           argument needs to be added or modified.
        -  **new_argument** - (optional) the argument to be added if not
           already present, eg, `dcredit=-1`. It is required when the argument
           is not already present and needs to be added. 
        -  **remove_argument** - (optional) the argument will be
           removed, if the argument is present. This parameter must not be
           specified when the argument is being added or modified.
       
-    Language: Ansible, OVAL

#### sebool
-   Checks values of SELinux booleans.

-   Parameters:

    -   **seboolid** - name of SELinux boolean, eg.
        `cron_userdomain_transition`

    -   **sebool_bool** - the value of the SELinux Boolean. Can be
        either `"true"` or `"false"`. If this parameter is not
        specified, the rule will use XCCDF Value `var_<seboolid>`. These
        XCCDF Values are usually defined in the same directory where the
        `rule.yml` that describes the rule is located. The **seboolid**
        will be replaced by a SELinux boolean, for example:
        `selinuxuser_execheap` and in the profile you can use
        `var_selinuxuser_execheap` to turn on or off the SELinux
        boolean.

-   Languages: Ansible, Bash, OVAL

#### service_disabled
-   Checks if a service is disabled. Uses either systemd or SysV init
    based on the product configuration in `product.yml`.

-   Parameters:

    -   **servicename** - name of the service.

    -   **packagename** - name of the package that provides this
        service. This argument is optional. If **packagename** is not
        specified it means the name of the package is the same as the
        name of service.

    -   **daemonname** - name of the daemon. This argument is optional.
        If **daemonname** is not specified it means the name of the
        daemon is the same as the name of service.

-   Languages: Ansible, Bash, OVAL, Puppet, Ignition, Kubernetes, Blueprint

#### service_enabled
-   Checks if a system service is enabled. Uses either systemd or SysV
    init based on the product configuration in `product.yml`.

-   Parameters:

    -   **servicename** - name of the service.

    -   **packagename** - name of the package that provides this
        service. This argument is optional. If **packagename** is not
        specified it means the name of the package is the same as the
        name of service.

    -   **daemonname** - name of the daemon. This argument is optional.
        If **daemonname** is not specified it means the name of the
        daemon is the same as the name of service.

-   Languages: Ansible, Bash, OVAL, Puppet, Blueprint

#### shell_lineinfile
-   Checks shell variable assignments in files. Remediations will paste
    assignments with single shell quotes unless there is the dollar sign
    in the value string, in which case double quotes are administered.
    The OVAL checks for a match with either of no quotes, single quoted
    string, or double quoted string.

-   Parameters:

    -   **path** - What file to check.

    -   **parameter** - name of the shell variable, eg. `SHELL`.

    -   **value** - value of the SSH configuration option specified by
        **parameter**, eg. `"/bin/bash"`. Don’t pass extra shell
        quoting - that will be handled on the lower level.

    -   **no_quotes** - If set to `"true"`, the assigned value has to
        be without quotes during the check and remediation doesn’t quote
        assignments either.

    -   **missing_parameter_pass** - effective only in OVAL checks, if
        set to `"false"` and the parameter is not present in the
        configuration file, the OVAL check will return false (default value: `"false"`).

-   Languages: Ansible, Bash, OVAL

-   Example: A template invocation specifying that parameter `HISTSIZE`
    should be set to value `500` in `/etc/profile` will produce a check
    that passes if any of the following lines are present in
    `/etc/profile`:

    -   `HISTSIZE=500`

    -   `HISTSIZE="500"`

    -   `HISTSIZE='500'`

        The remediation would insert one of the quoted forms if the line
        was not present.

        If the `no_quotes` would be set in the template, only the first
        form would be checked for, and the unquoted assignment would be
        inserted to the file by the remediation if not present.

#### sshd_lineinfile
-   Checks SSH server configuration items in `/etc/ssh/sshd_config` or
    `/etc/ssh/sshd_config.d/00-complianceascode-hardening.conf` in case
    of Fedora or RHEL9 and newer.

-   Parameters:

    -   **parameter** - name of the SSH configuration option, eg.
        `KerberosAuthentication`

    -   **value** - value of the SSH configuration option specified by
        **parameter**, eg. `"no"`.

    -   **missing_parameter_pass** - effective only in OVAL checks, if
        set to `"false"` and the parameter is not present in the
        configuration file, the OVAL check will return false (default value: `"false"`).

    -   **is_default_value** - effective only in Ansible and Bash remediation, if
        set to `"true"`, settings will be remediated into a file
        called (in case of Fedora or RHEL9 and newer):
        `/etc/ssh/sshd_config.d/01-complianceascode-reinforce-os-defaults.conf`

-   Languages: Ansible, Bash, OVAL, Kubernetes

#### sudo_defaults_option
This template ensures a sudo `Defaults` options is enabled in `/etc/sudoers` or in `/etc/sudoers.d/*`.\
The template can check for options with and without parameters.\
The remediations add the `Defaults` option  to `/etc/sudoers` file.

-   Parameters:

    - **option** - name of sudo `Defaults` option to enable.
    - **option_regex_suffix** - suffix to the pattern-match to use after **option**; defaults to `=(\w+)\b`.
    - **parameter_variable** - name of the XCCDF variable to get the value for the option parameter.\
      (optional, if not set the check and remediation won't use parameters)
    - **default_is_enabled** -  set to `"true"` if the option is enabled by default for the product.
      In this case, the check will pass even if the options is not explicitly set.\
      If **parameter_variable** is used this is forced to `"false"`. As the Value selector can be changed by tailoring at scan-time the default value needs to be defined at compile-time, and this is not supported at the moment.\
      (optional, default value is `"false"`. )

-   Languages: Ansible, Bash, OVAL

Examples:
```
template:
  name: sudo_defaults_option
  vars:
    option: noexec
```
This will generate:
-   A check that asserts `Defaults noexec` is present in `/etc/sudoers` or `/etc/sudoers.d/`.\
    `Defaults` with multiple options are also accepted, i.e.: `Defaults ignore_dot,noexec,use_pty`.
-   A remediation that adds `Defaults noexec` to `/etc/sudoers`.

```
template:
  name: sudo_defaults_option
  vars:
    option: umask
    variable_name: var_sudo_umask
```
The default selected value of `var_sudo_umask` is `"0022"`.  Hence, the template key will generate:
-   A check that asserts `Defaults umask=0022` is present in `/etc/sudoers` or `/etc/sudoers.d/`.\
    `Defaults` with multiple options are also accepted, i.e.: `Defaults ignore_dot,umask=0022,use_pty`.
-   A remediation that adds `Defaults umask=0022` to `/etc/sudoers`.

The selected value can be changed in the profile (consult the actual variable for valid selectors). E.g.:
```
    - var_sudo_umask=0027
```

#### sysctl
-   Checks sysctl parameters. The OVAL definition checks both static
    configuration and runtime settings and require both of them to be
    set to the desired value to return true.

    The following file and directories are checked for static
    sysctl configurations:
    - /etc/sysctl.conf
    - /etc/sysctl.d/\*.conf
    - /run/sysctl.d/\*.conf
    - /usr/lib/sysctl.d/\*.conf (does not apply to RHEL and OL)

    A sysctl option defined in more than one file within the scanned directories
    will result in `fail`.

-   Parameters:

    -   **sysctlvar** - name of the sysctl value, eg.
        `net.ipv4.conf.all.secure_redirects`.

    -   **datatype** - data type of the sysctl value, eg. `int`.

    -   **sysctlval** - value of the sysctl value, eg. `'1'`. If this
        parameter is not specified, XCCDF Value is used instead.

    -   **operation** - operation used for comparison of collected object
        with **sysctlval**. Default value: `equals`.

    -   **sysctlval_regex** - if **operation** is `pattern match`, this
        parameter is used instead of **sysctlval**.

-   Languages: Ansible, Bash, OVAL

#### timer_enabled
-   Checks if a SystemD timer unit is enabled.

-   Parameters:

    -   **timername** - name of the SystemD timer unit, without the
        `timer` suffix, eg. `dnf-automatic`.

    -   **packagename** - name of the RPM package which provides the
        SystemD timer unit. This parameter is optional, if it is not
        provided it is assumed that the name of the RPM package is the
        same as the name of the SystemD timer unit.

-   Languages: Ansible, Bash, OVAL

#### yamlfile_value
-   Check if value(s) of certain type is (are) present in a YAML (or
    JSON) file at a given path.

-   Parameters:

    -   **ocp_data** - if set to `"true"` then the filepath would be
        treated as a part of the dump of OCP configuration with the
        `ocp_data_root` prefix; optional.

    -   **filepath** - full path to the file to check

    -   **yamlpath** - OVAL’s [YAML
        Path](https://github.com/OpenSCAP/yaml-filter/wiki/YAML-Path-Definition)
        expression.

    -   **entity_check**
        ([CheckEnumeration](https://github.com/OVALProject/Language/blob/master/docs/oval-common-schema.md#CheckEnumeration)) -
        entity_check value for state’s value, optional. If omitted,
        entity_check attribute would not be set and will be treated by
        OVAL as *all*.
        Possible options are `all`, `at least one`, `none satisfy` and
        `only one`.

    -   **check_existence**
        ([ExistenceEnumeration](https://github.com/OVALProject/Language/blob/master/docs/oval-common-schema.md#ExistenceEnumeration)) -
        `check_existence` value for the `yamlfilecontent_test`,
        optional. If omitted, check_existence attribute will default to
        *only_one_exists*.
        Possible options are `all_exist`, `any_exist`,
        `at_least_one_exists`, `none_exist`, `only_one_exists`.

    -   **xccdf_variable** - XCCDF variable selector. Use this field if the comparison involves
        checking for a value selected by a XCCDF variable.

    -   **embedded_data** - if set to `"true"` and used combined with `xccdf_variable`, the data retrieved by `yamlpath`
        is considered as a blob and the field `value` has to contain a capture regex.
   
    -   **regex_data** - if set to `"true"` and combined with `xccdf_variable`, it will use the value of `xccdf_variable` as a regex
        and does pattern match operation instead of equal operation.


    -   **check_existence_yamlpath** - optional YAML Path that could be set to ensure that the target sequence from `yamlpath` has all
        required sub-elements. It is helpful when the `yamlpath` is targeting a map inside a sequence, and the document could be
        missing a key in that map (i.e. `$.seq[:].obj.item.key_that_might_be_missing`). When `check_existence_yamlpath` is set to a path
        like `$.seq[:].obj.item.key_that_always_exists` (or `$.seq[:].obj.key_that_always_exists`) the template will create a check,
        that will count elements in both paths and would fail if amounts are not equal.

        This check has a limitation: both `check_existence_yamlpath` and `yamlpath` have to point to a scalar value for it to work
        correctly (that is, the path `$.seq[:].obj.item` won't work).

    -   **values** - a list of dictionaries with values to check, where:

        -   **key** - the yaml key to check, optional. Used when the
            yamlpath expression yields a map.

        -   **value** - the value to check. If used in combination with
            `xccdf_variable` and `embedded_data`, this field must have a
            regex with a capture group. The value captured by the regex
            will be compared with value of variable referenced by `xccdf_variable`.

        -   **type**
            ([SimpleDatatypeEnumeration](https://github.com/OVALProject/Language/blob/master/docs/oval-common-schema.md#---simpledatatypeenumeration---)) -
            datatype for state’s field (child of value), optional. If
            omitted, datatype would be treated as OVAL’s default *string*.
            Most common datatypes are `string` and `int`. For complete list
            check reference link.

        -   **operation**
            ([OperationEnumeration](https://github.com/OVALProject/Language/blob/master/docs/oval-common-schema.md#---operationenumeration---)) -
            operation value for state’s field (child of value), optional. If
            omitted, operation attribute would not be set. OVAL’s default
            operation is *equals*.
            Most common operations are `equals`, `not equal`,
            `pattern match`, `greater than or equal` and
            `less than or equal`. For complete list of operations check the
            reference link.

        -   **entity_check**
            ([CheckEnumeration](https://github.com/OVALProject/Language/blob/master/docs/oval-common-schema.md#CheckEnumeration)) -
            entity_check value for state’s field (child of value),
            optional. If omitted, entity_check attribute would not be set
            and will be treated by OVAL as *all*.
            Possible options are `all`, `at least one`, `none satisfy` and
            `only one`.

-   Languages: OVAL

### Creating Templates

The offer of currently available templates can be extended by developing a new
template.

1) Create a new subdirectory within the
[shared/templates](https://github.com/ComplianceAsCode/content/tree/master/shared/templates) directory. The name of the
new subdirectory will become the template name.

2) For each language supported by this template, create a corresponding file
within the template directory. File names should have format of `LANG.template`,
where *LANG* should be the language  identifier in lower case, e.g.
`oval.template`, `bash.template` etc.

    Use the Jinja syntax we use elsewhere in the project; refer to the earlier
    section on Jinja macros for more information.  The parameters should be named
    using uppercase letters, because the keys from `rule.yml` are converted to
    uppercase by the code that substitutes the parameters to the template.

    Notice that OVAL should be written in shorthand format.  This is an example of
    an OVAL template file called `oval.template` within the `package_installed`
    directory:

        <def-group>
        <definition class="compliance" id="package_{{{ PKGNAME }}}_installed"
        version="1">
            <metadata>
            <title>Package {{{ PKGNAME }}} Installed</title>
            <affected family="unix">
                <platform>multi_platform_all</platform>
            </affected>
            <description>The {{{ pkg_system|upper }}} package {{{ PKGNAME }}} should be installed.</description>
            </metadata>
            <criteria>
            <criterion comment="package {{{ PKGNAME }}} is installed"
            test_ref="test_package_{{{ PKGNAME }}}_installed" />
            </criteria>
        </definition>
        {{{ oval_test_package_installed(package=PKGNAME, evr=EVR, test_id="test_package_"+PKGNAME+"_installed") }}}
        </def-group>

    And here is the Ansible template file called `ansible.template` within the
    `package_installed` directory:

        # platform = multi_platform_all
        # reboot = false
        # strategy = enable
        # complexity = low
        # disruption = low
        - name: Ensure {{{ PKGNAME }}} is installed
        package:
            name: "{{{ PKGNAME }}}"
            state: present

3) Create a file called `template.yml` within the template directory. This file
stores template metadata. Currently, it stores list of supported languages. Note
that each language listed in this file must have associated implementation
file with the *.template* extension, see above. 

    An example can look like this:

    supported_languages:
    - ansible
    - bash
    - ignition
    - kubernetes
    - oval
    - puppet


4) If needed, implement a preprocessing function which will process the
parameters before passing them to the Jinja engine.  For example, this function can
provide default values, escape characters, check if parameters are correct, or
perform any other processing of the parameters specific for the template.

    The function should be called _preprocess_ and should be located in the file
    `template.py` within the template directory.

    The function must have 2 parameters:

    - `data` - dictionary which contains the contents of `vars:` dictionary from `rule.yml`
    - `lang` - string, describes language, can be one of: `"anaconda"`, `"ansible"`, `"bash"`, `"oval"`, `"puppet"`, `"ignition"`, `"kubernetes"`

    The function is executed for every supported language, so it can process the data differently for each language.

    The function must always return the (modified) `data` dictionary.

    The following example shows the file `template.py` for the template
    `mount_option`. The code takes the `data` argument which is a dictionary with
    template parameters from `rule.yml` and based on `lang` it modifies the template
    parameters and returns the modified dictionary.

        import re

        def preprocess(data, lang):
            if lang == "oval":
                data["pointid"] = re.sub(r"[-\./]", "_", data["mountpoint"]).lstrip("_")
            else:
                data["mountoption"] = re.sub(" ", ",", data["mountoption"])
            return data

### Filters

You can use Jinja macros and Jinja filters in the template code.
ComplianceAsCode support all built-in Jinja
[filters](https://jinja.palletsprojects.com/en/2.11.x/templates/#builtin-filters).

There are also some custom filters useful for content authoring defined
in the project:

escape_id
-   Replaces all non-word (regex **\\W**) characters with underscore.
    Useful for sanitizing ID strings as it is compatible with OVAL IDs
    `oval:[A-Za-z0-9_\-\.]+:ste:[1-9][0-9]*`.

escape_regex
-   Escapes characters in the string for it to be usable as a part of
    some regular expression, behaves similar to the Python 3’s
    [**re.escape**](https://docs.python.org/3/library/re.html#re.escape).
