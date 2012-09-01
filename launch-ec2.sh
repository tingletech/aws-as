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
yum -y update			# get the latest security updates
yum -y install git tomcat7
yum -y install ant 		# ant via ./build was crying about tools.jar b/c it was running in JRE
yum -y install mysql-bench	# assuming this is needed for mysql client??
# yum -y install monit		# set this up later
yum -y install tree

# iotop is a handy utility on linux
easy_install pip
pip install http://guichaz.free.fr/iotop/files/iotop-0.4.4.tar.gz

# node speeds up sprockets asset pipeline generation during build
# https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager
yum -y localinstall --nogpgcheck http://nodejs.tchol.org/repocfg/amzn1/nodejs-stable-release.noarch.rpm 
yum -y install nodejs-compat-symlinks npm

# _   /|  ack is a tool like grep, optimized for programmers
# \'o.O'  http://betterthangrep.com
# =(___)=                                                 not sure exactly what is going on here
#    U    ack!                                                                   ⇩ ⇩
curl http://betterthangrep.com/ack-standalone > /usr/local/bin/ack && chmod 0755 !#:3


# can't find a package for http://software.clapper.org/daemonize/
# used to run the standalone server as a daemon
cd /usr/local/src
git clone http://github.com/bmc/daemonize.git
cd daemonize
sh configure
make
make install

# create role account for the application
useradd aspace
# so we can read the log files
gpasswd -a ec2-user tomcat
gpasswd -a aspace tomcat

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
# back on remote machine as root
su - -c aspace ~aspace/init.sh

# tweak environment
# java -DARCHIVESSPACE_BACKEND=localhost:8089 ??


# need two tomcats (one for frontend, one for backend)
# from /etc/sysconfig/tomcat7 on Amazon Linux AMI:
# To change values for a specific service make your edits here.
# To create a new service create a link from /etc/init.d/<your new service> to
# /etc/init.d/tomcat7 (do not copy the init script) 
# ln -s /etc/init.d/tomcat7 /etc/init.d/tomcat7back

# and make a copy of the
# /etc/sysconfig/tomcat7 file to /etc/sysconfig/<your new service>
#cp /etc/sysconfig/tomcat7 /etc/sysconfig/tomcat7back
# and change
# the property values so the two services won't conflict.
## sed sed sed
cp -rp /usr/share/tomcat7/ /usr/share/tomcat7back

# redirect port 8080 to port 80 so we don't have to run tomcat as root
# http://forum.slicehost.com/index.php?p=/discussion/2497/iptables-redirect-port-80-to-port-8080/p1
iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 8080

# public_address=`curl http://169.254.169.254/latest/meta-data/public-ipv4`

exit # just using the bulit in test server and derby for now

# Register the new
# service in the system as usual (see chkconfig and similars).
## chkconfig!
# install war files into tomcat
cp /home/aspace/archivesspace/frontend/frontend.war /usr/share/tomcat7/webapps/ROOT.war
## hacking around the missing mysql driver...
cd /usr/share/tomcat7/webapps
unzip /usr/share/tomcat7/webapps/ROOT.war
cp /home/aspace/archivesspace/build/gems/gems/jdbc-mysql-5.1.13/lib/mysql-connector-java-5.1.13.jar /usr/share/tomcat7/webapps/ROOT/WEB-INF/lib/

# can these run in one server, rathern than two?
cp /home/aspace/archivesspace/backend/backend.war /usr/share/tomcat7back/webapps/ROOT.war

service tomcat7 start


# http://www.excelsior-usa.com/articles/tomcat-amazon-ec2-basic.html
# To have Tomcat start automatically on instance boot, issue the following commands:
chkconfig --level 345 tomcat7 on
# chkconfig --level 345 tomcat7back on

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
