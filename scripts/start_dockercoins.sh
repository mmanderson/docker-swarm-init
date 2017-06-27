#!/bin/bash

cd ~/orchestration-workshop/dockercoins
docker-compose build

REGISTRY=127.0.0.1:5000 
TAG=v1
for SERVICE in hasher rng webui worker; do
  docker tag dockercoins_$SERVICE $REGISTRY/$SERVICE:$TAG
  docker push $REGISTRY/$SERVICE
done

docker service create --network swarm_network --name redis --detach=false redis

for SERVICE in hasher rng webui worker; do
	docker service create --network swarm_network --detach=false --name $SERVICE $REGISTRY/$SERVICE:$TAG
done

cd ~
