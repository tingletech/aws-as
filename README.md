## Archival applicaiton set up scripts for AWS

This github gist contains scripts used to launch the alpha version
of an archival management system product on Amazon Web Services.


Installation
------------
These files go in ~/aws/

In the management console, you will need to go to "My Account" >
"Security Credentials" > "X.509 Certificates" > "Create a new
Certificate".  Download the .pem files and put them in ~/.ec2 .

Create a file .dbpass in ~/.ec2 with the password for the database.

Create a private ssh key at ~/.ec2/ec2-keypair .

Fix the permissions on ~/.ec2 :

```sh
chmod -R 700 ~/.ec2/
chmod -R 600 ~/.ec2/*
```

Grab the amazon command line tools.

```sh
./grabazon.sh
```

Launch services on AWS
----------------------

Launch an AWS RDS server.

```sh
./launch-rds.sh
```

Launch the EC2 server.

```sh
./launch-ec2.sh
```

AWS Command Documentation
------------------

[rds-create-db-instance](http://docs.amazonwebservices.com/AmazonRDS/latest/CommandLineReference/CLIReference-cmd-CreateDBInstance.html)

[ec2-run-instances](http://docs.amazonwebservices.com/AWSEC2/latest/CommandLineReference/ApiReference-cmd-RunInstances.html)

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
