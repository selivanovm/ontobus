module persistent_triple_storage;

private import tango.io.FileScan;
private import tango.time.StopWatch;
private import tango.io.Stdout;
private import Text = tango.text.Util;

private import TripleStorage;
private import fact_tools;
private import Log;
private import mod.tango.io.device.File;
private import tango.stdc.string;

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

void parse_file(char[] file_name, char[] begin_block_marker, char[] end_block_marker, void function(char* txt, ulong size) _block_acceptor)
{
	// ...прийдется отказаться от считывания всего файла в память, это довольно глупая идея, 
	// особенно если памяти мало 

	log.trace("open file");
	// open file for reading
	auto file = new File(file_name);

	uint total_read_bytes_size = 0;

	// create an array to house the entire file
	auto content = new char[160 * 1024];//[file.length];
	int content_size = 0;

	auto tail = new char[160 * 1024];//[file.length];
	int tail_size = 0;

	while(total_read_bytes_size < file.length)
	{
		// read the file content. Return value is the number of bytes read
//		log.trace("open block from file");
		content_size = file.read(cast(byte*) content.ptr, 16 * 1024);
//		log.trace("readed bytes = {}", content_size);
		int start_pos = 0;

		if(tail_size > 0)
		{
//			log.trace("!!! 0 tail > 0");

			// найдем в этом блоке маркер конца
			ubyte ii = 0;
			while(ii < end_block_marker.length)
			{
				if(end_block_marker[ii] == content[start_pos])
					ii++;
				else
					ii = 0;

				start_pos++;
			}

			// недообработанный хвост

//			log.trace("[{}]", tail[0 .. tail_size] ~ content[0 .. start_pos - 1]);
			_block_acceptor((tail[0 .. tail_size] ~ content[0 .. start_pos - 1]).ptr, tail_size + start_pos - 1);

			tail_size = 0;
		}

		if(content_size > 0)
			total_read_bytes_size += content_size;
		else
			break;

		int block_end_pos = content_size - 1;

		if(content_size < file.length)
		{
			// подравняем буфер сзади до начала маркера сигнализирующего о конце искомого блока
			bool found_tail = false;

			while(block_end_pos > 0)
			{
				byte i = end_block_marker.length;
				while(i >= 0)
				{
					//					log.trace("#3 i={} block_end_pos={} [{}] ? [{}] = {}", i, block_end_pos, end_block_marker[i - 1], content[block_end_pos],
					//							end_block_marker[i] == content[block_end_pos]);
					if(end_block_marker[i - 1] != content[block_end_pos])
					{
						break;
					}

					i--;

					if(i == 0)
					{
						found_tail = true;
						break;
					}

					block_end_pos--;
				}

				if(found_tail == true)
					break;

				block_end_pos--;
			}

			////
			if(found_tail == true)
			{
				tail_size = content_size - block_end_pos - 1;
				if(tail_size > 0)
				{
					//					log.trace("#!!! 5 копируем хвост content_size={}, block_end_pos={}, tail_size = {}", content_size, block_end_pos, tail_size);
					// копируем хвост
					strncpy(tail.ptr, content.ptr + block_end_pos + 1, tail_size);

					//					log.trace("#!!! 5 content + block_end_pos = {}", content[block_end_pos + 1 .. content_size]);
					//					log.trace("#!!! 5 tail = {}", tail[0 .. tail_size]);
				}

			}
		}

		//				log.trace("#!!!");
		// маркер конца блока найден, размер блока = block_end_pos + end_block_marker.length 
		// сохраним хвост этого буфера, в дальнейшем он станет началом для последующего чтения буфера

		// !!! нужна функция для чтения из файла определенного количества байтов?

		// начинаем делить буфер на куски по признакам начала и конца 
		// и вызываем для каждого куска функцию обработчик
		//
		int end_pos = 0;

		while(end_pos < block_end_pos)
		{
			//				log.trace("#!!! 2");

			// найдем в этом блоке маркер конца
			// найдем в этом блоке маркер конца
			ubyte ii = 0;
			while(ii < end_block_marker.length)
			{
				if(end_block_marker[ii] == content[end_pos])
					ii++;
				else
					ii = 0;

				end_pos++;
			}
			//				log.trace("#!!! 3");

			if(ii == end_block_marker.length)
			{

				//	log.trace("#end_pos={}", end_pos);
				//				log.trace("{}", content[start_pos .. end_pos]);
				_block_acceptor(content.ptr + start_pos, end_pos - start_pos);
				//				log.trace("#!!! 6 start_pos={}, end_pos={}", start_pos, end_pos);
				//	_block_acceptor(content[start_pos .. end_pos]);

				start_pos = end_pos + end_block_marker.length;
				end_pos = start_pos;
			}
		}

	}

	file.close();
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
