#!/bin/bash 
# just run this once; grabs the AWS command line tools for EC2 and RDS
set -eu
which wget unzip
wget http://s3.amazonaws.com/ec2-downloads/ec2-api-tools.zip 
unzip ec2-api-tools.zip
wget http://s3.amazonaws.com/rds-downloads/RDSCli.zip 
unzip RDSCli.zip
