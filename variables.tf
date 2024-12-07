
variable "ssh_private_key_path" {
  description = "The path to the private SSH key file"
  type        = string
  default     = "C:/Users/Win10/.ssh/id_rsa" # Putanja do privatnog ključa
}
variable "operator_ip" {
  description = "The IP address of the operator"
  type        = string
  #default     = "192.168.1.100"  # Primer IP adrese, promeni prema stvarnoj vrednosti
}
# Domain name for the redirector server
variable "domain_rdir" {
  description = "The domain for the redirector server"
  type        = string
  default     = "example-rdir.com" # Postavi na svoj domen
}
# Domain name for the C2 server
variable "domain_c2" {
  description = "The domain for the C2 server"
  type        = string
  default     = "example-c2.com" # Postavi na svoj domen
}
# Subdomains for the C2 server
variable "sub1" {
  description = "Subdomain 1 for the C2 server"
  type        = string
  default     = "sub1"
}

variable "sub2" {
  description = "Subdomain 2 for the C2 server"
  type        = string
  default     = "sub2"
}

variable "sub3" {
  description = "Subdomain 3 for the C2 server"
  type        = string
  default     = "sub3"
}

variable "sub4" {
  description = "Subdomain 4 for the C2 server"
  type        = string
  default     = "sub4"
}

# Subdomains for the phishing server
variable "sub5" {
  description = "Subdomain 5 for the Phishing server"
  type        = string
  default     = "sub5"
}

variable "sub6" {
  description = "Subdomain 6 for the Phishing server"
  type        = string
  default     = "sub6"
}