#!/bin/bash
# Crear la VPC
vpc_id=$(aws ec2 create-vpc --cidr-block 10.3.0.0/16 --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=mensagl-2024}]' --output json | jq -r '.Vpc.VpcId')
echo "La vpc se ha creado con la id $vpc_id"
#
# Crear la tabla de enrutamiento para la subred pública
public_route_table_id=$(aws ec2 create-route-table --vpc-id $vpc_id --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=tabla-de-enrutamiento-publica}]' --output json | jq -r '.RouteTable.RouteTableId')
echo "La tabla de enrutamiento publica se ha creado con la id $public_route_table_id"
#
# Crear la subred pública1
subnet_public1_id=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block 10.3.10.0/24 --availability-zone us-east-1a --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=publica1}]' --output json | jq -r '.Subnet.SubnetId')
echo "La subred publica 1 se ha creado con la id $subnet_public1_id"
#
# Asociarla con la tabla de enrutamiento
aws ec2 associate-route-table --subnet-id $subnet_public1_id --route-table-id $public_route_table_id
echo "Se ha asociado la red $subnet_public1_id a la tabla de enrutamiento $public_route_table_id"
#
# Crear la subred pública2
subnet_public2_id=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block 10.3.20.0/24 --availability-zone us-east-1b --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=publica2}]' --output json | jq -r '.Subnet.SubnetId')
echo "La subred publica 2 se ha creado con la id $subnet_public2_id"
#
# Asociarla con la tabla de enrutamiento
aws ec2 associate-route-table --subnet-id $subnet_public2_id --route-table-id $public_route_table_id
echo "Se ha asociado la subred $subnet_public2_id a la tabla de enrutamiento $public_route_table_id"
#
# Crear el Internet Gateway
igw_id=$(aws ec2 create-internet-gateway --output json | jq -r '.InternetGateway.InternetGatewayId')
echo "Se ha creado la gateway de internet con la id $igw_id"
#
# Asociar el Internet Gateway con la VPC
aws ec2 attach-internet-gateway --internet-gateway-id $igw_id --vpc-id $vpc_id
echo "Se ha asociado la gateway de internet con la id $igw_id con la vpc $vpc_id"
#
# Crea una ruta en la tabla de enrutamiento pública utilizando el Internet Gateway
aws ec2 create-route --route-table-id $public_route_table_id --destination-cidr-block 0.0.0.0/0 --gateway-id $igw_id
echo "Se ha creado una ruta en la tabla de enrutamiento publica con la id $public_route_table_id desde la gateway de internet con la id $igw_id"
#
# Crear la tabla de enrutamiento para la subred privada
private_route_table_id=$(aws ec2 create-route-table --vpc-id $vpc_id --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=tabla-de-enrutamiento-privada}]' --output json | jq -r '.RouteTable.RouteTableId')
echo "La tabla de enrutamiento privada se ha creado con la id $private_route_table_id"
#
# Crear la subred privada1
subnet_private1_id=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block 10.3.11.0/24 --availability-zone us-east-1a --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=privada1}]' --output json | jq -r '.Subnet.SubnetId')
echo "La subred privada 1 se ha creado con la id $subnet_private1_id"
#
# Asociarla con la tabla de enrutamiento
aws ec2 associate-route-table --subnet-id $subnet_private1_id --route-table-id $private_route_table_id
echo "Se ha asociado la red $subnet_private1_id a la tabla de enrutamiento $private_route_table_id"
#
# Crear la subred privada2
subnet_private2_id=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block 10.3.21.0/24 --availability-zone us-east-1b --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=privada2}]' --output json | jq -r '.Subnet.SubnetId')
echo "La subred privada 2 se ha creado con la id $subnet_private2_id"
#
# Asociarla con la tabla de enrutamiento
aws ec2 associate-route-table --subnet-id $subnet_private2_id --route-table-id $private_route_table_id
echo "Se ha asociado la red $subnet_private2_id a la tabla de enrutamiento $private_route_table_id"
#
# Crear una Elastic IP para el NAT Gateway
nat_eip_allocation_id=$(aws ec2 allocate-address --domain vpc --output json | jq -r '.AllocationId')
echo "Se ha creado la ip elastica para la nat gateway con la id $nat_eip_allocation_id"
#
# Crear el NAT Gateway
nat_gateway_id=$(aws ec2 create-nat-gateway --subnet-id $subnet_public1_id --allocation-id $nat_eip_allocation_id --output json | jq -r '.NatGateway.NatGatewayId')
echo "Se ha creado la gateway nat con la id $nat_gateway_id empleando la ip elastica con la id $nat_eip_allocation_id"
# Esperar a que el NAT Gateway esté disponible
echo "Se esta habilitando la gateway nat con la id $nat_gateway_id por favor espere"
aws ec2 wait nat-gateway-available --nat-gateway-ids $nat_gateway_id
#
# Obtener el ID de la tabla de enrutamiento de la subnet privada
private_route_table_id=$(aws ec2 describe-route-tables --filters "Name=association.subnet-id,Values=$subnet_private1_id" --query 'RouteTables[].RouteTableId' --output json | jq -r '.[0]')
echo "Se ha actualizado la tabla de enrutamiento privada con id $private_route_table_id para que el gateway nat con id $nat_gateway_id funcione correctamente"
#
# Agregar una ruta a través del NAT Gateway en la tabla de enrutamiento privada
aws ec2 create-route --route-table-id $private_route_table_id --destination-cidr-block 0.0.0.0/0 --nat-gateway-id $nat_gateway_id
echo "Se ha creado una ruta atraves del gateway nat empleando la id $nat_gateway_id a la tabla de enrutamiento privada con id $private_route_table_id"
