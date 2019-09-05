from __future__ import print_function

import contextlib
import sys
import os
import time
import subprocess
import json

import ssg_test_suite
from ssg_test_suite import common


class SavedState(object):
    def __init__(self, environment, name):
        self.name = name
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
            except KeyboardInterrupt as exc:
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
        self.ssh_port = 22

    def start(self):
        """
        Run the environment and
        ensure that the environment will not be permanently modified
        by subsequent procedures.
        """
        pass

    def finalize(self):
        """
        Perform the environment cleanup and shut it down.
        """
        pass

    def reset_state_to(self, state_name, new_running_state_name):
        raise NotImplementedError()

    def save_state(self, state_name):
        self.running_state_base = state_name
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

    def __init__(self, mode, hypervisor, domain_name):
        super(VMTestEnv, self).__init__(mode)

        try:
            import libvirt
        except ImportError:
            raise RuntimeError("Can't import libvirt module, libvirt backend will therefore not work.")

        self.domain = None

        self.hypervisor = hypervisor
        self.domain_name = domain_name
        self.snapshot_stack = None

        self._origin = None

    def start(self):
        from ssg_test_suite import virt

        self.domain = virt.connect_domain(
            self.hypervisor, self.domain_name)

        self.snapshot_stack = virt.SnapshotStack(self.domain)

        virt.start_domain(self.domain)
        self.domain_ip = virt.determine_ip(self.domain)

        self._origin = self._save_state("origin")

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
        state = self.snapshot_stack.create(state_name)
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
        state = self._create_new_image(self.current_container, state_name)
        return state

    def run_container(self, image_name, container_name="running"):
        new_container = self._new_container_from_image(image_name, container_name)
        self.containers.append(new_container)
        # Get the container time to fully start its service
        time.sleep(0.2)

        self.domain_ip = self._get_container_ip(new_container)
        if not self.domain_ip:
            self.domain_ip = 'localhost'
            ports = self._get_container_ports(new_container)
            if self.internal_ssh_port in ports:
                self.ssh_port = ports[self.internal_ssh_port]
        else:
            self.ssh_port = self.internal_ssh_port
        common.SSH_ADDITIONAL_OPTS = ('-o', 'Port={}'.format(self.ssh_port), ) + common.SSH_ADDITIONAL_OPTS
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

    def _get_container_ip(self, container):
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

    def _get_container_ip(self, container):
        container.reload()
        container_ip = container.attrs["NetworkSettings"]["Networks"]["bridge"]["IPAddress"]
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
            msg = "Command '{0}' returned {1}:\n{2}".format(" ".join(e.cmd), e.returncode, e.output.decode("utf-8"))
            raise RuntimeError(msg)

    def _new_container_from_image(self, image_name, container_name):
        long_name = "{0}_{1}".format(self._name_stem, container_name)
        podman_cmd = ["podman", "run", "--name", long_name,
                      "--publish", "{}".format(self.internal_ssh_port), "--detach", image_name,
                      "/usr/sbin/sshd", "-p", "{}".format(self.internal_ssh_port), "-D"]
        try:
            podman_output = subprocess.check_output(podman_cmd, stderr=subprocess.STDOUT)
        except subprocess.CalledProcessError as e:
            msg = "Command '{0}' returned {1}:\n{2}".format(" ".join(e.cmd), e.returncode, e.output.decode("utf-8"))
            raise RuntimeError(msg)
        container_id = podman_output.decode("utf-8").strip()
        return container_id

    def _get_container_ip(self, container):
        podman_cmd = ["podman", "inspect", container, "--format", "{{.NetworkSettings.IPAddress}}"]
        try:
            podman_output = subprocess.check_output(podman_cmd, stderr=subprocess.STDOUT)
        except subprocess.CalledProcessError as e:
            msg = "Command '{0}' returned {1}:\n{2}".format(" ".join(e.cmd), e.returncode, e.output.decode("utf-8"))
            raise RuntimeError(msg)
        ip_address = podman_output.decode("utf-8").strip()
        return ip_address

    def _get_container_ports(self, container):
        podman_cmd = ["podman", "inspect", container, "--format", "{{json .NetworkSettings.Ports}}"]
        try:
            podman_output = subprocess.check_output(podman_cmd, stderr=subprocess.STDOUT)
        except subprocess.CalledProcessError as e:
            msg = "Command '{0}' returned {1}:\n{2}".format(" ".join(e.cmd), e.returncode, e.output.decode("utf-8"))
            raise RuntimeError(msg)
        ports = {}
        for pb in json.loads(podman_output):
            ports[pb['containerPort']] = pb['hostPort']
        return ports

    def _terminate_current_running_container_if_applicable(self):
        if self.containers:
            running_state = self.containers.pop()
            podman_cmd = ["podman", "stop", running_state]
            try:
                subprocess.check_output(podman_cmd, stderr=subprocess.STDOUT)
            except subprocess.CalledProcessError as e:
                msg = "Command '{0}' returned {1}:\n{2}".format(" ".join(e.cmd), e.returncode, e.output.decode("utf-8"))
                raise RuntimeError(msg)
            podman_cmd = ["podman", "rm", running_state]
            try:
                subprocess.check_output(podman_cmd, stderr=subprocess.STDOUT)
            except subprocess.CalledProcessError as e:
                msg = "Command '{0}' returned {1}:\n{2}".format(" ".join(e.cmd), e.returncode, e.output.decode("utf-8"))
                raise RuntimeError(msg)

    def _remove_image(self, image):
        podman_cmd = ["podman", "rmi", image]
        try:
            subprocess.check_output(podman_cmd, stderr=subprocess.STDOUT)
        except subprocess.CalledProcessError as e:
            msg = "Command '{0}' returned {1}:\n{2}".format(" ".join(e.cmd), e.returncode, e.output.decode("utf-8"))
            raise RuntimeError(msg)

    def _local_oscap_check_base_arguments(self):
        raise NotImplementedError("OpenSCAP doesn't support offline scanning of Podman Containers")
