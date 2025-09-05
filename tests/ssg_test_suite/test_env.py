from __future__ import print_function

import contextlib
import sys
import os
import re
import time
import subprocess
import json
import logging

import ssg_test_suite
from ssg_test_suite import common


class SavedState(object):
    def __init__(self, environment, name):
        self.name = common.get_prefixed_name(name)
        self.environment = environment
        self.initial_running_state = True

    def map_on_top(self, function, args_list):
        if not args_list:
            return
        current_running_state = self.initial_running_state
        function(* args_list[0])
        for idx, args in enumerate(args_list[1:], 1):
            current_running_state = self.environment.reset_state_to(
                self.name, "running_%d" % idx)
            function(* args)
        current_running_state = self.environment.reset_state_to(
            self.name, "running_last")

    @classmethod
    @contextlib.contextmanager
    def create_from_environment(cls, environment, state_name):
        state = cls(environment, state_name)

        state_handle = environment.save_state(state_name)
        exception_to_reraise = None
        try:
            yield state
        except KeyboardInterrupt as exc:
            print("Hang on for a minute, cleaning up the saved state '{0}'."
                  .format(state_name), file=sys.stderr)
            exception_to_reraise = exc
        finally:
            try:
                environment._delete_saved_state(state_handle)
            except KeyboardInterrupt:
                print("Hang on for a minute, cleaning up the saved state '{0}'."
                      .format(state_name), file=sys.stderr)
                environment._delete_saved_state(state_handle)
            finally:
                if exception_to_reraise:
                    raise exception_to_reraise


