# Eduardo_Cubias_vm_vs_docker
Proyecto commparativo de docker y maquinas virtuales
Eduardo René Cubias Morán

# 🐳 Introducción a Docker

Docker es una plataforma que permite desarrollar, enviar y ejecutar aplicaciones dentro de **contenedores**, asegurando que funcionen de forma consistente en cualquier entorno. Este documento proporciona una guía básica para comenzar a trabajar con Docker.

---

## 📑 Índice

1. [Conceptos Básicos](#-1-conceptos-básicos)
2. [Diferencias entre Contenedores y Máquinas Virtuales](#-2-diferencias-entre-contenedores-y-máquinas-virtuales)
3. [Instalación de Docker](#-3-instalación-de-docker)
4. [Trabajando con Contenedores](#-4-trabajando-con-contenedores)
5. [Tabla de Comandos Básicos](#-5-tabla-de-comandos-básicos)

---

## 🟢 **1. Conceptos Básicos**

### 🔸 ¿Qué es Docker?

Docker es una plataforma que permite empaquetar, distribuir y ejecutar aplicaciones en **contenedores**.  
Un **contenedor** es un entorno ligero, portátil y aislado que contiene una aplicación junto con todas sus dependencias, lo que garantiza su funcionamiento uniforme sin importar el sistema operativo del host (siempre que tenga Docker instalado).

---

## 🟢 **2. Diferencias entre Contenedores y Máquinas Virtuales**

| Característica           | Máquinas Virtuales (VM)          | Contenedores (Docker)            |
|--------------------------|----------------------------------|----------------------------------|
| **Sistema Operativo**    | Cada VM incluye su propio SO     | Comparten el SO del host         |
| **Consumo de Recursos**  | Altos (GBs de RAM y almacenamiento) | Bajos (MBs de RAM)            |
| **Velocidad de Arranque**| Lento (minutos)                  | Rápido (segundos)                |
| **Escalabilidad**        | Menos eficiente                  | Muy eficiente                    |

---

## 🟢 **3. Instalación de Docker**

Docker está disponible para Windows, Linux y macOS.  
Para instalar Docker, consulta la guía oficial:  
🔗 [Guía de instalación de Docker](https://docs.docker.com/get-docker/)

---

## 🟢 **4. Trabajando con Contenedores**

### 🔸 Imágenes vs. Contenedores

- **Imagen:** Plantilla inmutable que contiene el sistema base, dependencias y configuración de una aplicación.
- **Contenedor:** Instancia en ejecución de una imagen. Es efímero, portátil y aislado.

### 🔸 Comandos Básicos

```bash
# Verificar versión de Docker instalada
docker --version

# Ejecutar un contenedor de Ubuntu en modo interactivo
docker run -it ubuntu bash

# Listar contenedores en ejecución
docker ps

# Detener un contenedor
docker stop <CONTAINER_ID>

# Eliminar un contenedor
docker rm <CONTAINER_ID>

# Eliminar una imagen
docker rmi <IMAGE_ID>

# Ver imágenes descargadas
docker images
