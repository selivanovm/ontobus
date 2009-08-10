date
dmd -Iimport src/libdbus_client.d src/libdbus_headers.d -O -Hdexport -release -lib
rm *.o
date
