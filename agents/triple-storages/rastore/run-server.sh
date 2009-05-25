#!/bin/sh
sudo rabbitmqctl add_user rastore rspass
sudo rabbitmqctl add_vhost rs
sudo rabbitmqctl map_user_vhost rastore rs
java -cp /home/selivanovm/bin/scala-2.7.3.final/lib/scala-library.jar:/home/mike/bin/scala-2.7.3.final/lib/*:./target/rastore-0.0.1-SNAPSHOT.jar:/home/selivanovm/soft/javalibs/rabbitmq-client.jar:/home/selivanovm/soft/javalibs/commons-cli-1.1.jar:/home/selivanovm/soft/javalibs/h2-1.0.67.jar:/home/selivanovm/soft/javalibs/commons-io-1.2.jar ru.magnetosoft.rastore.Server