# Tyr Server IaC Project #

## Overview ##

This project will cover the creation of a ready-to-go webserver through the use of two IaC (Infrastructure as Code) technologies, Terraform and Ansible. These technologies should be installed on your local machine, and some familiarity with their useage is suggested.  

The goal here is to use a few commands on a local machine to create a new cloud server on Digital Ocean, provision that remote machine as a webserver, then deploy a build of the website through a CI/CD pipeline from GitHub.

---

## Keys to the Kingdom ##

In order for the project to work, one must first establish an SSH keypair and drop the public key in DO by going to the `Settings` -> `Security` tab and adding a new key. The SSH key fingerprint should be saved and will be included in the `terraform.tfvars` file in the form of:

```hcl
    ssh_key_fingerprint = "[fingerprint_from_do]"
```

Similarly, a PAT needs to be created on DO for connecting to the API. This can be found on the `API` -> `Tokens` tab. Make sure the scope is set to Read and Write, and be sure to copy the token once it is created, because you'll never get to see it again. Once copied, place the token in the `terraform.tfvars` file like so:

```hcl
    do_token = "[personal_access_token]"
```

Now that there is an access mechanism, you need to specify the specific IP addresses that you want to have access the machine. This is done by adding the specific IP addresses to the `terraform.tfvars` file. In this case, there are two: one is the IP address of your home network, and the other belongs to a static IP address provided by a VPN provider (for those times when you're working remotely outside of your home network). If you don't have a static IP address from a VPN provider, just use the one associated with your home network:

```hcl
    inbound_home_ip: "[home_ip4_address]"
    inbound_static_ip: "[static_ip4_address]"
```

Note that the `terraform.tfvars` file does not exist in the repository. This file is protected from version control with `.gitignore`. This file needs to be created in the project's root directory, and the above values should be placed inside it.

---

## Initializing and Launching the Project ##

Once the project is cloned to your local machine. Navigate a terminal to the `terraform` directory and initialize the terraform project:

```shell
    terraform init
```

If terraform has been successfully intialized, check the plan by running:

```shell
    terraform plan
```

If this looks okay, you can spin up the cloud machines any time by applying the plan:

```shell
    terraform apply
```

You'll have to type `yes` in order to confirm the process. It'll take a little time to create the cloud machine, attach the volume, and build up the firewall. But once it's done, the newly-created machine's IP address should be listed in the terminal that ran the terraform. If all goes as expected, your VM is ready for you to ssh into and/or run the ansible process for initial server provisioning.

---

## Machine Details ##

This process creates a VM on Digital Ocean with the following properties:

- **Image:** Debian 11 x64
- **Size:** 1 Intel vCPU, 2 GB Memory
- **Storage:** 50 GB disk
- **Region:** NYC1
- **Firewall:** Inbound: SSH, HTTP; Outbound: ICPM, All TCP, All UDP

---

## Destroying the Machine ##

To destroy and tear down the infrastructure. Simply use the following command in the terraform directory:

```shell
    terraform destroy
```
