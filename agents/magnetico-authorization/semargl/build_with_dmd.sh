date
rm Semargl-in-memory
rm Semargl-on-mongodb
rm *.agent

dmd -version=tango_99_8 /usr/include/d/tango-dmd/tango/net/InternetAddress /usr/include/d/tango-dmd/tango/net/Socket /usr/include/d/tango-dmd/tango/stdc/stdarg.d /usr/include/d/tango-dmd/tango/stdc/errno.d \
-Iimport/other -Iimport/trioplax \
src/*.d src/mod/tango/io/device/*.d src/scripts/*.d \
lib/mom_client.a lib/librabbitmq_client.a lib/librabbitmq.a lib/TripleStorage.a lib/libdbus_client.a lib/libdbus-1.a \
-O -inline -release -ofSemargl-in-memory

rm *.o

dmd -version=tango_99_8 /usr/include/d/tango-dmd/tango/net/InternetAddress /usr/include/d/tango-dmd/tango/net/Socket /usr/include/d/tango-dmd/tango/stdc/stdarg.d /usr/include/d/tango-dmd/tango/stdc/errno.d \
-Iimport/mongo-d-driver -Iimport/other -Iimport/trioplax-mongodb src/*.d src/mod/tango/io/device/*.d src/scripts/*.d \
lib/mom_client.a lib/librabbitmq_client.a lib/librabbitmq.a lib/trioplax-mongodb.a lib/libdbus_client.a lib/libdbus-1.a lib/libmongod.a \
-O -inline -release -ofSemargl-on-mongodb

rm *.log
rm *.o
date

