#!/bin/bash 
set -eu
which wget unzip
wget http://s3.amazonaws.com/ec2-downloads/ec2-api-tools.zip 
unzip ec2-api-tools.zip
wget http://s3.amazonaws.com/rds-downloads/RDSCli.zip 
unzip RDSCli.zip
