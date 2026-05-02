echo "Fixing Jenkins Keys for Ubuntu 24.04..."
sudo mkdir -p /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

echo "Installing Jenkins..."
sudo apt-get update -y
sudo apt-get install jenkins -y

echo "Configuring Docker permissions..."
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins

echo "====================================="
echo "Setup Complete! Here is your Jenkins Password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo "====================================="
