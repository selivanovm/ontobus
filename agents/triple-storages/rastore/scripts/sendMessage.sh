#!/bin/sh
sudo rabbitmqctl add_user rastore rspass
sudo rabbitmqctl add_vhost auth
sudo rabbitmqctl map_user_vhost rastore auth

scalac -cp /home/selivanovm/soft/javalibs/rabbitmq-client.jar Client.scala
/usr/lib/jvm/java-6-sun/bin/java -cp /home/selivanovm/soft/javalibs/commons-io-1.2.jar:/home/selivanovm/soft/javalibs/commons-cli-1.1.jar:/home/selivanovm/soft/javalibs/rabbitmq-client.jar:./:/home/selivanovm/bin/scala-2.7.3.final/lib/scala-library.jar Client $1 192.168.150.197 5672 auth rsexchange auth rastore rspass 0 rskey direct $2
