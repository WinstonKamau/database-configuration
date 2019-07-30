## Deploying Our Infrastructure.

To achieve our Chef setup we need to first setup infrastructure on the cloud. For this setup, we will be using [Google Cloud Platform](https://cloud.google.com). We shall setup the following:

- A chef infrastructure server which will require a virtual machine on Compute engine where it will be installed. We shall also expose it by providing it with an external IP Address. 
- Three Virtual Machines for which we shall install our PostgreSQL databases. Each shall also have its own external IP addresses.

To make our process of deploying our chef setup repeatable, less error prone and easy we need to automate this process. To automate it, we need a scripting language to enable us achieve infrastructure as code. To do this I chose **Terraform**. I value [terraform](https://www.terraform.io/) for its ease of use, its integration with many cloud environments, its high support; with new versions being released frequently, its quality of being free with good documentation.


### Setting up Google Cloud Platform for Our Infrastructure.

1. Create a storage bucket

First we need to start by creating a storage bucket. Terraform needs to store a file in this storage bucket, which it can use to continuously check in the current state and determine what the desired state will be, before building infrastructure on your platform. Instructions for creating a storage bucket can be found [here](https://cloud.google.com/storage/docs/creating-buckets). Once you are done take note of the name of the bucket that you just created as we shall use it later when running terraform commands

2. Reserve four static external IP addresses in their respective zones.

Steps for reserving this can be found [here](https://cloud.google.com/compute/docs/ip-addresses/reserve-static-external-ip-address#reserve_new_static). Note that when reserving any of the IP address, create it in a region where you would like to also create your VMs so that you may not have difficulty attaching it to an instance. This is as shown below, where the user intends to create the VM in the us-east1 region:
![IP address reservation Image](docs/images/regional-ip-address.png?raw=true)
Most instances are regional and if given a regional IP address in a different region from their own an error is raised when running the script.

At this step, we need to make a decision for each of our four instances: chef infrastructure server, master database server and two slave databases servers. We need to determine each of their zones. By determining their zones we can then determine the regions where we will create the IP addresses on. Below is a table that list the relationship between the instances, its zone variable and IP address variable. These two variables are provided in the first step of  [Running Terraform scripts](#running-terraform-scripts)

| Instance Name         | Zone Variable      | IP Address Variable  |
|-----------------------|--------------------|----------------------|
|chef-infra-server      |   chef_server_zone | chef_ip_address      |
|master-database-server |   chef_node_zone   |chef_node_ip_address  |
|slave-database-server-1|   chef_node_zone_2 |chef_node_ip_address_2|
|slave-database-server-2|   chef_node_zone_3 |chef_node_ip_address_3|

3. Enable APIs and services.

Instructions for enabling an API and Services can be found [here](https://cloud.google.com/endpoints/docs/openapi/enable-api).
Ensure that the Compute Engine API is enabled.

4. Setup the service account 

You may follow instructions on creating a service account as per this [link](https://cloud.google.com/iam/docs/creating-managing-service-accounts). The most critical part of the service account is the role that the account will be able to perform. Ensure that the service account has at lease admin capabilities of **Compute Admin**, **Compute Network Admin**, **Service Account User** and **Storage Object Admin**. Download the Service Account JSON key to your machine after giving the Service Account its roles.

Once you have gotten the key, change the name of the file [account.json.example](account-folder/account.json.example) to account.json. *This file is located under the account-folder directory*. Delete the contents in the file and paste your JSON key here.

5. Map a domain to your chef server

You need to have a domain for which you will use to connect online to your chef infra server. To do this you need to purchase your domain from a Domain Registrar Company. You then need to map your domain to point to the IPV4 address that you reserved for the chef infra server in step 2 above. This will require you to use the Type A option for creating your record.
The domain name you use here will be used as one of the environment variables for your next step.

6. Generate an SSH key.

Change directory into the chef-server-configuration directory and run the command below to generate ssh keys that will be used by chef to bootstrap your nodes.

```
bash create_ssh_key.sh
```

### Running Terraform scripts

1. Pass environment variables

Our deployment script requires some environment variables. Create a file called terraform.tfvars on the root of your repository. You can derive the structure of secrets needed using the [terrafrom.tfvars.example](terraform.tfvars.example) file on the root of your repository. Replace each of the secret with its respective value. Note that `hostname` was determined in Step 5 of [Setting up Google Cloud Platform for Our Infrastructure](#setting-up-google-cloud-platform-for-our-infrastructure) while `chef_server_zone`, `chef_ip_address`, `chef_node_zone`, `chef_node_ip_address`, `chef_node_zone_2`, `chef_node_ip_address_2` `chef_node_zone_3` and `chef_node_ip_address_3` were determined in Step 2.

2. Initializing terraform. 
First step involves initializing terraform. To perform this step you need to have the name of your storage bucket that you created on Step 1 of [Setting up Google Cloud Platform for Our Infrastructure](#setting-up-google-cloud-platform-for-our-infrastructure).

Run the command below on the root of your repository:
```
terraform init
```

You should get a response like the one below. I have blocked the name of my storage bucket in the image below.

![Terraform init](docs/images/terraform-init.png?raw=true)

3. Create a plan.
The second step involves creating a terraform plan. This produces an output on the console indicating the plan that terraform will execute.
Run the command below on the root of your repository:
```
terraform plan
```

![Terraform plan](docs/images/terraform-plan.png?raw=true)

4. Create the infrastructure.

If you are comfortable with the plan shown in the step above, then create the infrastructure needed for the application by running the command below.


```
terraform apply
```

After running the command above you can visit your infrastructure and check whether your VM instance has been created.

**Note**
- If you have an issue with running the `terraform init` command when setting up the environment variables, sometimes deleting the .terraform folder that is created locally on the folder where you ran the command, will help.

