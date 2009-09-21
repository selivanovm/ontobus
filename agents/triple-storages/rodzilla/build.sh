#!/bin/sh

rm rodzilla
dmd -O -Iimport src/rodzilla.d src/ListOntoFunctions.d src/Triple.d src/OntoFunction.d src/ListStrings.d src/ListTriples.d lib/librabbitmq_client.a lib/librabbitmq.a 
#dmd src/librabbitmq_client.d src/librabbitmq_headers.d -O -Hdexport -release -lib
rm *.o

