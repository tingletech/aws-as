# run as role account
set -eux

mkdir archivesspace
cd archivesspace
mkdir lib
curl https://archivesspace.s3.amazonaws.com/public-files/archivesspace.%{TAG}.jar -o lib/archivesspace.jar
# need to hack the jar to put in our customized templates
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
AppConfig[:backend_url] = "http://localhost:8089"
AppConfig[:frontend_url] = "http://localhost:8080"
AppConfig[:public_url] = "http://localhost:8081"
AppConfig[:search_user_secret] = "%{PW1}"
AppConfig[:public_user_secret] = "%{PW2}"
RAILSCONFIG
# end of here file with config.rb 
chmod 600 config/config.rb

#unzip as-build.zip
#./build/run db:migrate

# set up jar style as a back up
# wget https://raw.github.com/gist/3519687/archivesspace.sh
# need a better way to do this ... keep having to update the version
wget https://raw.github.com/tingletech/aws-as/master/archivesspace.sh
chmod a+x archivesspace.sh
# ./archivesspace.sh start

# set up tomcat style 
# https://github.com/tingletech/twincat SNAC style ‖tomcat 
cd
git clone https://github.com/tingletech/twincat.git
cd twincat
./grabcat.sh 
./clonecat.sh appFront 8080 12005
./clonecat.sh appBack 8089 12006
./clonecat.sh public 8081 12007
	
# install war files into tomcat
curl https://archivesspace.s3.amazonaws.com/public-files/frontend.%{TAG}.war -o appFront/webapps/ROOT.war
curl https://archivesspace.s3.amazonaws.com/public-files/backend.%{TAG}.war -o appBack/webapps/ROOT.war
curl https://archivesspace.s3.amazonaws.com/public-files/public.%{TAG}.war -o public/webapps/ROOT.war
# this used to work to set up the conf file
cp -p ~/archivesspace/config/config.rb appFront/conf
cp -p ~/archivesspace/config/config.rb appBack/conf
cp -p ~/archivesspace/config/config.rb public/conf
# install the GPL mysql library
cp -p ~/archivesspace/lib/mysql-connector-java-5.1.21.jar tomcat/lib/
# tweak the template
cd
cd twincat
# _   _     _       _                               
#| | | |   (_)     (_)                              
#| |_| |__  _ ___   _ ___   ___  ___                
#| __| '_ \| / __| | / __| / __|/ _ \               
#| |_| | | | \__ \ | \__ \ \__ \ (_) |              
# \__|_| |_|_|___/ |_|___/ |___/\___/               
#                                                   
# _                                                 
#| |                                                
#| | __ _ _ __ ___   ___                            
#| |/ _` | '_ ` _ \ / _ \                           
#| | (_| | | | | | |  __/                           
#|_|\__,_|_| |_| |_|\___|                           
                                                   
                                                   
# unpack the @@@@@ ##### .war file; by starting up tomcat...
./wrapper.sh appFront ./tomcat/bin/startup.sh
sleep 30  # wait for the .war to unzip so we can mess around in there
# shutdown.sh don't work right here, just kill it
pkill java

cd appFront/webapps
curl https://raw.github.com/tingletech/aws-as/master/_footer.html.erb -o ROOT/WEB-INF/app/views/site/_footer.html.erb
## need to put a sed in here to switch out the URL for the help documentation
## sed -e ... http://aspace.hudmol.com/help/Default.htm  http://www.archivesspace.org/get-involved/software-testing-help/  ROOT/WEB-INF/config/help.yml
cd ~/twincat
cat > appFront/bin/setenv.sh << SETENV
export JAVA_OPTS="\\\$JAVA_OPTS -Daspace.config=/home/aspace/archivesspace/config/config.rb"
SETENV
cp -rp appFront/bin/setenv.sh appBack/bin/setenv.sh
cp -rp appFront/bin/setenv.sh public/bin/setenv.sh
# finally, start up the tomcats!
./wrapper.sh appBack ./tomcat/bin/startup.sh
sleep 30
# migrate the database
curl -v -X POST http://localhost:8089/setup/update_schema
./wrapper.sh appFront ./tomcat/bin/startup.sh
./wrapper.sh public ./tomcat/bin/startup.sh
