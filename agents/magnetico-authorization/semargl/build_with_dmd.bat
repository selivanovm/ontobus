rem date
del *.test
del *.agent
del *.exe

dmd -version=tango_99_8 -Iexport C:\tango-0.99.8-bin-win32-dmd.1.041\import/tango/net/InternetAddress C:\tango-0.99.8-bin-win32-dmd.1.041\import/tango/net/Socket C:\tango-0.99.8-bin-win32-dmd.1.041\import/tango/stdc/stdarg.d C:\tango-0.99.8-bin-win32-dmd.1.041\import/tango/stdc/errno.d -Iimport src\authorization.d src\autotest.d src\category.d src\fact_tools.d src\Log.d src\mom_client.d src\persistent_triple_storage.d src\portions_read.d src\RightTypeDef.d src\script_util.d src\server.d src\mod\tango\io\device\Conduit.d src\mod\tango\io\device\Device.d src\mod\tango\io\device\File.d src\scripts\S01AllLoggedUsersCanCreateDocuments.d src\scripts\S01UserIsAdmin.d src\scripts\S05InDocFlow.d src\scripts\S09DocumentOfTemplate.d src\scripts\S10UserIsAuthorOfDocument.d src\scripts\S10UserIsPermissionTargetAuthor.d src\scripts\S11ACLRightsHierarhical.d lib/librabbitmq_client.lib lib/librabbitmq.lib lib/TripleStorage.lib -O -release -ofSemargl.exe

rem dmd src/Triple.d src/TripleStorage.d src/Log.d src/HashMap.d src/Hash.d src/librabbitmq_headers.d src/librabbitmq_listen.d src/server.d lib/librabbitmq.a -O -release -ofSemargl.agent

del *.log
del *.o
rem date

rem src\authorization.d src\autotest.d src\category.d src\fact_tools.d src\Log.d src\mom_client.d src\persistent_triple_storage.d src\portions_read.d src\RightTypeDef.d src\script_util.d src\server.d
rem src\mod\tango\io\device\Conduit.d src\mod\tango\io\device\Device.d src\mod\tango\io\device\File.d
rem src\scripts\S01AllLoggedUsersCanCreateDocuments.d src\scripts\S01UserIsAdmin.d src\scripts\S05InDocFlow.d src\scripts\S09DocumentOfTemplate.d src\scripts\S10UserIsAuthorOfDocument.d src\scripts\S10UserIsPermissionTargetAuthor.d src\scripts\S11ACLRightsHierarhical.d