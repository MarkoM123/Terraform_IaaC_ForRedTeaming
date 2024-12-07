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

I use a socat to simply redirect all incoming traffic on port 80 and 443 to the main HTTP C2 server running Cobalt Strike team server:

![image](https://github.com/user-attachments/assets/34d2b98b-4729-414c-8bea-1aadccbe79cd)

<h2> Testing C2 and C2 redirector </h2>
It's easy to test if your C2 and its redirectors work as expected.

Note below - a couple of FQDNs that were printed out by Terraform when outputs.tf file was executed: static.redteam.me and ads.redteam.me both pointing to 159.203.122.243 - this is the C2 redirector IP - any traffic on port 80 and 443 will be redirected to the main C2 server, which is hosted on 68.183.150.191 as shown in the second image below:
![image](https://github.com/user-attachments/assets/fecd26b3-5fbd-4452-bf1d-b9014077240d)

![image](https://github.com/user-attachments/assets/69a6b284-0799-4ded-9995-263496ee45fd)

The steps are as follows:

1.Cobalt Strike is launched and connected to the main C2 server hosted on 68.183.150.191 - it can be reached via css.ired.team

2.a new listener on port 443 is created on the C2 host 68.183.150.191

3.beacon hostsname are set to two subdomains on the C2 redirector - static.redteam.me and ads.redteam.me

4.stageless beacon is generated and executed on the target system via SMB

5.beacon calls back to *.redteam.me which redirects traffic to the C2 teamserver on 68.183.150.191 and we see a CS session popup:

Below is a screengrab of the tcpdump on C2 server which shows that the redirector IP (organge, 159.203.122.243) has initiated the connection to the C2 (blue, 68.183.150.191):

![image](https://github.com/user-attachments/assets/5f57c6f3-2470-41e2-83b4-81f954e08c85)

<h2>Phishing</h2>










