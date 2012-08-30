#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" # http://stackoverflow.com/questions/59895
. $DIR/setenv.sh
set -eu

## TODO ... compose command to launch the mysql database in AWS RDS

## TODO ... figure out how to handle passwords to the database
