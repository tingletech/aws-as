#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" # http://stackoverflow.com/questions/59895
. $DIR/setenv.sh
set -eu
ec2-run-instances                     \
     --verbose                        \
     --user-data-file aws_init.sh     \
     --key ec2-keypair                \
     --monitor                        \
     --instance-type m1.small         \
     --availability-zone us-east-1b
