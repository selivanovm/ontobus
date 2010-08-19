module trioplax.memory.TripleStorageMemory;

private import tango.io.Stdout;
private import tango.stdc.string;
private import tango.stdc.stringz;

private import Integer = tango.text.convert.Integer;
private import tango.io.device.File;
private import tango.time.WallClock;
private import tango.time.Clock;
private import tango.text.locale.Locale;

private import trioplax.Log;
private import trioplax.triple;
private import trioplax.TripleStorage;

private import trioplax.memory.HashMap;
private import trioplax.memory.IndexException;

private Locale layout;

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

class TripleStorageMemory: TripleStorage
{
	private char[] buff = null;

	private bool log_query = false;
	//	public bool INFO_stat_get_triples = true;
	private bool log_stat_info = true;

	public bool INFO_remove_triple_from_list = false;
	private bool f_init_debug = false;

	private HashMap idx_s = null;
	private HashMap idx_p = null;
	private HashMap idx_o = null;
	private HashMap idx_sp = null;
	private HashMap idx_po = null;
	private HashMap idx_so = null;
	private HashMap idx_spo = null;
	private HashMap idx_s1ppoo = null;

	private char[][16] look_predicate_p1_on_idx_s1ppoo;
	private char[][16] look_predicate_p2_on_idx_s1ppoo;
	private char[][16] look_predicate_pp_on_idx_s1ppoo;
	private char[][16] store_predicate_in_list_on_idx_s1ppoo;
	private uint count_look_predicate_on_idx_s1ppoo = 0;

	private char* idx;

	private char[] cat_buff1;
	private char[] cat_buff2;

	private int dummy;

	private bool[char[]] predicate_as_multiple;

	this(int max_count_element, uint max_length_order, uint inital_triple_area_length)
	{
		layout = new Locale;

		cat_buff1 = new char[64 * 1024];
		cat_buff2 = new char[64 * 1024];
		buff = new char[32];

		if(f_init_debug)
			log.trace("create idx_spo...");
		// создается всегда, потому как является особенным индексом, хранящим экземпляры триплетов
		idx_spo = new HashMap("SPO", max_count_element, inital_triple_area_length, max_length_order);
		if(f_init_debug)
			log.trace("ok");
	}

	public void set_log_query_mode(bool on_off)
	{
		log_query = on_off;
	}

	public void define_predicate_as_multiple(char[] predicate)
	{
		predicate_as_multiple[predicate] = true;

		log.trace("define predicate [{}] as multiple", predicate);
	}

	public void list_no_longer_required(triple_list_element* first_element_of_list)
	{
	}

	public void release_all_lists()
	{
	}

	public void set_new_index(ubyte index, uint max_count_element, uint max_length_order, uint inital_triple_area_length)
	{
		if(index & idx_name.S)
		{
			if(idx_s is null)
				idx_s = new HashMap("S", max_count_element, inital_triple_area_length, max_length_order);
			return;
		}

		if(index & idx_name.P)
		{
			if(idx_p is null)
				idx_p = new HashMap("P", max_count_element, inital_triple_area_length, max_length_order);
			return;
		}

		if(index & idx_name.O)
		{
			if(idx_o is null)
				idx_o = new HashMap("O", max_count_element, inital_triple_area_length, max_length_order);
			return;
		}

		if(index & idx_name.SP)
		{
			if(idx_sp is null)
				idx_sp = new HashMap("SP", max_count_element, inital_triple_area_length, max_length_order);
			return;
		}

		if(index & idx_name.PO)
		{
			if(idx_po is null)
				idx_po = new HashMap("PO", max_count_element, inital_triple_area_length, max_length_order);
			return;
		}

		if(index & idx_name.SO)
		{
			if(idx_so is null)
				idx_so = new HashMap("SO", max_count_element, inital_triple_area_length, max_length_order);
			return;
		}

		if(index & idx_name.S1PPOO)
		{
			if(idx_s1ppoo is null && idx_sp !is null)
				idx_s1ppoo = new HashMap("S1PPOO", max_count_element, inital_triple_area_length, max_length_order);

			if(idx_sp is null)
				log.trace("for index S1PPOO need index SP");

			return;
		}

	}

