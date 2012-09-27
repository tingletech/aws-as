# Set up AT and Archon tracer database

Launch an AWS EC2 c1.medium and ssh to it.

Update and install packages, start servers.

```sh
sudo yum -y update
sudo yum -y install php php-pear
sudo pear install MDB2-2.4.1
sudo pear install MDB2_Driver_mysql-1.4.1
sudo service httpd start
sudo yum -y install mysql51
sudo yum -y install mysql51-server
sudo service mysqld start
sudo /usr/bin/mysql_secure_installation
mysql -u root  -p

```

create databases

```sql
mysql> create database archon default character set utf8;
Query OK, 1 row affected (0.00 sec)

mysql> create database at default character set utf8;
Query OK, 1 row affected (0.00 sec)

mysql> grant all on archon.* to 'XXX'@'localhost' identified by 'XXX';
Query OK, 0 rows affected (0.00 sec)

mysql> grant all on at.* to 'XXX'@'%' identified by 'XXX';
Query OK, 0 rows affected (0.00 sec)

```

Install archon.

```sh

sudo yum -y install php-pear

cd /var/www/html
wget http://downloads.sourceforge.net/project/archonproject/Archon/3.21/Archon%203.21-r1.zip
sudo unzip Archon\ 3.21-r1.zip
sudo vi 3.21-r1/Archon/config.inc.php # set database info

```

Go to the web interface and to the install; then do this:

```sh
sudo mv Archon/packages/core/install/install.php Archon/packages/core/install/install-done.php
```
