#!/bin/bash
RDS_INSTANCE_NAME=qa; export RDS_INSTANCE_NAME
export AWS_DEFAULT_REGION=eu-central-1
aws s3 ls
aws logs describe-log-groups --region eu-central-1 | jq -r '.logGroups[].logGroupName' | while read file
do
    if [[ $file == "/aws/rds/instance/${RDS_INSTANCE_NAME}/postgresql" ]] || [[ $file == "/aws/rds/instance/${RDS_INSTANCE_NAME}/upgrade" ]] || [[ $file == "/aws/rds/proxy/${RDS_INSTANCE_NAME}" ]]
    then
        echo "Deleting log group: $file"
        aws logs delete-log-group --log-group-name $file
    fi
done
