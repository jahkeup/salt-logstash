logstash-user:
  user.present:
    - name: logstash
    - groups:
      - wheel
