# Allow all connections that are established or related to come in
base-allow-est-rel:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - match: state
    - connstate: ESTABLISHED,RELATED

# Allow all traffic on lo
base-allow-lo:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - in-interface: lo

# Allow ssh traffic in
base-allow-ssh:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - dport: 22
    - proto: tcp

# Allow icmp traffic
base-allow-icmp:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - protocol: icmp

# Set INPUT policy to DROP
# requires all 3 other base because we need to allow some things in before
# dropping everything
base-input-policy-drop:
  iptables.set_policy:
    - table: filter
    - chain: INPUT
    - policy: DROP
    - require:
      - iptables: base-allow-est-rel
      - iptables: base-allow-lo
      - iptables: base-allow-ssh
