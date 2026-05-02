echo "Forcing Jenkins Installation..."
echo "deb [trusted=yes] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

echo "Updating System..."
sudo apt-get update -y

echo "Installing Jenkins..."
sudo apt-get install jenkins -y

echo "Configuring Docker permissions..."
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins

echo "====================================="
echo "Setup Complete! Here is your Jenkins Password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo "====================================="
