postgresql:
  pkg:
    - installed
  service:
    - running
    - enable: True
    - watch:
      - file: /etc/postgresql/9.3/main/*
     

/etc/postgresql/9.3/main/postgresql.conf:
  file.replace:
    - pattern: '#listen_addresses\s*=\s*.+'
    - repl: "listen_addresses = '*'"

/etc/postgresql/9.3/main/pg_hba.conf:
  file.append:
    - text: "hostssl all all samenet md5"

{% for app_name in grains["django-apps"] %}

{% set app = pillar["django-apps"][app_name] %}
{% set name = app_name %}
{% set user = app["user"] %}
{% set database = app["database"] %}
{% set db_password = app["db_password"] %}

# Create postgresql user
db-user-{{ user }}:
  postgres_user.present:
    - name: {{ user }}
    - login: True
    - password:  {{ db_password }}
    - require:
      - pkg: postgresql

# Create database
db-{{ database }}:
  postgres_database.present:
    - name: {{ database }}
    - owner: {{ user }}
    - require:
      - pkg: postgresql
      - postgres_user: db-user-{{ user }}
{% endfor %}
