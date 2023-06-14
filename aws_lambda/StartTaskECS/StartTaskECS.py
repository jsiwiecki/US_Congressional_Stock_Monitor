import os
import boto3
import json
from botocore.exceptions import ClientError

def get_secrets():

    secret_name = os.getenv("SECRET")
    region_name = os.getenv("REGION")

    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
        raise e

    secret = get_secret_value_response['SecretString']
    secret_dict = json.loads(secret)

    aws_region = secret_dict["AWS_REGION"]
    cluster_name = secret_dict["CLUSTER_NAME"]
    task_definition = secret_dict["TASK_DEFINITION"]
    subnet_id = secret_dict["SUBNET_ID"]
    security_group_id = secret_dict["SECURITY_GROUP_ID"]

    return aws_region, cluster_name, task_definition, subnet_id, security_group_id


def lambda_handler(event,context):

    aws_region, cluster_name, task_definition, subnet_id, security_group_id = get_secrets()
    print("HERE")

    AWS_REGION = aws_region
    CLUSTER_NAME = cluster_name
    TASK_DEFINITION = task_definition
    SUBNET_ID = subnet_id
    SECURITY_GROUP_ID = security_group_id

    ecs_client = boto3.client('ecs', region_name=AWS_REGION)

    response = ecs_client.run_task(
        cluster=CLUSTER_NAME,
        launchType='FARGATE',
        taskDefinition=TASK_DEFINITION,
        count=1,
        platformVersion='LATEST',
        networkConfiguration={
            'awsvpcConfiguration': {
                'subnets': [SUBNET_ID],
                'assignPublicIp': 'ENABLED',
                'securityGroups': [SECURITY_GROUP_ID]
            }
        }
    )

    return str(response)
