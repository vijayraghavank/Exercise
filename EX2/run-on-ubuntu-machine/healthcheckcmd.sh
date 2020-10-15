#!/bin/bash


echo "Check the cluster health"
curl http://127.0.0.1:9200/_cat/health

echo "health"

curl -XGET http://localhost:9200/_cluster/health?pretty

echo "Cluster Health: Index Level"

curl -XGET 'http://localhost:9200/_cluster/health?level=indices&pretty'

echo "Cluster Health: Shard Level:"

curl -XGET 'http://localhost:9200/_cluster/health?level=shards&pretty'

echo "Nodes Overview:"

curl -XGET http://localhost:9200/_cat/nodes?v

echo "Shard Allocation per Node:"

curl -XGET http://localhost:9200/_cat/allocation?v
