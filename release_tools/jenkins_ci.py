import argparse
import jenkins


class JenkinsCI(object):
    JENKINS_URL="https://jenkins.complianceascode.io/"

    green_job_names = ['scap-security-guide',
                       'scap-security-guide-scapval-scap-1.2',
                       'scap-security-guide-scapval-scap-1.3',
                       'scap-security-guide-nightly-zip',
                       'scap-security-guide-nightly-oval510-zip']

    def __init__(self,username, password):
        self.server = jenkins.Jenkins(self.JENKINS_URL, username=username, password=password)

    def _get_last_build_status(self, job_name):
        last_build_number = self.server.get_job_info(job_name)['lastBuild']['number']
        last_build = self.server.get_build_info(job_name,last_build_number)
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
    parser.add_argument('action', choices=['check'],
                        help="Command to perform")
    return parser.parse_args()

if __name__ == "__main__":
    parser = create_parser()

    jenkins_ci = JenkinsCI(username=parser.user, password=parser.token)

    if parser.action == 'check':
        all_green = jenkins_ci.check_all_green()
