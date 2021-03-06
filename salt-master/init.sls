# Configuring the Salt Master:
#    https://docs.saltstack.com/en/latest/ref/configuration/master.html

manage-srv-remarkbox-states:
  git.latest:
    - name: https://github.com/russellballestrini/remarkbox-states.git
    - target: /src/remarkbox-states
    - branch: master

salt-master:

  pkg:
    - installed

  service:
    - running

  file.managed:
    - name: /etc/salt/master.d/custom.conf
    - source: salt://salt-master/custom.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - git: manage-srv-remarkbox-states
    - watch_in:
      - service: salt-master
