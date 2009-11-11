private import mom_client;
private import Log;
private import tango.io.File;
private import Text = tango.text.Util;
private import portions_read;
private import tango.stdc.string;
private import tango.stdc.stdio;

void function(byte* txt, ulong size) message_acceptor;

class autotest: mom_client
{
	char[] message_log_file_name;

	this(char[] _message_log_file_name)
	{
		message_log_file_name = _message_log_file_name;
		log.trace("open message_log file [{}]", message_log_file_name);

	}

	void set_callback(void function(byte* txt, ulong size) _message_acceptor)
	{
		message_acceptor = _message_acceptor;
	}

	int send(char* routingkey, char* messagebody)
	{
		return 0;
	}

	void listener()
	{
		log.trace("autotest listen!");

		parse_file(message_log_file_name, "\r", "ok\".", &prepare_block);

		log.trace("autotest listen stop");
	}

}

void prepare_block(char* line, ulong line_length)
{
	line[line_length] = 0;
	//	log.trace("read new block {}", line[0 .. line_length]);
	char* input_data = strstr(line, "INPUT");

	if(input_data !is null)
	{
		input_data += 7;
	}

	char* output_data = strstr(line, "OUTPUT");

	if(output_data !is null)
	{
		*output_data = 0;
		output_data += 8;
	}

	char* end_input_block = strstr(input_data + 2, "\r\n");
	if(end_input_block !is null)
		*end_input_block = 0;

	int size = end_input_block - input_data;
	//	printf("\nINPUT%d:%s\n", size, input_data);

	message_acceptor(cast(byte*) input_data, size);

	//	printf("\nOUTPUT:%s\n", output_data);
}
