#!/bin/bash

cd ~/docker-swarm-visualizer
docker-compose up -d

docker service create --name registry --publish 5000:5000 registry:2
