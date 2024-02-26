#!/bin/bash

# This helper script will create a DNS record for ingress hostname

set -ex

# Make sure INGRESS_DOMAIN_NAME is set
if [ -z "${INGRESS_DOMAIN_NAME}" ]; then
  echo "INGRESS_DOMAIN_NAME is not set"
  exit 1
fi

# Make sure INGRESS_SUBDOMAIN_NAME is set
if [ -z "${INGRESS_SUBDOMAIN_NAME}" ]; then
  echo "INGRESS_SUBDOMAIN_NAME is not set"
  exit 1
fi

# Make sure INGRESS_NAME is set
if [ -z "${INGRESS_NAME}" ]; then
  echo "INGRESS_NAME is not set"
  exit 1
fi

# Find LoadBalancer address of the Ingress
for i in {1..12}; do
  INGRESS_LB_ADDRESS=$(kubectl get ing ${INGRESS_NAME} -o json | jq -r ".status | select (.loadBalancer != null and .loadBalancer.ingress != null) | .loadBalancer.ingress[0].hostname | select (.!=null)")
  if [ -n "${INGRESS_LB_ADDRESS}" ]; then
    break
  fi
  echo "Waiting for LoadBalancer address of the Ingress"
  sleep 10
done

# Make sure LoadBalancer address exists
if [ -z "${INGRESS_LB_ADDRESS}" ]; then
    echo "LoadBalancer address of the Ingress is not found"
    exit 1
fi

# Find HostedZoneId of the INGRESS_DOMAIN_NAME
HOSTED_ZONE_ID=$(aws route53 list-hosted-zones-by-name --dns-name ${INGRESS_DOMAIN_NAME} --max-items 1 | jq -r ".HostedZones[] | select(.Name == \"${INGRESS_DOMAIN_NAME}.\") | .Id | select (.!=null)")
# Make sure HostedZoneId exists
if [ -z "${HOSTED_ZONE_ID}" ]; then
    echo "HostedZoneId of the INGRESS_DOMAIN_NAME is not found"
    exit 1
fi

# Remove /hostedzone/ prefix from the HostedZoneId
HOSTED_ZONE_ID=${HOSTED_ZONE_ID#"/hostedzone/"}
# Make sure HostedZoneId is not empty
if [ -z "${HOSTED_ZONE_ID}" ]; then
    echo "HostedZoneId is empty"
    exit 1
fi

FQDN="${INGRESS_SUBDOMAIN_NAME}.${INGRESS_DOMAIN_NAME}"

# Find the record set of the FQDN
RECORD_VALUE=$(aws route53 list-resource-record-sets --hosted-zone-id ${HOSTED_ZONE_ID} --start-record-name ${FQDN} --max-items 1 | jq -r ".ResourceRecordSets[] | select(.Name == \"${FQDN}.\") | .ResourceRecords[].Value | select (.!=null)")

echo "Existing record value for ${FQDN} is ${RECORD_VALUE}"

# Create change batch for UPSERT to a file
cat > /tmp/change-resource-record-sets.json <<EOF
{
  "Comment": "Create or update a record set",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "${FQDN}.",
        "Type": "CNAME",
        "TTL": 300,
        "ResourceRecords": [
          {
            "Value": "${INGRESS_LB_ADDRESS}"
          }
        ]
      }
    }
  ]
}
EOF

# UPSERT the record set of the FQDN
aws route53 change-resource-record-sets --hosted-zone-id ${HOSTED_ZONE_ID} --change-batch file:///tmp/change-resource-record-sets.json

# Check and wait until the record set is created for max 1 minute
for i in {1..6}; do
  RECORD_VALUE=$(aws route53 list-resource-record-sets --hosted-zone-id ${HOSTED_ZONE_ID} --start-record-name ${FQDN} --max-items 1 | jq -r ".ResourceRecordSets[] | select(.Name == \"${FQDN}.\") | .ResourceRecords[].Value | select (.!=null)")
  if [ "${RECORD_VALUE}" == "${INGRESS_LB_ADDRESS}" ]; then
    echo "Record value for ${FQDN} is ${RECORD_VALUE}"
    break
  fi
  echo "Waiting for record value for ${FQDN} to be ${INGRESS_LB_ADDRESS}"
  sleep 10
done

# Print the record set of the FQDN
echo "Record value for ${FQDN} is ${RECORD_VALUE}"

# If the record value is not the same as the Ingress Controller LoadBalancer address, exit with error
if [ "${RECORD_VALUE}" != "${INGRESS_LB_ADDRESS}" ]; then
  echo "Record value for ${FQDN} is not ${INGRESS_LB_ADDRESS}"
  exit 1
fi

