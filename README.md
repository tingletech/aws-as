## Archival applicaiton set up scripts for AWS

This github gist contains scripts used to launch the alpha version
of an archival management system product on Amazon Web Services.

todo
----

needs reorder; see source code of these file for most up to date comments

 * `./launch-build.sh`  lanuch an ec2 to build the app and test it with selenium/firefox; then upload to s3; ping irc
   -  `./upload_files.py`  generate temporary signed s3 upload URLs to POST files
 * `./launch-ec2.sh`  start up an RDS database, then start up an EC2 server
   -  `./as_role_account.sh.template.sh`  template for install script run as `aspace` user 
   -  `./archivesspace.sh`  init.d style start script for jar file

here is the original order / some obsolete parts removed 2013-Mar-06

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

Also; https://github.com/aws/aws-cli is needed

The python library `boto` needs to be set up with the S3 credential for the push to S3 to work.

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
(ubuntu/alestic.com)

Launch the EC2 server.
----------------------

Start up the database, wait, start up an ec2, wait, report hostname (sould report instance id as well probably)

```sh
./launch-ec2.sh
```
(amazon linux)

AWS Command Documentation
------------------

[aws-cli](https://github.com/aws/aws-cli) is new

[ec2-run-instances](http://docs.amazonwebservices.com/AWSEC2/latest/CommandLineReference/ApiReference-cmd-RunInstances.html) is old and used by `launch-build.sh`

[ubuntu cloud init](https://help.ubuntu.com/community/CloudInit) is used by the [Amazon Linux AMI](http://aws.amazon.com/amazon-linux-ami/)

License
-------

Copyright © 2013, Regents of the University of California
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
