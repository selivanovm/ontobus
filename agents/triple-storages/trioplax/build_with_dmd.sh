rm *.a
src=src/trioplax/memory
general_src=src/trioplax

dmd $general_src/triple.d $general_src/TripleStorage.d $src/Hash.d $src/HashMap.d $src/Log.d $src/IndexException.d $src/TripleStorageMemory.d -O -Hdexport/trioplax/memory -release -lib -oftrioplax-memory

src=src/trioplax/mongodb
dmd -Iimport/libmongod $general_src/triple.d $general_src/TripleStorage.d $src/Log.d $src/TripleStorageMongoDB.d -O -Hdexport/trioplax/mongodb -release -lib -oftrioplax-mongodb

rm *.o