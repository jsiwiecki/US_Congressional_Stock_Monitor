# StartTaskECS

This function triggers a Spark Application in AWS ECS.

## Installation
0. Install required libraries
`pip install --target=./lib -r requirements.txt`

1. Zip needed libraries (from folder with libraries)
`zip -r ../deployment_package.zip .`

2. Zip zipped libs with function itself
`zip -g deployment_package.zip StartTaskECS.py`

3. Upload it to AWS Lambda. Remember to adjust Handler:
`<NameOfScript>.<NameOfMainFunction>`

4. Add environmental variables to AWS Lambda: 
`REGION`
`SECRET`

5. This script for AWS Lambda needs proper permissions to be able to read from Secrets Manager + run tasks in ECS.
