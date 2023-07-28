if [ -z $1 ]
then
        echo -e Please run this script as follows:\n ./pg14.sh yoursupersecretpassword \(optional\)your_database_file.sql
#update
else
sudo dnf update -y
#install deps
sudo dnf -y install gnupg2 wget vim tar zlib openssl
#get repo
sudo dnf install https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm -y
#disable old pg
sudo dnf -qy module disable postgresql
#install new pg
sudo dnf install postgresql14 postgresql14-server postgresql14-contrib -y
#init new pg
sudo /usr/pgsql-14/bin/postgresql-14-setup initdb
#enable the service.
sudo systemctl enable --now postgresql-14

# note that the default location for all files has changed from
# /var/lib/postgresql/data/pgdata/ to /var/lib/pgsql/14/data
# if you're on a distribution that's not fedora or opensuse downstream, then...perhaps it's in /etc/.
# luckily, I have your back.
# we need to do a few things, before we make the database available to k8.

# first, we need to change local connection controls. This allows use to run psql commands locally.

sudo sed -i.bak 's/^local.\{1,\}all.\{1,\}all.\{1,\}peer/local all all trust/'  /var/lib/pgsql/14/data/pg_hba.conf | grep trust$

#then we need to allow remote connection controls, for the newly created database. This allows us to run psql commands remotely. pods and tasks need this.
sudo bash -c "echo host awx awx 0.0.0.0/0 md5 >> /var/lib/pgsql/14/data/pg_hba.conf" | grep awx

#then we need to update the posgresql.conf to listen for external connections. This is so we can connect to the DB, from our pods.
sudo sed -i.bak "s/^#listen_addresses = 'localhost'/listen_addresses = '*'/" /var/lib/pgsql/14/data/postgresql.conf | grep listen
#restart to apply changes
sudo systemctl restart postgresql-14.service

#create a database.
psql -U postgres -c "create database awx;"
#create teh role.
 psql -U postgres -c "create role awx with superuser login password '$1';"
#test the connection.
psql -U awx awx -h localhost -c "\c awx;\q;"
#You are now connected to database "awx" as user "awx".
#^means succes.

echo  "We are done. We can proceeed with the K8s setup now."

#if we have a database that we need to restore, then we need to perform a few more steps:

#1. restore the DB
#
if [ ! -z $2 ]
then
psql -U awx awx < $2
#
#2. Done.
fi
fi

#NOTE: When restoring a database, the next AWX depployment will likely also upgrade the database, so the deployment can take a while.
#NOTE2: Don't forget to claim your secret-key secret from the old AWX instance. You'll need this for the AWX deployment to connect with your restored database.