module rodzilla;

import tango.io.stream.MapStream;

import tango.core.Thread;
import tango.io.Console;
import tango.text.convert.Format;
import tango.io.FileScan;
import tango.io.stream.DataFileStream;
import tango.io.FileConduit;

import std.c.string;
import std.c.stdio;
import std.string;
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

void main()
{	

  char[][char[]] props = load_props;

  Cout(Format("{:d15} ", WallClock.now.span.millis));

  char[] hostname = make_null_string(props["amqp_server_address"]);
  int port = atoi(props["amqp_server_port"]);

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

  file = new DataFileOutput(conduit, 1000, false);
	
  client = new librabbitmq_client (hostname, port, &get_message);
	
  (new Thread(&client.listener)).start;
  Thread.sleep(0.250);

}

void store_triplet(char* start, int l, char* s, int s_l, char* p, 
		   int p_l, char* o, int o_l, uint  m)
{
  file.write(now);
  file.buffer.append(start, l);
  file.write("\n");
}

void get_triplet(char* destination)
{

  char[] buffer = new char[ TRIPLES_IN_PACKET * 5000 ];
  char* buf_ptr = &buffer[0];

  int msg_length = 0;
  int triples_count = 0;
  char[] header = "<subject><put>{\0";
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
		      if (*(line_ptr + line_length) == '\n' || *(line_ptr + line_length) == '0')
			  break;
		      *(buf_ptr + msg_length++) = *(line_ptr + line_length);
		    }

		  if (triples_count == TRIPLES_IN_PACKET)
		    {
		      memcpy(buf_ptr + msg_length, cast(char*)footer, footer.length - 1);
		      msg_length += footer.length - 1;
		      *(buf_ptr + msg_length) = 0;

		      client.send(destination, buf_ptr);

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
	  client.send(destination, buf_ptr);
	  total_chars_sent += msg_length;
	  total_triples_sent += triples_count;
	}
    }

    Stdout.format("Total sent: {} chars, {} triples", total_chars_sent, total_triples_sent).newline;

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
	  *(o + o_l) = 0;
	  get_triplet(o);
	}
    }
}
	
void get_message (byte* message, ulong message_size)
{

  auto elapsed = new StopWatch();  
  now = Format("{:d15}", WallClock.now.span.millis); // field has size of time_mark_size characters
  elapsed.start;
	
  *(message + message_size) = 0;

  //  Cout(str_2_char_array(cast(char*)message, message_size));

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

private char[] str_2_char_array(char* str, uint len)
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

// Loads server properties
private char[][char[]] load_props()
{
  char[][char[]] result;
  FileConduit props_conduit;

  path = new FilePath("./rodzilla.properties");

  if (!path.exists)
    {

      result["amqp_server_address"] = "localhost";
      result["amqp_server_port"] = "5762";
      result["amqp_server_exchange"] = "";
      result["amqp_server_login"] = "rodzilla";
      result["amqp_server_password"] = "rodzilla_password";
      result["amqp_server_routingkey"] = "";
      result["amqp_server_queue"] = "store";

      props_conduit = new FileConduit(path.toString(), FileConduit.ReadWriteCreate);
      auto output = new MapOutput!(char)(props_conduit.output);

      output.append(result);
      output.flush;
      props_conduit.close;

      return result;

    }

  props_conduit = new FileConduit(path.toString(), FileConduit.ReadExisting);
  auto input = new MapInput!(char)(props_conduit.input);
  result = result.init;
  input.load(result);
  props_conduit.close;
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