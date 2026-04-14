# MULTI-TIER WEB APPLICATION - COMPLETE PROJECT ANALYSIS

## 📋 TABLE OF CONTENTS
1. [Project Overview](#project-overview)
2. [Project Summary](#project-summary)
3. [Architecture Explanation](#architecture-explanation)
4. [Scripts & Components](#scripts--components)
5. [Technology Stack](#technology-stack)
6. [Key Concepts](#key-concepts)
7. [Interview Questions](#interview-questions)
8. [Alternatives & Comparison](#alternatives--comparison)
9. [Improvements & Enhancements](#improvements--enhancements)
10. [Learning Outcomes](#learning-outcomes)

---

## PROJECT OVERVIEW

### 🎯 What is This Project?

This is a **production-ready, cloud-native 3-tier web application** deployed on AWS using **Infrastructure as Code (Terraform)**. It demonstrates a complete DevOps workflow for deploying a scalable web application with proper networking, security, and database management.

### 🏗️ Architecture Layers

```
TIER 1: PRESENTATION (Frontend)
├─ Nginx Web Server running on EC2
├─ Public Subnet (accessible from internet)
├─ Serves static HTML/CSS
└─ Proxies API calls to backend

TIER 2: APPLICATION (Backend/API)
├─ Node.js REST API Server
├─ Private Subnet (not directly accessible)
├─ Exposes HTTP endpoints
└─ Communicates with database

TIER 3: DATA (Database)
├─ MySQL RDS Instance
├─ Private Subnet (only accessible from backend)
├─ Persistent data storage
└─ Multi-AZ deployment
```

### 📱 User Flow

```
Internet User
    ↓
ALB (Application Load Balancer)
    ↓
Frontend Server (Nginx)
    ↓
Backend API (Node.js)
    ↓
MySQL Database (RDS)
```

---

## PROJECT SUMMARY

### Quick Overview

This project automates the complete deployment of a cloud-ready web application using:

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Infrastructure** | Terraform | Infrastructure as Code (IaC) |
| **Cloud Platform** | AWS | Hosting and managed services |
| **Frontend** | Nginx | Web server and reverse proxy |
| **Backend** | Node.js | REST API server |
| **Database** | MySQL 8.0 | Relational database |
| **Load Balancer** | AWS ALB | Traffic distribution |
| **Networking** | VPC | Isolated network environment |
| **Security** | Security Groups | Network access control |
| **Automation** | Bash Scripts | Instance initialization |

### Key Features

✅ **Multi-tier architecture** - Separated concerns for scalability
✅ **High availability** - Multi-AZ deployment with ALB
✅ **Security** - Private subnets, security groups, least-privilege access
✅ **Infrastructure as Code** - Reproducible, version-controlled setup
✅ **Automation** - Zero-touch deployment with scripts
✅ **Cloud-native** - Uses managed services (RDS, ALB)
✅ **Modular** - Reusable Terraform modules
✅ **Monitoring** - Ready for CloudWatch integration

### What It Does

1. **Deploys a complete VPC** with public and private subnets
2. **Creates security boundaries** using security groups
3. **Launches web servers** running Nginx
4. **Deploys API backend** with Node.js
5. **Sets up database** with MySQL RDS
6. **Configures load balancing** with ALB
7. **Automates initialization** with bash scripts
8. **Provides secure communication** between tiers

---

## ARCHITECTURE EXPLANATION

### Network Design (VPC)

```
VPC CIDR: 10.0.0.0/16

PUBLIC SUBNETS (for web-facing resources):
├─ Public Subnet 1: 10.0.1.0/24 (AZ-a)
│  ├─ Nginx Server
│  ├─ ALB
│  └─ NAT Gateway
└─ Public Subnet 2: 10.0.2.0/24 (AZ-b)
   └─ NAT Gateway (optional)

PRIVATE SUBNETS (for backend resources):
├─ Private Subnet 1: 10.0.3.0/24 (AZ-a)
│  ├─ Node.js Backend
│  └─ RDS (Primary)
└─ Private Subnet 2: 10.0.4.0/24 (AZ-b)
   └─ RDS (Secondary - standby)
```

### Security Architecture

```
INTERNET
    ↓
ALB Security Group (allows :80 from 0.0.0.0/0)
    ↓
Frontend SG (allows :80 from ALB, :22 for SSH)
    ↓
Backend SG (allows :3000 from Frontend, :22 for SSH)
    ↓
RDS SG (allows :3306 from Backend only)
```

### Module Dependencies

```
vpc
├─ Creates network foundation
└─ Outputs: VPC ID, Subnet IDs, NAT Gateway

sg (depends on vpc)
├─ Creates security groups
└─ Outputs: Security Group IDs

ec2 (depends on vpc, sg)
├─ Frontend instance (public subnet)
├─ Backend instance (private subnet)
└─ Outputs: Instance IDs, IP addresses

alb (depends on vpc, sg, ec2)
├─ Load balancer in public subnet
├─ Health checks frontend
└─ Outputs: ALB DNS name

rds (depends on vpc, sg)
├─ Database in private subnets
├─ Multi-AZ setup
└─ Outputs: Database endpoint
```

### Data Flow

```
Request Lifecycle:

1. CLIENT REQUEST
   User sends HTTP request to ALB DNS

2. ALB ROUTING
   ALB (port 80) → Frontend instance (port 80)

3. NGINX PROCESSING
   - Serves static content directly
   - Proxies /api/* requests to backend

4. BACKEND API
   - Receives request on port 3000
   - Processes business logic
   - Connects to database

5. DATABASE QUERY
   - MySQL executes query
   - Returns result to backend

6. RESPONSE
   Backend → Nginx → ALB → Client
```

---

## SCRIPTS & COMPONENTS

### 1. TERRAFORM FILES

#### **main.tf** - Orchestration
```
What it does: Calls all modules and wires them together

Key resources:
- aws_key_pair: SSH key for EC2 access
- Module calls: vpc, sg, ec2 (frontend), ec2 (backend), alb, rds
- Templating: Injects backend IP into frontend.sh
- Dependencies: Ensures backend created before frontend
```

#### **provider.tf** - AWS Configuration
```
What it does: Configures AWS provider
- Region settings
- Authentication
- Default tags
```

#### **variables.tf** - Input Variables
```
What it does: Accepts input parameters for customization
- Common variables (region, tags)
- Module inputs
- Allows environment-specific configurations
```

#### **outputs.tf** - Output Values
```
What it does: Exposes important values
- app_url: ALB DNS for accessing application
- backend_private_ip: IP for debugging
- rds_address: Database endpoint
```

### 2. TERRAFORM MODULES

#### **VPC Module** (`modules/vpc/`)
```
Purpose: Create isolated network environment

Resources created:
- aws_vpc: Main VPC (10.0.0.0/16)
- aws_internet_gateway: Gateway for public internet access
- aws_subnet: 4 subnets (2 public, 2 private)
- aws_route_table: Public and private routing tables
- aws_nat_gateway: Allows private subnet internet access
- aws_eip: Elastic IP for NAT

Why multi-AZ?
- High availability
- Failover support
- Distributed load
```

#### **Security Groups Module** (`modules/sg/`)
```
Purpose: Implement network security controls

4 Security Groups:

1. ALB_SG
   - Ingress: 80 from 0.0.0.0/0 (public)
   - Egress: All traffic
   
2. FRONTEND_SG
   - Ingress: 80 from ALB_SG, 22 from anywhere
   - Egress: All traffic
   - Purpose: Web server access control
   
3. BACKEND_SG
   - Ingress: 3000 from Frontend_SG, 22 SSH
   - Egress: All traffic
   - Purpose: API server access control
   
4. RDS_SG
   - Ingress: 3306 (MySQL) from Backend_SG only
   - Egress: All traffic
   - Purpose: Database access control

Why strict rules?
- Principle of least privilege
- Defense in depth
- Prevents unauthorized access
```

#### **EC2 Module** (`modules/ec2/`)
```
Purpose: Launch and configure EC2 instances

Resources:
- aws_instance: EC2 instance with:
  * AMI: Ubuntu 20.04 LTS
  * Instance Type: t3.micro (free tier eligible)
  * Public IP assignment
  * SSH key pair
  * IAM instance profile
  
- aws_iam_role: Allows SSM Sessions Manager
- aws_iam_instance_profile: Attaches IAM role

Why IAM role?
- Secure credential management
- Systems Manager access
- No SSH keys needed for remote access
```

#### **ALB Module** (`modules/alb/`)
```
Purpose: Distribute traffic across instances

Resources:
- aws_lb: Application Load Balancer
- aws_lb_target_group: Group of targets (instances)
- aws_lb_listener: Listen on port 80
- aws_lb_target_group_attachment: Register targets

Health checks:
- Path: /
- Interval: 30 seconds
- Healthy threshold: 2
- Matcher: 200 response code

Why ALB?
- Layer 7 (application) load balancing
- Path-based routing support
- Better for microservices
```

#### **RDS Module** (`modules/rds/`)
```
Purpose: Deploy managed MySQL database

Resources:
- aws_db_subnet_group: Multi-AZ subnet group
- aws_db_instance: MySQL 8.0 instance

Configuration:
- Instance class: db.t4g.micro (free tier)
- Storage: 20 GB (free tier)
- Multi-AZ: Enabled (HA)
- Engine: MySQL 8.0
- DB Name: mydb
- Root user: admin / password123

Why RDS?
- Managed service (AWS handles backups, patches)
- Automated failover
- Point-in-time recovery
- No infrastructure management
```

### 3. INITIALIZATION SCRIPTS

#### **frontend.sh** - Frontend Server Setup
```bash
#!/bin/bash

Purpose: Automatically configure Nginx server

Steps:
1. Update apt packages
2. Install nginx
3. Remove default nginx config
4. Create custom nginx config:
   - Listen on port 80
   - Serve static files from /var/www/html
   - Proxy /api/* requests to backend server
5. Create index.html with:
   - Dashboard showing system info
   - Form to register users in database
   - JavaScript to call backend APIs

Template injection:
- ${backend_ip} - Injected by Terraform
- Allows frontend to know backend location
```

#### **backend.sh** - Backend Server Setup
```bash
#!/bin/bash

Purpose: Deploy Node.js API server

Steps:
1. Update apt packages
2. Install Node.js 18.x
3. Install MySQL client
4. Create app.js with endpoints:
   - GET /health - Returns server status
   - POST /register - Inserts user in RDS
5. Configure CORS headers
6. Connect to MySQL database
7. Start server using PM2

API Endpoints:
- /health (GET)
  └─ Returns: status, database, instanceId, az, privateIp
  
- /register (POST)
  └─ Body: {name, email}
  └─ Action: INSERT INTO users table
  └─ Returns: Success/error message

Why PM2?
- Process management
- Auto-restart on crash
- Process monitoring
```

---

## TECHNOLOGY STACK

### Cloud Platform: AWS
- **Compute**: EC2 (t3.micro instances)
- **Database**: RDS (MySQL 8.0)
- **Load Balancing**: Application Load Balancer
- **Networking**: VPC, Subnets, Security Groups, NAT Gateway
- **Identity**: IAM Roles

### Infrastructure as Code
- **Tool**: Terraform 1.x
- **Provider**: HashiCorp AWS Provider v6.39.0

### Application Stack
- **Frontend**: Nginx (reverse proxy, web server)
- **Backend**: Node.js 18.x (REST API)
- **Database**: MySQL 8.0
- **Process Manager**: PM2

### Scripting
- **Initialization**: Bash scripts (frontend.sh, backend.sh)
- **Infrastructure**: Terraform (HCL)

---

## KEY CONCEPTS

### 1. **Infrastructure as Code (IaC)**
**What**: Writing infrastructure as code files instead of manual clicking

**How in this project**:
- Entire infrastructure defined in .tf files
- Version controlled in Git
- Reproducible deployments
- Easy rollbacks and changes

**Benefits**:
- Consistency across environments
- Documentation through code
- Easy to test and validate
- Faster deployments

---

### 2. **Modular Architecture**
**What**: Breaking code into reusable components

**Modules in this project**:
- vpc: Networking
- sg: Security
- ec2: Compute
- alb: Load balancing
- rds: Database

**Benefits**:
- Reusability
- Maintainability
- Clear separation of concerns
- Easy testing

---

### 3. **Multi-tier Architecture**
**What**: Separating application into distinct layers

**Three tiers**:
1. **Presentation**: User interface (Nginx)
2. **Application**: Business logic (Node.js)
3. **Data**: Persistent storage (MySQL)

**Benefits**:
- Scalability (scale each tier independently)
- Maintainability (changes in one tier don't affect others)
- Security (restrict access between tiers)
- Testability (test each tier separately)

---

### 4. **VPC (Virtual Private Cloud)**
**What**: Isolated network environment in AWS

**Components**:
- Subnets: Smaller networks within VPC
- Route Tables: Define traffic routing
- Internet Gateway: Connect to internet
- NAT Gateway: Allows private → internet

**In this project**:
- Public subnets: Frontend, ALB, NAT Gateway
- Private subnets: Backend, RDS

---

### 5. **Security Groups**
**What**: Virtual firewalls for AWS resources

**Rules**:
- Ingress: Inbound traffic
- Egress: Outbound traffic
- Can reference other security groups

**Principle of Least Privilege**:
- Only allow necessary traffic
- Restrict by source/destination
- Minimize exposure

---

### 6. **Availability Zones (AZ)**
**What**: Physically separate data centers within a region

**In this project**:
- Subnets spread across 2 AZs
- RDS Multi-AZ enabled
- High availability (if one AZ down, others work)

**Benefits**:
- Fault tolerance
- Reduced downtime
- Better resilience

---

### 7. **Auto-Initialization (User Data)**
**What**: Scripts that run when EC2 starts

**In this project**:
- frontend.sh: Configure Nginx
- backend.sh: Install Node.js, start API

**Benefits**:
- Zero-touch deployment
- Consistent configuration
- Faster scaling

---

### 8. **Load Balancing**
**What**: Distributing traffic across multiple instances

**ALB Features**:
- Health checks: Monitors instance health
- Target groups: Groups of instances
- Listeners: Listen on specific ports/protocols
- Routing: Can route based on path, host, etc.

**In this project**:
- Routes HTTP requests to frontend instance
- Health checks every 30 seconds

---

### 9. **Reverse Proxy**
**What**: Server that forwards requests to backend servers

**In this project**:
- Nginx acts as reverse proxy
- /api/* requests forwarded to Node.js
- Static requests served directly

**Benefits**:
- Security (backend not exposed)
- Performance (caching)
- Load distribution

---

### 10. **Managed Services**
**What**: AWS-managed services (less operational overhead)

**RDS Benefits**:
- No server management
- Automatic backups
- Automatic patching
- Automatic failover
- Point-in-time recovery

---

## ALTERNATIVES & COMPARISON

### Alternative 1: Kubernetes (EKS)

**Comparison**:
```
This Project (EC2 + Terraform):
✓ Simpler to understand
✓ Lower learning curve
✓ Direct infrastructure control
✗ Manual scaling
✗ More operational overhead

Kubernetes (EKS):
✓ Auto-scaling built-in
✓ Self-healing
✓ Declarative management
✓ Container orchestration
✗ Steeper learning curve
✗ More complex
✗ Overkill for simple apps

Verdict: EC2 better for learning, K8s better for scale
```

---

### Alternative 2: Serverless (Lambdas + DynamoDB)

**Comparison**:
```
This Project (Traditional):
✓ Full control
✓ Standard frameworks
✓ Better for traditional apps
✗ Always running (costs)
✗ Manual scaling

Serverless:
✓ Pay-per-execution
✓ Auto-scaling
✓ Less operational overhead
✗ Cold start latency
✗ Vendor lock-in
✗ 15-minute timeout limit
✗ Not good for long-running processes

Verdict: EC2 better for consistent load, Serverless for spiky
```

---

### Alternative 3: Elastic Beanstalk

**Comparison**:
```
This Project (Raw Terraform):
✓ Full control
✓ Learn every component
✓ No abstractions
✗ More code to write

Elastic Beanstalk:
✓ Automated infrastructure
✓ Less code
✓ Auto-scaling built-in
✗ Less flexibility
✗ Less learning value
✗ More expensive

Verdict: Terraform better for learning, Beanstalk for speed
```

---

### Alternative 4: Docker + ECS

**Comparison**:
```
This Project:
✓ Simpler (no containers)
✓ Direct VMs
✗ Environment mismatch (local vs AWS)
✗ No versioning

ECS (Elastic Container Service):
✓ Containerization
✓ Reproducible environments
✓ Better deployment workflow
✓ Easier rollbacks
✗ More complex
✗ Requires Docker knowledge

Verdict: This project simpler but ECS is production-standard
```

---

### Why This Project's Architecture is Better

**For Learning**:
- ✅ Shows all components
- ✅ No magic abstractions
- ✅ Learn each service
- ✅ Understand interactions

**For Production** (with improvements):
- ✅ Uses managed database (RDS)
- ✅ Load balancing (ALB)
- ✅ Multi-AZ (HA)
- ✅ Security groups (defense)
- ✅ Infrastructure as code
- ✅ Easy to modify/scale

**Cost-Effective**:
- ✅ Free tier eligible
- ✅ No expensive abstractions
- ✅ Pay for exactly what you use
- ✅ Easy to add/remove resources

**Scalability** (with modifications):
- ✅ Can add Auto Scaling Groups
- ✅ Can add read replicas
- ✅ Can add caching layer
- ✅ Can add CDN
- ✅ Can move to containers

---

## IMPROVEMENTS & ENHANCEMENTS

### 1. **Security Improvements**

#### Current Issues
```
❌ Database password hardcoded
❌ SSH open to world (0.0.0.0/0)
❌ No HTTPS/TLS encryption
❌ No input validation on backend
❌ Hardcoded credentials in scripts
```

#### Improvements
```
✅ Use AWS Secrets Manager
  - Store passwords securely
  - Rotate automatically
  - Audit trail

✅ Restrict SSH access
  - Bastion host pattern
  - Or use Systems Manager Sessions Manager
  - Only allow specific IPs

✅ Add HTTPS/TLS
  - AWS Certificate Manager
  - ALB SSL termination
  - Automatic HTTP→HTTPS redirect

✅ Input validation
  - Validate email format
  - Prevent SQL injection (use parameterized queries)
  - Rate limiting

✅ Use IAM Database Authentication
  - No passwords in code
  - Token-based access
  - Better audit trail
```

---

### 2. **High Availability Improvements**

#### Current Setup
```
- Single frontend instance
- Single backend instance
- Multi-AZ RDS (good)
- No auto-scaling
```

#### Improvements
```
1. Auto Scaling Groups for frontend
   - Min 2, Max 5 instances
   - Scale based on CPU/memory
   - Automatic replacement if unhealthy

2. Multiple backend instances
   - Run in ASG
   - ALB routes between them
   - Better load distribution

3. Read Replicas for RDS
   - Handle read-heavy workloads
   - Distribute traffic

4. Caching Layer
   - ElastiCache (Redis/Memcached)
   - Reduce database load
   - Faster responses

5. CDN for static content
   - CloudFront
   - Cache static assets globally
   - Reduce ALB traffic

Architecture after improvements:
```
Internet
  ↓
CloudFront (CDN)
  ↓
ALB
  ↓
ASG (Frontend) → ASG (Backend)
  ↓
ElastiCache ← RDS + Read Replicas
```
```

---

### 3. **Operational Improvements**

#### Logging & Monitoring
```
Current: No centralized logging

Add:
- CloudWatch Logs
  * Application logs
  * ALB access logs
  * RDS logs
  * EC2 system logs

- CloudWatch Metrics
  * Custom metrics from application
  * Infrastructure metrics
  * Database metrics

- CloudWatch Alarms
  * High CPU usage
  * High memory usage
  * Failed requests
  * Database connection errors

- Dashboards
  * Unified view of all metrics
  * Real-time monitoring
  * Historical trends
```

#### Backup & Recovery
```
Current: RDS automated backups (default 7 days)

Add:
- Automated DB snapshots
- Cross-region backup for disaster recovery
- Test recovery procedures
- Document RTO/RPO
- Backup before major changes
```

---

### 4. **Code Quality Improvements**

#### Terraform Code
```
Add:
- Variable validation
  ```hcl
  variable "instance_type" {
    validation {
      condition = contains(["t3.micro", "t3.small"], var.instance_type)
      error_message = "Only t3 family allowed"
    }
  }
  ```

- Locals for common values
  ```hcl
  locals {
    common_tags = {
      Project = "MultiTierApp"
      Env = var.environment
    }
  }
  ```

- Better variable names and descriptions
- Separate files by component (networking.tf, compute.tf, etc.)
- Add comments explaining "why" not just "what"
```

#### Application Code
```
Current backend.js: Basic implementation

Add:
- Error handling
  * Try-catch blocks
  * Proper error responses
  * Error logging

- Input validation
  * Email format validation
  * Name length validation
  * SQL injection prevention

- Database connection pooling
  * mysql2/promise for better handling
  * Connection pool configuration
  * Reconnection logic

- Rate limiting
  * Prevent abuse
  * DDoS protection
  * Per-IP or per-endpoint

- Middleware
  * Request logging
  * Authentication
  * CORS handling
```

---

### 5. **Architecture Improvements**

#### Add Bastion Host
```
Instead of: SSH 0.0.0.0/0
Implement: Bastion Host
  - Single entry point
  - Reduced attack surface
  - Audit trail
  - Jump to private instances
```

#### Add VPN
```
For remote access:
- AWS Client VPN
- Encrypted tunnel to VPC
- Granular access control
```

#### Service Discovery
```
Problem: Backend IP hardcoded in frontend
Solution: Use Route 53
- DNS-based service discovery
- Automatic failover
- Health checks
```

---

### 6. **Testing Improvements**

#### Infrastructure Tests
```
Add:
- Terraform validation
- Checkov (IaC security scanning)
- TFLint (Terraform linting)
- Cost estimation with Infracost
```

#### Application Tests
```
Add:
- Unit tests for Node.js
- Integration tests
- Load testing (Artillery.io)
- Security testing (OWASP ZAP)
```

---

### 7. **CI/CD Pipeline**

#### Current: Manual terraform apply

#### Add:
```
GitHub Actions Pipeline:

1. On Pull Request:
   - Terraform validate
   - Terraform format check
   - Infrastructure cost estimation
   - Security scanning

2. On Push to Main:
   - Terraform plan
   - Require approval
   - Terraform apply
   - Run tests
   - Deploy updates

3. Automated testing:
   - Smoke tests
   - Health checks
   - Database connectivity tests
```

---

### 8. **Documentation Improvements**

```
Add:
- Architecture decision records (ADRs)
- Runbooks for common operations
- Troubleshooting guide
- Disaster recovery procedures
- Cost optimization guide
```

---

## LEARNING OUTCOMES

### What You Learn From This Project

#### Cloud Architecture
- ✅ VPC design and networking
- ✅ Multi-tier application architecture
- ✅ Load balancing concepts
- ✅ Security through network isolation
- ✅ Multi-AZ for high availability
- ✅ Managed services benefits

#### Infrastructure as Code
- ✅ Terraform fundamentals
- ✅ Modular code organization
- ✅ Resource dependencies
- ✅ Variable management
- ✅ Module composition
- ✅ Output management

#### AWS Services
- ✅ VPC, Subnets, Route Tables
- ✅ Security Groups
- ✅ EC2 instances and IAM roles
- ✅ Application Load Balancer
- ✅ RDS database
- ✅ NAT Gateway

#### Automation
- ✅ Bash scripting
- ✅ Cloud-init/User Data
- ✅ Configuration automation
- ✅ Zero-touch deployments

#### Application Development
- ✅ Web server (Nginx)
- ✅ REST API design
- ✅ Database connections
- ✅ Reverse proxy concepts
- ✅ CORS and request routing

#### Operations & DevOps
- ✅ Infrastructure provisioning
- ✅ Environment management
- ✅ Deployment automation
- ✅ Troubleshooting approaches
- ✅ Monitoring basics

#### Security
- ✅ Principle of least privilege
- ✅ Network segmentation
- ✅ Credential management
- ✅ Access control
- ✅ Security groups design

### Skills Developed
```
🔧 Technical Skills:
- Terraform (Advanced)
- AWS (Intermediate-Advanced)
- Networking (Intermediate)
- DevOps (Intermediate)
- Bash Scripting (Intermediate)
- Node.js (Intermediate)
- Database (Intermediate)

🧠 Conceptual Skills:
- Infrastructure as Code
- Cloud architecture
- Security principles
- Scalability patterns
- High availability
- Disaster recovery

🏢 Professional Skills:
- Documentation
- Problem solving
- Systems thinking
- Code organization
- Best practices
```

---

## Summary

This project is a **comprehensive demonstration of modern cloud infrastructure** design. It shows:

1. **How to build** production-grade infrastructure
2. **Why to separate concerns** (3-tier architecture)
3. **How to automate everything** (Terraform + scripts)
4. **How to secure** applications (security groups, subnets)
5. **How to think** like a DevOps engineer

It's complex enough to learn real concepts but simple enough to understand each piece.
