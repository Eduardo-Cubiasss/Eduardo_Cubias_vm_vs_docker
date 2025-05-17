=======================
WSL2 MÉTRICAS DE RENDIMIENTO
=======================

Este proyecto contiene un script para medir métricas clave de rendimiento en entornos WSL2 con Ubuntu.

-----------------------
REQUISITOS
-----------------------
- WSL2 con Ubuntu instalado
- Permisos sudo
- Acceso a Internet
- Base de datos MySQL funcionando (con base `sakila` importada)

-----------------------
ARCHIVOS INCLUIDOS
-----------------------
1. run_metrics.sh
   - Script bash que:
     * Verifica entorno
     * Instala herramientas necesarias
     * Ejecuta pruebas de CPU, RAM, Disco
     * Consulta simple a MySQL
     * Guarda resultados en: ~/metricas_wsl/*.log

2. README.txt
   - Este documento.

-----------------------
CÓMO USAR
-----------------------
1. Abre WSL2 (Ubuntu)
2. Ve al directorio donde guardaste los archivos
3. Ejecuta el script:
   
   bash run_metrics.sh

4. Ingresa contraseña de sudo si se solicita
5. Al final, los resultados estarán en:

   ~/metricas_wsl/

-----------------------
RESULTADOS GENERADOS
-----------------------
- uso_ram_idle.log
- uso_cpu_idle.log
- cpu_benchmark.log
- disk_benchmark.log
- mysql_query_tiempo.log

-----------------------
NOTAS
-----------------------
- Para evitar errores de permisos, NO ejecutes desde doble clic en Windows.
- Si necesitas ejecutar MySQL en Docker, crea una versión paralela del script para contenedor.

