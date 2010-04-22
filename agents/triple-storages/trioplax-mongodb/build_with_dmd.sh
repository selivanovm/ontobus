date
rm *.a
date
dmd src/TripleStorage.d src/Log.d src/HashMap.d src/IndexException.d src/libmongoc_headers.d -O -Hdexport -release -lib -oftrioplax-mongodb.a
date
