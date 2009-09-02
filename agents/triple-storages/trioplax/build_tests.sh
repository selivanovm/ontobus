date
rm *.test
dmd src/test/testTripleStorage.d src/Log.d src/TripleStorage.d src/HashMap.d src/Hash.d -O -debug -ofTripleStorage.test
dmd src/test/testHashMap.d src/Log.d src/HashMap.d src/Hash.d -O -debug -ofHashMap.test
rm hashMap.log
rm *.o
date
