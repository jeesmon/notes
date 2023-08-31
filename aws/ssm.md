# SSH/RSYNC over SSM

## Overview

This document describes how to use AWS SSM to run ssh commands and rsync files to/from EC2 instances.

## Prerequisites

* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
* [IAM Role with SSM permissions](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-getting-started-instance-profile.html) (ex: `AmazonSSMManagedInstanceCore`)
* EC2 instance with SSM agent and IAM role attached
* [Session Manager Plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html) installed on your local machine
* If you are running EC2 instance in private subnet you need to setup 3 additional [VPC Endpoints](https://repost.aws/knowledge-center/ec2-systems-manager-vpc-endpoints) for SSM

## Setup

* Copy [aws-ssm-ec2-proxy-command.sh](https://github.com/qoomon/aws-ssm-ec2-proxy-command/blob/master/aws-ssm-ec2-proxy-command.sh) to your local machine and make it executable

```
wget https://raw.githubusercontent.com/qoomon/aws-ssm-ec2-proxy-command/master/aws-ssm-ec2-proxy-command.sh -O ~/.ssh/aws-ssm-ec2-proxy-command.sh

chmod +x ~/.ssh/aws-ssm-ec2-proxy-command.sh
```

* Add following lines to your `~/.ssh/config`

```
host i-* mi-*
  IdentityFile ~/.ssh/id_rsa
  ProxyCommand ~/.ssh/aws-ssm-ec2-proxy-command.sh %h %r %p ~/.ssh/id_rsa.pub
  StrictHostKeyChecking no
```

## Test Connection

* Verify SSM Plugin is installed

```
session-manager-plugin

The Session Manager plugin was installed successfully. Use the AWS CLI to start a session.
```

* Verify SSM Association Status for EC2 instance

```
aws ssm describe-instance-associations-status --instance-id i-0123456789abcdef0
```


* Make sure your local machine is able to connect to EC2 instance via SSM

```
aws ssm start-session --target i-0123456789abcdef0
```

* Connect to EC2 instance via SSH

```
ssh ec2-user@i-0123456789abcdef0
```

* Rsync files to EC2 instance

```
rsync -avz -e "ssh" ./local/path ec2-user@i-0123456789abcdef0:/remote/path
```

## Links
* https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-getting-started-enable-ssh-connections.html
* https://docs.aws.amazon.com/systems-manager/latest/userguide/setup-create-vpc.html
* https://github.com/qoomon/aws-ssm-ec2-proxy-command
* https://www.tripwire.com/state-of-security/aws-session-manager-enhanced-ssh-scp-capability
