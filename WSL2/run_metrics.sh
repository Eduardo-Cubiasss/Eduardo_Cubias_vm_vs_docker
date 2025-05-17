#!/bin/bash

# ===============================
# Script: run_metrics.sh
# Requiere: Ubuntu/WSL2, sudo
# ===============================

# Carpeta destino de métricas
METRIC_DIR="metricas_wsl"
mkdir -p "$METRIC_DIR"

# Timestamp para nombre de archivos
TS=$(date +"%Y-%m-%d_%H-%M-%S")
RESUMEN="$METRIC_DIR/resumen_$TS.txt"

# Detectar si está en WSL
echo "[INFO] Verificando entorno..."
if ! grep -qiE "wsl" /proc/version; then
  echo "[ERROR] Este script está diseñado para ejecutarse en WSL2 (Ubuntu)." >&2
  exit 1
fi

# Instalación de paquetes necesarios
REQUIRED=(mysql-server mysql-client sysbench fio iperf3 htop bc time gnuplot)
echo "[INFO] Instalando herramientas necesarias..."
sudo apt update -y && sudo apt install -y "${REQUIRED[@]}"

# MySQL: crear usuario y base de datos si no existen
echo "[INFO] Configurando MySQL..."
echo -n "Ingrese nombre de usuario MySQL a crear: "
read MYSQL_USER
echo -n "Ingrese contraseña para $MYSQL_USER: "
read -s MYSQL_PASS
echo

# Comprobación y creación del usuario si no existe
USER_EXISTS=$(mysql -u root -e "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = '$MYSQL_USER');" 2>/dev/null | tail -1)
if [ "$USER_EXISTS" != "1" ]; then
  mysql -u root -e "CREATE USER '$MYSQL_USER'@'localhost' IDENTIFIED BY '$MYSQL_PASS';"
  mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_USER'@'localhost'; FLUSH PRIVILEGES;"
  echo "[OK] Usuario creado."
else
  echo "[INFO] Usuario MySQL ya existe."
fi

# Crear DB sakila si no existe
DB_EXISTS=$(mysql -u root -e "SHOW DATABASES LIKE 'sakila';" | grep sakila)
if [ -z "$DB_EXISTS" ]; then
  echo "[INFO] Creando base de datos sakila..."
  mysql -u root -e "CREATE DATABASE sakila;"
  DB_CREATED=true
else
  echo "[INFO] La base de datos 'sakila' ya existe."
  DB_CREATED=false
fi

# Importar datos si se creó la base de datos
if [ "$DB_CREATED" = true ]; then
  echo "[INFO] Importando esquema y datos..."
  SCRIPT_DIR=$(dirname "$0")
  mysql -u root sakila < "$SCRIPT_DIR/sakila-schema.sql"
  mysql -u root sakila < "$SCRIPT_DIR/sakila-data.sql"
  echo "[OK] Base de datos importada."
fi

# Métricas CPU y RAM
CPU_RAM=$(top -b -n1 | head -n5)
echo -e "===== CPU Y RAM =====\n$CPU_RAM\n" >> "$RESUMEN"

# Sysbench CPU
echo "[INFO] Ejecutando prueba de CPU..."
CPU_BENCH=$(sysbench cpu --cpu-max-prime=20000 run | grep -E "total time|events per second")
echo -e "===== CPU BENCHMARK =====\n$CPU_BENCH\n" >> "$RESUMEN"

# I/O benchmark con fio
echo "[INFO] Ejecutando prueba de disco (1GB)..."
FIO_OUT=$(fio --name=test --size=1G --filename=$METRIC_DIR/testfile --bs=1M --rw=write --iodepth=1 --direct=1)
echo -e "===== DISCO I/O =====\n$(echo "$FIO_OUT" | grep -A4 "WRITE")\n" >> "$RESUMEN"
rm "$METRIC_DIR/testfile"

# Extraer y guardar datos para gráfico de disco
DISK_MBPS=$(echo "$FIO_OUT" | grep -oP 'bw=\K[0-9.]+' | head -1)
echo -e "$TS\t$DISK_MBPS" >> "$METRIC_DIR/historial_disco.dat"

# Prueba de consulta SQL
echo "[INFO] Ejecutando consulta a MySQL..."
SQL_TEST=$(mysql -u "$MYSQL_USER" -p"$MYSQL_PASS" -e "USE sakila; SELECT COUNT(*) FROM film;" 2>/dev/null)
echo -e "===== CONSULTA SQL =====\n$SQL_TEST\n" >> "$RESUMEN"

# Extraer y guardar datos para gráfico de SQL
SQL_COUNT=$(echo "$SQL_TEST" | tail -n1)
echo -e "$TS\t$SQL_COUNT" >> "$METRIC_DIR/historial_sql.dat"

# Crear gráficos con gnuplot
if command -v gnuplot &> /dev/null; then
  echo "[INFO] Generando gráfico de CPU..."
  echo -e "#Tiempo\tEventos/s\n1\t$(echo "$CPU_BENCH" | grep "events per second" | awk '{print $4}')" > "$METRIC_DIR/cpu_$TS.dat"
  echo -e "set terminal png size 600,400\nset output '$METRIC_DIR/grafica_cpu_$TS.png'\nset title 'Rendimiento CPU'\nset xlabel 'Prueba'\nset ylabel 'Eventos/s'\nplot '$METRIC_DIR/cpu_$TS.dat' using 1:2 with linespoints title 'CPU'" | gnuplot

  echo "[INFO] Generando gráfico de Disco..."
  echo -e "set terminal png size 600,400\nset xdata time\nset timefmt '%Y-%m-%d_%H-%M-%S'\nset format x '%H:%M'\nset output '$METRIC_DIR/grafica_disco.png'\nset title 'Rendimiento de Disco'\nset xlabel 'Tiempo'\nset ylabel 'MiB/s'\nplot '$METRIC_DIR/historial_disco.dat' using 1:2 with linespoints title 'MiB/s'" | gnuplot

  echo "[INFO] Generando gráfico de SQL..."
  echo -e "set terminal png size 600,400\nset xdata time\nset timefmt '%Y-%m-%d_%H-%M-%S'\nset format x '%H:%M'\nset output '$METRIC_DIR/grafica_sql.png'\nset title 'Registros SQL (tabla film)'\nset xlabel 'Tiempo'\nset ylabel 'Cantidad'\nplot '$METRIC_DIR/historial_sql.dat' using 1:2 with linespoints title 'Registros'" | gnuplot
fi

echo "[OK] Métricas completadas. Resultados en $RESUMEN"

