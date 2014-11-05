base:
    '*':
        - vim
        - mda
    
    'role:web':
        - match: grain
        - django-apps
    
    'role:db':
        - match: grain
        - postgresql
#    
#    'role:db-slave':
#        - match: grain
#        - database-slave
