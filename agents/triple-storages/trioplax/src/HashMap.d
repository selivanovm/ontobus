module HashMap;

//private import tango.stdc.stdlib: alloca;
//private import tango.stdc.stdlib: malloc;
private import tango.stdc.string;
private import tango.stdc.stringz;
private import tango.io.Stdout;
private import Integer = tango.text.convert.Integer;

private import Hash;

private import Log;
private import IndexException;

/*
 struct triple
 {
 short s_length = 0;
 short p_length = 0;
 short o_length = 0;
 char* s;
 char* p;
 char* o;
 }
 */

struct triple_list_element
{
	char* triple_ptr;
	triple_list_element* next_triple_list_element;
}

struct triple_list_header
{
	triple_list_element* first_element;
	triple_list_element* last_element;
	char* keys;
}

class HashMap
{
	public bool f_check_add_to_index = false;
	public bool f_check_remove_from_index = false;

	public bool INFO_remove_triple_from_list = false;
	private uint count_element = 0;
	private char[] hashName;

	private uint max_count_elements = 1_000;

	private uint max_size_short_order = 8;

	// в таблице соответствия первые четыре элемента содержат ссылки на ключи, короткие списки конфликтующих ключей содержатся в reducer_area
	private triple_list_header*[] reducer;
	private uint max_size_reducer = 0;

	// область связки ключей и списков триплетов
	private ubyte[] key_2_list_triples_area;
	private uint key_2_list_triples_area__last = 0;
	private uint key_2_list_triples_area__right = 0;

	this(char[] _hashName, uint _max_count_elements, uint _triple_area_length, uint _max_size_short_order)
	{
		hashName = _hashName;
		max_size_short_order = _max_size_short_order;
		max_count_elements = _max_count_elements;
		log.trace("*** create HashMap[name={}, max_count_elements={}, max_size_short_order={}, triple_area_length={} ... start", hashName,
				_max_count_elements, max_size_short_order, _triple_area_length);

		// область маппинга ключей, 
		// содержит короткую очередь из [max_size_short_order] элементов в формате [ссылка на ключ 4b][ссылка на список триплетов ключа 4b]
		max_size_reducer = max_count_elements * max_size_short_order + max_size_short_order;
		reducer = new triple_list_header*[max_size_reducer];
		log.trace("*** HashMap[name={}, reducer.length={}", hashName, reducer.length);

		key_2_list_triples_area = new ubyte[_triple_area_length];
		key_2_list_triples_area__last = 0;
		key_2_list_triples_area__right = key_2_list_triples_area.length;
		log.trace("*** HashMap[name={}, key_2_list_triples_area__right={}", hashName, key_2_list_triples_area__right);

		log.trace("*** create object HashMap... ok");
	}

	public uint get_count_elements()
	{
		return count_element;
	}

	public char[] getName()
	{
		return hashName;
	}

	public bool f_trace_put = false;

