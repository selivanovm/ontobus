module rodzilla;

private import tango.core.Thread;
private import tango.io.Console;
private import std.c.string;
import tango.time.StopWatch;
import tango.io.stream.DataFileStream;
private import tango.io.FileConduit;

import Integer = tango.text.convert.Integer;

private import tango.io.Stdout;
import Text = tango.text.Util;
import tango.time.StopWatch;
import tango.io.File;

import librabbitmq_client;
import tango.time.WallClock;

//File file;
DataFileOutput file;
FileConduit conduit;
FilePath path;

class Triple
{
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

  //  file = new File ("rodzilla.data");


  char[] hostname = "192.168.150.197\0";


  path = new FilePath("triples.data");

  if (path.exists)
    conduit = new FileConduit(path.toString(), FileConduit.WriteAppending);
  else
    conduit = new FileConduit(path.toString(), FileConduit.WriteCreate);

  file = new DataFileOutput(conduit, 1000, false);

  //	char[] hostname = "services.magnetosoft.ru\0";
  int port = 5672;
	
  librabbitmq_client client = new librabbitmq_client (hostname, port, &get_message);
	
  (new Thread(&client.listener)).start;
  Thread.sleep(0.250);

}

void store_triplet(char* start, int l, char* s, int s_l, char* p, 
		   int p_l, char* o, int o_l, uint  m)
{
  //  for(int i = 0; i < l; i++)
  file.buffer.append(start, l);
  file.write("\n");
}

void parse_functions(char* start, int l, char* s, int s_l, char* p, 
		     int p_l, char* o, int o_l, uint  m)
{
  if (*s == 's' && *(s + 1) == 'u' && *(s + 2) == 'b' && 
      *(s + 3) == 'j' && *(s + 4) == 'e' && *(s + 5) == 'c' && 
      *(s + 6) == 't')
    {
      if (*p == 's' && *(p + 1) == 't' && *(p + 2) == 'o' && 
	  *(p + 3) == 'r' && *(p + 4) == 'e')
	{
	  split_triples_line(o, o_l, &store_triplet);
	} else if (*p == 'g' && *(p + 1) == 'e' && *(p + 2) == 't')
	{
	  
	}
    }
}
	
void get_message (byte* message, ulong message_size)
{

  auto elapsed = new StopWatch();  
  elapsed.start;
	
  *(message + message_size) = 0;
  //  char* msg = ;

  split_triples_line(cast(char*) message, message_size, &parse_functions);

  file.flush;

  double time = elapsed.stop;  

  TimeOfDay tod = WallClock.now.time;
  Stdout.format("{}:{:d02}:{:d02}:{:d002} | {:d6};{:d6}", tod.hours, tod.minutes, tod.seconds, tod.millis, time, message_size).newline;

}

private void split_triples_line(char* line, ulong line_size, void function(char* start, int l, char* s, int s_l, char* p, 
									   int p_l, char* o, int o_l, uint  m) triple_handler)
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

  for(int i = 0; i < line_size; i++) {
      
    char* c_ptr = line + i;

    //    char c = *c_ptr;

    bool is_process_needed = false;

    //    Stdout.format("{} : {} : {} : {} : {} ||| ", i, c, str_2_char_array(line, i), delim_num, is_beetween_tokens).newline;
    

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
	if (i > 0 && *(c_ptr - 1) != '\\')
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
	  get_scan_param(c_ptr, delim_num, i);
	  if (*(c_ptr) == '.')
	    {
	      idx_count++;
	      triple_handler(start, l, s, s_l, p, p_l, o, o_l, m);
	    }
	  
	  //	  get_scan_param(c_ptr, delim_num, i);
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

  //  return facts_cnt;

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

void fn(char* c_ptr, uint c_length)
{
  Cout(str_2_char_array(c_ptr, c_length)).newline;
}

unittest
{
  // split_triples_line
  char[] tripletsLine = "<s1><p1>{<ss><pp><oo>.<ss1><pp1><oo1>.}.<s2><p2>\"uid1\".<s3><p3>\"o3\\\"\".";
  char* tripletsLine_ptr = &tripletsLine[0];


  //  split_triples_line(tripletsLine_ptr, tripletsLine.length, &fn);

  /*Triple[] facts = new Triple[ tripletsLine.length / 7 ];
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