DNS
---

Set up environment
```
. setup.sh
```
Look up instance...

```
ec2-describe-instances 
```
  

Associate the IP address

```
ec2-associate-address `dig alpha.archivesspace.org +short` -i INSTANCE
```
  
