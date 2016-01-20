nginx:

  pkg:
    - installed

  service:
    - running

  #file.uncomment:
  #  - name: /etc/nginx/nginx.conf
  #  - regex: server_names_hash_bucket_size 64;
  #  - char: '# '
  #  - require:
  #    - pkg: nginx
  #  - watch_in:
  #    - service: nginx

nginx-disable-default-vhost:
  file.absent:
    - name: /etc/nginx/sites-enabled/default
    - watch_in:
      - service: nginx

# the directory to hold our tls keys and certs.
/etc/nginx/tls:
  file.directory:
    - user: root
    - group: root
    - require:
      - pkg: nginx

# the root directory to hold our site assets and code.
/www:
  file.directory:
    - user: root
    - group: root
    - require:
      - pkg: nginx

# the directory to host let's encrypt challenge files.
/www/.well-known/acme-challenge:
  file.directory:
    - user: root
    - group: root
    - makedirs: True
    - require:
      - file: /www
