#!/bin/bash
# launch an EC2 server, build the application, upload to S3
set -eu
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" # http://stackoverflow.com/questions/59895
. $DIR/setenv.sh
cd $DIR

# start user-data script payload
# https://help.ubuntu.com/community/CloudInit
cat > aws_builder_init.sh << DELIM
#!/bin/bash
set -eux
# this gets run as root on the amazon machine when it boots up

# install packages we need from amazon's repo
yum -y update			# get the latest security updates
yum -y install git 
yum -y install ant 		# ant via ./build was crying about tools.jar b/c it was running in JRE
yum -y install mysql-bench	# assuming this is needed for mysql client??
# yum -y install monit		# set this up later
yum -y install tree
yum -y install libxslt		# need this for tomcat setup
# node speeds up sprockets asset pipeline generation during build
# https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager
yum -y localinstall --nogpgcheck http://nodejs.tchol.org/repocfg/amzn1/nodejs-stable-release.noarch.rpm 
yum -y install nodejs-compat-symlinks npm
npm install http-proxy		# reverse proxy for logging posts

mkdir /media/ephemeral0/aspace
cd /media/ephemeral0/aspace

git clone https://github.com/archivesspace/archivesspace.git
cd archivesspace
./build/run bootstrap 
./build/run backend:integration 
./build/run backend:doc
./build/run backend:test
./build/run common:test
./build/run dist
./build/run backend:war
./build/run frontend:war
DELIM

./upload_files.py $TAG >> aws_builder_init.sh

cat >> aws_builder_init.sh << DELIM
halt
DELIM

## chkconfig an init.d script that will start and stop monit
# back to the local machine

gzip aws_builder_init.sh

# http://docs.amazonwebservices.com/AWSEC2/latest/CommandLineReference/ApiReference-cmd-RunInstances.html
# "You must have the key pair where you run your script." -- https://forums.aws.amazon.com/message.jspa?messageID=88003
ec2-run-instances $AMI                \
     --verbose                        \
     --user-data-file aws_builder_init.sh.gz  \
     --key ec2-keypair                \
     --monitor                        \
     --instance-type m1.large         \
     --availability-zone $ZONE

# clean up
rm aws_builder_init.sh.gz
