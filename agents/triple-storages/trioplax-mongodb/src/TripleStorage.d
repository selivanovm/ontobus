module TripleStorage;

private import tango.io.Stdout;
private import tango.stdc.string;
private import tango.stdc.stringz;
private import tango.stdc.stdlib: calloc;

private import HashMap;
private import Log;

private import Integer = tango.text.convert.Integer;
private import tango.io.FileConduit;
private import tango.time.WallClock;
private import tango.time.Clock;
private import tango.text.locale.Locale;

private Locale layout;

private import libmongoc_headers;
private import tango.stdc.stdlib: calloc, free;

enum idx_name
{
	S = (1 << 0),
	P = (1 << 1),
	O = (1 << 2),
	SP = (1 << 3),
	PO = (1 << 4),
	SO = (1 << 5),
	SPO = (1 << 6),
	S1PPOO = (1 << 7)
};

class TripleStorage
{
	private char[] buff = null;
	const char* col = "az1";
	const char* ns = "az1.simple";

	private bool[char[]] predicate_as_multiple;

	public bool log_query = false;

	mongo_connection conn;

	this(uint max_count_element, uint max_length_order, uint inital_triple_area_length)
	{
		layout = new Locale;
		buff = new char[32];

		mongo_connection_options opts;

		strncpy(cast(char*) opts.host, "127.0.0.1", 255);
		opts.host[254] = '\0';
		opts.port = 27017;

		if(mongo_connect(&conn, &opts))
		{
			log.trace("failed to connect tomongodb");
			throw new Exception("failed to connect to mongodb");
		}
		log.trace("connect tomongodb sucessful");
	}

	public void define_predicate_as_multiple(char[] predicate)
	{
		predicate_as_multiple[predicate] = true;

		log.trace("define predicate [{}] as multiple", predicate);
	}

	public void list_no_longer_required(triple_list_element* first_element_of_list)
	{
		/*        triple_list_element* list_iterator = first_element_of_list;
		 while(list_iterator !is null)
		 {
		 Triple* triple = list_iterator.triple;
		 
		 if (triple.s !is null)
		 free (triple.s);

		 if (triple.p !is null)
		 free (triple.p);

		 if (triple.o !is null)
		 free (triple.o);

		 free (cast (void *)triple);

		 free (cast (void *)list_iterator);
		 
		 list_iterator = list_iterator.next_triple_list_element;
		 }        */
	}

	public void set_new_index(ubyte index, uint max_count_element, uint max_length_order,
			uint inital_triple_area_length)
	{
	}

	public void set_stat_info_logging(bool flag)
	{
	}

	public void setPredicatesToS1PPOO(char[] P1, char[] P2, char[] _store_predicate_in_list_on_idx_s1ppoo)
	{
	}

	public triple_list_element* getTriplesUseIndex(char* s, char* p, char* o, ubyte useindex)
	{

		//		log.trace("getTriplesUseIndex #1 [{}] [{}] [{}]", fromStringz(s), fromStringz(p), fromStringz(o));

		bson_buffer bb;
		bson b;

		bson_buffer_init(&bb);

		if(s !is null)
			bson_append_string(&bb, "mo/at/acl#tgSsE", p);

		if(p !is null)
			bson_append_string(&bb, "mo/at/acl#eId", o);

		bson_from_buffer(&b, &bb);

		mongo_cursor* cursor = mongo_find(&conn, ns, &b, null, 0, 0, 0);

		//		log.trace("getTriplesUseIndex #2");

		triple_list_element* list = null;
		triple_list_element* next_element = null;
		triple_list_element* prev_element = null;

		while(mongo_cursor_next(cursor))
		{
			//			log.trace("getTriplesUseIndex #3");
			bson_iterator it;
			bson_iterator_init(&it, cursor.current.data);

			char* ts = null;
			char* tp = cast(char*) calloc(byte.sizeof, "mo/at/acl#rt".length + 1);
			strncpy(tp, "mo/at/acl#rt".ptr, "mo/at/acl#rt".length);
			char* to = null;

			while(bson_iterator_next(&it))
			{

				char* name_key = bson_iterator_key(&it);

				switch(bson_iterator_type(&it))
				{
					case bson_type.bson_string:

						//						log.trace("getTriplesUseIndex #4");
						char* value = bson_iterator_string(&it);
						int len = strlen(value);

						//						if(len > 0)
						{
							//						printf("(string) \"%s \" %d\n", value, len);

							if(strcmp(name_key, "ss".ptr) == 0)
							{
								ts = cast(char*) calloc(byte.sizeof, len + 1);
								strcpy(ts, value);
							} else if(strcmp(name_key, "mo/at/acl#rt".ptr) == 0)
							{
								to = cast(char*) calloc(byte.sizeof, len + 1);
								strcpy(to, value);
							}
						}

					break;
					default:
					break;
				}
			}

			next_element = cast(triple_list_element*) calloc(triple_list_element.sizeof, 1);

			if(prev_element !is null)
			{
				prev_element.next_triple_list_element = next_element;
			}

			prev_element = next_element;
			if(list is null)
			{
				list = next_element;
			}

			Triple* triple = cast(Triple*) calloc(Triple.sizeof, 1);
			triple.s = ts;
			triple.p = tp;
			triple.o = to;

			next_element.triple = triple;
			//			log.trace("get #9, list[{:X4}], triple[{:X4}], triple.o[{:X4}]", &list, triple, triple.o);

			//			log.trace("get:result <{}> <{}> \"{}\"", ts, tp, to);
		}

		if(log_query == true)
			logging_query("GET USE INDEX", s, p, o, list);

		mongo_cursor_destroy(cursor);
		return list;
	}

