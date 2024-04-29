#!/bin/bash

CLUSTER=$1
if [ -z "$CLUSTER" ]; then
  echo "Usage: $0 <cluster-name>"
  exit 1
fi

VERSION=$(aws eks describe-cluster --name $CLUSTER --query 'cluster.version' --output text)
echo "${CLUSTER}: v${VERSION}"

# List node groups and delete them
aws eks list-nodegroups --cluster-name $CLUSTER --output text | awk '{print $2}' | while read -r NODEGROUP; do
  echo "Deleting nodegroup $NODEGROUP in cluster $CLUSTER"
  OUTPUT=$(aws eks delete-nodegroup --cluster-name $CLUSTER --nodegroup-name $NODEGROUP | cat)
  STATUS=$(echo $OUTPUT | jq -r '.nodegroup.status')
  # If status is "DELETING", wait until it's deleted
  while [ "$STATUS" == "DELETING" ]; do
    echo "Waiting for nodegroup $NODEGROUP to be deleted..."
    sleep 10
    OUTPUT=$(aws eks describe-nodegroup --cluster-name $CLUSTER --nodegroup-name $NODEGROUP | cat)
    STATUS=$(echo $OUTPUT | jq -r '.nodegroup.status')
  done
done

# Delete the EKS cluster
echo "Deleting EKS cluster $CLUSTER"
OUTPUT=$(aws eks delete-cluster --name $CLUSTER | cat)
STATUS=$(echo $OUTPUT | jq -r '.cluster.status')
# If status is "DELETING", wait until it's deleted
while [ "$STATUS" == "DELETING" ]; do
  echo "Waiting for cluster $CLUSTER to be deleted..."
  sleep 10
  OUTPUT=$(aws eks describe-cluster --name $CLUSTER | cat)
  STATUS=$(echo $OUTPUT | jq -r '.cluster.status')
done
