# Terraform Modules

Terraform modules can be used as containers for multiple resources that are used together. A module consists of a collection of .tf files kept together in a directory.
Modules are the main way to package and reuse resource configurations with Terraform.

## Introduction

The purpose of this repository is to maintain the blueprints and modules for our key resource elements included in our infrastructure. We have dedicated modules for the following :-

1. [eks-cluster-stack](./modules/eks-cluster-stack/):
   This module will be responsible to create a EKS cluster with managed node groups inside a VPC.

## Deploying the modules

1. [Deploy eks stack with examples](./docs/deploy-eks-module.md)

## Resources Created

1. EKS Clusters with Managed NodeGroup

## Destroy Infrastructure

Navigate to each modules directory individually and execute the following command:
`terraform destroy`

# Terraform EKS Cluster Create

This repository provides **Terraform modules** for creating and managing Amazon EKS clusters.  
It is intended to be consumed by a higher-level orchestration layer such as **Terragrunt**.

👉 For end-to-end cluster creation, please refer to the companion repo:  
[terragrunt-eks-cluster-create](https://github.com/sunilnerella23/terragrunt-eks-cluster-create)

---

## 📦 Modules
- **eks-cluster-stack** → Provisions the EKS cluster, managed node groups, IAM roles.
- **addons** → Installs optional addons (ArgoCD, Istio, Prometheus, Kyverno, Mimir, etc).
- **irsa** → Creates IAM Roles for Service Accounts.
