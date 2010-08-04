module n3log2mongodb;

private import tango.io.File;

private import tango.io.FileScan;
private import tango.io.Console;

private import Predicates;
private import libmongoc_headers;
private import Log;

private import tango.io.Stdout;
private import tango.stdc.string;
private import tango.time.StopWatch;
private import Text = tango.text.Util;
private import tango.core.Thread;

void main(char[][] args)
{
	char[][] i_know_predicates;

	i_know_predicates = new char[][21];

	int d = 0;

	//		 запись о праве, данная часть ACL требует переработки!

	//      - система выдающая право, "BA"/"DOCFLOW"
	i_know_predicates[d++] = AUTHOR_SYSTEM;
	//      - "user"/routeName
	i_know_predicates[d++] = AUTHOR_SUBSYSTEM;
	//		 - id user or id route.
	i_know_predicates[d++] = AUTHOR_SUBSYSTEM_ELEMENT;
	i_know_predicates[d++] = TARGET_SYSTEM; //           - система, для которой выдали права, "BA"/"DOCFLOW".

	i_know_predicates[d++] = TARGET_SUBSYSTEM; //       - "user"/"department".
	i_know_predicates[d++] = TARGET_SUBSYSTEM_ELEMENT; // - user id or department id.

	i_know_predicates[d++] = CATEGORY; //                                 - категория элемента, на который выдаются права (DOCUMENT, DOCUMENTTYPE, DICTIONARY и т. д.).
	i_know_predicates[d++] = DATE_FROM; //                                 - период действия прав (до (с возможностью указания открытых интервалов значение null)).
	i_know_predicates[d++] = DATE_TO; //                                 - период действия прав (от (с возможностью указания открытых интервалов- значение null)).
	i_know_predicates[d++] = ELEMENT_ID; //                                 - идентификатор элемента, на который выдаются права.
	i_know_predicates[d++] = RIGHTS; //                                 - "c|r|u|d"

	//		 запись о делегировании
	i_know_predicates[d++] = DELEGATION_DELEGATE; // - кому делегируют
	i_know_predicates[d++] = DELEGATION_OWNER; // - кто делегирует
	i_know_predicates[d++] = DELEGATION_WITH_TREE; // - делегировать с учетом дерева делегатов

	// document
	i_know_predicates[d++] = CREATOR; // - создатель объекта(документа, типа документа, справочника)
	i_know_predicates[d++] = SUBJECT;
	//		i_know_predicates[d++] = "magnet-ontology#typeName";

	// ORGANIZATION
	i_know_predicates[d++] = HAS_PART;
	i_know_predicates[d++] = MEMBER_OF;
	i_know_predicates[d++] = IS_ADMIN;

	i_know_predicates[d++] = DOCUMENT_TEMPLATE_ID;
        i_know_predicates[d++] = DELEGATION_DOCUMENT_ID;
	
	

	char[] root = ".";
	log.trace("Scanning '{}'", root);

	auto scan = (new FileScan)(root, ".n3");
	log.trace("\n{} Folders\n", scan.folders.length);
	foreach(folder; scan.folders)
		log.trace("{}\n", folder);
	log.trace("\n{0} Files\n", scan.files.length);

	foreach(file; scan.files)
	{
		log.trace("{}\n", file);
		load_from_file(file, i_know_predicates);
	}
	log.trace("\n{} Errors", scan.errors.length);
	foreach(error; scan.errors)
		log.trace(error);

	scan = (new FileScan)(root, ".n3log");
	log.trace("\n{} Folders\n", scan.folders.length);
	foreach(folder; scan.folders)
		log.trace("{}\n", folder);
	log.trace("\n{0} Files\n", scan.files.length);

	FilePath[] fp = scan.files;

	char[][] fp_str = new char[][fp.length];

	for(int i = 0; i < fp.length; i++)
	{
		fp_str[i] = fp[i].toString();
	}
	fp_str.sort;

	for(int i = 0; i < fp_str.length; i++)
	{
		log.trace("{}\n", fp_str[i]);
		load_from_file(new FilePath(fp_str[i]), i_know_predicates);
	}

	log.trace("\n{} Errors", scan.errors.length);
	foreach(error; scan.errors)
		log.trace(error);

	log.trace("authorization init ... ok");
	Stdout.format("authorization init.. ok").newline;

}

