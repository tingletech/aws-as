#!/bin/bash
set -eu
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" # http://stackoverflow.com/questions/59895
. $DIR/setenv.sh
cd $DIR
# TODO: generate aws_init.sh from aws_init.sh.in template file
cp aws_init.sh.in aws_init.sh
gzip aws_init.sh
# http://docs.amazonwebservices.com/AWSEC2/latest/CommandLineReference/ApiReference-cmd-RunInstances.html
ec2-run-instances $AMI                \
     --verbose                        \
     --user-data-file aws_init.sh.gz  \
     --key ec2-keypair                \
     --monitor                        \
     --instance-type m1.small         \
     --availability-zone $ZONE
