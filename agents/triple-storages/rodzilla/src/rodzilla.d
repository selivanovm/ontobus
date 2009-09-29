module rodzilla;

import tango.io.stream.MapStream;

import tango.core.Thread;
import tango.io.Console;
import tango.text.convert.Format;
import tango.io.FileScan;
import tango.io.stream.DataFileStream;
import tango.io.FileConduit;

import tango.stdc.string;
import tango.stdc.stdio;
import tango.stdc.stdlib;
import tango.io.Stdout;
import tango.text.locale.Locale;
import tango.time.StopWatch;
import tango.time.WallClock;

import librabbitmq_client;

const time_mark_size = 15;
const TRIPLES_IN_PACKET = 500;

DataFileOutput file;
FileConduit conduit;
FilePath path;
Locale locale;
char[] now;

librabbitmq_client client;

private enum TripleType { URI, LITERAL, SET }

uint functions_cnt = 0;
const uint MAX_FUNCTIONS_IN_MESSAGE = 1000;

char[] PUT = "magnet-ontology/logging#put";
char[] GET = "magnet-ontology/logging#get";
char[] SUBJECT = "magnet-ontology#subject";
char[] ARGUMENT = "magnet-ontology/transport#argument";
char[] RESULT_DATA = "magnet-ontology/transport#result:data";
char[] RESULT_STATE = "magnet-ontology/transport#result:state";
char[] REPLY_TO = "magnet-ontology/transport#reply_to";

uint fn_cnt = 0;
uint args_cnt = 0;
uint reply_to_cnt = 0;

char*[] fn_names;
uint[] fn_names_l;

char*[] fn_uids;
uint[] fn_uids_l;

char*[] args;
uint[] args_l;

char*[] args_uids;
uint[] args_uids_l;

char*[] reply_to;
uint[] reply_to_l;

char*[] reply_to_uids;
uint[] reply_to_uids_l;

void main()
{	

  fn_names = new char*[1000];
  fn_names_l = new uint[1000];

  fn_uids = new char*[1000];
  fn_uids_l = new uint[1000];

  reply_to = new char*[1000];
  reply_to_l = new uint[1000];

  args = new char*[1000];
  args_l = new uint[1000];
  
  args_uids = new char*[1000];
  args_uids_l = new uint[1000];

  reply_to = new char*[1000];
  reply_to_l = new uint[1000];

  reply_to_uids = new char*[1000];
  reply_to_uids_l = new uint[1000];

  char[][char[]] props = load_props;

  Cout(Format("{:d15} ", WallClock.now.span.millis));

  char[] hostname = make_null_string(props["amqp_server_address"]);
  int portt = atoi(&(props["amqp_server_port"][0]));

  /*      result["amqp_server_address"] = "localhost";
      result["amqp_server_port"] = "5762";
      result["amqp_server_exchange"] = "";
      result["amqp_server_login"] = "rodzilla";
      result["amqp_server_password"] = "rodzilla_password";
      result["amqp_server_routingkey"] = "";
      result["amqp_server_queue"] = "store";*/



  auto locale = new Locale();
  path = new FilePath(locale ("./data/{:yyyy-MM-dd}.triples", WallClock.now));

  if (path.exists)
    conduit = new FileConduit(path.toString(), FileConduit.WriteAppending);
  else
    conduit = new FileConduit(path.toString(), FileConduit.WriteCreate);

		   //  file = new DataFileOutput(conduit, 1000, false);
  file = new DataFileOutput(conduit);

  client = new librabbitmq_client (hostname, portt, make_null_string(props["amqp_server_login"]), props["amqp_server_password"],
				   props["amqp_server_queue"], props["amqp_server_vhost"]);

  client.set_callback(&get_message);
  (new Thread(&client.listener)).start;
  Thread.sleep(0.250);

}

void store_triplet(char* start, int l, char* s, int s_l, char* p, 
		   int p_l, char* o, int o_l, uint  m)
{
  file.write(now);
  char[] line = new char[l];
  memcpy (cast(void*)line.ptr, cast(void*)start, l);
  file.write(line);
  file.write("\n");
}