	public void put(char[] key1, char[] key2, char[] key3, void* triple_ptr)
	{

		if(key1 is null && key2 is null && key3 is null)
			return null;

		if(key1.length == 0 && key2.length == 0 && key3.length == 0)
			return null;

		uint hash = (getHash(key1, key2, key3) & 0x7FFFFFFF) % max_count_elements;
		uint short_order_conflict_keys = hash * max_size_short_order;

		if(short_order_conflict_keys + max_size_short_order >= max_size_reducer)
		{
			log.trace("Exception: {}, hash={}, short_order_conflict_keys={}, short_order_conflict_keys + max_size_short_order={}, max_size_reducer={}",
					hashName, hash, short_order_conflict_keys, short_order_conflict_keys + max_size_short_order, max_size_reducer);
			throw new Exception(hashName ~ "put:short_order_conflict_keys + max_size_short_order >= max_size_reducer");
		}

		if(f_trace_put)
		{
			log.trace("\r\n\r\nput{} #10 key1={}, key2={}, key3={}", hashName, key1, key2, key3);
			log.trace("put #20 triple_ptr={:X4}, hash = {:X4}", triple_ptr, hash);
		}

		triple_list_header* header;
		triple_list_element* last_element;
		triple_list_element* new_element;

		bool isKeyExists = false;
		char* keyz;

		if(f_trace_put)
		{
			log.trace("reducer[{:X4}]={}", hash, reducer[hash]);
		}

		int i = 0;
		int first_free_header_place = -1;

		while(i < max_size_short_order)
		{
			header = reducer[short_order_conflict_keys + i];

			if(header is null)
			{
				if(first_free_header_place == -1)
					first_free_header_place = i;
				i++;
				continue;
			}

			if(f_trace_put)
			{
				log.trace("put #40 header = {:X4}", header);
			}

			isKeyExists = false;
			keyz = header.keys;
			if(keyz !is null)
			{

				//				if(key1 !is null && strncmp(keyz.s, key1.ptr, key1.length) == 0)
				//					isKeyExists = true;
				//
				//				if(isKeyExists && key2 !is null)
				//					isKeyExists = strncmp(keyz.p, key2.ptr, key2.length) == 0;
				//
				//				if(isKeyExists && key3 !is null)
				//					isKeyExists = strncmp(keyz.o, key3.ptr, key3.length) == 0;
				byte* keyz_len_ptr = cast(byte*) keyz;
				uint key1_length = (*(keyz_len_ptr + 0) << 8) + *(keyz_len_ptr + 1);
				uint key2_length = (*(keyz_len_ptr + 2) << 8) + *(keyz_len_ptr + 3);
				uint key3_length = (*(keyz_len_ptr + 4) << 8) + *(keyz_len_ptr + 5);

				keyz += short.sizeof * 3;

				if(f_trace_put)
				{
					log.trace("put #10 keyz = <{}> <{}> <{}>", fromStringz(keyz), fromStringz(keyz + key1_length + 1), fromStringz(
							keyz + key1_length + 1 + key2_length + 1));
				}

				if(key1 !is null)
				{
					//					log.trace("put:{} 7.1 сравниваем key1={}", hashName, key1);

					if(strncmp(keyz, key1.ptr, key1.length) == 0)
					{
						//						log.trace("put:[{:X}] 7.1 key1={} совпал", cast(void*) this, key1);
						isKeyExists = true;

						if(key2 is null && key3 is null)
							break;

						keyz += key1.length + 1;
					}
				}
				if(key2 !is null && (key1 is null || key1 !is null && isKeyExists == true))
				{
					isKeyExists = false;
					//					log.trace("put:[{:X}] 7.2 сравниваем key2={}", cast(void*) this, key2);

					if(strncmp(keyz, key2.ptr, key2.length) == 0)
					{
						//						log.trace("put:[{:X}] 7.2 key2={} совпал", cast(void*) this, key2);

						isKeyExists = true;

						if(key3 is null)
							break;

						keyz += key2.length + 1;
					}

				}
				if(key3 !is null && ((key1 is null || key1 !is null && isKeyExists == true) || (key2 is null || key2 !is null && isKeyExists == true)))
				{
					isKeyExists = false;
					// log.trace("put:[{:X}] 7.3 сравниваем key3={}", cast(void*) this, key3);
					if(strncmp(keyz, key3.ptr, key3.length) == 0)
					{
						// log.trace("put:[{:X}] 7.3 key3={} совпал", cast(void*) this, key3);
						isKeyExists = true;
						break;
					}

				}

			}

			if(isKeyExists)
			{
				if(f_trace_put)
				{
					log.trace("put:key exist");
				}
				break;
			}

			i++;

		}

		//		log.trace("put #50 header={:X4}, isKeyExists={}", header, isKeyExists);
		new_element = cast(triple_list_element*) (key_2_list_triples_area.ptr + key_2_list_triples_area__last);
		key_2_list_triples_area__last += triple_list_element.sizeof;
		//log.trace("put new_element = {:X4}", new_element);

		if(!isKeyExists)
		{
			if(f_trace_put)
			{
				log.trace("put:key not exist");
			}
			// ключ по данному хешу не был найден, создаем новый
			//			log.trace("put #21");
			header = cast(triple_list_header*) (key_2_list_triples_area.ptr + key_2_list_triples_area__last);
			key_2_list_triples_area__last += triple_list_header.sizeof;

			//			header = new triple_list_header;

			//			if(short_order_conflict_keys + i < reducer.length)
			if(first_free_header_place != -1)
			{
				reducer[short_order_conflict_keys + first_free_header_place] = header;
			}
			else
			{
				throw new IndexException("put:" ~ hashName ~ " short_order_conflict_keys > max_size_short_order", hashName,
						errorCode.hash2short_is_out_of_range, 0);
				//				throw new Exception("short_order_conflict_keys + i > reducer.length");
			}

			//			log.trace("put #53 !!! new header={:X4} i={}", header, i);
			header.first_element = new_element;

			//			log.trace("put #54 header.first_element={:X4}, key_2_list_triples_area__last={}", header.first_element, key_2_list_triples_area__last);

			keyz = cast(char*) (key_2_list_triples_area.ptr + key_2_list_triples_area__last);

			//			log.trace("put:{} check key1_length={}, key2_length={}, key3_length={}", hashName, key1.length, key2.length, key3.length);

			ubyte* keyz_len_ptr = cast(ubyte*) keyz;

			*(keyz_len_ptr + 0) = (key1.length & 0x0000FF00) >> 8;
			*(keyz_len_ptr + 1) = (key1.length & 0x000000FF);

			*(keyz_len_ptr + 2) = (key2.length & 0x0000FF00) >> 8;
			*(keyz_len_ptr + 3) = (key2.length & 0x000000FF);

			*(keyz_len_ptr + 4) = (key3.length & 0x0000FF00) >> 8;
			*(keyz_len_ptr + 5) = (key3.length & 0x000000FF);

			//			*(cast(short*)(keyz)) = key1.length;
			//			*(cast(short*)(keyz)+1) = key2.length;
			//			*(cast(short*)(keyz)+2) = key3.length;
			//			log.trace("put #53 keyz={:X4}", keyz);
			key_2_list_triples_area__last += short.sizeof * 3;

			char* cptr = cast(char*) (key_2_list_triples_area.ptr + key_2_list_triples_area__last);

			if(key1 !is null)
			{
				//				log.trace("put #54 header.key1={:X4}", cptr);
				strncpy(cptr, key1.ptr, key1.length + 1);
				//				keyz.s = cast(char*) (key_2_list_triples_area.ptr + key_2_list_triples_area__last);
				//				log.trace("put #55 keyz={:X4}, keyz.s={:X4}", keyz, keyz.s);
				key_2_list_triples_area__last += key1.length + 1;
				//				keyz.s_length = key1.length;
				//				strncpy(keyz.s, key1.ptr, key1.length + 1);
				cptr = cast(char*) (key_2_list_triples_area.ptr + key_2_list_triples_area__last);
			}

			if(key2 !is null)
			{
				strncpy(cptr, key2.ptr, key2.length + 1);
				key_2_list_triples_area__last += key2.length + 1;
				cptr = cast(char*) (key_2_list_triples_area.ptr + key_2_list_triples_area__last);
			}

			if(key3 !is null)
			{
				strncpy(cptr, key3.ptr, key3.length + 1);
				key_2_list_triples_area__last += key3.length + 1;
				cptr = cast(char*) (key_2_list_triples_area.ptr + key_2_list_triples_area__last);
			}

			if(key_2_list_triples_area__last + 1024 > key_2_list_triples_area__right)
			{
				log.trace("Exception: put:{}, key_2_list_triples_area__last[{}] + 128 > key_2_list_triples_area__right[{}]", hashName,
						key_2_list_triples_area__last, key_2_list_triples_area__right);
				//				throw new Exception("put:" ~ hashName ~ ", key_2_list_triples_area__last + 128 > key_2_list_triples_area__right");
				throw new IndexException("hashName=" ~ hashName ~ ", key_2_list_triples_area__last > key_2_list_triples_area__right", hashName,
						errorCode.block_triple_area_is_full, key_2_list_triples_area__right);
			}

			header.keys = keyz;
			//			log.trace("put #55 header.keys={:X4}", header.keys);
		}
		else
		{
			// ключ уже существует, допишем триплет к last_element в найденном header
			//						log.trace("put #61 header.last_element={:X4}", header.last_element);
			//						log.trace("put #62 header.last_element.next_triple_list_element={:X4}", header.last_element.next_triple_list_element);
			header.last_element.next_triple_list_element = new_element;
			//			log.trace("put #63 header.last_element.next_triple_list_element={:X4}", header.last_element.next_triple_list_element);
			header.last_element = new_element;
			//			log.trace("put #64 header.last_element={:X4}", header.last_element);
		}

		//		log.trace("put #70 reducer[{:X4}]={:X4}", hash, reducer[hash]);

		//		log.trace("put #80 triple_ptr={:X4}", triple_ptr);

		if(triple_ptr is null)
			new_element.triple_ptr = keyz;
		else
			new_element.triple_ptr = cast(char*) triple_ptr;

		//		log.trace("put #85 | new_element={:X4}", new_element);

		header.last_element = new_element;
		//		return new_element.triple_ptr;
		//		log.trace("put{} #90 | new_element={:X4}", hashName, new_element);
		//		log.trace("put{} #100 | new_element.triple={:X4}", hashName, new_element.triple_ptr);

		if(f_check_add_to_index && triple_ptr !is null)
		{
			log.trace("Exception: {} check add triple {} -> [{}][{}][{}] in index", triple_to_string(cast(byte*) triple_ptr), hashName, key1, key2, key3);
			if(check_triple_in_list(triple_ptr, key1.ptr, key2.ptr, key3.ptr) == false)
				throw new Exception(hashName ~ " triple <" ~ key1 ~ "><" ~ key2 ~ "><" ~ key3 ~ "> not added in index");
		}

	}

