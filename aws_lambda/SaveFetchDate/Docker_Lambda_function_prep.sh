#!/bin/bash

docker build -t save_date:latest -f ./Docker/Dockerfile .

docker tag save_date:latest <ID>.dkr.ecr.eu-central-1.amazonaws.com/save_date:latest

docker push <ID>.dkr.ecr.eu-central-1.amazonaws.com/save_date

# Check if the Lambda function exists
LAMBDA_FUNCTION=$(aws lambda list-functions | jq '.Functions[] | select(.FunctionName=="SaveFetchDate")')

# Create or update the Lambda function
if [ -z "$LAMBDA_FUNCTION" ]; then
    # Create the Lambda function
    aws lambda create-function \
        --function-name SaveFetchDate \
        --package-type Image \
        --code ImageUri=<ID>.dkr.ecr.eu-central-1.amazonaws.com/save_date:latest \
        --role arn:aws:iam::<IAM>:role/UsingLambda \
        --timeout 60 \
        --memory-size 128
else
    # Update the Lambda function code
    aws lambda update-function-code \
        --function-name SaveFetchDate \
        --image-uri <ID>.dkr.ecr.eu-central-1.amazonaws.com/save_date:latest
fi

