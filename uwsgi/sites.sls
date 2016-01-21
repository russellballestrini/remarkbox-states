# Manage none or many uWSGI web application services.
#
# example pillar data
#
#   uwsgi:
#     user: uwsgi
#     home: /opt/uwsgi
#
#     sites:
#       demo.remarkbox.com:
#       port: 6001
#       source: salt://remarkbox-jenkins01/home/jenkins/workspace/remarkbox/env.tar.gz
#       source_hash:
#       commit_hash: salt://remarkbox-jenkins01/home/jenkins/workspace/remarkbox/commit-hash.txt
#       commit_hash_sha:
#
#       # cookie library secret.
#       session_secret: put-a-large-string-here
#
#       # authtkt library secret.
#       authtkt_secret: put-a-large-string-here-but-different

#include:
#  - nginx

{% set user = salt['pillar.get']('uwsgi:user', 'uwsgi') %}
{% set home = salt['pillar.get']('uwsgi:home', '/opt/uwsgi') %}

{{ user }}:
  user.present:
    - fullname: Web Application Server
    - home: {{ home }}
    - system: True
    - shell: /bin/bash

  file.directory:
    - name: {{ home }}

{% for site, site_data in salt['pillar.get']('uwsgi:sites', {}).items() %}

{% set site_dir = home + '/' + site %}

# manage the directory for {{ site }}
{{ site_dir }}:
  file.directory:
    - user: {{ user }}
    - group: {{ user }}
    - require:
      - user: {{ user }}

# manage commit-hash.txt for this build.
manage-commit-hash-for-{{ site }}:
  file.managed:
    - name: {{ site_dir }}/commit-hash.txt
    - source: {{ site_data['commit_hash'] }}
    - source_hash: {{ site_data['commit_hash_sha'] }}
    - user: {{ user }}
    - group: {{ user }}
    - require:
      - file: {{ site_dir }}

# stop {{ site }} service before new tarball release is extracted.
make-{{ site }}-dead-for-release:
  service.dead:
    - name: {{ site }}
    - onchanges:
      - file: manage-commit-hash-for-{{ site }}
    - require:
      - file: /etc/init/{{ site }}.conf

# extract virtualenv tarball.
extract-tarball-for-{{ site }}:
  archive.extracted:
    - name: {{ site_dir }}
    - archive_format: tar
    - source: {{ site_data['source'] }}
    - source_hash: {{ site_data['source_hash'] }}
    - user: {{ user }}
    - group: {{ user }}
    - if_missing: /dev/taco
    - onchanges:
      - file: manage-commit-hash-for-{{ site }}
    - require:
      - service: make-{{ site }}-dead-for-release

## manage the nginx vhost config for {{ site }}
#/etc/nginx/sites-available/{{ site }}.conf:
#  file.managed:
#    - source: salt://uwsgi/sites-vhost-nginx.j2
#    - user: root
#    - group: root
#    - template: jinja
#    - context:
#      site: {{ site }}
#      site_data: {{ site_data }}
#      site_dir: {{ site_dir }}
#      user: {{ user }}
#    - require:
#      - user: {{ user }}
#    - watch_in:
#      - service: nginx

## enable the nginx vhost config for {{ site }}
#/etc/nginx/sites-enabled/{{ site }}.conf:
#  file.symlink:
#    - target: /etc/nginx/sites-available/{{ site }}.conf
#    - require:
#      - file: /etc/nginx/sites-available/{{ site }}.conf
#    - watch_in:
#      - service: nginx

{{ site_dir }}/production.ini:
  file.managed:
    - source: salt://uwsgi/configs/{{ site }}.ini
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
      site_data: {{ site_data }}
    - require:
      - file: {{ site_dir }}

# manage the upstart conf and service for {{ site }}
{{ site }}:

  file.managed:
    - name: /etc/init/{{ site }}.conf
    - source: salt://uwsgi/uwsgi-upstart.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
      site: {{ site }}
      site_data: {{ site_data }}
      site_dir: {{ site_dir }}
      user: {{ user }}

  service.running:
    - watch:
      - file: /etc/init/{{ site }}.conf
      - file: {{ site_dir }}/production.ini
      - archive: extract-tarball-for-{{ site }}

{% endfor %}
