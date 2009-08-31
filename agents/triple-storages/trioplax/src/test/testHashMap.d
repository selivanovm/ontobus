module testHashMap;

private import tango.stdc.stdlib: alloca;
private import tango.stdc.string;
import HashMap;
import Hash;
private import tango.io.Stdout;

//import ListTriple;
import Log;

void main()
{

	bool check_control_mem(int* control_mem_addr, uint control_mem_content)
	{
		if(*control_mem_addr != control_mem_content)
		{
			Stdout.format(
					"main:0 !!!!!!!!!!! *control_mem_addr != control_mem_content").newline;
			return false;
		} else
		{
			return true;
		}
	}
	uint* res_triples;
	Stdout.format("main:1 Test HashMap").newline;

	HashMap hm = new HashMap(1_000, 1024 * 1024, 8);

	char[] triple = null;

	int* control_mem_addr = null;
	uint control_mem_content = 0;

	/*
	 char* triple_ptr = cast(char*)alloca (10+1);
	 
	 int k;	
	 for (k=0; k<triple.length; k++)
	 {
	 *(triple_ptr + k) = 'Y';
	 }
	 *(triple_ptr + k) = 0;
	 */

	Stdout.format("main:2 full 100 items").newline;

	for(int i = 1; i <= 1_00; i++)
	{
		char[] i_str = Integer.format(new char[32], i);

		triple = "<S_" ~ i_str ~ "><P_" ~ i_str ~ "><O_" ~ i_str ~ ">";

		char* triple_ptr = cast(char*) alloca(triple.length + 1);

		int k;
		for(k = 0; k < triple.length; k++)
		{
			*(triple_ptr + k) = triple[k];
		}
		*(triple_ptr + k) = 0;

		//        Stdout.format("triple_ptr={:X}", triple_ptr);

		hm.put("testkey_" ~ i_str, "testkey_" ~ i_str, null, triple_ptr);
		hm.put("testkeys", null, null, triple_ptr);
	}

	Stdout.format("main:2 stop full data").newline;

	res_triples = hm.get("testkeys", null, null, false);
	print_triple_list(res_triples);

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

void print_triple_list(uint* res_triples)
{
	if(res_triples !is null)
	{
		uint* iterator = res_triples;
		//		Stdout.format("print_triple_list:0 iterator={:X}", iterator);

		uint next_element = 0xFF;
		while(next_element > 0)
		{
			char* readed_triple = cast(char*) *iterator;
			//            Stdout.format("print_triple_list:1 readed_triple={:X}", readed_triple);

			Stdout.format("print_triple_list:2 readed buff {}",
					str_2_char_array(readed_triple)).newline;

			next_element = *(iterator + 1);
			iterator = cast(uint*) next_element;
			//			Stdout.format("print_triple_list:3 iterator={:X}", iterator);
		}
	}

}

private char[] str_2_char_array(char* s)
{
	return s ? s[0 .. strlen(s)] : cast(char[]) null;
	/*	
	 uint str_length = 0;
	 char* tmp_ptr = str;
	 while(*tmp_ptr != 0)
	 {
	 //		Stdout.format("@={}", *tmp_ptr);
	 tmp_ptr++;
	 }

	 str_length = tmp_ptr - str;

	 char[] res = new char[str_length];

	 for(uint i = 0; i < str_length; i++)
	 {
	 res[i] = *(str + i);
	 }

	 return res;
	 */
}
