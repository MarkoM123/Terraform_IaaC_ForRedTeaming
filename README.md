This project provides detail instraction how to use Terraform for Red Team operation - Automated operations-Deploying **Infrastructure as a Code**.

<h1>Infrastructure Overview</h1>

Below is a high level diagram showing the infrastructure that I built for this lab - it can be and usually is much more built out, but the principle remains the same - redirectors are placed in front of each server to make the infrastructure more resilient to discovery that enables operators to quickly replace the burned servers with new ones:
![image](https://github.com/user-attachments/assets/38e75f38-e4e0-4efa-9f0c-110dc9393378)

This project involves the deployment of six servers on AWS, each with distinct roles:

1.**Phishing Server**: Hosts the phishing HTML page to simulate email or webpage attacks in a controlled environment. It's a key part of the offensive infrastructure used to lure users into revealing sensitive information.

2.**Payload Server**: Stores and delivers malicious payloads to targets (e.g., executable files or scripts) when users interact with phishing links. It ensures reliable delivery of the payload.

3.**C2 (Command and Control)** Server: Acts as the central point for managing compromised machines. It receives data from infected systems and sends commands to control their behavior.

4.**SMTP Redirector**: A proxy that relays phishing emails while hiding the actual origin server, ensuring the phishing server remains undiscovered.

5.**Payload Redirector**: Intercepts traffic destined for the payload server, ensuring that the payload server's location is obscured from detection.

6.**C2 Redirector**: A proxy server that filters and forwards C2 communication, providing an additional layer of security and making the C2 server harder to track.
Each redirector acts as a disposable proxy to protect the core infrastructure (Phishing, Payload, and C2 servers), ensuring resiliency and operational continuity.

<h1> Configuring Infrastructure </h1>
<h2>Service Providers</h2>
For this project, I primarily used AWS (Amazon Web Services) as the cloud service provider to host and manage the infrastructure. AWS was selected due to its scalability, reliability, and wide range of services. I utilized Amazon EC2 instances to host six servers: three redirectors (SMTP redirector, Payload redirector, and C2 redirector) and three primary servers (Phishing server, Payload server, and C2 server). Each server was assigned a specific role in the infrastructure to ensure operational separation and security.

To manage the infrastructure, I used Terraform, an Infrastructure-as-Code (IaC) tool, which allowed me to automate the provisioning of these servers. AWS's IAM (Identity and Access Management) was employed to securely control access to the instances and services. Additionally, Amazon S3 was utilized to store static files like payloads or log data, providing a secure and cost-effective storage solution.

The combination of Terraform and AWS services enabled efficient deployment and configuration of the project's environment, ensuring that the infrastructure could be quickly adjusted or rebuilt if necessary.

My red team infrastructure is defined by terraform state configuration files that are currently organized in the following way:

<h2>Variables</h2>
Variables.tf stores things like API tokens, domain names for redirectors and c2s, operator IPs that are used in firewall rules (i.e only allow incoming connections to team server or GoPhish from an operator owned IP):

![image](https://github.com/user-attachments/assets/1ecbfba0-1ce8-498a-a5f7-476b0f170b89)


<h2>C2</h2>

For this lab, I chose Metasploit as my C2 server.

This Terraform provisioner block uses remote-exec to configure a machine after it's created. It performs the following actions:

![image](https://github.com/user-attachments/assets/45847799-7a74-4285-92fb-0396f1e34ad5)
1.Updates the package list and installs zip and default-jre.

2.Downloads the latest version of the Metasploit Framework as a ZIP file into /opt.

3.Extracts the ZIP and installs required Ruby gems for Metasploit.

4.Sets up a cron job to start Metasploit with a resource script (msfvenom.rc) at every reboot.

5.Reboots the machine to apply changes.

<h2>C2 redirector</h2>
This script turns the instance into a C2 redirector. The Nginx reverse proxy hides the actual Command and Control (C2) server by routing traffic through the redirector, adding a layer of operational security.

![image](https://github.com/user-attachments/assets/77c637f4-a2d1-44f0-b2c7-e94249cfc825)
Here's what it does step by step:

1.Update System Packages: The script starts by updating the package list using apt-get update.

2.Install Nginx: It installs the Nginx web server with the command apt-get install -y nginx.

3.Configure Proxy Pass: The script creates an Nginx configuration file in /etc/nginx/sites-enabled/default.The configuration sets up a basic reverse proxy.
It listens on port 80 and forwards incoming traffic to the backend server at http://10.0.2.1.

4.Restart Nginx: Finally, it restarts the Nginx service to apply the new configuration.

<h2>Phishing</h2>
My phishing server is running GoPhish framework.

![image](https://github.com/user-attachments/assets/64cbcd30-2725-41c1-a682-975333fd5981)

The GoPhish is set to listen on port 3333 which I expose to the internet, but only allow access for the operator using AWS security group:

![image](https://github.com/user-attachments/assets/0703878d-e47f-4b82-95aa-d7fd005e3a9a)

Again - var.operator-ip is set in variables.tf

<h2>Phishing redirector</h2>

This was the most time consuming piece to set up. It is a known fact that setting up SMTP servers usually is a huge pain. Automating the red team infrastructure is worth purely because of the fact that you will not ever need to rebuild the SMTP server from scratch once it gets burned during the engagement.

The pain for this piece originated from setting up the smtp relay, since there were a number of moving parts to it:

*setting up SPF records

*setting up DKIM

*setting up encryption

*configuring postfix as a relay

*sanitizing email headers to obfuscate the originating email server (the phishing server)

<h2>Payload redirector</h2>
Payload redirector server is built on apache2 mod_rewrite and proxy modules. Mod_rewrite module allows us to write fine-grained URL rewriting rules and proxy victim's HTTP requests to appropriate payloads as the operator deems appropriate.

.htaccess
Below is an .htaccess file that instructs apache, or to be precise mod_rewrite module, on when, where and how (i.e proxy or redirect) to rewrite incoming HTTP requests:

.htaccess

RewriteEngine On
RewriteCond %{HTTP_USER_AGENT} "android|blackberry|googlebot-mobile|iemobile|ipad|iphone|ipod|opera mobile|palmos|webos" [NC]
RewriteRule ^.*$ http://payloadURLForMobiles/login [P]
RewriteRule ^.*$ http://payloadURLForOtherClients/%{REQUEST_URI} [P]
Breakdown of the file:

Line 2 essentially says: hey, apache, if you see an incoming http request with a user agent that contains any of the words "android, blackberry, ..." etc, move to line 3

Line 3 instructs apache to proxy ([P]) the http request to http://payloadURLForMobiles/login. If condition in line 2 fails, move to line 4

If condition in line 2 fails, the http request gets proxied to http://payloadURLForOtherClients/%{REQUEST_URI} where REQUEST_URI is the part of the http request that was appended after the domain name - i.e someDomain.com/?thisIsTheRequestUri=true









