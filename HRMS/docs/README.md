# HRMS (Human Resource Management System) API

A comprehensive FastAPI-based Human Resource Management System with mock REST API endpoints for managing employees, departments, and leave requests.

## 🚀 Features

### Employee Management
- Create, Read, Update, Delete (CRUD) operations
- Filter by department and employment status
- Email uniqueness validation
- Department association tracking

### Department Management
- Full CRUD operations
- Department statistics and metrics
- Manager assignment
- Employee count tracking

### Leave Management
- Submit leave requests
- Approve/reject leave requests
- Multiple leave types (sick, vacation, personal, unpaid, maternity, paternity)
- Overlap detection
- Employee leave summary

## 📋 Prerequisites

- Python 3.11 or higher
- Docker (optional, for containerized deployment)
- AWS CLI (for EC2 deployment)

## 🛠️ Installation & Setup

### Local Development Setup

1. **Clone the repository**
   ```bash
   cd HRMS
   ```

2. **Create a virtual environment**
   ```bash
   python -m venv venv
   
   # On Windows
   venv\Scripts\activate
   
   # On Linux/Mac
   source venv/bin/activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Run the application**
   ```bash
   uvicorn main:app --reload
   ```
   
   Or using Python directly:
   ```bash
   python main.py
   ```

5. **Access the API**
   - API Base URL: `http://localhost:8000`
   - Interactive API Documentation (Swagger): `http://localhost:8000/docs`
   - Alternative Documentation (ReDoc): `http://localhost:8000/redoc`

## 🐳 Docker Deployment

### Build Docker Image

```bash
docker build -t hrms-api:latest .
```

### Run Docker Container

```bash
docker run -d \
  --name hrms-api \
  -p 8000:8000 \
  hrms-api:latest
```

### Verify Container is Running

```bash
docker ps
docker logs hrms-api
```

### Stop and Remove Container

```bash
docker stop hrms-api
docker rm hrms-api
```

## ☁️ AWS EC2 Deployment with Docker

### Step 1: Launch EC2 Instance

1. Log in to AWS Console
2. Navigate to EC2 Dashboard
3. Click "Launch Instance"
4. Configure instance:
   - **Name**: hrms-api-server
   - **AMI**: Amazon Linux 2023 or Ubuntu 22.04 LTS
   - **Instance Type**: t2.micro (free tier eligible) or t2.small
   - **Key Pair**: Create or select existing key pair
   - **Security Group**: Configure inbound rules:
     - SSH (Port 22) - Your IP
     - Custom TCP (Port 8000) - 0.0.0.0/0 (or specific IPs)
   - **Storage**: 8-20 GB

### Step 2: Connect to EC2 Instance

```bash
# Make key file read-only
chmod 400 your-key.pem

# Connect via SSH
ssh -i "your-key.pem" ec2-user@your-ec2-public-dns
```

### Step 3: Install Docker on EC2

**For Amazon Linux 2023:**
```bash
sudo yum update -y
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
```

**For Ubuntu:**
```bash
sudo apt update
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu
```

Log out and log back in for group changes to take effect.

### Step 4: Transfer Application to EC2

**Option A: Using Git**
```bash
# Install git if not available
sudo yum install git -y  # Amazon Linux
sudo apt install git -y  # Ubuntu

# Clone your repository
git clone https://github.com/your-username/hrms-api.git
cd hrms-api
```

**Option B: Using SCP**
```bash
# From your local machine
scp -i "your-key.pem" -r ./HRMS ec2-user@your-ec2-public-dns:~/
```

### Step 5: Build and Run Docker Container on EC2

```bash
# Navigate to application directory
cd HRMS

# Build Docker image
docker build -t hrms-api:latest .

# Run container
docker run -d \
  --name hrms-api \
  --restart unless-stopped \
  -p 8000:8000 \
  hrms-api:latest

# Verify container is running
docker ps
docker logs hrms-api
```

### Step 6: Access the Application

Your API is now accessible at:
- **API Base**: `http://your-ec2-public-dns:8000`
- **Swagger Docs**: `http://your-ec2-public-dns:8000/docs`
- **ReDoc**: `http://your-ec2-public-dns:8000/redoc`

### Step 7: (Optional) Set up NGINX as Reverse Proxy

```bash
# Install NGINX
sudo yum install nginx -y  # Amazon Linux
sudo apt install nginx -y  # Ubuntu

# Configure NGINX
sudo nano /etc/nginx/conf.d/hrms-api.conf
```

