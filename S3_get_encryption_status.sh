#!/bin/bash

red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
reset=`tput sgr0`

echo '----------------------------------------------------------'
echo '| Bucket                              | SSE Algorithm    |'
echo '----------------------------------------------------------'
while read -r bucket
do
  #echo $bucket
  sse=$(aws s3api get-bucket-encryption --bucket $bucket | jq -r '.ServerSideEncryptionConfiguration.Rules[].ApplyServerSideEncryptionByDefault.SSEAlgorithm')

  if [ "$sse" == "AES256" ]; then
    printf -v output "| ${yellow} %s ${resest}    | ${green} %s ${resest}    |" $bucket $sse
  else
    printf -v output "| ${yellow} %s ${resest}    | ${red} SSE NOT ENABLED ${reset}    |" $bucket
  fi

  echo -e $output

done < <(aws s3api list-buckets --output text --query Buckets[*].[Name])