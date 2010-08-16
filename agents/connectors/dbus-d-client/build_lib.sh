date
rm *.a
dmd -Iimport src/*.d -O -Hdexport -release -lib
rm *.o
date
