base:

  #'*':

  '*-salt*':
    - salt-master
 
  '*-web*':
    - nginx

  '*-app*':
    - uwsgi.sites
    #- postfix
    #- postfix.local

  '*-db*':
    - postgresql

  '*-mx*':
    - postfix
    - postfix.server

  '*-jenkins*':
    - jenkins.worker.ubuntu
    - python.virtualenv
    - java
    - vcs.git
