module TripleStorage;

private import HashMap;
//import Triple;
private import tango.io.Stdout;
private import tango.stdc.string;
private import Log;
private import tango.util.container.HashMap;
import tango.stdc.stringz;

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
	private char[][16] look_predicate_pp_on_idx_s1ppoo;
	private char[][16] store_predicate_in_list_on_idx_s1ppoo;
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
	private char[] cat_buff1;
	private char[] cat_buff2;

	this(ubyte useindex, uint _max_count_element, uint _max_length_order, uint inital_triple_area_length)
	{
		cat_buff1 = new char[64 * 1024];
		cat_buff2 = new char[64 * 1024];

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
			idx_s1ppoo = new HashMap("S1PPOO", max_count_element, inital_triple_area_length, max_length_order);
		}

		// создается всегда, потому как является особенным индексом, хранящим экземпляры триплетов
		idx_spo = new HashMap("SPO", max_count_element, inital_triple_area_length * 3, max_length_order);

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

	public uint* getTriples(char* s, char* p, char* o, ubyte useindex)

	{
	  //log.trace("### getTriples1");
		if(useindex & idx_name.S1PPOO)
		{
			return idx_s1ppoo.get(s, p, o, false);
		}
	}
	
	public uint* getTriples(char* s, char* p, char* o, bool debug_info)
	{
	  //log.trace("### getTriples2");
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
				  //Stdout.format("@get from index O").newline;
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
		//log.trace("LIST {:X4}", list);
		return list;
	}

	public bool removeTriple(char[] s, char[] p, char[] o)
	{

		if(s.length == 0 && p.length == 0 && o.length == 0)
			return false;

	  //do_things(o);

		if(s is null && p is null && o is null)
			return false;

		uint* removed_triple;

		uint* list_iterator = idx_spo.get(s.ptr, p.ptr, o.ptr, false);
		if(list_iterator !is null)
		{
			removed_triple = cast(uint*) (*list_iterator);
			idx_spo.remove_triple_from_list(removed_triple,  s,  p,  o);
		}
		else
		  return false;

		if(idx_s !is null)
		{
		  idx_s.remove_triple_from_list(removed_triple,  s, null, null);
		}

		if(idx_p !is null)
		{
		  idx_p.remove_triple_from_list(removed_triple,  p, null, null);
		}

		if(idx_o !is null)
		{
		  idx_o.remove_triple_from_list(removed_triple,  o, null, null);
		}

		if(idx_sp !is null)
		{
		  idx_sp.remove_triple_from_list(removed_triple,  s,  p, null);
		}

		if(idx_po !is null)
		{
		  idx_po.remove_triple_from_list(removed_triple,  p,  o, null);
		}

		if(idx_so !is null)
		{
		  idx_so.remove_triple_from_list(removed_triple,  s,  o, null);
		}

		//do_things(o);

		return true;
	}

  /*	public bool removeTriple(char[] s, char[] p, char[] o)
	{

		return removeTriple(s, p, o);
		}*/

	public int addTriple(char[] s, char[] p, char[] o)
	{
		synchronized
		{
		  
		  //do_things(o.ptr);



		  //		log.trace("addTriple:1 add triple <{}>,<{}>,<{}>", s, p, o);
			void* triple;

			if(s.length == 0 && p.length == 0 && o.length == 0)
				return -1;



			uint* list = idx_spo.get(cast(char*) s, cast(char*) p, cast(char*) o, false);
		  //log.trace("addTriple #1");
			if(list !is null)
			{

			  /*	uint next_element1 = 0xFF;
	while(next_element1 > 0)
	  {
	    if(list !is null) {
	      byte* triple2 = cast(byte*) *list;
	      if(triple2 !is null)
		{
		  char* ss = cast(char*) triple2 + 6;
		
		  char* pp = cast(char*) (triple2 + 6 + (*(triple2 + 0) << 8) + *(triple2 + 1) + 1);
		
		  char* oo = cast(char*) (triple2 + 6 + (*(triple2 + 0) << 8) + *(triple2 + 1) + 1 + (*(triple2 + 2) << 8) + *(triple2 + 3) + 1);
		
		  if (ss !is null || pp !is null || oo !is null)
		    return -2;

		}
	    }
	    next_element1 = *(list + 1);
	    list = cast(uint*) next_element1;
	    log.trace("!!!!!!!!!!!!!!!!!!22");
	    }*/
			  return -2;

				//			log.trace("addTriple:2 triple <{}><{}><{}> already exist", s, p, o);
				//		        throw new Exception ("addTriple: triple already exist");

			}

			//		log.trace("addTriple:add index spo");
			idx_spo.put(s, p, o, null);
		  //log.trace("addTriple #2");
			//		log.trace("addTriple:get this index as triple");
			list = idx_spo.get(cast(char*) s, cast(char*) p, cast(char*) o, false);
			//		log.trace("addTriple:ok, list={:X4}", list);
		  //log.trace("addTriple #3");
			if(list is null)
				throw new Exception("addTriple: not found triple in index spo");

			triple = cast(void*) *list;

			//log.trace("!!!!!!!!!!!!!!!!!!11");

			//		log.trace("addTriple:3 addr={:X4}", triple);
			//		log.trace("addTriple:4 addr={:X4} s={} p={} o={}", triple, _toString(cast(char*) (triple + 6)));

			if(idx_s !is null)
				idx_s.put(s, null, null, triple);
		  //log.trace("addTriple #4");
			if(idx_p !is null)
				idx_p.put(p, null, null, triple);
		  //log.trace("addTriple #5");
			if(idx_o !is null)
				idx_o.put(o, null, null, triple);
		  //log.trace("addTriple #6");
			if(idx_sp !is null)
				idx_sp.put(s, p, null, triple);
		  //log.trace("addTriple #7");
			if(idx_po !is null)
			  {
			    //			    log.trace("addTriple #7 \n {} \n {} \n {}", p, o, _toString(cast(char*)triple));
				idx_po.put(p, o, null, triple);
			  }
		  //log.trace("addTriple #8");
			if(idx_so !is null)
				idx_so.put(s, o, null, triple);
		  //log.trace("addTriple #9");
			/* 
			 * для s1ppoo следует проверять на полноту пары PP, так как хранить данные неполного индекса будет накладно
			 */

			if(idx_s1ppoo !is null)
			{
				//log.trace ("#1_");
				for(int i = 0; i < count_look_predicate_on_idx_s1ppoo; i++)
				{
					//log.trace ("#2_");
					if(p == look_predicate_p1_on_idx_s1ppoo[i])
					{
					//log.trace ("#3");
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
							idx_s1ppoo.put(look_predicate_pp_on_idx_s1ppoo[i], o1, o2, triple);
						}

					}
					else if(p == look_predicate_p2_on_idx_s1ppoo[i])
					{
					//log.trace ("#4");
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
							idx_s1ppoo.put(look_predicate_pp_on_idx_s1ppoo[i], o1, o2, triple);
						}

					}
					else if(p == store_predicate_in_list_on_idx_s1ppoo[i])
					{
					  					//log.trace ("#5");
						// 1. найдем o1 и o2, для этого просмотрим все факты у которых subject = s  

						// !!! НЕ РАССМОТРЕНЫ ВАРИАНТЫ КОГДА store_predicate_in_list_on_idx_s1ppoo[i] встречается раньше чем p1 или p2  
						uint* list_iterator = idx_s.get(cast(char*) s, null, null, false);

						char* o1 = null;
						char* o2 = null;
						char[] p1 = look_predicate_p1_on_idx_s1ppoo[i];
						char[] p2 = look_predicate_p2_on_idx_s1ppoo[i];

						if(list_iterator !is null)
						{
							uint next_element0 = 0xFF;
							while(next_element0 > 0)
							{
								byte* triple0 = cast(byte*) *list_iterator;

								//								log.trace("### {:X4}", triple0);

								if(triple0 !is null)
								  {

								char* p_of_s = cast(char*) (triple0 + 6 + (*(triple0 + 0) << 8) + *(triple0 + 1) + 1);

								if(strcmp(p_of_s, cast(char*) p1) == 0)
								{
									o1 = cast(char*) (triple0 + 6 + (*(triple0 + 0) << 8) + *(triple0 + 1) + 1 + (*(triple0 + 2) << 8) + *(triple0 + 3) + 1);
								}
								else if(strcmp(p_of_s, cast(char*) p2) == 0)
								{
									o2 = cast(char*) (triple0 + 6 + (*(triple0 + 0) << 8) + *(triple0 + 1) + 1 + (*(triple0 + 2) << 8) + *(triple0 + 3) + 1);
								}

								if(o1 !is null && o2 !is null)
								{									
									list_iterator = idx_s1ppoo.get(cast(char*) look_predicate_pp_on_idx_s1ppoo[i], o1, o2, false);
									if(list_iterator !is null)
									{
//										log.trace ("#2 pp={}, o1={}, o2={} => {}", look_predicate_pp_on_idx_s1ppoo[i], _toString(o1), _toString(o2), cast(uint) triple);
										*list_iterator = cast(uint) triple;
									}
									else
									  log.trace("!!! idx_s1ppoo EX0000");

									break;
								}
								
								  }

								next_element0 = *(list_iterator + 1);
								list_iterator = cast(uint*) next_element0;
							}
						}
						

					/*											
					 if(o1 !is null && o2 !is null)
					 {
					 ////							log.trace ("#3 p={}", store_predicate_in_list_on_idx_s1ppoo[i]);
					 //							// оба предиката уже существуют, 
					 //							// значит для данного s индекс s1ppoo уже заполнялся и можно добавить к нему в список данный триплет 
					 //
					 idx_s1ppoo.put(p1 ~ p2, _toString(o1) ~ _toString(o2), null, triple);
					 }
					 */
					}
					//					log.trace ("#END");

				}

			}
			//do_things(o.ptr);

			return 0;
		}
	}

	public void print_stat()
	{
		log.trace(
				"*** statistic read *** \n" //
				"index s={} reads \n" //
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

public void do_things(char* ooo) {
  if(strcmp(ooo, "4f7a561bd9024baebb2efea4c7b8e1c9") == 0) {
    uint* list_facts = getTriples(null, null, "4f7a561bd9024baebb2efea4c7b8e1c9".ptr, true);
    
    if(list_facts !is null)
      {
	uint next_element1 = 0xFF;
	while(next_element1 > 0)
	  {
	    if(list_facts !is null) {
	    byte* triple = cast(byte*) *list_facts;
	    log.trace("list_fact {:X4}", list_facts);
	    if(triple !is null)
	      {
		char* s = cast(char*) triple + 6;
		
		char* p = cast(char*) (triple + 6 + (*(triple + 0) << 8) + *(triple + 1) + 1);
		
		char* o = cast(char*) (triple + 6 + (*(triple + 0) << 8) + *(triple + 1) + 1 + (*(triple + 2) << 8) + *(triple + 3) + 1);
		
		log.trace("get result: <{}><{}><{}>", fromStringz(s), fromStringz(p), fromStringz(o));
	      }
	    }
	    next_element1 = *(list_facts + 1);
	    list_facts = cast(uint*) next_element1;
	  }
      }
  }
}

}

private static char[] _toString(char* s)
{
	return s ? s[0 .. strlen(s)] : cast(char[]) null;
}

