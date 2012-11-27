#!/bin/sh

### BEGIN INIT INFO
# Provides:          archivesspace
# Required-Start:    networking
# Required-Stop:     networking
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start archivesspace/ embedded jetty 
# Description:       Start archivesspace.jar using daemonize(1) http://software.clapper.org/daemonize/
### END INIT INFO

set -e

# AS_HOME has a default or can be read from environment
AS_HOME=${AS_HOME-"$HOME/archivesspace"}

PIDFILE=$AS_HOME/log/archivesspace.pid
OUTFILE=$AS_HOME/log/stdout.txt
ERRFILE=$AS_HOME/log/stderr.txt

case "$1" in
start)
  set -u
  /usr/sbin/daemonize -a -c $AS_HOME -e $ERRFILE -o $OUTFILE -p $PIDFILE -l $PIDFILE \
    $JAVA_HOME/bin/java \
      -Daspace.config=$AS_HOME/config/config.rb \
      -cp $AS_HOME/lib/mysql-connector-java-5.1.21.jar:$AS_HOME/lib/archivesspace.v0.2.2.jar \
      org.archivesspace.Main
;;

stop)
  PID=`cat $PIDFILE`
  if [ -f $PIDFILE ]; then
    kill -HUP $PID
    printf "%s\n" "Ok"
    rm -f $PIDFILE
  else
    printf "%s\n" "pidfile not found"
  fi
;;

restart)
  $0 stop
  $0 start
;;

status)
#    if pidof -o %PPID rpc.mountd > /dev/null; then
#                     echo "Running"
#                     exit 0
#             else
#                     echo "Not running"
#                     exit 1
#             fi
;;

*)
  echo "Usage: $0 {start|stop|restart|status}"
  exit 1
esac

