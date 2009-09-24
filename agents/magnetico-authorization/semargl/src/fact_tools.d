module fact_tools;

private import tango.time.Clock;
private import tango.time.Time;
private import tango.stdc.posix.stdio;
private import tango.io.Stdout;
private import tango.stdc.string;
private import Log;

struct Counts
{
	byte facts;
	byte open_brakets;
}

public void print_list_triple(uint* list_iterator)
{
	byte* triple;
//	log.trace("list_iterator {:X4}", list_iterator);
	if(list_iterator !is null)
	{
		uint next_element0 = 0xFF;
		while(next_element0 > 0)
		{
			triple = cast(byte*) *list_iterator;
//			log.trace("triple {:X4}", triple);
			print_triple(triple);

			next_element0 = *(list_iterator + 1);
//			log.trace("next_element0 {:X4}", next_element0);
			list_iterator = cast(uint*) next_element0;
		}
	}
}

public void print_triple(byte* triple)
{
	if(triple is null)
		return;

	char* s = cast(char*) triple + 6;

	char* p = cast(char*) (triple + 6 + (*(triple + 0) << 8) + *(triple + 1) + 1);

	char*
			o = cast(char*) (triple + 6 + (*(triple + 0) << 8) + *(triple + 1) + 1 + (*(triple + 2) << 8) + *(triple + 3) + 1);

	log.trace("triple: <{}><{}><{}>", getString (s), getString (p), getString (o));
}

public Counts calculate_count_facts(char* message, ulong message_size)
{
	Counts res;

	for(int i = message_size; i > 0; i--)
	{
		char* cur_char = cast(char*) (message + i);

		if(*cur_char == '.')
			res.facts++;

		if(*cur_char == '{')
			res.open_brakets++;
	}

	return res;
}

public uint extract_facts_from_message(char* message, ulong message_size, Counts counts, char* fact_s[],
		char* fact_p[], char* fact_o[], uint is_fact_in_object[])
{
	//	Stdout.format("extract_facts_from_message ... facts.size={}", counts.facts).newline;

	byte count_open_brakets = 0;
	byte count_facts = 0;
	byte count_fact_fragment = 0;

	uint stack_brackets[] = new uint[counts.open_brakets];

	bool is_open_quotes = false;

	for(int i = 0; i < message_size; i++)
	{
		char* cur_char_ptr = message + i;
		char cur_char = *cur_char_ptr;

		if(cur_char == '"')
		{
			if(is_open_quotes == false)
				is_open_quotes = true;
			else
			{
				is_open_quotes = false;
				*cur_char_ptr = 0;
			}
		}

		if(cur_char == '{')
		{
			count_open_brakets++;
			stack_brackets[count_open_brakets] = count_facts;
		}
		if(cur_char == '}')
		{
			count_open_brakets--;
		}

		if(cur_char == '<' || cur_char == '{' || (cur_char == '"' && is_open_quotes == true))
		{
			if(count_fact_fragment == 0)
			{
				if(count_open_brakets > 0)
				{
					is_fact_in_object[count_facts] = stack_brackets[count_open_brakets];
				}

				fact_s[count_facts] = cur_char_ptr + 1;
			}
			if(count_fact_fragment == 1)
			{
				fact_p[count_facts] = cur_char_ptr + 1;
			}
			if(count_fact_fragment == 2)
			{
				fact_o[count_facts] = cur_char_ptr + 1;
			}

			count_fact_fragment++;
			if(count_fact_fragment > 2)
			{
				count_fact_fragment = 0;
				count_facts++;
			}

		}

		if(cur_char == '>')
		{
			*cur_char_ptr = 0;
		}

	//			if(*cur_char == '}')
	//				count_open_brakets--;

	//			if(*cur_char == '.' && count_open_brakets == 0)
	//			if(*cur_char == '.')
	//			{
	//				*cur_char = 0;
	//				count_fact_fragment = 0;
	//				count_facts++;
	//			}
	}

	/*
	 Stdout.format("extract_facts_from_message ... ok").newline;

	 for(int i = 0; i < count_facts; i++)
	 {
	 printf("\nfound s=%s\n", fact_s[i]);
	 printf("found p=%s\n", fact_p[i]);
	 printf("found o=%s\n\n", fact_o[i]);
	 }
	 */
	return count_facts;
}

public static final char[16] HEX_CHARS = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e',
		'f'];

public static final ulong getUUID()
{
	return Clock.now.span().nanos();
}

public static final void longToHex(ulong dl, char* buff)
{
	buff[15] = HEX_CHARS[cast(ubyte) (dl & 0x0F)];
	buff[14] = HEX_CHARS[cast(ubyte) ((dl >> 4) & 0x0F)];
	buff[13] = HEX_CHARS[cast(ubyte) ((dl >> 8) & 0x0F)];
	buff[12] = HEX_CHARS[cast(ubyte) ((dl >> 12) & 0x0F)];
	buff[11] = HEX_CHARS[cast(ubyte) ((dl >> 16) & 0x0F)];
	buff[10] = HEX_CHARS[cast(ubyte) ((dl >> 20) & 0x0F)];
	buff[9] = HEX_CHARS[cast(ubyte) ((dl >> 24) & 0x0F)];
	buff[8] = HEX_CHARS[cast(ubyte) ((dl >> 28) & 0x0F)];
	buff[7] = HEX_CHARS[cast(ubyte) ((dl >> 32) & 0x0F)];
	buff[6] = HEX_CHARS[cast(ubyte) ((dl >> 36) & 0x0F)];
	buff[5] = HEX_CHARS[cast(ubyte) ((dl >> 40) & 0x0F)];
	buff[4] = HEX_CHARS[cast(ubyte) ((dl >> 44) & 0x0F)];
	buff[3] = HEX_CHARS[cast(ubyte) ((dl >> 48) & 0x0F)];
	buff[2] = HEX_CHARS[cast(ubyte) ((dl >> 52) & 0x0F)];
	buff[1] = HEX_CHARS[cast(ubyte) ((dl >> 56) & 0x0F)];
	buff[0] = HEX_CHARS[cast(ubyte) ((dl >> 60) & 0x0F)];
//	buff[16] = 0;

//	printf("time=%s\n", buff);
}

public static char[] getString(char* s)
{
	return s ? s[0 .. strlen(s)] : cast(char[]) null;
}
