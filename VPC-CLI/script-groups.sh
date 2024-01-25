#!/bin/bash
# Obtener el ID de la VPC
vpc_id=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=mensagl-2024" --query 'Vpcs[0].VpcId' --output json | jq -r '.')
echo "La VPC tiene la ID: $vpc_id"
# Crear un grupo de seguridad llamado "nginx"
nginx_security_group_id=$(aws ec2 create-security-group --group-name nginx --description "Security group for nginx" --vpc-id $vpc_id --output json | jq -r '.GroupId')
echo "Se ha creado el grupo de seguridad con la id $nginx_security_group_id"
#
# Agregar etiqueta al grupo de seguridad
aws ec2 create-tags --resources $nginx_security_group_id --tags Key=Name,Value=nginx
echo "Se ha agregado una etiqueta con el nombre nginx para el grupo de seguridad con la id $nginx_security_group_id"
#
# Añadir reglas de entrada al grupo de seguridad
aws ec2 authorize-security-group-ingress --group-id $nginx_security_group_id --protocol tcp --port 22 --cidr 0.0.0.0/0
echo "Se ha agragado una regla de entrada de tcp por el puerto 22 al grupo de seguridad con id $nginx_security_group_id"
aws ec2 authorize-security-group-ingress --group-id $nginx_security_group_id --protocol tcp --port 3478 --cidr 0.0.0.0/0
echo "Se ha agragado una regla de entrada de tcp por el puerto 3478 al grupo de seguridad con id $nginx_security_group_id"
aws ec2 authorize-security-group-ingress --group-id $nginx_security_group_id --protocol tcp --port 8448 --cidr 0.0.0.0/0
echo "Se ha agragado una regla de entrada de tcp por el puerto 8448 al grupo de seguridad con id $nginx_security_group_id"
aws ec2 authorize-security-group-ingress --group-id $nginx_security_group_id --protocol tcp --port 3479 --cidr 0.0.0.0/0
echo "Se ha agragado una regla de entrada de tcp por el puerto 3479 al grupo de seguridad con id $nginx_security_group_id"
aws ec2 authorize-security-group-ingress --group-id $nginx_security_group_id --protocol tcp --port 443 --cidr 0.0.0.0/0
echo "Se ha agragado una regla de entrada de tcp por el puerto 443 al grupo de seguridad con id $nginx_security_group_id"
#
#
# Crear un grupo de seguridad llamado "matrix"
matrix_security_group_id=$(aws ec2 create-security-group --group-name matrix --description "Security group for matrix" --vpc-id $vpc_id --output json | jq -r '.GroupId')
echo "Se ha creado el grupo de seguridad con la id $matrix_security_group_id"
#
# Agregar etiqueta al grupo de seguridad
aws ec2 create-tags --resources $matrix_security_group_id --tags Key=Name,Value=matrix
echo "Se ha agregado una etiqueta con el nombre matrix para el grupo de seguridad con la id $matrix_security_group_id"
#
# Añadir reglas de entrada al grupo de seguridad
aws ec2 authorize-security-group-ingress --group-id $matrix_security_group_id --protocol tcp --port 22 --cidr 0.0.0.0/0
echo "Se ha agragado una regla de entrada de tcp por el puerto 22 al grupo de seguridad con id $matrix_security_group_id"
aws ec2 authorize-security-group-ingress --group-id $matrix_security_group_id --protocol tcp --port 8448 --cidr 0.0.0.0/0
echo "Se ha agragado una regla de entrada de tcp por el puerto 8448 al grupo de seguridad con id $matrix_security_group_id"
aws ec2 authorize-security-group-ingress --group-id $matrix_security_group_id --protocol tcp --port 443 --cidr 0.0.0.0/0
echo "Se ha agragado una regla de entrada de tcp por el puerto 443 al grupo de seguridad con id $matrix_security_group_id"
aws ec2 authorize-security-group-ingress --group-id $matrix_security_group_id --protocol tcp --port 80 --cidr 0.0.0.0/0
echo "Se ha agragado una regla de entrada de tcp por el puerto 80 al grupo de seguridad con id $matrix_security_group_id"
