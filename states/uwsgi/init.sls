uwsgi:
  pkg:
    - installed
  service:
    - running
    - enable: True
    - reload: True
    - watch:
      - file: /etc/uwsgi/apps-enabled/*

uwsgi-plugin-python:
  pkg.installed
