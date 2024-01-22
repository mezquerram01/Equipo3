# Crear un grupo de seguridad llamado "nginx"
security_group_id=$(aws ec2 create-security-group --group-name nginx --description "Security group for nginx" --vpc-id $vpc_id --output json | jq -r '.GroupId')

# Agregar etiqueta al grupo de seguridad
aws ec2 create-tags --resources $security_group_id --tags Key=Name,Value=nginx

# Añadir reglas de entrada al grupo de seguridad
aws ec2 authorize-security-group-ingress --group-id $security_group_id --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $security_group_id --protocol tcp --port 3478 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $security_group_id --protocol tcp --port 8448 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $security_group_id --protocol tcp --port 3479 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $security_group_id --protocol tcp --port 443 --cidr 0.0.0.0/0

# Imprimir la ID del grupo de seguridad creado
echo "Grupo de seguridad 'nginx' creado con ID: $security_group_id"

# Crear un grupo de seguridad llamado "matrix"
security_group_id=$(aws ec2 create-security-group --group-name matrix --description "Security group for matrix" --vpc-id $vpc_id --output json | jq -r '.GroupId')

# Agregar etiqueta al grupo de seguridad
aws ec2 create-tags --resources $security_group_id --tags Key=Name,Value=matrix

# Añadir reglas de entrada al grupo de seguridad
aws ec2 authorize-security-group-ingress --group-id $security_group_id --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $security_group_id --protocol tcp --port 8448 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $security_group_id --protocol tcp --port 443 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $security_group_id --protocol tcp --port 80 --cidr 0.0.0.0/0

# Imprimir la ID del grupo de seguridad creado
echo "Grupo de seguridad 'matrix' creado con ID: $security_group_id y etiqueta 'matrix'"
