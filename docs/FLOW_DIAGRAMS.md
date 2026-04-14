# ARCHITECTURE DIAGRAMS & FLOW EXPLANATIONS

## 📐 Complete System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         AWS REGION (us-east-1)                      │
│                                                                     │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │                          VPC (10.0.0.0/16)                     │ │
│  │                                                                │ │
│  │  ┌─────────────────────────────────────────────────────────┐   │ │
│  │  │  PUBLIC SUBNETS (IGW-Accessible)                        │   │ │
│  │  │                                                         │   │ │
│  │  │  Subnet-1 (10.0.1.0/24) - AZ-a                          │   │ │
│  │  │  ┌────────────────────────────────────────────────┐     │   │ │
│  │  │  │ Nginx Server (Frontend)                        │     │   │ │
│  │  │  │ EC2 Instance (t3.micro)                        │     │   │ │
│  │  │  │ Public IP: 54.x.x.x                            │     │   │ │
│  │  │  │ Port: 80 (HTTP)                                │     │   │ │
│  │  │  └────────────────────────────────────────────────┘     │   │ │
│  │  │                                                         │   │ │
│  │  │  Subnet-2 (10.0.2.0/24) - AZ-b                          │   │ │
│  │  │  ┌────────────────────────────────────────────────┐     │   │ │
│  │  │  │ NAT Gateway                                    │     │   │ │
│  │  │  │ Allows private→internet                        │     │   │ │
│  │  │  │ Elastic IP: x.x.x.x                            │     │   │ │
│  │  │  └────────────────────────────────────────────────┘     │   │ │
│  │  │                                                         │   │ │
│  │  │  ┌────────────────────────────────────────────────┐     │   │ │
│  │  │  │ ALB (Application Load Balancer)                │     │   │ │
│  │  │  │ DNS: app-lb-xxxxx.elb.amazonaws.com            │     │   │ │
│  │  │  │ Port: 80                                       │     │   │ │
│  │  │  │ Health Check: GET / every 30s                  │     │   │ │
│  │  │  │ Routing: frontend.nginx:80                     │     │   │ │
│  │  │  └────────────────────────────────────────────────┘     │   │ │
│  │  └─────────────────────────────────────────────────────────┘   │ │
│  │                          ↓ Route Table                         │ │
│  │                   0.0.0.0/0 → IGW                              │ │
│  │                                                                │ │
│  │  ┌─────────────────────────────────────────────────────────┐   │ │
│  │  │  PRIVATE SUBNETS (NAT-Accessible Only)                  │   │ │
│  │  │                                                         │   │ │
│  │  │  Subnet-3 (10.0.3.0/24) - AZ-a                          │   │ │
│  │  │  ┌────────────────────────────────────────────────┐     │   │ │
│  │  │  │ Node.js Backend API                            │     │   │ │
│  │  │  │ EC2 Instance (t3.micro)                        │     │   │ │
│  │  │  │ Private IP: 10.0.3.x                           │     │   │ │
│  │  │  │ Port: 3000 (HTTP)                              │     │   │ │
│  │  │  │ Routes:                                        │     │   │ │
│  │  │  │   GET  /health    → Server status              │     │   │ │
│  │  │  │   POST /register  → Insert user to RDS         │     │   │ │
│  │  │  │                                                │     │   │ │
│  │  │  │ Connected to: MySQL via TCP:3306               │     │   │ │
│  │  │  └────────────────────────────────────────────────┘     │   │ │
│  │  │                                                         │   │ │
│  │  │  Subnet-4 (10.0.4.0/24) - AZ-b                          │   │ │
│  │  │  ┌────────────────────────────────────────────────┐     │   │ │
│  │  │  │ RDS MySQL Database                             │     │   │ │
│  │  │  │ Instance: db.t4g.micro                         │     │   │ │
│  │  │  │ Version: MySQL 8.0                             │     │   │ │
│  │  │  │ Endpoint: mydb.xxxxx.rds.amazonaws.com         │     │   │ │
│  │  │  │ Port: 3306 (MySQL)                             │     │   │ │
│  │  │  │ Storage: 20 GB                                 │     │   │ │
│  │  │  │ Database: mydb                                 │     │   │ │
│  │  │  │ User: admin / password123                      │     │   │ │
│  │  │  │ Multi-AZ: Enabled (Standby in AZ-b)            │     │   │ │
│  │  │  │ Table: users (name, email)                     │     │   │ │
│  │  │  └────────────────────────────────────────────────┘     │   │ │
│  │  │                                                         │   │ │
│  │  └─────────────────────────────────────────────────────────┘   │ │
│  │                          ↓ Route Table                         │ │
│  │                   0.0.0.0/0 → NAT                              │ │
│  │                                                                │ │
│  │  SECURITY GROUPS (Firewalls):                                  │ │
│  │  ┌─ ALB_SG:                                                    │ │
│  │  │  Ingress:  80 from 0.0.0.0/0                                │ │
│  │  │  Egress:   All                                              │ │
│  │  │                                                             │ │
│  │  ├─ FRONTEND_SG:                                               │ │
│  │  │  Ingress:  80 from ALB_SG, 22 from 0.0.0.0/0                │ │
│  │  │  Egress:   All                                              │ │
│  │  │                                                             │ │
│  │  ├─ BACKEND_SG:                                                │ │
│  │  │  Ingress:  3000 from FRONTEND_SG, 22 from 0.0.0.0/0         │ │
│  │  │  Egress:   All                                              │ │
│  │  │                                                             │ │
│  │  └─ RDS_SG:                                                    │ │
│  │     Ingress:  3306 from BACKEND_SG                             │ │
│  │     Egress:   All                                              │ │
│  │                                                                │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                     │
│                    ↑ Internet Gateway (IGW)                         │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘

                           INTERNET
