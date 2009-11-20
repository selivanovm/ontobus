module HashMap;

//private import tango.stdc.stdlib: alloca;
//private import tango.stdc.stdlib: malloc;
private import tango.stdc.string;
private import tango.stdc.stringz;
private import tango.io.Stdout;
private import Integer = tango.text.convert.Integer;

private import Hash;

private import Log;

struct triple
{
	char[] s;
	char[] p;
	char[] o;
}

struct triple_list_element 
{
	triple* triple_ptr;
	triple_list_element* next_triple_list_element;
}

struct triple_list_header
{
	triple_list_element* last_element;
	triple* keys;
	triple_list_element* first_element;
}

class HashMap
{
	private uint max_count_elements = 1_000;

	private uint max_size_short_order = 8;

	// в таблице соответствия первые четыре элемента содержат ссылки на ключи, короткие списки конфликтующих ключей содержатся в reducer_area
	private uint reducer_area_length;
	private uint[] reducer_area_ptr;
	
	private triple_list_header*[][] reducer;
	
	private uint reducer_area_right;

	// область связки ключей и списков триплетов
	private uint key_2_list_triples_area__length;
	private ubyte[] key_2_list_triples_area;
	private uint key_2_list_triples_area__last = 0;
	private uint key_2_list_triples_area__right = 0;

	private char[] hashName;

	// область длинных списков конфликтующих ключей
	//	uint long_list_length;
	//	byte* long_list_ptr;
	//	uint next_ptr_in_long_list;

	// область списков триплетов 
	//	uint list_triples_area__length;
	//	int* list_triples_area;
	//	int* list_triples_area__last_used_list;

	// область хранения триплетов 
	//	uint triples_area__length;
	//	int* triples_area__ptr;
	//	uint triples_area__last_used;

	this(char[] _hashName, uint _max_count_elements, uint _triple_area_length, uint _max_size_short_order)
	{
		hashName = _hashName;
		max_size_short_order = _max_size_short_order;
		max_count_elements = _max_count_elements;
		log.trace("*** create HashMap[name={}, max_count_elements={}, max_size_short_order={}, triple_area_length={} ... start", hashName,
				_max_count_elements, max_size_short_order, _triple_area_length);

		// область маппинга ключей, 
		// содержит короткую очередь из [max_size_short_order] элементов в формате [ссылка на ключ 4b][ссылка на список триплетов ключа 4b] 
		reducer_area_length = max_count_elements * max_size_short_order;
		log.trace("*** HashMap[name={}, reducer_area_length={}", hashName, reducer_area_length);

		reducer_area_ptr = new uint[reducer_area_length];
		

		// инициализируем в reducer_area_ptr первые позиции коротких очередей 
		// это понадобится для функции выдачи всех фактов по данному HashMap
		for(uint i = 0; i < reducer_area_length; i += max_size_short_order)
				reducer_area_ptr[i] = 0;

		reducer_area_right = reducer_area_length;

		reducer.length = max_count_elements;

		// область ключей и списков триплетов
		// формат:
		// [ссылка на последний элемент очереди 4b]
		// [позиция следующего ключа 2b] 
		// [позиция следующего ключа 2b] 
		// [тело ключа][0][тело ключа][0]
		// -- элемент списка триплетов этого ключа --
		// [ссылка на триплет 4b]
		// [ссылка на следующий элемент 4b]				
		key_2_list_triples_area__length = _triple_area_length;

		key_2_list_triples_area = new ubyte[key_2_list_triples_area__length + 1];

		key_2_list_triples_area__last = 1;

		key_2_list_triples_area__right = key_2_list_triples_area__length;
		log.trace("*** HashMap[name={}, key_2_list_triples_area__right={}", hashName, key_2_list_triples_area__right);
		//		log.trace(
		//				"область связки ключей и списков триплетов, length={}, start_addr={:X}, end_addr={:X}",
		//				key_2_list_triples_area__length, key_2_list_triples_area,
		//				key_2_list_triples_area__right);

		// область длинных списков конфликтующих ключей
		//		long_list_length = max_count_elements;
		//		long_list_ptr = cast(byte*) alloca(long_list_length);
		//		next_ptr_in_long_list = 0;
		//		Stdout.format("*3** область длинных списков конфликтующих ключей:{:X}", long_list_ptr).newline;

		//область триплетов		
		//		triples_area__length = max_count_elements * 16;
		//		triples_area__ptr = cast(int*) alloca(triples_area__length);
		//		triples_area__last_used = 0;
		//		Stdout.format("*5** область триплетов:{:X}", triples_area__ptr).newline;

		//		log.trace("область маппинга ключей - oчистка, max_element={}", reducer_area_length);

		uint i = 0;
		for(i = 0; i < reducer_area_length; i++)
		{
			//@			*(reducer_area_ptr + i) = 0;
			reducer_area_ptr[i] = 0;
		}

		//		Stdout.format("*7** область длинных списков конфликтующих ключей - очистка").newline;
		//		for(uint i = 0; i < list_triples_area__length; i++)
		//		{
		//			*(i + list_triples_area) = 0;
		//		}
		log.trace("*** create object HashMap... ok");
	}


