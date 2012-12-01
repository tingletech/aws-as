## Archival applicaiton set up scripts for AWS

This github gist contains scripts used to launch the alpha version
of an archival management system product on Amazon Web Services.


Installation
------------

The system configuration files in this gist go in `~/aws/`

In the management console, you will need to go to "My Account" >
"Security Credentials" > "X.509 Certificates" > "Create a new
Certificate".  Download the two `.pem` files and put them in `~/.ec2` .

Create a file `.dbpass` in `~/.ec2` with the password for the database.

Create a private ssh key at `~/aws/ec2-keypair` .

(most commands assume current working directory of `~/aws`)

```
. setenv.sh
ec2-create-keypair ec2-keypair
```

Fix the permissions on `~/.ec2` and `~/aws/ec2-keypair` :

```sh
chmod -R 700 ~/.ec2/
chmod -R 700 ~/aws/
chmod -R 600 ~/.ec2/*
chmod -R 600 ~/aws/ec2-keypair
```

Grab the amazon command line tools.

```sh
./grabazon.sh
```

They python library `boto` needs to be set up with the S3 credential for the push to S3 to work.

grant access (security groups left as an exercise for the reader)

```
ec2-authorize blah -p 22
ec2-authorize blah -p 80
rds-authorize-db-security-group-ingress blah --ec2-security-group-name blah --ec2-security-group-owner-id 8675309
```

Set up RDS parameter group for utf8

```sh
rds-create-db-parameter-group --db-parameter-group-family mysql5.5 --description "utf8" --db-parameter-group-name utf8

rds-modify-db-parameter-group utf8 \
>     --parameters="name=character_set_server, value=utf8, method=immediate" \
>     --parameters="name=character_set_client, value=utf8, method=immediate" \
>     --parameters="name=character_set_results, value=utf8, method=immediate" \
>     --parameters="name=collation_server, value=utf8_unicode_ci, method=immediate" \
>     --parameters="name=collation_connection, value=utf8_unicode_ci, method=immediate"

```

## Every new release

Build the .jar and .war files
-----------------------------

Launch a m1.large, build the `.jar` and `.war`, push the artifacts to S3, terminate instance.

```sh
./launch-build.sh
```

Launch mysql on AWS RDS
----------------------

```sh
./launch-rds.sh
```

Wait for the server to spin up.  At first, `rds-describe-db-instances` will return something like this:
```
DBINSTANCE  alpha01  db.m1.small  mysql  10  aspace  creating  us-east-1b  1  ****  n  5.5.25a  general-public-license
      SECGROUP  default  active
      PARAMGRP  default.mysql5.5  in-sync
      OPTIONGROUP  default:mysql-5-5  in-sync
```

Once the database has cranked up; you should see something like this:

```
DBINSTANCE  alpha01  2012-08-31T20:27:02.502Z  db.m1.small  mysql  10  aspace  backing-up  alpha01.blahblah.us-east-1.rds.amazonaws.com  3306  us-east-1b  1  n  5.5.25a  general-public-license
      SECGROUP  default  active
      PARAMGRP  default.mysql5.5  in-sync
      OPTIONGROUP  default:mysql-5-5  in-sync
```


Launch the EC2 server.
----------------------

Once the database is running the build artifacts are on s3. 

```sh
./launch-ec2.sh
```

AWS Command Documentation
------------------

[rds-create-db-instance](http://docs.amazonwebservices.com/AmazonRDS/latest/CommandLineReference/CLIReference-cmd-CreateDBInstance.html)

[ec2-run-instances](http://docs.amazonwebservices.com/AWSEC2/latest/CommandLineReference/ApiReference-cmd-RunInstances.html)

[ubuntu cloud init](https://help.ubuntu.com/community/CloudInit) is used by the [Amazon Linux AMI](http://aws.amazon.com/amazon-linux-ami/)

License
-------

Copyright © 2012, Regents of the University of California
All rights reserved.

Redistribution and use in source and binary forms, with or without 
modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, 
  this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, 
  this list of conditions and the following disclaimer in the documentation 
  and/or other materials provided with the distribution.
- Neither the name of the University of California nor the names of its
  contributors may be used to endorse or promote products derived from this 
  software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
POSSIBILITY OF SUCH DAMAGE.
