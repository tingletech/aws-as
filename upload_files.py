#!/usr/bin/env python
import boto
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('tag', nargs=1)
args = parser.parse_args()
tag = args.tag[0]

c = boto.connect_s3()
fn = 'archivesspace.' + tag + '.jar'
bw = 'backend.' + tag + '.war'
fw = 'frontend.' + tag + '.war'
fn_public = 'public-files/'
fn_private = 'private-files/'
build = 'public-files/as-build.' + tag + '.zip'
url_upload_public = c.generate_url(10800, 'PUT', 'archivesspace', fn_public + fn, headers={'x-amz-acl': 'public-read'})
url_upload_public_back = c.generate_url(10800, 'PUT', 'archivesspace', fn_public + bw, headers={'x-amz-acl': 'public-read'})
url_upload_public_front = c.generate_url(10800, 'PUT', 'archivesspace', fn_public + fw, headers={'x-amz-acl': 'public-read'})
url_upload_public_build = c.generate_url(10800, 'PUT', 'archivesspace', build , headers={'x-amz-acl': 'public-read'})

url_upload_private = c.generate_url(10800, 'PUT', 'archivesspace', fn_private + fn )
url_upload_private_back = c.generate_url(10800, 'PUT', 'archivesspace', fn_private + bw )
url_upload_private_front = c.generate_url(10800, 'PUT', 'archivesspace', fn_private + fw )

print 'curl --request PUT --upload-file archivesspace.jar "' + url_upload_private + '"'
print 'curl --request PUT --upload-file backend/backend.war "' + url_upload_private_back + '"'
print 'curl --request PUT --upload-file frontend/frontend.war "' + url_upload_private_front + '"'
print 'zip archivesspace.jar -d "*mysql-connector*"'
print 'zip backend/backend.war -d "*mysql-connector*"'

print 'curl --request PUT --upload-file archivesspace.jar -H \'x-amz-acl: public-read\' "' + url_upload_public + '"'
print 'curl --request PUT --upload-file backend/backend.war -H \'x-amz-acl: public-read\' "' + url_upload_public_back + '"'
print 'curl --request PUT --upload-file frontend/frontend.war -H \'x-amz-acl: public-read\' "' + url_upload_public_front + '"'
print 'curl --request PUT --upload-file build.zip -H \'x-amz-acl: public-read\' "' +  url_upload_public_build + '"'

