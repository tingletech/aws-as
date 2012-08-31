#!/bin/bash
# launch an EC2 server and install application
# run ./launch-rds.sh first
set -eux
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" # http://stackoverflow.com/questions/59895
. $DIR/setenv.sh
cd $DIR

hackconf() {	# poor man's templates; hard coded for %{DB_URL} and %{password}
  sed -e "s,%{DB_URL},$2," -e "s,%{password},$3," -e "s,%{endpoint},$4," $1.in > $1
}

# figure out database connection string to put in confing/config.rb
password=`cat ~/.ec2/.dbpass`
# get the hostname for the database
endpoint=`rds-describe-db-instances $DB_INSTANCE_IDENTIFIER | head -1 | awk '{ print $9 }'`
endpoint="endpoint"

db_url="jdbc:mysql://$endpoint:3306/archivesspace?user=aspace\&password=$password"
#                                                            ^ escaped for regex ...

if [ -z "$endpoint" ]; then		# not sure why set -u is not catching this
  echo "no endpoint, did you run launch-rds.sh?"
  exit 1
fi

# start user-data script payload
# https://help.ubuntu.com/community/CloudInit
cat > aws_init.sh << DELIM
#!/bin/bash
set -eux
# this gets run as root on the amazon machine when it boots up

# install packages we need from amazon's repo
yum -y install git tomcat7
yum -y install mysql-bench

# create role account for the application
useradd aspace

# execute this script as the role account
cat > ~aspace/init.sh <<EOSETUP
DELIM

# middle of payload user-data file

# as_role_account.sh will be run as the role account on the AWS EC2 server
# hack sensitive info into the script
hackconf as_role_account.sh $db_url $password $endpoint
# cat the script into the payload
cat as_role_account.sh >> aws_init.sh 

# finish off the user-data payload file
cat >> aws_init.sh << DELIM
EOSETUP
# still on remote machine
su - -c aspace ~aspace/init.sh

# tweak environment
# java -DARCHIVESSPACE_BACKEND=localhost:8089

# install war files into tomcat
# actually... need two tomcats...

# notifications?
DELIM
# back to the local machine

gzip aws_init.sh
# clean up
rm as_role_account.sh 

# http://docs.amazonwebservices.com/AWSEC2/latest/CommandLineReference/ApiReference-cmd-RunInstances.html
# "You must have the key pair where you run your script." -- https://forums.aws.amazon.com/message.jspa?messageID=88003
ec2-run-instances $AMI                \
     --verbose                        \
     --user-data-file aws_init.sh.gz  \
     --key ec2-keypair                \
     --monitor                        \
     --instance-type m1.small         \
     --availability-zone $ZONE

# clean up
rm aws_init.sh.gz
