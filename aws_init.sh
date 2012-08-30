#!/bin/bash
set -eu
# this gets run on the amazon machine when it boots up

yum install git tomcat7
useradd aspace
su aspace -c "git clone https://github.com/archivesspace/archivesspace.git"
