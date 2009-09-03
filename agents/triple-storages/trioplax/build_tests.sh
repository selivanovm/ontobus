date
rm *.test
dmd -version=tango_99_7 src/test/testTripleStorage.d src/test/fact_tools.d src/Log.d src/TripleStorage.d src/HashMap.d src/Hash.d -O -debug -ofTripleStorage.test
dmd -version=tango_99_7 src/test/testHashMap.d src/test/fact_tools.d src/Log.d src/HashMap.d src/Hash.d -O -debug -ofHashMap.test
rm hashMap.log
rm *.o
date
