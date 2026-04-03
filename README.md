# mini-spark-container
We are creating a "Cloud-Native" sandbox on your own laptop
Combining Jupyter, Spark, and Delta Lake into one container, and then adding MinIO as a separate storage container, 

1. **The Storage Layer (minio-compose.yml)**

This file manages only your "Data Warehouse" (MinIO).

2. **The Compute Layer (spark-compose.yml)**

This file manages your Jupyter and Spark engine. Notice it "joins" the network created by the first file.



Lifecycle Management: You can stop your Spark cluster (docker-compose -f spark-compose.yml down) to save RAM on your laptop, while keeping your MinIO storage running in the background.

Pluggability: You could create a third YAML file for a different tool (like Presto or Trino) and simply point it to the same data-exchange network to query the same Delta Lake files.

Cleanliness: It prevents your "Compute" logs from getting mixed up with your "Storage" logs in your terminal.

The Execution Order

To run this correctly, you must follow this sequence:

** Start MinIO first: docker-compose -f minio-compose.yml up -d **

** Start Spark second: docker-compose -f spark-compose.yml up -d **

By using the external: true flag in the second file, the Spark containers will be able to resolve the hostname minio as if they were in the same file.
