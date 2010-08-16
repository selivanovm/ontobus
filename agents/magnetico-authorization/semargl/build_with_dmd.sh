date
rm Semargl

dmd /usr/include/d/dmd/tango/net/InternetAddress.d /usr/include/d/dmd/tango/net/device/Socket.d /usr/include/d/dmd/tango/stdc/stdarg.d /usr/include/d/dmd/tango/stdc/errno.d \
-Iimport/libmongod -Iimport/other -Iimport \
src/*.d src/mod/tango/io/device/*.d src/scripts/*.d \
lib/mom_client.a lib/librabbitmq_client.a lib/librabbitmq.a lib/trioplax.a lib/libmongod.a \
-O -inline -release -ofSemargl


#rm *.o

#dmd -version=tango_99_8 /usr/include/d/tango-dmd/tango/net/InternetAddress /usr/include/d/tango-dmd/tango/net/Socket /usr/include/d/tango-dmd/tango/stdc/stdarg.d /usr/include/d/tango-dmd/tango/stdc/errno.d \
#-Iimport/mongo-d-driver -Iimport/other -Iimport/trioplax-mongodb src/*.d src/mod/tango/io/device/*.d src/scripts/*.d \
#lib/mom_client.a lib/librabbitmq_client.a lib/librabbitmq.a lib/trioplax-mongodb.a lib/libdbus_client.a lib/libdbus-1.a lib/libmongod.a \
#-O -inline -release -ofSemargl-on-mongodb

rm *.log
rm *.o
date

