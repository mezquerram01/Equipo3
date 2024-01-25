#!/bin/bash
# Crear la clave y guardarla en un archivo
aws ec2 create-key-pair --key-name mensagl-2024 --query 'KeyMaterial' --output text > mensagl-2024.pem
echo "Se ha creado el par de claves con el nombre mensagl-2024"
# Asignar el nombre de la clave a una variable
clave="mensagl-2024"
subnet_public1_id=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=publica1" --query 'Subnets[0].SubnetId' --output json | jq -r '.')
echo "Se ha descrito la subred1 con el nombre publica1 con la id $subnet_public1_id"
wget https://raw.githubusercontent.com/alexchispa/Equipo3/Equipo3/script-nginx
echo "Se ha descargado el archivo script-nginx"
# Lanzar una instancia EC2 utilizando la VPC 
ec2_nginx=$(aws ec2 run-instances --image-id ami-0c7217cdde317cfec --instance-type t2.micro --key-name $clave --subnet-id $subnet_public1_id --associate-public-ip-address --user-data file://./script-nginx --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=nginx3}]' --output json)
echo "Se ha creado una instancia de ubuntu 20.04 con el par de claves $clave en la subred $subnet_public1_id"
# Obtener la ID del grupo de seguridad "nginx"
nginx_security_group_id=$(aws ec2 describe-security-groups --filters "Name=tag:Name,Values=nginx" --query 'SecurityGroups[0].GroupId' --output json | jq -r '.')
echo "Se ha obtenido la id del grupo de seguridad de nginx con la id $nginx_security_group_id"
instance_id=$(echo $ec2_nginx | jq -r '.Instances[0].InstanceId')
echo "Se ha obtenido la id de la instacia con la id $ec2_nginx"
aws ec2 modify-instance-attribute --instance-id $instance_id --groups $nginx_security_group_id
echo "Se ha modificado la instancia con la id $ec2_nginx para asignarle el grupo de seguridad con la id $nginx_security_group_id"
