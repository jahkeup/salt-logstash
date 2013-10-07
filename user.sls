logstash-user:
  user.present:
    - name: logstash
    - system: False
    - groups:
      - adm
