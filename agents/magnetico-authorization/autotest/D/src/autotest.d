private import Log;
private import tango.io.File;
//private import Text = tango.text.Util;
private import tango.text.Text;
//private import tango.text.Regex;
private import portions_read;
private import tango.stdc.string;
private import tango.stdc.stringz;
private import tango.stdc.stdio;
import tango.io.Stdout;

private import tango.core.Thread;

private char* output_data = null;
private int count_commands = 0;
private long count_repeat;
private bool nocompare;

private import amqp_messages;

char[] hostname;
int port;
char[] vhost;
char[] login;
char[] passw;
char[] exchange;
private long count_send_messages = 0;
amqp_messages client;

class autotest
{
	char[] message_log_file_name;

	this(char[] _message_log_file_name, long _count_repeat, bool _nocompare, char[] _hostname, int _port, char[] _vhost, char[] _exchange,
			char[] _login, char[] _passw)
	{
		hostname = _hostname;
		port = _port;
		vhost = _vhost;
		login = _login;
		passw = _passw;
		exchange = _exchange;

		count_repeat = _count_repeat;
		nocompare = _nocompare;
		message_log_file_name = _message_log_file_name;
		log.trace("open message_log file [{}]", message_log_file_name);
	}

	public void prepare_file()
	{
		client = new amqp_messages(hostname, port, vhost, exchange, login, passw);
		log.trace("create client");
		client.connect();

		log.trace("autotest run");

		for(long i = 0; i < count_repeat; i++)
		{
			parse_file(message_log_file_name, "\r", "\r\n\r\n\r\n", &prepare_block);
		}

		log.trace("autotest listen end, count commands: {}", count_commands);

		client.close();

	}

}

void get_message(byte* message, ulong message_size)
{
	log.trace("get_message, size={}", message_size);
	char* msg = cast(char*) message;

}

void prepare_block(char* line, ulong line_length)
{
	line[line_length] = 0;

	char* end_io_block = strstr(line, "\r\n\r\n\r\n");
	if(end_io_block !is null)
		*end_io_block = 0;

	//	log.trace("read new block {}", line[0 .. (end_io_block-line)]);

	char* input_data = strstr(line, "INPUT");

	if(input_data !is null)
	{
		input_data += 7;
	}

	output_data = strstr(input_data, "OUTPUT");

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

	if(size < 0)
		throw new Exception("autotest:prepare_block, size < 0");

	//	printf("\nINPUT %d: %s\n", size, input_data);

	//	printf("\nOUTPUT: %s\n", output_data);

	if(strstr(input_data, "magnet-ontology/authorization/functions#create") !is null && strstr(input_data, "<>") !is null && output_data !is null)
	{
		//		printf("\nINPUT %d: %s\n", size, input_data);

		//		printf("\nOUTPUT: %s\n", output_data);

		// это команда на создание записи авторизации

		char[] result_id_tag = "<magnet-ontology/transport#result:data>";

		char* result_id = strstr(output_data, result_id_tag.ptr);
		if(result_id !is null)
			result_id += result_id_tag.length;

		int size_id = strlen(result_id) - 2;
		char[] result_id_text = result_id[1 .. size_id];
		char[] qqq = input_data[0 .. size];

		//		auto rr = Regex(result_id_text).replaceAll ("<>", "<" ~ result_id_text ~ ">");
		//		printf("\nresult: %s\n", rr.ptr);

		auto input_data_text = new Text!(char)(qqq);
		while(strstr(input_data_text.toString().ptr, "<>") !is null)
		{
			input_data_text.select("<>");
			input_data_text.replace("<" ~ result_id_text ~ ">");
		}

		input_data = toStringz(input_data_text.toString());
		size = strlen(input_data);

	}

	message_sender(input_data, size);
	count_commands++;
}

private void message_sender(char* message, long size)
{
	//	log.trace("send message {}", message[0 .. size]);

	char[] str_template = "<magnet-ontology/transport/message#reply_to>";

	char* reply_to_start = strstr(message, str_template.ptr) + str_template.length + 1;
	char* reply_to_end = strstr(reply_to_start, "\".".ptr);
	char[] reply_to = reply_to_start[0 .. (reply_to_end - reply_to_start)];
	//	reply_to[reply_to_end - reply_to_start] = 0;

	if(reply_to !is null)
	{
		char[] qqq = "semargl-a";

		size = strlen(message);

//		log.trace("set reply_to={}", reply_to);
//		Stdout.format("set reply_to={}", reply_to).newline;
		client.set_listen_queue (reply_to);
		(new Thread(&client.listen)).start;
//        Thread.sleep(0.250);

		//		printf("\nmessage: %s\n", message);
		count_send_messages++;
//		log.trace("send message");
//		Stdout.format("send message {}", count_send_messages).newline;
		client.send(qqq, message);
		
//		log.trace("wait reply message");
//		Stdout.format("wait reply message").newline;
		while (client.result_out is null) {Thread.yield();};
//		log.trace("get reply message = {}", client.result_out);
//		Stdout.format("get reply message = {}", client.result_out).newline;
//		printf("\nout message: %s\n", client.result_out);
		client.result_out = null;
				
		

//		client.listen (reply_to);
//		log.trace("listen ok");


		if(count_send_messages % 100 == 0)
		{
			log.trace("count send messages: {}", count_send_messages);
		}

		//		client.set_callback(&get_message);
		//		client.listener();
	}
}