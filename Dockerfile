# Use a base image with the desired OS (e.g., Ubuntu, Debian, etc.)
FROM ubuntu:latest

# Install SSH server
RUN apt-get update
RUN apt-get install -y openssh-server ca-certificates curl gnupg lsb-release sudo

# Mettre à jour le gestionnaire de paquets et installer sshpass
RUN apt-get update && \
    apt-get install -y sshpass && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create an SSH user
RUN useradd -rm -d /home/test -s /bin/bash -g root -G sudo -u 1001 test
# Set the SSH user's password (replace "password" with your desired password)
RUN echo 'test:test' | chpasswd

# Install Ansible
RUN apt-get update 
RUN apt-get install -y vim python3 python3-pip git libffi-dev libssl-dev supervisor
RUN apt-get install -y ansible

# Install ddependencies for Terraform.
RUN apt update \
    && apt install -y wget \
    && apt install -y unzip \
    && apt install -y openssh-client

# Download the latest version of Terraform from the official website
RUN wget https://releases.hashicorp.com/terraform/0.15.4/terraform_0.15.4_linux_amd64.zip

# Unzip the downloaded file:
RUN unzip terraform_0.15.4_linux_amd64.zip

# Move the terraform binary to a directory in your system's PATH.
RUN mv terraform /usr/local/bin/

# Verify that Terraform is installed by checking its version:
RUN terraform version

# Allow SSH access
RUN mkdir /var/run/sshd
# Expose the SSH port
EXPOSE 22
# Expose other ports
#EXPOSE 8080/tcp
#EXPOSE 9000/tcp
#EXPOSE 50000/tcp
#EXPOSE 5432/tcp
#EXPOSE 5000/tcp

# Start SSH server on container startup
CMD ["/usr/sbin/sshd", "-D"]

