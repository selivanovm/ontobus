#!/bin/sh
java -cp /home/selivanovm/bin/scala-2.7.3.final/lib/scala-library.jar:./target/rastore-0.0.1-SNAPSHOT.jar:/home/selivanovm/soft/javalibs/*:/home/selivanovm/soft/javalibs/h2-1.0.67.jar ru.magnetosoft.rastore.TestRunner $1 $2
