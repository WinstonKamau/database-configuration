### Configuring your workstation to connect to the Chef Server

1. Before we start connecting our workstation to the Chef Server, the Chef setup needs to be up and running. To achieve this follow the documentation [here](../chef-server-configuration/README.MD)

2. Once you are done with step 1 you can change directory to the cookbooks directory and export the following environment variable on your terminal

```
cd cookbooks
export HOSTNAME="The domain name that is pointing to your chef server"
```

3. Fetch the contents of the chefadmin.pem file on your server instance.

This step requires you to ssh into your running server. You can find more instructions [here](https://cloud.google.com/compute/docs/instances/connecting-to-instance).
![SSH-into-instance](../docs/images/ssh-into-instance.png)
Move into the /drop directory, and copy the contents of the chefadmin.pem
![Get-Chefadmine-PEM-file](../docs/images/get-chefadmin-pem-file.png)
Copy the contents you find here to the chefadmin.pem file located under the .chef folder.
The contents fo the file change every time a new chef server instance is created.

4. Once this is done you can run the commands below to create a connection:

```
knife ssl fetch
```
The fetch command will fetch the certificate that was automatically generated to connect to your chef server using knife.

```
knife ssl check
```
The check command will confirm if the certificate that has been fetched is valid.

You should not get any errors with the commands above but success or warning messages.
If the commands work, your workstation is now connected to your chef infra server.

### Uploading a cookbook to the Chef Server

Once you have performed the [Configuring your workstation to connect to the Chef Server](#configuring-your-workstation-to-connect-to-the-Chef-Server) step you can upload a cookbook to your chef server.

1. Ensure that you are on the cookbooks directory before running the command below.

```
knife cookbook upload postgres_database
knife cookbook upload postgres_database_standby
```
You should get the success message: *Created postgres_database*

### Testing a cookbook

To test a cookbook, you need to change directory into the cookbook and run the test command as shown below:

```
cd postgres_database
chef exec rspec
```

### Provide the name of the storage bucket

On the [postgresql.conf](postgres_database/files/postgresql.conf) file you need to edit the code below.

```
archive_command = 'export CLOUDSDK_PYTHON=/usr/bin/python && gsutil cp %p gs://{BUCKET_NAME}/prirmay-database-archive/%f'	
```

The `{BUCKET_NAME}` should be a private bucket on GCS which stores the archives for the master database.

Do the same for the [recovery.conf](postgres_database_standby/files/recovery.conf) file, giving the same bucket name.

### Bootstrap the nodes with the cookbooks

The next step involves bootstrapping our nodes with the cookbooks that we just created. We start off by bootstrapping the master with the postgres_database cookbook. This cookbook is meant to run the postgres setup for a master database. We then bootstrap our slaves with the postgres_database_standby cookbook. The postgres_database_standby cookbook is meant to run the setup for a standby database. While boostrapping any of the nodes in our current setup, use the `ssh-user` as `ubuntu`. By default the ubuntu image we use on GCP to create our VM instances, already contains this user. Changing the version of the image may have some effect on the SSH creation scripts that we use on Terraform.

To bootstrap the **master-database-server** run the command below:

```
knife bootstrap <ip address of the master node> --ssh-user ubuntu --sudo --identity-file ../chef-server-configuration/chef_node_ssh_key --node-name node1-ubuntu --run-list 'recipe[postgres_database]'
```

To bootstrap the **standby-database-server-1** run the command below:
```
knife bootstrap <ip address of the standby server node 1> --ssh-user ubuntu --sudo --identity-file ../chef-server-configuration chef_node_ssh_key --node-name node2-ubuntu --run-list 'recipe[postgres_database_standby]'
```

To bootstrap the **standby-database-server-2** run the command below:
```
knife bootstrap <ip address of the standby server node 2> --ssh-user ubuntu --sudo --identity-file ../chef-server-configuration/chef_node_ssh_key --node-name node3-ubuntu --run-list 'recipe[postgres_database_standby]'
```

In case you get an issue where you try to bootstrap and this command refuses, this could be because the host had been added to the known_hosts file previously. You may need to locate this file and edit it by deleting the line that contains your nodes' IP address and key.