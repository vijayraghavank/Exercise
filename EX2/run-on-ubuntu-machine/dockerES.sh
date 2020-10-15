#!/bin/bash

for i in {1..10}

    do docker run -it -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" docker.elastic.co/elasticsearch/elasticsearch:7.9.2

    sleep 3
done
