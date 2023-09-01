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

## Links

* https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html
* https://aws.amazon.com/blogs/containers/de-mystifying-cluster-networking-for-amazon-eks-worker-nodes/
* https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-eni.html