FROM jupyter/pyspark-notebook:spark-3.5.0

USER root

# 1. Install Delta Lake Python library
RUN pip install --no-cache-dir delta-spark==3.2.0

# 2. Add Delta and S3/MinIO JARs
ADD https://repo1.maven.org/maven2/io/delta/delta-spark_2.12/3.1.0/delta-spark_2.12-3.1.0.jar /usr/local/spark/jars/
ADD https://repo1.maven.org/maven2/io/delta/delta-storage/3.1.0/delta-storage-3.1.0.jar /usr/local/spark/jars/
ADD https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.4/hadoop-aws-3.3.4.jar /usr/local/spark/jars/
ADD https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.262/aws-java-sdk-bundle-1.12.262.jar /usr/local/spark/jars/

# 3. COPY THE CONFIG FILE (Put it here!)
# Ensure spark-defaults.conf is in the same folder as this Dockerfile on your Mac
COPY spark-defaults.conf /usr/local/spark/conf/spark-defaults.conf

# 4. Fix permissions
RUN chown -R jovyan:users /home/jovyan /usr/local/spark

# Ensure the JARs are in the correct place and PUBLICLY READABLE
RUN chmod 644 /usr/local/spark/jars/hadoop-aws-3.3.4.jar && \
    chmod 644 /usr/local/spark/jars/aws-java-sdk-bundle-1.12.262.jar && \
    chmod 644 /usr/local/spark/jars/delta-spark_2.12-3.1.0.jar && \
    chmod 644 /usr/local/spark/jars/delta-storage-3.1.0.jar

# IMPORTANT: Your spark-defaults.conf uses /opt/spark/jars, 
# but your ls shows /usr/local/spark/jars. Let's make them consistent.
RUN mkdir -p /opt/spark/jars && \
    cp /usr/local/spark/jars/*aws* /opt/spark/jars/ && \
    chmod -R 755 /opt/spark/jars


USER jovyan
WORKDIR /home/jovyan/work1
