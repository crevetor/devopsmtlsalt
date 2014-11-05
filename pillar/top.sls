base:
  'role:web':
    - match: grain
    - django-apps
  'role:db':
    - match: grain
    - django-apps
