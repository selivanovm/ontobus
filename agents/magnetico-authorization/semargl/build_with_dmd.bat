del *.obj
del *.map
del *.exe
SET tango=C:\tango-0.99.8-bin-win32-dmd.1.041

dmd -version=tango_99_8 %tango%\import\tango\net\InternetAddress %tango%\import\tango\net\Socket %tango%\import\tango\stdc\stdarg.d %tango%\import\tango\stdc\errno.d -Iimport\other -Iimport\trioplax src\predicates.d src\authorization.d src\autotest.d src\category.d src\fact_tools.d src\Log.d src\mom_client.d src\persistent_triple_storage.d src\portions_read.d src\RightTypeDef.d src\script_util.d src\server.d src\mod\tango\io\device\Conduit.d src\mod\tango\io\device\Device.d src\mod\tango\io\device\File.d src\scripts\S01AllLoggedUsersCanCreateDocuments.d src\scripts\S01UserIsAdmin.d src\scripts\S05InDocFlow.d src\scripts\S09DocumentOfTemplate.d src\scripts\S10UserIsAuthorOfDocument.d src\scripts\S10UserIsPermissionTargetAuthor.d src\scripts\S11ACLRightsHierarhical.d lib\librabbitmq_client.lib lib\librabbitmq.lib lib\TripleStorage.lib -O -inline -release -ofSemargl-in-memory.exe

rem dmd -version=tango_99_8 /usr/include/d/tango-dmd/tango/net/InternetAddress /usr/include/d/tango-dmd/tango/net/Socket /usr/include/d/tango-dmd/tango/stdc/stdarg.d /usr/include/d/tango-dmd/tango/stdc/errno.d -Iimport/other -Iimport/trioplax-mongodb src/*.d src/mod/tango/io/device/*.d src/scripts/*.d lib/mom_client.lib lib/librabbitmq_client.lib lib/librabbitmq.lib lib/trioplax-mongodb.lib lib/libdbus_client.lib lib/libdbus-1.lib lib/libmongoc.lib -O -inline -release -ofSemargl-on-mongodb.exe

del *.log
del *.obj
del *.map
