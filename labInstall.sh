echo "Beginning installation"
sudo ufw allow OpenSSH
sudo ufw enable
sudo apt update
sudo apt install apache2
sudo ufw allow 'Apache'
sudo systemctl enable apache2
echo "Installation complete!"
echo "You're next step is to approve Craig Stansbury for Security Labs"