	//в индексе S1PPOO бывают одинаковые факты

	public bool check_triple_in_list(void* triple_ptr, char* key1, char* key2, char* key3)
	{

		///////////////////////////// check PUT
		if(triple_ptr !is null)
		{
			//			log.trace("{} check add triple in index ", hashName);

			int dummy;

			triple_list_element* list = get(key1, key2, key3, dummy);
			if(list !is null)
			{
				//				log.trace("{} check add triple in index #1", hashName);
				while(list !is null)
				{
					//					log.trace("{} check add triple in index #2", hashName);
					if(list.triple_ptr !is null)
					{
						//						log.trace("{} check add triple in index #3", hashName);
						if(triple_ptr == list.triple_ptr)
						{
							//							log.trace("{} check add triple in index #4", hashName);
							return true;
						}

					}
					list = list.next_triple_list_element;
				}
			}
		}
		return false;
	}

	public bool f_trace_get = false;

	public triple_list_element* get(char* key1, char* key2, char* key3, out int pos_in_reducer)
	{
		if(key1 is null && key2 is null && key3 is null)
		{
			pos_in_reducer = -1;
			return null;
		}
		//		if(key1.length == 0 && key2.length == 0 && key3.length == 0)
		//			return null;

		uint hash = (getHash(key1, key2, key3) & 0x7FFFFFFF) % max_count_elements;
		uint short_order_conflict_keys = hash * max_size_short_order;

		if(short_order_conflict_keys + max_size_short_order >= max_size_reducer)
		{
			log.trace("Exception: {}, hash={}, short_order_conflict_keys={}, short_order_conflict_keys + max_size_short_order={}, max_size_reducer={}",
					hashName, hash, short_order_conflict_keys, short_order_conflict_keys + max_size_short_order, max_size_reducer);
			throw new Exception(hashName ~ "get:short_order_conflict_keys + max_size_short_order >= max_size_reducer");
		}

		triple_list_header* header;

		if(f_trace_get)
			log.trace("get:{}, hash[{:X}] map key1[{}], key2[{}], key3[{}]", hashName, hash, fromStringz(key1), fromStringz(key2), fromStringz(key3));

		if(reducer[short_order_conflict_keys] is null)
		{
			pos_in_reducer = -1;
			return null;
		}
		else
		{

			bool isKeyExists = false;
			int i = 0;
			char* keyz;
			while(i < max_size_short_order)
			{
				header = reducer[short_order_conflict_keys + i];

				if(header is null)
				{
					i++;
					continue;
				}

				isKeyExists = false;

				if(f_trace_get)
					log.trace("get:{} header={:X4} header.keys={:X4}, i={}", hashName, header, header.keys, i);

				keyz = header.keys;

				ubyte* keyz_len_ptr = cast(ubyte*) keyz;
				uint key1_length = (*(keyz_len_ptr + 0) << 8) + *(keyz_len_ptr + 1);
				uint key2_length = (*(keyz_len_ptr + 2) << 8) + *(keyz_len_ptr + 3);
				uint key3_length = (*(keyz_len_ptr + 4) << 8) + *(keyz_len_ptr + 5);

				if(f_trace_get)
				{
					log.trace("get:{} 7 key1_length={}, key2_length={}, key3_length={}", hashName, key1_length, key2_length, key3_length);
				}

				keyz += short.sizeof * 3;

				if(key1 !is null)
				{
					if(f_trace_get)
					{
						log.trace("get:[{:X}] 7.1 сравниваем key1={} и keyz[{:X}]={}", cast(void*) this, fromStringz(key1), keyz, fromStringz(keyz));
					}

					if(strncmp(keyz, key1, key1_length + 1) == 0)
					{
						if(f_trace_get)
						{

							log.trace("get:[{:X}] 7.1 key1={} совпал", cast(void*) this, key1);
						}

						isKeyExists = true;

						if(key2 is null && key3 is null)
							break;

						keyz += key1_length + 1;
					}
				}
				if(key2 !is null && (key1 is null || key1 !is null && isKeyExists == true))
				{
					isKeyExists = false;

					if(f_trace_get)
					{

						log.trace("get:[{:X}] 7.2 сравниваем key2={} и keyz[{:X}]={}", cast(void*) this, fromStringz(key2), keyz, fromStringz(keyz));
					}

					if(strncmp(keyz, key2, key2_length + 1) == 0)
					{

						if(f_trace_get)
						{

							log.trace("get:[{:X}] 7.2 key2={} совпал", cast(void*) this, key2);
						}

						isKeyExists = true;

						if(key3 is null)
							break;

						keyz += key2_length + 1;
					}

				}
				if(key3 !is null && ((key1 is null || key1 !is null && isKeyExists == true) || (key2 is null || key2 !is null && isKeyExists == true)))
				{
					isKeyExists = false;

					if(f_trace_get)
					{
						log.trace("get:[{:X}] 7.3 сравниваем key3={} и keyz[{:X}]={}", cast(void*) this, fromStringz(key3), keyz, fromStringz(keyz));
					}

					if(strncmp(keyz, key3, key3_length + 1) == 0)
					{
						if(f_trace_get)
						{
							log.trace("get:[{:X}] 7.3 key3={} совпал", cast(void*) this, key3);
						}

						isKeyExists = true;
						break;
					}

				}

				if(isKeyExists)
					break;

				i++;
			}

			if(isKeyExists == false)
			{
				if(f_trace_get)
					log.trace("get isKeyExists == false");
				pos_in_reducer = -1;
				return null;
			}

			if(f_trace_get)
			{

				log.trace("get #100 header.first_element={:X4}", header.first_element);

			}

			pos_in_reducer = short_order_conflict_keys + i;

			return header.first_element;
		}

	}

