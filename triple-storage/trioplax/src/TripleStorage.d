import HashMap;
//import ListTriple;
import Triple;
private import tango.stdc.stdlib: alloca;
private import tango.io.Stdout;
import dee0xd.Log;

class TripleStorage
{
	private HashMap idx_s;
	private HashMap idx_p;
	private HashMap idx_o;
	private HashMap idx_sp;
	private HashMap idx_po;
	private HashMap idx_so;
	private HashMap idx_spo;
	char* idx;
	uint max_count_element = 450_000;
	uint max_length_order = 8;

	this()
	{
		idx_s = new HashMap(max_count_element, 1024*1024*50, max_length_order);
		idx_p = new HashMap(1000, 1024*1024*50, 3);
		idx_o = new HashMap(max_count_element, 1024*1024*50, max_length_order);
		idx_sp = new HashMap(max_count_element, 1024*1024*50, max_length_order);
		idx_po = new HashMap(max_count_element, 1024*1024*50, max_length_order);
		idx_so = new HashMap(max_count_element, 1024*1024*50, max_length_order);
		idx_spo = new HashMap(max_count_element, 1024*1024*50, max_length_order); // является особенным индексом, хранящим экземпляры триплетов
	}

	public uint* getTriples(char* s, char* p, char* o, bool debug_info)
	{
		uint* list;
		
		if(s != null)
		{
			//				Stdout.format("#s != null").newline;
			if(p != null)
			{
				if(o != null)
				{
//					Stdout.format("@get from index SPO").newline;
					// spo
					HashMap idx_xxx = idx_spo;
					list = idx_xxx.get(s, p, o, debug_info);
				} else
				{
//					Stdout.format("@get from index SP").newline;
					// sp
					HashMap idx_xxx = idx_sp;
					list = idx_xxx.get(s, p, null, debug_info);
				}
			} else
			{
				if(o != null)
				{
//					Stdout.format("@get from index SO").newline;
					// so
					HashMap idx_xxx = idx_so;
					list = idx_xxx.get(s, o, null,  debug_info);
				} else
				{
//					Stdout.format("@get from index S").newline;
					// s
					HashMap idx_xxx = idx_s;
					list = idx_xxx.get(s, null, null, debug_info);
				}

			}
		} else
		{
			//				Stdout.format("#s == null").newline;
			if(p != null)
			{
				//				Stdout.format("#p != null").newline;
				if(o != null)
				{
//					Stdout.format("@get from index PO").newline;
					// po
					HashMap idx_xxx = idx_po;
					list = idx_xxx.get(p, o, null, debug_info);
				} else
				{
//					Stdout.format("@get from index P").newline;
					//				Stdout.format("#o == null").newline;
					// p
					idx = p;
					HashMap idx_xxx = idx_p;
					list = idx_xxx.get(p, null, null, debug_info);
				}
			} else
			{
				if(o != null)
				{
//					Stdout.format("@get from index O").newline;
					// o
					HashMap idx_xxx = idx_o;
					list = idx_xxx.get(o, null, null, debug_info);
				} else
				{
					// ?
				}

			}
		}
		return list;
	}

	public bool addTriple(char[] s, char[] p, char[] o)
	{
//		log.trace("addTriple:1 add triple <{}>,<{}>,<{}>", s, p, o);
		void* triple;

		if (s.length == 0 && p.length == 0 && o.length == 0)
			return false;
			
		
		uint* list = idx_spo.get(cast(char*) s, cast(char*) p, cast(char*) o, false);
		if (list !is null)
		{
//			log.trace("addTriple:2 triple <{}><{}><{}> already exist", s, p, o);
//		        throw new Exception ("addTriple: triple already exist");
			return false;
		}
		
//		log.trace("addTriple:add index spo");
		idx_spo.put(s, p, o, null);
//		log.trace("addTriple:get this index as triple");
		list = idx_spo.get(cast(char*) s, cast(char*) p, cast(char*) o, false);
//		log.trace("addTriple:ok, list={:X4}", list);
		
		if (list is null)
		  throw new Exception ("addTriple: not found triple in index spo");
		

		triple = cast(void*)*list;

//		log.trace("addTriple:3 addr={:X4}", triple);
//		log.trace("addTriple:4 addr={:X4} s={} p={} o={}", triple, str_2_char_array(cast(char*) (triple + 6)));

		idx_s.put(s, null, null, triple);
		idx_p.put(p, null, null, triple);
		idx_o.put(o, null, null, triple);
		idx_sp.put(s, p, null, triple);
		idx_po.put(p, o, null, triple);
		idx_so.put(s, o, null, triple);
		
		return true;
	}
}

	private char[] str_2_char_array(char* str)
	{
		uint str_length = 0;
		char* tmp_ptr = str;
		while(*tmp_ptr != 0)
		{
//			Stdout.format("@={}", *tmp_ptr).newline;
			tmp_ptr++;
		}

		str_length = tmp_ptr - str;

		char[] res = new char[str_length];

		for(uint i = 0; i < str_length; i++)
		{
			res[i] = *(str + i);
		}

		return res;
	}
