#!/bin/sh

rm rodzilla
dmd -unittest -O -Iimport src/rodzilla.d lib/librabbitmq_client.a lib/librabbitmq.a 
rm *.o

./rodzilla