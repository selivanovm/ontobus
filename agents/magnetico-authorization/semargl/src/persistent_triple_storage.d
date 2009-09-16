module persistent_triple_storage;

//import tango.io.File;
version(tango_99_8)
{
	private import tango.io.device.File;
}

version(tango_99_7)
{
	private import tango.io.File;
}

private import tango.io.FileScan;
private import tango.time.StopWatch;
private import tango.io.Stdout;
private import Text = tango.text.Util;

private import TripleStorage;
private import fact_tools;

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
		char command = '-';

		uint b_pos = 0;
		uint e_pos = 0;
		for(uint i = 0; i < line.length; i++)
		{
			if(line[i] == '<' || line[i] == '"' && b_pos < e_pos)
			{
				b_pos = i;
				if(b_pos - 2 > 0 && (line[b_pos - 2] == 'A' || line[b_pos - 2] == 'D' || line[b_pos - 2] == 'U'))
				{
					command = line[b_pos - 2];
				}

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

		//		Stdout.format("persistent_triple_storage: add triple [{}] <{}><{}><{}>", count_add_triple, s, p, o).newline;

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
			//						Stdout.format("persistent_triple_storage: add triple [{}] <{}><{}><{}>", count_add_triple, s, p, o).newline;

			if(command == 'A')
			{
				if(ts.addTriple(s, p, o))
				{
					count_add_triple++;
				}
				else
				{
					Stdout.format("!!! triple not added").newline;

					count_ignored_triple++;
				}
			}
			if(command == 'D')
			{
				Stdout.format("persistent_triple_storage: remove triple [{}] <{}><{}><{}>", count_add_triple, s, p, o).newline;
				ts.removeTriple(s, p, o);
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
