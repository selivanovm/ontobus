date
rm dbus_listen_and_send
dmd -Iexport examples/*.d libdbus_client.a lib/libdbus-1.a -O -release -ofdbus_listen_and_send
rm *.o
date
