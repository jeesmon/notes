#!/bin/bash

# This helper script will remove the DNS record of ingress hostname

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

# Find HostedZoneId of the INGRESS_DOMAIN_NAME
HOSTED_ZONE_ID=$(aws route53 list-hosted-zones-by-name --dns-name ${INGRESS_DOMAIN_NAME} --max-items 1 | jq -r ".HostedZones[] | select(.Name == \"${INGRESS_DOMAIN_NAME}.\") | .Id | select (.!=null)")
# Make sure HostedZoneId exists
if [ -z "${HOSTED_ZONE_ID}" ]; then
    echo "HostedZoneId of the INGRESS_DOMAIN_NAME is not found"
    exit 0
fi

# Remove /hostedzone/ prefix from the HostedZoneId
HOSTED_ZONE_ID=${HOSTED_ZONE_ID#"/hostedzone/"}
# Make sure HostedZoneId is not empty
if [ -z "${HOSTED_ZONE_ID}" ]; then
    echo "HostedZoneId is empty"
    exit 0
fi

# Find the DNS record
DNS_RECORD=$(aws route53 list-resource-record-sets --hosted-zone-id ${HOSTED_ZONE_ID} --query "ResourceRecordSets[?Name == '${INGRESS_SUBDOMAIN_NAME}.${INGRESS_DOMAIN_NAME}.']" --output json | jq -r ".[0] | select (.!=null)")
# Make sure DNS record exists
if [ -z "${DNS_RECORD}" ]; then
    echo "DNS record for ${INGRESS_SUBDOMAIN_NAME}.${INGRESS_DOMAIN_NAME} does not exist"
    exit 0
fi

# Create change batch to remove the DNS record to a temporary file
cat >/tmp/change-batch-for-delete.json <<EOF
{
  "Comment": "Remove the DNS record of Airflow UI",
  "Changes": [
    {
      "Action": "DELETE",
      "ResourceRecordSet": ${DNS_RECORD}
    }
  ]
}
EOF

# Remove the DNS record
aws route53 change-resource-record-sets --hosted-zone-id ${HOSTED_ZONE_ID} --change-batch file:///tmp/change-batch-for-delete.json

# Check and wait until the DNS record is removed for max 1 minute
for i in {1..6}; do
  DNS_RECORD=$(aws route53 list-resource-record-sets --hosted-zone-id ${HOSTED_ZONE_ID} --query "ResourceRecordSets[?Name == '${INGRESS_SUBDOMAIN_NAME}.${INGRESS_DOMAIN_NAME}.']" --output json | jq -r ".[0] | select (.!=null)")
  if [ -z "${DNS_RECORD}" ]; then
    echo "DNS record for ${INGRESS_SUBDOMAIN_NAME}.${INGRESS_DOMAIN_NAME} is removed"
    break
  fi
  echo "Waiting for DNS record for ${INGRESS_SUBDOMAIN_NAME}.${INGRESS_DOMAIN_NAME} to be removed"
  sleep 10
done

# If the DNS record is not removed, print the DNS record
if [ -n "${DNS_RECORD}" ]; then
  echo "DNS record for ${INGRESS_SUBDOMAIN_NAME}.${INGRESS_DOMAIN_NAME} is not removed"
  echo "DNS record: ${DNS_RECORD}"
  exit 1
fi
