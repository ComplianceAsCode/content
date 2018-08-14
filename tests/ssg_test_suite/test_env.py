from __future__ import print_function

import contextlib
import sys

import time
import logging

import docker

import ssg_test_suite
from ssg_test_suite.virt import SnapshotStack


class SavedState(object):
    def __init__(self, environment, name):
        self.name = name
        self.environment = environment
        self.initial_running_state = True

    def map_on_top(self, function, args_list):
        current_running_state = self.initial_running_state
        function(* args_list[0])
        for args in args_list[1:]:
            current_running_state = self.environment.reset_state_to(self.name)
            function(* args)

    @classmethod
    @contextlib.contextmanager
    def create_from_environment(cls, environment, state_name):
        state = cls(environment, state_name)

        state_handle = environment._save_state(state_name)
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
    def __init__(self):
        self.running_state_base = None
        self.running_state = None

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

    def _save_state(self, state_name):
        self.running_state_base = state_name
        running_state = self.running_state

        return None

    def _delete_saved_state(self, state_name):
        raise NotImplementedError()

    def _stop_state(self, state):
        pass

    @contextlib.contextmanager
    def run_state(self, state_name, try_to_use_current_state=True):
        if try_to_use_current_state and state_name == self.running_state_base:
            running_state = self.running_state
            self.running_state_base = None
        else:
            self.running_state = None
            running_state = self.get_running_state(state_name)

        try:
            yield running_state
        except KeyboardInterrupt as exc:
            print("Hang on for a minute, aborting the running state '{0}'."
                  .format(state_name), file=sys.stderr)
            exception_to_reraise = exc
        finally:
            try:
                self._stop_state(running_state)
            except KeyboardInterrupt as exc:
                print("Hang on for a minute, aborting the running state '{0}'."
                      .format(state_name), file=sys.stderr)
                self._stop_state(running_state)
            finally:
                if exception_to_reraise:
                    raise exception_to_reraise

    @contextlib.contextmanager
    def save_state(self, state_name):
        snapshot = self._save_state(state_name)
        exception_to_reraise = None
        try:
            yield snapshot
        except KeyboardInterrupt as exc:
            print("Hang on for a minute, cleaning up the snapshot '{0}'."
                  .format(state_name), file=sys.stderr)
            exception_to_reraise = exc
        finally:
            try:
                self._delete_saved_state(snapshot)
            except KeyboardInterrupt as exc:
                print("Hang on for a minute, cleaning up the snapshot '{0}'."
                      .format(state_name), file=sys.stderr)
                self._delete_saved_state(snapshot)
            finally:
                if exception_to_reraise:
                    raise exception_to_reraise


class VMTestEnv(TestEnv):
    name = "libvirt-based"

    def __init__(self, hypervisor, domain_name):
        super(VMTestEnv, self).__init__()
        self.domain = None

        self.hypervisor = hypervisor
        self.domain_name = domain_name
        self.snapshot_stack = None

        self._origin = None

    def start(self):
        self.domain = ssg_test_suite.virt.connect_domain(
            self.hypervisor, self.domain_name)
        self.snapshot_stack = SnapshotStack(self.domain)

        ssg_test_suite.virt.start_domain(self.domain)
        self.domain_ip = ssg_test_suite.virt.determine_ip(self.domain)

        self._origin = self._save_state("origin")

    def finalize(self):
        self._delete_saved_state(self._origin)
        # self.domain.shutdown()
        # logging.debug('Shut the domain off')

    def reset_state_to(self, state_name):
        last_snapshot_name = self.snapshot_stack.snapshot_stack[-1].getName()
        assert last_snapshot_name == state_name, (
            "You can only revert to the last snapshot, which is {0}, not {1}"
            .format(last_snapshot_name, state_name))
        state = self.snapshot_stack.revert(delete=False)
        return state

    def discard_running_state(self, state_handle):
        pass

    def _save_state(self, state_name):
        super(VMTestEnv, self)._save_state(state_name)
        state = self.snapshot_stack.create(state_name)
        return state

    def _delete_saved_state(self, snapshot):
        self.snapshot_stack.revert()


class DockerTestEnv(TestEnv):
    name = "container-based"

    def __init__(self, image_name):
        super(DockerTestEnv, self).__init__()

        self._name_stem = "ssg_test"

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

        self.base_image = image_name
        self.created_images = []
        self.containers = []

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
        from_container.commit(repository=new_image_name)
        self.created_images.append(new_image_name)
        return new_image_name

    def _save_state(self, state_name):
        super(DockerTestEnv, self)._save_state(state_name)
        state = self._create_new_image(self.current_container, state_name)
        return state

    def run_container(self, image_name, container_name="running"):
        new_container = self._new_container_from_image(image_name, container_name)
        self.containers.append(new_container)

        new_container.reload()
        self.domain_ip = new_container.attrs["NetworkSettings"]["Networks"]["bridge"]["IPAddress"]

        return new_container

    def reset_state_to(self, state_name):
        self._terminate_current_running_container_if_applicable()
        image_name = self.image_stem2fqn(state_name)

        new_container = self.run_container(image_name)

        return new_container

    def _find_image_by_name(self, image_name):
        return self.client.images.get(image_name)

    def _new_container_from_image(self, image_name, container_name):
        img = self._find_image_by_name(image_name)
        result = self.client.containers.run(
            img, "/usr/sbin/sshd -D",
            name="{0}_{1}".format(self._name_stem, container_name), ports={"22": None},
            detach=True)
        return result

    def _terminate_current_running_container_if_applicable(self):
        if self.containers:
            running_state = self.containers.pop()
            running_state.stop()
            running_state.remove()

    def _delete_saved_state(self, image):
        self._terminate_current_running_container_if_applicable()

        assert self.created_images

        associated_image = self.created_images.pop()
        assert associated_image == image
        self.client.images.remove(associated_image)

    def discard_running_state(self, state_handle):
        self._terminate_current_running_container_if_applicable()
