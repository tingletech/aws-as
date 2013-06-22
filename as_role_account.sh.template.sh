# run as role account
set -eux

# if "%{TAG}" contains '{%' and 'TAG}' this is a template file for an ArchivesSpace installation script

# this script is designed to be run once in a virgin unix account and immediately deleted
# role account for the applicaiton is expected to be "aspace" in "/home/aspace?

# download the %{TAG} jar; renaming it to lib/archivesspace.jar
curl https://archivesspace.s3.amazonaws.com/public-files/archivesspace.%{TAG}.zip -o archivesspace.zip

unzip archivesspace.zip

cd archivesspace/wars
mkdir -p WEB-INF/app/views/site/
curl https://raw.github.com/tingletech/aws-as/master/_footer.html.erb -o WEB-INF/app/views/site/_footer.html.erb
# show the version number
echo "%{TAG}" >> WEB-INF/app/views/site/_footer.html.erb
curl http://169.254.169.254/latest/meta-data/instance-id >> WEB-INF/app/views/site/_footer.html.erb
# now, zip that bad boy into the war file
zip -u frontend.war WEB-INF/app/views/site/_footer.html.erb

mkdir -p WEB-INF/config
unzip frontend.war WEB-INF/config/help.yml
sed -i 's#http://aspace.hudmol.com/help/Default.*htm#http://www.archivesspace.org/get-involved/software-testing-help/#g' WEB-INF/config/help.yml
zip -u frontend.war WEB-INF/config/help.yml

cd
cd archivesspace
curl http://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.21/mysql-connector-java-5.1.21.jar -o lib/mysql-connector-java-5.1.21.jar

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
AppConfig[:db_max_connections] = 25
RAILSCONFIG
# end of here file with config.rb 

./scripts/setup-database.sh
export JAVA_OPTS="-verbose:gc"
./archivesspace.sh start

exit
