date
dmd -Iimport src/librabbitmq_client.d src/librabbitmq_headers.d -O -Hdexport -release -lib
rm *.o
date
