#!/bin/bash

set -ex


VERSION=`cat VERSION.txt`

docker push pasapipeline/pasa_lite:${VERSION} 
docker push pasapipeline/pasa_lite:latest

