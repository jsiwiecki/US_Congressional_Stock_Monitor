#!/bin/bash

docker build -t s3 -f Docker/Dockerfile . && \

docker run -p 4040:4040 \
           -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
           -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
           -e S3_BUCKET_NAME=$S3_BUCKET_NAME \
           -e AWS_REGION=$AWS_REGION \
           s3