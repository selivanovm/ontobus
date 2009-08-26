#!/bin/sh
#sudo rabbitmqctl add_user rastore rspass
#sudo rabbitmqctl add_vhost auth
#sudo rabbitmqctl map_user_vhost rastore auth

~/workplace/scala-2.7.5.final/bin/scalac -cp lib/rabbitmq-client.jar Client.scala
java -cp ./:lib/commons-io-1.2.jar:lib/commons-cli-1.1.jar:lib/rabbitmq-client.jar:lib/scala-library.jar Client $1 192.168.150.196 5672 magnetico rsexchange test eks 123456 0 authentication-manager direct $2
