#!/bin/bash

red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

echo '---------------------------------------------------------------------'
echo '| Bucket                              | Bucket Policy Statements    |'
echo '---------------------------------------------------------------------'

for bucket in $(aws s3api list-buckets --query "Buckets[].Name" --output text); do 

skeleton="{
    \"Bucket\": \"$bucket\", 
    \"Policy\": \"{\"Version\": \"2012-10-17\",\"Statement\":[{\"Sid\": \"AllowSSLRequestsOnly\",\"Action\": \"s3:*\",\"Effect\": \"Deny\",\"Resource\": [\"arn:aws:s3:::${bucket}\",\"arn:aws:s3:::${bucket}/*\",],\"Condition\": {\"Bool\": {\"aws:SecureTransport\": \"false\"}}}]}\"
}"

aws s3api put-bucket-policy --cli-input-json "$skeleton"
    policy=$(aws s3api get-bucket-policy --bucket "$bucket" 2>/dev/null;)
    if [ "$policy" != "" ]; then
        printf -v output "| ${yellow} %s ${reset}    | Has a current policy - check manually    |" "$bucket"
    else
        printf -v output "SKIPPING"
        aws s3api put-bucket-policy --cli-input-json "$skeleton"
    fi

    echo -e $output
done;





