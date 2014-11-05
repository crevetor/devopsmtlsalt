include:
  - nginx
  - uwsgi
  - virtualenv
  - memcached

git:
  pkg.installed

{% for app_name in grains["django-apps"] %}

{% set app = pillar["django-apps"][app_name] %}
{% set name = app_name %}
{% set url = app["url"] %}
{% set app_base = pillar["django-basepath"] + "/" + url %}
{% set user = app["user"] %}
{% set database = app["database"] %}
{% set repo = app["repository"] %}
{% set db_password = app["db_password"] %}
{% set db_host = app["db_host"] %}
{% set secret_key = app["secret_key"] %}
{% set database_url = "postgres://"+ user + ":" + db_password + "@"+ db_host + ":5432/" + database %}

# Ensure that django-basepath exists (needed as our users home)
{{ pillar["django-basepath"] }}:
  file.directory:
    - makedirs: True
    - mode: 755

# Create a user for our app
{{ user }}:
  user.present:
    - home: {{ app_base }}
    - require:
      - file: {{ pillar["django-basepath"] }}

# Create our app base dir
{{ app_base }}:
  file.directory:
    - user: {{ user }}
    - mode: 755
    - require:
      - user: {{ user }}
    - makedirs: True

# Create app virtualenv
su - {{ user }} -c "virtualenv {{ app_base }}/env":
  cmd.run:
    - unless: test -f {{ app_base }}/env/bin/activate
    - require:
      - pkg: python-virtualenv
      - user: {{ user }}
      - file: {{ app_base }}

# Create app env variable file
{{ app_base }}/env.sh:
  file.managed:
    - source: salt://django-apps/files/env.sh
    - template: jinja
    - user: {{ user }}
    - mode: 600
    - context:
      db_url: {{ database_url }}
      secret_key: {{ secret_key }}
    - require:
      - user: {{ user }}
      - file: {{ app_base }}

# Pull app from repo into app dir
{{ repo }}:
  git.latest:
    - target: {{ app_base }}/app
    - user: {{ user }}
    - require:
        - pkg: git

# Create app uwsgi config
{{ name }}-uwsgi:
  file.managed:
    - name: /etc/uwsgi/apps-available/{{ url }}.ini
    - source: salt://uwsgi/files/django-app.ini
    - template: jinja
    - context:
      user: {{ user }}
      base_dir: {{ app_base }}
      db_url: {{ database_url }}
      secret_key: {{ secret_key }}
    - require:
      - pkg: uwsgi-plugin-python
      - user: {{ user }}
      - file: {{ app_base }}

# Create app vhost
{{ name }}-nginx:
  file.managed:
    - name: /etc/nginx/sites-available/{{ url }}.conf
    - source: salt://nginx/files/vhost-uwsgi.conf
    - template: jinja
    - context:
      url: {{ url }}
      base_dir: {{ app_base }}
    - require:
      - pkg: nginx

# Enable uwsgi config
{{ name }}-uwsgi-enabled:
  file.symlink:
    - name: /etc/uwsgi/apps-enabled/{{ url }}.ini
    - target: /etc/uwsgi/apps-available/{{ url }}.ini
    - require:
      - file: {{ name }}-uwsgi

# Enable nginx vhost
{{ name }}-nginx-enabled:
  file.symlink:
    - name: /etc/nginx/sites-enabled/{{ url }}.conf
    - target: /etc/nginx/sites-available/{{ url }}.conf
    - require:
      - file: {{ name }}-nginx

# Install postgresql python requirements
libpq-dev:
  pkg.installed

python-dev:
  pkg.installed
{% endfor %}
