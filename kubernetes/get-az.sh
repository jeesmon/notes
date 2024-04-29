#!/bin/bash

# Get namespace
NAMESPACE=$1
if [ -z "$NAMESPACE" ]; then
  echo "NAMESPACE is not set"
  echo "Usage: $0 <namespace> <label>"
  exit 1
fi

# Get all pod names by label
LABEL=$2
if [ -z "$LABEL" ]; then
  echo "LABEL is not set"
  echo "Usage: $0 <namespace> <label>"
  exit 1
fi

PODS=$(kubectl -n ${NAMESPACE} get pods -l ${LABEL} -o json | jq -r '.items[].metadata.name')
RESULT=""
for POD in $PODS; do
  echo "Checking AZ from pod $POD"
  # Append the result to the variable
  CURRENT=$(kubectl -n ${NAMESPACE} exec -it $POD -- curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
  CURRENT+=" - "
  CURRENT+=$(kubectl -n ${NAMESPACE} exec -it $POD -- curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone-id)
  RESULT+=$CURRENT
  RESULT+="#"
  echo $CURRENT
done

# Print unique lines
echo "Unique AZs"
echo -n "AZ - AZ_ID"
# Split result by # and print unique lines
echo "$RESULT" | tr "#" "\n" | sort -u

