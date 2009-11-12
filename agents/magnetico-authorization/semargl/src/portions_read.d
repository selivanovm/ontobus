module portions_read;

private import mod.tango.io.device.File;
private import tango.stdc.string;
private import Log;

void parse_file(char[] file_name, char[] begin_block_marker, char[] end_block_marker, void function(char* txt, ulong size) _block_acceptor)
{
	// ...прийдется отказаться от считывания всего файла в память, 
	// хотя это было очень просто, но не очень умно, 
	// особенно если памяти мало, а файлы по сотню-другую метров 

	log.trace("open file {}", file_name);
	// open file for reading
	auto file = new File(file_name);
	log.trace("...");
	log.trace("file.length={}", file.length);

	uint total_read_bytes_size = 0;

	// create an array to house the entire file
	auto content = new char[1000 * 1024];//[file.length];
	int content_size = 0;

	auto tail = new char[1000 * 1024];//[file.length];
	int tail_size = 0;

	while(total_read_bytes_size < file.length)
	{
		// read the file content. Return value is the number of bytes read
		log.trace("open block from file");
		content_size = file.read(cast(byte*) content.ptr, 1000 * 1024);
		log.trace("readed bytes = {}", content_size);
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

			log.trace("BL-OCK[{}]", tail[0 .. tail_size] ~ content[0 .. start_pos]);
			_block_acceptor((tail[0 .. tail_size] ~ content[0 .. start_pos]).ptr, tail_size + start_pos);

			tail_size = 0;
		}

		if(content_size > 0)
			total_read_bytes_size += content_size;
		else
			break;

		int block_end_pos = content_size - 1;

		if(content_size < file.length)
		{
			log.trace("#2.5 подравняем буфер сзади до начала маркера сигнализирующего о конце искомого блока");
			// подравняем буфер сзади до начала маркера сигнализирующего о конце искомого блока
			bool found_tail = false;

			while(block_end_pos > 0)
			{
				byte i = end_block_marker.length;
				while(i >= 0)
				{
					//					log.trace("#3 i={} block_end_pos={} [{}] ? [{}] = {}", i, block_end_pos, end_block_marker[i - 1], content[block_end_pos],
					//					end_block_marker[i-1] == content[block_end_pos]);

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

			log.trace("#2.5 found_tail={}, block_end_pos={}", found_tail, block_end_pos);

			////
			if(found_tail == true)
			{
				tail_size = content_size - block_end_pos - end_block_marker.length;
				if(tail_size > 0)
				{
					log.trace("#!!! 5 копируем хвост content_size={}, block_end_pos={}, tail_size = {}", content_size, block_end_pos, tail_size);
					// копируем хвост
					strncpy(tail.ptr, content.ptr + block_end_pos + end_block_marker.length, tail_size);

					//					log.trace("#!!! 5 content + block_end_pos = {}", content[block_end_pos + 1 .. content_size]);
					//					log.trace("#!!! 5 tail = {}", tail[0 .. tail_size]);
				}

			}
		}

		log.trace("#!!!");
		// маркер конца блока найден, размер блока = block_end_pos + end_block_marker.length 
		// сохраним хвост этого буфера, в дальнейшем он станет началом для последующего чтения буфера

		// !!! нужна функция для чтения из файла определенного количества байтов?

		// начинаем делить буфер на куски по признакам начала и конца 
		// и вызываем для каждого куска функцию обработчик
		//
		int end_pos = 0;

		while(end_pos < block_end_pos)
		{
			log.trace("#!!! 2");

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
			log.trace("#!!! 3");

			if(ii == end_block_marker.length && end_pos > start_pos)
			{

				log.trace("#start_pos={}, end_pos={}", start_pos, end_pos);
				//				log.trace("{}", content[start_pos .. end_pos]);
				_block_acceptor(content.ptr + start_pos, end_pos - start_pos);
				//				log.trace("#!!! 6 start_pos={}, end_pos={}", start_pos, end_pos);

				start_pos = end_pos + end_block_marker.length;
				end_pos = start_pos;
			}
		}

	}

	file.close();
}
