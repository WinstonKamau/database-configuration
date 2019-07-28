# database-configuration

database-configuration is a repository that is meant to automate the creation of a master and two slave PostgreSQL databases and deploy them to Google Cloud Platform.

# Description

The automation scripts above are separated into two:

1. Configuration Management with Chef.
The purpose of this step is to use chef scripts to configure our compute engine database nodes. Our Chef setup involves the following:
    - Chef Work Station: This work station exists locally on the computer where the repository has been cloned. In this work station this is where you are able to make updates to the postgres_database and postgres_database_standby cookbooks. The cookbooks are located under the cookbooks directory.
    - Chef Infrastructure Server: This is a server where cookbooks are uploaded to. This server is where our database nodes are managed, by running chef client on the nodes.
    - Chef Nodes: These are the compute engines where we setup our Master and Slave databases.

2. Infrastructure Automation with Terraform.
The purpose of this step is to create the infrastructure on the cloud. These scripts are located under the chef-server-configuration directory. 


## Documentation

## Setup

### Dependencies

This project was setup using the following technologies:

| **Version**     | **Packages/Languages/Frameworks**                              |
|-----------------|----------------------------------------------------------------|
|`0.11.4`         | [Terraform](https://www.terraform.io/) |
|`14.7.17`        | [Chef-Client](https://docs.chef.io/install_server.html)          |

### Getting Started

#### Clone this repository, and change directory into the database-configuration folder
    git clone https://github.com/WinstonKamau/database-configuration.git
    cd database-configuration
#### Setup the Infrastructure
All documentation on setting up the infrastructure for chef can be found [here](chef-server-configuration/README.MD).
#### Setup Configuration Management    
All documentation on using chef to configure the databases can be found [here](cookbooks/README.Md).
