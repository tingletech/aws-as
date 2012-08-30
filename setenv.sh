# source or . this file to set up amazon command line tools

# Setup Amazon EC2 Command-Line Tools
# http://www.robertsosinski.com/2008/01/26/starting-amazon-ec2-with-mac-os-x/

# http://s3.amazonaws.com/ec2-downloads/ec2-api-tools.zip
export EC2_HOME=~/aws/ec2-api-tools-1.6.1.4
export PATH=$PATH:$EC2_HOME/bin

export EC2_URL=http://ec2.us-east-1.amazonaws.com

# get these files from the management console
export EC2_PRIVATE_KEY=`ls ~/.ec2/pk-*.pem`
export EC2_CERT=`ls ~/.ec2/cert-*.pem`

# command line tools for the relation database service
# http://s3.amazonaws.com/rds-downloads/RDSCli.zip
export AWS_RDS_HOME=~/aws/RDSCli-1.9.001
export PATH=$PATH:$AWS_RDS_HOME/bin

# http://stackoverflow.com/questions/1348842/what-should-i-set-java-home-to-on-osx
export JAVA_HOME=$(/usr/libexec/java_home)

export EC2_REGION=us-east-1
export ZONE=us-east-1b

# http://aws.amazon.com/amazon-linux-ami/ 
export AMI=ami-94cd60fd		# this is a 64-bit Amazon Linux AMI with session storage
