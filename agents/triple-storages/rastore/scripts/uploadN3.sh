#!/bin/sh
sudo rabbitmqctl add_user rastore rspass
sudo rabbitmqctl add_vhost rs
sudo rabbitmqctl map_user_vhost rastore rs

scalac -cp /home/selivanovm/soft/javalibs/rabbitmq-client.jar N3Uploader.scala
java -cp /home/selivanovm/soft/javalibs/commons-io-1.2.jar:/home/selivanovm/soft/javalibs/commons-cli-1.1.jar:/home/selivanovm/soft/javalibs/rabbitmq-client.jar:./:/home/selivanovm/bin/scala-2.7.3.final/lib/scala-library.jar N3Uploader $1 localhost 5672 rs rsexchange rsinbox rastore rspass 0 rskey direct
