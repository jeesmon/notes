#!/bin/bash

# Get a list of all EKS clusters
clusters=$(aws eks list-clusters --query 'clusters' --output text)

# Loop through each cluster and get its version
for cluster in $clusters; do
    version=$(aws eks describe-cluster --name $cluster --query 'cluster.version' --output text)
    echo "${cluster}: v${version}"
done
