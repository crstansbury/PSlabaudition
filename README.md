Welcome to Craig Stansbury's Security lab audition. For this lab, you will need a clean install of Ubuntu 20.04, as well as a secondary device that is on the same network of Ubuntu 20.04. The secondary device needs to have the ability to SSH, as well as open a web browser.

Please note that throughout this lab experience, you may see a configuration contained in brackets, such as \<yourServersIP>. I'll ask you to replace that with the actual information that I want to use. Please make sure to replace the brackets and information inside the brackets with your actual configuration

For example, you would replace \<yourServersIP> with the actual IP address of your server. So if you are asked to enter a command such as `sudo nano /etc/apache2/sites-available/<yourServersIP>.conf` and the IP address of your server is 172.20.1.211, you would enter:
`sudo nano /etc/apache2/sites-available/172.20.1.211.conf`

Please also notice that I have removed the brackets "<>" and replaced it with the IP address of my server. 

The goal of this lab is to secure Globomantics' web server and make sure that all traffic is encrypted. This will prevent hackers to sniff the traffic and obtain sensitive data! You will do this by enabling the firewall, creating a certificate to encrypt the web traffic, and finally, forcing all web traffic to use https, as opposed to http. But first, you need the source files:

Step 1: Clone this repo to your Ubuntu server by entering the following command:

`git clone https://github.com/crstansbury/PSlabaudition`

Step 2: Run the install script.

Step 2.1: Enable your user account access to the labInstal.sh script:  
`sudo chmod +x PSlabaudition/labInstall.sh`

Step 2.2: Run the install script:   
`PSlabaudition/labInstall.sh`

Step 3: By default, there is no firewall running. This leaves your server open to various attacks. You need to enable the firewall, but before you do so, you need to allow SSH connections to your computer. Otherwise, if you enable the firewall without allowing SSH connections, your SSH connection may be dropped. Addtionally, this server is also hosting a web server, so you need to have the firewall also allow Apache, which is the webserver that we are using. 

Step 3.1: Allow ssh connections to your server by entering the following command:  
`sudo ufw allow OpenSSH`

Step 3.2: Allow the Apache webserver to run by entering the following command:  
`sudo ufw allow 'Apache'`

Step 3.3: Enable the firewall by entering the command (you may be prompted to enter Y).  
`sudo ufw enable`

Step 4: Browser traffic over without SSL/TLS encryption is in plain text! This means that a hacker could sniff the traffic and gain unauthorized information. In this step, we will generate a self signed certificate, create a file to tell the server to use this certificate to encrypt traffic, and then redirect any unencrypted traffic to use this new certificate!

Step 4.1 In this step, we will generate a certificate to be used by our server.

Step 4.1.1 Generate a self signed certificate:  
`sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt`

Step 4.1.2 : Fill out the information. It may look something like this:  

	Country Name (2 letter code) [XX]:<InsertACountry:US>  
	State or Province Name (full name) []:<InsertAState:Nebraska>  
	Locality Name (eg, city) [Default City]:<InsertACity:Omaha>  
	Organization Name (eg, company) [Default Company Ltd]:<InsertFictiousCompany:Globomantics>  
	Organizational Unit Name (eg, section) []:<InsertDepartment:IT>  
	Common Name (eg, your name or your server's hostname) []:<insertComputersIP:172.20.1.211>  
	Email Address []:<insertAnEmail:craig@globomantics.com>  

step 4.2 Now that our certificate is created, we need to create a .conf file to tell the server to use this certificate.

step 4.2.1 Create a conf file to reference the new self signed cert you just created. Replace \<yourServersIP> with the IP address of your server:  
`sudo nano /etc/apache2/sites-available/<yourServersIP>.conf`

step 4.2.2 Copy the below contents into your new .conf file. Be sure to change the server name \<yourServersIP> to the IP address of your server:  

	<VirtualHost *:443>  
	   ServerName <yourServersIP>  
	   DocumentRoot /var/www/html  
	   SSLEngine on  
	   SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt  
	   SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key  
	</VirtualHost>  

Step 4.2.3 Save the file
Press `ctrl + x` and type `Y` when prompted, and hit `enter` to save over the file

Step 4.3 Now we need to enable the .conf file that we just created. 

Step 4.3.1 Enter the below command and be sure to change \<yourServersIP> to the IP address of your server:  
`sudo a2ensite <yourServersIP>.conf`

Step 4.3.2 Now we will have the server to recognize your servers IP address as it's name. To do that, run the below command, and then enter `ServerName <yourServersIP>` on a new line in the file. This can be anywhere, I put it about half way down, after `#ServerRoot '/etc/apache2' `  

`sudo nano /etc/apache2/apache2.conf`

Step 4.3.2.1 copy `ServerName <yourServersIP>` on a new line in the file:  
example: `ServerName 172.20.1.211`

Step 4.3.2.2 save the file:  
Press `ctrl + x` and type `Y` when prompted, and hit `enter` to save over the file  

Step 4.3.3 Now we are going to test that the previous command worked. The output should say "Syntax OK"  
`sudo apache2ctl configtest`

Step 4.3.4 Now we need to reload the apache2 service for the previous changes to take effect:  
`sudo systemctl reload apache2`

Step 4.3.5 Since we have already enabled the firewall, we need to tell the server to allow all of Apache:  
`sudo ufw allow "Apache Full"`

Step 4.3.6 Now we will test and make sure that we can navigate to this site over https. You may receive an error that the traffic is not protected, asking if you want to proceed. This is to be expected becuase the certificate that we are using was self-generated, and not natively trusted by your browser. Please click "advanced" and then "accept the risk and continue" (The exact syntax of this may differ depending on your browser)
To do that, open up a browser on your other machine and navigate to the following:
`https://<yourServersIP>`

Step 5 The last step that we need to do is to have the server redirect all unsecure http traffic to secure https traffic. We will do this by modifying the apache config file

Step 5.1 Open the .conf file
sudo nano /etc/apache2/apache2.conf

Step 5.2 We will create a virtual host over port 80, and tell it to redirect to https. Copy the following into your .conf file, after "ServerName <yourServersIP>" that you configured in step 4.3.2.1
<Virtualhost *:80>
	ServerName <yourServersIP>
	RedirectMatch permanent ^(.*)$ https://<yourServersIP>$1
</Virtualhost>

Step 5.2.1 Save your work
Press "ctrl + x" and type "Y" when prompted, and hit enter to save over the file

Step 5.3 Now we are going to test that the previous command worked. The output should say "Syntax OK"
sudo apachectl configtest

Step 5.4 Lastly, we will restart apache one more time to make sure all of our changes are active
sudo systemctl reload apache2

Step 5.5 From your other computer, navigate to your server over port 80, and see if you've been redirected to https
http://<yourServersIP>

Congratulations! You've just completed Craig's Security Lab Demo! If you would like to dive further, please approve Craig Stansbury to do Security labs so he can take some work off your plate!

