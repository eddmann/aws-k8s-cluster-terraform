# Single-node Kubernetes Cluster on AWS

Provisions a single-node (Master) Kubernetes cluster (using [Kubeadm](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm/)) with [Flannel](https://github.com/coreos/flannel) CNI and [Helm](https://helm.sh/) client on AWS.

### Setup

- `cp terraform.tfvars.example terraform.tfvars`, modify according to preference
- `terraform init`
- `terraform apply`
- Experiment with your single-node Kubernetes Cluster via `{cluster_name}.{host_zone}`

### Ingress (Optional)

If you wish experiment with [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) without the desire for a Load Balancer you can run `kubectl apply -f nginx-ingress.yaml`.
This will setup the [Nginx Ingress Controller](https://github.com/kubernetes/ingress-nginx) on your Cluster, binding to the host node ports `80` and `443`.

### Inspiration

- https://github.com/cablespaghetti/kubeadm-aws
- https://github.com/scholzj/aws-minikube
