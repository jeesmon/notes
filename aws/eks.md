# EKS Cluster Setup

## Setup

* [Create IAM Role for EKS Cluster](https://docs.aws.amazon.com/eks/latest/userguide/service_IAM_role.html#create-service-role)
  * AmazonEKSClusterPolicy
  * AmazonEKSVPCResourceController
* [Create Cluster](https://docs.aws.amazon.com/eks/latest/userguide/create-cluster.html)
* Create IAM Role for Worker Nodes
  * AmazonEKSWorkerNodePolicy
  * AmazonEKS_CNI_Policy
  * AmazonEC2ContainerRegistryReadOnly
  * AmazonSSMManagedInstanceCore
* Create Node Group
  * [Node Group](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html)

## Notes
* NAT Gateway is required for node group to join nodes to cluster
* For `kube2iam` work with EKS you need to add the following assume role policy to the EKS worker node role
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Resource": "*"
        }
    ]
}
```
* To access VPCE (ex: Kinesis) from EKS worker node, add eks cluster security group to inbound rule of VPCE security group

## Node Group

* List node groups
```
aws eks list-nodegroups --cluster-name my-cluster
```
* Describe node group
```
aws eks describe-nodegroup --cluster-name my-cluster --nodegroup-name my-node-group
```
* Update node group
```
aws eks update-nodegroup-config --cluster-name my-cluster --nodegroup-name my-node-group --scaling-config minSize=1,maxSize=3,desiredSize=2
```

## Links

* https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html
* https://aws.amazon.com/blogs/containers/de-mystifying-cluster-networking-for-amazon-eks-worker-nodes/
* https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-eni.html
