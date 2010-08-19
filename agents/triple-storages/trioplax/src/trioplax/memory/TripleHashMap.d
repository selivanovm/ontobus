module trioplax.memory.HashMap;

private import tango.stdc.stdlib: calloc;
private import tango.stdc.stdlib: malloc;
private import tango.stdc.string;
private import tango.stdc.stringz;
private import tango.io.Stdout;
private import Integer = tango.text.convert.Integer;

private import trioplax.Log;
private import trioplax.triple;

private import trioplax.memory.Hash;
private import trioplax.memory.IndexException;

struct triple_list_header
{
	triple_list_element* first_element;
	triple_list_element* last_element;
	Triple* keys;
}

class HashMap
{
	public bool f_check_add_to_index = false;
	public bool f_check_remove_from_index = false;

	public bool INFO_remove_triple_from_list = false;
	public bool f_trace_put = false;
	public bool f_trace_get = false;

	private uint count_element = 0;
	private char[] hashName;

	private uint max_count_elements = 1_000;

	private uint max_size_short_order = 8;

	// в таблице соответствия первые четыре элемента содержат ссылки на ключи, короткие списки конфликтующих ключей содержатся в reducer_area
	private triple_list_header*[] reducer;
	private int max_size_reducer = 0;

	// область хранения ключей
	private ubyte[] keyz_area;
	private int keyz_area__last = 0;

	// область хранения Triple
	private Triple[] triples_area = null;
	private int triples_area__last = 0;

