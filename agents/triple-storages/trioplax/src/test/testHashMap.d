module testHashMap;

private import tango.io.Stdout;
import HashMap;
import Hash;
import Log;

void main()
{
	log.trace("main:1 Test HashMap");

	HashMap hm = new HashMap("test", 100, 1024 * 1024, 8);

	log.trace("main:2 full 100 items");

	for(int i = 1; i <= 1_000; i++)
	{
		char[] i_str = Integer.format(new char[32], i);

		triple* tt = new triple;
		tt.s = "S_" ~ i_str;
		tt.p = "P_" ~ i_str;
		tt.o = "O_" ~ i_str;

		hm.put("testkey_s_" ~ i_str, "testkey_p_" ~ i_str, "testkey_o_" ~ i_str, tt, false);
		hm.put("testkeys", null, null, tt, false);
	}

	log.trace("main:2 stop full data");

	triple_list_element* list_triples = hm.get("testkey_s_500", "testkey_p_500", "testkey_o_500", false);
	print_triple_list(list_triples);

	list_triples = hm.get("testkeys", null, null, false);
	print_triple_list(list_triples);

	list_triples = hm.get("testkey", null, null, false);
	print_triple_list(list_triples);
	/*
	 Stdout.format("main:3 ----------------- res_triples={:X} ", res_triples).newline;

	 for(int h = 0; h < 1; h++)
	 {

	 res_triples = hm.get("testkey_1", "testkey_1", null, false);
	 print_triple_list(res_triples);

	 res_triples = hm.get("testkey_999", "testkey_999", null, false);
	 print_triple_list(res_triples);

	 res_triples = hm.get("testkey_99", "testkey_99", null, false);
	 print_triple_list(res_triples);

	 res_triples = hm.get("testkey_50", "testkey_50", null, false);
	 print_triple_list(res_triples);

	 res_triples = hm.get("testkey_1", "testkey_1", null, false);
	 print_triple_list(res_triples);

	 res_triples = hm.get("testkey_999", "testkey_999", null, false);
	 print_triple_list(res_triples);

	 res_triples = hm.get("testkey_99", "testkey_99", null, false);
	 print_triple_list(res_triples);

	 res_triples = hm.get("testkey_50", "testkey_50", null, false);
	 print_triple_list(res_triples);

	 Stdout.format("start read").newline;
	 for(int i = 2_000_000; i > 0; i--)
	 {
	 res_triples = hm.get("testkey_1", "testkey_1", null, false);

	 //		ListTripleIterator it = res_triples.iterator ();
	 //		while (it.hasNext ())
	 //		{
	 //			it.next ();
	 //		}

	 //	 res_triples = hm.get("testkey_999", "testkey_999");

	 //		res_triples = hm.get("testkey_99", "testkey_99", null);
	 }
	 Stdout.format("stop read").newline;

	 res_triples = hm.get("testkey_1", "testkey_1", null, false);
	 print_triple_list(res_triples);

	 res_triples = hm.get("testkey_999", "testkey_999", null, false);
	 print_triple_list(res_triples);

	 res_triples = hm.get("testkey_99", "testkey_99", null, false);
	 print_triple_list(res_triples);

	 res_triples = hm.get("testkey_50", "testkey_50", null, false);
	 print_triple_list(res_triples);

	 }
	 }
	 */
}

	void print_triple_list(triple_list_element* list_triples)
	{
		while(list_triples !is null)
		{
			triple* tt = list_triples.triple_ptr;
			log.trace("triple <{}><{}><{}>", tt.s, tt.p, tt.o);
			list_triples = list_triples.next_triple_list_element;
		}

	}

