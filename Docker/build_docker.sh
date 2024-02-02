#!/bin/bash

set -ex


VERSION=`cat VERSION.txt`

docker build -t pasapipeline/pasa_lite:${VERSION} .
docker build -t pasapipeline/pasa_lite:latest .