void get_triplet(char* uid, uint u_l, char* destination, uint d_l)
{

  char[] dst = new char[d_l];
  for(int i = 0; i < d_l; i++) {
    dst[i] = *(destination + i);
  }

  char[] uid_str = new char[u_l];
  for(int i = 0; i < u_l; i++) {
    uid_str[i] = *(uid + i);
  }

  char[] buffer = new char[ TRIPLES_IN_PACKET * 5000 ];
  char* buf_ptr = &buffer[0];

  int msg_length = 0;
  int triples_count = 0;
  char[] header = "<" ~ uid_str ~ "><" ~ RESULT_DATA  ~ ">{\0";
  char[] footer = "}.\0";
  char[] root = "./data/";
  auto scan = (new FileScan)(root, ".triples");

  int total_chars_sent = 0;
  int total_triples_sent = 0;

  char[] line = new char[5000];
  char* line_ptr = &(line[0]);
  char* t;

  foreach (file; scan.files)
    {
      memcpy(buf_ptr, cast(char*)header, header.length - 1);
      msg_length = header.length - 1;

      FILE *data_file = fopen ( &(file.toString[0]), "r" );

      if (data_file != null)
	{
 
	  while ( fgets ( line_ptr, 5000, data_file ) != null )
	    {
	      
	      if (line.length > time_mark_size)
		{
		  triples_count++;

		  uint line_length = time_mark_size;
		  for(; line_length < 5000; line_length++)
		    {
		      if (*(line_ptr + line_length) == '\n' || *(line_ptr + line_length) == 0)
			  break;
		      *(buf_ptr + msg_length++) = *(line_ptr + line_length);
		    }

		  if (triples_count == TRIPLES_IN_PACKET)
		    {
		      memcpy(buf_ptr + msg_length, cast(char*)footer, footer.length - 1);
		      msg_length += footer.length - 1;
		      *(buf_ptr + msg_length) = 0;

		      client.send(&dst[0], buf_ptr);

		      total_chars_sent += msg_length;
		      total_triples_sent += triples_count;

		      memcpy(buf_ptr, cast(char*)header, header.length - 1);
		      msg_length = header.length - 1;
		      triples_count = 0;
		    } 
		}
  	      
	    }
	  fclose(data_file);
	}

      if (triples_count > 0)
	{

	  memcpy(buf_ptr + msg_length, cast(char*)footer, footer.length - 1);
	  msg_length += footer.length - 1;

	  *(buf_ptr + msg_length) = 0;
	  //	  printf("%s\n", buf_ptr);
	  client.send(&dst[0], buf_ptr);
	  total_chars_sent += msg_length;
	  total_triples_sent += triples_count;
	}
    }

    char[] state_message = "<" ~ uid_str ~ "><" ~ RESULT_STATE ~ ">\"ok\".\0";
    client.send(&dst[0], &state_message[0]);

    Stdout.format("Total sent: {} chars, {} triples", total_chars_sent, total_triples_sent).newline;

}

void parse_functions(char* start, int l, char* s, int s_l, char* p, int p_l, char* o, int o_l, uint  m)
{
  if (cmp_str(p, p_l, SUBJECT)) {

    // сохраняем uid
    fn_uids[fn_cnt] = s;
    fn_uids_l[fn_cnt] = s_l;

    // сохраняем функцию
    fn_names[fn_cnt] = o;
    fn_names_l[fn_cnt] = o_l;

    fn_cnt++;

  } else if (cmp_str(p, p_l, ARGUMENT)) {

    // сохраняем uid
    args_uids[args_cnt] = s;
    args_uids_l[args_cnt] = s_l;

    // сохраняем аргумент
    args[args_cnt] = o;
    args_l[args_cnt] = o_l;

    args_cnt++;

  } else if (cmp_str(p, p_l, REPLY_TO)) {
    
    reply_to_uids[reply_to_cnt] = s;
    reply_to_uids_l[reply_to_cnt] = s_l;

    reply_to[reply_to_cnt] = o;
    reply_to_l[reply_to_cnt] = o_l;

    reply_to_cnt++;

  }

}
	
void get_message (byte* message, ulong message_size)
{

  auto elapsed = new StopWatch();  
  now = Format("{:d15}", WallClock.now.span.millis); // field has size of time_mark_size characters
  elapsed.start;
	
  *(message + message_size) = 0;

  //  Cout(str_2_char_array(cast(char*)message, message_size));
  
  fn_cnt = 0;
  args_cnt = 0;
  reply_to_cnt = 0;

  split_triples_line(cast(char*) message, message_size, &parse_functions);

  char* reply_to_ptr;
  uint reply_to_length;

  for(uint i = 0; i < fn_cnt; i++) {

    reply_to_ptr = null;
    reply_to_length = 0;
    
    for(uint k = 0; k < reply_to_cnt; k++) {
      if (cmp_str(fn_uids[i], fn_uids_l[i], reply_to_uids[k], reply_to_uids_l[k])) {
	reply_to_ptr = reply_to[k];
	reply_to_length = reply_to_l[k];
      }
    }

    if (reply_to_ptr == null || reply_to_length == 0) {
      continue;
    }

    if (cmp_str(fn_names[i], fn_names_l[i], PUT)) {
      for(uint j = 0; j < args_cnt; j++) {
	if (cmp_str(fn_uids[i], fn_uids_l[i], args_uids[j], args_uids_l[j])) {
	 split_triples_line(args[j], args_l[j], &store_triplet);	  
	}
      }
    } else if (cmp_str(fn_names[i], fn_names_l[i], GET)) {
      uint arg_idx  = -1;
      for(uint j = 0; j < args_cnt; j++) {
	if (cmp_str(fn_uids[i], fn_uids_l[i], args_uids[j], args_uids_l[j])) {
	  //	  split_triples_line(args[j], args_l[j], &get_triplet(fn_uids[i], fn_uids_l[i], reply_to_ptr, reply_to_length);
	}
      }
    }

  }
  file.flush;

  double time = elapsed.stop;  

  TimeOfDay tod = WallClock.now.time;
  Stdout.format("{}:{:d02}:{:d02}:{:d002} | {:d6};{:d6}", tod.hours, tod.minutes, tod.seconds, tod.millis, time, message_size).newline;

}

