# source or . this file to set up amazon command line tools

# Setup Amazon EC2 Command-Line Tools
# http://www.robertsosinski.com/2008/01/26/starting-amazon-ec2-with-mac-os-x/

export EC2_URL=http://ec2.us-east-1.amazonaws.com

# export BLITZ_RUSH=`tail -1 ~/.ec2/blitz.txt`

export EC2_REGION=us-east-1
export ZONE=us-east-1b
export DB_INSTANCE_IDENTIFIER=load02
export TAG="v0.4.1"

#export RDS_SIZE="db.t1.micro"
#export EC2_SIZE="t1.micro"

#export RDS_SIZE="db.m1.medium"
#export EC2_SIZE="m1.medium"

export RDS_SIZE="db.m1.small"
export EC2_SIZE="m1.small"

# http://aws.amazon.com/amazon-linux-ami/ 
export AMI=ami-94cd60fd			# this is a 64-bit Amazon Linux AMI with session storage (m1.)
export UB_IN_AMI=ami-e864da81		# Ubuntu AMIs for EC2 http://alestic.com for build machine (sesion)
export AMI_EBS=ami-1624987f		# 64 bit with EBS (for t1.micro) (Amazon Linux AMI)