	public void remove_triple_from_list(byte* removed_triple, char[] s, char[] p, char[] o)
	{
//		f_check_add_to_index = true;

		//		INFO_remove_triple_from_list = true;

		int idx_header;
		int count_triples_in_list = 0;

		if(f_check_remove_from_index)
		{
			triple_list_element* list = get(s.ptr, p.ptr, o.ptr, idx_header);
			if(list !is null)
			{
				while(list !is null)
				{
					if(list.triple_ptr !is null)
					{
						count_triples_in_list++;
					}
					list = list.next_triple_list_element;
				}

			}
		}

		triple_list_element* list = get(s.ptr, p.ptr, o.ptr, idx_header);

		if(idx_header == -1)
		{
			// удалять нечего, этого факта нет в индексе
			return;
		}

		if(list != reducer[idx_header].first_element)
			throw new Exception("Exception: неведомахуйня");

		if(INFO_remove_triple_from_list)
		{
			print_triple("remove triple from list: удаляем элемент:", cast(byte*) removed_triple);
			log.trace("<{}><{}><{}>,count triples={}", s, p, o, count_triples_in_list);
			log.trace("first_element={:X4}", list);
		}

		bool found_remove_triple_in_list = false;

		if(list !is null)
		{
			int i = 0;

			triple_list_element* prev_element = null;

			while(list !is null)
			{
				//count_triples_in_list++;

				if(removed_triple == cast(byte*) list.triple_ptr)
				{
					found_remove_triple_in_list = true;

					if(INFO_remove_triple_from_list)
					{
						log.trace(hashName ~ "remove triple from list:  в списке нашли удаляемый элемент");
					}

					if(list.next_triple_list_element is null)
					{
						// *(list + 1) == 0 -> означает что далее нет элементов, список закончен.
						if(INFO_remove_triple_from_list)
							log.trace("#{} remove triple from list: далее нет элементов, список закончен", hashName);

						if(i == 0)
						{
							if(INFO_remove_triple_from_list)
								log.trace("#{} remove triple from list: это первый и последний элемент в списке", hashName);
							// это первый и последний элемент в списке, и так как длинна будующего списока равна нулю, 
							// то следует удалить запись об этом списке в короткой очереди reducer'a
							//							log.trace("#remove_triple_from_list: это первый и последний элемент в списке");
							/*
							 short last_element_in_order;
							 for (last_element_in_order = found_pos_in_order_conflict_keys; last_element_in_order < max_size_short_order; last_element_in_order++)
							 {
							 log.trace("#{} remove triple from list: #0 last_element_in_order={}", hashName, last_element_in_order);
							 if(reducer[found_short_order_conflict_keys + last_element_in_order] is null)
							 {
							 last_element_in_order--;
							 break;
							 }
							 }
							 if(INFO_remove_triple_from_list)
							 log.trace("#{} remove triple from list: #1 last_element_in_order={}", hashName, last_element_in_order);

							 if(last_element_in_order > 1)
							 {
							 // на место удаляемого элемента поставим последний, на место последнего запишем null
							 if(INFO_remove_triple_from_list)
							 log.trace("#{} remove triple from list: #2", hashName);
							 reducer[found_short_order_conflict_keys + found_pos_in_order_conflict_keys] = reducer[last_element_in_order];
							 reducer[last_element_in_order] = null;
							 }
							 else
							 {
							 if(INFO_remove_triple_from_list)
							 log.trace("#{} remove triple from list: #3", hashName);
							 reducer[found_short_order_conflict_keys + found_pos_in_order_conflict_keys] = null;
							 
							 }
							 */
							list.triple_ptr = null;
							//print_list_triple(list);

							list.next_triple_list_element = null;
							// в область преобразования запишем 0, так как в очереди был один единственный элемент
							// а значит, нужно удалить все упоминания об этом триплете 
							//!!!???							reducer[found_short_order_conflict_keys + found_pos_in_order_conflict_keys] = null;
							reducer[idx_header] = null;
							break;
						}
						else
						{
							if(INFO_remove_triple_from_list)
								log.trace(
										"#{} remove triple from list: удаляемый элемент является последним элементом в списке, но список еще не пуст",
										hashName);
							// удаляемый элемент является последним элементом в списке, но список еще не пуст,   
							// нужно выставить указатель на последний элемент списка, 
							// для корректной работы добавления фактов с список (put) 
							//							triple_list_header* header = reducer[found_short_order_conflict_keys + found_pos_in_order_conflict_keys];

							//							log.trace("#remove_triple_from_list: это последний но не единственный элемент в списке");
							//							log.trace("#remove_triple_from_list: keys_of_hash_in_reducer={:X4}, found_short_order_conflict_keys={:X4}",
							//									keys_of_hash_in_reducer, found_short_order_conflict_keys);

							if(idx_header > 0)
							{
								//								if(INFO_remove_triple_from_list)
								if(INFO_remove_triple_from_list)
									log.trace("#{} remove triple from list: сохраним в заголовке списка, ссылку на последний элемент этого списка",
											hashName);

								triple_list_header* header = reducer[idx_header];

								//								log.trace("#remove_triple_from_list: prev_element={:X4}", prev_element);
								// сохраним в заголовке списка, ссылку на последний элемент этого списка
								//ptr_to_mem(key_area, keys_of_hash_in_reducer + _LAST_ELEMENT, cast(uint) prev_element);
								header.last_element = prev_element;

								//								*(cast(uint*) (key_area.ptr + keys_of_hash_in_reducer + _LAST_ELEMENT)) = cast(uint) prev_element;
								prev_element.next_triple_list_element = null;
							}
							//							break;
						}
					}
					else
					{
						if(INFO_remove_triple_from_list)
							log.trace("#{} remove triple from list: после удаляемого элемента есть еще элементы", hashName);

						//log.trace("#rtf5 {:X4} {:X4} {:X4}", list, list + 1, prev_element);
						if(prev_element !is null)
						{
							if(INFO_remove_triple_from_list)
								log.trace("#{} remove triple from list: перед удаляемым элементом есть элементы", hashName);

							prev_element.next_triple_list_element = list.next_triple_list_element;
							break;
						}
						else
						{
							if(INFO_remove_triple_from_list)
								log.trace("#{} remove triple from list: удаляемый элемент первый", hashName);

							// нужно ссылку на next_element поместить в заголовок

							//log.trace("#rtf6 {:X4} {:X4} ", (cast(uint*)*(list + 1)) + 1, cast(uint*)*(list + 1));
							//print_triple(cast(byte*)*(list));
							//print_triple(cast(byte*)*(cast(uint*)*(list + 1)));

							//						triple_list_header* header = reducer[found_short_order_conflict_keys + found_pos_in_order_conflict_keys];
							triple_list_header* header = reducer[idx_header];
							header.first_element = list.next_triple_list_element;

							//							uint* next_replaced_element = cast(uint*)*(list + 1);							

							//							*list = cast(uint)next_replaced_element;
							//print_list_triple(list);

							//							*(list + 1) = cast(uint)*(next_replaced_element + 1);
							//print_list_triple(list);

							break;
						}

					}
					break;
				}
				prev_element = list;
				list = list.next_triple_list_element;
				i++;

			}
		}

		if(f_check_remove_from_index)
		{

			if(found_remove_triple_in_list == false)
			{
				log.trace("{} remove triple: triple not found in list", hashName);
				//throw new Exception (hashName ~ " remove triple: triple not found in list");
			}
			int tmp_count_triples_in_list = 0;

			log.trace("{} check deleted triple from list, in list = {} triples", hashName, count_triples_in_list);
			list = get(s.ptr, p.ptr, o.ptr, idx_header);

			if(list is null && count_triples_in_list > 1)
			{
				log.trace("Exception: {} first_element={:X4}", hashName, list);
				throw new Exception(hashName ~ " list is null && count_triples_in_list > 1");
			}

//			log.trace("first_element={:X4}", list);

			if(list !is null)
			{
				while(list !is null)
				{
					if(list.triple_ptr !is null)
					{
						tmp_count_triples_in_list++;
						if(removed_triple == cast(byte*) list.triple_ptr)
						{
							log.trace("Exception: {} this triple found in list, not deleted !", hashName);
							throw new Exception(hashName ~ " this triple found in list, not deleted !");
						}
					}
					list = list.next_triple_list_element;

				}
			}

			if(count_triples_in_list > 0 && count_triples_in_list != (tmp_count_triples_in_list + 1))
			{
				log.trace("Exception: list corrupted, {} count_triples_in_list, before {} != after {} + 1", hashName, count_triples_in_list, tmp_count_triples_in_list);
				throw new Exception("list corrupted");
			}
		}

		//		log.trace("remove_triple_from_list:{} #end", hashName);
	}

	public void print_triple(char[] header, byte* triple)
	{
		if(triple is null)
			return;

		char* s = cast(char*) triple + 6;

		char* p = cast(char*) (triple + 6 + (*(triple + 0) << 8) + *(triple + 1) + 1);

		char* o = cast(char*) (triple + 6 + (*(triple + 0) << 8) + *(triple + 1) + 1 + (*(triple + 2) << 8) + *(triple + 3) + 1);

		log.trace("{} {} triple: <{}><{}><{}>", hashName, header, fromStringz(s), fromStringz(p), fromStringz(o));
	}

	public char[] triple_to_string(byte* triple)
	{
		if(triple is null)
			return "";

		char* s = cast(char*) triple + 6;

		char* p = cast(char*) (triple + 6 + (*(triple + 0) << 8) + *(triple + 1) + 1);

		char* o = cast(char*) (triple + 6 + (*(triple + 0) << 8) + *(triple + 1) + 1 + (*(triple + 2) << 8) + *(triple + 3) + 1);

		return "<" ~ fromStringz(s) ~ "><" ~ fromStringz(p) ~ "><" ~ fromStringz(o) ~ ">";
	}

}