	public void put(char[] key1, char[] key2, char[] key3, triple* triple_ptr, bool is_delete)
	{

		if(key1 is null && key2 is null && key3 is null)
			return;

		if(key1.length == 0 && key2.length == 0 && key3.length == 0)
			return;

		uint hash = (getHash(key1, key2, key3) & 0x7FFFFFFF) % max_count_elements;

		log.trace("put #1 hash = {:X4}", hash);
		

		triple_list_header header;
		triple_list_element last_element;
		triple_list_element new_element;

		if(reducer[hash] is null)
		{

			log.trace("put #2");

			reducer[hash].length = max_size_short_order;

			log.trace("put #3");

			reducer[hash][0] = new triple_list_header;

			log.trace("put #4");

			header = *(reducer[hash][0]);

			log.trace("put #5");

			//			log.trace("put #8");

		}
		

		
			log.trace("put #10");
			bool isKeyExists = false;			
			int i = 0;
			triple* keyz;
			while(i < max_size_short_order && reducer[hash][i] !is null)
			{
				
				log.trace("put #15");
				
				header = *(reducer[hash][i]);
				
				isKeyExists = false;

				log.trace("put #17 header = {:X4}", &header);

				keyz = header.keys;
				

				log.trace("put #18 keyz = {:X4}", keyz);

				if(keyz !is null)
				{
				
				if(key1 !is null && keyz.s == key1)
					isKeyExists = true;

				if(isKeyExists && key2 !is null)
					isKeyExists = keyz.p == key2;

				if(isKeyExists && key3 !is null)
					isKeyExists = keyz.o == key3;

				}

				i++;

				if(isKeyExists)
					break;


			}
			i--;

			log.trace("put #20");

			if(!isKeyExists)
			{

				log.trace("put #21");

				header =*(new triple_list_header);
				log.trace("put #22");
				reducer[hash][i] = &header;
				log.trace("put #23");
				header.first_element = &new_element;
				log.trace("put #24");
			
				keyz = new triple;
				keyz.s = key1;
				log.trace("put #25");
				keyz.p = key2;
				keyz.o = key3;
				header.keys = keyz;

				triple_ptr = keyz;

			}
			
			last_element = *(reducer[hash][i].last_element);			
			
		
		//		if(header.first_element is null)
		//header.first_element = &new_element;

		if(triple_ptr is null)
			new_element.triple_ptr = keyz;
		
		log.trace("put #100 | reducer = {:X4}", reducer[hash]);
		
		header.last_element = &new_element;

	}


	public triple_list_element* get(char[] key1, char[] key2, char[] key3, bool debug_info)
	{
		
		log.trace("get #1");
		
		if(key1 is null && key2 is null && key3 is null)
			return null;

		
		if(key1.length == 0 && key2.length == 0 && key3.length == 0)
			return null;

		//		log.trace("put in hash[{:X}] map key1[{}], key2[{}], key3[{}], triple={:X4}",
		//				cast(void*) this, key1, key2, key3, triple);

		uint hash = (getHash(key1, key2, key3) & 0x7FFFFFFF) % max_count_elements;
		triple_list_header* header;

		log.trace("get #2 hash = {:X4}", hash);

		if(reducer[hash] is null)
			return null;
		else
		{
		log.trace("get #4");
			bool isKeyExists = false;			
			int i = 0;
			triple* keyz;
			while(i < max_size_short_order)
			{
				log.trace("get #5");
				
				header = reducer[hash][i];

				if(header is null)
					break;

				isKeyExists = false;

				log.trace("get #6 {:X4} {:X4}", header, header.keys);

				keyz = header.keys;

				log.trace("get #7 keyz = {:X4}", keyz);				

				if(key1 !is null && keyz.s == key1)
					isKeyExists = true;

				if(isKeyExists && key2 !is null)
					isKeyExists = keyz.p == key2;

				if(isKeyExists && key3 !is null)
					isKeyExists = keyz.o == key3;

				if(isKeyExists)
					break;
				i++;
			}
			log.trace("get #100");
			return (reducer[hash][i].first_element);			
		}
		
	}


	public uint* get_next_list_of_list_iterator(ref uint current_list_of_list_V_iterator, ref uint current_list_of_list_H_iterator)
	{
		// set iterator V+H in next position 
		if(current_list_of_list_H_iterator < max_size_short_order)
			max_size_short_order++;
		else
			max_size_short_order = 0;

		if(current_list_of_list_V_iterator < max_count_elements)
			current_list_of_list_V_iterator += max_size_short_order;

		// TODO 
		// 1. skip SPO keys values
		// 2. return list of facts

		return null;
	}


