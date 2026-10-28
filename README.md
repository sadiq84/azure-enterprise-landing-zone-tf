<div align="center">

# 🏛️ Enterprise Azure Landing Zone (CAF ALZ)
### Microsoft Cloud Adoption Framework Scale Reference Architecture in Modular Terraform

[![Terraform](https://img.shields.io/badge/Terraform->=_1.5.0-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)](https://terraform.io/)
[![Azure CAF](https://img.shields.io/badge/Architecture-Microsoft_CAF_Landing_Zone-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)](https://learn.microsoft.com/azure/cloud-adoption-framework/)
[![Firewall](https://img.shields.io/badge/Security-Azure_Firewall_Premium_IDPS-10B981?style=for-the-badge&logo=shield&logoColor=white)](#)
[![Compliance](https://img.shields.io/badge/Compliance-CIS_Benchmark_&_MCSB-F59E0B?style=for-the-badge)](#)
[![Architect](https://img.shields.io/badge/Author-Mohammad_Sadique_Qutub-06B6D4?style=for-the-badge)](#)

```
  ========================================================================================
  [ ENTERPRISE LANDING ZONE PILLARS ]
  * Microsoft Entra ID Tenant Root & Multi-Tier Management Group Hierarchy
  * Centralized Hub-and-Spoke Networking with Azure Firewall Premium IDPS
  * User-Defined Routes (UDRs: 0.0.0.0/0) for Centralized Deep Packet Inspection
  * Guardrails via Azure Policy Initiatives (CIS Azure Benchmark & MCSB)
  ========================================================================================
```

</div>

---

## 📌 Architectural Topology

```
                            [ Microsoft Entra ID Tenant ]
                                          |
                              [ Tenant Root Group ]
                                          |
         +--------------------------------+--------------------------------+
         |                                |                                |
 [ Platform Management Group ]   [ Landing Zones (Workloads) ]    [ Sandboxes ]
   |-- Identity (AD/DNS)           |-- Corp (Internal Only)         `-- Sandbox MG
   |-- Management (Logs/Mon)       |-- Online (Public/DMZ)
   `-- Connectivity (Hub/Firewall) |-- Dev Subscriptions
                                   |-- UAT Subscriptions
                                   `-- Prod Subscriptions
```

---

## 🌐 Hub-and-Spoke Traffic Flow

```
       [ On-Premises Datacenter ]
                   |
     (ExpressRoute / VPN Gateway)
                   |
+------------------v--------------------------------------------------+
|                   HUB VNet (Central Connectivity - 10.100.0.0/16)   |
|                                                                     |
|  +---------------------------+       +---------------------------+  |
|  | GatewaySubnet             | ----> | Azure Firewall Premium    |  |
|  | (10.100.1.0/24)           |       | (10.100.2.4 - Inspection) |  |
|  +---------------------------+       +-------------+-------------+  |
+----------------------------------------------------|----------------+
                 | (VNet Peering + UDR: 0.0.0.0/0 -> Firewall IP)
                 +-------------------+-------------------+
                 |                                       |
+----------------v-------------------+   +---------------v-------------------+
| Spoke: Corp Workloads (10.101.0.0) |   | Spoke: Online DMZ (10.102.0.0/16) |
| - App Subnets                      |   | - Application Gateway (WAF)       |
| - Database Subnets                 |   | - Public Ingress APIs             |
| - Private Endpoints                |   | - External Web Services           |
+------------------------------------+   +-----------------------------------+
```

---

## 🚀 Deployment Instructions

```bash
# 1. Initialize Terraform
terraform init

# 2. Plan Infrastructure
terraform plan -var-file="terraform.tfvars.example" -out=tfplan

# 3. Apply Landing Zone
terraform apply tfplan
```

---

## 👨‍💻 Author & Maintainer
**Mohammad Sadique Qutub**  
*Senior DevSecOps & Cloud Solutions Architect*  
GitHub: [@sadiq84](https://github.com/sadiq84) • Email: [mohd.sadiq84@gmail.com](mailto:mohd.sadiq84@gmail.com)