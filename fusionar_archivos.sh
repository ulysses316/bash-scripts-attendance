#!/bin/bash

# Definir la fecha a procesar
# fecha=$(date +%F)
fecha="2023-04-18"

# Obtener la lista de archivos JSON de WiFi y Ethernet correspondientes a la fecha especificada
wifi_files=$(ls ./wifi | grep "${fecha}_.*\.json")
eth_files=$(ls ./ethernet | grep "${fecha}_.*\.json")

# Juntar todos los archivos JSON de WiFi correspondientes a la fecha en un solo archivo
for archivo in $wifi_files; do
  cat ./wifi/$archivo | sort -u | tee -a ${fecha}_merged_file.json
done

# Juntar todos los archivos JSON de Ethernet correspondientes a la fecha en un solo archivo
for archivo in $eth_files; do
  cat ./ethernet/$archivo | sort -u | tee -a ${fecha}_merged_file.json
done

# Eliminar las llaves {} del archivo fusionado de Ethernet
tr -d '{}' < ${fecha}_merged_file.json > ${fecha}_merged_file.json.temp && mv ${fecha}_merged_file.json.temp ${fecha}_merged_file.json

# Ordenar y eliminar duplicados del archivo fusionado
sort -u ${fecha}_merged_file.json > ${fecha}_merged_file.json.temp && mv ${fecha}_merged_file.json.temp ${fecha}_merged_file.json


# Agregar llaves {} al principio y al final del archivo fusionado
echo "{" | cat - ${fecha}_merged_file.json > ${fecha}_merged_file.json.temp
mv ${fecha}_merged_file.json.temp ${fecha}_merged_file.json
echo "}" >> ${fecha}_merged_file.json

# Agregar la fecha de procesamiento al archivo fusionado
jq --arg v "$fecha" '. + {date: $v}' ${fecha}_merged_file.json > ${fecha}_merged_file.temp.json && mv ${fecha}_merged_file.temp.json ${fecha}_merged_file.json

# Importar el archivo fusionado a la base de datos MongoDB
mongoimport --host localhost --port 27017 --db Users --collection Assistant --file ${fecha}_merged_file.json

# Limpiar la consola
clear

# Imprimir mensaje de éxito
echo "Se han fusionado todos los archivos en el archivo ${fecha}_${fecha}_merged_file.json"
