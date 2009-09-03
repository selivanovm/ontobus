module persistent_triple_storage;

//import tango.io.File;
version(tango_99_8)
{
	import tango.io.device.File;
}

version(tango_99_7)
{
	import tango.io.File;
}

import tango.io.FileScan;
import tango.time.StopWatch;
private import tango.io.Stdout;
import Text = tango.text.Util;
import TripleStorage;
import fact_tools;

/*
 public void load_from_file(FilePath file_path, char[][] i_know_predicates, TripleStorage ts)
 {
 uint count_add_triple = 0;
 uint count_ignored_triple = 0;

 auto elapsed = new StopWatch();
 double time;
 Stdout.format("load triples from file {}", file_path).newline;

 auto file = new File(file_path.path ~ file_path.name ~ file_path.suffix);
 
 version (tango_99_7)
 {
 auto content = cast(char[]) file.read;
 }
 
 version (tango_99_8)
 {
 auto content = file.load;
 }

 elapsed.start;

 foreach(line; Text.lines(content))
 {
 char[] s, p, o;
 int idx = 0;
 foreach(element; Text.delimit(line, ">"))
 {
 element = Text.chopl(element, "<");
 element = Text.chopl(element, " <");
 element = Text.chopr(element, " .");
 element = Text.trim(element);

 if(element[4] == '-' && element[7] == '-' && element[10] == ' ' && element[13] == ':' && element[16] == ':' && element[19] == ',')
 element = Text.delimit(element, "<")[1];

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
 if(element.length > 2)
 {
 o = element[1 .. (element.length - 1)];
 o[o.length] = 0;
 }
 }

 //				Stdout.format("element={} ", element).newline;

 }

 Stdout.format("main: add triple [{}] <{}><{}><{}>", count_add_triple, s, p, o).newline;

 if(s.length == 0 && p.length == 0 && o.length == 0)
 continue;

 //	?	if(o.length == 2)
 //		{
 //			// Stdout.format("main: skip this triple [{}] <{}><{}><{}>", count_add_triple, s, p, o).newline;
 //			continue;
 //		}

 bool i_know_predicat = false;
 for(int i = 0; i < i_know_predicates.length; i++)
 {
 if(p == i_know_predicates[i])
 {
 i_know_predicat = true;
 break;
 }

 }

 if(i_know_predicat)
 {
 //						Stdout.format("main: add triple [{}] <{}><{}><{}>", count_add_triple, s, p, o).newline;
 if(ts.addTriple(s, p, o))
 count_add_triple++;
 else
 {
 Stdout.format("!!! triple not added").newline;
 
 count_ignored_triple++;
 }
 }
 else
 {
 count_ignored_triple++;

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
 */

public void load_from_file(FilePath file_path, char[][] i_know_predicates, TripleStorage ts)
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

		bool i_know_predicat = false;
		for(int i = 0; i < i_know_predicates.length; i++)
		{
			if(p == i_know_predicates[i])
			{
				i_know_predicat = true;
				break;
			}

		}

		if(i_know_predicat)
		{
			//						Stdout.format("main: add triple [{}] <{}><{}><{}>", count_add_triple, s, p, o).newline;
			if(ts.addTriple(s, p, o))
				count_add_triple++;
			else
			{
				Stdout.format("!!! triple not added").newline;

				count_ignored_triple++;
			}
		}
		else
		{
			count_ignored_triple++;

		}

	//				if(count_add_triple > 5)
	//					break;
	}

	//	

	time = elapsed.stop;

	Stdout.format("create TripleStorage time = {}, count add triples = {}, ignored = {}", time, count_add_triple,
			count_ignored_triple).newline;
}
