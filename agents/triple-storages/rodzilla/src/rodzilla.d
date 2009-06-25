module rodzilla;

private import tango.core.Thread;
private import tango.io.Console;
private import std.c.string;
import tango.time.StopWatch;

import Integer = tango.text.convert.Integer;

private import tango.io.Stdout;
import Text = tango.text.Util;
import tango.time.StopWatch;
import tango.io.File;

import librabbitmq_client;

File file;

class Triple
{
  char* start;
  int l;
  char* s;
  int s_l;
  char* p;
  int p_l;
  char* o;
  int o_l;
  uint  m;
}

struct Functions
{
  Triple* cmd;
  Triple* facts[];
}

private enum TripleType { URI, LITERAL, SET }

void main()
{	
  //	TripleStorage ts = new TripleStorage ();

  file = new File ("rodzilla.data");

  char[] hostname = "192.168.1.1\0";
  //	char[] hostname = "services.magnetosoft.ru\0";
  int port = 5672;
	
  librabbitmq_client client = new librabbitmq_client (hostname, port, &get_message);
	
  (new Thread(&client.listener)).start;
  Thread.sleep(0.250);

}
	
void get_message (byte* message, ulong message_size)
{

  *(message + message_size) = 0;
  char* msg = cast(char*) message;

  Triple[] facts = new Triple[ message_size / 7 ];
  int facts_count = split_triples_line(msg, message_size, facts);

  for(int fact_idx = 0; fact_idx < facts_count; fact_idx++)
    {
      if (*(facts[fact_idx].s) == 's' && *(facts[fact_idx].s + 1) == 'u' && *(facts[fact_idx].s + 2) == 'b' && 
	  *(facts[fact_idx].s + 3) == 'j' && *(facts[fact_idx].s + 4) == 'e' && *(facts[fact_idx].s + 5) == 'c' && 
	  *(facts[fact_idx].s + 6) == 't')
	{
	  if (*(facts[fact_idx].p) == 's' && *(facts[fact_idx].p + 1) == 't' && *(facts[fact_idx].p + 2) == 'o' && 
	      *(facts[fact_idx].p + 3) == 'r' && *(facts[fact_idx].p + 4) == 'e')
	    {
	      	      auto file = new File("triples.data");
	      Triple[] facts_to_store = new Triple[ facts[fact_idx].o_l / 7 ];
	      //	      Cout(str_2_char_array(facts[fact_idx].o, facts[fact_idx].o_l)).newline;
	      int fts_cnt = split_triples_line(facts[fact_idx].o, facts[fact_idx].o_l, facts_to_store);
	      for(int fts = 0; fts < fts_cnt; fts++)
		{
		  file.append(str_2_char_array(facts_to_store[fts].start, facts_to_store[fts].l));
		  file.append("\n");
		}
	    }
	}
    }


}

private int split_triples_line(char* line, ulong line_size, Triple[] facts)
{

  int idx_count = 0;

  bool is_beetween_tokens = false;

  int delim_num = 0;

  char sp = ' ';

  char* prev_delim = &sp;
  
  int facts_cnt = 0;

  int tk_start = 0;
  int fact_start = 0;
  // функция для определения параметров проверки разделителей
  void get_scan_param(char* c, int dn, int char_pos) {
    prev_delim = c;
    
    switch (dn) {
    case 0:
      is_beetween_tokens = false;
      delim_num = 1;
      if (facts[facts_cnt] is null) { facts[facts_cnt] = new Triple(); }
      facts[facts_cnt].s = c + 1;
      facts[facts_cnt].start = c;
      fact_start = char_pos;
      tk_start = char_pos;
      break;
    case 1:
      is_beetween_tokens = true;
      delim_num = 2;
      facts[facts_cnt].s_l = char_pos - tk_start - 1;
      break;
    case 2:
      is_beetween_tokens = false;
      delim_num = 3;
      facts[facts_cnt].p = c + 1;
      tk_start = char_pos;
      break;
    case 3:
      is_beetween_tokens = true;
      delim_num = 4;
      facts[facts_cnt].p_l = char_pos - tk_start - 1;
      break;
    case 4:
      is_beetween_tokens = false;
      delim_num = 5;
      facts[facts_cnt].o = c + 1;
      tk_start = char_pos;
      break;
    case 5:
      is_beetween_tokens = true;
      delim_num = 6;
      facts[facts_cnt].o_l = char_pos - tk_start - 1;
      switch (*c)
	{
	case '>':
	  facts[facts_cnt].m = TripleType.URI;
	  break;
	case '}':
	  facts[facts_cnt].m = TripleType.SET;
	  break;
	default:
	  facts[facts_cnt].m = TripleType.LITERAL;
	  break;
	}
      break;
    case 6:
      is_beetween_tokens = true;
      delim_num = 0;
      facts[facts_cnt].l = char_pos - fact_start + 1;
      facts_cnt++;
      break;
    default:
      break;
    }
  }

  for(int i = 0; i < line_size; i++) {
      
    char* c_ptr = line + i;

    char c = *c_ptr;

    bool is_process_needed = false;

    //    Stdout.format("{} : {} : {} : {} : {} ||| ", i, c, str_2_char_array(line, i), delim_num, is_beetween_tokens);
    

    if (c != ' ') {

      switch (delim_num) {
      case 0:
	is_process_needed = c == '<';
	break;
      case 1:
	is_process_needed = c == '>';
	break;
      case 2:
	is_process_needed = c == '<';
	break;
      case 3:
	is_process_needed = c == '>';
	break;
      case 4:
	is_process_needed = (c == '"' || c == '{' || c == '<');
	break;
      case 5:
	if (i > 0 && *(c_ptr - 1) != '\\')
	  {
	    switch (*prev_delim) {
	    case '"': 
	      is_process_needed = c == '"';
	      break;
	    case '<':
	      is_process_needed = c == '>';
	      break;
	    case '{':
	      is_process_needed = c == '}';
	      break;
	    default:
	      is_process_needed = false;
	    }
	  }
	break;
      case 6:
	is_process_needed = c == '.';
	break;
      default:
	is_process_needed = false;
	break;
      }

      if (is_process_needed) 
	{
	  if (c == '.') 
	    idx_count++;
	  get_scan_param(c_ptr, delim_num, i);
	  //	  	  Cout("3").newline;
	} else if (is_beetween_tokens) 
	{
	  if (delim_num == 0 && idx_count > 0) 
	    {
	      //	      Cout("1").newline;
	      --idx_count;
	      get_scan_param(prev_delim, 6, i);
	    } else 
	    {
	      //	      Cout("2 ").newline;
	      //	      get_scan_param(c_ptr, 
	      is_beetween_tokens = false;
	      if (delim_num > 0) {--delim_num; }
			       //, i
			     //);

	    }
	}
    }
  }

  return facts_cnt;

}

