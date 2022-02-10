#!/bin/bash
set -e

aws s3api list-buckets \
  --output text \
  --query "Buckets[*].[Name]" \
  | \
  xargs -t -I {} \
  aws s3api put-public-access-block \
    --bucket {} \
    --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"