Add the following configuration:
```nginx
server {
    listen 80;
    server_name your-domain.com;  # Or use EC2 public DNS

    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```bash
# Start NGINX
sudo systemctl start nginx
sudo systemctl enable nginx

# Update Security Group to allow HTTP (port 80)
```

## 📚 API Endpoints

### Employees
- `GET /api/v1/employees` - List all employees (with filters)
- `GET /api/v1/employees/{employee_id}` - Get employee by ID
- `POST /api/v1/employees` - Create new employee
- `PUT /api/v1/employees/{employee_id}` - Update employee
- `DELETE /api/v1/employees/{employee_id}` - Delete employee
- `GET /api/v1/employees/department/{department_id}/employees` - Get employees by department

### Departments
- `GET /api/v1/departments` - List all departments
- `GET /api/v1/departments/{department_id}` - Get department by ID
- `POST /api/v1/departments` - Create new department
- `PUT /api/v1/departments/{department_id}` - Update department
- `DELETE /api/v1/departments/{department_id}` - Delete department
- `GET /api/v1/departments/{department_id}/stats` - Get department statistics

### Leave Requests
- `GET /api/v1/leaves` - List all leave requests (with filters)
- `GET /api/v1/leaves/{leave_id}` - Get leave request by ID
- `POST /api/v1/leaves` - Create new leave request
- `PUT /api/v1/leaves/{leave_id}` - Update leave request
- `DELETE /api/v1/leaves/{leave_id}` - Cancel leave request
- `POST /api/v1/leaves/{leave_id}/approve` - Approve/reject leave request
- `GET /api/v1/leaves/employee/{employee_id}/summary` - Get employee leave summary

## 🧪 Testing the API

### Using Swagger UI
Navigate to `http://localhost:8000/docs` and use the interactive interface.

### Using curl

**Create an Employee:**
```bash
curl -X POST "http://localhost:8000/api/v1/employees" \
  -H "Content-Type: application/json" \
  -d '{
    "first_name": "Alice",
    "last_name": "Johnson",
    "email": "alice.johnson@company.com",
    "phone": "+12345678906",
    "department_id": 1,
    "position": "Senior Developer",
    "hire_date": "2024-01-15",
    "salary": 90000.00,
    "status": "active"
  }'
```

**Get All Employees:**
```bash
curl "http://localhost:8000/api/v1/employees"
```

**Submit Leave Request:**
```bash
curl -X POST "http://localhost:8000/api/v1/leaves" \
  -H "Content-Type: application/json" \
  -d '{
    "employee_id": 1,
    "leave_type": "vacation",
    "start_date": "2024-12-20",
    "end_date": "2024-12-31",
    "reason": "Holiday vacation"
  }'
```

## 🏗️ Project Structure

```
HRMS/
├── main.py                 # FastAPI application entry point
├── database.py             # Mock database with sample data
├── requirements.txt        # Python dependencies
├── Dockerfile             # Docker configuration
├── .dockerignore          # Docker ignore patterns
├── README.md              # This file
├── models/
│   ├── __init__.py
│   └── schemas.py         # Pydantic models
└── routers/
    ├── __init__.py
    ├── employees.py       # Employee endpoints
    ├── departments.py     # Department endpoints
    └── leaves.py          # Leave management endpoints
```

## 🔒 Security Considerations

- Change default credentials if implementing authentication
- Use HTTPS in production (configure SSL/TLS)
- Implement proper authentication and authorization
- Use environment variables for sensitive data
- Enable CORS only for trusted domains
- Implement rate limiting
- Use AWS security groups to restrict access

## 🚦 Health Check

The API includes a health check endpoint:
```bash
curl http://localhost:8000/health
```

## 📝 Environment Variables

You can customize the application using environment variables:
- `PORT`: Application port (default: 8000)
- `HOST`: Application host (default: 0.0.0.0)

## 🐛 Troubleshooting

### Port Already in Use
```bash
# Find process using port 8000
lsof -i :8000  # Linux/Mac
netstat -ano | findstr :8000  # Windows

# Kill the process or use a different port
uvicorn main:app --port 8001
```

### Docker Container Won't Start
```bash
# Check logs
docker logs hrms-api

# Check if port is available
docker ps -a
```

### Cannot Connect to EC2 Instance
- Verify Security Group allows inbound traffic on port 8000
- Check EC2 instance is running
- Verify public DNS/IP address is correct
- Ensure Docker container is running: `docker ps`

## 📄 License

This is a sample project for educational purposes.

## 👥 Support

For issues and questions, please refer to the API documentation at `/docs`.

---

**Built with FastAPI** 🚀