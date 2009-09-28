module TripleStorage;

import HashMap;
//import Triple;
private import tango.io.Stdout;
private import tango.stdc.string;

private import Log;
import tango.util.container.HashMap;

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
	private uint count_look_predicate_on_idx_s1ppoo = 0;

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

	this(ubyte useindex, uint _max_count_element, uint _max_length_order, uint inital_triple_area_length)
	{
		max_count_element = _max_count_element;
		max_length_order = _max_length_order;
		//		Stdout.format("TripleStorage:use_index={:X1}", useindex).newline;

		if(useindex & idx_name.S)
		{
			idx_s = new HashMap("S", max_count_element, inital_triple_area_length, max_length_order);
		}

		if(useindex & idx_name.P)
		{
			idx_p = new HashMap("P", 1000, inital_triple_area_length, 3);
		}

		if(useindex & idx_name.O)
		{
			idx_o = new HashMap("O", max_count_element, inital_triple_area_length, max_length_order);
		}

		if(useindex & idx_name.SP || useindex & idx_name.S1PPOO)
		{
			idx_sp = new HashMap("SP", max_count_element, inital_triple_area_length * 2, max_length_order);
		}

		if(useindex & idx_name.PO)
		{
			idx_po = new HashMap("PO", max_count_element, inital_triple_area_length * 2, max_length_order);
		}

		if(useindex & idx_name.SO)
		{
			idx_so = new HashMap("SO", max_count_element, inital_triple_area_length * 2, max_length_order);
		}

		if(useindex & idx_name.S1PPOO)
		{
			idx_s1ppoo = new HashMap("S1PPOO", max_count_element / 10, inital_triple_area_length, max_length_order);
		}

		// создается всегда, потому как является особенным индексом, хранящим экземпляры триплетов
		idx_spo = new HashMap("SPO", max_count_element, inital_triple_area_length * 3, max_length_order);

	}

	public void setPredicatesToS1PPOO(char[] P1, char[] P2)
	{
		look_predicate_p1_on_idx_s1ppoo[count_look_predicate_on_idx_s1ppoo] = P1;
		look_predicate_p2_on_idx_s1ppoo[count_look_predicate_on_idx_s1ppoo] = P2;
		count_look_predicate_on_idx_s1ppoo++;
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
		if(s !is null && p !is null && o !is null)
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

		return removeTriple(cast(char*) s, cast(char*) p, cast(char*) o);
	}

	public bool addTriple(char[] s, char[] p, char[] o)
	{
		synchronized
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

			/* 
			 * для s1ppoo следует проверять на полноту пары PP, так как хранить данные неполного индекса будет накладно
			 */

			if(idx_s1ppoo !is null)
			{
				for(int i = 0; i < count_look_predicate_on_idx_s1ppoo; i++)
				{
					if(look_predicate_p1_on_idx_s1ppoo[i] == p)
					{
						char[] o1 = o;
						char[] p1 = p;
						char[] p2 = look_predicate_p2_on_idx_s1ppoo[i];

						uint* listS = idx_sp.get(cast(char*) s, cast(char*) p2, null, false);
						if(listS !is null)
						{
							byte* tripleS = cast(byte*) *listS;
							char[]
									o2 = _toString(
											cast(char*) (tripleS + 6 + (*(tripleS + 0) << 8) + *(tripleS + 1) + 1 + (*(tripleS + 2) << 8) + *(tripleS + 3) + 1));

//							log.trace("add A: p1 = {}, p2 = {}", p1, p2);
							// вторая часть p2 для этого субьекта успешно была найдена, переходим к созданию индекса
							idx_s1ppoo.put(s, p1 ~ p2, o1 ~ o2, triple);
						}

					}
					else if(look_predicate_p2_on_idx_s1ppoo[i] == p)
					{
						char[] o2 = o;
						char[] p2 = p;
						char[] p1 = look_predicate_p1_on_idx_s1ppoo[i];

						uint* listS = idx_sp.get(cast(char*) s, cast(char*) p1, null, false);
						if(listS !is null)
						{
							byte* tripleS = cast(byte*) *listS;
							char[]
									o1 = _toString(
											cast(char*) (tripleS + 6 + (*(tripleS + 0) << 8) + *(tripleS + 1) + 1 + (*(tripleS + 2) << 8) + *(tripleS + 3) + 1));

//							log.trace("add B: p1 = {}, p2 = {}", p1, p2);
							// вторая часть p2 для этого субьекта успешно была найдена, переходим к созданию индекса
							idx_s1ppoo.put(s, p1 ~ p2, o1 ~ o2, triple);
						}

					}
				}


			}

			return true;
		}
	}

	public void print_stat()
	{
		log.trace(
				"*** statistic read *** \n" //
				"index s={} reads \n" //
				"stat__idx_s__reads \n" //
				"index p={} reads \n" //
				"index o={} reads \n" //
				"index sp={} reads \n" //
				"index po={} reads \n" //
				"index so={} reads \n" //
				"index spo={} reads \n",
				//
				stat__idx_s__reads, stat__idx_p__reads, stat__idx_o__reads, stat__idx_sp__reads, stat__idx_po__reads, stat__idx_so__reads,
				stat__idx_spo__reads);
	}

}

private static char[] _toString(char* s)
{
	return s ? s[0 .. strlen(s)] : cast(char[]) null;
}
