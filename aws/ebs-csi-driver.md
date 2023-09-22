# EBS CSI Driver

## Links
https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html
https://docs.aws.amazon.com/eks/latest/userguide/csi-iam-role.html
https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html

## Setup

```
export CLUSTER_NAME=my-cluster
export EBS_ROLE_NAME=my-cluster-ebs-csi-driverrole
export AWS_REGION=us-east-1
export AWS_ACCOUNT=123456890
```

### Verify IAM OIDC provider for the cluster

```
aws eks describe-cluster \
    --name $CLUSTER_NAME \
    --query "cluster.identity.oidc.issuer" \
    --output text
```

### Get OIDC ID for the cluster

```
OIDC_ID=$(aws eks describe-cluster \
    --name $CLUSTER_NAME \
    --query "cluster.identity.oidc.issuer" \
    --output text | sed -e 's#^https://.*id/##')
```

### List OpenID Connect providers for the OIDC ID

```
aws iam list-open-id-connect-providers \
    --query "OpenIDConnectProviderList[?ends_with(Arn, '/$OIDC_ID')].Arn" \
    --output text
```

If the command returns an empty response, then you must create an IAM OIDC provider for your cluster.

### Creating an IAM OIDC provider for the cluster

```
eksctl utils associate-iam-oidc-provider \
    --region $AWS_REGION \
    --cluster $CLUSTER_NAME \
    --approve
```

### Create IAM role for the EBS CSI driver

```
eksctl create iamserviceaccount \
    --name ebs-csi-controller-sa \
    --namespace kube-system \
    --cluster ${CLUSTER_NAME} \
    --role-name ${EBS_ROLE_NAME} \
    --role-only \
    --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
    --approve \
    --region ${AWS_REGION}
```

### Create AWS EBS CSI driver addon

```
eksctl create addon \
    --name aws-ebs-csi-driver \
    --cluster ${CLUSTER_NAME} \
    --region ${AWS_REGION} \
    --service-account-role-arn arn:aws:iam::${AWS_ACCOUNT}:role/${EBS_ROLE_NAME}
    --force
```

### Verify addon status

```
eksctl get addon --name aws-ebs-csi-driver --cluster ${CLUSTER_NAME} --region ${AWS_REGION}
```
