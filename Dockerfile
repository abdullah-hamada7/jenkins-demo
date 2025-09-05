FROM jenkins/inbound-agent:latest

USER root

RUN apt-get update && \
    apt-get install -y python3 python3-pip python3-venv git docker.io && \
    rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /opt/venv

RUN /opt/venv/bin/pip install --upgrade pip

RUN chown -R jenkins:jenkins /opt/venv

ENV PATH="/opt/venv/bin:$PATH"

USER jenkins
