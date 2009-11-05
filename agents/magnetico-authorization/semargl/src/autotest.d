private import mom_client;
private import Log;
private import tango.io.File;
private import Text = tango.text.Util;

class autotest: mom_client
{
	private File file = null;
	private char[] content = null;
	void function(byte* txt, ulong size) message_acceptor;

	this(char[] message_log_file_name)
	{
		log.trace("open message_log file [{}]", message_log_file_name);
		file = new File(message_log_file_name);
		content = cast(char[]) file.read;
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
		foreach(line; Text.lines(content))
		{
			log.trace("line: {}", line);
		}

		// message_acceptor(message, *ptr_frame_payload_body_fragment_len);
	}
}