private void split_triples_line(char* line, ulong line_size, void function(char* start, int l, char* s, int s_l, char* p, int p_l, char* o, 
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
	  
	} else if (is_beetween_tokens) 
	{
	  if (delim_num == 0 && idx_count > 0) 
	    {
	      --idx_count;
	      get_scan_param(prev_delim, 6, i);
	    } else 
	    {
	      is_beetween_tokens = false;
	      if (delim_num > 0) {--delim_num; }
	    }
	}
    }
  }
}

private int parse_query(char* query, uint query_length)
{
  //  split_triples_line(query, query_length, &eval_query_triple);

  Cout(str_2_char_array(query, query_length)).newline;

  char[] OP_AND = "and";
  char[] OP_OR = "or";
  char[] OP_SELECT = "select";
  char[] OP_WHERE = "where";

  char*[] variables = new char*[1000];
  uint[] variables_l = new uint[1000];
  uint variables_cnt = 0;

  uint char_idx = 0;
  char* prev_c = null;
  char* c = null;
  char* token_start_ptr = null;

  uint token_length = 0;
  
  bool is_new_token = false;

  uint query_part = 0;

  uint patterns_cnt = 0;
  uint pattern_token_cnt = 0;

  char*[] patterns_op = new char*[1000];
  uint[] patterns_op_l = new uint[1000];
  uint[] patterns_op_map = new uint[1000];
  uint patterns_op_cnt = 0;

  uint variables_to_return_cnt = 0;

  bool is_open_brace = false;
  bool is_open_quota = false;
  bool is_delimiter = false;

  while (char_idx < query_length)
    {
      c = (query + char_idx++);

      //      Stdout.format("<{}>", "" ~ *c).newline;

      switch (query_part)
	{
	case 2:
	  if ((*c == ' ' && !is_open_quota) || 
	      (*prev_c != '\\' && (*c == '{' && !is_open_brace) || ((*c == '"' || *c == '}') && is_open_brace)))
	    is_delimiter = true;
	  else
	    is_delimiter = false;
	  break;
	default:
	  if (*c == ' ')
	    is_delimiter = true;
	  else
	    is_delimiter = false;
	  break;
	}

      //      Stdout.format("{} : is_open_brace = {}, is_open_quota={} is_delimiter={}, is_new_token={}", 
      //	    "I='" ~ *c ~ '\'', is_open_brace, is_open_quota, is_delimiter, is_new_token).newline;
      
      if (is_delimiter)
	{
	  if (is_new_token)
	    {
	      token_length = c - token_start_ptr;
	      Cout("|");
	      Cout(str_2_char_array(token_start_ptr, token_length));
	      Cout("|").newline;

	      switch (query_part)
		{
		case 0: //select
		  if (!cmp_str(OP_SELECT.ptr, OP_SELECT.length, token_start_ptr, token_length))
		    {
		      Cout("ERROR! Select part must be first query part.").newline;
		      return -1;
		    }
		  query_part++;
		  break;
		case 1: // variables
		  if (cmp_str(OP_WHERE.ptr, OP_WHERE.length, token_start_ptr, token_length))
		    {
		      if (variables_to_return_cnt < 1)
			{
			  Cout("ERROR! Variables count must be non zero.");
			  return -1;
			}
		      Cout("Variables: ");
		      for(uint i = 0; i < variables_to_return_cnt; i++)
			{
			  Stdout.format("{} ", str_2_char_array(variables[i], variables_l[i]));
			}
		      Cout("\n");
		      query_part++;
		    } 
		  else
		    {
		      variables[variables_cnt] = token_start_ptr;
		      variables_l[variables_cnt] = token_length;
		      variables_cnt++;
		      variables_to_return_cnt++;
		    }
		  break;
		case 2: //patterns
		  //		  Stdout.format("{}", "" ~ *c).newline;
		  if (*c == ' ')
		    {
		      if (!is_open_brace)
			{
			  patterns_op[patterns_op_cnt] = token_start_ptr;
			  patterns_op_l[patterns_op_cnt] = token_length;
			  patterns_op_map[patterns_op_cnt] = patterns_cnt;
			  patterns_op_cnt++;
			}
		    }
		  else if (*c == '}')
		    {
		      is_open_brace = false;
		    }
		  else if (*c == '"')
		    {
		      if (is_open_quota == true) 
			{
			  is_open_quota = false;
			}
		      else
			is_open_quota = true;
		    }
		  break;
		default:
		  break;
		}
	      is_new_token = false;
	    }
	  else
	    {
	      if (query_part == 2)
		{
		  if (!is_open_brace && *c == '{')
		    {
		      is_open_brace = true;
		    } 
		  else if (*c == '"')
		    {
		      is_open_quota = ! is_open_quota;
		    }
		  else if (*c == '}')
		    {
		      is_open_brace = false;
		    }
		}
	    } 
	}
      else
	{
	  if (!is_new_token)
	    {
	      token_start_ptr = query + char_idx - 1;
	      is_new_token = true;
	    }
	  
	}
      prev_c = c;
    }
  
  return 0;

}

