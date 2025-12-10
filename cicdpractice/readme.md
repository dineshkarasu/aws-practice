# Hello World Application

A simple HTML, CSS, and JavaScript application containerized with Docker.

## Project Structure

```
CICD/
├── Dockerfile
├── .dockerignore
└── src/
    ├── index.html
    ├── css/
    │   └── styles.css
    └── js/
        └── script.js
```

## Building the Docker Image

```bash
docker build -t hello-world-app .
```

## Running Locally

```bash
docker run -d -p 80:80 hello-world-app
```

Access the application at `http://localhost`

## Running on EC2 Instance

### Prerequisites
- EC2 instance with Docker installed
- Security group allowing inbound traffic on port 80

### Deployment Steps

1. **SSH into your EC2 instance:**
   ```bash
   ssh -i your-key.pem ec2-user@your-ec2-ip
   ```

2. **Install Docker (if not already installed):**
   ```bash
   sudo yum update -y
   sudo yum install docker -y
   sudo service docker start
   sudo usermod -a -G docker ec2-user
   ```

3. **Transfer files to EC2 or clone from repository**

4. **Build the Docker image:**
   ```bash
   docker build -t hello-world-app .
   ```

5. **Run the container:**
   ```bash
   docker run -d -p 80:80 --name hello-world hello-world-app
   ```

6. **Access your application:**
   - Navigate to `http://your-ec2-public-ip` in your browser

## Docker Commands

- **Stop container:** `docker stop hello-world`
- **Start container:** `docker start hello-world`
- **View logs:** `docker logs hello-world`
- **Remove container:** `docker rm hello-world`
- **Remove image:** `docker rmi hello-world-app`

## Security Group Configuration

Ensure your EC2 security group has the following inbound rule:
- Type: HTTP
- Protocol: TCP
- Port: 80
- Source: 0.0.0.0/0 (or restrict to specific IPs)
