module testTripleStorage;

private import tango.io.Stdout;
private import tango.stdc.string;

//import Integer = tango.text.convert.Integer;
import fact_tools;
import Log;

version(tango_99_8)
{
	import tango.io.device.File;
}

version(tango_99_7)
{
	import tango.io.File;
}

import Text = tango.text.Util;
import tango.time.StopWatch;
import Log;

import HashMap;
import TripleStorage;
import tango.io.FileScan;

import tango.io.FileScan;

int main(char[][] args)
{
	uint count_add_triple = 0;

	TripleStorage ts = new TripleStorage(0xff, 100, 100, 5);
	//	Triple triple;
	//		
	auto elapsed = new StopWatch();
	double time;

	log.trace ("!!!! TEST !!!!");

	elapsed.start;

	char[] root = ".";
	Stdout.formatln("Scanning '{}'", root);
	auto scan = (new FileScan)(root, ".tn3");
	Stdout.format("\n{} Folders\n", scan.folders.length);
	foreach(folder; scan.folders)
		Stdout.format("{}\n", folder);
	Stdout.format("\n{0} Files\n", scan.files.length);

	foreach(file; scan.files)
	{
		Stdout.format("{}\n", file);
		load_from_file(file, ts);
	}
	Stdout.formatln("\n{} Errors", scan.errors.length);
	foreach(error; scan.errors)
		Stdout(error).newline;

	time = elapsed.stop;

	Stdout.format("create TripleStorage time = {}, all count triples = {}", time, count_add_triple).newline;

	print_list_triple(ts.getTriples("6fade578b4571790", null, null, false));

	for(uint i = 0; i < 100; i++)
	{
		uint count_read = 0;
		// считываем все контакты
		//		uint* iterator0 = ts.getTriples(null, "Contact", null);
		uint* iterator0 = ts.getTriples(null, "http://magnetosoft.ru/ontology/id", null, false);
		//		uint* iterator0 = ts.getTriples(null, "http://magnetosoft.ru/ontology/id", null);

		if(iterator0 is null)
		{
			break;
		}

		Stdout.format("#1 iterator0={:X4}", cast(void*) iterator0).newline;

		char* char_p_dept = cast(char*) "Department";

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
				char* triple0_p = cast(char*) (triple0 + 6 + (*(triple0 + 0) << 8) + *(triple0 + 1) + 1);
				char*
						triple0_o = cast(char*) (triple0 + 6 + (*(triple0 + 0) << 8) + *(triple0 + 1) + 1 + (*(triple0 + 2) << 8) + *(triple0 + 3) + 1);

				Stdout.format("#3 считаем поля субьекта iterator0={:X4} triple0={:X} <{}><{}><{}>", iterator0, triple0,
						str_2_char_array(triple0_s), str_2_char_array(triple0_p), str_2_char_array(triple0_o)).newline;

				uint* iterator1;
				//		uint i = 0;

				// 1. считываем все поля контакта
				iterator1 = ts.getTriples(triple0_s, null, null, false);

				if(iterator1 is null)
				{
					Stdout.format("#4 iterator1 is null").newline;
				}
				else
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

		Stdout.format("read TripleStorage, read={}, time ={}, cps={}", count_read, time, count_read / time).newline;
	}
	return 0;
}

public char[] str_2_char_array(char* s)
{
	return s ? s[0 .. strlen(s)] : cast(char[]) null;
}

public void load_from_file(FilePath file_path, TripleStorage ts)
{
	uint count_add_triple = 0;
	uint count_ignored_triple = 0;

	auto elapsed = new StopWatch();
	double time;
	Stdout.format("load triples from file {}", file_path).newline;

	auto file = new File(file_path.path ~ file_path.name ~ file_path.suffix);

	version(tango_99_8)
	{
		auto content = cast(char[]) file.load;
	}
	version(tango_99_7)
	{
		auto content = cast(char[]) file.read;
	}

	elapsed.start;

	foreach(line; Text.lines(content))
	{
		char[] s, p, o;
		char[] element;
		int idx = 0;

		uint b_pos = 0;
		uint e_pos = 0;
		for(uint i = 0; i < line.length; i++)
		{
			if(line[i] == '<' || line[i] == '"' && b_pos < e_pos)
			{
				b_pos = i;
			}
			else
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

		Stdout.format("main: add triple [{}] <{}><{}><{}>", count_add_triple, s, p, o).newline;

		if(s.length == 0 && p.length == 0 && o.length == 0)
			continue;

		//						Stdout.format("main: add triple [{}] <{}><{}><{}>", count_add_triple, s, p, o).newline;
		if(ts.addTriple(s, p, o))
		{
			count_add_triple++;
		}
		else
		{
			Stdout.format("!!! triple not added").newline;
		}

		print_list_triple(ts.getTriples(cast(char*) s, cast(char*) p, cast(char*) o, false));

	//				if(count_add_triple > 5)
	//					break;
	}

	//	

	time = elapsed.stop;

	Stdout.format("create TripleStorage time = {}, count add triples = {}, ignored = {}", time, count_add_triple,
			count_ignored_triple).newline;
}
