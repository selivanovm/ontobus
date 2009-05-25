// import TripleStorageInvoker;
private import tango.io.Stdout;
private import std.c.string;
//import Integer = tango.text.convert.Integer;
import tango.io.File;
import Text = tango.text.Util;
import tango.time.StopWatch;
import dee0xd.Log;

import HashMap;
import TripleStorage;
//import ListTriple;
import Triple;

int main(char[][] args)
{
	//	uint max_count_elements = 300000;

	uint count_add_triple = 0;

	TripleStorage ts = new TripleStorage();
	Triple triple;
	//		

	auto file = new File("organization_triple");
	auto content = cast(char[]) file.read;

	auto elapsed = new StopWatch();
	elapsed.start;

	foreach(line; Text.lines(content))
	{
		char[] s, p, o;
		int idx = 0;
		foreach(element; Text.delimit(line, ">"))
		{
			element = Text.chopl(element, "<");
//			element = Text.chopl(element, " <");
//			element = Text.chopr(element, " .");
//			element = Text.trim(element);
			element[element.length] = 0;

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
//					Stdout.format("element={} ", element).newline;

		}

		//		void* q = cast(void *)triple;
		//		Stdout.format("addr triple={:X4}", q).newline;
		//		byte* triple = cast (byte*) alloca(1 + s.length + 1 + 1 + p.length + 1 + 1 + o.length);

		//		if (_0triple is null)
		//			_0triple = triple;

		if (s.length == 0 && p.length == 0 && o.length == 0)
			continue;
		
//		Stdout.format("main: add triple [{}] s={} p={} o={}", count_add_triple, s, p, o).newline;
//		Stdout.format("main: count={}", count_add_triple).newline;
		ts.addTriple(s, p, o);

		count_add_triple++;

//		if(count_add_triple > 100)
//			break;
	}

	//	
	double time = elapsed.stop;
	Stdout.format("create TripleStorage time = {}, count triples = {}", time, count_add_triple).newline;

	for(uint i = 0; i < 100; i++)
	{
		uint count_read = 0;
		// считываем все контакты
//		uint* iterator0 = ts.getTriples(null, "Contact", null);
		uint* iterator0 = ts.getTriples(null, "ID", null);
//		uint* iterator0 = ts.getTriples(null, "http://magnetosoft.ru/ontology/id", null);

		if (iterator0 is null)
		{
			break;
		}
		
		Stdout.format("#1 iterator0={:X4}", cast(void*) iterator0).newline;

		char* char_p_dept = cast (char*)"Department";
		
//		Stdout.format("#1 predicate_department={}", char_p_dept).newline;
		
		elapsed.start;
		
		for(uint h = 0; h < 1; h++)
		{
			uint next_element = 0xFF;
			while(next_element > 0)
			{
				byte* triple0 = cast(byte*) *iterator0;
//				Stdout.format("#2 triple0={:X4}", cast(void*) triple0).newline;

//				uint key1_length = (*(triple0 + 0) << 8) + *(triple0 + 1);
//				uint key2_length = (*(triple0 + 2) << 8) + *(triple0 + 3);
//				uint key3_length = (*(triple0 + 4) << 8) + *(triple0 + 5);

				char* triple0_s = cast(char*) triple0 + 6;
//				char* triple0_p = cast(char*) (triple0 + 6 + (*(triple0 + 0) << 8) + *(triple0 + 1) + 1);
//				char* triple0_o = cast(char*) (triple0 + 6 + (*(triple0 + 0) << 8) + *(triple0 + 1) + 1 + (*(triple0 + 2) << 8) + *(triple0 + 3) + 1);
				
//				Stdout.format("#3 считаем поля субьекта iterator0={:X4} triple0={:X} <{}><{}><{}>", iterator0, triple0, str_2_char_array(triple0_s), str_2_char_array(triple0_p), str_2_char_array(triple0_o)).newline;

				uint* iterator1;
				//		uint i = 0;

				// 1. считываем все поля контакта
				iterator1 = ts.getTriples(triple0_s, null, null);

				if(iterator1 is null)
				{
					Stdout.format("#4 iterator1 is null").newline;
				} else
				{
					uint next_element1 = 0xFF;
					while(next_element1 > 0)
					{
						byte* triple1 = cast(byte*) *iterator1;

//						char* triple1_s = cast(char*) (triple1 + 6);
//						char* triple1_p = cast(char*) (triple1 + 6 + (*(triple1 + 0) << 8) + *(triple1 + 1) + 1);
//						char* triple1_o = cast(char*) (triple1 + 6 + (*(triple1 + 0) << 8) + *(triple1 + 1) + 1 + (*(triple1 + 2) << 8) + *(triple1 + 3) + 1);

//						Stdout.format("#6 addr={:X4} s={} p={} o={}", triple1, str_2_char_array(triple1_s), str_2_char_array(triple1_p), str_2_char_array(triple1_o)).newline;

//						if(strcmp (char_p_dept, triple1_p) == 0)
//						{
//							char* triple1_s = cast(char*) (triple1 + 6);
//							char* triple1_o = cast(char*) (triple1 + 6 + (*(triple1 + 0) << 8) + *(triple1 + 1) + 1 + (*(triple1 + 2) << 8) + *(triple1 + 3) + 1);
//							Stdout.format("#7 addr={:X4} s={} p={} o={}", triple1, str_2_char_array(triple1_s), str_2_char_array(triple1_p), str_2_char_array(triple1_o)).newline;

												 
//							 uint* iterator2 = ts.getTriples(triple1_o, null, null);
							 //					print_list_triples (result1);
//							 if(result2 !is null)
//							 {
//							 ListTripleIterator iterator2 = result2.iterator();
//							 while(iterator2.hasNext())
//							 {
//							 Triple triple2 = cast(Triple) iterator2.next();
							 //																Stdout.format("#1 s={} p={} o={}", triple2.s, triple2.p,
							 //																		triple2.o).newline;							 
							 
//						}

						next_element1 = *(iterator1 + 1);
						iterator1 = cast(uint*) next_element1;

					}

				//				
				//				Stdout.format("triple:s={}, p={}, o={}",
				//					triple.s, triple.p, triple.o).newline;

				}
				next_element = *(iterator0 + 1);
				iterator0 = cast(uint*) next_element;
				count_read++;
//				log.trace ("next_element={:X}, iterator0={:X}", next_element, iterator0);
			}

		}

		time = elapsed.stop;

		Stdout.format("read TripleStorage, read={}, time ={}, cps={}", count_read, time,
				count_read / time).newline;
	}
	return 0;
}

public char[] str_2_char_array(char* str)
{
	uint str_length = 0;
	char* tmp_ptr = str;
	while(*tmp_ptr != 0)
	{
		//		Stdout.format("@={}", *tmp_ptr).newline;
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
