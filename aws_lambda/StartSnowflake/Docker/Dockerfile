FROM public.ecr.aws/lambda/python:3.8

RUN yum -y update && yum -y upgrade

RUN yum -y update && \
    yum -y install \
      yum-utils \
      gcc-c++ \
      openssl-devel \
      libffi-devel \
      python3-devel \
      zip

WORKDIR /var/task

COPY ../requirements.txt ./requirements.txt
COPY ../StartSnowflake.py ./StartSnowflake.py

RUN pip3 install -r requirements.txt


CMD ["StartSnowflake.lambda_handler"]