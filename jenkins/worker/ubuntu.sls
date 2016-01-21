# http://russell.ballestrini.net/securely-publish-jenkins-build-artifacts-on-salt-master/
# manage jenkins user, home dir, and Jenkins "master" public SSH key.
jenkins:
  user.present:
    - fullname: jenkins butler
    - shell: /bin/bash
    - home: /home/jenkins

  file.directory:
    - name: /home/jenkins
    - user: jenkins
    - group: jenkins
    - require:
      - user: jenkins

  ssh_auth.present:
    - user: jenkins
    - name: {{ pillar.get('jenkins-public-key') }}
    - require:
      - user: jenkins

# Manage a script to push artifacts to Salt Master.
# Note: jenkins user should _not_ have ability to change this file.
/home/jenkins/salt-call-put-artifacts-onto-salt-master.sh:
  file.managed:
    - user: root
    - group: root
    - mode: 755
    - contents: |
        echo salt-call cp.push_dir "$PWD" glob='*.tar.gz'
        salt-call cp.push_dir "$PWD" glob='*.tar.gz'
        echo salt-call cp.push "$PWD/commit-hash.txt"
        salt-call cp.push "$PWD/commit-hash.txt"
        echo salt-call cp.push "$PWD/build-hashes.txt"
        salt-call cp.push "$PWD/build-hashes.txt"
    - require:
      - file: jenkins

# Allow jenkins to run push script as root via sudo.
jenkins-sudoers:
  file.append:
    - name: /etc/sudoers
    - text:
      - "jenkins    ALL = NOPASSWD: /home/jenkins/salt-call-put-artifacts-onto-salt-master.sh"

# Ubuntu System Packages needed to compile and build things.
jenkins-ubuntu-system-depends:
  pkg.installed:
    - names:
      # python virtualenvs are great for sandboxing.
      - python-virtualenv
      # python dev headers for compiling some python libraries.
      - python-dev
      # libffi-dev headers ffi.h required to build bcrypt.
      - libffi-dev
      # headers and configs needed to compile MySQL-python.
      - libmysqlclient-dev
      # required to pip install psycopg2 (PostgreSQL Driver).
      - postgresql-server-dev-all