private char[] str_2_char_array(char* str, ulong len)
{
  if (str is null)
    return "null";
		
  char[] res = new char[len];

  for(uint i = 0; i < len; i++)
    {
      res[i] = *(str + i);
    }

  return res;
}

unittest
{
  // split_triples_line
  char[] tripletsLine = "<s1><p1>{<ss><pp><oo>.<ss1><pp1><oo1>.}.<s2><p2>\"uid1\".<s3><p3>\"o3\\\"\".";
  char* tripletsLine_ptr = &tripletsLine[0];

  Triple[] facts = new Triple[ tripletsLine.length / 7 ];
  int fns = split_triples_line(tripletsLine_ptr, tripletsLine.length, facts);

  for(int i = 0; i < fns; i++)
    {
      Cout(str_2_char_array(facts[i].s, facts[i].s_l)).newline;
      //      Cout(str_2_char_array(facts[i].p, facts[i].p_l)).newline;
      //      Cout(str_2_char_array(facts[i].o, facts[i].o_l)).newline;
      //      Stdout.format("{}",facts[i].m).newline;
      //      Cout("").newline;
    }

  assert(fns == 3);

  assert(str_2_char_array(facts[0].s, facts[0].s_l) == "s1");
  assert(str_2_char_array(facts[0].p, facts[0].p_l) == "p1");
  assert(str_2_char_array(facts[0].o, facts[0].o_l) == "<ss><pp><oo>.<ss1><pp1><oo1>.");
  assert(facts[0].m == TripleType.SET);
  Cout(str_2_char_array(facts[0].start, facts[0].l)).newline;
  assert(str_2_char_array(facts[0].start, facts[0].l) == "<s1><p1>{<ss><pp><oo>.<ss1><pp1><oo1>.}.");

  assert(str_2_char_array(facts[1].s, facts[1].s_l) == "s2");
  assert(str_2_char_array(facts[1].p, facts[1].p_l) == "p2");
  assert(str_2_char_array(facts[1].o, facts[1].o_l) == "uid1");
  assert(facts[1].m == TripleType.LITERAL);

  assert(str_2_char_array(facts[2].s, facts[2].s_l) == "s3");
  assert(str_2_char_array(facts[2].p, facts[2].p_l) == "p3");
  assert(str_2_char_array(facts[2].o, facts[2].o_l) == "o3\\\"");
  assert(facts[1].m == TripleType.LITERAL); 

  /*  char[] large_triple_set = "
<_:Directive0> <http://magnetosoft.ru/ontology/isPrivate> \"true\" .<_:Directive0> <http://magnetosoft.ru/ontology/documentType> \"1791\" .<_:Directive0> <http://purl.org/dc/elements/1.1/title> \"О списании затрат по объекту \\\" Главный корпус №2. ЦОГП. Расширение помещения склада готовой продукции\\\"\" .<_:Directive0> <http://magnetosoft.ru/ontology/fileAttachment> \"c294f2f9-828f-4878-af11-eda188039b3f\" .<_:Directive1> <http://magnetosoft.ru/ontology/id> \"b8602efe38bd4c5c85d519e8db0e5130\" .";

  Triple[] large_facts = new Triple[ large_triple_set.length / 7 ];
  int large_fns = split_triples_line(&large_triple_set[0], large_triple_set.length, large_facts); 

  for(int i = 0; i < large_fns; i++)
    {
      Cout(str_2_char_array(large_facts[i].s, large_facts[i].s_l)).newline;
      Cout(str_2_char_array(large_facts[i].p, large_facts[i].p_l)).newline;
      Cout(str_2_char_array(large_facts[i].o, large_facts[i].o_l)).newline;
      Stdout.format("{}",large_facts[i].m).newline;
      Cout("").newline;
      }*/

}