	this(char[] _hashName, int _max_count_elements, uint _triple_area_length, uint _max_size_short_order)
	{
		hashName = _hashName;
		max_size_short_order = _max_size_short_order;
		max_count_elements = _max_count_elements;
		log.trace("*** create HashMap[name={}, max_count_elements={}, max_size_short_order={}, triple_area_length={} ... start", hashName,
				_max_count_elements, max_size_short_order, _triple_area_length);

		// область маппинга ключей, 
		// содержит короткую очередь
		max_size_reducer = max_count_elements * max_size_short_order + max_size_short_order;
		reducer = new triple_list_header*[max_size_reducer];
		log.trace("*** HashMap[name={}, reducer.length={}", hashName, reducer.length);

		keyz_area = new ubyte[_triple_area_length];
		keyz_area__last = 0;
		log.trace("*** HashMap[name={}, keyz_area.length={}", hashName, keyz_area.length);

		triples_area = new Triple[_max_count_elements];
		triples_area__last = 0;

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

	public void put(char[] key1, char[] key2, char[] key3, Triple* triple_ptr)
	{
		if(key1 is null && key2 is null && key3 is null)
			return;

		if(key1.length == 0 && key2.length == 0 && key3.length == 0)
			return;

		int STORE_keyz_area__last = keyz_area__last;
		int STORE_triples_area__last = triples_area__last;

		uint hash = (getHash(key1, key2, key3) & 0x7FFFFFFF) % max_count_elements;
		uint short_order_conflict_keys = hash * max_size_short_order;

		if(short_order_conflict_keys + max_size_short_order >= max_size_reducer)
		{
			log.trace(
					"Exception: {}, hash={}, short_order_conflict_keys={}, short_order_conflict_keys + max_size_short_order={}, max_size_reducer={}",
					hashName, hash, short_order_conflict_keys, short_order_conflict_keys + max_size_short_order, max_size_reducer);
			throw new Exception(hashName ~ " put:short_order_conflict_keys + max_size_short_order >= max_size_reducer");
		}

		if(f_trace_put)
		{
			log.trace("\r\n\r\nput{} #10 key1={}, key2={}, key3={}", hashName, key1, key2, key3);
			log.trace("put #10 triple_ptr={:X4}, hash = {:X4}", triple_ptr, hash);
		}

		triple_list_header* header;
		triple_list_element* last_element;
		triple_list_element* new_element;

		bool isKeyExists = false;
		Triple* keyz;

		if(f_trace_put)
		{
			log.trace("put:{}:reducer[{:X4}]={:X4}", hashName, short_order_conflict_keys, reducer[short_order_conflict_keys]);
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
				log.trace("put:{}: i={}, header = {:X4}", i, hashName, header);
			}

			isKeyExists = false;
			keyz = header.keys;

			if(f_trace_put)
			{
				log.trace("put:{}: keyz = {:X4}", hashName, keyz);
			}

			if(f_trace_put)
			{
				log.trace("put:{}: keyz.s={:X4}, keyz.p={:X4}, keyz.o={:X4}", hashName, keyz.s, keyz.p, keyz.o);
			}

			if(keyz !is null)
			{

				if(f_trace_put)
				{
					log.trace("put:{} 20 keyz = <{}> <{}> <{}>", hashName, fromStringz(keyz.s), fromStringz(keyz.p), fromStringz(keyz.o));
				}

				if(key1 !is null)
				{
					//					log.trace("put:{} 7.1 сравниваем key1={}", hashName, key1);

					if(strncmp(keyz.s, key1.ptr, key1.length) == 0)
					{
						//						log.trace("put:[{:X}] 7.1 key1={} совпал", cast(void*) this, key1);
						isKeyExists = true;

						if(key2 is null && key3 is null)
							break;

						//						keyz += key1.length + 1;
					}
				}
				if(key2 !is null && (key1 is null || key1 !is null && isKeyExists == true))
				{
					isKeyExists = false;
					//					log.trace("put:[{:X}] 7.2 сравниваем key2={}", cast(void*) this, key2);

					if(strncmp(keyz.p, key2.ptr, key2.length) == 0)
					{
						//						log.trace("put:[{:X}] 7.2 key2={} совпал", cast(void*) this, key2);

						isKeyExists = true;

						if(key3 is null)
							break;

						//						keyz += key2.length + 1;
					}

				}
				if(key3 !is null && ((key1 is null || key1 !is null && isKeyExists == true) || (key2 is null || key2 !is null && isKeyExists == true)))
				{
					isKeyExists = false;
					// log.trace("put:[{:X}] 7.3 сравниваем key3={}", cast(void*) this, key3);
					if(strncmp(keyz.o, key3.ptr, key3.length) == 0)
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
		new_element = cast(triple_list_element*) calloc(1, triple_list_element.sizeof);
		if(new_element is null)
			throw new Exception("put: " ~ hashName ~ " Can not allocate memory");

		if(!isKeyExists)
		{
			if(f_trace_put)
			{
				log.trace("put:key not exist");
			}
			// ключ по данному хешу не был найден, создаем новый
			//			log.trace("put #21");

			header = cast(triple_list_header*) calloc(1, triple_list_header.sizeof);
			if(header is null)
				throw new Exception("put: " ~ hashName ~ " Can not allocate memory");

			//			header = cast(triple_list_header*) (key_2_list_triples_area.ptr + key_2_list_triples_area__last);
			//			key_2_list_triples_area__last += triple_list_header.sizeof;

			//			if(short_order_conflict_keys + i < reducer.length)
			if(first_free_header_place != -1)
			{
				reducer[short_order_conflict_keys + first_free_header_place] = header;
			}
			else
			{
				throw new IndexException("put: " ~ hashName ~ " short_order_conflict_keys > max_size_short_order", hashName,
						errorCode.hash2short_is_out_of_range, 0);
				//				throw new Exception("short_order_conflict_keys + i > reducer.length");
			}

			//			log.trace("put #53 !!! new header={:X4} i={}", header, i);
			header.first_element = new_element;

			//			log.trace("put #54 header.first_element={:X4}, key_2_list_triples_area__last={}", header.first_element, key_2_list_triples_area__last);

			//			keyz = cast(Triple*) (key_2_list_triples_area.ptr + key_2_list_triples_area__last);
			keyz = &triples_area[triples_area__last];
			triples_area__last++;
			if(triples_area__last > triples_area.length)
			{
				log.trace("{}, triple area: increase the size of the array, new size = {}", hashName, triples_area.length + 10000);
				triples_area.length = triples_area.length + 10000;
			}
			//				throw new Exception (hashName ~ ": Can not allocate memory for Triple");

			//			keyz = cast(Triple*) calloc(1, Triple.sizeof);
			//			if (keyz is null)
			//				throw new Exception ("Can not allocate memory");

			//			log.trace("put:{} check key1_length={}, key2_length={}, key3_length={}", hashName, key1.length, key2.length, key3.length);

			if(f_trace_put)
			{
				log.trace("put:store keys length, keyz={:X4}, key1_length={}, key2_length={}, key3_length={}", keyz, key1.length,
						key2.length, key3.length);
			}

			keyz.s_length = key1.length;
			keyz.p_length = key2.length;
			keyz.o_length = key3.length;
			keyz.s = null;
			keyz.p = null;
			keyz.o = null;

			char* buff = null;
			if(key1.length + key2.length + key3.length > 0)
			{
				//				buff = cast(char*) calloc(key1.length + key2.length + key3.length + 3, byte.sizeof);
				//				if (buff is null)
				//					throw new Exception ("Can not allocate memory");

				buff = cast(char*) (keyz_area.ptr + keyz_area__last);

				if(keyz_area__last + key1.length + key2.length + key3.length + 3 > keyz_area.length)
				{
					// перед выбросом Exception, если заполнялась новая ячейка в short order, то очистим ее
					// восстановим глобальные переменные  

					keyz_area__last = STORE_keyz_area__last;
					triples_area__last = STORE_triples_area__last;

					reducer[short_order_conflict_keys + first_free_header_place] = null;

					throw new Exception("put: " ~ hashName ~ " Can not allocate memory for keyz_area");
				}

				keyz_area__last += key1.length + key2.length + key3.length + 3;

				if(f_trace_put)
				{
					log.trace("put:store keys values, alloc buff={:X4}", buff);
				}
			}

			if(f_trace_put)
			{
				log.trace("put:store keys values, store key1, key1.length={}", key1.length);
			}

			if(key1 !is null)
			{
				keyz.s = buff;
				strncpy(keyz.s, key1.ptr, key1.length + 1);
			}

			if(f_trace_put)
			{
				log.trace("put:store keys values, store key2");
			}

			if(key2 !is null)
			{
				keyz.p = keyz.s + key1.length + 1;
				strncpy(keyz.p, key2.ptr, key2.length + 1);
			}

			if(f_trace_put)
			{
				log.trace("put:store keys values, store key3");
			}

			if(key3 !is null)
			{
				keyz.o = keyz.p + key2.length + 1;
				strncpy(keyz.o, key3.ptr, key3.length + 1);
			}

			if(f_trace_put)
			{
				log.trace("put:store struct triple to header, keyz={:x4}", keyz);
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

		//		log.trace("put #80 triple_ptr={:X4}", triple_ptr);

		if(triple_ptr is null)
			new_element.triple = keyz;
		else
			new_element.triple = triple_ptr;

		header.last_element = new_element;

		if(f_check_add_to_index && triple_ptr !is null)
		{
			if(check_triple_in_list(triple_ptr, key1.ptr, key2.ptr, key3.ptr) == false)
			{
				log.trace("Exception: {} check add triple {} -> [{}][{}][{}] in index, triple not added in index", triple_to_string(
						triple_ptr), hashName, key1, key2, key3);
				throw new Exception(hashName ~ " triple <" ~ key1 ~ "><" ~ key2 ~ ">\"" ~ key3 ~ "\" not added in index");
			}
		}

		if(f_trace_put)
		{
			log.trace("put:end header={:X4}, keyz={:X4}", header, header.keys);
		}

		count_element++;
	}

	//в индексе S1PPOO бывают одинаковые факты

	public bool check_triple_in_list(Triple* triple_ptr, char* key1, char* key2, char* key3)
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
					if(list.triple !is null)
					{
						//						log.trace("{} check add triple in index #3", hashName);
						if(triple_ptr == list.triple)
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
			log.trace(
					"Exception: {}, hash={}, short_order_conflict_keys={}, short_order_conflict_keys + max_size_short_order={}, max_size_reducer={}",
					hashName, hash, short_order_conflict_keys, short_order_conflict_keys + max_size_short_order, max_size_reducer);
			throw new Exception(hashName ~ " get:short_order_conflict_keys + max_size_short_order >= max_size_reducer");
		}

		triple_list_header* header;

		if(f_trace_get)
		{
			log.trace("");
			log.trace("get:{}, hash[{:X}] map key1[{}], key2[{}], key3[{}]", hashName, hash, fromStringz(key1), fromStringz(key2),
					fromStringz(key3));
		}

		// @@@@ здесь бля баг
		/*		
		 if(reducer[short_order_conflict_keys] is null)
		 {
		 pos_in_reducer = -1;
		 if(f_trace_get)
		 {
		 log.trace("get:{}:return, reducer[short_order_conflict_keys] is null", hashName);
		 }
		 return null;
		 }
		 else
		 */
		{

			bool isKeyExists = false;
			int i = 0;
			Triple* keyz;
			while(i < max_size_short_order)
			{
				isKeyExists = false;
				header = reducer[short_order_conflict_keys + i];

				if(header is null)
				{
					i++;
					continue;
				}

				if(f_trace_get)
					log.trace("get:{} header={:X4} header.keys={:X4}, i={}, short_order_conflict_keys + i={:X4}", hashName, header,
							header.keys, i, short_order_conflict_keys + i);

				keyz = header.keys;

				if(f_trace_get)
					log.trace("get:{} keyz.s={:X4}", hashName, keyz.s);

				//				ubyte* keyz_len_ptr = cast(ubyte*) keyz;
				//				uint key1_length = (*(keyz_len_ptr + 0) << 8) + *(keyz_len_ptr + 1);
				//				uint key2_length = (*(keyz_len_ptr + 2) << 8) + *(keyz_len_ptr + 3);
				//				uint key3_length = (*(keyz_len_ptr + 4) << 8) + *(keyz_len_ptr + 5);

				if(f_trace_get)
				{
					log.trace("get:{} 7 key1_length={}, key2_length={}, key3_length={}", hashName, keyz.s_length, keyz.p_length,
							keyz.o_length);
				}

				//				keyz += short.sizeof * 3;

				if(key1 !is null)
				{
					if(f_trace_get)
					{
						log.trace("get:[{:X}] 7.1 сравниваем key1={} и keyz.s[{:X4}]={}", cast(void*) this, fromStringz(key1), keyz.s,
								fromStringz(keyz.s));
					}

					if(strncmp(keyz.s, key1, keyz.s_length + 1) == 0)
					{
						if(f_trace_get)
						{

							log.trace("get:[{:X}] 7.1 key1={} совпал", cast(void*) this, key1);
						}

						isKeyExists = true;

						if(key2 is null && key3 is null)
							break;

						//						keyz += key1_length + 1;
					}
				}
				if(key2 !is null && (key1 is null || key1 !is null && isKeyExists == true))
				{
					isKeyExists = false;

					if(f_trace_get)
					{
						log.trace("get:[{:X}] 7.2 сравниваем key2={} и keyz.p={}", cast(void*) this, fromStringz(key2), fromStringz(keyz.p));
					}

					if(strncmp(keyz.p, key2, keyz.p_length + 1) == 0)
					{

						if(f_trace_get)
						{

							log.trace("get:[{:X}] 7.2 key2={} совпал", cast(void*) this, key2);
						}

						isKeyExists = true;

						if(key3 is null)
							break;

						//						keyz += key2_length + 1;
					}

				}
				if(key3 !is null && ((key1 is null || key1 !is null && isKeyExists == true) || (key2 is null || key2 !is null && isKeyExists == true)))
				{
					isKeyExists = false;

					if(f_trace_get)
					{
						log.trace("get:[{:X}] 7.3 сравниваем key3={} и keyz={}", cast(void*) this, fromStringz(key3), fromStringz(keyz.o));
					}

					if(strncmp(keyz.o, key3, keyz.o_length + 1) == 0)
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

			pos_in_reducer = short_order_conflict_keys + i;

			if(f_trace_get)
			{
				log.trace("get:{}:end, header.first_element={:X4}", hashName, header.first_element);
			}

			return header.first_element;
		}

	}

	public void remove_triple_from_list(Triple* removed_triple, char[] s, char[] p, char[] o)
	{
		f_check_add_to_index = true;

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
					if(list.triple !is null)
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
			throw new Exception("put:" ~ hashName ~ " Exception: неведомахуйня");

		if(INFO_remove_triple_from_list)
		{
			print_triple("remove triple from list: удаляем элемент:", removed_triple);
			log.trace("<{}><{}>\"{}\",count triples={}", s, p, o, count_triples_in_list);
			log.trace("first_element={:X4}", list);
		}

		bool found_remove_triple_in_list = false;

		if(list !is null)
		{
			int i = 0;

			triple_list_element* prev_element = null;

			while(list !is null)
			{
				if(removed_triple == list.triple)
				{
					found_remove_triple_in_list = true;

					if(INFO_remove_triple_from_list)
					{
						log.trace(hashName ~ "remove triple from list:  в списке нашли удаляемый элемент");
					}

					if(list.next_triple_list_element is null)
					{
						if(INFO_remove_triple_from_list)
							log.trace("#{} remove triple from list: далее нет элементов, список закончен", hashName);

						if(i == 0)
						{
							// это первый и последний элемент в списке, и так как длинна будующего списока равна нулю, 
							// то следует удалить запись об этом списке в короткой очереди reducer'a

							if(INFO_remove_triple_from_list)
								log.trace("#{} remove triple from list: это первый и последний элемент в списке", hashName);

							list.triple = null;

							list.next_triple_list_element = null;

							// в область преобразования запишем 0, так как в очереди был один единственный элемент
							// а значит, нужно удалить все упоминания об этом триплете 

							reducer[idx_header] = null;

							break;
						}
						else
						{
							// удаляемый элемент является последним элементом в списке, но список еще не пуст,   
							// нужно выставить указатель на последний элемент списка, 
							// для корректной работы добавления фактов с список (put) 

							if(INFO_remove_triple_from_list)
								log.trace(
										"#{} remove triple from list: удаляемый элемент является последним элементом в списке, но список еще не пуст",
										hashName);

							if(idx_header > 0)
							{
								if(INFO_remove_triple_from_list)
									log.trace(
											"#{} remove triple from list: сохраним в заголовке списка, ссылку на последний элемент этого списка",
											hashName);

								triple_list_header* header = reducer[idx_header];

								// сохраним в заголовке списка, ссылку на последний элемент этого списка
								header.last_element = prev_element;

								prev_element.next_triple_list_element = null;
							}
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

			//			log.trace("{} check deleted triple from list, in list = {} triples", hashName, count_triples_in_list);
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
					if(list.triple !is null)
					{
						tmp_count_triples_in_list++;
						if(removed_triple == list.triple)
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
				log.trace("Exception: list corrupted, {} count_triples_in_list, before {} != after {} + 1", hashName,
						count_triples_in_list, tmp_count_triples_in_list);
				throw new Exception("put: " ~ hashName ~ " list corrupted");
			}
		}

		//		log.trace("remove_triple_from_list:{} #end", hashName);
	}

	public void print_triple(char[] header, Triple* triple)
	{
		if(triple is null)
			return;

		log.trace("{} {} triple: <{}><{}>\"{}\"", hashName, header, fromStringz(triple.s), fromStringz(triple.p), fromStringz(triple.o));
	}

	public char[] triple_to_string(Triple* triple)
	{
		if(triple is null)
			return "";

		return "<" ~ fromStringz(triple.s) ~ "><" ~ fromStringz(triple.p) ~ ">\"" ~ fromStringz(triple.o) ~ "\"";
	}

}