	public void remove_triple_from_list(triple_list_element* removed_triple, char[] s, char[] p, char[] o)
	{
		triple_list_element* list = get(s, p, o, false);

		triple_list_element* prev_element = null;

		int i = 0;
		while(list !is null)
		{
			//				log.trace("#rtf1");
				
			if(removed_triple == list)
			{
				//log.trace("#rtf2");
					
				if(list.next_triple_list_element is null)
				{
					if(i == 0)
					{
						//log.trace("#rtf3 {} {} {}", s, p, o);

						uint hash = (getHash(s, p, o) & 0x7FFFFFFF) % max_count_elements;

						triple_list_header header;
						triple_list_element last_element;
						triple_list_element new_element;

						if(reducer[hash] !is null)
						{
							bool isKeyExists = false;			
							int l = 0;
							triple keyz;
							while(l < max_size_short_order && reducer[hash][l] !is null)
							{
				
								header = *(reducer[hash][l]);
				
								isKeyExists = false;

								keyz = *(header.keys);
				
								if(s !is null && keyz.s == s)
									isKeyExists = true;

								if(isKeyExists && p !is null)
									isKeyExists = keyz.p == p;

								if(isKeyExists && o !is null)
									isKeyExists = keyz.o == o;

								if(isKeyExists)
									break;
								l++;
							}

							if(isKeyExists)
							{
								int k = l;
								while(reducer[hash][l] !is null)
								{
									k++;
								}
								if(k > l)
								{
									reducer[hash][l] = reducer[hash][k];
									reducer[hash][k] = null;
								}
								else
									reducer[hash][l] = null;
							}
						}

						break;
					}
					else
					{
						prev_element.next_triple_list_element = null;
						break;
					}
				}
				else
				{
					//log.trace("#rtf5 {:X4} {:X4} {:X4}", list, list + 1, prev_element);
					if(prev_element !is null)
					{
						prev_element.next_triple_list_element = list.next_triple_list_element;
						break;
					}
					else
					{
						//log.trace("#rtf6 {:X4} {:X4} ", (cast(uint*)*(list + 1)) + 1, cast(uint*)*(list + 1));
						//print_triple(cast(byte*)*(list));
						//print_triple(cast(byte*)*(cast(uint*)*(list + 1)));

						*list = *list.next_triple_list_element;
						//print_list_triple(list);

						break;
					}

				}
			}
			prev_element = list;
			list = list.next_triple_list_element;
			i++;

		}
	}



	private void dump_mem(ubyte[] mem, uint ptr)
	{
		log.trace("dump {:X4}", cast(void*) this);
		for(int row = 0; row < 40; row++)
		{
			log.trace(
					"{:X8}  {:X2} {:X2} {:X2} {:X2} {:X2} {:X2} {:X2} {:X2}  {:X2} {:X2} {:X2} {:X2} {:X2} {:X2} {:X2} {:X2}   {:C1}{:C1}{:C1}{:C1}{:C1}{:C1}{:C1}{:C1}{:C1}{:C1}{:C1}{:C1}{:C1}{:C1}{:C1}{:C1}",
					row * 16, mem[ptr + row * 16 + 0], mem[ptr + row * 16 + 1], mem[ptr + row * 16 + 2], mem[ptr + row * 16 + 3],
					mem[ptr + row * 16 + 4], mem[ptr + row * 16 + 5], mem[ptr + row * 16 + 6], mem[ptr + row * 16 + 7], mem[ptr + row * 16 + 8],
					mem[ptr + row * 16 + 9], mem[ptr + row * 16 + 10], mem[ptr + row * 16 + 11], mem[ptr + row * 16 + 12], mem[ptr + row * 16 + 13],
					mem[ptr + row * 16 + 14], mem[ptr + row * 16 + 15], cast(char) mem[ptr + row * 16 + 0], cast(char) mem[ptr + row * 16 + 1],
					cast(char) mem[ptr + row * 16 + 2], cast(char) mem[ptr + row * 16 + 3], cast(char) mem[ptr + row * 16 + 4],
					cast(char) mem[ptr + row * 16 + 5], cast(char) mem[ptr + row * 16 + 6], cast(char) mem[ptr + row * 16 + 7],
					cast(char) mem[ptr + row * 16 + 8], cast(char) mem[ptr + row * 16 + 9], cast(char) mem[ptr + row * 16 + 10],
					cast(char) mem[ptr + row * 16 + 11], cast(char) mem[ptr + row * 16 + 12], cast(char) mem[ptr + row * 16 + 13],
					cast(char) mem[ptr + row * 16 + 14], cast(char) mem[ptr + row * 16 + 15]);
		}
	}

}

