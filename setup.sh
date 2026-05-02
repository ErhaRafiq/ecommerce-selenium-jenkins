echo "Installing Java..."
sudo apt update -y
sudo apt install openjdk-17-jre -y

echo "Installing Jenkins..."
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update -y
sudo apt-get install jenkins -y

echo "Installing Docker..."
sudo apt install docker.io -y
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
sudo systemctl restart docker

echo "====================================="
echo "Setup Complete! Here is your Jenkins Password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo "====================================="
