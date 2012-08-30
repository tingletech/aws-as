#!/bin/bash
set -eu
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" # http://stackoverflow.com/questions/59895
. $DIR/setenv.sh
cd $DIR

genconf() {
  if [ -e $1 ]
    then 
      chmod u+w $1
  fi
  echo $1 $2 $3
  sed s,%{$2},$3, $1.in > $1
  chmod u-w $1
}

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
cat as_role_account.sh.in >> aws_init.sh 
cat >> aws_init.sh << DELIM
EOSETUP

# install war files into tomcat

# start tomcat

# notifications?
DELIM

exit 0

gzip aws_init.sh
rm as_role_accout.sh

# http://docs.amazonwebservices.com/AWSEC2/latest/CommandLineReference/ApiReference-cmd-RunInstances.html
ec2-run-instances $AMI                \
     --verbose                        \
     # https://help.ubuntu.com/community/CloudInit
     --user-data-file aws_init.sh.gz  \
     --key ~/.ec2/ec2-keypair         \
     --monitor                        \
     --instance-type m1.small         \
     --availability-zone $ZONE
