module persistent_triple_storage;

private import tango.io.FileScan;
private import tango.time.StopWatch;
private import tango.io.Stdout;
private import Text = tango.text.Util;

private import TripleStorage;
private import fact_tools;
private import Log;
private import tango.stdc.string;
private import portions_read;

private char[][] i_know_predicates;
private TripleStorage ts;

uint count_add_triple = 0;
uint count_ignored_triple = 0;

public void load_from_file(FilePath file_path, char[][] _i_know_predicates, TripleStorage _ts)
{
	count_add_triple = 0;
	count_ignored_triple = 0;
	
	ts = _ts;
	i_know_predicates = _i_know_predicates;

	auto elapsed = new StopWatch();
	double time;
	elapsed.start;
	
	log.trace("load triples from file {}", file_path);

	parse_file(file_path.path ~ file_path.name ~ file_path.suffix, "\r", "\n", &prepare_block);

	//          log.trace ("{}, {}, {}", bytes, total_read_bytes_size, file.length);

	time = elapsed.stop;
	log.trace("end read triples, total time = {}, count add triples = {}, ignored = {}", time, count_add_triple, count_ignored_triple);
}


void prepare_block(char* line, ulong line_length)
{
	//	log.trace("read triples");

	char[] s, p, o;
	char[] element;
	int idx = 0;
	char command = 'A';

	int b_pos = 0;
	uint e_pos = 0;
	for(uint i = 0; i < line_length; i++)
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

	//	log.trace("persistent_triple_storage: add triple [{}] <{}><{}><{}>", count_add_triple, s, p, o);

	if(s.length == 0 && p.length == 0 && o.length == 0)
		return;

	bool i_know_predicat = false;
	for(int i = 0; i < i_know_predicates.length; i++)
	{
		if(i_know_predicates[i] !is null && p == i_know_predicates[i])
		{
			i_know_predicat = true;
			break;
		}

	}

	if(i_know_predicat)
	{
		//		log.trace("persistent_triple_storage: add triple [{}] <{}><{}><{}>", count_add_triple, s, p, o);

		if(command == 'A')
		{
			int result = ts.addTriple(s, p, o);
			if(result >= 0)
			{
				count_add_triple++;
			}
			else
			{
//				log.trace("!!! triple [{}] <{}><{}><{}> not added. result = {}", count_add_triple, s, p, o, result);

				count_ignored_triple++;
			}
		}
		if(command == 'D')
		{
			//			log.trace("persistent_triple_storage: remove triple [{}] <{}><{}><{}>", count_add_triple, s, p, o);
			ts.removeTriple(s, p, o);
		}

	}
	else
	{
		count_ignored_triple++;
	}

}