	public triple_list_element* getTriples(char* s, char* p, char* o)
	{

		char ss[];
		char pp[];
		char oo[];

		if(s !is null)
		{
			ss = fromStringz(s);
			//			log.trace("GET TRIPLES #0 len(s)={}", strlen(s));
		}

		if(p !is null)
		{
			pp = fromStringz(p);
			//			log.trace("GET TRIPLES #0 len(p)={}", strlen(p));
		}

		if(o !is null)
		{
			oo = fromStringz(o);
			//			log.trace("GET TRIPLES #0, len(o)={}", strlen(o));
		}

		//		log.trace("GET TRIPLES <{}> <{}> \"{}\"", ss, pp, oo);

		bson_buffer bb, bb2;
		bson query;
		bson fields;

		bson_buffer_init(&bb2);
		bson_buffer_init(&bb);

		if(s !is null)
		{
			bson_append_string(&bb, "ss", s);
			//			bson_append_int(&bb2, "ss", 1);
		}

		if(p !is null && o !is null)
		{
			bson_append_string(&bb, p, o);
			//			bson_append_int(&bb2, p, 1);
		}

		//		log.trace("GET TRIPLES #4");
		bson_from_buffer(&query, &bb);
		//		bson_from_buffer(&fields, &bb2);

		//		log.trace("GET TRIPLES #5");
		triple_list_element* list = null;
		triple_list_element* next_element = null;
		triple_list_element* prev_element = null;

		//		log.trace("GET TRIPLES #6");
		mongo_cursor* cursor = mongo_find(&conn, ns, &query, &fields, 0, 0, 0);

		//		log.trace("GET TRIPLES #7");
		while(mongo_cursor_next(cursor))
		{
			bson_iterator it;
			bson_iterator_init(&it, cursor.current.data);

			char* ts = null;
			char* tp = null;
			char* to = null;

			//			log.trace("GET TRIPLES #8");

			while(bson_iterator_next(&it))
			{

				char* name_key = bson_iterator_key(&it);

				switch(bson_iterator_type(&it))
				{
					case bson_type.bson_string:

						char* value = bson_iterator_string(&it);
						int len = strlen(value);

						//						if(len > 0)
						{
							//							log.trace("name_key=[{}], value=[{}], len={}", fromStringz(name_key), fromStringz(value),
							//									len);

							if(strcmp(name_key, "ss".ptr) == 0)
							{
								ts = cast(char*) calloc(byte.sizeof, len + 1);
								strcpy(ts, value);
							} else if(p !is null && strcmp(name_key, p) == 0)
							{
								to = cast(char*) calloc(byte.sizeof, len + 1);
								strcpy(to, value);
							} else if(p is null)
							{
								ts = cast(char*) calloc(byte.sizeof, strlen(s) + 1);
								strcpy(ts, s);

								tp = cast(char*) calloc(byte.sizeof, strlen(name_key) + 1);
								strcpy(tp, name_key);

								to = cast(char*) calloc(byte.sizeof, len + 1);
								strcpy(to, value);

								if(ts !is null && tp !is null && to !is null)
								{
									//									log.trace("GET TRIPLES #9-0");

									next_element = cast(triple_list_element*) calloc(triple_list_element.sizeof, 1);

									if(prev_element !is null)
									{
										prev_element.next_triple_list_element = next_element;
									}

									prev_element = next_element;
									if(list is null)
									{
										list = next_element;
									}

									//			log.trace("GET TRIPLES #10");

									Triple* triple = cast(Triple*) calloc(Triple.sizeof, 1);
									triple.s = ts;
									triple.p = tp;
									triple.o = to;

									next_element.triple = triple;
									//			log.trace("get #11, list[{:X4}], triple[{:X4}]", list, triple);

									//									log.trace("get:result <{}> <{}> \"{}\"", fromStringz(ts), fromStringz(tp),
									//											fromStringz(to));
								}
							}
						}

					break;

					case bson_type.bson_array:

						bson_iterator sub_it;
						bson_iterator_subiterator(&it, &sub_it);

						while(bson_iterator_next(&sub_it))
						{
							switch(bson_iterator_type(&sub_it))
							{
								case bson_type.bson_string:

									char* value = bson_iterator_string(&sub_it);
									int len = strlen(value);

									if(len > 0)
									{
										//										log.trace("sub:name_key=[{}], value=[{}], len={}", fromStringz(name_key),
										//												fromStringz(value), len);
									}

								break;

								default:
								break;
							}

						}

					break;

					default:
					break;
				}
			}

			if(p !is null)
			{
				tp = cast(char*) calloc(byte.sizeof, strlen(p) + 1);
				strcpy(tp, p);

				if(o !is null)
				{
					to = cast(char*) calloc(byte.sizeof, strlen(o) + 1);
					strcpy(to, o);
				}

				if(ts !is null && tp !is null && to !is null)
				{
					//					log.trace("GET TRIPLES #9");

					next_element = cast(triple_list_element*) calloc(triple_list_element.sizeof, 1);

					if(prev_element !is null)
					{
						prev_element.next_triple_list_element = next_element;
					}

					prev_element = next_element;
					if(list is null)
					{
						list = next_element;
					}

					//			log.trace("GET TRIPLES #10");

					Triple* triple = cast(Triple*) calloc(Triple.sizeof, 1);
					triple.s = ts;
					triple.p = tp;
					triple.o = to;

					next_element.triple = triple;
					//			log.trace("get #11, list[{:X4}], triple[{:X4}]", list, triple);

					//					log.trace("get:result <{}> <{}> \"{}\"", fromStringz(ts), fromStringz(tp), fromStringz(to));
				}
			}
		}

		mongo_cursor_destroy(cursor);
		bson_destroy(&fields);
		bson_destroy(&query);

		if(log_query == true)
			logging_query("GET", s, p, o, list);

		return list;
	}

