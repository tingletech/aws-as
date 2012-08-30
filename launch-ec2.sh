#!/bin/bash
set -eu		# exit if a command has an error or if there is an undefined variable
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" # http://stackoverflow.com/questions/59895
. $DIR/setenv.sh
cd $DIR

genconf() {	# poor man's templates
  if [ -e $1 ]
    then 
      chmod u+w $1
  fi
  sed s,%{$2},$3, $1.in > $1
}

# figure out database connection string to put in confing/config.rb
password=`cat ~/.ec2/.dbpass`
# get the hostname for the database
endpoint=`rds-describe-db-instances alpha | awk '{ print $9 }'`
# endpoint will be undefined if the database is not started, undefined variable will cause an abort
db_url="jdbc:mysql://$endpoint:3306/archivesspace?user=as&password=$password"

# create user-data script payload
# https://help.ubuntu.com/community/CloudInit
cat > aws_init.sh << DELIM
#!/bin/bash
set -eu
# this gets run as root on the amazon machine when it boots up

# install packages we need from amazon's repo
yum install git tomcat7

# create role account for the application
useradd aspace

# execute this script as the role account
su aspace -c <<EOSETUP
DELIM

# middle of payload user-data file

# these commands will be run as the role account on the server
genconf as_role_account.sh DB_URL $db_url	# set the database URL in the payload
cat as_role_account.sh >> aws_init.sh 

# finish off the user-data payload file
cat >> aws_init.sh << DELIM
EOSETUP

# install war files into tomcat

# start tomcat

# notifications?
DELIM

gzip aws_init.sh
# clean up
rm as_role_accout.sh

# http://docs.amazonwebservices.com/AWSEC2/latest/CommandLineReference/ApiReference-cmd-RunInstances.html
ec2-run-instances $AMI                \
     --verbose                        \
     --user-data-file aws_init.sh.gz  \
     --key ~/.ec2/ec2-keypair         \
     --monitor                        \
     --instance-type m1.small         \
     --availability-zone $ZONE
