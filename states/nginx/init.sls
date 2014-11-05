nginx:
  pkg:
    - installed
  service:
    - running
    - enable: True
    - watch:
      - file: /etc/nginx/sites-enabled/*
  file.uncomment:
    - name: /etc/nginx/nginx.conf
    - regex: server_names_hash_bucket_size

nginx-open-http-port:
  iptables.append:
    - table: filter
    - chain: INPUT
    - proto: tcp
    - dport: 80
    - jump: ACCEPT
