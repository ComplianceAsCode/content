import logging
import subprocess


IGNORE_KNOWN_HOSTS_OPTIONS = (
    "-o", "StrictHostKeyChecking=no",
    "-o", "UserKnownHostsFile=/dev/null",
)


def run_cmd_local(command, verbose_path, env=None):
    command_string = ' '.join(command)
    logging.debug('Running {}'.format(command_string))
    returncode, output = _run_cmd(command, verbose_path, env)
    return returncode, output


def run_cmd_remote(command_string, domain_ip, verbose_path, env=None):
    machine = 'root@{0}'.format(domain_ip)
    remote_cmd = ['ssh'] + IGNORE_KNOWN_HOSTS_OPTIONS + [machine, command_string]
    logging.debug('Running {}'.format(command_string))
    returncode, output = _run_cmd(remote_cmd, verbose_path, env)
    return returncode, output


def _run_cmd(command_list, verbose_path, env=None):
    returncode = 0
    output = b""
    try:
        with open(verbose_path, 'w') as verbose_file:
            output = subprocess.check_output(
                command_list, stderr=verbose_file, env=env)
    except subprocess.CalledProcessError as e:
        returncode = e.returncode
        output = e.output
    return returncode, output.decode('utf-8')
