date
rm n3log2mongodb
dmd src/*.d lib/libmongoc.a -O -inline -release -ofn3log2mongodb
rm *.log
rm *.o
date

