#!/bin/sh
scalac -cp /home/mike/work/javalibs/rabbitmq-client.jar N3Uploader.scala
java -cp /home/mike/work/javalibs/commons-io-1.2.jar:/home/mike/work/javalibs/commons-cli-1.1.jar:/home/mike/work/javalibs/rabbitmq-client.jar:./:/home/mike/bin/scala-2.7.3.final/lib/scala-library.jar N3Uploader $1 localhost 5672 rs rsexchange rsinbox rastore rspass 0 rskey direct
