from __future__ import absolute_import
from __future__ import print_function

import os.path
import jinja2

try:
    from urllib.parse import quote
except ImportError:
    from urllib import quote


from .constants import (JINJA_MACROS_BASE_DEFINITIONS,
                        JINJA_MACROS_HIGHLEVEL_DEFINITIONS,
                        JINJA_MACROS_ANSIBLE_DEFINITIONS,
                        JINJA_MACROS_BASH_DEFINITIONS,
                        JINJA_MACROS_OVAL_DEFINITIONS,
                        JINJA_MACROS_IGNITION_DEFINITIONS,
                        JINJA_MACROS_KUBERNETES_DEFINITIONS,
                        )
from .utils import (required_key,
                    prodtype_to_name,
                    name_to_platform,
                    prodtype_to_platform,
                    banner_regexify,
                    banner_anchor_wrap
                    )


class MacroError(RuntimeError):
    pass


class AbsolutePathFileSystemLoader(jinja2.BaseLoader):
    """Loads templates from the file system. This loader insists on absolute
    paths and fails if a relative path is provided.

    >>> loader = AbsolutePathFileSystemLoader()

    Per default the template encoding is ``'utf-8'`` which can be changed
    by setting the `encoding` parameter to something else.
    """

    def __init__(self, encoding='utf-8'):
        self.encoding = encoding

    def get_source(self, environment, template):
        if not os.path.isabs(template):
            raise jinja2.TemplateNotFound(template)

        template_file = jinja2.utils.open_if_exists(template)
        if template_file is None:
            raise jinja2.TemplateNotFound(template)
        try:
            contents = template_file.read().decode(self.encoding)
        finally:
            template_file.close()

        mtime = os.path.getmtime(template)

        def uptodate():
            try:
                return os.path.getmtime(template) == mtime
            except OSError:
                return False
        return contents, template, uptodate


def _get_jinja_environment(substitutions_dict):
    if _get_jinja_environment.env is None:
        bytecode_cache = None
        if substitutions_dict.get("jinja2_cache_enabled") == "true":
            bytecode_cache = jinja2.FileSystemBytecodeCache(
                required_key(substitutions_dict, "jinja2_cache_dir")
            )

        # TODO: Choose better syntax?
        _get_jinja_environment.env = jinja2.Environment(
            block_start_string="{{%",
            block_end_string="%}}",
            variable_start_string="{{{",
            variable_end_string="}}}",
            comment_start_string="{{#",
            comment_end_string="#}}",
            loader=AbsolutePathFileSystemLoader(),
            bytecode_cache=bytecode_cache
        )
        _get_jinja_environment.env.filters['banner_regexify'] = banner_regexify
        _get_jinja_environment.env.filters['banner_anchor_wrap'] = banner_anchor_wrap

    return _get_jinja_environment.env


_get_jinja_environment.env = None


def raise_exception(message):
    raise MacroError(message)


def update_substitutions_dict(filename, substitutions_dict):
    """
    Treat the given filename as a jinja2 file containing macro definitions,
    and export definitions that don't start with _ into the substitutions_dict,
    a name->macro dictionary. During macro compilation, symbols already
    existing in substitutions_dict may be used by those definitions.
    """
    template = _get_jinja_environment(substitutions_dict).get_template(filename)
    all_symbols = template.make_module(substitutions_dict).__dict__
    for name, symbol in all_symbols.items():
        if name.startswith("_"):
            continue
        substitutions_dict[name] = symbol


def process_file(filepath, substitutions_dict):
    """
    Process the jinja file at the given path with the specified
    substitutions. Return the result as a string. Note that this will not
    load the project macros; use process_file_with_macros(...) for that.
    """
    filepath = os.path.abspath(filepath)
    template = _get_jinja_environment(substitutions_dict).get_template(filepath)
    return template.render(substitutions_dict)


def add_python_functions(substitutions_dict):
    substitutions_dict['prodtype_to_name'] = prodtype_to_name
    substitutions_dict['name_to_platform'] = name_to_platform
    substitutions_dict['prodtype_to_platform'] = prodtype_to_platform
    substitutions_dict['url_encode'] = url_encode
    substitutions_dict['raise'] = raise_exception


def load_macros(substitutions_dict=None):
    """
    Augment the substitutions_dict dict with project Jinja macros in /shared/.
    """
    if substitutions_dict is None:
        substitutions_dict = dict()

    add_python_functions(substitutions_dict)
    try:
        update_substitutions_dict(JINJA_MACROS_BASE_DEFINITIONS, substitutions_dict)
        update_substitutions_dict(JINJA_MACROS_HIGHLEVEL_DEFINITIONS, substitutions_dict)
        update_substitutions_dict(JINJA_MACROS_ANSIBLE_DEFINITIONS, substitutions_dict)
        update_substitutions_dict(JINJA_MACROS_BASH_DEFINITIONS, substitutions_dict)
        update_substitutions_dict(JINJA_MACROS_OVAL_DEFINITIONS, substitutions_dict)
        update_substitutions_dict(JINJA_MACROS_IGNITION_DEFINITIONS, substitutions_dict)
        update_substitutions_dict(JINJA_MACROS_KUBERNETES_DEFINITIONS, substitutions_dict)
    except Exception as exc:
        msg = ("Error extracting macro definitions: {0}"
               .format(str(exc)))
        raise RuntimeError(msg)

    return substitutions_dict


