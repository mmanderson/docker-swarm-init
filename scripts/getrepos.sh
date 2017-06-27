#!/bin/bash

if [ ! -d orchestration-workshop ]; then 
	git clone https://github.com/jpetazzo/orchestration-workshop.git
fi

if [ ! -d docker-swarm-visualizer ]; then
	git clone https://github.com/dockersamples/docker-swarm-visualizer.git
fi
