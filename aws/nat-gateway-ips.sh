#!/bin/bash -e

# Script to get the NAT Gateway IPs for a given VPC

CLUSTER_NAME=$1

# Find the VPC ID for the given EKS cluster
VPC_ID=$(aws eks describe-cluster --name $CLUSTER_NAME --query 'cluster.resourcesVpcConfig.vpcId' --output text)

# Find all NAT Gateways for the given VPC
NAT_GATEWAY_IDS=$(aws ec2 describe-nat-gateways --filter Name=vpc-id,Values=$VPC_ID --query 'NatGateways[*].NatGatewayId' --output text)

# Print the IPs for each NAT Gateway
echo "NAT Gateway IPs for EKS Cluster $CLUSTER_NAME ($VPC_ID):"
for NAT_GATEWAY_ID in $NAT_GATEWAY_IDS; do
  PUBLIC_IP=$(aws ec2 describe-nat-gateways --nat-gateway-ids $NAT_GATEWAY_ID --query 'NatGateways[*].NatGatewayAddresses[*].PublicIp' --output text)
  echo "$NAT_GATEWAY_ID: $PUBLIC_IP"
done
