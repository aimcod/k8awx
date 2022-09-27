The files in this folder are based on the instructions in https://github.com/ansible/awx-operator 

Installation steps:

Create new Linux server(s), if you don'talready have one. My AWX environment has been built on Oracle Linux 8.5. 
Any fedora-based distribution will work. Ubuntu works too.
Setup Kubernetes single node cluster(1 control plane). There is a script called kubeDeploy.sh that works well on Ubuntu 22.04, in this repo.
Install postgresql database. https://www.postgresql.org/download/linux/redhat/ 
Create awx database in postgresq. Connect: ```psql -U postgres```, then create: ```create database awx;```
create awx superuser role in postgresql -> ```create role awx with superuser login password 'mynewpassword';```
edit pg_hba.conf to allow host access to the awx database using the awx user and md5 authentication. You may need to specify an address.
edit postgresql.conf listen_addresses, for k8s cluster access(i.e. cluster IP or '*' if in a secure network)
restart postgresql service & test the connection from the remote host -> psql -U awx awx -h "databaseserverIPorHostname"
Once connection succeeds, you're ready to run the awxSetup.sh script.

Note the instructions in the script file and the required files. I left some notes in each.

If the site is inaccessible after the script completes, check the last instruction from the script. 
This is an issue with the awx-operator, where it removes the ingress-class annotation/spec.
Note that in some cases, you might need to define the default ingress class, using the ingress-class.yaml
