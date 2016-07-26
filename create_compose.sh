#!/bin/bash
NODE_NAME="${NODE_NAME:=$1}"
NODE_IP="${NODE_IP:=$2}"


sed -e "s/NODE_NAME/${NODE_NAME}/g" compose_infrastructure.yml>tee compose_infrastructure.${NODE_NAME}.yml
sed -i "s/NODE_IP/${NODE_IP}/g" compose_infrastructure.${NODE_NAME}.yml
