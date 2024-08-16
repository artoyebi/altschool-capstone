# Deploying the Socks Shop microservices application using Infrastructure as Code (IaC) on Kubernetes

### Setup Details

Application Repo: [microservice-demo](https://github.com/microservices-demo/microservices-demo/tree/master)

Cloud Provider: AWS

Deployment pipeline: Jenkins

Monitoring: Grafana

Metrics: Alertmanager

Logging: Prometheus

Tools: AWS CLI, Kubectl, Helm and Terraform

---

## Deploment Steps

### Phase 1: Environment Setup

- Setup cloud resources such as EC2 Instance, VPC, Elastic IP and Bastion Instance and Kubernetes Cluster

- Update kubeconfig

`aws eks --region us-west-1 update-kubeconfig --name test-eksdemo1`

![alt text](images/image2.jpeg)

### Phase 2: Deployment

- Deploy using the manifest file

![alt text](images/image1.jpeg)

- Get services and pods deployment status

![alt text](<images/image0 (1).jpeg>)

- Install Helm and Setup ingress

    `curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash`

    `helm version`

    - Choose the version nginx controller that is compatible with your k8s

        `helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx`
        `helm search repo ingress-nginx --versions
`
    - Install ingress-nginx controller

        `mkdir ./manifest`

    - helm template ingress-nginx ingress-nginx \
        --repo https://kubernetes.github.io/ingress-nginx \
        --version ${CHART_VERSION} \
        --namespace ingress-nginx \
        > ./manifest/nginx-ingress.${APP_VERSION}.yaml

    - kubectl create namespace ingress-nginx

    - deploy the file in ./manifest

        `kubectl apply -f ./manifest`


    - Confirm the port
    `kubectl get svc -n ingress-nginx`

        `kubectl -n ingress-nginx port-forward svc/ingress-nginx-controller 80`

    - Create a domain and let it point to the load balancer that ingress has created

    ![alt text](<images/Screenshot 2024-08-15 235706.png>)


    - Install cert-manager
    
    `kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml`

    - Create cluster issuer

        `kubectl apply -f cluster-issuer.yaml`

    - Create the ingress

        `kubectl get ingress`

    - See the certs and secrets

        `kubectl get certs`

        `kubectl get secrets`

    ![alt text](<images/Screenshot 2024-08-15 235241.png>)


### Phase 3: Monitoring

-Create the monitoring namespace using the `00-monitoring-ns.yaml` file:

`$ kubectl create -f 00-monitoring-ns.yaml`

#### Prometheus

- Deploy using the prometheus manifests (01-10) in any order:

`kubectl apply $(ls *-prometheus-*.yaml | awk ' { print " -f " $1 } ')`

The prometheus server will be exposed on Nodeport `31090`.

![alt text](<images/Screenshot 2024-08-15 235146.png>)

#### Grafana

- Apply the grafana manifests from 20 to 22:

    `kubectl apply $(ls *-grafana-*.yaml | awk ' { print " -f " $1 }'  | grep -v grafana-import)`

Once the grafana pod is in the Running state apply the `23-grafana-import-dash-batch.yaml` manifest to import the Dashboards:

`kubectl apply -f 23-grafana-import-dash-batch.yaml`

Grafana will be exposed on the NodePort `31300` 

![alt text](<images/Screenshot 2024-08-15 235213.png>)

#### Alertmanager

Setup alertmanager using Prometheus as datasource on grafana and integrate with Slack Webhook

![alt text](images/image.png)

