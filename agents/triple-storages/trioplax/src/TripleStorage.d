module TripleStorage;

import HashMap;
//import Triple;
private import tango.io.Stdout;
private import tango.stdc.string;

private import Log;

enum idx_name
{
	S = (1 << 0),
	P = (1 << 1),
	O = (1 << 2),
	SP = (1 << 3),
	PO = (1 << 4),
	SO = (1 << 5),
	SPO = (1 << 6)
};

class TripleStorage
{
	private HashMap idx_s = null;
	private HashMap idx_p = null;
	private HashMap idx_o = null;
	private HashMap idx_sp = null;
	private HashMap idx_po = null;
	private HashMap idx_so = null;
	private HashMap idx_spo = null;
	private char* idx;

	private ulong stat__idx_s__reads = 0;
	private ulong stat__idx_p__reads = 0;
	private ulong stat__idx_o__reads = 0;
	private ulong stat__idx_sp__reads = 0;
	private ulong stat__idx_po__reads = 0;
	private ulong stat__idx_so__reads = 0;
	private ulong stat__idx_spo__reads = 0;

	uint max_count_element = 100_000;
	uint max_length_order = 4;

	this(ubyte useindex, uint _max_count_element, uint _max_length_order)
	{
		max_count_element = _max_count_element;
		max_length_order = _max_length_order;
		//		Stdout.format("TripleStorage:use_index={:X1}", useindex).newline;

		if(useindex & idx_name.S)
		{
			Stdout.format("TripleStorage:create index S").newline;
			idx_s = new HashMap(max_count_element, 1024 * 1024 * 50, max_length_order);
		}

		if(useindex & idx_name.P)
		{
			Stdout.format("TripleStorage:create index P").newline;
			idx_p = new HashMap(1000, 1024 * 1024 * 50, 3);
		}

		if(useindex & idx_name.O)
		{
			Stdout.format("TripleStorage:create index O").newline;
			idx_o = new HashMap(max_count_element, 1024 * 1024 * 50, max_length_order);
		}

		if(useindex & idx_name.SP)
		{
			Stdout.format("TripleStorage:create index SP").newline;
			idx_sp = new HashMap(max_count_element, 1024 * 1024 * 50, max_length_order);
		}

		if(useindex & idx_name.PO)
		{
			Stdout.format("TripleStorage:create index PO").newline;
			idx_po = new HashMap(max_count_element, 1024 * 1024 * 50, max_length_order);
		}

		if(useindex & idx_name.SO)
		{
			Stdout.format("TripleStorage:create index SO").newline;
			idx_so = new HashMap(max_count_element, 1024 * 1024 * 50, max_length_order);
		}

		Stdout.format("TripleStorage:create index SPO").newline;
		idx_spo = new HashMap(max_count_element, 1024 * 1024 * 50, max_length_order); // является особенным индексом, хранящим экземпляры триплетов
	}

	public uint* getTriples(char* s, char* p, char* o, bool debug_info)
	{
		uint* list = null;

		if(s != null)
		{
			if(p != null)
			{
				if(o != null)
				{
					//					Stdout.format("@get from index SPO").newline;
					// spo
					stat__idx_spo__reads++;
					if(idx_spo !is null)
						list = idx_spo.get(s, p, o, debug_info);
				}
				else
				{
					//					Stdout.format("@get from index SP").newline;
					// sp
					stat__idx_sp__reads++;
					if(idx_sp !is null)
						list = idx_sp.get(s, p, null, debug_info);
				}
			}
			else
			{
				if(o != null)
				{
					//					Stdout.format("@get from index SO").newline;
					// so
					stat__idx_so__reads++;
					if(idx_so !is null)
						list = idx_so.get(s, o, null, debug_info);
				}
				else
				{
					//					Stdout.format("@get from index S").newline;
					// s
					stat__idx_s__reads++;
					if(idx_s !is null)
						list = idx_s.get(s, null, null, debug_info);
				}

			}
		}
		else
		{
			if(p != null)
			{
				if(o != null)
				{
					//					Stdout.format("@get from index PO").newline;
					// po
					stat__idx_po__reads++;
					if(idx_po !is null)
						list = idx_po.get(p, o, null, debug_info);
				}
				else
				{
					//					Stdout.format("@get from index P").newline;
					// p
					idx = p;
					stat__idx_p__reads++;
					if(idx_p !is null)
						list = idx_p.get(p, null, null, debug_info);
				}
			}
			else
			{
				if(o != null)
				{
					//					Stdout.format("@get from index O").newline;
					// o
					stat__idx_o__reads++;
					if(idx_o !is null)
						list = idx_o.get(o, null, null, debug_info);
				}
				else
				{
					Stdout.format("getTriples:TripleStorage unknown index").newline;
				}

			}
		}
		return list;
	}

