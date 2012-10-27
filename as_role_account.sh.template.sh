# run as role account
set -eux

mkdir archivesspace
cd archivesspace
mkdir lib
curl https://archivesspace.s3.amazonaws.com/public-files/archivesspace.%{TAG}.jar -o lib/archivesspace.%{TAG}.jar
curl http://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.21/mysql-connector-java-5.1.21.jar -o lib/mysql-connector-java-5.1.21.jar
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

wget https://raw.github.com/gist/3519687/1aa59bc7009ca79684c58642cb1f4f453a123b99/archivesspace.sh
chmod a+x archivesspace.sh
./archivesspace.sh start


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
