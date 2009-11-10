date
rm *.test
rm *.agent
dmd -version=tango_99_8 -Iimport src/*.d src/mod/tango/io/device/*.d src/scripts/*.d lib/mom_client.a lib/librabbitmq_client.a lib/librabbitmq.a lib/TripleStorage.a -O -release -ofSemargl.test
#dmd src/Triple.d src/TripleStorage.d src/Log.d src/HashMap.d src/Hash.d src/librabbitmq_headers.d src/librabbitmq_listen.d src/server.d lib/librabbitmq.a -O -release -ofSemargl.agent
rm *.log
rm *.o
date

