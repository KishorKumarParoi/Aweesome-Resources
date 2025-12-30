kubectl delete namespace game-2048
helm uninstall aws-load-balancer-controller -n kube-system
eksctl delete cluster --name demo-cluster --region us-east-1
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Detach policy
aws iam detach-role-policy \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy

# Delete role
aws iam delete-role --role-name AmazonEKSLoadBalancerControllerRole

# Delete policy
aws iam delete-policy \
  --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy

# List OIDC providers
aws iam list-open-id-connect-providers

# Delete the one related to your cluster
aws iam delete-open-id-connect-provider --open-id-connect-provider-arn arn:aws:iam::ACCOUNT_ID:oidc-provider/oidc.eks.region.amazonaws.com/id/EXAMPLED...