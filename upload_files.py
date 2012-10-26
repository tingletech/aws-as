#!/usr/bin/env python
import boto
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('tag', nargs=1)
args = parser.parse_args()
tag = args.tag[0]

c = boto.connect_s3()
fn = 'archivesspace.' + tag + '.jar'
fn_public = 'public-files/' + fn
fn_private = 'private-files/' + fn
url_upload_public = c.generate_url(3600, 'PUT', 'archivesspace', fn_public, headers={'x-amz-acl': 'public-read'})
url_upload_private = c.generate_url(3600, 'PUT', 'archivesspace', fn_private )

print 'curl --request PUT --upload-file archivesspace.jar "' + url_upload_private + '"'
print 'zip archivesspace.jar -d "*mysql-connector*"'
print 'curl --request PUT --upload-file archivesspace.jar -H \'x-amz-acl: public-read\' "' + url_upload_public + '"'


