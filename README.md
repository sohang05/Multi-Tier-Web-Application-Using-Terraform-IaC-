# Multi-Tier Web Application - Infrastructure as Code

![AWS](https://img.shields.io/badge/AWS-FF9900?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-00758F?style=for-the-badge&logo=mysql&logoColor=white)
![Nginx](https://img.shields.io/badge/Nginx-009639?style=for-the-badge&logo=nginx&logoColor=white)

> A production-ready, fully automated 3-tier web application deployed on AWS using Terraform Infrastructure as Code. This project demonstrates modern DevOps practices including cloud architecture, security, automation, and scalability.

**[View Project Analysis](#-project-components) | [Quick Start](#-quick-start) | [Architecture](#-architecture) | [Learning Outcomes](#-learning-outcomes)**

---

## 📋 Project Overview

This repository contains a complete infrastructure setup for a cloud-native 3-tier web application. It serves as both a **learning resource** for cloud engineering and a **production-grade template** for real-world deployments.

### ✨ Key Features

- **Infrastructure as Code**: 100% automated with Terraform
- **Multi-tier Architecture**: Presentation, Application, and Data layers
- **High Availability**: Multi-AZ deployment with load balancing
- **Security First**: VPC isolation, security groups, least-privilege access
- **Cloud-native**: Uses managed AWS services (RDS, ALB, EC2)
- **Zero-touch Deployment**: Fully automated with Bash scripts
- **Production-ready**: Best practices implemented throughout
- **Modular Design**: Reusable Terraform modules for each component

### 🎯 Perfect For

- 👨‍💼 **DevOps Engineers**: Learn complete infrastructure automation
- 🎓 **Cloud Architects**: Study 3-tier architecture design
- 💻 **Full-stack Developers**: Understand cloud deployment
- 🚀 **AWS Learners**: Master AWS services and VPC networking
- 📚 **Career Growth**: Build portfolio project for job applications

---

## 📐 Architecture

### System Diagram

```
┌─────────────────────────────────────────────────────┐
│              AWS Region (us-east-1)                 │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌──────────────────────────────────────────────┐   │
│  │  PUBLIC SUBNETS (Internet Accessible)        │   │
│  │                                              │   │
│  │  ├─ Nginx Frontend Server (EC2 t3.micro)     │   │
│  │  ├─ Application Load Balancer (ALB)          │   │
│  │  └─ NAT Gateway                              │   │
│  └──────────────────────────────────────────────┘   │
│                       ↓                             │
│  ┌──────────────────────────────────────────────┐   │
│  │  PRIVATE SUBNETS (Internal Only)             │   │
│  │                                              │   │
│  │  ├─ Node.js Backend API (EC2 t3.micro)       │   │
│  │  ├─ MySQL RDS Database (db.t4g.micro)        │   │
│  │  └─ Multi-AZ Standby Database                │   │
│  └──────────────────────────────────────────────┘   │
│                                                     │
└─────────────────────────────────────────────────────┘
```
## 📸 Screenshots 
<img width="959" height="500" alt="Cloud Health Dashboard" src="https://github.com/user-attachments/assets/0affa20b-30d7-41e7-a3d8-c0c6c3a549c6" />
<img width="1918" height="1003" alt="Screenshot 2026-04-13 155153" src="https://github.com/user-attachments/assets/474548b7-5e40-4e17-837f-e3b919de9fc1" />
<img width="1903" height="1008" alt="Screenshot 2026-04-13 155240" src="https://github.com/user-attachments/assets/4ab42149-29cd-4c0b-9d54-8fc18f6c2f40" />




### Three Tiers Explained

| Tier | Component | Technology | Purpose |
|------|-----------|-----------|---------|
| **1. Presentation** | Frontend Server | Nginx | Serves web interface, proxies API calls |
| **2. Application** | Backend API | Node.js 18.x | REST API endpoints, business logic |
| **3. Data** | Database | MySQL 8.0 RDS | Persistent data storage, managed service |

### Network Architecture

```
VPC CIDR: 10.0.0.0/16

Public Subnets (2):
├─ 10.0.1.0/24 (AZ-a) → Frontend + NAT Gateway
└─ 10.0.2.0/24 (AZ-b) → Reserved for HA

Private Subnets (2):
├─ 10.0.3.0/24 (AZ-a) → Backend + RDS Primary
└─ 10.0.4.0/24 (AZ-b) → RDS Secondary (Multi-AZ)
```

---

## 🚀 Quick Start

### Prerequisites

- **AWS Account** (Free tier eligible)
- **Terraform** v1.0 or later ([Install](https://learn.hashicorp.com/tutorials/terraform/install-cli))
- **AWS CLI** v2 ([Install](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html))
- **Git** ([Install](https://git-scm.com/))
- **SSH Key Pair** (Generate: `ssh-keygen`)

### Installation Steps

#### 1. Clone Repository

```bash
git clone https://github.com/yourusername/multi-tier-web-app.git
cd multi-tier-web-app
```

#### 2. Configure AWS Credentials

```bash
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Default region: us-east-1
# Output format: json
```

Verify configuration:
```bash
aws sts get-caller-identity
```

#### 3. Generate SSH Key (if needed)

```bash
ssh-keygen -t rsa -b 4096 -f ./terraform/terra-key-ec2 -N ""
# This creates:
# - terra-key-ec2 (private key - NEVER commit)
# - terra-key-ec2.pub (public key)
```

**⚠️ Important**: Add to `.gitignore`:
```
terraform/terra-key-ec2
terraform/terraform.tfvars
```

#### 4. Initialize Terraform

```bash
cd terraform
terraform init
```

This downloads the AWS provider plugin and prepares the workspace.

#### 5. Review Deployment Plan

```bash
terraform plan -out=tfplan
```

Review the output to see what resources will be created (~30+ resources).

#### 6. Deploy Infrastructure

```bash
terraform apply tfplan
```

⏱️ **Deployment Time**: 10-15 minutes (RDS takes longest)

#### 7. Get Application URL

```bash
terraform output app_url
```

The output will be: `http://app-lb-xxxxx.us-east-1.elb.amazonaws.com`

#### 8. Access Application

Open the URL in your browser to see the **Cloud Health Dashboard**.

---

## 🧪 Testing the Application

### 1. View Dashboard

- Open ALB DNS name in browser
- See backend status, instance information
- View the registration form

### 2. Register a Node

Fill in the form:
```
Node Name: production-node-1
Email: admin@example.com
```

Click **"Submit to RDS"** to insert data into database.

### 3. Verify Database

SSH into backend instance:
```bash
# Get instance IP from terraform outputs
ssh -i terraform/terra-key-ec2 ubuntu@<backend_private_ip>

# Connect to RDS
mysql -h <rds-endpoint> -u admin -ppassword123 -e "SELECT * FROM mydb.users;"
```

---

## 📁 Project Structure

```
multi-tier-web-app/
├── terraform/
│   ├── main.tf                 # Main orchestration, module calls
│   ├── provider.tf             # AWS provider configuration
│   ├── variables.tf            # Input variables
│   ├── outputs.tf              # Output values
│   │
│   ├── modules/
│   │   ├── vpc/                # Virtual Private Cloud module
│   │   │   ├── main.tf         # VPC, subnets, IGW, NAT, routes
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   │
│   │   ├── sg/                 # Security Groups module
│   │   │   ├── main.tf         # 4 security groups with rules
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   │
│   │   ├── ec2/                # EC2 Instances module
│   │   │   ├── main.tf         # Instance creation + IAM
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   │
│   │   ├── alb/                # Application Load Balancer
│   │   │   ├── main.tf         # ALB, listeners, target groups
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   │
│   │   └── rds/                # RDS Database module
│   │       ├── main.tf         # MySQL instance, subnet group
│   │       ├── variables.tf
│   │       └── outputs.tf
│   │
│   ├── scripts/
│   │   ├── frontend.sh         # Nginx + Dashboard setup
│   │   └── backend.sh          # Node.js API setup
│   │
│   ├── terra-key-ec2           # SSH private key (generated)
│   ├── terra-key-ec2.pub       # SSH public key
│   │
│   └── terraform.tfvars        # Variable values (local only)
│
├── app/
│   ├── frontend/
│   │   └── index.html          # Dashboard HTML (in script)
│   └── backend/
│       └── app.js              # Node.js API (in script)
│
├── docs/
│   ├── PROJECT_ANALYSIS.md     # Detailed analysis
│   ├── FLOW_DIAGRAMS.md        # Architecture diagrams
│   └── IMPROVEMENTS.md         # Enhancement ideas
│
├── .gitignore
├── README.md                   # This file
└── LICENSE                     # MIT License
```

---

## 🔐 Security Features

### Network Security

- **VPC Isolation**: Resources in isolated network
- **Subnets**: Public/private separation
- **Security Groups**: Firewall rules per layer
- **NAT Gateway**: Masks private IPs for outbound
- **IGW**: Single entry point for internet traffic

### Access Control

- **Principle of Least Privilege**: Only required ports open
- **Database**: Only accessible from backend
- **Backend**: Only accessible from frontend
- **Frontend**: Only accessible from internet via ALB

### Best Practices Implemented

✅ Multi-AZ for high availability
✅ Managed database (RDS) for security
✅ IAM roles for EC2 access
✅ Systems Manager Sessions Manager ready
✅ Health checks for instance validation
✅ Parameterized queries (prevents SQL injection)
✅ CORS headers configured

### Security Groups

| SG Name | Ingress | Source | Purpose |
|---------|---------|--------|---------|
| alb_sg | 80 | 0.0.0.0/0 | Public web access |
| frontend_sg | 80 | alb_sg | Frontend access |
| backend_sg | 3000 | frontend_sg | API access |
| rds_sg | 3306 | backend_sg | Database access |

---

## 📊 Project Components

### Modules Overview

#### VPC Module (`modules/vpc/`)
Creates the network foundation:
- VPC (10.0.0.0/16)
- 4 Subnets (2 public, 2 private) across 2 AZs
- Internet Gateway for public access
- NAT Gateway for private internet access
- Route tables with proper routing

#### Security Groups Module (`modules/sg/`)
Implements network security:
- ALB Security Group (HTTP from internet)
- Frontend Security Group (HTTP from ALB)
- Backend Security Group (3000 from frontend)
- RDS Security Group (3306 from backend only)

#### EC2 Module (`modules/ec2/`)
Launches compute instances:
- EC2 instances (t3.micro - free tier)
- IAM role for Systems Manager
- Instance profile attachment
- User data templating
- Public IP assignment for frontend

#### ALB Module (`modules/alb/`)
Implements load balancing:
- Application Load Balancer
- Target groups
- Health checks (every 30 seconds)
- Listener on port 80
- Target registration

#### RDS Module (`modules/rds/`)
Deploys managed database:
- DB Subnet Group (private subnets)
- MySQL 8.0 instance
- Multi-AZ for high availability
- Automated backups
- 20 GB storage (free tier)

### Scripts Overview

#### frontend.sh
Installs and configures Nginx:
- Updates system packages
- Installs Nginx
- Creates nginx config with proxy rules
- Generates dashboard HTML
- Proxies /api/* to backend

#### backend.sh
Deploys Node.js API:
- Installs Node.js 18.x
- Creates Express-like API endpoints
- GET /health - Returns server status
- POST /register - Inserts user in RDS
- Uses PM2 for process management
- CORS headers configured

---

## 📚 Terraform Concepts

### Key Concepts Demonstrated

**Modules**: Encapsulation of related resources
```hcl
module "vpc" {
  source = "./modules/vpc"
  # variables passed as inputs
}
```

**Variables & Outputs**: Data flow between modules
```hcl
# VPC module outputs vpc_id
output "vpc_id" { value = aws_vpc.main.id }

# SG module uses it as input
variable "vpc_id" { type = string }
```

**Templating**: Dynamic script injection
```hcl
user_data = templatefile("./scripts/frontend.sh", {
  backend_ip = module.backend.private_ip
})
```

**Dependencies**: Control resource creation order
```hcl
depends_on = [module.backend]  # Frontend waits for backend
```

**Data Sources**: Query existing AWS resources
```hcl
data "aws_availability_zones" "available" {}
```

---

## 🛠️ Common Operations

### View Current State

```bash
cd terraform

# Show all resources
terraform state list

# Show resource details
terraform state show module.vpc.aws_vpc.main

# Show outputs
terraform output
```

### Update Infrastructure

```bash
# Change variables or code
nano terraform/variables.tf

# Plan changes
terraform plan -out=tfplan

# Apply changes
terraform apply tfplan
```

### Destroy Infrastructure

```bash
cd terraform

# Caution: This deletes everything
terraform destroy

# Or target specific resources
terraform destroy -target module.rds
```

### SSH to Instances

```bash
# Get IPs from outputs
terraform output

# SSH to frontend (public subnet)
ssh -i terraform/terra-key-ec2 ubuntu@<frontend_public_ip>

# SSH to backend (private subnet) - requires bastion
ssh -i terraform/terra-key-ec2 -J ubuntu@<frontend_ip> ubuntu@<backend_private_ip>
```

### Debug Resources

```bash
# Check EC2 instances
aws ec2 describe-instances --region us-east-1

# Check RDS
aws rds describe-db-instances --region us-east-1

# Check ALB
aws elbv2 describe-load-balancers --region us-east-1

# View ALB logs
aws elbv2 describe-target-health --target-group-arn <arn>
```

---

## 🚨 Troubleshooting

### ALB shows unhealthy targets

```bash
# 1. Check if frontend is running
aws ec2 describe-instance-status --instance-ids <id>

# 2. Check if Nginx is running
ssh -i terraform/terra-key-ec2 ubuntu@<ip>
sudo systemctl status nginx

# 3. Check if port 80 is listening
netstat -tuln | grep 80

# 4. Check security group
aws ec2 describe-security-groups --group-ids <id>
```

### Backend can't connect to database

```bash
# 1. Check RDS status
aws rds describe-db-instances

# 2. Check if RDS is in private subnet (should be)
aws ec2 describe-subnets

# 3. SSH to backend and test connection
mysql -h <rds-endpoint> -u admin -ppassword123

# 4. Check backend logs
ssh -i terraform/terra-key-ec2 ubuntu@<backend-ip>
cat /home/ubuntu/backend.log
tail -f /home/ubuntu/backend.log  # Watch real-time
```

### Terraform apply fails

```bash
# 1. Validate syntax
terraform validate

# 2. Check plan first
terraform plan

# 3. Check AWS limits
# - VPC limit (5 per region)
# - Security groups (500 per VPC)
# - Instances (varies by instance type)

# 4. Check IAM permissions
# - Ensure user can create EC2, RDS, VPC resources

# 5. Check region
# - Ensure resources are in us-east-1
```

---

## 📈 Performance & Scaling

### Current Limits

- **Frontend**: Single t3.micro (1 vCPU, 1 GB RAM)
- **Backend**: Single t3.micro (1 vCPU, 1 GB RAM)
- **Database**: db.t4g.micro (1 vCPU, 1 GB RAM)
- **Throughput**: ~100-500 requests/min (approximate)

### To Scale Up

```hcl
# 1. Increase instance size
variable "instance_type" {
  default = "t3.small"  # 2 vCPU, 2 GB RAM
}

# 2. Add Auto Scaling Groups
resource "aws_autoscaling_group" "frontend" {
  min_size = 2
  max_size = 5
  desired_capacity = 2
}

# 3. Add RDS read replicas
resource "aws_db_instance" "replica" {
  replicate_source_db = aws_db_instance.mysql.identifier
}

# 4. Add ElastiCache for caching
resource "aws_elasticache_cluster" "redis" {
  engine = "redis"
  node_type = "cache.t3.micro"
}
```

---

## 📝 Learning Outcomes

### Technologies Mastered

- ✅ **Terraform**: IaC best practices, modules, state management
- ✅ **AWS**: VPC, EC2, RDS, ALB, IAM, Security Groups
- ✅ **Cloud Architecture**: 3-tier design, high availability
- ✅ **DevOps**: Automation, CI/CD-ready, infrastructure management
- ✅ **Security**: Defense in depth, least privilege, isolation
- ✅ **Networking**: CIDR blocks, subnets, routing, NAT
- ✅ **Bash**: Scripting, configuration automation
- ✅ **Node.js**: REST APIs, database connections
- ✅ **MySQL**: Schema design, connections, parameterized queries

### Interview-Ready Skills

After completing this project, you can confidently discuss:
- Multi-tier architecture design
- VPC networking and security
- Infrastructure as Code principles
- Terraform module organization
- AWS services and their interactions
- Cloud security best practices
- Scalability and high availability
- Cost optimization
- Production deployment strategies

---

## 🤝 Contributing

Contributions are welcome! Areas for enhancement:

- [ ] Add HTTPS/SSL support
- [ ] Implement CloudWatch monitoring
- [ ] Add Auto Scaling Groups
- [ ] Create CI/CD pipeline (GitHub Actions)
- [ ] Add Terraform tests (TFLint, Checkov)
- [ ] Implement backup strategy
- [ ] Add disaster recovery documentation
- [ ] Create deployment runbooks

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🔗 Resources

### Documentation
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS VPC Guide](https://docs.aws.amazon.com/vpc/)
- [Terraform Best Practices](https://terraform.io/docs/language)

### Related Projects
- [Terraform Examples](https://github.com/hashicorp/terraform-provider-aws/tree/main/examples)
- [AWS Workshops](https://aws.amazon.com/builders/)

---

## 👨‍💼 Author

Created as a Cloud Engineer portfolio project demonstrating:
- Modern cloud architecture
- Infrastructure automation
- Security best practices
- Professional-grade infrastructure

---

## ❓ FAQ

**Q: Is this free to run?**
A: Yes! This project uses AWS Free Tier resources. However, you may incur costs if you exceed free tier limits or don't destroy resources.

**Q: How long does deployment take?**
A: Typically 10-15 minutes. RDS database creation takes the longest (5-10 minutes).

**Q: Can I use a different AWS region?**
A: Yes, change `aws_region` in variables.tf. Some free tier resources may not be available in all regions.

**Q: What happens if I make changes?**
A: Terraform will intelligently update only changed resources. Use `terraform plan` to review changes before applying.

**Q: How do I connect to instances securely?**
A: Currently SSH is open (0.0.0.0/0). For production, use Systems Manager Sessions Manager or a bastion host.

**Q: Can I run multiple deployments?**
A: Yes, but update resource names to avoid conflicts. Use different directories with separate terraform state.

---

## 📞 Support

For issues or questions:
1. Check [FLOW_DIAGRAMS.md](docs/FLOW_DIAGRAMS.md) for architecture understanding
2. Review [PROJECT_ANALYSIS.md](docs/PROJECT_ANALYSIS.md) for detailed explanations
3. Check Terraform logs: `terraform apply -var="debug=true"`
4. Review AWS Console for actual resource status
5. Open an issue on GitHub

---

**⭐ If you find this project helpful, please give it a star!**

---

*Last Updated: 2024-04-13*
*Terraform Version: 1.0+*
*AWS Provider Version: 6.39.0+*
