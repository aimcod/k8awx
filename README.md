The files in this folder are based on the instructions in https://github.com/ansible/awx-operator 
There are references to HAproxy and Load Balancers in some of the files/scripts. 
Ignore them. 
This is for a multi-node AWX setup, where DaemonSets are involved, for High Availability.
We won't actually do that.
I did it, but you don't have to.


Installation steps:

1. Create new Linux server(s), if you don't already have one. 
 - My AWX environment has been built on Oracle Linux 8.5. 
   Any fedora-based distribution will work. 
   Ubuntu works too.

2. Setup Kubernetes single node cluster(1 control plane). 
 - The kubeDeploy.sh script works well on Ubuntu 20.04 and Ubuntu 22.04

3. Install a postgresql database. https://www.postgresql.org/download/linux/

4. Create awx database in postgresq. 
 - Connect: ```psql -U postgres```
 - Create: ```create database awx;```

5. create awx superuser role in postgresql
 - ```create role awx with superuser login password 'mynewpassword';``` <- don't forget to set an actual password.

6. Edit pg_hba.conf to allow host access to the awx database using the awx user and md5 authentication. 
You may need to specify an address.
7. Edit postgresql.conf listen_addresses, for k8s cluster access(i.e. cluster IP or '*' if in a secure network)
8. Restart postgresql service & test the connection from the remote host
 -  ```psql -U awx awx -h "databaseserverIPorHostname"``` <- do this if you host the postgres database on a different server. 
 - Note that the awx pods are remote servers in this context, so it's crucial for remote access to postgres to work.

9. Once connection succeeds, you're ready to run the awxSetup.sh script.

10. Note the instructions in the script file and the required files. I left some notes in each.

NOTE:
If the site is inaccessible after the script completes, check the last instruction from the script. 
```kubectl apply -f ingress.yaml -n awx
#you should check the site now. If the output of the below changes, make sure you can still access the site.if you can't re-run the command above.
```
This is an issue with the awx-operator, where it removes the ingress-class annotation/spec.
Note that in some cases, you might need to define the default ingress class, using the ingress-class.yaml

NOTE#2: I have created this repo because I too found awx deployment difficult and I ran into all sorts of issues during my journey. Some things might not quite work off the first try, but I do encourage you to persist.
This is the way.
