echo "Beginning installation"
sudo apt update
sudo apt install apache2 -y
sudo systemctl enable apache2
sudo a2enmod ssl
sudo chmod -R 755 PSlabaudition/
sudo chmod -R 755 /var/www
sudo chmod -R 755 /etc/apache2/
sudo mv PSlabaudition/index.html /var/www/html/
sudo mkdir /var/www/html/img
sudo mv PSlabaudition/web01.jpg /var/www/img/
sudo systemctl restart apache2
echo "Installation complete!"
echo "You're next step is to complete this lab and then approve Craig Stansbury for Security Labs"