	public void set_stat_info_logging(bool flag)
	{
		log_stat_info = flag;
	}

	public void setPredicatesToS1PPOO(char[] P1, char[] P2, char[] _store_predicate_in_list_on_idx_s1ppoo)
	{
		//		log.trace ("#0");		
		look_predicate_p1_on_idx_s1ppoo[count_look_predicate_on_idx_s1ppoo] = P1;
		look_predicate_p2_on_idx_s1ppoo[count_look_predicate_on_idx_s1ppoo] = P2;
		look_predicate_pp_on_idx_s1ppoo[count_look_predicate_on_idx_s1ppoo] = P1 ~ P2;
		store_predicate_in_list_on_idx_s1ppoo[count_look_predicate_on_idx_s1ppoo] = _store_predicate_in_list_on_idx_s1ppoo;
		count_look_predicate_on_idx_s1ppoo++;
	}

	public triple_list_element* getTriplesUseIndexS1PPOO(char* s, char* p, char* o)
	{
		triple_list_element* list = idx_s1ppoo.get(s, p, o, dummy);

		if(log_query == true)
			logging_query("GET USE INDEX", s, p, o, list);

		return list;
	}

	public triple_list_element* getTriples(char* s, char* p, char* o)
	{
		bool debug_info = false;

		//log.trace("### getTriples2");
		triple_list_element* list = null;

		if(s != null)
		{
			if(p != null)
			{
				if(o != null)
				{
					// spo
					if(idx_spo !is null)
						list = idx_spo.get(s, p, o, dummy);
				}
				else
				{
					// sp
					if(idx_sp !is null)
						list = idx_sp.get(s, p, null, dummy);
				}
			}
			else
			{
				if(o != null)
				{
					// so
					if(idx_so !is null)
						list = idx_so.get(s, o, null, dummy);
				}
				else
				{
					// s
					if(idx_s !is null)
						list = idx_s.get(s, null, null, dummy);
				}

			}
		}
		else
		{
			if(p != null)
			{
				if(o != null)
				{
					if(idx_po !is null)
						list = idx_po.get(p, o, null, dummy);
				}
				else
				{
					// p
					if(idx_p !is null)
						list = idx_p.get(p, null, null, dummy);
				}
			}
			else
			{
				if(o != null)
				{
					// o
					if(idx_o !is null)
						list = idx_o.get(o, null, null, dummy);
				}
				else
				{
					log.trace("getTriples:TripleStorage unknown index !!!");
				}

			}
		}

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
				"\n" ~ op ~ " s=[" ~ fromStringz(s) ~ "] p=[" ~ fromStringz(p) ~ "] o=[" ~ fromStringz(o) ~ "] " ~ Integer.format(buff,
						count) ~ "\n");

		print_list_triple_to_file(log_file, list);

