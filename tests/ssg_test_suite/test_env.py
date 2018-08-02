from __future__ import print_function

import contextlib
import sys

import docker

import ssg_test_suite
from ssg_test_suite.virt import SnapshotStack


class TestEnv(object):
    def __init__(self):
        self.domain_ip = ""

    def start(self):
        pass

    def finalize(self):
        pass

    def _get_snapshot(self, snapshot_name):
        raise NotImplementedError()

    def _revert_snapshot(self, snapshot_name):
        raise NotImplementedError()

    @contextlib.contextmanager
    def in_layer(self, snapshot_name, delete=True):
        snapshot = self._get_snapshot(snapshot_name)
        exception_to_reraise = None
        try:
            yield snapshot
        except KeyboardInterrupt as exc:
            print("Hang on for a minute, cleaning up the snapshot '{0}'."
                  .format(snapshot_name), file=sys.stderr)
            exception_to_reraise = exc
        finally:
            try:
                self._revert_snapshot(snapshot)
            except KeyboardInterrupt as exc:
                print("Hang on for a minute, cleaning up the snapshot '{0}'."
                      .format(snapshot_name), file=sys.stderr)
                self._revert_snapshot(snapshot)
            finally:
                if exception_to_reraise:
                    raise exception_to_reraise


class VMTestEnv(TestEnv):
    name = "libvirt-based"

    def __init__(self, hypervisor, domain_name):
        super(VMTestEnv, self).__init__()

        self.hypervisor = hypervisor
        self.domain_name = domain_name
        self.snapshot_stack = None

    def start(self):
        dom = ssg_test_suite.virt.connect_domain(
            self.hypervisor, self.domain_name)
        self.snapshot_stack = SnapshotStack(dom)

        ssg_test_suite.virt.start_domain(dom)
        self.domain_ip = ssg_test_suite.virt.determine_ip(dom)

    def _get_snapshot(self, snapshot_name):
        return self.snapshot_stack.create(snapshot_name)

    def _revert_snapshot(self, snapshot):
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

    @property
    def current_container(self):
        if self.containers:
            return self.containers[-1]
        return None

    def _create_new_image(self, from_container, name):
        new_image_name = "{0}_{1}".format(self.base_image, name)
        from_container.commit(repository=new_image_name)
        self.created_images.append(new_image_name)
        return new_image_name

    def _new_container(self, name):
        if self.containers:
            img = self._create_new_image(self.containers[-1], name)
        else:
            img = self.base_image
        return self.client.containers.run(
            img, "/usr/sbin/sshd -D",
            name="{0}_{1}".format(self._name_stem, name), ports={"22": None},
            detach=True)

    def _get_snapshot(self, snapshot_name):
        new_container = self._new_container(snapshot_name)
        self.containers.append(new_container)

        new_container.reload()
        self.domain_ip = new_container.attrs["NetworkSettings"]["Networks"]["bridge"]["IPAddress"]

        return new_container

    def _revert_snapshot(self, snapshot):
        snapshot.stop()
        snapshot.remove()

        assert snapshot == self.containers.pop()

        if self.created_images:
            associated_image = self.created_images.pop()
            self.client.images.remove(associated_image)
