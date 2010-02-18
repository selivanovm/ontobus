module autotest;

private import Predicates;
private import mom_client;
private import Log;
private import tango.io.File;
//private import Text = tango.text.Util;
private import tango.text.Text;
//private import tango.text.Regex;
private import portions_read;
private import tango.stdc.string;
private import tango.stdc.stringz;
private import tango.stdc.stdio;

void function(byte* txt, ulong size, mom_client from_client) message_acceptor;

private char* output_data = null;
private int count_commands = 0;
private long count_repeat;
private bool nocompare;

private static mom_client im;

class autotest: mom_client
{
	char[] message_log_file_name;

	this(char[] _message_log_file_name, long _count_repeat, bool _nocompare)
	{
		count_repeat = _count_repeat;
		nocompare = _nocompare;
		message_log_file_name = _message_log_file_name;
		log.trace("open message_log file [{}]", message_log_file_name);
		im = this;
	}

	void set_callback(void function(byte* txt, ulong size, mom_client from_client) _message_acceptor)
	{
		message_acceptor = _message_acceptor;
	}

	int send(char* routingkey, char* messagebody)
	{

		if(nocompare == false && strcmp(messagebody, output_data) != 0)
		{
			printf("\nCOMPARE OUTPUT message from file: %s\n", output_data);
			printf("\nCOMPARE OUTPUT message accepted : %s\n", messagebody);
			log.trace("out messages\r\n[{}]", fromStringz(messagebody));
			log.trace("not compare with original \r\n[{}]", fromStringz(output_data));
			throw new Exception("out messages not compare with original");

		}
		
//		log.trace("prepare block #6");
		return 0;
	}
	
	char* get_message()
	{
		throw new Exception ("not implemented");
	}
	void listener()
	{
		log.trace("autotest listen!");

		for(long i = 0; i < count_repeat; i++)
		{
			parse_file(message_log_file_name, "\r", "\r\n\r\n\r\n", &prepare_block);
		}

		log.trace("autotest listen end, count commands: {}", count_commands);
	}

}

void prepare_block(char* line, ulong line_length)
{
	line[line_length] = 0;

	char* end_io_block = strstr(line, "\r\n\r\n\r\n");
	if(end_io_block !is null)
		*end_io_block = 0;
	
	log.trace("read new block {}", line[0 .. (end_io_block-line)]);
	
	char* input_data = strstr(line, "INPUT");

	if(input_data !is null)
	{
		input_data += 7;
	}

	output_data = strstr(input_data, "OUTPUT");
	
	if (output_data is null)
	{
		printf("\nINPUT %s\n", input_data);
		throw new Exception ("OUTPUT message not found");
	}
	
	if(output_data !is null)
	{
		*output_data = 0;
		output_data += 8;
	}

	char* end_input_block = strstr(input_data + 2, "\r\n");
	if(end_input_block !is null)
		*end_input_block = 0;
	else
		end_input_block = end_io_block;
	
	int size = end_input_block - input_data;
	
	if (size < 0)
		throw new Exception ("autotest:prepare_block, size < 0");
	
//		printf("\nINPUT %d: %s\n", size, input_data);

//		printf("\nOUTPUT: %s\n", output_data);
		

	if(strstr(input_data, CREATE.ptr) !is null && strstr(input_data, "<>") !is null && output_data !is null)
	{
		log.trace("#i1 result_data_header={}", result_data_header);
//				printf("\nINPUT %d: %s\n", size, input_data);

//				printf("\nOUTPUT: %s\n", output_data);

		// это команда на создание записи авторизации
		
		char* result_id = strstr(output_data, result_data_header.ptr);
		if(result_id !is null)
			result_id += result_data_header.length;

		printf("\nresult_id: %s\n", result_id);
		log.trace("#i1-1 result_id = {}", result_id);

		int size_id = strlen(result_id) - 2;
		log.trace("#i1-2");
		char[] result_id_text = result_id[0 .. size_id];
		log.trace("#i1-3");
		char[] qqq = input_data[0 .. size];
		log.trace("#i1-4");
		

		//		auto rr = Regex(result_id_text).replaceAll ("<>", "<" ~ result_id_text ~ ">");
		//		printf("\nresult: %s\n", rr.ptr);

		auto input_data_text = new Text!(char)(qqq);
		while(strstr(input_data_text.toString().ptr, "<>") !is null)
		{
			input_data_text.select("<>");
			input_data_text.replace("<" ~ result_id_text ~ ">");
		}
		log.trace("#i1-5");

		input_data = toStringz(input_data_text.toString());
		size = strlen(input_data);

//				printf("\nresult: %s\n", input_data);
		log.trace("#i2");
	}
	
	log.trace("message_acceptor #in");
	message_acceptor(cast(byte*) input_data, size, im);
	log.trace("message_acceptor #out");
	count_commands++;
}
