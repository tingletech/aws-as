#!/usr/bin/env python
import boto
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('tag', nargs=1)
args = parser.parse_args()
tag = args.tag[0]

c = boto.connect_s3()
fn = 'archivesspace.' + tag + '.zip'
fn_public = 'public-files/'

url_upload_public = c.generate_url(10800, 'PUT', 'archivesspace', fn_public + fn, headers={'x-amz-acl': 'public-read'})

print 'curl --request PUT --upload-file archivesspace.zip -H \'x-amz-acl: public-read\' "' + url_upload_public + '"'