```

---

## 📊 Request/Response Flow Diagram

```
SCENARIO: User registers a new cloud node through web dashboard

1. USER INTERACTION
   ┌─────────────────┐
   │ User opens      │
   │ browser         │
   │ Enters name,    │
   │ email           │
   │ Clicks submit   │
   └────────┬────────┘
            │
            ▼ HTTP Request to ALB DNS name
   ┌─────────────────────────────────────────────────────┐
   │ http://app-lb-xxxxx.elb.amazonaws.com/              │
   └────────┬────────────────────────────────────────────┘
            │ POST body: {name: "node1", email: "admin@example.com"}
            │
            ▼
2. LOAD BALANCER ROUTING
   ┌─────────────────────────────────────────────┐
   │ ALB (Port 80)                               │
   │ ├─ Receives HTTP request                    │
   │ ├─ Health checks target (Nginx)             │
   │ ├─ Routes to target group                   │
   │ └─ Forwards to Frontend instance:80         │
   └────────┬────────────────────────────────────┘
            │
            ▼
3. FRONTEND PROCESSING
   ┌─────────────────────────────────────────────────────┐
   │ Nginx (Reverse Proxy)                               │
   │                                                     │
   │ Path: /                                             │
   │ ├─ Static content (index.html, CSS, JS)             │
   │ └─ Return to client → Dashboard displayed           │
   │                                                     │
   │ Path: /api/*                                        │
   │ └─ Proxy to Backend (10.0.3.x:3000/...)             │
   │                                                     │
   │ For our request:                                    │
   │ POST /api/register → Proxied to 10.0.3.x:3000       │
   └────────┬────────────────────────────────────────────┘
            │ ProxyPass: http://10.0.3.x:3000/register
            │ Headers passed: Content-Type, User-Agent, etc.
            │
            ▼
4. API ROUTING
   ┌─────────────────────────────────────────────────────┐
   │ Node.js Backend (Port 3000)                         │
   │                                                     │
   │ POST /register request received                     │
   │ ├─ CORS headers added                               │
   │ ├─ Parse JSON body                                  │
   │ ├─ Extract: name="node1", email="admin@..."         │
   │ └─ Call database                                    │
   └────────┬────────────────────────────────────────────┘
            │ SQL: INSERT INTO users (name, email) VALUES (?, ?)
            │ Connection via: TCP:3306 to RDS endpoint
            │
            ▼
5. DATABASE OPERATION
   ┌─────────────────────────────────────────────────────┐
   │ MySQL RDS Instance                                  │
   │                                                     │
   │ ├─ Receives INSERT statement                        │
   │ ├─ Validates query                                  │
   │ ├─ Writes to disk (InnoDB)                          │
   │ ├─ Replicates to standby (Multi-AZ)                 │
   │ └─ Returns: Query OK                                │
   └────────┬────────────────────────────────────────────┘
            │ Response: Query executed successfully
            │
            ▼
6. BACKEND RESPONSE
   ┌─────────────────────────────────────────────────────┐
   │ Node.js Backend                                     │
   │                                                     │
   │ ├─ No error from database                           │
   │ ├─ Generate response JSON                           │
   │ ├─ {message: "User Registered Successfully!"}       │
   │ └─ Send back to Nginx                               │
   └────────┬────────────────────────────────────────────┘
            │ HTTP 200 OK with JSON body
            │
            ▼
7. FRONTEND DISPLAY
   ┌─────────────────────────────────────────────────────┐
   │ Nginx Reverse Proxy                                 │
   │                                                     │
   │ ├─ Receives response from backend                   │
   │ └─ Forwards to client                               │
   └────────┬────────────────────────────────────────────┘
            │ HTTP 200 + JSON response
            │
            ▼
8. BROWSER HANDLING
   ┌─────────────────────────────────────────────────────┐
   │ JavaScript (in Browser)                             │
   │                                                     │
   │ ├─ fetch() receives response                        │
   │ ├─ Parse JSON: {message: "User Registered..."}      │
   │ ├─ Update DOM element                               │
   │ └─ Display: "User Registered Successfully!"         │
   │    in green text                                    │
   └─────────────────────────────────────────────────────┘
            │
            ▼
9. USER SEES RESULT
   ┌─────────────────────────────────────────────────────┐
   │ "User Registered Successfully!" message appears     │
   │ in green on the dashboard                           │
   └─────────────────────────────────────────────────────┘

COMPLETE FLOW TIME: ~500-1000ms (depending on network/DB)
```

---

## 🔄 Alternative Flow: Health Check

```
SCENARIO: Frontend dashboard checks backend health status

Automatic flow every few seconds:

1. Browser JavaScript
   ┌─────────────────┐
   │ fetch('/api/    │
   │  health')       │
   └────────┬────────┘
            │
            ▼ GET request to /api/health
   
2. Nginx (reverse proxy)
   ┌──────────────────────────┐
   │ Routes to 10.0.3.x:3000  │
   └────────┬─────────────────┘
            │
            ▼

3. Node.js Backend
   ┌──────────────────────────┐
   │ GET /health endpoint     │
   │ ├─ Query AWS metadata    │
   │ ├─ Get instance ID       │
   │ ├─ Get availability zone │
   │ ├─ Get private IP        │
   │ └─ Return JSON           │
   └────────┬─────────────────┘
            │ {status: "Online", database: "Connected",
            │  instanceId: "i-...", az: "us-east-1a",
            │  privateIp: "10.0.3.x"}
            │
            ▼

4. Browser JavaScript
   ┌──────────────────────────────────────┐
   │ Update dashboard with:               │
   │ ├─ Status pill: "Online"             │
   │ ├─ Instance ID: i-...                │
   │ ├─ Region/AZ: us-east-1a             │
   │ └─ Private IP: 10.0.3.x              │
   └──────────────────────────────────────┘

TIME: ~200-300ms
ERROR HANDLING: If backend offline, shows "Offline" status
```

---

## 🔐 Security Flow Diagram

```
SECURITY LAYERS (Defense in Depth)

┌─────────────────────────────────────────────────────────────┐
│ LAYER 1: Network Level (VPC)                                │
│                                                             │
│ Frontend in Public Subnet ─┐                                │
│                             │                               │
│ Backend in Private Subnet ──┼─→ Only NAT Gateway internet   │
│                             │                               │
│ Database in Private Subnet ─┘                               │
│                                                             │
│ Benefit: Database never exposed to internet                 │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ LAYER 2: Security Groups (Firewalls)                        │
│                                                             │
│ Frontend ──80──→ ALB ──[allowed]──→ Frontend:80             │
│            │                                                │
│            └─→ Port 443/8080/etc [BLOCKED]                  │
│                                                             │
│ Backend ──3000──→ Frontend ──[allowed]──→ Backend:3000      │
│           │                                                 │
│           └─→ RDS/Other ports [BLOCKED]                     │
│                                                             │
│ RDS ──3306──→ Backend ──[allowed]──→ RDS:3306               │
│        │                                                    │
│        └─→ Frontend/Other sources [BLOCKED]                 │
│                                                             │
│ Benefit: Only required ports accessible                     │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ LAYER 3: Application Level                                  │
│                                                             │
│ ├─ CORS headers (prevent unauthorized domains)              │
│ ├─ Input validation (prevent injection)                     │
│ ├─ Error handling (don't leak internal details)             │
│ └─ Rate limiting (prevent abuse)                            │
│                                                             │
│ Benefit: Application-level security controls                │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ LAYER 4: Database Level                                     │
│                                                             │
│ ├─ User/password authentication                             │
│ ├─ Parameterized queries (prevent SQL injection)            │
│ ├─ Principle of least privilege (minimal permissions)       │
│ └─ Encrypted connections (SSL/TLS)                          │
│                                                             │
│ Benefit: Database-level security controls                   │
└─────────────────────────────────────────────────────────────┘

ATTACK SCENARIOS & DEFENSE:

1. DDoS on Frontend
   → ALB rate limiting, WAF (future)
   
2. Direct DB access from internet
   → Private subnet + security group blocks
   
3. Frontend compromise
   → Backend still protected (in private subnet)
   → RDS still protected (only from Backend)
   
4. SSH access
   → Restricted to specific IPs (should be)
   → Use IAM role instead (better practice)
   
5. SQL Injection
   → Parameterized queries prevent it
```

---

## 🚀 Deployment Flow Diagram

```
TERRAFORM DEPLOYMENT WORKFLOW

Developer
    │
    ├─→ Writes Terraform (.tf files)
    │
    ├─→ terraform init
    │   └─→ Downloads AWS provider plugin
    │
    ├─→ terraform plan
    │   └─→ Shows what will be created:
    │       ├─ VPC
    │       ├─ Subnets (4)
    │       ├─ Route tables, IGW, NAT
    │       ├─ Security groups (4)
    │       ├─ EC2 instances (2)
    │       ├─ ALB with target groups
    │       └─ RDS instance
    │
    ├─→ Review plan output
    │
    └─→ terraform apply
        │
        ├─→ AWS API Calls (parallel where possible)
        │   │
        │   ├─→ VPC created
        │   ├─→ Subnets created
        │   ├─→ Route tables created & associated
        │   ├─→ IGW attached
        │   ├─→ NAT Gateway created
        │   │
        │   ├─→ Security groups created
        │   │   └─→ Ingress/egress rules added
        │   │
        │   ├─→ RDS subnet group created
        │   ├─→ RDS instance launched
        │   │   └─→ Takes 5-10 minutes
        │   │
        │   ├─→ Backend EC2 launched
        │   │   ├─→ User data script runs:
        │   │   │   ├─ Install Node.js
        │   │   │   ├─ Create app.js
        │   │   │   ├─ Start with PM2
        │   │   │   └─ Backend ready
        │   │   └─→ Backend IP = 10.0.3.x
        │   │
        │   ├─→ Frontend EC2 launched
        │   │   ├─→ User data script runs:
        │   │   │   ├─ Install Nginx
        │   │   │   ├─ Create nginx config (with backend IP!)
        │   │   │   ├─ Create index.html
        │   │   │   └─ Nginx started
        │   │   └─→ Frontend ready
        │   │
        │   └─→ ALB created & configured
        │       ├─ Listeners added
        │       ├─ Target group added
        │       ├─ Frontend instance attached
        │       └─ Health checks start
        │
        └─→ Outputs printed:
            ├─ app_url: http://app-lb-xxxx.elb.amazonaws.com
            ├─ backend_private_ip: 10.0.3.x
            └─ rds_address: mydb-xxxx.rds.amazonaws.com

TOTAL TIME: 10-15 minutes
```

---

## 📈 Scaling Flow (What Would Happen)

```
CURRENT STATE:
├─ 1 Frontend EC2
├─ 1 Backend EC2
├─ 1 RDS instance
└─ 1 ALB

PROBLEM: Traffic increases 10x

SOLUTION: Add Auto Scaling Groups

1. Create Launch Template from current EC2
   └─ Captures AMI, security group, user data, etc.

2. Create Auto Scaling Group for Frontend
   ├─ Min: 2 instances
   ├─ Max: 5 instances
   ├─ Target: 70% CPU utilization
   └─ Automatically creates/destroys instances

3. Create Auto Scaling Group for Backend
   ├─ Min: 2 instances
   ├─ Max: 10 instances
   ├─ Register all with ALB
   └─ Auto-scale with demand

4. Database Scaling
   ├─ Add read replicas for read-heavy loads
   ├─ Upgrade to larger instance if needed
   └─ Add ElastiCache for caching

RESULT:
┌─────────────────────────────────────┐
│ ALB                                 │
├─────────────────┬───────────────────┤
│                 │                   │
▼                 ▼                   ▼
Frontend-1     Frontend-2     Frontend-3...

Automatically routes to healthy instances
Scales up when CPU > 70%
Scales down when CPU < 30%
```

---

## 💾 Data Flow Diagram

```
DATA PERSISTENCE FLOW

USER SUBMITS DATA: {name: "Cloud Node 1", email: "admin@aws.com"}
    │
    ▼
HTTP POST /api/register
    │
    ▼
Nginx (Reverse Proxy)
    │ (forwards to backend)
    ▼
Node.js Backend
    │ const stmt = "INSERT INTO users (name, email) VALUES (?, ?)"
    │ connection.query(stmt, [name, email], callback)
    ▼
MySQL Network Protocol (TCP:3306)
    │ Encrypted connection (optional SSL/TLS)
    ▼
RDS Endpoint
    │
    ├─→ Primary Instance (us-east-1a)
    │   ├─ Executes INSERT
    │   ├─ Writes to InnoDB buffer
    │   ├─ Flushes to disk (crash recovery)
    │   └─ Replicates to secondary
    │
    └─→ Secondary Instance (us-east-1b) [Standby]
        ├─ Receives replication data
        ├─ Applies same INSERT
        └─ Keeps in sync

RESULT:
✓ Data persisted in primary
✓ Data replicated to secondary
✓ If primary fails → Failover to secondary (< 2 minutes)
✓ Data not lost

NEXT REQUEST:
SELECT * FROM users
    │
    ▼ (same path in reverse)
    
Backend gets data and returns to Frontend
```

---

## 🔄 Module Dependencies Diagram

```
Terraform Module Dependency Graph:

aws_key_pair
    │
    ├─→ VPC Module
    │   └─→ Creates: VPC, Subnets, IGW, NAT, Route Tables
    │       Outputs: vpc_id, public_subnets, private_subnets
    │
    ├─→ SG Module (depends on VPC)
    │   └─→ Creates: 4 Security Groups
    │       Outputs: alb_sg, frontend_sg, backend_sg, rds_sg
    │
    ├─→ RDS Module (depends on VPC, SG)
    │   ├─→ Creates: DB Subnet Group, RDS Instance
    │   └─→ Outputs: rds_address, rds_port
    │
    ├─→ Backend EC2 Module (depends on VPC, SG, RDS)
    │   ├─→ Uses: private_subnets[0], backend_sg
    │   ├─→ User data: backend.sh (template: RDS endpoint)
    │   └─→ Outputs: backend_private_ip, backend_id
    │
    ├─→ Frontend EC2 Module (depends on VPC, SG, Backend)
    │   ├─→ Uses: public_subnets[0], frontend_sg
    │   ├─→ User data: frontend.sh (template: Backend IP)
    │   └─→ Outputs: frontend_public_ip, frontend_id
    │
    └─→ ALB Module (depends on VPC, SG, Frontend)
        ├─→ Creates: ALB, Target Group, Listener
        ├─→ Registers: Frontend instance
        └─→ Outputs: alb_dns_name

KEY DEPENDENCY: frontend depends_on backend
    ├─ Ensures backend created first
    ├─ Terraform passes backend_ip to frontend.sh
    ├─ Frontend knows where to send API requests
    └─ Without it: frontend.sh gets empty backend_ip
```

---

## 🔗 Communication Paths Diagram

```
ALLOWED COMMUNICATION PATHS:

┌─ Internet → ALB:80
│  Reason: Users need to access application
│  Security: SG allows 80 from 0.0.0.0/0
│
├─ ALB → Frontend:80
│  Reason: Load balancer must reach targets
│  Security: Frontend SG allows 80 from ALB SG
│
├─ Frontend:* → Backend:3000
│  Reason: Frontend proxies API requests
│  Security: Backend SG allows 3000 from Frontend SG
│
├─ Backend:* → RDS:3306
│  Reason: Backend needs to query database
│  Security: RDS SG allows 3306 from Backend SG
│
├─ Private:* → NAT Gateway:*
│  Reason: Private resources need internet (patches, etc.)
│  Security: Outbound only, NAT masks private IP
│
└─ Admin → Any instance:22 (SSH)
   Reason: Management/troubleshooting
   Security: Should be restricted (currently open)

BLOCKED PATHS:

× Internet → Backend:3000 [Not allowed by SG]
× Internet → RDS:3306 [Not allowed by SG]
× Frontend → RDS:3306 [Not allowed by SG]
× Backend → Unknown:* [Only MySQL allowed out]

WHY THIS MATTERS:
- Each component isolated
- Attack on one doesn't cascade
- Principle of least privilege
- Defense in depth strategy
```

---

End of Flow Diagrams

This document shows how every piece connects and communicates!
