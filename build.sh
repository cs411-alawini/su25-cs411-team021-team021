#!/usr/bin/env bash

docker secret create db_config ./db_config.txt

docker build -t melomood:latest .