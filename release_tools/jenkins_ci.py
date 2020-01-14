import argparse
import jenkins
import json
import os
import shutil
import sys
import urllib.request


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

    build_job_names = ['scap-security-guide-docs',
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
                print("Job {} is failing, it needs to be passing for the release".format(job_name))
            else:
                print("Job {} is passing".format(job_name))
        return all_green

    def _trigger_build_job(self, job_name, build_parameters):
        next_build_number = self.server.get_job_info(job_name)['nextBuildNumber']
        self.server.build_job(job_name)
        self.build_ids[job_name] = next_build_number
        self._save_build_ids()

    def _get_build_status(self, job_name, build_number):
        try:
            build_info = self.server.get_build_info(job_name, build_number)
            if build_info['building']:
                return 'building'
            else:
                return 'built'
        except jenkins.NotFoundException:
            return 'not found'

    def build_jobs_for_release(self, build_parameters=None):
        queue = self.server.get_queue_info()
        all_built = True

        for job_name in self.build_job_names:
            build_number = self.build_ids.get(job_name)

            if build_number is None:
                # Trigger build
                self._trigger_build_job(job_name, build_parameters)
                print("Building job {}".format(job_name))
                all_built = False
            else:
                build_status = self._get_build_status(job_name, build_number)
                if build_status == 'building':
                    print("Build for {} is still running".format(job_name))
                    all_built = False
                elif build_status == 'built':
                    print("Build for {} is finished".format(job_name))
                elif build_status == 'not found':
                    all_built = False
                    found = False
                    for queue_item in queue:
                        if queue_item['task']['name'] == job_name:
                            print("Build for {} is in the queue".format(job_name))
                            print("\t" + queue_item['why'])
                            found = True
                            break
                    if not found:
                        print("Build for {} is in unknown state".format(job_name))
        return all_built

    def _download_artifact(self, build_info, version):
        filename = build_info['artifacts'][0]['fileName']
        save_filename = filename.replace('nightly', version)
        url = build_info['url'] + 'artifact/' + filename
        print(f"Downloading {filename} to {self.artifacts_dir}{save_filename}")
        urllib.request.urlretrieve(url, self.artifacts_dir + save_filename)

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