private bool _strcmp(char[] mem, uint ptr, char[] key)
{
	//	log.trace("_strcmp key={}", key);
	for(int i = key.length - 1; i >= 0; i--)
	{
		//		log.trace("{:X4} {:X2} {} =? {:X2} {}", ptr + i, cast(ubyte) mem[ptr + i],
		//				cast(char) mem[ptr + i], cast(ubyte) key[i], key[i]);
		if(cast(char) mem[ptr + i] != key[i])
		{
			return false;
		}
	}
	return true;
}

private bool _strcmp(char[] mem, uint ptr, char* key)
{
	//		log.trace("_strcmp key={}", key);
	while(*key != 0)
	{
		//		log.trace("{:X4} {:X2} {} =? {:X2} {}", ptr + i, cast(ubyte) mem[ptr + i], cast(char) mem[ptr + i], cast(ubyte) *key, *key);
		if(cast(char) mem[ptr] != *key)
		{
			return false;
		}

		ptr++;
		key++;
	}

	return true;
}

//@ private char[] mem_to_char(char* ptr, int length)
private char[] mem_to_char(ubyte[] mem, uint ptr, int length)
{
	char[] buff = new char[length];

	int pos = 0;
	for(int i = length; i > 0; i--)
	{
		//@		char next_char = *(ptr + i);
		char next_char = mem[ptr + i];
		//			log.trace("readed triple={:X},  {}", next_char);
		buff[i] = next_char;
	}
	return buff;
}

private uint ptr_from_mem(ubyte[] mem, uint ptr)
{
	try
	{
		//		log.trace("ptr_from_mem ptr={:X}   {:X2},{:X2},{:X2},{:X2}", ptr, mem[ptr + 0], mem[ptr + 1],
		//				mem[ptr + 2], mem[ptr + 3]);
		return (mem[ptr + 3] << 24) + (mem[ptr + 2] << 16) + (mem[ptr + 1] << 8) + mem[ptr + 0];
	}
	catch(Exception ex)
	{
		throw new Exception("ptr_from_mem");
	}
}

private void ptr_to_mem(ubyte[] mem, uint max_size_mem, uint ptr, uint addr)
{

	//	log.trace("#ptr_to_mem {:X4}", ptr);

	if(max_size_mem < ptr + 4) 
		throw new Exception("ptr_to_mem max_size_mem < ptr + 4");

	try
	{
		uint ui = addr;

		mem[ptr + 3] = (ui & 0xFF000000) >> 24;
		mem[ptr + 2] = (ui & 0x00FF0000) >> 16;
		mem[ptr + 1] = (ui & 0x0000FF00) >> 8;
		mem[ptr + 0] = (ui & 0x000000FF);

		version(trace)
		{

			log.trace("ptr_to_mem:0 ptr={:X}, addr={:X}        {:X},{:X},{:X},{:X}", ptr, addr, b1, b2, b3, b4);
			log.trace("ptr_to_mem ptr={:X4}  addr={:X4} {:X2},{:X2},{:X2},{:X2}", ptr, addr, mem[ptr + 0], mem[ptr + 1], mem[ptr + 2], mem[ptr + 3]);
		}

	}
	catch(Exception ex)
	{
		throw new Exception("ptr_to_mem");
	}
}

private static char[] _toString(char* s)
{
	return s ? s[0 .. strlen(s)] : cast(char[]) null;
}

public void print_triple_ptr(byte* triple_ptr)
{
	if(triple_ptr is null)
		return;

	char* s = cast(char*) triple_ptr + 6;

	char* p = cast(char*) (triple_ptr + 6 + (*(triple_ptr + 0) << 8) + *(triple_ptr + 1) + 1);

	char* o = cast(char*) (triple_ptr + 6 + (*(triple_ptr + 0) << 8) + *(triple_ptr + 1) + 1 + (*(triple_ptr + 2) << 8) + *(triple_ptr + 3) + 1);

	log.trace("triple_ptr: <{}><{}><{}>", fromStringz (s), fromStringz (p), fromStringz (o));
}

public void print_list_triple(uint* list_iterator)
{
	byte* triple_ptr;
	if(list_iterator !is null)
	{
		uint next_element0 = 0xFF;
		while(next_element0 > 0)
		{
			log.trace("#YYY {:X4} {:X4} {:X4}", list_iterator, *list_iterator, *(list_iterator + 1));
			
			triple_ptr = cast(byte*) *list_iterator;
			if (triple_ptr !is null)
			  print_triple_ptr(triple_ptr);
			
			next_element0 = *(list_iterator + 1);
			list_iterator = cast(uint*) next_element0;
		}
	}
}
