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

private enum TripleType { URI, LITERAL, SET }

public void print_list_triple(uint* list_iterator)
{
	byte* triple;
	if(list_iterator !is null)
	{
		uint next_element0 = 0xFF;
		while(next_element0 > 0)
		{
			triple = cast(byte*) *list_iterator;
			if (triple !is null)
			  print_triple(triple);
			
			next_element0 = *(list_iterator + 1);
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

	char* o = cast(char*) (triple + 6 + (*(triple + 0) << 8) + *(triple + 1) + 1 + (*(triple + 2) << 8) + *(triple + 3) + 1);

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

public void split_triples_line(char* line, ulong line_size, void delegate(char* start, int l, char* s, int s_l, char* p, int p_l, char* o, 
									   int o_l, uint  m) triple_handler)
{

  int idx_count = 0;
  bool is_beetween_tokens = false;
  int delim_num = 0;
  char sp = ' ';
  char* prev_delim = &sp;
  int facts_cnt = 0;
  int tk_start = 0;
  int fact_start = 0;


  char* start;
  int l;
  char* s;
  int s_l;
  char* p;
  int p_l;
  char* o;
  int o_l;
  uint  m;

  log.trace("#11 {}", line_size);

  // функция для определения параметров проверки разделителей
  void get_scan_param(char* c, int dn, int char_pos) {
    prev_delim = c;
    
    switch (dn) {
    case 0:
      is_beetween_tokens = false;
      delim_num = 1;
      //if (facts[facts_cnt] is null) { facts[facts_cnt] = new Triple(); }
      s = c + 1;
      start = c;
      fact_start = char_pos;
      tk_start = char_pos;
      break;
    case 1:
      is_beetween_tokens = true;
      delim_num = 2;
      s_l = char_pos - tk_start - 1;
      break;
    case 2:
      is_beetween_tokens = false;
      delim_num = 3;
      p = c + 1;
      tk_start = char_pos;
      break;
    case 3:
      is_beetween_tokens = true;
      delim_num = 4;
      p_l = char_pos - tk_start - 1;
      //      triple_handler(null, 0, s, s_l, p, p_l, null, 0, 0);      
      break;
    case 4:
      is_beetween_tokens = false;
      delim_num = 5;
      o = c + 1;
      tk_start = char_pos;
      break;
    case 5:
      is_beetween_tokens = true;
      delim_num = 6;
      o_l = char_pos - tk_start - 1;
      switch (*c)
	{
	case '>':
	  m = TripleType.URI;
	  break;
	case '}':
	  m = TripleType.SET;
	  break;
	default:
	  m = TripleType.LITERAL;
	  break;
	}
      break;
    case 6:
      is_beetween_tokens = true;
      delim_num = 0;
      l = char_pos - fact_start + 1;
      facts_cnt++;
      break;
    default:
      break;
    }
  }

  for(ulong ii = 0; ii < line_size; ii++) {
    log.trace("#33 {}", line_size);      
    char* c_ptr = line + ii;

    Stdout.format("## {} {}\n", *c_ptr, ii).newline; 

    bool is_process_needed = false;

    if (*c_ptr != ' ') {

      switch (delim_num) {
      case 0:
	is_process_needed = *(c_ptr) == '<';
	break;
      case 1:
	is_process_needed = *(c_ptr) == '>';
	break;
      case 2:
	is_process_needed = *(c_ptr) == '<';
	break;
      case 3:
	is_process_needed = *(c_ptr) == '>';
	break;
      case 4:
	is_process_needed = (*(c_ptr) == '"' || *(c_ptr) == '{' || *(c_ptr) == '<');
	break;
      case 5:
	if (ii > 0 && *(c_ptr - 1) != '\\')
	  {
	    switch (*prev_delim) {
	    case '"': 
	      is_process_needed = *(c_ptr) == '"';
	      break;
	    case '<':
	      is_process_needed = *(c_ptr) == '>';
	      break;
	    case '{':
	      is_process_needed = *(c_ptr) == '}';
	      break;
	    default:
	      is_process_needed = false;
	    }
	  }
	break;
      case 6:
	is_process_needed = *(c_ptr) == '.';
	break;
      default:
	is_process_needed = false;
	break;
      }

      if (is_process_needed) 
	{
	  get_scan_param(c_ptr, delim_num, ii);
	  if (*(c_ptr) == '.')
	    {
	      idx_count++;
	      triple_handler(start, l, s, s_l, p, p_l, o, o_l, m);
	    }
	  
	} else if (is_beetween_tokens) 
	{
	  if (delim_num == 0 && idx_count > 0) 
	    {
	      --idx_count;
	      get_scan_param(prev_delim, 6, ii);
	    } else 
	    {
	      is_beetween_tokens = false;
	      if (delim_num > 0) {--delim_num; }
	    }
	}
    }
  }
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

public static char[] getString(char* s, uint l)
{
	return s ? s[0 .. l] : cast(char[]) null;
}
