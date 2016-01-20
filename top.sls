base:

  #'*':

  '*-salt':
    - salt-master
 
  '*-web*':
    - nginx

  '*-app*':
    - uwsgi
    - postfix
    - postfix.local

  '*-db*':
    - postgresql

  '*-mx*':
    - postfix
    - postfix.server
