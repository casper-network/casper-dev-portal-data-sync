#!/usr/bin/env python3

import boto3
import sys
import os

def delete_all_objects(bucket, session):
    s3 = session.resource('s3')
    bucket = s3.Bucket(bucket)
    bucket.objects.delete()

def replicate_s3_bucket(source_bucket, target_bucket, session):
    s3 = session.client('s3')
    
    # List all objects in the source bucket
    paginator = s3.get_paginator('list_objects_v2')
    pages = paginator.paginate(Bucket=source_bucket)
    
    for page in pages:
        for obj in page['Contents']:
            source_key = obj['Key']
            print(f'Copying {source_key} from {source_bucket} to {target_bucket}')
            
            # Copy object from source to target bucket
            s3.copy_object(
                CopySource={'Bucket': source_bucket, 'Key': source_key},
                Bucket=target_bucket,
                Key=source_key
            )

def invalidate_cloudfront(cloudfront_distribution_id, session):
    cloudfront = session.client('cloudfront')
    invalidation_batch = {
        'Paths': {
            'Quantity': 1,
            'Items': ['/*']
        },
        'CallerReference': 'S3ReplicationInvalidateAll'
    }
    
    cloudfront.create_invalidation(
        DistributionId=cloudfront_distribution_id,
        InvalidationBatch=invalidation_batch
    )

def main():    
    source_bucket = os.environ['SOURCE_S3_BUCKET']
    target_bucket = os.environ['DEST_S3_BUCKET']
    cloudfront_distribution_id = os.environ['DEST_CLOUDFRONT_ID']
    aws_profile = os.environ['AWS_PROFILE']
    
    session = boto3.Session(profile_name=aws_profile)
    
    # Delete all objects in the target bucket
    delete_all_objects(target_bucket, session)
    
    # Replicate the source bucket to the target bucket
    replicate_s3_bucket(source_bucket, target_bucket, session)
    
    # Invalidate the CloudFront distribution
    invalidate_cloudfront(cloudfront_distribution_id, session)

if __name__ == "__main__":
    main()
