import argparse
import jenkins
import json
import os
import shutil
import sys
import urllib.request

from time import sleep


class JenkinsCI(object):
    JENKINS_URL = "https://jenkins.complianceascode.io/"
    build_ids_file = ".jenkins_builds"
    artifacts_dir = "artifacts/"

    # Latest builds were probably run on master, and not on stabilization branch.
    # But checking them provides us a certain level of assurance
    green_job_names = ['scap-security-guide',
                       'scap-security-guide-linkcheck',
                       'scap-security-guide-lint-check',
                       'scap-security-guide-scapval-scap-1.2',
                       'scap-security-guide-scapval-scap-1.3',
                       'scap-security-guide-nightly-zip',
                       'scap-security-guide-nightly-oval510-zip']

    build_job_names = ['scap-security-guide-docs-and-tarball',
                       'scap-security-guide-nightly-zip',
                       'scap-security-guide-nightly-oval510-zip']

    def _load_build_ids(self):
        try:
            with open(self.build_ids_file, "r") as queue_file:
                self.build_ids = json.loads(queue_file.read())
        except FileNotFoundError:
            self.build_ids = {}

    def _save_build_ids(self):
        with open(self.build_ids_file, "w") as queue_file:
            queue_file.write(json.dumps(self.build_ids))

    def __init__(self, username, password):
        self.server = jenkins.Jenkins(self.JENKINS_URL, username=username, password=password)

        self._load_build_ids()

    def _get_last_build_status(self, job_name):
        last_build_number = self.server.get_job_info(job_name)['lastBuild']['number']
        last_build = self.server.get_build_info(job_name, last_build_number)
        return last_build['result']

    def check_all_green(self):
        all_green = True
        for job_name in self.green_job_names:
            job_result = self._get_last_build_status(job_name)
            if job_result != 'SUCCESS':
                all_green = False
                print("Job {} is failing, verify if it release can proceed.".format(job_name))
            else:
                print("Job {} is passing".format(job_name))
        return all_green

    def _trigger_build_job(self, job_name, build_parameters):
        next_build_number = self.server.get_job_info(job_name)['nextBuildNumber']
        self.server.build_job(job_name, build_parameters)
        self.build_ids[job_name] = next_build_number
        self._save_build_ids()

        return next_build_number

    def _get_build_status(self, job_name, build_number):
        try:
            build_info = self.server.get_build_info(job_name, build_number)
            if build_info['building']:
                return 'building'
            else:
                return 'built'
        except jenkins.NotFoundException:
            return 'not found'

    def get_queue_item(self, job_name):
        queue = self.server.get_queue_info()

        found = False
        for queue_item in queue:
            if queue_item['task']['name'] == job_name:
                return queue_item
        return None

    def query_status_of_queue_item(self, job_name):
        queue_item = self.get_queue_item(job_name)
        if queue_item:
            # build has not started yet, and is waiting in the queue
            print("Build for {} is in the \033[33mqueue\033[m".format(job_name))
            print("\t" + queue_item['why'])
        else:
            print("Build for {} is in \033[31munknown state\033[m".format(job_name))

    # May throw jenkins.NotFoundException
    def query_status_of_build_job(self, job_name, build_number):
        build_info = self.server.get_build_info(job_name, build_number)
        if build_info['building']:
            print(f"Build for {job_name} is still \033[33mrunning\033[m: {build_info['url']}")
            return 'building'
        else:
            print(f"Build for {job_name} is \033[32mfinished\033[m: {build_info['url']}")
            return 'built'

    def build_jobs_for_release(self, build_parameters=None):
        all_built = True

        for job_name in self.build_job_names:
            build_number = self.build_ids.get(job_name)

            if build_number is None:
                all_built = False

                # Trigger build
                build_number = self._trigger_build_job(job_name, build_parameters)
                # It may take a while for Jenkins to create and start the build
                sleep(10)
                try:
                    build_info = self.server.get_build_info(job_name, build_number)
                    print(f"Building job {job_name}: {build_info['url']}")
                except jenkins.NotFoundException:
                    self.query_status_of_queue_item(job_name)
            else:
                try:
                    build_status = self.query_status_of_build_job(job_name, build_number)
                    if build_status == 'building':
                        all_built = False
                except jenkins.NotFoundException:
                    # If build is not running, it may be waiting
                    self.query_status_of_queue_item(job_name)
                    all_built = False
        return all_built

    def _download_artifact(self, build_info, version):
        artifacts = build_info['artifacts']
        for i in range(len(artifacts)):
            filename = build_info['artifacts'][i]['fileName']
            # zip files are created with nightly version
            # while the tarball already contains the version number
            filename_save = filename
            if 'nightly' in filename:
                filename_save = filename.replace('nightly', version)

            url = build_info['url'] + 'artifact/' + filename
            print(f"Downloading {filename} to {self.artifacts_dir}{filename_save}")
            try:
                urllib.request.urlretrieve(url, self.artifacts_dir + filename_save)
            except urllib.error.HTTPError:
                print(f"Artifact at {url} was not found")

    def _download_job_artifact(self, job_name, build_number, version):
        build_info = self.server.get_build_info(job_name, build_number)
        self._download_artifact(build_info, version)

    def download_release_artifacts(self, version):
        try:
            os.mkdir(self.artifacts_dir)
        except FileExistsError:
            pass

        for job_name in self.build_ids:
            build_number = self.build_ids.get(job_name)
            build_status = self._get_build_status(job_name, build_number)
            if build_status == 'built':
                self._download_job_artifact(job_name, build_number, version)
            else:
                print("Build for {} is not fininished".format(job_name))
                print("\tRun 'build' action to check status of {}".format(job_name))

    def forget_release_builds(self):
        print("Forgetting release builds ids")
        try:
            os.unlink(self.build_ids_file)
        except FileNotFoundError:
            pass
        print("Deleting build artifacts")
        shutil.rmtree(self.artifacts_dir, ignore_errors=True)


def create_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument('--jenkins-user', dest='user',
                        help="Jenkins user ID, this is available in your"
                             "personal profile page")
    parser.add_argument('--jenkins-token', dest='token',
                        help="Jenkins token, this token is available in your"
                             "personal configuration page")
    parser.add_argument('--version',
                        help="version to use when downloading assets")
    parser.add_argument('action', choices=['check', 'build', 'download', 'clean'],
                        help="Command to perform")
    return parser.parse_args()


if __name__ == "__main__":
    parser = create_parser()

    jenkins_ci = JenkinsCI(username=parser.user, password=parser.token)

    if parser.action == 'check':
        all_green = jenkins_ci.check_all_green()

    # Builds the zip files and static docs
    if parser.action == 'build':
        if not jenkins_ci.build_jobs_for_release():
            sys.exit(1)

    if parser.action == 'download':
        jenkins_ci.download_release_artifacts(parser.version)

    if parser.action == 'clean':
        jenkins_ci.forget_release_builds()
