#!/bin/bash
# launch a mysql server on RDS
set -eu
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" # http://stackoverflow.com/questions/59895
. $DIR/setenv.sh
# http://docs.amazonwebservices.com/AmazonRDS/latest/CommandLineReference/CLIReference-cmd-CreateDBInstance.html
#rds-create-db-instance            \
aws --region $EC2_REGION rds create-db-instance \
  --db-instance-identifier $DB_INSTANCE_IDENTIFIER \
  --db-instance-class db.t1.micro \
  --db-parameter-group-name utf8  \
  --engine MySQL                  \
  --db-name archivesspace         \
  --master-user-password `cat ~/.ec2/.dbpass`  \
  --port 3306                     \
  --backup-retention-period 1     \
  --allocated-storage 10          \
  --master-username aspace        \
  --availability-zone $ZONE
