### Configuring your workstation to connect to the Chef Server

1. Before we start connecting our workstation to the Chef Server, the Chef server needs to be up and running. To achieve this follow the documentation [here](../chef-server-configuration/README.MD)

2. Once you are done with step 1 you can change directory to the cookbooks directory and export the following environment variable on your terminal

```
cd cookbooks
export HOSTNAME="The domain name that is pointing to your chef server"
```

3. Once this is done you can run the commands below to create a connection:

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