FROM ubuntu:22.04

RUN apt update && apt install -y \
    mysql-server mysql-client \
    sysbench fio iperf3 htop bc time gnuplot \
    && apt clean

COPY sakila-db/sakila-db/sakila-schema.sql /root/sakila-schema.sql
COPY sakila-db/sakila-db/sakila-data.sql /root/sakila-data.sql
COPY DOCKER/run_metrics_docker.sh /root/run_metrics_docker.sh

RUN chmod +x /root/run_metrics_docker.sh
