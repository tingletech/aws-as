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
AppConfig[:backend_url] = "http://localhost:8081"
AppConfig[:frontend_url] = "http://localhost:8080"
RAILSCONFIG
# end of here file with config.rb (not really sure if this is railsconf)

./build/run db:migrate 		# this runs and talks to the mysql in amazon okay
./build/run backend:war
./build/run frontend:war

cd ~
# https://github.com/tingletech/twincat SNAC style ‖tomcat 
git clone https://github.com/tingletech/twincat.git
cd twincat
./grabcat.sh appFront appBack	# this sets up two tomcat servers using the same binary distribution
				# 8080 is appFront and 8081 is appBack
# install war files into tomcat
cp ~/archivesspace/frontend/frontend.war appFront/webapps/ROOT.war
cp ~/archivesspace/backend/backend.war appBack/webapps/ROOT.war
./wrapper.sh appFront ./tomcat/bin/startup.sh
./wrapper.sh appBack ./tomcat/bin/startup.sh
