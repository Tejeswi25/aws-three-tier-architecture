# Secure 3-Tier Enterprise Architecture on AWS
### Automated with Terraform & GitHub Actions

## 🏗️ Architecture Overview
This project demonstrates a production-standard **Hub-and-Spoke** network topology. It centralizes internet traffic (Egress) through a Hub VPC to save costs and increase security for a 3-tier application stack.

### Key Features:
* **Modular Terraform:** Infrastructure is split into reusable modules (VPC, TGW, RDS).
* **Transit Gateway (TGW):** Centralized routing between App and Data VPCs—no VPC Peering.
* **Hardened Database:** RDS MySQL instance living in a private subnet with zero internet access.
* **CI/CD Pipeline:** Fully automated deployments via GitHub Actions.
* **Remote State:** State management using AWS S3 for consistency.

## 🛠️ Tech Stack
* **Cloud:** AWS (VPC, EC2, RDS, Transit Gateway, NAT Gateway)
* **IaC:** Terraform
* **CI/CD:** GitHub Actions
* **Security:** Security Group Referencing, Private Subnets, IAM Least Privilege

## 📂 Repository Structure
```text
├── .github/workflows/   # CI/CD Pipeline
├── modules/
│   ├── vpc/             # Networking Foundation
│   ├── tgw/             # Routing Hub
│   └── rds/             # Database Tier
├── main.tf              # Root Configuration
└── backend.tf           # S3 Remote State