#!/bin/bash

cp -a ./bin /opt/apps/
cp -a ./lib /opt/apps/
cp -a ./pkgs /opt/apps/
mkdir -p /opt/apps/etc/
cp test.yaml /opt/apps/etc/cuntainer.yml
cp build/* /opt/apps/bin/
