del *.obj
del *.map
del *.exe
SET tango=C:\tango-0.99.8-bin-win32-dmd.1.041

dmd -version=tango_99_8 %tango%\import\tango\net\InternetAddress %tango%\import\tango\net\Socket %tango%\import\tango\stdc\stdarg.d %tango%\import\tango\stdc\errno.d -Iimport\other -Iimport\trioplax src\predicates.d src\authorization.d src\autotest.d src\category.d src\fact_tools.d src\Log.d src\mom_client.d src\persistent_triple_storage.d src\portions_read.d src\RightTypeDef.d src\script_util.d src\server.d src\mod\tango\io\device\Conduit.d src\mod\tango\io\device\Device.d src\mod\tango\io\device\File.d src\scripts\S01AllLoggedUsersCanCreateDocuments.d src\scripts\S01UserIsAdmin.d src\scripts\S05InDocFlow.d src\scripts\S09DocumentOfTemplate.d src\scripts\S10UserIsAuthorOfDocument.d src\scripts\S10UserIsPermissionTargetAuthor.d src\scripts\S11ACLRightsHierarhical.d lib\librabbitmq_client.lib lib\librabbitmq.lib lib\TripleStorage.lib -O -inline -release -ofSemargl-in-memory.exe

dmd -version=tango_99_8 %tango%\import\tango\net\InternetAddress %tango%\import\tango\net\Socket %tango%\import\tango\stdc\stdarg.d %tango%\import\tango\stdc\errno.d -Iimport\other -Iimport\trioplax-mongodb -Iimport/mongo-d-driver src\predicates.d src\authorization.d src\autotest.d src\category.d src\fact_tools.d src\Log.d src\mom_client.d src\persistent_triple_storage.d src\portions_read.d src\RightTypeDef.d src\script_util.d src\server.d src\mod\tango\io\device\Conduit.d src\mod\tango\io\device\Device.d src\mod\tango\io\device\File.d src\scripts\S01AllLoggedUsersCanCreateDocuments.d src\scripts\S01UserIsAdmin.d src\scripts\S05InDocFlow.d src\scripts\S09DocumentOfTemplate.d src\scripts\S10UserIsAuthorOfDocument.d src\scripts\S10UserIsPermissionTargetAuthor.d src\scripts\S11ACLRightsHierarhical.d lib\librabbitmq_client.lib lib\librabbitmq.lib lib\libmongod.lib lib\trioplax-mongodb.lib -O -inline -release -ofSemargl-on-mongodb.exe

del *.log
del *.obj
del *.map