private void eval_query_triple(char* start, int l, char* s, int s_l, char* p, int p_l, char* o, int o_l, uint  m) {
  Cout(str_2_char_array(s, s_l)).newline;
  Cout(str_2_char_array(p, p_l)).newline;
  Cout(str_2_char_array(o, o_l)).newline;
}

private char[] str_2_char_array(char* str, uint len)
{
  if (str is null)
    return "null";
		
  char[] res = new char[len];

  for(uint i = 0; i < len; i++)
    res[i] = *(str + i);

  return res;
}

// Loads server properties
private char[][char[]] load_props()
{
  char[][char[]] result;
  FileConduit props_conduit;

  auto props_path = new FilePath("./rodzilla.properties");

  if (!props_path.exists) // props file doesn't exists, so create new one with defaults
    {
      result["amqp_server_address"] = "localhost";
      result["amqp_server_port"] = "5762";
      result["amqp_server_exchange"] = "";
      result["amqp_server_login"] = "rodzilla";
      result["amqp_server_password"] = "rodzilla_password";
      result["amqp_server_routingkey"] = "";
      result["amqp_server_queue"] = "store";

      props_conduit = new FileConduit(props_path.toString(), FileConduit.ReadWriteCreate);
      auto output = new MapOutput!(char)(props_conduit.output);

      output.append(result);
      output.flush;
      props_conduit.close;
    }
  else
    {
      props_conduit = new FileConduit(props_path.toString(), FileConduit.ReadExisting);
      auto input = new MapInput!(char)(props_conduit.input);
      result = result.init;
      input.load(result);
      props_conduit.close;
    }

  return result;
}

// make null string form common string
char[] make_null_string(char[] str)
{
  char[] result = new char[str.length + 1];
  char* result_ptr = &result[0];
  char* str_ptr = &str[0];
  memcpy(result_ptr, str_ptr, str.length);
  result[str.length] = '\0';
  return result;
}

bool cmp_str(char* buf1, uint l1, char[] buf2) {
  if (l1 != buf2.length)
    return false;
  if (l1 == 0)
    return true;

  char* bbuf = &buf2[0];
  for(uint i = 0; i < l1; i++) {
    if (*(buf1 + i) != *(bbuf + i))
      return false;
  }
  return true;
}

bool cmp_str(char* buf1, uint l1, char* buf2, uint l2) {
  if (l1 != l2)
    return false;
  if (l1 == 0)
    return true;

  for(uint i = 0; i < l1; i++) {
    if (*(buf1 + i) != *(buf2 + i))
      return false;
  }
  return true;
}

void print_buf(char* buf, uint l) {
  if (buf != null && l > 0) {
    
    for(uint i = 0; i < l; i++) {
      Stdout.format("{}", *(buf + i));
    }
    Cout("\n");
  }
}

unittest {

  char[] query = " select ?x ?y  where {?x \"pred1\"  \"obj1\"} and {?y \"pred1\" ?x}.";
  int result = parse_query(query.ptr, query.length);
  assert(result == 0);


  query = " seldect ?x ?y  where x? \"pred1\"  \"obj1\" and ?y \"pred1\" ?x.";
  result = parse_query(query.ptr, query.length);
  assert(result == -1);

  exit(0);

}