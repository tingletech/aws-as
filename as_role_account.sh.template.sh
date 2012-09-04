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
./build/run backend:devserver	# did not check if this dev server could connect to RDS!
./build/run backend:war		# <-- did not try the unconfigured/derby .war files in tomcat
./build/run frontend:war

cd ~
# https://github.com/tingletech/twincat SNAC style ‖tomcat 
git clone https://github.com/tingletech/twincat.git
cd twincat
				# standalone jar will use 8080 and 8089 right now
export START_LISTEN=8081	# since default 8080 will be used by java -jar archivesspace.jar
./grabcat.sh appFront appBack	# this sets up two tomcat servers using the same binary distribution
				# 8081 is appFront and 8082 is appBack
# install war files into tomcat
cp ~/archivesspace/frontend/frontend.war appFront/webapps/ROOT.war
cp ~/archivesspace/backend/backend.war appBack/webapps/ROOT.war
## hacking around the missing mysql driver...
  cd appFront/webapps
  unzip ROOT.war
  cd ~
  cp ~/archivesspace/build/gems/gems/jdbc-mysql-5.1.13/lib/mysql-connector-java-5.1.13.jar \
    twincat/appFront/webapps/ROOT/WEB-INF/lib/

# java -DARCHIVESSPACE_BACKEND=localhost:8089 ??  via JAVA_OPTS?
# front needs to know where the back is
cat >> appFront/bin/setenv.sh << ASBACKEND
JAVA_OPTS="-DARCHIVESSPACE_BACKEND=http://localhost:8082"
ASBACKEND
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
