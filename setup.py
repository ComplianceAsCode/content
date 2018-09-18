from setuptools import setup

setup(name='ssg',
      version='0.1',
      description='SCAP Security Guide build and utilities module for generating compliance content',
      url='http://github.com/OpenSCAP/scap-security-guide',
      author='The OpenSCAP Team',
      author_email='open-scap-list@redhat.com',
      license='BSD',
      packages=['ssg'],
      install_requires=['jinja2', 'PyYAML'],
      zip_safe=False)
