#!/bin/bash

if [ -z "$1" ]
  then
    echo "You must supply an Instance ID as the first argument."
fi

aws ec2 modify-instance-metadata-options \
    --instance-id $1 \
    --http-tokens required \
    --http-endpoint enabled

aws ec2 modify-instance-metadata-options --instance-id $1 --http-tokens required --http-endpoint enabled