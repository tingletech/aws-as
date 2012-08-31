#!/bin/bash
set -eu
which mysql	# make sure this command is installed
endpoint=`rds-describe-db-instances alpha | awk '{ print $9 }'`

if [ -z "$endpoint" ]; then             # not sure why set -u is not catching this
  echo "no endpoint, did you run launch-rds.sh?"
  exit 1
fi

password=`cat ~/.ec2/.dbpass`

mysql --host=$endpoint --user=as --password %{password} << SQL
create database archivesspace default character set utf8;
SQL
# grant all on archivesspace.* to 'as'@'localhost' identified by '%{password}';
