#!/bin/sh
#sudo rabbitmqctl add_user rastore rspass
#sudo rabbitmqctl add_vhost auth
#sudo rabbitmqctl map_user_vhost rastore auth

#scalac -cp /home/selivanovm/soft/javalibs/rabbitmq-client.jar Client.scala
/usr/lib/jvm/java-6-sun/bin/java -cp /home/selivanovm/soft/javalibs/commons-io-1.2.jar:/home/selivanovm/soft/javalibs/commons-cli-1.1.jar:/home/selivanovm/soft/javalibs/rabbitmq-client.jar:./:/home/selivanovm/bin/scala-2.7.3.final/lib/scala-library.jar Client "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$10" "$11" "$12" "$13" "$14" "$15"