		log_file.close();

	}

	public bool removeTriple(char[] s, char[] p, char[] o)
	{
		if(s.length == 0 && p.length == 0 && o.length == 0)
		{
			INFO_remove_triple_from_list = false;
			return false;
		}

		//do_things(o);

		if(s is null && p is null && o is null)
		{
			INFO_remove_triple_from_list = false;
			return false;
		}

		//		log.trace("");
		//		log.trace("remove triple <{}><{}>\"{}\"", s, p, o);

		Triple* removed_triple;

		triple_list_element* list_iterator = idx_spo.get(s.ptr, p.ptr, o.ptr, dummy);
		if(list_iterator !is null)
		{
			removed_triple = list_iterator.triple;
		}
		else
		{
			INFO_remove_triple_from_list = false;
			return false;
		}

		//		log.trace("removing triple <{}><{}>\"{}\"", fromStringz(removed_triple.s), fromStringz(removed_triple.p), fromStringz(removed_triple.o));

		if(idx_s !is null)
		{
			idx_s.INFO_remove_triple_from_list = INFO_remove_triple_from_list;
			idx_s.remove_triple_from_list(removed_triple, s, null, null);
		}

		if(idx_p !is null)
		{
			idx_p.INFO_remove_triple_from_list = INFO_remove_triple_from_list;
			idx_p.remove_triple_from_list(removed_triple, p, null, null);
		}

		if(idx_o !is null)
		{
			idx_o.INFO_remove_triple_from_list = INFO_remove_triple_from_list;
			idx_o.remove_triple_from_list(removed_triple, o, null, null);
		}

		if(idx_po !is null)
		{
			idx_po.INFO_remove_triple_from_list = INFO_remove_triple_from_list;
			idx_po.remove_triple_from_list(removed_triple, p, o, null);
		}

		if(idx_so !is null)
		{
			idx_so.INFO_remove_triple_from_list = INFO_remove_triple_from_list;
			idx_so.remove_triple_from_list(removed_triple, s, o, null);
		}

		if(idx_s1ppoo !is null)
		{
			bool is_deleted_from_list = false;
			// !!! store_predicate_in_list_on_idx_s1ppoo
			// проверим удаляемую запись на соответствие установленных предикатов для индекса sppoo [setPredicatesToS1PPOO]					
			for(int i = 0; i < count_look_predicate_on_idx_s1ppoo; i++)
			{
				if(p == look_predicate_p1_on_idx_s1ppoo[i])
				{
					log.trace("remove triple <{}><{}>\"{}\"", s, p, o);
					log.trace("remove from index s1ppoo A:[{}]", p);

					char[] o1 = o;
					char[] p1 = p;
					char[] p2 = look_predicate_p2_on_idx_s1ppoo[i];

					triple_list_element* listS = idx_sp.get(cast(char*) s, cast(char*) p2, null, dummy);
					if(listS !is null)
					{
						char[] o2 = fromStringz(listS.triple.o);

						//						log.trace("remove from index sppoo A: p1 = {}, p2 = {}", p1, p2);
						//						log.trace("### [{}] [{}] [{}]", look_predicate_pp_on_idx_s1ppoo[i], o1, o2);

						listS = idx_s1ppoo.get(look_predicate_pp_on_idx_s1ppoo[i].ptr, o1.ptr, o2.ptr, dummy);
						//						log.trace("#s1ppoo content:");
						//						print_list_triple(listS);

						// вторая часть p2 для этого субьекта успешно была найдена, переходим к удалению из индекса
						Triple* triple1;
						{
							while(listS !is null)
							{
								triple1 = listS.triple;
								if(triple1.s !is null)
								{
									if(strcmp(s.ptr, triple1.s) == 0)
									{
										//										log.trace("found: <{}><{}>\"{}\"", fromStringz(triple1.s), fromStringz(triple1.p), fromStringz(triple1.o));
										break;
									}
								}
								listS = listS.next_triple_list_element;
							}
						}

						if(triple1 !is null)
						{
							//							log.trace("#! list before remove:");
							//							listS = idx_s1ppoo.get(look_predicate_pp_on_idx_s1ppoo[i].ptr, o1.ptr, o2.ptr, dummy);
							//							print_list_triple(listS);

							idx_s1ppoo.INFO_remove_triple_from_list = INFO_remove_triple_from_list;
							idx_s1ppoo.remove_triple_from_list(triple1, look_predicate_pp_on_idx_s1ppoo[i], o1, o2);
							is_deleted_from_list = true;
							//							log.trace("#! list after remove:");
							//							listS = idx_s1ppoo.get(look_predicate_pp_on_idx_s1ppoo[i].ptr, o1.ptr, o2.ptr, dummy);
							//							print_list_triple(listS);
						}
					}

				}
				else if(p == look_predicate_p2_on_idx_s1ppoo[i])
				{
					log.trace("remove from index s1ppoo B:[{}]", p);

					char[] o2 = o;
					char[] p2 = p;
					char[] p1 = look_predicate_p1_on_idx_s1ppoo[i];

					triple_list_element* listS = idx_sp.get(cast(char*) s, cast(char*) p1, null, dummy);
					if(listS !is null)
					{
						char[] o1 = fromStringz(listS.triple.o);

						//						log.trace("remove from index sppoo B: p1 = {}, p2 = {}", p1, p2);
						// вторая часть p2 для этого субьекта успешно была найдена, переходим к удалению из индекса
						idx_s1ppoo.INFO_remove_triple_from_list = INFO_remove_triple_from_list;
						idx_s1ppoo.remove_triple_from_list(removed_triple, look_predicate_pp_on_idx_s1ppoo[i], o1, o2);
						is_deleted_from_list = true;
					}

				}
				else if(p == store_predicate_in_list_on_idx_s1ppoo[i])
				{
					log.trace("remove from index s1ppoo C:[{}]", p);
					char[] o1;
					char[] o2;
					char[] p1 = look_predicate_p1_on_idx_s1ppoo[i];
					char[] p2 = look_predicate_p2_on_idx_s1ppoo[i];

					// найдем через субьекта, O фактов P1 и P2
					triple_list_element* listS = idx_sp.get(cast(char*) s, cast(char*) p1, null, dummy);
					if(listS !is null)
					{
						o1 = fromStringz(listS.triple.o);
					}

					listS = idx_sp.get(cast(char*) s, cast(char*) p2, null, dummy);
					if(listS !is null)
					{
						o2 = fromStringz(listS.triple.o);
					}

					//					log.trace ("o1={}, o2={}", o1, o2);

					idx_s1ppoo.remove_triple_from_list(removed_triple, look_predicate_pp_on_idx_s1ppoo[i], o1, o2);
					is_deleted_from_list = true;

				}

			}
			
			if (is_deleted_from_list == false)
			{
				log.trace ("Exception: remove from index S1PPOO FAIL!");
				throw new Exception ("remove from index S1PPOO FAIL!");
			}
		}

		if(idx_sp !is null)
		{
			idx_sp.INFO_remove_triple_from_list = INFO_remove_triple_from_list;
			idx_sp.remove_triple_from_list(removed_triple, s, p, null);
		}

		idx_spo.INFO_remove_triple_from_list = INFO_remove_triple_from_list;
		idx_spo.remove_triple_from_list(removed_triple, s, p, o);

		removed_triple.s = null;
		removed_triple.p = null;
		removed_triple.o = null;
		removed_triple.s_length = 0;
		removed_triple.p_length = 0;
		removed_triple.o_length = 0;

		INFO_remove_triple_from_list = false;

		if(log_query == true)
			logging_query("REMOVE", s.ptr, p.ptr, o.ptr, null);

		return true;
	}

	/*	public bool removeTriple(char[] s, char[] p, char[] o)
	 {

	 return removeTriple(s, p, o);
	 }*/

	bool f_trace_addTriple = false;

	public int addTriple(char[] s, char[] p, char[] o)
	{
		try
		{

			synchronized
			{

				//do_things(o.ptr);

				if(f_trace_addTriple)
					log.trace("addTriple:1 add triple <{}><{}>\"{}\"", s, p, o);

				Triple* triple;

				if(s.length == 0 && p.length == 0 && o.length == 0)
					return -1;

				if(f_trace_addTriple)
					log.trace("add triple:get_from_spo");

				bool this_predicate_as_multiple = false;

				if((p in predicate_as_multiple) !is null)
					this_predicate_as_multiple = true;

				//				for(int i; i < predicate_as_multiple.length; i++)
				//				{
				//					log.trace("add triple:##2");
				//					if(strcmp(p, predicate_as_multiple[i].ptr) == 0)
				//					{
				//						this_predicate_as_predicate_as_multiple = true;
				//						log.trace("add triple:##3");
				//					}
				//				}

				triple_list_element* list = null;

				// проверка для предикатов которые не могут иметь множества значений для одного субьекта
				if(this_predicate_as_multiple == false)
				{
					list = idx_sp.get(cast(char*) s, cast(char*) p, null, dummy);

					//					log.trace("add triple:##1 list={:X4}", list);

					if(list !is null)
					{
						if(f_trace_addTriple)
						{
							log.trace("addTriple: add triple <{}><{}>\"{}\"", s, p, o);
							log.trace("addTriple: exist triples:");
							print_list_triple(list);

							log.trace("addTriple: remove triple <{}><{}>\"{}\"", s, p, fromStringz(list.triple.o));
						}
						removeTriple(s, p, fromStringz(list.triple.o));
						//						throw new Exception("addTriple: for that predicate already has data ");

					}
				}

				// проверка, существует ли такой факт в хранилище
				list = idx_spo.get(cast(char*) s, cast(char*) p, cast(char*) o, dummy);
				//log.trace("addTriple #1");
				if(list !is null)
				{
					log.trace("addTriple: triple <{}><{}>\"{}\" already exist", s, p, o);
					log.trace("addTriple: exist triples:");
					print_list_triple(list);
					return -2;
					//		        throw new Exception ("addTriple: triple already exist");
				}

				if(f_trace_addTriple)
					log.trace("addTriple:add index spo");

				//				idx_spo.f_trace_put = true; //@@@@@
				idx_spo.put(s, p, o, null);

				if(f_trace_addTriple)
					log.trace("addTriple:check adding to spo");

				list = idx_spo.get(cast(char*) s, cast(char*) p, cast(char*) o, dummy);
				//		log.trace("addTriple:ok, list={:X4}", list);
				//log.trace("addTriple #3");
				if(list is null)
				{
					if(f_trace_addTriple)
						log.trace("addTriple:list is null");

					idx_spo.f_trace_put = true;
					idx_spo.f_trace_get = true;

					idx_spo.put(s, p, o, null);

					idx_spo.get(cast(char*) s, cast(char*) p, cast(char*) o, dummy);

					throw new Exception("addTriple: not found triple <" ~ s ~ "><" ~ p ~ ">\"" ~ o ~ "\" in index spo");
				}

				triple = list.triple;

				if(f_trace_addTriple)
					log.trace("addTriple:triple <{}><{}>\"{}\"", fromStringz(triple.s), fromStringz(triple.p), fromStringz(triple.o));

				//		log.trace("addTriple:3 addr={:X4}", triple);
				//		log.trace("addTriple:4 addr={:X4} s={} p={} o={}", triple, fromStringz(cast(char*) (triple + 6)));

				//				idx_s.f_check_add_to_index = true;

				if(idx_s !is null)
				{
					if(f_trace_addTriple)
						log.trace("addTriple: add to S index");
					idx_s.put(s, null, null, triple);
				}

				//				idx_s.f_check_add_to_index = false;

				if(idx_p !is null)
				{
					if(f_trace_addTriple)
						log.trace("addTriple: add to P index");
					idx_p.put(p, null, null, triple);
				}

				if(idx_o !is null)
				{
					if(f_trace_addTriple)
						log.trace("addTriple: add to O index");
					idx_o.put(o, null, null, triple);
				}

				if(idx_sp !is null)
				{
					//					idx_sp.f_trace_put = true; //@@@@@
					if(f_trace_addTriple)
						log.trace("addTriple: add to SP index");
					idx_sp.put(s, p, null, triple);
				}

				if(idx_po !is null)
				{
					if(f_trace_addTriple)
						log.trace("addTriple: add to PO index");
					idx_po.put(p, o, null, triple);
				}

				if(idx_so !is null)
				{
					if(f_trace_addTriple)
						log.trace("addTriple: add to SO index");
					idx_so.put(s, o, null, triple);
				}

				/* 
				 * для s1ppoo следует проверять на полноту пары PP, так как хранить данные неполного индекса будет накладно
				 */

				if(idx_s1ppoo !is null)
				{
					if(f_trace_addTriple)
						log.trace("addTriple: add to index s1ppoo");

					char[] p1;
					char[] p2;
					char[] p3;

					char[] o1;
					char[] o2;
					// проверим запись на соответствие установленных предикатов для индекса sppoo [setPredicatesToS1PPOO]					
					for(int i = 0; i < count_look_predicate_on_idx_s1ppoo; i++)
					{
						//log.trace ("#2_");
						if(p == look_predicate_p1_on_idx_s1ppoo[i])
						{
							//log.trace ("#3");
							p1 = p;
							p2 = look_predicate_p2_on_idx_s1ppoo[i];
							p3 = store_predicate_in_list_on_idx_s1ppoo[i];

							o1 = o;
							triple_list_element* listS = idx_sp.get(cast(char*) s, cast(char*) p2, null, dummy);

							if(listS !is null)
							{
								o2 = fromStringz(listS.triple.o);
							}

						}
						else if(p == look_predicate_p2_on_idx_s1ppoo[i])
						{
							//log.trace ("#4");
							p1 = look_predicate_p1_on_idx_s1ppoo[i];
							p2 = p;
							p3 = store_predicate_in_list_on_idx_s1ppoo[i];

							o2 = o;
							triple_list_element* listS = idx_sp.get(cast(char*) s, cast(char*) p1, null, dummy);

							if(listS !is null)
							{
								o1 = fromStringz(listS.triple.o);
							}

						}
						else if(p == store_predicate_in_list_on_idx_s1ppoo[i])
						{
							//log.trace ("#4");
							p1 = look_predicate_p1_on_idx_s1ppoo[i];
							p2 = look_predicate_p2_on_idx_s1ppoo[i];
							p3 = p;

							triple_list_element* listS = idx_sp.get(cast(char*) s, cast(char*) p1, null, dummy);
							if(listS !is null)
							{
								o1 = fromStringz(listS.triple.o);
							}

							listS = idx_sp.get(cast(char*) s, cast(char*) p2, null, dummy);
							if(listS !is null)
							{
								o2 = fromStringz(listS.triple.o);
							}

						}

					}

					if(p1 !is null && p2 !is null && p3 !is null && o1 !is null && o2 !is null)
					{
						triple_list_element* listS = idx_sp.get(cast(char*) s, cast(char*) p3, null, dummy);
						if(listS !is null)
						{
							//log.trace("#SPPOO_ADD 0");
							//print_list_triple(listS);
							char[] p1p2 = p1 ~ p2;
							//log.trace ("#SPPOO_ADD 1 {} {} {} {} {} {}", p1 , p2 , p3 , o1 , o2, p1p2);
							Triple* tripleS = listS.triple;

							if(idx_s1ppoo.check_triple_in_list(tripleS, p1p2.ptr, o1.ptr, o2.ptr) == true)
							{
								return -2;
								//								throw new Exception ("triple already in index S1PPOO");
							}

							idx_s1ppoo.put(p1p2, o1, o2, tripleS);

							//listS = idx_s1ppoo.get(p1p2.ptr, o1.ptr, o2.ptr, false);					
							//log.trace("#SPPOO_ADD 2");
							//print_list_triple(listS);

						}
					}

				}
				//					log.trace ("#END");

			}

		} catch(IndexException ex)
		{
			log.trace("add triple Exception, {}, param={}", ex.message, ex.curLimitParam);
			throw ex;
		}

		if(f_trace_addTriple)
			log.trace("add triple ok");

		if(log_query == true)
			logging_query("ADD", s.ptr, p.ptr, o.ptr, null);

		return 0;
	}

	public void print_stat()
	{
		if(idx_s !is null)
			log.trace("index {}, counts={} ", idx_s.getName(), idx_s.get_count_elements());
		if(idx_p !is null)
			log.trace("index {}, counts={} ", idx_p.getName(), idx_p.get_count_elements());
		if(idx_o !is null)
			log.trace("index {}, counts={} ", idx_o.getName(), idx_o.get_count_elements());
		if(idx_sp !is null)
			log.trace("index {}, counts={} ", idx_sp.getName(), idx_sp.get_count_elements());
		if(idx_po !is null)
			log.trace("index {}, counts={} ", idx_po.getName(), idx_po.get_count_elements());
		if(idx_so !is null)
			log.trace("index {}, counts={} ", idx_so.getName(), idx_so.get_count_elements());
		if(idx_spo !is null)
			log.trace("index {}, counts={} ", idx_spo.getName(), idx_spo.get_count_elements());
		if(idx_s1ppoo !is null)
			log.trace("index {}, counts={} ", idx_s1ppoo.getName(), idx_s1ppoo.get_count_elements());
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
