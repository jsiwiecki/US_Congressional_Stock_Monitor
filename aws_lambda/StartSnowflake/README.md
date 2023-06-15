# StartSnowflake
This function triggers a Snowflake Stored Procedure.

## Docker
Due to issues with libraries in AWS Lambda function runtime with one of libraries, it was necessary to use a docker which will act as a runtime for AWS Lambda function. Remember about:
- proper policies for lambda. 
- necessary environmental variables to connect with Snowflake.

To speed up process, following steps are in `Docker_Lambda_function_prep.sh`. 
Just necessary details are needed to be added there (like AWS ID etc.). Or you can do it manually following the steps:

1. Create docker image
`docker build -t savefetchdate:latest -f ./Docker/Dockerfile .`

2. Tag the image
`docker tag <image> <aws_id>.dkr.ecr.<region>.amazonaws.com/<image>`

3. Use AWS CLI (if needed, isntall it)

4. Create a new repository in Amazon ECR:
`aws ecr create-repository --repository-name <your-repository-name>`

5. Authenticate your Docker client to your Amazon ECR registry:
`aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.<region>.amazonaws.com`

6. Push docker image
`docker push <aws_id>.dkr.ecr.eu-central-1.amazonaws.com/save_date`

7. Create lambda function which will use a docker image
```bash
aws lambda create-function \
  --function-name your-function-name \
  --package-type Image \
  --code ImageUri=<account-id>.dkr.ecr.<region>.amazonaws.com/<repo_name>:latest \
  --role <ARN_execution_role> \
  --timeout 60 \
  --memory-size 128
```

8. Update lambda code:
```bash
aws lambda update-function-code \
  --function-name SaveFetchDate \
  --image-uri <account-id>.dkr.ecr.eu-central-1.amazonaws.com/<repo_name>:latest