class TestEnv(object):
    def __init__(self, scanning_mode):
        self.running_state_base = None
        self.running_state = None

        self.scanning_mode = scanning_mode
        self.backend = None
        self.ssh_port = None

        self.domain_ip = None
        self.ssh_additional_options = []

        self.product = None

        self.have_local_oval_graph = False
        try:
            p = subprocess.run(['arf-to-graph', '--version'],
                               stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            if p.returncode == 0:
                self.have_local_oval_graph = True
        except FileNotFoundError:
            # There is no arf-to-graph - in that case the proces can't be even started,
            # not to mention return codes.
            pass

    def arf_to_html(self, arf_filename):
        if not self.have_local_oval_graph:
            return

        html_filename = re.sub(r"\barf\b", "graph", arf_filename)
        html_filename = re.sub(r".xml", ".html", html_filename)

        cmd = ['arf-to-graph', '--all-in-one', '--output', html_filename, arf_filename, '.']
        p = subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
        if p.returncode != 0:
            print("Error generating OVAL check summaries: {stderr}".format(stderr=p.stderr),
                  file=sys.stderr)

    def start(self):
        """
        Run the environment and
        ensure that the environment will not be permanently modified
        by subsequent procedures.
        """
        self.refresh_connection_parameters()

    def refresh_connection_parameters(self):
        self.domain_ip = self.get_ip_address()
        self.ssh_port = self.get_ssh_port()
        self.ssh_additional_options = self.get_ssh_additional_options()

    def get_ip_address(self):
        raise NotImplementedError()

    def get_ssh_port(self):
        return 22

    def get_ssh_additional_options(self):
        return list(common.SSH_ADDITIONAL_OPTS)

    def execute_ssh_command(self, command, log_file, error_msg_template=None):
        """
        Args:
            - command: Command to execute remotely as a single string
            - log_file
            - error_msg_template: A string that can contain references to:
                ``command``, ``remote_dest``, ``rc``, and ``stderr``
        """
        if not error_msg_template:
            error_msg_template = "Return code of '{command}' on {remote_dest} is {rc}: {stderr}"
        remote_dest = "root@{ip}".format(ip=self.domain_ip)
        result = common.retry_with_stdout_logging(
            "ssh", tuple(self.ssh_additional_options) + (remote_dest, command), log_file)
        if result.returncode:
            error_msg = error_msg_template.format(
                command=command, remote_dest=remote_dest,
                rc=result.returncode, stderr=result.stderr)
            raise RuntimeError(error_msg)
        return result.stdout

    def scp_download_file(self, source, destination, log_file, error_msg=None):
        scp_src = "root@{ip}:{source}".format(ip=self.domain_ip, source=source)
        return self.scp_transfer_file(scp_src, destination, log_file, error_msg)

    def scp_upload_file(self, source, destination, log_file, error_msg=None):
        scp_dest = "root@{ip}:{dest}".format(ip=self.domain_ip, dest=destination)
        return self.scp_transfer_file(source, scp_dest, log_file, error_msg)

    def scp_transfer_file(self, source, destination, log_file, error_msg=None):
        if not error_msg:
            error_msg = (
                "Failed to copy {source} to {destination}"
                .format(source=source, destination=destination))
        try:
            result = common.run_with_stdout_logging(
                "scp", tuple(self.ssh_additional_options) + (source, destination), log_file)
        except Exception as exc:
            error_msg = error_msg + ": " + str(exc)
            logging.error(error_msg)
            raise RuntimeError(error_msg)

    def finalize(self):
        """
        Perform the environment cleanup and shut it down.
        """
        pass

    def reset_state_to(self, state_name, new_running_state_name):
        raise NotImplementedError()

    def save_state(self, state_name):
        self.running_state_base = common.get_prefixed_name(state_name)
        running_state = self.running_state
        return self._save_state(state_name)

    def _delete_saved_state(self, state_name):
        raise NotImplementedError()

    def _stop_state(self, state):
        pass

    def _oscap_ssh_base_arguments(self):
        full_hostname = 'root@{}'.format(self.domain_ip)
        return ['oscap-ssh', full_hostname, "{}".format(self.ssh_port), 'xccdf', 'eval']

    def scan(self, args, verbose_path):
        if self.scanning_mode == "online":
            return self.online_scan(args, verbose_path)
        elif self.scanning_mode == "offline":
            return self.offline_scan(args, verbose_path)
        else:
            msg = "Invalid scanning mode {mode}".format(mode=self.scanning_mode)
            raise KeyError(msg)

    def online_scan(self, args, verbose_path):
        os.environ["SSH_ADDITIONAL_OPTIONS"] = " ".join(common.SSH_ADDITIONAL_OPTS)
        command_list = self._oscap_ssh_base_arguments() + args
        return common.run_cmd_local(command_list, verbose_path)

    def offline_scan(self, args, verbose_path):
        raise NotImplementedError()


class VMTestEnv(TestEnv):
    name = "libvirt-based"

    def __init__(self, mode, hypervisor, domain_name, keep_snapshots):
        super(VMTestEnv, self).__init__(mode)

        try:
            import libvirt
        except ImportError:
            raise RuntimeError("Can't import libvirt module, libvirt backend will "
                               "therefore not work.")

        self.domain = None

        self.hypervisor = hypervisor
        self.domain_name = domain_name
        self.snapshot_stack = None
        self.keep_snapshots = keep_snapshots

        self._origin = None

    def has_test_suite_prefix(self, snapshot_name):
        if str(snapshot_name).startswith(common.TEST_SUITE_PREFIX):
            return True
        return False

    def snapshot_lookup(self, snapshot_name):
        return self.domain.snapshotLookupByName(snapshot_name)

    def snapshots_cleanup(self):
        snapshot_list = self.domain.snapshotListNames()
        for snapshot_name in snapshot_list:
            if self.has_test_suite_prefix(snapshot_name):
                snapshot = self.snapshot_lookup(snapshot_name)
                snapshot.delete()

    def start(self):
        from ssg_test_suite import virt

        self.domain = virt.connect_domain(
            self.hypervisor, self.domain_name)

        if self.domain is None:
            sys.exit(1)

        if not self.keep_snapshots:
            self.snapshots_cleanup()

        self.snapshot_stack = virt.SnapshotStack(self.domain)

        virt.start_domain(self.domain)

        self._origin = self._save_state("origin")

        super().start()

    def get_ip_address(self):
        from ssg_test_suite import virt

        return virt.determine_ip(self.domain)

    def reboot(self):
        from ssg_test_suite import virt

        if self.domain is None:
            self.domain = virt.connect_domain(
                self.hypervisor, self.domain_name)

        virt.reboot_domain(self.domain, self.domain_ip, self.ssh_port)

    def finalize(self):
        self._delete_saved_state(self._origin)
        # self.domain.shutdown()
        # logging.debug('Shut the domain off')

    def reset_state_to(self, state_name, new_running_state_name):
        last_snapshot_name = self.snapshot_stack.snapshot_stack[-1].getName()
        assert last_snapshot_name == state_name, (
            "You can only revert to the last snapshot, which is {0}, not {1}"
            .format(last_snapshot_name, state_name))
        state = self.snapshot_stack.revert(delete=False)
        return state

    def _save_state(self, state_name):
        prefixed_state_name = common.get_prefixed_name(state_name)
        state = self.snapshot_stack.create(prefixed_state_name)
        return state

    def _delete_saved_state(self, snapshot):
        self.snapshot_stack.revert()

    def _local_oscap_check_base_arguments(self):
        return ['oscap-vm', "domain", self.domain_name, 'xccdf', 'eval']

    def offline_scan(self, args, verbose_path):
        command_list = self._local_oscap_check_base_arguments() + args

        return common.run_cmd_local(command_list, verbose_path)


class ContainerTestEnv(TestEnv):
    def __init__(self, scanning_mode, image_name):
        super(ContainerTestEnv, self).__init__(scanning_mode)
        self._name_stem = "ssg_test"
        self.base_image = image_name
        self.created_images = []
        self.containers = []
        self.domain_ip = None
        self.internal_ssh_port = 22222

    def start(self):
        self.run_container(self.base_image)
        super().start()

    def finalize(self):
        self._terminate_current_running_container_if_applicable()

    def image_stem2fqn(self, stem):
        image_name = "{0}_{1}".format(self.base_image, stem)
        return image_name

    @property
    def current_container(self):
        if self.containers:
            return self.containers[-1]
        return None

    @property
    def current_image(self):
        if self.created_images:
            return self.created_images[-1]
        return self.base_image

    def _create_new_image(self, from_container, name):
        new_image_name = self.image_stem2fqn(name)
        if not from_container:
            from_container = self.run_container(self.current_image)
        self._commit(from_container, new_image_name)
        self.created_images.append(new_image_name)
        return new_image_name

    def _save_state(self, state_name):
        prefixed_state_name = common.get_prefixed_name(state_name)
        state = self._create_new_image(self.current_container, prefixed_state_name)
        return state

    def get_ssh_port(self):
        if self.domain_ip == 'localhost':
            try:
                ports = self._get_container_ports(self.current_container)
            except Exception as exc:
                msg = (
                    "Unable to extract SSH ports from the container. "
                    "This usually means that the container backend reported its configuration "
                    "in an unexpected format."
                )
                raise RuntimeError(msg)

            if self.internal_ssh_port in ports:
                ssh_port = ports[self.internal_ssh_port]
            else:
                msg = "Unable to detect the SSH port for the container."
                raise RuntimeError(msg)
        else:
            ssh_port = self.internal_ssh_port
        return ssh_port

    def get_ssh_additional_options(self):
        ssh_additional_options = super().get_ssh_additional_options()

        # Assure that the -o option is followed by Port=<correct value> argument
        # If there is Port, assume that -o precedes it and just set the correct value
        port_opt = ['-o', 'Port={}'.format(self.ssh_port)]
        for index, opt in enumerate(ssh_additional_options):
            if opt.startswith('Port='):
                ssh_additional_options[index] = port_opt[1]

        # Put both arguments to the list of arguments if Port is not there.
        if port_opt[1] not in ssh_additional_options:
            ssh_additional_options = port_opt + ssh_additional_options
        return ssh_additional_options

    def run_container(self, image_name, container_name="running"):
        new_container = self._new_container_from_image(image_name, container_name)
        self.containers.append(new_container)
        # Get the container time to fully start its service
        time.sleep(0.2)

        self.refresh_connection_parameters()

        return new_container

    def reset_state_to(self, state_name, new_running_state_name):
        self._terminate_current_running_container_if_applicable()
        image_name = self.image_stem2fqn(state_name)

        new_container = self.run_container(image_name, new_running_state_name)

        return new_container

    def _delete_saved_state(self, image):
        self._terminate_current_running_container_if_applicable()

        assert self.created_images

        associated_image = self.created_images.pop()
        assert associated_image == image
        self._remove_image(associated_image)

    def offline_scan(self, args, verbose_path):
        command_list = self._local_oscap_check_base_arguments() + args

        return common.run_cmd_local(command_list, verbose_path)

    def _commit(self, container, image):
        raise NotImplementedError

    def _new_container_from_image(self, image_name, container_name):
        raise NotImplementedError

    def get_ip_address(self):
        raise NotImplementedError

    def _get_container_ports(self, container):
        raise NotImplementedError

    def _terminate_current_running_container_if_applicable(self):
        raise NotImplementedError

    def _remove_image(self, image):
        raise NotImplementedError

    def _local_oscap_check_base_arguments(self):
        raise NotImplementedError


class DockerTestEnv(ContainerTestEnv):
    name = "docker-based"

    def __init__(self, mode, image_name):
        super(DockerTestEnv, self).__init__(mode, image_name)
        try:
            import docker
        except ImportError:
            raise RuntimeError("Can't import the docker module, Docker backend will not work.")
        try:
            self.client = docker.from_env(version="auto")
            self.client.ping()
        except Exception as exc:
            msg = (
                "{}\n"
                "Unable to start the Docker test environment, "
                "is the Docker service started "
                "and do you have rights to access it?"
                .format(str(exc)))
            raise RuntimeError(msg)

    def _commit(self, container, image):
        container.commit(repository=image)

    def _new_container_from_image(self, image_name, container_name):
        img = self.client.images.get(image_name)
        result = self.client.containers.run(
            img, "/usr/sbin/sshd -p {} -D".format(self.internal_ssh_port),
            name="{0}_{1}".format(self._name_stem, container_name),
            ports={"{}".format(self.internal_ssh_port): None},
            detach=True)
        return result

    def get_ip_address(self):
        container = self.current_container
        container.reload()
        container_ip = container.attrs["NetworkSettings"]["Networks"]["bridge"]["IPAddress"]
        if not container_ip:
            container_ip = 'localhost'
        return container_ip

    def _terminate_current_running_container_if_applicable(self):
        if self.containers:
            running_state = self.containers.pop()
            running_state.stop()
            running_state.remove()

    def _remove_image(self, image):
        self.client.images.remove(image)

    def _local_oscap_check_base_arguments(self):
        return ['oscap-docker', "container", self.current_container.id,
                'xccdf', 'eval']

    def _get_container_ports(self, container):
        raise NotImplementedError("This method shouldn't be needed.")


class PodmanTestEnv(ContainerTestEnv):
    # TODO: Rework this class using Podman Python bindings (python3-podman)
    # at the moment when their API will provide methods to run containers,
    # commit images and inspect containers
    name = "podman-based"

    def __init__(self, scanning_mode, image_name):
        super(PodmanTestEnv, self).__init__(scanning_mode, image_name)

    def _commit(self, container, image):
        podman_cmd = ["podman", "commit", container, image]
        try:
            subprocess.check_output(podman_cmd, stderr=subprocess.STDOUT)
        except subprocess.CalledProcessError as e:
            msg = "Command '{0}' returned {1}:\n{2}".format(
                " ".join(e.cmd), e.returncode, e.output.decode("utf-8"))
            raise RuntimeError(msg)

    def _new_container_from_image(self, image_name, container_name):
        long_name = "{0}_{1}".format(self._name_stem, container_name)
        # Podman drops cap_audit_write which causes that it is not possible
        # run sshd by default. Therefore, we need to add the capability.
        # We also need cap_sys_admin so it can perform mount/umount.
        podman_cmd = ["podman", "run", "--name", long_name,
                      "--cap-add=cap_audit_write",
                      "--cap-add=cap_sys_admin",
                    #   "--privileged",
                      "--publish", "{}".format(self.internal_ssh_port), "--detach", image_name,
                      "/usr/sbin/sshd", "-p", "{}".format(self.internal_ssh_port), "-D"]
        try:
            podman_output = subprocess.check_output(podman_cmd, stderr=subprocess.STDOUT)
        except subprocess.CalledProcessError as e:
            msg = "Command '{0}' returned {1}:\n{2}".format(
                " ".join(e.cmd), e.returncode, e.output.decode("utf-8"))
            raise RuntimeError(msg)
        container_id = podman_output.decode("utf-8").strip()
        return container_id

    def get_ip_address(self):
        podman_cmd = [
                "podman", "inspect", self.current_container,
                "--format", "{{.NetworkSettings.IPAddress}}",
        ]
        try:
            podman_output = subprocess.check_output(podman_cmd, stderr=subprocess.STDOUT)
        except subprocess.CalledProcessError as e:
            msg = "Command '{0}' returned {1}:\n{2}".format(
                " ".join(e.cmd), e.returncode, e.output.decode("utf-8"))
            raise RuntimeError(msg)
        ip_address = podman_output.decode("utf-8").strip()
        if not ip_address:
            ip_address = "localhost"
        return ip_address

    def _get_container_ports(self, container):
        podman_cmd = ["podman", "inspect", container, "--format",
                      "{{json .NetworkSettings.Ports}}"]
        try:
            podman_output = subprocess.check_output(podman_cmd, stderr=subprocess.STDOUT)
        except subprocess.CalledProcessError as e:
            msg = "Command '{0}' returned {1}:\n{2}".format(
                " ".join(e.cmd), e.returncode, e.output.decode("utf-8"))
            raise RuntimeError(msg)
        return self.extract_port_map(json.loads(podman_output))

    def extract_port_map(self, podman_network_data):
        if 'containerPort' in podman_network_data:
            container_port = podman_network_data['containerPort']
            host_port = podman_network_data['hostPort']
        else:
            container_port_with_protocol, host_data = podman_network_data.popitem()
            container_port = container_port_with_protocol.split("/")[0]
            host_port = host_data[0]['HostPort']
        port_map = {int(container_port): int(host_port)}
        return port_map

    def _terminate_current_running_container_if_applicable(self):
        if self.containers:
            running_state = self.containers.pop()
            podman_cmd = ["podman", "stop", running_state]
            try:
                subprocess.check_output(podman_cmd, stderr=subprocess.STDOUT)
            except subprocess.CalledProcessError as e:
                msg = "Command '{0}' returned {1}:\n{2}".format(
                    " ".join(e.cmd), e.returncode, e.output.decode("utf-8"))
                raise RuntimeError(msg)
            podman_cmd = ["podman", "rm", running_state]
            try:
                subprocess.check_output(podman_cmd, stderr=subprocess.STDOUT)
            except subprocess.CalledProcessError as e:
                msg = "Command '{0}' returned {1}:\n{2}".format(
                    " ".join(e.cmd), e.returncode, e.output.decode("utf-8"))
                raise RuntimeError(msg)

    def _remove_image(self, image):
        podman_cmd = ["podman", "rmi", image]
        try:
            subprocess.check_output(podman_cmd, stderr=subprocess.STDOUT)
        except subprocess.CalledProcessError as e:
            msg = "Command '{0}' returned {1}:\n{2}".format(
                " ".join(e.cmd), e.returncode, e.output.decode("utf-8"))
            raise RuntimeError(msg)

    def _local_oscap_check_base_arguments(self):
        raise NotImplementedError("OpenSCAP doesn't support offline scanning of Podman Containers")