	private void logging_query(char[] op, char* s, char* p, char* o, triple_list_element* list)
	{
		char[] a_s = "";
		char[] a_p = "";
		char[] a_o = "";

		if(s !is null)
			a_s = "S";

		if(p !is null)
			a_p = "P";

		if(o !is null)
			a_o = "O";

		int count = get_count_form_list_triple(list);

		auto style = File.ReadWriteOpen;
		style.share = File.Share.Read;
		style.open = File.Open.Append;
		File log_file = new File("triple-storage-io", style);

		auto tm = WallClock.now;
		auto dt = Clock.toDate(tm);
		log_file.output.write(layout("{:yyyy-MM-dd HH:mm:ss},{} ", tm, dt.time.millis));

		log_file.output.write(
				"\n" ~ op ~ " FROM INDEX " ~ a_s ~ a_p ~ a_o ~ " s=[" ~ fromStringz(s) ~ "] p=[" ~ fromStringz(p) ~ "] o=[" ~ fromStringz(
						o) ~ "] " ~ Integer.format(buff, count) ~ "\n");

		print_list_triple_to_file(log_file, list);

		log_file.close();

	}

	public bool removeTriple(char[] s, char[] p, char[] o)
	{
		if(s is null || p is null || o is null)
		{
			throw new Exception("remove triple:s is null || p is null || o is null");
		}

		//		log.trace("remove! #1");

		bson_buffer bb;
		bson query;
		bson fields;
		bson record;

		bson_buffer_init(&bb);
		//		log.trace("remove! #2");

		bson_append_string(&bb, "ss", s.ptr);
		bson_append_string(&bb, p.ptr, o.ptr);
		bson_from_buffer(&query, &bb);
		mongo_cursor* cursor = mongo_find(&conn, ns, &query, &fields, 0, 0, 0);

		//		log.trace("remove! #3");

		if(mongo_cursor_next(cursor))
		{
			bson_iterator it;
			bson_iterator_init(&it, cursor.current.data);
			switch(bson_iterator_type(&it))
			{
				case bson_type.bson_string:

					log.trace("remove! string");

				break;

				case bson_type.bson_array:

					log.trace("remove! array");

				break;

				default:
				break;
			}

		} else
		{
			throw new Exception("remove triple <" ~ s ~ "><" ~ p ~ ">\"" ~ o ~ "\": triple not found");
		}

		mongo_cursor_destroy(cursor);
		bson_destroy(&fields);
		bson_destroy(&query);

		//		bson_buffer bb;
//		bson b;
		{

			bson op;
			bson cond;

			bson_buffer_init(&bb);
			bson_append_string(&bb, "ss".ptr, s.ptr);
			bson_from_buffer(&cond, &bb);

			//			if(p == HAS_PART)
			//			{
			//				bson_buffer_init(&bb);
			//				bson_buffer* sub = bson_append_start_object(&bb,
			//						"$pull");
			//				bson_append_int(sub, p.ptr, 1);
			//				bson_append_finish_object(sub);
			//			} else
			{
				bson_buffer_init(&bb);
				bson_buffer* sub = bson_append_start_object(&bb, "$unset");
				bson_append_int(sub, p.ptr, 1);
				bson_append_finish_object(sub);
			}

			bson_from_buffer(&op, &bb);
			mongo_update(&conn, ns, &cond, &op, 0);

			bson_destroy(&cond);
			bson_destroy(&op);
		}

		if(log_query == true)
			logging_query("REMOVE", s.ptr, p.ptr, o.ptr, null);

		return true;
	}

