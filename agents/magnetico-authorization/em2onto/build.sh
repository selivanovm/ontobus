#!/bin/sh
mvn -npu clean assembly:assembly
# eclipse:eclipse
mv ./target/em2onto-0.0.1-SNAPSHOT-jar-with-dependencies.jar ./target/em2onto.jar
