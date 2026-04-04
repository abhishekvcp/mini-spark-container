# 🚀 Laptop : Distributed Spark & Delta Lakehouse on MinIO (Macbook M1/ARM64)

This project establishes a high-performance distributed Spark cluster using Docker. It is specifically optimized for **Apple Silicon (M1/M2/M3)** and uses **Delta Lake** for ACID transactions and **MinIO** as the S3-compatible storage layer.

## 📂 Project Structure
```text
.
├── build/
│   ├── delta-jupyter.Dockerfile  # Unified image for Driver, Master, & Worker
│   └── spark-defaults.conf       # System-level Spark/Hadoop configurations
├── notebooks/                    # Persistent storage for .ipynb files
├── spark-compose.yml             # Spark Cluster Orchestration (Master/Worker)
└── minio-compose.yml             # Storage & Bucket Auto-creation

************************************************************************************************************
Prerequisite : INSTALL Docker Desktop on Macbook Apple silicon

We are going to spin up spark cluster with 1 master , 1 worker , 1 jupyter notebook engine with lakehouse , 1 minio engine to simulate aws s3 and send data as if it were a real cluster.

***************************************************************************************************************

Setting up Spark with S3A on M1 Macs often leads to ClassNotFoundException. This project solves that through three critical layers of configuration:

System-Level Defaults: Instead of configuring S3 in Python, we bake spark-defaults.conf into the Docker image. This ensures the JVM on every node (Driver and Worker) initializes the S3A protocol at startup.

Permission Synchronization: JARs are explicitly set to chmod 644 in the Dockerfile. This prevents the "Silent Failure" where a Worker cannot read the AWS SDK because it is owned by root.

Architecture Alignment: Using a single Dockerfile for Master, Worker, and Jupyter ensures the Java Classpath is identical across the entire cluster, preventing "Brain-Split" errors.

######################################################

STARTING THE Environment

docker-compose -f minio-compose.yml up -d

docker-compose -f spark-compose.yml up -d

jupyter -> http://localhost:8888  (token = password)
minio - > http://localhost:9001  (admin password)
Spark - > http://localhost:8080/ 


######################################################

STOPPING THE Environment

docker-compose -f spark-compose.yml down && docker-compose -f minio-compose.yml down

# clean the unused images from the environment
docker image prune -f

######################################################

REBUILD Environment when there is change in docker compose files

docker-compose -f spark-compose.yml up -d --build --force-recreate

######################################################

## pyspark Code Send data to local lakshouse ##

from pyspark.sql import SparkSession
from delta import *

builder = SparkSession.builder \
    .appName("Lakehouse-Test") \
    .master("spark://spark-master:7077") \
    .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension") \
    .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog")

spark = configure_spark_with_delta_pip(builder).getOrCreate()

# Write a Delta Table
spark.range(10).write.format("delta").mode("overwrite").save("s3a://lakehouse/my_table")

######################################################

<img width="862" height="400" alt="image" src="https://github.com/user-attachments/assets/7d4932f4-3c73-4328-bd8e-a6b217caedf0" />






