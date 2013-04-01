# run as role account
set -eux

# if "%{TAG}" contains '{%' and 'TAG}' this is a template file for an ArchivesSpace installation script

# this script is designed to be run once in a virgin unix account and immediately deleted
# role account for the applicaiton is expected to be "aspace" in "/home/aspace?

mkdir archivesspace
cd archivesspace
mkdir lib
# download the %{TAG} jar; renaming it to lib/archivesspace.jar
curl https://archivesspace.s3.amazonaws.com/public-files/archivesspace.%{TAG}.jar -o lib/archivesspace.jar
# need to hack the jar to put in our customized templates
mkdir -p lib/frontend/WEB-INF/app/views/site/
curl https://raw.github.com/tingletech/aws-as/master/_footer.html.erb -o lib/frontend/WEB-INF/app/views/site/_footer.html.erb
# show the version number
echo "%{TAG}" >> lib/frontend/WEB-INF/app/views/site/_footer.html.erb
curl http://169.254.169.254/latest/meta-data/instance-id >> lib/frontend/WEB-INF/app/views/site/_footer.html.erb
# now, zip that bad boy into the jar file
cd lib
unzip archivesspace.jar frontend/WEB-INF/config/help.yml
sed -i 's#http://aspace.hudmol.com/help/Default.*htm#http://www.archivesspace.org/get-involved/software-testing-help/#g' frontend/WEB-INF/config/help.yml 
zip -u archivesspace.jar frontend/WEB-INF/app/views/site/_footer.html.erb
zip -u archivesspace.jar frontend/WEB-INF/config/help.yml 
cd ..
# back in ~/archivesspace/lib; grab the GPL mysql connector
curl http://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.21/mysql-connector-java-5.1.21.jar -o lib/mysql-connector-java-5.1.21.jar
mkdir log

# set up configuration file
mkdir config
touch config/config.rb
# passwords go in here; make it -rw------- 
chmod 600 config/config.rb
# create config/config.rb, pointing to the AWS RDS mysql DB that we've started
cat >> config/config.rb << RAILSCONFIG
AppConfig[:db_url] = "%{DB_URL}"
AppConfig[:backend_url] = "http://localhost:8089"
AppConfig[:frontend_url] = "http://localhost:8080"
AppConfig[:public_url] = "http://localhost:8081"
AppConfig[:solr_url] = "http://localhost:8082"
AppConfig[:search_user_secret] = "%{PW1}"
AppConfig[:public_user_secret] = "%{PW2}"
AppConfig[:allow_other_unmapped] = true
RAILSCONFIG
# end of here file with config.rb 

#unzip as-build.zip
#./build/run db:migrate

# set up jar style as a back up
# archivesspace.sh requires daemonize http://software.clapper.org/daemonize/
wget https://raw.github.com/tingletech/aws-as/master/archivesspace.sh
chmod a+x archivesspace.sh
./archivesspace.sh start
sleep 60
curl -v -X POST http://localhost:8089/setup/update_schema

exit

# set up solr, for use with tomcat
mkdir -p ~/aspace-solr-data  # data directory
cd ~/archivesspace/
mkdir solr                   # add this directory to solr's tomcat's classpath
cd solr
unzip ../lib/archivesspace.jar schema.xml solrconfig.xml stopwords.txt synonyms.txt

# set up tomcat style 
# https://github.com/tingletech/twincat SNAC style ‖tomcat 
cd
git clone https://github.com/tingletech/twincat.git
cd twincat
./grabcat.sh 
./clonecat.sh appFront 8080 12005
./clonecat.sh appBack 8089 12006
./clonecat.sh public 8081 12007
./clonecat.sh solr 8082 12008
	
# install war files into tomcat
curl https://archivesspace.s3.amazonaws.com/public-files/frontend.%{TAG}.war -o appFront/webapps/ROOT.war
curl https://archivesspace.s3.amazonaws.com/public-files/backend.%{TAG}.war -o appBack/webapps/ROOT.war
curl https://archivesspace.s3.amazonaws.com/public-files/public.%{TAG}.war -o public/webapps/ROOT.war
curl http://repo1.maven.org/maven2/org/apache/solr/solr/4.0.0/solr-4.0.0.war -o solr/webapps/ROOT.war
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
                                                   
# needs to be a better way to modify the template of a .war file
# - OR -
# we need to NOT SUPPORT .war distribution.  Who is going to want to run 
# it in tomcat and not customize it?                                                   
# unpack the @@@@@ ##### .war file; by starting up tomcat...
./wrapper.sh appFront ./tomcat/bin/startup.sh
# wait for the .war to unzip so we can mess around in there
sleep 30  
# shutdown.sh don't work right here, just kill it
pkill java

# add in our custom footer template
cd appFront/webapps
curl https://raw.github.com/tingletech/aws-as/master/_footer.html.erb -o ROOT/WEB-INF/app/views/site/_footer.html.erb
echo "%{TAG} " >> ROOT/WEB-INF/app/views/site/_footer.html.erb
curl http://169.254.169.254/latest/meta-data/instance-id >> ROOT/WEB-INF/app/views/site/_footer.html.erb
## need to put a sed in here to switch out the URL for the help documentation
## this is only happening in the tomcat/ not the .jar
sed -i 's#http://aspace.hudmol.com/help/Default.*htm#http://www.archivesspace.org/get-involved/software-testing-help/#g' ROOT/WEB-INF/config/help.yml

# set up tomcats
# \\\$ is required in the template to escape \$ in the install script to escape to $ in tomcat setenv.sh
cd ~/twincat
cat > appFront/bin/setenv.sh << SETENV
export JAVA_OPTS="\\\$JAVA_OPTS -Daspace.config=/home/aspace/archivesspace/config/config.rb -Dsolr.data.directory=/home/aspace/aspace-solr-data"
export CLASSPATH="\\\$CLASSPATH:/home/aspace/archivesspace/solr"
SETENV
cp -rp appFront/bin/setenv.sh appBack/bin/setenv.sh
cp -rp appFront/bin/setenv.sh public/bin/setenv.sh
cp -rp appFront/bin/setenv.sh solr/bin/setenv.sh
# finally, start up the tomcats!
./wrapper.sh solr ./tomcat/bin/startup.sh
./wrapper.sh appBack ./tomcat/bin/startup.sh
sleep 30
# migrate the database
curl -v -X POST http://localhost:8089/setup/update_schema
./wrapper.sh appFront ./tomcat/bin/startup.sh
./wrapper.sh public ./tomcat/bin/startup.sh
