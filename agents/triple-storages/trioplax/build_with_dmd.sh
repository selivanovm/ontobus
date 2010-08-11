rm *.a
src=src/trioplax/memory
general_src=src/trioplax

dmd -Iimport/libmongod $general_src/Log.d $general_src/triple.d $general_src/TripleStorage.d $src/Hash.d $src/TripleHashMap.d $src/IndexException.d $src/TripleStorageMemory.d \
$general_src/mongodb/TripleStorageMongoDB.d -O -Hdexport/trioplax -release -lib -oftrioplax


rm *.o