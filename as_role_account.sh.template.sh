# run as role account
set -eux
git clone https://github.com/archivesspace/archivesspace.git
# make a copy so we can run standalone as a back up
cp -rp archivesspace archivesspace.orig
cd archivesspace
./build/run bootstrap 
./build/run backend:integration 
./build/run backend:doc
./build/run backend:test
./build/run common:test
# create config/config.rb, pointing to the AWS RDS mysql DB that we've started
cat > config/config.rb << RAILSCONFIG
AppConfig[:db_url] = "%{DB_URL}"
RAILSCONFIG
# end of here file with config.rb (not really sure if this is railsconf)

# now, write a database.yml file
cat > frontend/config/database.yml << DATABASEYML
#
# http://bleything.net/articles/dry-out-your-database-yml.html
#
login: &login
  adapter: mysql
  encoding: utf8
  username: aspace
  password: %{password}
  host: %{endpoint}

development:
  <<: *login
  database: archivesspace

# Warning: The database defined as "test" will be erased and
# re-generated from your development database when you run "rake".
# Do not set this db to the same as development or production.
test:
  adapter: sqlite3
  database: db/test.sqlite3

production:
  <<: *login
  database: archivesspace

DATABASEYML
# end of database.yml file

./build/run db:migrate 		# this runs and talks to the mysql in amazon okay
./build/run backend:war
./build/run frontend:war

cd ~aspace
# https://github.com/tingletech/twincat SNAC style ‖tomcat 
git clone https://github.com/tingletech/twincat.git
cd twincat
./grabcat.sh

# install war files into tomcat
cp /home/aspace/archivesspace/frontend/frontend.war appFront/webapps/ROOT.war
## hacking around the missing mysql driver...
cd appFront/webapps
unzip ROOT.war
cd ~aspace
cp /home/aspace/archivesspace/build/gems/gems/jdbc-mysql-5.1.13/lib/mysql-connector-java-5.1.13.jar twincat/appFront/webapps/ROOT/WEB-INF/lib/

# can these run in one server, rathern than two?
cp /home/aspace/archivesspace/backend/backend.war twincat/appBack/webapps/ROOT.war

# java -DARCHIVESSPACE_BACKEND=localhost:8089 ??
./twincat/wrapper.sh appFront ./twincat/tomcat/bin/startup.sh
./twincat/wrapper.sh appBack ./twincat/tomcat/bin/startup.sh

# if we are running two tomcats; maybe it will be eaiser to set up in the role account
# rather than using the tomcat7 that comes with Amazon Linux
# or... run a tomcat6 and a tomcat7?

# For now, run exactly what gets checked out as a standalone service
#
cd ../archivesspace.orig
./build/run dist
mkdir daemonize
daemonize -c .       \
 -e daemonize/stderr \
 -o daemonize/stdout \
 -p daemonize/pid    \
 -l daemonize/lock   \
 /usr/bin/java -jar archivesspace.jar 8080
