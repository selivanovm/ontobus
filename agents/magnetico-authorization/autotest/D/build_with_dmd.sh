date
rm *.test
rm *.agent
dmd -version=tango_99_8 -version=Tango -Iimport /usr/include/d/tango-dmd/tango/net/InternetAddress /usr/include/d/tango-dmd/tango/net/Socket /usr/include/d/tango-dmd/tango/stdc/stdarg.d /usr/include/d/tango-dmd/tango/stdc/errno.d src/*.d src/mod/tango/io/device/*.d lib/mom_client.a lib/libdbus_client.a lib/libdbus-1.a -O -release -ofAutotest.test
#dmd src/Triple.d src/TripleStorage.d src/Log.d src/HashMap.d src/Hash.d src/librabbitmq_headers.d src/librabbitmq_listen.d src/server.d lib/librabbitmq.a -O -release -ofSemargl.agent
rm *.log
rm *.o
date

