## Deploying the Chef Server.

To achieve a running chef server for our chef setup we need to setup our infrastructure on the cloud. For this setup, we will be using [Google Cloud Platform](https://cloud.google.com). Our chef server will require a virtual machine on Compute engine where it will be installed. We shall also expose it by providing it with an external IP Address. To make our process of deploying our chef server repeatable, less error prone and easy we need to automate this process. To automate it, we need a scripting language to enable us achieve infrastructure as code. To do this we choose **Terraform**. I value [terraform](https://www.terraform.io/) for its ease of use, its integration with many cloud environments, its high support; with new versions being released frequently, its quality of being free with good documentation.


### Setting up Google Cloud Platform for Our Chef Server.

1. Create a storage bucket

First we need to start by creating a storage bucket. Terraform needs to store a file in this storage bucket, which it can use to continuously check in the current state and determine what the desired state will be, before building infrastructure on your platform. Instructions for creating a storage bucket can be found [here](https://cloud.google.com/storage/docs/creating-buckets). Once you are done take note of the name of the bucket that you just created as we shall use it later when running terraform commands.

2. Reserve a static external IP address.

Steps for reserving this can be found [here](https://cloud.google.com/compute/docs/ip-addresses/reserve-static-external-ip-address#reserve_new_static). Note that when reserving an IP address, create it in a region where you would like to create your chef-server VM so that you may not have difficulty attaching it to an instance. This is as shown below, where the user intends to create the VM in the us-east1 region:
![IP address reservation Image](docs/images/regional-ip-address.png?raw=true)
Most instances are regional and if given a regional IP address in a different region from their own an error is raised when creating the script.

We need an external Static IP address through which we shall be able to access our chef server. The reason we choose an external Static IP address rather than an ephemeral IP address, is because we need something long-term that we are going to point our domain address to. Take note of the IP address you reserved as we shall also use it later.

3. Enable APIs and services.

Instructions for enabling an API and Services can be found [here](https://cloud.google.com/endpoints/docs/openapi/enable-api).
Ensure that the Compute Engine API is enabled.

4. Setup the service account 

**Note:** *This service account is different from the one we created above for packer*.

You may follow instructions on creating a service account as per this [link](https://cloud.google.com/iam/docs/creating-managing-service-accounts). The most critical part of the service account is the role that the account will be able to perform. Ensure that the service account has at lease admin capabilities of **Compute Admin**, **Compute Network Admin**, **Service Account User** and **Storage Object Admin**. Download the Service Account JSON key to your machine after giving the Service Account its roles.

Once you have gotten the key, change the name of the file [account.json.example](account-folder/account.json.example) to account.json. *This file is located under the account-folder directory*. Delete the contents in the file and paste your JSON key here.

5. Map a domain to your chef server

You need to have a domain for which you will use to connect online to your chef infra server. To do this you need to purchase your domain from a Domain Registrar Company. You then need to map your domain to point to the IPV4 address that you reserved above. This will require you to use the Type A option for creating your record.
The domain name you use here will be used as one of the environment variables for your next step.


### Running Terraform scripts

1. Pass environment variables

Our deployment script requires some environment variables. Create a file called terraform.tfvars on the root of your repository. You can derive the structure of secrets needed using the [terrafrom.tfvars.example](terraform.tfvars.example) file on the root of your repository. Replace each of the secret with its respective value.

2. Initializing terraform. 
First step involves initializing terraform. To perform this step you need to have the name of your storage bucket that you created on Step 1 of [Setting up Google Cloud Platform for deployment.](#setting-up-google-cloud-platform-for-deployment)

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

