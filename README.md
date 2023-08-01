# Tyr Server IaC Project #

## Overview ##

This project will cover the creation of a ready-to-go webserver through the use of two IaC (Infrastructure as Code) technologies, Terraform and Ansible. These technologies should be installed on your local machine, and some familiarity with their useage is suggested.  

The goal here is to use a few commands on a local machine to create a new cloud server on DigitalOcean, provision that remote machine as a webserver, copy over a React project from GitHub, then deploy a build of the website via Nginx.

---

## DigitalOcean ##

[DigitalOcean](https://www.digitalocean.com) is a cloud hosting provider that offers cloud computing services and Infrastructure as a Service (IaaS). It is a developer-friendly platform that provides services such as compute, storage, data, and network services. This project assumes you have an account set up with DigitalOcean.

---

## Terraform | Keys to the Kingdom ##

In order for the project to work, one must first establish an SSH keypair and drop the public key in Digital Ocean by going to the `Settings` -> `Security` tab and adding a new key. The SSH key fingerprint should be saved and will be included in the `terraform.tfvars` file in the form of:

```hcl
    ssh_key_fingerprint = "[fingerprint_from_do]"
```

Similarly, a PAT needs to be created on DigitalOcean for connecting to the API. This can be found on the `API` -> `Tokens` tab. Make sure the scope is set to Read and Write, and be sure to copy the token once it is created, because you'll never get to see it again. Once copied, place the token in the `terraform.tfvars` file like so:

```hcl
    do_token = "[personal_access_token]"
```

Now that there is an access mechanism, you need to specify the specific IP addresses that you want to have access the machine. This is done by adding the specific IP addresses to the `terraform.tfvars` file. In this case, there are two: one is the IP address of your home network, and the other belongs to a static IP address provided by a VPN provider (for those times when you're working remotely outside of your home network). If you don't have a static IP address from a VPN provider, just use the one associated with your home network:

```hcl
    inbound_home_ip: "[home_ip4_address]"
    inbound_static_ip: "[static_ip4_address]"
```

Note that the `terraform.tfvars` file does not exist in the repository. This file is protected from version control with `.gitignore`. This file needs to be created in the project's root directory, and the above values should be placed inside it. A sample template for this file is included in the repo, as `terraform.tfvars.template`. Simply substiute your own values for the variables, then remove the `.template` extension from the file name.

---

## Terraform | Initializing and Launching the Project ##

Once the project is cloned to your local machine and the steps above have been followed, navigate a terminal to the `terraform` directory and initialize the terraform project:

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

You'll have to type `yes` in order to confirm the process. It'll take a little time to create the cloud machine and build up the firewall. But once it's done, the newly-created machine's IP address should be listed in the terminal that ran the terraform as `public_ip_server`. If all goes as expected, your VM is ready for you to ssh into and/or run the ansible process for initial server provisioning.

---

## Terraform | Machine Details ##

This process creates a VM on Digital Ocean with the following properties:

- **Image:** Debian 11 x64
- **Size:** 1 Intel vCPU, 2 GB Memory
- **Storage:** 50 GB disk
- **Region:** NYC1
- **Firewall:** Inbound: SSH, HTTP, HTTPS; Outbound: HTTP, HTTPS, DNS

---

## Terraform | Destroying the Machine ##

To destroy and tear down the infrastructure. Simply use the following command in the terraform directory:

```shell
    terraform destroy
```

---

## Ansible | Setting up the Inventory ##

Before you can run the playbook, you must first set up the `inventory` file so that Ansible knows on which host to operate. The inventory file is protected by version control, so it is not checked into the repo. This INI file should be named `inventory`, exist in the `ansible` directory, and contain the following code:

```
[webservers]
tyr ansible_host=<public_ip_server> ansible_connection=ssh ansible_user=root 
```

The value, `<public_ip_server>` is the IP address of the DigitalOcean droplet created by Terraform above. Once the inventory is in place, you can run the following command to make sure it aligns with what is expected:

```shell
ansible-inventory -i inventory --list
```

The output should look like the following:

```shell
{
    "_meta": {
        "hostvars": {
            "tyr": {
                "ansible_connection": "ssh",
                "ansible_host": "<public_ip_server>",
                "ansible_user": "root"
            }
        }
    },
    "all": {
        "children": [
            "ungrouped",
            "webservers"
        ]
    },
    "webservers": {
        "hosts": [
            "tyr"
        ]
    }
}
```

---

## Ansible | Setting up the External Variables File

The Ansible playbook relies on some variables that are protected from version control via the `.gitignore` file. This file is named `external_vars.yml` and contains the following code:

```yaml
---
app_root: [name_of_project_root_directory]
react_repo: [url_for_react_project_repo]
```

A sample template file named `external_vars.yml.template` is included in the repo. Simply replace the appropriate variables and remove the `.template` extension from the file name.

---

## Ansible | Running the Playbook ##

Provisioning the server is accomplished by running the following command from within the `ansible` directory:

```shell
ansible-playbook -i inventory playbook.yml
```

This provisioning runs the following tasks on the remote machine:

- Set up passwordless sudo
- Create a new user with sudo privileges
- Copy over local public ssh key for remote access
- Disable password authentication for root
- Install git
- Checkout a React project repo from GitHub
- Install nodejs
- Install npm
- Install the npm packages for the React project
- Create a production build of the React project
- Update apt cache and install Nginx
- Install rsync
- Copy build files to the webserver's document root
- Apply the Nginx template
- Enable the new site
- Restart Nginx service

`NOTE:` You may have to wait a minute for the server to be fully up and running after running the Terraform build process above before running this play.

---

## Checking out the Website ##

Now you should be able to point your browser to the IP address of your DigitalOcean server to see the deployed website!

