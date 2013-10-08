# Logstash Logger States

I have followed the [logstash](http://logstash.net/docs/1.2.1/tutorials/getting-started-centralized) centralized setup to create these states.

There are 3 main states that are provided:

1. Indexer `logstash.indexer`

  Dumps redis broker objects into elasticsearch.

2. Shipper `logstash.shipper`

  Sends log events to the redis host (`redis_host`)

3. Web `logstash.web`

  Provides the kibana interface to elasticsearch.

These are all tested functioning on Ubuntu 13.04. In addition to these states there is a `logstash.server` state that will install elasticsearch and redis, download logstash, and configures the minion with `logstash.indexer`.

The `logstash.server` state also configures redis to bind to all interfaces and *does not* configure a firewall rule. It also will configure a message index for elasticsearch [^1].If the server is a public server, please please please, firewall that shit.

Part of the elasticsearch install is to configure a `logstash*` index template [^1] to improve elasticsearch's performance:

    curl -XPUT http://localhost:9200/_template/logstash_per_index -d '{
        "template" : "logstash*",
        "settings" : {
            "number_of_shards" : 4,
            "index.cache.field.type" : "soft",
            "index.refresh_interval" : "5s",
            "index.store.compress.stored" : true,
            "index.query.default_field" : "@message",
            "index.routing.allocation.total_shards_per_node" : 2
        },
        "mappings" : {
            "_default_" : {
               "_all" : {"enabled" : false},
               "properties" : {
                  "@fields" : {
                       "type" : "object",
                       "dynamic": true,
                       "path": "full",
                       "properties" : {
                           "clientip" : { "type": "ip"}
                       }
                  },
                  "@message": { "type": "string", "index": "analyzed" },
                  "@source": { "type": "string", "index": "not_analyzed" },
                  "@source_host": { "type": "string", "index": "not_analyzed" },
                  "@source_path": { "type": "string", "index": "not_analyzed" },
                  "@tags": { "type": "string", "index": "not_analyzed" },
                  "@timestamp": { "type": "date", "index": "not_analyzed" },
                   "@type": { "type": "string", "index": "not_analyzed" }
               }
            }
       }
    }'

[^1]: [untergeek improve logstash indexes](http://untergeek.com/2012/09/20/using-templates-to-improve-elasticsearch-caching-with-logstash/)