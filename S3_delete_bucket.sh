#!/bin/bash
bucket=$1

set -e

versioning=$(aws s3api get-bucket-versioning --bucket $bucket | jq '.Status')
#echo $versioning

if [ "$versioning" != '"Enabled"' ];
then
    echo "Deleting the Bucket: ${bucket} - the easy way."
    ## If no versioning is enabled - do it the easy way:
    aws s3 rm s3://$bucket --recursive
    aws s3 rb s3://$bucket --force  
else
    echo "Removing all versions from $bucket"

    versions=`aws s3api list-object-versions --bucket $bucket |jq '.Versions'`
    markers=`aws s3api list-object-versions --bucket $bucket |jq '.DeleteMarkers'`

    echo "Removing files"
    for version in $(echo "${versions}" | jq -r '.[] | @base64'); do 
        version=$(echo ${version} | base64 --decode)

        key=`echo $version | jq -r .Key`
        versionId=`echo $version | jq -r .VersionId `
        cmd="aws s3api delete-object --bucket $bucket --key $key --version-id $versionId"
        echo $cmd
        $cmd
    done

    echo "Removing delete markers"
    for marker in $(echo "${markers}" | jq -r '.[] | @base64'); do 
        marker=$(echo ${marker} | base64 --decode)

        key=`echo $marker | jq -r .Key`
        versionId=`echo $marker | jq -r .VersionId `
        cmd="aws s3api delete-object --bucket $bucket --key $key --version-id $versionId"
        echo $cmd
        $cmd
    done

    echo "Deleting the buckt, now that it's empty..."
    cmd="aws s3api delete-bucket --bucket $bucket"
    echo $cmd
    $cmd

fi