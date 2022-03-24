#!/bin/bash

red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

echo '    ********     Enabling SSE for all DynamoDB Tables    ********     '
echo '----------------------------------------------------------------------'
echo '| DynamoDB Table                              |     SSE Algorithm    |'
echo '----------------------------------------------------------------------'

tables=$(aws dynamodb list-tables --output text --query TableNames)

for table in $tables; do
        sse_status=$(aws dynamodb describe-table --table-name "$table" | jq -r '.Table.SSEDescription.Status')
        sse_type=$(aws dynamodb describe-table --table-name "$table" | jq -r '.Table.SSEDescription.SSEType')

        if [ "$sse_status" == "ENABLED" ]; then
                printf -v output "| ${yellow} %s ${reset}    | ${green} %s - %s ${reset}    |" "$table" "$sse_status" "$sse_type"
        else
                printf -v output "| ${red} %s ${reset}    | ${yellow} ENABLING SSE NOW... ${reset}    |" "$table"

                aws dynamodb update-table --sse-specification Enabled=true --table-name "$table" >/dev/null 2>&1
        fi
        echo -e "$output"
done