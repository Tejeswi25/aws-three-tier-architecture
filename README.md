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

This project is a high-level Infrastructure as Code (IaC) implementation of a secure, scalable AWS environment. It moves away from "simple" cloud setups by using a Hub-and-Spoke topology, which is the gold standard for enterprise-grade networking.

🏗️ Architectural Summary
The project architecture is centered around two distinct environments:

The Hub (Singapore-hub): Acts as the "Central Post Office." It contains the NAT Gateway and Internet Gateway. Its sole job is to manage entry and exit points for the entire network.

The Spoke (SG-App-VPC): This is the protected "Workload Zone." It houses the application servers and the RDS MySQL database in strictly private subnets with no direct path to the internet.

🛡️ Key Technical Pillars
1. Centralized Egress (Transit Gateway)
Instead of paying for a NAT Gateway in every VPC, all traffic from the App VPC is "backhauled" to the Hub VPC via a Transit Gateway (TGW).


2. Identity-Based Access (No SSH)
The project eliminates the biggest security risk: Port 22 (SSH).

By using AWS Systems Manager (SSM), you can manage the private instances and tunnel into the RDS database using IAM credentials rather than vulnerable SSH keys or public-facing Bastion hosts.

3. Data Privacy
The RDS MySQL instance is completely isolated. It resides in a private subnet and only accepts traffic on port 3306 if it originates from the specific Security Group of the App Server.

🚀 Business & Operational Value
Cost Efficiency: By sharing a single NAT Gateway across multiple VPCs via the TGW, the architecture significantly reduces the monthly AWS bill.

Security Compliance: It follows the principle of Least Privilege. No resource has more access than it needs, and the "attack surface" is minimized by removing public IP addresses from all productive workloads.

Automation-First: Using GitHub Actions and Terraform, the entire environment can be destroyed and recreated in minutes, ensuring "Environment Parity" (dev looks exactly like prod).