	bool f_trace_addTriple = false;

	public int addTriple(char[] s, char[] p, char[] o)
	{
		bson_buffer bb;

		bson op;
		bson cond;

		bson_buffer_init(&bb);
		bson_append_string(&bb, "ss", s.ptr);
		bson_from_buffer(&cond, &bb);
		
		if((p in predicate_as_multiple) !is null)
		{
			bson_buffer_init(&bb);
			bson_buffer* sub = bson_append_start_object(&bb, "$addToSet");
			bson_append_string(sub, p.ptr, o.ptr);
			bson_append_finish_object(sub);
			bson_from_buffer(&op, &bb);
		}
		else	
		{
			bson_buffer_init(&bb);
			bson_buffer* sub = bson_append_start_object(&bb, "$set");
			bson_append_string(sub, p.ptr, o.ptr);
			bson_append_finish_object(sub);
			bson_from_buffer(&op, &bb);
		}

		mongo_update(&conn, ns, &cond, &op, 1);

		bson_destroy(&cond);
		bson_destroy(&op);
		return 0;
	}

	public void print_stat()
	{
	}

	public void print_list_triple_to_file(File log_file, triple_list_element* list_iterator)
	{
		Triple* triple;
		if(list_iterator !is null)
		{
			while(list_iterator !is null)
			{
				//				log.trace("#KKK {:X4} {:X4} {:X4}", list_iterator, *list_iterator, *(list_iterator + 1));

				triple = list_iterator.triple;
				if(triple !is null)
				{
					char[] triple_str = triple_to_string(triple);
					log_file.output.write(triple_str);
				}

				list_iterator = list_iterator.next_triple_list_element;
			}
		}
	}

	public void print_list_triple(triple_list_element* list_iterator)
	{
		Triple* triple;
		if(list_iterator !is null)
		{
			while(list_iterator !is null)
			{
				//				log.trace("#KKK {:X4} {:X4} {:X4}", list_iterator, *list_iterator, *(list_iterator + 1));

				triple = list_iterator.triple;
				if(triple !is null)
					print_triple(triple);

				list_iterator = list_iterator.next_triple_list_element;
			}
		}
	}

	public int get_count_form_list_triple(triple_list_element* list_iterator)
	{
		int count;
		Triple* triple;
		if(list_iterator !is null)
		{
			while(list_iterator !is null)
			{
				triple = list_iterator.triple;
				if(triple !is null)
				{
					count++;
				}

				list_iterator = list_iterator.next_triple_list_element;
			}
		}
		return count;
	}

	public void print_triple(Triple* triple)
	{
		if(triple is null)
			return;

		log.trace("triple: <{}><{}>\"{}\"", fromStringz(triple.s), fromStringz(triple.p), fromStringz(triple.o));
	}

	public char[] triple_to_string(Triple* triple)
	{
		if(triple is null)
			return "";

		return "<" ~ fromStringz(triple.s) ~ "> <" ~ fromStringz(triple.p) ~ "> \"" ~ fromStringz(triple.o) ~ "\".\n";
	}

}
