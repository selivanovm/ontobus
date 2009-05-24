#!/bin/sh
java -cp /home/mike/bin/scala-2.7.3.final/lib/*:./target/rastore-0.0.1-SNAPSHOT.jar:/home/mike/work/javalibs/* ru.magnetosoft.rastore.TestRunner $1 $2
