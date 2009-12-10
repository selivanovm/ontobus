rem date
rem dmd test_triple_storage.d HashMap.d TripleStorage.d Triple.d ListTriple.d Hash.d HashNeighbour.d KeysValueEntry.d -O -ofmytest_triple_storage
rem dmd socketserver.d ListStrings.d HashMap.d TripleStorage.d Triple.d ListTriple.d Hash.d HashNeighbour.d KeysValueEntry.d -O -oftriple_storage_server
rem dmd test_triple_storage_in_file.d Hash.d HashNeighbour.d -O -oftest_triple_storage_in_file
rem rm *.test
rem rm *.run
rem rm *.a
rem dmd src/testHashMap.d src/Log.d src/HashMap.d src/Hash.d -debug -ofhashMapDebug.test
rem dmd src/testHashMap.d src/Log.d src/HashMap.d src/Hash.d -O -release -ofhashMapRelease.test
rem date
rem dmd -Iimport src/*.d lib/librabbitmq_client.a lib/librabbitmq.a -O -release -ofTrioplaxServer.run
rem date
dmd src/TripleStorage.d src/Log.d src/HashMap.d src/Hash.d -O -Hdexport -release -lib

rem dmd Triple.d socketserver.d ListStrings.d TripleStorage.d Log.d HashMap.d Hash.d -O -release -ofFRTSServer
rem rm hashMap.log
rem rm *.o
rem date

rem dmd Triple.d test_triple_storage.d TripleStorage.d Log.d HashMap.d Hash.d libfs.a *.a libamq_common.a libamq_operate.a libamq_server.a libamq_wireapi.a libapr.a libaprutil.a libasl.a libfs.a libgsl.a libgsl3.a libicl.a libipr.a libpcre.a libsfl.a libsmt.a libsmt3.a libzip.a -O -release -oftripleStorageRelease.test