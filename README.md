Azure Private AKS with Bastion Host and Azure Container Registry
Overview
This repository contains Terraform code for provisioning a private Azure Kubernetes Service (AKS) cluster, Bastion Host, and Azure Container Registry (ACR). The infrastructure is designed to enhance security by restricting access to the AKS cluster via a Bastion Host and securing container images in a private ACR.

Key Components
Azure Kubernetes Service (AKS): A private AKS cluster that provides a scalable and secure environment for running containerized applications.
Bastion Host: A jump server that allows secure SSH access to the AKS cluster without exposing it to the internet.
Azure Container Registry (ACR): A private registry for storing Docker images used in the AKS cluster.
Terraform: Infrastructure as Code (IaC) tool used for provisioning the entire environment.
Architecture
Private AKS Cluster: The AKS cluster runs in a private VNet, accessible only from the Bastion Host.
Bastion Host: A secure host used to manage and access the AKS cluster via SSH.
Azure Container Registry: Stores container images securely and is integrated with AKS for pulling images during application deployment.
Diagram

Prerequisites
Before deploying the infrastructure, ensure you have the following:

Azure Subscription
Terraform installed on your local machine (Install Terraform)
Azure CLI installed (Install Azure CLI)
SSH Keys for accessing the Bastion Host
GitHub Account for version control
Setup and Usage
1. Clone the Repository
git clone[ https://github.com/your-username/private-aks-bastion-acr.git](https://github.com/chandan-cloudops/Private-aks-bastion-host-acr.git)
cd private-aks-bastion-acr
2. Configure the Environment Variables
Create a .tfvars file or set environment variables for the following parameters:


# example.tfvars
azure_subscription_id = "your-subscription-id"
azure_client_id = "your-client-id"
azure_client_secret = "your-client-secret"
azure_tenant_id = "your-tenant-id"
ssh_public_key_path = "~/.ssh/id_rsa.pub"
3. Initialize Terraform
Run the following command to initialize the Terraform working directory. This will download the necessary provider plugins.

terraform init
4. Plan the Infrastructure
Generate and review the execution plan to see what Terraform will provision:

terraform plan -var-file="example.tfvars"
5. Apply the Terraform Configuration
Apply the configuration to provision the resources:


terraform apply -var-file="example.tfvars"
6. Access the Bastion Host
Once the infrastructure is deployed, you can SSH into the Bastion Host to manage the AKS cluster:


ssh -i ~/.ssh/id_rsa azureuser@<bastion-host-ip>
7. Access AKS Cluster
From the Bastion Host, you can use kubectl to manage the AKS cluster:

az aks get-credentials --resource-group <resource-group> --name <aks-cluster-name>
kubectl get nodes
8. Push Docker Images to ACR
You can build and push Docker images to the Azure Container Registry:

az acr login --name <acr-name>
docker build -t <acr-name>.azurecr.io/my-app:v1 .
docker push <acr-name>.azurecr.io/my-app:v1
Repository Structure
.
├── main.tf               # Main Terraform configuration
├── variables.tf          # Input variables for the infrastructure
├── outputs.tf            # Outputs generated after applying Terraform
├── example.tfvars        # Example variables file
├── modules/              # Modularized Terraform code (VNet, AKS, Bastion)
├── README.md             # Documentation (this file)

Key Features
Private AKS Cluster: The Kubernetes API and node pools are isolated within a virtual network.
Bastion Host: Secure access to the AKS cluster without exposing it to the public internet.
Azure Container Registry: A private registry for storing and pulling Docker images for your AKS workloads.
Automated Provisioning: Terraform automates the entire infrastructure setup, making deployments repeatable and version-controlled.
Security Considerations
Restricted AKS Access: Only the Bastion Host is allowed to communicate with the AKS cluster.
SSH Key Authentication: Access to the Bastion Host is secured through SSH key-based authentication.
ACR Integration: The AKS cluster pulls container images directly from ACR, ensuring that your container images are not publicly accessible.
Contributing
Contributions are welcome! Please fork the repository and create a pull request with any improvements or new features.

Steps to Contribute:
Fork the repository.
Create a new branch (git checkout -b feature/my-feature).
Commit your changes (git commit -m 'Add new feature').
Push to the branch (git push origin feature/my-feature).
Open a pull request.
