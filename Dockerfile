FROM mcr.microsoft.com/powershell:6.2.3-ubuntu-xenial

RUN apt-get update
RUN apt-get install curl -y
RUN apt-get install unzip -y

# Install rclone
RUN curl https://rclone.org/install.sh | bash

# Install AZ CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Main Script
COPY  ./azureToAwsSync.ps1 azureToAwsSync.ps1

# rclone config base
COPY ./rclone.conf /root/.config/rclone/rclone.conf

# Run upload
CMD [ "pwsh", "-c", "./azureToAwsSync.ps1" ]