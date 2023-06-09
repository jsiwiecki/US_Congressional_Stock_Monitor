FROM ubuntu:18.04

RUN apt-get update && \
    apt-get install -y software-properties-common curl openjdk-8-jdk

RUN apt-get install -y python3.8 python3-pip && \
    pip3 install --upgrade pip

RUN curl -L -O https://archive.apache.org/dist/spark/spark-3.1.2/spark-3.1.2-bin-hadoop3.2.tgz && \
    tar -xf spark-3.1.2-bin-hadoop3.2.tgz && \
    mv spark-3.1.2-bin-hadoop3.2 /opt/spark && \
    rm spark-3.1.2-bin-hadoop3.2.tgz

RUN curl -L -o /opt/spark/jars/hadoop-aws-3.2.0.jar https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.2.0/hadoop-aws-3.2.0.jar && \
    curl -L -o /opt/spark/jars/aws-java-sdk-bundle-1.11.900.jar https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.11.900/aws-java-sdk-bundle-1.11.900.jar

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV SPARK_HOME=/opt/spark
ENV PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin

RUN pip3 install pyspark==3.1.2

COPY ../requirements.txt opt/spark/requirements.txt
RUN pip3 install -r opt/spark/requirements.txt

ENV AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
ENV AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
ENV S3_BUCKET_NAME=${S3_BUCKET_NAME}

COPY ../app/s3_transformer.py /opt/spark/scripts/s3_transformer.py

WORKDIR /opt/spark/scripts

ENTRYPOINT ["spark-submit", "--packages", "org.apache.hadoop:hadoop-aws:3.2.0,com.amazonaws:aws-java-sdk-bundle:1.11.900", "s3_transformer.py"]