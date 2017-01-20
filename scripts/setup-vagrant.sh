#!/bin/bash
#
# Program: Setup a vagrant env
# History: 2017/1/19 Kyle.b Release

set -xe

BIND_ETH="enp0s8"

ETCD_DEFAULT_PATH="./roles/etcd/defaults/main.yaml"
NODE_DEFAULT_PATH="./roles/node/defaults/main.yaml"