	public bool removeTriple(char* s, char* p, char* o)
	{
		if(s !is null  && p !is null && o !is null)
			return false;
		uint* removed_triple;

		uint* list_iterator = idx_spo.get(s, p, o, false);
		if(list_iterator !is null)
		{
			removed_triple = cast(uint*) (*list_iterator);
			*list_iterator = 0;
		}
		else
			return false;

		if(idx_s !is null)
		{
			list_iterator = idx_s.get(cast(char*) s, null, null, false);
			if(list_iterator !is null)
			{
				uint next_element0 = 0xFF;
				while(next_element0 > 0)
				{
					if(cast(uint*) (*list_iterator) == removed_triple)
					{
						Stdout.format("removeTriple from S, removed_triple={:X4}", removed_triple).newline;
						*list_iterator = 0;
					}

					next_element0 = *(list_iterator + 1);
					list_iterator = cast(uint*) next_element0;

				}
			}
		}

		if(idx_p !is null)
		{
			list_iterator = idx_p.get(cast(char*) p, null, null, false);
			if(list_iterator !is null)
			{
				uint next_element0 = 0xFF;
				while(next_element0 > 0)
				{
					if(cast(uint*) (*list_iterator) == removed_triple)
					{
						Stdout.format("removeTriple from P, removed_triple={:X4}", removed_triple).newline;
						*list_iterator = 0;
					}

					next_element0 = *(list_iterator + 1);
					list_iterator = cast(uint*) next_element0;
				}
			}
		}

		if(idx_o !is null)
		{
			list_iterator = idx_o.get(cast(char*) o, null, null, false);
			if(list_iterator !is null)
			{
				uint next_element0 = 0xFF;
				while(next_element0 > 0)
				{
					if(cast(uint*) (*list_iterator) == removed_triple)
					{
						Stdout.format("removeTriple from O, removed_triple={:X4}", removed_triple).newline;
						*list_iterator = 0;
					}

					next_element0 = *(list_iterator + 1);
					list_iterator = cast(uint*) next_element0;
				}
			}
		}

		if(idx_sp !is null)
		{
			list_iterator = idx_sp.get(cast(char*) s, cast(char*) p, null, false);
			if(list_iterator !is null)
			{
				uint next_element0 = 0xFF;
				while(next_element0 > 0)
				{
					if(cast(uint*) (*list_iterator) == removed_triple)
					{
						Stdout.format("removeTriple from SP, removed_triple={:X4}", removed_triple).newline;
						*list_iterator = 0;
					}

					next_element0 = *(list_iterator + 1);
					list_iterator = cast(uint*) next_element0;
				}
			}
		}

		if(idx_po !is null)
		{
			list_iterator = idx_po.get(cast(char*) p, cast(char*) o, null, false);
			if(list_iterator !is null)
			{
				uint next_element0 = 0xFF;
				while(next_element0 > 0)
				{
					if(cast(uint*) (*list_iterator) == removed_triple)
					{
						Stdout.format("removeTriple from PO, removed_triple={:X4}", removed_triple).newline;
						*list_iterator = 0;
					}

					next_element0 = *(list_iterator + 1);
					list_iterator = cast(uint*) next_element0;
				}
			}
		}

		if(idx_so !is null)
		{
			list_iterator = idx_so.get(cast(char*) s, cast(char*) o, null, false);
			if(list_iterator !is null)
			{
				uint next_element0 = 0xFF;
				while(next_element0 > 0)
				{
					if(cast(uint*) (*list_iterator) == removed_triple)
					{
						Stdout.format("removeTriple from SO, removed_triple={:X4}", removed_triple).newline;
						*list_iterator = 0;
					}

					next_element0 = *(list_iterator + 1);
					list_iterator = cast(uint*) next_element0;
				}
			}
		}
		
	}
		
	public bool removeTriple(char[] s, char[] p, char[] o)
	{
		if(s.length == 0 && p.length == 0 && o.length == 0)
			return false;
		
		return removeTriple(cast (char*)s, cast (char*)p, cast (char*)o);
	}

	public bool addTriple(char[] s, char[] p, char[] o)
	{
		//		log.trace("addTriple:1 add triple <{}>,<{}>,<{}>", s, p, o);
		void* triple;

		if(s.length == 0 && p.length == 0 && o.length == 0)
			return false;

		uint* list = idx_spo.get(cast(char*) s, cast(char*) p, cast(char*) o, false);
		if(list !is null)
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

		if(list is null)
			throw new Exception("addTriple: not found triple in index spo");

		triple = cast(void*) *list;

		//		log.trace("addTriple:3 addr={:X4}", triple);
		//		log.trace("addTriple:4 addr={:X4} s={} p={} o={}", triple, _toString(cast(char*) (triple + 6)));

		if(idx_s !is null)
			idx_s.put(s, null, null, triple);

		if(idx_p !is null)
			idx_p.put(p, null, null, triple);

		if(idx_o !is null)
			idx_o.put(o, null, null, triple);

		if(idx_sp !is null)
			idx_sp.put(s, p, null, triple);

		if(idx_po !is null)
			idx_po.put(p, o, null, triple);

		if(idx_so !is null)
			idx_so.put(s, o, null, triple);

		return true;
	}

	public void print_stat()
	{
		Stdout.format("*** statistic read ***").newline;
		Stdout.format("index s={} reads", stat__idx_s__reads).newline;
		Stdout.format("index p={} reads", stat__idx_p__reads).newline;
		Stdout.format("index o={} reads", stat__idx_o__reads).newline;
		Stdout.format("index sp={} reads", stat__idx_sp__reads).newline;
		Stdout.format("index po={} reads", stat__idx_po__reads).newline;
		Stdout.format("index so={} reads", stat__idx_so__reads).newline;
		Stdout.format("index spo={} reads", stat__idx_spo__reads).newline;
	}

}

private static char[] _toString(char* s)
{
	return s ? s[0 .. strlen(s)] : cast(char[]) null;
}
