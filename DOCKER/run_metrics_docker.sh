#!/bin/bash

OUTPUT_DIR="/metricas_docker"

# Eliminar resultados anteriores si existen
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Iniciar MySQL
service mysql start

# Crear usuario y base de datos (solo si no existen)
mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS sakila;
CREATE USER IF NOT EXISTS 'usuario'@'localhost' IDENTIFIED BY 'clave123';
GRANT ALL PRIVILEGES ON sakila.* TO 'usuario'@'localhost';
EOF

# Cargar esquema y datos
mysql -u root sakila < /root/sakila-schema.sql
mysql -u root sakila < /root/sakila-data.sql

# Ejecutar métricas
sysbench cpu run > "$OUTPUT_DIR/sysbench_cpu.txt"
fio --name=randwrite --ioengine=libaio --rw=randwrite --bs=4k --size=64M --numjobs=4 --runtime=60 --group_reporting > "$OUTPUT_DIR/fio.txt"
iperf3 -s -D && iperf3 -c localhost > "$OUTPUT_DIR/iperf3.txt"
htop -b -n 1 > "$OUTPUT_DIR/htop.txt"
free -h > "$OUTPUT_DIR/memoria.txt"

# Crear gráficas falsas (simulación de gnuplot si está vacío)
echo "set terminal png; set output '$OUTPUT_DIR/cpu_plot.png'; plot '$OUTPUT_DIR/sysbench_cpu.txt'" | gnuplot || echo "Fallo gnuplot"

echo "[OK] Métricas completadas. Resultados en $OUTPUT_DIR"
