# **Jenkins CI/CD with Docker and Python**

This repository contains a complete **Jenkins CI/CD pipeline** setup using **Docker Compose**, a **custom Jenkins inbound agent** with Python support, and a sample pipeline configured via a `Jenkinsfile`.

---

## **Project Overview**

This project sets up:

* A **Jenkins Controller** running in Docker.
* A **custom Jenkins Docker agent** with:

  * Python 3 + pip + venv preinstalled.
  * Git and Docker CLI support.
* Integration with **Docker-in-Docker** for building and deploying containers.
* A **declarative Jenkins pipeline** for:

  * Installing dependencies.
  * Running Python scripts.
  * Delivering the application.

---

## **📂 Project Structure**

```
jenkins-101/
├── ansible/                      # Ansible automation for Jenkins + Docker
│   ├── ansible.cfg              # Ansible configuration file
│   ├── group_vars/              # Global variables for Ansible roles
│   │   └── vars.yml             # Common variables (e.g., Docker Hub creds)
│   ├── inventory.ini            # Target hosts inventory
│   ├── playbook.yml             # Main Ansible playbook
│   └── roles/                   # Ansible roles
│       ├── agent/               # Role for Jenkins custom agent
│       │   └── tasks/
│       │       └── main.yml     # Build & push Docker agent image
│       ├── docker/              # Role for Docker installation
│       │   └── tasks/
│       │       └── main.yml     # Install & configure Docker
│       └── jenkins/             # Role for Jenkins deployment
│           └── tasks/
│               └── main.yml     # Run Jenkins via Docker Compose
│
├── compose.yml                  # Docker Compose file for Jenkins setup
├── Dockerfile                   # Custom Jenkins Docker agent image
├── helloworld.py                # Sample Python script
├── Jenkinsfile                  # Declarative Jenkins pipeline
├── Jenkinsfile.template         # Jenkinsfile template (to know the structure of the file and adjust it based on your settings)
├── myapp/                       # Python demo application
│   ├── hello.py                 # Sample Python app
│   └── requirements.txt         # Python dependencies
└── Vagrantfile                 # Optional Vagrant setup for local testing
```

---

## **Prerequisites**

Make sure you have the following installed:

* [Docker](https://docs.docker.com/get-docker/) ≥ 20.x
* [Docker Compose](https://docs.docker.com/compose/install/)
* A [Docker Hub](https://hub.docker.com/) account (for pushing/pulling custom agents)

---

## **1. Docker Compose Setup**

Create a `docker-compose.yml` file:

```yaml
version: '3.8'

services:
  jenkins:
    image: jenkins/jenkins:lts
    container_name: jenkins
    restart: unless-stopped
    user: root
    privileged: true
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - jenkins-data:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock

volumes:
  jenkins-data:
```

### **Start Jenkins**

```bash
docker compose up -d
```

### **Access Jenkins**

* URL: [http://localhost:8080](http://localhost:8080)
* Default username: `admin`
* Get initial password:

```bash
docker exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

---

## **2. Build Custom Jenkins Docker Agent**

Create a `Dockerfile` for the agent:

```dockerfile
FROM jenkins/inbound-agent:latest

USER root

# Install required tools
RUN apt-get update && \
    apt-get install -y python3 python3-pip python3-venv git docker.io && \
    rm -rf /var/lib/apt/lists/*

# Create Python virtual environment
RUN python3 -m venv /opt/venv

# Upgrade pip inside venv
RUN /opt/venv/bin/pip install --upgrade pip

# Fix permissions so Jenkins can install packages
RUN chown -R jenkins:jenkins /opt/venv

# Add venv to PATH
ENV PATH="/opt/venv/bin:$PATH"

USER jenkins
```

### **Build and Push Image**

```bash
docker build -t abdullahhamada7/jenkins-docker-agent:latest .
docker push abdullahhamada7/jenkins-docker-agent:latest
```

---

## **3. Configure Jenkins Docker Cloud**

1. Go to **Manage Jenkins → Nodes and Clouds → Configure Clouds**.
2. Add a new **Docker Cloud**:

   * Docker Host URI: `unix:///var/run/docker.sock`
   * Test connection → Should succeed.
3. Configure **Docker Agent Template**:

   * **Name:** `docker`
   * **Labels:** `docker`
   * **Docker Image:** `abdullahhamada7/jenkins-docker-agent:latest`
   * **Remote File System Root:** `/home/jenkins/agent`
   * Enable **Connect method**: `Attach Docker container`.

---
### **Start the VM and Deploy**

```bash
vagrant up
```

* Vagrant provisions the VM and automatically runs the Ansible playbook.

### **Access the Jenkins**

```bash
http://localhost:8080
```

### **Destroy the environment**

```bash
vagrant destroy -f
```

## **6. Run the Pipeline**

1. Create a new **Pipeline** in Jenkins.
2. Set the GitHub repository URL.
3. Start the pipeline — Jenkins will:

   * Spin up a Docker agent.
   * Install dependencies.
   * Run Python tests.
   * Deliver the app.
             