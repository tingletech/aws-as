#!/bin/bash
# launch a mysql server on RDS
set -eu
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" # http://stackoverflow.com/questions/59895
. $DIR/setenv.sh
# http://docs.amazonwebservices.com/AmazonRDS/latest/CommandLineReference/CLIReference-cmd-CreateDBInstance.html
rds-create-db-instance            \
  $DB_INSTANCE_IDENTIFIER         \
  --db-instance-class db.m1.small \
  --db-parameter-group-name utf8  \
  --engine MySQL                  \
  --db-name archivesspace         \
  --master-user-password -        \
  --port 3306                     \
  --backup-retention-period 1     \
  --allocated-storage 10          \
  --master-username aspace        \
  --availability-zone $ZONE < ~/.ec2/.dbpass
