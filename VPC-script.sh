# Crear la VPC
vpc_id=$(aws ec2 create-vpc --cidr-block 10.3.0.0/16 --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=mensagl-2024}]' --output json | jq -r '.Vpc.VpcId')

# Crear la tabla de enrutamiento para la subred pública
public_route_table_id=$(aws ec2 create-route-table --vpc-id $vpc_id --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=tabla-de-enrutamiento-publica}]' --output json | jq -r '.RouteTable.RouteTableId')

# Crear la subred pública1
subnet_public1_id=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block 10.3.10.0/24 --availability-zone us-east-1a --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=publica1}]' --output json | jq -r '.Subnet.SubnetId')

# Asociarla con la tabla de enrutamiento
aws ec2 associate-route-table --subnet-id $subnet_public1_id --route-table-id $public_route_table_id

# Crear la subred pública2
subnet_public2_id=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block 10.3.20.0/24 --availability-zone us-east-1b --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=publica2}]' --output json | jq -r '.Subnet.SubnetId')

# Asociarla con la tabla de enrutamiento
aws ec2 associate-route-table --subnet-id $subnet_public2_id --route-table-id $public_route_table_id

# Crear el Internet Gateway
igw_id=$(aws ec2 create-internet-gateway --output json | jq -r '.InternetGateway.InternetGatewayId')

# Asociar el Internet Gateway con la VPC
aws ec2 attach-internet-gateway --internet-gateway-id $igw_id --vpc-id $vpc_id

# Crea una ruta en la tabla de enrutamiento pública utilizando el Internet Gateway
aws ec2 create-route --route-table-id $public_route_table_id --destination-cidr-block 0.0.0.0/0 --gateway-id $igw_id

# Crear la tabla de enrutamiento para la subred privada
private_route_table_id=$(aws ec2 create-route-table --vpc-id $vpc_id --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=tabla-de-enrutamiento-privada}]' --output json | jq -r '.RouteTable.RouteTableId')

# Crear la subred privada1
subnet_private1_id=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block 10.3.11.0/24 --availability-zone us-east-1a --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=privada1}]' --output json | jq -r '.Subnet.SubnetId')

# Asociarla con la tabla de enrutamiento
aws ec2 associate-route-table --subnet-id $subnet_private1_id --route-table-id $private_route_table_id

# Crear la subred privada2
subnet_private2_id=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block 10.3.21.0/24 --availability-zone us-east-1b --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=privada2}]' --output json | jq -r '.Subnet.SubnetId')

# Asociarla con la tabla de enrutamiento
aws ec2 associate-route-table --subnet-id $subnet_private2_id --route-table-id $private_route_table_id

# Crear una Elastic IP para el NAT Gateway
nat_eip_allocation_id=$(aws ec2 allocate-address --domain vpc --output json | jq -r '.AllocationId')

# Crear el NAT Gateway
nat_gateway_id=$(aws ec2 create-nat-gateway --subnet-id $subnet_public1_id --allocation-id $nat_eip_allocation_id --output json | jq -r '.NatGateway.NatGatewayId')

# Esperar a que el NAT Gateway esté disponible
aws ec2 wait nat-gateway-available --nat-gateway-ids $nat_gateway_id


# Obtener el ID de la tabla de enrutamiento de la subnet privada
private_route_table_id=$(aws ec2 describe-route-tables --filters "Name=association.subnet-id,Values=$subnet_private1_id" --query 'RouteTables[].RouteTableId' --output json | jq -r '.[0]')


# Agregar una ruta a través del NAT Gateway en la tabla de enrutamiento privada
aws ec2 create-route --route-table-id $private_route_table_id --destination-cidr-block 0.0.0.0/0 --nat-gateway-id $nat_gateway_id


