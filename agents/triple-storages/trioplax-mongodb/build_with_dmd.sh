date
rm *.a
date
dmd -Iimport src/triple.d src/TripleStorage.d src/Log.d src/IndexException.d -O -Hdexport -release -lib -oftrioplax-mongodb
date
