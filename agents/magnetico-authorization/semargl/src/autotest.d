private import mom_client;
private import Log;
private import tango.io.File;
private import Text = tango.text.Util;
private import portions_read;

class autotest: mom_client
{
	void function(byte* txt, ulong size) message_acceptor;
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

		// message_acceptor(message, *ptr_frame_payload_body_fragment_len);
		log.trace("autotest listen stop");
	}

}
void prepare_block(char* line, ulong line_length)
{
		log.trace("read new block {}", line [0..line_length]);
}