def process_file_with_macros(filepath, substitutions_dict):
    """
    Process the file with jinja macros at the given path with the specified
    substitutions. Return the result as a string.

    See also: process_file
    """
    substitutions_dict = load_macros(substitutions_dict)
    assert 'indent' not in substitutions_dict
    return process_file(filepath, substitutions_dict)


def url_encode():
    source="""#	$OpenBSD: sshd_config,v 1.103 2018/04/09 20:41:22 tj Exp $

# This is the sshd server system-wide configuration file.  See
# sshd_config(5) for more information.

# This sshd was compiled with PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin

# The strategy used for options in the default sshd_config shipped with
# OpenSSH is to specify options with their default value where
# possible, but leave them commented.  Uncommented options override the
# default value.

# If you want to change the port on a SELinux system, you have to tell
# SELinux about this change.
# semanage port -a -t ssh_port_t -p tcp #PORTNUMBER
#
#Port 22
#AddressFamily any
#ListenAddress 0.0.0.0
#ListenAddress ::

HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key

# Ciphers and keying
RekeyLimit 512M 1h

# System-wide Crypto policy:
# This system is following system-wide crypto policy. The changes to
# Ciphers, MACs, KexAlgoritms and GSSAPIKexAlgorithsm will not have any
# effect here. They will be overridden by command-line options passed on
# the server start up.
# To opt out, uncomment a line with redefinition of  CRYPTO_POLICY=
# variable in  /etc/sysconfig/sshd  to overwrite the policy.
# For more information, see manual page for update-crypto-policies(8).

# Logging
#SyslogFacility AUTH
SyslogFacility AUTHPRIV
#LogLevel INFO

# Authentication:

#LoginGraceTime 2m
PermitRootLogin no
StrictModes yes
#MaxAuthTries 6
#MaxSessions 10

PubkeyAuthentication yes

# The default is to check both .ssh/authorized_keys and .ssh/authorized_keys2
# but this is overridden so installations will only check .ssh/authorized_keys
AuthorizedKeysFile	.ssh/authorized_keys

#AuthorizedPrincipalsFile none

#AuthorizedKeysCommand none
#AuthorizedKeysCommandUser nobody

# For this to work you will also need host keys in /etc/ssh/ssh_known_hosts
HostbasedAuthentication no
# Change to yes if you don't trust ~/.ssh/known_hosts for
# HostbasedAuthentication
IgnoreUserKnownHosts yes
# Don't read the user's ~/.rhosts and ~/.shosts files
IgnoreRhosts yes

# To disable tunneled clear text passwords, change to no here!
#PasswordAuthentication yes
PermitEmptyPasswords no
PasswordAuthentication no

# Change to no to disable s/key passwords
#ChallengeResponseAuthentication yes
ChallengeResponseAuthentication no

# Kerberos options
KerberosAuthentication no
#KerberosOrLocalPasswd yes
#KerberosTicketCleanup yes
#KerberosGetAFSToken no
#KerberosUseKuserok yes

# GSSAPI options
GSSAPIAuthentication no
GSSAPICleanupCredentials no
#GSSAPIStrictAcceptorCheck yes
#GSSAPIKeyExchange no
#GSSAPIEnablek5users no

# Set this to 'yes' to enable PAM authentication, account processing,
# and session processing. If this is enabled, PAM authentication will
# be allowed through the ChallengeResponseAuthentication and
# PasswordAuthentication.  Depending on your PAM configuration,
# PAM authentication via ChallengeResponseAuthentication may bypass
# the setting of "PermitRootLogin without-password".
# If you just want the PAM account and session checks to run without
# PAM authentication, then enable this but set PasswordAuthentication
# and ChallengeResponseAuthentication to 'no'.
# WARNING: 'UsePAM no' is not supported in Fedora and may cause several
# problems.
UsePAM yes

#AllowAgentForwarding yes
#AllowTcpForwarding yes
#GatewayPorts no
X11Forwarding yes
#X11DisplayOffset 10
#X11UseLocalhost yes
#PermitTTY yes

# It is recommended to use pam_motd in /etc/pam.d/sshd instead of PrintMotd,
# as it is more configurable and versatile than the built-in version.
PrintMotd no

PrintLastLog yes
#TCPKeepAlive yes
PermitUserEnvironment no
Compression no
ClientAliveInterval 600
ClientAliveCountMax 0
#UseDNS no
#PidFile /var/run/sshd.pid
#MaxStartups 10:30:100
#PermitTunnel no
#ChrootDirectory none
#VersionAddendum none

# no default banner path
Banner /etc/issue

# Accept locale-related environment variables
AcceptEnv LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES
AcceptEnv LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT
AcceptEnv LC_IDENTIFICATION LC_ALL LANGUAGE
AcceptEnv XMODIFIERS

# override default of no subsystems
Subsystem	sftp	/usr/libexec/openssh/sftp-server

# Example of overriding settings on a per-user basis
#Match User anoncvs
#	X11Forwarding no
#	AllowTcpForwarding no
#	PermitTTY no
#	ForceCommand cvs server

UsePrivilegeSeparation sandbox
"""

    return quote(source)
