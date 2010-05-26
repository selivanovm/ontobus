module persistent_triple_storage;

private import mod.tango.io.device.File;

private import tango.io.FileScan;
private import tango.time.StopWatch;
private import tango.io.Stdout;
private import Text = tango.text.Util;

private import TripleStorage;
private import fact_tools;
private import Log;
private import triple;
private import tango.stdc.stdio;
private import tango.stdc.string;
private import tango.stdc.errno;
private import tango.stdc.stringz;

public void load_from_file(FilePath file_path, char[][] i_know_predicates, TripleStorage ts)
{
	uint count_add_triple = 0;
	uint count_ignored_triple = 0;

	auto elapsed = new StopWatch();
	double time;

	char full_path[] = file_path.path ~ file_path.name ~ file_path.suffix;

	log.trace("load triples from file {}", full_path);
	Stdout.format("load triples from file {}", full_path).newline;

	FileLineRead n3file = new FileLineRead(full_path);

	char[512] buff_s;
	char[512] buff_p;
	char[512] buff_o;

	elapsed.start;

	char* line = null;

	do
	{
		line = n3file.read_next_line();
		if(line is null)
			break;

		//		log.trace("readed line = {}", fromStringz (line));

		try
		{
			char[] s, p, o;
			int idx = 0;
			char command = 'A';

			try
			{

				int b_pos = 0;
				uint e_pos = 0;
				for(uint i = 0; i < strlen(line); i++)
				{
					if(line[i] == '<' || line[i] == '"' && b_pos < e_pos)
					{
						b_pos = i;
						if(b_pos - 2 > 0 && (line[b_pos - 2] == 'A' || line[b_pos - 2] == 'D' || line[b_pos - 2] == 'U'))
						{
							command = line[b_pos - 2];
						}

					} else
					{
						if(line[i] == '>' || line[i] == '"')
						{
							e_pos = i;
							int length = e_pos - b_pos - 1;

							//							if (length > 100)
							//							log.trace ("length={}", length);

							idx++;
							if(idx == 1)
							{
								strncpy(buff_s.ptr, line + b_pos + 1, length);
								*(buff_s.ptr + length) = 0;
								s = fromStringz(buff_s.ptr);
								//								log.trace ("s ={}", s);
							}

							if(idx == 2)
							{
								strncpy(buff_p.ptr, line + b_pos + 1, length);
								*(buff_p.ptr + length) = 0;
								p = fromStringz(buff_p.ptr);
								//								log.trace ("p ={}", p);
							}

							if(idx == 3)
							{
								strncpy(buff_o.ptr, line + b_pos + 1, length);
								*(buff_o.ptr + length) = 0;
								o = fromStringz(buff_o.ptr);
								//								log.trace ("o ={}", o);
							}

						}
					}

				}
				//				log.trace("@3");

			} catch(Exception ex)
			{
				throw new Exception("fail read triple", ex);
			}
			//				log.trace("persistent_triple_storage: command={} triple [{}] <{}><{}>\"{}\"", command, count_add_triple, s, p, o);

			if(s.length == 0 && p.length == 0 && o.length == 0)
				continue;

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

				if(command == 'A')
				{

					//					log.trace("persistent_triple_storage: add triple [{}] <{}><{}>\"{}\"", count_add_triple, s, p, o);

					//						log.trace("#1");
					int result = ts.addTriple(s, p, o);
					//						log.trace("#2");
					if(result >= 0)
					{
						count_add_triple++;

						if(count_add_triple % 34567 == 0)
							Stdout.format("count load triples {}", count_add_triple).newline;

					} else
					{
						log.trace("!!! triple [{}] <{}><{}>\"{}\" not added. result = {}", count_add_triple, s, p, o,
								result);

						count_ignored_triple++;
					}

					//					triple_list_element* list = ts.getTriples (s.ptr, p.ptr, o);
					//					if (list is null)
					//						throw new Exception ("triple <" ~ s ~ "><" ~ p ~ ">\"" ~ o ~ "\", not added");

				}
				if(command == 'D')
				{
					//					log.trace("persistent_triple_storage: remove triple [{}] <{}><{}>\"{}\"", count_add_triple, s, p, o);
					ts.removeTriple(s, p, o);
				}

			} else
			{
				count_ignored_triple++;
			}

			//				if(count_add_triple > 5)
			//					break;

		} catch(Exception ex)
		{
			log.trace("fail load triples, count loaded {}", count_add_triple);
			throw ex;
		}
	} while(line !is null);
	//		

	time = elapsed.stop;

	log.trace("end read triples, total time = {}, count add triples = {}, ignored = {}", time, count_add_triple,
			count_ignored_triple);
	Stdout.format("end read triples, total time = {}, count add triples = {}, ignored = {}", time, count_add_triple,
			count_ignored_triple).newline;

	delete n3file;
}

class FileLineRead
{
	// ! строка не может быть больше половины размера буффера buff

	private int buff_size = 1000 * 1024;
	private char[] buff = null;

	int pos_end_line_in_buff = 0;
	private int total_read_bytes_size = 0;
	private int content_size = 0;

	private File file;

	this(char[] full_file_name)
	{
		buff = new char[buff_size];
		file = new File(full_file_name);
	}

	~this()
	{
		file.close();
		delete buff;
	}

	private char* read_next_line()
	{
		//				log.trace("");
		//				log.trace("#pos_end_line_in_buff = {}", pos_end_line_in_buff);

		if(content_size - pos_end_line_in_buff <= 0)
		{
			content_size = file.read(cast(byte*) buff.ptr, buff_size);
			//			log.trace("# content_size = {}", content_size);

			if(content_size <= 0)
			{
				return null;
			}

			pos_end_line_in_buff = 0;

		}

		if(content_size - pos_end_line_in_buff > 0)
		{
			// буффер еще не пуст, найдем следующую строку	

			// найти с текущей позиции признак конца строки
			char* buff_ptr = cast(char*) buff.ptr + pos_end_line_in_buff;
			for(int i = pos_end_line_in_buff; i < content_size; i++)
			{
				//				log.trace("#i={}", i);
				if(*(buff.ptr + i) == '\n')
				{
					*(buff.ptr + i) = 0;
					pos_end_line_in_buff = i + 1;
					//										log.trace("end line in pos = {}", pos_end_line_in_buff);
					return buff_ptr;
				}

			}
			//			log.trace("#2");

			// признак конца строки не найден, а буффер еще не пуст
			// скопируем первую часть этой строки в начало буффера, при этом 
			// размер нашей строки в конце буффера не должен быть более половины размера буффера
			if(pos_end_line_in_buff < buff_size / 2)
				throw new Exception(
						"read_next_line: size of the string at the end of buffer should not be more than half the size of the buffer");

			int size_first_half_line = content_size - pos_end_line_in_buff;

			strncpy(buff.ptr, buff.ptr + pos_end_line_in_buff, size_first_half_line);

			content_size = file.read(cast(byte*) buff.ptr + size_first_half_line, buff_size - size_first_half_line) + size_first_half_line;
			pos_end_line_in_buff = 0;

			//			log.trace("#3 size_first_half_line={}, content_size={}", size_first_half_line, content_size);
			char* line = read_next_line();
			//			log.trace("#4");
			return line;

		}

	}

}