public void load_from_file(FilePath file_path, char[][] i_know_predicates)
{
	bson_buffer bb;
//	bson b;

	mongo_connection conn;
	mongo_connection_options opts;

	strncpy(cast(char*) opts.host, "127.0.0.1", 255);
	opts.host[254] = '\0';
	opts.port = 27017;

	if(mongo_connect(&conn, &opts))
	{
		log.trace("failed to connect tomongodb\n");
		throw new Exception("failed to connect to mongodb");
	}

	const char* col = "az1";
	const char* ns = "az1.simple";

	uint count_add_triple = 0;
	uint count_ignored_triple = 0;

	auto elapsed = new StopWatch();
	double time;
	log.trace("load triples from file {}", file_path);

	log.trace("open file");
	auto file = new File(file_path.path ~ file_path.name ~ file_path.suffix);

	auto content = cast(char[]) file.read;

	log.trace("read triples");
	elapsed.start;

	try
	{

		foreach(line; Text.lines(content))
		{
			//		log.trace("line {}", line);

			char[] s, p, o;
			char[] element;
			int idx = 0;
			char command = 'A';

			int b_pos = 0;
			uint e_pos = 0;
			for(uint i = 0; i < line.length; i++)
			{
				if(line[i] == '<' || line[i] == '"' && b_pos < e_pos)
				{
					b_pos = i;
					if(b_pos - 2 > 0 && (line[b_pos - 2] == 'A' || line[b_pos - 2] == 'D' || line[b_pos - 2] == 'U'))
					{
						command = line[b_pos - 2];
					}

				} else
				{
					if(line[i] == '>' || line[i] == '"')
					{
						e_pos = i;
						element = line[b_pos + 1 .. (e_pos + 1)];
						element[element.length - 1] = 0;
						element.length = element.length - 1;

						idx++;
						if(idx == 1)
						{
							s = element;
						}

						if(idx == 2)
						{
							p = element;
						}

						if(idx == 3)
						{
							o = element;
						}

					}
				}

			}

			//			log.trace("persistent_triple_storage: add triple [{}] <{}><{}><{}>", count_add_triple, s, p, o);

			if(s.length == 0 && p.length == 0 && o.length == 0)
				continue;

			bool i_know_predicat = false;
			for(int i = 0; i < i_know_predicates.length; i++)
			{
				if(i_know_predicates[i] !is null && p == i_know_predicates[i])
				{
					i_know_predicat = true;
					break;
				}

			}

			if(i_know_predicat)
			{
				
				//        bson_buffer_init( & bb );
				//        bson_append_string( &bb , "s" , s.ptr ); 
				//        bson_append_string( &bb , "p" , p.ptr ); 
				//        bson_append_string( &bb , "o" , o.ptr ); 

				if(command == 'A')
				{

					//        bson_append_new_oid( &bb, "_id" );                

					//        bson_from_buffer(&b, &bb);
					//        mongo_insert( &conn , ns , &b );

					//if (
					//p == AUTHOR_SYSTEM || p == AUTHOR_SUBSYSTEM || p == AUTHOR_SUBSYSTEM_ELEMENT || p == TARGET_SYSTEM || p == TARGET_SUBSYSTEM || 
					//p == TARGET_SUBSYSTEM_ELEMENT || p == CATEGORY || p == DATE_FROM || p == DATE_TO || p == ELEMENT_ID || p == RIGHTS
					//)			
					if (s == "6fdfa6c238d603a0")
					{
						Cout ("persistent_triple_storage: add triple <" ~ s ~ "><" ~ p ~ ">\"" ~ o ~ "\"").newline;
						Cin.get();						
					}
					
					{

						bson op;
						bson cond;

						bson_buffer_init(&bb);
						bson_append_string(&bb, "ss", s.ptr);
						bson_from_buffer(&cond, &bb);

						if(p == HAS_PART)
						{
							bson_buffer_init(&bb);
							bson_buffer* sub = bson_append_start_object(&bb,
									"$addToSet");
							bson_append_string(sub, p.ptr, o.ptr);
							bson_append_finish_object(sub);
							bson_from_buffer(&op, &bb);
						} else
						{
							bson_buffer_init(&bb);
							bson_buffer* sub = bson_append_start_object(&bb,
									"$set");
							bson_append_string(sub, p.ptr, o.ptr);
							bson_append_finish_object(sub);
							bson_from_buffer(&op, &bb);
						}

						mongo_update(&conn, ns, &cond, &op, 1);

						bson_destroy(&cond);
						bson_destroy(&op);

						log.trace(
								"persistent_triple_storage: add triple [{}] <{}> <{}> \"{}\" .",
								count_add_triple, s, p, o);
					}

					//					log.trace("persistent_triple_storage: add triple [{}] <{}><{}><{}>", count_add_triple, s, p, o);

					count_add_triple++;

					if(count_add_triple % 12345 == 0)
						Stdout.format("count load triples {} {}", count_add_triple, file_path).newline;
					/*
					 else
					 {
					 log.trace("!!! triple [{}] <{}><{}><{}> not added. result = {}", count_add_triple, s, p, o, result);

					 count_ignored_triple++;
					 }
					 */
				}
				if(command == 'D')
				{
					//        bson_append_bool( &bb , "$atomic" , true ); 
					//        bson_from_buffer(&b, &bb);
					//    mongo_remove(&conn, ns, &b);

					//if (
					//p == AUTHOR_SYSTEM || p == AUTHOR_SUBSYSTEM || p == AUTHOR_SUBSYSTEM_ELEMENT || p == TARGET_SYSTEM || p == TARGET_SUBSYSTEM || 
					//p == TARGET_SUBSYSTEM_ELEMENT || p == CATEGORY || p == DATE_FROM || p == DATE_TO || p == ELEMENT_ID || p == RIGHTS
					//)	

					if (s == "6fdfa6c238d603a0")
					{
						Cout ("persistent_triple_storage: remove triple <" ~ s ~ "><" ~ p ~ ">\"" ~ o ~ "\"").newline;
						Cin.get();						
					}

					{
						bson op;
						bson cond;

						bson_buffer_init(&bb);
						bson_append_string(&bb, "ss", s.ptr);
						bson_from_buffer(&cond, &bb);

						bson_buffer_init(&bb);

						bson_buffer* sub;

						if(p == HAS_PART)
						{
							sub = bson_append_start_object(&bb, "$pull");
							bson_append_int(sub, p.ptr, 1);
							log.trace("$pull {}", p);
						} else
						{
							sub = bson_append_start_object(&bb, "$unset");
							bson_append_int(sub, p.ptr, 1);
							log.trace("$unset {}", p);
						}

						bson_append_finish_object(sub);

						bson_from_buffer(&op, &bb);

						mongo_update(&conn, ns, &cond, &op, 0);
						
						bson_destroy(&cond);
						bson_destroy(&op);
						
						Thread.sleep(0.011);
						// не всегда удаляется ? возможно если очень быстро удалять												
					}

					Stdout.format ("\npersistent_triple_storage: remove triple [{}] <{}> <{}> \"{}\" .",
							count_add_triple, s, p, o);
					log.trace("persistent_triple_storage: remove triple [{}] <{}> <{}> \"{}\"",
							count_add_triple, s, p, o);
				}

			} else
			{
				count_ignored_triple++;
			}

			//				if(count_add_triple > 5)
			//					break;
			//        bson_destroy(&b);

		}

	} catch(Exception ex)
	{
		log.trace("fail load triples, count loaded {}", count_add_triple);
		throw ex;
	}
	//	

	time = elapsed.stop;

	log.trace(
			"end read triples, total time = {}, count add triples = {}, ignored = {}",
			time, count_add_triple, count_ignored_triple);

	mongo_destroy(&conn);

}
