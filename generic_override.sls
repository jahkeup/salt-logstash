# Overriding
{% set role = "collector" %}
{% set jar_role = "agent" %}
{% set source = 'salt://logstash/conf/OVERRIDEN.conf' %}

{% include 'logstash/service.jinja' %}
