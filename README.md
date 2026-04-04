# mini-spark-container
mini-spark-container/
├── docker/
│   ├── build/
│   │   └── delta-jupyter.Dockerfile
│   ├── minio-compose.yml
│   └── spark-compose.yml
├── notebooks/                <-- Your .ipynb files will live here
└── .gitignore


docker/build/delta-jupyter.Dockerfile
docker/minio-compose.yml
docker/spark-compose.yml

Step 1: Initialize the Storage 
docker-compose -f minio-compose.yml up -d

Step 2: Launch the Spark Cluster
docker-compose -f spark-compose.yml up -d --build

Step 3: 
Start Coding in Jupyter
http://localhost:8888
token is password

Watch and manage spark jobs : 
http://localhost:8080/ 
<img width="772" height="594" alt="image" src="https://github.com/user-attachments/assets/110ff3e8-5070-496d-85ef-72ee9152c7f3" />

Test the miniio 
http://localhost:9001/
<img width="716" height="394" alt="image" src="https://github.com/user-attachments/assets/9d1d2a9a-47a5-490d-917f-7072db7f71d3" />


-----------------------------------------------
from pyspark.sql import SparkSession
#from delta import configure_spark_with_delta_pip

from pyspark.sql import SparkSession
from delta import *

# 1. Point to the Spark Master container defined in your docker-compose
# 2. Tell Spark where the MinIO storage lives
builder = SparkSession.builder \
    .appName("Abhi-Distributed-Delta-Job") \
    .master("spark://spark-master:7077") \
    .config("spark.hadoop.fs.s3a.endpoint", "http://minio-storage:9000") \
    .config("spark.hadoop.fs.s3a.access.key", "admin") \
    .config("spark.hadoop.fs.s3a.secret.key", "password") \
    .config("spark.hadoop.fs.s3a.path.style.access", "true") \
    .config("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem") \
    .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension") \
    .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog") \
    .config("spark.executor.memory", "1g") \
    .config("spark.executor.cores", "1")

# Use the delta-spark helper to ensure all distributed workers get the libraries
spark = configure_spark_with_delta_pip(builder).getOrCreate()

print("Connected to Master at spark://spark-master:7077")

print("Data saved to Delta Lake on MinIO!")](http://localhost:8888)
 --------------------------------------------------------------------------------------------------------
Error1 : 
The code failed to create spark object

Reason : sometime delta-spark 3.1.0 dont work well with jupyter  3.5.0

vim docker/build/delta-jupyter.Dockerfile 

RUN pip install delta-spark==3.2.0  ( Replaced older version) 

Rebuilt the imege and restarted the containers
docker-compose -f spark-compose.yml build  (Rebuilt image ) 
docker-compose -f spark-compose.yml up -d  ( Restart containers )

 --------------------------------------------------------------------------------------------------------
 Error2 : Jupyter notebook was not refreshed 
 Solution : Recreated jupyter notebook with 3 commands
 
 1010  docker-compose -f spark-compose.yml down
 1011  docker rmi docker-jupyter
 1012  docker-compose -f spark-compose.yml up -d --build
 
--------------------------------------------------------------------------------------------------------

