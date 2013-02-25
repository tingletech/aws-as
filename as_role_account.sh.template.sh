# run as role account
set -eux

mkdir archivesspace
cd archivesspace
mkdir lib
curl https://archivesspace.s3.amazonaws.com/public-files/archivesspace.%{TAG}.jar -o lib/archivesspace.jar
mkdir -p lib/frontend/WEB-INF/app/views/site/
curl https://raw.github.com/tingletech/aws-as/master/_footer.html.erb -o lib/frontend/WEB-INF/app/views/site/_footer.html.erb
cd lib
zip -u archivesspace.jar frontend/WEB-INF/app/views/site/_footer.html.erb
cd ..
curl http://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.21/mysql-connector-java-5.1.21.jar -o lib/mysql-connector-java-5.1.21.jar
curl https://s3.amazonaws.com/archivesspace/public-files/as-build.%{TAG}.zip -o as-build.zip
mkdir log
mkdir config
# create config/config.rb, pointing to the AWS RDS mysql DB that we've started
cat > config/config.rb << RAILSCONFIG
AppConfig[:db_url] = "%{DB_URL}"
AppConfig[:backend_url] = "http://localhost:8081"
AppConfig[:frontend_url] = "http://localhost:8080"
RAILSCONFIG
# end of here file with config.rb 
chmod 600 config/config.rb

unzip as-build.zip
./build/run db:migrate

# wget https://raw.github.com/gist/3519687/archivesspace.sh
# need a better way to do this ... keep having to update the version
wget https://raw.github.com/tingletech/aws-as/master/archivesspace.sh
chmod a+x archivesspace.sh
./archivesspace.sh start

exit
# set up tomcat style as a backup
# https://github.com/tingletech/twincat SNAC style ‖tomcat 
cd
git clone https://github.com/tingletech/twincat.git
cd twincat
./grabcat.sh appFront appBack	# this sets up two tomcat servers using the same binary distribution
				# 8080 is appFront and 8081 is appBack
# install war files into tomcat
curl https://archivesspace.s3.amazonaws.com/public-files/frontend.%{TAG}.war -o appFront/webapps/ROOT.war
curl https://archivesspace.s3.amazonaws.com/public-files/backend.%{TAG}.war -o appBack/webapps/ROOT.war
cp -p ~/config/config.rb appFront/conf
cp -p ~/config/config.rb appBack/conf
# ./wrapper.sh appFront ./tomcat/bin/startup.sh
# ./wrapper.sh appBack ./tomcat/bin/startup.sh
